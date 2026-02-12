"""
Backend для прозрачного апгрейда legacy MD5 паролей при первом логине.

Логика:
- если стандартная проверка пароля не прошла (или пароль unusable),
  но в `legacy_password_md5` есть значение, то проверяем md5(raw).
- при успехе: устанавливаем Django-хеш, очищаем legacy поле.
"""

from __future__ import annotations

import hashlib

from django.contrib.auth import get_user_model
from django.contrib.auth.backends import ModelBackend
from django.db import transaction
import logging

logger = logging.getLogger("security")


class LegacyMd5Backend(ModelBackend):
    def authenticate(self, request, username=None, password=None, **kwargs):
        if not username or not password:
            return None

        User = get_user_model()
        # username в нашем проекте = email
        email = (username or kwargs.get("email") or "").strip().lower()
        if not email:
            return None

        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return None

        if not user.is_active:
            return None

        legacy_md5 = (getattr(user, "legacy_password_md5", "") or "").strip().lower()
        if not legacy_md5:
            return None

        raw_md5 = hashlib.md5(password.encode("utf-8")).hexdigest()
        if raw_md5 != legacy_md5:
            return None

        # Апгрейд пароля атомарно
        with transaction.atomic():
            user.set_password(password)
            user.legacy_password_md5 = ""
            user.save(update_fields=["password", "legacy_password_md5"])

        logger.info("Апгрейд legacy MD5 пароля при логине. user_id=%s", user.pk)
        return user

