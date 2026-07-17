--
-- PostgreSQL database dump
--

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

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
-- Name: dic_work_task_status; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.dic_work_task_status (
    id integer NOT NULL,
    status_code character varying(50) NOT NULL,
    status_name character varying(100) NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    timeline_step smallint DEFAULT 0 NOT NULL,
    is_final boolean DEFAULT false NOT NULL,
    is_archived boolean DEFAULT false NOT NULL,
    created_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: dic_work_task_status_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.dic_work_task_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dic_work_task_status_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.dic_work_task_status_id_seq OWNED BY tech_accounting.dic_work_task_status.id;


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
    id_type integer,
    parent_equipment_id bigint,
    delivery_id integer,
    delivery_unit_id integer,
    CONSTRAINT chk_equipment_name_not_empty CHECK ((length(TRIM(BOTH FROM name)) > 0)),
    CONSTRAINT chk_equipment_parent_not_self CHECK (((parent_equipment_id IS NULL) OR (parent_equipment_id <> id))),
    CONSTRAINT chk_equipment_warranty_dates CHECK (((warranty_until IS NULL) OR (commissioning_date IS NULL) OR (warranty_until >= commissioning_date)))
);


--
-- Name: equipment_attachments; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.equipment_attachments (
    id integer NOT NULL,
    equipment_id integer NOT NULL,
    attachment_id bigint NOT NULL,
    linked_by integer,
    linked_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: equipment_attachments_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.equipment_attachments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: equipment_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.equipment_attachments_id_seq OWNED BY tech_accounting.equipment_attachments.id;


--
-- Name: equipment_deliveries; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.equipment_deliveries (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    supplier character varying(255) DEFAULT NULL::character varying,
    delivery_date date NOT NULL,
    warehouse_location_id integer,
    status character varying(16) DEFAULT 'draft'::character varying NOT NULL,
    notes text,
    created_by integer,
    created_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(0) without time zone DEFAULT NULL::timestamp without time zone
);


--
-- Name: equipment_deliveries_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.equipment_deliveries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: equipment_deliveries_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.equipment_deliveries_id_seq OWNED BY tech_accounting.equipment_deliveries.id;


--
-- Name: equipment_delivery_attachments; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.equipment_delivery_attachments (
    id integer NOT NULL,
    delivery_id integer NOT NULL,
    attachment_id bigint NOT NULL,
    linked_by integer,
    linked_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: equipment_delivery_attachments_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.equipment_delivery_attachments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: equipment_delivery_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.equipment_delivery_attachments_id_seq OWNED BY tech_accounting.equipment_delivery_attachments.id;


--
-- Name: equipment_delivery_lines; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.equipment_delivery_lines (
    id integer NOT NULL,
    delivery_id integer NOT NULL,
    equipment_type character varying(100) NOT NULL,
    equipment_type_id integer,
    name character varying(200) NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    description text,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(0) without time zone DEFAULT NULL::timestamp without time zone,
    warehouse_location_id integer,
    char_template text,
    warranty_years numeric(4,1) DEFAULT NULL::numeric
);


--
-- Name: equipment_delivery_lines_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.equipment_delivery_lines_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: equipment_delivery_lines_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.equipment_delivery_lines_id_seq OWNED BY tech_accounting.equipment_delivery_lines.id;


--
-- Name: equipment_delivery_units; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.equipment_delivery_units (
    id integer NOT NULL,
    line_id integer NOT NULL,
    seq_no integer NOT NULL,
    serial_number character varying(150) DEFAULT NULL::character varying,
    inventory_number character varying(100) DEFAULT NULL::character varying,
    number_status character varying(16) DEFAULT 'empty'::character varying NOT NULL,
    equipment_id integer,
    created_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(0) without time zone DEFAULT NULL::timestamp without time zone
);


--
-- Name: equipment_delivery_units_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.equipment_delivery_units_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: equipment_delivery_units_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.equipment_delivery_units_id_seq OWNED BY tech_accounting.equipment_delivery_units.id;


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
-- Name: equipment_import_logs; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.equipment_import_logs (
    id integer NOT NULL,
    uploaded_by integer,
    file_name character varying(255) NOT NULL,
    total_rows integer DEFAULT 0 NOT NULL,
    valid_rows integer DEFAULT 0 NOT NULL,
    error_rows integer DEFAULT 0 NOT NULL,
    status character varying(32) DEFAULT 'validated'::character varying NOT NULL,
    payload_json text,
    created_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: equipment_import_logs_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.equipment_import_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: equipment_import_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.equipment_import_logs_id_seq OWNED BY tech_accounting.equipment_import_logs.id;


--
-- Name: equipment_links; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.equipment_links (
    id integer NOT NULL,
    parent_equipment_id integer NOT NULL,
    child_equipment_id integer NOT NULL,
    link_type character varying(32) NOT NULL,
    created_by integer,
    created_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(0) without time zone DEFAULT NULL::timestamp without time zone
);


--
-- Name: equipment_links_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.equipment_links_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: equipment_links_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.equipment_links_id_seq OWNED BY tech_accounting.equipment_links.id;


--
-- Name: equipment_software; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.equipment_software (
    id bigint NOT NULL,
    equipment_id bigint NOT NULL,
    software_id bigint NOT NULL,
    installed_at date,
    created_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP,
    license_id bigint
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
-- Name: equipment_types; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.equipment_types (
    id integer NOT NULL,
    name character varying
);


--
-- Name: equipment_types_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.equipment_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: equipment_types_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.equipment_types_id_seq OWNED BY tech_accounting.equipment_types.id;


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
-- Name: license_attachments; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.license_attachments (
    id bigint NOT NULL,
    license_id bigint NOT NULL,
    attachment_id bigint NOT NULL,
    linked_by bigint,
    linked_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: license_attachments_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.license_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: license_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.license_attachments_id_seq OWNED BY tech_accounting.license_attachments.id;


--
-- Name: licenses; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.licenses (
    id bigint NOT NULL,
    software_id bigint NOT NULL,
    valid_until date,
    notes text,
    created_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP,
    supplier character varying(255),
    purchase_date date,
    valid_from date,
    seats integer DEFAULT 1 NOT NULL,
    validity_years numeric(5,1),
    is_perpetual boolean DEFAULT false NOT NULL
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
    contact_phone character varying(50) DEFAULT NULL::character varying,
    room_number character varying(50) DEFAULT NULL::character varying,
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
-- Name: user_equipment_cards; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.user_equipment_cards (
    id integer NOT NULL,
    user_id integer NOT NULL,
    is_signed boolean DEFAULT false NOT NULL,
    signed_at timestamp(0) without time zone DEFAULT NULL::timestamp without time zone,
    signed_by_admin_id integer,
    version_no integer DEFAULT 1 NOT NULL,
    last_snapshot_hash character varying(64) DEFAULT NULL::character varying,
    created_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(0) without time zone DEFAULT NULL::timestamp without time zone
);


--
-- Name: user_equipment_cards_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.user_equipment_cards_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_equipment_cards_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.user_equipment_cards_id_seq OWNED BY tech_accounting.user_equipment_cards.id;


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
-- Name: work_task_attachments; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.work_task_attachments (
    id bigint NOT NULL,
    work_task_id bigint NOT NULL,
    attachment_id bigint NOT NULL,
    linked_by bigint,
    linked_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: work_task_attachments_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.work_task_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: work_task_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.work_task_attachments_id_seq OWNED BY tech_accounting.work_task_attachments.id;


--
-- Name: work_task_comments; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.work_task_comments (
    id bigint NOT NULL,
    work_task_id bigint NOT NULL,
    author_id bigint NOT NULL,
    body text NOT NULL,
    created_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: work_task_comments_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.work_task_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: work_task_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.work_task_comments_id_seq OWNED BY tech_accounting.work_task_comments.id;


--
-- Name: work_task_executors; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.work_task_executors (
    id bigint NOT NULL,
    work_task_id bigint NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: work_task_executors_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.work_task_executors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: work_task_executors_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.work_task_executors_id_seq OWNED BY tech_accounting.work_task_executors.id;


--
-- Name: work_task_history; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.work_task_history (
    id bigint NOT NULL,
    work_task_id bigint NOT NULL,
    event_type character varying(50) NOT NULL,
    old_status_id bigint,
    new_status_id bigint,
    comment text,
    changed_by bigint,
    changed_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: work_task_history_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.work_task_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: work_task_history_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.work_task_history_id_seq OWNED BY tech_accounting.work_task_history.id;


--
-- Name: work_tasks; Type: TABLE; Schema: tech_accounting; Owner: -
--

CREATE TABLE tech_accounting.work_tasks (
    id bigint NOT NULL,
    title character varying(250) NOT NULL,
    description text NOT NULL,
    status_id bigint NOT NULL,
    request_task_id bigint,
    creator_id bigint NOT NULL,
    executor_id bigint,
    priority character varying(20) DEFAULT 'medium'::character varying NOT NULL,
    submitted_at timestamp(0) without time zone DEFAULT NULL::timestamp without time zone,
    confirmed_at timestamp(0) without time zone DEFAULT NULL::timestamp without time zone,
    confirmed_by bigint,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status_changed_at timestamp(0) without time zone NOT NULL
);


--
-- Name: work_tasks_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: -
--

CREATE SEQUENCE tech_accounting.work_tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: work_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: -
--

ALTER SEQUENCE tech_accounting.work_tasks_id_seq OWNED BY tech_accounting.work_tasks.id;


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
-- Name: dic_work_task_status id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.dic_work_task_status ALTER COLUMN id SET DEFAULT nextval('tech_accounting.dic_work_task_status_id_seq'::regclass);


--
-- Name: equip_history id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equip_history ALTER COLUMN id SET DEFAULT nextval('tech_accounting.equip_history_id_seq'::regclass);


--
-- Name: equipment id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment ALTER COLUMN id SET DEFAULT nextval('tech_accounting.equipment_id_seq'::regclass);


--
-- Name: equipment_attachments id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_attachments ALTER COLUMN id SET DEFAULT nextval('tech_accounting.equipment_attachments_id_seq'::regclass);


--
-- Name: equipment_deliveries id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_deliveries ALTER COLUMN id SET DEFAULT nextval('tech_accounting.equipment_deliveries_id_seq'::regclass);


--
-- Name: equipment_delivery_attachments id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_delivery_attachments ALTER COLUMN id SET DEFAULT nextval('tech_accounting.equipment_delivery_attachments_id_seq'::regclass);


--
-- Name: equipment_delivery_lines id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_delivery_lines ALTER COLUMN id SET DEFAULT nextval('tech_accounting.equipment_delivery_lines_id_seq'::regclass);


--
-- Name: equipment_delivery_units id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_delivery_units ALTER COLUMN id SET DEFAULT nextval('tech_accounting.equipment_delivery_units_id_seq'::regclass);


--
-- Name: equipment_import_logs id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_import_logs ALTER COLUMN id SET DEFAULT nextval('tech_accounting.equipment_import_logs_id_seq'::regclass);


--
-- Name: equipment_links id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_links ALTER COLUMN id SET DEFAULT nextval('tech_accounting.equipment_links_id_seq'::regclass);


--
-- Name: equipment_software id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_software ALTER COLUMN id SET DEFAULT nextval('tech_accounting.equipment_software_id_seq'::regclass);


--
-- Name: equipment_types id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_types ALTER COLUMN id SET DEFAULT nextval('tech_accounting.equipment_types_id_seq'::regclass);


--
-- Name: import_errors id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.import_errors ALTER COLUMN id SET DEFAULT nextval('tech_accounting.import_errors_id_seq'::regclass);


--
-- Name: import_runs id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.import_runs ALTER COLUMN id SET DEFAULT nextval('tech_accounting.import_runs_id_seq'::regclass);


--
-- Name: license_attachments id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.license_attachments ALTER COLUMN id SET DEFAULT nextval('tech_accounting.license_attachments_id_seq'::regclass);


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
-- Name: user_equipment_cards id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.user_equipment_cards ALTER COLUMN id SET DEFAULT nextval('tech_accounting.user_equipment_cards_id_seq'::regclass);


--
-- Name: user_roles id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.user_roles ALTER COLUMN id SET DEFAULT nextval('tech_accounting.user_roles_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.users ALTER COLUMN id SET DEFAULT nextval('tech_accounting.users_id_seq'::regclass);


--
-- Name: work_task_attachments id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.work_task_attachments ALTER COLUMN id SET DEFAULT nextval('tech_accounting.work_task_attachments_id_seq'::regclass);


--
-- Name: work_task_comments id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.work_task_comments ALTER COLUMN id SET DEFAULT nextval('tech_accounting.work_task_comments_id_seq'::regclass);


--
-- Name: work_task_executors id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.work_task_executors ALTER COLUMN id SET DEFAULT nextval('tech_accounting.work_task_executors_id_seq'::regclass);


--
-- Name: work_task_history id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.work_task_history ALTER COLUMN id SET DEFAULT nextval('tech_accounting.work_task_history_id_seq'::regclass);


--
-- Name: work_tasks id; Type: DEFAULT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.work_tasks ALTER COLUMN id SET DEFAULT nextval('tech_accounting.work_tasks_id_seq'::regclass);


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
-- Name: dic_work_task_status dic_work_task_status_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.dic_work_task_status
    ADD CONSTRAINT dic_work_task_status_pkey PRIMARY KEY (id);


--
-- Name: dic_work_task_status dic_work_task_status_status_code_key; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.dic_work_task_status
    ADD CONSTRAINT dic_work_task_status_status_code_key UNIQUE (status_code);


--
-- Name: dic_work_task_status dic_work_task_status_status_name_key; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.dic_work_task_status
    ADD CONSTRAINT dic_work_task_status_status_name_key UNIQUE (status_name);


--
-- Name: equip_history equip_history_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equip_history
    ADD CONSTRAINT equip_history_pkey PRIMARY KEY (id);


--
-- Name: equipment_attachments equipment_attachments_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_attachments
    ADD CONSTRAINT equipment_attachments_pkey PRIMARY KEY (id);


--
-- Name: equipment_deliveries equipment_deliveries_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_deliveries
    ADD CONSTRAINT equipment_deliveries_pkey PRIMARY KEY (id);


--
-- Name: equipment_delivery_attachments equipment_delivery_attachments_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_delivery_attachments
    ADD CONSTRAINT equipment_delivery_attachments_pkey PRIMARY KEY (id);


--
-- Name: equipment_delivery_lines equipment_delivery_lines_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_delivery_lines
    ADD CONSTRAINT equipment_delivery_lines_pkey PRIMARY KEY (id);


--
-- Name: equipment_delivery_units equipment_delivery_units_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_delivery_units
    ADD CONSTRAINT equipment_delivery_units_pkey PRIMARY KEY (id);


--
-- Name: equipment_import_logs equipment_import_logs_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_import_logs
    ADD CONSTRAINT equipment_import_logs_pkey PRIMARY KEY (id);


--
-- Name: equipment_links equipment_links_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_links
    ADD CONSTRAINT equipment_links_pkey PRIMARY KEY (id);


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
-- Name: license_attachments license_attachments_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.license_attachments
    ADD CONSTRAINT license_attachments_pkey PRIMARY KEY (id);


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
-- Name: user_equipment_cards user_equipment_cards_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.user_equipment_cards
    ADD CONSTRAINT user_equipment_cards_pkey PRIMARY KEY (id);


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
-- Name: work_task_attachments work_task_attachments_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.work_task_attachments
    ADD CONSTRAINT work_task_attachments_pkey PRIMARY KEY (id);


--
-- Name: work_task_comments work_task_comments_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.work_task_comments
    ADD CONSTRAINT work_task_comments_pkey PRIMARY KEY (id);


--
-- Name: work_task_executors work_task_executors_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.work_task_executors
    ADD CONSTRAINT work_task_executors_pkey PRIMARY KEY (id);


--
-- Name: work_task_history work_task_history_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.work_task_history
    ADD CONSTRAINT work_task_history_pkey PRIMARY KEY (id);


--
-- Name: work_tasks work_tasks_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.work_tasks
    ADD CONSTRAINT work_tasks_pkey PRIMARY KEY (id);


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
-- Name: idx_equipment_attachments_equipment; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_equipment_attachments_equipment ON tech_accounting.equipment_attachments USING btree (equipment_id);


--
-- Name: idx_equipment_attachments_unique; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE UNIQUE INDEX idx_equipment_attachments_unique ON tech_accounting.equipment_attachments USING btree (equipment_id, attachment_id);


--
-- Name: idx_equipment_deliveries_delivery_date; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_equipment_deliveries_delivery_date ON tech_accounting.equipment_deliveries USING btree (delivery_date);


--
-- Name: idx_equipment_deliveries_status; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_equipment_deliveries_status ON tech_accounting.equipment_deliveries USING btree (status);


--
-- Name: idx_equipment_deliveries_supplier; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_equipment_deliveries_supplier ON tech_accounting.equipment_deliveries USING btree (supplier);


--
-- Name: idx_equipment_delivery_attachments_delivery; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_equipment_delivery_attachments_delivery ON tech_accounting.equipment_delivery_attachments USING btree (delivery_id);


--
-- Name: idx_equipment_delivery_attachments_unique; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE UNIQUE INDEX idx_equipment_delivery_attachments_unique ON tech_accounting.equipment_delivery_attachments USING btree (delivery_id, attachment_id);


--
-- Name: idx_equipment_delivery_id; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_equipment_delivery_id ON tech_accounting.equipment USING btree (delivery_id);


--
-- Name: idx_equipment_delivery_lines_delivery; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_equipment_delivery_lines_delivery ON tech_accounting.equipment_delivery_lines USING btree (delivery_id);


--
-- Name: idx_equipment_delivery_units_equipment; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_equipment_delivery_units_equipment ON tech_accounting.equipment_delivery_units USING btree (equipment_id);


--
-- Name: idx_equipment_delivery_units_serial; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_equipment_delivery_units_serial ON tech_accounting.equipment_delivery_units USING btree (serial_number);


--
-- Name: idx_equipment_filters_responsible; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_equipment_filters_responsible ON tech_accounting.equipment USING btree (responsible_user_id, is_archived, is_deleted);


--
-- Name: idx_equipment_filters_status_location; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_equipment_filters_status_location ON tech_accounting.equipment USING btree (status_id, location_id, is_archived, is_deleted);


--
-- Name: idx_equipment_import_logs_created_at; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_equipment_import_logs_created_at ON tech_accounting.equipment_import_logs USING btree (created_at);


--
-- Name: idx_equipment_import_logs_status; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_equipment_import_logs_status ON tech_accounting.equipment_import_logs USING btree (status);


--
-- Name: idx_equipment_is_archived_is_deleted; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_equipment_is_archived_is_deleted ON tech_accounting.equipment USING btree (is_archived, is_deleted);


--
-- Name: idx_equipment_links_child; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_equipment_links_child ON tech_accounting.equipment_links USING btree (child_equipment_id);


--
-- Name: idx_equipment_links_parent; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_equipment_links_parent ON tech_accounting.equipment_links USING btree (parent_equipment_id);


--
-- Name: idx_equipment_links_type; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_equipment_links_type ON tech_accounting.equipment_links USING btree (link_type);


--
-- Name: idx_equipment_location_id; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_equipment_location_id ON tech_accounting.equipment USING btree (location_id);


--
-- Name: idx_equipment_parent; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_equipment_parent ON tech_accounting.equipment USING btree (parent_equipment_id);


--
-- Name: idx_equipment_responsible_user_id; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_equipment_responsible_user_id ON tech_accounting.equipment USING btree (responsible_user_id);


--
-- Name: idx_equipment_search_inventory; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_equipment_search_inventory ON tech_accounting.equipment USING btree (inventory_number);


--
-- Name: idx_equipment_search_name; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_equipment_search_name ON tech_accounting.equipment USING btree (lower((name)::text));


--
-- Name: idx_equipment_status_id; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_equipment_status_id ON tech_accounting.equipment USING btree (status_id);


--
-- Name: idx_import_errors_run_id; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_import_errors_run_id ON tech_accounting.import_errors USING btree (import_run_id);


--
-- Name: idx_part_char_values_char_id; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_part_char_values_char_id ON tech_accounting.part_char_values USING btree (char_id);


--
-- Name: idx_part_char_values_equipment; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_part_char_values_equipment ON tech_accounting.part_char_values USING btree (equipment_id);


--
-- Name: idx_part_char_values_equipment_id; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_part_char_values_equipment_id ON tech_accounting.part_char_values USING btree (equipment_id);


--
-- Name: idx_part_char_values_part_char; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_part_char_values_part_char ON tech_accounting.part_char_values USING btree (part_id, char_id);


--
-- Name: idx_part_char_values_part_id; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_part_char_values_part_id ON tech_accounting.part_char_values USING btree (part_id);


--
-- Name: idx_task_attachments_attachment; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_task_attachments_attachment ON tech_accounting.task_attachments USING btree (attachment_id);


--
-- Name: idx_task_attachments_attachment_id; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_task_attachments_attachment_id ON tech_accounting.task_attachments USING btree (attachment_id);


--
-- Name: idx_task_attachments_task; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_task_attachments_task ON tech_accounting.task_attachments USING btree (task_id);


--
-- Name: idx_task_attachments_task_attachment; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_task_attachments_task_attachment ON tech_accounting.task_attachments USING btree (task_id, attachment_id);


--
-- Name: idx_task_attachments_task_id; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_task_attachments_task_id ON tech_accounting.task_attachments USING btree (task_id);


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
-- Name: idx_tasks_created_at; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_tasks_created_at ON tech_accounting.tasks USING btree (created_at);


--
-- Name: idx_tasks_executor; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_tasks_executor ON tech_accounting.tasks USING btree (executor_id, created_at DESC);


--
-- Name: idx_tasks_executor_id; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_tasks_executor_id ON tech_accounting.tasks USING btree (executor_id);


--
-- Name: idx_tasks_requester; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_tasks_requester ON tech_accounting.tasks USING btree (requester_id, created_at DESC);


--
-- Name: idx_tasks_requester_id; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_tasks_requester_id ON tech_accounting.tasks USING btree (requester_id);


--
-- Name: idx_tasks_status_created; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_tasks_status_created ON tech_accounting.tasks USING btree (status_id, created_at DESC);


--
-- Name: idx_tasks_status_id; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_tasks_status_id ON tech_accounting.tasks USING btree (status_id);


--
-- Name: idx_user_equipment_cards_is_signed; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_user_equipment_cards_is_signed ON tech_accounting.user_equipment_cards USING btree (is_signed);


--
-- Name: idx_work_task_attachments_attachment; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_work_task_attachments_attachment ON tech_accounting.work_task_attachments USING btree (attachment_id);


--
-- Name: idx_work_task_attachments_task; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_work_task_attachments_task ON tech_accounting.work_task_attachments USING btree (work_task_id);


--
-- Name: idx_work_task_attachments_task_attachment; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE UNIQUE INDEX idx_work_task_attachments_task_attachment ON tech_accounting.work_task_attachments USING btree (work_task_id, attachment_id);


--
-- Name: idx_work_task_comments_created; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_work_task_comments_created ON tech_accounting.work_task_comments USING btree (work_task_id, created_at);


--
-- Name: idx_work_task_comments_task; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_work_task_comments_task ON tech_accounting.work_task_comments USING btree (work_task_id);


--
-- Name: idx_work_task_executors_task; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_work_task_executors_task ON tech_accounting.work_task_executors USING btree (work_task_id);


--
-- Name: idx_work_task_executors_user; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_work_task_executors_user ON tech_accounting.work_task_executors USING btree (user_id);


--
-- Name: idx_work_tasks_executor; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_work_tasks_executor ON tech_accounting.work_tasks USING btree (executor_id);


--
-- Name: idx_work_tasks_request; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_work_tasks_request ON tech_accounting.work_tasks USING btree (request_task_id);


--
-- Name: idx_work_tasks_status; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE INDEX idx_work_tasks_status ON tech_accounting.work_tasks USING btree (status_id);


--
-- Name: uidx_work_task_executors_task_user; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE UNIQUE INDEX uidx_work_task_executors_task_user ON tech_accounting.work_task_executors USING btree (work_task_id, user_id);


--
-- Name: uq_equipment_delivery_unit_id; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE UNIQUE INDEX uq_equipment_delivery_unit_id ON tech_accounting.equipment USING btree (delivery_unit_id) WHERE (delivery_unit_id IS NOT NULL);


--
-- Name: uq_equipment_delivery_units_line_seq; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE UNIQUE INDEX uq_equipment_delivery_units_line_seq ON tech_accounting.equipment_delivery_units USING btree (line_id, seq_no);


--
-- Name: uq_equipment_links_parent_child_type; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE UNIQUE INDEX uq_equipment_links_parent_child_type ON tech_accounting.equipment_links USING btree (parent_equipment_id, child_equipment_id, link_type);


--
-- Name: uq_equipment_serial_number_not_null; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE UNIQUE INDEX uq_equipment_serial_number_not_null ON tech_accounting.equipment USING btree (serial_number) WHERE (serial_number IS NOT NULL);


--
-- Name: uq_user_equipment_cards_user_id; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE UNIQUE INDEX uq_user_equipment_cards_user_id ON tech_accounting.user_equipment_cards USING btree (user_id);


--
-- Name: ux_license_attachments_pair; Type: INDEX; Schema: tech_accounting; Owner: -
--

CREATE UNIQUE INDEX ux_license_attachments_pair ON tech_accounting.license_attachments USING btree (license_id, attachment_id);


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
-- Name: equipment_attachments fk_equipment_attachments_attachment; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_attachments
    ADD CONSTRAINT fk_equipment_attachments_attachment FOREIGN KEY (attachment_id) REFERENCES tech_accounting.desk_attachments(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: equipment_attachments fk_equipment_attachments_equipment; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_attachments
    ADD CONSTRAINT fk_equipment_attachments_equipment FOREIGN KEY (equipment_id) REFERENCES tech_accounting.equipment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: equipment_attachments fk_equipment_attachments_linked_by; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_attachments
    ADD CONSTRAINT fk_equipment_attachments_linked_by FOREIGN KEY (linked_by) REFERENCES tech_accounting.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: equipment_deliveries fk_equipment_deliveries_created_by; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_deliveries
    ADD CONSTRAINT fk_equipment_deliveries_created_by FOREIGN KEY (created_by) REFERENCES tech_accounting.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: equipment_deliveries fk_equipment_deliveries_warehouse_location; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_deliveries
    ADD CONSTRAINT fk_equipment_deliveries_warehouse_location FOREIGN KEY (warehouse_location_id) REFERENCES tech_accounting.locations(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: equipment_delivery_attachments fk_equipment_delivery_attachments_attachment; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_delivery_attachments
    ADD CONSTRAINT fk_equipment_delivery_attachments_attachment FOREIGN KEY (attachment_id) REFERENCES tech_accounting.desk_attachments(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: equipment_delivery_attachments fk_equipment_delivery_attachments_delivery; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_delivery_attachments
    ADD CONSTRAINT fk_equipment_delivery_attachments_delivery FOREIGN KEY (delivery_id) REFERENCES tech_accounting.equipment_deliveries(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: equipment_delivery_attachments fk_equipment_delivery_attachments_linked_by; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_delivery_attachments
    ADD CONSTRAINT fk_equipment_delivery_attachments_linked_by FOREIGN KEY (linked_by) REFERENCES tech_accounting.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: equipment fk_equipment_delivery_id; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment
    ADD CONSTRAINT fk_equipment_delivery_id FOREIGN KEY (delivery_id) REFERENCES tech_accounting.equipment_deliveries(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: equipment_delivery_lines fk_equipment_delivery_lines_delivery; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_delivery_lines
    ADD CONSTRAINT fk_equipment_delivery_lines_delivery FOREIGN KEY (delivery_id) REFERENCES tech_accounting.equipment_deliveries(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: equipment_delivery_lines fk_equipment_delivery_lines_warehouse; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_delivery_lines
    ADD CONSTRAINT fk_equipment_delivery_lines_warehouse FOREIGN KEY (warehouse_location_id) REFERENCES tech_accounting.locations(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: equipment fk_equipment_delivery_unit_id; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment
    ADD CONSTRAINT fk_equipment_delivery_unit_id FOREIGN KEY (delivery_unit_id) REFERENCES tech_accounting.equipment_delivery_units(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: equipment_delivery_units fk_equipment_delivery_units_equipment; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_delivery_units
    ADD CONSTRAINT fk_equipment_delivery_units_equipment FOREIGN KEY (equipment_id) REFERENCES tech_accounting.equipment(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: equipment_delivery_units fk_equipment_delivery_units_line; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_delivery_units
    ADD CONSTRAINT fk_equipment_delivery_units_line FOREIGN KEY (line_id) REFERENCES tech_accounting.equipment_delivery_lines(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: equipment_import_logs fk_equipment_import_logs_uploaded_by; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_import_logs
    ADD CONSTRAINT fk_equipment_import_logs_uploaded_by FOREIGN KEY (uploaded_by) REFERENCES tech_accounting.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: equipment_links fk_equipment_links_child_equipment; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_links
    ADD CONSTRAINT fk_equipment_links_child_equipment FOREIGN KEY (child_equipment_id) REFERENCES tech_accounting.equipment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: equipment_links fk_equipment_links_parent_equipment; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_links
    ADD CONSTRAINT fk_equipment_links_parent_equipment FOREIGN KEY (parent_equipment_id) REFERENCES tech_accounting.equipment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: equipment fk_equipment_parent_equipment; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment
    ADD CONSTRAINT fk_equipment_parent_equipment FOREIGN KEY (parent_equipment_id) REFERENCES tech_accounting.equipment(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: equipment_software fk_equipment_software_equipment; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_software
    ADD CONSTRAINT fk_equipment_software_equipment FOREIGN KEY (equipment_id) REFERENCES tech_accounting.equipment(id);


--
-- Name: equipment_software fk_equipment_software_license; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_software
    ADD CONSTRAINT fk_equipment_software_license FOREIGN KEY (license_id) REFERENCES tech_accounting.licenses(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: equipment_software fk_equipment_software_software; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.equipment_software
    ADD CONSTRAINT fk_equipment_software_software FOREIGN KEY (software_id) REFERENCES tech_accounting.software(id);


--
-- Name: license_attachments fk_license_attachments_attachment; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.license_attachments
    ADD CONSTRAINT fk_license_attachments_attachment FOREIGN KEY (attachment_id) REFERENCES tech_accounting.desk_attachments(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: license_attachments fk_license_attachments_license; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.license_attachments
    ADD CONSTRAINT fk_license_attachments_license FOREIGN KEY (license_id) REFERENCES tech_accounting.licenses(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: licenses fk_licenses_software; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.licenses
    ADD CONSTRAINT fk_licenses_software FOREIGN KEY (software_id) REFERENCES tech_accounting.software(id);


--
-- Name: user_equipment_cards fk_user_equipment_cards_admin; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.user_equipment_cards
    ADD CONSTRAINT fk_user_equipment_cards_admin FOREIGN KEY (signed_by_admin_id) REFERENCES tech_accounting.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: user_equipment_cards fk_user_equipment_cards_user; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.user_equipment_cards
    ADD CONSTRAINT fk_user_equipment_cards_user FOREIGN KEY (user_id) REFERENCES tech_accounting.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: work_task_attachments fk_work_task_attachments_attachment; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.work_task_attachments
    ADD CONSTRAINT fk_work_task_attachments_attachment FOREIGN KEY (attachment_id) REFERENCES tech_accounting.desk_attachments(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: work_task_attachments fk_work_task_attachments_linked_by; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.work_task_attachments
    ADD CONSTRAINT fk_work_task_attachments_linked_by FOREIGN KEY (linked_by) REFERENCES tech_accounting.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: work_task_attachments fk_work_task_attachments_task; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.work_task_attachments
    ADD CONSTRAINT fk_work_task_attachments_task FOREIGN KEY (work_task_id) REFERENCES tech_accounting.work_tasks(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: work_task_comments fk_work_task_comments_author; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.work_task_comments
    ADD CONSTRAINT fk_work_task_comments_author FOREIGN KEY (author_id) REFERENCES tech_accounting.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: work_task_comments fk_work_task_comments_task; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.work_task_comments
    ADD CONSTRAINT fk_work_task_comments_task FOREIGN KEY (work_task_id) REFERENCES tech_accounting.work_tasks(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: work_task_executors fk_work_task_executors_task; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.work_task_executors
    ADD CONSTRAINT fk_work_task_executors_task FOREIGN KEY (work_task_id) REFERENCES tech_accounting.work_tasks(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: work_task_executors fk_work_task_executors_user; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.work_task_executors
    ADD CONSTRAINT fk_work_task_executors_user FOREIGN KEY (user_id) REFERENCES tech_accounting.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: work_task_history fk_work_task_history_task; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.work_task_history
    ADD CONSTRAINT fk_work_task_history_task FOREIGN KEY (work_task_id) REFERENCES tech_accounting.work_tasks(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: work_tasks fk_work_tasks_confirmed_by; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.work_tasks
    ADD CONSTRAINT fk_work_tasks_confirmed_by FOREIGN KEY (confirmed_by) REFERENCES tech_accounting.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: work_tasks fk_work_tasks_creator; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.work_tasks
    ADD CONSTRAINT fk_work_tasks_creator FOREIGN KEY (creator_id) REFERENCES tech_accounting.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: work_tasks fk_work_tasks_executor; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.work_tasks
    ADD CONSTRAINT fk_work_tasks_executor FOREIGN KEY (executor_id) REFERENCES tech_accounting.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: work_tasks fk_work_tasks_request; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.work_tasks
    ADD CONSTRAINT fk_work_tasks_request FOREIGN KEY (request_task_id) REFERENCES tech_accounting.tasks(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: work_tasks fk_work_tasks_status; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: -
--

ALTER TABLE ONLY tech_accounting.work_tasks
    ADD CONSTRAINT fk_work_tasks_status FOREIGN KEY (status_id) REFERENCES tech_accounting.dic_work_task_status(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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

