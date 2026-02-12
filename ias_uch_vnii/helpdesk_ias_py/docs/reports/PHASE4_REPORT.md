# Отчет: Фаза 4 (миграция данных и файлов)

Дата: 2026-02-07

## Цель фазы

- Management commands миграции (идемпотентно).
- Файлы: перенос/линковка из `/web/uploads/tasks/` в `MEDIA_ROOT`.
- Legacy MD5: хранение legacy‑хеша + апгрейд при логине (реализация backend — см. Фаза 5 в плане; фактически реализовано в рамках работ).
- Сверка целостности (counts + выборочные проверки).

## Реализовано

### 1) Подключение legacy БД

Файлы:
- `helpdesk_ias_py/helpdesk_ias/config/settings.py`
- `helpdesk_ias_py/helpdesk_ias/.env.example`

Сделано:
- Добавлена переменная окружения `LEGACY_DATABASE_URL`.
- При наличии `LEGACY_DATABASE_URL` создаётся подключение `DATABASES["legacy"]` (только для чтения при миграции).

### 2) Management commands (идемпотентно)

Расположение:
- `helpdesk_ias_py/helpdesk_ias/apps/core/management/commands/`

Команды:
- `migrate_roles` — `roles`
- `migrate_users` — `users` (с опцией `--set-staff-for-admin`)
- `migrate_task_statuses` — `dic_task_status`
- `migrate_attachments_meta` — `desk_attachments`
- `migrate_tasks` — `tasks`
- `migrate_task_attachments` — перенос `tasks.attachments` (JSON) в `task_attachments`
- `migrate_task_files` — перенос/линковка файлов в `MEDIA_ROOT/legacy/tasks/`
- `migrate_verify` — сверка counts + ожидаемые связи

Идемпотентность:
- Для основных сущностей сохраняется legacy PK (`id`) через `update_or_create(id=...)`.
- Для связей `task_attachments` используется `get_or_create(task_id=..., attachment_id=...)`.

### 3) Перенос файлов

Команда:
- `python manage.py migrate_task_files --src <dir> --mode copy|hardlink|symlink`

Поведение:
- кладёт файлы в `MEDIA_ROOT/legacy/tasks/`;
- обновляет `Attachment.path` на `legacy/tasks/<filename>`;
- повторный прогон: если файл уже есть и размер совпадает — пропуск.

### 4) Сверка целостности

Команда:
- `python manage.py migrate_verify`

Проверяет:
- counts по `roles/users/dic_task_status/tasks/desk_attachments`;
- количество связей `task_attachments` относительно `tasks.attachments` в legacy.

## Пример запуска (dev)

```bash
source helpdesk_ias_py/.venv/bin/activate
cd helpdesk_ias_py/helpdesk_ias

export LEGACY_DATABASE_URL='postgres://postgres:12345@localhost:5432/ias_vnii'

python manage.py migrate
python manage.py migrate_roles
python manage.py migrate_users --set-staff-for-admin
python manage.py migrate_task_statuses
python manage.py migrate_attachments_meta
python manage.py migrate_tasks
python manage.py migrate_task_attachments
python manage.py migrate_verify
```

