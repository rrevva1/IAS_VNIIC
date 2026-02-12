"""
Вспомогательные функции для миграции данных из legacy БД (соединение `legacy`).
"""

from __future__ import annotations

import json
from datetime import datetime
from dataclasses import dataclass
from typing import Any, Iterable

from django.conf import settings
from django.db import connections
from django.utils import timezone


@dataclass(frozen=True)
class LegacyRow:
    data: dict[str, Any]

    def __getattr__(self, item: str) -> Any:  # pragma: no cover
        return self.data.get(item)


def get_legacy_connection():
    if "legacy" not in settings.DATABASES:
        raise RuntimeError(
            "Не настроено подключение к legacy БД. "
            "Добавьте LEGACY_DATABASE_URL в .env и перезапустите команду."
        )
    return connections["legacy"]


def fetchall_dicts(sql: str, params: Iterable[Any] | None = None) -> list[dict[str, Any]]:
    """Выполняет SQL в legacy БД и возвращает список dict-строк."""
    conn = get_legacy_connection()
    with conn.cursor() as cursor:
        cursor.execute(sql, params or [])
        cols = [c[0] for c in cursor.description]
        return [dict(zip(cols, row, strict=False)) for row in cursor.fetchall()]


def parse_attachment_ids(raw: Any) -> list[int]:
    """
    Парсит legacy поле `tasks.attachments` в список int.

    Поддерживаемые форматы:
    - JSON массив: [1,2,3]
    - PostgreSQL array: {1,2,3}
    - пусто/NULL → []
    """
    if raw is None:
        return []
    if isinstance(raw, list):
        return [int(x) for x in raw if str(x).isdigit()]
    if not isinstance(raw, str):
        return []

    s = raw.strip()
    if not s:
        return []

    # JSON
    if s.startswith("["):
        try:
            data = json.loads(s)
            if isinstance(data, list):
                return [int(x) for x in data if str(x).isdigit()]
        except Exception:
            return []

    # PostgreSQL array
    if s.startswith("{") and s.endswith("}"):
        body = s.strip("{}").strip()
        if not body:
            return []
        out: list[int] = []
        for part in body.split(","):
            part = part.strip().strip('"')
            if part.isdigit():
                out.append(int(part))
        return out

    return []


def ensure_aware(value: Any):
    """
    Приводит naive datetime (из legacy) к aware, используя TIME_ZONE проекта.
    Остальные типы возвращает без изменений.
    """
    if isinstance(value, datetime):
        if timezone.is_naive(value):
            return timezone.make_aware(value, timezone.get_current_timezone())
        return value
    return value

