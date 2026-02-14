--
-- PostgreSQL database dump
--

\restrict usNVUbIh8pRPRrLgLLnOdMaXIMmlfMaEGqvNBag7v4gA3wgxCDdCVhaIskPoWPU

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.8 (Homebrew)

-- Started on 2026-02-14 08:52:39 MSK

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
-- TOC entry 6 (class 2615 OID 108818)
-- Name: tech_accounting; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA tech_accounting;


ALTER SCHEMA tech_accounting OWNER TO postgres;

--
-- TOC entry 269 (class 1255 OID 108819)
-- Name: prevent_update_delete(); Type: FUNCTION; Schema: tech_accounting; Owner: postgres
--

CREATE FUNCTION tech_accounting.prevent_update_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    RAISE EXCEPTION 'Изменение и удаление записей запрещено для таблицы %', TG_TABLE_NAME;
END;
$$;


ALTER FUNCTION tech_accounting.prevent_update_delete() OWNER TO postgres;

--
-- TOC entry 270 (class 1255 OID 108820)
-- Name: set_updated_at(); Type: FUNCTION; Schema: tech_accounting; Owner: postgres
--

CREATE FUNCTION tech_accounting.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION tech_accounting.set_updated_at() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 218 (class 1259 OID 108821)
-- Name: audit_events; Type: TABLE; Schema: tech_accounting; Owner: postgres
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


ALTER TABLE tech_accounting.audit_events OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 108828)
-- Name: audit_events_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: postgres
--

CREATE SEQUENCE tech_accounting.audit_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE tech_accounting.audit_events_id_seq OWNER TO postgres;

--
-- TOC entry 4046 (class 0 OID 0)
-- Dependencies: 219
-- Name: audit_events_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: postgres
--

ALTER SEQUENCE tech_accounting.audit_events_id_seq OWNED BY tech_accounting.audit_events.id;


--
-- TOC entry 220 (class 1259 OID 108829)
-- Name: desk_attachments; Type: TABLE; Schema: tech_accounting; Owner: postgres
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


ALTER TABLE tech_accounting.desk_attachments OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 108837)
-- Name: desk_attachments_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: postgres
--

CREATE SEQUENCE tech_accounting.desk_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE tech_accounting.desk_attachments_id_seq OWNER TO postgres;

--
-- TOC entry 4047 (class 0 OID 0)
-- Dependencies: 221
-- Name: desk_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: postgres
--

ALTER SEQUENCE tech_accounting.desk_attachments_id_seq OWNED BY tech_accounting.desk_attachments.id;


--
-- TOC entry 222 (class 1259 OID 108838)
-- Name: dic_equipment_status; Type: TABLE; Schema: tech_accounting; Owner: postgres
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


ALTER TABLE tech_accounting.dic_equipment_status OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 108846)
-- Name: dic_equipment_status_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: postgres
--

CREATE SEQUENCE tech_accounting.dic_equipment_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE tech_accounting.dic_equipment_status_id_seq OWNER TO postgres;

--
-- TOC entry 4048 (class 0 OID 0)
-- Dependencies: 223
-- Name: dic_equipment_status_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: postgres
--

ALTER SEQUENCE tech_accounting.dic_equipment_status_id_seq OWNED BY tech_accounting.dic_equipment_status.id;


--
-- TOC entry 224 (class 1259 OID 108847)
-- Name: dic_task_status; Type: TABLE; Schema: tech_accounting; Owner: postgres
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


ALTER TABLE tech_accounting.dic_task_status OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 108855)
-- Name: dic_task_status_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: postgres
--

CREATE SEQUENCE tech_accounting.dic_task_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE tech_accounting.dic_task_status_id_seq OWNER TO postgres;

--
-- TOC entry 4049 (class 0 OID 0)
-- Dependencies: 225
-- Name: dic_task_status_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: postgres
--

ALTER SEQUENCE tech_accounting.dic_task_status_id_seq OWNED BY tech_accounting.dic_task_status.id;


--
-- TOC entry 226 (class 1259 OID 108856)
-- Name: equip_history; Type: TABLE; Schema: tech_accounting; Owner: postgres
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


ALTER TABLE tech_accounting.equip_history OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 108863)
-- Name: equip_history_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: postgres
--

CREATE SEQUENCE tech_accounting.equip_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE tech_accounting.equip_history_id_seq OWNER TO postgres;

--
-- TOC entry 4050 (class 0 OID 0)
-- Dependencies: 227
-- Name: equip_history_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: postgres
--

ALTER SEQUENCE tech_accounting.equip_history_id_seq OWNED BY tech_accounting.equip_history.id;


--
-- TOC entry 228 (class 1259 OID 108864)
-- Name: equipment; Type: TABLE; Schema: tech_accounting; Owner: postgres
--

CREATE TABLE tech_accounting.equipment (
    id bigint NOT NULL,
    inventory_number character varying(100) NOT NULL,
    serial_number character varying(150),
    name character varying(200) NOT NULL,
    equipment_type character varying(100),
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
    CONSTRAINT chk_equipment_name_not_empty CHECK ((length(TRIM(BOTH FROM name)) > 0)),
    CONSTRAINT chk_equipment_warranty_dates CHECK (((warranty_until IS NULL) OR (commissioning_date IS NULL) OR (warranty_until >= commissioning_date)))
);


ALTER TABLE tech_accounting.equipment OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 108875)
-- Name: equipment_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: postgres
--

CREATE SEQUENCE tech_accounting.equipment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE tech_accounting.equipment_id_seq OWNER TO postgres;

--
-- TOC entry 4051 (class 0 OID 0)
-- Dependencies: 229
-- Name: equipment_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: postgres
--

ALTER SEQUENCE tech_accounting.equipment_id_seq OWNED BY tech_accounting.equipment.id;


--
-- TOC entry 268 (class 1259 OID 109378)
-- Name: equipment_software; Type: TABLE; Schema: tech_accounting; Owner: postgres
--

CREATE TABLE tech_accounting.equipment_software (
    id bigint NOT NULL,
    equipment_id bigint NOT NULL,
    software_id bigint NOT NULL,
    installed_at date,
    created_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE tech_accounting.equipment_software OWNER TO postgres;

--
-- TOC entry 267 (class 1259 OID 109377)
-- Name: equipment_software_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: postgres
--

CREATE SEQUENCE tech_accounting.equipment_software_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE tech_accounting.equipment_software_id_seq OWNER TO postgres;

--
-- TOC entry 4052 (class 0 OID 0)
-- Dependencies: 267
-- Name: equipment_software_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: postgres
--

ALTER SEQUENCE tech_accounting.equipment_software_id_seq OWNED BY tech_accounting.equipment_software.id;


--
-- TOC entry 230 (class 1259 OID 108876)
-- Name: import_errors; Type: TABLE; Schema: tech_accounting; Owner: postgres
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


ALTER TABLE tech_accounting.import_errors OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 108882)
-- Name: import_errors_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: postgres
--

CREATE SEQUENCE tech_accounting.import_errors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE tech_accounting.import_errors_id_seq OWNER TO postgres;

--
-- TOC entry 4053 (class 0 OID 0)
-- Dependencies: 231
-- Name: import_errors_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: postgres
--

ALTER SEQUENCE tech_accounting.import_errors_id_seq OWNED BY tech_accounting.import_errors.id;


--
-- TOC entry 232 (class 1259 OID 108883)
-- Name: import_runs; Type: TABLE; Schema: tech_accounting; Owner: postgres
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


ALTER TABLE tech_accounting.import_runs OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 108895)
-- Name: import_runs_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: postgres
--

CREATE SEQUENCE tech_accounting.import_runs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE tech_accounting.import_runs_id_seq OWNER TO postgres;

--
-- TOC entry 4054 (class 0 OID 0)
-- Dependencies: 233
-- Name: import_runs_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: postgres
--

ALTER SEQUENCE tech_accounting.import_runs_id_seq OWNED BY tech_accounting.import_runs.id;


--
-- TOC entry 266 (class 1259 OID 109363)
-- Name: licenses; Type: TABLE; Schema: tech_accounting; Owner: postgres
--

CREATE TABLE tech_accounting.licenses (
    id bigint NOT NULL,
    software_id bigint NOT NULL,
    valid_until date,
    notes text,
    created_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE tech_accounting.licenses OWNER TO postgres;

--
-- TOC entry 265 (class 1259 OID 109362)
-- Name: licenses_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: postgres
--

CREATE SEQUENCE tech_accounting.licenses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE tech_accounting.licenses_id_seq OWNER TO postgres;

--
-- TOC entry 4055 (class 0 OID 0)
-- Dependencies: 265
-- Name: licenses_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: postgres
--

ALTER SEQUENCE tech_accounting.licenses_id_seq OWNED BY tech_accounting.licenses.id;


--
-- TOC entry 234 (class 1259 OID 108896)
-- Name: locations; Type: TABLE; Schema: tech_accounting; Owner: postgres
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


ALTER TABLE tech_accounting.locations OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 108906)
-- Name: locations_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: postgres
--

CREATE SEQUENCE tech_accounting.locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE tech_accounting.locations_id_seq OWNER TO postgres;

--
-- TOC entry 4056 (class 0 OID 0)
-- Dependencies: 235
-- Name: locations_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: postgres
--

ALTER SEQUENCE tech_accounting.locations_id_seq OWNED BY tech_accounting.locations.id;


--
-- TOC entry 262 (class 1259 OID 109349)
-- Name: migration; Type: TABLE; Schema: tech_accounting; Owner: postgres
--

CREATE TABLE tech_accounting.migration (
    version character varying(180) NOT NULL,
    apply_time integer
);


ALTER TABLE tech_accounting.migration OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 108907)
-- Name: nsi_change_log; Type: TABLE; Schema: tech_accounting; Owner: postgres
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


