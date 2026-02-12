from __future__ import annotations

from typing import Any

from django.utils import timezone

from apps.audit.models import AuditEvent


class AuditService:
    """Сервис записи аудит-событий."""

    def log_event(
        self,
        *,
        actor,
        action: str,
        object_type: str = "",
        object_id: str = "",
        payload: dict[str, Any] | None = None,
        request_id: str = "",
        ip: str | None = None,
        user_agent: str = "",
    ) -> AuditEvent:
        return AuditEvent.objects.create(
            created_at=timezone.now(),
            request_id=request_id or "",
            actor=actor if actor and getattr(actor, "is_authenticated", False) else None,
            action=action,
            object_type=object_type or "",
            object_id=str(object_id or ""),
            payload=payload or {},
            ip=ip,
            user_agent=user_agent or "",
        )

