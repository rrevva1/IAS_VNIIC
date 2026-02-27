"""Подключение к PostgreSQL и запросы с учётом прав (RBAC)."""
from datetime import datetime
from typing import Any, List, Dict, Optional

import psycopg2
from psycopg2.extras import RealDictCursor

from config import get_settings


def get_connection():
    s = get_settings()
    conn = psycopg2.connect(
        host=s.db_host,
        port=s.db_port,
        dbname=s.db_name,
        user=s.db_user,
        password=s.db_password,
        options=f"-c search_path={s.db_schema}",
    )
    return conn


def fetch_tasks(
    user_id: int,
    is_admin: bool,
    is_operator: bool,
    requester_id: Optional[int] = None,
    date_from: Optional[str] = None,
    date_to: Optional[str] = None,
    status_id: Optional[int] = None,
) -> List[Dict[str, Any]]:
    """Список заявок с учётом прав: пользователь — свои/исполнитель, админ/оператор — все."""
    conn = get_connection()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            sql = """
                SELECT t.id, t.description, t.created_at,
                       s.status_name,
                       u_req.full_name AS user_name,
                       u_ex.full_name AS executor_name
                FROM tasks t
                LEFT JOIN dic_task_status s ON s.id = t.status_id
                LEFT JOIN users u_req ON u_req.id = t.requester_id
                LEFT JOIN users u_ex ON u_ex.id = t.executor_id
                WHERE 1=1
            """
            params: List[Any] = []
            n = 0
            if not is_admin and not is_operator:
                n += 1
                sql += f" AND (t.requester_id = %s OR t.executor_id = %s)"
                params.extend([user_id, user_id])
            if requester_id is not None:
                n += 1
                sql += f" AND t.requester_id = %s"
                params.append(requester_id)
            if date_from:
                n += 1
                sql += f" AND t.created_at >= %s::timestamp"
                params.append(date_from + " 00:00:00")
            if date_to:
                n += 1
                sql += f" AND t.created_at <= %s::timestamp"
                params.append(date_to + " 23:59:59")
            if status_id is not None:
                n += 1
                sql += f" AND t.status_id = %s"
                params.append(status_id)
            sql += " ORDER BY t.id DESC"
            cur.execute(sql, params)
            rows = cur.fetchall()
        return [dict(r) for r in rows]
    finally:
        conn.close()


def format_task_date(created_at) -> str:
    if created_at is None:
        return ""
    if isinstance(created_at, datetime):
        return created_at.strftime("%d.%m.%Y %H:%M")
    return str(created_at)[:16].replace("-", ".").replace("T", " ")


def fetch_status_list() -> List[Dict[str, Any]]:
    conn = get_connection()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT id, status_code, status_name FROM dic_task_status ORDER BY COALESCE(sort_order, 0), id")
            return [dict(r) for r in cur.fetchall()]
    finally:
        conn.close()


def fetch_statistics() -> tuple:
    """Статистика по авторам и по исполнителям (завершённые). Возвращает (user_rows, executor_rows, total_tasks, total_resolved)."""
    conn = get_connection()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                SELECT id FROM dic_task_status
                WHERE status_code IN ('resolved', 'closed') ORDER BY status_code LIMIT 1
            """)
            row = cur.fetchone()
            resolved_id = row["id"] if row else None
            cur.execute("""
                SELECT u.full_name AS name, COUNT(*) AS count
                FROM tasks t
                LEFT JOIN users u ON u.id = t.requester_id
                GROUP BY t.requester_id, u.full_name
            """)
            user_stats = [dict(r) for r in cur.fetchall()]
            if resolved_id is not None:
                cur.execute("""
                    SELECT u.full_name AS name, COUNT(*) AS count
                    FROM tasks t
                    JOIN users u ON u.id = t.executor_id
                    WHERE t.status_id = %s AND t.executor_id IS NOT NULL
                    GROUP BY t.executor_id, u.full_name
                """, (resolved_id,))
                executor_stats = [dict(r) for r in cur.fetchall()]
            else:
                executor_stats = []
            total_tasks = sum(s["count"] for s in user_stats)
            total_resolved = sum(s["count"] for s in executor_stats)
        return user_stats, executor_stats, total_tasks, total_resolved
    finally:
        conn.close()


def get_user_name(user_id: int) -> str:
    conn = get_connection()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT full_name FROM users WHERE id = %s", (user_id,))
            r = cur.fetchone()
            return r["full_name"] if r else "Неизвестный пользователь"
    finally:
        conn.close()