ALTER TABLE tech_accounting.nsi_change_log OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 108914)
-- Name: nsi_change_log_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: postgres
--

CREATE SEQUENCE tech_accounting.nsi_change_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE tech_accounting.nsi_change_log_id_seq OWNER TO postgres;

--
-- TOC entry 4057 (class 0 OID 0)
-- Dependencies: 237
-- Name: nsi_change_log_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: postgres
--

ALTER SEQUENCE tech_accounting.nsi_change_log_id_seq OWNED BY tech_accounting.nsi_change_log.id;


--
-- TOC entry 238 (class 1259 OID 108915)
-- Name: part_char_values; Type: TABLE; Schema: tech_accounting; Owner: postgres
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


ALTER TABLE tech_accounting.part_char_values OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 108922)
-- Name: part_char_values_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: postgres
--

CREATE SEQUENCE tech_accounting.part_char_values_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE tech_accounting.part_char_values_id_seq OWNER TO postgres;

--
-- TOC entry 4058 (class 0 OID 0)
-- Dependencies: 239
-- Name: part_char_values_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: postgres
--

ALTER SEQUENCE tech_accounting.part_char_values_id_seq OWNED BY tech_accounting.part_char_values.id;


--
-- TOC entry 240 (class 1259 OID 108923)
-- Name: permissions; Type: TABLE; Schema: tech_accounting; Owner: postgres
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


ALTER TABLE tech_accounting.permissions OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 108931)
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: postgres
--

CREATE SEQUENCE tech_accounting.permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE tech_accounting.permissions_id_seq OWNER TO postgres;

--
-- TOC entry 4059 (class 0 OID 0)
-- Dependencies: 241
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: postgres
--

ALTER SEQUENCE tech_accounting.permissions_id_seq OWNED BY tech_accounting.permissions.id;


--
-- TOC entry 242 (class 1259 OID 108932)
-- Name: role_permissions; Type: TABLE; Schema: tech_accounting; Owner: postgres
--

CREATE TABLE tech_accounting.role_permissions (
    id bigint NOT NULL,
    role_id bigint NOT NULL,
    permission_id bigint NOT NULL,
    granted_by bigint,
    granted_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE tech_accounting.role_permissions OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 108936)
-- Name: role_permissions_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: postgres
--

CREATE SEQUENCE tech_accounting.role_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE tech_accounting.role_permissions_id_seq OWNER TO postgres;

--
-- TOC entry 4060 (class 0 OID 0)
-- Dependencies: 243
-- Name: role_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: postgres
--

ALTER SEQUENCE tech_accounting.role_permissions_id_seq OWNED BY tech_accounting.role_permissions.id;


--
-- TOC entry 244 (class 1259 OID 108937)
-- Name: roles; Type: TABLE; Schema: tech_accounting; Owner: postgres
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


ALTER TABLE tech_accounting.roles OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 108948)
-- Name: roles_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: postgres
--

CREATE SEQUENCE tech_accounting.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE tech_accounting.roles_id_seq OWNER TO postgres;

--
-- TOC entry 4061 (class 0 OID 0)
-- Dependencies: 245
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: postgres
--

ALTER SEQUENCE tech_accounting.roles_id_seq OWNED BY tech_accounting.roles.id;


--
-- TOC entry 264 (class 1259 OID 109355)
-- Name: software; Type: TABLE; Schema: tech_accounting; Owner: postgres
--

CREATE TABLE tech_accounting.software (
    id bigint NOT NULL,
    name character varying(200) NOT NULL,
    version character varying(100),
    created_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE tech_accounting.software OWNER TO postgres;

--
-- TOC entry 263 (class 1259 OID 109354)
-- Name: software_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: postgres
--

CREATE SEQUENCE tech_accounting.software_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE tech_accounting.software_id_seq OWNER TO postgres;

--
-- TOC entry 4062 (class 0 OID 0)
-- Dependencies: 263
-- Name: software_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: postgres
--

ALTER SEQUENCE tech_accounting.software_id_seq OWNED BY tech_accounting.software.id;


--
-- TOC entry 246 (class 1259 OID 108949)
-- Name: spr_chars; Type: TABLE; Schema: tech_accounting; Owner: postgres
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


ALTER TABLE tech_accounting.spr_chars OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 108958)
-- Name: spr_chars_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: postgres
--

CREATE SEQUENCE tech_accounting.spr_chars_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE tech_accounting.spr_chars_id_seq OWNER TO postgres;

--
-- TOC entry 4063 (class 0 OID 0)
-- Dependencies: 247
-- Name: spr_chars_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: postgres
--

ALTER SEQUENCE tech_accounting.spr_chars_id_seq OWNED BY tech_accounting.spr_chars.id;


--
-- TOC entry 248 (class 1259 OID 108959)
-- Name: spr_parts; Type: TABLE; Schema: tech_accounting; Owner: postgres
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


ALTER TABLE tech_accounting.spr_parts OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 108968)
-- Name: spr_parts_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: postgres
--

CREATE SEQUENCE tech_accounting.spr_parts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE tech_accounting.spr_parts_id_seq OWNER TO postgres;

--
-- TOC entry 4064 (class 0 OID 0)
-- Dependencies: 249
-- Name: spr_parts_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: postgres
--

ALTER SEQUENCE tech_accounting.spr_parts_id_seq OWNED BY tech_accounting.spr_parts.id;


--
-- TOC entry 250 (class 1259 OID 108969)
-- Name: task_attachments; Type: TABLE; Schema: tech_accounting; Owner: postgres
--

CREATE TABLE tech_accounting.task_attachments (
    id bigint NOT NULL,
    task_id bigint NOT NULL,
    attachment_id bigint NOT NULL,
    linked_by bigint,
    linked_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE tech_accounting.task_attachments OWNER TO postgres;

--
-- TOC entry 251 (class 1259 OID 108973)
-- Name: task_attachments_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: postgres
--

CREATE SEQUENCE tech_accounting.task_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE tech_accounting.task_attachments_id_seq OWNER TO postgres;

--
-- TOC entry 4065 (class 0 OID 0)
-- Dependencies: 251
-- Name: task_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: postgres
--

ALTER SEQUENCE tech_accounting.task_attachments_id_seq OWNED BY tech_accounting.task_attachments.id;


--
-- TOC entry 252 (class 1259 OID 108974)
-- Name: task_equipment; Type: TABLE; Schema: tech_accounting; Owner: postgres
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


ALTER TABLE tech_accounting.task_equipment OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 108981)
-- Name: task_equipment_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: postgres
--

CREATE SEQUENCE tech_accounting.task_equipment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE tech_accounting.task_equipment_id_seq OWNER TO postgres;

--
-- TOC entry 4066 (class 0 OID 0)
-- Dependencies: 253
-- Name: task_equipment_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: postgres
--

ALTER SEQUENCE tech_accounting.task_equipment_id_seq OWNED BY tech_accounting.task_equipment.id;


--
-- TOC entry 254 (class 1259 OID 108982)
-- Name: task_history; Type: TABLE; Schema: tech_accounting; Owner: postgres
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


ALTER TABLE tech_accounting.task_history OWNER TO postgres;

--
-- TOC entry 255 (class 1259 OID 108988)
-- Name: task_history_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: postgres
--

CREATE SEQUENCE tech_accounting.task_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE tech_accounting.task_history_id_seq OWNER TO postgres;

--
-- TOC entry 4067 (class 0 OID 0)
-- Dependencies: 255
-- Name: task_history_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: postgres
--

ALTER SEQUENCE tech_accounting.task_history_id_seq OWNED BY tech_accounting.task_history.id;


--
-- TOC entry 256 (class 1259 OID 108989)
-- Name: tasks; Type: TABLE; Schema: tech_accounting; Owner: postgres
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


ALTER TABLE tech_accounting.tasks OWNER TO postgres;

--
-- TOC entry 257 (class 1259 OID 108999)
-- Name: tasks_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: postgres
--

CREATE SEQUENCE tech_accounting.tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE tech_accounting.tasks_id_seq OWNER TO postgres;

--
-- TOC entry 4068 (class 0 OID 0)
-- Dependencies: 257
-- Name: tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: postgres
--

ALTER SEQUENCE tech_accounting.tasks_id_seq OWNED BY tech_accounting.tasks.id;


--
-- TOC entry 258 (class 1259 OID 109000)
-- Name: user_roles; Type: TABLE; Schema: tech_accounting; Owner: postgres
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


ALTER TABLE tech_accounting.user_roles OWNER TO postgres;

--
-- TOC entry 259 (class 1259 OID 109005)
-- Name: user_roles_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: postgres
--

CREATE SEQUENCE tech_accounting.user_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE tech_accounting.user_roles_id_seq OWNER TO postgres;

--
-- TOC entry 4069 (class 0 OID 0)
-- Dependencies: 259
-- Name: user_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: postgres
--

ALTER SEQUENCE tech_accounting.user_roles_id_seq OWNED BY tech_accounting.user_roles.id;


--
-- TOC entry 260 (class 1259 OID 109006)
-- Name: users; Type: TABLE; Schema: tech_accounting; Owner: postgres
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


ALTER TABLE tech_accounting.users OWNER TO postgres;

--
-- TOC entry 261 (class 1259 OID 109019)
-- Name: users_id_seq; Type: SEQUENCE; Schema: tech_accounting; Owner: postgres
--

CREATE SEQUENCE tech_accounting.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE tech_accounting.users_id_seq OWNER TO postgres;

--
-- TOC entry 4070 (class 0 OID 0)
-- Dependencies: 261
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: tech_accounting; Owner: postgres
--

ALTER SEQUENCE tech_accounting.users_id_seq OWNED BY tech_accounting.users.id;


