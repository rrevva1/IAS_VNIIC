"""
Сервисный слой для модуля Help Desk (tasks).

Фаза 5:
- вынести бизнес-логику из views в сервисы,
- обеспечить транзакционность операций «БД + файлы»,
- логировать критичные действия в аудит.
"""

from __future__ import annotations

import shutil
import time
import uuid
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

from django.conf import settings
from django.core.exceptions import ValidationError
from django.core.files.storage import default_storage
from django.db import transaction
from django.utils import timezone
from django.utils.text import slugify

from apps.audit.services import AuditService
from apps.tasks.models import Attachment, Task, TaskAttachment, TaskStatus

MAX_FILES = 10
MAX_FILE_SIZE = 10 * 1024 * 1024
ALLOWED_EXTENSIONS = {"jpg", "jpeg", "png", "gif", "pdf", "doc", "docx", "xls", "xlsx", "txt"}


def save_attachments(task: Task, files) -> list[Attachment]:
    if not files:
        return []

    if len(files) > MAX_FILES:
        raise ValidationError(f"Можно загрузить не более {MAX_FILES} файлов.")

    saved: list[Attachment] = []
    for file in files:
        ext = Path(file.name).suffix.lstrip(".").lower()
        if ext not in ALLOWED_EXTENSIONS:
            raise ValidationError(f"Недопустимый тип файла: {file.name}")
        if file.size > MAX_FILE_SIZE:
            raise ValidationError(f"Файл слишком большой: {file.name}")

        base = slugify(Path(file.name).stem) or "file"
        filename = f"{int(time.time())}_{base}.{ext}"
        rel_path = f"uploads/tasks/{filename}"
        stored_path = default_storage.save(rel_path, file)

        att = Attachment.objects.create(
            path=stored_path,
            name=file.name,
            extension=ext,
        )
        TaskAttachment.objects.create(task=task, attachment=att)
        saved.append(att)

    return saved


def delete_attachment(att: Attachment) -> None:
    if att.path:
        try:
            default_storage.delete(att.path)
        except Exception:
            pass
    att.delete()


@dataclass(frozen=True)
class SavedFile:
    tmp_path: Path
    final_rel: str
    original_name: str


class TaskService:
    def __init__(self, *, audit: AuditService | None = None):
        self._audit = audit or AuditService()

    def create_task(self, *, creator, description: str, status: TaskStatus, executor=None, comment: str = "") -> Task:
        with transaction.atomic():
            task = Task.objects.create(
                description=description,
                status=status,
                creator=creator,
                executor=executor,
                comment=comment or "",
                created_at=timezone.now(),
                updated_at=timezone.now(),
            )
            self._audit.log_event(
                actor=creator,
                action="task.create",
                object_type="Task",
                object_id=str(task.pk),
                payload={"description_len": len(description or "")},
            )
            return task

    def change_status(self, *, actor, task: Task, new_status: TaskStatus) -> Task:
        with transaction.atomic():
            task.status = new_status
            task.updated_at = timezone.now()
            task.save(update_fields=["status", "updated_at"])
            self._audit.log_event(
                actor=actor,
                action="task.change_status",
                object_type="Task",
                object_id=str(task.pk),
                payload={"status_id": new_status.pk},
            )
            return task

    def assign_executor(self, *, actor, task: Task, executor) -> Task:
        with transaction.atomic():
            task.executor = executor
            task.updated_at = timezone.now()
            task.save(update_fields=["executor", "updated_at"])
            self._audit.log_event(
                actor=actor,
                action="task.assign_executor",
                object_type="Task",
                object_id=str(task.pk),
                payload={"executor_id": getattr(executor, "pk", None)},
            )
            return task

    def update_comment(self, *, actor, task: Task, comment: str) -> Task:
        with transaction.atomic():
            task.comment = comment or ""
            task.updated_at = timezone.now()
            task.save(update_fields=["comment", "updated_at"])
            self._audit.log_event(
                actor=actor,
                action="task.update_comment",
                object_type="Task",
                object_id=str(task.pk),
                payload={"comment_len": len(comment or "")},
            )
            return task

    def add_attachments(self, *, actor, task: Task, files: Iterable) -> list[Attachment]:
        """
        Прикрепляет файлы к задаче.

        `files` — iterable объектов, похожих на Django UploadedFile (имеют `.name` и `.chunks()`).
        """
        saved_files: list[SavedFile] = []
        created_attachments: list[Attachment] = []

        media_root = Path(settings.MEDIA_ROOT)
        tmp_dir = media_root / "tmp"
        tmp_dir.mkdir(parents=True, exist_ok=True)

        today = timezone.now().date()
        final_dir = media_root / "task_attachments" / f"{today:%Y}" / f"{today:%m}" / f"{today:%d}"
        final_dir.mkdir(parents=True, exist_ok=True)

        with transaction.atomic():
            # 1) Пишем во временные файлы
            for f in files:
                original_name = getattr(f, "name", "file")
                ext = Path(original_name).suffix.lstrip(".").lower()[:10]
                token = uuid.uuid4().hex
                tmp_path = tmp_dir / f"{token}.upload"
                final_name = f"{token}_{Path(original_name).name}"
                final_rel = f"task_attachments/{today:%Y}/{today:%m}/{today:%d}/{final_name}"

                with tmp_path.open("wb") as out:
                    for chunk in f.chunks():
                        out.write(chunk)

                saved_files.append(SavedFile(tmp_path=tmp_path, final_rel=final_rel, original_name=original_name))

                # 2) Создаем записи (в рамках транзакции)
                att = Attachment.objects.create(
                    path=final_rel,
                    name=original_name,
                    extension=ext,
                    created_at=timezone.now(),
                )
                TaskAttachment.objects.get_or_create(task=task, attachment=att)
                created_attachments.append(att)

            # 3) Финализируем файлы только после коммита
            def _finalize():
                for s in saved_files:
                    dst = media_root / s.final_rel
                    dst.parent.mkdir(parents=True, exist_ok=True)
                    shutil.move(str(s.tmp_path), str(dst))

            transaction.on_commit(_finalize)

            self._audit.log_event(
                actor=actor,
                action="task.add_attachments",
                object_type="Task",
                object_id=str(task.pk),
                payload={"count": len(created_attachments)},
            )

        return created_attachments

    def remove_attachment(self, *, actor, task: Task, attachment: Attachment) -> None:
        with transaction.atomic():
            TaskAttachment.objects.filter(task=task, attachment=attachment).delete()
            self._audit.log_event(
                actor=actor,
                action="task.remove_attachment",
                object_type="Task",
                object_id=str(task.pk),
                payload={"attachment_id": attachment.pk},
            )
