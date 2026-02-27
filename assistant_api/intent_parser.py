"""Парсер интентов по ключевым словам и шаблонам (re)."""
import re
from datetime import datetime, timedelta
from typing import Any, Dict, Optional, Tuple

from db import fetch_status_list

MY_TASKS_KEYWORDS = (
    "мои заявки", "мои обращения", "заявки где я автор", "где я автор",
    "заявки которые я создал", "созданные мной",
)
PERIOD_KEYWORDS = (
    "заявки за", "заявки за последние", "за последнюю", "за последний",
    "за месяц", "за неделю", "за квартал", "за год",
)
STATS_KEYWORDS = (
    "статистика", "статистика заявок", "сколько заявок", "отчёт по заявкам", "сводка заявок",
)
HELP_KEYWORDS = (
    "справка", "помощь", "как создать заявку", "как создать обращение", "инструкция", "подсказка",
)

DEFAULT_HINTS = [
    "«Мои заявки» — заявки, где вы автор",
    "«Заявки за месяц» — заявки за последние 30 дней",
    "«Открытые заявки» — заявки в статусе «В работе» или «Новая»",
    "«Статистика заявок» — сводка по пользователям и исполнителям",
    "«Справка» — подсказка по работе с системой",
]

HELP_TEXT = """В системе учёта технических средств вы можете:

• Создать заявку — раздел «Заявки» → кнопка создания заявки; укажите описание и при необходимости прикрепите файлы.
• Просматривать свои заявки и заявки, где вы назначены исполнителем (в разделе «Заявки»).
• Запросить у помощника: «Мои заявки», «Заявки за месяц», «Открытые заявки», «Статистика заявок». Результат можно открыть в соответствующем разделе по ссылке."""


def _matches_any(text: str, keywords: Tuple[str, ...]) -> bool:
    return any(kw in text for kw in keywords)


def _detect_period(text: str) -> Optional[Dict[str, Any]]:
    if not _matches_any(text, PERIOD_KEYWORDS):
        return None
    now = datetime.now()
    date_to = now.strftime("%Y-%m-%d")
    if re.search(r"недел[ию]|последнюю\s+недел", text):
        date_from = (now - timedelta(days=7)).strftime("%Y-%m-%d")
        label = "Заявки за последнюю неделю."
    elif re.search(r"месяц|последний\s+месяц", text):
        date_from = (now - timedelta(days=30)).strftime("%Y-%m-%d")
        label = "Заявки за последний месяц."
    elif re.search(r"квартал", text):
        date_from = (now - timedelta(days=90)).strftime("%Y-%m-%d")
        label = "Заявки за последний квартал."
    elif re.search(r"год", text):
        date_from = (now - timedelta(days=365)).strftime("%Y-%m-%d")
        label = "Заявки за последний год."
    else:
        date_from = (now - timedelta(days=30)).strftime("%Y-%m-%d")
        label = "Заявки за последний месяц."
    return {"date_from": date_from, "date_to": date_to, "interpretation": label}


def _detect_status(text: str) -> Optional[Dict[str, Any]]:
    status_rows = fetch_status_list()
    status_by_code = {r["status_code"]: r for r in status_rows}
    map_code_to_words = {
        "open": ["открытые", "новые", "новая", "открытая"],
        "in_progress": ["в работе"],
        "resolved": ["закрытые", "выполненные", "закрыта", "выполнена", "решен"],
        "closed": ["закрытые", "выполненные"],
    }
    for code, words in map_code_to_words.items():
        for w in words:
            if w in text:
                row = status_by_code.get(code) or (status_by_code.get("closed") if code == "resolved" else None)
                if row:
                    return {
                        "status_id": row["id"],
                        "interpretation": f"Заявки со статусом «{row['status_name']}».",
                    }
    for row in status_rows:
        if row["status_name"] and row["status_name"].lower() in text:
            return {
                "status_id": row["id"],
                "interpretation": f"Заявки со статусом «{row['status_name']}».",
            }
    return None


def parse(message: str, user_id: Optional[int]) -> Dict[str, Any]:
    """Разбирает сообщение и возвращает intent, params, interpretation, link, hints, helpText (опционально)."""
    text = (message or "").strip().lower()
    if not text:
        return {
            "intent": None,
            "params": {},
            "interpretation": "Уточните, пожалуйста, что вы ищете.",
            "link": None,
            "hints": DEFAULT_HINTS,
        }

    if _matches_any(text, HELP_KEYWORDS):
        return {
            "intent": "help",
            "params": {},
            "interpretation": "Справка по системе.",
            "link": None,
            "hints": [],
            "helpText": HELP_TEXT,
        }

    if _matches_any(text, MY_TASKS_KEYWORDS) and user_id:
        return {
            "intent": "my_tasks",
            "params": {"requester_id": user_id},
            "interpretation": "Поиск заявок, где вы автор.",
            "link": {"label": "Открыть в разделе Заявки", "path": "tasks/index", "params": {"TasksSearch": {"requester_id": user_id}}},
            "hints": [],
        }

    period = _detect_period(text)
    if period:
        params = {"date_from": period["date_from"], "date_to": period["date_to"]}
        return {
            "intent": "tasks_period",
            "params": params,
            "interpretation": period["interpretation"],
            "link": {"label": "Открыть в разделе Заявки", "path": "tasks/index", "params": {"TasksSearch": params}},
            "hints": [],
        }

    status_intent = _detect_status(text)
    if status_intent:
        params = {"status_id": status_intent["status_id"]}
        return {
            "intent": "tasks_status",
            "params": params,
            "interpretation": status_intent["interpretation"],
            "link": {"label": "Открыть в разделе Заявки", "path": "tasks/index", "params": {"TasksSearch": params}},
            "hints": [],
        }

    if _matches_any(text, STATS_KEYWORDS):
        return {
            "intent": "statistics",
            "params": {},
            "interpretation": "Статистика заявок по пользователям и исполнителям.",
            "link": {"label": "Открыть раздел Статистика заявок", "path": "tasks/statistics", "params": {}},
            "hints": [],
        }

    if re.match(r"^(покажи\s+)?(все\s+)?заявки?$", text) or re.match(r"^заявки?\s*$", text):
        return {
            "intent": "tasks_all",
            "params": {},
            "interpretation": "Список заявок (с учётом ваших прав доступа).",
            "link": {"label": "Открыть в разделе Заявки", "path": "tasks/index", "params": {}},
            "hints": [],
        }

    return {
        "intent": None,
        "params": {},
        "interpretation": "Не удалось однозначно понять запрос.",
        "link": None,
        "hints": DEFAULT_HINTS,
    }
