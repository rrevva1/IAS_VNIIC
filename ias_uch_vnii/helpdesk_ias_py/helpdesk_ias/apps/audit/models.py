"""
Модуль audit (аудит критичных действий).

Фаза 3: минимальная модель AuditEvent + индексы.
"""

from __future__ import annotations

from django.conf import settings
from django.db import models


class AuditEvent(models.Model):
    """Аудит-событие (критичные операции)."""

    created_at = models.DateTimeField("Дата", auto_now_add=True)
    request_id = models.CharField("Request ID", max_length=64, blank=True, default="")

    actor = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        related_name="audit_events",
        verbose_name="Пользователь",
        null=True,
        blank=True,
    )

    action = models.CharField("Действие", max_length=200)
    object_type = models.CharField("Тип объекта", max_length=100, blank=True, default="")
    object_id = models.CharField("ID объекта", max_length=100, blank=True, default="")
    payload = models.JSONField("Данные", blank=True, default=dict)

    ip = models.GenericIPAddressField("IP", null=True, blank=True)
    user_agent = models.TextField("User-Agent", blank=True)

    class Meta:
        verbose_name = "Событие аудита"
        verbose_name_plural = "События аудита"
        db_table = "audit_events"
        indexes = [
            models.Index(fields=["created_at"]),
            models.Index(fields=["actor"]),
            models.Index(fields=["action"]),
            models.Index(fields=["object_type", "object_id"]),
            models.Index(fields=["request_id"]),
        ]
