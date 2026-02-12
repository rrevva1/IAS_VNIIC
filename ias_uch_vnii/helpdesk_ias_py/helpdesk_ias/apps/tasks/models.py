"""
Модуль tasks (Help Desk).

Ключевое требование Фазы 3:
- вложения должны быть нормализованы через FK/таблицу связи, без JSON в tasks.
"""

from __future__ import annotations

from django.conf import settings
from django.db import models
from django.utils import timezone


class TaskStatus(models.Model):
    """Справочник статусов заявок (legacy: `dic_task_status`)."""

    name = models.CharField("Статус", max_length=50, unique=True)

    class Meta:
        verbose_name = "Статус заявки"
        verbose_name_plural = "Статусы заявок"
        db_table = "dic_task_status"

    def __str__(self) -> str:  # pragma: no cover
        return self.name


class Attachment(models.Model):
    """Вложение (legacy: `desk_attachments`)."""

    path = models.CharField("Путь к файлу", max_length=500)
    name = models.CharField("Имя файла", max_length=255)
    extension = models.CharField("Расширение", max_length=10)
    created_at = models.DateTimeField(
        "Создано",
        default=timezone.now,
        help_text="Дата создания вложения в legacy системе (переносим как есть).",
    )

    class Meta:
        verbose_name = "Вложение"
        verbose_name_plural = "Вложения"
        db_table = "desk_attachments"
        indexes = [
            models.Index(fields=["name"]),
            models.Index(fields=["created_at"]),
        ]

    def __str__(self) -> str:  # pragma: no cover
        return self.name


class Task(models.Model):
    """Заявка Help Desk (legacy: `tasks`)."""

    description = models.TextField("Описание")
    status = models.ForeignKey(
        TaskStatus,
        on_delete=models.PROTECT,
        related_name="tasks",
        verbose_name="Статус",
    )

    creator = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name="created_tasks",
        verbose_name="Автор",
    )
    executor = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        related_name="assigned_tasks",
        verbose_name="Исполнитель",
        null=True,
        blank=True,
    )

    created_at = models.DateTimeField(
        "Создана",
        default=timezone.now,
        help_text="Дата создания заявки в legacy системе (переносим как есть).",
    )
    updated_at = models.DateTimeField(
        "Обновлена",
        default=timezone.now,
        help_text="Дата последнего обновления заявки в legacy системе (переносим как есть).",
    )
    comment = models.TextField("Комментарий", blank=True)

    attachments = models.ManyToManyField(
        Attachment,
        through="TaskAttachment",
        related_name="tasks",
        verbose_name="Вложения",
        blank=True,
    )

    class Meta:
        verbose_name = "Заявка"
        verbose_name_plural = "Заявки"
        db_table = "tasks"
        indexes = [
            models.Index(fields=["status"]),
            models.Index(fields=["creator"]),
            models.Index(fields=["executor"]),
            models.Index(fields=["created_at"]),
            models.Index(fields=["updated_at"]),
        ]

    def __str__(self) -> str:  # pragma: no cover
        return f"Заявка #{self.pk}"


class TaskAttachment(models.Model):
    """Связь заявка ↔ вложение (нормализация; вместо JSON в tasks)."""

    task = models.ForeignKey(Task, on_delete=models.CASCADE)
    attachment = models.ForeignKey(Attachment, on_delete=models.CASCADE)
    attached_at = models.DateTimeField("Прикреплено", auto_now_add=True)

    class Meta:
        verbose_name = "Вложение заявки"
        verbose_name_plural = "Вложения заявок"
        db_table = "task_attachments"
        constraints = [
            models.UniqueConstraint(
                fields=["task", "attachment"],
                name="uq_task_attachment",
            )
        ]
