"""
Модуль users.

Фаза 3: проектирование и реализация моделей.
"""

from __future__ import annotations

from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin
from django.contrib.auth.base_user import BaseUserManager
from django.db import models
from django.utils import timezone


class Role(models.Model):
    """Справочник ролей (legacy: `roles`)."""

    name = models.CharField("Роль", max_length=100, unique=True)

    class Meta:
        verbose_name = "Роль"
        verbose_name_plural = "Роли"
        db_table = "roles"

    def __str__(self) -> str:  # pragma: no cover
        return self.name


class UserManager(BaseUserManager):
    """Менеджер пользователей (обязателен для `createsuperuser`)."""

    def create_user(self, email: str, password: str | None = None, **extra_fields):
        if not email:
            raise ValueError("Email обязателен")
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        if password:
            user.set_password(password)
            user.legacy_password_md5 = ""
        else:
            user.set_unusable_password()
        user.save(using=self._db)
        return user

    def create_superuser(self, email: str, password: str, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        extra_fields.setdefault("is_active", True)
        return self.create_user(email=email, password=password, **extra_fields)


class User(AbstractBaseUser, PermissionsMixin):
    """
    Пользователь системы.

    Примечание:
    - На Фазе 4 будет миграция legacy-паролей (MD5) с прозрачным апгрейдом при логине.
    """

    email = models.EmailField("Email", max_length=255, unique=True)
    full_name = models.CharField("ФИО", max_length=200)
    position = models.CharField("Должность", max_length=100, blank=True)
    department = models.CharField("Отдел", max_length=100, blank=True)
    phone = models.CharField("Телефон", max_length=50, blank=True)

    role = models.ForeignKey(
        Role,
        on_delete=models.PROTECT,
        related_name="users",
        verbose_name="Роль",
        null=True,
        blank=True,
    )

    # Служебные поля (миграция с Yii2)
    legacy_password_md5 = models.CharField(
        "Legacy MD5 пароль",
        max_length=32,
        blank=True,
        default="",
        help_text="Сюда временно переносим legacy MD5-хеш для апгрейда при первом логине.",
    )

    is_active = models.BooleanField("Активен", default=True)
    is_staff = models.BooleanField("Доступ в админку", default=False)
    created_at = models.DateTimeField(
        "Создан",
        help_text="Дата создания пользователя в legacy системе (переносим как есть).",
        default=timezone.now,
    )

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS: list[str] = ["full_name"]
    objects = UserManager()

    class Meta:
        verbose_name = "Пользователь"
        verbose_name_plural = "Пользователи"
        db_table = "users"
        indexes = [
            models.Index(fields=["department"]),
            models.Index(fields=["role"]),
            models.Index(fields=["created_at"]),
        ]

    def __str__(self) -> str:  # pragma: no cover
        return f"{self.full_name} <{self.email}>"

    def is_admin(self) -> bool:
        if self.is_superuser:
            return True
        return bool(self.role and (self.role.name or "").strip().lower() == "администратор")

    def is_user(self) -> bool:
        return bool(self.role and (self.role.name or "").strip().lower() == "пользователь")

    def is_administrator(self) -> bool:
        return self.is_admin()

    def is_regular_user(self) -> bool:
        return self.is_user()
