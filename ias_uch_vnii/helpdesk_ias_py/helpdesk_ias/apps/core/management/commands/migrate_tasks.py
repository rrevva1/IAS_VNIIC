from __future__ import annotations

from django.core.management.base import BaseCommand
from django.db import transaction
from django.utils import timezone

from apps.core.management.commands._legacy_db import ensure_aware, fetchall_dicts
from apps.tasks.models import Task, TaskStatus
from apps.users.models import User


class Command(BaseCommand):
    help = "Миграция заявок из legacy БД (tasks). Идемпотентно."

    def handle(self, *args, **options):
        rows = fetchall_dicts(
            """
            SELECT
                id,
                status_id,
                description,
                user_id,
                date,
                last_time_update,
                comment,
                executor_id
            FROM public.tasks
            ORDER BY id
            """
        )

        created = 0
        updated = 0
        skipped_missing_fk = 0

        with transaction.atomic():
            for r in rows:
                task_id = int(r["id"])
                status_id = int(r["status_id"])
                creator_id = int(r["user_id"])
                executor_id = r.get("executor_id")
                executor_id = int(executor_id) if executor_id is not None else None

                if not TaskStatus.objects.filter(id=status_id).exists():
                    skipped_missing_fk += 1
                    self.stderr.write(f"[skip] task#{task_id}: нет TaskStatus id={status_id}")
                    continue
                if not User.objects.filter(id=creator_id).exists():
                    skipped_missing_fk += 1
                    self.stderr.write(f"[skip] task#{task_id}: нет User(creator) id={creator_id}")
                    continue
                if executor_id is not None and not User.objects.filter(id=executor_id).exists():
                    # В legacy бывает дрейф ссылок. Делаем executor NULL.
                    executor_id = None

                defaults = {
                    "description": (r.get("description") or "").strip(),
                    "status_id": status_id,
                    "creator_id": creator_id,
                    "executor_id": executor_id,
                    "comment": (r.get("comment") or "").strip(),
                    "created_at": ensure_aware(r.get("date") or timezone.now()),
                    "updated_at": ensure_aware(r.get("last_time_update") or r.get("date") or timezone.now()),
                }

                obj, is_created = Task.objects.update_or_create(id=task_id, defaults=defaults)
                if is_created:
                    created += 1
                else:
                    updated += 1

        self.stdout.write(
            self.style.SUCCESS(
                f"Готово. created={created}, updated={updated}, skipped_missing_fk={skipped_missing_fk}, total={len(rows)}"
            )
        )