--
-- TOC entry 3577 (class 2604 OID 109020)
-- Name: audit_events id; Type: DEFAULT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.audit_events ALTER COLUMN id SET DEFAULT nextval('tech_accounting.audit_events_id_seq'::regclass);


--
-- TOC entry 3579 (class 2604 OID 109021)
-- Name: desk_attachments id; Type: DEFAULT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.desk_attachments ALTER COLUMN id SET DEFAULT nextval('tech_accounting.desk_attachments_id_seq'::regclass);


--
-- TOC entry 3582 (class 2604 OID 109022)
-- Name: dic_equipment_status id; Type: DEFAULT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.dic_equipment_status ALTER COLUMN id SET DEFAULT nextval('tech_accounting.dic_equipment_status_id_seq'::regclass);


--
-- TOC entry 3588 (class 2604 OID 109023)
-- Name: dic_task_status id; Type: DEFAULT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.dic_task_status ALTER COLUMN id SET DEFAULT nextval('tech_accounting.dic_task_status_id_seq'::regclass);


--
-- TOC entry 3594 (class 2604 OID 109024)
-- Name: equip_history id; Type: DEFAULT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.equip_history ALTER COLUMN id SET DEFAULT nextval('tech_accounting.equip_history_id_seq'::regclass);


--
-- TOC entry 3596 (class 2604 OID 109025)
-- Name: equipment id; Type: DEFAULT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.equipment ALTER COLUMN id SET DEFAULT nextval('tech_accounting.equipment_id_seq'::regclass);


--
-- TOC entry 3662 (class 2604 OID 109381)
-- Name: equipment_software id; Type: DEFAULT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.equipment_software ALTER COLUMN id SET DEFAULT nextval('tech_accounting.equipment_software_id_seq'::regclass);


--
-- TOC entry 3601 (class 2604 OID 109026)
-- Name: import_errors id; Type: DEFAULT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.import_errors ALTER COLUMN id SET DEFAULT nextval('tech_accounting.import_errors_id_seq'::regclass);


--
-- TOC entry 3603 (class 2604 OID 109027)
-- Name: import_runs id; Type: DEFAULT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.import_runs ALTER COLUMN id SET DEFAULT nextval('tech_accounting.import_runs_id_seq'::regclass);


--
-- TOC entry 3660 (class 2604 OID 109366)
-- Name: licenses id; Type: DEFAULT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.licenses ALTER COLUMN id SET DEFAULT nextval('tech_accounting.licenses_id_seq'::regclass);


--
-- TOC entry 3609 (class 2604 OID 109028)
-- Name: locations id; Type: DEFAULT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.locations ALTER COLUMN id SET DEFAULT nextval('tech_accounting.locations_id_seq'::regclass);


--
-- TOC entry 3613 (class 2604 OID 109029)
-- Name: nsi_change_log id; Type: DEFAULT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.nsi_change_log ALTER COLUMN id SET DEFAULT nextval('tech_accounting.nsi_change_log_id_seq'::regclass);


--
-- TOC entry 3615 (class 2604 OID 109030)
-- Name: part_char_values id; Type: DEFAULT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.part_char_values ALTER COLUMN id SET DEFAULT nextval('tech_accounting.part_char_values_id_seq'::regclass);


--
-- TOC entry 3618 (class 2604 OID 109031)
-- Name: permissions id; Type: DEFAULT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.permissions ALTER COLUMN id SET DEFAULT nextval('tech_accounting.permissions_id_seq'::regclass);


--
-- TOC entry 3620 (class 2604 OID 109032)
-- Name: role_permissions id; Type: DEFAULT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.role_permissions ALTER COLUMN id SET DEFAULT nextval('tech_accounting.role_permissions_id_seq'::regclass);


--
-- TOC entry 3622 (class 2604 OID 109033)
-- Name: roles id; Type: DEFAULT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.roles ALTER COLUMN id SET DEFAULT nextval('tech_accounting.roles_id_seq'::regclass);


--
-- TOC entry 3658 (class 2604 OID 109358)
-- Name: software id; Type: DEFAULT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.software ALTER COLUMN id SET DEFAULT nextval('tech_accounting.software_id_seq'::regclass);


--
-- TOC entry 3627 (class 2604 OID 109034)
-- Name: spr_chars id; Type: DEFAULT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.spr_chars ALTER COLUMN id SET DEFAULT nextval('tech_accounting.spr_chars_id_seq'::regclass);


--
-- TOC entry 3631 (class 2604 OID 109035)
-- Name: spr_parts id; Type: DEFAULT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.spr_parts ALTER COLUMN id SET DEFAULT nextval('tech_accounting.spr_parts_id_seq'::regclass);


--
-- TOC entry 3635 (class 2604 OID 109036)
-- Name: task_attachments id; Type: DEFAULT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.task_attachments ALTER COLUMN id SET DEFAULT nextval('tech_accounting.task_attachments_id_seq'::regclass);


--
-- TOC entry 3637 (class 2604 OID 109037)
-- Name: task_equipment id; Type: DEFAULT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.task_equipment ALTER COLUMN id SET DEFAULT nextval('tech_accounting.task_equipment_id_seq'::regclass);


--
-- TOC entry 3641 (class 2604 OID 109038)
-- Name: task_history id; Type: DEFAULT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.task_history ALTER COLUMN id SET DEFAULT nextval('tech_accounting.task_history_id_seq'::regclass);


--
-- TOC entry 3643 (class 2604 OID 109039)
-- Name: tasks id; Type: DEFAULT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.tasks ALTER COLUMN id SET DEFAULT nextval('tech_accounting.tasks_id_seq'::regclass);


--
-- TOC entry 3648 (class 2604 OID 109040)
-- Name: user_roles id; Type: DEFAULT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.user_roles ALTER COLUMN id SET DEFAULT nextval('tech_accounting.user_roles_id_seq'::regclass);


--
-- TOC entry 3651 (class 2604 OID 109041)
-- Name: users id; Type: DEFAULT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.users ALTER COLUMN id SET DEFAULT nextval('tech_accounting.users_id_seq'::regclass);


--
-- TOC entry 3990 (class 0 OID 108821)
-- Dependencies: 218
-- Data for Name: audit_events; Type: TABLE DATA; Schema: tech_accounting; Owner: postgres
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
\.


--
-- TOC entry 3992 (class 0 OID 108829)
-- Dependencies: 220
-- Data for Name: desk_attachments; Type: TABLE DATA; Schema: tech_accounting; Owner: postgres
--

COPY tech_accounting.desk_attachments (id, storage_path, original_name, file_extension, mime_type, size_bytes, checksum_sha256, uploaded_by, uploaded_at, is_deleted, deleted_at, deleted_by) FROM stdin;
\.


--
-- TOC entry 3994 (class 0 OID 108838)
-- Dependencies: 222
-- Data for Name: dic_equipment_status; Type: TABLE DATA; Schema: tech_accounting; Owner: postgres
--

COPY tech_accounting.dic_equipment_status (id, status_code, status_name, sort_order, is_final, is_archived, created_at, updated_at) FROM stdin;
1	in_use	В эксплуатации	10	f	f	2026-02-12 11:12:45.835301+03	2026-02-12 11:12:45.835301+03
2	in_stock	На складе	20	f	f	2026-02-12 11:12:45.835301+03	2026-02-12 11:12:45.835301+03
3	in_repair	В ремонте	30	f	f	2026-02-12 11:12:45.835301+03	2026-02-12 11:12:45.835301+03
4	writeoff	Списано	40	t	f	2026-02-12 11:12:45.835301+03	2026-02-12 11:12:45.835301+03
5	archived	В архиве	50	t	f	2026-02-12 11:12:45.835301+03	2026-02-12 11:12:45.835301+03
\.


--
-- TOC entry 3996 (class 0 OID 108847)
-- Dependencies: 224
-- Data for Name: dic_task_status; Type: TABLE DATA; Schema: tech_accounting; Owner: postgres
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
-- TOC entry 3998 (class 0 OID 108856)
-- Dependencies: 226
-- Data for Name: equip_history; Type: TABLE DATA; Schema: tech_accounting; Owner: postgres
--

COPY tech_accounting.equip_history (id, equipment_id, event_type, old_value, new_value, changed_by, changed_at, comment) FROM stdin;
\.


--
-- TOC entry 4000 (class 0 OID 108864)
-- Dependencies: 228
-- Data for Name: equipment; Type: TABLE DATA; Schema: tech_accounting; Owner: postgres
--

