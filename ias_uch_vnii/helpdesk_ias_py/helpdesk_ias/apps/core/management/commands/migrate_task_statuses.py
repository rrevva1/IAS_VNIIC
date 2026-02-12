from __future__ import annotations

from django.core.management.base import BaseCommand
from django.db import transaction

from apps.core.management.commands._legacy_db import fetchall_dicts
from apps.tasks.models import TaskStatus


class Command(BaseCommand):
    help = "Миграция статусов задач из legacy БД (dic_task_status). Идемпотентно."

    def handle(self, *args, **options):
        rows = fetchall_dicts("SELECT id, status_name FROM public.dic_task_status ORDER BY id")
        created = 0
        updated = 0

        with transaction.atomic():
            for r in rows:
                obj, is_created = TaskStatus.objects.update_or_create(
                    id=int(r["id"]),
                    defaults={"name": (r["status_name"] or "").strip()},
                )
                if is_created:
                    created += 1
                else:
                    updated += 1

        self.stdout.write(self.style.SUCCESS(f"Готово. created={created}, updated={updated}, total={len(rows)}"))

