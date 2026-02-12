from __future__ import annotations

from django.core.management.base import BaseCommand
from django.db import transaction

from apps.core.management.commands._legacy_db import fetchall_dicts
from apps.users.models import Role


class Command(BaseCommand):
    help = "Миграция ролей из legacy БД (roles). Идемпотентно."

    def handle(self, *args, **options):
        rows = fetchall_dicts("SELECT id, role_name FROM public.roles ORDER BY id")
        created = 0
        updated = 0

        with transaction.atomic():
            for r in rows:
                obj, is_created = Role.objects.update_or_create(
                    id=int(r["id"]),
                    defaults={"name": (r["role_name"] or "").strip()},
                )
                if is_created:
                    created += 1
                else:
                    updated += 1

        self.stdout.write(self.style.SUCCESS(f"Готово. created={created}, updated={updated}, total={len(rows)}"))