COPY tech_accounting.equipment (id, inventory_number, serial_number, name, equipment_type, status_id, responsible_user_id, location_id, supplier, purchase_date, commissioning_date, warranty_until, description, archived_at, archive_reason, is_archived, is_deleted, created_by_id, updated_by_id, created_at, updated_at) FROM stdin;
4	190354	\N	Треугольник	Системный блок	1	4	2	\N	2008-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
5	МЦ.04.2	\N	USN Computers (mini)	Системный блок	1	4	2	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
6	МЦ.04.2-строка4	\N	USN Computers (mini)	Системный блок	1	5	2	\N	2013-01-01	\N	\N	ИБП Powercom RPT-1000A EURO	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
7	МЦ.04.2-строка5	\N	USN Computers (mini)	Системный блок	1	6	2	\N	2013-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
8	00-000804	\N	МИР4	Системный блок	1	7	3	\N	2020-06-18	\N	\N	ИБП APC Back-UPS 650 ВА (BX650CI-RS)	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
9	МЦ.04.1	\N	ARBYTE	Системный блок	1	8	3	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
10	МЦ.04	\N	ООО "ГКС" (ГИГАНТ)	Системный блок	1	9	4	\N	2017-10-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
11	МЦ.04-строка9	\N	Моноблок HP EliteOne 800	Моноблок	1	10	4	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
12	МЦ.04-строка10	\N	AOC 24P2Q\nAOC 24P2Q	Монитор	1	9	4	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
13	Электроника	\N	Моноблок Lenovo ThinkCentre Edge 72z	Моноблок	1	11	4	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
14	МЦ.04 (001601)	\N	Ноутбук Lenivo IdeaPad 300-17ISK	Ноутбук	1	12	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
15	БП-001223	\N	RDW Xpert GE	Системный блок	1	13	5	\N	2024-05-21	\N	\N	ИБП APC Back-UPS 650 ВА (BX650CI-RS)	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
16	БП-001152	\N	RDW Xpert GE	Системный блок	1	14	5	\N	2024-05-21	\N	\N	ИБП APC Back-UPS 650 ВА (BX650CI-RS)	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
17	БП-001187	\N	RDW Xpert GE	Системный блок	1	15	5	\N	2024-05-21	\N	\N	ИБП APC Back-UPS 650 ВА (BX650CI-RS)	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
18	БП-001197	\N	RDW Xpert GE	Системный блок	1	16	5	\N	2024-05-21	\N	\N	ИБП APC Back-UPS BC650-RSX761	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
19	МЦ.04 (001605)	\N	Ноутбук HP Probook 450 G5	Ноутбук	1	16	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
20	БП-001226	\N	RDW Xpert GE	Системный блок	1	17	5	\N	2024-05-21	\N	\N	ИБП APC Back-UPS 650(белый)	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
21	БП-001188	\N	RDW Xpert GE	Системный блок	1	18	5	\N	2024-05-21	\N	\N	ИБП APC Back-UPS 500 Белый	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
22	00-000213	\N	ООО "ГКС" (ГИГАНТ)	Системный блок	1	19	6	\N	2017-10-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
23	00-000894	\N	Ноутбук Lenovo ThinkPad E15-IML 20RD001CRT	Ноутбук	1	19	6	\N	2021-03-07	\N	\N	\N	\N	\N	f	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
\.


--
-- TOC entry 4040 (class 0 OID 109378)
-- Dependencies: 268
-- Data for Name: equipment_software; Type: TABLE DATA; Schema: tech_accounting; Owner: postgres
--

COPY tech_accounting.equipment_software (id, equipment_id, software_id, installed_at, created_at) FROM stdin;
\.


--
-- TOC entry 4002 (class 0 OID 108876)
-- Dependencies: 230
-- Data for Name: import_errors; Type: TABLE DATA; Schema: tech_accounting; Owner: postgres
--

COPY tech_accounting.import_errors (id, import_run_id, row_number, error_code, error_message, raw_payload, created_at) FROM stdin;
\.


--
-- TOC entry 4004 (class 0 OID 108883)
-- Dependencies: 232
-- Data for Name: import_runs; Type: TABLE DATA; Schema: tech_accounting; Owner: postgres
--

COPY tech_accounting.import_runs (id, source_type, source_name, started_at, finished_at, total_rows, success_rows, error_rows, run_status, initiated_by, details) FROM stdin;
\.


--
-- TOC entry 4038 (class 0 OID 109363)
-- Dependencies: 266
-- Data for Name: licenses; Type: TABLE DATA; Schema: tech_accounting; Owner: postgres
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
-- TOC entry 4006 (class 0 OID 108896)
-- Dependencies: 234
-- Data for Name: locations; Type: TABLE DATA; Schema: tech_accounting; Owner: postgres
--

COPY tech_accounting.locations (id, location_code, name, location_type, floor, description, is_archived, created_by_id, updated_by_id, created_at, updated_at) FROM stdin;
2	\N	103	кабинет	\N	\N	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
3	\N	105	кабинет	\N	\N	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
4	\N	Пост охраны	кабинет	\N	\N	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
5	\N	701	кабинет	\N	\N	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
6	\N	702 в	кабинет	\N	\N	f	\N	\N	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
\.


--
-- TOC entry 4034 (class 0 OID 109349)
-- Dependencies: 262
-- Data for Name: migration; Type: TABLE DATA; Schema: tech_accounting; Owner: postgres
--

COPY tech_accounting.migration (version, apply_time) FROM stdin;
m000000_000000_base	1771004397
m260212_100000_insert_initial_admin_user	1771004397
m260213_120000_add_software_licenses	1771004397
\.


--
-- TOC entry 4008 (class 0 OID 108907)
-- Dependencies: 236
-- Data for Name: nsi_change_log; Type: TABLE DATA; Schema: tech_accounting; Owner: postgres
--

COPY tech_accounting.nsi_change_log (id, dictionary_name, record_id, operation_type, old_value, new_value, changed_by, changed_at) FROM stdin;
\.


--
-- TOC entry 4010 (class 0 OID 108915)
-- Dependencies: 238
-- Data for Name: part_char_values; Type: TABLE DATA; Schema: tech_accounting; Owner: postgres
--

COPY tech_accounting.part_char_values (id, equipment_id, part_id, char_id, value_text, value_num, source, updated_by, updated_at) FROM stdin;
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
55	8	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-02-12 20:47:56.480176+03
56	8	7	9	16 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
57	8	8	8	1 Тб	\N	manual	\N	2026-02-12 20:47:56.480176+03
58	8	9	8	Philips 23.8" 241B8QJEB	\N	manual	\N	2026-02-12 20:47:56.480176+03
59	8	9	10	МЦ.04	\N	manual	\N	2026-02-12 20:47:56.480176+03
60	8	10	11	105-w10p64-47	\N	manual	\N	2026-02-12 20:47:56.480176+03
61	8	10	12	10.1.4.47	\N	manual	\N	2026-02-12 20:47:56.480176+03
62	8	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-12 20:47:56.480176+03
63	8	10	14	KES11	\N	manual	\N	2026-02-12 20:47:56.480176+03
64	9	6	8	Core i3-540 3,07 ГГц	\N	manual	\N	2026-02-12 20:47:56.480176+03
65	9	7	9	8 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
66	9	8	8	1 ТБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
67	9	9	8	Nec MultiSync E222W	\N	manual	\N	2026-02-12 20:47:56.480176+03
68	9	9	10	МЦ.04.1	\N	manual	\N	2026-02-12 20:47:56.480176+03
69	9	10	11	105-w10p64-31	\N	manual	\N	2026-02-12 20:47:56.480176+03
70	9	10	12	10.1.4.31	\N	manual	\N	2026-02-12 20:47:56.480176+03
71	9	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-12 20:47:56.480176+03
72	9	10	14	KES12	\N	manual	\N	2026-02-12 20:47:56.480176+03
73	10	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-02-12 20:47:56.480176+03
74	10	7	9	8 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
75	10	8	8	1 ТБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
76	10	9	8	Samsung S22C200	\N	manual	\N	2026-02-12 20:47:56.480176+03
77	10	9	10	МЦ.04.2	\N	manual	\N	2026-02-12 20:47:56.480176+03
78	10	10	11	ohr-W10Px64-1	\N	manual	\N	2026-02-12 20:47:56.480176+03
79	10	10	12	не в сети	\N	manual	\N	2026-02-12 20:47:56.480176+03
80	10	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-12 20:47:56.480176+03
81	11	6	8	Core i3-4130 3,4 ГГц	\N	manual	\N	2026-02-12 20:47:56.480176+03
82	11	7	9	8 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
83	11	8	8	500 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
84	11	9	8	Моноблок	\N	manual	\N	2026-02-12 20:47:56.480176+03
85	11	10	11	PostOhrani	\N	manual	\N	2026-02-12 20:47:56.480176+03
86	11	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-12 20:47:56.480176+03
87	11	10	14	KES11	\N	manual	\N	2026-02-12 20:47:56.480176+03
88	12	9	8	AOC 24P2Q; AOC 24P2Q	\N	manual	\N	2026-02-12 20:47:56.480176+03
89	12	9	10	МЦ.04\nМЦ.04	\N	manual	\N	2026-02-12 20:47:56.480176+03
90	13	6	8	Core i5-3330S 2,7 ГГц	\N	manual	\N	2026-02-12 20:47:56.480176+03
91	13	7	9	8 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
92	13	8	8	500 ГБ	\N	manual	\N	2026-02-12 20:47:56.480176+03
93	13	10	13	Win10 Pro (x64)	\N	manual	\N	2026-02-12 20:47:56.480176+03
94	13	10	14	KES11	\N	manual	\N	2026-02-12 20:47:56.480176+03
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
\.


--
-- TOC entry 4012 (class 0 OID 108923)
-- Dependencies: 240
-- Data for Name: permissions; Type: TABLE DATA; Schema: tech_accounting; Owner: postgres
--

COPY tech_accounting.permissions (id, perm_code, perm_name, description, created_at) FROM stdin;
\.


--
-- TOC entry 4014 (class 0 OID 108932)
-- Dependencies: 242
-- Data for Name: role_permissions; Type: TABLE DATA; Schema: tech_accounting; Owner: postgres
--

COPY tech_accounting.role_permissions (id, role_id, permission_id, granted_by, granted_at) FROM stdin;
\.


--
-- TOC entry 4016 (class 0 OID 108937)
-- Dependencies: 244
-- Data for Name: roles; Type: TABLE DATA; Schema: tech_accounting; Owner: postgres
--

COPY tech_accounting.roles (id, role_code, role_name, description, is_system, is_archived, created_at, updated_at) FROM stdin;
1	admin	Администратор	Полный доступ к данным и настройкам	t	f	2026-02-12 11:12:45.835301+03	2026-02-12 11:12:45.835301+03
2	operator	Оператор	Обработка и сопровождение заявок	t	f	2026-02-12 11:12:45.835301+03	2026-02-12 11:12:45.835301+03
3	user	Пользователь	Создание и просмотр собственных заявок	t	f	2026-02-12 11:12:45.835301+03	2026-02-12 11:12:45.835301+03
\.


