"""
Политики доступа для Help Desk.

Пока используем простые правила, близкие к текущему Yii2:
- администратор видит всё,
- обычный пользователь видит только свои заявки.
"""

from __future__ import annotations


def is_admin(user) -> bool:
    if not user or not getattr(user, "is_authenticated", False):
        return False
    if getattr(user, "is_superuser", False):
        return True
    role = getattr(user, "role", None)
    return bool(role and getattr(role, "name", "") == "администратор")


class TaskPolicy:
    @staticmethod
    def can_view(user, task) -> bool:
        if is_admin(user):
            return True
        if not user or not getattr(user, "is_authenticated", False):
            return False
        return task.creator_id == user.id or task.executor_id == user.id

    @staticmethod
    def can_edit(user, task) -> bool:
        # На старте разрешим редактировать только автору (или админу).
        if is_admin(user):
            return True
        return bool(user and getattr(user, "is_authenticated", False) and task.creator_id == user.id)

    @staticmethod
    def can_change_status(user, task) -> bool:
        # Админ может всё; исполнитель может менять статус своей задачи.
        if is_admin(user):
            return True
        return bool(user and getattr(user, "is_authenticated", False) and task.executor_id == user.id)

    @staticmethod
    def can_assign_executor(user, task) -> bool:
        # На старте: только админ.
        return is_admin(user)

    @staticmethod
    def can_manage_attachments(user, task) -> bool:
        # Вложения: автор/исполнитель/админ.
        return TaskPolicy.can_view(user, task)

