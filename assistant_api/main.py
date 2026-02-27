"""FastAPI-приложение микросервиса ИИ-помощника."""
from typing import Any, Dict

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

from db import fetch_tasks, fetch_statistics, format_task_date
from intent_parser import parse

app = FastAPI(title="Assistant API", version="1.0")


@app.get("/")
def root():
    """Корневой путь: подсказка по API."""
    return {
        "service": "Assistant API",
        "docs": "/docs",
        "health": "/health",
        "query": "POST /query",
    }


class QueryRequest(BaseModel):
    message: str
    user_id: int
    is_admin: bool = False
    is_operator: bool = False


def _handle_query(req: QueryRequest) -> Dict[str, Any]:
    """Общая логика обработки запроса."""
    try:
        result = parse(req.message.strip(), req.user_id)
        response = {
            "success": True,
            "interpretation": result["interpretation"],
        }
        if result.get("hints"):
            response["hints"] = result["hints"]
        if result.get("helpText") is not None:
            response["helpText"] = result["helpText"]
            response["data"] = []
            response["total"] = 0
            return response
        if result.get("link") is not None:
            response["link"] = result["link"]
        if result.get("intent") == "statistics":
            user_stats, executor_stats, total_tasks, total_resolved = fetch_statistics()
            rows = []
            rows.append({"type": "header", "title": "По авторам заявок"})
            for s in user_stats:
                name = s.get("name") or "Неизвестный пользователь"
                count = int(s["count"])
                pct = round((count / total_tasks) * 100, 1) if total_tasks else 0
                rows.append({"type": "row", "name": name, "count": count, "percentage": f"{pct}%"})
            rows.append({"type": "header", "title": "По исполнителям (завершённые заявки)"})
            for s in executor_stats:
                name = s.get("name") or "Неизвестный исполнитель"
                count = int(s["count"])
                pct = round((count / total_resolved) * 100, 1) if total_resolved else 0
                rows.append({"type": "row", "name": name, "count": count, "percentage": f"{pct}%"})
            response["data"] = rows
            response["total"] = len(rows)
            response["summary"] = {"total_tasks": total_tasks, "total_resolved": total_resolved}
            return response
        if result.get("intent") in ("my_tasks", "tasks_period", "tasks_status", "tasks_all"):
            p = result.get("params") or {}
            rows = fetch_tasks(
                user_id=req.user_id,
                is_admin=req.is_admin,
                is_operator=req.is_operator,
                requester_id=p.get("requester_id"),
                date_from=p.get("date_from"),
                date_to=p.get("date_to"),
                status_id=p.get("status_id"),
            )
            data = []
            for r in rows:
                data.append({
                    "id": r["id"],
                    "description": r.get("description") or "",
                    "status_name": r.get("status_name") or "",
                    "user_name": r.get("user_name") or "",
                    "executor_name": r.get("executor_name") or "",
                    "date": format_task_date(r.get("created_at")),
                })
            response["data"] = data
            response["total"] = len(data)
            return response
        response["data"] = []
        response["total"] = 0
        return response
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/query")
def query(req: QueryRequest) -> Dict[str, Any]:
    """Обработка запроса пользователя. POST с телом: message, user_id, is_admin, is_operator."""
    return _handle_query(req)


@app.post("/query/")
def query_trailing_slash(req: QueryRequest) -> Dict[str, Any]:
    """Дубликат для URL с завершающим слэшем."""
    return _handle_query(req)


@app.post("/api/query")
def query_api(req: QueryRequest) -> Dict[str, Any]:
    """Тот же endpoint по пути /api/query (если используется префикс)."""
    return _handle_query(req)


@app.get("/health")
def health():
    return {"status": "ok"}
