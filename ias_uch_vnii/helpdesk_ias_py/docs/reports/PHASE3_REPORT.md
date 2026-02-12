# Отчет: Фаза 3 (проектирование и реализация моделей)

Дата: 2026-02-07

## Цель фазы

- Реализовать модели и миграции (users/assets/tasks/software/audit).
- Вложения: **FK‑связь, без JSON**.
- Индексы под фильтры и отчёты.

## Что сделано

### 1) Users

Файлы:
- `helpdesk_ias_py/helpdesk_ias/apps/users/models.py`

Сделано:
- Добавлены модели:
  - `Role` (таблица `roles`)
  - `User` (таблица `users`, `AUTH_USER_MODEL`)
- Добавлены индексы (department/role/created_at).
- Добавлено поле `legacy_password_md5` под Фазу 4 (миграция и апгрейд паролей).

Настройки:
- `helpdesk_ias_py/helpdesk_ias/config/settings.py` → `AUTH_USER_MODEL = "users.User"`

### 2) Tasks (Help Desk) + вложения без JSON

Файлы:
- `helpdesk_ias_py/helpdesk_ias/apps/tasks/models.py`

Сделано:
- `TaskStatus` (`dic_task_status`)
- `Task` (`tasks`) с FK на `status`, `creator`, `executor`
- `Attachment` (`desk_attachments`)
- Нормализация связи вложений: `TaskAttachment` (`task_attachments`) + UNIQUE (task, attachment)

### 3) Assets (учёт техники/активов)

Файлы:
- `helpdesk_ias_py/helpdesk_ias/apps/assets/models.py`

Сделано:
- `Location` (`locations`)
- `Equipment` (`equipment`) + FK на `users`/`locations`
- `EquipHistory` (`equip_history`)
- Справочники и значения характеристик:
  - `SprPart` (`spr_parts`)
  - `SprChar` (`spr_chars`)
  - `PartCharValue` (`part_char_values`) + UNIQUE (equipment, part, char)

### 4) Software

Файлы:
- `helpdesk_ias_py/helpdesk_ias/apps/software/models.py`

Сделано:
- `Software` (`software`) + UNIQUE (name, vendor)
- `License` (`licenses`)
- `SoftwareInstall` (`software_installs`) — минимальный каркас (на Фазе 5+ можно перевести `equipment_id` на FK к `assets.Equipment`)

### 5) Audit

Файлы:
- `helpdesk_ias_py/helpdesk_ias/apps/audit/models.py`

Сделано:
- `AuditEvent` (`audit_events`) + индексы по actor/action/object/request_id/created_at.

## Миграции и проверка приёмки

Миграции сгенерированы и прогнаны на чистой БД SQLite:
- `python manage.py makemigrations`
- `python manage.py migrate`
- `python manage.py check`

Результат:
- схема поднимается без ошибок, `check` проходит.

## Важные замечания

- Чтобы избежать ограничений длины имён индексов/constraints, имена индексов оставлены автогенерации Django; для UNIQUE constraints использованы короткие имена.
- Табличные имена (`db_table`) выставлены так, чтобы совпадать с текущей предметной областью и облегчить будущую миграцию данных.

