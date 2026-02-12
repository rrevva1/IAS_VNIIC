from __future__ import annotations

from django.core.management.base import BaseCommand
from django.db import transaction
from django.utils import timezone

from apps.core.management.commands._legacy_db import ensure_aware, fetchall_dicts
from apps.tasks.models import Attachment


class Command(BaseCommand):
    help = "Миграция метаданных вложений из legacy БД (desk_attachments). Идемпотентно."

    def handle(self, *args, **options):
        rows = fetchall_dicts(
            """
            SELECT id, path, name, extension, created_at
            FROM public.desk_attachments
            ORDER BY id
            """
        )

        created = 0
        updated = 0

        with transaction.atomic():
            for r in rows:
                defaults = {
                    "path": (r.get("path") or "").strip(),
                    "name": (r.get("name") or "").strip(),
                    "extension": (r.get("extension") or "").strip(),
                    "created_at": ensure_aware(r.get("created_at") or timezone.now()),
                }
                obj, is_created = Attachment.objects.update_or_create(id=int(r["id"]), defaults=defaults)
                if is_created:
                    created += 1
                else:
                    updated += 1

        self.stdout.write(self.style.SUCCESS(f"Готово. created={created}, updated={updated}, total={len(rows)}"))