--
-- TOC entry 4036 (class 0 OID 109355)
-- Dependencies: 264
-- Data for Name: software; Type: TABLE DATA; Schema: tech_accounting; Owner: postgres
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
-- TOC entry 4018 (class 0 OID 108949)
-- Dependencies: 246
-- Data for Name: spr_chars; Type: TABLE DATA; Schema: tech_accounting; Owner: postgres
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
-- TOC entry 4020 (class 0 OID 108959)
-- Dependencies: 248
-- Data for Name: spr_parts; Type: TABLE DATA; Schema: tech_accounting; Owner: postgres
--

COPY tech_accounting.spr_parts (id, name, description, is_archived, created_at, updated_at) FROM stdin;
6	ЦП	\N	f	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
7	ОЗУ	\N	f	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
8	Накопитель	\N	f	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
9	Монитор	\N	f	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
10	ПК	\N	f	2026-02-12 20:47:56.480176+03	2026-02-12 20:47:56.480176+03
\.


--
-- TOC entry 4022 (class 0 OID 108969)
-- Dependencies: 250
-- Data for Name: task_attachments; Type: TABLE DATA; Schema: tech_accounting; Owner: postgres
--

COPY tech_accounting.task_attachments (id, task_id, attachment_id, linked_by, linked_at) FROM stdin;
\.


--
-- TOC entry 4024 (class 0 OID 108974)
-- Dependencies: 252
-- Data for Name: task_equipment; Type: TABLE DATA; Schema: tech_accounting; Owner: postgres
--

COPY tech_accounting.task_equipment (id, task_id, equipment_id, relation_type, is_primary, linked_by, linked_at) FROM stdin;
12	3	16	related	f	1	2026-02-13 23:36:53.453528+03
13	2	8	related	f	1	2026-02-13 23:36:56.053291+03
14	1	4	related	f	1	2026-02-13 23:36:57.640705+03
\.


--
-- TOC entry 4026 (class 0 OID 108982)
-- Dependencies: 254
-- Data for Name: task_history; Type: TABLE DATA; Schema: tech_accounting; Owner: postgres
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
\.


--
-- TOC entry 4028 (class 0 OID 108989)
-- Dependencies: 256
-- Data for Name: tasks; Type: TABLE DATA; Schema: tech_accounting; Owner: postgres
--

COPY tech_accounting.tasks (id, task_number, title, description, status_id, requester_id, executor_id, priority, due_at, closed_at, comment, attachments_legacy, is_deleted, deleted_at, deleted_by, delete_reason, created_at, updated_at) FROM stdin;
3	\N	\N	123	2	4	20	medium	\N	\N	\N	\N	f	\N	\N	\N	2026-02-13 20:46:21.039945+03	2026-02-13 23:36:53.44276+03
2	\N	\N	Хуита	2	4	20	medium	\N	\N	\N	\N	f	\N	\N	\N	2026-02-13 20:43:55.078886+03	2026-02-13 23:36:56.045592+03
1	\N	\N	пизда ему	2	4	20	medium	\N	\N	\N	\N	f	\N	\N	\N	2026-02-13 20:43:30.296644+03	2026-02-13 23:36:57.633852+03
\.


--
-- TOC entry 4030 (class 0 OID 109000)
-- Dependencies: 258
-- Data for Name: user_roles; Type: TABLE DATA; Schema: tech_accounting; Owner: postgres
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
\.


--
-- TOC entry 4032 (class 0 OID 109006)
-- Dependencies: 260
-- Data for Name: users; Type: TABLE DATA; Schema: tech_accounting; Owner: postgres
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
\.


--
-- TOC entry 4071 (class 0 OID 0)
-- Dependencies: 219
-- Name: audit_events_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: postgres
--

SELECT pg_catalog.setval('tech_accounting.audit_events_id_seq', 25, true);


--
-- TOC entry 4072 (class 0 OID 0)
-- Dependencies: 221
-- Name: desk_attachments_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: postgres
--

SELECT pg_catalog.setval('tech_accounting.desk_attachments_id_seq', 1, false);


--
-- TOC entry 4073 (class 0 OID 0)
-- Dependencies: 223
-- Name: dic_equipment_status_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: postgres
--

SELECT pg_catalog.setval('tech_accounting.dic_equipment_status_id_seq', 5, true);


--
-- TOC entry 4074 (class 0 OID 0)
-- Dependencies: 225
-- Name: dic_task_status_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: postgres
--

SELECT pg_catalog.setval('tech_accounting.dic_task_status_id_seq', 6, true);


--
-- TOC entry 4075 (class 0 OID 0)
-- Dependencies: 227
-- Name: equip_history_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: postgres
--

SELECT pg_catalog.setval('tech_accounting.equip_history_id_seq', 1, false);


--
-- TOC entry 4076 (class 0 OID 0)
-- Dependencies: 229
-- Name: equipment_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: postgres
--

SELECT pg_catalog.setval('tech_accounting.equipment_id_seq', 23, true);


--
-- TOC entry 4077 (class 0 OID 0)
-- Dependencies: 267
-- Name: equipment_software_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: postgres
--

SELECT pg_catalog.setval('tech_accounting.equipment_software_id_seq', 1, false);


--
-- TOC entry 4078 (class 0 OID 0)
-- Dependencies: 231
-- Name: import_errors_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: postgres
--

SELECT pg_catalog.setval('tech_accounting.import_errors_id_seq', 1, false);


--
-- TOC entry 4079 (class 0 OID 0)
-- Dependencies: 233
-- Name: import_runs_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: postgres
--

SELECT pg_catalog.setval('tech_accounting.import_runs_id_seq', 1, false);


--
-- TOC entry 4080 (class 0 OID 0)
-- Dependencies: 265
-- Name: licenses_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: postgres
--

SELECT pg_catalog.setval('tech_accounting.licenses_id_seq', 10, true);


--
-- TOC entry 4081 (class 0 OID 0)
-- Dependencies: 235
-- Name: locations_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: postgres
--

SELECT pg_catalog.setval('tech_accounting.locations_id_seq', 6, true);


--
-- TOC entry 4082 (class 0 OID 0)
-- Dependencies: 237
-- Name: nsi_change_log_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: postgres
--

SELECT pg_catalog.setval('tech_accounting.nsi_change_log_id_seq', 1, false);


--
-- TOC entry 4083 (class 0 OID 0)
-- Dependencies: 239
-- Name: part_char_values_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: postgres
--

SELECT pg_catalog.setval('tech_accounting.part_char_values_id_seq', 170, true);


--
-- TOC entry 4084 (class 0 OID 0)
-- Dependencies: 241
-- Name: permissions_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: postgres
--

SELECT pg_catalog.setval('tech_accounting.permissions_id_seq', 1, false);


--
-- TOC entry 4085 (class 0 OID 0)
-- Dependencies: 243
-- Name: role_permissions_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: postgres
--

SELECT pg_catalog.setval('tech_accounting.role_permissions_id_seq', 1, false);


--
-- TOC entry 4086 (class 0 OID 0)
-- Dependencies: 245
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: postgres
--

SELECT pg_catalog.setval('tech_accounting.roles_id_seq', 3, true);


--
-- TOC entry 4087 (class 0 OID 0)
-- Dependencies: 263
-- Name: software_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: postgres
--

SELECT pg_catalog.setval('tech_accounting.software_id_seq', 900010, true);


--
-- TOC entry 4088 (class 0 OID 0)
-- Dependencies: 247
-- Name: spr_chars_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: postgres
--

SELECT pg_catalog.setval('tech_accounting.spr_chars_id_seq', 14, true);


--
-- TOC entry 4089 (class 0 OID 0)
-- Dependencies: 249
-- Name: spr_parts_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: postgres
--

SELECT pg_catalog.setval('tech_accounting.spr_parts_id_seq', 10, true);


--
-- TOC entry 4090 (class 0 OID 0)
-- Dependencies: 251
-- Name: task_attachments_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: postgres
--

SELECT pg_catalog.setval('tech_accounting.task_attachments_id_seq', 1, false);


--
-- TOC entry 4091 (class 0 OID 0)
-- Dependencies: 253
-- Name: task_equipment_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: postgres
--

SELECT pg_catalog.setval('tech_accounting.task_equipment_id_seq', 14, true);


--
-- TOC entry 4092 (class 0 OID 0)
-- Dependencies: 255
-- Name: task_history_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: postgres
--

SELECT pg_catalog.setval('tech_accounting.task_history_id_seq', 11, true);


--
-- TOC entry 4093 (class 0 OID 0)
-- Dependencies: 257
-- Name: tasks_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: postgres
--

SELECT pg_catalog.setval('tech_accounting.tasks_id_seq', 3, true);


--
-- TOC entry 4094 (class 0 OID 0)
-- Dependencies: 259
-- Name: user_roles_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: postgres
--

SELECT pg_catalog.setval('tech_accounting.user_roles_id_seq', 20, true);


--
-- TOC entry 4095 (class 0 OID 0)
-- Dependencies: 261
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: postgres
--

SELECT pg_catalog.setval('tech_accounting.users_id_seq', 20, true);


--
-- TOC entry 3685 (class 2606 OID 109043)
-- Name: audit_events audit_events_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.audit_events
    ADD CONSTRAINT audit_events_pkey PRIMARY KEY (id);


--
-- TOC entry 3691 (class 2606 OID 109045)
-- Name: desk_attachments desk_attachments_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.desk_attachments
    ADD CONSTRAINT desk_attachments_pkey PRIMARY KEY (id);


--
-- TOC entry 3695 (class 2606 OID 109047)
-- Name: dic_equipment_status dic_equipment_status_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.dic_equipment_status
    ADD CONSTRAINT dic_equipment_status_pkey PRIMARY KEY (id);


