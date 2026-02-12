from __future__ import annotations

from django.core.management.base import BaseCommand
from django.db import transaction

from apps.core.management.commands._legacy_db import fetchall_dicts, parse_attachment_ids
from apps.tasks.models import Attachment, Task, TaskAttachment


class Command(BaseCommand):
    help = "Миграция связи заявка↔вложение из legacy поля tasks.attachments (JSON). Идемпотентно."

    def handle(self, *args, **options):
        rows = fetchall_dicts("SELECT id, attachments FROM public.tasks ORDER BY id")
        created = 0
        skipped = 0
        total_links = 0

        with transaction.atomic():
            for r in rows:
                task_id = int(r["id"])
                if not Task.objects.filter(id=task_id).exists():
                    skipped += 1
                    continue

                attach_ids = parse_attachment_ids(r.get("attachments"))
                total_links += len(attach_ids)
                for aid in attach_ids:
                    if not Attachment.objects.filter(id=aid).exists():
                        skipped += 1
                        continue
                    _, is_created = TaskAttachment.objects.get_or_create(task_id=task_id, attachment_id=aid)
                    if is_created:
                        created += 1

        self.stdout.write(
            self.style.SUCCESS(
                f"Готово. created_links={created}, total_links_seen={total_links}, skipped={skipped}, tasks={len(rows)}"
            )
        )

