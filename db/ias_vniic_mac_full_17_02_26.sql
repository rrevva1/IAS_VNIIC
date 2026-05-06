--
-- PostgreSQL database dump
--

\restrict aWwNwLrSVOosUSWtBpbKOGdodc4BuWNCjuaXwXIufl3yXefmSundDHSYMwTgl7J

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.8 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: tech_accounting; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA tech_accounting;


--
-- Name: prevent_update_delete(); Type: FUNCTION; Schema: tech_accounting; Owner: -
--

CREATE FUNCTION tech_accounting.prevent_update_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    RAISE EXCEPTION 'Изменение и удаление записей запрещено для таблицы %', TG_TABLE_NAME;
END;
$$;


--
-- Name: set_updated_at(); Type: FUNCTION; Schema: tech_accounting; Owner: -
--

CREATE FUNCTION tech_accounting.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_events; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.audit_events (
    id bigint NOT NULL,
    event_time timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    actor_id bigint,
    action_type character varying(100) NOT NULL,
    object_type character varying(100) NOT NULL,
    object_id character varying(100) NOT NULL,
    result_status character varying(20) NOT NULL,
    source_ip inet,
    user_agent text,
    request_id character varying(64),
    correlation_id character varying(64),
    payload jsonb,
    error_message text,
    CONSTRAINT chk_audit_result_status CHECK (((result_status)::text = ANY (ARRAY[('success'::character varying)::text, ('error'::character varying)::text, ('denied'::character varying)::text])))
);


--
-- Name: audit_events_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.audit_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audit_events_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.audit_events_id_seq OWNED BY tech_accounting.audit_events.id;


--
-- Name: desk_attachments; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.desk_attachments (
    id bigint NOT NULL,
    storage_path character varying(1000) NOT NULL,
    original_name character varying(255) NOT NULL,
    file_extension character varying(20),
    mime_type character varying(150),
    size_bytes bigint NOT NULL,
    checksum_sha256 character(64),
    uploaded_by bigint,
    uploaded_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    deleted_by bigint,
    CONSTRAINT chk_attachment_size_nonnegative CHECK ((size_bytes >= 0))
);


--
-- Name: desk_attachments_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.desk_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: desk_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.desk_attachments_id_seq OWNED BY tech_accounting.desk_attachments.id;


--
-- Name: dic_equipment_status; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.dic_equipment_status (
    id bigint NOT NULL,
    status_code character varying(50) NOT NULL,
    status_name character varying(100) NOT NULL,
    sort_order integer DEFAULT 100 NOT NULL,
    is_final boolean DEFAULT false NOT NULL,
    is_archived boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: dic_equipment_status_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.dic_equipment_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dic_equipment_status_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.dic_equipment_status_id_seq OWNED BY tech_accounting.dic_equipment_status.id;


--
-- Name: dic_task_status; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.dic_task_status (
    id bigint NOT NULL,
    status_code character varying(50) NOT NULL,
    status_name character varying(100) NOT NULL,
    sort_order integer DEFAULT 100 NOT NULL,
    is_final boolean DEFAULT false NOT NULL,
    is_archived boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: dic_task_status_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.dic_task_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dic_task_status_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.dic_task_status_id_seq OWNED BY tech_accounting.dic_task_status.id;


--
-- Name: equip_history; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.equip_history (
    id bigint NOT NULL,
    equipment_id bigint NOT NULL,
    event_type character varying(50) NOT NULL,
    old_value jsonb,
    new_value jsonb,
    changed_by bigint,
    changed_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    comment text,
    CONSTRAINT chk_equip_history_event_type CHECK (((event_type)::text = ANY (ARRAY[('create'::character varying)::text, ('update'::character varying)::text, ('move'::character varying)::text, ('assign'::character varying)::text, ('unassign'::character varying)::text, ('status_change'::character varying)::text, ('maintenance'::character varying)::text, ('writeoff'::character varying)::text, ('archive'::character varying)::text, ('restore'::character varying)::text])))
);


--
-- Name: equip_history_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.equip_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: equip_history_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.equip_history_id_seq OWNED BY tech_accounting.equip_history.id;


--
-- Name: equipment; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.equipment (
    id bigint NOT NULL,
    inventory_number character varying(100) NOT NULL,
    serial_number character varying(150),
    name character varying(200) NOT NULL,
    status_id bigint NOT NULL,
    responsible_user_id bigint,
    location_id bigint NOT NULL,
    supplier character varying(200),
    purchase_date date,
    commissioning_date date,
    warranty_until date,
    description text,
    archived_at timestamp with time zone,
    archive_reason text,
    is_archived boolean DEFAULT false NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_by_id bigint,
    updated_by_id bigint,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    equipment_type character varying(100) DEFAULT NULL::character varying,
    CONSTRAINT chk_equipment_name_not_empty CHECK ((length(TRIM(BOTH FROM name)) > 0)),
    CONSTRAINT chk_equipment_warranty_dates CHECK (((warranty_until IS NULL) OR (commissioning_date IS NULL) OR (warranty_until >= commissioning_date)))
);


--
-- Name: equipment_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.equipment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: equipment_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.equipment_id_seq OWNED BY tech_accounting.equipment.id;


--
-- Name: equipment_software; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.equipment_software (
    id bigint NOT NULL,
    equipment_id bigint NOT NULL,
    software_id bigint NOT NULL,
    installed_at date,
    created_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: equipment_software_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.equipment_software_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: equipment_software_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.equipment_software_id_seq OWNED BY tech_accounting.equipment_software.id;


--
-- Name: import_errors; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.import_errors (
    id bigint NOT NULL,
    import_run_id bigint NOT NULL,
    row_number integer,
    error_code character varying(50),
    error_message text NOT NULL,
    raw_payload jsonb,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: import_errors_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.import_errors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: import_errors_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.import_errors_id_seq OWNED BY tech_accounting.import_errors.id;


--
-- Name: import_runs; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.import_runs (
    id bigint NOT NULL,
    source_type character varying(30) NOT NULL,
    source_name character varying(255),
    started_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    finished_at timestamp with time zone,
    total_rows integer DEFAULT 0 NOT NULL,
    success_rows integer DEFAULT 0 NOT NULL,
    error_rows integer DEFAULT 0 NOT NULL,
    run_status character varying(20) DEFAULT 'running'::character varying NOT NULL,
    initiated_by bigint,
    details jsonb,
    CONSTRAINT chk_import_rows_nonnegative CHECK (((total_rows >= 0) AND (success_rows >= 0) AND (error_rows >= 0))),
    CONSTRAINT chk_import_run_status CHECK (((run_status)::text = ANY (ARRAY[('running'::character varying)::text, ('success'::character varying)::text, ('error'::character varying)::text, ('partial'::character varying)::text])))
);


--
-- Name: import_runs_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.import_runs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: import_runs_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.import_runs_id_seq OWNED BY tech_accounting.import_runs.id;


--
-- Name: licenses; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.licenses (
    id bigint NOT NULL,
    software_id bigint NOT NULL,
    valid_until date,
    notes text,
    created_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: licenses_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.licenses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: licenses_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.licenses_id_seq OWNED BY tech_accounting.licenses.id;


--
-- Name: locations; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.locations (
    id bigint NOT NULL,
    location_code character varying(50),
    name character varying(150) NOT NULL,
    location_type character varying(50) NOT NULL,
    floor integer,
    description text,
    is_archived boolean DEFAULT false NOT NULL,
    created_by_id bigint,
    updated_by_id bigint,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_location_type CHECK (((location_type)::text = ANY (ARRAY[('кабинет'::character varying)::text, ('склад'::character varying)::text, ('серверная'::character varying)::text, ('лаборатория'::character varying)::text, ('другое'::character varying)::text]))),
    CONSTRAINT chk_locations_name_not_empty CHECK ((length(TRIM(BOTH FROM name)) > 0))
);


--
-- Name: locations_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: locations_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.locations_id_seq OWNED BY tech_accounting.locations.id;


--
-- Name: migration; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.migration (
    version character varying(180) NOT NULL,
    apply_time integer
);


--
-- Name: nsi_change_log; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.nsi_change_log (
    id bigint NOT NULL,
    dictionary_name character varying(100) NOT NULL,
    record_id bigint NOT NULL,
    operation_type character varying(20) NOT NULL,
    old_value jsonb,
    new_value jsonb,
    changed_by bigint,
    changed_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_nsi_change_operation CHECK (((operation_type)::text = ANY (ARRAY[('insert'::character varying)::text, ('update'::character varying)::text, ('archive'::character varying)::text, ('restore'::character varying)::text, ('delete'::character varying)::text])))
);


--
-- Name: nsi_change_log_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.nsi_change_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nsi_change_log_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.nsi_change_log_id_seq OWNED BY tech_accounting.nsi_change_log.id;


--
-- Name: part_char_values; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.part_char_values (
    id bigint NOT NULL,
    equipment_id bigint NOT NULL,
    part_id bigint NOT NULL,
    char_id bigint NOT NULL,
    value_text text,
    value_num numeric(18,4),
    source character varying(50) DEFAULT 'manual'::character varying,
    updated_by bigint,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: part_char_values_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.part_char_values_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: part_char_values_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.part_char_values_id_seq OWNED BY tech_accounting.part_char_values.id;


--
-- Name: permissions; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.permissions (
    id bigint NOT NULL,
    perm_code character varying(100) NOT NULL,
    perm_name character varying(200) NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_permissions_perm_code_not_empty CHECK ((length(TRIM(BOTH FROM perm_code)) > 0)),
    CONSTRAINT chk_permissions_perm_name_not_empty CHECK ((length(TRIM(BOTH FROM perm_name)) > 0))
);


--
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.permissions_id_seq OWNED BY tech_accounting.permissions.id;


--
-- Name: role_permissions; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.role_permissions (
    id bigint NOT NULL,
    role_id bigint NOT NULL,
    permission_id bigint NOT NULL,
    granted_by bigint,
    granted_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: role_permissions_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.role_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: role_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.role_permissions_id_seq OWNED BY tech_accounting.role_permissions.id;


--
-- Name: roles; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.roles (
    id bigint NOT NULL,
    role_code character varying(50) NOT NULL,
    role_name character varying(150) NOT NULL,
    description text,
    is_system boolean DEFAULT false NOT NULL,
    is_archived boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_roles_role_code_not_empty CHECK ((length(TRIM(BOTH FROM role_code)) > 0)),
    CONSTRAINT chk_roles_role_name_not_empty CHECK ((length(TRIM(BOTH FROM role_name)) > 0))
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.roles_id_seq OWNED BY tech_accounting.roles.id;


--
-- Name: software; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.software (
    id bigint NOT NULL,
    name character varying(200) NOT NULL,
    version character varying(100),
    created_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: software_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.software_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: software_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.software_id_seq OWNED BY tech_accounting.software.id;


--
-- Name: spr_chars; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.spr_chars (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    measurement_unit character varying(50),
    is_archived boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_spr_chars_name_not_empty CHECK ((length(TRIM(BOTH FROM name)) > 0))
);


--
-- Name: spr_chars_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.spr_chars_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: spr_chars_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.spr_chars_id_seq OWNED BY tech_accounting.spr_chars.id;


--
-- Name: spr_parts; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.spr_parts (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    is_archived boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_spr_parts_name_not_empty CHECK ((length(TRIM(BOTH FROM name)) > 0))
);


--
-- Name: spr_parts_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.spr_parts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: spr_parts_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.spr_parts_id_seq OWNED BY tech_accounting.spr_parts.id;


--
-- Name: task_attachments; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.task_attachments (
    id bigint NOT NULL,
    task_id bigint NOT NULL,
    attachment_id bigint NOT NULL,
    linked_by bigint,
    linked_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: task_attachments_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.task_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: task_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.task_attachments_id_seq OWNED BY tech_accounting.task_attachments.id;


--
-- Name: task_equipment; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.task_equipment (
    id bigint NOT NULL,
    task_id bigint NOT NULL,
    equipment_id bigint NOT NULL,
    relation_type character varying(30) DEFAULT 'related'::character varying NOT NULL,
    is_primary boolean DEFAULT false NOT NULL,
    linked_by bigint,
    linked_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_task_equipment_relation_type CHECK (((relation_type)::text = ANY (ARRAY[('related'::character varying)::text, ('affected'::character varying)::text, ('requested_for'::character varying)::text])))
);


--
-- Name: task_equipment_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.task_equipment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: task_equipment_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.task_equipment_id_seq OWNED BY tech_accounting.task_equipment.id;


--
-- Name: task_history; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.task_history (
    id bigint NOT NULL,
    task_id bigint NOT NULL,
    field_name character varying(100) NOT NULL,
    old_value text,
    new_value text,
    changed_by bigint,
    changed_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    comment text
);


--
-- Name: task_history_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.task_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: task_history_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.task_history_id_seq OWNED BY tech_accounting.task_history.id;


--
-- Name: tasks; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.tasks (
    id bigint NOT NULL,
    task_number character varying(50),
    title character varying(250),
    description text NOT NULL,
    status_id bigint NOT NULL,
    requester_id bigint NOT NULL,
    executor_id bigint,
    priority character varying(20) DEFAULT 'medium'::character varying NOT NULL,
    due_at timestamp with time zone,
    closed_at timestamp with time zone,
    comment text,
    attachments_legacy jsonb,
    is_deleted boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    deleted_by bigint,
    delete_reason text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_tasks_priority CHECK (((priority)::text = ANY (ARRAY[('low'::character varying)::text, ('medium'::character varying)::text, ('high'::character varying)::text, ('critical'::character varying)::text])))
);


--
-- Name: tasks_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.tasks_id_seq OWNED BY tech_accounting.tasks.id;


--
-- Name: user_roles; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.user_roles (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    role_id bigint NOT NULL,
    assigned_by bigint,
    assigned_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    revoked_at timestamp with time zone,
    is_active boolean DEFAULT true NOT NULL
);


--
-- Name: user_roles_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.user_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.user_roles_id_seq OWNED BY tech_accounting.user_roles.id;


--
-- Name: users; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.users (
    id bigint NOT NULL,
    username character varying(100),
    full_name character varying(200) NOT NULL,
    "position" character varying(100),
    department character varying(100),
    email character varying(150),
    phone character varying(50),
    password_hash character varying(255),
    is_active boolean DEFAULT true NOT NULL,
    is_locked boolean DEFAULT false NOT NULL,
    failed_login_attempts integer DEFAULT 0 NOT NULL,
    lock_until timestamp with time zone,
    password_changed_at timestamp with time zone,
    last_login_at timestamp with time zone,
    created_by_id bigint,
    updated_by_id bigint,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    CONSTRAINT chk_users_failed_login_attempts_nonnegative CHECK ((failed_login_attempts >= 0)),
    CONSTRAINT chk_users_full_name_not_empty CHECK ((length(TRIM(BOTH FROM full_name)) > 0))
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.users_id_seq OWNED BY tech_accounting.users.id;


--
-- Name: audit_events id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.audit_events ALTER COLUMN id SET DEFAULT nextval('tech_accounting.audit_events_id_seq'::regclass);


--
-- Name: desk_attachments id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.desk_attachments ALTER COLUMN id SET DEFAULT nextval('tech_accounting.desk_attachments_id_seq'::regclass);


--
-- Name: dic_equipment_status id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.dic_equipment_status ALTER COLUMN id SET DEFAULT nextval('tech_accounting.dic_equipment_status_id_seq'::regclass);


--
-- Name: dic_task_status id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.dic_task_status ALTER COLUMN id SET DEFAULT nextval('tech_accounting.dic_task_status_id_seq'::regclass);


--
-- Name: equip_history id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equip_history ALTER COLUMN id SET DEFAULT nextval('tech_accounting.equip_history_id_seq'::regclass);


--
-- Name: equipment id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment ALTER COLUMN id SET DEFAULT nextval('tech_accounting.equipment_id_seq'::regclass);


--
-- Name: equipment_software id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_software ALTER COLUMN id SET DEFAULT nextval('tech_accounting.equipment_software_id_seq'::regclass);


--
-- Name: import_errors id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.import_errors ALTER COLUMN id SET DEFAULT nextval('tech_accounting.import_errors_id_seq'::regclass);


--
-- Name: import_runs id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.import_runs ALTER COLUMN id SET DEFAULT nextval('tech_accounting.import_runs_id_seq'::regclass);


--
-- Name: licenses id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.licenses ALTER COLUMN id SET DEFAULT nextval('tech_accounting.licenses_id_seq'::regclass);


--
-- Name: locations id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.locations ALTER COLUMN id SET DEFAULT nextval('tech_accounting.locations_id_seq'::regclass);


--
-- Name: nsi_change_log id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.nsi_change_log ALTER COLUMN id SET DEFAULT nextval('tech_accounting.nsi_change_log_id_seq'::regclass);


--
-- Name: part_char_values id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.part_char_values ALTER COLUMN id SET DEFAULT nextval('tech_accounting.part_char_values_id_seq'::regclass);


--
-- Name: permissions id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.permissions ALTER COLUMN id SET DEFAULT nextval('tech_accounting.permissions_id_seq'::regclass);


--
-- Name: role_permissions id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.role_permissions ALTER COLUMN id SET DEFAULT nextval('tech_accounting.role_permissions_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.roles ALTER COLUMN id SET DEFAULT nextval('tech_accounting.roles_id_seq'::regclass);


--
-- Name: software id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.software ALTER COLUMN id SET DEFAULT nextval('tech_accounting.software_id_seq'::regclass);


--
-- Name: spr_chars id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.spr_chars ALTER COLUMN id SET DEFAULT nextval('tech_accounting.spr_chars_id_seq'::regclass);


--
-- Name: spr_parts id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.spr_parts ALTER COLUMN id SET DEFAULT nextval('tech_accounting.spr_parts_id_seq'::regclass);


--
-- Name: task_attachments id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.task_attachments ALTER COLUMN id SET DEFAULT nextval('tech_accounting.task_attachments_id_seq'::regclass);


--
-- Name: task_equipment id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.task_equipment ALTER COLUMN id SET DEFAULT nextval('tech_accounting.task_equipment_id_seq'::regclass);


--
-- Name: task_history id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.task_history ALTER COLUMN id SET DEFAULT nextval('tech_accounting.task_history_id_seq'::regclass);


--
-- Name: tasks id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.tasks ALTER COLUMN id SET DEFAULT nextval('tech_accounting.tasks_id_seq'::regclass);


--
-- Name: user_roles id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.user_roles ALTER COLUMN id SET DEFAULT nextval('tech_accounting.user_roles_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.users ALTER COLUMN id SET DEFAULT nextval('tech_accounting.users_id_seq'::regclass);


--
-- Data for Name: audit_events; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.audit_events (id, event_time, actor_id, action_type, object_type, object_id, result_status, source_ip, user_agent, request_id, correlation_id, payload, error_message) FROM stdin;
1	2026-02-13 22:56:12.892261+03	1	task.create	task	1	success	\N	\N	\N	\N	{"i": 0, "seed": true}	\N
2	2026-02-13 21:56:12.892261+03	1	task.update	task	2	success	\N	\N	\N	\N	{"i": 1, "seed": true}	\N
3	2026-02-13 20:56:12.892261+03	1	task.view	task	3	success	\N	\N	\N	\N	{"i": 2, "seed": true}	\N
4	2026-02-13 19:56:12.892261+03	1	user.login	user	4	error	\N	\N	\N	\N	{"i": 3, "seed": true}	\N
5	2026-02-13 18:56:12.892261+03	1	user.view	user	5	denied	\N	\N	\N	\N	{"i": 4, "seed": true}	\N
6	2026-02-13 17:56:12.892261+03	1	equipment.view	equipment	6	success	\N	\N	\N	\N	{"i": 5, "seed": true}	\N
7	2026-02-13 16:56:12.892261+03	1	equipment.update	equipment	7	success	\N	\N	\N	\N	{"i": 6, "seed": true}	\N
8	2026-02-13 15:56:12.892261+03	1	attachment.upload	attachment	8	success	\N	\N	\N	\N	{"i": 7, "seed": true}	\N
9	2026-02-13 14:56:12.892261+03	1	task.create	task	9	error	\N	\N	\N	\N	{"i": 8, "seed": true}	\N
10	2026-02-13 13:56:12.892261+03	1	task.update	task	10	denied	\N	\N	\N	\N	{"i": 9, "seed": true}	\N
11	2026-02-13 12:56:12.892261+03	1	task.view	task	11	success	\N	\N	\N	\N	{"i": 10, "seed": true}	\N
12	2026-02-13 11:56:12.892261+03	1	user.login	user	12	success	\N	\N	\N	\N	{"i": 11, "seed": true}	\N
13	2026-02-13 10:56:12.892261+03	1	user.view	user	13	success	\N	\N	\N	\N	{"i": 12, "seed": true}	\N
14	2026-02-13 09:56:12.892261+03	1	equipment.view	equipment	14	error	\N	\N	\N	\N	{"i": 13, "seed": true}	\N
15	2026-02-13 08:56:12.892261+03	1	equipment.update	equipment	15	denied	\N	\N	\N	\N	{"i": 14, "seed": true}	\N
16	2026-02-13 07:56:12.892261+03	1	attachment.upload	attachment	16	success	\N	\N	\N	\N	{"i": 15, "seed": true}	\N
17	2026-02-13 06:56:12.892261+03	1	task.create	task	17	success	\N	\N	\N	\N	{"i": 16, "seed": true}	\N
18	2026-02-13 05:56:12.892261+03	1	task.update	task	18	success	\N	\N	\N	\N	{"i": 17, "seed": true}	\N
19	2026-02-13 04:56:12.892261+03	1	task.view	task	19	error	\N	\N	\N	\N	{"i": 18, "seed": true}	\N
20	2026-02-13 03:56:12.892261+03	1	user.login	user	20	denied	\N	\N	\N	\N	{"i": 19, "seed": true}	\N
21	2026-02-13 02:56:12.892261+03	1	user.view	user	1	success	\N	\N	\N	\N	{"i": 20, "seed": true}	\N
22	2026-02-13 01:56:12.892261+03	1	equipment.view	equipment	2	success	\N	\N	\N	\N	{"i": 21, "seed": true}	\N
23	2026-02-13 00:56:12.892261+03	1	equipment.update	equipment	3	success	\N	\N	\N	\N	{"i": 22, "seed": true}	\N
24	2026-02-12 23:56:12.892261+03	1	attachment.upload	attachment	4	error	\N	\N	\N	\N	{"i": 23, "seed": true}	\N
25	2026-02-12 22:56:12.892261+03	1	task.create	task	5	denied	\N	\N	\N	\N	{"i": 24, "seed": true}	\N
26	2026-02-17 21:30:26.645152+03	1	task.update_comment	task	3	success	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 YaBrowser/25.12.0.0 Safari/537.36	\N	\N	\N	\N
27	2026-02-17 22:11:50.143699+03	1	task.assign_executor	task	5	success	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 YaBrowser/25.12.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":\\"13\\"}"	\N
28	2026-02-17 22:11:51.914975+03	1	task.assign_executor	task	4	success	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 YaBrowser/25.12.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":\\"8\\"}"	\N
\.


--
-- Data for Name: desk_attachments; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.desk_attachments (id, storage_path, original_name, file_extension, mime_type, size_bytes, checksum_sha256, uploaded_by, uploaded_at, is_deleted, deleted_at, deleted_by) FROM stdin;
\.


--
-- Data for Name: dic_equipment_status; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.dic_equipment_status (id, status_code, status_name, sort_order, is_final, is_archived, created_at, updated_at) FROM stdin;
1	in_use	В эксплуатации	10	f	f	2026-02-12 11:12:45.835301+03	2026-02-12 11:12:45.835301+03
2	in_stock	На складе	20	f	f	2026-02-12 11:12:45.835301+03	2026-02-12 11:12:45.835301+03
3	in_repair	В ремонте	30	f	f	2026-02-12 11:12:45.835301+03	2026-02-12 11:12:45.835301+03
4	writeoff	Списано	40	t	f	2026-02-12 11:12:45.835301+03	2026-02-12 11:12:45.835301+03
5	archived	В архиве	50	t	f	2026-02-12 11:12:45.835301+03	2026-02-12 11:12:45.835301+03
\.


--
-- Data for Name: dic_task_status; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.dic_task_status (id, status_code, status_name, sort_order, is_final, is_archived, created_at, updated_at) FROM stdin;
1	new	Новая	10	f	f	2026-02-12 11:12:45.835301+03	2026-02-12 11:12:45.835301+03
2	in_progress	В работе	20	f	f	2026-02-12 11:12:45.835301+03	2026-02-12 11:12:45.835301+03
3	on_hold	На паузе	30	f	f	2026-02-12 11:12:45.835301+03	2026-02-12 11:12:45.835301+03
4	resolved	Решена	40	t	f	2026-02-12 11:12:45.835301+03	2026-02-12 11:12:45.835301+03
5	closed	Закрыта	50	t	f	2026-02-12 11:12:45.835301+03	2026-02-12 11:12:45.835301+03
6	cancelled	Отменена	60	t	f	2026-02-12 11:12:45.835301+03	2026-02-12 11:12:45.835301+03
\.


--
-- Data for Name: equip_history; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.equip_history (id, equipment_id, event_type, old_value, new_value, changed_by, changed_at, comment) FROM stdin;
\.


--
-- Data for Name: equipment; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.equipment (id, inventory_number, serial_number, name, status_id, responsible_user_id, location_id, supplier, purchase_date, commissioning_date, warranty_until, description, archived_at, archive_reason, is_archived, is_deleted, created_by_id, updated_by_id, created_at, updated_at, equipment_type) FROM stdin;
24	МЦ.04-mon-001	\N	Samsung SyncMaster SA200	1	4	2	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:11:36.524749+03	2026-02-17 23:11:36.524749+03	Монитор
25	МЦ.04-mon-002	\N	Samsung SyncMaster SA200	1	4	2	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:11:36.524749+03	2026-02-17 23:11:36.524749+03	Монитор
26	МЦ.04-mon-003	\N	BENQ BL2201M	1	5	2	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:11:36.524749+03	2026-02-17 23:11:36.524749+03	Монитор
27	МЦ.04-mon-004	\N	Nec MultiSync E222W	1	6	2	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:11:36.524749+03	2026-02-17 23:11:36.524749+03	Монитор
28	МЦ.04-mon-005	\N	Philips 23.8" 241B8QJEB	1	7	3	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:11:36.524749+03	2026-02-17 23:11:36.524749+03	Монитор
29	МЦ.04-mon-006	\N	Nec MultiSync E222W	1	8	3	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:11:36.524749+03	2026-02-17 23:11:36.524749+03	Монитор
30	МЦ.04-mon-007	\N	Samsung S22C200	1	9	4	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:11:36.524749+03	2026-02-17 23:11:36.524749+03	Монитор
31	МЦ.04-mon-008	\N	AOC 24P2Q	1	9	4	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:11:36.524749+03	2026-02-17 23:11:36.524749+03	Монитор
32	МЦ.04-mon-009	\N	AOC 24P2Q	1	9	4	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:11:36.524749+03	2026-02-17 23:11:36.524749+03	Монитор
33	МЦ.04-mon-010	\N	MB27V13FS51	1	13	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:11:36.524749+03	2026-02-17 23:11:36.524749+03	Монитор
34	МЦ.04-mon-011	\N	BenQ BL2405	1	14	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:11:36.524749+03	2026-02-17 23:11:36.524749+03	Монитор
35	МЦ.04-mon-012	\N	BenQ BL2405	1	15	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:11:36.524749+03	2026-02-17 23:11:36.524749+03	Монитор
36	МЦ.04-mon-013	\N	MB27V13FS51	1	16	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:11:36.524749+03	2026-02-17 23:11:36.524749+03	Монитор
37	МЦ.04-mon-014	\N	BENQ BL2405	1	17	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:11:36.524749+03	2026-02-17 23:11:36.524749+03	Монитор
38	МЦ.04-mon-015	\N	BENQ GL2460	1	18	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:11:36.524749+03	2026-02-17 23:11:36.524749+03	Монитор
39	МЦ.04-mon-016	\N	Philips 23.8" 241B8QJEB	1	19	6	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:11:36.524749+03	2026-02-17 23:11:36.524749+03	Монитор
40	МЦ.04-mon-017	\N	Philips 23.8" 241B8QJEB	1	19	6	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:11:36.524749+03	2026-02-17 23:11:36.524749+03	Монитор
12	МЦ.04-строка10	\N	AOC 24P2Q\nAOC 24P2Q	1	9	4	\N	\N	\N	\N	\N	2026-02-17 23:11:36+03	Разнесение на отдельные записи: 1 актив = 1 запись (мониторы МЦ.04-mon-008, МЦ.04-mon-009)	t	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-17 23:11:36.524749+03	Монитор
41	МЦ.04-ups-001	\N	Powercom RPT-1000A EURO	1	5	2	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:18:47.381175+03	2026-02-17 23:18:47.381175+03	ИБП
42	МЦ.04-ups-002	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	7	3	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:18:47.381175+03	2026-02-17 23:18:47.381175+03	ИБП
9	МЦ.04.1	\N	ARBYTE	1	5	8	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-17 23:54:02.090047+03	Системный блок
7	МЦ.04.2-строка5	\N	USN Computers (mini)	1	6	2	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-15 19:07:36.617809+03	Системный блок
10	МЦ.04	\N	INWIN	1	22	11	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-17 23:54:02.090047+03	Системный блок
4	190354	\N	Треугольник	1	4	2	\N	2008-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-17 23:54:02.090047+03	Системный блок
5	МЦ.04.2	\N	USN Computers (mini)	1	4	2	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-17 23:54:02.090047+03	Системный блок
8	00-000804	\N	МИР4	1	7	3	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-17 23:54:02.090047+03	Системный блок
13	Электроника	\N	Моноблок Lenovo ThinkCentre Edge 72z	1	11	4	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-17 23:54:02.090047+03	Моноблок
14	МЦ.04 (001601)	\N	Ноутбук Lenivo IdeaPad 300-17ISK	1	12	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-17 23:54:02.090047+03	Ноутбук
15	БП-001223	\N	RDW Xpert GE	1	13	5	\N	2024-05-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-17 23:54:02.090047+03	Системный блок
11	МЦ.04-строка9	\N	Моноблок HP EliteOne 800	1	10	4	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-15 19:07:36.617809+03	Моноблок
6	МЦ.04.2-строка4	\N	USN Computers (mini)	1	5	2	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-17 23:18:47.381175+03	Системный блок
43	МЦ.04-ups-003	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	13	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:18:47.381175+03	2026-02-17 23:18:47.381175+03	ИБП
44	МЦ.04-ups-004	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	14	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:18:47.381175+03	2026-02-17 23:18:47.381175+03	ИБП
45	МЦ.04-ups-005	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	15	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:18:47.381175+03	2026-02-17 23:18:47.381175+03	ИБП
46	МЦ.04-ups-006	\N	APC Back-UPS BC650-RSX761	1	16	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:18:47.381175+03	2026-02-17 23:18:47.381175+03	ИБП
47	МЦ.04-ups-007	\N	APC Back-UPS 650(белый)	1	17	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:18:47.381175+03	2026-02-17 23:18:47.381175+03	ИБП
48	МЦ.04-ups-008	\N	APC Back-UPS 500 Белый	1	18	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:18:47.381175+03	2026-02-17 23:18:47.381175+03	ИБП
19	МЦ.04 (001605)	\N	Ноутбук HP Probook 450 G5	1	16	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-17 23:54:02.090047+03	Ноутбук
22	00-000213	\N	ООО "ГКС" (ГИГАНТ)	1	19	6	\N	2017-10-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-17 23:54:02.090047+03	Системный блок
51	МЦ.04-mon-1	\N	Samsung S22C200	1	5	8	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
52	00-001011	\N	ICL  B102 тип1	1	21	9	\N	2022-08-30	\N	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
53	МЦ.04-mon-2	\N	AOC 27P2Q	1	21	9	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
54	НИИСУ	\N	SuperMicro	1	21	9	\N	2012-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
55	МЦ.04-mon-3	\N	Dell E2314H	1	21	9	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
56	не учтен	\N	INWIN	1	\N	10	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
57	МЦ.04-mon-4	\N	NEC MultiSync EA241WM	1	\N	10	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
59	МЦ.04-mon-5	\N	Lenovo l2250p	1	22	11	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
60	НИИСУ-строка10	\N	ARBYTE	1	23	11	\N	2008-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
61	МЦ.04-mon-6	\N	Nec MultiSync EA222W	1	23	11	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
63	МЦ.04-mon-7	\N	Samsung SyncMaster SA200	1	4	2	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
65	МЦ.04-mon-8	\N	Samsung SyncMaster SA200	1	4	2	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
66	МЦ.04.2-строка14	\N	USN Computers (mini)	1	5	2	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
67	МЦ.04-mon-9	\N	BENQ BL2201M	1	5	2	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
68	МЦ.04-ups-1	\N	Powercom RPT-1000A EURO	1	5	2	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
69	МЦ.04.2-строка15	\N	USN Computers (mini)	1	6	2	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
70	МЦ.04-mon-10	\N	Nec MultiSync E222W	1	6	2	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
71	00-000509	\N	HP Elite Desk 800 G2	1	24	2	\N	2016-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
72	МЦ.04-mon-11	\N	Samsung SyncMaster SA200	1	24	2	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
73	00-000518	\N	ARBYTE	1	5	2	\N	2012-01-01	\N	\N	APC Back-UPS CS	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
74	МЦ.04-mon-12	\N	Nec MultiSync E224wi	1	5	2	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
75	00-001028	\N	ICL  B102 тип1	1	5	2	\N	2022-08-30	\N	\N	АСТ ГОЗ	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
76	МЦ.04-mon-13	\N	DELL E2313Hf	1	5	2	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
77	МЦ.04-ups-2	\N	Powercom RPT-1000A EURO	1	5	2	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
78	НИИСУ-строка19	\N	ARBYTE	1	5	2	\N	2012-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
79	МЦ.04-mon-14	\N	LG 22m35	1	5	2	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
80	МЦ.04-ups-3	\N	Powercom RPT-1000A EURO	1	5	2	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
81	00-000803	\N	МИР4	1	25	3	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
82	МЦ.04-mon-15	\N	ASUS 23.8" BE249QLB	1	25	3	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
83	МЦ.04-ups-4	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	25	3	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
84	99036	\N	Flextron	1	26	3	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
85	МЦ.04-mon-16	\N	Samsung SyncMaster 226cw	1	26	3	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
86	МЦ.04-ups-5	\N	SVEN	1	26	3	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
88	МЦ.04-mon-17	\N	Philips 23.8" 241B8QJEB	1	7	3	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
89	МЦ.04-ups-6	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	7	3	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
90	МЦ.04.1-строка24	\N	ARBYTE	1	8	3	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
91	МЦ.04-mon-18	\N	Nec MultiSync E222W	1	8	3	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
92	МЦ.04-строка26	\N	ООО "ГКС" (ГИГАНТ)	1	9	4	\N	2017-10-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
93	МЦ.04-mon-19	\N	Samsung S22C200	1	9	4	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
94	МЦ.04-строка27	\N	Моноблок HP EliteOne 800	1	10	4	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Моноблок
95	МЦ.04-строка28	\N	AOC 24P2Q; AOC 24P2Q	1	9	4	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
97	99036-строка31	\N	Flextron	1	9	12	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
98	МЦ.04-mon-20	\N	Samsung S22C200	1	9	12	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
99	МЦ.04.2-строка32	\N	Flextron (Integro)	1	9	12	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
100	МЦ.04-mon-21	\N	Samsung SyncMaster P2270	1	9	12	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
101	00-000959	\N	Некстген3	1	11	12	\N	2022-03-17	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
102	МЦ.04-mon-22	\N	Lenovo L27e-30 27"	1	11	12	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
821	МЦ.04-mon-335	\N	15,6"	1	205	67	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
103	МЦ.04.1-строка34	\N	IRU	1	10	12	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
104	МЦ.04-mon-23	\N	Nec MultiSync EA221WMe	1	10	12	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
105	МЦ.04-ups-7	\N	Powercom RPT-1000A EURO	1	10	12	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
106	МЦ.04-строка35	\N	Universal D2 (ООО «Десктоп»)	1	10	13	\N	2021-02-15	\N	\N	APC Back-UPS 650 ВА (BX650CI-RS)	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
107	МЦ.04-mon-24	\N	LG Flatron L1934S	1	10	13	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
108	МЦ.04-ROW-37	\N	Aerocool	1	\N	14	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
109	МЦ.04-mon-25	\N	Samsung S22C200	1	\N	14	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
110	МЦ.04-ups-8	\N	Powercom RPT-1000A EURO	1	\N	14	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
111	НИИСУ-строка39	\N	______	1	27	15	\N	2012-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
112	МЦ.04-mon-26	\N	ASUS PA248Q	1	27	15	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
113	МЦ.04-mon-27	\N	ASUS PA248Q	1	27	15	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
114	МЦ.04-ups-9	\N	APC  650 (белый)	1	27	15	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
115	00-000479	\N	HP Elite Desk 800 G2	1	28	16	\N	2016-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
116	МЦ.04-mon-28	\N	Nec MultiSync AS221WM	1	28	16	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
118	МЦ.04-mon-29	\N	13,3"	1	29	17	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
119	МОЛ Данилкин	\N	GIGANT G-station i5-7500	1	29	17	\N	2019-09-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
120	МЦ.04-mon-30	\N	BENQ GW2780 27"	1	29	17	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
121	МЦ.04-ups-10	\N	Ippon Back Power Pro II 500 300Вт 500ВА	1	29	17	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
122	00-000424	\N	ARBYTE	1	30	17	\N	2012-09-07	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
123	МЦ.04-mon-31	\N	Nec MultiSync E231W	1	30	17	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
124	МОЛ Данилкин-строка45	\N	GIGANT G-station i5-7500	1	30	17	\N	2019-09-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
125	МЦ.04-mon-32	\N	BENQ GW2780 27"	1	30	17	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
126	МЦ.04-ups-11	\N	Ippon Back Power Pro II 500 300Вт 500ВА	1	30	17	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
127	МОЛ Данилкин-строка46	\N	GIGANT G-station i5-7500	1	31	17	\N	2019-09-30	\N	\N	Внешний SSD ADATA SE760 Black External ASE760-512GU32G2-CBK - 1 шт.\nHDD WD My Passport 4Tb 2.5, USB 3.0, WDBPKJ0040BBK-WESN - 2 шт.	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
128	МЦ.04-mon-33	\N	BENQ GW2780 27"	1	31	17	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
129	МЦ.04-ups-12	\N	Ippon Back Power Pro II 500 300Вт 500ВА	1	31	17	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
130	БП-001306 (Информ. - 000190)	\N	BENQ BL2710	1	32	18	\N	\N	\N	\N	Голосовой помощник Алиса, ProXL, Whatsapp, версия 2.7.21, Movavi Video Editor 15	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
131	МЦ.04-mon-34	\N	BENQ BL2710	1	32	18	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
132	БП-001301 (Информ.- 000125 )	\N	Ноутбук Asus ROG GL752 VW (FX753V)	1	32	18	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
133	МЦ.04-mon-35	\N	17"	1	32	18	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
134	МЦ.04 (001183)	\N	Dell P2720DC	1	33	18	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
135	МЦ.04-mon-36	\N	Dell P2720DC	1	33	18	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
136	МЦ.04 (001196)	\N	BENQ GW2760S	1	34	18	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
137	МЦ.04-mon-37	\N	BENQ GW2760S	1	34	18	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
138	БП-001302 (Информ. - 000143)	\N	МИР2725Z	1	35	18	\N	\N	\N	\N	Infatica P2B Network	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
139	МЦ.04-mon-38	\N	BENQ GW2765	1	35	18	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
140	МЦ.04-mon-39	\N	BENQ BL2710	1	35	18	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
141	МЦ.04-ups-13	\N	CROWN CMU-SP 1200 EURO USB	1	35	18	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
142	БП-001303 (Информ. - 000144)	\N	МИР2725Z	1	36	18	\N	\N	\N	\N	I.R.I.S OCR	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
143	МЦ.04-mon-40	\N	Dell P2720DC	1	36	18	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
144	МЦ.04-mon-41	\N	BENQ BL2710	1	36	18	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
145	БП-001299 (Информ. - 000104)	\N	Ноутбук MSI GL72 6QD-004RU	1	36	18	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
146	МЦ.04-mon-42	\N	17"	1	36	18	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
147	МЦ.04 (001622)	\N	Dell P2720DC	1	37	18	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
148	МЦ.04-mon-43	\N	Dell P2720DC	1	37	18	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
149	БП-001206	\N	RDW Xpert GE	1	38	18	\N	2024-05-21	\N	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
150	МЦ.04-mon-44	\N	MB27V13FS51	1	38	18	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
151	БП-000994	\N	ICL  B102 тип1	1	39	18	\N	2022-08-30	\N	\N	APC Back-UPS 650 ВА (BX650CI-RS)	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
152	МЦ.04-mon-45	\N	MB27V13FS51	1	39	18	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
153	МЦ.04-mon-46	\N	MB27V13FS51	1	39	18	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
154	БП-001176	\N	RDW Xpert GE	1	40	18	\N	2024-05-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
155	МЦ.04-mon-47	\N	Samsung 27" C27F390FHI	1	40	18	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
156	МЦ.04-ups-14	\N	APC Back-UPS 650(Белый)	1	40	18	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
157	БП-001201	\N	RDW Xpert GE	1	41	18	\N	2024-05-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
158	МЦ.04-mon-48	\N	MB27V13FS51	1	41	18	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
159	МЦ.04-ups-15	\N	APC Back-UPS 500 Белый	1	41	18	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
160	00-001049	\N	ICL  B102 тип1	1	42	19	\N	2022-08-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
161	МЦ.04-mon-49	\N	AOC 27P2Q	1	42	19	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
162	МЦ.04-ups-16	\N	Powercom RPT-1000A EURO	1	42	19	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
163	00-000998	\N	ICL  B102 тип1	1	43	19	\N	2022-08-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
164	МЦ.04-mon-50	\N	Philips 273V7QJAB	1	43	19	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
165	МЦ.04-ups-17	\N	Powercom RPT-1000A EURO	1	43	19	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
166	00-001053	\N	ICL  B102 тип1	1	44	19	\N	2022-08-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
167	МЦ.04-mon-51	\N	Philips 273V7QJAB	1	44	19	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
168	МЦ.04-ups-18	\N	Powercom RPT-1000A EURO	1	44	19	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
169	00-001009	\N	ICL  B102 тип1	1	45	19	\N	2022-08-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
170	МЦ.04-mon-52	\N	AOC 27P2Q	1	45	19	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
171	МЦ.04-ups-19	\N	Powercom RPT-1000A EURO	1	45	19	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
172	00-000961	\N	Некстген3	1	46	20	\N	2022-03-17	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
173	МЦ.04-mon-53	\N	Philips 273V7QJAB	1	46	20	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
174	МЦ.04-mon-54	\N	Philips 273V7QJAB	1	46	20	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
175	МЦ.04-ups-20	\N	Powercom RPT-1000A EURO	1	46	20	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
176	БП-001158	\N	RDW Xpert GE	1	47	20	\N	2024-05-21	\N	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
177	МЦ.04-mon-55	\N	MB27V13FS51	1	47	20	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
178	МЦ.04-mon-56	\N	Asus 27" MX279H	1	47	20	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
179	БП-001184	\N	RDW Xpert GE	1	48	21	\N	2024-05-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
180	МЦ.04-mon-57	\N	MB27V13FS51	1	48	21	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
181	МЦ.04-ups-21	\N	Powercom RPT-1000A EURO	1	48	21	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
182	00-000952	\N	Некстген1	1	49	21	\N	2022-03-10	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
183	МЦ.04-mon-58	\N	AOC 27P2Q	1	49	21	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
184	МЦ.04-mon-59	\N	AOC 27P2Q	1	49	21	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
185	МЦ.04-ups-22	\N	APC Back-UPS 500(Белый)	1	49	21	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
186	МЦ.04.2-строка75	\N	USN Computers (mini)	1	50	22	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
187	МЦ.04-mon-60	\N	MB27V13FS51	1	50	22	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
188	МЦ.04-mon-61	\N	Nec Multisync EA222WMe	1	50	22	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
189	МЦ.04-ups-23	\N	Powercom Raptor RPT-1000A	1	50	22	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
190	БП-001155	\N	RDW Xpert GE	1	51	22	\N	2024-05-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
191	МЦ.04-mon-62	\N	Benq BL2405	1	51	22	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
192	МЦ.04-ups-24	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	51	22	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
193	00-000995	\N	ICL  B102 тип1	1	52	23	\N	2022-08-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
194	МЦ.04-mon-63	\N	Benq 32" EW3270ZL	1	52	23	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
195	МЦ.04-ups-25	\N	APC Back-UPS BX1100CI-RS	1	52	23	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
196	99036-строка80	\N	99036-строка80	1	52	23	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
197	МОЛ-Карлов С.Н.	\N	Поставка ООО "Гигант"	1	53	23	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
198	МЦ.04-mon-64	\N	Acer XV322QK	1	53	23	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
199	МЦ.04-ups-26	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	53	23	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
200	00-001019	\N	ICL  B102 тип1	1	54	23	\N	2022-08-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
201	МЦ.04-mon-65	\N	Benq 32" EW3270ZL	1	54	23	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
202	МЦ.04-ups-27	\N	Powercom RPT-1000A EURO	1	54	23	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
203	МОЛ-Карлов С.Н.-строка83	\N	Поставка ООО "Гигант"	1	55	23	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
204	МЦ.04-mon-66	\N	PHL346E2LA	1	55	23	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
205	МЦ.04-ups-28	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	55	23	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
206	МОЛ-Карлов С.Н.-строка84	\N	Поставка ООО "Гигант"	1	55	23	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
207	МЦ.04-mon-67	\N	Philips 345E2AE	1	55	23	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
208	00-000245	\N	МИР Z23271 (ООО "Мира")	1	56	23	\N	2017-12-22	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
209	МЦ.04-mon-68	\N	AOC 27P2Q	1	56	23	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
210	МЦ.04-ups-29	\N	Powercom RPT-1000A EURO	1	56	23	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
211	00-000256	\N	МИР Z23272 (ООО "Мира")	1	57	23	\N	2017-12-22	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
212	МЦ.04-mon-69	\N	Benq BL2405	1	57	23	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
214	99036-строка90	\N	Ноутбук Sony Vaio ; VGN-NR21MR/S	1	59	25	\N	2010-01-01	\N	\N	Не работает	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
215	МЦ.04-mon-70	\N	15"	1	59	25	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
216	МЦ.04-строка91	\N	Некстген4	1	59	26	\N	2022-03-25	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
217	МЦ.04-mon-71	\N	Samsung S22C200	1	59	26	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
218	00-000664	\N	AVK 1 (ООО «Вест-Тайп»)	1	60	27	\N	2020-02-05	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
219	МЦ.04-mon-72	\N	Iiyama ProLite XB3270QS-B1	1	60	27	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
220	00-000165	\N	Pioneer	1	61	27	\N	2014-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
221	МЦ.04-mon-73	\N	Benq 32" EW3270ZL	1	61	27	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
222	МЦ.04-ups-30	\N	APC Back-UPS BX1100CI-RS	1	61	27	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
223	00-000662	\N	AVK 1 (ООО «Вест-Тайп»)	1	62	27	\N	2020-02-05	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
224	МЦ.04-mon-74	\N	Iiyama ProLite XB3270QS-B1	1	62	27	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
225	МЦ.04-ups-31	\N	APC Back-UPS BC650-RSX761	1	62	27	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
226	МЦ.04-строка96	\N	Iiyama ProLite XB3270QS-B1	1	62	27	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
227	МЦ.04-ups-32	\N	APC Back-UPS BC650-RSX761	1	62	27	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
228	00-000665	\N	AVK 1 (ООО «Вест-Тайп»)	1	63	27	\N	2020-02-05	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
229	МЦ.04-mon-75	\N	Philips 273V7QJAB	1	63	27	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
230	МЦ.04-ups-33	\N	APC Back-UPS BC650-RSX761	1	63	27	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
231	00-001062	\N	ICL  B102 тип1	1	64	27	\N	2022-08-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
232	МЦ.04-mon-76	\N	Iiyama ProLite XB3270QS-B1	1	64	27	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
233	МЦ.04-mon-77	\N	Samsung S22C200	1	64	27	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
234	МЦ.04-ups-34	\N	Powercom RPT-1000A EURO	1	64	27	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
235	МЦ.04.2-строка99	\N	ARBYTE	1	65	27	\N	2014-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
236	МЦ.04-mon-78	\N	AOC 27P2Q	1	65	27	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
237	МЦ.04-ups-35	\N	Powercom RPT-1000A EURO	1	65	27	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
238	МЦ.04-строка100	\N	Ноутбук Huawei Matebook D 16 RLEF-X	1	62	27	\N	2023-05-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
239	МЦ.04-mon-79	\N	16"	1	62	27	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
240	МЦ.04-строка101	\N	Ноутбук Huawei Matebook D 16 RLEF-X	1	62	27	\N	2023-05-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
241	МЦ.04-mon-80	\N	16"	1	62	27	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
242	МЦ.04-ROW-103	\N	Ноутбук DELL Latitude 5590	1	\N	28	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
243	МОЛ Карлов С.Н.	\N	AVK 1	1	66	26	\N	2022-11-22	\N	\N	Ippon Back Basic 1500 Euro	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
244	МЦ.04-mon-81	\N	Philips 27E1N5600AE	1	66	26	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
245	МОЛ Карлов С.Н.-строка106	\N	AVK 1	1	66	26	\N	2022-11-22	\N	\N	Ippon Back Basic 1500 Euro	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
246	МЦ.04-mon-82	\N	Philips 27E1N5600AE	1	66	26	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
247	МОЛ Карлов С.Н.-строка107	\N	AVK 1	1	66	26	\N	2022-11-22	\N	\N	Ippon Back Basic 1500 Euro	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
248	МЦ.04-mon-83	\N	Philips 27E1N5600AE	1	66	26	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
249	МОЛ Карлов С.Н.-строка108	\N	AVK 1	1	66	26	\N	2022-11-22	\N	\N	Ippon Back Basic 1500 Euro	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
250	МЦ.04-mon-84	\N	Philips 27E1N5600AE	1	66	26	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
251	МОЛ Карлов С.Н.-строка109	\N	AVK 1	1	66	26	\N	2022-11-22	\N	\N	Ippon Back Basic 1500 Euro	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
252	МЦ.04-mon-85	\N	Philips 27E1N5600AE	1	66	26	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
253	МОЛ Карлов С.Н.-строка110	\N	AVK 1	1	66	26	\N	2022-11-22	\N	\N	Ippon Back Basic 1500 Euro	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
254	МЦ.04-mon-86	\N	Philips 27E1N5600AE	1	66	26	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
255	МОЛ Карлов С.Н.-строка111	\N	AVK 1	1	66	26	\N	2022-11-22	\N	\N	Ippon Back Basic 1500 Euro	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
256	МЦ.04-mon-87	\N	Philips 27E1N5600AE	1	66	26	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1604	МЦ.04-mon-675	\N	17"	1	394	114	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
257	МОЛ Карлов С.Н.-строка112	\N	AVK 1	1	66	26	\N	2022-11-22	\N	\N	Ippon Back Basic 1500 Euro	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
258	МЦ.04-mon-88	\N	Philips 27E1N5600AE	1	66	26	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
259	МОЛ Карлов С.Н.-строка113	\N	AVK 1	1	66	26	\N	2022-11-22	\N	\N	Ippon Back Basic 1500 Euro	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
260	МЦ.04-mon-89	\N	Philips 27E1N5600AE	1	66	26	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
261	МОЛ Карлов С.Н.-строка114	\N	AVK 1	1	66	26	\N	2022-11-22	\N	\N	Ippon Back Basic 1500 Euro	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
262	МЦ.04-mon-90	\N	Philips 27E1N5600AE	1	66	26	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
263	МОЛ Карлов С.Н.-строка115	\N	AVK 1	1	66	26	\N	2022-11-22	\N	\N	Ippon Back Basic 1500 Euro	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
264	МЦ.04-mon-91	\N	Philips 27E1N5600AE	1	66	26	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
265	МОЛ Карлов С.Н.-строка116	\N	AVK 1	1	66	26	\N	2022-11-22	\N	\N	Ippon Back Basic 1500 Euro	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
266	МЦ.04-mon-92	\N	Philips 27E1N5600AE	1	66	26	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
267	МОЛ Карлов С.Н.-строка117	\N	AVK 1	1	66	26	\N	2022-11-22	\N	\N	Ippon Back Basic 1500 Euro	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
268	МЦ.04-mon-93	\N	Philips 27E1N5600AE	1	66	26	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
269	МОЛ Карлов С.Н.-строка118	\N	AVK 1	1	66	26	\N	2022-11-22	\N	\N	Ippon Back Basic 1500 Euro	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
270	МЦ.04-mon-94	\N	Philips 27E1N5600AE	1	66	26	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
271	МОЛ Карлов С.Н.-строка119	\N	AVK 1	1	66	26	\N	2022-11-22	\N	\N	Ippon Back Basic 1500 Euro	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
272	МЦ.04-mon-95	\N	Philips 27E1N5600AE	1	66	26	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
273	МОЛ Карлов С.Н.-строка120	\N	AVK 1	1	66	26	\N	2022-11-22	\N	\N	Ippon Back Basic 1500 Euro	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
274	МЦ.04-mon-96	\N	Philips 27E1N5600AE	1	66	26	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
275	МОЛ Карлов С.Н.-строка121	\N	Интерактивная панель InFocus INF9850	1	\N	26	\N	2022-11-22	\N	\N	Ippon Back Basic 1500 Euro	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
276	МЦ.04-mon-97	\N	Интерактивная панель InFocus INF9850	1	\N	26	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
277	МОЛ Карлов С.Н.-строка122	\N	3D-сканер RangeVision Pro	1	\N	26	\N	2022-11-22	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
278	МЦ.04-ROW-123	\N	Коммутатор HP 1930	1	\N	26	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
279	00-000334	\N	HP Z240	1	67	29	\N	2016-12-23	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
280	МЦ.04-mon-98	\N	Philips 273V7QJAB	1	67	29	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
281	МЦ.04-mon-99	\N	Philips 273V7QJAB	1	67	29	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
282	00-000893	\N	Ноутбук Lenovo ThinkPad E15-IML 20RD001CRT	1	67	29	\N	2021-03-07	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
283	00-000950	\N	Некстген1	1	68	29	\N	2022-03-10	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
284	МЦ.04-mon-100	\N	Philips 273V7QJAB	1	68	29	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
285	МЦ.04-mon-101	\N	Philips 234E5QSB 23"	1	68	29	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
286	МЦ.04-строка128	\N	MAXIMA( INWIN)	1	69	29	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
287	МЦ.04-mon-102	\N	Philips 273V7QJAB	1	69	29	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
288	МЦ.04-mon-103	\N	Dell E2314Hf	1	69	29	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
289	00-001055	\N	ICL  B102 тип1	1	70	29	\N	2022-08-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
290	МЦ.04-mon-104	\N	AOC 27P2Q	1	70	29	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
291	МЦ.04-mon-105	\N	AOC 27P2Q	1	70	29	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
292	МЦ.04-ups-36	\N	APC Back-UPSBC650I RSX, 650 BA	1	70	29	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
293	00-000821	\N	МИР4	1	71	30	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
294	МЦ.04-mon-106	\N	Philips 273V7QJAB	1	71	30	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
295	МЦ.04-ups-37	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	71	30	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
296	00-000813	\N	МИР4	1	72	30	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
297	МЦ.04-mon-107	\N	Philips 273V7QJAB	1	72	30	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
298	МЦ.04-ups-38	\N	Powercom RPT-1000A EURO	1	72	30	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
299	МЦ.04.2-строка133	\N	USN Computers (mini)	1	73	30	\N	2013-01-01	\N	\N	новый кулер	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
300	МЦ.04-mon-108	\N	Samsung S22C200	1	73	30	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
301	МЦ.04-ups-39	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	73	30	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
302	00-000809	\N	МИР4	1	74	30	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
303	МЦ.04-mon-109	\N	Philips 273V7QJAB	1	74	30	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
304	МЦ.04-ups-40	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	74	30	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
305	00-000791	\N	МИР4	1	75	30	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
306	МЦ.04-mon-110	\N	Philips 273V7QJAB	1	75	30	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
307	МЦ.04-ups-41	\N	APC Back UPS 500 (белый)	1	75	30	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
308	00-000819	\N	МИР4	1	73	30	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
309	МЦ.04-mon-111	\N	Philips 273V7QJAB	1	73	30	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
310	МЦ.04-ups-42	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	1	73	30	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
311	00-000810	\N	МИР4	1	76	30	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
312	МЦ.04-mon-112	\N	Philips 234E5QSB 23"	1	76	30	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
313	МЦ.04-ups-43	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	76	30	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
314	00-000798	\N	МИР4	1	77	30	\N	2020-06-18	\N	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
315	МЦ.04-mon-113	\N	Philips 273V7QJAB	1	77	30	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
316	Электроника-строка139	\N	Моноблок Lenovo ThinkCentre Edge 72z	1	77	30	\N	\N	\N	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Моноблок
317	НИИСУ-строка140	\N	ARBYTE	1	78	30	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
318	МЦ.04-mon-114	\N	Samsung S22C200	1	78	30	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
319	00-000451	\N	ARBYTE	1	79	31	\N	2012-01-01	\N	\N	Списано 30-12-2021	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
320	МЦ.04-mon-115	\N	Acer K222 HQL	1	79	31	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
321	МЦ.04-ups-44	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	79	31	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
322	МЦ.04.2-строка144	\N	USN Computers (mini)	1	80	32	\N	2013-01-01	\N	\N	новый кулер	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
323	МЦ.04-mon-116	\N	Samsung S22C200	1	80	32	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
324	00-000796	\N	МИР4	1	81	32	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
325	МЦ.04-mon-117	\N	BenQ  GL2450	1	81	32	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
326	00-000225	\N	МИР Z2330 (ООО "Мира")	1	81	32	\N	2017-12-21	\N	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
327	МЦ.04-mon-118	\N	Samsung 27" C27F390FHI	1	81	32	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
328	00-000224	\N	МИР Z2330 (ООО "Мира")	1	82	32	\N	2017-12-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
329	МЦ.04-mon-119	\N	NEC AccuSync AS221WM	1	82	32	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
330	МЦ.04-ups-45	\N	APC  500 (белый)	1	82	32	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
331	00-000233	\N	МИР Z2330 (ООО "Мира")	1	82	32	\N	2017-12-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
332	МЦ.04-mon-120	\N	Samsung 27" C27F390FHI	1	82	32	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
333	МЦ.04-ups-46	\N	APC Back-UPSBC650I RSX, 650 BA	1	82	32	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
334	00-000227	\N	МИР Z2330 (ООО "Мира")	1	83	32	\N	2017-12-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
335	МЦ.04-mon-121	\N	Samsung 27" C27F390FHI	1	83	32	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
336	МЦ.04-ups-47	\N	APC Back-UPSBC650I RSX, 650 BA	1	83	32	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
337	МЦ.04 (От безопасников)	\N	Aerocool	1	83	32	\N	2022-01-01	\N	\N	APC Back-UPS 650 ВА (BX650CI-RS)	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
338	МЦ.04-mon-122	\N	Benq BL2405	1	83	32	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
339	00-000228	\N	МИР Z2330 (ООО "Мира")	1	84	32	\N	2017-12-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
340	МЦ.04-mon-123	\N	Samsung 27" C27F390FHI	1	84	32	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
341	МЦ.04-ups-48	\N	APC Back-UPSBC650I RSX, 650 BA	1	84	32	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
343	МЦ.04-mon-124	\N	Samsung SyncMaster S23B300	1	84	32	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
344	МЦ.04-ups-49	\N	APC Back-UPSBC650I RSX, 650 BA	1	84	32	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
345	00-000226	\N	МИР Z2330 (ООО "Мира")	1	85	32	\N	2017-12-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
346	МЦ.04-mon-125	\N	Samsung 27" C27F390FHI	1	85	32	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
347	МЦ.04-ups-50	\N	APC Back-UPSBC650I RSX, 650 BA	1	85	32	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
348	00-000800	\N	МИР4	1	86	32	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
349	МЦ.04-mon-126	\N	Philips 273V7QJAB	1	86	32	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
350	МЦ.04-ups-51	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	1	86	32	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
351	00-000811	\N	МИР4	1	86	32	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
352	МЦ.04-mon-127	\N	Philips 273V7QJAB	1	86	32	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
353	МЦ.04-ups-52	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	86	32	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
354	00-000241	\N	МИР Z2330 (ООО "Мира")	1	87	33	\N	2017-12-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
355	МЦ.04-mon-128	\N	Samsung 27" C27F390FHI	1	87	33	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
356	МЦ.04-ups-53	\N	APC Back-UPSBC650I RSX, 650 BA	1	87	33	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
357	00-000769	\N	Ноутбук HP Pavilion Gaming 15-bc500ur	1	87	33	\N	2020-03-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
358	МЦ.04-mon-129	\N	15.6"	1	87	33	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
359	00-000790	\N	МИР4	1	80	33	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
360	МЦ.04-mon-130	\N	Philips 273V7QJAB	1	80	33	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
361	МЦ.04-ups-54	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	80	33	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
362	00-000820	\N	МИР4	1	80	33	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
363	МЦ.04-mon-131	\N	Philips 273V7QJAB	1	80	33	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
364	МЦ.04-ups-55	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	80	33	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
365	00-000234	\N	МИР Z2330 (ООО "Мира")	1	88	34	\N	2017-12-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
366	МЦ.04-mon-132	\N	Samsung 27" C27F390FHI	1	88	34	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
367	МЦ.04-ups-56	\N	Powercom RPT-1000A EURO	1	88	34	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
368	?	\N	Треугольник	1	89	34	\N	2008-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
369	МЦ.04-mon-133	\N	Samsung SyncMaster P2270	1	89	34	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
370	00-000799	\N	МИР4	1	89	34	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
371	МЦ.04-mon-134	\N	Philips 273V7QJAB	1	89	34	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
372	МЦ.04-ups-57	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	89	34	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
373	00-000229	\N	МИР Z2330 (ООО "Мира")	1	90	34	\N	2017-12-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
374	МЦ.04-mon-135	\N	Samsung 27" C27F390FHI	1	90	34	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
375	МЦ.04-ups-58	\N	APC Back-UPSBC650I RSX, 650 BA	1	90	34	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
376	МЦ.04.2-строка166	\N	USN Computers (mini)	1	90	34	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
377	МЦ.04-mon-136	\N	BenQ G2025HDA	1	90	34	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
378	МЦ.04.2-строка167	\N	USN Computers (mini)	1	88	34	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
379	МЦ.04-mon-137	\N	Nec MultiSync EA221WMe	1	88	34	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
380	МЦ.04-ups-59	\N	Powercom RPT-1000A EURO	1	88	34	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
381	00-000797	\N	МИР4	1	91	34	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
382	МЦ.04-mon-138	\N	Philips 273V7QJAB	1	91	34	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
383	МЦ.04-ups-60	\N	Powercom RPT-1000A EURO	1	91	34	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
384	00-000818	\N	МИР4	1	92	34	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
385	МЦ.04-mon-139	\N	Philips 273V7QJAB	1	92	34	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
386	МЦ.04-ups-61	\N	APC Back-UPSBC650I RSX, 650 BA	1	92	34	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
387	Электроника-строка170	\N	Моноблок Lenovo ThinkCentre Edge 72z	1	91	34	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Моноблок
388	00-000957	\N	Некстген2	1	93	34	\N	2022-03-16	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
389	МЦ.04-mon-140	\N	AOC 27P2Q	1	93	34	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
390	МЦ.04-ups-62	\N	Powercom RPT-1000A EURO	1	93	34	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
391	99036-строка173	\N	Flextron	1	94	35	\N	2010-01-01	\N	\N	Нет на месте	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
392	00-000235	\N	МИР Z2330 (ООО "Мира")	1	94	35	\N	2017-12-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
393	МЦ.04-mon-141	\N	Samsung 27" C27F390FHI	1	94	35	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
394	МЦ.04-ups-63	\N	APC Back-UPSBC650I RSX, 650 BA	1	94	35	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
395	00-000823	\N	МИР4	1	94	35	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
396	МЦ.04-mon-142	\N	Philips 273V7QJAB	1	94	35	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
397	МЦ.04-ups-64	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	94	35	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
398	00-000822	\N	МИР4	1	95	35	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
399	МЦ.04-mon-143	\N	Philips 273V7QJAB	1	95	35	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
400	МЦ.04-ups-65	\N	Powercom RPT-1000A EURO	1	95	35	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
401	00-000239	\N	МИР Z2330 (ООО "Мира")	1	95	35	\N	2017-12-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
402	МЦ.04-mon-144	\N	Samsung 27" C27F390FHI	1	95	35	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
403	МЦ.04-ups-66	\N	APC Back-UPSBC650I RSX, 650 BA	1	95	35	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
404	00-000808	\N	МИР4	1	96	35	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
405	МЦ.04-mon-145	\N	Philips 273V7QJAB	1	96	35	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
406	МЦ.04-ups-67	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	96	35	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
408	МЦ.04-mon-146	\N	Samsung S22C200	1	97	35	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
409	00-000219	\N	МИР Z2330 (ООО "Мира")	1	97	35	\N	2017-12-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
410	МЦ.04-mon-147	\N	Samsung S22C200	1	97	35	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
411	МЦ.04-ups-68	\N	Powercom RPT-1000A EURO	1	97	35	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
412	00-000814	\N	МИР4	1	98	35	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
413	МЦ.04-mon-148	\N	Philips 273V7QJAB	1	98	35	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
414	МЦ.04-ups-69	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	98	35	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
415	МЦ.04.2-строка182	\N	Flextron	1	98	35	\N	2012-01-01	\N	\N	Создана ученная запись Туганов Евгений Вячеславович в домене vniicentr.local	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
416	МЦ.04-mon-149	\N	Nec MultiSync E222w	1	98	35	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
417	МЦ.04 (От безопасников)-строка183	\N	Aerocool	1	99	35	\N	2022-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
418	МЦ.04-mon-150	\N	AOC 27P2Q	1	99	35	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
419	МЦ.04-ups-70	\N	APC Back-UPS 650	1	99	35	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
420	БП-001217	\N	RDW Xpert GE	1	99	35	\N	2024-05-14	\N	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
421	МЦ.04-mon-151	\N	MB27V13FS51	1	99	35	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
422	00-000794	\N	МИР4	1	100	36	\N	2020-06-18	\N	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
423	МЦ.04-mon-152	\N	Philips 273V7QJAB	1	100	36	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
424	00-000242	\N	МИР Z2330 (ООО "Мира")	1	101	36	\N	2017-12-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
425	МЦ.04-mon-153	\N	Samsung 27" C27F390FHI	1	101	36	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
426	МЦ.04-ups-71	\N	APC Back-UPSBC650I RSX, 650 BA	1	101	36	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
427	00-000792	\N	МИР4	1	102	36	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
428	МЦ.04-mon-154	\N	Philips 273V7QJAB	1	102	36	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
429	МЦ.04-ups-72	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	102	36	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
430	00-000795	\N	МИР4	1	103	36	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
431	МЦ.04-mon-155	\N	Philips 273V7QJAB	1	103	36	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
432	МЦ.04-ups-73	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	103	36	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
433	00-000240	\N	МИР Z2330 (ООО "Мира")	1	104	36	\N	2017-12-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
434	МЦ.04-mon-156	\N	Samsung 27" C27F390FHI	1	104	36	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
435	МЦ.04-ups-74	\N	APC Back-UPSBC650I RSX, 650 BA	1	104	36	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
436	00-000793	\N	МИР4	1	105	36	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
437	МЦ.04-mon-157	\N	Philips 273V7QJAB	1	105	36	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
438	МЦ.04-ups-75	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	105	36	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
439	00-000515	\N	ARBYTE	1	100	36	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
440	МЦ.04-mon-158	\N	Samsung S22C200	1	100	36	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
441	00-000824	\N	МИР4	1	106	36	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
442	МЦ.04-mon-159	\N	Philips 273V7QJAB	1	106	36	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
443	МЦ.04-ups-76	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	106	36	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
444	00-000232	\N	МИР Z2330 (ООО "Мира")	1	107	37	\N	2017-12-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
445	МЦ.04-mon-160	\N	Samsung 27" C27F390FHI	1	107	37	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
446	00-000230	\N	МИР Z2330 (ООО "Мира")	1	108	37	\N	2017-12-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
447	МЦ.04-mon-161	\N	Samsung 27" C27F390FHI	1	108	37	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
448	МЦ.04-ups-77	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	1	108	37	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
449	00-000802	\N	МИР4	1	109	37	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
450	МЦ.04-mon-162	\N	Philips 273V7QJAB	1	109	37	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
451	МЦ.04-ups-78	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	1	109	37	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
452	00-000817	\N	МИР4	1	110	37	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
453	МЦ.04-mon-163	\N	Philips 273V7QJAB	1	110	37	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
454	МЦ.04-ups-79	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	110	37	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
455	00-000223	\N	МИР Z2330 (ООО "Мира")	1	110	37	\N	2017-12-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
456	МЦ.04-mon-164	\N	Samsung 27" C27F390FHI	1	110	37	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
457	МЦ.04-ups-80	\N	APC Back-UPSBC650I RSX, 650 BA	1	110	37	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
458	99036-строка200	\N	Flextron	1	110	37	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
459	МЦ.04-mon-165	\N	LG Flatron L192WS	1	110	37	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
460	00-000231	\N	МИР Z2330 (ООО "Мира")	1	111	37	\N	2017-12-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
461	МЦ.04-mon-166	\N	Samsung 27" C27F390FHI	1	111	37	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
462	МЦ.04-ups-81	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	1	111	37	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
463	00-000805	\N	МИР4	1	107	37	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
464	МЦ.04-mon-167	\N	Philips 273V7QJAB	1	107	37	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
465	МЦ.04-ups-82	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	1	107	37	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
466	МЦ.04.2-строка203	\N	USN Computers (mini)	1	112	37	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
467	МЦ.04-mon-168	\N	Samsung S22C200	1	112	37	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
468	00-000812	\N	МИР4	1	112	37	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
469	МЦ.04-mon-169	\N	LG Flatron L192WS	1	112	37	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
470	МЦ.04.2-строка206	\N	USN Computers (mini)	1	113	38	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
471	МЦ.04-mon-170	\N	Samsung S22C200	1	113	38	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
472	00-000942	\N	EC027Black (ООО "АВК")	1	113	38	\N	2021-11-08	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
473	МЦ.04-mon-171	\N	Philips 272S1AE	1	113	38	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
474	МЦ.04-ups-83	\N	Powercom Back-UPS IMPERIAL IMP-1200AP	1	113	38	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
475	МЦ.04-строка208	\N	INWIN	1	114	38	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
476	МЦ.04-mon-172	\N	Samsung S22C200	1	114	38	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
477	00-000943	\N	EC027Black (ООО "АВК")	1	114	38	\N	2021-11-08	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
478	МЦ.04-mon-173	\N	Philips 272S1AE	1	114	38	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
479	МЦ.04-ups-84	\N	Powercom Back-UPS IMPERIAL IMP-1200AP	1	114	38	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
480	00-000566	\N	Моноблок HP ProOne 440 G4 23.8"	1	115	39	\N	2019-10-22	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Моноблок
481	МЦ.04-mon-174	\N	23,8"	1	115	39	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
482	87992	\N	____	1	116	40	\N	2008-01-01	\N	\N	Списать	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
483	МЦ.04-mon-175	\N	Nec MultiSync E224Wi	1	116	40	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
484	99038	\N	_____	1	116	40	\N	2007-01-01	\N	\N	Не используется	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
485	МЦ.04-mon-176	\N	LG Flatron Slim L1980u	1	116	40	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
486	99051	\N	Пирит	1	59	40	\N	2009-01-01	\N	\N	Списано	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
487	МЦ.04-mon-177	\N	Nec MultiSync E224Wi	1	59	40	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
488	00-001029	\N	ICL  B102 тип1	1	117	41	\N	2022-08-30	\N	\N	APC ES 700	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
489	МЦ.04-mon-178	\N	Benq BL2405	1	117	41	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
490	МЦ.04-mon-179	\N	Benq BL2405	1	117	41	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
491	00-001051	\N	ICL  B102 тип1	1	118	41	\N	2022-08-30	\N	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
492	МЦ.04-mon-180	\N	MB27V13FS51	1	118	41	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
493	МЦ.04-mon-181	\N	MB27V13FS51	1	118	41	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
494	МЦ.04-строка220	\N	Universal D1 (ООО «Десктоп»)	1	119	42	\N	2021-02-15	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
495	МЦ.04-mon-182	\N	Dell E2314H	1	119	42	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
496	МЦ.04-mon-183	\N	Dell E2314H	1	119	42	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
497	МЦ.04-ups-85	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	1	119	42	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
498	00-000888	\N	Ноутбук Lenovo Legion 5 17IMH05	1	119	42	\N	2021-03-07	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
499	МЦ.04-mon-184	\N	17"	1	119	42	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
500	00-000554	\N	HP 460-p206ur	1	120	42	\N	2019-09-19	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
501	МЦ.04-mon-185	\N	Benq BL2201	1	120	42	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
502	МЦ.04-mon-186	\N	Benq BL2201	1	120	42	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
503	МЦ.04-ups-86	\N	APC Back-UPS CS500	1	120	42	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
504	00-000517	\N	ARBYTE	1	121	42	\N	2012-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
505	МЦ.04-mon-187	\N	Samsung C32F391FWI	1	121	42	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
506	МЦ.04-строка224	\N	Universal D1 (ООО «Десктоп»)	1	122	42	\N	2021-02-15	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
507	МЦ.04-mon-188	\N	Samsung S27F358FWI	1	122	42	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
508	МЦ.04-mon-189	\N	Samsung S27F358FWI	1	122	42	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
509	МЦ.04-ups-87	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	1	122	42	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
510	МЦ.04-строка225	\N	USN Computers (mini)	1	122	42	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
511	МЦ.04-mon-190	\N	Samsung S22C200	1	122	42	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
512	МЦ.04.2-строка226	\N	USN Computers (mini)	1	123	42	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
513	МЦ.04-mon-191	\N	Asus VX239	1	123	42	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
514	МЦ.04-ups-88	\N	APC Back-UPS BX650CI-RS	1	123	42	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
515	МЦ.04 (s/n NXKN3CD00734108D583400)	\N	Ноутбук Acer Aspire A515-57-50EC	1	123	42	\N	2023-12-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
516	МЦ.04-mon-192	\N	15,6"	1	123	42	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
517	00-001018	\N	ICL  B102 тип1	1	124	42	\N	2022-08-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
518	МЦ.04-mon-193	\N	MB27V13FS51	1	124	42	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
519	МЦ.04-mon-194	\N	Samsung 27" C27F390FHI	1	124	42	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
520	МЦ.04-ups-89	\N	APC Back-UPS BX650CI-RS	1	124	42	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
521	00-000671	\N	AVK 2 (ООО «Вест-Тайп»)	1	125	43	\N	2020-02-05	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
522	МЦ.04-mon-195	\N	LG 27GL650F	1	125	43	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
523	МЦ.04-mon-196	\N	LG 27GL650F	1	125	43	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
524	МЦ.04-ups-90	\N	Powercom RPT-1000A EURO	1	125	43	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
525	МЦ.04-строка231	\N	Ноутбук HP 15s-eq1436ur	1	126	43	\N	2022-03-05	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
526	МЦ.04-mon-197	\N	15"	1	126	43	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
527	00-000677	\N	AVK 2 (ООО «Вест-Тайп»)	1	127	44	\N	2020-02-05	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
528	МЦ.04-mon-198	\N	AOC 24P2Q	1	127	44	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
529	МЦ.04-mon-199	\N	AOC 24P2Q	1	127	44	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
530	00-000886	\N	Ноутбук Lenovo Legion 5 17IMH05	1	128	44	\N	2021-03-07	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
531	МЦ.04-mon-200	\N	17"	1	128	44	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
532	МЦ.04\nМЦ.04	\N	NoName	1	129	44	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
533	МЦ.04-mon-201	\N	Philips 273V7QJAB	1	129	44	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
534	МЦ.04-mon-202	\N	Philips 273V7QJAB	1	129	44	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
535	МЦ.04-ups-91	\N	APC Back-UPS CS500	1	129	44	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
536	00-000676	\N	AVK 2 (ООО «Вест-Тайп»)	1	130	44	\N	2020-02-05	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
537	МЦ.04-mon-203	\N	Samsung S27F358FWI	1	130	44	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
538	МЦ.04-mon-204	\N	Samsung S27F358FWI	1	130	44	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
539	МЦ.04-ups-92	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	1	130	44	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
540	00-001032	\N	ICL  B102 тип1	1	131	44	\N	2022-08-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
541	МЦ.04-mon-205	\N	AOC 27P2Q	1	131	44	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
542	МЦ.04-mon-206	\N	AOC 27P2Q	1	131	44	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
543	МЦ.04-ups-93	\N	Powercom RPT-1000A EURO	1	131	44	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
545	МЦ.04-mon-207	\N	Samsung C32F391FWI	1	132	44	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
546	МЦ.04-ups-94	\N	APC Back-UPS BX650CI-RS	1	132	44	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
547	99036-строка240	\N	Ноутбук SONY VAIO VPCF1	1	133	45	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
548	00-000214	\N	ООО "ГКС" (ГИГАНТ)	1	133	45	\N	2017-10-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
549	МЦ.04-mon-208	\N	Asus 27" MX279H	1	133	45	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
550	МЦ.04-mon-209	\N	Samsung S22C200	1	133	45	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
551	МЦ.04-ups-95	\N	APC Back-UPS BC650-RSX761	1	133	45	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
552	00-000679	\N	AVK 2 (ООО «Вест-Тайп»)	1	128	45	\N	2020-02-05	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
553	МЦ.04-mon-210	\N	Nec MultiSync EA221WMe	1	128	45	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
554	МЦ.04-mon-211	\N	Nec MultiSync E231W	1	128	45	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
555	БП-001153	\N	RDW Xpert GE	1	134	46	\N	2024-05-14	\N	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
556	МЦ.04-mon-212	\N	MB27V13FS51	1	134	46	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
557	МЦ.04-mon-213	\N	Philips 273V7QJAB	1	134	46	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
558	00-000550	\N	Ноутбук HP Pro Book 450 G6	1	134	46	\N	2019-09-19	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
559	МЦ.04-mon-214	\N	Ноутбук HP Pro Book 450 G6	1	134	46	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
560	БП-001172	\N	RDW Xpert GE	1	135	47	\N	2024-05-14	\N	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
561	МЦ.04-mon-215	\N	MB27V13FS51	1	135	47	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
562	МЦ.04-mon-216	\N	AOC 24P2Q	1	135	47	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
563	00-000663	\N	AVK 1 (ООО «Вест-Тайп»)	1	136	48	\N	2020-02-05	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
564	МЦ.04-mon-217	\N	AOC 27P2Q	1	136	48	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
565	МЦ.04-ups-96	\N	Powercom RPT-1000A EURO	1	136	48	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
566	МЦ.04-строка249	\N	Universal D1 (ООО «Десктоп»)	1	137	48	\N	2021-02-15	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
567	МЦ.04-mon-218	\N	Philips 243V7QJABF	1	137	48	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
568	МЦ.04-строка250	\N	Universal D1 (ООО «Десктоп»)	1	137	48	\N	2021-02-15	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
569	МЦ.04-mon-219	\N	Philips 243V7QJABF	1	137	48	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
570	МЦ.04-mon-220	\N	Philips 243V7QJABF	1	137	48	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
571	МЦ.04-ups-97	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	137	48	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
572	МЦ.04-строка251	\N	Universal D1 (ООО «Десктоп»)	1	137	48	\N	2021-02-15	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
573	МЦ.04-mon-221	\N	Philips 243V7QJABF	1	137	48	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
574	МЦ.04-mon-222	\N	Philips 243V7QJABF	1	137	48	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
575	МЦ.04-ups-98	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	1	137	48	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
576	МЦ.04-строка252	\N	Universal D1 (ООО «Десктоп»)	1	138	48	\N	2021-02-15	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
577	МЦ.04-mon-223	\N	Philips 243V7QJABF	1	138	48	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
578	МЦ.04-mon-224	\N	Philips 243V7QJABF	1	138	48	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
579	МЦ.04-ups-99	\N	APC Back-UPS 650	1	138	48	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
580	МЦ.04.2-строка253	\N	USN Computers (mini)	1	138	49	\N	2013-01-01	\N	\N	Передан в Минпромторг	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
581	МЦ.04.2-строка254	\N	INWIN	1	139	50	\N	2014-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
582	МЦ.04-mon-225	\N	Samsung S22C200	1	139	50	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
583	00-001059	\N	ICL  B102 тип1	1	140	48	\N	2022-08-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
584	МЦ.04-mon-226	\N	MB27V13FS51	1	140	48	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
585	МЦ.04-ups-100	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	1	140	48	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
586	МЦ.04.2-строка256	\N	INWIN	1	141	48	\N	2014-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
587	МЦ.04-mon-227	\N	Samsung S22C200	1	141	48	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
588	МЦ.04-mon-228	\N	Samsung SyncMaster SA200	1	141	48	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
589	МЦ.04-ups-101	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	1	141	48	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
590	Электроника-строка257	\N	Моноблок Lenovo ThinkCentre Edge 72z	1	142	48	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Моноблок
591	БП-001212	\N	RDW Xpert GE	1	143	48	\N	2024-05-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
592	00-000299	\N	Ультрабук Aser Swift 3 SF315-51G-59	1	144	51	\N	2018-04-26	\N	\N	Внешний SSD ADATA SE760 Black External ASE760-512GU32G2-CBK	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
593	МЦ.04-mon-229	\N	15,6"	1	144	51	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
594	БП-001190	\N	RDW Xpert GE	1	144	51	\N	2024-05-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
595	00-000265	\N	Ноутбук Aser Aspire A517-51G-532B	1	145	51	\N	2018-04-26	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
596	МЦ.04-mon-230	\N	17"	1	145	51	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
597	МЦ.04-строка263	\N	Ноутбук HP 15s-eq1318ur	1	144	51	\N	2022-03-23	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
598	МЦ.04-mon-231	\N	15"	1	144	51	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
599	00-000889	\N	Ноутбук Lenovo Legion 5 17IMH05	1	144	51	\N	2021-03-07	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
600	МЦ.04-mon-232	\N	17"	1	144	51	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
601	00-001040	\N	ICL  B102 тип1	1	144	51	\N	2022-08-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
602	МЦ.04-mon-233	\N	AOC 27P2Q	1	144	51	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
603	МЦ.04-ups-102	\N	APC Back-UPS 650	1	144	51	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
604	00-000266	\N	Ноутбук HP 15-bs654ur (15-bs063ur);  (ООО "МОЛВЕРС")	1	144	51	\N	2018-04-26	\N	\N	Внешний диск Trancend 1TB StoreJet	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
605	МЦ.04-mon-234	\N	15,6"	1	144	51	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
606	00-000993	\N	ICL  B102 тип1	1	146	51	\N	2022-08-30	\N	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
607	МЦ.04-mon-235	\N	Samsung S27F358FWI	1	146	51	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
608	МЦ.04-mon-236	\N	Samsung S27F358FWI	1	146	51	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
609	МЦ.04-строка268	\N	Universal D1 (ООО «Десктоп»)	1	147	51	\N	2021-02-15	\N	\N	APC Back-UPS 650 ВА (BX650CI-RS)	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
610	МЦ.04-mon-237	\N	Philips 273V7QJAB	1	147	51	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
611	МЦ.04-mon-238	\N	Philips 273V7QJAB	1	147	51	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
612	МЦ.04-строка269	\N	Universal D1 (ООО «Десктоп»)	1	148	51	\N	2021-02-15	\N	\N	APC Back-UPS 650 ВА (BX650CI-RS)	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
613	МЦ.04-mon-239	\N	Samsung C32F391FWI	1	148	51	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
614	МЦ.04-mon-240	\N	Samsung C32F391FWI	1	148	51	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
615	00-000672	\N	AVK 2 (ООО «Вест-Тайп»)	1	149	51	\N	2020-02-05	\N	\N	Создана учетка: Юрчева Юлия Александрова	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
616	МЦ.04-mon-241	\N	Philips 273V7QJAB	1	149	51	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
617	МЦ.04-mon-242	\N	Philips 273V7QJAB	1	149	51	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
618	МЦ.04-mon-243	\N	Samsung F27T  (по факту)	1	149	51	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
619	МЦ.04-mon-244	\N	Samsung F27T  (по факту)	1	149	51	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
620	МЦ.04-ups-103	\N	Powercom RPT-1000A EURO	1	149	51	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
621	МЦ.04-строка271	\N	Ноутбук HP 250 G8 [3V5H7EA]	1	149	51	\N	2022-09-06	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
623	МЦ.04-mon-245	\N	Philips 273V7QJAB	1	150	51	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
624	МЦ.04-mon-246	\N	Philips 273V7QJAB	1	150	51	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
625	00-000669	\N	AVK 2 (ООО «Вест-Тайп»)	1	151	51	\N	2020-02-05	\N	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
626	МЦ.04-mon-247	\N	Philips 273V7QJAB	1	151	51	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
627	МЦ.04-mon-248	\N	Philips 273V7QJAB	1	151	51	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
628	МЦ.04.2-строка275	\N	Flextron	1	152	51	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
629	МЦ.04-строка276	\N	Ноутбук HP 15s-eq1318ur	1	152	51	\N	2022-03-23	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
630	МЦ.04-mon-249	\N	15"	1	152	51	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
631	00-000675	\N	AVK 2 (ООО «Вест-Тайп»)	1	153	51	\N	2020-02-05	\N	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
632	МЦ.04-mon-250	\N	MB27V13FS51	1	153	51	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
633	МЦ.04-mon-251	\N	MB27V13FS51	1	153	51	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
634	БП-001191	\N	RDW Xpert GE	1	154	51	\N	2024-05-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
635	МЦ.04-mon-252	\N	MB27V13FS51	1	154	51	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
636	МЦ.04-ups-104	\N	Powercom RPT-1000A EURO	1	154	51	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
637	БП-001200	\N	RDW Xpert GE	1	155	51	\N	2024-05-21	\N	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
638	МЦ.04-mon-253	\N	MB27V13FS51	1	155	51	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
639	99036-строка281	\N	Ноутбук SONY VAIO VPCF1	1	156	52	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
640	00-000267	\N	Ноутбук HP 15-bs654ur; (15-bs063ur);  (ООО "МОЛВЕРС")	1	156	52	\N	2018-04-26	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
641	МЦ.04-mon-254	\N	15,6"	1	156	52	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
642	МЦ.04.2-строка283	\N	USN Computers (mini)	1	157	52	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
643	МЦ.04-mon-255	\N	Philips 273V7QJAB	1	157	52	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
644	МЦ.04-ups-105	\N	Powercom SPIDER SPD-850N	1	157	52	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
645	00-000295	\N	Молверс2 ; (ООО "МОЛВЕРС")	1	156	52	\N	2018-04-26	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
646	МЦ.04-mon-256	\N	ASUS 23.8" BE249QLB	1	156	52	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
647	МЦ.04-ups-106	\N	Powercom RPT-1000A EURO	1	156	52	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
648	МЦ.04.2-строка285	\N	USN Computers (mini)	1	158	52	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
649	МЦ.04-mon-257	\N	ASUS 23.8" BE249QLB	1	158	52	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
650	00-000801	\N	МИР4	1	159	53	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
651	МЦ.04-mon-258	\N	Philips 273V7QJAB	1	159	53	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
652	МЦ.04-ups-107	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	159	53	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
653	00-000816	\N	МИР4	1	159	53	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
654	МЦ.04-mon-259	\N	Philips 273V7QJAB	1	159	53	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
655	МЦ.04-ups-108	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	159	53	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
656	00-000513	\N	____	1	160	54	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
657	МЦ.04-mon-260	\N	BenQ GL 2450 (спис.)	1	160	54	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
658	87993	\N	____	1	161	55	\N	2012-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
659	МЦ.04-mon-261	\N	Dell E2314H	1	161	55	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
660	МЦ.04-ups-109	\N	Powercom RPT-1000A EURO	1	161	55	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
661	МЦ.04-строка293	\N	LENOVO IdeaPad 330-151KBR (81DE01UDRU)	1	161	55	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
662	МЦ.04-mon-262	\N	15,6"	1	161	55	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
663	МЦ.04-строка294	\N	Universal D2 (ООО «Десктоп»)	1	162	55	\N	2021-02-15	\N	\N	APC Back-UPS 650 ВА (BX650CI-RS)	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
664	МЦ.04-mon-263	\N	Benq EW2430	1	162	55	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
665	МЦ.04-строка296	\N	Universal D2 (ООО «Десктоп»)	1	163	56	\N	2021-02-15	\N	\N	APC Back-UPS 650 ВА (BX650CI-RS)	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
666	МЦ.04-mon-264	\N	Philips 273V7QJAB	1	163	56	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
667	МЦ.04.2-строка298	\N	Flextron	1	164	57	\N	2013-01-01	\N	\N	APC Back-UPS 650 ВА (BX650CI-RS)	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
668	МЦ.04-mon-265	\N	Philips 273V7QJAB	1	164	57	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
669	87996	\N	Philips 273V7QJAB	1	165	57	\N	\N	\N	\N	APC Back-UPS 650 ВА (BX650CI-RS)	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
670	МЦ.04-mon-266	\N	Philips 273V7QJAB	1	165	57	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
671	МЦ.04 (s/n NXKN3CD00734108D693400)	\N	Ноутбук Acer Aspire A515-57-50EC	1	165	57	\N	2023-12-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
672	МЦ.04-mon-267	\N	15,6"	1	165	57	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
673	МЦ.04-строка301	\N	Universe	1	166	57	\N	2014-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
674	МЦ.04-mon-268	\N	Samsung S22C200	1	166	57	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
675	МЦ.04-mon-269	\N	Samsung S22C200.	1	166	57	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
676	МЦ.04.2-строка302	\N	USN Computers (mini)	1	167	57	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
677	МЦ.04-mon-270	\N	Benq GL2450	1	167	57	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
678	МЦ.04-mon-271	\N	Benq GL2450	1	167	57	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
679	00-001013	\N	ICL  B102 тип1	1	168	57	\N	2022-08-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
680	МЦ.04-mon-272	\N	Samsung S22C200	1	168	57	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
681	МЦ.04-ups-110	\N	Powercom RPT-1000A EURO	1	168	57	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
682	00-000296	\N	Молверс2 ; (ООО "МОЛВЕРС")	1	169	57	\N	2018-04-26	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
683	МЦ.04-mon-273	\N	Philips 273V7QJAB	1	169	57	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
684	МЦ.04-mon-274	\N	Philips 273V7QJAB	1	169	57	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
685	МЦ.04-ups-111	\N	APC Back-UPS 500(белый)	1	169	57	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
686	001202	\N	ARBYTE	1	170	57	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
687	МЦ.04-mon-275	\N	Dell U2412M	1	170	57	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
688	МЦ.04-строка307	\N	Universal D1 (ООО «Десктоп»)	1	171	58	\N	2021-02-15	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
689	МЦ.04-mon-276	\N	AOC 27P2Q	1	171	58	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
690	МЦ.04-mon-277	\N	NEC AS221WM	1	171	58	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
691	00-000678	\N	AVK 2 (ООО «Вест-Тайп»)	1	172	58	\N	2020-02-05	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
692	МЦ.04-mon-278	\N	Samsung S27F358FWI	1	172	58	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
693	МЦ.04-mon-279	\N	Samsung S27F358FWI	1	172	58	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
694	00-000555	\N	Моноблок HP Pavilion; I 27-xa0023ur	1	173	58	\N	2019-09-19	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Моноблок
695	МЦ.04-mon-280	\N	Philips 273V7QJAB	1	173	58	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
696	МЦ.04-ups-112	\N	APC Back-UPS BX650CI-RS	1	173	58	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
697	МОЛ Карлов С.Н.-строка311	\N	АРМ тип 1 Gigant G-Station Mid-tower (ООО «ГКС»)	1	174	59	\N	2023-11-09	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
698	МЦ.04-mon-281	\N	Aser XV322QK	1	174	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
699	МЦ.04-mon-282	\N	ASUS 32" PA328Q IPS LED 4K	1	174	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
700	МЦ.04-ups-113	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	1	174	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
701	00-000254	\N	МИР Z23272 (ООО "Мира")	1	174	59	\N	2017-12-22	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
702	МЦ.04-mon-283	\N	Philips 273V7QJAB	1	174	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
703	МЦ.04-mon-284	\N	Benq GL2450	1	174	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
704	МЦ.04-строка313	\N	INWIN	1	174	60	\N	2014-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
705	МЦ.04-mon-285	\N	SMART Board 8055i	1	174	60	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
706	00-000244	\N	МИР Z23273 (ООО "Мира"), сервер	1	174	59	\N	2017-12-22	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
707	МЦ.04-ups-114	\N	Ippon Innova RT 1000 900 Вт 1000 ВА	1	174	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
708	МЦ.04.2-строка315	\N	Коммутатор HPE 1820-48G J9981A	1	174	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
709	МОЛ Карлов С.Н.-строка316	\N	АРМ тип 1 Gigant G-Station Mid-tower (ООО «ГКС»)	1	175	59	\N	2023-11-09	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
710	МЦ.04-mon-286	\N	ASUS 32" PA328Q IPS LED 4K	1	175	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
711	МЦ.04-mon-287	\N	ACER XV322QK	1	175	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
712	МЦ.04-ups-115	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	1	175	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
713	МОЛ Карлов С.Н.-строка317	\N	АРМ тип 2 Gigant G-Station Mini-tower (ООО «ГКС»)	1	176	59	\N	2023-11-09	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
714	МЦ.04-mon-288	\N	Aser XV322QK	1	176	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
715	МЦ.04-mon-289	\N	ASUS 32" PA328Q IPS LED 4K	1	176	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
716	МЦ.04-ups-116	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	1	176	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
717	МОЛ Карлов С.Н.-строка318	\N	АРМ тип 2 Gigant G-Station Mini-tower (ООО «ГКС»)	1	177	59	\N	2023-11-09	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
718	МЦ.04-mon-290	\N	Aser XV322QK	1	177	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
719	МЦ.04-ups-117	\N	Powercom RPT-1000A EURO	1	177	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
720	00-000255	\N	МИР Z23272 (ООО "Мира")	1	178	59	\N	2017-12-22	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
721	МЦ.04-mon-291	\N	Benq 32" EW3270ZL	1	178	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
722	МЦ.04-ups-118	\N	APC Back-UPS BX1100CI-RS	1	178	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
723	00-001043	\N	ICL  B102 тип1	1	179	59	\N	2022-08-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
724	МЦ.04-mon-292	\N	AOC 27P2Q	1	179	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
725	МЦ.04-ups-119	\N	Powercom RPT-1000A EURO	1	179	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
726	МОЛ Карлов С.Н.-строка321	\N	АРМ тип 1 Gigant G-Station Mid-tower (ООО «ГКС»)	1	180	59	\N	2023-11-09	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
727	МЦ.04-mon-293	\N	Aser XV322QK	1	180	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
728	МЦ.04-mon-294	\N	Benq 32" EW3270ZL	1	180	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
729	МЦ.04-ups-120	\N	APC Back-UPS BX650CI-RS	1	180	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
730	МОЛ Карлов С.Н.-строка322	\N	АРМ тип 2 Gigant G-Station Mini-tower (ООО «ГКС»)	1	181	59	\N	2023-11-09	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
731	МЦ.04-mon-295	\N	Aser XV322QK	1	181	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
732	МОЛ Карлов С.Н.-строка323	\N	АРМ тип 2 Gigant G-Station Mini-tower (ООО «ГКС»)	1	182	59	\N	2023-11-09	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
733	МЦ.04-mon-296	\N	Aser XV322QK	1	182	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
734	МЦ.04-mon-297	\N	AOC 27P2Q	1	182	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
735	00-000247	\N	МИР Z23271 (ООО "Мира")	1	183	59	\N	2017-12-22	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
736	МЦ.04-mon-298	\N	Benq 32" EW3270ZL	1	183	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
737	МЦ.04-ups-121	\N	APC Back-UPS BX1100CI-RS	1	183	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
738	МЦ.04-строка325	\N	SuperMicro	1	184	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
739	МЦ.04-mon-299	\N	Benq 32" EW3270ZL	1	184	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
740	МЦ.04-ups-122	\N	Powercom RPT-1000A EURO	1	184	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
741	00-000248	\N	МИР Z23271 (ООО "Мира")	1	185	59	\N	2017-12-22	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
742	МЦ.04-mon-300	\N	Benq 32" EW3270ZL	1	185	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
743	МЦ.04-ups-123	\N	APC Back-UPS BX1100CI-RS	1	185	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
744	87995	\N	_____	1	185	59	\N	2012-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
745	МЦ.04-mon-301	\N	Dell E2314H	1	185	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
746	МЦ.04-строка328	\N	INWIN	1	185	59	\N	2014-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
747	МЦ.04-mon-302	\N	Benq GL2450	1	185	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
748	МЦ.04-строка329	\N	Benq 32" EW3270ZL	1	185	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
749	00-000246	\N	МИР Z23271 (ООО "Мира")	1	186	59	\N	2017-12-22	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
750	МЦ.04-mon-303	\N	Samsung C32F391FWI	1	186	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
751	МЦ.04-ups-124	\N	APC Back-UPS BX1100CI-RS	1	186	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
752	МЦ.04-MON-331	\N	МЦ.04-MON-331	1	185	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
753	00-000253	\N	МИР Z23271 (ООО "Мира")	1	187	59	\N	2017-12-22	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
754	МЦ.04-mon-304	\N	Benq 32" EW3270ZL	1	187	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
755	МЦ.04-ups-125	\N	APC Back-UPS BX1100CI-RS	1	187	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
756	00-000268	\N	Ноутбук HP Pavilion 15-cc532ur	1	187	59	\N	2018-04-26	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
757	МЦ.04-mon-305	\N	15,6"	1	187	59	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
758	НИИСУ-строка335	\N	ARBYTE	1	188	61	\N	\N	\N	\N	DCM 1000	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
759	МЦ.04-mon-306	\N	Dell U214Hb	1	188	61	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
760	00-000963	\N	Некстген3	1	189	61	\N	2022-03-17	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
761	МЦ.04-mon-307	\N	AOC 27P2Q	1	189	61	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
762	НИИСУ-строка337	\N	ARBYTE	1	190	61	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
763	МЦ.04-mon-308	\N	AOC 27P2Q	1	190	61	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
764	00-000953	\N	Некстген1	1	191	61	\N	2022-03-10	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
765	МЦ.04-mon-309	\N	NEC MultiSync EA243WM	1	191	61	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
766	МЦ.04-ups-126	\N	Powercom BNT-1000AP	1	191	61	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
767	НИИСУ-строка339	\N	ARBYTE	1	188	61	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
768	МЦ.04-mon-310	\N	LG Flatron W2242T	1	188	61	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
769	МЦ.04-ups-127	\N	APC Back-UPS BX650CI-RS	1	188	61	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
770	НИИСУ-строка340	\N	ARBYTE	1	188	62	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
771	МЦ.04-mon-311	\N	NEC MultiSync E231W	1	188	62	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
772	МЦ.04-ups-128	\N	APC Back-UPS BX650CI-RS	1	188	62	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
773	МЦ.04.2-строка343	\N	Flextron	1	192	63	\N	2012-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
774	МЦ.04-mon-312	\N	Philips 273V7QJAB/01/00	1	192	63	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
775	МЦ.04-строка344	\N	Ноутбук Acer Aspire 7720G	1	192	63	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
776	МЦ.04-mon-313	\N	17"	1	192	63	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
777	00-000951	\N	Некстген1	1	193	64	\N	2022-03-10	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
778	МЦ.04-mon-314	\N	AOC 27P2Q	1	193	64	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
779	00-000331	\N	SuperMicro	1	194	64	\N	2014-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
780	МЦ.04-mon-315	\N	Benq BL2201	1	194	64	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
781	МЦ.04.2-строка347	\N	Flextron	1	195	65	\N	2012-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
782	МЦ.04-mon-316	\N	MB27V13FS51	1	195	65	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
783	МЦ.04-ups-129	\N	APC 500 (Белый)	1	195	65	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
784	МЦ.04-строка349	\N	Universal D2 (ООО «Десктоп»)	1	196	66	\N	2021-02-15	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
785	МЦ.04-mon-317	\N	Philips 273V7QJAB	1	196	66	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
786	МЦ.04-ups-130	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	196	66	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
787	Собран из частей безопасниками	\N	ARBYTE	1	197	66	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
788	МЦ.04-mon-318	\N	Philips 273V7QJAB/01/00	1	197	66	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
789	БП-001215	\N	RDW Xpert GE	1	198	66	\N	2024-05-14	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
790	МЦ.04-mon-319	\N	Dell E214H	1	198	66	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
791	МЦ.04-ups-131	\N	Powercom RPT-1000A EURO	1	198	66	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
793	МЦ.04-mon-320	\N	MB27V13FS51	1	199	67	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
794	МЦ.04-mon-321	\N	MB27V13FS51	1	199	67	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
795	МЦ.04-ups-132	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	1	199	67	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
796	МЦ.04-строка354	\N	Ноутбук HP 15s-eq1436ur	1	199	67	\N	2022-03-05	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
797	МЦ.04-mon-322	\N	15"	1	199	67	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
798	МЦ.04-строка355	\N	Ноутбук Acer Aspire 5 A515-57-52ZZ	1	199	67	\N	2024-06-07	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
799	МЦ.04-mon-323	\N	15"	1	199	67	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
800	00-001046	\N	ICL  B102 тип1	1	200	67	\N	2022-08-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
801	МЦ.04-mon-324	\N	Nec E222W	1	200	67	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
802	МЦ.04-mon-325	\N	Nec Multisync E231W	1	200	67	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
803	МЦ.04-ups-133	\N	Powercom RPT-1000A EURO	1	200	67	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
804	00-000667	\N	AVK 2 (ООО «Вест-Тайп»)	1	201	67	\N	2020-02-05	\N	\N	APC Back-UPS 650 ВА (BX650CI-RS)	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
805	МЦ.04-mon-326	\N	AOC 27P2Q	1	201	67	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
806	МЦ.04-mon-327	\N	AOC 27P2Q	1	201	67	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
807	МЦ.04.2-строка358	\N	RAMEK	1	202	67	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
808	МЦ.04-mon-328	\N	AOC 27P2Q	1	202	67	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
809	МЦ.04-mon-329	\N	AOC 27P2Q	1	202	67	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
810	МЦ.04-ups-134	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	1	202	67	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
811	00-001038	\N	ICL  B102 тип1	1	203	67	\N	2022-08-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
812	МЦ.04-mon-330	\N	AOC 27P2Q	1	203	67	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
813	МЦ.04-mon-331	\N	AOC 27P2Q	1	203	67	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
814	МЦ.04-ups-135	\N	Powercom RPT-1000A EURO	1	203	67	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
815	00-000338	\N	HP Z240	1	204	67	\N	2016-12-23	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
816	МЦ.04-mon-332	\N	Dell U2412M	1	204	67	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
817	МЦ.04-mon-333	\N	Acer RT240Y	1	204	67	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
818	НИИСУ-строка361	\N	ARBYTE	1	205	67	\N	2012-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
819	МЦ.04-mon-334	\N	AOC 27P2Q	1	205	67	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
820	00-000337	\N	Ноутбук HP EliteBook 8540w	1	205	67	\N	2010-07-31	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
822	БП-001203	\N	RDW Xpert GE	1	206	67	\N	2024-05-21	\N	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
823	МЦ.04-mon-336	\N	MB27V13FS51	1	206	67	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
824	МЦ.04-строка364	\N	USN Computers (mini)	1	207	67	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
825	МЦ.04-mon-337	\N	MB27V13FS51	1	207	67	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
826	00-000218	\N	МИР Z2330 (ООО "Мира")	1	207	67	\N	2017-12-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
827	МЦ.04-mon-338	\N	Samsung 27" C27F390FHI	1	207	67	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
828	МЦ.04-mon-339	\N	Samsung S22C200	1	207	67	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
829	МЦ.04-ups-136	\N	APC 500 (черный)	1	207	67	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
830	БП-001182	\N	RDW Xpert GE	1	208	67	\N	2024-05-21	\N	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
831	МЦ.04-mon-340	\N	Philips 273V7QJAB	1	208	67	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
832	МЦ.04-строка368	\N	Universal D1 (ООО «Десктоп»)	1	209	68	\N	2021-02-15	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
833	МЦ.04-mon-341	\N	Philips 243V7QJABF	1	209	68	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
834	МЦ.04-mon-342	\N	Philips 243V7QJABF	1	209	68	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
835	МЦ.04-ups-137	\N	APC Back-UPS 650  (Белый)	1	209	68	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
836	МЦ.04.2-строка369	\N	INWIN	1	210	68	\N	2014-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
837	МЦ.04-mon-343	\N	LG Flatron L192WS	1	210	68	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
838	НИИСУ-строка370	\N	ARBYTE	1	211	68	\N	2012-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
839	МЦ.04-mon-344	\N	Samsung S22C200	1	211	68	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
840	00-000450	\N	ARBYTE	1	212	68	\N	2012-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
841	МЦ.04-mon-345	\N	Nec MultiSync V221W	1	212	68	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
842	БП-001163	\N	RDW Xpert GE	1	213	68	\N	2024-05-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
843	МЦ.04-mon-346	\N	Samsung S22C200	1	213	68	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
844	НИИСУ-строка373	\N	ARBYTE	1	214	68	\N	2012-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
845	МЦ.04-mon-347	\N	Samsung SyncMaster SA450 (19")	1	214	68	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
846	00-000788	\N	МИР 3	1	215	68	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
847	МЦ.04-mon-348	\N	Dell E2314H	1	215	68	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
848	МЦ.04-ups-138	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	215	68	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
849	НИИСУ-строка375	\N	ARBYTE	1	216	68	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
850	МЦ.04-mon-349	\N	Samsung SyncMaster SA450 (19")	1	216	68	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
851	00-000958	\N	Некстген2	1	217	68	\N	2022-03-16	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
852	МЦ.04-mon-350	\N	AOC 27P2Q	1	217	68	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
853	99036-строка377	\N	Flextron	1	218	68	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
854	МЦ.04-mon-351	\N	Samsung SyncMaster S22C200	1	218	68	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
855	МЦ.04.2-строка378	\N	Flextron	1	219	69	\N	2012-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
856	МЦ.04-mon-352	\N	Philips 273V7QJAB	1	219	69	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
857	БП-001175	\N	RDW Xpert GE	1	220	68	\N	2024-05-21	\N	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
858	МЦ.04-mon-353	\N	MB27V13FS51	1	220	68	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
859	БП-001185	\N	RDW Xpert GE	1	221	68	\N	2024-05-21	\N	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
860	МЦ.04-mon-354	\N	MB27V13FS51	1	221	68	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
861	БП-001195	\N	RDW Xpert GE	1	222	68	\N	2024-05-21	\N	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
862	МЦ.04-mon-355	\N	MB27V13FS51	1	222	68	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
863	00-001017	\N	ICL  B102 тип1	1	223	70	\N	2022-08-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
864	МЦ.04-mon-356	\N	Lenovo L27e-30 27"	1	223	70	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
865	МЦ.04-ups-139	\N	Powercom RPT-1000A EURO	1	223	70	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
866	00-000996	\N	ICL  B102 тип1	1	224	70	\N	2022-08-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
867	МЦ.04-mon-357	\N	Lenovo L27e-30 27"	1	224	70	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
868	МЦ.04-ups-140	\N	Powercom RPT-1000A EURO	1	224	70	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
869	00-000997	\N	ICL  B102 тип1	1	225	70	\N	2022-08-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
870	МЦ.04-mon-358	\N	Lenovo L27e-30 27"	1	225	70	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
871	МЦ.04-ups-141	\N	Powercom RPT-1000A EURO	1	225	70	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
872	00-000992	\N	ICL  B102 тип1	1	226	70	\N	2022-08-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
873	МЦ.04-mon-359	\N	Philips 273V7QJAB	1	226	70	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
874	МЦ.04-ups-142	\N	Powercom RPT-1000A EURO	1	226	70	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
875	00-001045	\N	ICL  B102 тип1	1	227	70	\N	2022-08-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
876	МЦ.04-mon-360	\N	Philips 273V7QJAB	1	227	70	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
877	МЦ.04-mon-361	\N	Lenovo L27e-30 27"	1	227	70	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
878	МЦ.04-ups-143	\N	Powercom RPT-1000A EURO	1	227	70	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
879	00-001058	\N	ICL  B102 тип1	1	228	70	\N	2022-08-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
880	МЦ.04-mon-362	\N	Dell E2314H	1	228	70	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
881	МЦ.04-ups-144	\N	Powercom RPT-1000A EURO	1	228	70	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
882	00-001000	\N	ICL  B102 тип1	1	229	70	\N	2022-08-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
883	МЦ.04-mon-363	\N	Philips 273V7QJAB	1	229	70	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
884	МЦ.04-ups-145	\N	Powercom RPT-1000A EURO	1	229	70	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
885	00-001006	\N	ICL  B102 тип1	1	230	70	\N	2022-08-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
886	МЦ.04-mon-364	\N	Philips 273V7QJAB	1	230	70	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
887	МЦ.04-ups-146	\N	Powercom RPT-1000A EURO	1	230	70	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
888	00-001007	\N	ICL  B102 тип1	1	231	70	\N	2022-08-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
889	МЦ.04-mon-365	\N	Dell E2314H	1	231	70	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
890	МЦ.04-ups-147	\N	Powercom RPT-1000A EURO	1	231	70	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
891	00-001052	\N	ICL  B102 тип1	1	232	70	\N	2022-08-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
892	МЦ.04-mon-366	\N	MB27V13FS51	1	232	70	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
893	МЦ.04-ups-148	\N	Powercom RPT-1000A EURO	1	232	70	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
894	00-001047	\N	ICL  B102 тип1	1	233	70	\N	2022-08-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
895	МЦ.04-mon-367	\N	AOC 27P2Q	1	233	70	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
896	МЦ.04-ups-149	\N	Powercom RPT-1000A EURO	1	233	70	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
897	БП-001174	\N	RDW Xpert GE	1	234	70	\N	2024-05-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
898	МЦ.04-mon-368	\N	MB27V13FS51	1	234	70	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
899	МЦ.04-ups-150	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	1	234	70	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
900	БП-001228	\N	RDW Xpert GE	1	235	70	\N	2024-05-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
901	МЦ.04-mon-369	\N	MB27V13FS51	1	235	70	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
902	МЦ.04-ups-151	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	1	235	70	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
903	БП-001159	\N	RDW Xpert GE	1	236	70	\N	2024-05-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
904	МЦ.04-mon-370	\N	MB27V13FS51	1	236	70	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
905	МЦ.04-ups-152	\N	APC Back-UPS 500(белый)	1	236	70	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
906	БП-001207	\N	RDW Xpert GE	1	237	70	\N	2024-05-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
907	МЦ.04-mon-371	\N	MB27V13FS51	1	237	70	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
908	МЦ.04-ups-153	\N	APC Back-UPS 500(белый)	1	237	70	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
909	00-001010	\N	ICL  B102 тип1	1	238	70	\N	2022-08-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
910	МЦ.04-mon-372	\N	Philips 273V7QJAB	1	238	70	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
911	МЦ.04-ups-154	\N	Powercom RPT-1000A EURO	1	238	70	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
912	1000048	\N	моноблок Lenovo ideacentre B520	1	239	71	\N	2012-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Моноблок
913	МЦ.04-mon-373	\N	моноблок Lenovo 23"	1	239	71	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
914	1000055	\N	моноблок Lenovo ideacentre B520	1	239	71	\N	2012-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Моноблок
915	МЦ.04-mon-374	\N	моноблок Lenovo 23"	1	239	71	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
916	190363	\N	Ноутбук Acer Aspire 7720G	1	239	71	\N	2010-01-01	\N	\N	Списано 30-12-2021	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
917	МЦ.04-mon-375	\N	17"	1	239	71	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
918	МЦ.04.2-строка403	\N	Flextron	1	240	71	\N	2012-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
919	МЦ.04-mon-376	\N	Benq EW2450	1	240	71	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
920	МЦ.04.2-строка404	\N	Flextron	1	241	71	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
921	МЦ.04-mon-377	\N	Nec Multisync EA222WMe	1	241	71	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
922	00-000960	\N	Некстген3	1	242	71	\N	2022-03-17	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
923	МЦ.04-mon-378	\N	Lenovo L27e-30 27"	1	242	71	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
924	БП-001177	\N	RDW Xpert GE	1	243	71	\N	2024-05-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
925	МЦ.04-mon-379	\N	MB27V13FS51	1	243	71	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
926	МЦ.04-ups-155	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	1	243	71	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
927	БП-001151	\N	RDW Xpert GE	1	244	71	\N	2024-05-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
928	МЦ.04-mon-380	\N	MB27V13FS51	1	244	71	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
929	00-001041	\N	ICL  B102 тип1	1	245	72	\N	2022-08-30	\N	\N	APC Back-UPS CS500	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
930	МЦ.04-mon-381	\N	AOC 27P2Q	1	245	72	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
931	МЦ.04-строка410	\N	ноутбук  Acer 7250G	1	245	72	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
932	МЦ.04-MON-411	\N	Samsung S24B300B	1	246	72	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
933	МЦ.04-строка412	\N	USN Computers (mini)	1	247	73	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
934	МЦ.04-mon-382	\N	Philips 273V7QJAB	1	247	73	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
935	БП-001160	\N	RDW Xpert GE	1	248	73	\N	2024-05-14	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
936	МЦ.04-mon-383	\N	AOC 27P2Q	1	248	73	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
937	МЦ.04-ups-156	\N	Powercom RPT-1000A EURO	1	248	73	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
938	МЦ.04-строка414	\N	Universal D2 (ООО «Десктоп»)	1	249	73	\N	2021-02-15	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
939	МЦ.04-mon-384	\N	Philips 273V7QJAB	1	249	73	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
940	МЦ.04.1-строка416	\N	SuperMicro	1	250	74	\N	2014-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
941	МЦ.04-mon-385	\N	Samsung 24"S24D300H	1	250	74	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
942	МЦ.04-ups-157	\N	Powercom RPT-1000A EURO	1	250	74	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
943	МЦ.04-строка417	\N	Ноутбук Acer Aspire 5 A515-57-52ZZ	1	250	74	\N	2024-06-07	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
944	МЦ.04-mon-386	\N	15"	1	250	74	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
945	НИИСУ-строка418	\N	Hyper-X	1	251	74	\N	2012-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
946	МЦ.04-mon-387	\N	Dell E2314HF	1	251	74	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
947	МЦ.04.2-строка419	\N	Flextron	1	252	74	\N	2014-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
948	МЦ.04-ups-158	\N	Powercom RPT-1000A EURO	1	252	74	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
949	МЦ.04-строка420	\N	Ноутбук Acer Aspire 5 A515-57-52ZZ	1	252	74	\N	2024-06-07	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
950	МЦ.04-mon-388	\N	15"	1	252	74	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
951	МЦ.04.2-строка421	\N	Flextron	1	253	74	\N	2014-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
952	МЦ.04-mon-389	\N	Philips 273V7QJAB	1	253	74	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
953	МЦ.04-mon-390	\N	AOC 27P2Q - где?	1	253	74	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
954	МЦ.04-строка422	\N	Ноутбук Acer Aspire 5 A515-57-52ZZ	1	253	74	\N	2024-06-07	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
955	МЦ.04-mon-391	\N	15"	1	253	74	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
956	00-000670	\N	AVK 2 (ООО «Вест-Тайп»)	1	254	74	\N	2020-02-05	\N	\N	Компьютерная гарнитура Оклик HS-L320G Phoenix, Веб-камера Logitech HD Pro C920	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
957	МЦ.04-mon-392	\N	Samsung S27F358FWI	1	254	74	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
958	МЦ.04-mon-393	\N	Samsung S27F358FWI	1	254	74	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
959	МЦ.04-ups-159	\N	Powercom RPT-1000A EURO	1	254	74	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
960	МЦ.04-строка424	\N	Ноутбук Asus R521JB-ET280T	1	254	74	\N	2020-10-09	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
961	МЦ.04-строка425	\N	Ноутбук HP 250 G8 [3V5H7EA]	1	255	74	\N	2022-09-06	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
962	МЦ.04-строка426	\N	AOC 27P2Q; AOC 27P2Q	1	256	74	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
963	00-001039	\N	ICL  B102 тип1	1	257	74	\N	2022-08-30	\N	\N	Внешний SSD ADATA SE760 Black External ASE760-512GU32G2-CBK	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
964	МЦ.04-mon-394	\N	AOC 27P2Q	1	257	74	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
965	МЦ.04-mon-395	\N	AOC 27P2Q	1	257	74	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
966	МЦ.04-ups-160	\N	Powercom RPT-1000A EURO	1	257	74	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
967	00-001037	\N	ICL  B102 тип1	1	258	74	\N	2022-08-30	\N	\N	Созданы учетки: Чернышева Алина Руслановна	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
968	МЦ.04-mon-396	\N	AOC 27P2Q	1	258	74	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
969	МЦ.04-mon-397	\N	AOC 27P2Q	1	258	74	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
970	МЦ.04-ups-161	\N	APC Back-UPS 500	1	258	74	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
971	МЦ.04-строка429	\N	Ноутбук Acer Aspire 5 A515-57-52ZZ	1	258	74	\N	2024-06-07	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
972	МЦ.04-mon-398	\N	15"	1	258	74	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
973	МЦ.04-строка430	\N	Universal D1 (ООО «Десктоп»)	1	259	74	\N	2021-02-15	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
974	МЦ.04-mon-399	\N	AOC 27P2Q	1	259	74	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
975	МЦ.04-mon-400	\N	AOC 27P2Q	1	259	74	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
976	МЦ.04-ups-162	\N	APC Back-UPS 500(белый)	1	259	74	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
977	БП-001209	\N	RDW Xpert GE	1	260	74	\N	2024-05-21	\N	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
978	МЦ.04-mon-401	\N	MB27V13FS51	1	260	74	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
979	БП-001157	\N	RDW Xpert GE	1	261	74	\N	2024-05-21	\N	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
980	МЦ.04-mon-402	\N	MB27V13FS51	1	261	74	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
981	МЦ.04-mon-403	\N	Dell E2314HF	1	261	74	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
982	БП-001178	\N	RDW Xpert GE	1	262	74	\N	2024-05-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
983	МЦ.04-mon-404	\N	Iiyama Prolite E2483HS	1	262	74	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
984	МЦ.04-ups-163	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	262	74	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
985	БП-001165	\N	RDW Xpert GE	1	263	74	\N	2024-05-21	\N	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА; Внешний SSD ADATA SE760 Black External ASE760-512GU32G2-CBK	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
986	МЦ.04-mon-405	\N	AOC 27P2Q	1	263	74	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
987	МЦ.04-mon-406	\N	AOC 27P2Q	1	263	74	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
988	00-000826	\N	МИР5	1	264	75	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
989	МЦ.04-mon-407	\N	Philips 273V7QJAB	1	264	75	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
990	МЦ.04-ups-164	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	1	264	75	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
991	БП-001171	\N	RDW Xpert GE	1	264	75	\N	2024-05-14	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
992	МЦ.04-mon-408	\N	MB27V13FS51	1	264	75	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
993	МЦ.04-ups-165	\N	APC Back-UPS 650 ВА (белый)	1	264	75	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
994	00-000828	\N	МИР5	1	265	75	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
995	МЦ.04-mon-409	\N	Philips 273V7QJAB	1	265	75	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
996	МЦ.04-mon-410	\N	Philips 240V5Q	1	265	75	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
997	МЦ.04-ups-166	\N	APC Back-UPS 650 ВА	1	265	75	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
998	00-000829	\N	МИР5	1	266	75	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
999	МЦ.04-mon-411	\N	Philips 273V7QJAB	1	266	75	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1000	МЦ.04-mon-412	\N	Samsung C32F391FWI	1	266	75	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1001	МЦ.04-ups-167	\N	APC Back-UPS 650 ВА	1	266	75	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1002	00-000830	\N	МИР5	1	7	75	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1003	МЦ.04-mon-413	\N	Philips 273V7QJAB	1	7	75	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1004	МЦ.04-mon-414	\N	Philips 273V7QJAB	1	7	75	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1005	МЦ.04-ups-168	\N	APC Back-UPS 650 ВА	1	7	75	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1006	00-000825	\N	МИР5	1	264	75	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1007	МЦ.04-ups-169	\N	Powercom RPT-1000A EURO	1	264	75	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1008	00-000827	\N	МИР5	1	267	75	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1009	МЦ.04-mon-415	\N	Philips 273V7QJAB	1	267	75	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1010	МЦ.04-mon-416	\N	Samsung 27" C27F390FHI	1	267	75	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1011	МЦ.04-ups-170	\N	APC Back-UPS 650 ВА	1	267	75	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1012	МЦ.04-строка443	\N	Samsung S27F358FWI; Samsung S27F358FWI	1	268	75	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1013	МЦ.04-ups-171	\N	Powercom RPT-1000A EURO	1	268	75	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1014	БП-001230	\N	RDW Xpert GE	1	269	75	\N	2024-05-14	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1015	МЦ.04-mon-417	\N	MB27V13FS51	1	269	75	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1016	МЦ.04-ups-172	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	1	269	75	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1017	00-000548	\N	Ноутбук  Xiaomi Mi Notebook Pro 15.6	1	270	76	\N	2019-09-19	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
1018	МЦ.04-mon-418	\N	15,6"	1	270	76	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1019	МЦ.04-mon-419	\N	Philips 273V7QJAB	1	270	76	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1020	МЦ.04-строка447	\N	Ноутбук Honor BBR-WAH9	1	271	76	\N	2022-03-05	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
1021	МЦ.04-mon-420	\N	15,6"	1	271	76	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1022	МЦ.04-строка448	\N	Ноутбук Honor BBR-WAH9	1	271	76	\N	2022-03-05	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
1023	МЦ.04-mon-421	\N	15,6"	1	271	76	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1024	00-000891	\N	Ноутбук Lenovo Legion 5 17IMH05	1	270	76	\N	2021-03-07	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
1025	МЦ.04-mon-422	\N	17"	1	270	76	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1026	МЦ.04-строка451	\N	USN Computers (mini)	1	272	77	\N	2013-01-01	\N	\N	новый кулер	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1027	МЦ.04-mon-423	\N	Benq GL2460	1	272	77	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1028	00-000955	\N	Некстген2	1	273	78	\N	2022-03-16	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1029	МЦ.04-mon-424	\N	Lenovo L27e-30 27"	1	273	78	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1030	МЦ.04-ups-173	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	1	273	78	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1031	99036-строка454	\N	Flextron	1	274	78	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1032	МЦ.04-mon-425	\N	LG Flatron L192WS	1	274	78	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1033	МЦ.04.2-строка455	\N	Flextron	1	275	78	\N	2012-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1034	МЦ.04-mon-426	\N	Samsung S22C200	1	275	78	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1035	МЦ.04-MON-456	\N	МЦ.04-MON-456	1	274	79	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1036	МЦ.04-ups-174	\N	IPPON Smart Winner 2000	1	274	79	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1037	МЦ.04-строка458	\N	Universal D1 (ООО «Десктоп»)	1	276	80	\N	2021-02-15	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1038	МЦ.04-mon-427	\N	Asus VX239 IPS HDMI MHL	1	276	80	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1039	00-000673	\N	AVK 2 (ООО «Вест-Тайп»)	1	277	80	\N	2020-02-05	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1040	МЦ.04-mon-428	\N	Samsung S27F358FWI	1	277	80	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1041	МЦ.04-строка460	\N	Ноутбук HP 15s-eq1318ur	1	277	80	\N	2022-03-23	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
1042	МЦ.04-mon-429	\N	15"	1	277	80	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1043	00-000171	\N	Aerocool	1	278	81	\N	2014-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1044	МЦ.04-mon-430	\N	AOC 24P2Q	1	278	81	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1045	МЦ.04.2-строка463	\N	Flextron	1	279	81	\N	2012-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1046	МЦ.04-mon-431	\N	Dell 27"	1	279	81	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1047	МЦ.04-ups-175	\N	APC Back-UPS 500(белый)	1	279	81	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1048	00-001020	\N	ICL  B102 тип1	1	279	81	\N	2022-08-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1049	МЦ.04-mon-432	\N	LG Flatron W2261VP	1	279	81	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1050	МЦ.04.2-строка465	\N	USN Computers (mini)	1	280	81	\N	2013-01-01	\N	\N	новый кулер	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1051	МЦ.04-mon-433	\N	Benq GL2450	1	280	81	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1052	МЦ.04.2-строка466	\N	USN Computers (mini)	1	280	81	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1053	МЦ.04-mon-434	\N	Benq G2220HD	1	280	81	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1054	МЦ.04 (От безопасников)-строка467	\N	Aerocool	1	281	81	\N	2022-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1055	МЦ.04-mon-435	\N	Nec E222W	1	281	81	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1056	МЦ.04-ups-176	\N	Powercom RPT-1000A EURO	1	281	81	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1057	00-000956	\N	Некстген2	1	282	81	\N	2022-03-16	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1058	МЦ.04-mon-436	\N	ASUS PA249Q	1	282	81	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1059	МЦ.04-ups-177	\N	APC Back-UPS BC650-RSX761	1	282	81	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1060	МЦ.04-ROW-469	\N	СБ	1	283	81	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1061	МЦ.04-mon-437	\N	BENQ  GL2450	1	283	81	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1062	МЦ.04-ups-178	\N	APC Back-UPS BC650-RSX761	1	283	81	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1063	00-000806	\N	МИР4	1	284	82	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1064	МЦ.04-mon-438	\N	Philips 273V7QJAB	1	284	82	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1065	МЦ.04-ups-179	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	284	82	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1066	Электроника-строка472	\N	Моноблок Lenovo ThinkCentre Edge 72z	1	284	82	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Моноблок
1067	Электроника-строка473	\N	Моноблок Lenovo ThinkCentre Edge 72z	1	285	82	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Моноблок
1068	Электроника-строка474	\N	Моноблок Lenovo ThinkCentre Edge 72z	1	286	82	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Моноблок
1069	НИИСУ-строка475	\N	ARBYTE	1	286	82	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1070	МЦ.04-mon-439	\N	Dell P2219H	1	286	82	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1071	00-000815	\N	МИР4	1	287	82	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1072	МЦ.04-mon-440	\N	Philips 273V7QJAB	1	287	82	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1073	МЦ.04-ups-180	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	1	287	82	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1074	МЦ.04-MON-477	\N	МЦ.04-MON-477	1	287	82	\N	\N	\N	\N	Дубликатор дисков на  5 приводов - инв. № 00-000879	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1075	Электроника-строка478	\N	Моноблок Lenovo ThinkCentre Edge 72z	1	287	82	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Моноблок
1076	МЦ.04.2-строка479	\N	USN Computers (mini)	1	288	82	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1077	МЦ.04-mon-441	\N	Samsung S22C200	1	288	82	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1078	00-000221	\N	МИР Z2330 (ООО "Мира")	1	288	82	\N	2017-12-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1079	МЦ.04-mon-442	\N	Samsung 27" C27F390FHI	1	288	82	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1080	МЦ.04-ups-181	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	288	82	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1081	НИИСУ-строка481	\N	ARBYTE	1	289	82	\N	2012-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1082	МЦ.04-mon-443	\N	Philips 273V7QJAB	1	289	82	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1083	МЦ.04-ups-182	\N	APC Back-UPS 500(белый)	1	289	82	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1084	МЦ.04.2-строка482	\N	USN Computers (mini)	1	290	82	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1085	МЦ.04-mon-444	\N	Samsung 27" C27F390FHI	1	290	82	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1086	00-000222	\N	МИР Z2330 (ООО "Мира")	1	290	82	\N	2017-12-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1087	МЦ.04-mon-445	\N	Samsung S22C200	1	290	82	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1088	00-000236	\N	МИР Z2330 (ООО "Мира")	1	291	82	\N	2017-12-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1089	МЦ.04-mon-446	\N	Samsung 27" C27F390FHI	1	291	82	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1090	МЦ.04-ups-183	\N	Powercom RPT-1000A EURO	1	291	82	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1091	Электроника-строка485	\N	INWIN	1	291	82	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1092	МЦ.04-mon-447	\N	NEC MultiSync EA223WN	1	291	82	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1093	Электроника-строка486	\N	INWIN	1	292	82	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1094	МЦ.04-mon-448	\N	AOC 27P2Q	1	292	82	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1095	МЦ.04-ups-184	\N	Powercom RPT-1000A EURO	1	292	82	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1096	00-000294	\N	Молверс2 ; (ООО "МОЛВЕРС")	1	292	82	\N	2018-04-26	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1097	МЦ.04-mon-449	\N	MB27V13FS51	1	292	82	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1098	00-000807	\N	МИР4	1	293	82	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1099	МЦ.04-mon-450	\N	Philips 273V7QJAB	1	293	82	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1100	МЦ.04-ups-185	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	293	82	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1101	НИИСУ-строка490	\N	ARBYTE	1	294	83	\N	2016-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1102	МЦ.04-mon-451	\N	Моноблок Asus V220IC	1	294	83	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1103	НИИСУ-строка492	\N	ARBYTE	1	295	84	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1104	МЦ.04-mon-452	\N	Nec AccuSync AS241W	1	295	84	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1105	МЦ.04.1-строка493	\N	ARBYTE	1	296	84	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1106	МЦ.04-mon-453	\N	Nec MultiSync E222W	1	296	84	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1107	МЦ.04-ROW-494	\N	OLDI	1	297	84	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1108	МЦ.04-mon-454	\N	Acer V243H	1	297	84	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1109	00-001044	\N	ICL  B102 тип1	1	298	85	\N	2022-08-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1110	МЦ.04-mon-455	\N	Philips 273V7QJAB	1	298	85	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1111	МЦ.04-ups-186	\N	APC Back-UPS 500 ВА	1	298	85	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1112	МЦ.04.2-строка498	\N	USN Computers (mini)	1	299	86	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1113	МЦ.04-mon-456	\N	Samsung S22C200	1	299	86	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1114	МЦ.04-mon-457	\N	Samsung S22C200	1	299	86	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1115	МЦ.04.2-строка499	\N	USN Computers (mini)	1	299	86	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1116	МЦ.04-mon-458	\N	Philips 273V7QJAB	1	299	86	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1117	МЦ.04-mon-459	\N	Samsung S22C200	1	299	86	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1118	МЦ.04.2-строка500	\N	USN Computers (mini)	1	300	86	\N	2013-01-01	\N	\N	Созданы учетки: Фадиной Марины Владимировны, Муравьевой Марины Николаевны	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1119	МЦ.04-mon-460	\N	Samsung S22C200	1	300	86	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1120	00-000787	\N	МИР 3	1	301	86	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1121	МЦ.04-mon-461	\N	Philips 273V7QJAB	1	301	86	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1122	МЦ.04-mon-462	\N	Samsung Syncmaster SA450	1	301	86	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1123	00-000237	\N	МИР Z2330 (ООО "Мира")	1	302	86	\N	2017-12-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1124	МЦ.04-mon-463	\N	Samsung SyncMaster S24B300	1	302	86	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1125	00-000786	\N	МИР 3	1	302	86	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1126	МЦ.04-mon-464	\N	Philips 273V7QJAB	1	302	86	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1127	МЦ.04.2-строка504	\N	USN Computers (mini)	1	303	86	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1128	МЦ.04-mon-465	\N	Nec MultiSync V221W	1	303	86	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1129	00-000785	\N	МИР 3	1	303	86	\N	2020-06-18	\N	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1130	МЦ.04-mon-466	\N	Philips 273V7QJAB	1	303	86	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1131	МЦ.04-mon-467	\N	Samsung S22C200	1	303	86	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1132	00-001060	\N	ICL  B102 тип1	1	304	86	\N	2022-08-30	\N	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1133	МЦ.04-mon-468	\N	LG Flatron E2251	1	304	86	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1134	МЦ.04-mon-469	\N	Samsung C32F391FWI	1	304	86	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1135	00-000895	\N	Моноблок DELL Inspiron 7700	1	305	86	\N	2021-03-07	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Моноблок
1136	Б/н	\N	Моноблок Dell	1	305	86	\N	2017-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Моноблок
1137	МЦ.04-строка509	\N	Ноутбук HP 15s-eq1318ur	1	305	86	\N	2022-03-23	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
1138	МЦ.04-mon-470	\N	15"	1	305	86	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1139	00-001048	\N	ICL  B102 тип1	1	306	5	\N	2022-08-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1140	МЦ.04-mon-471	\N	AOC 27P2Q	1	306	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1141	МЦ.04-ups-187	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	1	306	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1142	МЦ.04.2-строка513	\N	Zalman (Flextron)	1	306	5	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1143	МЦ.04-mon-472	\N	NEC  V221W	1	306	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1144	МЦ.04-ups-188	\N	APC Back-UPS 500	1	306	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1145	МЦ.04-строка514	\N	Ноутбук Acer Aspire A515-57-50EC	1	306	5	\N	2023-12-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
1146	МЦ.04-mon-473	\N	15,6"	1	306	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1147	МЦ.04 (001613)	\N	BENQ GW2760S	1	307	5	\N	\N	\N	\N	8GadgetPack	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1148	МЦ.04-mon-474	\N	BENQ GW2760S	1	307	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1149	МЦ.04.1-строка516	\N	ARBYTE	1	307	5	\N	2011-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1150	МЦ.04-mon-475	\N	Dell U2412Mc	1	307	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1151	МЦ.04 (001290)	\N	Dell U2412M	1	308	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1152	МЦ.04-mon-476	\N	Dell U2412M	1	308	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1153	БП-001304 (Информ. - 000153)	\N	МИР2725Z	1	309	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1154	МЦ.04-mon-477	\N	BENQ GW2765	1	309	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1155	МЦ.04-ups-189	\N	CROWN CMU-SP 1200 EURO USB (001517)	1	309	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1156	БП-001314 (Информ. - 000279)	\N	Klerk 6036	1	310	5	\N	\N	\N	\N	Azure Data Studio, foobar2000 v2.24.2 (x64), Total Commander, Snagit 2024, WinSCP 6.3.7, Konopka Signature VCL Controls 6.2.3, Lazarus 3.8,Devart UniDAC 10.3.1 Professional for RAD Studio 12,	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1157	МЦ.04-mon-478	\N	AOC34G2X	1	310	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1158	МЦ.04-ups-190	\N	CROWN CMU-SP 1200 EURO USB	1	310	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1159	МЦ.04 (01939/2)	\N	Samsung SyncMaster SA850 S24A850DW	1	311	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1160	МЦ.04-mon-479	\N	Samsung SyncMaster SA850 S24A850DW	1	311	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1161	МЦ.04-ups-191	\N	CROWN CMU-SP 1200 EURO USB	1	311	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1162	БП-001316 (Информ. - 000281)	\N	Klerk 6048	1	312	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1163	МЦ.04-mon-480	\N	AOC 34G2X	1	312	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1164	МЦ.04 (001608)	\N	Dell P2720DC	1	313	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1165	МЦ.04-mon-481	\N	Dell P2720DC	1	313	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1166	МЦ.04-ups-192	\N	CROWN CMU-SP 1200 EURO USB (001529)	1	313	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1167	МЦ.04 (001555)	\N	Dell P2720DC; Dell P2720DC	1	314	5	\N	\N	\N	\N	µTorrent, Glary Utilities 6.5, Revo Uninstaller 2.2.8, Revo Uninstaller 1.94	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1168	МЦ.04-mon-482	\N	Dell P2720DC	1	314	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1169	МЦ.04-mon-483	\N	Dell P2720DC	1	314	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1170	МЦ.04 (001606)	\N	Ноутбук HP Probook 450 G5	1	314	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
1171	БП-001307 (Информ. - 000205)	\N	Dell U3219W	1	315	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1172	МЦ.04-mon-484	\N	Dell U3219W	1	315	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1173	БП-001308 (Информ. - 000233)	\N	Ноутбук Dell XPS15	1	315	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
1174	БП-001315 (Информ. - 000280)	\N	Klerk 6038	1	316	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1175	МЦ.04-mon-485	\N	AOC 34G2X	1	316	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1176	БП-001317 (Информ. - 000282)	\N	Klerk 6050	1	317	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1177	МЦ.04-mon-486	\N	AOC 34G2X	1	317	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1178	БП-001309 (Информ. - 000234)	\N	Ноутбук Dell XPS15	1	317	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
1179	МЦ.04 (001316)	\N	BENQ GL2410-B	1	318	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1180	МЦ.04-mon-487	\N	BENQ GL2410-B	1	318	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1181	БП-001312 (Информ. - 000277)	\N	Klerk 6034	1	319	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1182	МЦ.04-mon-488	\N	AOC 34G2X	1	319	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1183	МЦ.04-mon-489	\N	Dell U2412Mc	1	319	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1184	МЦ.04 (001615)	\N	Ноутбук HP 17-BY1042ur	1	319	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
1185	МЦ.04-mon-490	\N	17"	1	319	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1186	МЦ.04 (001614)	\N	Dell P2720DC; Dell P2720DC	1	320	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1187	МЦ.04-mon-491	\N	Dell P2720DC	1	320	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1188	МЦ.04-mon-492	\N	Dell P2720DC	1	320	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1189	МЦ.04 (001597)	\N	BENQ GW2760G	1	321	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1190	МЦ.04-mon-493	\N	BENQ GW2760G	1	321	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1191	БП-001313 (Информ. - 000278)	\N	Klerk 6035	1	322	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1192	МЦ.04-mon-494	\N	AOC 34G2X	1	322	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1193	МЦ.04 (001607)	\N	Ноутбук HP Probook 450 G5	1	322	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
1194	МЦ.04 (001623)	\N	Dell U2412M	1	323	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1195	МЦ.04-mon-495	\N	Dell U2412M	1	323	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1196	МЦ.04 (001034)	\N	Dell P2720DC	1	324	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1197	МЦ.04-mon-496	\N	Dell P2720DC	1	324	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1198	МЦ.04.2-строка539	\N	Flextron	1	324	5	\N	2015-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1199	МЦ.04-mon-497	\N	Samsung SyncMaster P2270	1	324	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1202	МЦ.04-mon-498	\N	MB27V13FS51	1	13	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1203	МЦ.04-ups-193	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	13	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
16	БП-001152	\N	RDW Xpert GE	1	14	5	\N	2024-05-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-17 23:54:02.090047+03	Системный блок
1205	МЦ.04-mon-499	\N	BenQ BL2405	1	14	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1206	МЦ.04-ups-194	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	14	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
17	БП-001187	\N	RDW Xpert GE	1	15	5	\N	2024-05-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-17 23:54:02.090047+03	Системный блок
1208	МЦ.04-mon-500	\N	BenQ BL2405	1	15	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1209	МЦ.04-ups-195	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	15	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
18	БП-001197	\N	RDW Xpert GE	1	16	5	\N	2024-05-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-17 23:54:02.090047+03	Системный блок
1211	МЦ.04-mon-501	\N	MB27V13FS51	1	16	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1212	МЦ.04-ups-196	\N	APC Back-UPS BC650-RSX761	1	16	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
20	БП-001226	\N	RDW Xpert GE	1	17	5	\N	2024-05-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-17 23:54:02.090047+03	Системный блок
1215	МЦ.04-mon-502	\N	BENQ BL2405	1	17	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1216	МЦ.04-ups-197	\N	APC Back-UPS 650(белый)	1	17	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
21	БП-001188	\N	RDW Xpert GE	1	18	5	\N	2024-05-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-17 23:54:02.090047+03	Системный блок
1218	МЦ.04-mon-503	\N	BENQ GL2460	1	18	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1219	МЦ.04-ups-198	\N	APC Back-UPS 500 Белый	1	18	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1220	00-000269	\N	Молверс1 ; (ООО "МОЛВЕРС")	1	185	87	\N	2018-04-26	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1221	МЦ.04-mon-504	\N	ASUS 23.8" BE249QLB	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1222	МЦ.04-ups-199	\N	Powercom SPIDER SPD-850N	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1223	00-000270	\N	Молверс1 ; (ООО "МОЛВЕРС")	1	185	87	\N	2018-04-26	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1224	МЦ.04-mon-505	\N	ASUS 23.8" BE249QLB	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1225	МЦ.04-ups-200	\N	Powercom SPIDER SPD-850N	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1226	00-000271	\N	Молверс1 ; (ООО "МОЛВЕРС")	1	185	87	\N	2018-04-26	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1227	МЦ.04-mon-506	\N	ASUS 23.8" BE249QLB	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1228	МЦ.04-ups-201	\N	Powercom SPIDER SPD-850N	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1229	00-000272	\N	Молверс1 ; (ООО "МОЛВЕРС")	1	185	87	\N	2018-04-26	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1230	МЦ.04-mon-507	\N	ASUS 23.8" BE249QLB	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1231	МЦ.04-ups-202	\N	Powercom SPIDER SPD-850N	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1232	00-000273	\N	Молверс1 ; (ООО "МОЛВЕРС")	1	185	87	\N	2018-04-26	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1233	МЦ.04-mon-508	\N	ASUS 23.8" BE249QLB	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1234	МЦ.04-ups-203	\N	Powercom SPIDER SPD-850N	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1235	00-000274	\N	Молверс1 ; (ООО "МОЛВЕРС")	1	185	87	\N	2018-04-26	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1236	МЦ.04-mon-509	\N	ASUS 23.8" BE249QLB	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1237	МЦ.04-ups-204	\N	Powercom SPIDER SPD-850N	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1238	00-000275	\N	Молверс1 ; (ООО "МОЛВЕРС")	1	185	87	\N	2018-04-26	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1239	МЦ.04-mon-510	\N	ASUS 23.8" BE249QLB	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1240	МЦ.04-ups-205	\N	Powercom SPIDER SPD-850N	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1241	00-000276	\N	Молверс1 ; (ООО "МОЛВЕРС")	1	185	87	\N	2018-04-26	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1242	МЦ.04-mon-511	\N	ASUS 23.8" BE249QLB	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1243	МЦ.04-ups-206	\N	Powercom SPIDER SPD-850N	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1244	00-000277	\N	Молверс1 ; (ООО "МОЛВЕРС")	1	185	87	\N	2018-04-26	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1245	МЦ.04-mon-512	\N	ASUS 23.8" BE249QLB	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1246	МЦ.04-ups-207	\N	Powercom SPIDER SPD-850N	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1247	00-000278	\N	Молверс1 ; (ООО "МОЛВЕРС")	1	185	87	\N	2018-04-26	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1248	МЦ.04-mon-513	\N	ASUS 23.8" BE249QLB	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1249	МЦ.04-ups-208	\N	Powercom SPIDER SPD-850N	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1250	00-000279	\N	Молверс1 ; (ООО "МОЛВЕРС")	1	185	87	\N	2018-04-26	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1251	МЦ.04-mon-514	\N	ASUS 23.8" BE249QLB	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1252	МЦ.04-ups-209	\N	Powercom SPIDER SPD-850N	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1253	00-000280	\N	Молверс1 ; (ООО "МОЛВЕРС")	1	185	87	\N	2018-04-26	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1254	МЦ.04-mon-515	\N	ASUS 23.8" BE249QLB	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1255	МЦ.04-ups-210	\N	Powercom SPIDER SPD-850N	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1256	00-000281	\N	Молверс1 ; (ООО "МОЛВЕРС")	1	185	87	\N	2018-04-26	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1257	МЦ.04-mon-516	\N	ASUS 23.8" BE249QLB	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1258	МЦ.04-ups-211	\N	Powercom SPIDER SPD-850N	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1259	00-000282	\N	Молверс1 ; (ООО "МОЛВЕРС")	1	185	87	\N	2018-04-26	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1260	МЦ.04-mon-517	\N	ASUS 23.8" BE249QLB	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1261	МЦ.04-ups-212	\N	Powercom SPIDER SPD-850N	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1262	00-000283	\N	Молверс1 ; (ООО "МОЛВЕРС")	1	185	87	\N	2018-04-26	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1263	МЦ.04-mon-518	\N	ASUS 23.8" BE249QLB	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1264	МЦ.04-ups-213	\N	Powercom SPIDER SPD-850N	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1265	00-000284	\N	Молверс1 ; (ООО "МОЛВЕРС")	1	185	87	\N	2018-04-26	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1266	МЦ.04-mon-519	\N	ASUS 23.8" BE249QLB	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1267	МЦ.04-ups-214	\N	Powercom SPIDER SPD-850N	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1268	00-000285	\N	Молверс1 ; (ООО "МОЛВЕРС")	1	185	87	\N	2018-04-26	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1269	МЦ.04-mon-520	\N	ASUS 23.8" BE249QLB	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1270	МЦ.04-ups-215	\N	Powercom SPIDER SPD-850N	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1271	00-000286	\N	Молверс1 ; (ООО "МОЛВЕРС")	1	185	87	\N	2018-04-26	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1272	МЦ.04-mon-521	\N	ASUS 23.8" BE249QLB	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1273	МЦ.04-ups-216	\N	Powercom SPIDER SPD-850N	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1274	00-000287	\N	Молверс1 ; (ООО "МОЛВЕРС")	1	185	87	\N	2018-04-26	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1275	МЦ.04-mon-522	\N	ASUS 23.8" BE249QLB	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1276	МЦ.04-ups-217	\N	Powercom SPIDER SPD-850N	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1277	00-000288	\N	Молверс1 ; (ООО "МОЛВЕРС")	1	185	87	\N	2018-04-26	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1278	МЦ.04-mon-523	\N	ASUS 23.8" BE249QLB	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1279	МЦ.04-ups-218	\N	Powercom SPIDER SPD-850N	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1280	00-000289	\N	Молверс1 ; (ООО "МОЛВЕРС")	1	185	87	\N	2018-04-26	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1281	МЦ.04-mon-524	\N	ASUS 23.8" BE249QLB	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1282	МЦ.04-ups-219	\N	Powercom SPIDER SPD-850N	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1283	00-000290	\N	Молверс1 ; (ООО "МОЛВЕРС")	1	185	87	\N	2018-04-26	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1284	МЦ.04-mon-525	\N	ASUS 23.8" BE249QLB	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1285	МЦ.04-ups-220	\N	Powercom SPIDER SPD-850N	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1286	00-000291	\N	Молверс1 ; (ООО "МОЛВЕРС")	1	185	87	\N	2018-04-26	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1287	МЦ.04-mon-526	\N	ASUS 23.8" BE249QLB	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1288	МЦ.04-ups-221	\N	Powercom SPIDER SPD-850N	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1289	00-000292	\N	Молверс1 ; (ООО "МОЛВЕРС")	1	185	87	\N	2018-04-26	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1290	МЦ.04-mon-527	\N	ASUS 23.8" BE249QLB	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1291	МЦ.04-ups-222	\N	Powercom SPIDER SPD-850N	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1292	00-000293	\N	Молверс1 ; (ООО "МОЛВЕРС")	1	185	87	\N	2018-04-26	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1293	МЦ.04-mon-528	\N	ASUS 23.8" BE249QLB	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1294	МЦ.04-ups-223	\N	Powercom SPIDER SPD-850N	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1295	00-000264	\N	Интерактивная панель;  Prestigio 98"	1	185	87	\N	2018-04-26	\N	\N	Мобильный стенд для панели	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1296	МЦ.04-mon-529	\N	Интерактивная панель	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1297	МЦ.04-mon-530	\N	Prestigio 98"	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1298	МЦ.04.2-строка575	\N	Документ камера Classic Solution DC6e	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1299	МЦ.04.2-строка576	\N	Патч-панель Hyperline PP3-19-48-8P8C-C5E-110D	1	185	87	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1300	МЦ.04.2-строка577	\N	Коммутатор HPE 1820-48G J9981A	1	185	87	\N	\N	\N	\N	APC Back-UPS BC650-RSX761	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1301	00-000297	\N	Supermicro; Молверс3 ;  (ООО "МОЛВЕРС")	1	185	88	\N	2018-04-26	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1302	МЦ.04-ups-224	\N	UPS POWERMAN Online 1000	1	185	88	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1303	00-000439	\N	ARBYTE	1	325	89	\N	2008-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1304	МЦ.04-mon-531	\N	Samsung SyncMaster 710N 17"	1	325	89	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1305	МЦ.04.2-строка581	\N	ELL9	1	325	89	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1306	МЦ.04-mon-532	\N	Samsung SyncMaster 710N 17"	1	325	89	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1307	МЦ.04.2-строка582	\N	Треугольник	1	325	89	\N	2008-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1308	МЦ.04-mon-533	\N	Samsung SyncMaster 710N 17"	1	325	89	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1309	МЦ.04.2-строка583	\N	Треугольник	1	325	89	\N	2008-01-01	\N	\N	Списать 2023-10-17	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1310	МЦ.04-mon-534	\N	Samsung SyncMaster 720N 17"	1	325	89	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1311	МЦ.04.2-строка584	\N	Треугольник	1	325	89	\N	2008-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1312	МЦ.04-mon-535	\N	Samsung SyncMaster 710N 17"	1	325	89	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1313	00-000439-строка585	\N	ARBYTE	1	325	89	\N	2008-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1314	МЦ.04-mon-536	\N	Samsung SyncMaster 710N 17"	1	325	89	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1315	МЦ.04.2-строка586	\N	CoolerMaster	1	325	89	\N	2008-01-01	\N	\N	Списать 2023-10-17	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1316	МЦ.04-mon-537	\N	Acer AL1714 (17")	1	325	89	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1317	МЦ.04.2-строка587	\N	Треугольник	1	325	89	\N	2008-01-01	\N	\N	Списать 2023-10-17	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1318	МЦ.04-mon-538	\N	Acer AL1714 (17")	1	325	89	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1319	МЦ.04.2-строка588	\N	Flextron	1	325	89	\N	2008-01-01	\N	\N	Списать 2023-10-17	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1320	МЦ.04-mon-539	\N	Acer AL1714 (17")	1	325	89	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1321	МЦ.04.2-строка589	\N	Flextron	1	325	89	\N	2008-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1322	МЦ.04-mon-540	\N	Samsung SyncMaster 710N 17"	1	325	89	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1323	МЦ.04.2-строка590	\N	Flextron	1	325	89	\N	2008-01-01	\N	\N	Списать 2023-10-17	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1324	МЦ.04-mon-541	\N	Philips 170S	1	325	89	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1326	МЦ.04-mon-542	\N	Philips 23.8" 241B8QJEB	1	19	6	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1327	МЦ.04-mon-543	\N	Philips 23.8" 241B8QJEB	1	19	6	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
23	00-000894	\N	Ноутбук Lenovo ThinkPad E15-IML 20RD001CRT	1	19	6	\N	2021-03-07	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-17 23:54:02.090047+03	Ноутбук
1329	МЦ.04-строка595	\N	Моноблок HP EliteOne 800	1	325	90	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Моноблок
1330	МЦ.04-строка596	\N	Моноблок HP EliteOne 800	1	325	90	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Моноблок
1331	МЦ.04-строка598	\N	Некстген4	1	325	91	\N	2022-03-25	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1332	МЦ.04-mon-544	\N	AOC 24P2Q	1	325	91	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1333	МЦ.04-mon-545	\N	Nec MultiSync AS221WM	1	325	91	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1334	МЦ.04.2-строка600	\N	INWIN	1	326	92	\N	2008-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1335	МЦ.04-mon-546	\N	LG Flatron L192WS	1	326	92	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1336	МЦ.04.2-строка601	\N	USN Computers (mini)	1	326	92	\N	2013-01-01	\N	\N	Стоит VipNet и Secret Net	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1337	МЦ.04-mon-547	\N	Samsung S22C200	1	326	92	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1338	99036-строка603	\N	Flextron	1	327	93	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1339	МЦ.04-mon-548	\N	Samsung SyncMaster E1920	1	327	93	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1340	МЦ.04.2-строка604	\N	Треугольник	1	327	93	\N	2008-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1341	МЦ.04-mon-549	\N	Samsung SyncMaster E1920	1	327	93	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1342	МЦ.04.2-строка605	\N	Треугольник	1	327	93	\N	2008-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1343	МЦ.04-mon-550	\N	Samsung SyncMaster E1920	1	327	93	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1344	МЦ.04.2-строка606	\N	Треугольник	1	327	93	\N	2008-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1345	МЦ.04-mon-551	\N	Samsung SyncMaster E1920	1	327	93	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1346	99036-строка607	\N	Flextron	1	327	93	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1347	МЦ.04-mon-552	\N	Samsung SyncMaster E1920	1	327	93	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1348	99036-строка608	\N	Flextron	1	327	93	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1349	МЦ.04-mon-553	\N	Samsung SyncMaster E1920	1	327	93	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1350	99036-строка609	\N	Flextron	1	327	93	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1351	МЦ.04-mon-554	\N	Samsung SyncMaster E1920	1	327	93	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1352	99036-строка610	\N	Flextron	1	327	93	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1353	МЦ.04-mon-555	\N	Samsung SyncMaster E1920	1	327	93	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1354	МЦ.04.2-строка612	\N	Flextron	1	327	94	\N	2012-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1355	МЦ.04-mon-556	\N	Nec MultiSync AS221WM	1	327	94	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1356	МЦ.04-строка613	\N	Некстген4	1	328	95	\N	2022-03-25	\N	\N	Новый ключ KES\nVipNet	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1357	МЦ.04-mon-557	\N	Samsung SyncMaster 943	1	328	95	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1358	МЦ.04.2-строка614	\N	Flextron	1	328	95	\N	2012-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1359	МЦ.04-mon-558	\N	Philips 273V7QJAB	1	328	95	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1360	МЦ.04-ROW-615	\N	INWIN	1	329	95	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1361	МЦ.04-mon-559	\N	Philips 234E	1	329	95	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1362	МЦ.04-ups-225	\N	APC Back-UPS 500 (белый)	1	329	95	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1363	МЦ.04-строка617	\N	Universal D1 (ООО «Десктоп»)	1	330	96	\N	2021-02-15	\N	\N	Для VipNet	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1364	МЦ.04-mon-560	\N	Philips 243V7QJABF	1	330	96	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1365	МЦ.04-mon-561	\N	Philips 243V7QJABF	1	330	96	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1366	МЦ.04-ups-226	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	1	330	96	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1367	МЦ.04-строка618	\N	Universal D1 (ООО «Десктоп»)	1	143	96	\N	2021-02-15	\N	\N	Для VipNet	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1368	МЦ.04-mon-562	\N	Philips 273V7QJAB	1	143	96	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1369	МЦ.04-ups-227	\N	APC Back-UPS 650	1	143	96	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1370	00-000789	\N	МИР 3	1	331	96	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1371	МЦ.04-mon-563	\N	Philips 243V7QJABF	1	331	96	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1372	МЦ.04-mon-564	\N	Philips 243V7QJABF	1	331	96	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1373	МЦ.04-ups-228	\N	APC Back-UPS 650	1	331	96	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1374	00-000784	\N	МИР 3	1	143	96	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1375	МЦ.04-mon-565	\N	Philips 243V7QJABF	1	143	96	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1376	МЦ.04-mon-566	\N	Philips 243V7QJABF	1	143	96	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1377	99036-строка621	\N	Flextron	1	332	96	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1378	МЦ.04-mon-567	\N	LG Flatron L192WS	1	332	96	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1379	МЦ.04-ups-229	\N	APC Back-UPS 650	1	332	96	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1380	МЦ.04-строка622	\N	Universal D1 (ООО «Десктоп»)	1	333	96	\N	2021-02-15	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1381	МЦ.04-mon-568	\N	Philips 243V7QJABF	1	333	96	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1382	МЦ.04-mon-569	\N	Philips 243V7QJABF	1	333	96	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1383	МЦ.04-ups-230	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	333	96	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1384	00-001050	\N	ICL  B102 тип1	1	334	96	\N	2022-08-30	\N	\N	Powercom RPT-1000A EURO	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1385	МЦ.04-mon-570	\N	AOC 27P2Q	1	334	96	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1386	00-000459	\N	ARBYTE	1	335	96	\N	2011-09-26	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1387	МЦ.04-mon-571	\N	Benq GL2450	1	335	96	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1388	МЦ.04-mon-572	\N	Benq GL2450	1	335	96	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1389	МЦ.04-ups-231	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	1	335	96	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1390	00-000168	\N	Aerocool	1	336	96	\N	2014-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1391	МЦ.04-mon-573	\N	AOC 24P2Q	1	336	96	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1392	МЦ.04-ups-232	\N	Powercom RPT-1000A EURO	1	336	96	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1393	00-000999	\N	ICL  B102 тип1	1	337	97	\N	2022-08-30	\N	\N	APC Back-UPS 650 ВА (BX650CI-RS)	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1394	МЦ.04-mon-574	\N	Dell U2415	1	337	97	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1395	МЦ.04-mon-575	\N	Dell U2415	1	337	97	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1396	НИИСУ-строка628	\N	ARBYTE	1	338	97	\N	2012-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1397	МЦ.04-mon-576	\N	LG 22MP55	1	338	97	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1398	00-000360	\N	HP Z240	1	339	97	\N	2016-12-23	\N	\N	APC Back-UPS 650 ВА (BX650CI-RS)	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1399	МЦ.04-mon-577	\N	Dell U2415	1	339	97	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1400	00-001001	\N	ICL  B102 тип1	1	340	97	\N	2022-08-30	\N	\N	APC Back-UPS 650 ВА (BX650CI-RS)	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1401	МЦ.04-mon-578	\N	Dell U2415	1	340	97	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1402	00-000949	\N	Некстген1	1	341	97	\N	2022-03-10	\N	\N	Ключ Win10:  VVGMD-D4GTM-G8P9F-43MKQ-49CKC	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1403	МЦ.04-mon-579	\N	Philips 273V7QJAB	1	341	97	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1404	МЦ.04-ups-233	\N	APC Back-UPS CS 650 ВА	1	341	97	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1405	00-000954	\N	Некстген2	1	342	97	\N	2022-03-16	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1406	МЦ.04-mon-580	\N	Dell E2314H	1	342	97	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1407	МЦ.04-mon-581	\N	Dell E2314H	1	342	97	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1408	БП-001199	\N	RDW Xpert GE	1	343	97	\N	2024-05-21	\N	\N	Powercom RPT-1000A EURO	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1409	МЦ.04-mon-582	\N	AOC 27P2Q	1	343	97	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1410	МЦ.04-mon-583	\N	MB27V13FS51	1	343	97	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1411	00-001035	\N	ICL  B102 тип1	1	344	97	\N	2022-08-30	\N	\N	Powercom RPT-1000A EURO	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1412	МЦ.04-mon-584	\N	MB27V13FS51	1	344	97	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1413	МЦ.04-строка635	\N	Ноутбук Asus R522MA-BQ862W	1	344	97	\N	2022-03-05	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
1414	МЦ.04-mon-585	\N	15,6"	1	344	97	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1415	НИИСУ-строка637	\N	ANTEC	1	345	98	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1416	МЦ.04-mon-586	\N	Dell E2313HF	1	345	98	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1417	НИИСУ-строка638	\N	INWIN	1	346	98	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1418	МЦ.04-mon-587	\N	NEC MultiSyncE222W	1	346	98	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1419	МЦ.04-ups-234	\N	APC  500 (белый)	1	346	98	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1420	МЦ.04.2-строка639	\N	USN Computers (mini)	1	188	98	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1421	МЦ.04-mon-588	\N	NEC Multisync E222W	1	188	98	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1422	99092	\N	Flextron	1	160	99	\N	2008-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1423	МЦ.04-mon-589	\N	LG Flatron L192WS	1	160	99	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1424	00-000777	\N	МИР2	1	347	100	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1425	МЦ.04-mon-590	\N	Philips 243V7QJABF	1	347	100	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1426	МЦ.04-mon-591	\N	Philips 243V7QJABF	1	347	100	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1427	МЦ.04-ups-235	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	1	347	100	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1428	МЦ.04.2-строка644	\N	USN Computers (mini)	1	348	100	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1429	МЦ.04-mon-592	\N	Samsung S22C200	1	348	100	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1430	МЦ.04.2-строка645	\N	USN Computers (mini)	1	349	100	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1431	МЦ.04-mon-593	\N	Philips 243V7QJABF	1	349	100	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1432	МЦ.04-ups-236	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	349	100	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1433	МЦ.04.2-строка646	\N	USN Computers (mini)	1	350	100	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1434	МЦ.04-mon-594	\N	Philips 243V7QJABF	1	350	100	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1435	МЦ.04-mon-595	\N	Philips 243V7QJABF	1	350	100	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1436	МЦ.04-ups-237	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	350	100	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1437	00-000776	\N	МИР2	1	351	100	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1438	МЦ.04-mon-596	\N	AOC 27P2Q	1	351	100	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1439	МЦ.04-ups-238	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	351	100	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1440	МЦ.04.2-строка648	\N	Flextron	1	348	100	\N	2012-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1441	МЦ.04-mon-597	\N	AOC 27P2Q	1	348	100	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1442	МЦ.04-mon-598	\N	Philips 243V7QJABF	1	348	100	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1443	МЦ.04-ups-239	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	348	100	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1444	МЦ.04-строка650	\N	Gigant G-Station	1	352	101	\N	2018-09-19	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1445	МЦ.04-mon-599	\N	Philips 243V7QDSB 23,8"	1	352	101	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1446	МЦ.04-ups-240	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	352	101	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1447	МЦ.04.2-строка651	\N	Flextron (GSG-Group)	1	353	101	\N	2014-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1448	МЦ.04-mon-600	\N	Philips 243V7QJABF	1	353	101	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1449	МЦ.04-ups-241	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	353	101	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1450	00-000352	\N	Ноутбук (Dell Inspiron 5770 (5770-9676)	1	353	101	\N	2019-04-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
1451	00-000553	\N	HP 460-p206ur	1	354	102	\N	2019-09-19	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1452	МЦ.04-mon-601	\N	Samsung S22C200	1	354	102	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1453	МЦ.04.2-строка655	\N	USN Computers (mini)	1	355	102	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1454	МЦ.04-mon-602	\N	Samsung S22C200	1	355	102	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1455	МЦ.04-строка656	\N	INWIN	1	356	102	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1456	МЦ.04-mon-603	\N	MB27V13FS51	1	356	102	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1457	МЦ.04-ups-242	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	1	356	102	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1458	00-001064	\N	ICL  B102 тип1	1	357	103	\N	2022-08-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1459	МЦ.04-mon-604	\N	MB27V13FS51	1	357	103	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1460	МЦ.04-ups-243	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	357	103	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1461	МЦ.04.2-строка659	\N	Flextron (Integro)	1	358	103	\N	2012-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1462	МЦ.04-mon-605	\N	Samsung SyncMaster B2430	1	358	103	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1463	00-000448	\N	ARBYTE	1	359	103	\N	2012-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1464	МЦ.04-mon-606	\N	Benq G2220HD	1	359	103	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1465	МЦ.04.2-строка662	\N	USN Computers (mini)	1	360	104	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1466	МЦ.04-mon-607	\N	Samsung S22C200	1	360	104	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1467	МЦ.04.2-строка663	\N	USN Computers (mini)	1	361	104	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1468	МЦ.04-mon-608	\N	Samsung SyncMaster P2050	1	361	104	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1469	МЦ.04.2-строка664	\N	USN Computers (mini)	1	362	104	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1470	МЦ.04-mon-609	\N	Samsung S22C200	1	362	104	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1471	00-000552	\N	HP 460-p206ur	1	363	105	\N	2019-09-19	\N	\N	Внешний привод DVD-RW Asus SDRW-08D2S-U	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1472	МЦ.04-mon-610	\N	MB27V13FS51	1	363	105	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1473	МЦ.04-mon-611	\N	Samsung Syncmaster SA450	1	363	105	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1474	МЦ.04-ups-244	\N	APC Back-UPS 500	1	363	105	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1475	МЦ.04.2-строка667	\N	USN Computers (mini)	1	364	105	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1476	МЦ.04-mon-612	\N	AOC 27P2Q	1	364	105	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1477	МЦ.04-mon-613	\N	AOC 27P2Q	1	364	105	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1478	МЦ.04.2-строка668	\N	USN Computers (mini)	1	364	105	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1479	МЦ.04-mon-614	\N	AOC 27P2Q	1	364	105	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1480	МЦ.04-mon-615	\N	Samsung S22C200	1	364	105	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1481	00-000887	\N	Ноутбук Lenovo Legion 5 17IMH05	1	365	106	\N	2021-03-07	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
1482	МЦ.04-mon-616	\N	17"	1	365	106	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1483	МЦ.04.2-строка671	\N	USN Computers (mini)	1	365	106	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1484	МЦ.04-mon-617	\N	Samsung S22C200	1	365	106	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1485	00-000220	\N	МИР Z2330 (ООО "Мира")	1	365	106	\N	2017-12-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1486	МЦ.04-mon-618	\N	Samsung 27" C27F390FHI	1	365	106	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1487	МЦ.04.2-строка673	\N	Flextron	1	366	106	\N	2014-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1488	МЦ.04-mon-619	\N	Samsung SyncMaster P2270	1	366	106	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1489	МЦ.04-mon-620	\N	Samsung S22C200	1	366	106	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1490	00-000962	\N	Некстген3	1	367	107	\N	2022-03-17	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1491	МЦ.04-mon-621	\N	Philips 273V7QJAB	1	367	107	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1492	МЦ.04-mon-622	\N	Nec MultiSync E222W	1	367	107	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1493	МЦ.04-ups-245	\N	APC Back-UPS 500(белый)	1	367	107	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1494	МЦ.04-строка676	\N	Universal D1 (ООО «Десктоп»)	1	368	107	\N	2021-02-15	\N	\N	APC Back-UPS 650 ВА (BX650CI-RS)	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1495	МЦ.04-mon-623	\N	Philips 273V7QJAB	1	368	107	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1496	МЦ.04-mon-624	\N	Philips 273V7QJAB	1	368	107	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1497	00-000668	\N	AVK 2 (ООО «Вест-Тайп»)	1	369	107	\N	2020-02-05	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1498	МЦ.04-mon-625	\N	Samsung S27F358FWI	1	369	107	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1499	МЦ.04-mon-626	\N	Samsung S27F358FWI	1	369	107	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1500	БП-001156	\N	RDW Xpert GE	1	144	107	\N	2024-05-14	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1501	МЦ.04-mon-627	\N	MB27V13FS51	1	144	107	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1502	МЦ.04-ups-246	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	1	144	107	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1503	МЦ.04-строка680	\N	USN Computers (mini)	1	370	108	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1504	МЦ.04-mon-628	\N	Samsung SyncMaster 931с	1	370	108	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1505	МЦ.04-mon-629	\N	LG Flatron L192ws	1	370	108	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1506	МЦ.04-ups-247	\N	APC Back-UPSBC650I RSX	1	370	108	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1507	00-000238	\N	МИР Z2330 (ООО "Мира")	1	370	108	\N	2017-12-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1508	МЦ.04-mon-630	\N	Samsung SyncMaster E1920	1	370	108	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1509	МОЛ Ильин Л.К.	\N	DEPO	1	370	108	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1510	МЦ.04-mon-631	\N	Dell P2219H	1	370	108	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1511	МЦ.04-mon-632	\N	LG Flatron Slim L1980u	1	370	108	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1512	МЦ.04-ups-248	\N	Powercom RPT-1000A EURO	1	370	108	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1513	00-000215	\N	ООО "ГКС" (ГИГАНТ)	1	371	108	\N	2017-10-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1514	МЦ.04-mon-633	\N	Philips 234E5QSB 23"	1	371	108	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1515	МЦ.04-mon-634	\N	Philips 234E5QSB 23"	1	371	108	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1516	МЦ.04-ups-249	\N	Powercom RPT-1000A EURO	1	371	108	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1517	99036-строка684	\N	Ноутбук SONY VAIO VGN-NR21MR	1	371	108	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
1518	00-000359	\N	HP Z240	1	371	108	\N	2016-12-23	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1519	МЦ.04-mon-635	\N	Nec MultiSync AS221WM	1	371	108	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1520	00-000216	\N	ООО "ГКС" (ГИГАНТ)	1	372	108	\N	2017-10-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1521	МЦ.04-mon-636	\N	Samsung S22C200	1	372	108	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1522	МЦ.04-mon-637	\N	Samsung S22C200	1	372	108	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1523	МЦ.04-ups-250	\N	APC Back-UPS BC650-RSX761	1	372	108	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1524	00-000551	\N	HP 460-p206ur	1	373	108	\N	2019-09-19	\N	\N	Внешний привод DVD-RW Asus SDRW-08D2S-U	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1525	МЦ.04-mon-638	\N	Samsung 27" C27F390FHI (Монитор Руфата)	1	373	108	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1526	МЦ.04-mon-639	\N	Dell P2219H	1	373	108	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1527	99036-строка689	\N	Flextron	1	374	109	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1528	МЦ.04-mon-640	\N	Samsung SyncMaster E2220	1	374	109	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1529	МЦ.04-строка690	\N	Некстген4	1	375	109	\N	2022-03-25	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1530	МЦ.04-mon-641	\N	AOC 24P2Q	1	375	109	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1531	МЦ.04 (001618)	\N	Dell U2412M; Dell P2720	1	376	110	\N	\N	\N	\N	Офисная система публикации Primera BravoSE Disk Pudlisher МЦ.04 (001596)	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1532	МЦ.04-mon-642	\N	Dell U2412M	1	376	110	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1533	МЦ.04-mon-643	\N	Dell P2720	1	376	110	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1534	МЦ.04 (001628)	\N	Ноутбук Dell Vostro I5         ; S/N 2V09YH3	1	376	110	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
1535	БП-001305 (Информ. - 000189)	\N	Dell U2412	1	376	110	\N	\N	\N	\N	Пароль admuser - 12345678	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1536	МЦ.04-mon-644	\N	Dell U2412	1	376	110	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1537	МЦ.04 (000032)	\N	BENQ GL2450	1	376	110	\N	\N	\N	\N	Пароль admuser - 12345678	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1538	МЦ.04-mon-645	\N	BENQ GL2450	1	376	110	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1539	МЦ.04 (001016)	\N	BENQ GL2760	1	376	110	\N	\N	\N	\N	Пароль admuser - 12345678	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1540	МЦ.04-mon-646	\N	BENQ GL2760	1	376	110	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1541	БП-001310 (информ. - 000237)	\N	Ноутбук Dell XPS17;  S/N FYN1563	1	376	110	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
1542	МЦ.04 (001610)	\N	BENQ GW2765	1	377	110	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1543	МЦ.04-mon-647	\N	BENQ GW2765	1	377	110	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1544	МЦ.04 (001609)	\N	Dell P2720DC	1	378	110	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1545	МЦ.04-mon-648	\N	Dell P2720DC	1	378	110	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1546	МЦ.04 (001616)	\N	Dell P2720DC	1	379	110	\N	\N	\N	\N	MPC-HC 1.7.13 (64-bit)	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1547	МЦ.04-mon-649	\N	Dell P2720DC	1	379	110	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1548	МЦ.04 (001161)	\N	Dell P2720DC; Dell U2412	1	380	110	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1549	МЦ.04-mon-650	\N	Dell P2720DC	1	380	110	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1550	МЦ.04-mon-651	\N	Dell U2412	1	380	110	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1551	МЦ.04 (001176)	\N	Dell P2720DC	1	381	110	\N	\N	\N	\N	Skype Click to Call,	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1552	МЦ.04-mon-652	\N	Dell P2720DC	1	381	110	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1553	МЦ.04 (001286)	\N	BENQ GW2760S	1	382	110	\N	\N	\N	\N	Голосовой помощник Алиса	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1554	МЦ.04-mon-653	\N	BENQ GW2760S	1	382	110	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1555	МЦ.04 (001315)	\N	Dell P2720DC	1	383	110	\N	\N	\N	\N	Desktop Clock-7 Plus 1.12	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1556	МЦ.04-mon-654	\N	Dell P2720DC	1	383	110	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1557	МЦ.04 (001621)	\N	BENQ GW2760	1	376	110	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1558	МЦ.04-mon-655	\N	BENQ GW2760	1	376	110	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1559	БП-001311 (Информ. - 000239)	\N	Ноутбук DELL XPS 17; S/N IZN1563	1	376	110	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
1560	МЦ.04 (001619)	\N	Dell U2412Mc	1	376	110	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1561	МЦ.04-mon-656	\N	Dell U2412Mc	1	376	110	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1562	МЦ.04.2-строка710	\N	USN Computers (mini)	1	384	111	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1563	МЦ.04-mon-657	\N	Samsung S22C200	1	384	111	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1564	МЦ.04-ups-251	\N	Powercom RPT-1000A EURO	1	384	111	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1565	МЦ.04.2-строка711	\N	Flextron	1	385	111	\N	2012-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1566	МЦ.04-mon-658	\N	Nec MultiSync E231W	1	385	111	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1567	МЦ.04-ups-252	\N	Powercom RPT-1000A EURO	1	385	111	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1568	00-000252	\N	МИР Z23271 (ООО "Мира")	1	385	111	\N	2017-12-22	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1569	МЦ.04-mon-659	\N	Samsung S22C200	1	385	111	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1570	МЦ.04-ups-253	\N	Powercom RPT-1000A EURO	1	385	111	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1571	МЦ.04-строка713	\N	Ноутбук HP 15s-eq1318ur	1	385	111	\N	2022-03-23	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
1572	МЦ.04-mon-660	\N	15"	1	385	111	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1573	МЦ.04.2-строка714	\N	USN Computers (mini)	1	386	111	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1574	МЦ.04-mon-661	\N	Samsung S22C200	1	386	111	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1575	МЦ.04-ups-254	\N	Powercom RPT-1000A EURO	1	386	111	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1576	МЦ.04-строка715	\N	INWIN	1	386	111	\N	2014-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1577	МЦ.04-mon-662	\N	NEC MultiSync EA223WM	1	386	111	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1578	00-000355	\N	Моноблок Lenovo ThinkCentre Edge 72z	1	387	111	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Моноблок
1579	МЦ.04-ups-255	\N	Powercom RPT-1000A EURO	1	387	111	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1580	00-000353	\N	HP Elite Desk 800 G2	1	388	112	\N	2016-12-23	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1581	МЦ.04-mon-663	\N	Nec EA221Wme	1	388	112	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1582	МЦ.04-ups-256	\N	APC Back-UPS 500(белый)	1	388	112	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1583	МЦ.04.2-строка719	\N	Flextron	1	389	113	\N	2012-01-01	\N	\N	Уничтожитель бумаг Fellowers Powershred P-35C	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1584	МЦ.04-mon-664	\N	AOC 24P2Q	1	389	113	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1585	МЦ.04-mon-665	\N	Nеc MultiSinc E222W	1	389	113	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1586	НИИСУ-строка720	\N	InWin	1	390	113	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1587	МЦ.04-mon-666	\N	AOC 27P2Q	1	390	113	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1588	00-000332	\N	SuperMicro	1	391	113	\N	2014-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1589	МЦ.04-mon-667	\N	AOC 27P2Q	1	391	113	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1590	МЦ.04-mon-668	\N	Dell U2415	1	391	113	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1591	МЦ.04-ups-257	\N	Powercom RPT-1000A EURO	1	391	113	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1592	00-000340	\N	HP Z240	1	392	113	\N	2016-12-23	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1593	МЦ.04-mon-669	\N	AOC 27P2Q	1	392	113	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1594	МЦ.04-ups-258	\N	APC UPS 500	1	392	113	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1595	МЦ.04.2-строка723	\N	Flextron	1	391	113	\N	2012-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1596	МЦ.04-mon-670	\N	Benq G2220HD	1	391	113	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1597	00-000483	\N	CAD-Station	1	393	113	\N	2011-06-10	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1598	МЦ.04-mon-671	\N	Nec MultiSync E231W	1	393	113	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1599	МЦ.04-mon-672	\N	Nec MultiSync EA221WM	1	393	113	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1600	МЦ.04.2-строка726	\N	INWIN	1	394	114	\N	2014-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1601	МЦ.04-mon-673	\N	Samsung 24"S24D300H	1	394	114	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1602	МЦ.04-mon-674	\N	Samsung 24"S24D300H	1	394	114	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1603	00-000890	\N	Ноутбук Lenovo Legion 5 17IMH05	1	394	114	\N	2021-03-07	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
1605	МЦ.04.2-строка728	\N	INWIN	1	395	114	\N	2014-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1606	МЦ.04-mon-676	\N	Samsung SyncMaster E1920	1	395	114	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1607	МЦ.04-mon-677	\N	Samsung SyncMaster E1920	1	395	114	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1608	МЦ.04.2-строка729	\N	INWIN	1	396	114	\N	2014-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1609	МЦ.04-mon-678	\N	Dell U2412M	1	396	114	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1610	МЦ.04-mon-679	\N	Samsung SyncMaster E1920	1	396	114	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1611	00-000209	\N	Aerocool; Поставка ООО "АВК"; (подмена матер. платы)	1	397	115	\N	2017-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1612	МЦ.04-mon-680	\N	Samsung 24"S24D300H	1	397	115	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1613	МЦ.04.2-строка732	\N	INWIN	1	398	116	\N	2014-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1614	МЦ.04-mon-681	\N	Dell Г2313Hf	1	398	116	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1615	МЦ.04-ups-259	\N	APC  500 (белый)	1	398	116	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1616	00-000354	\N	HP Elite Desk 800 G2	1	398	116	\N	2016-12-23	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1617	МЦ.04-mon-682	\N	Nec MultiSync EA221WMe	1	398	116	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1618	МЦ.04-mon-683	\N	Nec MultiSync EA221WMe	1	398	116	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1619	МЦ.04-ups-260	\N	APC  500 (белый)	1	398	116	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1620	МЦ.04.2-строка734	\N	USN Computers (mini)	1	399	116	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1621	МЦ.04-mon-684	\N	LG Flatron L192WS	1	399	116	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1622	00-000251	\N	МИР Z23271 (ООО "Мира")	1	400	116	\N	2017-12-22	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1623	МЦ.04-mon-685	\N	Benq GL2450	1	400	116	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1624	МЦ.04-ups-261	\N	Powercom RPT-1000A EURO	1	400	116	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1625	МЦ.04.2-строка737	\N	Flextron	1	401	117	\N	2012-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1626	МЦ.04-mon-686	\N	Dell U2412M	1	401	117	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1627	МЦ.04.2-строка738	\N	Flextron	1	402	117	\N	2012-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1628	МЦ.04-mon-687	\N	Dell E2314H	1	402	117	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1629	МЦ.04.2-строка739	\N	USN Computers (mini)	1	403	117	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1630	МЦ.04-mon-688	\N	AOC 24P2Q	1	403	117	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1631	00-000674	\N	AVK 2 (ООО «Вест-Тайп»)	1	404	118	\N	2020-02-05	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1632	МЦ.04-mon-689	\N	Samsung S27F358FWI	1	404	118	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1633	00-000770	\N	Ноутбук HP Pavilion Gaming 15-bc500ur	1	404	118	\N	2020-03-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
1634	МЦ.04-mon-690	\N	15.6"	1	404	118	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1635	МЦ.04.2-строка743	\N	Flextron	1	404	118	\N	2012-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1636	МЦ.04-mon-691	\N	LG Flatron IPS235	1	404	118	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1637	МЦ.04.2-строка745	\N	Flextron	1	405	119	\N	2012-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1638	МЦ.04-mon-692	\N	Samsung SyncMaster SA200	1	405	119	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1639	МЦ.04-ups-262	\N	APC UPS 500	1	405	119	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1640	МЦ.04.2-строка746	\N	Flextron	1	406	119	\N	2012-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1641	МЦ.04-mon-693	\N	Asus PA249	1	406	119	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1642	МЦ.04-ups-263	\N	APC UPS 500	1	406	119	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1643	00-001023	\N	ICL  B102 тип1	1	407	119	\N	2022-08-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1644	МЦ.04-mon-694	\N	Samsung SyncMaster B2240	1	407	119	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1645	00-000250	\N	МИР Z23271 (ООО "Мира")	1	408	120	\N	2017-12-22	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1646	МЦ.04-mon-695	\N	AOC 27P2Q	1	408	120	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1647	МЦ.04-ups-264	\N	APC Back-UPS 500(белый)	1	408	120	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1648	МЦ.04-строка750	\N	Ноутбук Acer Aspire A515-57-50EC	1	408	120	\N	2023-12-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
1649	МЦ.04-mon-696	\N	15,6"	1	408	120	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1650	00-000249	\N	МИР Z23271 (ООО "Мира")	1	409	121	\N	2017-12-22	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1651	МЦ.04-mon-697	\N	Dell E2313H	1	409	121	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1652	МЦ.04-mon-698	\N	Dell E2313H	1	409	121	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1653	МЦ.04-ups-265	\N	APC Back-UPS 500(белый)	1	409	121	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	ИБП
1654	00-000516	\N	ARBYTE	1	410	121	\N	2011-10-12	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1655	МЦ.04-mon-699	\N	NEC Multisync E221WMe	1	410	121	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1656	00-000514	\N	ARBYTE	1	411	122	\N	2012-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1657	МЦ.04-mon-700	\N	Nec MultiSync E231W	1	411	122	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1658	МЦ.04.2-строка756	\N	USN Computers (mini)	1	387	122	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1659	МЦ.04-mon-701	\N	Benq GL2450	1	387	122	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1660	99036-строка758	\N	HP  Proliant DL160 G6	1	19	27	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1661	99036-строка759	\N	HP  Proliant DL160 G6	1	19	27	\N	2010-01-01	\N	\N	Выключен	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1662	99036-строка760	\N	HP  Proliant DL160 G6	1	19	27	\N	2010-01-01	\N	\N	CD1 (старый домен)	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1663	00-000846	\N	HPE ProLiant DL360 Gen10 8SFF	1	19	27	\N	2020-10-07	\N	\N	Консультант,	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1664	00-000211	\N	Сервер Dell PowerEdge 330	1	19	27	\N	2017-10-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1665	00-000217	\N	ИБП Eaton 9130	1	19	27	\N	2017-12-14	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1666	00-000845	\N	HPE ProLiant DL360 Gen10 8SFF	1	19	123	\N	2020-10-07	\N	\N	Сервер 1С (Бух, ЗУП)	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1667	00-000486	\N	Сервер Proliant DL380 G7	1	19	124	\N	2011-06-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1668	00-000487	\N	Сервер Proliant DL380 G7	1	19	124	\N	2011-06-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1669	00-000488	\N	СХД HP StorageWorks P2000 G3	1	19	124	\N	2011-12-31	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1670	МЦ.04-ROW-769	\N	Supermicro	1	19	124	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1671	99036-строка771	\N	HP  Proliant DL160 G6	1	412	40	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1672	99036-строка772	\N	HP  Proliant DL160 G6	1	412	40	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1673	00-000174	\N	DEPO Storm 3400D1 X10DRW	1	412	40	\N	2016-02-17	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1674	МЦ.04.2-строка774	\N	R-STYLE MARSHALL	1	412	40	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1675	РБК6947	\N	Intel Swift Current Pass S2400SC	1	19	123	\N	2014-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Системный блок
1676	МЦ.04-строка783	\N	Ноутбук HP 15s-eq1436ur (669X8EA)	1	19	125	\N	2022-03-05	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Ноутбук
1677	МЦ.04-mon-702	\N	15"	1	19	125	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Монитор
1678	МЦ.04-принтер-2	\N	МФУ HP LaserJet Pro MFP M428fdn (МФУ, A4, лазерный, ч/б, LAN, WiFi)	1	5	8	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1679	19099	\N	Konica Minolta bizhub PRO C5501	1	413	9	\N	2008-11-18	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1680	РБК6950	\N	Konica Minolta bizhub Press C1070	1	413	9	\N	2015-01-26	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1681	МОЛ Рыбаков	\N	Konica Minolta bizhub C250i (МФУ, А3, лазер, цвет., LAN)	1	21	9	\N	2024-07-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1682	МОЛ Рыбаков-строка7	\N	Konica Minolta bizhub C250i (МФУ, А3, лазер, цвет., LAN)	1	21	9	\N	2024-07-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1683	00-001095	\N	МФУ Катюша M247 (МФУ, А4, лазер, ч/б, LAN, Wi-Fi)	1	5	2	\N	2023-01-17	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1684	МЦ.04-принтер-10	\N	МФУ HP Color LaserJet Pro MFP M477	1	5	2	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1685	МЦ.04-строка11	\N	Сканер Canon imageFORMULA DR-M260	1	5	2	\N	2024-06-04	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1686	НИИСУ-строка12	\N	Сканер Fujitsu fi-7160	1	6	2	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1687	МЦ.04.1-строка13	\N	Сканер Fujitsu fi-6130	1	5	2	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1688	00-001093	\N	МФУ Катюша M247 (МФУ, А4, лазер, ч/б, LAN, Wi-Fi)	1	5	2	\N	2023-01-17	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1689	НИИСУ-строка15	\N	Сканер Fujitsu fi-6130	1	4	2	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1690	НИИСУ-строка16	\N	Сканер Fujitsu fi-6130	1	24	2	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1691	1000012	\N	Konica Minolta bizhub C280	1	5	2	\N	2011-12-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1692	(списанная МЦ)	\N	МФУ Canon i-Sensys MF4690PL (МФУ, ч/б, лазер, А4, LAN)	1	23	11	\N	2008-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1693	МЦ.04-принтер-20	\N	HP LaserJet P1102	1	22	11	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1694	НИИСУ-строка21	\N	МФУ Canon i-SENSYS MF8340 (МФУ, цвет,  лазер, А4, LAN)	1	23	11	\N	2012-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1695	МЦ.04.2-строка23	\N	HP LaserJet 3050 (МФУ, ч/б, А4, только USB)	1	73	3	\N	2007-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1696	МЦ.04.2-строка25	\N	МФУ LaserJet HP 1522nf (лазер., ч/б, А4, LAN)	1	9	126	\N	2008-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1697	МЦ.04.2-строка26	\N	HP LaserJet 1018	1	9	126	\N	2007-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1698	МЦ.04.1-строка27	\N	Canon i-Sensys MF4550d (МФУ, ч/б, А4, USB)	1	9	12	\N	2011-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1699	МЦ.04.2-строка28	\N	HP LaserJet 1018	1	10	12	\N	2007-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1700	МЦ.04.2-строка29	\N	HP LaserJet P1505	1	11	12	\N	2007-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1701	00-000642	\N	Samsung MultiXpress SCX-8240 (МФУ, ч/б, лазер, А3)	1	\N	127	\N	2017-04-13	\N	\N	Учтен для картриджей; Акт о передаче ОС подписал	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1702	МЦ.04-принтер-33	\N	HP LaserJet P1505	1	\N	14	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1703	НИИСУ-строка37	\N	МФУ Canon i-sensys MF418x (МФУ, лазер, ч/б, 2-х сторон., А4, LAN, WiFi)	1	28	128	\N	2016-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1704	НИИСУ-строка38	\N	HP LaserJet M1212nf MFP (МФУ, ч/б, А4, LAN)	1	27	129	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
117	НИИСУ-строка42	\N	HP LaserJet M2727nf (МФУ, ч/б, лазер, А4, LAN)	1	29	17	\N	2012-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1706	МОЛ Данилкин-строка43	\N	Xerox B1025 (МФУ, A3, ч/б, лазер, LAN)	1	29	17	\N	2018-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1707	БП-001300 (информ. - 000118)	\N	HP Color LaserJet Enterprise 700 M750 (принтер, А3, лазер, цвет.,LAN)	1	32	18	\N	\N	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1708	МЦ.04 (001185)	\N	HP LaserJet Pro MFP M435nw (МФУ, А3, лазер, ч/б.,LAN,Wi-Fi)	1	32	18	\N	\N	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1709	МЦ.04 (001130)	\N	HP LaserJet M1212nf MFP (МФУ, ч/б, А4, LAN)	1	32	18	\N	\N	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1710	001344	\N	HP LaserJet Pro MFP M521dw (МФУ, A4, лазерный, ч/б, LAN, WiFi)	1	43	19	\N	\N	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1711	МЦ.04-принтер-53	\N	Xerox WorkCentre 3210 (МФУ,лазер,  ч/б,А4, LAN)	1	50	22	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1712	МОЛ - Карлов С.Н.	\N	Kyocera TASKalfa 2554ci (МФУ, цвет., лазер, A3, LAN)	1	414	23	\N	2023-11-13	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1713	МЦ.04-строка57	\N	МФУ HP Color LaserJet M476 dw (МФУ, цвет., лазер, A4, LAN, WiFi)	1	61	27	\N	2014-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1714	00-000666	\N	МФУ KYOCERA TASKalfa 2553ci + DP-7100 (МФУ, цвет., лазер, A3, LAN)	1	62	27	\N	2020-02-05	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1715	МЦ.04-строка59	\N	Brother QL-810W  (Настольный принтер  для печати этикеток и наклеек)	1	62	27	\N	2023-05-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1716	МЦ.04-строка60	\N	Brother QL-810W  (Настольный принтер  для печати этикеток и наклеек)	1	62	27	\N	2023-05-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1717	МЦ.04.2-строка62	\N	HP LaserJet 1018	1	72	30	\N	2007-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1718	МЦ.04.2-строка63	\N	Canon i-Sensys MF4550d (МФУ, ч/б, А4, USB)	1	73	30	\N	2011-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1719	МЦ.04.2-строка64	\N	HP LaserJet P1102	1	73	30	\N	2007-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1720	МЦ.04.2-строка65	\N	HP LaserJet 1020	1	74	30	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1721	МЦ.04-принтер-66	\N	Canon I-Sensys LBP252dw (принтер, ч/б, A4, LAN, WiFi)	1	71	30	\N	2016-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1722	МЦ.04.2-строка67	\N	HP LaserJet 1018	1	75	30	\N	2007-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1723	МЦ.04-принтер-68	\N	HP LaserJet 1200	1	76	30	\N	2001-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1724	Электроника-строка69	\N	HP LaserJet Pro MFP M426fdn (МФУ, A4, лазерный, ч/б, LAN)	1	77	30	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1725	МЦ.04-2	\N	HP LaserJet 1018	1	78	30	\N	2007-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1726	МЦ.04-строка72	\N	HP LaserJet P1102w	1	79	130	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1727	МЦ.04-строка73	\N	МФУ HP Color Laser MFP 178nw (А4, лазер, цвет., LAN, WiFi)	1	79	130	\N	2021-11-08	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1728	МЦ.04-принтер-74	\N	Brother HL-1112R	1	79	130	\N	2013-01-01	\N	\N	Личный - на нем не печатает	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1729	МЦ.04.2-строка76	\N	HP LaserJet P1102	1	82	32	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1730	МЦ.04.2-строка77	\N	HP LaserJet P1102	1	83	32	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1731	МЦ.04.2-строка78	\N	HP LaserJet P1102	1	84	32	\N	2007-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1732	МЦ.04.2-строка79	\N	HP LaserJet P1102	1	85	32	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1733	МЦ.04.2-строка80	\N	HP LaserJet P1102	1	86	32	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1734	(МЦ.04)	\N	Kyocera M2135dn (МФУ, ч/б, лазер, A4, LAN)	1	80	32	\N	2017-12-21	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1735	МЦ.04.2-строка82	\N	HP LaserJet P1102	1	80	32	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1736	МЦ.04.2-строка84	\N	HP LaserJet 1018	1	87	33	\N	2007-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1737	МЦ.04.2-строка85	\N	HP LaserJet P1102	1	80	33	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1738	МЦ.04.2-строка87	\N	HP LaserJet 1020	1	90	34	\N	2007-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
213	МЦ.04.2-строка88	\N	HP LaserJet 1020	1	89	34	\N	2007-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1740	МЦ.04.2-строка89	\N	HP LaserJet 1020	1	88	34	\N	2007-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1741	МЦ.04.2-строка91	\N	HP LaserJet P1102	1	96	35	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1742	МЦ.04.2-строка92	\N	HP LaserJet 1020	1	94	35	\N	2007-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1743	87387	\N	HP LaserJet 1200	1	95	35	\N	2001-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1744	МЦ.04-принтер-94	\N	Xerox Phaser 3140 (принтер, ч/б, лазер, USB)	1	99	35	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1745	МЦ.04-строка95	\N	МФУ HP Color LaserJet Pro MFP M479fdn (МФУ, цвет.,А4, LAN)	1	98	35	\N	2020-02-05	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1746	МЦ.04.2-строка96	\N	HP LaserJet P1102	1	415	35	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1747	МЦ.04.2-строка98	\N	HP LaserJet P1102	1	101	36	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1748	87283	\N	HP LaserJet P1102	1	100	36	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1749	МЦ.04.2-строка100	\N	HP LaserJet P1102	1	104	36	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1750	МЦ.04.2-строка101	\N	HP LaserJet P1102	1	105	36	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1751	МЦ.04.2-строка102	\N	HP LaserJet P1102	1	102	36	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1752	МЦ.04.2-строка103	\N	HP LaserJet 1020	1	106	36	\N	2007-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1753	МЦ.04-принтер-104	\N	HP LaserJet Pro 400 Color MFP M475dw	1	100	36	\N	2012-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1754	МЦ.04.2-строка106	\N	Canon i-Sensys MF4550d (МФУ, ч/б, А4, USB)	1	107	37	\N	2011-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1755	МЦ.04.2-строка107	\N	HP LaserJet P1102	1	108	37	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1756	МЦ.04.2-строка108	\N	HP LaserJet P1102	1	110	37	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1757	(МЦ.04.2)	\N	HP LaserJet 3050 (МФУ, ч/б, А4, только USB)	1	111	37	\N	2007-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1758	МЦ.04.2-строка110	\N	HP LaserJet P1102	1	109	37	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1759	МЦ.04.2-строка111	\N	HP LaserJet 1018	1	112	37	\N	2007-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1760	МЦ.04.2-строка113	\N	HP LaserJet 1020	1	116	40	\N	2007-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1761	99049	\N	HP Color LaserJet 3600n  (принтер, цв., А4, LAN)	1	59	40	\N	2006-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1762	(МЦ.04.2)-строка115	\N	HP Color LaserJet 5550n (принтер, цв., А3, LAN)	1	416	40	\N	2007-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1763	870956	\N	Konica Minolta magicolor 2550 (принтер, цв., А4, LAN)	1	59	40	\N	2007-01-01	\N	\N	Готовится к списанию	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1764	190353	\N	Сканер Canon DR2580C	1	116	40	\N	\N	\N	\N	Возможно числится за МОЛ Шемякина А.Е.	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1765	МЦ.04.2-строка119	\N	HP LaserJet P1102	1	113	38	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1766	МЦ.04-строка120	\N	МФУ Canon i-Sensys MF744cdw (МФУ, цвет,А4, LAN, WiFi)	1	114	38	\N	2021-03-02	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1767	МЦ.04-строка122	\N	МФУ HP Color LaserJet Pro MFP M479fdn (МФУ, цвет.,А4, LAN)	1	115	39	\N	2023-04-14	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1768	(МЦ.04.2)-строка124	\N	Сканер Canon CanoScan 5600F	1	417	40	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1769	МЦ.04-строка126	\N	HP LaserJet M127 fw (МФУ, ч/б, А4, LAN, WiFi)	1	67	29	\N	2014-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1770	МЦ.04.2-строка128	\N	HP LaserJet P1102	1	117	41	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1771	МЦ.04-принтер-129	\N	Сканер Canon Lide210	1	117	41	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1772	МЦ.04.2-строка130	\N	HP LaserJet 1020	1	118	41	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1773	МЦ.04.2-строка132	\N	HP LaserJet M1212nf MFP (МФУ, ч/б, А4, LAN)	1	120	42	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1774	00-000646	\N	Принтер Canon PIXMA PRO-100S (принтер, A3, струйный, цвет., LAN, WiFi)	1	173	131	\N	2019-09-19	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1775	МЦ.04-строка135	\N	МФУ HP Color LaserJet Pro MFP M479fdn (МФУ, цвет.,А4, LAN)	1	134	131	\N	2020-02-05	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1776	МЦ.04-принтер-137	\N	Canon i-Sensys MF4550d (МФУ, ч/б, А4, USB)	1	133	44	\N	2011-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1777	00-000681	\N	МФУ Konica Minolta bizhub C227 + DF-628 (МФУ, цвет., А3, LAN)	1	133	44	\N	2020-02-05	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1778	МЦ.04.2-строка141	\N	HP LaserJet Pro M426dw,(МФУ, A4, лазерный, ч/б, LAN, WiFi)	1	163	56	\N	2018-04-26	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1779	00-000854	\N	МФУ KYOCERA ECOSYS M3145dn (МФУ, ч/б, лазер, А4, LAN)	1	49	57	\N	2020-09-16	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1780	00-000680	\N	МФУ Konica Minolta bizhub C227 + DF-628 (МФУ, цвет., А3, LAN)	1	173	58	\N	2020-02-05	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1781	?-строка147	\N	Brother MFP 7360 NR (МФУ, ч/б, А4, LAN)	1	185	59	\N	2011-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1782	МЦ.04-строка148	\N	HP LaserJet Pro 400 MFP M425dw	1	185	59	\N	2012-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1783	00-000243	\N	Kyocera TASKalfa 2552ci (МФУ, цвет., лазер, A3, LAN)	1	185	59	\N	2017-12-22	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1784	?-строка150	\N	Brother MFP 7360 NR (МФУ, ч/б, А4, LAN)	1	187	59	\N	2011-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
342	МЦ.04-строка152	\N	МФУ Canon i-Sensys MF744cdw (МФУ, цвет,А4, LAN, WiFi)	1	137	48	\N	2021-03-02	\N	\N	Не учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1786	00-001091	\N	МФУ Катюша M247 (МФУ, А4, лазер, ч/б, LAN, Wi-Fi)	1	137	48	\N	2023-01-17	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1787	БП-001247	\N	Konica Minolta bizhub C250i (МФУ, А3, лазер, цвет., LAN)	1	137	48	\N	2024-07-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1788	00-001094	\N	МФУ Катюша M247 (МФУ, А4, лазер, ч/б, LAN, Wi-Fi)	1	141	48	\N	2023-01-17	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1789	МЦ.04.2-строка156	\N	HP LaserJet 1020	1	142	48	\N	2007-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1790	МЦ.04.2-строка158	\N	HP LaserJet Pro M426dw,(МФУ, A4, лазерный, ч/б, LAN, WiFi)	1	144	51	\N	2018-04-26	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1791	00-000653	\N	МФУ KYOCERA TASKalfa 2553ci + DP-7100 (МФУ, цвет., лазер, A3, LAN)	1	144	51	\N	2019-12-27	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1792	МЦ.04.2-строка161	\N	HP LaserJet P1102	1	156	52	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1793	МЦ.04.2-строка162	\N	МФУ HP LaserJet Pro MFP M428fdw (МФУ, A4, лазерный, ч/б, LAN, WiFi)	1	156	52	\N	2019-09-19	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1794	00-000842	\N	МФУ Konica Minolta bizhub C227 + DF-628 (МФУ, цвет., А3, LAN)	1	156	132	\N	2020-09-16	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1795	МЦ.04.2-строка164	\N	HP LaserJet P1102w	1	159	53	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1796	99036-строка166	\N	HP LaserJet M1319f MFP(МФУ, ч/б,А4, USB)	1	160	133	\N	2008-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1797	МЦ.04-строка168	\N	МФУ Canon i-Sensys Colour MF752Cdw (МФУ, А4, лазер, цвет., LAN, Wi-Fi)	1	161	55	\N	2024-07-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1798	99036-строка169	\N	HP LaserJet P1102	1	161	55	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1799	МЦ.04-строка170	\N	HP LaserJet 107a	1	162	55	\N	2021-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1800	БП-001238	\N	МФУ Катюша M247 (МФУ, А4, лазер, ч/б, LAN, Wi-Fi)	1	279	81	\N	2024-07-18	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1801	00-000682	\N	МФУ KYOCERA ECOSYS M3145dn (МФУ, ч/б, лазер, А4, LAN)	1	279	81	\N	2020-02-05	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1802	БП-001240	\N	Konica Minolta bizhub C3320i (МФУ, А4, лазер, цвет., LAN)	1	279	81	\N	2024-07-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1803	НИИСУ-строка176	\N	HP LaserJet M1212nf MFP (МФУ, ч/б, А4, LAN)	1	418	134	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1804	НИИСУ-строка177	\N	HP LaserJet P1102	1	191	134	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1805	00-001089	\N	МФУ Катюша M247 (МФУ, А4, лазер, ч/б, LAN, Wi-Fi)	1	188	134	\N	2023-01-17	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
407	НИИСУ-строка179	\N	HP LaserJet P1102	1	188	134	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1807	99036-строка181	\N	HP LaserJet M1319f MFP(МФУ, ч/б,А4, USB)	1	192	63	\N	2008-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1808	99036-строка182	\N	HP LaserJet P1102	1	193	64	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1809	МЦ.04-строка183	\N	МФУ Canon i-Sensys Colour MF752Cdw (МФУ, А4, лазер, цвет., LAN, Wi-Fi)	1	193	64	\N	2024-07-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1810	МЦ.04.2-строка184	\N	HP LaserJet 3050 (МФУ, ч/б, А4, только USB)	1	195	135	\N	2007-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1811	МЦ.04.2-строка186	\N	HP LaserJet Pro 200 color MFP M276n	1	196	136	\N	2012-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1812	МЦ.04-принтер-187	\N	HP LaserJet P1102	1	196	136	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1813	БП-001253	\N	Konica Minolta bizhub C250i (МФУ, А3, лазер, цвет., LAN)	1	199	137	\N	2024-07-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1814	НИИСУ-строка190	\N	МФУ Canon i-Sensys MF9280cdn (МФУ, лазер, цвет., 2-х сторон., А4, LAN)	1	205	137	\N	\N	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1815	МЦ.04.2-строка192	\N	МФУ HP LaserJet Pro MFP M428fdw (МФУ, A4, лазерный, ч/б, LAN, WiFi)	1	211	69	\N	2019-12-27	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1816	МЦ.04.2-строка194	\N	HP LaserJet 1018	1	209	68	\N	2007-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1817	00-000652	\N	МФУ KYOCERA TASKalfa 2553ci + DP-7100 (МФУ, цвет., лазер, A3, LAN)	1	211	68	\N	2019-12-27	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1818	НИИСУ-строка197	\N	МФУ Canon i-SENSYS MF6140dn (МФУ, ч/б, лазер, А4, LAN)	1	227	70	\N	2014-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1819	00-001109	\N	МФУ HP Color LaserJet Enterprise M776dn (МФУ, цвет, лазер, А3, LAN)	1	227	70	\N	2023-04-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1820	МЦ.04-принтер-200	\N	HP LaserJet M1319f MFP(МФУ, ч/б,А4, USB)	1	239	71	\N	2008-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1821	00-000844	\N	Kyocera M6230cidn (МФУ, А4, лазер, цвет., LAN)	1	239	71	\N	2020-09-16	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1822	МЦ.04-принтер-202	\N	XEROX Phaser 5335 (принтер,лазер, ч/б, А3, LAN)	1	239	71	\N	2008-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1823	МЦ.04-принтер-204	\N	Xerox WorkCentre 3210 (МФУ,лазер,  ч/б,А4, LAN)	1	239	138	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1824	МЦ.04-принтер-205	\N	Xerox WorkCentre 3210 (МФУ,лазер,  ч/б,А4, LAN)	1	239	138	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1825	00-001096	\N	МФУ Катюша M247 (МФУ, А4, лазер, ч/б, LAN, Wi-Fi)	1	248	73	\N	2023-01-17	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1826	НИИСУ-строка208	\N	МФУ HP LaserJet Pro M217nfw (МФУ, лазер,ч/б, А4, LAN, WiFi)	1	245	72	\N	2012-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1827	МЦ.04.2-строка209	\N	HP LaserJet 1020	1	246	72	\N	2007-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1828	МЦ.04-строка211	\N	МФУ HP Color LaserJet Pro MFP M479fdw (МФУ, цвет.,А4, LAN, WiFi)	1	264	75	\N	2020-02-05	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1829	МЦ.04.2-строка212	\N	HP LaserJet 1018	1	419	75	\N	2007-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1830	00-000878	\N	МФУ Konica Minolta bizhub C227 + DF-628 (МФУ, цвет., А3, LAN)	1	250	74	\N	2021-03-02	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1831	00-000843	\N	Kyocera ECOSYS M6230cidn (МФУ, цвет.,А4, LAN, WiFi)+ IB-36	1	270	76	\N	2020-09-16	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1832	МЦ.04.2-строка217	\N	HP LaserJet 1020	1	270	76	\N	2007-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1833	МЦ.04.2-строка219	\N	HP LaserJet 1020	1	272	77	\N	2007-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1834	МЦ.04.2-строка220	\N	HP LaserJet P1102	1	420	77	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1835	МЦ.04.2-строка222	\N	HP LaserJet Pro 400 Color MFP M475dw	1	273	78	\N	2012-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1836	МЦ.04.2-строка223	\N	HP LaserJet 1200	1	274	79	\N	2001-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1837	(МЦ.04.2)-строка225	\N	HP LaserJet M1319f MFP(МФУ, ч/б,А4, USB)	1	276	80	\N	2008-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1838	МЦ.04-строка226	\N	МФУ HP Color LaserJet Pro MFP M479fdn (МФУ, цвет.,А4, LAN)	1	277	80	\N	2019-12-27	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1839	МЦ.04.2-строка228	\N	HP LaserJet 1018	1	421	66	\N	2007-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1840	Электроника-строка230	\N	HP LaserJet Pro MFP M426dw (МФУ, A4, лазерный, ч/б, LAN, WiFi)	1	284	82	\N	\N	\N	\N	admin	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1841	(МЦ.04)-строка231	\N	Kyocera M2135dn (МФУ, ч/б, лазер, A4, LAN)	1	290	82	\N	2017-12-21	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1842	МЦ.04-строка232	\N	Canon iSENSYS MF443dw (МФУ, ч/б, А4, лазер, LAN, WiFi)	1	288	82	\N	2021-03-02	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1843	НИИСУ-строка234	\N	МФУ Canon i-Sensys MF5940DN (МФУ, ч/б, лазер, А4, LAN)	1	294	84	\N	2012-01-01	\N	\N	Учтен для картриджей; Списать	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1844	НИИСУ-строка235	\N	МФУ HP Laser Jet M125ra (МФУ, ч/б, лазер, А4, LAN)	1	294	84	\N	2008-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1845	НИИСУ-строка236	\N	МФУ HP Laser Jet M1217nfw MFP (МФУ, ч/б, лазер, А4, LAN)	1	\N	83	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
544	МЦ.04-строка238	\N	МФУ Canon i-Sensys Colour MF752Cdw (МФУ, А4, лазер, цвет., LAN, Wi-Fi)	1	298	85	\N	2024-07-18	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1847	МЦ.04.2-строка240	\N	HP LaserJet 3050 (МФУ, ч/б, А4, только USB)	1	303	86	\N	2007-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1848	МЦ.04.2-строка241	\N	HP LaserJet M1212nf MFP (МФУ, ч/б, А4, LAN)	1	299	86	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1849	МЦ.04-строка242	\N	Canon iSENSYS MF443dw (МФУ, ч/б, А4, лазер, LAN, WiFi)	1	304	86	\N	2021-03-02	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1850	990002	\N	Xerox WorkCentre 3210 (МФУ,лазер,  ч/б,А4, LAN)	1	300	86	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1851	МЦ.04-принтер-244	\N	Xerox WorkCentre 3210 (МФУ,лазер,  ч/б,А4, LAN)	1	422	86	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1852	МЦ.04.2-строка245	\N	Canon iSENSYS MF443dw (МФУ, ч/б, А4, лазер, LAN, WiFi)	1	301	86	\N	2021-03-02	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1853	00-000877	\N	МФУ Konica Minolta bizhub C227 + DF-628 (МФУ, цвет., А3, LAN)	1	301	86	\N	2021-03-02	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1854	(МЦ.04.2)-строка247	\N	Xerox Phaser 3140 (принтер, ч/б, лазер, USB)	1	302	86	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1855	МЦ.04-строка248	\N	Canon iSENSYS MF443dw (МФУ, ч/б, А4, лазер, LAN, WiFi)	1	305	86	\N	2021-03-02	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1856	МЦ.04-принтер-250	\N	HP LaserJet EnterPrise M604   (принтер, ч/б, А4)	1	423	66	\N	2015-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1857	МЦ.04-принтер-251	\N	HP LaserJet Pro 400 Color M451dn (принтер, цвет, А4)	1	423	66	\N	2012-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1858	БП-001250	\N	Konica Minolta bizhub C250i (МФУ, А3, лазер, цвет., LAN)	1	337	97	\N	2024-07-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1859	00-001088	\N	МФУ Катюша M247 (МФУ, А4, лазер, ч/б, LAN, Wi-Fi)	1	337	97	\N	2023-01-17	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1860	00-001072	\N	Сканер Fujitsu fi-7260	1	339	97	\N	2022-12-19	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1861	НИИСУ-строка257	\N	HP LaserJet M1212nf MFP (МФУ, ч/б, А4, LAN)	1	345	98	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1862	00-001090	\N	МФУ Катюша M247 (МФУ, А4, лазер, ч/б, LAN, Wi-Fi)	1	346	98	\N	2023-01-17	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1863	НИИСУ-строка259	\N	HP Color LaserJet M751 (принтер, лазер, цвет., А3, LAN)	1	189	98	\N	2019-01-01	\N	\N	Не учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1864	НИИСУ-строка260	\N	HP LaserJet M1212nf MFP (МФУ, ч/б, А4, LAN)	1	188	98	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1865	МЦ.04-строка262	\N	МФУ HP Color LaserJet Pro MFP M479fdn (МФУ, цвет.,А4, LAN)	1	353	100	\N	2020-09-16	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1866	00-000320	\N	МФУ Konica Minolta bizhub C227 + DF-628 (МФУ, цвет., А3, LAN)	1	353	100	\N	2018-09-19	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1867	99036-строка264	\N	HP LaserJet P1006	1	348	100	\N	2008-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1868	(МЦ.04.2)-строка266	\N	HP LaserJet M1212nf MFP (МФУ, ч/б, А4, LAN)	1	357	103	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1869	МЦ.04-принтер-267	\N	HP LaserJet 100 color MFP M175 (МФУ, цвет., А4, USB)	1	357	103	\N	2011-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1870	МЦ.04.2-строка268	\N	HP LaserJet 1020	1	358	103	\N	2007-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1871	00-001099	\N	МФУ Катюша M247 (МФУ, А4, лазер, ч/б, LAN, Wi-Fi)	1	359	103	\N	2023-01-17	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1872	МЦ.04.2-строка271	\N	МФУ HP LaserJet Pro MFP M428fdw (МФУ, A4, лазерный, ч/б, LAN, WiFi)	1	355	102	\N	2019-09-19	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
622	МЦ.04.2-строка273	\N	HP LaserJet 1020	1	360	104	\N	2007-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1874	БП-001232	\N	МФУ Катюша M247 (МФУ, А4, лазер, ч/б, LAN, Wi-Fi)	1	360	104	\N	2024-07-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1875	МЦ.04-принтер-276	\N	HP LaserJet Pro 400 Color MFP M475dw	1	364	105	\N	2012-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1876	БП-001233	\N	МФУ Катюша M247 (МФУ, А4, лазер, ч/б, LAN, Wi-Fi)	1	364	105	\N	2024-07-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1877	99036-строка279	\N	HP LaserJet P1102	1	365	106	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1878	МЦ.04-строка280	\N	Kyocera M2135dn (МФУ, ч/б, лазер, A4, LAN)	1	365	106	\N	2017-12-21	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1879	МЦ.04.2-строка281	\N	HP LaserJet 1020	1	366	106	\N	2007-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1880	БП-001244	\N	Konica Minolta bizhub C3320i (МФУ, А4, лазер, цвет., LAN)	1	369	107	\N	2024-07-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1881	МЦ.04.2-строка284	\N	МФУ HP LaserJet Pro MFP M428fdw (МФУ, A4, лазерный, ч/б, LAN, WiFi)	1	369	107	\N	2019-09-19	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1882	МЦ.04-2-строка286	\N	HP LaserJet Pro 400 Color MFP M475dw	1	371	108	\N	2012-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1883	МЦ.04.2-строка287	\N	HP LaserJet 1018	1	370	108	\N	2007-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1884	МЦ.04.2-строка288	\N	HP LaserJet 3050 (МФУ, ч/б, А4, только USB)	1	371	108	\N	2007-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1885	МЦ.04.2-строка289	\N	HP LaserJet M1319f MFP(МФУ, ч/б,А4, USB)	1	372	108	\N	2008-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1886	РБК6931	\N	OKI	1	371	108	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1887	МЦ.04-принтер-292	\N	HP LaserJet M1212nf MFP (МФУ, ч/б, А4, LAN)	1	424	109	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1888	00-000643	\N	Kyocera TASKalfa 3051ci  (МФУ, цвет., лазер, A3, LAN)	1	337	109	\N	2015-10-22	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1889	МЦ.04-строка295	\N	Kyocera M6030CDN (МФУ, цвет.,А4, LAN)	1	414	139	\N	2017-12-22	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1890	МЦ.04.2-строка297	\N	HP LaserJet Pro 200 color MFP M276n	1	19	6	\N	2013-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1891	БП-001252	\N	Konica Minolta bizhub C250i (МФУ, А3, лазер, цвет., LAN)	1	313	5	\N	2024-07-18	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1892	МЦ.04-строка300	\N	МФУ HP Color Laser 179fnw (А4, лазер, цвет.)	1	306	5	\N	2022-12-19	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1893	МЦ.04 (001036)	\N	Brother MFC-7360NR (МФУ, ч/б, А4, LAN)	1	319	5	\N	\N	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1894	МЦ.04 (001591)	\N	HP LaserJet Enterprice M609 (принтер, А4, лазер, ч/б)	1	313	5	\N	\N	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1895	МЦ.04 (000209)	\N	HP Color LaserJet CP5225dn (принтер, А3, лазер, цвет., LAN)	1	313	5	\N	\N	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1896	МЦ.04 (001116)	\N	HP LaserJet Pro M1214nfh (МФУ, А4, лазер, ч/б, LAN)	1	324	5	\N	\N	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1897	МЦ.04 (001625)	\N	EPSON L1800 (принтер, А3, струйный, цвет)	1	316	5	\N	\N	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1898	МЦ.04 (001593)	\N	HP Color LaserJet CP5225dn (принтер, А3, лазер, цвет., LAN)	1	313	5	\N	\N	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1899	МЦ.04 (001213)	\N	HP LaserJet P3015 (принтер, А4, лазер, ч/б, LAN)	1	314	5	\N	\N	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1900	МЦ.04 (001228)	\N	Brother MFC-7360NR (МФУ, ч/б, А4, LAN)	1	307	5	\N	\N	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1901	МЦ.04 (001102)	\N	HP COLOR LaserJet Pro 400 M451dw (принтер, А4, лазер, цвет.,LAN, WiFi)	1	322	5	\N	\N	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1902	?-строка311	\N	HP LaserJet M1120 MFP (МФУ, ч/б,А4, USB)	1	325	90	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1903	?-строка313	\N	HP LaserJet P1102	1	326	91	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1904	МЦ.04-строка314	\N	МФУ Canon i-Sensys MF744cdw (МФУ, цвет,А4, LAN, WiFi)	1	326	91	\N	2021-03-02	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1905	МЦ.04-принтер-316	\N	HP LaserJet 1018	1	328	95	\N	2007-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1906	00-000834	\N	МФУ KYOCERA ECOSYS M3145dn (МФУ, ч/б, лазер, А4, LAN)	1	327	94	\N	2020-06-18	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1907	00-000876	\N	МФУ Konica Minolta bizhub C227 + DF-628 (МФУ, цвет., А3, LAN)	1	143	96	\N	2021-03-02	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1908	?-строка321	\N	HP LaserJet P1102	1	384	111	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1909	МЦ.04.2-строка322	\N	HP LaserJet 1018	1	387	111	\N	2007-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1910	МПТ	\N	МФУ Ricoh SP 325snw (МФУ, ч/б,А4, USB, WiFi )	1	386	111	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1911	БП-001241	\N	Konica Minolta bizhub C3320i (МФУ, А4, лазер, цвет., LAN)	1	385	111	\N	2024-07-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1912	МЦ.04.2-строка326	\N	HP LaserJet 1020	1	398	116	\N	2007-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1913	00-001075	\N	Kyocera M6230cidn (МФУ, А4, лазер, цвет., LAN)	1	398	116	\N	2022-12-19	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1914	МЦ.04.2-строка329	\N	HP LaserJet M1319f MFP(МФУ, ч/б,А4, USB)	1	401	117	\N	2008-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1915	НИИСУ-строка330	\N	МФУ Canon i-sensys MF418x (МФУ, лазер, ч/б, 2-х сторон., А4, LAN, WiFi)	1	401	117	\N	2016-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1916	00-001097	\N	МФУ Катюша M247 (МФУ, А4, лазер, ч/б, LAN, Wi-Fi)	1	404	118	\N	2023-01-17	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1917	МЦ.04.2-строка334	\N	HP LaserJet M1319f MFP(МФУ, ч/б,А4, USB)	1	405	119	\N	2008-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1918	МЦ.04.2-строка335	\N	HP LaserJet 1020	1	406	119	\N	2007-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1919	00-001073	\N	Kyocera M6230cidn (МФУ, А4, лазер, цвет., LAN)	1	405	119	\N	2022-12-19	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1920	МЦ.04-принтер-337	\N	HP LaserJet P1102	1	425	119	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1921	?-строка339	\N	HP LaserJet P1102	1	408	120	\N	2010-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1922	МЦ.04-строка340	\N	МФУ Canon i-Sensys Colour MF752Cdw (МФУ, А4, лазер, цвет., LAN, Wi-Fi)	1	408	120	\N	2024-07-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1923	00-000510	\N	HP LaserJet Enterprise 700 M712dn	1	409	121	\N	2016-12-23	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1924	НИИСУ-строка343	\N	МФУ Canon i-Sensys MF5940DN (МФУ, ч/б, лазер, А4, LAN)	1	409	121	\N	2012-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1925	МЦ.04-строка345	\N	МФУ HP Color LaserJet Pro MFP M479fdn (МФУ, цвет.,А4, LAN)	1	389	113	\N	2020-02-05	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1926	МЦ.04.2-строка346	\N	HP LaserJet 1020	1	390	113	\N	2007-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1927	Электроника-строка347	\N	HP LaserJet Pro MFP M426dw (МФУ, A4, лазерный, ч/б, LAN, WiFi)	1	390	113	\N	\N	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1928	00-000853	\N	МФУ KYOCERA ECOSYS M3145dn (МФУ, ч/б, лазер, А4, LAN)	1	426	113	\N	2020-09-16	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1929	НИИСУ-строка349	\N	МФУ Canon i-Sensys MF5940DN (МФУ, ч/б, лазер, А4, LAN)	1	393	113	\N	2012-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1930	МЦ.04.2-строка351	\N	HP LaserJet 1020	1	394	114	\N	2007-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1931	БП-001234	\N	МФУ Катюша M247 (МФУ, А4, лазер, ч/б, LAN, Wi-Fi)	1	394	114	\N	2024-07-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
792	МЦ.04-строка353	\N	Xerox WorkCentre (МФУ,лазер,  ч/б,А4, LAN)	1	396	115	\N	2014-01-01	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1933	МЦ.04 (001486)	\N	МФУ HP LaserJet Pro MFP M428fdn (МФУ, A4, лазерный, ч/б, LAN)	1	379	110	\N	\N	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	МФУ
1934	МЦ.04 (001411)	\N	HP Color LaserJet Pro M452dn (принтер, А4, лазер, цвет.,LAN)	1	379	110	\N	\N	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1935	МЦ.04 (001595)	\N	Epson DS-7500 (Планшетный сканер, A4)	1	380	110	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1936	МЦ.04 (001255)	\N	HP LaserJet 600 M603 (принтер, А4, лазер, ч/б.,LAN)	1	376	110	\N	\N	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1937	МЦ.04 (001596)	\N	Офисная система публикации Primera BravoSE Disk Pudlisher	1	376	110	\N	\N	\N	\N	Дубликатор дисков	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
1938	МЦ.04.2-строка362	\N	HP LaserJet 1020	1	411	122	\N	2007-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	Принтер
\.


--
-- Data for Name: equipment_software; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.equipment_software (id, equipment_id, software_id, installed_at, created_at) FROM stdin;
\.


--
-- Data for Name: import_errors; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.import_errors (id, import_run_id, row_number, error_code, error_message, raw_payload, created_at) FROM stdin;
\.


--
-- Data for Name: import_runs; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.import_runs (id, source_type, source_name, started_at, finished_at, total_rows, success_rows, error_rows, run_status, initiated_by, details) FROM stdin;
\.


--
-- Data for Name: licenses; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.licenses (id, software_id, valid_until, notes, created_at) FROM stdin;
1	900001	2027-02-14	Тестовая лицензия для проверки раздела	2026-02-13 22:54:56
2	900002	2027-02-15	Тестовая лицензия для проверки раздела	2026-02-13 22:54:56
3	900003	2027-02-16	Тестовая лицензия для проверки раздела	2026-02-13 22:54:56
4	900004	2027-02-17	Тестовая лицензия для проверки раздела	2026-02-13 22:54:56
5	900005	2027-02-18	Тестовая лицензия для проверки раздела	2026-02-13 22:54:56
6	900006	2027-02-19	Тестовая лицензия для проверки раздела	2026-02-13 22:54:56
7	900007	2027-02-20	Тестовая лицензия для проверки раздела	2026-02-13 22:54:56
8	900008	2027-02-21	Тестовая лицензия для проверки раздела	2026-02-13 22:54:56
9	900009	2027-02-22	Тестовая лицензия для проверки раздела	2026-02-13 22:54:56
10	900010	2027-02-23	Тестовая лицензия для проверки раздела	2026-02-13 22:54:56
\.


--
-- Data for Name: locations; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.locations (id, location_code, name, location_type, floor, description, is_archived, created_by_id, updated_by_id, created_at, updated_at) FROM stdin;
2	\N	103	кабинет	\N	\N	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
3	\N	105	кабинет	\N	\N	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
4	\N	Пост охраны	кабинет	\N	\N	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
5	\N	701	кабинет	\N	\N	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
6	\N	702 в	кабинет	\N	\N	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
8	\N	подвал	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
9	\N	118	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
10	\N	101	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
11	\N	104	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
12	\N	106	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
13	\N	Болид	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
14	\N	108	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
15	\N	110 а	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
16	\N	110б	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
17	\N	111	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
18	\N	112	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
19	\N	113а	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
20	\N	113в	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
21	\N	113г	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
22	\N	114	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
23	\N	115	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
24	\N	121	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
25	\N	301-302 (Белый зал, балкон)	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
26	\N	305	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
27	\N	303	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
28	\N	304 (Красный зал)	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
29	\N	306	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
30	\N	307	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
31	\N	307 а	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
32	\N	308	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
33	\N	309	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
34	\N	310	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
35	\N	311	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
36	\N	312	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
37	\N	313	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
38	\N	314	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
39	\N	315	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
40	\N	317	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
41	\N	318	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
42	\N	319	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
43	\N	320	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
44	\N	321	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
45	\N	321а	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
46	\N	322а	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
47	\N	322a	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
48	\N	406	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
49	\N	Передан в Минпромторг	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
50	\N	406а	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
51	\N	408	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
52	\N	409 б	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
53	\N	409 а	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
54	\N	411	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
55	\N	416-417	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
56	\N	419	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
57	\N	420	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
58	\N	421	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
59	\N	422	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
60	\N	403	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
61	\N	501а	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
62	\N	501a	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
63	\N	501 ж	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
64	\N	501 е	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
65	\N	501 д	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
66	\N	525	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
67	\N	501к	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
68	\N	503	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
69	\N	504	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
70	\N	505	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
71	\N	506	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
72	\N	509	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
73	\N	508	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
74	\N	510	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
75	\N	511	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
76	\N	513	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
77	\N	512	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
78	\N	518	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
79	\N	519	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
80	\N	520	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
81	\N	524	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
82	\N	604	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
83	\N	608	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
84	\N	609	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
85	\N	610	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
86	\N	612	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
87	\N	к. 702а	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
88	\N	к. 704	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
89	\N	702 б	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
90	\N	703	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
91	\N	704	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
92	\N	704а	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
93	\N	705	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
94	\N	706	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
95	\N	706а	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
96	\N	707	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
97	\N	708	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
98	\N	710	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
99	\N	711	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
100	\N	712	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
101	\N	714	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
102	\N	715	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
103	\N	716	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
104	\N	717	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
105	\N	718	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
106	\N	719	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
107	\N	720	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
108	\N	721	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
109	\N	723	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
110	\N	807	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
111	\N	807 з	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
112	\N	807з	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
113	\N	807 г	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
114	\N	807д	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
115	\N	807 д	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
116	\N	810 а	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
117	\N	810 б	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
118	\N	810 в	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
119	\N	811	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
120	\N	812 б	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
121	\N	812 а	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
122	\N	805	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
123	\N	806 б	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
124	\N	116	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
125	\N	702в	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
126	\N	охрана	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
127	\N	1 этаж	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
128	\N	110	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
129	\N	110а	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
130	\N	307А	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
131	\N	322	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
132	\N	409	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
133	\N	412	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
134	\N	501 а	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
135	\N	501д	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
136	\N	525а	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
137	\N	501 к	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
138	\N	507	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
139	\N	702а	кабинет	\N	\N	f	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
\.


--
-- Data for Name: migration; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.migration (version, apply_time) FROM stdin;
m000000_000000_base	1771004397
m260212_100000_insert_initial_admin_user	1771004397
m260213_120000_add_software_licenses	1771004397
m260215_100000_equipment_types	1771171131
m260215_120000_revert_to_dump_equipment_type	1771171656
m260217_100000_seed_17_monitors	1771359096
m260217_120000_extract_ups_from_description	1771359527
\.


--
-- Data for Name: nsi_change_log; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.nsi_change_log (id, dictionary_name, record_id, operation_type, old_value, new_value, changed_by, changed_at) FROM stdin;
\.


--
-- Data for Name: part_char_values; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.part_char_values (id, equipment_id, part_id, char_id, value_text, value_num, source, updated_by, updated_at) FROM stdin;
37	6	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-12 20:47:56.480176+03
38	6	7	9	8 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
39	6	8	8	SSD 480 ГБ; HDD 500 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
40	6	9	8	BENQ BL2201M	\N	manual	\N	2026-02-12 20:47:56.480176+03
41	6	9	10	НИИСУ	\N	manual	\N	2026-02-12 20:47:56.480176+03
42	6	10	11	105-w7u32-12	\N	manual	\N	2026-02-12 20:47:56.480176+03
43	6	10	12	192.168.20.12	\N	manual	\N	2026-02-12 20:47:56.480176+03
44	6	10	13	Win10Pro (x64)	\N	manual	\N	2026-02-12 20:47:56.480176+03
45	6	10	14	KES11	\N	manual	\N	2026-02-12 20:47:56.480176+03
46	7	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-12 20:47:56.480176+03
47	7	7	9	8 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
48	7	8	8	500 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
49	7	9	8	Nec MultiSync E222W	\N	manual	\N	2026-02-12 20:47:56.480176+03
50	7	9	10	НИИСУ	\N	manual	\N	2026-02-12 20:47:56.480176+03
51	7	10	11	105-w7p64-10	\N	manual	\N	2026-02-12 20:47:56.480176+03
52	7	10	12	192.168.20.10	\N	manual	\N	2026-02-12 20:47:56.480176+03
53	7	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-12 20:47:56.480176+03
54	7	10	14	KES11	\N	manual	\N	2026-02-12 20:47:56.480176+03
77	10	9	10	МЦ.04.2	\N	manual	\N	2026-02-12 20:47:56.480176+03
81	11	6	8	Core i3-4130 3,4 ГГц	\N	manual	\N	2026-02-12 20:47:56.480176+03
82	11	7	9	8 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
83	11	8	8	500 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
84	11	9	8	Моноблок	\N	manual	\N	2026-02-12 20:47:56.480176+03
85	11	10	11	PostOhrani	\N	manual	\N	2026-02-12 20:47:56.480176+03
86	11	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-12 20:47:56.480176+03
87	11	10	14	KES11	\N	manual	\N	2026-02-12 20:47:56.480176+03
88	12	9	8	AOC 24P2Q; AOC 24P2Q	\N	manual	\N	2026-02-12 20:47:56.480176+03
89	12	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-12 20:47:56.480176+03
64	9	6	8	Core i3-540 3,07 ГГц	\N	manual	\N	2026-02-12 20:47:56.480176+03
65	9	7	9	8 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
66	9	8	8	1 ТБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
67	9	9	8	Samsung S22C200	\N	manual	\N	2026-02-12 20:47:56.480176+03
68	9	9	10	МЦ.04.2	\N	manual	\N	2026-02-12 20:47:56.480176+03
69	9	10	11	Archive-1	\N	manual	\N	2026-02-12 20:47:56.480176+03
70	9	10	12	Не в сети	\N	manual	\N	2026-02-12 20:47:56.480176+03
71	9	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-12 20:47:56.480176+03
72	9	10	14	KES12	\N	manual	\N	2026-02-12 20:47:56.480176+03
180	52	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
181	52	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
182	52	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
183	52	9	8	AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
184	52	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
185	52	10	11	118-w10p64-69	\N	manual	\N	2026-02-17 23:54:02.090047+03
186	52	10	12	10.1.4.69\n192.168.0.5	\N	manual	\N	2026-02-17 23:54:02.090047+03
187	52	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
188	52	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
189	54	6	8	Core i5-2500 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
190	54	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
191	54	8	8	1 TB	\N	manual	\N	2026-02-17 23:54:02.090047+03
192	54	9	8	Dell E2314H	\N	manual	\N	2026-02-17 23:54:02.090047+03
193	54	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
194	54	10	11	118-HorkovaLA	\N	manual	\N	2026-02-17 23:54:02.090047+03
195	54	10	12	192.168.0.6	\N	manual	\N	2026-02-17 23:54:02.090047+03
196	54	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
197	54	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
198	56	6	8	Pentium Gold G5400 3,70 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
199	56	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
200	56	8	8	HDD 80 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
201	56	9	8	NEC MultiSync EA241WM	\N	manual	\N	2026-02-17 23:54:02.090047+03
202	56	9	10	не учтен	\N	manual	\N	2026-02-17 23:54:02.090047+03
203	56	10	11	101-w10p32-79	\N	manual	\N	2026-02-17 23:54:02.090047+03
204	56	10	12	10.1.4.79	\N	manual	\N	2026-02-17 23:54:02.090047+03
205	56	10	13	Win10pro (x32)	\N	manual	\N	2026-02-17 23:54:02.090047+03
206	56	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
73	10	6	8	Core i3-4160 3,6 ГГц	\N	manual	\N	2026-02-12 20:47:56.480176+03
74	10	7	9	8 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
75	10	8	8	500 ГБ SSD; 1 ТБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
76	10	9	8	Lenovo l2250p	\N	manual	\N	2026-02-12 20:47:56.480176+03
78	10	10	11	103-W7P32-70	\N	manual	\N	2026-02-12 20:47:56.480176+03
79	10	10	12	10.1.4.70	\N	manual	\N	2026-02-12 20:47:56.480176+03
80	10	10	13	Win7 Pro (x32)	\N	manual	\N	2026-02-12 20:47:56.480176+03
214	10	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
215	60	6	8	Pentium Dual-Core E8400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
216	60	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
217	60	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
218	60	9	8	Nec MultiSync EA222W	\N	manual	\N	2026-02-17 23:54:02.090047+03
219	60	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
220	60	10	11	104-W7p64-44	\N	manual	\N	2026-02-17 23:54:02.090047+03
221	60	10	12	10.1.4.44	\N	manual	\N	2026-02-17 23:54:02.090047+03
222	60	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
223	60	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
19	4	6	8	Pentium Dual-Core E6500 2,93 ГГц	\N	manual	\N	2026-02-12 20:47:56.480176+03
20	4	7	9	4 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
21	4	8	8	300 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
22	4	9	8	Samsung SyncMaster SA200	\N	manual	\N	2026-02-12 20:47:56.480176+03
23	4	9	10	МЦ.04.2	\N	manual	\N	2026-02-12 20:47:56.480176+03
24	4	10	11	105-w7p64-11	\N	manual	\N	2026-02-12 20:47:56.480176+03
25	4	10	12	192.168.20.11	\N	manual	\N	2026-02-12 20:47:56.480176+03
26	4	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-12 20:47:56.480176+03
27	4	10	14	KES11	\N	manual	\N	2026-02-12 20:47:56.480176+03
28	5	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-12 20:47:56.480176+03
29	5	7	9	8 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
30	5	8	8	500 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
31	5	9	8	Samsung SyncMaster SA200	\N	manual	\N	2026-02-12 20:47:56.480176+03
32	5	9	10	МЦ.04.2	\N	manual	\N	2026-02-12 20:47:56.480176+03
33	5	10	11	105-W10p64-81	\N	manual	\N	2026-02-12 20:47:56.480176+03
34	5	10	12	10.1.4.81	\N	manual	\N	2026-02-12 20:47:56.480176+03
35	5	10	13	Win10pro (x64)	\N	manual	\N	2026-02-12 20:47:56.480176+03
36	5	10	14	KES11	\N	manual	\N	2026-02-12 20:47:56.480176+03
242	66	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
243	66	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
244	66	8	8	SSD 480 ГБ; HDD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
245	66	9	8	BENQ BL2201M	\N	manual	\N	2026-02-17 23:54:02.090047+03
246	66	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
247	66	10	11	105-w7u32-12	\N	manual	\N	2026-02-17 23:54:02.090047+03
248	66	10	12	192.168.20.12	\N	manual	\N	2026-02-17 23:54:02.090047+03
249	66	10	13	Win10Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
250	66	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
251	69	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
252	69	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
253	69	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
254	69	9	8	Nec MultiSync E222W	\N	manual	\N	2026-02-17 23:54:02.090047+03
255	69	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
256	69	10	11	105-w7p64-10	\N	manual	\N	2026-02-17 23:54:02.090047+03
257	69	10	12	192.168.20.10	\N	manual	\N	2026-02-17 23:54:02.090047+03
258	69	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
259	69	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
260	71	6	8	Core i5-6500 3,2 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
261	71	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
262	71	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
263	71	9	8	Samsung SyncMaster SA200	\N	manual	\N	2026-02-17 23:54:02.090047+03
264	71	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
265	71	10	11	105-w10p64-143	\N	manual	\N	2026-02-17 23:54:02.090047+03
266	71	10	12	192.168.20.16	\N	manual	\N	2026-02-17 23:54:02.090047+03
267	71	10	13	Win10Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
268	71	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
269	73	6	8	Core i5 2500 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
270	73	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
271	73	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
272	73	9	8	Nec MultiSync E224wi	\N	manual	\N	2026-02-17 23:54:02.090047+03
273	73	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
274	73	10	11	105-W10P64-243	\N	manual	\N	2026-02-17 23:54:02.090047+03
275	73	10	12	10.1.4.243	\N	manual	\N	2026-02-17 23:54:02.090047+03
276	73	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
277	73	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
278	75	6	8	Core i5-10500 3,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
279	75	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
280	75	8	8	SSD 235Gb       HDD 1Tb	\N	manual	\N	2026-02-17 23:54:02.090047+03
281	75	9	8	DELL E2313Hf	\N	manual	\N	2026-02-17 23:54:02.090047+03
282	75	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
283	75	10	11	103-w10p64-95	\N	manual	\N	2026-02-17 23:54:02.090047+03
284	75	10	12	10.1.4.95	\N	manual	\N	2026-02-17 23:54:02.090047+03
285	75	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
286	75	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
287	78	6	8	Core i5-2300 2,8 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
288	78	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
289	78	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
290	78	9	8	LG 22m35	\N	manual	\N	2026-02-17 23:54:02.090047+03
291	78	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
292	78	10	11	103-w10p64-17	\N	manual	\N	2026-02-17 23:54:02.090047+03
293	78	10	12	192.168.20.17	\N	manual	\N	2026-02-17 23:54:02.090047+03
294	78	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
295	78	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
296	81	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
297	81	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
298	81	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
299	81	9	8	ASUS 23.8" BE249QLB	\N	manual	\N	2026-02-17 23:54:02.090047+03
300	81	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
301	81	10	11	105-w10p64-46	\N	manual	\N	2026-02-17 23:54:02.090047+03
302	81	10	12	10.1.4.46	\N	manual	\N	2026-02-17 23:54:02.090047+03
303	81	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
304	81	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
305	84	6	8	Pentium Dual-Core E5700  3,25 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
306	84	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
307	84	8	8	300 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
308	84	9	8	Samsung SyncMaster 226cw	\N	manual	\N	2026-02-17 23:54:02.090047+03
309	84	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
310	84	10	11	105-w7p32-10	\N	manual	\N	2026-02-17 23:54:02.090047+03
311	84	10	12	10.10.10.10	\N	manual	\N	2026-02-17 23:54:02.090047+03
312	84	10	13	Win 7 pro (x32)	\N	manual	\N	2026-02-17 23:54:02.090047+03
313	84	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
55	8	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-12 20:47:56.480176+03
56	8	7	9	16 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
57	8	8	8	1 Тб	\N	manual	\N	2026-02-12 20:47:56.480176+03
58	8	9	8	Philips 23.8" 241B8QJEB	\N	manual	\N	2026-02-12 20:47:56.480176+03
59	8	9	10	МЦ.04	\N	manual	\N	2026-02-12 20:47:56.480176+03
60	8	10	11	105-w10p64-47	\N	manual	\N	2026-02-12 20:47:56.480176+03
61	8	10	12	10.1.4.47	\N	manual	\N	2026-02-12 20:47:56.480176+03
62	8	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-12 20:47:56.480176+03
63	8	10	14	KES11	\N	manual	\N	2026-02-12 20:47:56.480176+03
323	90	6	8	Core i3-540 3,07 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
324	90	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
325	90	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
326	90	9	8	Nec MultiSync E222W	\N	manual	\N	2026-02-17 23:54:02.090047+03
327	90	9	10	МЦ.04.1	\N	manual	\N	2026-02-17 23:54:02.090047+03
328	90	10	11	105-w10p64-31	\N	manual	\N	2026-02-17 23:54:02.090047+03
329	90	10	12	10.1.4.31	\N	manual	\N	2026-02-17 23:54:02.090047+03
330	90	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
331	90	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
332	92	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
333	92	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
334	92	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
335	92	9	8	Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
336	92	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
337	92	10	11	ohr-W10Px64-1	\N	manual	\N	2026-02-17 23:54:02.090047+03
338	92	10	12	не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
339	92	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
340	94	6	8	Core i3-4130 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
341	94	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
342	94	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
343	94	9	8	Моноблок	\N	manual	\N	2026-02-17 23:54:02.090047+03
344	94	10	11	PostOhrani	\N	manual	\N	2026-02-17 23:54:02.090047+03
345	94	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
346	94	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
347	95	9	8	AOC 24P2Q; AOC 24P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
348	95	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
90	13	6	8	Core i5-3330S 2,7 ГГц	\N	manual	\N	2026-02-12 20:47:56.480176+03
91	13	7	9	8 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
92	13	8	8	500 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
93	13	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-12 20:47:56.480176+03
94	13	10	14	KES11	\N	manual	\N	2026-02-12 20:47:56.480176+03
354	97	6	8	AMD Athlon 64X2Dual Core 2,90 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
355	97	7	9	2 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
356	97	8	8	250 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
357	97	9	8	Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
358	97	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
359	97	10	11	501d-W7Ux32-2	\N	manual	\N	2026-02-17 23:54:02.090047+03
360	97	10	12	192.168.0.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
361	97	10	13	Win7 Ultimate (x32)	\N	manual	\N	2026-02-17 23:54:02.090047+03
362	97	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
363	99	6	8	Core i3-2100 3,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
364	99	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
365	99	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
366	99	9	8	Samsung SyncMaster P2270	\N	manual	\N	2026-02-17 23:54:02.090047+03
367	99	9	10	99036	\N	manual	\N	2026-02-17 23:54:02.090047+03
368	99	10	11	106-W7P32-223	\N	manual	\N	2026-02-17 23:54:02.090047+03
369	99	10	12	10.2.2.223	\N	manual	\N	2026-02-17 23:54:02.090047+03
370	99	10	13	Win10Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
371	99	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
372	101	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
373	101	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
374	101	8	8	SSD -256 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
375	101	9	8	Lenovo L27e-30 27"	\N	manual	\N	2026-02-17 23:54:02.090047+03
376	101	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
377	101	10	11	106-w10p64-240	\N	manual	\N	2026-02-17 23:54:02.090047+03
378	101	10	12	10.2.2.240	\N	manual	\N	2026-02-17 23:54:02.090047+03
379	101	10	13	Win10Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
380	101	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
381	103	6	8	Core i5-3470 3,2 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
382	103	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
383	103	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
384	103	9	8	Nec MultiSync EA221WMe	\N	manual	\N	2026-02-17 23:54:02.090047+03
385	103	9	10	МЦ.04.1	\N	manual	\N	2026-02-17 23:54:02.090047+03
386	103	10	11	106B-W10P64-239	\N	manual	\N	2026-02-17 23:54:02.090047+03
387	103	10	12	10.2.2.239	\N	manual	\N	2026-02-17 23:54:02.090047+03
388	103	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
389	103	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
390	106	6	8	Core i5-10400 2,90 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
391	106	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
392	106	8	8	HDD - 1 TB	\N	manual	\N	2026-02-17 23:54:02.090047+03
393	106	9	8	LG Flatron L1934S	\N	manual	\N	2026-02-17 23:54:02.090047+03
394	106	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
395	106	10	11	Desktop-VHQNLO1	\N	manual	\N	2026-02-17 23:54:02.090047+03
396	106	10	12	не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
397	106	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
398	106	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
399	108	6	8	Core i3-10105 3,70 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
400	108	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
401	108	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
402	108	9	8	Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
403	108	10	11	108-w10p64	\N	manual	\N	2026-02-17 23:54:02.090047+03
404	108	10	12	Не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
405	108	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
406	108	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
407	111	6	8	Core i3-2100 3,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
408	111	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
409	111	8	8	SSD 480 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
410	111	9	8	ASUS PA248Q; ASUS PA248Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
411	111	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
412	111	10	11	110a-w10p64-119	\N	manual	\N	2026-02-17 23:54:02.090047+03
413	111	10	12	10.1.4.119	\N	manual	\N	2026-02-17 23:54:02.090047+03
414	111	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
415	111	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
416	115	6	8	Core i5-6500 3,2 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
417	115	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
418	115	8	8	SSD 120 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
419	115	9	8	Nec MultiSync AS221WM	\N	manual	\N	2026-02-17 23:54:02.090047+03
420	115	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
421	115	10	11	110-W10p64-125	\N	manual	\N	2026-02-17 23:54:02.090047+03
422	115	10	12	10.1.4.125	\N	manual	\N	2026-02-17 23:54:02.090047+03
423	115	10	13	Win10Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
424	117	6	8	Core i5-6200U 2,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
425	117	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
426	117	8	8	SSD 250 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
427	117	9	8	13,3"	\N	manual	\N	2026-02-17 23:54:02.090047+03
428	117	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
429	117	10	11	DESKTOP-SSHGK2I	\N	manual	\N	2026-02-17 23:54:02.090047+03
430	117	10	12	10.1.4.118	\N	manual	\N	2026-02-17 23:54:02.090047+03
431	117	10	13	Windows 10(x64) HE SL	\N	manual	\N	2026-02-17 23:54:02.090047+03
432	117	10	14	Windows Defender	\N	manual	\N	2026-02-17 23:54:02.090047+03
433	119	6	8	Core i5-7500 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
434	119	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
435	119	8	8	256 ГБ SSD; 2 ТБ HDD	\N	manual	\N	2026-02-17 23:54:02.090047+03
436	119	9	8	BENQ GW2780 27"	\N	manual	\N	2026-02-17 23:54:02.090047+03
437	119	9	10	МОЛ Данилкин	\N	manual	\N	2026-02-17 23:54:02.090047+03
438	119	10	11	109-W10p64-197	\N	manual	\N	2026-02-17 23:54:02.090047+03
439	119	10	12	10.1.4.197	\N	manual	\N	2026-02-17 23:54:02.090047+03
440	119	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
441	119	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
442	122	6	8	Core i3-2100 3,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
443	122	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
444	122	8	8	250 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
445	122	9	8	Nec MultiSync E231W	\N	manual	\N	2026-02-17 23:54:02.090047+03
446	122	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
447	122	10	11	109b-w7p64-110	\N	manual	\N	2026-02-17 23:54:02.090047+03
448	122	10	12	10.1.4.110	\N	manual	\N	2026-02-17 23:54:02.090047+03
449	122	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
450	122	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
451	124	6	8	Core i5-7500 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
452	124	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
453	124	8	8	256 ГБ SSD; 2 ТБ HDD	\N	manual	\N	2026-02-17 23:54:02.090047+03
454	124	9	8	BENQ GW2780 27"	\N	manual	\N	2026-02-17 23:54:02.090047+03
455	124	9	10	МОЛ Данилкин	\N	manual	\N	2026-02-17 23:54:02.090047+03
456	124	10	11	109-W10p64-195	\N	manual	\N	2026-02-17 23:54:02.090047+03
457	124	10	12	10.1.4.195	\N	manual	\N	2026-02-17 23:54:02.090047+03
458	124	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
459	124	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
460	127	6	8	Core i5-7500 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
461	127	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
462	127	8	8	256 ГБ SSD; 2 ТБ HDD	\N	manual	\N	2026-02-17 23:54:02.090047+03
463	127	9	8	BENQ GW2780 27"	\N	manual	\N	2026-02-17 23:54:02.090047+03
464	127	9	10	МОЛ Данилкин	\N	manual	\N	2026-02-17 23:54:02.090047+03
465	127	10	11	109-W10p64-196	\N	manual	\N	2026-02-17 23:54:02.090047+03
466	127	10	12	10.1.4.196	\N	manual	\N	2026-02-17 23:54:02.090047+03
467	127	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
468	127	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
469	130	6	8	Core i5-6600 3,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
470	130	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
471	130	8	8	SSD 120 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
472	130	9	8	BENQ BL2710	\N	manual	\N	2026-02-17 23:54:02.090047+03
473	130	9	10	БП-001306 (Информ. - 000190)	\N	manual	\N	2026-02-17 23:54:02.090047+03
474	130	10	11	112-SENICHKINPN	\N	manual	\N	2026-02-17 23:54:02.090047+03
475	130	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
476	130	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
477	130	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
478	132	6	8	Core i7-7700HQ  2,8 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
479	132	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
480	132	8	8	SSD 120 ГБ; HDD 2 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
481	132	9	8	17"	\N	manual	\N	2026-02-17 23:54:02.090047+03
482	132	10	11	SENICHKIN-NOTE	\N	manual	\N	2026-02-17 23:54:02.090047+03
483	132	10	12	Не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
484	132	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
485	134	6	8	Core i7-3770 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
486	134	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
487	134	8	8	SSD 250 ГБ; HDD 2 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
488	134	9	8	Dell P2720DC	\N	manual	\N	2026-02-17 23:54:02.090047+03
489	134	9	10	МЦ.04 (001463)	\N	manual	\N	2026-02-17 23:54:02.090047+03
490	134	10	11	112-MITROFANOVA	\N	manual	\N	2026-02-17 23:54:02.090047+03
491	134	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
492	134	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
493	134	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
494	136	6	8	Core i3-3225 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
495	136	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
496	136	8	8	SSD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
497	136	9	8	BENQ GW2760S	\N	manual	\N	2026-02-17 23:54:02.090047+03
498	136	9	10	МЦ.04 (001197)	\N	manual	\N	2026-02-17 23:54:02.090047+03
499	136	10	11	807-MITROFANOVA	\N	manual	\N	2026-02-17 23:54:02.090047+03
500	136	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
501	136	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
502	136	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
503	138	6	8	Core i7-7740X 4,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
504	138	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
505	138	8	8	SSD 500 ГБ; HDD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
506	138	9	8	BENQ GW2765; BENQ BL2710	\N	manual	\N	2026-02-17 23:54:02.090047+03
507	138	9	10	БП-001302 (Информ. - 000143)\nБП-001305 (Информ. - 000189)	\N	manual	\N	2026-02-17 23:54:02.090047+03
508	138	10	11	112-ILYUKHINAVA	\N	manual	\N	2026-02-17 23:54:02.090047+03
509	138	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
510	138	10	13	Win11pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
511	138	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
512	142	6	8	Core i7-7740X 4,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
513	142	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
514	142	8	8	SSD 500 ГБ; HDD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
515	142	9	8	Dell P2720DC; BENQ BL2710	\N	manual	\N	2026-02-17 23:54:02.090047+03
516	142	9	10	МЦ.04 (001470)\nМЦ.04 (001015)	\N	manual	\N	2026-02-17 23:54:02.090047+03
517	142	10	11	112-BONDAREVDV	\N	manual	\N	2026-02-17 23:54:02.090047+03
518	142	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
519	142	10	13	Win11pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
520	142	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
521	145	6	8	Core i7-6740HQ 2,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
522	145	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
523	145	8	8	SSD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
524	145	9	8	17"	\N	manual	\N	2026-02-17 23:54:02.090047+03
525	145	10	11	BONDAREV-Noot	\N	manual	\N	2026-02-17 23:54:02.090047+03
526	145	10	12	Не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
527	145	10	13	Win11pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
528	147	6	8	Core i5-9400 2,9 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
529	147	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
530	147	8	8	SSD 250 ГБ; HDD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
531	147	9	8	Dell P2720DC	\N	manual	\N	2026-02-17 23:54:02.090047+03
532	147	9	10	МЦ.04 (001469)	\N	manual	\N	2026-02-17 23:54:02.090047+03
533	147	10	11	112-BUKHTEEVAKI	\N	manual	\N	2026-02-17 23:54:02.090047+03
534	147	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
535	147	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
536	147	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
537	149	6	8	Core i5-12500 3,00 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
538	149	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
539	149	8	8	SSD 512 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
540	149	9	8	MB27V13FS51	\N	manual	\N	2026-02-17 23:54:02.090047+03
541	149	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
542	149	10	11	112-Fomin	\N	manual	\N	2026-02-17 23:54:02.090047+03
543	149	10	12	DHCP (VLAN 207)	\N	manual	\N	2026-02-17 23:54:02.090047+03
544	149	10	13	Astra Linux 1.8  Special Edition	\N	manual	\N	2026-02-17 23:54:02.090047+03
545	149	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
546	151	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
547	151	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
548	151	8	8	SSD 250 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
549	151	9	8	MB27V13FS51; MB27V13FS51	\N	manual	\N	2026-02-17 23:54:02.090047+03
550	151	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
551	151	10	11	112-AkzhigitovaAR	\N	manual	\N	2026-02-17 23:54:02.090047+03
552	151	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
553	151	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
554	151	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
555	154	6	8	Core i5-12500  3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
556	154	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
557	154	8	8	SSD 512 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
558	154	9	8	Samsung 27" C27F390FHI	\N	manual	\N	2026-02-17 23:54:02.090047+03
559	154	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
560	154	10	11	112-varlamovava	\N	manual	\N	2026-02-17 23:54:02.090047+03
561	154	10	12	DHCP (VLAN 207)	\N	manual	\N	2026-02-17 23:54:02.090047+03
562	154	10	13	Astra Linux Special Edition 1.7	\N	manual	\N	2026-02-17 23:54:02.090047+03
563	154	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
564	157	6	8	Core i5-12500  3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
565	157	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
566	157	8	8	SSD 512 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
567	157	9	8	MB27V13FS51	\N	manual	\N	2026-02-17 23:54:02.090047+03
568	157	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
569	157	10	11	112-Leontevgy	\N	manual	\N	2026-02-17 23:54:02.090047+03
570	157	10	12	DHCP (VLAN 207)	\N	manual	\N	2026-02-17 23:54:02.090047+03
571	157	10	13	Astra Linux 1.8  Special Edition	\N	manual	\N	2026-02-17 23:54:02.090047+03
572	157	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
573	160	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
574	160	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
575	160	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
576	160	9	8	AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
577	160	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
578	160	10	11	113A-BLANUTSAOA	\N	manual	\N	2026-02-17 23:54:02.090047+03
579	160	10	12	DHCP (VLAN 208) vniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
580	160	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
581	160	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
582	163	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
583	163	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
584	163	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
585	163	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
586	163	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
587	163	10	11	113a-nevidanchukis	\N	manual	\N	2026-02-17 23:54:02.090047+03
588	163	10	12	DHCP (VLAN 208)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
589	163	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
590	163	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
591	166	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
592	166	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
593	166	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
594	166	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
595	166	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
596	166	10	11	113A-PODLESNYOL	\N	manual	\N	2026-02-17 23:54:02.090047+03
597	166	10	12	DHCP (VLAN 208)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
598	166	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
599	166	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
600	169	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
601	169	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
602	169	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
603	169	9	8	AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
604	169	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
605	169	10	11	113A-YALYMOVAAA	\N	manual	\N	2026-02-17 23:54:02.090047+03
606	169	10	12	DHCP (VLAN 208)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
607	169	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
608	169	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
609	172	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
610	172	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
611	172	8	8	256 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
612	172	9	8	Philips 273V7QJAB; Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
613	172	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
614	172	10	11	113v-RudelevAA	\N	manual	\N	2026-02-17 23:54:02.090047+03
615	172	10	12	DHCP (VLAN 207) vniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
616	172	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
617	172	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
618	176	6	8	Core i5-12500 3,00 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
619	176	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
620	176	8	8	SSD 512 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
621	176	9	8	MB27V13FS51; Asus 27" MX279H	\N	manual	\N	2026-02-17 23:54:02.090047+03
622	176	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
623	176	10	11	113-skrebkovas	\N	manual	\N	2026-02-17 23:54:02.090047+03
624	176	10	12	DHCP (VLAN 207)	\N	manual	\N	2026-02-17 23:54:02.090047+03
625	176	10	13	Astra Linux Special Edition 1.8	\N	manual	\N	2026-02-17 23:54:02.090047+03
626	176	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
627	179	6	8	Core i5-12500 3,00 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
628	179	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
629	179	8	8	SSD 512 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
630	179	9	8	MB27V13FS51	\N	manual	\N	2026-02-17 23:54:02.090047+03
631	179	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
632	179	10	11	113v-yamanovaea	\N	manual	\N	2026-02-17 23:54:02.090047+03
633	179	10	12	DHCP (VLAN 207)	\N	manual	\N	2026-02-17 23:54:02.090047+03
634	179	10	13	Astra Linux 1.8 Special Edition	\N	manual	\N	2026-02-17 23:54:02.090047+03
635	179	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
636	182	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
637	182	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
638	182	8	8	SSD -256 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
639	182	9	8	AOC 27P2Q; AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
640	182	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
641	182	10	11	113g-GlukhovskayaEN	\N	manual	\N	2026-02-17 23:54:02.090047+03
642	182	10	12	DHCP (VLAN 207) vniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
643	182	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
644	182	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
645	186	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
646	186	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
647	186	8	8	SSD 480 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
648	186	9	8	MB27V13FS51; Nec Multisync EA222WMe	\N	manual	\N	2026-02-17 23:54:02.090047+03
649	186	9	10	МЦ.04\nМЦ.04.1	\N	manual	\N	2026-02-17 23:54:02.090047+03
650	186	10	11	114-w10p64-49	\N	manual	\N	2026-02-17 23:54:02.090047+03
651	186	10	12	10.10.10.49	\N	manual	\N	2026-02-17 23:54:02.090047+03
652	186	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
653	186	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
654	190	6	8	Core i5-12500 3,00 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
655	190	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
656	190	8	8	SSD 512 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
657	190	9	8	Benq BL2405	\N	manual	\N	2026-02-17 23:54:02.090047+03
658	190	10	11	114-astra-52	\N	manual	\N	2026-02-17 23:54:02.090047+03
659	190	10	12	10.10.10.52	\N	manual	\N	2026-02-17 23:54:02.090047+03
660	190	10	13	Astra Linux 1.8 Special Edition	\N	manual	\N	2026-02-17 23:54:02.090047+03
661	190	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
662	193	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
663	193	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
664	193	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
665	193	9	8	Benq 32" EW3270ZL	\N	manual	\N	2026-02-17 23:54:02.090047+03
666	193	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
667	193	10	11	115-MolostovskayaOB	\N	manual	\N	2026-02-17 23:54:02.090047+03
668	193	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
669	193	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
670	193	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
671	196	6	8	Дубликатор дисков Power Digital (CUBE-2) инв. № 99036	\N	manual	\N	2026-02-17 23:54:02.090047+03
672	197	6	8	Core i7-13700KF 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
673	197	7	9	32 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
674	197	8	8	SSD 1ТБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
675	197	9	8	Acer XV322QK	\N	manual	\N	2026-02-17 23:54:02.090047+03
676	197	9	10	МОЛ-Карлов С.Н.	\N	manual	\N	2026-02-17 23:54:02.090047+03
677	197	10	11	115-LogachevaAV	\N	manual	\N	2026-02-17 23:54:02.090047+03
678	197	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
679	197	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
680	197	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
681	200	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
682	200	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
683	200	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
684	200	9	8	Benq 32" EW3270ZL	\N	manual	\N	2026-02-17 23:54:02.090047+03
685	200	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
686	200	10	11	115-KutilinaKE	\N	manual	\N	2026-02-17 23:54:02.090047+03
687	200	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
688	200	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
689	200	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
690	203	6	8	Core i7-13700KF 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
691	203	7	9	32 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
692	203	8	8	SSD 1ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
693	203	9	8	PHL346E2LA	\N	manual	\N	2026-02-17 23:54:02.090047+03
694	203	9	10	МОЛ-Карлов С.Н.	\N	manual	\N	2026-02-17 23:54:02.090047+03
695	203	10	11	115-SankinAS	\N	manual	\N	2026-02-17 23:54:02.090047+03
696	203	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
697	203	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
698	203	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
699	206	6	8	Core i5-12500 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
700	206	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
701	206	8	8	SSD 1ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
702	206	9	8	Philips 345E2AE	\N	manual	\N	2026-02-17 23:54:02.090047+03
703	206	9	10	МОЛ-Карлов С.Н.	\N	manual	\N	2026-02-17 23:54:02.090047+03
704	206	10	11	115-2-SankinAS	\N	manual	\N	2026-02-17 23:54:02.090047+03
705	206	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
706	206	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
707	206	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
708	208	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
709	208	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
710	208	8	8	HDD - 1 ТБ; SSD - 240 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
711	208	9	8	AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
712	208	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
713	208	10	11	115-KulakovaAV	\N	manual	\N	2026-02-17 23:54:02.090047+03
714	208	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
715	208	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
716	208	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
717	211	6	8	Core i7-7700К 4,5 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
718	211	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
719	211	8	8	240 ГБ (SSD); 2 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
720	211	9	8	Benq BL2405	\N	manual	\N	2026-02-17 23:54:02.090047+03
721	211	10	11	115-KucherukSA	\N	manual	\N	2026-02-17 23:54:02.090047+03
722	211	10	12	DHCP (VLAN 207)	\N	manual	\N	2026-02-17 23:54:02.090047+03
723	211	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
724	211	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
725	213	6	8	Core2Duo E8400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
726	213	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
727	213	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
728	213	9	8	Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
729	213	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
730	213	10	11	121-Computer	\N	manual	\N	2026-02-17 23:54:02.090047+03
731	213	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
732	213	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
733	213	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
734	214	9	8	15"	\N	manual	\N	2026-02-17 23:54:02.090047+03
735	216	6	8	Core i3-10100,3,6GHz	\N	manual	\N	2026-02-17 23:54:02.090047+03
736	216	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
737	216	8	8	SSD 250 Гб	\N	manual	\N	2026-02-17 23:54:02.090047+03
738	216	9	8	Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
739	216	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
740	216	10	11	305-w10p64-1	\N	manual	\N	2026-02-17 23:54:02.090047+03
741	216	10	12	DHCP (VLAN 207)\n192.168.207.254/24	\N	manual	\N	2026-02-17 23:54:02.090047+03
742	216	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
743	216	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
744	218	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
745	218	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
746	218	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
747	218	9	8	Iiyama ProLite XB3270QS-B1	\N	manual	\N	2026-02-17 23:54:02.090047+03
748	218	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
749	218	10	11	303-w10p64-36	\N	manual	\N	2026-02-17 23:54:02.090047+03
750	218	10	12	10.2.2.36	\N	manual	\N	2026-02-17 23:54:02.090047+03
751	218	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
752	218	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
753	220	6	8	Core i5-4670 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
754	220	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
755	220	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
756	220	9	8	Benq 32" EW3270ZL	\N	manual	\N	2026-02-17 23:54:02.090047+03
757	220	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
758	220	10	11	303-W10P64-39	\N	manual	\N	2026-02-17 23:54:02.090047+03
759	220	10	12	10.2.2.39	\N	manual	\N	2026-02-17 23:54:02.090047+03
760	220	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
761	220	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
762	223	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
763	223	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
764	223	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
765	223	9	8	Iiyama ProLite XB3270QS-B1	\N	manual	\N	2026-02-17 23:54:02.090047+03
766	223	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
767	223	10	11	303-w10p64-38	\N	manual	\N	2026-02-17 23:54:02.090047+03
768	223	10	12	10.2.2.38	\N	manual	\N	2026-02-17 23:54:02.090047+03
769	223	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
770	223	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
771	226	9	8	Iiyama ProLite XB3270QS-B1	\N	manual	\N	2026-02-17 23:54:02.090047+03
772	226	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
773	228	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
774	228	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
775	228	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
776	228	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
777	228	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
778	228	10	11	303-w10p64-35	\N	manual	\N	2026-02-17 23:54:02.090047+03
779	228	10	12	10.2.2.35	\N	manual	\N	2026-02-17 23:54:02.090047+03
780	228	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
781	228	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
782	231	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
783	231	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
784	231	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
785	231	9	8	Iiyama ProLite XB3270QS-B1; Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
786	231	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
787	231	10	11	303-w10p64-96	\N	manual	\N	2026-02-17 23:54:02.090047+03
788	231	10	12	10.2.2.96	\N	manual	\N	2026-02-17 23:54:02.090047+03
789	231	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
790	231	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
791	235	6	8	Core i3-4160 3,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
792	235	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
793	235	8	8	SSD 250 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
794	235	9	8	AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
795	235	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
796	235	10	11	303-w10p64-175	\N	manual	\N	2026-02-17 23:54:02.090047+03
797	235	10	12	10.2.2.175	\N	manual	\N	2026-02-17 23:54:02.090047+03
798	235	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
799	235	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
800	238	6	8	Core i7-12700H 4,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
801	238	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
802	238	8	8	SSD 512 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
803	238	9	8	16"	\N	manual	\N	2026-02-17 23:54:02.090047+03
804	238	10	13	Win11 Home	\N	manual	\N	2026-02-17 23:54:02.090047+03
805	240	6	8	Core i7-12700H 4,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
806	240	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
807	240	8	8	SSD 512 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
808	240	9	8	16"	\N	manual	\N	2026-02-17 23:54:02.090047+03
809	240	10	13	Win11 Home	\N	manual	\N	2026-02-17 23:54:02.090047+03
810	242	6	8	Intel® Core™ i7-8650U CPU @1.90 GHz 2.11 GHz	\N	manual	\N	2026-02-17 23:54:02.090047+03
811	242	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
812	242	8	8	SSD 512 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
813	242	10	11	DESKTOP-D5A6CSB	\N	manual	\N	2026-02-17 23:54:02.090047+03
814	242	10	12	10.10.10.36	\N	manual	\N	2026-02-17 23:54:02.090047+03
815	242	10	13	Win 11 Pro	\N	manual	\N	2026-02-17 23:54:02.090047+03
816	243	6	8	Core i7-12700F 2,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
817	243	7	9	32 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
818	243	8	8	SSD 512ГБ; HDD - 2 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
819	243	9	8	Philips 27E1N5600AE	\N	manual	\N	2026-02-17 23:54:02.090047+03
820	243	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
821	243	10	11	305-STUDENT-1	\N	manual	\N	2026-02-17 23:54:02.090047+03
822	243	10	12	DHCP (VLAN 215)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
823	243	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
824	243	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
825	245	6	8	Core i7-12700F 2,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
826	245	7	9	32 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
827	245	8	8	SSD 512ГБ; HDD - 2 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
828	245	9	8	Philips 27E1N5600AE	\N	manual	\N	2026-02-17 23:54:02.090047+03
829	245	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
830	245	10	11	305-STUDENT-2	\N	manual	\N	2026-02-17 23:54:02.090047+03
831	245	10	12	DHCP (VLAN 215)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
832	245	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
833	245	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
834	247	6	8	Core i7-12700F 2,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
835	247	7	9	32 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
836	247	8	8	SSD 512ГБ; HDD - 2 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
837	247	9	8	Philips 27E1N5600AE	\N	manual	\N	2026-02-17 23:54:02.090047+03
838	247	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
839	247	10	11	305-STUDENT-3	\N	manual	\N	2026-02-17 23:54:02.090047+03
840	247	10	12	DHCP (VLAN 215)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
841	247	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
842	247	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
843	249	6	8	Core i7-12700F 2,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
844	249	7	9	32 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
845	249	8	8	SSD 512ГБ; HDD - 2 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
846	249	9	8	Philips 27E1N5600AE	\N	manual	\N	2026-02-17 23:54:02.090047+03
847	249	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
848	249	10	11	305-STUDENT-4	\N	manual	\N	2026-02-17 23:54:02.090047+03
849	249	10	12	DHCP (VLAN 215)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
850	249	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
851	249	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
852	251	6	8	Core i7-12700F 2,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
853	251	7	9	32 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
854	251	8	8	SSD 512ГБ; HDD - 2 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
855	251	9	8	Philips 27E1N5600AE	\N	manual	\N	2026-02-17 23:54:02.090047+03
856	251	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
857	251	10	11	305-STUDENT-5	\N	manual	\N	2026-02-17 23:54:02.090047+03
858	251	10	12	DHCP (VLAN 215)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
859	251	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
860	251	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
861	253	6	8	Core i7-12700F 2,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
862	253	7	9	32 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
863	253	8	8	SSD 512ГБ; HDD - 2 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
864	253	9	8	Philips 27E1N5600AE	\N	manual	\N	2026-02-17 23:54:02.090047+03
865	253	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
866	253	10	11	305-STUDENT-6	\N	manual	\N	2026-02-17 23:54:02.090047+03
867	253	10	12	DHCP (VLAN 215)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
868	253	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
869	253	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
870	255	6	8	Core i7-12700F 2,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
871	255	7	9	32 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
872	255	8	8	SSD 512ГБ; HDD - 2 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
873	255	9	8	Philips 27E1N5600AE	\N	manual	\N	2026-02-17 23:54:02.090047+03
874	255	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
875	255	10	11	305-STUDENT-7	\N	manual	\N	2026-02-17 23:54:02.090047+03
876	255	10	12	DHCP (VLAN 215)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
877	255	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
878	255	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
879	257	6	8	Core i7-12700F 2,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
880	257	7	9	32 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
881	257	8	8	SSD 512ГБ; HDD - 2 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
882	257	9	8	Philips 27E1N5600AE	\N	manual	\N	2026-02-17 23:54:02.090047+03
883	257	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
884	257	10	11	305-STUDENT-8	\N	manual	\N	2026-02-17 23:54:02.090047+03
885	257	10	12	DHCP (VLAN 215)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
886	257	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
887	257	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
888	259	6	8	Core i7-12700F 2,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
889	259	7	9	32 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
890	259	8	8	SSD 512ГБ; HDD - 2 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
891	259	9	8	Philips 27E1N5600AE	\N	manual	\N	2026-02-17 23:54:02.090047+03
892	259	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
893	259	10	11	305-STUDENT-9	\N	manual	\N	2026-02-17 23:54:02.090047+03
894	259	10	12	DHCP (VLAN 215)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
895	259	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
896	259	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
897	261	6	8	Core i7-12700F 2,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
898	261	7	9	32 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
899	261	8	8	SSD 512ГБ; HDD - 2 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
900	261	9	8	Philips 27E1N5600AE	\N	manual	\N	2026-02-17 23:54:02.090047+03
901	261	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
902	261	10	11	305-STUDENT-10	\N	manual	\N	2026-02-17 23:54:02.090047+03
903	261	10	12	DHCP (VLAN 215)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
904	261	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
905	261	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
906	263	6	8	Core i7-12700F 2,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
907	263	7	9	32 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
908	263	8	8	SSD 512ГБ; HDD - 2 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
909	263	9	8	Philips 27E1N5600AE	\N	manual	\N	2026-02-17 23:54:02.090047+03
910	263	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
911	263	10	11	305-STUDENT-11	\N	manual	\N	2026-02-17 23:54:02.090047+03
912	263	10	12	DHCP (VLAN 215)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
913	263	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
914	263	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
915	265	6	8	Core i7-12700F 2,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
916	265	7	9	32 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
917	265	8	8	SSD 512ГБ; HDD - 2 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
918	265	9	8	Philips 27E1N5600AE	\N	manual	\N	2026-02-17 23:54:02.090047+03
919	265	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
920	265	10	11	305-STUDENT-12	\N	manual	\N	2026-02-17 23:54:02.090047+03
921	265	10	12	DHCP (VLAN 215)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
922	265	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
923	265	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
924	267	6	8	Core i7-12700F 2,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
925	267	7	9	32 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
926	267	8	8	SSD 512ГБ; HDD - 2 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
927	267	9	8	Philips 27E1N5600AE	\N	manual	\N	2026-02-17 23:54:02.090047+03
928	267	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
929	267	10	11	305-STUDENT-13	\N	manual	\N	2026-02-17 23:54:02.090047+03
930	267	10	12	DHCP (VLAN 215)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
931	267	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
932	267	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
933	269	6	8	Core i7-12700F 2,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
934	269	7	9	32 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
935	269	8	8	SSD 512ГБ; HDD - 2 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
936	269	9	8	Philips 27E1N5600AE	\N	manual	\N	2026-02-17 23:54:02.090047+03
937	269	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
938	269	10	11	305-STUDENT-14	\N	manual	\N	2026-02-17 23:54:02.090047+03
939	269	10	12	DHCP (VLAN 215)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
940	269	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
941	269	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
942	271	6	8	Core i7-12700F 2,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
943	271	7	9	32 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
944	271	8	8	SSD 512ГБ; HDD - 2 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
945	271	9	8	Philips 27E1N5600AE	\N	manual	\N	2026-02-17 23:54:02.090047+03
946	271	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
947	271	10	11	305-STUDENT-15	\N	manual	\N	2026-02-17 23:54:02.090047+03
948	271	10	12	DHCP (VLAN 215)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
949	271	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
950	271	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
951	273	6	8	Core i7-12700F 2,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
952	273	7	9	32 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
953	273	8	8	SSD 512ГБ; HDD - 2 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
954	273	9	8	Philips 27E1N5600AE	\N	manual	\N	2026-02-17 23:54:02.090047+03
955	273	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
956	273	10	11	305-TEACHER	\N	manual	\N	2026-02-17 23:54:02.090047+03
957	273	10	12	DHCP (VLAN 215)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
958	273	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
959	273	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
1202	351	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
960	275	9	8	Интерактивная панель InFocus INF9850	\N	manual	\N	2026-02-17 23:54:02.090047+03
961	279	6	8	Core i7-6700 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
962	279	7	9	24 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
963	279	8	8	SSD 256 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
964	279	9	8	Philips 273V7QJAB; Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
965	279	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
966	279	10	11	306-KulakovDD	\N	manual	\N	2026-02-17 23:54:02.090047+03
967	279	10	12	DHCP (VLAN 206)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
968	279	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
969	279	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
970	282	6	8	Core i5-10210U 2,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
971	282	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
972	282	8	8	SSD -500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
973	282	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
974	283	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
975	283	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
976	283	8	8	SSD -256 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
977	283	9	8	Philips 273V7QJAB; Philips 234E5QSB 23"	\N	manual	\N	2026-02-17 23:54:02.090047+03
978	283	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
979	283	10	11	306-KokorevRA	\N	manual	\N	2026-02-17 23:54:02.090047+03
980	283	10	12	DHCP (VLAN 206)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
981	283	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
982	283	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
983	286	6	8	Core i5-3550 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
984	286	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
985	286	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
986	286	9	8	Philips 273V7QJAB; Dell E2314Hf	\N	manual	\N	2026-02-17 23:54:02.090047+03
987	286	9	10	МЦ.04\nМЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
988	286	10	11	306-KaluginII	\N	manual	\N	2026-02-17 23:54:02.090047+03
989	286	10	12	DHCP (VLAN 206)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
990	286	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
991	286	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
992	289	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
993	289	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
994	289	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
995	289	9	8	AOC 27P2Q; AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
996	289	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
997	289	10	11	306-RevvaRR	\N	manual	\N	2026-02-17 23:54:02.090047+03
998	289	10	12	DHCP (VLAN 206)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
999	289	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1000	289	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
1001	293	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1002	293	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1003	293	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
1004	293	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
1005	293	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1006	293	10	11	KuzinaOA	\N	manual	\N	2026-02-17 23:54:02.090047+03
1007	293	10	12	оптика	\N	manual	\N	2026-02-17 23:54:02.090047+03
1008	293	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1009	293	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1010	296	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1011	296	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1012	296	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
1013	296	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
1014	296	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1015	296	10	11	PtushkinaNG	\N	manual	\N	2026-02-17 23:54:02.090047+03
1016	296	10	12	оптика\n192.168.10.132	\N	manual	\N	2026-02-17 23:54:02.090047+03
1017	296	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1018	296	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1019	299	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1020	299	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1021	299	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1022	299	9	8	Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
1023	299	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1024	299	10	11	307-Computer	\N	manual	\N	2026-02-17 23:54:02.090047+03
1025	299	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1026	299	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1027	299	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
1028	302	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1029	302	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1030	302	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
1031	302	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
1032	302	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1033	302	10	11	IvanovaGP	\N	manual	\N	2026-02-17 23:54:02.090047+03
1034	302	10	12	оптика\n192.168.10.253	\N	manual	\N	2026-02-17 23:54:02.090047+03
1035	302	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1036	302	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1037	305	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1038	305	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1039	305	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
1040	305	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
1041	305	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1042	305	10	11	VasilievaTN	\N	manual	\N	2026-02-17 23:54:02.090047+03
1043	305	10	12	оптика\n192.168.10.66	\N	manual	\N	2026-02-17 23:54:02.090047+03
1044	305	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1045	305	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1046	308	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1047	308	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1048	308	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
1049	308	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
1050	308	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1051	308	10	11	307-KoptevAI	\N	manual	\N	2026-02-17 23:54:02.090047+03
1052	308	10	12	оптика (без IP)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1053	308	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1054	308	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
1055	311	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1056	311	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1057	311	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
1058	311	9	8	Philips 234E5QSB 23"	\N	manual	\N	2026-02-17 23:54:02.090047+03
1059	311	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1060	311	10	11	307-PopovichIV	\N	manual	\N	2026-02-17 23:54:02.090047+03
1061	311	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1062	311	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1063	311	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
1064	314	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1065	314	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1066	314	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
1067	314	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
1068	314	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1069	314	10	11	307-w10p64-22	\N	manual	\N	2026-02-17 23:54:02.090047+03
1070	314	10	12	оптика\n192.168.10.22	\N	manual	\N	2026-02-17 23:54:02.090047+03
1071	314	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1072	314	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1073	316	6	8	Core i3-3240 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1074	316	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1075	316	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1076	316	10	11	307-TimofeevaTN	\N	manual	\N	2026-02-17 23:54:02.090047+03
1077	316	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1078	316	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1079	316	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
1080	317	6	8	Core i3-3240 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1081	317	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1082	317	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1083	317	9	8	Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
1084	317	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
1085	317	10	11	307-LYKOVANA	\N	manual	\N	2026-02-17 23:54:02.090047+03
1086	317	10	12	DHCP (VLAN 207) vniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1087	317	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1088	317	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
1089	319	6	8	Core i5-2300 2,8 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1090	319	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1091	319	8	8	SSD - 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1092	319	9	8	Acer K222 HQL	\N	manual	\N	2026-02-17 23:54:02.090047+03
1093	319	9	10	Личный	\N	manual	\N	2026-02-17 23:54:02.090047+03
1094	319	10	11	307a-RybakOP	\N	manual	\N	2026-02-17 23:54:02.090047+03
1095	319	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1096	319	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1097	319	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
1098	322	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1099	322	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1100	322	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1101	322	9	8	Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
1102	322	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1103	322	10	11	308-Computer	\N	manual	\N	2026-02-17 23:54:02.090047+03
1104	322	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1105	322	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1106	322	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
1107	324	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1108	324	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1109	324	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
1110	324	9	8	BenQ  GL2450	\N	manual	\N	2026-02-17 23:54:02.090047+03
1111	324	10	11	308-KataevaLA	\N	manual	\N	2026-02-17 23:54:02.090047+03
1112	324	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1113	324	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1114	324	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
1115	326	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1116	326	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1117	326	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1118	326	9	8	Samsung 27" C27F390FHI	\N	manual	\N	2026-02-17 23:54:02.090047+03
1119	326	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1120	326	10	11	Lobanova	\N	manual	\N	2026-02-17 23:54:02.090047+03
1121	326	10	12	оптика\n192.168.10.23	\N	manual	\N	2026-02-17 23:54:02.090047+03
1122	326	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1123	326	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1124	328	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1125	328	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1126	328	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1127	328	9	8	NEC AccuSync AS221WM	\N	manual	\N	2026-02-17 23:54:02.090047+03
1128	328	10	11	308-KirillovaIB	\N	manual	\N	2026-02-17 23:54:02.090047+03
1129	328	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1130	328	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1131	328	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1132	331	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1133	331	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1134	331	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1135	331	9	8	Samsung 27" C27F390FHI	\N	manual	\N	2026-02-17 23:54:02.090047+03
1136	331	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1137	331	10	11	KirillovaIB	\N	manual	\N	2026-02-17 23:54:02.090047+03
1138	331	10	12	оптика\n192.168.10.19	\N	manual	\N	2026-02-17 23:54:02.090047+03
1139	331	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1140	331	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1141	334	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1142	334	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1143	334	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1144	334	9	8	Samsung 27" C27F390FHI	\N	manual	\N	2026-02-17 23:54:02.090047+03
1145	334	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1146	334	10	11	308-w10p64-35	\N	manual	\N	2026-02-17 23:54:02.090047+03
1147	334	10	12	оптика\n192.168.10.	\N	manual	\N	2026-02-17 23:54:02.090047+03
1148	334	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1149	334	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1150	337	6	8	Core i3-10105 3,70 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1151	337	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1152	337	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1153	337	9	8	Benq BL2405	\N	manual	\N	2026-02-17 23:54:02.090047+03
1154	337	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1155	337	10	11	308-UdaltsovaOA	\N	manual	\N	2026-02-17 23:54:02.090047+03
1156	337	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1157	337	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1158	337	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
1159	339	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1160	339	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1161	339	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1162	339	9	8	Samsung 27" C27F390FHI	\N	manual	\N	2026-02-17 23:54:02.090047+03
1163	339	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1164	339	10	11	KozlovaEE	\N	manual	\N	2026-02-17 23:54:02.090047+03
1165	339	10	12	оптика\n192.168.10.24	\N	manual	\N	2026-02-17 23:54:02.090047+03
1166	339	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1167	339	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1168	342	6	8	Core i3-2100 3,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1169	342	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1170	342	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1171	342	9	8	Samsung SyncMaster S23B300	\N	manual	\N	2026-02-17 23:54:02.090047+03
1172	342	10	11	308-KozlovaEE	\N	manual	\N	2026-02-17 23:54:02.090047+03
1173	342	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1174	342	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1175	342	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
1176	345	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1177	345	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1178	345	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1179	345	9	8	Samsung 27" C27F390FHI	\N	manual	\N	2026-02-17 23:54:02.090047+03
1180	345	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1181	345	10	11	308-CabutOV	\N	manual	\N	2026-02-17 23:54:02.090047+03
1182	345	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1183	345	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1184	345	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
1185	348	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1186	348	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1187	348	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
1188	348	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
1189	348	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1190	348	10	11	ZholudovaIV	\N	manual	\N	2026-02-17 23:54:02.090047+03
1191	348	10	12	оптика\n192.168.10.9	\N	manual	\N	2026-02-17 23:54:02.090047+03
1192	348	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1193	348	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1194	351	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1195	351	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1196	351	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
1197	351	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
1198	351	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1199	351	10	11	308-ZholudovaIV	\N	manual	\N	2026-02-17 23:54:02.090047+03
1200	351	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1201	351	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1203	354	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1204	354	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1205	354	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1206	354	9	8	Samsung 27" C27F390FHI	\N	manual	\N	2026-02-17 23:54:02.090047+03
1207	354	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1208	354	10	11	309-KovalevVI	\N	manual	\N	2026-02-17 23:54:02.090047+03
1209	354	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1210	354	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1211	354	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
1212	357	6	8	Core i5-9300H 2,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1213	357	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1214	357	8	8	SSD 480 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1215	357	9	8	15.6"	\N	manual	\N	2026-02-17 23:54:02.090047+03
1216	357	10	11	LAPTOP-KOVALEVV	\N	manual	\N	2026-02-17 23:54:02.090047+03
1217	357	10	12	DHCP (VLAN 207)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1218	357	10	13	Win 10 Home (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1219	357	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
1220	359	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1221	359	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1222	359	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
1223	359	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
1224	359	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1225	359	10	11	308-AlexandrovVV	\N	manual	\N	2026-02-17 23:54:02.090047+03
1226	359	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1227	359	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1228	359	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
1229	362	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1230	362	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1231	362	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
1232	362	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
1233	362	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1234	362	10	11	AleksandrovVV	\N	manual	\N	2026-02-17 23:54:02.090047+03
1235	362	10	12	оптика\n192.168.10.26	\N	manual	\N	2026-02-17 23:54:02.090047+03
1236	362	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1237	362	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1238	365	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1239	365	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1240	365	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1241	365	9	8	Samsung 27" C27F390FHI	\N	manual	\N	2026-02-17 23:54:02.090047+03
1242	365	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1243	365	10	11	SolovyovaEA	\N	manual	\N	2026-02-17 23:54:02.090047+03
1244	365	10	12	оптика\n192.168.10.11	\N	manual	\N	2026-02-17 23:54:02.090047+03
1245	365	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1246	365	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1247	368	6	8	Pentium Dual-Core E6500 2,93 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1248	368	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1249	368	8	8	300 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1250	368	9	8	Samsung SyncMaster P2270	\N	manual	\N	2026-02-17 23:54:02.090047+03
1251	368	9	10	99036	\N	manual	\N	2026-02-17 23:54:02.090047+03
1252	368	10	11	310-VysokovaND	\N	manual	\N	2026-02-17 23:54:02.090047+03
1253	368	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1254	368	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1255	368	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
1256	370	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1257	370	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1258	370	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
1259	370	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
1260	370	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1261	370	10	11	VisokovaND	\N	manual	\N	2026-02-17 23:54:02.090047+03
1262	370	10	12	оптика\n192.168.10.171	\N	manual	\N	2026-02-17 23:54:02.090047+03
1263	370	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1264	370	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1265	373	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1266	373	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1267	373	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1268	373	9	8	Samsung 27" C27F390FHI	\N	manual	\N	2026-02-17 23:54:02.090047+03
1269	373	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1270	373	10	11	310-W10P64-37	\N	manual	\N	2026-02-17 23:54:02.090047+03
1271	373	10	12	оптика\n192.168.10.37	\N	manual	\N	2026-02-17 23:54:02.090047+03
1272	373	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1273	373	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1274	376	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1275	376	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1276	376	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1277	376	9	8	BenQ G2025HDA	\N	manual	\N	2026-02-17 23:54:02.090047+03
1278	376	10	11	310-DvoryadkinaOI	\N	manual	\N	2026-02-17 23:54:02.090047+03
1279	376	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1280	376	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1281	376	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
1282	378	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1283	378	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1284	378	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1285	378	9	8	Nec MultiSync EA221WMe	\N	manual	\N	2026-02-17 23:54:02.090047+03
1286	378	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1287	378	10	11	310-SolovyovaEA	\N	manual	\N	2026-02-17 23:54:02.090047+03
1288	378	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1289	378	10	13	Win10 pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1290	378	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
1291	381	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1292	381	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1293	381	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
1294	381	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
1295	381	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1296	381	10	11	310-w10p64-38	\N	manual	\N	2026-02-17 23:54:02.090047+03
1297	381	10	12	оптика\n192.168.10.38	\N	manual	\N	2026-02-17 23:54:02.090047+03
1298	381	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1299	381	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1300	384	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1301	384	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1302	384	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
1303	384	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
1304	384	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1305	384	10	11	310-LazutinaJS	\N	manual	\N	2026-02-17 23:54:02.090047+03
1306	384	10	12	оптика\n192.168.10.197	\N	manual	\N	2026-02-17 23:54:02.090047+03
1307	384	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1308	384	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
1309	387	6	8	Core i5-3330S 2,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1310	387	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1311	387	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1312	387	10	11	310-GrafskyDA	\N	manual	\N	2026-02-17 23:54:02.090047+03
1313	387	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1314	387	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1315	387	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
1316	388	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1317	388	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1318	388	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
1319	388	9	8	AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
1320	388	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1321	388	10	11	310-BorovikovVV	\N	manual	\N	2026-02-17 23:54:02.090047+03
1322	388	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1323	388	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1324	388	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
1325	391	6	8	Pentium Dual-Core E5700 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1326	391	7	9	2 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1327	391	8	8	300 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1328	391	10	11	YUVN	\N	manual	\N	2026-02-17 23:54:02.090047+03
1329	391	10	13	Win7 Pro (x32)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1330	391	10	14	Avast	\N	manual	\N	2026-02-17 23:54:02.090047+03
1331	392	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1332	392	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1333	392	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1334	392	9	8	Samsung 27" C27F390FHI	\N	manual	\N	2026-02-17 23:54:02.090047+03
1335	392	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1336	392	10	11	311-ZamyatinaON	\N	manual	\N	2026-02-17 23:54:02.090047+03
1337	392	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1338	392	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1339	392	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
1340	395	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1341	395	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1342	395	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
1343	395	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
1344	395	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1345	395	10	11	ZamyatinaON	\N	manual	\N	2026-02-17 23:54:02.090047+03
1346	395	10	12	оптика	\N	manual	\N	2026-02-17 23:54:02.090047+03
1347	395	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1348	395	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1349	398	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1350	398	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1351	398	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
1352	398	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
1353	398	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1354	398	10	11	KurianovaAS	\N	manual	\N	2026-02-17 23:54:02.090047+03
1355	398	10	12	оптика	\N	manual	\N	2026-02-17 23:54:02.090047+03
1356	398	10	13	Astra Linux Special Edition	\N	manual	\N	2026-02-17 23:54:02.090047+03
1357	398	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1358	401	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1359	401	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1360	401	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1361	401	9	8	Samsung 27" C27F390FHI	\N	manual	\N	2026-02-17 23:54:02.090047+03
1362	401	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1363	401	10	11	311-KuryanovaAS	\N	manual	\N	2026-02-17 23:54:02.090047+03
1364	401	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1365	401	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1366	401	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
1367	404	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1368	404	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1369	404	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
1370	404	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
1371	404	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1372	404	10	11	LebedevaEV	\N	manual	\N	2026-02-17 23:54:02.090047+03
1373	404	10	12	оптика\n192.168.10.87	\N	manual	\N	2026-02-17 23:54:02.090047+03
1374	404	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1375	404	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1376	407	6	8	Core i3-2100 3,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1377	407	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1378	407	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1379	407	9	8	Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
1380	407	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1381	407	10	11	311-KornilovaMN	\N	manual	\N	2026-02-17 23:54:02.090047+03
1382	407	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1383	407	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1384	407	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
1385	409	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1386	409	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1387	409	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1388	409	9	8	Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
1389	409	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1390	409	10	11	311-W10p64	\N	manual	\N	2026-02-17 23:54:02.090047+03
1391	409	10	12	оптика	\N	manual	\N	2026-02-17 23:54:02.090047+03
1392	409	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1393	409	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
1394	412	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1395	412	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1396	412	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
1397	412	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
1398	412	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1399	412	10	11	311-w10p64	\N	manual	\N	2026-02-17 23:54:02.090047+03
1400	412	10	12	не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
1401	412	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1402	412	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1403	415	6	8	Core i3 -2100 3.10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1404	415	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1405	415	8	8	SSD 120 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1406	415	9	8	Nec MultiSync E222w	\N	manual	\N	2026-02-17 23:54:02.090047+03
1407	415	9	10	МЦ.04.1	\N	manual	\N	2026-02-17 23:54:02.090047+03
1408	415	10	11	311-SelivanovV	\N	manual	\N	2026-02-17 23:54:02.090047+03
1409	415	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1410	415	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1411	415	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
1412	417	6	8	Core i3-10105 3,70 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1413	417	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1414	417	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1415	417	9	8	AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
1416	417	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1417	417	10	11	311-TuganovEV	\N	manual	\N	2026-02-17 23:54:02.090047+03
1418	417	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1419	417	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1420	417	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
1421	420	6	8	Core i5-12500 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1422	420	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1423	420	8	8	SSD 512 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1424	420	9	8	MB27V13FS51	\N	manual	\N	2026-02-17 23:54:02.090047+03
1425	420	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1426	420	10	11	311-TuganovEV	\N	manual	\N	2026-02-17 23:54:02.090047+03
1427	420	10	12	оптика	\N	manual	\N	2026-02-17 23:54:02.090047+03
1428	420	10	13	Astra Linux Special Edition	\N	manual	\N	2026-02-17 23:54:02.090047+03
1429	420	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
1430	422	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1431	422	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1432	422	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
1433	422	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
1434	422	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1435	422	10	11	BusyginVP	\N	manual	\N	2026-02-17 23:54:02.090047+03
1436	422	10	12	оптика\n192.168.10.212	\N	manual	\N	2026-02-17 23:54:02.090047+03
1437	422	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1438	422	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1439	424	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1440	424	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1441	424	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1442	424	9	8	Samsung 27" C27F390FHI	\N	manual	\N	2026-02-17 23:54:02.090047+03
1443	424	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1444	424	10	11	EzikNS	\N	manual	\N	2026-02-17 23:54:02.090047+03
1445	424	10	12	оптика\n192.168.10.14	\N	manual	\N	2026-02-17 23:54:02.090047+03
1446	424	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1447	424	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1448	427	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1449	427	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1450	427	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
1451	427	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
1452	427	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1453	427	10	11	OrosNI	\N	manual	\N	2026-02-17 23:54:02.090047+03
1454	427	10	12	оптика\n192.168.10.251	\N	manual	\N	2026-02-17 23:54:02.090047+03
1455	427	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1456	427	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1457	430	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1458	430	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1459	430	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
1460	430	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
1461	430	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1462	430	10	11	NilovaEA	\N	manual	\N	2026-02-17 23:54:02.090047+03
1463	430	10	12	оптика\n192.168.10.129	\N	manual	\N	2026-02-17 23:54:02.090047+03
1464	430	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1465	430	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1466	433	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1467	433	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1468	433	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1469	433	9	8	Samsung 27" C27F390FHI	\N	manual	\N	2026-02-17 23:54:02.090047+03
1470	433	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1471	433	10	11	VasilievaON	\N	manual	\N	2026-02-17 23:54:02.090047+03
1472	433	10	12	оптика\n192.168.10.131	\N	manual	\N	2026-02-17 23:54:02.090047+03
1473	433	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1474	433	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1475	436	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1476	436	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1477	436	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
1478	436	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
1479	436	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1480	436	10	11	JudinBA	\N	manual	\N	2026-02-17 23:54:02.090047+03
1481	436	10	12	оптика	\N	manual	\N	2026-02-17 23:54:02.090047+03
1482	436	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1483	436	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1484	439	6	8	Core i5-2300 2,8 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1485	439	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1486	439	8	8	1000 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1487	439	9	8	Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
1488	439	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1489	439	10	11	312-Computer	\N	manual	\N	2026-02-17 23:54:02.090047+03
1490	439	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1491	439	10	13	Win10Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1492	439	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
1493	441	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1494	441	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1495	441	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
1496	441	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
1497	441	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1498	441	10	11	312-Panina	\N	manual	\N	2026-02-17 23:54:02.090047+03
1499	441	10	12	vniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1500	441	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1501	441	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1502	444	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1503	444	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1504	444	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1505	444	9	8	Samsung 27" C27F390FHI	\N	manual	\N	2026-02-17 23:54:02.090047+03
1506	444	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1507	444	10	11	MyatlikVA	\N	manual	\N	2026-02-17 23:54:02.090047+03
1508	444	10	12	оптика\n192.168.10.136	\N	manual	\N	2026-02-17 23:54:02.090047+03
1509	444	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1510	444	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1511	446	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1512	446	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1513	446	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1514	446	9	8	Samsung 27" C27F390FHI	\N	manual	\N	2026-02-17 23:54:02.090047+03
1515	446	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1516	446	10	11	DorohovaLN	\N	manual	\N	2026-02-17 23:54:02.090047+03
1517	446	10	12	оптика\n192.168.10.16	\N	manual	\N	2026-02-17 23:54:02.090047+03
1518	446	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1519	446	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1520	449	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1521	449	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1522	449	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
1523	449	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
1524	449	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1525	449	10	11	GurieliEO	\N	manual	\N	2026-02-17 23:54:02.090047+03
1526	449	10	12	оптика\n192.168.10.34	\N	manual	\N	2026-02-17 23:54:02.090047+03
1527	449	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1528	449	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1529	452	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1530	452	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1531	452	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
1532	452	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
1533	452	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1534	452	10	11	KaitukovaMV	\N	manual	\N	2026-02-17 23:54:02.090047+03
1535	452	10	12	оптика\n192.168.10.250	\N	manual	\N	2026-02-17 23:54:02.090047+03
1536	452	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1537	452	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1538	455	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1539	455	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1540	455	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1541	455	9	8	Samsung 27" C27F390FHI	\N	manual	\N	2026-02-17 23:54:02.090047+03
1542	455	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1543	455	10	11	313-KaitukovaMV	\N	manual	\N	2026-02-17 23:54:02.090047+03
1544	455	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1545	455	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1546	455	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1547	458	6	8	Pentium Dual-Core E5700 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1548	458	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1549	458	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1550	458	9	8	LG Flatron L192WS	\N	manual	\N	2026-02-17 23:54:02.090047+03
1551	458	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
1552	458	10	11	313-Computer	\N	manual	\N	2026-02-17 23:54:02.090047+03
1553	458	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1554	458	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1555	458	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1556	460	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1557	460	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1558	460	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1559	460	9	8	Samsung 27" C27F390FHI	\N	manual	\N	2026-02-17 23:54:02.090047+03
1560	460	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1561	460	10	11	SemyonovaSN	\N	manual	\N	2026-02-17 23:54:02.090047+03
1562	460	10	12	оптика\n192.168.10.45	\N	manual	\N	2026-02-17 23:54:02.090047+03
1563	460	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1564	460	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1565	463	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1566	463	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1567	463	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
1568	463	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
1569	463	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1570	463	10	11	313-YagodkinaOA	\N	manual	\N	2026-02-17 23:54:02.090047+03
1571	463	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1572	463	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1573	463	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1574	466	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1575	466	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1576	466	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1577	466	9	8	Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
1578	466	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
1579	466	10	11	313-ZorinaEA	\N	manual	\N	2026-02-17 23:54:02.090047+03
1580	466	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1581	466	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1582	466	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
1583	468	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1584	468	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1585	468	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
1586	468	9	8	LG Flatron L192WS	\N	manual	\N	2026-02-17 23:54:02.090047+03
1587	468	10	11	313-ZorinaEA	\N	manual	\N	2026-02-17 23:54:02.090047+03
1588	468	10	12	DHCP	\N	manual	\N	2026-02-17 23:54:02.090047+03
1589	468	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1590	468	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
1591	470	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1592	470	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1593	470	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1594	470	9	8	Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
1595	470	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
1596	470	10	11	314-W7P64-161	\N	manual	\N	2026-02-17 23:54:02.090047+03
1597	470	10	12	10.10.10.161	\N	manual	\N	2026-02-17 23:54:02.090047+03
1598	470	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1599	470	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
1600	472	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1601	472	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1602	472	8	8	HDD - 1 TB; SSD - 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1603	472	9	8	Philips 272S1AE	\N	manual	\N	2026-02-17 23:54:02.090047+03
1604	472	9	10	МЦ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1605	472	10	11	314-w10p64-sav	\N	manual	\N	2026-02-17 23:54:02.090047+03
1606	472	10	12	не с сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
1607	472	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1608	472	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1609	475	6	8	Core i5-650 3,19 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1610	475	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1611	475	8	8	1 ТБ; SSD 120	\N	manual	\N	2026-02-17 23:54:02.090047+03
1612	475	9	8	Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
1613	475	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
1614	475	10	11	314-W10P64-162	\N	manual	\N	2026-02-17 23:54:02.090047+03
1615	475	10	12	10.10.10.162	\N	manual	\N	2026-02-17 23:54:02.090047+03
1616	475	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1617	475	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
1618	477	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1619	477	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1620	477	8	8	HDD - 1 TB; SSD - 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1621	477	9	8	Philips 272S1AE	\N	manual	\N	2026-02-17 23:54:02.090047+03
1622	477	9	10	МЦ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1623	477	10	11	314-w10p64-pol	\N	manual	\N	2026-02-17 23:54:02.090047+03
1624	477	10	12	не с сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
1625	477	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1626	477	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1627	480	6	8	Core i7-8700T 2,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1628	480	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1629	480	8	8	1ТБ +; 128ГБ (SSD)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1630	480	9	8	23,8"	\N	manual	\N	2026-02-17 23:54:02.090047+03
1631	480	10	11	315-w10p64-147	\N	manual	\N	2026-02-17 23:54:02.090047+03
1632	480	10	12	10.10.10.147	\N	manual	\N	2026-02-17 23:54:02.090047+03
1633	480	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1634	480	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1635	482	6	8	Core i3-2100 3,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1636	482	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1637	482	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1638	482	9	8	Nec MultiSync E224Wi	\N	manual	\N	2026-02-17 23:54:02.090047+03
1639	482	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
1640	482	10	11	317-w7p64-6	\N	manual	\N	2026-02-17 23:54:02.090047+03
1641	482	10	12	10.1.4.6	\N	manual	\N	2026-02-17 23:54:02.090047+03
1642	482	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1643	482	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
1644	484	6	8	Pentium Dual-Core E2160 1.8 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1645	484	7	9	1 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1646	484	8	8	150 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1647	484	9	8	LG Flatron Slim L1980u	\N	manual	\N	2026-02-17 23:54:02.090047+03
1648	484	9	10	88263	\N	manual	\N	2026-02-17 23:54:02.090047+03
1649	484	10	11	Alla-PC	\N	manual	\N	2026-02-17 23:54:02.090047+03
1650	484	10	12	не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
1651	484	10	13	Win7 Ultimate (x32)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1652	484	10	14	Avast	\N	manual	\N	2026-02-17 23:54:02.090047+03
1653	486	6	8	Pentium Dual-Core E7500 2,94 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1654	486	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1655	486	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1656	486	9	8	Nec MultiSync E224Wi	\N	manual	\N	2026-02-17 23:54:02.090047+03
1657	486	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
1658	486	10	11	317-W7P64-5	\N	manual	\N	2026-02-17 23:54:02.090047+03
1659	486	10	12	10.1.4.5	\N	manual	\N	2026-02-17 23:54:02.090047+03
1660	486	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1661	486	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1662	488	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1663	488	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1664	488	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1665	488	9	8	Benq BL2405; Benq BL2405	\N	manual	\N	2026-02-17 23:54:02.090047+03
1666	488	9	10	НИИСУ\nНИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1667	488	10	11	318-W10P64-97	\N	manual	\N	2026-02-17 23:54:02.090047+03
1668	488	10	12	10.10.10.97	\N	manual	\N	2026-02-17 23:54:02.090047+03
1669	488	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1670	488	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
1671	491	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1672	491	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1673	491	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1674	491	9	8	MB27V13FS51; MB27V13FS51	\N	manual	\N	2026-02-17 23:54:02.090047+03
1675	491	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1676	491	10	11	318-w10p64-99	\N	manual	\N	2026-02-17 23:54:02.090047+03
1677	491	10	12	10.10.10.99	\N	manual	\N	2026-02-17 23:54:02.090047+03
1678	491	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1679	491	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
1680	494	6	8	Core i5-10400 2,90 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1681	494	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1682	494	8	8	HDD - 1 TB; SSD - 240 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1683	494	9	8	Dell E2314H; Dell E2314H	\N	manual	\N	2026-02-17 23:54:02.090047+03
1684	494	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1685	494	10	11	319-W10P64-169	\N	manual	\N	2026-02-17 23:54:02.090047+03
1686	494	10	12	10.10.10.169	\N	manual	\N	2026-02-17 23:54:02.090047+03
1687	494	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1688	494	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1689	498	6	8	Core i5-10300H 2,5 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1690	498	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1691	498	8	8	500 ГБ SSD	\N	manual	\N	2026-02-17 23:54:02.090047+03
1692	498	9	8	17"	\N	manual	\N	2026-02-17 23:54:02.090047+03
1693	498	10	13	Win10 Home (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1694	498	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1695	500	6	8	Core i3-7100T 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1696	500	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1697	500	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1698	500	9	8	Benq BL2201; Benq BL2201	\N	manual	\N	2026-02-17 23:54:02.090047+03
1699	500	9	10	НИИСУ\nНИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1700	500	10	11	319-w10p64-7	\N	manual	\N	2026-02-17 23:54:02.090047+03
1701	500	10	12	10.10.10.7	\N	manual	\N	2026-02-17 23:54:02.090047+03
1702	500	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1703	500	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1704	504	6	8	Core i5-2500 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1705	504	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1706	504	8	8	SSD - 480 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1707	504	9	8	Samsung C32F391FWI	\N	manual	\N	2026-02-17 23:54:02.090047+03
1708	504	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1709	504	10	11	319-w10p64-22	\N	manual	\N	2026-02-17 23:54:02.090047+03
1710	504	10	12	10.10.10.22	\N	manual	\N	2026-02-17 23:54:02.090047+03
1711	504	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1712	504	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
1713	506	6	8	Core i5-10400 2,90 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1714	506	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1715	506	8	8	HDD - 1 TB; SSD - 240 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1716	506	9	8	Samsung S27F358FWI; Samsung S27F358FWI	\N	manual	\N	2026-02-17 23:54:02.090047+03
1717	506	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1718	506	10	11	319-SamsonovaEM	\N	manual	\N	2026-02-17 23:54:02.090047+03
1719	506	10	12	не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
1720	506	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1721	506	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
1722	510	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1723	510	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1724	510	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1725	510	9	8	Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
1726	510	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1727	510	10	11	319-w10p64-168	\N	manual	\N	2026-02-17 23:54:02.090047+03
1728	510	10	12	10.10.10.168	\N	manual	\N	2026-02-17 23:54:02.090047+03
1729	510	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1730	510	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
1731	512	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1732	512	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1733	512	8	8	1TБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1734	512	9	8	Asus VX239	\N	manual	\N	2026-02-17 23:54:02.090047+03
1735	512	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1736	512	10	11	319-w10p64-61	\N	manual	\N	2026-02-17 23:54:02.090047+03
1737	512	10	12	10.10.10.61	\N	manual	\N	2026-02-17 23:54:02.090047+03
1738	512	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1739	512	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
1740	515	6	8	Core i5 – 12450H, 2,00ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1741	515	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1742	515	8	8	SSD 250 ГБ; SSD 1Т	\N	manual	\N	2026-02-17 23:54:02.090047+03
1743	515	9	8	15,6"	\N	manual	\N	2026-02-17 23:54:02.090047+03
1744	515	10	13	Win11 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1745	517	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1746	517	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1747	517	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1748	517	9	8	MB27V13FS51; Samsung 27" C27F390FHI	\N	manual	\N	2026-02-17 23:54:02.090047+03
1749	517	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1750	517	10	11	319-w10p64-59	\N	manual	\N	2026-02-17 23:54:02.090047+03
1751	517	10	12	10.10.10.59	\N	manual	\N	2026-02-17 23:54:02.090047+03
1752	517	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1753	517	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
1754	521	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1755	521	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1756	521	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1757	521	9	8	LG 27GL650F; LG 27GL650F	\N	manual	\N	2026-02-17 23:54:02.090047+03
1758	521	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1759	521	10	11	320-w10p64-98	\N	manual	\N	2026-02-17 23:54:02.090047+03
1760	521	10	12	10.10.10.98	\N	manual	\N	2026-02-17 23:54:02.090047+03
1761	521	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1762	521	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
1763	525	6	8	Athlon 3150U 2.40 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1764	525	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1765	525	8	8	SSD 240 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1766	525	9	8	15"	\N	manual	\N	2026-02-17 23:54:02.090047+03
1767	525	10	13	Win11H(x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1768	527	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1769	527	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1770	527	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1771	527	9	8	AOC 24P2Q; AOC 24P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
1772	527	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1773	527	10	11	321-w10p64-167	\N	manual	\N	2026-02-17 23:54:02.090047+03
1774	527	10	12	10.10.10.167	\N	manual	\N	2026-02-17 23:54:02.090047+03
1775	527	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1776	527	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1777	530	6	8	Core i5-10300H 2,5 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1778	530	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1779	530	8	8	500 ГБ SSD	\N	manual	\N	2026-02-17 23:54:02.090047+03
1780	530	9	8	17"	\N	manual	\N	2026-02-17 23:54:02.090047+03
1781	530	10	13	Win10 Home (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1782	530	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1783	532	6	8	Core i7-3770 3,4ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1784	532	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1785	532	8	8	SSD 480 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1786	532	9	8	Philips 273V7QJAB; Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
1787	532	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1788	532	10	11	321-w10p64-30	\N	manual	\N	2026-02-17 23:54:02.090047+03
1789	532	10	12	10.10.10.30	\N	manual	\N	2026-02-17 23:54:02.090047+03
1790	532	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1791	532	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
1792	536	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1793	536	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1794	536	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1795	536	9	8	Samsung S27F358FWI; Samsung S27F358FWI	\N	manual	\N	2026-02-17 23:54:02.090047+03
1796	536	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1797	536	10	11	319-w10p64-24	\N	manual	\N	2026-02-17 23:54:02.090047+03
1798	536	10	12	10.10.10.24	\N	manual	\N	2026-02-17 23:54:02.090047+03
1799	536	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1800	536	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
1801	540	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1802	540	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1803	540	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1804	540	9	8	AOC 27P2Q; AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
1805	540	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1806	540	10	11	321-W10P64-171	\N	manual	\N	2026-02-17 23:54:02.090047+03
1807	540	10	12	10.10.10.171	\N	manual	\N	2026-02-17 23:54:02.090047+03
1808	540	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1809	540	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
1810	544	6	8	Core i5-10400 2,90 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1811	544	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1812	544	8	8	HDD - 1 TB; SSD - 240 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1813	544	9	8	Samsung C32F391FWI	\N	manual	\N	2026-02-17 23:54:02.090047+03
1814	544	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1815	544	10	11	321-w10p64-174	\N	manual	\N	2026-02-17 23:54:02.090047+03
1816	544	10	12	10.10.10.174	\N	manual	\N	2026-02-17 23:54:02.090047+03
1817	544	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1818	544	10	14	KES 12	\N	manual	\N	2026-02-17 23:54:02.090047+03
1819	547	6	8	Core i3-370m 2,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1820	547	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1821	547	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1822	547	10	11	Андрей-VAIO	\N	manual	\N	2026-02-17 23:54:02.090047+03
1823	547	10	12	не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
1824	547	10	13	Win7 Home (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1825	547	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1826	548	6	8	Core i5-7400 3,0 ГГц nVidia GeForce GT710	\N	manual	\N	2026-02-17 23:54:02.090047+03
1827	548	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1828	548	8	8	SSD 480  ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1829	548	9	8	Asus 27" MX279H; Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
1830	548	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1831	548	10	11	321-w10p64-165	\N	manual	\N	2026-02-17 23:54:02.090047+03
1832	548	10	12	10.10.10.165	\N	manual	\N	2026-02-17 23:54:02.090047+03
1833	548	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1834	548	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
1835	552	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1836	552	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1837	552	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1838	552	9	8	Nec MultiSync EA221WMe; Nec MultiSync E231W	\N	manual	\N	2026-02-17 23:54:02.090047+03
1839	552	9	10	МЦ.04.1\nМЦ.04.1	\N	manual	\N	2026-02-17 23:54:02.090047+03
1840	552	10	11	321-w10p64-170	\N	manual	\N	2026-02-17 23:54:02.090047+03
1841	552	10	12	10.10.10.170	\N	manual	\N	2026-02-17 23:54:02.090047+03
1842	552	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1843	552	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1844	555	6	8	Core i5-12500 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1845	555	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1846	555	8	8	SSD 512 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1847	555	9	8	MB27V13FS51; Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
1848	555	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1849	555	10	11	ZhidmanPC	\N	manual	\N	2026-02-17 23:54:02.090047+03
1850	555	10	12	10.1.4.216	\N	manual	\N	2026-02-17 23:54:02.090047+03
1851	555	10	13	Ubuntu 20	\N	manual	\N	2026-02-17 23:54:02.090047+03
1852	555	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
1853	558	6	8	Core i7-8565U 1,8 ГГц,,	\N	manual	\N	2026-02-17 23:54:02.090047+03
1854	558	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1855	558	8	8	SSD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1856	558	9	8	Ноутбук HP Pro Book 450 G6	\N	manual	\N	2026-02-17 23:54:02.090047+03
1857	560	6	8	Core i5-12500 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1858	560	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1859	560	8	8	SSD 512 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1860	560	9	8	MB27V13FS51; AOC 24P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
1861	560	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1862	560	10	11	322a-astra-196	\N	manual	\N	2026-02-17 23:54:02.090047+03
1863	560	10	12	10.1.4.196	\N	manual	\N	2026-02-17 23:54:02.090047+03
1864	560	10	13	Astra Linux Special Edition	\N	manual	\N	2026-02-17 23:54:02.090047+03
1865	560	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
1866	563	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1867	563	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1868	563	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1869	563	9	8	AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
1870	563	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1871	563	10	11	406-EsakiaVN	\N	manual	\N	2026-02-17 23:54:02.090047+03
1872	563	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1873	563	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1874	563	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
1875	566	6	8	Core i5-10400 2,90 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1876	566	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1877	566	8	8	HDD - 1 TB; SSD - 240 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1878	566	9	8	Philips 243V7QJABF	\N	manual	\N	2026-02-17 23:54:02.090047+03
1879	566	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1880	566	10	12	не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
1881	566	10	13	Astra Linux Special Edition	\N	manual	\N	2026-02-17 23:54:02.090047+03
1882	566	10	14	____	\N	manual	\N	2026-02-17 23:54:02.090047+03
1883	568	6	8	Core i5-10400 2,90 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1884	568	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1885	568	8	8	HDD - 1 TB; SSD - 240 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1886	568	9	8	Philips 243V7QJABF; Philips 243V7QJABF	\N	manual	\N	2026-02-17 23:54:02.090047+03
1887	568	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1888	568	10	11	406-SHUSTROVAJV	\N	manual	\N	2026-02-17 23:54:02.090047+03
1889	568	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1890	568	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1891	568	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
1892	572	6	8	Core i5-10400 2,90 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1893	572	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1894	572	8	8	HDD - 1 TB; SSD - 240 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1895	572	9	8	Philips 243V7QJABF; Philips 243V7QJABF	\N	manual	\N	2026-02-17 23:54:02.090047+03
1896	572	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1897	572	10	11	707-w10p64-168	\N	manual	\N	2026-02-17 23:54:02.090047+03
1898	572	10	12	не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
1899	572	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1900	572	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
1901	576	6	8	Core i5-10400 2,90 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1902	576	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1903	576	8	8	HDD - 1 TB; SSD - 240 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1904	576	9	8	Philips 243V7QJABF; Philips 243V7QJABF	\N	manual	\N	2026-02-17 23:54:02.090047+03
1905	576	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1906	576	10	11	406-DUSHECHKINM	\N	manual	\N	2026-02-17 23:54:02.090047+03
1907	576	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1908	576	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1909	576	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
1910	580	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1911	580	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1912	580	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1913	580	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1914	580	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1915	581	6	8	Core i3-4160 3,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1916	581	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1917	581	8	8	2 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1918	581	9	8	Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
1919	581	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
1920	581	10	11	406-LutsenkoPP	\N	manual	\N	2026-02-17 23:54:02.090047+03
1921	581	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1922	581	10	13	Win8.1 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1923	581	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
1924	583	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1925	583	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1926	583	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1927	583	9	8	MB27V13FS51	\N	manual	\N	2026-02-17 23:54:02.090047+03
1928	583	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1929	583	10	11	406-MaklachkovaMA	\N	manual	\N	2026-02-17 23:54:02.090047+03
1930	583	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1931	583	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1932	583	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
1933	586	6	8	Core i3-4160 3,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1934	586	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1935	586	8	8	SSD -500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1936	586	9	8	Samsung S22C200; Samsung SyncMaster SA200	\N	manual	\N	2026-02-17 23:54:02.090047+03
1937	586	9	10	МЦ.04.2\nМЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
1938	586	10	11	406-w10p64-28	\N	manual	\N	2026-02-17 23:54:02.090047+03
1939	586	10	12	10.1.4.28	\N	manual	\N	2026-02-17 23:54:02.090047+03
1940	586	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1941	586	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
1942	590	6	8	Core i5-3330S 2,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1943	590	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1944	590	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1945	590	10	11	406-w10P64-32	\N	manual	\N	2026-02-17 23:54:02.090047+03
1946	590	10	12	10.1.4.32	\N	manual	\N	2026-02-17 23:54:02.090047+03
1947	590	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1948	590	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
1949	591	6	8	Core i5-12500 3,00 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1950	591	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1951	591	8	8	SSD 512 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1952	591	10	12	DHCP (VLAN 207)\n192.168.207.220	\N	manual	\N	2026-02-17 23:54:02.090047+03
1953	591	10	13	Astra Linux Special Edition 1.7	\N	manual	\N	2026-02-17 23:54:02.090047+03
1954	592	6	8	Core i5-7200U	\N	manual	\N	2026-02-17 23:54:02.090047+03
1955	592	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1956	592	8	8	SSD 256 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1957	592	9	8	15,6"	\N	manual	\N	2026-02-17 23:54:02.090047+03
1958	592	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1959	594	6	8	Core i5-12500 3,00 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1960	594	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1961	594	8	8	SSD 512 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1962	594	10	11	408-ZhurenkovDA	\N	manual	\N	2026-02-17 23:54:02.090047+03
1963	594	10	12	DHCP (VLAN 207)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1964	594	10	13	Astra Linux 1.8 Special Edition	\N	manual	\N	2026-02-17 23:54:02.090047+03
1965	594	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
1966	595	6	8	Core i5-7200U	\N	manual	\N	2026-02-17 23:54:02.090047+03
1967	595	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1968	595	8	8	1ТБ +; 128ГБ (SSD)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1969	595	9	8	17"	\N	manual	\N	2026-02-17 23:54:02.090047+03
1970	595	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1971	597	6	8	AMD 3020e 1.20 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1972	597	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1973	597	8	8	SSD 240 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1974	597	9	8	15"	\N	manual	\N	2026-02-17 23:54:02.090047+03
1975	597	10	13	Win10H(x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1976	597	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
1977	599	6	8	Core i5-10300H 2,5 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1978	599	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1979	599	8	8	500 ГБ SSD	\N	manual	\N	2026-02-17 23:54:02.090047+03
1980	599	9	8	17"	\N	manual	\N	2026-02-17 23:54:02.090047+03
1981	599	10	13	Win10 Home (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1982	599	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
1983	601	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1984	601	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1985	601	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1986	601	9	8	AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
1987	601	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
1988	601	10	11	501k-ZHURENKOVDA	\N	manual	\N	2026-02-17 23:54:02.090047+03
1989	601	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
1990	601	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1991	601	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
1992	604	6	8	Core i5-7200U	\N	manual	\N	2026-02-17 23:54:02.090047+03
1993	604	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1994	604	8	8	1ТБ +; 128ГБ (SSD)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1995	604	9	8	15,6"	\N	manual	\N	2026-02-17 23:54:02.090047+03
1996	604	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
1997	606	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
1998	606	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
1999	606	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2000	606	9	8	Samsung S27F358FWI; Samsung S27F358FWI	\N	manual	\N	2026-02-17 23:54:02.090047+03
2001	606	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2002	606	10	11	408-SEMAKOVAVS	\N	manual	\N	2026-02-17 23:54:02.090047+03
2003	606	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2004	606	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2005	606	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2006	609	6	8	Core i5-10400 2,90 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2007	609	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2008	609	8	8	HDD - 1 TB; SSD - 240 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2009	609	9	8	Philips 273V7QJAB; Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
2010	609	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2011	609	10	11	408-BASALAEVAJA	\N	manual	\N	2026-02-17 23:54:02.090047+03
2012	609	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2013	609	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2014	609	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
2015	612	6	8	Core i5-10400 2,90 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2016	612	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2017	612	8	8	HDD - 1 TB; SSD - 240 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2018	612	9	8	Samsung C32F391FWI; Samsung C32F391FWI	\N	manual	\N	2026-02-17 23:54:02.090047+03
2019	612	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2020	612	10	11	408-MILKINAIG	\N	manual	\N	2026-02-17 23:54:02.090047+03
2021	612	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2022	612	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2023	612	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
2024	615	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2025	615	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2026	615	8	8	SSD 128 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2027	615	9	8	Philips 273V7QJAB; Philips 273V7QJAB; Samsung F27T  (по факту); Samsung F27T  (по факту)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2028	615	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2029	615	10	11	408-SBITNEVAAY	\N	manual	\N	2026-02-17 23:54:02.090047+03
2030	615	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2031	615	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2032	615	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2033	621	6	8	Pentium Silver N5030	\N	manual	\N	2026-02-17 23:54:02.090047+03
2034	621	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2035	621	8	8	SSD 256 Gb	\N	manual	\N	2026-02-17 23:54:02.090047+03
2036	621	10	13	Win 10 Home (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2037	622	6	8	Core i3-4160 3,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2038	622	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2039	622	8	8	500 ГБ; 2 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2040	622	9	8	Philips 273V7QJAB; Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
2041	622	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2042	622	10	11	408-kriushuinska	\N	manual	\N	2026-02-17 23:54:02.090047+03
2043	622	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2044	622	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2045	622	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2046	625	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2047	625	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2048	625	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2049	625	9	8	Philips 273V7QJAB; Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
2050	625	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2051	625	10	11	510-w10p64-98	\N	manual	\N	2026-02-17 23:54:02.090047+03
2052	625	10	12	10.2.2.98	\N	manual	\N	2026-02-17 23:54:02.090047+03
2053	625	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2054	625	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2055	628	6	8	Core i3-2100 3,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2056	628	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2057	628	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2058	629	6	8	AMD 3020e 1.20 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2059	629	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2060	629	8	8	SSD 240 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2061	629	9	8	15"	\N	manual	\N	2026-02-17 23:54:02.090047+03
2062	631	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2063	631	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2064	631	8	8	SSD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2065	631	9	8	MB27V13FS51; MB27V13FS51	\N	manual	\N	2026-02-17 23:54:02.090047+03
2066	631	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2067	631	10	11	408-KazakovRA	\N	manual	\N	2026-02-17 23:54:02.090047+03
2068	631	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2069	631	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2070	631	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2071	634	6	8	Core i5-12500 3,00 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2072	634	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2073	634	8	8	SSD 512 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2074	634	9	8	MB27V13FS51	\N	manual	\N	2026-02-17 23:54:02.090047+03
2075	634	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2076	634	10	11	408-vilkovanv	\N	manual	\N	2026-02-17 23:54:02.090047+03
2077	634	10	12	DHCP (VLAN 207)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2078	634	10	13	Astra Linux 1.8 Special Edition	\N	manual	\N	2026-02-17 23:54:02.090047+03
2079	634	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2080	637	6	8	Core i5-12500 3,00 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2081	637	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2082	637	8	8	SSD 512 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2083	637	9	8	MB27V13FS51	\N	manual	\N	2026-02-17 23:54:02.090047+03
2084	637	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2085	637	10	11	408b-lobanovave	\N	manual	\N	2026-02-17 23:54:02.090047+03
2086	637	10	12	DHCP (VLAN 207)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2087	637	10	13	Astra Linux 1.8 Special Edition	\N	manual	\N	2026-02-17 23:54:02.090047+03
2088	637	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2089	639	6	8	Core i3-370m 2,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2090	639	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2091	639	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2092	639	10	11	Центр-VAIO	\N	manual	\N	2026-02-17 23:54:02.090047+03
2093	639	10	13	Win7 Home (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2094	639	10	14	Avast	\N	manual	\N	2026-02-17 23:54:02.090047+03
2095	640	6	8	Core i5-7200U	\N	manual	\N	2026-02-17 23:54:02.090047+03
2096	640	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2097	640	8	8	1ТБ +; 128ГБ (SSD)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2098	640	9	8	15,6"	\N	manual	\N	2026-02-17 23:54:02.090047+03
2099	640	10	11	409-W10p64-144	\N	manual	\N	2026-02-17 23:54:02.090047+03
2100	640	10	12	10.1.4.144	\N	manual	\N	2026-02-17 23:54:02.090047+03
2101	640	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2102	640	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2103	642	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2104	642	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2105	642	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2106	642	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
2107	642	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2108	642	10	11	409-w10p64-170	\N	manual	\N	2026-02-17 23:54:02.090047+03
2109	642	10	12	10.1.4.170	\N	manual	\N	2026-02-17 23:54:02.090047+03
2110	642	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2111	642	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2112	645	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2113	645	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2114	645	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2115	645	9	8	ASUS 23.8" BE249QLB	\N	manual	\N	2026-02-17 23:54:02.090047+03
2116	645	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2117	645	10	11	409-W10p64-168	\N	manual	\N	2026-02-17 23:54:02.090047+03
2118	645	10	12	10.1.4.168	\N	manual	\N	2026-02-17 23:54:02.090047+03
2119	645	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2120	645	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2121	648	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2122	648	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2123	648	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2124	648	9	8	ASUS 23.8" BE249QLB	\N	manual	\N	2026-02-17 23:54:02.090047+03
2125	648	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2126	648	10	11	409-w10p64-37	\N	manual	\N	2026-02-17 23:54:02.090047+03
2127	648	10	12	10.1.4.37	\N	manual	\N	2026-02-17 23:54:02.090047+03
2128	648	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2129	648	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2130	650	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2131	650	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2132	650	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
2133	650	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
2134	650	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2135	650	10	11	AfanasievAJ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2136	650	10	12	оптика\n192.168.10.179	\N	manual	\N	2026-02-17 23:54:02.090047+03
2137	650	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2138	650	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
2139	653	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2140	653	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2141	653	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
2142	653	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
2143	653	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2144	653	10	11	409-w10p64-183	\N	manual	\N	2026-02-17 23:54:02.090047+03
2145	653	10	12	10.1.4.183	\N	manual	\N	2026-02-17 23:54:02.090047+03
2146	653	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2147	653	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
2148	656	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2149	656	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2150	656	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2151	656	9	8	BenQ GL 2450 (спис.)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2152	656	9	10	От мобистов	\N	manual	\N	2026-02-17 23:54:02.090047+03
2153	656	10	11	411-w10p64-174	\N	manual	\N	2026-02-17 23:54:02.090047+03
2154	656	10	12	10.1.1.174	\N	manual	\N	2026-02-17 23:54:02.090047+03
2155	656	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2156	656	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2157	658	6	8	Core i3-2100 3,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2158	658	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2159	658	8	8	SSD 512 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2160	658	9	8	Dell E2314H	\N	manual	\N	2026-02-17 23:54:02.090047+03
2161	658	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2162	658	10	11	417-W10P64-182	\N	manual	\N	2026-02-17 23:54:02.090047+03
2163	658	10	12	10.1.4.182	\N	manual	\N	2026-02-17 23:54:02.090047+03
2164	658	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2165	658	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2166	661	6	8	Core i5-8250U 1,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2167	661	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2168	661	8	8	SSD 256 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2169	661	9	8	15,6"	\N	manual	\N	2026-02-17 23:54:02.090047+03
2170	661	10	11	417-w10p64-234	\N	manual	\N	2026-02-17 23:54:02.090047+03
2171	661	10	12	10.1.4.234	\N	manual	\N	2026-02-17 23:54:02.090047+03
2172	661	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2173	661	10	14	---	\N	manual	\N	2026-02-17 23:54:02.090047+03
2174	663	6	8	Core i5-10400 2,90 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2175	663	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2176	663	8	8	SSD 512 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2177	663	9	8	Benq EW2430	\N	manual	\N	2026-02-17 23:54:02.090047+03
2178	663	9	10	190269	\N	manual	\N	2026-02-17 23:54:02.090047+03
2179	663	10	11	416-w10p64-181	\N	manual	\N	2026-02-17 23:54:02.090047+03
2180	663	10	12	10.1.4.181	\N	manual	\N	2026-02-17 23:54:02.090047+03
2181	663	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2182	663	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2183	665	6	8	Core i5-10400 2,90 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2184	665	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2185	665	8	8	HDD - 1 TB	\N	manual	\N	2026-02-17 23:54:02.090047+03
2186	665	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
2187	665	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2188	665	10	11	419-W10P64-100	\N	manual	\N	2026-02-17 23:54:02.090047+03
2189	665	10	12	10.10.10.100	\N	manual	\N	2026-02-17 23:54:02.090047+03
2190	665	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2191	665	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
2192	667	6	8	Core i5-3330 3,2 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2193	667	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2194	667	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2195	667	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
2196	667	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2197	667	10	11	420-w10p64-141	\N	manual	\N	2026-02-17 23:54:02.090047+03
2198	667	10	12	10.10.10.141	\N	manual	\N	2026-02-17 23:54:02.090047+03
2199	667	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2200	667	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
2201	669	6	8	Core i3-2100 3,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2202	669	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2203	669	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2204	669	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
2205	669	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2206	669	10	11	420-w10p64-125	\N	manual	\N	2026-02-17 23:54:02.090047+03
2207	669	10	12	10.10.10.125	\N	manual	\N	2026-02-17 23:54:02.090047+03
2208	669	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2209	669	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
2210	671	6	8	Core i5 – 12450H, 2,00ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2211	671	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2212	671	8	8	SSD 250 ГБ; SSD 1Т	\N	manual	\N	2026-02-17 23:54:02.090047+03
2213	671	9	8	15,6"	\N	manual	\N	2026-02-17 23:54:02.090047+03
2214	671	10	11	Note-Belokopytov	\N	manual	\N	2026-02-17 23:54:02.090047+03
2215	671	10	12	не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
2216	671	10	13	Win11 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2217	671	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2218	673	6	8	А	\N	manual	\N	2026-02-17 23:54:02.090047+03
2219	673	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2220	673	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2221	673	9	8	Samsung S22C200; Samsung S22C200.	\N	manual	\N	2026-02-17 23:54:02.090047+03
2222	673	9	10	МЦ.04.2\nМЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
2223	673	10	11	420-w10p64-156	\N	manual	\N	2026-02-17 23:54:02.090047+03
2224	673	10	12	10.10.10.156	\N	manual	\N	2026-02-17 23:54:02.090047+03
2225	673	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2226	673	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2227	676	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2228	676	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2229	676	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2230	676	9	8	Benq GL2450; Benq GL2450	\N	manual	\N	2026-02-17 23:54:02.090047+03
2231	676	10	11	420-w10p64-77	\N	manual	\N	2026-02-17 23:54:02.090047+03
2232	676	10	12	10.10.10.77	\N	manual	\N	2026-02-17 23:54:02.090047+03
2233	676	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2234	676	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2235	679	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2236	679	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2237	679	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2238	679	9	8	Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
2239	679	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2240	679	10	11	420-w10p64-26	\N	manual	\N	2026-02-17 23:54:02.090047+03
2241	679	10	12	10.10.10.26	\N	manual	\N	2026-02-17 23:54:02.090047+03
2242	679	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2243	679	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2244	682	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2245	682	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2246	682	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2247	682	9	8	Philips 273V7QJAB; Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
2248	682	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2249	682	10	11	420-W10p64-129	\N	manual	\N	2026-02-17 23:54:02.090047+03
2250	682	10	12	10.10.10.129	\N	manual	\N	2026-02-17 23:54:02.090047+03
2251	682	10	13	Win10pro x64	\N	manual	\N	2026-02-17 23:54:02.090047+03
2252	682	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2253	686	6	8	Core i3-2120 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2254	686	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2255	686	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2256	686	9	8	Dell U2412M	\N	manual	\N	2026-02-17 23:54:02.090047+03
2257	686	9	10	001353	\N	manual	\N	2026-02-17 23:54:02.090047+03
2258	686	10	11	420-W10p64-140	\N	manual	\N	2026-02-17 23:54:02.090047+03
2259	686	10	12	10.10.10.140	\N	manual	\N	2026-02-17 23:54:02.090047+03
2260	686	10	13	Win10pro x64	\N	manual	\N	2026-02-17 23:54:02.090047+03
2261	686	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2262	688	6	8	Core i5-10400 2,90 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2263	688	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2264	688	8	8	HDD - 1 TB; SSD - 240 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2265	688	9	8	AOC 27P2Q; NEC AS221WM	\N	manual	\N	2026-02-17 23:54:02.090047+03
2266	688	9	10	МЦ.04\nНИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2267	688	10	11	421-w10p64-21	\N	manual	\N	2026-02-17 23:54:02.090047+03
2268	688	10	12	10.10.10.21	\N	manual	\N	2026-02-17 23:54:02.090047+03
2269	688	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2270	688	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2271	691	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2272	691	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2273	691	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2274	691	9	8	Samsung S27F358FWI; Samsung S27F358FWI	\N	manual	\N	2026-02-17 23:54:02.090047+03
2275	691	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2276	691	10	11	421-w10p64-172	\N	manual	\N	2026-02-17 23:54:02.090047+03
2277	691	10	12	10.10.10.172	\N	manual	\N	2026-02-17 23:54:02.090047+03
2278	691	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2279	691	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2280	694	6	8	Core i7-8700T 2,40 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2281	694	7	9	12 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2282	694	8	8	SSD 128 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2283	694	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
2284	694	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2285	694	10	11	421-w10h64-192	\N	manual	\N	2026-02-17 23:54:02.090047+03
2286	694	10	12	10.10.10.192	\N	manual	\N	2026-02-17 23:54:02.090047+03
2287	694	10	13	Win10 Home (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2288	694	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2289	697	6	8	Core i9-13900KF 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2290	697	7	9	64 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2291	697	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2292	697	9	8	Aser XV322QK; ASUS 32" PA328Q IPS LED 4K	\N	manual	\N	2026-02-17 23:54:02.090047+03
2293	697	9	10	МОЛ Карлов С.Н.\n00-000257	\N	manual	\N	2026-02-17 23:54:02.090047+03
2294	697	10	11	422-W10p64-58	\N	manual	\N	2026-02-17 23:54:02.090047+03
2295	697	10	12	10.2.2.58	\N	manual	\N	2026-02-17 23:54:02.090047+03
2296	697	10	13	Win11 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2297	697	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2298	701	6	8	Core i7-7700К 4,5 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2299	701	7	9	64 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2300	701	8	8	512ГБ (SSD); 2 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2301	701	9	8	Philips 273V7QJAB; Benq GL2450	\N	manual	\N	2026-02-17 23:54:02.090047+03
2302	701	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2303	701	10	11	505-W10p64-58-2	\N	manual	\N	2026-02-17 23:54:02.090047+03
2304	701	10	12	10.2.2.218	\N	manual	\N	2026-02-17 23:54:02.090047+03
2305	701	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2306	701	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2307	704	6	8	Core i3-4160 3,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2308	704	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2309	704	8	8	2 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2310	704	9	8	SMART Board 8055i	\N	manual	\N	2026-02-17 23:54:02.090047+03
2311	704	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2312	704	10	11	403-W10P64-70	\N	manual	\N	2026-02-17 23:54:02.090047+03
2313	704	10	12	10.2.2.70	\N	manual	\N	2026-02-17 23:54:02.090047+03
2314	704	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2315	704	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2316	706	6	8	E5-2603x2/X10DRH-C-WinServer	\N	manual	\N	2026-02-17 23:54:02.090047+03
2317	706	7	9	64 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2318	706	8	8	2x4ТБ; 2x240ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2319	706	10	11	505-W2016-serv	\N	manual	\N	2026-02-17 23:54:02.090047+03
2320	706	10	12	10.2.2.53	\N	manual	\N	2026-02-17 23:54:02.090047+03
2321	706	10	13	Windows Server 2016	\N	manual	\N	2026-02-17 23:54:02.090047+03
2322	706	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2323	709	6	8	Core i9-13900KF 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2324	709	7	9	64 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2325	709	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2326	709	9	8	ASUS 32" PA328Q IPS LED 4K; ACER XV322QK	\N	manual	\N	2026-02-17 23:54:02.090047+03
2327	709	9	10	00-000259\nМОЛ Карлов С.Н.	\N	manual	\N	2026-02-17 23:54:02.090047+03
2328	709	10	11	422-W10P64-57	\N	manual	\N	2026-02-17 23:54:02.090047+03
2329	709	10	12	10.2.2.57	\N	manual	\N	2026-02-17 23:54:02.090047+03
2330	709	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2331	709	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2332	713	6	8	Core i7-13700КF 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2333	713	7	9	32 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2334	713	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2335	713	9	8	Aser XV322QK; ASUS 32" PA328Q IPS LED 4K	\N	manual	\N	2026-02-17 23:54:02.090047+03
2336	713	9	10	МОЛ Карлов С.Н.\n00-000258	\N	manual	\N	2026-02-17 23:54:02.090047+03
2337	713	10	11	422-W10P64-70	\N	manual	\N	2026-02-17 23:54:02.090047+03
2338	713	10	12	10.2.2.140	\N	manual	\N	2026-02-17 23:54:02.090047+03
2339	713	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2340	713	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2341	717	6	8	Core i7-13700КF 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2342	717	7	9	32 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2343	717	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2344	717	9	8	Aser XV322QK	\N	manual	\N	2026-02-17 23:54:02.090047+03
2345	717	9	10	МОЛ Карлов С.Н.	\N	manual	\N	2026-02-17 23:54:02.090047+03
2346	717	10	11	422-W10P64-155	\N	manual	\N	2026-02-17 23:54:02.090047+03
2347	717	10	12	10.2.2.155	\N	manual	\N	2026-02-17 23:54:02.090047+03
2348	717	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2349	717	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2350	720	6	8	Core i7-7700К 4,5 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2351	720	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2352	720	8	8	512ГБ (SSD); 2 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2353	720	9	8	Benq 32" EW3270ZL	\N	manual	\N	2026-02-17 23:54:02.090047+03
2354	720	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2355	720	10	11	422-W10P64-40	\N	manual	\N	2026-02-17 23:54:02.090047+03
2356	720	10	12	10.2.2.40	\N	manual	\N	2026-02-17 23:54:02.090047+03
2357	720	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2358	720	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2359	723	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2360	723	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2361	723	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2362	723	9	8	AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
2363	723	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2364	723	10	11	422-W10P64-135	\N	manual	\N	2026-02-17 23:54:02.090047+03
2365	723	10	12	10.2.2.135	\N	manual	\N	2026-02-17 23:54:02.090047+03
2366	723	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2367	723	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2368	726	6	8	Core i9-13900KF 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2369	726	7	9	64 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2370	726	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2371	726	9	8	Aser XV322QK; Benq 32" EW3270ZL	\N	manual	\N	2026-02-17 23:54:02.090047+03
2372	726	9	10	МОЛ Карлов С.Н.\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2373	726	10	11	422-W10P64-55	\N	manual	\N	2026-02-17 23:54:02.090047+03
2374	726	10	12	10.2.2.55	\N	manual	\N	2026-02-17 23:54:02.090047+03
2375	726	10	13	Win11 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2376	726	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2377	730	6	8	Core i7-13700КF 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2378	730	7	9	32 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2379	730	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2380	730	9	8	Aser XV322QK	\N	manual	\N	2026-02-17 23:54:02.090047+03
2381	730	9	10	МОЛ Карлов С.Н.	\N	manual	\N	2026-02-17 23:54:02.090047+03
2382	730	10	11	422-W10P64-76	\N	manual	\N	2026-02-17 23:54:02.090047+03
2383	730	10	12	10.2.2.76	\N	manual	\N	2026-02-17 23:54:02.090047+03
2384	730	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2385	730	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2386	732	6	8	Core i7-13700КF 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2387	732	7	9	32 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2388	732	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2389	732	9	8	Aser XV322QK; AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
2390	732	9	10	МОЛ Карлов С.Н\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2391	732	10	11	422-W10P64-65	\N	manual	\N	2026-02-17 23:54:02.090047+03
2392	732	10	12	10.2.2.65	\N	manual	\N	2026-02-17 23:54:02.090047+03
2393	732	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2394	732	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2395	735	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2396	735	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2397	735	8	8	2 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2398	735	9	8	Benq 32" EW3270ZL	\N	manual	\N	2026-02-17 23:54:02.090047+03
2399	735	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2400	735	10	11	505-W10P64-51	\N	manual	\N	2026-02-17 23:54:02.090047+03
2401	735	10	12	10.2.2.51	\N	manual	\N	2026-02-17 23:54:02.090047+03
2402	735	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2403	735	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2404	738	6	8	Core i7-4770 3,40 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2405	738	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2406	738	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2407	738	9	8	Benq 32" EW3270ZL	\N	manual	\N	2026-02-17 23:54:02.090047+03
2408	738	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2409	738	10	11	422-w10p64-52	\N	manual	\N	2026-02-17 23:54:02.090047+03
2410	738	10	12	10.2.2.52	\N	manual	\N	2026-02-17 23:54:02.090047+03
2411	738	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2412	738	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2413	741	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2414	741	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2415	741	8	8	2 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2416	741	9	8	Benq 32" EW3270ZL	\N	manual	\N	2026-02-17 23:54:02.090047+03
2417	741	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2418	741	10	11	505-W10P64-215	\N	manual	\N	2026-02-17 23:54:02.090047+03
2419	741	10	12	10.2.2.215	\N	manual	\N	2026-02-17 23:54:02.090047+03
2420	741	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2421	741	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2422	744	6	8	Core i3-2100 3,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2423	744	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2424	744	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2425	744	9	8	Dell E2314H	\N	manual	\N	2026-02-17 23:54:02.090047+03
2426	744	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2427	744	10	11	423-W10P64-54	\N	manual	\N	2026-02-17 23:54:02.090047+03
2428	744	10	12	10.2.2.54	\N	manual	\N	2026-02-17 23:54:02.090047+03
2429	744	10	13	Win10 Home (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2430	744	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2431	746	6	8	Core i7-4770K 3,5 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2432	746	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2433	746	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2434	746	9	8	Benq GL2450	\N	manual	\N	2026-02-17 23:54:02.090047+03
2435	746	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2436	746	10	11	403-astra	\N	manual	\N	2026-02-17 23:54:02.090047+03
2437	746	10	12	не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
2438	746	10	13	Astra Linux Special Edition 1.8	\N	manual	\N	2026-02-17 23:54:02.090047+03
2439	746	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2440	748	9	8	Benq 32" EW3270ZL	\N	manual	\N	2026-02-17 23:54:02.090047+03
2441	748	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2442	749	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2443	749	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2444	749	8	8	2 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2445	749	9	8	Samsung C32F391FWI	\N	manual	\N	2026-02-17 23:54:02.090047+03
2446	749	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2447	749	10	11	422-W10P64-64	\N	manual	\N	2026-02-17 23:54:02.090047+03
2448	749	10	12	10.2.2.64	\N	manual	\N	2026-02-17 23:54:02.090047+03
2449	749	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2450	749	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
2451	753	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2452	753	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2453	753	8	8	2 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2454	753	9	8	Benq 32" EW3270ZL	\N	manual	\N	2026-02-17 23:54:02.090047+03
2455	753	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2456	753	10	11	422-W10P64-49	\N	manual	\N	2026-02-17 23:54:02.090047+03
2457	753	10	12	10.2.2.49	\N	manual	\N	2026-02-17 23:54:02.090047+03
2458	753	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2459	753	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
2460	756	6	8	Core i7-7500U	\N	manual	\N	2026-02-17 23:54:02.090047+03
2461	756	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2462	756	8	8	2ТБ + 128 ГБ (SSD)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2463	756	9	8	15,6"	\N	manual	\N	2026-02-17 23:54:02.090047+03
2464	756	10	13	Win10 Home (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2465	756	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
2466	758	6	8	Core 2 Duo E8400 3.00 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2467	758	7	9	3 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2468	758	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2469	758	9	8	Dell U214Hb	\N	manual	\N	2026-02-17 23:54:02.090047+03
2470	758	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2471	758	10	11	501-w8p64-74	\N	manual	\N	2026-02-17 23:54:02.090047+03
2472	758	10	12	не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
2473	758	10	13	Win8.1(x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2474	758	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2475	760	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2476	760	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2477	760	8	8	SSD -256 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2478	760	9	8	AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
2479	760	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2480	760	10	11	501-w10p64-74	\N	manual	\N	2026-02-17 23:54:02.090047+03
2481	760	10	12	10.2.2.74	\N	manual	\N	2026-02-17 23:54:02.090047+03
2482	760	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2483	760	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2484	762	6	8	Core2 Quad Q9300 3.00 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2485	762	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2486	762	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2487	762	9	8	AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
2488	762	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2489	762	10	11	Prom1	\N	manual	\N	2026-02-17 23:54:02.090047+03
2490	762	10	12	Не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
2491	762	10	13	Win8.1(x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2492	762	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2493	764	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2494	764	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2495	764	8	8	SSD -256 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2496	764	9	8	NEC MultiSync EA243WM	\N	manual	\N	2026-02-17 23:54:02.090047+03
2497	764	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2498	764	10	11	501-W10P64-44	\N	manual	\N	2026-02-17 23:54:02.090047+03
2499	764	10	12	10.2.2.44	\N	manual	\N	2026-02-17 23:54:02.090047+03
2500	764	10	13	Win10(x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2501	764	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2502	767	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2503	767	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2504	767	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2505	767	9	8	LG Flatron W2242T	\N	manual	\N	2026-02-17 23:54:02.090047+03
2506	767	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2507	767	10	11	501-ShabaylovSE	\N	manual	\N	2026-02-17 23:54:02.090047+03
2508	767	10	12	Не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
2509	767	10	13	Win8.1(x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2510	767	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2511	770	6	8	Core 2 Duo E8400 3,0ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2512	770	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2513	770	8	8	250 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2514	770	9	8	NEC MultiSync E231W	\N	manual	\N	2026-02-17 23:54:02.090047+03
2515	770	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2516	770	10	11	501a-w10p64-77	\N	manual	\N	2026-02-17 23:54:02.090047+03
2517	770	10	12	Не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
2518	770	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2519	770	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2520	773	6	8	Core i3-2100 3,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2521	773	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2522	773	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2523	773	9	8	Philips 273V7QJAB/01/00	\N	manual	\N	2026-02-17 23:54:02.090047+03
2524	773	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2525	773	10	11	501-W7P64-217	\N	manual	\N	2026-02-17 23:54:02.090047+03
2526	773	10	12	10.2.2.217	\N	manual	\N	2026-02-17 23:54:02.090047+03
2527	773	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2528	773	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2529	775	6	8	Core 2 Duo T5800 2,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2530	775	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2531	775	8	8	300 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2532	775	9	8	17"	\N	manual	\N	2026-02-17 23:54:02.090047+03
2533	775	9	10	______	\N	manual	\N	2026-02-17 23:54:02.090047+03
2534	775	10	11	609-2-PC	\N	manual	\N	2026-02-17 23:54:02.090047+03
2535	775	10	12	не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
2536	775	10	13	Win7 Ultimate (x32)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2537	775	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
2538	777	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2539	777	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2540	777	8	8	SSD -256 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2541	777	9	8	AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
2542	777	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2543	777	10	11	501-w10p64-162	\N	manual	\N	2026-02-17 23:54:02.090047+03
2544	777	10	12	10.2.2.162	\N	manual	\N	2026-02-17 23:54:02.090047+03
2545	777	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2546	777	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2547	779	6	8	Core i7-4770 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2548	779	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2549	779	8	8	SSD - 240 ГБ; 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2550	779	9	8	Benq BL2201	\N	manual	\N	2026-02-17 23:54:02.090047+03
2551	779	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2552	779	10	11	501E-W10P64-192	\N	manual	\N	2026-02-17 23:54:02.090047+03
2553	779	10	12	10.2.2.192	\N	manual	\N	2026-02-17 23:54:02.090047+03
2554	779	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2555	779	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2556	781	6	8	Core i5-3470 3,2 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2557	781	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2558	781	8	8	SSD - 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2559	781	9	8	MB27V13FS51	\N	manual	\N	2026-02-17 23:54:02.090047+03
2560	781	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2561	781	10	11	501D-W10P64-118	\N	manual	\N	2026-02-17 23:54:02.090047+03
2562	781	10	12	10.2.2.118	\N	manual	\N	2026-02-17 23:54:02.090047+03
2563	781	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2564	781	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2565	784	6	8	Core i5-10400 2,90 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2566	784	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2567	784	8	8	SSD - 120ГБ; HDD - 1 TB	\N	manual	\N	2026-02-17 23:54:02.090047+03
2568	784	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
2569	784	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2570	784	10	11	525A-MEKEKOVV	\N	manual	\N	2026-02-17 23:54:02.090047+03
2571	784	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2572	784	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2573	784	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2574	787	6	8	Core i7-4790	\N	manual	\N	2026-02-17 23:54:02.090047+03
2575	787	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2576	787	8	8	SSD -500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2577	787	9	8	Philips 273V7QJAB/01/00	\N	manual	\N	2026-02-17 23:54:02.090047+03
2578	787	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2579	787	10	11	525A-KOPTEVON	\N	manual	\N	2026-02-17 23:54:02.090047+03
2580	787	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2581	787	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2582	787	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2583	789	6	8	Core i5-12500 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2584	789	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2585	789	8	8	SSD 512 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2586	789	9	8	Dell E214H	\N	manual	\N	2026-02-17 23:54:02.090047+03
2587	789	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
2588	789	10	11	525-SidorovAA	\N	manual	\N	2026-02-17 23:54:02.090047+03
2589	789	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2590	789	10	13	Astra Linux Special Edition	\N	manual	\N	2026-02-17 23:54:02.090047+03
2591	789	10	14	KES 12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2592	792	6	8	Core i5-10400 2,90 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2593	792	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2594	792	8	8	HDD - 1 TB; SSD - 240 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2595	792	9	8	MB27V13FS51; MB27V13FS51	\N	manual	\N	2026-02-17 23:54:02.090047+03
2596	792	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2597	792	10	11	501K-BARKOVFE	\N	manual	\N	2026-02-17 23:54:02.090047+03
2598	792	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2599	792	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2600	792	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2601	796	6	8	Athlon 3150U 2,40 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2602	796	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2603	796	8	8	SSD 240 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2604	796	9	8	15"	\N	manual	\N	2026-02-17 23:54:02.090047+03
2605	796	10	11	HP 15s-eq1436	\N	manual	\N	2026-02-17 23:54:02.090047+03
2606	796	10	12	не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
2607	796	10	13	Win11H(x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2608	796	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2609	798	6	8	Core i5-12450H 2,00ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2610	798	7	9	16ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2611	798	8	8	SSD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2612	798	9	8	15"	\N	manual	\N	2026-02-17 23:54:02.090047+03
2613	798	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2614	800	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2615	800	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2616	800	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2617	800	9	8	Nec E222W; Nec Multisync E231W	\N	manual	\N	2026-02-17 23:54:02.090047+03
2618	800	9	10	МЦ.04.1\nМЦ.04.1	\N	manual	\N	2026-02-17 23:54:02.090047+03
2619	800	10	11	501K-MITROSHINAA	\N	manual	\N	2026-02-17 23:54:02.090047+03
2620	800	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2621	800	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2622	800	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2623	804	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2624	804	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2625	804	8	8	SSD -500 ГБ; HDD - 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2626	804	9	8	AOC 27P2Q; AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
2627	804	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2628	804	10	11	501k-vinogradovamv	\N	manual	\N	2026-02-17 23:54:02.090047+03
2629	804	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2630	804	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2631	804	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2632	807	6	8	Core i5-3550 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2633	807	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2634	807	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2635	807	9	8	AOC 27P2Q; AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
2636	807	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2637	807	10	11	501K-PEREPELKINY	\N	manual	\N	2026-02-17 23:54:02.090047+03
2638	807	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2639	807	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2640	807	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2641	811	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2642	811	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2643	811	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2644	811	9	8	AOC 27P2Q; AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
2645	811	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2646	811	10	11	501K-KholmanskikhEM	\N	manual	\N	2026-02-17 23:54:02.090047+03
2647	811	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2648	811	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2649	811	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2650	815	6	8	Core i7-6700 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2651	815	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2652	815	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2653	815	9	8	Dell U2412M; Acer RT240Y	\N	manual	\N	2026-02-17 23:54:02.090047+03
2654	815	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2655	815	10	11	501k-IminovUE	\N	manual	\N	2026-02-17 23:54:02.090047+03
2656	815	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2657	815	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2658	815	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2659	818	6	8	Core i5-2500 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2660	818	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2661	818	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2662	818	9	8	AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
2663	818	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2664	818	10	11	501k-MingalevaVB	\N	manual	\N	2026-02-17 23:54:02.090047+03
2665	818	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2666	818	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2667	818	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2668	820	6	8	Core i7-M620 2,67 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2669	820	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2670	820	8	8	320 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2671	820	9	8	15,6"	\N	manual	\N	2026-02-17 23:54:02.090047+03
2672	820	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2673	820	10	11	514-w7p64-24	\N	manual	\N	2026-02-17 23:54:02.090047+03
2674	820	10	12	10.2.2.24	\N	manual	\N	2026-02-17 23:54:02.090047+03
2675	820	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2676	820	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2677	822	6	8	Core i5-12500 3,00 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2678	822	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2679	822	8	8	SSD 512 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2680	822	9	8	MB27V13FS51	\N	manual	\N	2026-02-17 23:54:02.090047+03
2681	822	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2682	822	10	11	501k-reutje	\N	manual	\N	2026-02-17 23:54:02.090047+03
2683	822	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2684	822	10	13	Astra Linux 1.8  Special Edition	\N	manual	\N	2026-02-17 23:54:02.090047+03
2685	822	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2686	824	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2687	824	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2688	824	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2689	824	9	8	MB27V13FS51	\N	manual	\N	2026-02-17 23:54:02.090047+03
2690	824	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2691	824	10	11	501K-RODRIGESAA	\N	manual	\N	2026-02-17 23:54:02.090047+03
2692	824	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2693	824	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2694	824	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2695	826	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2696	826	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2697	826	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2698	826	9	8	Samsung 27" C27F390FHI; Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
2699	826	9	10	МЦ.04\nМЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
2700	826	10	11	501k-w10p64	\N	manual	\N	2026-02-17 23:54:02.090047+03
2701	826	10	12	не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
2702	826	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2703	826	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2704	830	6	8	Core i5-12500 3,00 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2705	830	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2706	830	8	8	SSD 512 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2707	830	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
2708	830	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2709	830	10	11	501k-AleksandrovDD	\N	manual	\N	2026-02-17 23:54:02.090047+03
2710	830	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2711	830	10	13	Astra Linux 1.8  Special Edition	\N	manual	\N	2026-02-17 23:54:02.090047+03
2712	830	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2713	832	6	8	Core i5-10400 2,90 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2714	832	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2715	832	8	8	HDD - 1 TB; SSD - 240 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2716	832	9	8	Philips 243V7QJABF; Philips 243V7QJABF	\N	manual	\N	2026-02-17 23:54:02.090047+03
2717	832	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2718	832	10	11	503-w10p64-93	\N	manual	\N	2026-02-17 23:54:02.090047+03
2719	832	10	12	10.2.2.93	\N	manual	\N	2026-02-17 23:54:02.090047+03
2720	832	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2721	832	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2722	836	6	8	Core i3-4160 3,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2723	836	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2724	836	8	8	2 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2725	836	9	8	LG Flatron L192WS	\N	manual	\N	2026-02-17 23:54:02.090047+03
2726	836	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
2727	836	10	11	503-w10p64-92	\N	manual	\N	2026-02-17 23:54:02.090047+03
2728	836	10	12	10.2.2.92	\N	manual	\N	2026-02-17 23:54:02.090047+03
2729	836	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2730	836	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2731	838	6	8	Core i3-2120 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2732	838	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2733	838	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2734	838	9	8	Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
2735	838	10	11	503-w7p64-83	\N	manual	\N	2026-02-17 23:54:02.090047+03
2736	838	10	12	10.2.2.83	\N	manual	\N	2026-02-17 23:54:02.090047+03
2737	838	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2738	838	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2739	840	6	8	Core i3-2120 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2740	840	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2741	840	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2742	840	9	8	Nec MultiSync V221W	\N	manual	\N	2026-02-17 23:54:02.090047+03
2743	840	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2744	840	10	11	503-w7p64-84	\N	manual	\N	2026-02-17 23:54:02.090047+03
2745	840	10	12	10.2.2.84	\N	manual	\N	2026-02-17 23:54:02.090047+03
2746	840	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2747	840	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2748	842	6	8	(Core i5-12500 3,00 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2749	842	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2750	842	8	8	SSD 512 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2751	842	9	8	Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
2752	842	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2753	842	10	11	503-ryadinskyea	\N	manual	\N	2026-02-17 23:54:02.090047+03
2754	842	10	12	DHCP (VLAN 400)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2755	842	10	13	Astra Linux 1.8 Special Edition	\N	manual	\N	2026-02-17 23:54:02.090047+03
2756	842	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2757	844	6	8	Core i5-2300 2,8 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2758	844	7	9	8 Гб	\N	manual	\N	2026-02-17 23:54:02.090047+03
2759	844	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2760	844	9	8	Samsung SyncMaster SA450 (19")	\N	manual	\N	2026-02-17 23:54:02.090047+03
2761	844	10	11	Ws-503-dsp	\N	manual	\N	2026-02-17 23:54:02.090047+03
2762	844	10	12	Не в сети \n(был 10.2.2.81)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2763	844	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2764	844	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
2765	846	6	8	Core i7-9700 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2766	846	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2767	846	8	8	SSD 480 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2768	846	9	8	Dell E2314H	\N	manual	\N	2026-02-17 23:54:02.090047+03
2769	846	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2770	846	10	11	503-w10p64-157	\N	manual	\N	2026-02-17 23:54:02.090047+03
2771	846	10	12	10.2.2.157	\N	manual	\N	2026-02-17 23:54:02.090047+03
2772	846	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2773	846	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2774	849	6	8	Core i3-3240 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2775	849	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2776	849	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2777	849	9	8	Samsung SyncMaster SA450 (19")	\N	manual	\N	2026-02-17 23:54:02.090047+03
2778	849	10	11	503-w7p64-158	\N	manual	\N	2026-02-17 23:54:02.090047+03
2779	849	10	12	10.2.2.158	\N	manual	\N	2026-02-17 23:54:02.090047+03
2780	849	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2781	849	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2782	851	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2783	851	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2784	851	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
2785	851	9	8	AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
2786	851	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2787	851	10	11	503-w10p64-27	\N	manual	\N	2026-02-17 23:54:02.090047+03
2788	851	10	12	10.2.2.27	\N	manual	\N	2026-02-17 23:54:02.090047+03
2789	851	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2790	851	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2791	853	6	8	Pentium Dual-Core E5700 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2792	853	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2793	853	8	8	300 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2794	853	9	8	Samsung SyncMaster S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
2795	853	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
2796	853	10	11	503-W7P32-173	\N	manual	\N	2026-02-17 23:54:02.090047+03
2797	853	10	12	10.2.2.173	\N	manual	\N	2026-02-17 23:54:02.090047+03
2798	853	10	13	Win7 Pro (x32)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2799	853	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2800	855	6	8	Core i3-2100 3,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2801	855	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2802	855	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2803	855	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
2804	855	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2805	855	10	11	504-W7P64-174	\N	manual	\N	2026-02-17 23:54:02.090047+03
2806	855	10	12	10.2.2.174	\N	manual	\N	2026-02-17 23:54:02.090047+03
2807	855	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2808	855	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2809	857	6	8	Core i5-12500 3,00 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2810	857	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2811	857	8	8	SSD 512 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2812	857	9	8	MB27V13FS51	\N	manual	\N	2026-02-17 23:54:02.090047+03
2813	857	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2814	857	10	11	503-vladimirovis	\N	manual	\N	2026-02-17 23:54:02.090047+03
2815	857	10	12	DHCP (VLAN 400)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2816	857	10	13	Astra Linux 1.8 Special Edition	\N	manual	\N	2026-02-17 23:54:02.090047+03
2817	857	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2818	859	6	8	Core i5-12500 3,00 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2819	859	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2820	859	8	8	SSD 512 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2821	859	9	8	MB27V13FS51	\N	manual	\N	2026-02-17 23:54:02.090047+03
2822	859	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2823	859	10	11	503-kaminvp	\N	manual	\N	2026-02-17 23:54:02.090047+03
2824	859	10	12	DHCP (VLAN 400)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2825	859	10	13	Astra Linux 1.8 Special Edition	\N	manual	\N	2026-02-17 23:54:02.090047+03
2826	859	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2827	861	6	8	Core i5-12500 3,00 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2828	861	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2829	861	8	8	SSD 512 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2830	861	9	8	MB27V13FS51	\N	manual	\N	2026-02-17 23:54:02.090047+03
2831	861	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2832	861	10	11	503-kulikovatv	\N	manual	\N	2026-02-17 23:54:02.090047+03
2833	861	10	12	DHCP (VLAN 400)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2834	861	10	13	Astra Linux 1.8 Special Edition	\N	manual	\N	2026-02-17 23:54:02.090047+03
2835	861	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2836	863	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2837	863	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2838	863	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2839	863	9	8	Lenovo L27e-30 27"	\N	manual	\N	2026-02-17 23:54:02.090047+03
2840	863	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2841	863	10	11	505-CherenkovaYA	\N	manual	\N	2026-02-17 23:54:02.090047+03
2842	863	10	12	DHCP (VLAN 208)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2843	863	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2844	863	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2845	866	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2846	866	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2847	866	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2848	866	9	8	Lenovo L27e-30 27"	\N	manual	\N	2026-02-17 23:54:02.090047+03
2849	866	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2850	866	10	11	505-GorohovEI	\N	manual	\N	2026-02-17 23:54:02.090047+03
2851	866	10	12	DHCP (VLAN 208)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2852	866	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2853	866	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2854	869	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2855	869	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2856	869	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2857	869	9	8	Lenovo L27e-30 27"	\N	manual	\N	2026-02-17 23:54:02.090047+03
2858	869	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2859	869	10	11	505-RYBALCHENKO	\N	manual	\N	2026-02-17 23:54:02.090047+03
2860	869	10	12	DHCP (VLAN 208)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2861	869	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2862	869	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2863	872	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2864	872	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2865	872	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2866	872	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
2867	872	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2868	872	10	11	505-RomashkovSN	\N	manual	\N	2026-02-17 23:54:02.090047+03
2869	872	10	12	DHCP (VLAN 208)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2870	872	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2871	872	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2872	875	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2873	875	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2874	875	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2875	875	9	8	Philips 273V7QJAB; Lenovo L27e-30 27"	\N	manual	\N	2026-02-17 23:54:02.090047+03
2876	875	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2877	875	10	11	505-TIKHONVN	\N	manual	\N	2026-02-17 23:54:02.090047+03
2878	875	10	12	DHCP (VLAN 208)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2879	875	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2880	875	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2881	879	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2882	879	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2883	879	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2884	879	9	8	Dell E2314H	\N	manual	\N	2026-02-17 23:54:02.090047+03
2885	879	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2886	879	10	11	505-TERYUKHOV	\N	manual	\N	2026-02-17 23:54:02.090047+03
2887	879	10	12	DHCP (VLAN 208)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2888	879	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2889	879	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2890	882	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2891	882	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2892	882	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2893	882	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
2894	882	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2895	882	10	11	505-LyubkinSS	\N	manual	\N	2026-02-17 23:54:02.090047+03
2896	882	10	12	DHCP (VLAN 208)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2897	882	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2898	882	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2899	885	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2900	885	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2901	885	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2902	885	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
2903	885	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2904	885	10	11	505-KUKAREKINAV	\N	manual	\N	2026-02-17 23:54:02.090047+03
2905	885	10	12	DHCP (VLAN 208)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2906	885	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2907	885	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2908	888	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2909	888	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2910	888	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2911	888	9	8	Dell E2314H	\N	manual	\N	2026-02-17 23:54:02.090047+03
2912	888	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2913	888	10	11	505-MelnikovEA	\N	manual	\N	2026-02-17 23:54:02.090047+03
2914	888	10	12	DHCP (VLAN 208)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2915	888	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2916	888	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2917	891	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2918	891	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2919	891	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2920	891	9	8	MB27V13FS51	\N	manual	\N	2026-02-17 23:54:02.090047+03
2921	891	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2922	891	10	11	505-BALABUKHAAN	\N	manual	\N	2026-02-17 23:54:02.090047+03
2923	891	10	12	DHCP (VLAN 208)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2924	891	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2925	891	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2926	894	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2927	894	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2928	894	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2929	894	9	8	AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
2930	894	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2931	894	10	11	505-GULYAEVAAM	\N	manual	\N	2026-02-17 23:54:02.090047+03
2932	894	10	12	DHCP (VLAN 208)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2933	894	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2934	894	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2935	897	6	8	Core i5-12500  3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2936	897	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2937	897	8	8	SSD 512 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2938	897	9	8	MB27V13FS51	\N	manual	\N	2026-02-17 23:54:02.090047+03
2939	897	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2940	897	10	11	505-ostrovskaya	\N	manual	\N	2026-02-17 23:54:02.090047+03
2941	897	10	12	DHCP (VLAN 208)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2942	897	10	13	Astra Linux 1.8 Special Edition	\N	manual	\N	2026-02-17 23:54:02.090047+03
2943	897	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2944	900	6	8	Core i5-12500  3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2945	900	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2946	900	8	8	SSD 512 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2947	900	9	8	MB27V13FS51	\N	manual	\N	2026-02-17 23:54:02.090047+03
2948	900	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2949	900	10	11	505-gricenkoev	\N	manual	\N	2026-02-17 23:54:02.090047+03
2950	900	10	12	DHCP (VLAN 208)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2951	900	10	13	Astra Linux 1.8 Special Edition	\N	manual	\N	2026-02-17 23:54:02.090047+03
2952	900	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2953	903	6	8	Core i5-12500 3,00 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2954	903	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2955	903	8	8	SSD 512 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2956	903	9	8	MB27V13FS51	\N	manual	\N	2026-02-17 23:54:02.090047+03
2957	903	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2958	903	10	11	505-drozdovays	\N	manual	\N	2026-02-17 23:54:02.090047+03
2959	903	10	12	DHCP (VLAN 400)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2960	903	10	13	Astra Linux 1.8 Special Edition	\N	manual	\N	2026-02-17 23:54:02.090047+03
2961	903	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2962	906	6	8	Core i5-12500 3,00 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2963	906	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2964	906	8	8	SSD 512 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2965	906	9	8	MB27V13FS51	\N	manual	\N	2026-02-17 23:54:02.090047+03
2966	906	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2967	906	10	11	113a-shilinav	\N	manual	\N	2026-02-17 23:54:02.090047+03
2968	906	10	12	DHCP (VLAN 208)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2969	906	10	13	Astra Linux 1.8 Special Edition	\N	manual	\N	2026-02-17 23:54:02.090047+03
2970	906	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
2971	909	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2972	909	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2973	909	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2974	909	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
2975	909	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
2976	909	10	11	505-DIKANEVBA	\N	manual	\N	2026-02-17 23:54:02.090047+03
2977	909	10	12	DHCP (VLAN 208)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
2978	909	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2979	909	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
2980	912	6	8	Core i5-2300 2,8 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2981	912	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2982	912	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2983	912	9	8	моноблок Lenovo 23"	\N	manual	\N	2026-02-17 23:54:02.090047+03
2984	912	10	11	lenovo	\N	manual	\N	2026-02-17 23:54:02.090047+03
2985	912	10	12	10.2.2.250	\N	manual	\N	2026-02-17 23:54:02.090047+03
2986	912	10	13	Win7 Home (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
2987	912	10	14	____	\N	manual	\N	2026-02-17 23:54:02.090047+03
2988	914	6	8	Core i5-2300 2,8 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2989	914	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2990	914	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2991	914	9	8	моноблок Lenovo 23"	\N	manual	\N	2026-02-17 23:54:02.090047+03
2992	916	6	8	Pentium Dual-Core T5800 2,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2993	916	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2994	916	8	8	300 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2995	916	9	8	17"	\N	manual	\N	2026-02-17 23:54:02.090047+03
2996	918	6	8	Core i3-2100 3,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
2997	918	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2998	918	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
2999	918	9	8	Benq EW2450	\N	manual	\N	2026-02-17 23:54:02.090047+03
3000	918	10	11	506-W7P64-251	\N	manual	\N	2026-02-17 23:54:02.090047+03
3001	918	10	12	10.2.2.251	\N	manual	\N	2026-02-17 23:54:02.090047+03
3002	918	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3003	918	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
3004	920	6	8	Core i5-3330 3,2 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3005	920	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3006	920	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3007	920	9	8	Nec Multisync EA222WMe	\N	manual	\N	2026-02-17 23:54:02.090047+03
3008	920	10	11	Admin	\N	manual	\N	2026-02-17 23:54:02.090047+03
3009	920	10	12	10.2.2.183	\N	manual	\N	2026-02-17 23:54:02.090047+03
3010	920	10	13	Win10 Korp (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3011	922	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3012	922	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3013	922	8	8	256 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3014	922	9	8	Lenovo L27e-30 27"	\N	manual	\N	2026-02-17 23:54:02.090047+03
3015	922	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3016	924	6	8	Core i5-12500  3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3017	924	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3018	924	8	8	SSD 512 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3019	924	9	8	MB27V13FS51	\N	manual	\N	2026-02-17 23:54:02.090047+03
3020	924	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3021	924	10	11	506-pushkov	\N	manual	\N	2026-02-17 23:54:02.090047+03
3022	924	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3023	927	6	8	Core i5-12500  3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3024	927	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3025	927	8	8	SSD 512 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3026	927	9	8	MB27V13FS51	\N	manual	\N	2026-02-17 23:54:02.090047+03
3027	927	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3028	929	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3029	929	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3030	929	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3031	929	9	8	AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
3032	929	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3033	929	10	11	509-W10P64-151	\N	manual	\N	2026-02-17 23:54:02.090047+03
3034	929	10	12	10.2.2.151	\N	manual	\N	2026-02-17 23:54:02.090047+03
3035	929	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3036	929	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3037	931	6	8	AMD Turion TL-58 1,9 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3038	931	7	9	2 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3039	931	8	8	200 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3040	931	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3041	931	10	11	501-W7P32-151	\N	manual	\N	2026-02-17 23:54:02.090047+03
3042	931	10	13	Win7 Pro (x32)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3043	931	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
3044	932	6	8	Core i7-3770 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3045	932	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3046	932	8	8	SSD 450 Гб	\N	manual	\N	2026-02-17 23:54:02.090047+03
3047	932	9	8	Samsung S24B300B	\N	manual	\N	2026-02-17 23:54:02.090047+03
3048	932	10	11	509-W10P64-130	\N	manual	\N	2026-02-17 23:54:02.090047+03
3049	932	10	12	10.2.2.130	\N	manual	\N	2026-02-17 23:54:02.090047+03
3050	932	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3051	932	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3052	933	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3053	933	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3054	933	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3055	933	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
3056	935	6	8	Core i5-12500 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3057	935	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3058	935	8	8	SSD 512 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3059	935	9	8	AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
3060	935	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3061	935	10	11	508-zemtsovava	\N	manual	\N	2026-02-17 23:54:02.090047+03
3062	935	10	12	Без сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
3063	935	10	13	Astra Linux Special Edition	\N	manual	\N	2026-02-17 23:54:02.090047+03
3064	935	10	14	KES 12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3065	938	6	8	Core i5-10400 2,90 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3066	938	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3067	938	8	8	HDD - 1 TB	\N	manual	\N	2026-02-17 23:54:02.090047+03
3068	938	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
3069	938	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3070	938	10	11	525-W10P64-211	\N	manual	\N	2026-02-17 23:54:02.090047+03
3071	938	10	12	10.2.2.211	\N	manual	\N	2026-02-17 23:54:02.090047+03
3072	938	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3073	938	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
3074	940	6	8	Core i3-4160 3,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3075	940	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3076	940	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3077	940	9	8	Samsung 24"S24D300H	\N	manual	\N	2026-02-17 23:54:02.090047+03
3078	940	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3079	940	10	11	422-W10p64-100	\N	manual	\N	2026-02-17 23:54:02.090047+03
3080	940	10	12	10.2.2.100	\N	manual	\N	2026-02-17 23:54:02.090047+03
3081	940	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3082	940	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
3083	943	6	8	Core i5-12450H 2,00ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3084	943	7	9	16ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3085	943	8	8	SSD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3086	943	9	8	15"	\N	manual	\N	2026-02-17 23:54:02.090047+03
3087	943	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3088	945	6	8	Core i5-2500K 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3089	945	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3090	945	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3091	945	9	8	Dell E2314HF	\N	manual	\N	2026-02-17 23:54:02.090047+03
3092	945	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3093	945	10	11	510-w10p64-79	\N	manual	\N	2026-02-17 23:54:02.090047+03
3094	945	10	12	10.2.2.79	\N	manual	\N	2026-02-17 23:54:02.090047+03
3095	945	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3096	945	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
3097	947	6	8	Core i3-4150 3,5 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3098	947	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3099	947	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3100	947	10	11	510-w10p64-156	\N	manual	\N	2026-02-17 23:54:02.090047+03
3101	947	10	12	10.2.2.156	\N	manual	\N	2026-02-17 23:54:02.090047+03
3102	947	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3103	947	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3104	949	6	8	Core i5-12450H 2,00ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3105	949	7	9	16ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3106	949	8	8	SSD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3107	949	9	8	15"	\N	manual	\N	2026-02-17 23:54:02.090047+03
3108	949	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3109	951	6	8	Core i3-4150 3,5 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3110	951	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3111	951	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3112	951	9	8	Philips 273V7QJAB; AOC 27P2Q - где?	\N	manual	\N	2026-02-17 23:54:02.090047+03
3113	951	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3114	951	10	11	510-w10p64-195	\N	manual	\N	2026-02-17 23:54:02.090047+03
3115	951	10	12	10.2.2.195	\N	manual	\N	2026-02-17 23:54:02.090047+03
3116	951	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3117	951	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3118	954	6	8	Core i5-12450H 2,00ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3119	954	7	9	16ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3120	954	8	8	SSD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3121	954	9	8	15"	\N	manual	\N	2026-02-17 23:54:02.090047+03
3122	954	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3123	956	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3124	956	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3125	956	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3126	956	9	8	Samsung S27F358FWI; Samsung S27F358FWI	\N	manual	\N	2026-02-17 23:54:02.090047+03
3127	956	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3128	956	10	11	510-BulgakovAY	\N	manual	\N	2026-02-17 23:54:02.090047+03
3129	956	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
3130	956	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3131	956	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3132	960	6	8	Core i3-1005G1 1,2 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3133	960	7	9	6 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3134	960	8	8	SSD 256 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3135	960	10	11	LAPTOP-LFJJV41R	\N	manual	\N	2026-02-17 23:54:02.090047+03
3136	960	10	13	Win10 Home (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3137	960	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
3138	961	6	8	Pentium Silver N5030	\N	manual	\N	2026-02-17 23:54:02.090047+03
3139	961	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3140	961	8	8	SSD 256 Gb	\N	manual	\N	2026-02-17 23:54:02.090047+03
3141	961	10	13	Win 10 Home (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3142	962	9	8	AOC 27P2Q; AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
3143	962	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3144	963	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3145	963	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3146	963	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3147	963	9	8	AOC 27P2Q; AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
3148	963	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3149	963	10	11	510-AbakumovaAA	\N	manual	\N	2026-02-17 23:54:02.090047+03
3150	963	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
3151	963	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3152	963	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3153	967	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3154	967	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3155	967	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3156	967	9	8	AOC 27P2Q; AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
3157	967	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3158	967	10	11	510-KlyucahrevaAD	\N	manual	\N	2026-02-17 23:54:02.090047+03
3159	967	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
3160	967	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3161	967	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
3162	971	6	8	Core i5-12450H 2,00ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3163	971	7	9	16ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3164	971	8	8	SSD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3165	971	9	8	15"	\N	manual	\N	2026-02-17 23:54:02.090047+03
3166	971	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3167	973	6	8	Core i5-10400 2,90 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3168	973	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3169	973	8	8	HDD - 1 TB; SSD - 240 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3170	973	9	8	AOC 27P2Q; AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
3171	973	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3172	973	10	11	510-W10P64-227	\N	manual	\N	2026-02-17 23:54:02.090047+03
3173	973	10	12	10.2.2.227	\N	manual	\N	2026-02-17 23:54:02.090047+03
3174	973	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3175	973	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
3176	977	6	8	Core i5-12500 3,00 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3177	977	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3178	977	8	8	SSD 512 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3179	977	9	8	MB27V13FS51	\N	manual	\N	2026-02-17 23:54:02.090047+03
3180	977	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3181	977	10	11	510-korbanyukOI	\N	manual	\N	2026-02-17 23:54:02.090047+03
3182	977	10	12	DHCP (VLAN 207)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3183	977	10	13	Astra Linux Special Edition 1.8	\N	manual	\N	2026-02-17 23:54:02.090047+03
3184	977	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3185	979	6	8	Core i5-12500 3,00 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3186	979	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3187	979	8	8	SSD 512 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3188	979	9	8	MB27V13FS51; Dell E2314HF	\N	manual	\N	2026-02-17 23:54:02.090047+03
3189	979	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3190	979	10	11	510-monakovva-210	\N	manual	\N	2026-02-17 23:54:02.090047+03
3191	979	10	12	10.2.2.210	\N	manual	\N	2026-02-17 23:54:02.090047+03
3192	979	10	13	Astra Linux Special Edition 1.8	\N	manual	\N	2026-02-17 23:54:02.090047+03
3193	979	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3194	982	6	8	Core i5-12500 3,00 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3195	982	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3196	982	8	8	SSD 512 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3197	982	9	8	Iiyama Prolite E2483HS	\N	manual	\N	2026-02-17 23:54:02.090047+03
3198	982	10	11	510-maltsevkm	\N	manual	\N	2026-02-17 23:54:02.090047+03
3199	982	10	12	DHCP (VLAN 207)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3200	982	10	13	Astra Linux Special Edition 1.8	\N	manual	\N	2026-02-17 23:54:02.090047+03
3201	982	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3202	985	6	8	Core i5-12500 3,00 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3203	985	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3204	985	8	8	SSD 512 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3205	985	9	8	AOC 27P2Q; AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
3206	985	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3207	985	10	11	510-MironovDA	\N	manual	\N	2026-02-17 23:54:02.090047+03
3208	985	10	12	10.2.2.102	\N	manual	\N	2026-02-17 23:54:02.090047+03
3209	985	10	13	Astra Linux 1.8 Special Edition	\N	manual	\N	2026-02-17 23:54:02.090047+03
3210	985	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3211	988	6	8	Core i9-9900K 3,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3212	988	7	9	32 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3213	988	8	8	1  ТБ (SSD)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3214	988	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
3215	988	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3216	988	10	11	511-w10p64-242	\N	manual	\N	2026-02-17 23:54:02.090047+03
3217	988	10	12	10.2.2.242	\N	manual	\N	2026-02-17 23:54:02.090047+03
3218	988	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3219	988	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
3220	991	6	8	Core i5-12500 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3221	991	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3222	991	8	8	SSD 512 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3223	991	9	8	MB27V13FS51	\N	manual	\N	2026-02-17 23:54:02.090047+03
3224	991	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3225	991	10	11	511-astra	\N	manual	\N	2026-02-17 23:54:02.090047+03
3226	991	10	13	Astra Linux Special Edition 1.8	\N	manual	\N	2026-02-17 23:54:02.090047+03
3227	991	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3228	994	6	8	Core i9-9900K 3,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3229	994	7	9	32 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3230	994	8	8	1  ТБ (SSD)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3231	994	9	8	Philips 273V7QJAB; Philips 240V5Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
3232	994	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3233	994	10	11	511-malakhovpc-108	\N	manual	\N	2026-02-17 23:54:02.090047+03
3234	994	10	12	10.2.2.108\n192.168.10.156	\N	manual	\N	2026-02-17 23:54:02.090047+03
3235	994	10	13	Ubuntu 20	\N	manual	\N	2026-02-17 23:54:02.090047+03
3236	998	6	8	Core i9-9900K 3,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3237	998	7	9	32 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3238	998	8	8	1  ТБ (SSD)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3239	998	9	8	Philips 273V7QJAB; Samsung C32F391FWI	\N	manual	\N	2026-02-17 23:54:02.090047+03
3240	998	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3241	998	10	11	511-mukanovpc-224	\N	manual	\N	2026-02-17 23:54:02.090047+03
3242	998	10	12	10.2.2.224\n192.168.10.224	\N	manual	\N	2026-02-17 23:54:02.090047+03
3243	998	10	13	Ubuntu 20	\N	manual	\N	2026-02-17 23:54:02.090047+03
3244	1002	6	8	Core i9-9900K 3,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3245	1002	7	9	32 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3246	1002	8	8	1  ТБ (SSD)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3247	1002	9	8	Philips 273V7QJAB; Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
3248	1002	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3249	1002	10	11	User-PC2	\N	manual	\N	2026-02-17 23:54:02.090047+03
3250	1002	10	12	10.2.2.212\n192.168.10.210	\N	manual	\N	2026-02-17 23:54:02.090047+03
3251	1002	10	13	Ubuntu 20	\N	manual	\N	2026-02-17 23:54:02.090047+03
3252	1006	6	8	Core i9-9900K 3,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3253	1006	7	9	32 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3254	1006	8	8	1  ТБ (SSD)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3255	1006	10	11	User-PC6	\N	manual	\N	2026-02-17 23:54:02.090047+03
3256	1006	10	12	10.2.2.213\n192.168.10.214	\N	manual	\N	2026-02-17 23:54:02.090047+03
3257	1006	10	13	Ubuntu 20	\N	manual	\N	2026-02-17 23:54:02.090047+03
3258	1008	6	8	Core i9-9900K 3,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3259	1008	7	9	32 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3260	1008	8	8	1  ТБ (SSD)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3261	1008	9	8	Philips 273V7QJAB; Samsung 27" C27F390FHI	\N	manual	\N	2026-02-17 23:54:02.090047+03
3262	1008	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3263	1008	10	11	511-voronovapc-109	\N	manual	\N	2026-02-17 23:54:02.090047+03
3264	1008	10	12	10.2.2.109	\N	manual	\N	2026-02-17 23:54:02.090047+03
3265	1008	10	13	Ubuntu 20	\N	manual	\N	2026-02-17 23:54:02.090047+03
3266	1012	9	8	Samsung S27F358FWI; Samsung S27F358FWI	\N	manual	\N	2026-02-17 23:54:02.090047+03
3267	1012	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3268	1014	6	8	Core i5-12500 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3269	1014	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3270	1014	8	8	SSD 512 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3271	1014	9	8	MB27V13FS51	\N	manual	\N	2026-02-17 23:54:02.090047+03
3272	1014	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3273	1014	10	11	511-vostrikovpc	\N	manual	\N	2026-02-17 23:54:02.090047+03
3274	1014	10	12	10.2.2.170	\N	manual	\N	2026-02-17 23:54:02.090047+03
3275	1014	10	13	Ubuntu 20	\N	manual	\N	2026-02-17 23:54:02.090047+03
3276	1014	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3277	1017	6	8	Core i7-8550u	\N	manual	\N	2026-02-17 23:54:02.090047+03
3278	1017	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3279	1017	8	8	SSD 256 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3280	1017	9	8	15,6"; Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
3281	1017	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3282	1017	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3283	1020	6	8	Core i5 10210U 1,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3284	1020	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3285	1020	8	8	SSD 512 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3286	1020	9	8	15,6"	\N	manual	\N	2026-02-17 23:54:02.090047+03
3287	1020	10	13	Win10H(x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3288	1022	6	8	Core i5 10210U 1,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3289	1022	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3290	1022	8	8	SSD 512 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3291	1022	9	8	15,6"	\N	manual	\N	2026-02-17 23:54:02.090047+03
3292	1022	10	13	Win10H(x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3293	1024	6	8	Core i5-10300H 2,5 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3294	1024	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3295	1024	8	8	500 ГБ SSD	\N	manual	\N	2026-02-17 23:54:02.090047+03
3296	1024	9	8	17"	\N	manual	\N	2026-02-17 23:54:02.090047+03
3297	1024	10	13	Win10 Home (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3298	1024	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
3299	1026	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3300	1026	7	9	6 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3301	1026	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3302	1026	9	8	Benq GL2460	\N	manual	\N	2026-02-17 23:54:02.090047+03
3303	1026	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3304	1026	10	11	512-w10p64-181	\N	manual	\N	2026-02-17 23:54:02.090047+03
3305	1026	10	12	10.2.2.181	\N	manual	\N	2026-02-17 23:54:02.090047+03
3306	1026	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3307	1026	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
3308	1028	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3309	1028	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3310	1028	8	8	SSD 500 ГБ; HDD 1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
3311	1028	9	8	Lenovo L27e-30 27"	\N	manual	\N	2026-02-17 23:54:02.090047+03
3312	1028	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3313	1028	10	11	518-W10P64-30	\N	manual	\N	2026-02-17 23:54:02.090047+03
3314	1028	10	12	10.2.2.30	\N	manual	\N	2026-02-17 23:54:02.090047+03
3315	1028	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3316	1028	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
3317	1031	6	8	Pentium Dual-Core E5700 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3318	1031	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3319	1031	8	8	320 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3320	1031	9	8	LG Flatron L192WS	\N	manual	\N	2026-02-17 23:54:02.090047+03
3321	1031	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
3322	1031	10	11	518-w7p64	\N	manual	\N	2026-02-17 23:54:02.090047+03
3323	1031	10	12	10.2.2.249	\N	manual	\N	2026-02-17 23:54:02.090047+03
3324	1031	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3325	1031	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
3326	1033	6	8	Core i3-2100 3,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3327	1033	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3328	1033	8	8	SSD 480 ГБ; HDD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3329	1033	9	8	Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
3330	1033	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
3331	1033	10	11	518-W7p64-253	\N	manual	\N	2026-02-17 23:54:02.090047+03
3332	1033	10	12	10.2.2.253	\N	manual	\N	2026-02-17 23:54:02.090047+03
3333	1033	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3334	1033	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
3335	1037	6	8	Core i5-10400 2,90 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3336	1037	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3337	1037	8	8	HDD - 1 TB; SSD - 240 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3338	1037	9	8	Asus VX239 IPS HDMI MHL	\N	manual	\N	2026-02-17 23:54:02.090047+03
3339	1037	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3340	1037	10	11	520-w10p64-222	\N	manual	\N	2026-02-17 23:54:02.090047+03
3341	1037	10	12	10.1.4.222	\N	manual	\N	2026-02-17 23:54:02.090047+03
3342	1037	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3343	1037	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3344	1039	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3345	1039	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3346	1039	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3347	1039	9	8	Samsung S27F358FWI	\N	manual	\N	2026-02-17 23:54:02.090047+03
3348	1039	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3349	1039	10	11	520-IvanovaEA	\N	manual	\N	2026-02-17 23:54:02.090047+03
3350	1039	10	12	DHCP (VLAN 205)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
3351	1039	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3352	1039	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
3353	1041	6	8	AMD 3020e 1.20 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3354	1041	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3355	1041	8	8	SSD 240 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3356	1041	9	8	15"	\N	manual	\N	2026-02-17 23:54:02.090047+03
3357	1041	10	11	520-W10H64-223	\N	manual	\N	2026-02-17 23:54:02.090047+03
3358	1041	10	12	10.1.4.223	\N	manual	\N	2026-02-17 23:54:02.090047+03
3359	1041	10	13	Win10H(x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3360	1041	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
3361	1043	6	8	Core i3-4170 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3362	1043	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3363	1043	8	8	SSD - 120 ГБ; HDD - 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3364	1043	9	8	AOC 24P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
3365	1043	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3366	1043	10	11	524-BoldyrevaEV	\N	manual	\N	2026-02-17 23:54:02.090047+03
3367	1043	10	12	DHCP (VLAN 205)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
3368	1043	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3369	1043	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3370	1045	6	8	Core i3-2100 3,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3371	1045	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3372	1045	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3373	1045	9	8	Dell 27"	\N	manual	\N	2026-02-17 23:54:02.090047+03
3374	1045	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3375	1045	10	11	524-MahovaAV	\N	manual	\N	2026-02-17 23:54:02.090047+03
3376	1045	10	12	DHCP (VLAN 205)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
3377	1045	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3378	1045	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3379	1048	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3380	1048	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3381	1048	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3382	1048	9	8	LG Flatron W2261VP	\N	manual	\N	2026-02-17 23:54:02.090047+03
3383	1048	10	11	524-computer	\N	manual	\N	2026-02-17 23:54:02.090047+03
3384	1048	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
3385	1048	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3386	1048	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
3387	1050	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3388	1050	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3389	1050	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3390	1050	9	8	Benq GL2450	\N	manual	\N	2026-02-17 23:54:02.090047+03
3391	1050	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3392	1050	10	11	524-AndrosovaMV	\N	manual	\N	2026-02-17 23:54:02.090047+03
3393	1050	10	12	DHCP (VLAN 205)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
3394	1050	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3395	1050	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
3396	1052	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3397	1052	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3398	1052	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3399	1052	9	8	Benq G2220HD	\N	manual	\N	2026-02-17 23:54:02.090047+03
3400	1052	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3401	1052	10	11	524-Androsova	\N	manual	\N	2026-02-17 23:54:02.090047+03
3402	1052	10	12	DHCP (VLAN 205)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
3403	1052	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3404	1052	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
3405	1054	6	8	Core i3-10105 3,70 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3406	1054	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3407	1054	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3408	1054	9	8	Nec E222W	\N	manual	\N	2026-02-17 23:54:02.090047+03
3409	1054	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3410	1054	10	11	524-BogunDK	\N	manual	\N	2026-02-17 23:54:02.090047+03
3411	1054	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
3412	1054	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3413	1054	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3414	1057	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3415	1057	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3416	1057	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
3417	1057	9	8	ASUS PA249Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
3418	1057	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3419	1057	10	11	524-KozlovaAM	\N	manual	\N	2026-02-17 23:54:02.090047+03
3420	1057	10	12	DHCP (VLAN 205)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
3421	1057	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3422	1057	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3423	1060	6	8	Core i7-3770 3,4ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3424	1060	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3425	1060	8	8	SSD 480 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3426	1060	9	8	BENQ  GL2450	\N	manual	\N	2026-02-17 23:54:02.090047+03
3427	1060	10	11	524-VoinovichenkoTG	\N	manual	\N	2026-02-17 23:54:02.090047+03
3428	1060	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
3429	1060	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3430	1060	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3431	1063	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3432	1063	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3433	1063	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
3434	1063	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
3435	1063	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3436	1063	10	11	604-KalyakinaTM	\N	manual	\N	2026-02-17 23:54:02.090047+03
3437	1063	10	12	оптика (без IP)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3438	1063	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3439	1063	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
3440	1066	6	8	Core i5-3330S 2,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3441	1066	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3442	1066	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3443	1066	10	11	604-KalyakinaTM	\N	manual	\N	2026-02-17 23:54:02.090047+03
3444	1066	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
3445	1066	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3446	1066	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
3447	1067	6	8	Core i5-3330S 2,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3448	1067	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3449	1067	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3450	1067	10	11	604-ChernomortsevaII	\N	manual	\N	2026-02-17 23:54:02.090047+03
3451	1067	10	12	оптика\n192.168.10.53	\N	manual	\N	2026-02-17 23:54:02.090047+03
3452	1067	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3453	1067	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
3454	1068	6	8	Core i5-3330S 2,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3455	1068	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3456	1068	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3457	1068	10	11	604-BelovaON	\N	manual	\N	2026-02-17 23:54:02.090047+03
3458	1068	10	12	оптика\n192.168.10.52	\N	manual	\N	2026-02-17 23:54:02.090047+03
3459	1068	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3460	1068	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
3461	1069	6	8	Core i3-540 3,07 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3462	1069	7	9	6 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3463	1069	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3464	1069	9	8	Dell P2219H	\N	manual	\N	2026-02-17 23:54:02.090047+03
3465	1069	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3466	1069	10	11	604-BelovaON	\N	manual	\N	2026-02-17 23:54:02.090047+03
3467	1069	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
3468	1069	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3469	1069	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
3470	1071	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3471	1071	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3472	1071	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
3473	1071	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
3474	1071	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3475	1071	10	11	604-ShavlovaNL	\N	manual	\N	2026-02-17 23:54:02.090047+03
3476	1071	10	12	оптика\n192.168.10.30	\N	manual	\N	2026-02-17 23:54:02.090047+03
3477	1071	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3478	1071	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
3479	1075	6	8	Core i5-3330S 2,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3480	1075	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3481	1075	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3482	1075	10	11	604-ShavlovaNL	\N	manual	\N	2026-02-17 23:54:02.090047+03
3483	1075	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
3484	1075	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3485	1075	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
3486	1076	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3487	1076	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3488	1076	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3489	1076	9	8	Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
3490	1076	10	11	604-SOKOLOVDA	\N	manual	\N	2026-02-17 23:54:02.090047+03
3491	1076	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
3492	1076	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3493	1076	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
3494	1078	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3495	1078	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3496	1078	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3497	1078	9	8	Samsung 27" C27F390FHI	\N	manual	\N	2026-02-17 23:54:02.090047+03
3498	1078	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3499	1078	10	11	717-W10p64	\N	manual	\N	2026-02-17 23:54:02.090047+03
3500	1078	10	12	оптика\n192.168.10.59	\N	manual	\N	2026-02-17 23:54:02.090047+03
3501	1078	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3502	1078	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
3503	1081	6	8	Core i7-2600 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3504	1081	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3505	1081	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3506	1081	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
3507	1081	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3508	1081	10	11	604-PopovaEV	\N	manual	\N	2026-02-17 23:54:02.090047+03
3509	1081	10	12	оптика\n192.168.10.54	\N	manual	\N	2026-02-17 23:54:02.090047+03
3510	1081	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3511	1081	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
3512	1084	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3513	1084	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3514	1084	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3515	1084	9	8	Samsung 27" C27F390FHI	\N	manual	\N	2026-02-17 23:54:02.090047+03
3516	1084	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3517	1084	10	11	604-AfanasievaJL	\N	manual	\N	2026-02-17 23:54:02.090047+03
3518	1084	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
3519	1084	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3520	1084	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3521	1086	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3522	1086	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3523	1086	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3524	1086	9	8	Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
3525	1086	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
3526	1086	10	11	604-AfanasievaJL	\N	manual	\N	2026-02-17 23:54:02.090047+03
3527	1086	10	12	оптика\n192.168.10.51	\N	manual	\N	2026-02-17 23:54:02.090047+03
3528	1086	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3529	1086	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
3530	1088	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3531	1088	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3532	1088	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3533	1088	9	8	Samsung 27" C27F390FHI	\N	manual	\N	2026-02-17 23:54:02.090047+03
3534	1088	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3535	1088	10	11	604-NovoselovDD	\N	manual	\N	2026-02-17 23:54:02.090047+03
3536	1088	10	12	оптика\n192.168.10.58	\N	manual	\N	2026-02-17 23:54:02.090047+03
3537	1088	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3538	1088	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
3539	1091	6	8	Core i5-650 3,20 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3540	1091	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3541	1091	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3542	1091	9	8	NEC MultiSync EA223WN	\N	manual	\N	2026-02-17 23:54:02.090047+03
3543	1091	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3544	1091	10	11	604-NovoselovDD	\N	manual	\N	2026-02-17 23:54:02.090047+03
3545	1091	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
3546	1091	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3547	1091	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
3548	1093	6	8	Core i3-2100 3,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3549	1093	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3550	1093	8	8	SSD 240 ГБ; HDD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3551	1093	9	8	AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
3552	1093	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3553	1093	10	11	IvanovaAI	\N	manual	\N	2026-02-17 23:54:02.090047+03
3554	1093	10	12	оптика\n192.168.10.76	\N	manual	\N	2026-02-17 23:54:02.090047+03
3555	1093	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3556	1093	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
3557	1096	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3558	1096	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3559	1096	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3560	1096	9	8	MB27V13FS51	\N	manual	\N	2026-02-17 23:54:02.090047+03
3561	1096	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3562	1096	10	11	604-IvanovaAI	\N	manual	\N	2026-02-17 23:54:02.090047+03
3563	1096	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
3564	1096	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3565	1096	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3566	1098	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3567	1098	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3568	1098	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
3569	1098	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
3570	1098	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3571	1098	10	11	604-RoshchupkinMG	\N	manual	\N	2026-02-17 23:54:02.090047+03
3572	1098	10	12	оптика (без IP)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3573	1098	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3574	1098	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
3575	1101	6	8	Core i5-6200U 2,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3576	1101	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3577	1101	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3578	1101	9	8	Моноблок Asus V220IC	\N	manual	\N	2026-02-17 23:54:02.090047+03
3579	1101	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3580	1101	10	11	610-w10h64-42	\N	manual	\N	2026-02-17 23:54:02.090047+03
3581	1101	10	12	не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
3582	1101	10	13	Win10 Home (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3583	1101	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
3584	1103	6	8	Core i5-3570 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3585	1103	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3586	1103	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3587	1103	9	8	Nec AccuSync AS241W	\N	manual	\N	2026-02-17 23:54:02.090047+03
3588	1103	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3589	1103	10	11	609-w10p64-40	\N	manual	\N	2026-02-17 23:54:02.090047+03
3590	1103	10	12	10.1.4.40	\N	manual	\N	2026-02-17 23:54:02.090047+03
3591	1103	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3592	1103	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
3593	1105	6	8	Core i3-540 3,07 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3594	1105	7	9	6 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3595	1105	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3596	1105	9	8	Nec MultiSync E222W	\N	manual	\N	2026-02-17 23:54:02.090047+03
3597	1105	9	10	МЦ.04.1	\N	manual	\N	2026-02-17 23:54:02.090047+03
3598	1105	10	11	609-w10p64-41	\N	manual	\N	2026-02-17 23:54:02.090047+03
3599	1105	10	12	10.1.4.41	\N	manual	\N	2026-02-17 23:54:02.090047+03
3600	1105	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3601	1105	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3602	1107	6	8	Pentium Dual-Core E5300  2,60 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3603	1107	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3604	1107	8	8	SSD 250 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3605	1107	9	8	Acer V243H	\N	manual	\N	2026-02-17 23:54:02.090047+03
3606	1107	10	11	609-w7p64-199	\N	manual	\N	2026-02-17 23:54:02.090047+03
3607	1107	10	12	не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
3608	1107	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3609	1107	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
3610	1109	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3611	1109	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3612	1109	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3613	1109	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
3614	1109	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3615	1109	10	11	610-w10p64-7	\N	manual	\N	2026-02-17 23:54:02.090047+03
3616	1109	10	12	10.1.4.7	\N	manual	\N	2026-02-17 23:54:02.090047+03
3617	1109	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3618	1109	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
3619	1112	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3620	1112	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3621	1112	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3622	1112	9	8	Samsung S22C200; Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
3623	1112	9	10	МЦ.04.2\nМЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
3624	1112	10	11	612-w10p64-106	\N	manual	\N	2026-02-17 23:54:02.090047+03
3625	1112	10	12	10.10.10.106	\N	manual	\N	2026-02-17 23:54:02.090047+03
3626	1112	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3627	1112	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3628	1115	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3629	1115	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3630	1115	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3631	1115	9	8	Philips 273V7QJAB; Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
3632	1115	9	10	МЦ.04\nМЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
3633	1115	10	11	612-w7p64-154	\N	manual	\N	2026-02-17 23:54:02.090047+03
3634	1115	10	12	10.10.10.154	\N	manual	\N	2026-02-17 23:54:02.090047+03
3635	1115	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3636	1115	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
3637	1118	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3638	1118	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3639	1118	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3640	1118	9	8	Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
3641	1118	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
3642	1118	10	11	612-w7M64-105	\N	manual	\N	2026-02-17 23:54:02.090047+03
3643	1118	10	12	10.10.10.105	\N	manual	\N	2026-02-17 23:54:02.090047+03
3644	1118	10	13	Win7 Max (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3645	1118	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
3646	1120	6	8	Core i7-9700 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3647	1120	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3648	1120	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3649	1120	9	8	Philips 273V7QJAB; Samsung Syncmaster SA450	\N	manual	\N	2026-02-17 23:54:02.090047+03
3650	1120	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3651	1120	10	11	612-w10p64-150	\N	manual	\N	2026-02-17 23:54:02.090047+03
3652	1120	10	12	не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
3653	1120	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3654	1120	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
3655	1123	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3656	1123	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3657	1123	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3658	1123	9	8	Samsung SyncMaster S24B300	\N	manual	\N	2026-02-17 23:54:02.090047+03
3659	1123	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
3660	1123	10	11	612-w10p64-117	\N	manual	\N	2026-02-17 23:54:02.090047+03
3661	1123	10	12	10.10.10.117	\N	manual	\N	2026-02-17 23:54:02.090047+03
3662	1123	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3663	1123	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3664	1125	6	8	Core i7-9700 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3665	1125	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3666	1125	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3667	1125	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
3668	1125	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3669	1125	10	11	612-w10p64	\N	manual	\N	2026-02-17 23:54:02.090047+03
3670	1125	10	12	не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
3671	1125	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3672	1125	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
3673	1127	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3674	1127	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3675	1127	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3676	1127	9	8	Nec MultiSync V221W	\N	manual	\N	2026-02-17 23:54:02.090047+03
3677	1127	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3678	1127	10	11	612-w7p64-5	\N	manual	\N	2026-02-17 23:54:02.090047+03
3679	1127	10	12	не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
3680	1127	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3681	1127	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
3682	1129	6	8	Core i7-9700 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3683	1129	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3684	1129	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3685	1129	9	8	Philips 273V7QJAB; Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
3686	1129	9	10	МЦ.04\nМЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
3687	1129	10	11	612-w10p64-5	\N	manual	\N	2026-02-17 23:54:02.090047+03
3688	1129	10	12	10.10.10.5	\N	manual	\N	2026-02-17 23:54:02.090047+03
3689	1129	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3690	1129	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
3691	1132	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3692	1132	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3693	1132	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3694	1132	9	8	LG Flatron E2251; Samsung C32F391FWI	\N	manual	\N	2026-02-17 23:54:02.090047+03
3695	1132	9	10	?\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3696	1132	10	11	612-W10P64-64	\N	manual	\N	2026-02-17 23:54:02.090047+03
3697	1132	10	12	10.10.10.64	\N	manual	\N	2026-02-17 23:54:02.090047+03
3698	1132	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3699	1132	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
3700	1135	6	8	Core i7-1165G7 2,8 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3701	1135	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3702	1135	8	8	500 ГБ SSD; 1 ТБ HDD	\N	manual	\N	2026-02-17 23:54:02.090047+03
3703	1135	10	11	612-w10h64-230	\N	manual	\N	2026-02-17 23:54:02.090047+03
3704	1135	10	12	10.1.4.230	\N	manual	\N	2026-02-17 23:54:02.090047+03
3705	1135	10	13	Win10 Home (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3706	1135	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
3707	1136	6	8	Core i5-7500 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3708	1136	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3709	1136	8	8	250 Гб SSD+ 2 ТБ HDD	\N	manual	\N	2026-02-17 23:54:02.090047+03
3710	1136	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3711	1136	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
3712	1137	6	8	AMD 3020e 1.20 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3713	1137	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3714	1137	8	8	SSD 240 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3715	1137	9	8	15"	\N	manual	\N	2026-02-17 23:54:02.090047+03
3716	1137	10	13	Win10 Home (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3717	1139	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3718	1139	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3719	1139	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3720	1139	9	8	AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
3721	1139	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
3722	1139	10	11	406-RymkevichSN	\N	manual	\N	2026-02-17 23:54:02.090047+03
3723	1139	10	12	DHCP (VLAN 214)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3724	1139	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3725	1139	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3726	1142	6	8	Core i5-3330 3,2 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3727	1142	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3728	1142	8	8	SSD 500 ГБ; 1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
3729	1142	9	8	NEC  V221W	\N	manual	\N	2026-02-17 23:54:02.090047+03
3730	1142	9	10	МЦ.04.1	\N	manual	\N	2026-02-17 23:54:02.090047+03
3731	1142	10	11	406-Rymkevych	\N	manual	\N	2026-02-17 23:54:02.090047+03
3732	1142	10	12	не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
3733	1142	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3734	1142	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
3735	1145	6	8	Core i5 – 12450H, 2,00ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3736	1145	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3737	1145	8	8	SSD 250 ГБ; SSD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3738	1145	9	8	15,6"	\N	manual	\N	2026-02-17 23:54:02.090047+03
3739	1145	10	11	Rymkevich-Note	\N	manual	\N	2026-02-17 23:54:02.090047+03
3740	1145	10	12	не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
3741	1145	10	13	Win11 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3742	1147	6	8	Core i3-8100 3,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3743	1147	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3744	1147	8	8	SSD 250 ГБ; HDD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3745	1147	9	8	BENQ GW2760S	\N	manual	\N	2026-02-17 23:54:02.090047+03
3746	1147	9	10	МЦ.04 (001119)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3747	1147	10	11	701-POLYANSKYDV	\N	manual	\N	2026-02-17 23:54:02.090047+03
3748	1147	10	12	DHCP (VLAN 214)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3749	1147	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3750	1147	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3751	1149	6	8	Core i3-540 3,07 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3752	1149	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3753	1149	8	8	SSD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3754	1149	9	8	Dell U2412Mc	\N	manual	\N	2026-02-17 23:54:02.090047+03
3755	1149	9	10	МЦ.04 (001227)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3756	1149	10	11	701-polyanskiy	\N	manual	\N	2026-02-17 23:54:02.090047+03
3757	1149	10	12	не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
3758	1149	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3759	1149	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3760	1151	6	8	Core i3-2100 3,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3761	1151	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3762	1151	8	8	HDD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3763	1151	9	8	Dell U2412M	\N	manual	\N	2026-02-17 23:54:02.090047+03
3764	1151	9	10	МЦ.04 (001442)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3765	1151	10	11	701-PolozkovaJS	\N	manual	\N	2026-02-17 23:54:02.090047+03
3766	1151	10	12	не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
3767	1151	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3768	1151	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3769	1153	6	8	Core i7-7740X 4,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3770	1153	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3771	1153	8	8	SSD 500 ГБ; HDD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3772	1153	9	8	BENQ GW2765	\N	manual	\N	2026-02-17 23:54:02.090047+03
3773	1153	9	10	БП-001304 (Информ. - 000153)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3774	1153	10	11	701-SotnikovVA	\N	manual	\N	2026-02-17 23:54:02.090047+03
3775	1153	10	12	DHCP (VLAN 214)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3776	1153	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3777	1153	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3778	1156	6	8	Core i5-12400 2,5 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3779	1156	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3780	1156	8	8	SSD 500 ГБ; HDD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3781	1156	9	8	AOC34G2X	\N	manual	\N	2026-02-17 23:54:02.090047+03
3782	1156	9	10	БП-001314 (Информ. - 000279)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3783	1156	10	11	701-BORISOVYA	\N	manual	\N	2026-02-17 23:54:02.090047+03
3784	1156	10	12	DHCP (VLAN 214)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3785	1156	10	13	Win11pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3786	1156	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3787	1159	6	8	Core i5-12400 2,5 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3788	1159	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3789	1159	8	8	SSD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3790	1159	9	8	Samsung SyncMaster SA850 S24A850DW	\N	manual	\N	2026-02-17 23:54:02.090047+03
3791	1159	9	10	МЦ.04 (001253)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3792	1159	10	11	701-SERGEEVVA	\N	manual	\N	2026-02-17 23:54:02.090047+03
3793	1159	10	12	DHCP (VLAN 214)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3794	1159	10	13	Win11pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3795	1159	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3796	1162	6	8	Core i5-12400 2,5 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3797	1162	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3798	1162	8	8	SSD 250 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3799	1162	9	8	AOC 34G2X	\N	manual	\N	2026-02-17 23:54:02.090047+03
3800	1162	9	10	БП-001316 (Информ. - 000281)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3801	1162	10	11	701-VASILYEVAEL	\N	manual	\N	2026-02-17 23:54:02.090047+03
3802	1162	10	12	DHCP (VLAN 214)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3803	1162	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3804	1162	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3805	1164	6	8	Core i3-8100 3,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3806	1164	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3807	1164	8	8	SSD 250 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3808	1164	9	8	Dell P2720DC	\N	manual	\N	2026-02-17 23:54:02.090047+03
3809	1164	9	10	МЦ.04 (001459)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3810	1164	10	11	701-KOTKODD	\N	manual	\N	2026-02-17 23:54:02.090047+03
3811	1164	10	12	DHCP (VLAN 214)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3812	1164	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3813	1164	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3814	1167	6	8	Core i5-9400 2,9 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3815	1167	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3816	1167	8	8	HDD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3817	1167	9	8	Dell P2720DC; Dell P2720DC	\N	manual	\N	2026-02-17 23:54:02.090047+03
3818	1167	9	10	МЦ.04 (001457)\nМЦ.04 (001458)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3819	1167	10	11	701-RYAZANTSEVN	\N	manual	\N	2026-02-17 23:54:02.090047+03
3820	1167	10	12	DHCP (VLAN 214)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3821	1167	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3822	1167	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3823	1170	6	8	Core i7-8550U 1,8 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3824	1170	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3825	1170	8	8	SSD 250 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3826	1170	10	11	DESKTOP-HA2MGA5	\N	manual	\N	2026-02-17 23:54:02.090047+03
3827	1170	10	12	не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
3828	1170	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3829	1171	6	8	Core i9-9900 3,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3830	1171	7	9	64 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3831	1171	8	8	SSD 500 ГБ - 3 шт.; SSD 120 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3832	1171	9	8	Dell U3219W	\N	manual	\N	2026-02-17 23:54:02.090047+03
3833	1171	9	10	МЦ.04 (001620)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3834	1171	10	11	701-SHAFEROVAE	\N	manual	\N	2026-02-17 23:54:02.090047+03
3835	1171	10	12	DHCP (VLAN 214)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3836	1171	10	13	Win11pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3837	1171	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3838	1173	6	8	Core i7-10750H 2,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3839	1173	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3840	1173	8	8	SSD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3841	1173	10	11	DESKTOP-100QU7SO	\N	manual	\N	2026-02-17 23:54:02.090047+03
3842	1173	10	12	не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
3843	1173	10	13	Win11pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3844	1174	6	8	Core i5-12400 2,5 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3845	1174	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3846	1174	8	8	SSD 250 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3847	1174	9	8	AOC 34G2X	\N	manual	\N	2026-02-17 23:54:02.090047+03
3848	1174	9	10	БП-001315 (Информ. - 000280)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3849	1174	10	11	701-KANTURNM	\N	manual	\N	2026-02-17 23:54:02.090047+03
3850	1174	10	12	DHCP (VLAN 214)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3851	1174	10	13	Win11pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3852	1174	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3853	1176	6	8	Core i5-12400 2,5 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3854	1176	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3855	1176	8	8	HDD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3856	1176	9	8	AOC 34G2X	\N	manual	\N	2026-02-17 23:54:02.090047+03
3857	1176	9	10	БП-001317 (Информ. - 000282)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3858	1176	10	11	701-KUSHNIRENKO	\N	manual	\N	2026-02-17 23:54:02.090047+03
3859	1176	10	12	DHCP (VLAN 214)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3860	1176	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3861	1176	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3862	1178	6	8	Core i7-10750H 2,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3863	1178	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3864	1178	8	8	SSD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3865	1178	10	11	DESKTOP-5K78LR3	\N	manual	\N	2026-02-17 23:54:02.090047+03
3866	1178	10	12	не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
3867	1179	6	8	Core i3-4130 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3868	1179	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3869	1179	8	8	HDD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3870	1179	9	8	BENQ GL2410-B	\N	manual	\N	2026-02-17 23:54:02.090047+03
3871	1179	9	10	МЦ.04 (001219)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3872	1179	10	11	701-TEREBINAA	\N	manual	\N	2026-02-17 23:54:02.090047+03
3873	1179	10	12	DHCP (VLAN 214)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3874	1179	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3875	1179	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3876	1181	6	8	Core i5-12400 2,5 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3877	1181	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3878	1181	8	8	SSD 250 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3879	1181	9	8	AOC 34G2X; Dell U2412Mc	\N	manual	\N	2026-02-17 23:54:02.090047+03
3880	1181	9	10	БП-001312 (Информ. - 000277)\nб/н	\N	manual	\N	2026-02-17 23:54:02.090047+03
3881	1181	10	11	701-NOVIKOVBN	\N	manual	\N	2026-02-17 23:54:02.090047+03
3882	1181	10	12	DHCP (VLAN 214)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3883	1181	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3884	1181	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3885	1184	6	8	Core i7-8565U 1,8 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3886	1184	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3887	1184	8	8	SSD 250 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3888	1184	9	8	17"	\N	manual	\N	2026-02-17 23:54:02.090047+03
3889	1184	10	11	novikov-nout	\N	manual	\N	2026-02-17 23:54:02.090047+03
3890	1184	10	12	не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
3891	1184	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3892	1186	6	8	Core i3-8100 3,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3893	1186	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3894	1186	8	8	HDD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3895	1186	9	8	Dell P2720DC; Dell P2720DC	\N	manual	\N	2026-02-17 23:54:02.090047+03
3896	1186	9	10	МЦ.04 (001456)\nМЦ.04 (001455)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3897	1186	10	11	701-AKSENOVADK	\N	manual	\N	2026-02-17 23:54:02.090047+03
3898	1186	10	12	DHCP (VLAN 214)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3899	1186	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3900	1186	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3901	1189	6	8	Core i3-4130 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3902	1189	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3903	1189	8	8	HDD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3904	1189	9	8	BENQ GW2760G	\N	manual	\N	2026-02-17 23:54:02.090047+03
3905	1189	9	10	МЦ.04 (001139)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3906	1189	10	11	701-KARULINVP	\N	manual	\N	2026-02-17 23:54:02.090047+03
3907	1189	10	12	DHCP (VLAN 214)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3908	1189	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3909	1189	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3910	1191	6	8	Core i5-12400 2,5 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3911	1191	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3912	1191	8	8	HDD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3913	1191	9	8	AOC 34G2X	\N	manual	\N	2026-02-17 23:54:02.090047+03
3914	1191	9	10	БП-001313 (Информ. - 000278)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3915	1191	10	11	701-BOLSHAKOVAI	\N	manual	\N	2026-02-17 23:54:02.090047+03
3916	1191	10	12	DHCP (VLAN 214)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3917	1191	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3918	1191	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3919	1193	6	8	Core i7-8550U 1,8 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3920	1193	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3921	1193	8	8	SSD 250 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3922	1193	10	11	DESKTOP-HOGASN9	\N	manual	\N	2026-02-17 23:54:02.090047+03
3923	1193	10	12	не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
3924	1193	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3925	1194	6	8	Core i5-9400 2,9 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3926	1194	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3927	1194	8	8	SSD 250 ГБ; HDD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3928	1194	9	8	Dell U2412M	\N	manual	\N	2026-02-17 23:54:02.090047+03
3929	1194	9	10	МЦ.04 (001436)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3930	1194	10	11	807-PRESLITSKAY	\N	manual	\N	2026-02-17 23:54:02.090047+03
3931	1194	10	12	DHCP (VLAN 214)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3932	1194	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3933	1194	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3934	1196	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3935	1196	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3936	1196	8	8	HDD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3937	1196	9	8	Dell P2720DC	\N	manual	\N	2026-02-17 23:54:02.090047+03
3938	1196	9	10	МЦ.04 (001484)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3939	1196	10	11	701-SHELEPETKOJ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3940	1196	10	12	DHCP (VLAN 214)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3941	1196	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3942	1196	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
3943	1198	6	8	Pentium G3250 3,20 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
3944	1198	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3945	1198	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
3946	1198	9	8	Samsung SyncMaster P2270	\N	manual	\N	2026-02-17 23:54:02.090047+03
3947	1198	9	10	99036	\N	manual	\N	2026-02-17 23:54:02.090047+03
3948	1198	10	11	701-Shelepetko	\N	manual	\N	2026-02-17 23:54:02.090047+03
3949	1198	10	12	нет сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
3950	1198	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
3951	1198	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
95	14	6	8	Core i7-6500 2,5 ГГц	\N	manual	\N	2026-02-12 20:47:56.480176+03
96	14	7	9	8 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
97	14	8	8	SSD 500 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
98	14	10	11	DESKTOP-KQ06HS9	\N	manual	\N	2026-02-12 20:47:56.480176+03
99	14	10	12	не в сети	\N	manual	\N	2026-02-12 20:47:56.480176+03
100	14	10	13	Win10pro (x64)	\N	manual	\N	2026-02-12 20:47:56.480176+03
101	15	6	8	Core i5-12500 3,00 ГГц	\N	manual	\N	2026-02-12 20:47:56.480176+03
102	15	7	9	16 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
103	15	8	8	SSD 512 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
104	15	9	8	MB27V13FS51	\N	manual	\N	2026-02-12 20:47:56.480176+03
105	15	9	10	МЦ.04	\N	manual	\N	2026-02-12 20:47:56.480176+03
106	15	10	11	701-belohvostvi	\N	manual	\N	2026-02-12 20:47:56.480176+03
107	15	10	12	DHCP (VLAN 214)	\N	manual	\N	2026-02-12 20:47:56.480176+03
108	15	10	13	Astra Linux Special Edition 1.8	\N	manual	\N	2026-02-12 20:47:56.480176+03
109	15	10	14	KES12	\N	manual	\N	2026-02-12 20:47:56.480176+03
110	16	6	8	Core i5-12500 3,00 ГГц	\N	manual	\N	2026-02-12 20:47:56.480176+03
111	16	7	9	16 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
112	16	8	8	SSD 512 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
113	16	9	8	BenQ BL2405	\N	manual	\N	2026-02-12 20:47:56.480176+03
114	16	10	11	701-PershinaMA	\N	manual	\N	2026-02-12 20:47:56.480176+03
115	16	10	12	DHCP (VLAN 214)	\N	manual	\N	2026-02-12 20:47:56.480176+03
116	16	10	13	Astra Linux Special Edition 1.8	\N	manual	\N	2026-02-12 20:47:56.480176+03
117	16	10	14	KES12	\N	manual	\N	2026-02-12 20:47:56.480176+03
118	17	6	8	Core i5-12500 3,00 ГГц	\N	manual	\N	2026-02-12 20:47:56.480176+03
119	17	7	9	16 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
120	17	8	8	SSD 512 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
121	17	9	8	BenQ BL2405	\N	manual	\N	2026-02-12 20:47:56.480176+03
122	17	10	11	701-SlobcovAY	\N	manual	\N	2026-02-12 20:47:56.480176+03
123	17	10	12	DHCP (VLAN 214)	\N	manual	\N	2026-02-12 20:47:56.480176+03
124	17	10	13	Astra Linux Special Edition 1.8	\N	manual	\N	2026-02-12 20:47:56.480176+03
125	17	10	14	KES12	\N	manual	\N	2026-02-12 20:47:56.480176+03
126	18	6	8	Core i5-12500 3,00 ГГц	\N	manual	\N	2026-02-12 20:47:56.480176+03
127	18	7	9	16 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
128	18	8	8	SSD 512 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
129	18	9	8	MB27V13FS51	\N	manual	\N	2026-02-12 20:47:56.480176+03
130	18	9	10	МЦ.04	\N	manual	\N	2026-02-12 20:47:56.480176+03
131	18	10	11	701-bichkova	\N	manual	\N	2026-02-12 20:47:56.480176+03
132	18	10	12	DHCP (VLAN 214)	\N	manual	\N	2026-02-12 20:47:56.480176+03
133	18	10	13	Astra Linux Special Edition 1.8	\N	manual	\N	2026-02-12 20:47:56.480176+03
134	18	10	14	KES12	\N	manual	\N	2026-02-12 20:47:56.480176+03
135	19	6	8	Core i7-8550U 1,8 ГГц	\N	manual	\N	2026-02-12 20:47:56.480176+03
136	19	7	9	8 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
137	19	8	8	SSD 250 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
138	19	10	11	DESKTOP-A07MBOG	\N	manual	\N	2026-02-12 20:47:56.480176+03
139	19	10	12	не в сети	\N	manual	\N	2026-02-12 20:47:56.480176+03
140	19	10	13	Win10pro (x64)	\N	manual	\N	2026-02-12 20:47:56.480176+03
141	20	6	8	Core i5-12500  3,0 ГГц	\N	manual	\N	2026-02-12 20:47:56.480176+03
142	20	7	9	16 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
143	20	8	8	SSD 512 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
144	20	9	8	BENQ BL2405	\N	manual	\N	2026-02-12 20:47:56.480176+03
145	20	10	11	701-shishkinmd	\N	manual	\N	2026-02-12 20:47:56.480176+03
146	20	10	12	DHCP (VLAN 207)	\N	manual	\N	2026-02-12 20:47:56.480176+03
147	20	10	13	Astra Linux Special Edition 1.8	\N	manual	\N	2026-02-12 20:47:56.480176+03
148	20	10	14	KES12	\N	manual	\N	2026-02-12 20:47:56.480176+03
149	21	6	8	Core i5-12500  3,0 ГГц	\N	manual	\N	2026-02-12 20:47:56.480176+03
150	21	7	9	16 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
151	21	8	8	SSD 512 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
152	21	9	8	BENQ GL2460	\N	manual	\N	2026-02-12 20:47:56.480176+03
153	21	10	11	701-nikoncevav	\N	manual	\N	2026-02-12 20:47:56.480176+03
154	21	10	12	DHCP (VLAN 207)	\N	manual	\N	2026-02-12 20:47:56.480176+03
155	21	10	13	Astra Linux Special Edition 1.8	\N	manual	\N	2026-02-12 20:47:56.480176+03
156	21	10	14	KES12	\N	manual	\N	2026-02-12 20:47:56.480176+03
4014	1220	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4015	1220	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4016	1220	8	8	SSD - 512 МБ; HDD - 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4017	1220	9	8	ASUS 23.8" BE249QLB	\N	manual	\N	2026-02-17 23:54:02.090047+03
4018	1220	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4019	1220	10	11	702A-W10X64-01	\N	manual	\N	2026-02-17 23:54:02.090047+03
4020	1220	10	12	DHCP (VLAN 212)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4021	1220	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4022	1220	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4023	1223	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4024	1223	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4025	1223	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4026	1223	9	8	ASUS 23.8" BE249QLB	\N	manual	\N	2026-02-17 23:54:02.090047+03
4027	1223	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4028	1223	10	11	702A-W10X64-02	\N	manual	\N	2026-02-17 23:54:02.090047+03
4029	1223	10	12	DHCP (VLAN 212)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4030	1223	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4031	1223	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4032	1226	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4033	1226	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4034	1226	8	8	SSD - 512 МБ; HDD - 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4035	1226	9	8	ASUS 23.8" BE249QLB	\N	manual	\N	2026-02-17 23:54:02.090047+03
4036	1226	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4037	1226	10	11	702A-W10X64-03	\N	manual	\N	2026-02-17 23:54:02.090047+03
4038	1226	10	12	DHCP (VLAN 212)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4039	1226	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4040	1226	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4041	1229	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4042	1229	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4043	1229	8	8	SSD - 512 МБ; HDD - 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4044	1229	9	8	ASUS 23.8" BE249QLB	\N	manual	\N	2026-02-17 23:54:02.090047+03
4045	1229	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4046	1229	10	11	702A-W10X64-04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4047	1229	10	12	DHCP (VLAN 212)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4048	1229	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4049	1229	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4050	1232	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4051	1232	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4052	1232	8	8	SSD - 512 МБ; HDD - 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4053	1232	9	8	ASUS 23.8" BE249QLB	\N	manual	\N	2026-02-17 23:54:02.090047+03
4054	1232	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4055	1232	10	11	702A-W10X64-05	\N	manual	\N	2026-02-17 23:54:02.090047+03
4056	1232	10	12	DHCP (VLAN 212)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4057	1232	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4058	1232	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4059	1235	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4060	1235	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4061	1235	8	8	SSD - 512 МБ; HDD - 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4062	1235	9	8	ASUS 23.8" BE249QLB	\N	manual	\N	2026-02-17 23:54:02.090047+03
4063	1235	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4064	1235	10	11	702A-W10X64-06	\N	manual	\N	2026-02-17 23:54:02.090047+03
4065	1235	10	12	DHCP (VLAN 212)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4066	1235	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4067	1235	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4068	1238	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4069	1238	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4070	1238	8	8	SSD - 512 МБ; HDD - 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4071	1238	9	8	ASUS 23.8" BE249QLB	\N	manual	\N	2026-02-17 23:54:02.090047+03
4072	1238	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4073	1238	10	11	702A-W10X64-07	\N	manual	\N	2026-02-17 23:54:02.090047+03
4074	1238	10	12	DHCP (VLAN 212)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4075	1238	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4076	1238	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4077	1241	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4078	1241	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4079	1241	8	8	SSD - 512 МБ; HDD - 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4080	1241	9	8	ASUS 23.8" BE249QLB	\N	manual	\N	2026-02-17 23:54:02.090047+03
4081	1241	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4082	1241	10	11	702A-W10X64-08	\N	manual	\N	2026-02-17 23:54:02.090047+03
4083	1241	10	12	DHCP (VLAN 212)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4084	1241	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4085	1241	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4086	1244	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4087	1244	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4088	1244	8	8	SSD - 512 МБ; HDD - 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4089	1244	9	8	ASUS 23.8" BE249QLB	\N	manual	\N	2026-02-17 23:54:02.090047+03
4090	1244	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4091	1244	10	11	702A-W10X64-09	\N	manual	\N	2026-02-17 23:54:02.090047+03
4092	1244	10	12	DHCP (VLAN 212)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4093	1244	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4094	1244	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4095	1247	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4096	1247	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4097	1247	8	8	SSD - 512 МБ; HDD - 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4098	1247	9	8	ASUS 23.8" BE249QLB	\N	manual	\N	2026-02-17 23:54:02.090047+03
4099	1247	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4100	1247	10	11	702A-W10X64-10	\N	manual	\N	2026-02-17 23:54:02.090047+03
4101	1247	10	12	DHCP (VLAN 212)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4102	1247	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4103	1247	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4104	1250	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4105	1250	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4106	1250	8	8	SSD - 512 МБ; HDD - 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4107	1250	9	8	ASUS 23.8" BE249QLB	\N	manual	\N	2026-02-17 23:54:02.090047+03
4108	1250	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4109	1250	10	11	702A-W10X64-11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4110	1250	10	12	DHCP (VLAN 212)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4111	1250	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4112	1250	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4113	1253	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4114	1253	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4115	1253	8	8	SSD - 512 МБ; HDD - 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4116	1253	9	8	ASUS 23.8" BE249QLB	\N	manual	\N	2026-02-17 23:54:02.090047+03
4117	1253	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4118	1253	10	11	702A-W10X64-12	\N	manual	\N	2026-02-17 23:54:02.090047+03
4119	1253	10	12	DHCP (VLAN 212)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4120	1253	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4121	1253	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4122	1256	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4123	1256	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4124	1256	8	8	SSD - 512 МБ; HDD - 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4125	1256	9	8	ASUS 23.8" BE249QLB	\N	manual	\N	2026-02-17 23:54:02.090047+03
4126	1256	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4127	1256	10	11	702A-W10X64-13	\N	manual	\N	2026-02-17 23:54:02.090047+03
4128	1256	10	12	DHCP (VLAN 212)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4129	1256	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4130	1256	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4131	1259	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4132	1259	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4133	1259	8	8	SSD - 512 МБ; HDD - 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4134	1259	9	8	ASUS 23.8" BE249QLB	\N	manual	\N	2026-02-17 23:54:02.090047+03
4135	1259	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4136	1259	10	11	702A-W10X64-14	\N	manual	\N	2026-02-17 23:54:02.090047+03
4137	1259	10	12	DHCP (VLAN 212)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4138	1259	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4139	1259	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4140	1262	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4141	1262	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4142	1262	8	8	SSD - 512 МБ; HDD - 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4143	1262	9	8	ASUS 23.8" BE249QLB	\N	manual	\N	2026-02-17 23:54:02.090047+03
4144	1262	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4145	1262	10	11	702A-W10X64-15	\N	manual	\N	2026-02-17 23:54:02.090047+03
4146	1262	10	12	DHCP (VLAN 212)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4147	1262	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4148	1262	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4149	1265	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4150	1265	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4151	1265	8	8	SSD - 512 МБ; HDD - 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4152	1265	9	8	ASUS 23.8" BE249QLB	\N	manual	\N	2026-02-17 23:54:02.090047+03
4153	1265	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4154	1265	10	11	702A-W10X64-16	\N	manual	\N	2026-02-17 23:54:02.090047+03
4155	1265	10	12	DHCP (VLAN 212)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4156	1265	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4157	1265	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4158	1268	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4159	1268	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4160	1268	8	8	SSD - 512 МБ; HDD - 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4161	1268	9	8	ASUS 23.8" BE249QLB	\N	manual	\N	2026-02-17 23:54:02.090047+03
4162	1268	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4163	1268	10	11	702A-W10X64-17	\N	manual	\N	2026-02-17 23:54:02.090047+03
4164	1268	10	12	DHCP (VLAN 212)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4165	1268	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4166	1268	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4167	1271	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4168	1271	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4169	1271	8	8	SSD - 512 МБ; HDD - 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4170	1271	9	8	ASUS 23.8" BE249QLB	\N	manual	\N	2026-02-17 23:54:02.090047+03
4171	1271	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4172	1271	10	11	702A-W10X64-18	\N	manual	\N	2026-02-17 23:54:02.090047+03
4173	1271	10	12	DHCP (VLAN 212)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4174	1271	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4175	1271	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4176	1274	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4177	1274	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4178	1274	8	8	SSD - 512 МБ; HDD - 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4179	1274	9	8	ASUS 23.8" BE249QLB	\N	manual	\N	2026-02-17 23:54:02.090047+03
4180	1274	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4181	1274	10	11	702A-W10X64-19	\N	manual	\N	2026-02-17 23:54:02.090047+03
4182	1274	10	12	DHCP (VLAN 212)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4183	1274	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4184	1274	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4185	1277	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4186	1277	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4187	1277	8	8	SSD - 512 МБ; HDD - 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4188	1277	9	8	ASUS 23.8" BE249QLB	\N	manual	\N	2026-02-17 23:54:02.090047+03
4189	1277	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4190	1277	10	11	702A-W10X64-20	\N	manual	\N	2026-02-17 23:54:02.090047+03
4191	1277	10	12	DHCP (VLAN 212)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4192	1277	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4193	1277	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4194	1280	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4195	1280	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4196	1280	8	8	SSD - 512 МБ; HDD - 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4197	1280	9	8	ASUS 23.8" BE249QLB	\N	manual	\N	2026-02-17 23:54:02.090047+03
4198	1280	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4199	1280	10	11	702A-W10X64-21	\N	manual	\N	2026-02-17 23:54:02.090047+03
4200	1280	10	12	DHCP (VLAN 212)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4201	1280	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4202	1280	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4203	1283	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4204	1283	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4205	1283	8	8	SSD - 512 МБ; HDD - 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4206	1283	9	8	ASUS 23.8" BE249QLB	\N	manual	\N	2026-02-17 23:54:02.090047+03
4207	1283	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4208	1283	10	11	702A-W10X64-22	\N	manual	\N	2026-02-17 23:54:02.090047+03
4209	1283	10	12	DHCP (VLAN 212)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4210	1283	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4211	1283	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4212	1286	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4213	1286	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4214	1286	8	8	SSD - 512 МБ; HDD - 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4215	1286	9	8	ASUS 23.8" BE249QLB	\N	manual	\N	2026-02-17 23:54:02.090047+03
4216	1286	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4217	1286	10	11	702A-W10X64-23	\N	manual	\N	2026-02-17 23:54:02.090047+03
4218	1286	10	12	DHCP (VLAN 212)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4219	1286	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4220	1286	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4221	1289	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4222	1289	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4223	1289	8	8	SSD - 512 МБ; HDD - 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4224	1289	9	8	ASUS 23.8" BE249QLB	\N	manual	\N	2026-02-17 23:54:02.090047+03
4225	1289	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4226	1289	10	11	702A-W10X64-24	\N	manual	\N	2026-02-17 23:54:02.090047+03
4227	1289	10	12	DHCP (VLAN 212)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4228	1289	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4229	1289	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4230	1292	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4231	1292	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4232	1292	8	8	SSD - 512 МБ; HDD - 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4233	1292	9	8	ASUS 23.8" BE249QLB	\N	manual	\N	2026-02-17 23:54:02.090047+03
4234	1292	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4235	1292	10	11	702A-W10X64-25	\N	manual	\N	2026-02-17 23:54:02.090047+03
4236	1292	10	12	DHCP (VLAN 212)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4237	1292	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4238	1292	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4239	1295	9	8	Интерактивная панель; Prestigio 98"	\N	manual	\N	2026-02-17 23:54:02.090047+03
4240	1301	6	8	Xeon E5-2603 v4	\N	manual	\N	2026-02-17 23:54:02.090047+03
4241	1301	7	9	32 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4242	1301	8	8	4x4TB	\N	manual	\N	2026-02-17 23:54:02.090047+03
4243	1301	10	11	704-W2016-Class	\N	manual	\N	2026-02-17 23:54:02.090047+03
4244	1301	10	12	DHCP (VLAN 212)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4245	1301	10	13	Windows Server 2016	\N	manual	\N	2026-02-17 23:54:02.090047+03
4246	1301	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
4247	1303	6	8	Pentium Dual-Core E8400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4248	1303	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4249	1303	8	8	240 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4250	1303	9	8	Samsung SyncMaster 710N 17"	\N	manual	\N	2026-02-17 23:54:02.090047+03
4251	1303	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
4252	1303	10	11	702B-W7P32-2	\N	manual	\N	2026-02-17 23:54:02.090047+03
4253	1303	10	12	DHCP (VLAN 211)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4254	1303	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4255	1303	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4256	1305	6	8	Core2Duo E6750	\N	manual	\N	2026-02-17 23:54:02.090047+03
4257	1305	7	9	3 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4258	1305	8	8	320 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4259	1305	9	8	Samsung SyncMaster 710N 17"	\N	manual	\N	2026-02-17 23:54:02.090047+03
4260	1305	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
4261	1305	10	11	702B-W7P32-9	\N	manual	\N	2026-02-17 23:54:02.090047+03
4262	1305	10	12	DHCP (VLAN 211)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4263	1305	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4264	1305	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4265	1307	6	8	Core2Duo E6500 2,93 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4266	1307	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4267	1307	8	8	150 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4268	1307	9	8	Samsung SyncMaster 710N 17"	\N	manual	\N	2026-02-17 23:54:02.090047+03
4269	1307	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
4270	1307	10	11	702B-W7P32-1	\N	manual	\N	2026-02-17 23:54:02.090047+03
4271	1307	10	12	DHCP (VLAN 211)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4272	1307	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4273	1307	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4274	1309	6	8	Core2Duo E6500 2,93 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4275	1309	7	9	3 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4276	1309	8	8	300 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4277	1309	9	8	Samsung SyncMaster 720N 17"	\N	manual	\N	2026-02-17 23:54:02.090047+03
4278	1309	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
4279	1309	10	11	702B-W7P32-3	\N	manual	\N	2026-02-17 23:54:02.090047+03
4280	1309	10	12	DHCP (VLAN 211)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4281	1309	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4282	1309	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4283	1311	6	8	Core2Duo E6500 2,93 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4284	1311	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4285	1311	8	8	300 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4286	1311	9	8	Samsung SyncMaster 710N 17"	\N	manual	\N	2026-02-17 23:54:02.090047+03
4287	1311	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
4288	1311	10	11	702B-W7P32-6	\N	manual	\N	2026-02-17 23:54:02.090047+03
4289	1311	10	12	DHCP (VLAN 211)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4290	1311	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4291	1311	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4292	1313	6	8	Core2Duo E8400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4293	1313	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4294	1313	8	8	240 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4295	1313	9	8	Samsung SyncMaster 710N 17"	\N	manual	\N	2026-02-17 23:54:02.090047+03
4296	1313	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
4297	1313	10	11	702B-W7P32-4	\N	manual	\N	2026-02-17 23:54:02.090047+03
4298	1313	10	12	DHCP (VLAN 211)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4299	1313	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4300	1313	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4301	1315	6	8	Core2Duo E8400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4302	1315	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4303	1315	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4304	1315	9	8	Acer AL1714 (17")	\N	manual	\N	2026-02-17 23:54:02.090047+03
4305	1315	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
4306	1315	10	11	702B-W7P32-5	\N	manual	\N	2026-02-17 23:54:02.090047+03
4307	1315	10	12	DHCP (VLAN 211)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4308	1315	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4309	1315	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4310	1317	6	8	Core2Duo E6500 2,93 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4311	1317	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4312	1317	8	8	300 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4313	1317	9	8	Acer AL1714 (17")	\N	manual	\N	2026-02-17 23:54:02.090047+03
4314	1317	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
4315	1317	10	11	702B-W7P32-8	\N	manual	\N	2026-02-17 23:54:02.090047+03
4316	1317	10	12	DHCP (VLAN 211)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4317	1317	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4318	1317	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4319	1319	6	8	Core2Duo E8400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4320	1319	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4321	1319	8	8	160 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4322	1319	9	8	Acer AL1714 (17")	\N	manual	\N	2026-02-17 23:54:02.090047+03
4323	1319	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
4324	1319	10	11	702B-W7P32-7	\N	manual	\N	2026-02-17 23:54:02.090047+03
4325	1319	10	12	DHCP (VLAN 211)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4326	1319	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4327	1319	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4328	1321	6	8	Core2Duo E8400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4329	1321	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4330	1321	8	8	250 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4331	1321	9	8	Samsung SyncMaster 710N 17"	\N	manual	\N	2026-02-17 23:54:02.090047+03
4332	1321	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
4333	1321	10	11	702B-W7P32-13	\N	manual	\N	2026-02-17 23:54:02.090047+03
4334	1321	10	12	DHCP (VLAN 211)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4335	1321	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4336	1321	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4337	1323	6	8	Core2Duo E8400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4338	1323	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4339	1323	8	8	250 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4340	1323	9	8	Philips 170S	\N	manual	\N	2026-02-17 23:54:02.090047+03
4341	1323	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
4342	1323	10	11	702B-W7P32-11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4343	1323	10	12	DHCP (VLAN 211)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4344	1323	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4345	1323	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
157	22	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-12 20:47:56.480176+03
158	22	7	9	16 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
159	22	8	8	1 ТБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
160	22	9	8	Philips 23.8" 241B8QJEB; Philips 23.8" 241B8QJEB	\N	manual	\N	2026-02-12 20:47:56.480176+03
161	22	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-12 20:47:56.480176+03
162	22	10	11	702v-W10x64	\N	manual	\N	2026-02-12 20:47:56.480176+03
163	22	10	12	10.1.4.94	\N	manual	\N	2026-02-12 20:47:56.480176+03
164	22	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-12 20:47:56.480176+03
165	22	10	14	KES10	\N	manual	\N	2026-02-12 20:47:56.480176+03
166	23	6	8	Core i5-10210U 2,10 ГГц	\N	manual	\N	2026-02-12 20:47:56.480176+03
167	23	7	9	16 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
168	23	8	8	SSD -500 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
169	23	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-12 20:47:56.480176+03
170	23	10	14	KES11	\N	manual	\N	2026-02-12 20:47:56.480176+03
4360	1329	6	8	Core i3-4130 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4361	1329	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4362	1329	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4363	1329	10	11	703-FARKHSHATOV	\N	manual	\N	2026-02-17 23:54:02.090047+03
4364	1329	10	12	DHCP\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4365	1329	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4366	1329	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4367	1330	6	8	Core i3-4130 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4368	1330	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4369	1330	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4370	1330	10	11	703-Computer	\N	manual	\N	2026-02-17 23:54:02.090047+03
4371	1330	10	12	DHCP\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4372	1330	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4373	1330	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4374	1331	6	8	Core i3-10100,3,6GHz	\N	manual	\N	2026-02-17 23:54:02.090047+03
4375	1331	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4376	1331	8	8	SSD 250 Гб	\N	manual	\N	2026-02-17 23:54:02.090047+03
4377	1331	9	8	AOC 24P2Q; Nec MultiSync AS221WM	\N	manual	\N	2026-02-17 23:54:02.090047+03
4378	1331	9	10	МЦ.04\nНИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4379	1331	10	11	704-W10P64-243	\N	manual	\N	2026-02-17 23:54:02.090047+03
4380	1331	10	12	10.2.2.243	\N	manual	\N	2026-02-17 23:54:02.090047+03
4381	1331	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4382	1331	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
4383	1334	6	8	Pentium Dual-Core E8400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4384	1334	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4385	1334	8	8	250 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4386	1334	9	8	LG Flatron L192WS	\N	manual	\N	2026-02-17 23:54:02.090047+03
4387	1334	10	11	704-w7p32-72	\N	manual	\N	2026-02-17 23:54:02.090047+03
4388	1334	10	12	10.1.4.72	\N	manual	\N	2026-02-17 23:54:02.090047+03
4389	1334	10	13	Win7 Pro (x32)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4390	1334	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4391	1336	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4392	1336	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4393	1336	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4394	1336	9	8	Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
4395	1336	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
4396	1336	10	11	704-w10p64-71	\N	manual	\N	2026-02-17 23:54:02.090047+03
4397	1336	10	12	10.1.4.71	\N	manual	\N	2026-02-17 23:54:02.090047+03
4398	1336	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4399	1336	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4400	1338	6	8	Pentium Dual-Core E5700 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4401	1338	7	9	2 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4402	1338	8	8	300 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4403	1338	9	8	Samsung SyncMaster E1920	\N	manual	\N	2026-02-17 23:54:02.090047+03
4404	1338	9	10	99036	\N	manual	\N	2026-02-17 23:54:02.090047+03
4405	1338	10	11	705-W7U32-187	\N	manual	\N	2026-02-17 23:54:02.090047+03
4406	1338	10	12	10.1.4.187	\N	manual	\N	2026-02-17 23:54:02.090047+03
4407	1338	10	13	Win7 Pro (x32)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4408	1338	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4409	1340	6	8	Pentium Dual-Core E6500 2,93 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4410	1340	7	9	2 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4411	1340	8	8	300 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4412	1340	9	8	Samsung SyncMaster E1920	\N	manual	\N	2026-02-17 23:54:02.090047+03
4413	1340	9	10	99036	\N	manual	\N	2026-02-17 23:54:02.090047+03
4414	1340	10	11	705-w7p32-188	\N	manual	\N	2026-02-17 23:54:02.090047+03
4415	1340	10	12	10.1.4.188	\N	manual	\N	2026-02-17 23:54:02.090047+03
4416	1340	10	13	Win7 Pro (x32)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4417	1340	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4418	1342	6	8	Pentium Dual-Core E6500 2,93 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4419	1342	7	9	2 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4420	1342	8	8	300 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4421	1342	9	8	Samsung SyncMaster E1920	\N	manual	\N	2026-02-17 23:54:02.090047+03
4422	1342	9	10	99036	\N	manual	\N	2026-02-17 23:54:02.090047+03
4423	1342	10	11	705-w7p32-189	\N	manual	\N	2026-02-17 23:54:02.090047+03
4424	1342	10	12	10.1.4.189	\N	manual	\N	2026-02-17 23:54:02.090047+03
4425	1342	10	13	Win7 Pro (x32)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4426	1342	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4427	1344	6	8	Pentium Dual-Core E6500 2,93 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4428	1344	7	9	2 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4429	1344	8	8	300 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4430	1344	9	8	Samsung SyncMaster E1920	\N	manual	\N	2026-02-17 23:54:02.090047+03
4431	1344	9	10	99036	\N	manual	\N	2026-02-17 23:54:02.090047+03
4432	1344	10	11	705-w7p32-190	\N	manual	\N	2026-02-17 23:54:02.090047+03
4433	1344	10	12	10.1.4.190	\N	manual	\N	2026-02-17 23:54:02.090047+03
4434	1344	10	13	Win7 Pro (x32)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4435	1344	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4436	1346	6	8	Pentium Dual-Core E5700 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4437	1346	7	9	2 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4438	1346	8	8	300 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4439	1346	9	8	Samsung SyncMaster E1920	\N	manual	\N	2026-02-17 23:54:02.090047+03
4440	1346	9	10	99036	\N	manual	\N	2026-02-17 23:54:02.090047+03
4441	1346	10	11	705-w7p32-191	\N	manual	\N	2026-02-17 23:54:02.090047+03
4442	1346	10	12	10.1.4.191	\N	manual	\N	2026-02-17 23:54:02.090047+03
4443	1346	10	13	Win7 Pro (x32)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4444	1346	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4445	1348	6	8	Pentium Dual-Core E5700 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4446	1348	7	9	2 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4447	1348	8	8	300 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4448	1348	9	8	Samsung SyncMaster E1920	\N	manual	\N	2026-02-17 23:54:02.090047+03
4449	1348	9	10	99036	\N	manual	\N	2026-02-17 23:54:02.090047+03
4450	1348	10	11	705-w7p32-192	\N	manual	\N	2026-02-17 23:54:02.090047+03
4451	1348	10	12	10.1.4.192	\N	manual	\N	2026-02-17 23:54:02.090047+03
4452	1348	10	13	Win7 Pro (x32)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4453	1348	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4454	1350	6	8	Pentium Dual-Core E5700 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4455	1350	7	9	2 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4456	1350	8	8	300 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4457	1350	9	8	Samsung SyncMaster E1920	\N	manual	\N	2026-02-17 23:54:02.090047+03
4458	1350	9	10	99036	\N	manual	\N	2026-02-17 23:54:02.090047+03
4459	1350	10	11	705-w7p32-193	\N	manual	\N	2026-02-17 23:54:02.090047+03
4460	1350	10	12	10.1.4.193	\N	manual	\N	2026-02-17 23:54:02.090047+03
4461	1350	10	13	Win7 Pro (x32)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4462	1350	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4463	1352	6	8	Pentium Dual-Core E5700 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4464	1352	7	9	2 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4465	1352	8	8	300 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4466	1352	9	8	Samsung SyncMaster E1920	\N	manual	\N	2026-02-17 23:54:02.090047+03
4467	1352	9	10	99036	\N	manual	\N	2026-02-17 23:54:02.090047+03
4468	1352	10	11	705-w7p32-194	\N	manual	\N	2026-02-17 23:54:02.090047+03
4469	1352	10	12	10.1.4.194	\N	manual	\N	2026-02-17 23:54:02.090047+03
4470	1352	10	13	Win7 Pro (x32)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4471	1352	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4472	1354	6	8	Core i3-2100 3,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4473	1354	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4474	1354	8	8	SSD - 128 ГБ; HDD - 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4475	1354	9	8	Nec MultiSync AS221WM	\N	manual	\N	2026-02-17 23:54:02.090047+03
4476	1354	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
4477	1354	10	11	706B-W10P64-66	\N	manual	\N	2026-02-17 23:54:02.090047+03
4478	1354	10	12	10.1.4.66	\N	manual	\N	2026-02-17 23:54:02.090047+03
4479	1354	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4480	1354	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
4481	1356	6	8	Core i3-10100,3,6GHz	\N	manual	\N	2026-02-17 23:54:02.090047+03
4482	1356	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4483	1356	8	8	SSD 250ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4484	1356	9	8	Samsung SyncMaster 943	\N	manual	\N	2026-02-17 23:54:02.090047+03
4485	1356	10	11	706A-W10P64-68	\N	manual	\N	2026-02-17 23:54:02.090047+03
4486	1356	10	12	10.1.4.68	\N	manual	\N	2026-02-17 23:54:02.090047+03
4487	1356	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4488	1356	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4489	1358	6	8	Core i3-2100 3,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4490	1358	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4491	1358	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4492	1358	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
4493	1358	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4494	1358	10	11	706A-W7P64-67	\N	manual	\N	2026-02-17 23:54:02.090047+03
4495	1358	10	12	10.1.4.67	\N	manual	\N	2026-02-17 23:54:02.090047+03
4496	1358	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4497	1358	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4498	1360	6	8	Core i7-4770k 3,5 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4499	1360	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4500	1360	8	8	ssd - 480 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4501	1360	9	8	Philips 234E	\N	manual	\N	2026-02-17 23:54:02.090047+03
4502	1360	10	11	706-W10P64-131	\N	manual	\N	2026-02-17 23:54:02.090047+03
4503	1360	10	12	10.1.4.131	\N	manual	\N	2026-02-17 23:54:02.090047+03
4504	1360	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4505	1360	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
4506	1363	6	8	Core i5-10400 2,90 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4507	1363	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4508	1363	8	8	HDD - 1 TB; SSD - 240 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4509	1363	9	8	Philips 243V7QJABF; Philips 243V7QJABF	\N	manual	\N	2026-02-17 23:54:02.090047+03
4510	1363	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4511	1363	10	11	707-POMAZOVSV	\N	manual	\N	2026-02-17 23:54:02.090047+03
4512	1363	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4513	1363	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4514	1363	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4515	1367	6	8	Core i5-10400 2,90 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4516	1367	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4517	1367	8	8	HDD - 1 TB; SSD - 240 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4518	1367	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
4519	1367	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4520	1367	10	11	707-w10p64-166	\N	manual	\N	2026-02-17 23:54:02.090047+03
4521	1367	10	12	DHCP (VLAN 207)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4522	1367	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4523	1367	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4524	1370	6	8	Core i7-9700 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4525	1370	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4526	1370	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4527	1370	9	8	Philips 243V7QJABF; Philips 243V7QJABF	\N	manual	\N	2026-02-17 23:54:02.090047+03
4528	1370	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4529	1370	10	11	707A-ANDREEVSN	\N	manual	\N	2026-02-17 23:54:02.090047+03
4530	1370	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4531	1370	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4532	1370	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
4533	1374	6	8	Core i7-9700 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4534	1374	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4535	1374	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4536	1374	9	8	Philips 243V7QJABF; Philips 243V7QJABF	\N	manual	\N	2026-02-17 23:54:02.090047+03
4537	1374	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4538	1374	10	11	707-KULESHOVAE	\N	manual	\N	2026-02-17 23:54:02.090047+03
4539	1374	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4540	1374	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4541	1374	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
4542	1377	6	8	Pentium Dual-Core E5700 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4543	1377	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4544	1377	8	8	SSD 120 ГБ; HDD 300 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4545	1377	9	8	LG Flatron L192WS	\N	manual	\N	2026-02-17 23:54:02.090047+03
4546	1377	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
4547	1377	10	11	707-SilkinSA	\N	manual	\N	2026-02-17 23:54:02.090047+03
4548	1377	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4549	1377	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4550	1377	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
4551	1380	6	8	Core i5-10400 2,90 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4552	1380	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4553	1380	8	8	HDD - 1 TB; SSD - 240 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4554	1380	9	8	Philips 243V7QJABF; Philips 243V7QJABF	\N	manual	\N	2026-02-17 23:54:02.090047+03
4555	1380	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4556	1380	10	11	707-SVETOVOV	\N	manual	\N	2026-02-17 23:54:02.090047+03
4557	1380	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4558	1380	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4559	1380	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4560	1384	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4561	1384	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4562	1384	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4563	1384	9	8	AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
4564	1384	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4565	1384	10	11	707-POGORELOVA	\N	manual	\N	2026-02-17 23:54:02.090047+03
4566	1384	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4567	1384	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4568	1384	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
4569	1386	6	8	Core i5-2310 2,9 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4570	1386	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4571	1386	8	8	HDD - 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4572	1386	9	8	Benq GL2450; Benq GL2450	\N	manual	\N	2026-02-17 23:54:02.090047+03
4573	1386	10	11	707-BOYKOAP	\N	manual	\N	2026-02-17 23:54:02.090047+03
4574	1386	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4575	1386	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4576	1386	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
4577	1390	6	8	Core i5-4690 3,5 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4578	1390	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4579	1390	8	8	HDD - 1 ТБ; SSD - 120 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4580	1390	9	8	AOC 24P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
4581	1390	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4582	1390	10	11	707-POKIDKOOV	\N	manual	\N	2026-02-17 23:54:02.090047+03
4583	1390	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4584	1390	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4585	1390	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
4586	1393	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4587	1393	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4588	1393	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4589	1393	9	8	Dell U2415; Dell U2415	\N	manual	\N	2026-02-17 23:54:02.090047+03
4590	1393	9	10	НИИСУ\nНИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4591	1393	10	11	708-w10p64-236	\N	manual	\N	2026-02-17 23:54:02.090047+03
4592	1393	10	12	10.2.2.236	\N	manual	\N	2026-02-17 23:54:02.090047+03
4593	1393	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4594	1393	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4595	1396	6	8	Core i3-2100 3,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4596	1396	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4597	1396	8	8	SSD -500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4598	1396	9	8	LG 22MP55	\N	manual	\N	2026-02-17 23:54:02.090047+03
4599	1396	10	11	708-W10P64-232	\N	manual	\N	2026-02-17 23:54:02.090047+03
4600	1396	10	12	10.2.2.232	\N	manual	\N	2026-02-17 23:54:02.090047+03
4601	1396	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4602	1396	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4603	1398	6	8	Core i7-6700 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4604	1398	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4605	1398	8	8	SSD - 500 ГБ; HDD - 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4606	1398	9	8	Dell U2415	\N	manual	\N	2026-02-17 23:54:02.090047+03
4607	1398	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4608	1398	10	11	708-W10p64-111	\N	manual	\N	2026-02-17 23:54:02.090047+03
4609	1398	10	12	10.2.2.111	\N	manual	\N	2026-02-17 23:54:02.090047+03
4610	1398	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4611	1398	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4612	1400	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4613	1400	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4614	1400	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4615	1400	9	8	Dell U2415	\N	manual	\N	2026-02-17 23:54:02.090047+03
4616	1400	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4617	1400	10	11	708-W10P64-112	\N	manual	\N	2026-02-17 23:54:02.090047+03
4618	1400	10	12	10.2.2.112	\N	manual	\N	2026-02-17 23:54:02.090047+03
4619	1400	10	13	Win10Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4620	1400	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4621	1402	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4622	1402	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4623	1402	8	8	SSD -256 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4624	1402	9	8	Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
4625	1402	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4626	1402	10	11	708-w10p64-61	\N	manual	\N	2026-02-17 23:54:02.090047+03
4627	1402	10	12	10.2.2.61	\N	manual	\N	2026-02-17 23:54:02.090047+03
4628	1402	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4629	1402	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4630	1405	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4631	1405	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4632	1405	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
4633	1405	9	8	Dell E2314H; Dell E2314H	\N	manual	\N	2026-02-17 23:54:02.090047+03
4634	1405	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4635	1405	10	12	10.2.2.63	\N	manual	\N	2026-02-17 23:54:02.090047+03
4636	1405	10	13	Linux	\N	manual	\N	2026-02-17 23:54:02.090047+03
4637	1408	6	8	Core i5-12500 3,00 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4638	1408	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4639	1408	8	8	SSD 512 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4640	1408	9	8	AOC 27P2Q; MB27V13FS51	\N	manual	\N	2026-02-17 23:54:02.090047+03
4641	1408	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4642	1408	10	11	708-polipovav	\N	manual	\N	2026-02-17 23:54:02.090047+03
4643	1408	10	12	DHCP (VLAN 400)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4644	1408	10	13	Astra Linux Special Edition 1.8	\N	manual	\N	2026-02-17 23:54:02.090047+03
4645	1408	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
4646	1411	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4647	1411	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4648	1411	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4649	1411	9	8	MB27V13FS51	\N	manual	\N	2026-02-17 23:54:02.090047+03
4650	1411	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4651	1411	10	11	708-w10p64-126	\N	manual	\N	2026-02-17 23:54:02.090047+03
4652	1411	10	12	10.2.2.126	\N	manual	\N	2026-02-17 23:54:02.090047+03
4653	1411	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4654	1411	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
4655	1413	6	8	AMD Athlon 3150U 2.40 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4656	1413	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4657	1413	8	8	SSD 240 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4658	1413	9	8	15,6"	\N	manual	\N	2026-02-17 23:54:02.090047+03
4659	1413	10	13	Win11 Home	\N	manual	\N	2026-02-17 23:54:02.090047+03
4660	1415	6	8	Xeon E3-1285 3.6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4661	1415	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4662	1415	8	8	SSD - 250 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4663	1415	9	8	Dell E2313HF	\N	manual	\N	2026-02-17 23:54:02.090047+03
4664	1415	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4665	1415	10	11	710-w8p64-43	\N	manual	\N	2026-02-17 23:54:02.090047+03
4666	1415	10	12	10.2.2.43	\N	manual	\N	2026-02-17 23:54:02.090047+03
4667	1415	10	13	Win8.1(x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4668	1415	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4669	1417	6	8	Core I7-4770k 3.5 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4670	1417	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4671	1417	8	8	1 ТБ; SSD 250ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4672	1417	9	8	NEC MultiSyncE222W	\N	manual	\N	2026-02-17 23:54:02.090047+03
4673	1417	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4674	1417	10	11	710-W10P64-45	\N	manual	\N	2026-02-17 23:54:02.090047+03
4675	1417	10	12	10.2.2.45	\N	manual	\N	2026-02-17 23:54:02.090047+03
4676	1417	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4677	1417	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4678	1420	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4679	1420	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4680	1420	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4681	1420	9	8	NEC Multisync E222W	\N	manual	\N	2026-02-17 23:54:02.090047+03
4682	1420	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4683	1420	10	11	710-w10p64-42	\N	manual	\N	2026-02-17 23:54:02.090047+03
4684	1420	10	12	10.2.2.42	\N	manual	\N	2026-02-17 23:54:02.090047+03
4685	1420	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4686	1420	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4687	1422	6	8	Pentium 4 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4688	1422	7	9	1 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4689	1422	8	8	200 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4690	1422	9	8	LG Flatron L192WS	\N	manual	\N	2026-02-17 23:54:02.090047+03
4691	1422	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
4692	1422	10	11	computer12	\N	manual	\N	2026-02-17 23:54:02.090047+03
4693	1422	10	12	не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
4694	1422	10	13	Win XP (x32)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4695	1422	10	14	Avast	\N	manual	\N	2026-02-17 23:54:02.090047+03
4696	1424	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4697	1424	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4698	1424	8	8	240 ГБ (SSD); 1000 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4699	1424	9	8	Philips 243V7QJABF; Philips 243V7QJABF	\N	manual	\N	2026-02-17 23:54:02.090047+03
4700	1424	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4701	1424	10	11	712-w10p64-55	\N	manual	\N	2026-02-17 23:54:02.090047+03
4702	1424	10	12	10.10.10.55	\N	manual	\N	2026-02-17 23:54:02.090047+03
4703	1424	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4704	1424	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4705	1428	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4706	1428	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4707	1428	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4708	1428	9	8	Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
4709	1428	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
4710	1428	10	11	712-W10P64-17	\N	manual	\N	2026-02-17 23:54:02.090047+03
4711	1428	10	12	10.10.10.17	\N	manual	\N	2026-02-17 23:54:02.090047+03
4712	1428	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4713	1428	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
4714	1430	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4715	1430	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4716	1430	8	8	SSD 500ГБ; HDD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4717	1430	9	8	Philips 243V7QJABF	\N	manual	\N	2026-02-17 23:54:02.090047+03
4718	1430	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4719	1430	10	11	712-W10P64-54	\N	manual	\N	2026-02-17 23:54:02.090047+03
4720	1430	10	12	10.10.10.54	\N	manual	\N	2026-02-17 23:54:02.090047+03
4721	1430	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4722	1430	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
4723	1433	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4724	1433	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4725	1433	8	8	SSD 500 ГБ; HDD 500 ГБ (откл.)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4726	1433	9	8	Philips 243V7QJABF; Philips 243V7QJABF	\N	manual	\N	2026-02-17 23:54:02.090047+03
4727	1433	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4728	1433	10	11	712-W10P64-114	\N	manual	\N	2026-02-17 23:54:02.090047+03
4729	1433	10	12	10.10.10.114	\N	manual	\N	2026-02-17 23:54:02.090047+03
4730	1433	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4731	1433	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4732	1437	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4733	1437	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4734	1437	8	8	240 ГБ (SSD); 1000 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4735	1437	9	8	AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
4736	1437	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4737	1437	10	11	712-w10p64-19	\N	manual	\N	2026-02-17 23:54:02.090047+03
4738	1437	10	12	10.10.10.19	\N	manual	\N	2026-02-17 23:54:02.090047+03
4739	1437	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4740	1437	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4741	1440	6	8	Core i3-2100 3,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4742	1440	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4743	1440	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4744	1440	9	8	AOC 27P2Q; Philips 243V7QJABF	\N	manual	\N	2026-02-17 23:54:02.090047+03
4745	1440	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4746	1440	10	11	712-W10P64-18	\N	manual	\N	2026-02-17 23:54:02.090047+03
4747	1440	10	12	10.10.10.18	\N	manual	\N	2026-02-17 23:54:02.090047+03
4748	1440	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4749	1440	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
4750	1444	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4751	1444	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4752	1444	8	8	SSD 480ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4753	1444	9	8	Philips 243V7QDSB 23,8"	\N	manual	\N	2026-02-17 23:54:02.090047+03
4754	1444	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4755	1444	10	11	712-W10p64-113	\N	manual	\N	2026-02-17 23:54:02.090047+03
4756	1444	10	12	10.10.10.113	\N	manual	\N	2026-02-17 23:54:02.090047+03
4757	1444	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4758	1444	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4759	1447	6	8	Core i5-4440 3,1ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4760	1447	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4761	1447	8	8	SSD 480ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4762	1447	9	8	Philips 243V7QJABF	\N	manual	\N	2026-02-17 23:54:02.090047+03
4763	1447	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4764	1447	10	11	712-W7p64-112	\N	manual	\N	2026-02-17 23:54:02.090047+03
4765	1447	10	12	10.10.10.112	\N	manual	\N	2026-02-17 23:54:02.090047+03
4766	1447	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4767	1447	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4768	1450	6	8	Core i5-8250U 1.6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4769	1450	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4770	1450	8	8	128 ГБ (SSD); 1000 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4771	1450	10	12	10.10.10.122	\N	manual	\N	2026-02-17 23:54:02.090047+03
4772	1450	10	13	Win10 H (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4773	1450	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4774	1451	6	8	Core i3-7100T 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4775	1451	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4776	1451	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4777	1451	9	8	Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
4778	1451	10	11	715-w10p64-50	\N	manual	\N	2026-02-17 23:54:02.090047+03
4779	1451	10	12	10.1.4.50	\N	manual	\N	2026-02-17 23:54:02.090047+03
4780	1451	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4781	1451	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
4782	1453	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4783	1453	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4784	1453	8	8	1 Тб	\N	manual	\N	2026-02-17 23:54:02.090047+03
4785	1453	9	8	Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
4786	1453	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
4787	1453	10	11	715-w10p64-60	\N	manual	\N	2026-02-17 23:54:02.090047+03
4788	1453	10	12	10.1.4.60	\N	manual	\N	2026-02-17 23:54:02.090047+03
4789	1453	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4790	1453	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
4791	1455	6	8	Core i5-650 3,2 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4792	1455	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4793	1455	8	8	SSD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4794	1455	9	8	MB27V13FS51	\N	manual	\N	2026-02-17 23:54:02.090047+03
4795	1455	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4796	1455	10	11	715-W10P64-74	\N	manual	\N	2026-02-17 23:54:02.090047+03
4797	1455	10	12	10.1.4.74	\N	manual	\N	2026-02-17 23:54:02.090047+03
4798	1455	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4799	1455	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
4800	1458	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4801	1458	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4802	1458	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4803	1458	9	8	MB27V13FS51	\N	manual	\N	2026-02-17 23:54:02.090047+03
4804	1458	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4805	1458	10	11	716-w10p64-26	\N	manual	\N	2026-02-17 23:54:02.090047+03
4806	1458	10	12	10.2.2.26	\N	manual	\N	2026-02-17 23:54:02.090047+03
4807	1458	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4808	1458	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
4809	1461	6	8	Core i3-2100 3,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4810	1461	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4811	1461	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4812	1461	9	8	Samsung SyncMaster B2430	\N	manual	\N	2026-02-17 23:54:02.090047+03
4813	1461	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
4814	1461	10	11	716-W10P64-231	\N	manual	\N	2026-02-17 23:54:02.090047+03
4815	1461	10	12	10.2.2.231	\N	manual	\N	2026-02-17 23:54:02.090047+03
4816	1461	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4817	1461	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
4818	1463	6	8	Core i3-2100 3,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4819	1463	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4820	1463	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4821	1463	9	8	Benq G2220HD	\N	manual	\N	2026-02-17 23:54:02.090047+03
4822	1463	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4823	1463	10	11	716-W10P64-32	\N	manual	\N	2026-02-17 23:54:02.090047+03
4824	1463	10	12	10.2.2.32	\N	manual	\N	2026-02-17 23:54:02.090047+03
4825	1463	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4826	1463	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4827	1465	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4828	1465	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4829	1465	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4830	1465	9	8	Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
4831	1465	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
4832	1465	10	11	717-w10p64-14	\N	manual	\N	2026-02-17 23:54:02.090047+03
4833	1465	10	12	10.1.4.14	\N	manual	\N	2026-02-17 23:54:02.090047+03
4834	1465	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4835	1465	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
4836	1467	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4837	1467	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4838	1467	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4839	1467	9	8	Samsung SyncMaster P2050	\N	manual	\N	2026-02-17 23:54:02.090047+03
4840	1467	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4841	1467	10	11	717-W10P64-11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4842	1467	10	12	10.1.4.11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4843	1467	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4844	1467	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
4845	1469	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4846	1469	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4847	1469	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4848	1469	9	8	Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
4849	1469	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
4850	1469	10	11	717-W10P64-19	\N	manual	\N	2026-02-17 23:54:02.090047+03
4851	1469	10	12	10.1.4.19	\N	manual	\N	2026-02-17 23:54:02.090047+03
4852	1469	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4853	1469	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
4854	1471	6	8	Core i3-7100T 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4855	1471	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4856	1471	8	8	SSD 480 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4857	1471	9	8	MB27V13FS51; Samsung Syncmaster SA450	\N	manual	\N	2026-02-17 23:54:02.090047+03
4858	1471	9	10	МЦ.04\nМЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
4859	1471	10	11	718-W10P64-45	\N	manual	\N	2026-02-17 23:54:02.090047+03
4860	1471	10	12	10.10.10.45	\N	manual	\N	2026-02-17 23:54:02.090047+03
4861	1471	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4862	1471	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
4863	1475	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4864	1475	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4865	1475	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4866	1475	9	8	AOC 27P2Q; AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
4867	1475	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4868	1475	10	11	718-w10p64-43	\N	manual	\N	2026-02-17 23:54:02.090047+03
4869	1475	10	12	10.10.10.43	\N	manual	\N	2026-02-17 23:54:02.090047+03
4870	1475	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4871	1475	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4872	1478	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4873	1478	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4874	1478	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4875	1478	9	8	AOC 27P2Q; Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
4876	1478	9	10	МЦ.04\nМЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
4877	1478	10	11	717-w7p64-dsp	\N	manual	\N	2026-02-17 23:54:02.090047+03
4878	1478	10	12	не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
4879	1478	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4880	1478	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4881	1481	6	8	Core i5-10300H 2,5 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4882	1481	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4883	1481	8	8	SSD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4884	1481	9	8	17"	\N	manual	\N	2026-02-17 23:54:02.090047+03
4885	1481	10	11	LAPTOP-D0292RGT	\N	manual	\N	2026-02-17 23:54:02.090047+03
4886	1481	10	12	не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
4887	1481	10	13	Win10 Home (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4888	1481	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
4889	1483	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4890	1483	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4891	1483	8	8	500 ГБ; 250 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4892	1483	9	8	Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
4893	1483	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
4894	1483	10	11	719-W10P64-20	\N	manual	\N	2026-02-17 23:54:02.090047+03
4895	1483	10	12	10.1.4.20	\N	manual	\N	2026-02-17 23:54:02.090047+03
4896	1483	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4897	1483	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
4898	1485	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4899	1485	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4900	1485	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4901	1485	9	8	Samsung 27" C27F390FHI	\N	manual	\N	2026-02-17 23:54:02.090047+03
4902	1485	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4903	1485	10	11	719-w10p64	\N	manual	\N	2026-02-17 23:54:02.090047+03
4904	1485	10	12	не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
4905	1485	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4906	1485	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
4907	1487	6	8	Core i3-4150 3,5 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4908	1487	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4909	1487	8	8	SSD 480 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4910	1487	9	8	Samsung SyncMaster P2270; Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
4911	1487	9	10	(99036)\nМЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
4912	1487	10	11	719-W10P64-16	\N	manual	\N	2026-02-17 23:54:02.090047+03
4913	1487	10	12	10.10.10.16	\N	manual	\N	2026-02-17 23:54:02.090047+03
4914	1487	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4915	1487	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
4916	1490	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4917	1490	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4918	1490	8	8	256 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4919	1490	9	8	Philips 273V7QJAB; Nec MultiSync E222W	\N	manual	\N	2026-02-17 23:54:02.090047+03
4920	1490	9	10	МЦ.04\nНИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4921	1490	10	11	720-BeschastnykhDM	\N	manual	\N	2026-02-17 23:54:02.090047+03
4922	1490	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4923	1490	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4924	1490	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4925	1494	6	8	Core i5-10400 2,90 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4926	1494	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4927	1494	8	8	HDD - 1 TB; SSD - 240 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4928	1494	9	8	Philips 273V7QJAB; Philips 273V7QJAB	\N	manual	\N	2026-02-17 23:54:02.090047+03
4929	1494	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4930	1494	10	11	720-POIKINAE	\N	manual	\N	2026-02-17 23:54:02.090047+03
4931	1494	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4932	1494	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4933	1494	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
4934	1497	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4935	1497	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4936	1497	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4937	1497	9	8	Samsung S27F358FWI; Samsung S27F358FWI	\N	manual	\N	2026-02-17 23:54:02.090047+03
4938	1497	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4939	1497	10	11	720-SHCHEGLOVSV	\N	manual	\N	2026-02-17 23:54:02.090047+03
4940	1497	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
4941	1497	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4942	1497	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
4943	1500	6	8	Core i5-12500 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4944	1500	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4945	1500	8	8	SSD 512 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4946	1500	9	8	MB27V13FS51	\N	manual	\N	2026-02-17 23:54:02.090047+03
4947	1500	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4948	1500	10	11	720-Astra	\N	manual	\N	2026-02-17 23:54:02.090047+03
4949	1500	10	12	Не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
4950	1500	10	13	Astra Linux Special Edition	\N	manual	\N	2026-02-17 23:54:02.090047+03
4951	1500	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
4952	1503	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4953	1503	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4954	1503	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4955	1503	9	8	Samsung SyncMaster 931с; LG Flatron L192ws	\N	manual	\N	2026-02-17 23:54:02.090047+03
4956	1503	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
4957	1503	10	11	721-W7P64-6	\N	manual	\N	2026-02-17 23:54:02.090047+03
4958	1503	10	12	оптика\n192.168.10.206	\N	manual	\N	2026-02-17 23:54:02.090047+03
4959	1503	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4960	1503	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
4961	1507	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4962	1507	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4963	1507	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4964	1507	9	8	Samsung SyncMaster E1920	\N	manual	\N	2026-02-17 23:54:02.090047+03
4965	1507	9	10	99036	\N	manual	\N	2026-02-17 23:54:02.090047+03
4966	1507	10	11	721-W10P64	\N	manual	\N	2026-02-17 23:54:02.090047+03
4967	1507	10	12	оптика\n192.168.10.71	\N	manual	\N	2026-02-17 23:54:02.090047+03
4968	1507	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4969	1507	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4970	1509	6	8	Core i5-8500 3,40 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4971	1509	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4972	1509	8	8	SSD 240 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4973	1509	9	8	Dell P2219H; LG Flatron Slim L1980u	\N	manual	\N	2026-02-17 23:54:02.090047+03
4974	1509	9	10	МОЛ Ильин Л.К.\nМЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
4975	1509	10	11	721-W10P64-6	\N	manual	\N	2026-02-17 23:54:02.090047+03
4976	1509	10	12	10.10.10.6	\N	manual	\N	2026-02-17 23:54:02.090047+03
4977	1509	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4978	1509	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
4979	1513	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4980	1513	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4981	1513	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4982	1513	9	8	Philips 234E5QSB 23"; Philips 234E5QSB 23"	\N	manual	\N	2026-02-17 23:54:02.090047+03
4983	1513	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4984	1513	10	11	721-W10P64-143	\N	manual	\N	2026-02-17 23:54:02.090047+03
4985	1513	10	12	оптика\n192.168.10.208	\N	manual	\N	2026-02-17 23:54:02.090047+03
4986	1513	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4987	1513	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
4988	1517	6	8	Pentium Dual-Core T5450 1,66ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4989	1517	7	9	2 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4990	1517	8	8	200 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4991	1517	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
4992	1517	10	11	Sav-PC	\N	manual	\N	2026-02-17 23:54:02.090047+03
4993	1517	10	13	Win Vista Home (х32)	\N	manual	\N	2026-02-17 23:54:02.090047+03
4994	1517	10	14	Avast	\N	manual	\N	2026-02-17 23:54:02.090047+03
4995	1518	6	8	Core i7-6700 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
4996	1518	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4997	1518	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
4998	1518	9	8	Nec MultiSync AS221WM	\N	manual	\N	2026-02-17 23:54:02.090047+03
4999	1518	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
5000	1518	10	11	721-W10P64-143	\N	manual	\N	2026-02-17 23:54:02.090047+03
5001	1518	10	12	10.10.10.143	\N	manual	\N	2026-02-17 23:54:02.090047+03
5002	1518	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5003	1518	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
5004	1520	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5005	1520	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5006	1520	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5007	1520	9	8	Samsung S22C200; Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
5008	1520	9	10	МЦ.04.2\nМЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
5009	1520	10	11	721-W10P64-140	\N	manual	\N	2026-02-17 23:54:02.090047+03
5010	1520	10	12	оптика\n192.168.10.207	\N	manual	\N	2026-02-17 23:54:02.090047+03
5011	1520	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5012	1520	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
5013	1524	6	8	Core i3-7100T 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5014	1524	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5015	1524	8	8	SSD 250 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5016	1524	9	8	Samsung 27" C27F390FHI (Монитор Руфата); Dell P2219H	\N	manual	\N	2026-02-17 23:54:02.090047+03
5017	1524	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
5018	1524	10	11	721-w10p64-32	\N	manual	\N	2026-02-17 23:54:02.090047+03
5019	1524	10	12	10.10.10.32	\N	manual	\N	2026-02-17 23:54:02.090047+03
5020	1524	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5021	1524	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
5022	1527	6	8	Pentium Dual-Core E5700 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5023	1527	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5024	1527	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5025	1527	9	8	Samsung SyncMaster E2220	\N	manual	\N	2026-02-17 23:54:02.090047+03
5026	1527	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5027	1527	10	11	723-w7p64-71	\N	manual	\N	2026-02-17 23:54:02.090047+03
5028	1527	10	12	10.10.10.71	\N	manual	\N	2026-02-17 23:54:02.090047+03
5029	1527	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5030	1527	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
5031	1529	6	8	Core i3-10100,3,6GHz	\N	manual	\N	2026-02-17 23:54:02.090047+03
5032	1529	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5033	1529	8	8	SSD 480 Гб	\N	manual	\N	2026-02-17 23:54:02.090047+03
5034	1529	9	8	AOC 24P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
5035	1529	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
5036	1529	10	11	723-w10P64-69	\N	manual	\N	2026-02-17 23:54:02.090047+03
5037	1529	10	12	10.10.10.69	\N	manual	\N	2026-02-17 23:54:02.090047+03
5038	1529	10	13	Win10Pro x64	\N	manual	\N	2026-02-17 23:54:02.090047+03
5039	1529	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
5040	1531	6	8	Core i3-8100 3,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5041	1531	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5042	1531	8	8	SSD 240 ГБ; HDD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5043	1531	9	8	Dell U2412M; Dell P2720	\N	manual	\N	2026-02-17 23:54:02.090047+03
5044	1531	9	10	МЦ.04 (001438)\nМЦ.04 (001451)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5045	1531	10	11	807-PETROVYA	\N	manual	\N	2026-02-17 23:54:02.090047+03
5046	1531	10	12	DHCP (VLAN 214)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5047	1531	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5048	1531	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
5049	1534	6	8	Core i5-1135П7 2,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5050	1534	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5051	1534	8	8	SSD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5052	1534	10	11	Petrov-Note	\N	manual	\N	2026-02-17 23:54:02.090047+03
5053	1534	10	12	Не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
5054	1534	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5055	1535	6	8	Core i5-6500 3,2 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5056	1535	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5057	1535	8	8	500 Гб	\N	manual	\N	2026-02-17 23:54:02.090047+03
5058	1535	9	8	Dell U2412	\N	manual	\N	2026-02-17 23:54:02.090047+03
5059	1535	9	10	МЦ.04 (001425)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5060	1535	10	11	astra17.massir.ru	\N	manual	\N	2026-02-17 23:54:02.090047+03
5061	1535	10	12	Не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
5062	1535	10	13	Astra Linux 1.7 Special Edition	\N	manual	\N	2026-02-17 23:54:02.090047+03
5063	1537	6	8	Core i3-2100 3,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5064	1537	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5065	1537	8	8	500 Гб	\N	manual	\N	2026-02-17 23:54:02.090047+03
5066	1537	9	8	BENQ GL2450	\N	manual	\N	2026-02-17 23:54:02.090047+03
5067	1537	9	10	МЦ.04 (001257)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5068	1537	10	11	ARM01	\N	manual	\N	2026-02-17 23:54:02.090047+03
5069	1537	10	12	Не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
5070	1537	10	13	Astra Linux 1.6 Special Edition	\N	manual	\N	2026-02-17 23:54:02.090047+03
5071	1539	6	8	Core i5-4460 3,2 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5072	1539	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5073	1539	8	8	SSD 120 ГБ; HDD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5074	1539	9	8	BENQ GL2760	\N	manual	\N	2026-02-17 23:54:02.090047+03
5075	1539	9	10	МЦ.04 (001192)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5076	1539	10	11	srv1	\N	manual	\N	2026-02-17 23:54:02.090047+03
5077	1539	10	12	Не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
5078	1539	10	13	Astra Linux 1.6 Special Edition	\N	manual	\N	2026-02-17 23:54:02.090047+03
5079	1541	6	8	Core i7-10750HQ  2,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5080	1541	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5081	1541	8	8	SSD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5082	1541	10	11	Desktop B2143MC	\N	manual	\N	2026-02-17 23:54:02.090047+03
5083	1541	10	13	Win10H (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5084	1542	6	8	Core i3-8100 3,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5085	1542	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5086	1542	8	8	SSD 250 ГБ; HDD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5087	1542	9	8	BENQ GW2765	\N	manual	\N	2026-02-17 23:54:02.090047+03
5088	1542	9	10	БП-001303 (Информ. - 000144)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5089	1542	10	11	807-KARACHEVAEG	\N	manual	\N	2026-02-17 23:54:02.090047+03
5090	1542	10	12	DHCP (VLAN 214)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5091	1542	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5092	1542	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
5093	1544	6	8	Core i3-8100 3,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5094	1544	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5095	1544	8	8	SSD 250 ГБ; HDD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5096	1544	9	8	Dell P2720DC	\N	manual	\N	2026-02-17 23:54:02.090047+03
5097	1544	9	10	МЦ.04 (001462)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5098	1544	10	11	807-PYRIEVVA	\N	manual	\N	2026-02-17 23:54:02.090047+03
5099	1544	10	12	DHCP (VLAN 214)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5100	1544	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5101	1544	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
5102	1546	6	8	Core i3-8100 3,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5103	1546	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5104	1546	8	8	SSD 250 ГБ; HDD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5105	1546	9	8	Dell P2720DC	\N	manual	\N	2026-02-17 23:54:02.090047+03
5106	1546	9	10	МЦ.04 (001450)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5107	1546	10	11	807-GRIBUTIE	\N	manual	\N	2026-02-17 23:54:02.090047+03
5108	1546	10	12	DHCP (VLAN 214)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5109	1546	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5110	1546	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
5111	1548	6	8	Core i5-4670 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5112	1548	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5113	1548	8	8	SSD 120 ГБ; HDD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5114	1548	9	8	Dell P2720DC; Dell U2412	\N	manual	\N	2026-02-17 23:54:02.090047+03
5115	1548	9	10	МЦ.04 (001452)\nМЦ.04 (001423)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5116	1548	10	11	807-GULYAEVAV	\N	manual	\N	2026-02-17 23:54:02.090047+03
5117	1548	10	12	DHCP (VLAN 214)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5118	1548	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5119	1548	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
5120	1551	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5121	1551	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5122	1551	8	8	HDD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5123	1551	9	8	Dell P2720DC	\N	manual	\N	2026-02-17 23:54:02.090047+03
5124	1551	9	10	МЦ.04 (001460)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5125	1551	10	11	807-SERDYUKOVVY	\N	manual	\N	2026-02-17 23:54:02.090047+03
5126	1551	10	12	DHCP (VLAN 214)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5127	1551	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5128	1551	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
5129	1553	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5130	1553	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5131	1553	8	8	HDD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5132	1553	9	8	BENQ GW2760S	\N	manual	\N	2026-02-17 23:54:02.090047+03
5133	1553	9	10	МЦ.04 (001287)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5134	1553	10	11	807-TSYMBALOVAL	\N	manual	\N	2026-02-17 23:54:02.090047+03
5135	1553	10	12	DHCP (VLAN 214)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5136	1553	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5137	1553	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
5138	1555	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5139	1555	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5140	1555	8	8	HDD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5141	1555	9	8	Dell P2720DC	\N	manual	\N	2026-02-17 23:54:02.090047+03
5142	1555	9	10	МЦ.04 (001453)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5143	1555	10	11	807-ZUEVAA	\N	manual	\N	2026-02-17 23:54:02.090047+03
5144	1555	10	12	DHCP (VLAN 214)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5145	1555	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5146	1555	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
5147	1557	6	8	Core i3-8100 3,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5148	1557	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5149	1557	8	8	SSD 250 ГБ; HDD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5150	1557	9	8	BENQ GW2760	\N	manual	\N	2026-02-17 23:54:02.090047+03
5151	1557	9	10	МЦ.04 (001598)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5152	1557	10	11	807-GULYAEVVV	\N	manual	\N	2026-02-17 23:54:02.090047+03
5153	1557	10	12	DHCP (VLAN 214)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5154	1557	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5155	1557	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
5156	1559	6	8	Core i7-10750H 2,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5157	1559	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5158	1559	8	8	SSD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5159	1559	10	11	DESKTOP	\N	manual	\N	2026-02-17 23:54:02.090047+03
5160	1559	10	12	не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
5161	1559	10	13	Win11pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5162	1560	6	8	Core i3-8100 3,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5163	1560	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5164	1560	8	8	SSD 250 ГБ; HDD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5165	1560	9	8	Dell U2412Mc	\N	manual	\N	2026-02-17 23:54:02.090047+03
5166	1560	9	10	МЦ.04 (001437)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5167	1560	10	11	807-KUZNETSOVAV	\N	manual	\N	2026-02-17 23:54:02.090047+03
5168	1560	10	12	DHCP (VLAN 214)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5169	1560	10	13	Win10pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5170	1560	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
5171	1562	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5172	1562	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5173	1562	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5174	1562	9	8	Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
5175	1562	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
5176	1562	10	11	807z-KonovalovaLL	\N	manual	\N	2026-02-17 23:54:02.090047+03
5177	1562	10	12	DHCP (VLAN 205)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
5178	1562	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5179	1562	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
5180	1565	6	8	Core i3-2100 3,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5181	1565	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5182	1565	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5183	1565	9	8	Nec MultiSync E231W	\N	manual	\N	2026-02-17 23:54:02.090047+03
5184	1565	9	10	МЦ.04.1	\N	manual	\N	2026-02-17 23:54:02.090047+03
5185	1565	10	11	807z-W10P64-138	\N	manual	\N	2026-02-17 23:54:02.090047+03
5186	1565	10	12	10.2.2.138	\N	manual	\N	2026-02-17 23:54:02.090047+03
5187	1565	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5188	1565	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
5189	1568	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5190	1568	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5191	1568	8	8	SSD 240 ГБ; 2 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5192	1568	9	8	Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
5193	1568	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
5194	1568	10	11	807z-W7P64-134	\N	manual	\N	2026-02-17 23:54:02.090047+03
5195	1568	10	12	10.2.2.134	\N	manual	\N	2026-02-17 23:54:02.090047+03
5196	1568	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5197	1568	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
5198	1571	6	8	AMD 3020e 1.20 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5199	1571	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5200	1571	8	8	SSD 240 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5201	1571	9	8	15"	\N	manual	\N	2026-02-17 23:54:02.090047+03
5202	1571	10	11	NOTE5	\N	manual	\N	2026-02-17 23:54:02.090047+03
5203	1571	10	12	DHCP (VLAN 205)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
5204	1571	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5205	1571	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
5206	1573	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5207	1573	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5208	1573	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5209	1573	9	8	Samsung S22C200	\N	manual	\N	2026-02-17 23:54:02.090047+03
5210	1573	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
5211	1573	10	11	807z-PatashovaYV	\N	manual	\N	2026-02-17 23:54:02.090047+03
5212	1573	10	12	DHCP (VLAN 205)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
5213	1573	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5214	1573	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
5215	1576	6	8	Core i3-4160 3,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5216	1576	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5217	1576	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5218	1576	9	8	NEC MultiSync EA223WM	\N	manual	\N	2026-02-17 23:54:02.090047+03
5219	1576	9	10	МЦ.04.1	\N	manual	\N	2026-02-17 23:54:02.090047+03
5220	1576	10	11	807z-w10p64-133	\N	manual	\N	2026-02-17 23:54:02.090047+03
5221	1576	10	12	10.2.2.133	\N	manual	\N	2026-02-17 23:54:02.090047+03
5222	1576	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5223	1576	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
5224	1578	6	8	Core i3-3240 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5225	1578	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5226	1578	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5227	1578	10	11	807z-DugushkinaSV	\N	manual	\N	2026-02-17 23:54:02.090047+03
5228	1578	10	12	DHCP (VLAN 205)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
5229	1578	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5230	1578	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
5231	1580	6	8	Core i5-6500 3,2 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5232	1580	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5233	1580	8	8	SSD 240 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5234	1580	9	8	Nec EA221Wme	\N	manual	\N	2026-02-17 23:54:02.090047+03
5235	1580	10	11	807-Grechanova	\N	manual	\N	2026-02-17 23:54:02.090047+03
5236	1580	10	12	DHCP (VLAN 205)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
5237	1580	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5238	1580	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
5239	1583	6	8	Core i3-2130 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5240	1583	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5241	1583	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5242	1583	9	8	AOC 24P2Q; Nеc MultiSinc E222W	\N	manual	\N	2026-02-17 23:54:02.090047+03
5243	1583	9	10	МЦ.04\nНИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5244	1583	10	11	807g-MoskalevaNL	\N	manual	\N	2026-02-17 23:54:02.090047+03
5245	1583	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
5246	1583	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5247	1583	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
5248	1586	6	8	Core i5-3470 3,2 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5249	1586	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5250	1586	8	8	SSD 500 ГБ; HDD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5251	1586	9	8	AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
5252	1586	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
5253	1586	10	11	807g-VinogradovVV	\N	manual	\N	2026-02-17 23:54:02.090047+03
5254	1586	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
5255	1586	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5256	1586	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
5257	1588	6	8	Core i7-4770 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5258	1588	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5259	1588	8	8	SSD - 120 ГБ; 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5260	1588	9	8	AOC 27P2Q; Dell U2415	\N	manual	\N	2026-02-17 23:54:02.090047+03
5261	1588	9	10	МЦ.04\nМЦ.04.1	\N	manual	\N	2026-02-17 23:54:02.090047+03
5262	1588	10	11	807g -KutishevAV	\N	manual	\N	2026-02-17 23:54:02.090047+03
5263	1588	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
5264	1588	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5265	1588	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
5266	1592	6	8	Core i5-6600 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5267	1592	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5268	1592	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5269	1592	9	8	AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
5270	1592	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
5271	1592	10	11	807g-IvanovaOA	\N	manual	\N	2026-02-17 23:54:02.090047+03
5272	1592	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
5273	1592	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5274	1592	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
5275	1595	6	8	Core i3-2100 3,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5276	1595	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5277	1595	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5278	1595	9	8	Benq G2220HD	\N	manual	\N	2026-02-17 23:54:02.090047+03
5279	1595	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5280	1595	10	11	807-RICON	\N	manual	\N	2026-02-17 23:54:02.090047+03
5281	1595	10	12	не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
5282	1595	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5283	1595	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
5284	1597	6	8	Core i7-2600 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5285	1597	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5286	1597	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5287	1597	9	8	Nec MultiSync E231W; Nec MultiSync EA221WM	\N	manual	\N	2026-02-17 23:54:02.090047+03
5288	1597	9	10	НИИСУ\nНИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5289	1597	10	11	807g-GorokhovAA	\N	manual	\N	2026-02-17 23:54:02.090047+03
5290	1597	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
5291	1597	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5292	1597	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
5293	1600	6	8	Core i3-4160 3,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5294	1600	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5295	1600	8	8	2 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5296	1600	9	8	Samsung 24"S24D300H; Samsung 24"S24D300H	\N	manual	\N	2026-02-17 23:54:02.090047+03
5297	1600	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
5298	1600	10	11	807d-W10P64-235	\N	manual	\N	2026-02-17 23:54:02.090047+03
5299	1600	10	12	10.2.2.235	\N	manual	\N	2026-02-17 23:54:02.090047+03
5300	1600	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5301	1600	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
5302	1603	6	8	Core i5-10300H 2,5 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5303	1603	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5304	1603	8	8	500 ГБ SSD	\N	manual	\N	2026-02-17 23:54:02.090047+03
5305	1603	9	8	17"	\N	manual	\N	2026-02-17 23:54:02.090047+03
5306	1603	10	12	не в сети	\N	manual	\N	2026-02-17 23:54:02.090047+03
5307	1603	10	13	Win10 Home (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5308	1603	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
5309	1605	6	8	Core i3-4160 3,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5310	1605	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5311	1605	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5312	1605	9	8	Samsung SyncMaster E1920; Samsung SyncMaster E1920	\N	manual	\N	2026-02-17 23:54:02.090047+03
5313	1605	9	10	99036\n99036	\N	manual	\N	2026-02-17 23:54:02.090047+03
5314	1605	10	11	807d-W10Px64-11	\N	manual	\N	2026-02-17 23:54:02.090047+03
5315	1605	10	12	10.2.2.11	\N	manual	\N	2026-02-17 23:54:02.090047+03
5316	1605	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5317	1605	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
5318	1608	6	8	Core i3-4160 3,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5319	1608	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5320	1608	8	8	2 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5321	1608	9	8	Dell U2412M; Samsung SyncMaster E1920	\N	manual	\N	2026-02-17 23:54:02.090047+03
5322	1608	9	10	МЦ.04.1\n99036	\N	manual	\N	2026-02-17 23:54:02.090047+03
5323	1608	10	11	807d-W10Px64-2-147	\N	manual	\N	2026-02-17 23:54:02.090047+03
5324	1608	10	12	10.2.2.147	\N	manual	\N	2026-02-17 23:54:02.090047+03
5325	1608	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5326	1608	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
5327	1611	6	8	Core i3-3250 3,5 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5328	1611	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5329	1611	8	8	1ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5330	1611	9	8	Samsung 24"S24D300H	\N	manual	\N	2026-02-17 23:54:02.090047+03
5331	1611	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
5332	1611	10	11	807-W10p64-125	\N	manual	\N	2026-02-17 23:54:02.090047+03
5333	1611	10	12	10.2.2.125	\N	manual	\N	2026-02-17 23:54:02.090047+03
5334	1611	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5335	1611	10	14	KES10	\N	manual	\N	2026-02-17 23:54:02.090047+03
5336	1613	6	8	Core i3-4160 3,6 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5337	1613	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5338	1613	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5339	1613	9	8	Dell Г2313Hf	\N	manual	\N	2026-02-17 23:54:02.090047+03
5340	1613	9	10	МЦ.04.1	\N	manual	\N	2026-02-17 23:54:02.090047+03
5341	1613	10	11	810a-LukyanchikovaKA	\N	manual	\N	2026-02-17 23:54:02.090047+03
5342	1613	10	12	DHCP (VLAN 205)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
5343	1613	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5344	1613	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
5345	1616	6	8	Core i5-6500 3,2 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5346	1616	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5347	1616	8	8	SSD 240 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5348	1616	9	8	Nec MultiSync EA221WMe; Nec MultiSync EA221WMe	\N	manual	\N	2026-02-17 23:54:02.090047+03
5349	1616	9	10	МЦ.04.1\nМЦ.04.1	\N	manual	\N	2026-02-17 23:54:02.090047+03
5350	1616	10	11	114-W10p64-90	\N	manual	\N	2026-02-17 23:54:02.090047+03
5351	1616	10	12	10.1.4.90	\N	manual	\N	2026-02-17 23:54:02.090047+03
5352	1616	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5353	1616	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
5354	1620	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5355	1620	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5356	1620	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5357	1620	9	8	LG Flatron L192WS	\N	manual	\N	2026-02-17 23:54:02.090047+03
5358	1620	9	10	Списан	\N	manual	\N	2026-02-17 23:54:02.090047+03
5359	1620	10	11	810A-SEMINAME	\N	manual	\N	2026-02-17 23:54:02.090047+03
5360	1620	10	12	DHCP (VLAN 205)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
5361	1620	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5362	1620	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
5363	1622	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5364	1622	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5365	1622	8	8	SSD 250ГБ; 2 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5366	1622	9	8	Benq GL2450	\N	manual	\N	2026-02-17 23:54:02.090047+03
5367	1622	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
5368	1622	10	11	810-GribakinaIY	\N	manual	\N	2026-02-17 23:54:02.090047+03
5369	1622	10	12	DHCP (VLAN 205)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
5370	1622	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5371	1622	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
5372	1625	6	8	Core i3-2130 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5373	1625	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5374	1625	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5375	1625	9	8	Dell U2412M	\N	manual	\N	2026-02-17 23:54:02.090047+03
5376	1625	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5377	1625	10	11	810b-RolduginaTL	\N	manual	\N	2026-02-17 23:54:02.090047+03
5378	1625	10	12	DHCP (VLAN 205)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
5379	1625	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5380	1625	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
5381	1627	6	8	Core i3-2130 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5382	1627	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5383	1627	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5384	1627	9	8	Dell E2314H	\N	manual	\N	2026-02-17 23:54:02.090047+03
5385	1627	10	11	810b-GolevaRI	\N	manual	\N	2026-02-17 23:54:02.090047+03
5386	1627	10	12	DHCP (VLAN 205)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
5387	1627	10	13	Win7 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5388	1627	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
5389	1629	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5390	1629	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5391	1629	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5392	1629	9	8	AOC 24P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
5393	1629	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
5394	1629	10	11	810-SHAKHOVAYS	\N	manual	\N	2026-02-17 23:54:02.090047+03
5395	1629	10	12	DHCP (VLAN 205)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
5396	1629	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5397	1629	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
5398	1631	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5399	1631	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5400	1631	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5401	1631	9	8	Samsung S27F358FWI	\N	manual	\N	2026-02-17 23:54:02.090047+03
5402	1631	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
5403	1631	10	11	810v-GarbuzovaEY	\N	manual	\N	2026-02-17 23:54:02.090047+03
5404	1631	10	12	10.2.2.131	\N	manual	\N	2026-02-17 23:54:02.090047+03
5405	1631	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5406	1631	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
5407	1633	6	8	Core i5-9300H 2,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5408	1633	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5409	1633	8	8	1000 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5410	1633	9	8	15.6"	\N	manual	\N	2026-02-17 23:54:02.090047+03
5411	1633	10	13	Win 10 Home (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5412	1635	6	8	Core i3-2100 3,1 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5413	1635	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5414	1635	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5415	1635	9	8	LG Flatron IPS235	\N	manual	\N	2026-02-17 23:54:02.090047+03
5416	1635	10	11	810V-GarbuzovaEU	\N	manual	\N	2026-02-17 23:54:02.090047+03
5417	1635	10	12	DHCP (VLAN 205)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
5418	1635	10	13	Win10 ProX64	\N	manual	\N	2026-02-17 23:54:02.090047+03
5419	1635	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
5420	1637	6	8	Core i3-2130 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5421	1637	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5422	1637	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5423	1637	9	8	Samsung SyncMaster SA200	\N	manual	\N	2026-02-17 23:54:02.090047+03
5424	1637	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
5425	1637	10	11	811-PashkovaMV	\N	manual	\N	2026-02-17 23:54:02.090047+03
5426	1637	10	12	DHCP (VLAN 205)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
5427	1637	10	13	Win10 ProX64	\N	manual	\N	2026-02-17 23:54:02.090047+03
5428	1637	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
5429	1640	6	8	Core i3-2130 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5430	1640	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5431	1640	8	8	500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5432	1640	9	8	Asus PA249	\N	manual	\N	2026-02-17 23:54:02.090047+03
5433	1640	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5434	1640	10	11	811-DzhulaevaVS	\N	manual	\N	2026-02-17 23:54:02.090047+03
5435	1640	10	12	DHCP (VLAN 205)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
5436	1640	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5437	1640	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
5438	1643	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5439	1643	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5440	1643	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5441	1643	9	8	Samsung SyncMaster B2240	\N	manual	\N	2026-02-17 23:54:02.090047+03
5442	1643	9	10	МЦ.04.2	\N	manual	\N	2026-02-17 23:54:02.090047+03
5443	1643	10	11	811-Computer	\N	manual	\N	2026-02-17 23:54:02.090047+03
5444	1643	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
5445	1643	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5446	1643	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
5447	1645	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5448	1645	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5449	1645	8	8	SSD 240 ГБ; 2 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5450	1645	9	8	AOC 27P2Q	\N	manual	\N	2026-02-17 23:54:02.090047+03
5451	1645	9	10	МЦ.04	\N	manual	\N	2026-02-17 23:54:02.090047+03
5452	1645	10	11	812b-Salkova	\N	manual	\N	2026-02-17 23:54:02.090047+03
5453	1645	10	12	DHCP (VLAN 205)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
5454	1645	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5455	1645	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
5456	1648	6	8	Core i5 – 12450H, 2,00ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5457	1648	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5458	1648	8	8	SSD 250 ГБ; SSD 1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5459	1648	9	8	15,6"	\N	manual	\N	2026-02-17 23:54:02.090047+03
5460	1648	10	11	SALKOVANV	\N	manual	\N	2026-02-17 23:54:02.090047+03
5461	1648	10	12	10.2.2.197	\N	manual	\N	2026-02-17 23:54:02.090047+03
5462	1648	10	13	Win11 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5463	1648	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
5464	1650	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5465	1650	7	9	16 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5466	1650	8	8	SSD 240 ГБ; 2 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5467	1650	9	8	Dell E2313H; Dell E2313H	\N	manual	\N	2026-02-17 23:54:02.090047+03
5468	1650	9	10	НИИСУ\nНИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5469	1650	10	11	812-BelobaevaE	\N	manual	\N	2026-02-17 23:54:02.090047+03
5470	1650	10	12	DHCP (VLAN 205)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
5471	1650	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5472	1650	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
5473	1654	6	8	Core i5-2500 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5474	1654	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5475	1654	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5476	1654	9	8	NEC Multisync E221WMe	\N	manual	\N	2026-02-17 23:54:02.090047+03
5477	1654	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5478	1654	10	11	812a-ShitovaEA	\N	manual	\N	2026-02-17 23:54:02.090047+03
5479	1654	10	12	DHCP (VLAN 205)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
5480	1654	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5481	1654	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
5482	1656	6	8	Core i7-2600 3,4 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5483	1656	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5484	1656	8	8	1 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5485	1656	9	8	Nec MultiSync E231W	\N	manual	\N	2026-02-17 23:54:02.090047+03
5486	1656	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5487	1656	10	11	805-MIHEEVYA	\N	manual	\N	2026-02-17 23:54:02.090047+03
5488	1656	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
5489	1656	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5490	1656	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
5491	1658	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5492	1658	7	9	8 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5493	1658	8	8	SSD 480 ГБ; HDD 500 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5494	1658	9	8	Benq GL2450	\N	manual	\N	2026-02-17 23:54:02.090047+03
5495	1658	9	10	НИИСУ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5496	1658	10	11	805-GLEBOVAAV	\N	manual	\N	2026-02-17 23:54:02.090047+03
5497	1658	10	12	DHCP (VLAN 207)\nvniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
5498	1658	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5499	1658	10	14	KES12	\N	manual	\N	2026-02-17 23:54:02.090047+03
5500	1660	6	8	Xeon X5650 2,67ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5501	1660	7	9	24 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5502	1660	8	8	300 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5503	1660	10	11	GW1	\N	manual	\N	2026-02-17 23:54:02.090047+03
5504	1660	10	12	10.10.10.1\n10.1.4.111	\N	manual	\N	2026-02-17 23:54:02.090047+03
5505	1660	10	13	Win Server 2008 R2	\N	manual	\N	2026-02-17 23:54:02.090047+03
5506	1661	6	8	Xeon X5650 2,67ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5507	1661	7	9	24 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5508	1661	8	8	300 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5509	1661	10	11	Cons1	\N	manual	\N	2026-02-17 23:54:02.090047+03
5510	1661	10	12	10.1.4.186	\N	manual	\N	2026-02-17 23:54:02.090047+03
5511	1661	10	13	Win Server 2008 R2	\N	manual	\N	2026-02-17 23:54:02.090047+03
5512	1662	6	8	Xeon X5650 2,67ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5513	1662	7	9	24 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5514	1662	8	8	146 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5515	1663	6	8	2 х Intel Xeon-S\n4208	\N	manual	\N	2026-02-17 23:54:02.090047+03
5516	1663	7	9	64 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5517	1663	8	8	280ГБ (RAID1)  SAS 300ГБ; 2; 4 ТБ (RAID5)  SAS 900ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5518	1663	10	13	ESXi (Win Server 2008 R2)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5519	1664	6	8	Xeon E3-1270,  3,8 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5520	1664	7	9	32 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5521	1664	8	8	300 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5522	1664	10	12	192.168.9.55	\N	manual	\N	2026-02-17 23:54:02.090047+03
5523	1664	10	13	IDECO NGFW	\N	manual	\N	2026-02-17 23:54:02.090047+03
5524	1665	10	12	10.1.4.64	\N	manual	\N	2026-02-17 23:54:02.090047+03
5525	1666	6	8	2 х Intel Xeon-S\n4208	\N	manual	\N	2026-02-17 23:54:02.090047+03
5526	1666	7	9	96 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5527	1666	8	8	600ГБ (RAID1)  SAS 600ГБ; 600ГБ (RAID1)  SAS 600ГБ; 1; 6ТБ (RAID5)  SAS 900ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5528	1666	10	11	1c-srv.vniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
5529	1666	10	13	Win Serv 2016 st	\N	manual	\N	2026-02-17 23:54:02.090047+03
5530	1667	6	8	Intel Xeon X5660 2.80GHz - 2 шт.	\N	manual	\N	2026-02-17 23:54:02.090047+03
5531	1667	7	9	96 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5532	1667	8	8	24 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5533	1667	10	12	192.168.9.43\n(vlan900)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5534	1668	6	8	Intel Xeon X5660 2.80GHz - 2 шт.	\N	manual	\N	2026-02-17 23:54:02.090047+03
5535	1668	7	9	96 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5536	1668	8	8	24 ТБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5537	1668	10	12	192.168.9.46 (vlan900)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5538	1670	6	8	2 х Intel Xeon E5-2640, 2,5 Ггц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5539	1670	7	9	64 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5540	1670	8	8	60ТБ 7 X 10 TB SATA в RAID5 + 1  диск в горячем резерве (Apdaptec ASR6805 raid controller)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5541	1670	10	11	mercury.vniicentr.local	\N	manual	\N	2026-02-17 23:54:02.090047+03
5542	1670	10	13	Gentoo linux	\N	manual	\N	2026-02-17 23:54:02.090047+03
5543	1671	6	8	Xeon X5650 2,67ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5544	1671	7	9	64 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5545	1671	8	8	HDD: 6x280 GB SAS 10K RAID0 (Объем 1.64 ТБ) - ESXI; STORAGE	\N	manual	\N	2026-02-17 23:54:02.090047+03
5546	1672	6	8	Xeon X5650 2,67ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5547	1672	7	9	52 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5548	1672	8	8	HDD: 2x160 GB 10K SAS RAID1 (Объем 160 Гб) -  4x280 GB SAS RAID10 (Объем 560 Гб) - STORAGE	\N	manual	\N	2026-02-17 23:54:02.090047+03
5549	1673	6	8	INTEL XEON X5650 2600 MHz      - 2 шт.	\N	manual	\N	2026-02-17 23:54:02.090047+03
5550	1673	7	9	64 Гб	\N	manual	\N	2026-02-17 23:54:02.090047+03
5551	1673	8	8	HDD: 2x280 GB SAS2 10K RAID1; 4x 560GB SAS2 10K RAID10 (Объем 1.1 ТБ)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5552	1674	6	8	INTEL XEON E5450 2000 MHz	\N	manual	\N	2026-02-17 23:54:02.090047+03
5553	1674	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5554	1674	8	8	2x750 GB SATA2 5; 4K RAID1 (Объем 750 ГБ)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5555	1675	6	8	Intel QuadCore Intel Xeon E5-2407, 2,2ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5556	1675	7	9	32 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5557	1676	6	8	AMD Athlon 3150U 2.40 ГГц	\N	manual	\N	2026-02-17 23:54:02.090047+03
5558	1676	7	9	4 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5559	1676	8	8	SSD 240 ГБ	\N	manual	\N	2026-02-17 23:54:02.090047+03
5560	1676	9	8	15"	\N	manual	\N	2026-02-17 23:54:02.090047+03
5561	1676	10	13	Win11H(x64)	\N	manual	\N	2026-02-17 23:54:02.090047+03
5562	1676	10	14	KES11	\N	manual	\N	2026-02-17 23:54:02.090047+03
5563	1678	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5564	1681	12	12	192.168.0.9	\N	manual	\N	2026-02-17 23:54:02.090047+03
5565	1682	12	12	192.168.0.10	\N	manual	\N	2026-02-17 23:54:02.090047+03
5566	1683	12	12	192.168.20.5	\N	manual	\N	2026-02-17 23:54:02.090047+03
5567	1684	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5568	1688	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5569	1691	12	12	10.1.4.244	\N	manual	\N	2026-02-17 23:54:02.090047+03
5570	1692	12	12	10.1.4.38	\N	manual	\N	2026-02-17 23:54:02.090047+03
5571	1695	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5572	1696	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5573	1697	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5574	1698	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5575	1700	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5576	1703	12	12	10.1.4.211	\N	manual	\N	2026-02-17 23:54:02.090047+03
5577	117	12	12	10.1.4.215	\N	manual	\N	2026-02-17 23:54:02.090047+03
5578	1706	12	12	10.1.4.214	\N	manual	\N	2026-02-17 23:54:02.090047+03
5579	1707	12	12	DHCP (VLAN 207) 192.168.207.238	\N	manual	\N	2026-02-17 23:54:02.090047+03
5580	1708	12	12	DHCP (VLAN 207)\n192.168.207.236	\N	manual	\N	2026-02-17 23:54:02.090047+03
5581	1709	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5582	1710	12	12	vniicentr.local\n10.0.208.123	\N	manual	\N	2026-02-17 23:54:02.090047+03
5583	1711	12	12	10.10.10.51	\N	manual	\N	2026-02-17 23:54:02.090047+03
5584	1712	12	12	192.168.207.133	\N	manual	\N	2026-02-17 23:54:02.090047+03
5585	1713	12	12	10.2.2.9	\N	manual	\N	2026-02-17 23:54:02.090047+03
5586	1714	12	12	10.2.2.10	\N	manual	\N	2026-02-17 23:54:02.090047+03
5587	1717	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5588	1719	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5589	1721	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5590	1722	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5591	1724	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5592	1725	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5593	1727	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5594	1731	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5595	1736	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5596	1738	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5597	213	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5598	1740	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5599	1742	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5600	1745	12	12	192.168.207.162	\N	manual	\N	2026-02-17 23:54:02.090047+03
5601	1752	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5602	1753	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5603	1757	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5604	1759	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5605	1760	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5606	1761	12	12	10.1.4.4	\N	manual	\N	2026-02-17 23:54:02.090047+03
5607	1762	12	12	10.1.4.13	\N	manual	\N	2026-02-17 23:54:02.090047+03
5608	1766	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5609	1767	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5610	1769	12	12	192.168.206.249	\N	manual	\N	2026-02-17 23:54:02.090047+03
5611	1774	12	12	не подключен	\N	manual	\N	2026-02-17 23:54:02.090047+03
5612	1775	12	12	10.1.4.213	\N	manual	\N	2026-02-17 23:54:02.090047+03
5613	1777	12	12	10.10.10.176	\N	manual	\N	2026-02-17 23:54:02.090047+03
5614	1778	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5615	1779	12	12	10.10.10.127	\N	manual	\N	2026-02-17 23:54:02.090047+03
5616	1780	12	12	10.10.10.253	\N	manual	\N	2026-02-17 23:54:02.090047+03
5617	1782	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5618	1783	12	12	10.2.2.41	\N	manual	\N	2026-02-17 23:54:02.090047+03
5619	1784	12	12	10.2.2.50	\N	manual	\N	2026-02-17 23:54:02.090047+03
5620	342	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5621	1786	12	12	192.168.207.168	\N	manual	\N	2026-02-17 23:54:02.090047+03
5622	1787	12	12	192.168.207.113	\N	manual	\N	2026-02-17 23:54:02.090047+03
5623	1788	12	12	10.1.4.73	\N	manual	\N	2026-02-17 23:54:02.090047+03
5624	1789	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5625	1790	12	12	192.168.207.181	\N	manual	\N	2026-02-17 23:54:02.090047+03
5626	1791	12	12	192.168.207.182	\N	manual	\N	2026-02-17 23:54:02.090047+03
5627	1792	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5628	1793	12	12	10.1.4.172	\N	manual	\N	2026-02-17 23:54:02.090047+03
5629	1794	12	12	10.1.4.232	\N	manual	\N	2026-02-17 23:54:02.090047+03
5630	1795	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5631	1797	12	12	10.1.4.179	\N	manual	\N	2026-02-17 23:54:02.090047+03
5632	1798	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5633	1799	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5634	1800	12	12	DHCP\nvniicentr.local\n192.168.205.164	\N	manual	\N	2026-02-17 23:54:02.090047+03
5635	1801	12	12	DHCP\nvniicentr.local   \n192.168.207.82	\N	manual	\N	2026-02-17 23:54:02.090047+03
5636	1802	12	12	DHCP\nvniicentr.local   \n192.168.205.178	\N	manual	\N	2026-02-17 23:54:02.090047+03
5637	1803	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5638	1804	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5639	1805	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5640	407	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5641	1808	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5642	1809	12	12	10.2.2.152	\N	manual	\N	2026-02-17 23:54:02.090047+03
5643	1810	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5644	1811	12	12	DHCP\nvniicentr.local\n192.168.207.120	\N	manual	\N	2026-02-17 23:54:02.090047+03
5645	1812	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5646	1813	12	12	DHCP\nvniicentr.local   \n192.168.207.101	\N	manual	\N	2026-02-17 23:54:02.090047+03
5647	1814	12	12	DHCP\nvniicentr.local   \n192.168.207.223	\N	manual	\N	2026-02-17 23:54:02.090047+03
5648	1815	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5649	1816	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5650	1817	12	12	10.2.2.82	\N	manual	\N	2026-02-17 23:54:02.090047+03
5651	1818	12	12	vniicentr.local\n10.0.208.106	\N	manual	\N	2026-02-17 23:54:02.090047+03
5652	1819	12	12	vniicentr.local\n10.0.208.110	\N	manual	\N	2026-02-17 23:54:02.090047+03
5653	1820	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5654	1821	12	12	10.200.12.64	\N	manual	\N	2026-02-17 23:54:02.090047+03
5655	1822	12	12	Закрытая сеть	\N	manual	\N	2026-02-17 23:54:02.090047+03
5656	1823	12	12	Закрытая сеть	\N	manual	\N	2026-02-17 23:54:02.090047+03
5657	1824	12	12	Закрытая сеть	\N	manual	\N	2026-02-17 23:54:02.090047+03
5658	1825	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5659	1826	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5660	1827	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5661	1828	12	12	10.2.2.107	\N	manual	\N	2026-02-17 23:54:02.090047+03
5662	1829	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5663	1830	12	12	10.2.2.106	\N	manual	\N	2026-02-17 23:54:02.090047+03
5664	1831	12	12	не подключен кабель	\N	manual	\N	2026-02-17 23:54:02.090047+03
5665	1832	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5666	1833	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5667	1835	12	12	10.2.2.31	\N	manual	\N	2026-02-17 23:54:02.090047+03
5668	1838	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5669	1839	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5670	1840	12	12	vniicentr.local\n192.168.207.228	\N	manual	\N	2026-02-17 23:54:02.090047+03
5671	1841	12	12	vniicentr.local\n192.168.207.214	\N	manual	\N	2026-02-17 23:54:02.090047+03
5672	1842	12	12	vniicentr.local\n192.168.207.217	\N	manual	\N	2026-02-17 23:54:02.090047+03
5673	1843	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5674	544	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5675	1847	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5676	1849	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5677	1852	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5678	1853	12	12	10.10.10.107	\N	manual	\N	2026-02-17 23:54:02.090047+03
5679	1855	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5680	1858	12	12	10.2.2.233	\N	manual	\N	2026-02-17 23:54:02.090047+03
5681	1859	12	12	10.2.2.237	\N	manual	\N	2026-02-17 23:54:02.090047+03
5682	1861	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5683	1862	12	12	10.2.2.48	\N	manual	\N	2026-02-17 23:54:02.090047+03
5684	1863	12	12	10.2.2.252	\N	manual	\N	2026-02-17 23:54:02.090047+03
5685	1864	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5686	1865	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5687	1866	12	12	10.10.10.56	\N	manual	\N	2026-02-17 23:54:02.090047+03
5688	1870	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5689	1871	12	12	10.2.2.193	\N	manual	\N	2026-02-17 23:54:02.090047+03
5690	1872	12	12	10.1.4.39	\N	manual	\N	2026-02-17 23:54:02.090047+03
5691	622	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5692	1874	12	12	10.1.4.17	\N	manual	\N	2026-02-17 23:54:02.090047+03
5693	1875	12	12	10.10.10.50	\N	manual	\N	2026-02-17 23:54:02.090047+03
5694	1876	12	12	10.10.10.123	\N	manual	\N	2026-02-17 23:54:02.090047+03
5695	1878	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5696	1879	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5697	1880	12	12	DHCP, vniicentr.local, 192.168.207.111	\N	manual	\N	2026-02-17 23:54:02.090047+03
5698	1881	12	12	DHCP, vniicentr.local, 192.168.207.121	\N	manual	\N	2026-02-17 23:54:02.090047+03
5699	1882	12	12	10.10.10.25	\N	manual	\N	2026-02-17 23:54:02.090047+03
5700	1883	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5701	1884	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5702	1887	12	12	10.10.10.70	\N	manual	\N	2026-02-17 23:54:02.090047+03
5703	1888	12	12	10.10.10.72	\N	manual	\N	2026-02-17 23:54:02.090047+03
5704	1890	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5705	1891	12	12	DHCP (VLAN 214)\n10.0.214.146	\N	manual	\N	2026-02-17 23:54:02.090047+03
5706	1892	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5707	1893	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5708	1894	12	12	DHCP (VLAN 214)\n10.0.214.138	\N	manual	\N	2026-02-17 23:54:02.090047+03
5709	1895	12	12	DHCP (VLAN 214)\n10.0.214.141	\N	manual	\N	2026-02-17 23:54:02.090047+03
5710	1896	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5711	1897	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5712	1898	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5713	1899	12	12	DHCP (VLAN 214)\n10.0.214.143	\N	manual	\N	2026-02-17 23:54:02.090047+03
5714	1900	12	12	RJ-45 прямо к ноутбуку	\N	manual	\N	2026-02-17 23:54:02.090047+03
5715	1901	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5716	1904	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5717	1905	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5718	1906	12	12	10.1.4.65	\N	manual	\N	2026-02-17 23:54:02.090047+03
5719	1907	12	12	DHCP (VLAN 207)\nvniicentr.local\n192.168.207.186	\N	manual	\N	2026-02-17 23:54:02.090047+03
5720	1909	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5721	1910	12	12	DHCP\nvniicentr.local\n192.168.205.200	\N	manual	\N	2026-02-17 23:54:02.090047+03
5722	1911	12	12	10.2.2.60	\N	manual	\N	2026-02-17 23:54:02.090047+03
5723	1912	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5724	1913	12	12	DHCP\nvniicentr.local\n192.168.205.167	\N	manual	\N	2026-02-17 23:54:02.090047+03
5725	1914	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5726	1915	12	12	DHCP\nvniicentr.local\n192.168.205.12	\N	manual	\N	2026-02-17 23:54:02.090047+03
5727	1916	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5728	1917	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5729	1918	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5730	1919	12	12	DHCP\nvniicentr.local\n192.168.205.217	\N	manual	\N	2026-02-17 23:54:02.090047+03
5731	1920	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5732	1921	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5733	1922	12	12	192.168.205.179	\N	manual	\N	2026-02-17 23:54:02.090047+03
5734	1923	12	12	DHCP\nvniicentr.local\n192.168.205.10	\N	manual	\N	2026-02-17 23:54:02.090047+03
5735	1924	12	12	USB для общего ПК	\N	manual	\N	2026-02-17 23:54:02.090047+03
5736	1926	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5737	1927	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5738	1928	12	12	DHCP\nvniicentr.local\n192.168.207.151	\N	manual	\N	2026-02-17 23:54:02.090047+03
5739	1929	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5740	1930	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5741	1931	12	12	10.2.2.216	\N	manual	\N	2026-02-17 23:54:02.090047+03
5742	792	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5743	1933	12	12	DHCP (VLAN 214)\n10.0.214.118	\N	manual	\N	2026-02-17 23:54:02.090047+03
5744	1934	12	12	DHCP (VLAN 214)\n10.0.214.121	\N	manual	\N	2026-02-17 23:54:02.090047+03
5745	1935	12	12	USB	\N	manual	\N	2026-02-17 23:54:02.090047+03
5746	1936	12	12	DHCP (VLAN 214)\n10.0.214.102	\N	manual	\N	2026-02-17 23:54:02.090047+03
\.


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.permissions (id, perm_code, perm_name, description, created_at) FROM stdin;
\.


--
-- Data for Name: role_permissions; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.role_permissions (id, role_id, permission_id, granted_by, granted_at) FROM stdin;
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.roles (id, role_code, role_name, description, is_system, is_archived, created_at, updated_at) FROM stdin;
1	admin	Администратор	Полный доступ к данным и настройкам	t	f	2026-02-12 11:12:45.835301+03	2026-02-12 11:12:45.835301+03
2	operator	Оператор	Обработка и сопровождение заявок	t	f	2026-02-12 11:12:45.835301+03	2026-02-12 11:12:45.835301+03
3	user	Пользователь	Создание и просмотр собственных заявок	t	f	2026-02-12 11:12:45.835301+03	2026-02-12 11:12:45.835301+03
\.


--
-- Data for Name: software; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.software (id, name, version, created_at) FROM stdin;
900001	Microsoft Windows 10 Pro	21H2	2026-02-13 22:54:56
900002	Microsoft Office	2019	2026-02-13 22:54:56
900003	Astra Linux	1.7	2026-02-13 22:54:56
900004	Kaspersky Endpoint Security	12.3	2026-02-13 22:54:56
900005	1C:Предприятие	8.3	2026-02-13 22:54:56
900006	Adobe Acrobat Reader	DC	2026-02-13 22:54:56
900007	Google Chrome	120	2026-02-13 22:54:56
900008	7-Zip	23.01	2026-02-13 22:54:56
900009	VLC Media Player	3.0	2026-02-13 22:54:56
900010	SEED-SW-10	1.0	2026-02-13 22:54:56
\.


--
-- Data for Name: spr_chars; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.spr_chars (id, name, description, measurement_unit, is_archived, created_at, updated_at) FROM stdin;
8	Модель	\N	\N	f	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
9	Объём	\N	\N	f	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
10	№ монитора	\N	\N	f	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
11	Имя ПК	\N	\N	f	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
12	IP адрес	\N	\N	f	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
13	ОС	\N	\N	f	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
14	Антивирус	\N	\N	f	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
\.


--
-- Data for Name: spr_parts; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.spr_parts (id, name, description, is_archived, created_at, updated_at) FROM stdin;
6	ЦП	\N	f	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
7	ОЗУ	\N	f	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
8	Накопитель	\N	f	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
9	Монитор	\N	f	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
10	ПК	\N	f	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
12	Принтер	\N	f	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03
\.


--
-- Data for Name: task_attachments; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.task_attachments (id, task_id, attachment_id, linked_by, linked_at) FROM stdin;
\.


--
-- Data for Name: task_equipment; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.task_equipment (id, task_id, equipment_id, relation_type, is_primary, linked_by, linked_at) FROM stdin;
13	2	8	related	f	1	2026-02-13 23:36:56.053291+03
14	1	4	related	f	1	2026-02-13 23:36:57.640705+03
15	3	16	related	f	1	2026-02-17 21:30:26.62094+03
17	4	4	related	f	1	2026-02-17 22:11:51.900719+03
\.


--
-- Data for Name: task_history; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.task_history (id, task_id, field_name, old_value, new_value, changed_by, changed_at, comment) FROM stdin;
1	3	status_id	1	5	1	2026-02-13 21:08:23.244481+03	\N
2	3	executor_id		5	1	2026-02-13 21:08:25.883518+03	\N
3	2	status_id	1	4	1	2026-02-13 21:08:27.608212+03	\N
4	2	executor_id		4	1	2026-02-13 21:08:29.200163+03	\N
5	2	executor_id	4	1	1	2026-02-13 21:08:32.020479+03	\N
6	3	status_id	5	2	1	2026-02-13 23:36:27.424756+03	\N
7	2	status_id	4	2	1	2026-02-13 23:36:29.236627+03	\N
8	1	status_id	1	2	1	2026-02-13 23:36:30.495633+03	\N
9	3	executor_id	5	20	1	2026-02-13 23:36:53.460292+03	\N
10	2	executor_id	1	20	1	2026-02-13 23:36:56.059892+03	\N
11	1	executor_id		20	1	2026-02-13 23:36:57.647103+03	\N
12	3	comment	\N	sdasdad	1	2026-02-17 21:30:26.632058+03	\N
13	5	executor_id		13	1	2026-02-17 22:11:50.123785+03	\N
14	4	executor_id		8	1	2026-02-17 22:11:51.908599+03	\N
\.


--
-- Data for Name: tasks; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.tasks (id, task_number, title, description, status_id, requester_id, executor_id, priority, due_at, closed_at, comment, attachments_legacy, is_deleted, deleted_at, deleted_by, delete_reason, created_at, updated_at) FROM stdin;
2	\N	\N	Хуита	2	4	20	medium	\N	\N	\N	\N	f	\N	\N	\N	2026-02-13 20:43:55.078886+03	2026-02-13 23:36:56.045592+03
1	\N	\N	пизда ему	2	4	20	medium	\N	\N	\N	\N	f	\N	\N	\N	2026-02-13 20:43:30.296644+03	2026-02-13 23:36:57.633852+03
3	\N	\N	123	2	4	20	medium	\N	\N	sdasdad	\N	f	\N	\N	\N	2026-02-13 20:46:21.039945+03	2026-02-17 21:30:26.595158+03
5	\N	\N	\r\nДанные БД хранятся в томе Docker и сохраняются между запусками.\r\n\r\n## Полезные команды\r\n\r\n| Действие              | Команда |\r\n|-----------------------|--------|\r\n| Логи                  | `docker compose logs -f` |\r\n| Логи только БД        | `docker compose logs -f db` |\r\n| Войти в контейнер PHP | `docker compose exec php bash` |\r\n| Миграции              | `docker compose exec php php /app/yii migrate --migrationPath=@app/migrations` |\r\n\r\n## Структура папки docker\r\n\r\n- `docker-compose.yml` — описание сервисов (БД, приложение)\r\n- `.env.example` — пример переменных окружения (скопировать в `.env`)\r\n- `init/01-init.sh` — скрипт инициализации БД из дампа\r\n- `README.md` — эта инструкция\r\n\r\nПеременные окружения (в т.ч. из `.env`) передаются в контейнеры; приложение читает их в `ias_uch_vnii/config/db.php` и подключается к контейнеру БД по имени сервиса `db`.\r\n	1	1	13	medium	\N	\N	\N	\N	f	\N	\N	\N	2026-02-17 22:11:13.716713+03	2026-02-17 22:11:50.112483+03
4	\N	\N	Сдесь напишу длинный текст для проверки отображения и работы грида.\r\nЗачефывлаофзэщваофызщвафоыз\r\nodfkas\r\ndop[fsf'sdfjp';dfkldlfkwplefqpwefqwoefk][qwpef[w]qf[]wpef[]wqpfe[]qfkw[]efp	1	1	8	medium	\N	\N	\N	\N	f	\N	\N	\N	2026-02-17 22:08:28.494864+03	2026-02-17 22:11:51.893018+03
\.


--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.user_roles (id, user_id, role_id, assigned_by, assigned_at, revoked_at, is_active) FROM stdin;
1	1	1	\N	2026-02-12 09:34:07+03	\N	t
4	4	3	\N	2026-02-12 20:47:56.480176+03	\N	t
5	5	3	\N	2026-02-12 20:47:56.480176+03	\N	t
6	6	3	\N	2026-02-12 20:47:56.480176+03	\N	t
7	7	3	\N	2026-02-12 20:47:56.480176+03	\N	t
8	8	3	\N	2026-02-12 20:47:56.480176+03	\N	t
9	9	3	\N	2026-02-12 20:47:56.480176+03	\N	t
10	10	3	\N	2026-02-12 20:47:56.480176+03	\N	t
11	11	3	\N	2026-02-12 20:47:56.480176+03	\N	t
12	12	3	\N	2026-02-12 20:47:56.480176+03	\N	t
13	13	3	\N	2026-02-12 20:47:56.480176+03	\N	t
14	14	3	\N	2026-02-12 20:47:56.480176+03	\N	t
15	15	3	\N	2026-02-12 20:47:56.480176+03	\N	t
16	16	3	\N	2026-02-12 20:47:56.480176+03	\N	t
17	17	3	\N	2026-02-12 20:47:56.480176+03	\N	t
18	18	3	\N	2026-02-12 20:47:56.480176+03	\N	t
19	19	3	\N	2026-02-12 20:47:56.480176+03	\N	t
20	20	2	\N	2026-02-13 20:31:32+03	\N	t
21	21	3	\N	2026-02-17 23:54:02.090047+03	\N	t
22	22	3	\N	2026-02-17 23:54:02.090047+03	\N	t
23	23	3	\N	2026-02-17 23:54:02.090047+03	\N	t
24	24	3	\N	2026-02-17 23:54:02.090047+03	\N	t
25	25	3	\N	2026-02-17 23:54:02.090047+03	\N	t
26	26	3	\N	2026-02-17 23:54:02.090047+03	\N	t
27	27	3	\N	2026-02-17 23:54:02.090047+03	\N	t
28	28	3	\N	2026-02-17 23:54:02.090047+03	\N	t
29	29	3	\N	2026-02-17 23:54:02.090047+03	\N	t
30	30	3	\N	2026-02-17 23:54:02.090047+03	\N	t
31	31	3	\N	2026-02-17 23:54:02.090047+03	\N	t
32	32	3	\N	2026-02-17 23:54:02.090047+03	\N	t
33	33	3	\N	2026-02-17 23:54:02.090047+03	\N	t
34	34	3	\N	2026-02-17 23:54:02.090047+03	\N	t
35	35	3	\N	2026-02-17 23:54:02.090047+03	\N	t
36	36	3	\N	2026-02-17 23:54:02.090047+03	\N	t
37	37	3	\N	2026-02-17 23:54:02.090047+03	\N	t
38	38	3	\N	2026-02-17 23:54:02.090047+03	\N	t
39	39	3	\N	2026-02-17 23:54:02.090047+03	\N	t
40	40	3	\N	2026-02-17 23:54:02.090047+03	\N	t
41	41	3	\N	2026-02-17 23:54:02.090047+03	\N	t
42	42	3	\N	2026-02-17 23:54:02.090047+03	\N	t
43	43	3	\N	2026-02-17 23:54:02.090047+03	\N	t
44	44	3	\N	2026-02-17 23:54:02.090047+03	\N	t
45	45	3	\N	2026-02-17 23:54:02.090047+03	\N	t
46	46	3	\N	2026-02-17 23:54:02.090047+03	\N	t
47	47	3	\N	2026-02-17 23:54:02.090047+03	\N	t
48	48	3	\N	2026-02-17 23:54:02.090047+03	\N	t
49	49	3	\N	2026-02-17 23:54:02.090047+03	\N	t
50	50	3	\N	2026-02-17 23:54:02.090047+03	\N	t
51	51	3	\N	2026-02-17 23:54:02.090047+03	\N	t
52	52	3	\N	2026-02-17 23:54:02.090047+03	\N	t
53	53	3	\N	2026-02-17 23:54:02.090047+03	\N	t
54	54	3	\N	2026-02-17 23:54:02.090047+03	\N	t
55	55	3	\N	2026-02-17 23:54:02.090047+03	\N	t
56	56	3	\N	2026-02-17 23:54:02.090047+03	\N	t
57	57	3	\N	2026-02-17 23:54:02.090047+03	\N	t
58	58	3	\N	2026-02-17 23:54:02.090047+03	\N	t
59	59	3	\N	2026-02-17 23:54:02.090047+03	\N	t
60	60	3	\N	2026-02-17 23:54:02.090047+03	\N	t
61	61	3	\N	2026-02-17 23:54:02.090047+03	\N	t
62	62	3	\N	2026-02-17 23:54:02.090047+03	\N	t
63	63	3	\N	2026-02-17 23:54:02.090047+03	\N	t
64	64	3	\N	2026-02-17 23:54:02.090047+03	\N	t
65	65	3	\N	2026-02-17 23:54:02.090047+03	\N	t
66	66	3	\N	2026-02-17 23:54:02.090047+03	\N	t
67	67	3	\N	2026-02-17 23:54:02.090047+03	\N	t
68	68	3	\N	2026-02-17 23:54:02.090047+03	\N	t
69	69	3	\N	2026-02-17 23:54:02.090047+03	\N	t
70	70	3	\N	2026-02-17 23:54:02.090047+03	\N	t
71	71	3	\N	2026-02-17 23:54:02.090047+03	\N	t
72	72	3	\N	2026-02-17 23:54:02.090047+03	\N	t
73	73	3	\N	2026-02-17 23:54:02.090047+03	\N	t
74	74	3	\N	2026-02-17 23:54:02.090047+03	\N	t
75	75	3	\N	2026-02-17 23:54:02.090047+03	\N	t
76	76	3	\N	2026-02-17 23:54:02.090047+03	\N	t
77	77	3	\N	2026-02-17 23:54:02.090047+03	\N	t
78	78	3	\N	2026-02-17 23:54:02.090047+03	\N	t
79	79	3	\N	2026-02-17 23:54:02.090047+03	\N	t
80	80	3	\N	2026-02-17 23:54:02.090047+03	\N	t
81	81	3	\N	2026-02-17 23:54:02.090047+03	\N	t
82	82	3	\N	2026-02-17 23:54:02.090047+03	\N	t
83	83	3	\N	2026-02-17 23:54:02.090047+03	\N	t
84	84	3	\N	2026-02-17 23:54:02.090047+03	\N	t
85	85	3	\N	2026-02-17 23:54:02.090047+03	\N	t
86	86	3	\N	2026-02-17 23:54:02.090047+03	\N	t
87	87	3	\N	2026-02-17 23:54:02.090047+03	\N	t
88	88	3	\N	2026-02-17 23:54:02.090047+03	\N	t
89	89	3	\N	2026-02-17 23:54:02.090047+03	\N	t
90	90	3	\N	2026-02-17 23:54:02.090047+03	\N	t
91	91	3	\N	2026-02-17 23:54:02.090047+03	\N	t
92	92	3	\N	2026-02-17 23:54:02.090047+03	\N	t
93	93	3	\N	2026-02-17 23:54:02.090047+03	\N	t
94	94	3	\N	2026-02-17 23:54:02.090047+03	\N	t
95	95	3	\N	2026-02-17 23:54:02.090047+03	\N	t
96	96	3	\N	2026-02-17 23:54:02.090047+03	\N	t
97	97	3	\N	2026-02-17 23:54:02.090047+03	\N	t
98	98	3	\N	2026-02-17 23:54:02.090047+03	\N	t
99	99	3	\N	2026-02-17 23:54:02.090047+03	\N	t
100	100	3	\N	2026-02-17 23:54:02.090047+03	\N	t
101	101	3	\N	2026-02-17 23:54:02.090047+03	\N	t
102	102	3	\N	2026-02-17 23:54:02.090047+03	\N	t
103	103	3	\N	2026-02-17 23:54:02.090047+03	\N	t
104	104	3	\N	2026-02-17 23:54:02.090047+03	\N	t
105	105	3	\N	2026-02-17 23:54:02.090047+03	\N	t
106	106	3	\N	2026-02-17 23:54:02.090047+03	\N	t
107	107	3	\N	2026-02-17 23:54:02.090047+03	\N	t
108	108	3	\N	2026-02-17 23:54:02.090047+03	\N	t
109	109	3	\N	2026-02-17 23:54:02.090047+03	\N	t
110	110	3	\N	2026-02-17 23:54:02.090047+03	\N	t
111	111	3	\N	2026-02-17 23:54:02.090047+03	\N	t
112	112	3	\N	2026-02-17 23:54:02.090047+03	\N	t
113	113	3	\N	2026-02-17 23:54:02.090047+03	\N	t
114	114	3	\N	2026-02-17 23:54:02.090047+03	\N	t
115	115	3	\N	2026-02-17 23:54:02.090047+03	\N	t
116	116	3	\N	2026-02-17 23:54:02.090047+03	\N	t
117	117	3	\N	2026-02-17 23:54:02.090047+03	\N	t
118	118	3	\N	2026-02-17 23:54:02.090047+03	\N	t
119	119	3	\N	2026-02-17 23:54:02.090047+03	\N	t
120	120	3	\N	2026-02-17 23:54:02.090047+03	\N	t
121	121	3	\N	2026-02-17 23:54:02.090047+03	\N	t
122	122	3	\N	2026-02-17 23:54:02.090047+03	\N	t
123	123	3	\N	2026-02-17 23:54:02.090047+03	\N	t
124	124	3	\N	2026-02-17 23:54:02.090047+03	\N	t
125	125	3	\N	2026-02-17 23:54:02.090047+03	\N	t
126	126	3	\N	2026-02-17 23:54:02.090047+03	\N	t
127	127	3	\N	2026-02-17 23:54:02.090047+03	\N	t
128	128	3	\N	2026-02-17 23:54:02.090047+03	\N	t
129	129	3	\N	2026-02-17 23:54:02.090047+03	\N	t
130	130	3	\N	2026-02-17 23:54:02.090047+03	\N	t
131	131	3	\N	2026-02-17 23:54:02.090047+03	\N	t
132	132	3	\N	2026-02-17 23:54:02.090047+03	\N	t
133	133	3	\N	2026-02-17 23:54:02.090047+03	\N	t
134	134	3	\N	2026-02-17 23:54:02.090047+03	\N	t
135	135	3	\N	2026-02-17 23:54:02.090047+03	\N	t
136	136	3	\N	2026-02-17 23:54:02.090047+03	\N	t
137	137	3	\N	2026-02-17 23:54:02.090047+03	\N	t
138	138	3	\N	2026-02-17 23:54:02.090047+03	\N	t
139	139	3	\N	2026-02-17 23:54:02.090047+03	\N	t
140	140	3	\N	2026-02-17 23:54:02.090047+03	\N	t
141	141	3	\N	2026-02-17 23:54:02.090047+03	\N	t
142	142	3	\N	2026-02-17 23:54:02.090047+03	\N	t
143	143	3	\N	2026-02-17 23:54:02.090047+03	\N	t
144	144	3	\N	2026-02-17 23:54:02.090047+03	\N	t
145	145	3	\N	2026-02-17 23:54:02.090047+03	\N	t
146	146	3	\N	2026-02-17 23:54:02.090047+03	\N	t
147	147	3	\N	2026-02-17 23:54:02.090047+03	\N	t
148	148	3	\N	2026-02-17 23:54:02.090047+03	\N	t
149	149	3	\N	2026-02-17 23:54:02.090047+03	\N	t
150	150	3	\N	2026-02-17 23:54:02.090047+03	\N	t
151	151	3	\N	2026-02-17 23:54:02.090047+03	\N	t
152	152	3	\N	2026-02-17 23:54:02.090047+03	\N	t
153	153	3	\N	2026-02-17 23:54:02.090047+03	\N	t
154	154	3	\N	2026-02-17 23:54:02.090047+03	\N	t
155	155	3	\N	2026-02-17 23:54:02.090047+03	\N	t
156	156	3	\N	2026-02-17 23:54:02.090047+03	\N	t
157	157	3	\N	2026-02-17 23:54:02.090047+03	\N	t
158	158	3	\N	2026-02-17 23:54:02.090047+03	\N	t
159	159	3	\N	2026-02-17 23:54:02.090047+03	\N	t
160	160	3	\N	2026-02-17 23:54:02.090047+03	\N	t
161	161	3	\N	2026-02-17 23:54:02.090047+03	\N	t
162	162	3	\N	2026-02-17 23:54:02.090047+03	\N	t
163	163	3	\N	2026-02-17 23:54:02.090047+03	\N	t
164	164	3	\N	2026-02-17 23:54:02.090047+03	\N	t
165	165	3	\N	2026-02-17 23:54:02.090047+03	\N	t
166	166	3	\N	2026-02-17 23:54:02.090047+03	\N	t
167	167	3	\N	2026-02-17 23:54:02.090047+03	\N	t
168	168	3	\N	2026-02-17 23:54:02.090047+03	\N	t
169	169	3	\N	2026-02-17 23:54:02.090047+03	\N	t
170	170	3	\N	2026-02-17 23:54:02.090047+03	\N	t
171	171	3	\N	2026-02-17 23:54:02.090047+03	\N	t
172	172	3	\N	2026-02-17 23:54:02.090047+03	\N	t
173	173	3	\N	2026-02-17 23:54:02.090047+03	\N	t
174	174	3	\N	2026-02-17 23:54:02.090047+03	\N	t
175	175	3	\N	2026-02-17 23:54:02.090047+03	\N	t
176	176	3	\N	2026-02-17 23:54:02.090047+03	\N	t
177	177	3	\N	2026-02-17 23:54:02.090047+03	\N	t
178	178	3	\N	2026-02-17 23:54:02.090047+03	\N	t
179	179	3	\N	2026-02-17 23:54:02.090047+03	\N	t
180	180	3	\N	2026-02-17 23:54:02.090047+03	\N	t
181	181	3	\N	2026-02-17 23:54:02.090047+03	\N	t
182	182	3	\N	2026-02-17 23:54:02.090047+03	\N	t
183	183	3	\N	2026-02-17 23:54:02.090047+03	\N	t
184	184	3	\N	2026-02-17 23:54:02.090047+03	\N	t
185	185	3	\N	2026-02-17 23:54:02.090047+03	\N	t
186	186	3	\N	2026-02-17 23:54:02.090047+03	\N	t
187	187	3	\N	2026-02-17 23:54:02.090047+03	\N	t
188	188	3	\N	2026-02-17 23:54:02.090047+03	\N	t
189	189	3	\N	2026-02-17 23:54:02.090047+03	\N	t
190	190	3	\N	2026-02-17 23:54:02.090047+03	\N	t
191	191	3	\N	2026-02-17 23:54:02.090047+03	\N	t
192	192	3	\N	2026-02-17 23:54:02.090047+03	\N	t
193	193	3	\N	2026-02-17 23:54:02.090047+03	\N	t
194	194	3	\N	2026-02-17 23:54:02.090047+03	\N	t
195	195	3	\N	2026-02-17 23:54:02.090047+03	\N	t
196	196	3	\N	2026-02-17 23:54:02.090047+03	\N	t
197	197	3	\N	2026-02-17 23:54:02.090047+03	\N	t
198	198	3	\N	2026-02-17 23:54:02.090047+03	\N	t
199	199	3	\N	2026-02-17 23:54:02.090047+03	\N	t
200	200	3	\N	2026-02-17 23:54:02.090047+03	\N	t
201	201	3	\N	2026-02-17 23:54:02.090047+03	\N	t
202	202	3	\N	2026-02-17 23:54:02.090047+03	\N	t
203	203	3	\N	2026-02-17 23:54:02.090047+03	\N	t
204	204	3	\N	2026-02-17 23:54:02.090047+03	\N	t
205	205	3	\N	2026-02-17 23:54:02.090047+03	\N	t
206	206	3	\N	2026-02-17 23:54:02.090047+03	\N	t
207	207	3	\N	2026-02-17 23:54:02.090047+03	\N	t
208	208	3	\N	2026-02-17 23:54:02.090047+03	\N	t
209	209	3	\N	2026-02-17 23:54:02.090047+03	\N	t
210	210	3	\N	2026-02-17 23:54:02.090047+03	\N	t
211	211	3	\N	2026-02-17 23:54:02.090047+03	\N	t
212	212	3	\N	2026-02-17 23:54:02.090047+03	\N	t
213	213	3	\N	2026-02-17 23:54:02.090047+03	\N	t
214	214	3	\N	2026-02-17 23:54:02.090047+03	\N	t
215	215	3	\N	2026-02-17 23:54:02.090047+03	\N	t
216	216	3	\N	2026-02-17 23:54:02.090047+03	\N	t
217	217	3	\N	2026-02-17 23:54:02.090047+03	\N	t
218	218	3	\N	2026-02-17 23:54:02.090047+03	\N	t
219	219	3	\N	2026-02-17 23:54:02.090047+03	\N	t
220	220	3	\N	2026-02-17 23:54:02.090047+03	\N	t
221	221	3	\N	2026-02-17 23:54:02.090047+03	\N	t
222	222	3	\N	2026-02-17 23:54:02.090047+03	\N	t
223	223	3	\N	2026-02-17 23:54:02.090047+03	\N	t
224	224	3	\N	2026-02-17 23:54:02.090047+03	\N	t
225	225	3	\N	2026-02-17 23:54:02.090047+03	\N	t
226	226	3	\N	2026-02-17 23:54:02.090047+03	\N	t
227	227	3	\N	2026-02-17 23:54:02.090047+03	\N	t
228	228	3	\N	2026-02-17 23:54:02.090047+03	\N	t
229	229	3	\N	2026-02-17 23:54:02.090047+03	\N	t
230	230	3	\N	2026-02-17 23:54:02.090047+03	\N	t
231	231	3	\N	2026-02-17 23:54:02.090047+03	\N	t
232	232	3	\N	2026-02-17 23:54:02.090047+03	\N	t
233	233	3	\N	2026-02-17 23:54:02.090047+03	\N	t
234	234	3	\N	2026-02-17 23:54:02.090047+03	\N	t
235	235	3	\N	2026-02-17 23:54:02.090047+03	\N	t
236	236	3	\N	2026-02-17 23:54:02.090047+03	\N	t
237	237	3	\N	2026-02-17 23:54:02.090047+03	\N	t
238	238	3	\N	2026-02-17 23:54:02.090047+03	\N	t
239	239	3	\N	2026-02-17 23:54:02.090047+03	\N	t
240	240	3	\N	2026-02-17 23:54:02.090047+03	\N	t
241	241	3	\N	2026-02-17 23:54:02.090047+03	\N	t
242	242	3	\N	2026-02-17 23:54:02.090047+03	\N	t
243	243	3	\N	2026-02-17 23:54:02.090047+03	\N	t
244	244	3	\N	2026-02-17 23:54:02.090047+03	\N	t
245	245	3	\N	2026-02-17 23:54:02.090047+03	\N	t
246	246	3	\N	2026-02-17 23:54:02.090047+03	\N	t
247	247	3	\N	2026-02-17 23:54:02.090047+03	\N	t
248	248	3	\N	2026-02-17 23:54:02.090047+03	\N	t
249	249	3	\N	2026-02-17 23:54:02.090047+03	\N	t
250	250	3	\N	2026-02-17 23:54:02.090047+03	\N	t
251	251	3	\N	2026-02-17 23:54:02.090047+03	\N	t
252	252	3	\N	2026-02-17 23:54:02.090047+03	\N	t
253	253	3	\N	2026-02-17 23:54:02.090047+03	\N	t
254	254	3	\N	2026-02-17 23:54:02.090047+03	\N	t
255	255	3	\N	2026-02-17 23:54:02.090047+03	\N	t
256	256	3	\N	2026-02-17 23:54:02.090047+03	\N	t
257	257	3	\N	2026-02-17 23:54:02.090047+03	\N	t
258	258	3	\N	2026-02-17 23:54:02.090047+03	\N	t
259	259	3	\N	2026-02-17 23:54:02.090047+03	\N	t
260	260	3	\N	2026-02-17 23:54:02.090047+03	\N	t
261	261	3	\N	2026-02-17 23:54:02.090047+03	\N	t
262	262	3	\N	2026-02-17 23:54:02.090047+03	\N	t
263	263	3	\N	2026-02-17 23:54:02.090047+03	\N	t
264	264	3	\N	2026-02-17 23:54:02.090047+03	\N	t
265	265	3	\N	2026-02-17 23:54:02.090047+03	\N	t
266	266	3	\N	2026-02-17 23:54:02.090047+03	\N	t
267	267	3	\N	2026-02-17 23:54:02.090047+03	\N	t
268	268	3	\N	2026-02-17 23:54:02.090047+03	\N	t
269	269	3	\N	2026-02-17 23:54:02.090047+03	\N	t
270	270	3	\N	2026-02-17 23:54:02.090047+03	\N	t
271	271	3	\N	2026-02-17 23:54:02.090047+03	\N	t
272	272	3	\N	2026-02-17 23:54:02.090047+03	\N	t
273	273	3	\N	2026-02-17 23:54:02.090047+03	\N	t
274	274	3	\N	2026-02-17 23:54:02.090047+03	\N	t
275	275	3	\N	2026-02-17 23:54:02.090047+03	\N	t
276	276	3	\N	2026-02-17 23:54:02.090047+03	\N	t
277	277	3	\N	2026-02-17 23:54:02.090047+03	\N	t
278	278	3	\N	2026-02-17 23:54:02.090047+03	\N	t
279	279	3	\N	2026-02-17 23:54:02.090047+03	\N	t
280	280	3	\N	2026-02-17 23:54:02.090047+03	\N	t
281	281	3	\N	2026-02-17 23:54:02.090047+03	\N	t
282	282	3	\N	2026-02-17 23:54:02.090047+03	\N	t
283	283	3	\N	2026-02-17 23:54:02.090047+03	\N	t
284	284	3	\N	2026-02-17 23:54:02.090047+03	\N	t
285	285	3	\N	2026-02-17 23:54:02.090047+03	\N	t
286	286	3	\N	2026-02-17 23:54:02.090047+03	\N	t
287	287	3	\N	2026-02-17 23:54:02.090047+03	\N	t
288	288	3	\N	2026-02-17 23:54:02.090047+03	\N	t
289	289	3	\N	2026-02-17 23:54:02.090047+03	\N	t
290	290	3	\N	2026-02-17 23:54:02.090047+03	\N	t
291	291	3	\N	2026-02-17 23:54:02.090047+03	\N	t
292	292	3	\N	2026-02-17 23:54:02.090047+03	\N	t
293	293	3	\N	2026-02-17 23:54:02.090047+03	\N	t
294	294	3	\N	2026-02-17 23:54:02.090047+03	\N	t
295	295	3	\N	2026-02-17 23:54:02.090047+03	\N	t
296	296	3	\N	2026-02-17 23:54:02.090047+03	\N	t
297	297	3	\N	2026-02-17 23:54:02.090047+03	\N	t
298	298	3	\N	2026-02-17 23:54:02.090047+03	\N	t
299	299	3	\N	2026-02-17 23:54:02.090047+03	\N	t
300	300	3	\N	2026-02-17 23:54:02.090047+03	\N	t
301	301	3	\N	2026-02-17 23:54:02.090047+03	\N	t
302	302	3	\N	2026-02-17 23:54:02.090047+03	\N	t
303	303	3	\N	2026-02-17 23:54:02.090047+03	\N	t
304	304	3	\N	2026-02-17 23:54:02.090047+03	\N	t
305	305	3	\N	2026-02-17 23:54:02.090047+03	\N	t
306	306	3	\N	2026-02-17 23:54:02.090047+03	\N	t
307	307	3	\N	2026-02-17 23:54:02.090047+03	\N	t
308	308	3	\N	2026-02-17 23:54:02.090047+03	\N	t
309	309	3	\N	2026-02-17 23:54:02.090047+03	\N	t
310	310	3	\N	2026-02-17 23:54:02.090047+03	\N	t
311	311	3	\N	2026-02-17 23:54:02.090047+03	\N	t
312	312	3	\N	2026-02-17 23:54:02.090047+03	\N	t
313	313	3	\N	2026-02-17 23:54:02.090047+03	\N	t
314	314	3	\N	2026-02-17 23:54:02.090047+03	\N	t
315	315	3	\N	2026-02-17 23:54:02.090047+03	\N	t
316	316	3	\N	2026-02-17 23:54:02.090047+03	\N	t
317	317	3	\N	2026-02-17 23:54:02.090047+03	\N	t
318	318	3	\N	2026-02-17 23:54:02.090047+03	\N	t
319	319	3	\N	2026-02-17 23:54:02.090047+03	\N	t
320	320	3	\N	2026-02-17 23:54:02.090047+03	\N	t
321	321	3	\N	2026-02-17 23:54:02.090047+03	\N	t
322	322	3	\N	2026-02-17 23:54:02.090047+03	\N	t
323	323	3	\N	2026-02-17 23:54:02.090047+03	\N	t
324	324	3	\N	2026-02-17 23:54:02.090047+03	\N	t
325	325	3	\N	2026-02-17 23:54:02.090047+03	\N	t
326	326	3	\N	2026-02-17 23:54:02.090047+03	\N	t
327	327	3	\N	2026-02-17 23:54:02.090047+03	\N	t
328	328	3	\N	2026-02-17 23:54:02.090047+03	\N	t
329	329	3	\N	2026-02-17 23:54:02.090047+03	\N	t
330	330	3	\N	2026-02-17 23:54:02.090047+03	\N	t
331	331	3	\N	2026-02-17 23:54:02.090047+03	\N	t
332	332	3	\N	2026-02-17 23:54:02.090047+03	\N	t
333	333	3	\N	2026-02-17 23:54:02.090047+03	\N	t
334	334	3	\N	2026-02-17 23:54:02.090047+03	\N	t
335	335	3	\N	2026-02-17 23:54:02.090047+03	\N	t
336	336	3	\N	2026-02-17 23:54:02.090047+03	\N	t
337	337	3	\N	2026-02-17 23:54:02.090047+03	\N	t
338	338	3	\N	2026-02-17 23:54:02.090047+03	\N	t
339	339	3	\N	2026-02-17 23:54:02.090047+03	\N	t
340	340	3	\N	2026-02-17 23:54:02.090047+03	\N	t
341	341	3	\N	2026-02-17 23:54:02.090047+03	\N	t
342	342	3	\N	2026-02-17 23:54:02.090047+03	\N	t
343	343	3	\N	2026-02-17 23:54:02.090047+03	\N	t
344	344	3	\N	2026-02-17 23:54:02.090047+03	\N	t
345	345	3	\N	2026-02-17 23:54:02.090047+03	\N	t
346	346	3	\N	2026-02-17 23:54:02.090047+03	\N	t
347	347	3	\N	2026-02-17 23:54:02.090047+03	\N	t
348	348	3	\N	2026-02-17 23:54:02.090047+03	\N	t
349	349	3	\N	2026-02-17 23:54:02.090047+03	\N	t
350	350	3	\N	2026-02-17 23:54:02.090047+03	\N	t
351	351	3	\N	2026-02-17 23:54:02.090047+03	\N	t
352	352	3	\N	2026-02-17 23:54:02.090047+03	\N	t
353	353	3	\N	2026-02-17 23:54:02.090047+03	\N	t
354	354	3	\N	2026-02-17 23:54:02.090047+03	\N	t
355	355	3	\N	2026-02-17 23:54:02.090047+03	\N	t
356	356	3	\N	2026-02-17 23:54:02.090047+03	\N	t
357	357	3	\N	2026-02-17 23:54:02.090047+03	\N	t
358	358	3	\N	2026-02-17 23:54:02.090047+03	\N	t
359	359	3	\N	2026-02-17 23:54:02.090047+03	\N	t
360	360	3	\N	2026-02-17 23:54:02.090047+03	\N	t
361	361	3	\N	2026-02-17 23:54:02.090047+03	\N	t
362	362	3	\N	2026-02-17 23:54:02.090047+03	\N	t
363	363	3	\N	2026-02-17 23:54:02.090047+03	\N	t
364	364	3	\N	2026-02-17 23:54:02.090047+03	\N	t
365	365	3	\N	2026-02-17 23:54:02.090047+03	\N	t
366	366	3	\N	2026-02-17 23:54:02.090047+03	\N	t
367	367	3	\N	2026-02-17 23:54:02.090047+03	\N	t
368	368	3	\N	2026-02-17 23:54:02.090047+03	\N	t
369	369	3	\N	2026-02-17 23:54:02.090047+03	\N	t
370	370	3	\N	2026-02-17 23:54:02.090047+03	\N	t
371	371	3	\N	2026-02-17 23:54:02.090047+03	\N	t
372	372	3	\N	2026-02-17 23:54:02.090047+03	\N	t
373	373	3	\N	2026-02-17 23:54:02.090047+03	\N	t
374	374	3	\N	2026-02-17 23:54:02.090047+03	\N	t
375	375	3	\N	2026-02-17 23:54:02.090047+03	\N	t
376	376	3	\N	2026-02-17 23:54:02.090047+03	\N	t
377	377	3	\N	2026-02-17 23:54:02.090047+03	\N	t
378	378	3	\N	2026-02-17 23:54:02.090047+03	\N	t
379	379	3	\N	2026-02-17 23:54:02.090047+03	\N	t
380	380	3	\N	2026-02-17 23:54:02.090047+03	\N	t
381	381	3	\N	2026-02-17 23:54:02.090047+03	\N	t
382	382	3	\N	2026-02-17 23:54:02.090047+03	\N	t
383	383	3	\N	2026-02-17 23:54:02.090047+03	\N	t
384	384	3	\N	2026-02-17 23:54:02.090047+03	\N	t
385	385	3	\N	2026-02-17 23:54:02.090047+03	\N	t
386	386	3	\N	2026-02-17 23:54:02.090047+03	\N	t
387	387	3	\N	2026-02-17 23:54:02.090047+03	\N	t
388	388	3	\N	2026-02-17 23:54:02.090047+03	\N	t
389	389	3	\N	2026-02-17 23:54:02.090047+03	\N	t
390	390	3	\N	2026-02-17 23:54:02.090047+03	\N	t
391	391	3	\N	2026-02-17 23:54:02.090047+03	\N	t
392	392	3	\N	2026-02-17 23:54:02.090047+03	\N	t
393	393	3	\N	2026-02-17 23:54:02.090047+03	\N	t
394	394	3	\N	2026-02-17 23:54:02.090047+03	\N	t
395	395	3	\N	2026-02-17 23:54:02.090047+03	\N	t
396	396	3	\N	2026-02-17 23:54:02.090047+03	\N	t
397	397	3	\N	2026-02-17 23:54:02.090047+03	\N	t
398	398	3	\N	2026-02-17 23:54:02.090047+03	\N	t
399	399	3	\N	2026-02-17 23:54:02.090047+03	\N	t
400	400	3	\N	2026-02-17 23:54:02.090047+03	\N	t
401	401	3	\N	2026-02-17 23:54:02.090047+03	\N	t
402	402	3	\N	2026-02-17 23:54:02.090047+03	\N	t
403	403	3	\N	2026-02-17 23:54:02.090047+03	\N	t
404	404	3	\N	2026-02-17 23:54:02.090047+03	\N	t
405	405	3	\N	2026-02-17 23:54:02.090047+03	\N	t
406	406	3	\N	2026-02-17 23:54:02.090047+03	\N	t
407	407	3	\N	2026-02-17 23:54:02.090047+03	\N	t
408	408	3	\N	2026-02-17 23:54:02.090047+03	\N	t
409	409	3	\N	2026-02-17 23:54:02.090047+03	\N	t
410	410	3	\N	2026-02-17 23:54:02.090047+03	\N	t
411	411	3	\N	2026-02-17 23:54:02.090047+03	\N	t
412	412	3	\N	2026-02-17 23:54:02.090047+03	\N	t
413	413	3	\N	2026-02-17 23:54:02.090047+03	\N	t
414	414	3	\N	2026-02-17 23:54:02.090047+03	\N	t
415	415	3	\N	2026-02-17 23:54:02.090047+03	\N	t
416	416	3	\N	2026-02-17 23:54:02.090047+03	\N	t
417	417	3	\N	2026-02-17 23:54:02.090047+03	\N	t
418	418	3	\N	2026-02-17 23:54:02.090047+03	\N	t
419	419	3	\N	2026-02-17 23:54:02.090047+03	\N	t
420	420	3	\N	2026-02-17 23:54:02.090047+03	\N	t
421	421	3	\N	2026-02-17 23:54:02.090047+03	\N	t
422	422	3	\N	2026-02-17 23:54:02.090047+03	\N	t
423	423	3	\N	2026-02-17 23:54:02.090047+03	\N	t
424	424	3	\N	2026-02-17 23:54:02.090047+03	\N	t
425	425	3	\N	2026-02-17 23:54:02.090047+03	\N	t
426	426	3	\N	2026-02-17 23:54:02.090047+03	\N	t
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.users (id, username, full_name, "position", department, email, phone, password_hash, is_active, is_locked, failed_login_attempts, lock_until, password_changed_at, last_login_at, created_by_id, updated_by_id, created_at, updated_at, is_deleted) FROM stdin;
1	admin	Администратор	\N	\N	admin@local	\N	$2y$13$y6s1IyitMYGUXmB8oaNdPeup3dEk0vR1njJYND5zr74GjY10Xv3la	t	f	0	\N	\N	\N	\N	\N	2026-02-12 11:34:07.204663+03	2026-02-12 11:34:07.204663+03	f
5	\N	Яшкина Елизавета  Вячеславовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03	f
6	\N	Аптекарева Виктория Михайловна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03	f
7	\N	Иваненко Константин Викторович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03	f
8	\N	Тютчев Сергей Николаевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03	f
9	\N	Котов Михаил Ювинальевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03	f
10	\N	Патраков Василий Николаевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03	f
11	\N	Печерский Виталий Васильевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03	f
12	\N	Шелепетко Юлия Олеговна (бывш. Чернявский Г. И.)	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03	f
13	\N	Белохвост Василий Иванович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03	f
14	\N	Першина Марина Анатольевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03	f
15	\N	Слобцов Алексей Юрьевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03	f
16	\N	Бычкова Дарья Алексеевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03	f
17	\N	Шишкин Михаил Дмитриевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03	f
18	\N	Никонцев Артур Владимирович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03	f
19	\N	Наместников Геннадий Федорович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03	f
4	\N	Абрамова Дарья Алексанровна	\N	\N	a@local.ru	\N	$2y$13$wMRNeCVqmLbSRR6y1gfkRuguIN9n7U3eqfVKjEtqwqwbAwl3YdeKe	t	f	0	\N	\N	\N	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-13 20:41:12.081045+03	f
20	\N	Мусагалиев Азамат Тахирович	\N	\N	amusa@local.ru	\N	$2y$13$L9GjmLWhvLITliuGtVZrS.ufbEEq.4ixTxqgsYL9KiZVbnltCLAlO	t	f	0	\N	\N	\N	\N	\N	2026-02-13 23:31:32.648265+03	2026-02-13 23:31:32.648265+03	f
21	\N	Рыбаков Руслан Анатольевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
22	\N	Сергеев Андрей Анатольевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
23	\N	Новгородова Елена Викторовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
24	\N	Елистратова Мария Сергеевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
25	\N	Катлинская Маргарита Александровна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
26	\N	Якушина Ирина Станиславовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
27	\N	Муранцев Андрей Михайлович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
28	\N	Лыч Ирина Владимировна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
29	\N	Данилкин Федор Алексеевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
30	\N	Данилкин Федор Алексеевич (бывш.Попов Владимир Валерьевич)	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
31	\N	Козляков Евгений Алексеевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
32	\N	Сеничкин Петр Николаевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
33	\N	Митрофанова Лариса Геннадьевна (бывш. Андрианов А. В.)	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
34	\N	Митрофанова Лариса Геннадьевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
35	\N	Илюхина Вера Александровна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
36	\N	Бондарев Дмитрий Владимирович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
37	\N	Бухтеева Карина Игоревна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
38	\N	Фомин Артем Владимирович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
39	\N	Акжигитова Анжела Расимовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
40	\N	Варламова Вероника Алексеевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
41	\N	Леонтьев Георгий Юрьевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
42	\N	Блануца Ольга Александровна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
43	\N	Невиданчук Игорь Сергеевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
44	\N	Подлесный Олег Леонидович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
45	\N	Ялымова Ангелина Александрова	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
46	\N	Руделев Александр Александрович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
47	\N	Скребков Александр Сергеевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
48	\N	Яманова Елена Александровна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
49	\N	Глуховская Елена Николаевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
50	\N	Руденко Дария Важевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
51	\N	Добрякова Карина Вадимовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
52	\N	Молостовская Ольга Борисовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
53	\N	Логачева Алла Викторовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
54	\N	Кутилина Кристина Евгеньевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
55	\N	Санкин Александр Станиславович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
56	\N	Кулакова Анастасия Васильевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
57	\N	Кучерук Светлана Александровна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
58	\N	Кушнир Григорий Абрамович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
59	\N	Шемякин Владимир Львович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
60	\N	Никитина Алина Валерьевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
61	\N	Писаренко Ольга Владимировна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
62	\N	Климова Полина Андреевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
63	\N	Незлученко Анна Витальевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
64	\N	Козлова Ангелина Вячеславовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
65	\N	Воронина Кристина Сергеевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
66	\N	Класс автоматизированного проектирования ФКЦ ОПК	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
67	\N	Кулаков Дмитрий Дмитриевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
68	\N	Крылов Роман Андреевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
69	\N	Калугин Илья Игоревич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
70	\N	Ревва Рубен Рубенович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
71	\N	Кузина Ольга Александровна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
72	\N	Птушкина Наталья Геннадьевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
73	\N	Коптев Алексей Игоревич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
74	\N	Иванова Галина Петровна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
75	\N	Васильева Татьяна Николаевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
76	\N	Попович Игорь Владимирович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
77	\N	Тимофеева Татьяна Николаевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
78	\N	Лыкова Наталья Александровна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
79	\N	Рыбак Ольга Петровна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
80	\N	Александров Вячеслав Викторович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
81	\N	Катаева Лидия Анатольевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
82	\N	Барулина Галина Михайловна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
83	\N	Удальцова Ольга Анатольевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
84	\N	Козлова Елена Евгеньевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
85	\N	Цабут Ольга Владимировна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
86	\N	Жолудова Ирина Владимировна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
87	\N	Ковалев Валерий Иванович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
88	\N	Соловьева Эльвира Анатольевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
89	\N	Высокова Наталья Дмитриевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
90	\N	Дворядкина Ольга Ивановна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
91	\N	Графский Дмитрий Анатольевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
92	\N	Аблец Севетлана Николаевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
93	\N	Боровиков Владислав Владимирович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
94	\N	Замятина Ольга Николаевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
95	\N	Курьянова Анастасия Сергеевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
96	\N	Лебедева Елена Васильевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
97	\N	Корнилова Мария Николаевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
98	\N	Селиванов Владислав Геннадьевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
99	\N	Туганов Евгений Вячеславович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
100	\N	Бусыгин Владимир Павлович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
101	\N	Език Наталия Сергеевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
102	\N	Орос Наталья Ивановна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
103	\N	Зайцева Ирина Олеговна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
104	\N	Васильева Ольга Николаевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
105	\N	Овешникова Елена Владимировна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
106	\N	Панина Ирина Анатольевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
107	\N	Ягодкина Ольга Александровна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
108	\N	Дорохова Лидия Николаевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
109	\N	Гуриели Елена Отиевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
110	\N	Кайтукова Марина Владимировна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
111	\N	Семенова Светлана Николаевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
112	\N	Зорина Елизавета Александровна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
113	\N	Савосина Светлана Андреевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
114	\N	Поляшкевич Елена Евгеньевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
115	\N	Гасанов Рауф Мамедович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
116	\N	Шемякина Алла Евгеньевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
117	\N	Гадомская Татьяна Евгеньевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
118	\N	Иванов Владимир Николаевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
119	\N	Шишков Виталий Владимирович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
120	\N	Грешнева Алина Валерьевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
121	\N	Дородная Мария Петровна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
122	\N	Самсонова Екатерина Михайловна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
123	\N	Шестопалов Антон Сергеевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
124	\N	Алексеев  Кирилл Дмитриевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
125	\N	Протопопов Сергей Владимирович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
126	\N	Разорёнов Денис Владиславович (через Косарев Алексей Сергеевич)	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
127	\N	Климов Алексей Сергеевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
128	\N	Климов Алексей Сергеевич (бывш. Соболев Леонид Алексеевич)	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
129	\N	Азиев Казбек Русланович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
130	\N	Иванников Яков Александрович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
131	\N	Кудряшов Артём Сергеевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
132	\N	Паршуткина Александра Николаевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
133	\N	Акжигитова Альбина Наиловна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
134	\N	Горштейн Евгений Михайлович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
135	\N	Климов Федор Николаевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
136	\N	Есакия Виктория Николаевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
137	\N	Шустрова Юлия Викторовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
138	\N	Душечкин Максим Владимирович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
139	\N	Луценко Петр Петрович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
140	\N	Маклачкова Марина Александровна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
141	\N	Урусов Андрей Анатольевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
142	\N	Бобрышев Артур Дмитриевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
143	\N	Кулешов Алексей Евгеньевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
144	\N	Журенков Денис Александрович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
145	\N	Журенков Денис Александрович (Минпромторг)	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
146	\N	Семакова Варвара Сергеевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
147	\N	Басалаева Юлия Андреевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
148	\N	Милькина Ирина Геннадьевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
149	\N	Сбитнева Анастасия Юрьевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
150	\N	Криушинская Мария Вячеславовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
151	\N	Тенина Елена Николаевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
152	\N	Манжиева Алина Александровна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
153	\N	Казаков Руслан Александрович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
154	\N	Вилкова Наталья Викторовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
155	\N	Лобанова Виктория Евгеньевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
156	\N	Комарова Марина Геннадьевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
157	\N	Цырулева Алла Алексеевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
158	\N	Фурсова Мария Алексеевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
159	\N	Афанасьев Александр Юрьевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
160	\N	Ушакова Ирина Николаевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
161	\N	Зибаева Татьяна Владимировна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
162	\N	Довгучиц Сергей Иванович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
163	\N	Пустякова Нэля Григорьевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
164	\N	Слободчиков Максим Игоревич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
165	\N	Белокопытов Кирилл Владимирович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
166	\N	Сайфудинов Дмитрий Аминович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
167	\N	Гриневич Алексей Николаевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
168	\N	Еременко Андрей Анатольевич (стоит бесхозный - 05.06.2025, Ревва Р.Р., звонил по телефону)	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
169	\N	Рожанский Андрей Васильевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
170	\N	Бунев Евгений Геннадьевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
171	\N	Иванцова Лилия Анатольевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
172	\N	Солдатова Людмила Ивановна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
173	\N	Образцова Юлия Сергеевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
174	\N	Ковальчук Андрей Олегович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
175	\N	Мезников Сергей Алексадрович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
176	\N	Шарапова Ольга Владимировна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
177	\N	Рябова Анастасия Борисовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
178	\N	Матвеева Виктория Алексеевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
179	\N	Вяльцева Екатерина Сергеевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
180	\N	Елкин Василий Вячеславович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
181	\N	Маевская Марина Вячеславовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
182	\N	Гришин Михаил Олегович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
183	\N	Клевцевич Ольга Юрьевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
184	\N	Ганин Матвей Андреевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
185	\N	Карлов Сергей Николаевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
186	\N	Олейник Виктория Александровна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
187	\N	Пальмов Владимир Геннадиевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
188	\N	Буланов Дмитрий Юрьевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
189	\N	Марговенко Олег Борисович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
190	\N	Буланов Юрий Валенитович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
191	\N	Астахова Ярославна Александровна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
192	\N	Канкулов Муаед Хажмусович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
193	\N	Маркова Ирина Алексеевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
194	\N	Бошляков Сергей Александрович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
195	\N	Лавриненко Юрий Алексеевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
196	\N	Мекеко Владимир Викторович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
197	\N	Коптев Олег Николаевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
198	\N	Сидоров Александр Алексеевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
199	\N	Барков Фёдор Егорович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
200	\N	Митрошин Артем Анатольевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
201	\N	Виноградова Мария Викторовна (бывш. Лопухин Д.А.)	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
202	\N	Перепелкин Юрий Константинович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
203	\N	Холманских Елена Максимовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
204	\N	Иминов Умед Евгеньевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
205	\N	Мингалёва Вера Борисовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
206	\N	Реут Юлиан Евгеньевич (бывш. Епифанов Матвей Михайлович)	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
207	\N	Родригес Пендас Анна Аугустовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
208	\N	Александров Данила Дмитриевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
209	\N	Королев Евгений Александрович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
210	\N	Бастрыгин Андрей Сергеевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
211	\N	Лалушкина Анна Юрьевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
212	\N	Ризакулиева М.Н. (Долматова Мария Николаевна)	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
213	\N	Рядинский Егор Александрович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
214	\N	Автономный	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
215	\N	Краснопеев Игорь Валерьевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
216	\N	Успанова Лариса Даудовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
217	\N	Голубев Алексей Сергеевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
218	\N	Федяева Галина Вячеславовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
219	\N	Голубев Сергей Сергеевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
220	\N	Владимиров Иван Сергеевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
221	\N	Камин Валерий Петрович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
222	\N	Куликова Татьяна Васильевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
223	\N	Черенкова Юлия Андреевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
224	\N	Горохов Евгений Игоревич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
225	\N	Ларионова Юлия Сергеевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
226	\N	Ромашков Сергей Николаевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
227	\N	Тихон Валерий Николаевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
228	\N	Терюхов Ярослав Игоревич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
229	\N	Любкин Сергей Сергеевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
230	\N	Кукарекин Алексей Викторович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
231	\N	Мельников Евгений Александрович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
232	\N	Балабуха Андрей Николаевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
233	\N	Гуляева Анастасия Михайловна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
234	\N	Островская Наталия Геннадиевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
235	\N	Гриценко Екатерина Викторовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
236	\N	Дроздова Юлия Сергеевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
237	\N	Шилин Андрей Викторович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
238	\N	Диканёв Богдан Анатольевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
239	\N	Пошехонов Юрий Игоревич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
240	\N	Святченко Борис Иванович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
241	\N	Зайцев Андрей Иванович (уволился)	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
242	\N	Мусави Руслан Владимирович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
243	\N	Пушков Степан Сергеевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
244	\N	Бачинов Денис Геннадьевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
245	\N	Терпеньянц Роберт Владимирович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
246	\N	Зуборев Лев Алексеевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
247	\N	Прохорова Наталья Станиславовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
248	\N	Земцова Вера Александровна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
249	\N	Земцова Вера Александровна (бывш. Зотов Александр Владимирович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
250	\N	Михайлова Наталья Павловна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
251	\N	Еременко Андрей Анатольевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
252	\N	Беркутова Татьяна Алексеевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
253	\N	Масленникова Оксана Викторовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
254	\N	Булгаков Алексей Юрьевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
255	\N	Булгаков Алексей Юрьевич (бывш. Авдеев М. М.)	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
256	\N	Авдеев Михаил Максимович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
257	\N	Абакумова Анастасия Александровна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
258	\N	Ключарева Александра Дмитриевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
259	\N	Гальцова Ирина Валентиновна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
260	\N	Корбанюк Ольга Игоревна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
261	\N	Монаков Владимир Алексеевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
262	\N	Мальцев Кирилл Михайлович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
263	\N	Миронов Дмитрий Анатольевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
264	\N	Ильин Лев Константинович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
265	\N	Малахов Алексей Александрович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
266	\N	Муканов Олег Александрович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
267	\N	Воронова Анна Александровна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
268	\N	Ильин Лев Константинович (бывш. Тасенко А.А.)	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
269	\N	Востриков Никита Эльсеварович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
270	\N	Савченко Виталий Максимович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
271	\N	Савченко Виталий Максимович (Минпромторг )	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
272	\N	Бабенко Алексей Мухарбекович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
273	\N	Смолков Владимир	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
274	\N	Горячев Михаил Сергеевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
275	\N	Милосердов Андрей Викторович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
276	\N	Косарев Сергей Васильевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
277	\N	Иванова Елена Алексеевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
278	\N	Болдырева Елена Валерьевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
279	\N	Махова Анастасия Вячеславовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
280	\N	Андросова Мария Владимировна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
281	\N	Богун Дарья Константиновна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
282	\N	Козлова Анастасия Михайловна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
283	\N	Войвиченко Татьяна Геннадьевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
284	\N	Калякина Татьяна Михайловна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
285	\N	Черноморцева Ирина Ивановна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
286	\N	Белова Ольга Николаевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
287	\N	Шавлова Наталья Львовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
288	\N	Соколов Дмитрий Алексеевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
289	\N	Попова Екатерина Вячеславовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
290	\N	Афанасьева Юлия Леонидовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
291	\N	Новоселов Даниил Дмитриевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
292	\N	Иванова Александра Ильинична	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
293	\N	Рощупкин Максим Геннадьевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
294	\N	Грудзинский Павел Вячеславович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
295	\N	Двоенко Дмитрий Владимирович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
296	\N	Козлов Андрей Иванович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
297	\N	Слиньков Александр Евгеньевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
298	\N	Денисов Сергей Николаевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
299	\N	Павлюченко Константин Валентинович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
300	\N	Завьялов Игорь Сергеевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
301	\N	Курицын Александр Викторович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
302	\N	Афанасьев Александр Леонидович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
303	\N	Закандаева Христина Алексеевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
304	\N	Матросова Ольга Вячеславовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
305	\N	Мушков Александр Юрьевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
306	\N	Рымкевич Станислав Николаевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
307	\N	Полянский Дмитрий Владимирович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
308	\N	Котко Дмитрий Дмитриевич (бывш. Полозкова Ю. С.)	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
309	\N	Сотников Владислав Андреевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
310	\N	Борисов Юрий Анатольевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
311	\N	Сергеев Владимир Александрович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
312	\N	Васильева Елена Львовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
313	\N	Котко Дмитрий Дмитриевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
314	\N	Рязанцев Николай Александрович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
315	\N	Шаферов Александр Эдуардович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
316	\N	Кантур Наталья Михайловна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
317	\N	Кушниренко Михаил Андреевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
318	\N	Кушниренко Михаил Андреевич (бывш. Теребин А. А.)	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
319	\N	Новиков Борис Николаевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
320	\N	Новиков Борис Николаевич (бывш. Аксенова Д.К.)	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
321	\N	Котко Дмитрий Дмитриевич (бывш. Карулин В. П.)	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
322	\N	Большакова Инна Николаевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
323	\N	Котко Дмитрий Дмитриевич (бывш. Преслицкая Ю.Б.)	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
324	\N	Шелепетко Юлия Олеговна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
325	\N	Фархшатова Гульнара Рифовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
326	\N	Гусев Юрий Васильевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
327	\N	Дюндик Елена Петровна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
328	\N	Баклагина Наталья Юрьевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
329	\N	Иванова Вера Владимировна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
330	\N	Кулешов Алексей Евгеньевич (Помазов Сергей Валерьевич)	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
331	\N	Андреев Сергей Николаевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
332	\N	Силкин Сергей Александрович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
333	\N	Светов Олег Вячеславович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
334	\N	Погорелова Анастасия Алексеевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
335	\N	Бойко Александра Павловна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
336	\N	Покидько Ольга Владимировна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
337	\N	Василенко Артем Григорьевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
338	\N	Филатов Виктор Владимирович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
339	\N	Темерёва Наталья Николаевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
340	\N	Тищенко Екатерина Юрьевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
341	\N	Лепешкин Александр Николаевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
342	\N	Петелин Алексей Евгеньевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
343	\N	Полипов Александр Владимирович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
344	\N	Титов Александр Сергеевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
345	\N	Шкваркин Даниил Степанович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
346	\N	Евдокимова Наталья Владимировна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
347	\N	Панфилов Дмитрий Александрович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
348	\N	Рябчикова Татьяна Сергеевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
349	\N	Кан Яна Артуровна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
350	\N	Шульга Михаил Владимирович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
351	\N	Кашковская (Ряховская) Дарья Викторовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
352	\N	Агеев Андрей Борисович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
353	\N	Буровцев Даниил Михайлович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
354	\N	Таныгин Сергей Валерьевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
355	\N	Иванов Виталий Витальевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
356	\N	Савицкая Надежда Михайловна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
357	\N	Куранова Татьяна Ивановна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
358	\N	Волков Вячеслав Иванович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
359	\N	Докиш Нелли Михайловна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
360	\N	Кузиванов Александр Михайлович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
361	\N	Кузиванов Александр Михайлович (общий)	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
362	\N	Потылицын Владимир Дмитриевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
363	\N	Голубчиков Сергей Викторович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
364	\N	Куслин Сергей Сергеевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
365	\N	Митрофанова Наталия Викторовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
366	\N	Кузнецова Мария Викторовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
367	\N	Бесчастных Дмитрий Михайлович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
368	\N	Пойкин Артем Евгеньевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
369	\N	Щеглов Сергей Владимирович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
370	\N	Намазов Руфат Беглярович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
371	\N	Кожевникова Юлия Сергеевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
372	\N	Кожевникова Юлия Сергеевна (бывш. Дрягина Анастасия Дмитриевна)	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
373	\N	Чихачева Татьяна Николаевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
374	\N	Карпухин Владимир Иванович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
375	\N	Миргородов Сергей Борисович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
376	\N	Петров Юрий Александрович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
377	\N	Карачёва Евгения Геннадьевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
378	\N	Пырьев Владимир Александрович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
379	\N	Грибут Игорь Энгельсович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
380	\N	Гуляев Антон Владимирович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
381	\N	Сердюков Владимир Юрьевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
382	\N	Цымбалова Людмила Николаевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
383	\N	Зуев Александр Алексеевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
384	\N	Коновалова Людмила Леонтьевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
385	\N	Панарина Зоя Николаевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
386	\N	Паташова Юлия Васильевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
387	\N	Дугушкина Серафима Васильевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
388	\N	Гречанова Тамара Леонидовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
389	\N	Москалева Наталья Львовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
390	\N	Виноградов Владислав Владимирович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
391	\N	Кутищев Анатолий Владимирович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
392	\N	Иванова Оксана Анатольевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
393	\N	Горохов Александр Александрович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
394	\N	Кудрявцева Светлана Сергеевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
395	\N	Никитина Дарья Петровна (Донич Алена Валентиновна)	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
396	\N	Думнов Андрей Александрович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
397	\N	Хаустов Антон Юрьевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
398	\N	Силина Евгения Валентиновна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
399	\N	Семина Марина Евгеньевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
400	\N	Грибакина Ирина Юрьевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
401	\N	Ролдугина Татьяна Леонидовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
402	\N	Голева Раиса Ивановна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
403	\N	Шахова Юлия Сергеевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
404	\N	Гарбузова Елена Юрьевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
405	\N	Пашкова Марина Викторовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
406	\N	Сребная Людмила Александровна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
407	\N	Общий ПК (Пашкова Марина Викторовна)	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
408	\N	Салькова Наталья Васильевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
409	\N	Белобаева Елена Николаевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
410	\N	Фатеева Ирина Алексеевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
411	\N	Михеев Юрий Алексеевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
412	\N	Пошехонов Ю.И.	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
413	\N	Ларин Игорь Сергеевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
414	\N	ФКЦ	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
415	\N	Корнилова М.П.	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
416	\N	е	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
417	\N	Юнисов Ильяз Равильевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
418	\N	Буланов Юрий Валентинович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
419	\N	Тасенко Анастасия Андреевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
420	\N	Мунгалов Роман Валерьевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
421	\N	Зотов Александр Владимирович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
422	\N	Павлюченко Константин Валентинович (бывш. Киселев Олег Иванович)	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
423	\N	На кого записывать --> Клюев П.К.	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
424	\N	Тараканов Борис Леонардович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
425	\N	Пашкова Марина Викторовна (общий ПК)	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
426	\N	Кутищев Анатолий Владимирович (бывш.Бабашкин Д В.)	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-02-17 23:54:02.090047+03	2026-02-17 23:54:02.090047+03	f
\.


--
-- Name: audit_events_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.audit_events_id_seq', 28, true);


--
-- Name: desk_attachments_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.desk_attachments_id_seq', 1, false);


--
-- Name: dic_equipment_status_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.dic_equipment_status_id_seq', 5, true);


--
-- Name: dic_task_status_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.dic_task_status_id_seq', 6, true);


--
-- Name: equip_history_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.equip_history_id_seq', 1, false);


--
-- Name: equipment_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.equipment_id_seq', 1938, true);


--
-- Name: equipment_software_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.equipment_software_id_seq', 1, false);


--
-- Name: import_errors_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.import_errors_id_seq', 1, false);


--
-- Name: import_runs_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.import_runs_id_seq', 1, false);


--
-- Name: licenses_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.licenses_id_seq', 10, true);


--
-- Name: locations_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.locations_id_seq', 139, true);


--
-- Name: nsi_change_log_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.nsi_change_log_id_seq', 1, false);


--
-- Name: part_char_values_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.part_char_values_id_seq', 5746, true);


--
-- Name: permissions_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.permissions_id_seq', 1, false);


--
-- Name: role_permissions_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.role_permissions_id_seq', 1, false);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.roles_id_seq', 3, true);


--
-- Name: software_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.software_id_seq', 900010, true);


--
-- Name: spr_chars_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.spr_chars_id_seq', 14, true);


--
-- Name: spr_parts_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.spr_parts_id_seq', 12, true);


--
-- Name: task_attachments_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.task_attachments_id_seq', 1, false);


--
-- Name: task_equipment_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.task_equipment_id_seq', 17, true);


--
-- Name: task_history_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.task_history_id_seq', 14, true);


--
-- Name: tasks_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.tasks_id_seq', 5, true);


--
-- Name: user_roles_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.user_roles_id_seq', 426, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.users_id_seq', 426, true);


--
-- Name: audit_events audit_events_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.audit_events
    ADD CONSTRAINT audit_events_pkey PRIMARY KEY (id);


--
-- Name: desk_attachments desk_attachments_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.desk_attachments
    ADD CONSTRAINT desk_attachments_pkey PRIMARY KEY (id);


--
-- Name: dic_equipment_status dic_equipment_status_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.dic_equipment_status
    ADD CONSTRAINT dic_equipment_status_pkey PRIMARY KEY (id);


--
-- Name: dic_equipment_status dic_equipment_status_status_code_key; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.dic_equipment_status
    ADD CONSTRAINT dic_equipment_status_status_code_key UNIQUE (status_code);


--
-- Name: dic_equipment_status dic_equipment_status_status_name_key; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.dic_equipment_status
    ADD CONSTRAINT dic_equipment_status_status_name_key UNIQUE (status_name);


--
-- Name: dic_task_status dic_task_status_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.dic_task_status
    ADD CONSTRAINT dic_task_status_pkey PRIMARY KEY (id);


--
-- Name: dic_task_status dic_task_status_status_code_key; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.dic_task_status
    ADD CONSTRAINT dic_task_status_status_code_key UNIQUE (status_code);


--
-- Name: dic_task_status dic_task_status_status_name_key; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.dic_task_status
    ADD CONSTRAINT dic_task_status_status_name_key UNIQUE (status_name);


--
-- Name: equip_history equip_history_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equip_history
    ADD CONSTRAINT equip_history_pkey PRIMARY KEY (id);


--
-- Name: equipment equipment_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment
    ADD CONSTRAINT equipment_pkey PRIMARY KEY (id);


--
-- Name: equipment_software equipment_software_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_software
    ADD CONSTRAINT equipment_software_pkey PRIMARY KEY (id);


--
-- Name: import_errors import_errors_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.import_errors
    ADD CONSTRAINT import_errors_pkey PRIMARY KEY (id);


--
-- Name: import_runs import_runs_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.import_runs
    ADD CONSTRAINT import_runs_pkey PRIMARY KEY (id);


--
-- Name: licenses licenses_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.licenses
    ADD CONSTRAINT licenses_pkey PRIMARY KEY (id);


--
-- Name: locations locations_name_key; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.locations
    ADD CONSTRAINT locations_name_key UNIQUE (name);


--
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- Name: migration migration_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.migration
    ADD CONSTRAINT migration_pkey PRIMARY KEY (version);


--
-- Name: nsi_change_log nsi_change_log_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.nsi_change_log
    ADD CONSTRAINT nsi_change_log_pkey PRIMARY KEY (id);


--
-- Name: part_char_values part_char_values_equipment_id_part_id_char_id_key; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.part_char_values
    ADD CONSTRAINT part_char_values_equipment_id_part_id_char_id_key UNIQUE (equipment_id, part_id, char_id);


--
-- Name: part_char_values part_char_values_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.part_char_values
    ADD CONSTRAINT part_char_values_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_perm_code_key; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.permissions
    ADD CONSTRAINT permissions_perm_code_key UNIQUE (perm_code);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (id);


--
-- Name: role_permissions role_permissions_role_id_permission_id_key; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.role_permissions
    ADD CONSTRAINT role_permissions_role_id_permission_id_key UNIQUE (role_id, permission_id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: roles roles_role_code_key; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.roles
    ADD CONSTRAINT roles_role_code_key UNIQUE (role_code);


--
-- Name: software software_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.software
    ADD CONSTRAINT software_pkey PRIMARY KEY (id);


--
-- Name: spr_chars spr_chars_name_key; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.spr_chars
    ADD CONSTRAINT spr_chars_name_key UNIQUE (name);


--
-- Name: spr_chars spr_chars_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.spr_chars
    ADD CONSTRAINT spr_chars_pkey PRIMARY KEY (id);


--
-- Name: spr_parts spr_parts_name_key; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.spr_parts
    ADD CONSTRAINT spr_parts_name_key UNIQUE (name);


--
-- Name: spr_parts spr_parts_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.spr_parts
    ADD CONSTRAINT spr_parts_pkey PRIMARY KEY (id);


--
-- Name: task_attachments task_attachments_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.task_attachments
    ADD CONSTRAINT task_attachments_pkey PRIMARY KEY (id);


--
-- Name: task_attachments task_attachments_task_id_attachment_id_key; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.task_attachments
    ADD CONSTRAINT task_attachments_task_id_attachment_id_key UNIQUE (task_id, attachment_id);


--
-- Name: task_equipment task_equipment_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.task_equipment
    ADD CONSTRAINT task_equipment_pkey PRIMARY KEY (id);


--
-- Name: task_equipment task_equipment_task_id_equipment_id_key; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.task_equipment
    ADD CONSTRAINT task_equipment_task_id_equipment_id_key UNIQUE (task_id, equipment_id);


--
-- Name: task_history task_history_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.task_history
    ADD CONSTRAINT task_history_pkey PRIMARY KEY (id);


--
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- Name: tasks tasks_task_number_key; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.tasks
    ADD CONSTRAINT tasks_task_number_key UNIQUE (task_number);


--
-- Name: equipment uq_equipment_inventory_number; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment
    ADD CONSTRAINT uq_equipment_inventory_number UNIQUE (inventory_number);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);


--
-- Name: user_roles user_roles_user_id_role_id_is_active_key; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.user_roles
    ADD CONSTRAINT user_roles_user_id_role_id_is_active_key UNIQUE (user_id, role_id, is_active);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: idx_audit_events_action; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_audit_events_action ON tech_accounting.audit_events USING btree (action_type, result_status);


--
-- Name: idx_audit_events_actor_time; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_audit_events_actor_time ON tech_accounting.audit_events USING btree (actor_id, event_time DESC);


--
-- Name: idx_audit_events_event_time; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_audit_events_event_time ON tech_accounting.audit_events USING btree (event_time DESC);


--
-- Name: idx_audit_events_object; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_audit_events_object ON tech_accounting.audit_events USING btree (object_type, object_id);


--
-- Name: idx_desk_attachments_name; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_desk_attachments_name ON tech_accounting.desk_attachments USING btree (original_name);


--
-- Name: idx_desk_attachments_uploaded_at; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_desk_attachments_uploaded_at ON tech_accounting.desk_attachments USING btree (uploaded_at DESC);


--
-- Name: idx_equip_history_equipment_date; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_equip_history_equipment_date ON tech_accounting.equip_history USING btree (equipment_id, changed_at DESC);


--
-- Name: idx_equipment_filters_responsible; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_equipment_filters_responsible ON tech_accounting.equipment USING btree (responsible_user_id, is_archived, is_deleted);


--
-- Name: idx_equipment_filters_status_location; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_equipment_filters_status_location ON tech_accounting.equipment USING btree (status_id, location_id, is_archived, is_deleted);


--
-- Name: idx_equipment_search_inventory; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_equipment_search_inventory ON tech_accounting.equipment USING btree (inventory_number);


--
-- Name: idx_equipment_search_name; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_equipment_search_name ON tech_accounting.equipment USING btree (lower((name)::text));


--
-- Name: idx_import_errors_run_id; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_import_errors_run_id ON tech_accounting.import_errors USING btree (import_run_id);


--
-- Name: idx_part_char_values_equipment; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_part_char_values_equipment ON tech_accounting.part_char_values USING btree (equipment_id);


--
-- Name: idx_part_char_values_part_char; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_part_char_values_part_char ON tech_accounting.part_char_values USING btree (part_id, char_id);


--
-- Name: idx_task_attachments_attachment; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_task_attachments_attachment ON tech_accounting.task_attachments USING btree (attachment_id);


--
-- Name: idx_task_attachments_task; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_task_attachments_task ON tech_accounting.task_attachments USING btree (task_id);


--
-- Name: idx_task_equipment_equipment; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_task_equipment_equipment ON tech_accounting.task_equipment USING btree (equipment_id);


--
-- Name: idx_task_equipment_task; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_task_equipment_task ON tech_accounting.task_equipment USING btree (task_id);


--
-- Name: idx_task_history_task_changed; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_task_history_task_changed ON tech_accounting.task_history USING btree (task_id, changed_at DESC);


--
-- Name: idx_tasks_executor; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_tasks_executor ON tech_accounting.tasks USING btree (executor_id, created_at DESC);


--
-- Name: idx_tasks_requester; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_tasks_requester ON tech_accounting.tasks USING btree (requester_id, created_at DESC);


--
-- Name: idx_tasks_status_created; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_tasks_status_created ON tech_accounting.tasks USING btree (status_id, created_at DESC);


--
-- Name: uq_equipment_serial_number_not_null; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE UNIQUE INDEX uq_equipment_serial_number_not_null ON tech_accounting.equipment USING btree (serial_number) WHERE (serial_number IS NOT NULL);


--
-- Name: audit_events trg_audit_events_immutable; Type: TRIGGER; Schema: tech_accounting; Owner: -
--

CREATE TRIGGER trg_audit_events_immutable BEFORE DELETE OR UPDATE ON tech_accounting.audit_events FOR EACH ROW EXECUTE FUNCTION tech_accounting.prevent_update_delete();


--
-- Name: dic_equipment_status trg_dic_equipment_status_set_updated_at; Type: TRIGGER; Schema: tech_accounting; Owner: -
--

CREATE TRIGGER trg_dic_equipment_status_set_updated_at BEFORE UPDATE ON tech_accounting.dic_equipment_status FOR EACH ROW EXECUTE FUNCTION tech_accounting.set_updated_at();


--
-- Name: dic_task_status trg_dic_task_status_set_updated_at; Type: TRIGGER; Schema: tech_accounting; Owner: -
--

CREATE TRIGGER trg_dic_task_status_set_updated_at BEFORE UPDATE ON tech_accounting.dic_task_status FOR EACH ROW EXECUTE FUNCTION tech_accounting.set_updated_at();


--
-- Name: equipment trg_equipment_set_updated_at; Type: TRIGGER; Schema: tech_accounting; Owner: -
--

CREATE TRIGGER trg_equipment_set_updated_at BEFORE UPDATE ON tech_accounting.equipment FOR EACH ROW EXECUTE FUNCTION tech_accounting.set_updated_at();


--
-- Name: locations trg_locations_set_updated_at; Type: TRIGGER; Schema: tech_accounting; Owner: -
--

CREATE TRIGGER trg_locations_set_updated_at BEFORE UPDATE ON tech_accounting.locations FOR EACH ROW EXECUTE FUNCTION tech_accounting.set_updated_at();


--
-- Name: roles trg_roles_set_updated_at; Type: TRIGGER; Schema: tech_accounting; Owner: -
--

CREATE TRIGGER trg_roles_set_updated_at BEFORE UPDATE ON tech_accounting.roles FOR EACH ROW EXECUTE FUNCTION tech_accounting.set_updated_at();


--
-- Name: spr_chars trg_spr_chars_set_updated_at; Type: TRIGGER; Schema: tech_accounting; Owner: -
--

CREATE TRIGGER trg_spr_chars_set_updated_at BEFORE UPDATE ON tech_accounting.spr_chars FOR EACH ROW EXECUTE FUNCTION tech_accounting.set_updated_at();


--
-- Name: spr_parts trg_spr_parts_set_updated_at; Type: TRIGGER; Schema: tech_accounting; Owner: -
--

CREATE TRIGGER trg_spr_parts_set_updated_at BEFORE UPDATE ON tech_accounting.spr_parts FOR EACH ROW EXECUTE FUNCTION tech_accounting.set_updated_at();


--
-- Name: tasks trg_tasks_set_updated_at; Type: TRIGGER; Schema: tech_accounting; Owner: -
--

CREATE TRIGGER trg_tasks_set_updated_at BEFORE UPDATE ON tech_accounting.tasks FOR EACH ROW EXECUTE FUNCTION tech_accounting.set_updated_at();


--
-- Name: users trg_users_set_updated_at; Type: TRIGGER; Schema: tech_accounting; Owner: -
--

CREATE TRIGGER trg_users_set_updated_at BEFORE UPDATE ON tech_accounting.users FOR EACH ROW EXECUTE FUNCTION tech_accounting.set_updated_at();


--
-- Name: audit_events audit_events_actor_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.audit_events
    ADD CONSTRAINT audit_events_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES tech_accounting.users(id);


--
-- Name: desk_attachments desk_attachments_deleted_by_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.desk_attachments
    ADD CONSTRAINT desk_attachments_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES tech_accounting.users(id);


--
-- Name: desk_attachments desk_attachments_uploaded_by_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.desk_attachments
    ADD CONSTRAINT desk_attachments_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES tech_accounting.users(id);


--
-- Name: equip_history equip_history_changed_by_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equip_history
    ADD CONSTRAINT equip_history_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES tech_accounting.users(id);


--
-- Name: equip_history equip_history_equipment_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equip_history
    ADD CONSTRAINT equip_history_equipment_id_fkey FOREIGN KEY (equipment_id) REFERENCES tech_accounting.equipment(id);


--
-- Name: equipment equipment_created_by_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment
    ADD CONSTRAINT equipment_created_by_id_fkey FOREIGN KEY (created_by_id) REFERENCES tech_accounting.users(id);


--
-- Name: equipment equipment_location_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment
    ADD CONSTRAINT equipment_location_id_fkey FOREIGN KEY (location_id) REFERENCES tech_accounting.locations(id);


--
-- Name: equipment equipment_responsible_user_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment
    ADD CONSTRAINT equipment_responsible_user_id_fkey FOREIGN KEY (responsible_user_id) REFERENCES tech_accounting.users(id);


--
-- Name: equipment equipment_status_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment
    ADD CONSTRAINT equipment_status_id_fkey FOREIGN KEY (status_id) REFERENCES tech_accounting.dic_equipment_status(id);


--
-- Name: equipment equipment_updated_by_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment
    ADD CONSTRAINT equipment_updated_by_id_fkey FOREIGN KEY (updated_by_id) REFERENCES tech_accounting.users(id);


--
-- Name: equipment_software fk_equipment_software_equipment; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_software
    ADD CONSTRAINT fk_equipment_software_equipment FOREIGN KEY (equipment_id) REFERENCES tech_accounting.equipment(id);


--
-- Name: equipment_software fk_equipment_software_software; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_software
    ADD CONSTRAINT fk_equipment_software_software FOREIGN KEY (software_id) REFERENCES tech_accounting.software(id);


--
-- Name: licenses fk_licenses_software; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.licenses
    ADD CONSTRAINT fk_licenses_software FOREIGN KEY (software_id) REFERENCES tech_accounting.software(id);


--
-- Name: import_errors import_errors_import_run_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.import_errors
    ADD CONSTRAINT import_errors_import_run_id_fkey FOREIGN KEY (import_run_id) REFERENCES tech_accounting.import_runs(id);


--
-- Name: import_runs import_runs_initiated_by_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.import_runs
    ADD CONSTRAINT import_runs_initiated_by_fkey FOREIGN KEY (initiated_by) REFERENCES tech_accounting.users(id);


--
-- Name: locations locations_created_by_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.locations
    ADD CONSTRAINT locations_created_by_id_fkey FOREIGN KEY (created_by_id) REFERENCES tech_accounting.users(id);


--
-- Name: locations locations_updated_by_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.locations
    ADD CONSTRAINT locations_updated_by_id_fkey FOREIGN KEY (updated_by_id) REFERENCES tech_accounting.users(id);


--
-- Name: nsi_change_log nsi_change_log_changed_by_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.nsi_change_log
    ADD CONSTRAINT nsi_change_log_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES tech_accounting.users(id);


--
-- Name: part_char_values part_char_values_char_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.part_char_values
    ADD CONSTRAINT part_char_values_char_id_fkey FOREIGN KEY (char_id) REFERENCES tech_accounting.spr_chars(id);


--
-- Name: part_char_values part_char_values_equipment_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.part_char_values
    ADD CONSTRAINT part_char_values_equipment_id_fkey FOREIGN KEY (equipment_id) REFERENCES tech_accounting.equipment(id);


--
-- Name: part_char_values part_char_values_part_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.part_char_values
    ADD CONSTRAINT part_char_values_part_id_fkey FOREIGN KEY (part_id) REFERENCES tech_accounting.spr_parts(id);


--
-- Name: part_char_values part_char_values_updated_by_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.part_char_values
    ADD CONSTRAINT part_char_values_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES tech_accounting.users(id);


--
-- Name: role_permissions role_permissions_granted_by_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.role_permissions
    ADD CONSTRAINT role_permissions_granted_by_fkey FOREIGN KEY (granted_by) REFERENCES tech_accounting.users(id);


--
-- Name: role_permissions role_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.role_permissions
    ADD CONSTRAINT role_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES tech_accounting.permissions(id);


--
-- Name: role_permissions role_permissions_role_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.role_permissions
    ADD CONSTRAINT role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES tech_accounting.roles(id);


--
-- Name: task_attachments task_attachments_attachment_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.task_attachments
    ADD CONSTRAINT task_attachments_attachment_id_fkey FOREIGN KEY (attachment_id) REFERENCES tech_accounting.desk_attachments(id);


--
-- Name: task_attachments task_attachments_linked_by_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.task_attachments
    ADD CONSTRAINT task_attachments_linked_by_fkey FOREIGN KEY (linked_by) REFERENCES tech_accounting.users(id);


--
-- Name: task_attachments task_attachments_task_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.task_attachments
    ADD CONSTRAINT task_attachments_task_id_fkey FOREIGN KEY (task_id) REFERENCES tech_accounting.tasks(id);


--
-- Name: task_equipment task_equipment_equipment_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.task_equipment
    ADD CONSTRAINT task_equipment_equipment_id_fkey FOREIGN KEY (equipment_id) REFERENCES tech_accounting.equipment(id);


--
-- Name: task_equipment task_equipment_linked_by_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.task_equipment
    ADD CONSTRAINT task_equipment_linked_by_fkey FOREIGN KEY (linked_by) REFERENCES tech_accounting.users(id);


--
-- Name: task_equipment task_equipment_task_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.task_equipment
    ADD CONSTRAINT task_equipment_task_id_fkey FOREIGN KEY (task_id) REFERENCES tech_accounting.tasks(id);


--
-- Name: task_history task_history_changed_by_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.task_history
    ADD CONSTRAINT task_history_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES tech_accounting.users(id);


--
-- Name: task_history task_history_task_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.task_history
    ADD CONSTRAINT task_history_task_id_fkey FOREIGN KEY (task_id) REFERENCES tech_accounting.tasks(id);


--
-- Name: tasks tasks_deleted_by_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.tasks
    ADD CONSTRAINT tasks_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES tech_accounting.users(id);


--
-- Name: tasks tasks_executor_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.tasks
    ADD CONSTRAINT tasks_executor_id_fkey FOREIGN KEY (executor_id) REFERENCES tech_accounting.users(id);


--
-- Name: tasks tasks_requester_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.tasks
    ADD CONSTRAINT tasks_requester_id_fkey FOREIGN KEY (requester_id) REFERENCES tech_accounting.users(id);


--
-- Name: tasks tasks_status_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.tasks
    ADD CONSTRAINT tasks_status_id_fkey FOREIGN KEY (status_id) REFERENCES tech_accounting.dic_task_status(id);


--
-- Name: user_roles user_roles_assigned_by_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.user_roles
    ADD CONSTRAINT user_roles_assigned_by_fkey FOREIGN KEY (assigned_by) REFERENCES tech_accounting.users(id);


--
-- Name: user_roles user_roles_role_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.user_roles
    ADD CONSTRAINT user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES tech_accounting.roles(id);


--
-- Name: user_roles user_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.user_roles
    ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES tech_accounting.users(id);


--
-- Name: users users_created_by_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.users
    ADD CONSTRAINT users_created_by_id_fkey FOREIGN KEY (created_by_id) REFERENCES tech_accounting.users(id);


--
-- Name: users users_updated_by_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.users
    ADD CONSTRAINT users_updated_by_id_fkey FOREIGN KEY (updated_by_id) REFERENCES tech_accounting.users(id);


--
-- PostgreSQL database dump complete
--

\unrestrict aWwNwLrSVOosUSWtBpbKOGdodc4BuWNCjuaXwXIufl3yXefmSundDHSYMwTgl7J

