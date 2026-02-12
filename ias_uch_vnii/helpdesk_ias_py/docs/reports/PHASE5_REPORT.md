# Отчет: Фаза 5 (реализация бизнес-логики)

Дата: 2026-02-07

## Цель фазы

- Сервисный слой: `TaskService`, `AttachmentService` (в рамках tasks), `AssetService`, `LicenseService`, `ReportService` (каркас/дальше).
- Политики доступа, аудит критичных действий.
- Транзакционность операций “БД + файлы”.

## Реализовано (по текущему scope: Help Desk)

### 1) Сервисный слой

Файл:
- `helpdesk_ias_py/helpdesk_ias/apps/tasks/services.py`

Сделано:
- `TaskService` (create/change_status/assign_executor/update_comment/add_attachments/remove_attachment).
- Для `add_attachments` реализована схема “БД + файлы” через `transaction.on_commit()`:\n  файл сначала пишется во временную папку `MEDIA_ROOT/tmp/`, и только после успешного коммита переносится в финальный путь.

### 2) Политики доступа

Файл:
- `helpdesk_ias_py/helpdesk_ias/apps/tasks/policies.py`

Сделано:
- `TaskPolicy` (`can_view/can_edit/can_change_status/can_assign_executor/can_manage_attachments`).
- Админ определяется по `role.name == 'администратор'` (или `is_superuser`).

### 3) Аудит

Файл:
- `helpdesk_ias_py/helpdesk_ias/apps/audit/services.py`

Сделано:
- `AuditService.log_event(...)` пишет в `audit_events`.
- `TaskService` пишет аудит на ключевые операции.

### 4) Безопасные эндпоинты вложений (минимум)

Файлы:
- `helpdesk_ias_py/helpdesk_ias/apps/tasks/views.py`
- `helpdesk_ias_py/helpdesk_ias/apps/tasks/urls.py`
- `helpdesk_ias_py/helpdesk_ias/config/urls.py`

Маршруты:
- `GET /tasks/<task_id>/attachments/<attachment_id>/download/`
- `GET /tasks/<task_id>/attachments/<attachment_id>/preview/`

Безопасность:
- проверка логина + `TaskPolicy.can_view`;
- проверка принадлежности вложения задаче (`task_attachments`);
- preview разрешён только для: `pdf/png/jpg/jpeg/gif/bmp` (SVG inline запрещён);\n  добавлен `X-Content-Type-Options: nosniff`.

