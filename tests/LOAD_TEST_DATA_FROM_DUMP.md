# Загрузка тестовых данных (как в дампе ias_vniic_14_02_26.sql)

В дампе с домашней машины присутствуют тестовые данные для проверки модулей, которые **не загружаются из Основного учёта (ОУ)**:

- **Журнал аудита** (`audit_events`) — 25 тестовых записей с разными типами действий и результатами.
- **ПО и лицензии** (`software`, `licenses`) — 10 наименований ПО и по одной лицензии на каждое (срок действия, примечание «Тестовая лицензия для проверки раздела»).

## Как загрузить

### Вариант 1: один скрипт (рекомендуется)

Из корня проекта (при наличии `psql` в PATH):

```bash
psql -U postgres -d ias_vniic -f tests/seed_audit_and_software_licenses.sql
```

Windows (с паролем):

```cmd
set PGPASSWORD=12345
psql -U postgres -h localhost -d ias_vniic -f tests/seed_audit_and_software_licenses.sql
```

Скрипт по очереди добавляет: записи в журнал аудита, записи в `software` (id 900001–900010), записи в `licenses` для этого ПО.

### Вариант 2: по отдельности

- **Только аудит (универсальные примеры):** `psql -U postgres -d ias_vniic -f tests/seed_audit_only.sql`
- **Аудит по каждому кейсу (3–5 записей на тип операции):** `psql -U postgres -d ias_vniic -f tests/seed_audit_all_cases.sql` — покрывает все типы событий из кода (task.*, attachment.delete, equipment.*, user.password_reset, software.*, license.*, equipment_software.*) с примерами success/error/denied.
- Только ПО и лицензии: `psql -U postgres -d ias_vniic -f tests/seed_software_licenses_only.sql`

## Условия

- БД `ias_vniic` создана, схема `tech_accounting` развёрнута (скрипт `scripts/create_ias_vniic.sql` или восстановление из дампа).
- Таблицы `audit_events`, `software`, `licenses` существуют (миграция `m260213_120000_add_software_licenses` или полное восстановление из `ias_vniic_14_02_26.sql`).
- В таблице `users` есть хотя бы одна запись (для записей аудита подставляется `actor_id` первого пользователя).

После загрузки можно проверять разделы «Журнал аудита» и «ПО и лицензии» в интерфейсе.
