# Фаза 1 — База (baseline) для проектирования схемы

## Что сравниваем

В репозитории есть дамп:
- `ias_uch_vnii_public_dump.sql` (legacy)

Также локально доступна БД:
- `ias_vnii` (по словам — та же предметная область, но «более корректная» схема)

## Вывод (решение)

**Для проектирования целевой модели (Django/DRF) принимаем за baseline схему `ias_vnii`.**

Причины:
- **Единый стиль именования**: в `ias_vnii` везде `id`, `role_id`, `status_id`, `location_id`, `user_id` (вместо смеси `id_user`, `id_role`, `id_status`, `id_location`, `id_arm`).
- **Лучше читается доменная модель**: `equipment` вместо `arm` (по смыслу это «оборудование/актив»).
- **Явные FK/UNIQUE/PK** присутствуют и согласованы (по схеме `ias_vnii`).

При этом:
- `ias_uch_vnii_public_dump.sql` остаётся важным как **источник legacy-данных** для будущей миграции (Фаза 4), но не как эталон именования.

## Ключевые различия (legacy → baseline)

### Пользователи и роли

- `ias_uch_vnii.public.users.id_user` → `ias_vnii.public.users.id`
- `ias_uch_vnii.public.users.id_role` → `ias_vnii.public.users.role_id`
- `ias_uch_vnii.public.roles.id_role` → `ias_vnii.public.roles.id`

FK в baseline:
- `users.role_id` → `roles.id`

### Заявки (Help Desk)

- `ias_uch_vnii.public.tasks.id_status` → `ias_vnii.public.tasks.status_id`
- `ias_uch_vnii.public.dic_task_status.id_status` → `ias_vnii.public.dic_task_status.id`

FK в baseline:
- `tasks.status_id` → `dic_task_status.id`
- `tasks.user_id` → `users.id`

Примечание:
- Поле `tasks.attachments` в обеих схемах остаётся `text` с комментарием «массив ID вложений в формате JSON». Это **технический долг**, который в Django-схеме будем **нормализовывать** (таблица связи вместо JSON).

### Активы / оборудование и локации

- `ias_uch_vnii.public.arm` → `ias_vnii.public.equipment`
- `arm.id_arm` → `equipment.id`
- `arm.id_user` → `equipment.user_id`
- `arm.id_location` → `equipment.location_id`
- `arm_history` → `equip_history`

FK в baseline:
- `equipment.location_id` → `locations.id`
- `equipment.user_id` → `users.id`
- `equip_history.equipment_id` → `equipment.id`
- `equip_history.changed_by` → `users.id`

### Характеристики/комплектующие

- `spr_char` → `spr_chars`
- `spr_parts` (совпадает по смыслу; различаются PK-имена)
- `part_char_values.id_arm` → `part_char_values.equipment_id`
- `part_char_values.id_part` → `part_char_values.part_id`
- `part_char_values.id_char` → `part_char_values.char_id`

FK в baseline:
- `part_char_values.part_id` → `spr_parts.id`
- `part_char_values.char_id` → `spr_chars.id`
- `part_char_values.equipment_id` → `equipment.id`

## Как воспроизвести сравнение (локально)

Команды (Mac/Linux), если `psql` установлен, а пароль postgres = `12345`:

```bash
PGPASSWORD='12345' psql -h localhost -U postgres -d ias_vnii -c "SELECT tablename FROM pg_tables WHERE schemaname='public' ORDER BY tablename;"
```

Схему отдельных таблиц удобнее смотреть через `psql`:

```bash
PGPASSWORD='12345' psql -h localhost -U postgres -d ias_vnii -c "\\d+ users"
PGPASSWORD='12345' psql -h localhost -U postgres -d ias_vnii -c "\\d+ tasks"
PGPASSWORD='12345' psql -h localhost -U postgres -d ias_vnii -c "\\d+ equipment"
```

