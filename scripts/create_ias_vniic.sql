-- Целевая БД: ias_vniic (боевая, учёт технических средств). Имя в нижнем регистре — единый конфиг на всех ОС.
-- Схема: tech_accounting (все объекты создаются в ней, не в public).
-- Назначение: полная схема для требований TZ.md (особенно 5.1.4, 5.1.5, 5.1.6, 5.1.8, 5.1.10).
--
-- ВАЖНО:
-- 1) Этот файл выполняется в уже выбранной БД.
-- 2) Перед запуском создайте БД (без кавычек — lowercase на всех платформах):
--      CREATE DATABASE ias_vniic WITH ENCODING 'UTF8' TEMPLATE template0;
-- 3) Подключитесь к БД ias_vniic и выполните данный файл целиком.
--
-- Вариант psql:
--   psql -U postgres -d postgres -c "CREATE DATABASE ias_vniic WITH ENCODING 'UTF8' TEMPLATE template0;"
--   psql -U postgres -d ias_vniic -f scripts/create_ias_vniic.sql
--
BEGIN;

-- Схема учёта ТС (вместо public)
CREATE SCHEMA IF NOT EXISTS tech_accounting;
SET search_path TO tech_accounting;

-- ==============================
-- 1. СЛУЖЕБНЫЕ ФУНКЦИИ И ТРИГГЕРЫ
-- ==============================

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION prevent_update_delete()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE EXCEPTION 'Изменение и удаление записей запрещено для таблицы %', TG_TABLE_NAME;
END;
$$;

-- ==============================
-- 2. RBAC И ПОЛЬЗОВАТЕЛИ
-- ==============================

CREATE TABLE IF NOT EXISTS roles (
    id BIGSERIAL PRIMARY KEY,
    role_code VARCHAR(50) NOT NULL UNIQUE,
    role_name VARCHAR(150) NOT NULL,
    description TEXT,
    is_system BOOLEAN NOT NULL DEFAULT FALSE,
    is_archived BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_roles_role_code_not_empty CHECK (length(trim(role_code)) > 0),
    CONSTRAINT chk_roles_role_name_not_empty CHECK (length(trim(role_name)) > 0)
);

CREATE TABLE IF NOT EXISTS permissions (
    id BIGSERIAL PRIMARY KEY,
    perm_code VARCHAR(100) NOT NULL UNIQUE,
    perm_name VARCHAR(200) NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_permissions_perm_code_not_empty CHECK (length(trim(perm_code)) > 0),
    CONSTRAINT chk_permissions_perm_name_not_empty CHECK (length(trim(perm_name)) > 0)
);

CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE,
    full_name VARCHAR(200) NOT NULL,
    position VARCHAR(100),
    department VARCHAR(100),
    email VARCHAR(150),
    phone VARCHAR(50),
    password_hash VARCHAR(255),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_locked BOOLEAN NOT NULL DEFAULT FALSE,
    failed_login_attempts INTEGER NOT NULL DEFAULT 0,
    lock_until TIMESTAMPTZ,
    password_changed_at TIMESTAMPTZ,
    last_login_at TIMESTAMPTZ,
    created_by_id BIGINT REFERENCES users(id),
    updated_by_id BIGINT REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT chk_users_full_name_not_empty CHECK (length(trim(full_name)) > 0),
    CONSTRAINT chk_users_failed_login_attempts_nonnegative CHECK (failed_login_attempts >= 0)
);

CREATE TABLE IF NOT EXISTS user_roles (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id),
    role_id BIGINT NOT NULL REFERENCES roles(id),
    assigned_by BIGINT REFERENCES users(id),
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    revoked_at TIMESTAMPTZ,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE (user_id, role_id, is_active)
);

CREATE TABLE IF NOT EXISTS role_permissions (
    id BIGSERIAL PRIMARY KEY,
    role_id BIGINT NOT NULL REFERENCES roles(id),
    permission_id BIGINT NOT NULL REFERENCES permissions(id),
    granted_by BIGINT REFERENCES users(id),
    granted_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (role_id, permission_id)
);

