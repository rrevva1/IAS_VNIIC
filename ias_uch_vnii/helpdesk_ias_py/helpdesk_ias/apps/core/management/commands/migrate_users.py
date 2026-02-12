from __future__ import annotations

import re

from django.core.management.base import BaseCommand
from django.db import transaction
from django.utils import timezone

from apps.core.management.commands._legacy_db import ensure_aware, fetchall_dicts
from apps.users.models import Role, User


MD5_RE = re.compile(r"^[a-fA-F0-9]{32}$")


class Command(BaseCommand):
    help = "Миграция пользователей из legacy БД (users). Идемпотентно."

    def add_arguments(self, parser):
        parser.add_argument(
            "--set-staff-for-admin",
            action="store_true",
            help="Если роль = 'администратор', выставить is_staff=True (для Django admin).",
        )

    def handle(self, *args, **options):
        set_staff_for_admin: bool = bool(options["set_staff_for_admin"])

        rows = fetchall_dicts(
            """
            SELECT
                id,
                full_name,
                position,
                department,
                email,
                phone,
                created_at,
                password,
                role_id
            FROM public.users
            ORDER BY id
            """
        )

        created = 0
        updated = 0

        with transaction.atomic():
            for r in rows:
                role_id = r.get("role_id")
                role = Role.objects.filter(id=int(role_id)).first() if role_id is not None else None

                legacy_password = (r.get("password") or "").strip()
                legacy_md5 = legacy_password if MD5_RE.match(legacy_password) else ""

                defaults = {
                    "email": (r.get("email") or f"user{r['id']}@example.local").strip().lower(),
                    "full_name": (r.get("full_name") or "").strip() or f"Пользователь #{r['id']}",
                    "position": (r.get("position") or "").strip(),
                    "department": (r.get("department") or "").strip(),
                    "phone": (r.get("phone") or "").strip(),
                    "created_at": ensure_aware(r.get("created_at") or timezone.now()),
                    "role": role,
                    "legacy_password_md5": legacy_md5,
                    "is_active": True,
                }

                # is_staff для админов (опционально)
                if set_staff_for_admin and role and role.name == "администратор":
                    defaults["is_staff"] = True

                user, is_created = User.objects.update_or_create(id=int(r["id"]), defaults=defaults)

                # Важно: password Django делаем unusable, пока не пройдет апгрейд на первом логине
                if legacy_md5 and user.has_usable_password():
                    user.set_unusable_password()
                    user.save(update_fields=["password"])

                if is_created:
                    created += 1
                else:
                    updated += 1

        self.stdout.write(self.style.SUCCESS(f"Готово. created={created}, updated={updated}, total={len(rows)}"))