--
-- TOC entry 3697 (class 2606 OID 109049)
-- Name: dic_equipment_status dic_equipment_status_status_code_key; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.dic_equipment_status
    ADD CONSTRAINT dic_equipment_status_status_code_key UNIQUE (status_code);


--
-- TOC entry 3699 (class 2606 OID 109051)
-- Name: dic_equipment_status dic_equipment_status_status_name_key; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.dic_equipment_status
    ADD CONSTRAINT dic_equipment_status_status_name_key UNIQUE (status_name);


--
-- TOC entry 3701 (class 2606 OID 109053)
-- Name: dic_task_status dic_task_status_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.dic_task_status
    ADD CONSTRAINT dic_task_status_pkey PRIMARY KEY (id);


--
-- TOC entry 3703 (class 2606 OID 109055)
-- Name: dic_task_status dic_task_status_status_code_key; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.dic_task_status
    ADD CONSTRAINT dic_task_status_status_code_key UNIQUE (status_code);


--
-- TOC entry 3705 (class 2606 OID 109057)
-- Name: dic_task_status dic_task_status_status_name_key; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.dic_task_status
    ADD CONSTRAINT dic_task_status_status_name_key UNIQUE (status_name);


--
-- TOC entry 3707 (class 2606 OID 109059)
-- Name: equip_history equip_history_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.equip_history
    ADD CONSTRAINT equip_history_pkey PRIMARY KEY (id);


--
-- TOC entry 3710 (class 2606 OID 109061)
-- Name: equipment equipment_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.equipment
    ADD CONSTRAINT equipment_pkey PRIMARY KEY (id);


--
-- TOC entry 3792 (class 2606 OID 109384)
-- Name: equipment_software equipment_software_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.equipment_software
    ADD CONSTRAINT equipment_software_pkey PRIMARY KEY (id);


--
-- TOC entry 3720 (class 2606 OID 109063)
-- Name: import_errors import_errors_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.import_errors
    ADD CONSTRAINT import_errors_pkey PRIMARY KEY (id);


--
-- TOC entry 3722 (class 2606 OID 109065)
-- Name: import_runs import_runs_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.import_runs
    ADD CONSTRAINT import_runs_pkey PRIMARY KEY (id);


--
-- TOC entry 3790 (class 2606 OID 109371)
-- Name: licenses licenses_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.licenses
    ADD CONSTRAINT licenses_pkey PRIMARY KEY (id);


--
-- TOC entry 3724 (class 2606 OID 109067)
-- Name: locations locations_name_key; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.locations
    ADD CONSTRAINT locations_name_key UNIQUE (name);


--
-- TOC entry 3726 (class 2606 OID 109069)
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- TOC entry 3786 (class 2606 OID 109353)
-- Name: migration migration_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.migration
    ADD CONSTRAINT migration_pkey PRIMARY KEY (version);


--
-- TOC entry 3728 (class 2606 OID 109071)
-- Name: nsi_change_log nsi_change_log_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.nsi_change_log
    ADD CONSTRAINT nsi_change_log_pkey PRIMARY KEY (id);


--
-- TOC entry 3732 (class 2606 OID 109073)
-- Name: part_char_values part_char_values_equipment_id_part_id_char_id_key; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.part_char_values
    ADD CONSTRAINT part_char_values_equipment_id_part_id_char_id_key UNIQUE (equipment_id, part_id, char_id);


--
-- TOC entry 3734 (class 2606 OID 109075)
-- Name: part_char_values part_char_values_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.part_char_values
    ADD CONSTRAINT part_char_values_pkey PRIMARY KEY (id);


--
-- TOC entry 3736 (class 2606 OID 109077)
-- Name: permissions permissions_perm_code_key; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.permissions
    ADD CONSTRAINT permissions_perm_code_key UNIQUE (perm_code);


--
-- TOC entry 3738 (class 2606 OID 109079)
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- TOC entry 3740 (class 2606 OID 109081)
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (id);


--
-- TOC entry 3742 (class 2606 OID 109083)
-- Name: role_permissions role_permissions_role_id_permission_id_key; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.role_permissions
    ADD CONSTRAINT role_permissions_role_id_permission_id_key UNIQUE (role_id, permission_id);


--
-- TOC entry 3744 (class 2606 OID 109085)
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- TOC entry 3746 (class 2606 OID 109087)
-- Name: roles roles_role_code_key; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.roles
    ADD CONSTRAINT roles_role_code_key UNIQUE (role_code);


--
-- TOC entry 3788 (class 2606 OID 109361)
-- Name: software software_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.software
    ADD CONSTRAINT software_pkey PRIMARY KEY (id);


--
-- TOC entry 3748 (class 2606 OID 109089)
-- Name: spr_chars spr_chars_name_key; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.spr_chars
    ADD CONSTRAINT spr_chars_name_key UNIQUE (name);


--
-- TOC entry 3750 (class 2606 OID 109091)
-- Name: spr_chars spr_chars_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.spr_chars
    ADD CONSTRAINT spr_chars_pkey PRIMARY KEY (id);


--
-- TOC entry 3752 (class 2606 OID 109093)
-- Name: spr_parts spr_parts_name_key; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.spr_parts
    ADD CONSTRAINT spr_parts_name_key UNIQUE (name);


--
-- TOC entry 3754 (class 2606 OID 109095)
-- Name: spr_parts spr_parts_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.spr_parts
    ADD CONSTRAINT spr_parts_pkey PRIMARY KEY (id);


--
-- TOC entry 3758 (class 2606 OID 109097)
-- Name: task_attachments task_attachments_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.task_attachments
    ADD CONSTRAINT task_attachments_pkey PRIMARY KEY (id);


--
-- TOC entry 3760 (class 2606 OID 109099)
-- Name: task_attachments task_attachments_task_id_attachment_id_key; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.task_attachments
    ADD CONSTRAINT task_attachments_task_id_attachment_id_key UNIQUE (task_id, attachment_id);


--
-- TOC entry 3764 (class 2606 OID 109101)
-- Name: task_equipment task_equipment_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.task_equipment
    ADD CONSTRAINT task_equipment_pkey PRIMARY KEY (id);


--
-- TOC entry 3766 (class 2606 OID 109103)
-- Name: task_equipment task_equipment_task_id_equipment_id_key; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.task_equipment
    ADD CONSTRAINT task_equipment_task_id_equipment_id_key UNIQUE (task_id, equipment_id);


--
-- TOC entry 3769 (class 2606 OID 109105)
-- Name: task_history task_history_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.task_history
    ADD CONSTRAINT task_history_pkey PRIMARY KEY (id);


--
-- TOC entry 3774 (class 2606 OID 109107)
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- TOC entry 3776 (class 2606 OID 109109)
-- Name: tasks tasks_task_number_key; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.tasks
    ADD CONSTRAINT tasks_task_number_key UNIQUE (task_number);


--
-- TOC entry 3716 (class 2606 OID 109111)
-- Name: equipment uq_equipment_inventory_number; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.equipment
    ADD CONSTRAINT uq_equipment_inventory_number UNIQUE (inventory_number);


--
-- TOC entry 3778 (class 2606 OID 109113)
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);


--
-- TOC entry 3780 (class 2606 OID 109115)
-- Name: user_roles user_roles_user_id_role_id_is_active_key; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.user_roles
    ADD CONSTRAINT user_roles_user_id_role_id_is_active_key UNIQUE (user_id, role_id, is_active);


--
-- TOC entry 3782 (class 2606 OID 109117)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 3784 (class 2606 OID 109119)
-- Name: users users_username_key; Type: CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- TOC entry 3686 (class 1259 OID 109120)
-- Name: idx_audit_events_action; Type: INDEX; Schema: tech_accounting; Owner: postgres
--

CREATE INDEX idx_audit_events_action ON tech_accounting.audit_events USING btree (action_type, result_status);


--
-- TOC entry 3687 (class 1259 OID 109121)
-- Name: idx_audit_events_actor_time; Type: INDEX; Schema: tech_accounting; Owner: postgres
--

CREATE INDEX idx_audit_events_actor_time ON tech_accounting.audit_events USING btree (actor_id, event_time DESC);


--
-- TOC entry 3688 (class 1259 OID 109122)
-- Name: idx_audit_events_event_time; Type: INDEX; Schema: tech_accounting; Owner: postgres
--

CREATE INDEX idx_audit_events_event_time ON tech_accounting.audit_events USING btree (event_time DESC);


--
-- TOC entry 3689 (class 1259 OID 109123)
-- Name: idx_audit_events_object; Type: INDEX; Schema: tech_accounting; Owner: postgres
--

CREATE INDEX idx_audit_events_object ON tech_accounting.audit_events USING btree (object_type, object_id);


--
-- TOC entry 3692 (class 1259 OID 109124)
-- Name: idx_desk_attachments_name; Type: INDEX; Schema: tech_accounting; Owner: postgres
--

CREATE INDEX idx_desk_attachments_name ON tech_accounting.desk_attachments USING btree (original_name);


--
-- TOC entry 3693 (class 1259 OID 109125)
-- Name: idx_desk_attachments_uploaded_at; Type: INDEX; Schema: tech_accounting; Owner: postgres
--

CREATE INDEX idx_desk_attachments_uploaded_at ON tech_accounting.desk_attachments USING btree (uploaded_at DESC);


--
-- TOC entry 3708 (class 1259 OID 109126)
-- Name: idx_equip_history_equipment_date; Type: INDEX; Schema: tech_accounting; Owner: postgres
--

CREATE INDEX idx_equip_history_equipment_date ON tech_accounting.equip_history USING btree (equipment_id, changed_at DESC);


--
-- TOC entry 3711 (class 1259 OID 109127)
-- Name: idx_equipment_filters_responsible; Type: INDEX; Schema: tech_accounting; Owner: postgres
--

CREATE INDEX idx_equipment_filters_responsible ON tech_accounting.equipment USING btree (responsible_user_id, is_archived, is_deleted);


