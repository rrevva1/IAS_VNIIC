from __future__ import annotations

from django.core.management.base import BaseCommand

from apps.core.management.commands._legacy_db import fetchall_dicts, parse_attachment_ids
from apps.tasks.models import Attachment, Task, TaskAttachment, TaskStatus
from apps.users.models import Role, User


class Command(BaseCommand):
    help = "Сверка целостности миграции (counts + выборочные проверки)."

    def handle(self, *args, **options):
        legacy_counts = {
            "roles": fetchall_dicts("SELECT COUNT(*) AS c FROM public.roles")[0]["c"],
            "users": fetchall_dicts("SELECT COUNT(*) AS c FROM public.users")[0]["c"],
            "statuses": fetchall_dicts("SELECT COUNT(*) AS c FROM public.dic_task_status")[0]["c"],
            "tasks": fetchall_dicts("SELECT COUNT(*) AS c FROM public.tasks")[0]["c"],
            "attachments": fetchall_dicts("SELECT COUNT(*) AS c FROM public.desk_attachments")[0]["c"],
        }

        new_counts = {
            "roles": Role.objects.count(),
            "users": User.objects.count(),
            "statuses": TaskStatus.objects.count(),
            "tasks": Task.objects.count(),
            "attachments": Attachment.objects.count(),
            "task_attachments": TaskAttachment.objects.count(),
        }

        self.stdout.write("=== COUNTS (legacy → new) ===")
        for k in ["roles", "users", "statuses", "tasks", "attachments"]:
            self.stdout.write(f"{k}: {legacy_counts[k]} → {new_counts[k]}")
        self.stdout.write(f"task_attachments(new): {new_counts['task_attachments']}")

        # Проверка ссылок из tasks.attachments → task_attachments
        legacy_rows = fetchall_dicts("SELECT id, attachments FROM public.tasks ORDER BY id")
        expected_links = 0
        for r in legacy_rows:
            expected_links += len(parse_attachment_ids(r.get("attachments")))

        self.stdout.write("=== LINKS ===")
        self.stdout.write(f"expected_links(from legacy tasks.attachments): {expected_links}")
        self.stdout.write(f"actual_links(task_attachments): {new_counts['task_attachments']}")

        self.stdout.write(self.style.SUCCESS("Проверка завершена (см. вывод выше)."))