-- ==============================
-- 3. СПРАВОЧНИКИ И ЛОКАЦИИ
-- ==============================

CREATE TABLE IF NOT EXISTS locations (
    id BIGSERIAL PRIMARY KEY,
    location_code VARCHAR(50),
    name VARCHAR(150) NOT NULL UNIQUE,
    location_type VARCHAR(50) NOT NULL,
    floor INTEGER,
    description TEXT,
    is_archived BOOLEAN NOT NULL DEFAULT FALSE,
    created_by_id BIGINT REFERENCES users(id),
    updated_by_id BIGINT REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_location_type CHECK (location_type IN ('кабинет', 'склад', 'серверная', 'лаборатория', 'другое')),
    CONSTRAINT chk_locations_name_not_empty CHECK (length(trim(name)) > 0)
);

CREATE TABLE IF NOT EXISTS dic_equipment_status (
    id BIGSERIAL PRIMARY KEY,
    status_code VARCHAR(50) NOT NULL UNIQUE,
    status_name VARCHAR(100) NOT NULL UNIQUE,
    sort_order INTEGER NOT NULL DEFAULT 100,
    is_final BOOLEAN NOT NULL DEFAULT FALSE,
    is_archived BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS dic_task_status (
    id BIGSERIAL PRIMARY KEY,
    status_code VARCHAR(50) NOT NULL UNIQUE,
    status_name VARCHAR(100) NOT NULL UNIQUE,
    sort_order INTEGER NOT NULL DEFAULT 100,
    is_final BOOLEAN NOT NULL DEFAULT FALSE,
    is_archived BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS spr_parts (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_archived BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_spr_parts_name_not_empty CHECK (length(trim(name)) > 0),
    UNIQUE (name)
);

CREATE TABLE IF NOT EXISTS spr_chars (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    measurement_unit VARCHAR(50),
    is_archived BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_spr_chars_name_not_empty CHECK (length(trim(name)) > 0),
    UNIQUE (name)
);

CREATE TABLE IF NOT EXISTS nsi_change_log (
    id BIGSERIAL PRIMARY KEY,
    dictionary_name VARCHAR(100) NOT NULL,
    record_id BIGINT NOT NULL,
    operation_type VARCHAR(20) NOT NULL,
    old_value JSONB,
    new_value JSONB,
    changed_by BIGINT REFERENCES users(id),
    changed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_nsi_change_operation CHECK (operation_type IN ('insert', 'update', 'archive', 'restore', 'delete'))
);

-- ==============================
-- 4. АКТИВЫ (ОБОРУДОВАНИЕ)
-- ==============================

CREATE TABLE IF NOT EXISTS equipment (
    id BIGSERIAL PRIMARY KEY,
    inventory_number VARCHAR(100) NOT NULL,
    serial_number VARCHAR(150),
    name VARCHAR(200) NOT NULL,
    equipment_type VARCHAR(100),
    status_id BIGINT NOT NULL REFERENCES dic_equipment_status(id),
    responsible_user_id BIGINT REFERENCES users(id),
    location_id BIGINT NOT NULL REFERENCES locations(id),
    supplier VARCHAR(200),
    purchase_date DATE,
    commissioning_date DATE,
    warranty_until DATE,
    description TEXT,
    archived_at TIMESTAMPTZ,
    archive_reason TEXT,
    is_archived BOOLEAN NOT NULL DEFAULT FALSE,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_by_id BIGINT REFERENCES users(id),
    updated_by_id BIGINT REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_equipment_inventory_number UNIQUE (inventory_number),
    CONSTRAINT chk_equipment_name_not_empty CHECK (length(trim(name)) > 0),
    CONSTRAINT chk_equipment_warranty_dates CHECK (warranty_until IS NULL OR commissioning_date IS NULL OR warranty_until >= commissioning_date)
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_equipment_serial_number_not_null
    ON equipment(serial_number)
    WHERE serial_number IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_equipment_search_name ON equipment(lower(name));
CREATE INDEX IF NOT EXISTS idx_equipment_search_inventory ON equipment(inventory_number);
CREATE INDEX IF NOT EXISTS idx_equipment_filters_status_location ON equipment(status_id, location_id, is_archived, is_deleted);
CREATE INDEX IF NOT EXISTS idx_equipment_filters_responsible ON equipment(responsible_user_id, is_archived, is_deleted);

CREATE TABLE IF NOT EXISTS equip_history (
    id BIGSERIAL PRIMARY KEY,
    equipment_id BIGINT NOT NULL REFERENCES equipment(id),
    event_type VARCHAR(50) NOT NULL,
    old_value JSONB,
    new_value JSONB,
    changed_by BIGINT REFERENCES users(id),
    changed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    comment TEXT,
    CONSTRAINT chk_equip_history_event_type CHECK (event_type IN ('create', 'update', 'move', 'assign', 'unassign', 'status_change', 'maintenance', 'writeoff', 'archive', 'restore'))
);

CREATE INDEX IF NOT EXISTS idx_equip_history_equipment_date ON equip_history(equipment_id, changed_at DESC);

CREATE TABLE IF NOT EXISTS part_char_values (
    id BIGSERIAL PRIMARY KEY,
    equipment_id BIGINT NOT NULL REFERENCES equipment(id),
    part_id BIGINT NOT NULL REFERENCES spr_parts(id),
    char_id BIGINT NOT NULL REFERENCES spr_chars(id),
    value_text TEXT,
    value_num NUMERIC(18,4),
    source VARCHAR(50) DEFAULT 'manual',
    updated_by BIGINT REFERENCES users(id),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (equipment_id, part_id, char_id)
);

CREATE INDEX IF NOT EXISTS idx_part_char_values_equipment ON part_char_values(equipment_id);
CREATE INDEX IF NOT EXISTS idx_part_char_values_part_char ON part_char_values(part_id, char_id);

-- ==============================
-- 5. HELPDESK (ЗАЯВКИ И ВЛОЖЕНИЯ)
-- ==============================

CREATE TABLE IF NOT EXISTS tasks (
    id BIGSERIAL PRIMARY KEY,
    task_number VARCHAR(50) UNIQUE,
    title VARCHAR(250),
    description TEXT NOT NULL,
    status_id BIGINT NOT NULL REFERENCES dic_task_status(id),
    requester_id BIGINT NOT NULL REFERENCES users(id),
    executor_id BIGINT REFERENCES users(id),
    priority VARCHAR(20) NOT NULL DEFAULT 'medium',
    due_at TIMESTAMPTZ,
    closed_at TIMESTAMPTZ,
    comment TEXT,
    attachments_legacy JSONB,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at TIMESTAMPTZ,
    deleted_by BIGINT REFERENCES users(id),
    delete_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_tasks_priority CHECK (priority IN ('low', 'medium', 'high', 'critical'))
);

CREATE INDEX IF NOT EXISTS idx_tasks_status_created ON tasks(status_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_tasks_executor ON tasks(executor_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_tasks_requester ON tasks(requester_id, created_at DESC);

CREATE TABLE IF NOT EXISTS task_history (
    id BIGSERIAL PRIMARY KEY,
    task_id BIGINT NOT NULL REFERENCES tasks(id),
    field_name VARCHAR(100) NOT NULL,
    old_value TEXT,
    new_value TEXT,
    changed_by BIGINT REFERENCES users(id),
    changed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    comment TEXT
);

CREATE INDEX IF NOT EXISTS idx_task_history_task_changed ON task_history(task_id, changed_at DESC);

-- Связь "заявка <-> актив" (M2M)
CREATE TABLE IF NOT EXISTS task_equipment (
    id BIGSERIAL PRIMARY KEY,
    task_id BIGINT NOT NULL REFERENCES tasks(id),
    equipment_id BIGINT NOT NULL REFERENCES equipment(id),
    relation_type VARCHAR(30) NOT NULL DEFAULT 'related',
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    linked_by BIGINT REFERENCES users(id),
    linked_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (task_id, equipment_id),
    CONSTRAINT chk_task_equipment_relation_type CHECK (relation_type IN ('related', 'affected', 'requested_for'))
);

CREATE INDEX IF NOT EXISTS idx_task_equipment_task ON task_equipment(task_id);
CREATE INDEX IF NOT EXISTS idx_task_equipment_equipment ON task_equipment(equipment_id);

CREATE TABLE IF NOT EXISTS desk_attachments (
    id BIGSERIAL PRIMARY KEY,
    storage_path VARCHAR(1000) NOT NULL,
    original_name VARCHAR(255) NOT NULL,
    file_extension VARCHAR(20),
    mime_type VARCHAR(150),
    size_bytes BIGINT NOT NULL,
    checksum_sha256 CHAR(64),
    uploaded_by BIGINT REFERENCES users(id),
    uploaded_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at TIMESTAMPTZ,
    deleted_by BIGINT REFERENCES users(id),
    CONSTRAINT chk_attachment_size_nonnegative CHECK (size_bytes >= 0)
);

CREATE INDEX IF NOT EXISTS idx_desk_attachments_name ON desk_attachments(original_name);
CREATE INDEX IF NOT EXISTS idx_desk_attachments_uploaded_at ON desk_attachments(uploaded_at DESC);

CREATE TABLE IF NOT EXISTS task_attachments (
    id BIGSERIAL PRIMARY KEY,
    task_id BIGINT NOT NULL REFERENCES tasks(id),
    attachment_id BIGINT NOT NULL REFERENCES desk_attachments(id),
    linked_by BIGINT REFERENCES users(id),
    linked_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (task_id, attachment_id)
);

CREATE INDEX IF NOT EXISTS idx_task_attachments_task ON task_attachments(task_id);
CREATE INDEX IF NOT EXISTS idx_task_attachments_attachment ON task_attachments(attachment_id);

-- ==============================
-- 6. АУДИТ И ПРОТОКОЛЫ ИМПОРТА
-- ==============================

CREATE TABLE IF NOT EXISTS audit_events (
    id BIGSERIAL PRIMARY KEY,
    event_time TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actor_id BIGINT REFERENCES users(id),
    action_type VARCHAR(100) NOT NULL,
    object_type VARCHAR(100) NOT NULL,
    object_id VARCHAR(100) NOT NULL,
    result_status VARCHAR(20) NOT NULL,
    source_ip INET,
    user_agent TEXT,
    request_id VARCHAR(64),
    correlation_id VARCHAR(64),
    payload JSONB,
    error_message TEXT,
    CONSTRAINT chk_audit_result_status CHECK (result_status IN ('success', 'error', 'denied'))
);

CREATE INDEX IF NOT EXISTS idx_audit_events_event_time ON audit_events(event_time DESC);
CREATE INDEX IF NOT EXISTS idx_audit_events_actor_time ON audit_events(actor_id, event_time DESC);
CREATE INDEX IF NOT EXISTS idx_audit_events_object ON audit_events(object_type, object_id);
CREATE INDEX IF NOT EXISTS idx_audit_events_action ON audit_events(action_type, result_status);

CREATE TABLE IF NOT EXISTS import_runs (
    id BIGSERIAL PRIMARY KEY,
    source_type VARCHAR(30) NOT NULL,
    source_name VARCHAR(255),
    started_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    finished_at TIMESTAMPTZ,
    total_rows INTEGER NOT NULL DEFAULT 0,
    success_rows INTEGER NOT NULL DEFAULT 0,
    error_rows INTEGER NOT NULL DEFAULT 0,
    run_status VARCHAR(20) NOT NULL DEFAULT 'running',
    initiated_by BIGINT REFERENCES users(id),
    details JSONB,
    CONSTRAINT chk_import_run_status CHECK (run_status IN ('running', 'success', 'error', 'partial')),
    CONSTRAINT chk_import_rows_nonnegative CHECK (total_rows >= 0 AND success_rows >= 0 AND error_rows >= 0)
);

CREATE TABLE IF NOT EXISTS import_errors (
    id BIGSERIAL PRIMARY KEY,
    import_run_id BIGINT NOT NULL REFERENCES import_runs(id),
    row_number INTEGER,
    error_code VARCHAR(50),
    error_message TEXT NOT NULL,
    raw_payload JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_import_errors_run_id ON import_errors(import_run_id);

-- ==============================
-- 7. ТРИГГЕРЫ НА ОБНОВЛЕНИЕ updated_at
-- ==============================

CREATE TRIGGER trg_roles_set_updated_at
BEFORE UPDATE ON roles
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_users_set_updated_at
BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_locations_set_updated_at
BEFORE UPDATE ON locations
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_dic_equipment_status_set_updated_at
BEFORE UPDATE ON dic_equipment_status
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_dic_task_status_set_updated_at
BEFORE UPDATE ON dic_task_status
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_spr_parts_set_updated_at
BEFORE UPDATE ON spr_parts
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_spr_chars_set_updated_at
BEFORE UPDATE ON spr_chars
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_equipment_set_updated_at
BEFORE UPDATE ON equipment
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_tasks_set_updated_at
BEFORE UPDATE ON tasks
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ==============================
-- 8. НЕИЗМЕНЯЕМОСТЬ АУДИТА
-- ==============================

CREATE TRIGGER trg_audit_events_immutable
BEFORE UPDATE OR DELETE ON audit_events
FOR EACH ROW EXECUTE FUNCTION prevent_update_delete();

-- ==============================
-- 9. БАЗОВОЕ НАПОЛНЕНИЕ СПРАВОЧНИКОВ
-- ==============================

INSERT INTO roles (role_code, role_name, description, is_system)
VALUES
    ('admin', 'Администратор', 'Полный доступ к данным и настройкам', TRUE),
    ('operator', 'Оператор', 'Обработка и сопровождение заявок', TRUE),
    ('user', 'Пользователь', 'Создание и просмотр собственных заявок', TRUE)
ON CONFLICT (role_code) DO NOTHING;

INSERT INTO dic_task_status (status_code, status_name, sort_order, is_final)
VALUES
    ('new', 'Новая', 10, FALSE),
    ('in_progress', 'В работе', 20, FALSE),
    ('on_hold', 'На паузе', 30, FALSE),
    ('resolved', 'Решена', 40, TRUE),
    ('closed', 'Закрыта', 50, TRUE),
    ('cancelled', 'Отменена', 60, TRUE)
ON CONFLICT (status_code) DO NOTHING;

INSERT INTO dic_equipment_status (status_code, status_name, sort_order, is_final)
VALUES
    ('in_use', 'В эксплуатации', 10, FALSE),
    ('in_stock', 'На складе', 20, FALSE),
    ('in_repair', 'В ремонте', 30, FALSE),
    ('writeoff', 'Списано', 40, TRUE),
    ('archived', 'В архиве', 50, TRUE)
ON CONFLICT (status_code) DO NOTHING;

COMMIT;

-- Важное примечание по совместимости:
-- Для миграции со старой схемы поле tasks.attachments следует переносить в:
--   1) tasks.attachments_legacy (как исторический слепок),
--   2) task_attachments + desk_attachments (нормализованная связь).
--
-- Подключение приложения к БД ias_vniic:
--   Укажите в конфиге: dbname=ias_vniic (одинаково на Mac и Windows).
--   Чтобы использовать схему tech_accounting без префикса в запросах, задайте для роли/пользователя:
--   ALTER ROLE your_app_user SET search_path TO tech_accounting;
--   либо в строке подключения (если клиент поддерживает): options=-c search_path=tech_accounting