--
-- TOC entry 3712 (class 1259 OID 109128)
-- Name: idx_equipment_filters_status_location; Type: INDEX; Schema: tech_accounting; Owner: postgres
--

CREATE INDEX idx_equipment_filters_status_location ON tech_accounting.equipment USING btree (status_id, location_id, is_archived, is_deleted);


--
-- TOC entry 3713 (class 1259 OID 109129)
-- Name: idx_equipment_search_inventory; Type: INDEX; Schema: tech_accounting; Owner: postgres
--

CREATE INDEX idx_equipment_search_inventory ON tech_accounting.equipment USING btree (inventory_number);


--
-- TOC entry 3714 (class 1259 OID 109130)
-- Name: idx_equipment_search_name; Type: INDEX; Schema: tech_accounting; Owner: postgres
--

CREATE INDEX idx_equipment_search_name ON tech_accounting.equipment USING btree (lower((name)::text));


--
-- TOC entry 3718 (class 1259 OID 109131)
-- Name: idx_import_errors_run_id; Type: INDEX; Schema: tech_accounting; Owner: postgres
--

CREATE INDEX idx_import_errors_run_id ON tech_accounting.import_errors USING btree (import_run_id);


--
-- TOC entry 3729 (class 1259 OID 109132)
-- Name: idx_part_char_values_equipment; Type: INDEX; Schema: tech_accounting; Owner: postgres
--

CREATE INDEX idx_part_char_values_equipment ON tech_accounting.part_char_values USING btree (equipment_id);


--
-- TOC entry 3730 (class 1259 OID 109133)
-- Name: idx_part_char_values_part_char; Type: INDEX; Schema: tech_accounting; Owner: postgres
--

CREATE INDEX idx_part_char_values_part_char ON tech_accounting.part_char_values USING btree (part_id, char_id);


--
-- TOC entry 3755 (class 1259 OID 109134)
-- Name: idx_task_attachments_attachment; Type: INDEX; Schema: tech_accounting; Owner: postgres
--

CREATE INDEX idx_task_attachments_attachment ON tech_accounting.task_attachments USING btree (attachment_id);


--
-- TOC entry 3756 (class 1259 OID 109135)
-- Name: idx_task_attachments_task; Type: INDEX; Schema: tech_accounting; Owner: postgres
--

CREATE INDEX idx_task_attachments_task ON tech_accounting.task_attachments USING btree (task_id);


--
-- TOC entry 3761 (class 1259 OID 109136)
-- Name: idx_task_equipment_equipment; Type: INDEX; Schema: tech_accounting; Owner: postgres
--

CREATE INDEX idx_task_equipment_equipment ON tech_accounting.task_equipment USING btree (equipment_id);


--
-- TOC entry 3762 (class 1259 OID 109137)
-- Name: idx_task_equipment_task; Type: INDEX; Schema: tech_accounting; Owner: postgres
--

CREATE INDEX idx_task_equipment_task ON tech_accounting.task_equipment USING btree (task_id);


--
-- TOC entry 3767 (class 1259 OID 109138)
-- Name: idx_task_history_task_changed; Type: INDEX; Schema: tech_accounting; Owner: postgres
--

CREATE INDEX idx_task_history_task_changed ON tech_accounting.task_history USING btree (task_id, changed_at DESC);


--
-- TOC entry 3770 (class 1259 OID 109139)
-- Name: idx_tasks_executor; Type: INDEX; Schema: tech_accounting; Owner: postgres
--

CREATE INDEX idx_tasks_executor ON tech_accounting.tasks USING btree (executor_id, created_at DESC);


--
-- TOC entry 3771 (class 1259 OID 109140)
-- Name: idx_tasks_requester; Type: INDEX; Schema: tech_accounting; Owner: postgres
--

CREATE INDEX idx_tasks_requester ON tech_accounting.tasks USING btree (requester_id, created_at DESC);


--
-- TOC entry 3772 (class 1259 OID 109141)
-- Name: idx_tasks_status_created; Type: INDEX; Schema: tech_accounting; Owner: postgres
--

CREATE INDEX idx_tasks_status_created ON tech_accounting.tasks USING btree (status_id, created_at DESC);


--
-- TOC entry 3717 (class 1259 OID 109142)
-- Name: uq_equipment_serial_number_not_null; Type: INDEX; Schema: tech_accounting; Owner: postgres
--

CREATE UNIQUE INDEX uq_equipment_serial_number_not_null ON tech_accounting.equipment USING btree (serial_number) WHERE (serial_number IS NOT NULL);


--
-- TOC entry 3835 (class 2620 OID 109143)
-- Name: audit_events trg_audit_events_immutable; Type: TRIGGER; Schema: tech_accounting; Owner: postgres
--

CREATE TRIGGER trg_audit_events_immutable BEFORE DELETE OR UPDATE ON tech_accounting.audit_events FOR EACH ROW EXECUTE FUNCTION tech_accounting.prevent_update_delete();


--
-- TOC entry 3836 (class 2620 OID 109144)
-- Name: dic_equipment_status trg_dic_equipment_status_set_updated_at; Type: TRIGGER; Schema: tech_accounting; Owner: postgres
--

CREATE TRIGGER trg_dic_equipment_status_set_updated_at BEFORE UPDATE ON tech_accounting.dic_equipment_status FOR EACH ROW EXECUTE FUNCTION tech_accounting.set_updated_at();


--
-- TOC entry 3837 (class 2620 OID 109145)
-- Name: dic_task_status trg_dic_task_status_set_updated_at; Type: TRIGGER; Schema: tech_accounting; Owner: postgres
--

CREATE TRIGGER trg_dic_task_status_set_updated_at BEFORE UPDATE ON tech_accounting.dic_task_status FOR EACH ROW EXECUTE FUNCTION tech_accounting.set_updated_at();


--
-- TOC entry 3838 (class 2620 OID 109146)
-- Name: equipment trg_equipment_set_updated_at; Type: TRIGGER; Schema: tech_accounting; Owner: postgres
--

CREATE TRIGGER trg_equipment_set_updated_at BEFORE UPDATE ON tech_accounting.equipment FOR EACH ROW EXECUTE FUNCTION tech_accounting.set_updated_at();


--
-- TOC entry 3839 (class 2620 OID 109147)
-- Name: locations trg_locations_set_updated_at; Type: TRIGGER; Schema: tech_accounting; Owner: postgres
--

CREATE TRIGGER trg_locations_set_updated_at BEFORE UPDATE ON tech_accounting.locations FOR EACH ROW EXECUTE FUNCTION tech_accounting.set_updated_at();


--
-- TOC entry 3840 (class 2620 OID 109148)
-- Name: roles trg_roles_set_updated_at; Type: TRIGGER; Schema: tech_accounting; Owner: postgres
--

CREATE TRIGGER trg_roles_set_updated_at BEFORE UPDATE ON tech_accounting.roles FOR EACH ROW EXECUTE FUNCTION tech_accounting.set_updated_at();


--
-- TOC entry 3841 (class 2620 OID 109149)
-- Name: spr_chars trg_spr_chars_set_updated_at; Type: TRIGGER; Schema: tech_accounting; Owner: postgres
--

CREATE TRIGGER trg_spr_chars_set_updated_at BEFORE UPDATE ON tech_accounting.spr_chars FOR EACH ROW EXECUTE FUNCTION tech_accounting.set_updated_at();


--
-- TOC entry 3842 (class 2620 OID 109150)
-- Name: spr_parts trg_spr_parts_set_updated_at; Type: TRIGGER; Schema: tech_accounting; Owner: postgres
--

CREATE TRIGGER trg_spr_parts_set_updated_at BEFORE UPDATE ON tech_accounting.spr_parts FOR EACH ROW EXECUTE FUNCTION tech_accounting.set_updated_at();


--
-- TOC entry 3843 (class 2620 OID 109151)
-- Name: tasks trg_tasks_set_updated_at; Type: TRIGGER; Schema: tech_accounting; Owner: postgres
--

CREATE TRIGGER trg_tasks_set_updated_at BEFORE UPDATE ON tech_accounting.tasks FOR EACH ROW EXECUTE FUNCTION tech_accounting.set_updated_at();


--
-- TOC entry 3844 (class 2620 OID 109152)
-- Name: users trg_users_set_updated_at; Type: TRIGGER; Schema: tech_accounting; Owner: postgres
--

CREATE TRIGGER trg_users_set_updated_at BEFORE UPDATE ON tech_accounting.users FOR EACH ROW EXECUTE FUNCTION tech_accounting.set_updated_at();


--
-- TOC entry 3793 (class 2606 OID 109153)
-- Name: audit_events audit_events_actor_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.audit_events
    ADD CONSTRAINT audit_events_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES tech_accounting.users(id);


--
-- TOC entry 3794 (class 2606 OID 109158)
-- Name: desk_attachments desk_attachments_deleted_by_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.desk_attachments
    ADD CONSTRAINT desk_attachments_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES tech_accounting.users(id);


--
-- TOC entry 3795 (class 2606 OID 109163)
-- Name: desk_attachments desk_attachments_uploaded_by_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.desk_attachments
    ADD CONSTRAINT desk_attachments_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES tech_accounting.users(id);


--
-- TOC entry 3796 (class 2606 OID 109168)
-- Name: equip_history equip_history_changed_by_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.equip_history
    ADD CONSTRAINT equip_history_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES tech_accounting.users(id);


--
-- TOC entry 3797 (class 2606 OID 109173)
-- Name: equip_history equip_history_equipment_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.equip_history
    ADD CONSTRAINT equip_history_equipment_id_fkey FOREIGN KEY (equipment_id) REFERENCES tech_accounting.equipment(id);


