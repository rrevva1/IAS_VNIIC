# Отчет: Фаза 2 (настройка Django проекта)

Дата: 2026-02-07

## Что сделано по задачам Фазы 2

### 1) Инициализирован Django проект и apps-структура

Создан Django-проект:
- `helpdesk_ias_py/helpdesk_ias/`
  - `config/` — настройки/urls/asgi/wsgi
  - `apps/` — пакет Django apps

Созданы приложения:
- `apps/core`
- `apps/users`
- `apps/tasks`
- `apps/assets`
- `apps/software`
- `apps/reports`
- `apps/procurement`
- `apps/audit`
- `apps/api`

### 2) `django-environ` для секретов

Добавлено чтение `.env` в `helpdesk_ias_py/helpdesk_ias/config/settings.py` через `django-environ`.

Добавлен шаблон переменных:
- `helpdesk_ias_py/helpdesk_ias/.env.example`

### 3) `django-debug-toolbar` (dev), `django-extensions`

Подключено:
- `django-extensions` — всегда (dev-утилиты).
- `django-debug-toolbar` — только при `DEBUG=true` (dev).

URL debug-toolbar:
- `__debug__/` (только в debug-режиме)

### 4) Логирование

Настроено логирование в 3 файла:
- `helpdesk_ias_py/helpdesk_ias/logs/app.log`
- `helpdesk_ias_py/helpdesk_ias/logs/security.log`
- `helpdesk_ias_py/helpdesk_ias/logs/audit.log`

## Файлы / артефакты

- `helpdesk_ias_py/requirements.txt` — зафиксированные зависимости.
- `helpdesk_ias_py/helpdesk_ias/config/settings.py` — env + logging + dev apps.
- `helpdesk_ias_py/helpdesk_ias/config/urls.py` — debug-toolbar url (dev).
- `helpdesk_ias_py/helpdesk_ias/.env.example` — пример переменных окружения.
- `helpdesk_ias_py/.gitignore` — игнор `.env`, `.venv`, логов и артефактов.

