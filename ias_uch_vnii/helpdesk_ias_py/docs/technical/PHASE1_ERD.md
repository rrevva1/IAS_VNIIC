# Фаза 1 — ERD (черновик)

Ниже — ER-диаграмма **baseline-схемы `ias_vnii`** (см. `PHASE1_DB_BASELINE.md`).

Примечание:
- В legacy/базовой БД связь заявок и вложений хранится как JSON в `tasks.attachments` (тип `text`).
- В целевой Django-схеме это будет нормализовано (таблица связи `task_attachments`), но на Фазе 1 фиксируем текущее состояние и план изменения.

## ERD (Mermaid)

```mermaid
erDiagram
    ROLES ||--o{ USERS : "users.role_id -> roles.id"
    DIC_TASK_STATUS ||--o{ TASKS : "tasks.status_id -> dic_task_status.id"
    USERS ||--o{ TASKS : "tasks.user_id -> users.id"
    USERS ||--o{ EQUIPMENT : "equipment.user_id -> users.id (nullable)"
    LOCATIONS ||--o{ EQUIPMENT : "equipment.location_id -> locations.id"
    USERS ||--o{ EQUIP_HISTORY : "equip_history.changed_by -> users.id (nullable)"
    EQUIPMENT ||--o{ EQUIP_HISTORY : "equip_history.equipment_id -> equipment.id"
    SPR_PARTS ||--o{ PART_CHAR_VALUES : "part_char_values.part_id -> spr_parts.id"
    SPR_CHARS ||--o{ PART_CHAR_VALUES : "part_char_values.char_id -> spr_chars.id"
    EQUIPMENT ||--o{ PART_CHAR_VALUES : "part_char_values.equipment_id -> equipment.id"

    ROLES {
      int id PK
      varchar role_name
    }

    USERS {
      int id PK
      varchar full_name
      varchar position
      varchar department
      varchar email
      varchar phone
      timestamp created_at
      varchar password
      varchar auth_key
      varchar access_token
      varchar password_reset_token
      int role_id FK
    }

    DIC_TASK_STATUS {
      int id PK
      varchar status_name UK
    }

    TASKS {
      int id PK
      int status_id FK
      text description
      int user_id FK
      timestamp date
      timestamp last_time_update
      text comment
      int executor_id "nullable (в baseline индексация есть, FK нет)"
      text attachments "JSON with attachment ids (legacy)"
    }

    DESK_ATTACHMENTS {
      int id PK
      varchar path
      varchar name
      varchar extension
      timestamp created_at
    }

    LOCATIONS {
      int id PK
      varchar name UK
      varchar location_type
      int floor
      text description
    }

    EQUIPMENT {
      int id PK
      varchar name
      int user_id FK
      int location_id FK
      text description
      timestamp created_at
    }

    EQUIP_HISTORY {
      int id PK
      int equipment_id FK
      int changed_by FK
      varchar change_type
      text old_value
      text new_value
      timestamp change_date
      text comment
    }

    SPR_PARTS {
      int id PK
      varchar name
      text description
    }

    SPR_CHARS {
      int id PK
      varchar name UK
      text description
      varchar measurement_unit
    }

    PART_CHAR_VALUES {
      int id PK
      int part_id FK
      int char_id FK
      text value_text
      int equipment_id FK
    }
```

## Что нужно уточнить/дополнить в Фазе 1

- `tasks.executor_id`: в baseline есть индекс, но в схеме, которую мы сняли, нет FK на `users.id`. Нужно проверить, так ли это в реальной БД (возможна разница между схемами/миграциями).
- Связь `tasks.attachments` → `desk_attachments`: хранится JSON-строкой, нужно подтвердить формат (массив int? структура объектов?).