--
-- TOC entry 3798 (class 2606 OID 109178)
-- Name: equipment equipment_created_by_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.equipment
    ADD CONSTRAINT equipment_created_by_id_fkey FOREIGN KEY (created_by_id) REFERENCES tech_accounting.users(id);


--
-- TOC entry 3799 (class 2606 OID 109183)
-- Name: equipment equipment_location_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.equipment
    ADD CONSTRAINT equipment_location_id_fkey FOREIGN KEY (location_id) REFERENCES tech_accounting.locations(id);


--
-- TOC entry 3800 (class 2606 OID 109188)
-- Name: equipment equipment_responsible_user_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.equipment
    ADD CONSTRAINT equipment_responsible_user_id_fkey FOREIGN KEY (responsible_user_id) REFERENCES tech_accounting.users(id);


--
-- TOC entry 3801 (class 2606 OID 109193)
-- Name: equipment equipment_status_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.equipment
    ADD CONSTRAINT equipment_status_id_fkey FOREIGN KEY (status_id) REFERENCES tech_accounting.dic_equipment_status(id);


--
-- TOC entry 3802 (class 2606 OID 109198)
-- Name: equipment equipment_updated_by_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.equipment
    ADD CONSTRAINT equipment_updated_by_id_fkey FOREIGN KEY (updated_by_id) REFERENCES tech_accounting.users(id);


--
-- TOC entry 3833 (class 2606 OID 109385)
-- Name: equipment_software fk_equipment_software_equipment; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.equipment_software
    ADD CONSTRAINT fk_equipment_software_equipment FOREIGN KEY (equipment_id) REFERENCES tech_accounting.equipment(id);


--
-- TOC entry 3834 (class 2606 OID 109390)
-- Name: equipment_software fk_equipment_software_software; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.equipment_software
    ADD CONSTRAINT fk_equipment_software_software FOREIGN KEY (software_id) REFERENCES tech_accounting.software(id);


--
-- TOC entry 3832 (class 2606 OID 109372)
-- Name: licenses fk_licenses_software; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.licenses
    ADD CONSTRAINT fk_licenses_software FOREIGN KEY (software_id) REFERENCES tech_accounting.software(id);


--
-- TOC entry 3803 (class 2606 OID 109203)
-- Name: import_errors import_errors_import_run_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.import_errors
    ADD CONSTRAINT import_errors_import_run_id_fkey FOREIGN KEY (import_run_id) REFERENCES tech_accounting.import_runs(id);


--
-- TOC entry 3804 (class 2606 OID 109208)
-- Name: import_runs import_runs_initiated_by_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.import_runs
    ADD CONSTRAINT import_runs_initiated_by_fkey FOREIGN KEY (initiated_by) REFERENCES tech_accounting.users(id);


--
-- TOC entry 3805 (class 2606 OID 109213)
-- Name: locations locations_created_by_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.locations
    ADD CONSTRAINT locations_created_by_id_fkey FOREIGN KEY (created_by_id) REFERENCES tech_accounting.users(id);


--
-- TOC entry 3806 (class 2606 OID 109218)
-- Name: locations locations_updated_by_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.locations
    ADD CONSTRAINT locations_updated_by_id_fkey FOREIGN KEY (updated_by_id) REFERENCES tech_accounting.users(id);


--
-- TOC entry 3807 (class 2606 OID 109223)
-- Name: nsi_change_log nsi_change_log_changed_by_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.nsi_change_log
    ADD CONSTRAINT nsi_change_log_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES tech_accounting.users(id);


--
-- TOC entry 3808 (class 2606 OID 109228)
-- Name: part_char_values part_char_values_char_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.part_char_values
    ADD CONSTRAINT part_char_values_char_id_fkey FOREIGN KEY (char_id) REFERENCES tech_accounting.spr_chars(id);


--
-- TOC entry 3809 (class 2606 OID 109233)
-- Name: part_char_values part_char_values_equipment_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.part_char_values
    ADD CONSTRAINT part_char_values_equipment_id_fkey FOREIGN KEY (equipment_id) REFERENCES tech_accounting.equipment(id);


--
-- TOC entry 3810 (class 2606 OID 109238)
-- Name: part_char_values part_char_values_part_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.part_char_values
    ADD CONSTRAINT part_char_values_part_id_fkey FOREIGN KEY (part_id) REFERENCES tech_accounting.spr_parts(id);


--
-- TOC entry 3811 (class 2606 OID 109243)
-- Name: part_char_values part_char_values_updated_by_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.part_char_values
    ADD CONSTRAINT part_char_values_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES tech_accounting.users(id);


--
-- TOC entry 3812 (class 2606 OID 109248)
-- Name: role_permissions role_permissions_granted_by_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.role_permissions
    ADD CONSTRAINT role_permissions_granted_by_fkey FOREIGN KEY (granted_by) REFERENCES tech_accounting.users(id);


--
-- TOC entry 3813 (class 2606 OID 109253)
-- Name: role_permissions role_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.role_permissions
    ADD CONSTRAINT role_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES tech_accounting.permissions(id);


--
-- TOC entry 3814 (class 2606 OID 109258)
-- Name: role_permissions role_permissions_role_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.role_permissions
    ADD CONSTRAINT role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES tech_accounting.roles(id);


--
-- TOC entry 3815 (class 2606 OID 109263)
-- Name: task_attachments task_attachments_attachment_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.task_attachments
    ADD CONSTRAINT task_attachments_attachment_id_fkey FOREIGN KEY (attachment_id) REFERENCES tech_accounting.desk_attachments(id);


--
-- TOC entry 3816 (class 2606 OID 109268)
-- Name: task_attachments task_attachments_linked_by_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.task_attachments
    ADD CONSTRAINT task_attachments_linked_by_fkey FOREIGN KEY (linked_by) REFERENCES tech_accounting.users(id);


--
-- TOC entry 3817 (class 2606 OID 109273)
-- Name: task_attachments task_attachments_task_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.task_attachments
    ADD CONSTRAINT task_attachments_task_id_fkey FOREIGN KEY (task_id) REFERENCES tech_accounting.tasks(id);


--
-- TOC entry 3818 (class 2606 OID 109278)
-- Name: task_equipment task_equipment_equipment_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.task_equipment
    ADD CONSTRAINT task_equipment_equipment_id_fkey FOREIGN KEY (equipment_id) REFERENCES tech_accounting.equipment(id);


--
-- TOC entry 3819 (class 2606 OID 109283)
-- Name: task_equipment task_equipment_linked_by_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.task_equipment
    ADD CONSTRAINT task_equipment_linked_by_fkey FOREIGN KEY (linked_by) REFERENCES tech_accounting.users(id);


--
-- TOC entry 3820 (class 2606 OID 109288)
-- Name: task_equipment task_equipment_task_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.task_equipment
    ADD CONSTRAINT task_equipment_task_id_fkey FOREIGN KEY (task_id) REFERENCES tech_accounting.tasks(id);


--
-- TOC entry 3821 (class 2606 OID 109293)
-- Name: task_history task_history_changed_by_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.task_history
    ADD CONSTRAINT task_history_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES tech_accounting.users(id);


--
-- TOC entry 3822 (class 2606 OID 109298)
-- Name: task_history task_history_task_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.task_history
    ADD CONSTRAINT task_history_task_id_fkey FOREIGN KEY (task_id) REFERENCES tech_accounting.tasks(id);


--
-- TOC entry 3823 (class 2606 OID 109303)
-- Name: tasks tasks_deleted_by_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.tasks
    ADD CONSTRAINT tasks_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES tech_accounting.users(id);


--
-- TOC entry 3824 (class 2606 OID 109308)
-- Name: tasks tasks_executor_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.tasks
    ADD CONSTRAINT tasks_executor_id_fkey FOREIGN KEY (executor_id) REFERENCES tech_accounting.users(id);


--
-- TOC entry 3825 (class 2606 OID 109313)
-- Name: tasks tasks_requester_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.tasks
    ADD CONSTRAINT tasks_requester_id_fkey FOREIGN KEY (requester_id) REFERENCES tech_accounting.users(id);


--
-- TOC entry 3826 (class 2606 OID 109318)
-- Name: tasks tasks_status_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.tasks
    ADD CONSTRAINT tasks_status_id_fkey FOREIGN KEY (status_id) REFERENCES tech_accounting.dic_task_status(id);


--
-- TOC entry 3827 (class 2606 OID 109323)
-- Name: user_roles user_roles_assigned_by_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.user_roles
    ADD CONSTRAINT user_roles_assigned_by_fkey FOREIGN KEY (assigned_by) REFERENCES tech_accounting.users(id);


--
-- TOC entry 3828 (class 2606 OID 109328)
-- Name: user_roles user_roles_role_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.user_roles
    ADD CONSTRAINT user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES tech_accounting.roles(id);


--
-- TOC entry 3829 (class 2606 OID 109333)
-- Name: user_roles user_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.user_roles
    ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES tech_accounting.users(id);


--
-- TOC entry 3830 (class 2606 OID 109338)
-- Name: users users_created_by_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.users
    ADD CONSTRAINT users_created_by_id_fkey FOREIGN KEY (created_by_id) REFERENCES tech_accounting.users(id);


--
-- TOC entry 3831 (class 2606 OID 109343)
-- Name: users users_updated_by_id_fkey; Type: FK CONSTRAINT; Schema: tech_accounting; Owner: postgres
--

ALTER TABLE ONLY tech_accounting.users
    ADD CONSTRAINT users_updated_by_id_fkey FOREIGN KEY (updated_by_id) REFERENCES tech_accounting.users(id);


-- Completed on 2026-02-14 08:52:39 MSK

--
-- PostgreSQL database dump complete
--

\unrestrict usNVUbIh8pRPRrLgLLnOdMaXIMmlfMaEGqvNBag7v4gA3wgxCDdCVhaIskPoWPU

