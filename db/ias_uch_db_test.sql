--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.0

-- Started on 2026-02-12 10:47:00

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
-- TOC entry 262 (class 1255 OID 61769)
-- Name: prevent_update_delete(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.prevent_update_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    RAISE EXCEPTION 'Изменение и удаление записей запрещено для таблицы %', TG_TABLE_NAME;
END;
$$;


ALTER FUNCTION public.prevent_update_delete() OWNER TO postgres;

--
-- TOC entry 261 (class 1255 OID 61768)
-- Name: set_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.set_updated_at() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 256 (class 1259 OID 62231)
-- Name: audit_events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit_events (
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
    CONSTRAINT chk_audit_result_status CHECK (((result_status)::text = ANY ((ARRAY['success'::character varying, 'error'::character varying, 'denied'::character varying])::text[])))
);


ALTER TABLE public.audit_events OWNER TO postgres;

--
-- TOC entry 255 (class 1259 OID 62230)
-- Name: audit_events_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.audit_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.audit_events_id_seq OWNER TO postgres;

--
-- TOC entry 5247 (class 0 OID 0)
-- Dependencies: 255
-- Name: audit_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.audit_events_id_seq OWNED BY public.audit_events.id;


--
-- TOC entry 252 (class 1259 OID 62180)
-- Name: desk_attachments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.desk_attachments (
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


ALTER TABLE public.desk_attachments OWNER TO postgres;

--
-- TOC entry 251 (class 1259 OID 62179)
-- Name: desk_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.desk_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.desk_attachments_id_seq OWNER TO postgres;

--
-- TOC entry 5248 (class 0 OID 0)
-- Dependencies: 251
-- Name: desk_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.desk_attachments_id_seq OWNED BY public.desk_attachments.id;


--
-- TOC entry 230 (class 1259 OID 61908)
-- Name: dic_equipment_status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dic_equipment_status (
    id bigint NOT NULL,
    status_code character varying(50) NOT NULL,
    status_name character varying(100) NOT NULL,
    sort_order integer DEFAULT 100 NOT NULL,
    is_final boolean DEFAULT false NOT NULL,
    is_archived boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.dic_equipment_status OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 61907)
-- Name: dic_equipment_status_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dic_equipment_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dic_equipment_status_id_seq OWNER TO postgres;

--
-- TOC entry 5249 (class 0 OID 0)
-- Dependencies: 229
-- Name: dic_equipment_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dic_equipment_status_id_seq OWNED BY public.dic_equipment_status.id;


--
-- TOC entry 232 (class 1259 OID 61924)
-- Name: dic_task_status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dic_task_status (
    id bigint NOT NULL,
    status_code character varying(50) NOT NULL,
    status_name character varying(100) NOT NULL,
    sort_order integer DEFAULT 100 NOT NULL,
    is_final boolean DEFAULT false NOT NULL,
    is_archived boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.dic_task_status OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 61923)
-- Name: dic_task_status_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dic_task_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dic_task_status_id_seq OWNER TO postgres;

--
-- TOC entry 5250 (class 0 OID 0)
-- Dependencies: 231
-- Name: dic_task_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dic_task_status_id_seq OWNED BY public.dic_task_status.id;


--
-- TOC entry 242 (class 1259 OID 62033)
-- Name: equip_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.equip_history (
    id bigint NOT NULL,
    equipment_id bigint NOT NULL,
    event_type character varying(50) NOT NULL,
    old_value jsonb,
    new_value jsonb,
    changed_by bigint,
    changed_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    comment text,
    CONSTRAINT chk_equip_history_event_type CHECK (((event_type)::text = ANY ((ARRAY['create'::character varying, 'update'::character varying, 'move'::character varying, 'assign'::character varying, 'unassign'::character varying, 'status_change'::character varying, 'maintenance'::character varying, 'writeoff'::character varying, 'archive'::character varying, 'restore'::character varying])::text[])))
);


ALTER TABLE public.equip_history OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 62032)
-- Name: equip_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.equip_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.equip_history_id_seq OWNER TO postgres;

--
-- TOC entry 5251 (class 0 OID 0)
-- Dependencies: 241
-- Name: equip_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.equip_history_id_seq OWNED BY public.equip_history.id;


--
-- TOC entry 240 (class 1259 OID 61986)
-- Name: equipment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.equipment (
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


ALTER TABLE public.equipment OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 61985)
-- Name: equipment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.equipment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.equipment_id_seq OWNER TO postgres;

--
-- TOC entry 5252 (class 0 OID 0)
-- Dependencies: 239
-- Name: equipment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.equipment_id_seq OWNED BY public.equipment.id;


--
-- TOC entry 260 (class 1259 OID 62272)
-- Name: import_errors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.import_errors (
    id bigint NOT NULL,
    import_run_id bigint NOT NULL,
    row_number integer,
    error_code character varying(50),
    error_message text NOT NULL,
    raw_payload jsonb,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.import_errors OWNER TO postgres;

--
-- TOC entry 259 (class 1259 OID 62271)
-- Name: import_errors_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.import_errors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.import_errors_id_seq OWNER TO postgres;

--
-- TOC entry 5253 (class 0 OID 0)
-- Dependencies: 259
-- Name: import_errors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.import_errors_id_seq OWNED BY public.import_errors.id;


--
-- TOC entry 258 (class 1259 OID 62251)
-- Name: import_runs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.import_runs (
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
    CONSTRAINT chk_import_run_status CHECK (((run_status)::text = ANY ((ARRAY['running'::character varying, 'success'::character varying, 'error'::character varying, 'partial'::character varying])::text[])))
);


ALTER TABLE public.import_runs OWNER TO postgres;

--
-- TOC entry 257 (class 1259 OID 62250)
-- Name: import_runs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.import_runs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.import_runs_id_seq OWNER TO postgres;

--
-- TOC entry 5254 (class 0 OID 0)
-- Dependencies: 257
-- Name: import_runs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.import_runs_id_seq OWNED BY public.import_runs.id;


--
-- TOC entry 228 (class 1259 OID 61882)
-- Name: locations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.locations (
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
    CONSTRAINT chk_location_type CHECK (((location_type)::text = ANY ((ARRAY['кабинет'::character varying, 'склад'::character varying, 'серверная'::character varying, 'лаборатория'::character varying, 'другое'::character varying])::text[]))),
    CONSTRAINT chk_locations_name_not_empty CHECK ((length(TRIM(BOTH FROM name)) > 0))
);


ALTER TABLE public.locations OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 61881)
-- Name: locations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.locations_id_seq OWNER TO postgres;

--
-- TOC entry 5255 (class 0 OID 0)
-- Dependencies: 227
-- Name: locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.locations_id_seq OWNED BY public.locations.id;


--
-- TOC entry 238 (class 1259 OID 61970)
-- Name: nsi_change_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.nsi_change_log (
    id bigint NOT NULL,
    dictionary_name character varying(100) NOT NULL,
    record_id bigint NOT NULL,
    operation_type character varying(20) NOT NULL,
    old_value jsonb,
    new_value jsonb,
    changed_by bigint,
    changed_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_nsi_change_operation CHECK (((operation_type)::text = ANY ((ARRAY['insert'::character varying, 'update'::character varying, 'archive'::character varying, 'restore'::character varying, 'delete'::character varying])::text[])))
);


ALTER TABLE public.nsi_change_log OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 61969)
-- Name: nsi_change_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.nsi_change_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.nsi_change_log_id_seq OWNER TO postgres;

--
-- TOC entry 5256 (class 0 OID 0)
-- Dependencies: 237
-- Name: nsi_change_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.nsi_change_log_id_seq OWNED BY public.nsi_change_log.id;


--
-- TOC entry 244 (class 1259 OID 62055)
-- Name: part_char_values; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.part_char_values (
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


ALTER TABLE public.part_char_values OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 62054)
-- Name: part_char_values_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.part_char_values_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.part_char_values_id_seq OWNER TO postgres;

--
-- TOC entry 5257 (class 0 OID 0)
-- Dependencies: 243
-- Name: part_char_values_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.part_char_values_id_seq OWNED BY public.part_char_values.id;


--
-- TOC entry 220 (class 1259 OID 61788)
-- Name: permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.permissions (
    id bigint NOT NULL,
    perm_code character varying(100) NOT NULL,
    perm_name character varying(200) NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_permissions_perm_code_not_empty CHECK ((length(TRIM(BOTH FROM perm_code)) > 0)),
    CONSTRAINT chk_permissions_perm_name_not_empty CHECK ((length(TRIM(BOTH FROM perm_name)) > 0))
);


ALTER TABLE public.permissions OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 61787)
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.permissions_id_seq OWNER TO postgres;

--
-- TOC entry 5258 (class 0 OID 0)
-- Dependencies: 219
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.permissions_id_seq OWNED BY public.permissions.id;


--
-- TOC entry 226 (class 1259 OID 61857)
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.role_permissions (
    id bigint NOT NULL,
    role_id bigint NOT NULL,
    permission_id bigint NOT NULL,
    granted_by bigint,
    granted_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.role_permissions OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 61856)
-- Name: role_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.role_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.role_permissions_id_seq OWNER TO postgres;

--
-- TOC entry 5259 (class 0 OID 0)
-- Dependencies: 225
-- Name: role_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.role_permissions_id_seq OWNED BY public.role_permissions.id;


--
-- TOC entry 218 (class 1259 OID 61771)
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
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


ALTER TABLE public.roles OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 61770)
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_id_seq OWNER TO postgres;

--
-- TOC entry 5260 (class 0 OID 0)
-- Dependencies: 217
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- TOC entry 236 (class 1259 OID 61955)
-- Name: spr_chars; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.spr_chars (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    measurement_unit character varying(50),
    is_archived boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_spr_chars_name_not_empty CHECK ((length(TRIM(BOTH FROM name)) > 0))
);


ALTER TABLE public.spr_chars OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 61954)
-- Name: spr_chars_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.spr_chars_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.spr_chars_id_seq OWNER TO postgres;

--
-- TOC entry 5261 (class 0 OID 0)
-- Dependencies: 235
-- Name: spr_chars_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.spr_chars_id_seq OWNED BY public.spr_chars.id;


--
-- TOC entry 234 (class 1259 OID 61940)
-- Name: spr_parts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.spr_parts (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    is_archived boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_spr_parts_name_not_empty CHECK ((length(TRIM(BOTH FROM name)) > 0))
);


ALTER TABLE public.spr_parts OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 61939)
-- Name: spr_parts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.spr_parts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.spr_parts_id_seq OWNER TO postgres;

--
-- TOC entry 5262 (class 0 OID 0)
-- Dependencies: 233
-- Name: spr_parts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.spr_parts_id_seq OWNED BY public.spr_parts.id;


--
-- TOC entry 254 (class 1259 OID 62204)
-- Name: task_attachments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_attachments (
    id bigint NOT NULL,
    task_id bigint NOT NULL,
    attachment_id bigint NOT NULL,
    linked_by bigint,
    linked_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.task_attachments OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 62203)
-- Name: task_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.task_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.task_attachments_id_seq OWNER TO postgres;

--
-- TOC entry 5263 (class 0 OID 0)
-- Dependencies: 253
-- Name: task_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.task_attachments_id_seq OWNED BY public.task_attachments.id;


--
-- TOC entry 250 (class 1259 OID 62150)
-- Name: task_equipment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_equipment (
    id bigint NOT NULL,
    task_id bigint NOT NULL,
    equipment_id bigint NOT NULL,
    relation_type character varying(30) DEFAULT 'related'::character varying NOT NULL,
    is_primary boolean DEFAULT false NOT NULL,
    linked_by bigint,
    linked_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_task_equipment_relation_type CHECK (((relation_type)::text = ANY ((ARRAY['related'::character varying, 'affected'::character varying, 'requested_for'::character varying])::text[])))
);


ALTER TABLE public.task_equipment OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 62149)
-- Name: task_equipment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.task_equipment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.task_equipment_id_seq OWNER TO postgres;

--
-- TOC entry 5264 (class 0 OID 0)
-- Dependencies: 249
-- Name: task_equipment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.task_equipment_id_seq OWNED BY public.task_equipment.id;


--
-- TOC entry 248 (class 1259 OID 62129)
-- Name: task_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_history (
    id bigint NOT NULL,
    task_id bigint NOT NULL,
    field_name character varying(100) NOT NULL,
    old_value text,
    new_value text,
    changed_by bigint,
    changed_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    comment text
);


ALTER TABLE public.task_history OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 62128)
-- Name: task_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.task_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.task_history_id_seq OWNER TO postgres;

--
-- TOC entry 5265 (class 0 OID 0)
-- Dependencies: 247
-- Name: task_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.task_history_id_seq OWNED BY public.task_history.id;


--
-- TOC entry 246 (class 1259 OID 62090)
-- Name: tasks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tasks (
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
    CONSTRAINT chk_tasks_priority CHECK (((priority)::text = ANY ((ARRAY['low'::character varying, 'medium'::character varying, 'high'::character varying, 'critical'::character varying])::text[])))
);


ALTER TABLE public.tasks OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 62089)
-- Name: tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tasks_id_seq OWNER TO postgres;

--
-- TOC entry 5266 (class 0 OID 0)
-- Dependencies: 245
-- Name: tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tasks_id_seq OWNED BY public.tasks.id;


--
-- TOC entry 224 (class 1259 OID 61831)
-- Name: user_roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_roles (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    role_id bigint NOT NULL,
    assigned_by bigint,
    assigned_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    revoked_at timestamp with time zone,
    is_active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.user_roles OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 61830)
-- Name: user_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_roles_id_seq OWNER TO postgres;

--
-- TOC entry 5267 (class 0 OID 0)
-- Dependencies: 223
-- Name: user_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_roles_id_seq OWNED BY public.user_roles.id;


--
-- TOC entry 222 (class 1259 OID 61802)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
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


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 61801)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- TOC entry 5268 (class 0 OID 0)
-- Dependencies: 221
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 4873 (class 2604 OID 62234)
-- Name: audit_events id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_events ALTER COLUMN id SET DEFAULT nextval('public.audit_events_id_seq'::regclass);


--
-- TOC entry 4868 (class 2604 OID 62183)
-- Name: desk_attachments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.desk_attachments ALTER COLUMN id SET DEFAULT nextval('public.desk_attachments_id_seq'::regclass);


--
-- TOC entry 4825 (class 2604 OID 61911)
-- Name: dic_equipment_status id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dic_equipment_status ALTER COLUMN id SET DEFAULT nextval('public.dic_equipment_status_id_seq'::regclass);


--
-- TOC entry 4831 (class 2604 OID 61927)
-- Name: dic_task_status id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dic_task_status ALTER COLUMN id SET DEFAULT nextval('public.dic_task_status_id_seq'::regclass);


--
-- TOC entry 4852 (class 2604 OID 62036)
-- Name: equip_history id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equip_history ALTER COLUMN id SET DEFAULT nextval('public.equip_history_id_seq'::regclass);


--
-- TOC entry 4847 (class 2604 OID 61989)
-- Name: equipment id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipment ALTER COLUMN id SET DEFAULT nextval('public.equipment_id_seq'::regclass);


--
-- TOC entry 4881 (class 2604 OID 62275)
-- Name: import_errors id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.import_errors ALTER COLUMN id SET DEFAULT nextval('public.import_errors_id_seq'::regclass);


--
-- TOC entry 4875 (class 2604 OID 62254)
-- Name: import_runs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.import_runs ALTER COLUMN id SET DEFAULT nextval('public.import_runs_id_seq'::regclass);


--
-- TOC entry 4821 (class 2604 OID 61885)
-- Name: locations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.locations ALTER COLUMN id SET DEFAULT nextval('public.locations_id_seq'::regclass);


--
-- TOC entry 4845 (class 2604 OID 61973)
-- Name: nsi_change_log id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nsi_change_log ALTER COLUMN id SET DEFAULT nextval('public.nsi_change_log_id_seq'::regclass);


--
-- TOC entry 4854 (class 2604 OID 62058)
-- Name: part_char_values id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.part_char_values ALTER COLUMN id SET DEFAULT nextval('public.part_char_values_id_seq'::regclass);


--
-- TOC entry 4807 (class 2604 OID 61791)
-- Name: permissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissions ALTER COLUMN id SET DEFAULT nextval('public.permissions_id_seq'::regclass);


--
-- TOC entry 4819 (class 2604 OID 61860)
-- Name: role_permissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permissions ALTER COLUMN id SET DEFAULT nextval('public.role_permissions_id_seq'::regclass);


--
-- TOC entry 4802 (class 2604 OID 61774)
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- TOC entry 4841 (class 2604 OID 61958)
-- Name: spr_chars id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spr_chars ALTER COLUMN id SET DEFAULT nextval('public.spr_chars_id_seq'::regclass);


--
-- TOC entry 4837 (class 2604 OID 61943)
-- Name: spr_parts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spr_parts ALTER COLUMN id SET DEFAULT nextval('public.spr_parts_id_seq'::regclass);


--
-- TOC entry 4871 (class 2604 OID 62207)
-- Name: task_attachments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_attachments ALTER COLUMN id SET DEFAULT nextval('public.task_attachments_id_seq'::regclass);


--
-- TOC entry 4864 (class 2604 OID 62153)
-- Name: task_equipment id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_equipment ALTER COLUMN id SET DEFAULT nextval('public.task_equipment_id_seq'::regclass);


--
-- TOC entry 4862 (class 2604 OID 62132)
-- Name: task_history id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_history ALTER COLUMN id SET DEFAULT nextval('public.task_history_id_seq'::regclass);


--
-- TOC entry 4857 (class 2604 OID 62093)
-- Name: tasks id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks ALTER COLUMN id SET DEFAULT nextval('public.tasks_id_seq'::regclass);


--
-- TOC entry 4816 (class 2604 OID 61834)
-- Name: user_roles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles ALTER COLUMN id SET DEFAULT nextval('public.user_roles_id_seq'::regclass);


--
-- TOC entry 4809 (class 2604 OID 61805)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 5237 (class 0 OID 62231)
-- Dependencies: 256
-- Data for Name: audit_events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audit_events (id, event_time, actor_id, action_type, object_type, object_id, result_status, source_ip, user_agent, request_id, correlation_id, payload, error_message) FROM stdin;
\.


--
-- TOC entry 5233 (class 0 OID 62180)
-- Dependencies: 252
-- Data for Name: desk_attachments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.desk_attachments (id, storage_path, original_name, file_extension, mime_type, size_bytes, checksum_sha256, uploaded_by, uploaded_at, is_deleted, deleted_at, deleted_by) FROM stdin;
\.


--
-- TOC entry 5211 (class 0 OID 61908)
-- Dependencies: 230
-- Data for Name: dic_equipment_status; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dic_equipment_status (id, status_code, status_name, sort_order, is_final, is_archived, created_at, updated_at) FROM stdin;
1	in_use	В эксплуатации	10	f	f	2026-02-10 17:05:48.397764+03	2026-02-10 17:05:48.397764+03
2	in_stock	На складе	20	f	f	2026-02-10 17:05:48.397764+03	2026-02-10 17:05:48.397764+03
3	in_repair	В ремонте	30	f	f	2026-02-10 17:05:48.397764+03	2026-02-10 17:05:48.397764+03
4	writeoff	Списано	40	t	f	2026-02-10 17:05:48.397764+03	2026-02-10 17:05:48.397764+03
5	archived	В архиве	50	t	f	2026-02-10 17:05:48.397764+03	2026-02-10 17:05:48.397764+03
\.


--
-- TOC entry 5213 (class 0 OID 61924)
-- Dependencies: 232
-- Data for Name: dic_task_status; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dic_task_status (id, status_code, status_name, sort_order, is_final, is_archived, created_at, updated_at) FROM stdin;
1	new	Новая	10	f	f	2026-02-10 17:05:48.397764+03	2026-02-10 17:05:48.397764+03
2	in_progress	В работе	20	f	f	2026-02-10 17:05:48.397764+03	2026-02-10 17:05:48.397764+03
3	on_hold	На паузе	30	f	f	2026-02-10 17:05:48.397764+03	2026-02-10 17:05:48.397764+03
4	resolved	Решена	40	t	f	2026-02-10 17:05:48.397764+03	2026-02-10 17:05:48.397764+03
5	closed	Закрыта	50	t	f	2026-02-10 17:05:48.397764+03	2026-02-10 17:05:48.397764+03
6	cancelled	Отменена	60	t	f	2026-02-10 17:05:48.397764+03	2026-02-10 17:05:48.397764+03
\.


--
-- TOC entry 5223 (class 0 OID 62033)
-- Dependencies: 242
-- Data for Name: equip_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.equip_history (id, equipment_id, event_type, old_value, new_value, changed_by, changed_at, comment) FROM stdin;
\.


--
-- TOC entry 5221 (class 0 OID 61986)
-- Dependencies: 240
-- Data for Name: equipment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.equipment (id, inventory_number, serial_number, name, equipment_type, status_id, responsible_user_id, location_id, supplier, purchase_date, commissioning_date, warranty_until, description, archived_at, archive_reason, is_archived, is_deleted, created_by_id, updated_by_id, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5241 (class 0 OID 62272)
-- Dependencies: 260
-- Data for Name: import_errors; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.import_errors (id, import_run_id, row_number, error_code, error_message, raw_payload, created_at) FROM stdin;
\.


--
-- TOC entry 5239 (class 0 OID 62251)
-- Dependencies: 258
-- Data for Name: import_runs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.import_runs (id, source_type, source_name, started_at, finished_at, total_rows, success_rows, error_rows, run_status, initiated_by, details) FROM stdin;
\.


--
-- TOC entry 5209 (class 0 OID 61882)
-- Dependencies: 228
-- Data for Name: locations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.locations (id, location_code, name, location_type, floor, description, is_archived, created_by_id, updated_by_id, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5219 (class 0 OID 61970)
-- Dependencies: 238
-- Data for Name: nsi_change_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.nsi_change_log (id, dictionary_name, record_id, operation_type, old_value, new_value, changed_by, changed_at) FROM stdin;
\.


--
-- TOC entry 5225 (class 0 OID 62055)
-- Dependencies: 244
-- Data for Name: part_char_values; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.part_char_values (id, equipment_id, part_id, char_id, value_text, value_num, source, updated_by, updated_at) FROM stdin;
\.


--
-- TOC entry 5201 (class 0 OID 61788)
-- Dependencies: 220
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.permissions (id, perm_code, perm_name, description, created_at) FROM stdin;
\.


--
-- TOC entry 5207 (class 0 OID 61857)
-- Dependencies: 226
-- Data for Name: role_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.role_permissions (id, role_id, permission_id, granted_by, granted_at) FROM stdin;
\.


--
-- TOC entry 5199 (class 0 OID 61771)
-- Dependencies: 218
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (id, role_code, role_name, description, is_system, is_archived, created_at, updated_at) FROM stdin;
1	admin	Администратор	Полный доступ к данным и настройкам	t	f	2026-02-10 17:05:48.397764+03	2026-02-10 17:05:48.397764+03
2	operator	Оператор	Обработка и сопровождение заявок	t	f	2026-02-10 17:05:48.397764+03	2026-02-10 17:05:48.397764+03
3	user	Пользователь	Создание и просмотр собственных заявок	t	f	2026-02-10 17:05:48.397764+03	2026-02-10 17:05:48.397764+03
\.


--
-- TOC entry 5217 (class 0 OID 61955)
-- Dependencies: 236
-- Data for Name: spr_chars; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.spr_chars (id, name, description, measurement_unit, is_archived, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5215 (class 0 OID 61940)
-- Dependencies: 234
-- Data for Name: spr_parts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.spr_parts (id, name, description, is_archived, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5235 (class 0 OID 62204)
-- Dependencies: 254
-- Data for Name: task_attachments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_attachments (id, task_id, attachment_id, linked_by, linked_at) FROM stdin;
\.


--
-- TOC entry 5231 (class 0 OID 62150)
-- Dependencies: 250
-- Data for Name: task_equipment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_equipment (id, task_id, equipment_id, relation_type, is_primary, linked_by, linked_at) FROM stdin;
\.


--
-- TOC entry 5229 (class 0 OID 62129)
-- Dependencies: 248
-- Data for Name: task_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_history (id, task_id, field_name, old_value, new_value, changed_by, changed_at, comment) FROM stdin;
\.


--
-- TOC entry 5227 (class 0 OID 62090)
-- Dependencies: 246
-- Data for Name: tasks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tasks (id, task_number, title, description, status_id, requester_id, executor_id, priority, due_at, closed_at, comment, attachments_legacy, is_deleted, deleted_at, deleted_by, delete_reason, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5205 (class 0 OID 61831)
-- Dependencies: 224
-- Data for Name: user_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_roles (id, user_id, role_id, assigned_by, assigned_at, revoked_at, is_active) FROM stdin;
\.


--
-- TOC entry 5203 (class 0 OID 61802)
-- Dependencies: 222
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, full_name, "position", department, email, phone, password_hash, is_active, is_locked, failed_login_attempts, lock_until, password_changed_at, last_login_at, created_by_id, updated_by_id, created_at, updated_at, is_deleted) FROM stdin;
\.


--
-- TOC entry 5269 (class 0 OID 0)
-- Dependencies: 255
-- Name: audit_events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.audit_events_id_seq', 1, false);


--
-- TOC entry 5270 (class 0 OID 0)
-- Dependencies: 251
-- Name: desk_attachments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.desk_attachments_id_seq', 1, false);


--
-- TOC entry 5271 (class 0 OID 0)
-- Dependencies: 229
-- Name: dic_equipment_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dic_equipment_status_id_seq', 5, true);


--
-- TOC entry 5272 (class 0 OID 0)
-- Dependencies: 231
-- Name: dic_task_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dic_task_status_id_seq', 6, true);


--
-- TOC entry 5273 (class 0 OID 0)
-- Dependencies: 241
-- Name: equip_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.equip_history_id_seq', 1, false);


--
-- TOC entry 5274 (class 0 OID 0)
-- Dependencies: 239
-- Name: equipment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.equipment_id_seq', 1, false);


--
-- TOC entry 5275 (class 0 OID 0)
-- Dependencies: 259
-- Name: import_errors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.import_errors_id_seq', 1, false);


--
-- TOC entry 5276 (class 0 OID 0)
-- Dependencies: 257
-- Name: import_runs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.import_runs_id_seq', 1, false);


--
-- TOC entry 5277 (class 0 OID 0)
-- Dependencies: 227
-- Name: locations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.locations_id_seq', 1, false);


--
-- TOC entry 5278 (class 0 OID 0)
-- Dependencies: 237
-- Name: nsi_change_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.nsi_change_log_id_seq', 1, false);


--
-- TOC entry 5279 (class 0 OID 0)
-- Dependencies: 243
-- Name: part_char_values_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.part_char_values_id_seq', 1, false);


--
-- TOC entry 5280 (class 0 OID 0)
-- Dependencies: 219
-- Name: permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.permissions_id_seq', 1, false);


--
-- TOC entry 5281 (class 0 OID 0)
-- Dependencies: 225
-- Name: role_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.role_permissions_id_seq', 1, false);


--
-- TOC entry 5282 (class 0 OID 0)
-- Dependencies: 217
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roles_id_seq', 3, true);


--
-- TOC entry 5283 (class 0 OID 0)
-- Dependencies: 235
-- Name: spr_chars_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.spr_chars_id_seq', 1, false);


--
-- TOC entry 5284 (class 0 OID 0)
-- Dependencies: 233
-- Name: spr_parts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.spr_parts_id_seq', 1, false);


--
-- TOC entry 5285 (class 0 OID 0)
-- Dependencies: 253
-- Name: task_attachments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.task_attachments_id_seq', 1, false);


--
-- TOC entry 5286 (class 0 OID 0)
-- Dependencies: 249
-- Name: task_equipment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.task_equipment_id_seq', 1, false);


--
-- TOC entry 5287 (class 0 OID 0)
-- Dependencies: 247
-- Name: task_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.task_history_id_seq', 1, false);


--
-- TOC entry 5288 (class 0 OID 0)
-- Dependencies: 245
-- Name: tasks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tasks_id_seq', 1, false);


--
-- TOC entry 5289 (class 0 OID 0)
-- Dependencies: 223
-- Name: user_roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_roles_id_seq', 1, false);


--
-- TOC entry 5290 (class 0 OID 0)
-- Dependencies: 221
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 1, false);


--
-- TOC entry 4994 (class 2606 OID 62240)
-- Name: audit_events audit_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_events
    ADD CONSTRAINT audit_events_pkey PRIMARY KEY (id);


--
-- TOC entry 4984 (class 2606 OID 62190)
-- Name: desk_attachments desk_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.desk_attachments
    ADD CONSTRAINT desk_attachments_pkey PRIMARY KEY (id);


--
-- TOC entry 4928 (class 2606 OID 61918)
-- Name: dic_equipment_status dic_equipment_status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dic_equipment_status
    ADD CONSTRAINT dic_equipment_status_pkey PRIMARY KEY (id);


--
-- TOC entry 4930 (class 2606 OID 61920)
-- Name: dic_equipment_status dic_equipment_status_status_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dic_equipment_status
    ADD CONSTRAINT dic_equipment_status_status_code_key UNIQUE (status_code);


--
-- TOC entry 4932 (class 2606 OID 61922)
-- Name: dic_equipment_status dic_equipment_status_status_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dic_equipment_status
    ADD CONSTRAINT dic_equipment_status_status_name_key UNIQUE (status_name);


--
-- TOC entry 4934 (class 2606 OID 61934)
-- Name: dic_task_status dic_task_status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dic_task_status
    ADD CONSTRAINT dic_task_status_pkey PRIMARY KEY (id);


--
-- TOC entry 4936 (class 2606 OID 61936)
-- Name: dic_task_status dic_task_status_status_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dic_task_status
    ADD CONSTRAINT dic_task_status_status_code_key UNIQUE (status_code);


--
-- TOC entry 4938 (class 2606 OID 61938)
-- Name: dic_task_status dic_task_status_status_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dic_task_status
    ADD CONSTRAINT dic_task_status_status_name_key UNIQUE (status_name);


--
-- TOC entry 4959 (class 2606 OID 62042)
-- Name: equip_history equip_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equip_history
    ADD CONSTRAINT equip_history_pkey PRIMARY KEY (id);


--
-- TOC entry 4950 (class 2606 OID 61999)
-- Name: equipment equipment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_pkey PRIMARY KEY (id);


--
-- TOC entry 5003 (class 2606 OID 62280)
-- Name: import_errors import_errors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.import_errors
    ADD CONSTRAINT import_errors_pkey PRIMARY KEY (id);


--
-- TOC entry 5000 (class 2606 OID 62265)
-- Name: import_runs import_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.import_runs
    ADD CONSTRAINT import_runs_pkey PRIMARY KEY (id);


--
-- TOC entry 4924 (class 2606 OID 61896)
-- Name: locations locations_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_name_key UNIQUE (name);


--
-- TOC entry 4926 (class 2606 OID 61894)
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- TOC entry 4948 (class 2606 OID 61979)
-- Name: nsi_change_log nsi_change_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nsi_change_log
    ADD CONSTRAINT nsi_change_log_pkey PRIMARY KEY (id);


--
-- TOC entry 4964 (class 2606 OID 62066)
-- Name: part_char_values part_char_values_equipment_id_part_id_char_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.part_char_values
    ADD CONSTRAINT part_char_values_equipment_id_part_id_char_id_key UNIQUE (equipment_id, part_id, char_id);


--
-- TOC entry 4966 (class 2606 OID 62064)
-- Name: part_char_values part_char_values_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.part_char_values
    ADD CONSTRAINT part_char_values_pkey PRIMARY KEY (id);


--
-- TOC entry 4908 (class 2606 OID 61800)
-- Name: permissions permissions_perm_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_perm_code_key UNIQUE (perm_code);


--
-- TOC entry 4910 (class 2606 OID 61798)
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- TOC entry 4920 (class 2606 OID 61863)
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (id);


--
-- TOC entry 4922 (class 2606 OID 61865)
-- Name: role_permissions role_permissions_role_id_permission_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_role_id_permission_id_key UNIQUE (role_id, permission_id);


--
-- TOC entry 4904 (class 2606 OID 61784)
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- TOC entry 4906 (class 2606 OID 61786)
-- Name: roles roles_role_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_role_code_key UNIQUE (role_code);


--
-- TOC entry 4944 (class 2606 OID 61968)
-- Name: spr_chars spr_chars_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spr_chars
    ADD CONSTRAINT spr_chars_name_key UNIQUE (name);


--
-- TOC entry 4946 (class 2606 OID 61966)
-- Name: spr_chars spr_chars_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spr_chars
    ADD CONSTRAINT spr_chars_pkey PRIMARY KEY (id);


--
-- TOC entry 4940 (class 2606 OID 61953)
-- Name: spr_parts spr_parts_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spr_parts
    ADD CONSTRAINT spr_parts_name_key UNIQUE (name);


--
-- TOC entry 4942 (class 2606 OID 61951)
-- Name: spr_parts spr_parts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spr_parts
    ADD CONSTRAINT spr_parts_pkey PRIMARY KEY (id);


--
-- TOC entry 4990 (class 2606 OID 62210)
-- Name: task_attachments task_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_attachments
    ADD CONSTRAINT task_attachments_pkey PRIMARY KEY (id);


--
-- TOC entry 4992 (class 2606 OID 62212)
-- Name: task_attachments task_attachments_task_id_attachment_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_attachments
    ADD CONSTRAINT task_attachments_task_id_attachment_id_key UNIQUE (task_id, attachment_id);


--
-- TOC entry 4980 (class 2606 OID 62159)
-- Name: task_equipment task_equipment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_equipment
    ADD CONSTRAINT task_equipment_pkey PRIMARY KEY (id);


--
-- TOC entry 4982 (class 2606 OID 62161)
-- Name: task_equipment task_equipment_task_id_equipment_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_equipment
    ADD CONSTRAINT task_equipment_task_id_equipment_id_key UNIQUE (task_id, equipment_id);


--
-- TOC entry 4976 (class 2606 OID 62137)
-- Name: task_history task_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_history
    ADD CONSTRAINT task_history_pkey PRIMARY KEY (id);


--
-- TOC entry 4971 (class 2606 OID 62102)
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- TOC entry 4973 (class 2606 OID 62104)
-- Name: tasks tasks_task_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_task_number_key UNIQUE (task_number);


--
-- TOC entry 4956 (class 2606 OID 62001)
-- Name: equipment uq_equipment_inventory_number; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT uq_equipment_inventory_number UNIQUE (inventory_number);


--
-- TOC entry 4916 (class 2606 OID 61838)
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);


--
-- TOC entry 4918 (class 2606 OID 61840)
-- Name: user_roles user_roles_user_id_role_id_is_active_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_user_id_role_id_is_active_key UNIQUE (user_id, role_id, is_active);


--
-- TOC entry 4912 (class 2606 OID 61817)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4914 (class 2606 OID 61819)
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- TOC entry 4995 (class 1259 OID 62249)
-- Name: idx_audit_events_action; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_events_action ON public.audit_events USING btree (action_type, result_status);


--
-- TOC entry 4996 (class 1259 OID 62247)
-- Name: idx_audit_events_actor_time; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_events_actor_time ON public.audit_events USING btree (actor_id, event_time DESC);


--
-- TOC entry 4997 (class 1259 OID 62246)
-- Name: idx_audit_events_event_time; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_events_event_time ON public.audit_events USING btree (event_time DESC);


--
-- TOC entry 4998 (class 1259 OID 62248)
-- Name: idx_audit_events_object; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_events_object ON public.audit_events USING btree (object_type, object_id);


--
-- TOC entry 4985 (class 1259 OID 62201)
-- Name: idx_desk_attachments_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_desk_attachments_name ON public.desk_attachments USING btree (original_name);


--
-- TOC entry 4986 (class 1259 OID 62202)
-- Name: idx_desk_attachments_uploaded_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_desk_attachments_uploaded_at ON public.desk_attachments USING btree (uploaded_at DESC);


--
-- TOC entry 4960 (class 1259 OID 62053)
-- Name: idx_equip_history_equipment_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_equip_history_equipment_date ON public.equip_history USING btree (equipment_id, changed_at DESC);


--
-- TOC entry 4951 (class 1259 OID 62031)
-- Name: idx_equipment_filters_responsible; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_equipment_filters_responsible ON public.equipment USING btree (responsible_user_id, is_archived, is_deleted);


--
-- TOC entry 4952 (class 1259 OID 62030)
-- Name: idx_equipment_filters_status_location; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_equipment_filters_status_location ON public.equipment USING btree (status_id, location_id, is_archived, is_deleted);


--
-- TOC entry 4953 (class 1259 OID 62029)
-- Name: idx_equipment_search_inventory; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_equipment_search_inventory ON public.equipment USING btree (inventory_number);


--
-- TOC entry 4954 (class 1259 OID 62028)
-- Name: idx_equipment_search_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_equipment_search_name ON public.equipment USING btree (lower((name)::text));


--
-- TOC entry 5001 (class 1259 OID 62286)
-- Name: idx_import_errors_run_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_import_errors_run_id ON public.import_errors USING btree (import_run_id);


--
-- TOC entry 4961 (class 1259 OID 62087)
-- Name: idx_part_char_values_equipment; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_part_char_values_equipment ON public.part_char_values USING btree (equipment_id);


--
-- TOC entry 4962 (class 1259 OID 62088)
-- Name: idx_part_char_values_part_char; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_part_char_values_part_char ON public.part_char_values USING btree (part_id, char_id);


--
-- TOC entry 4987 (class 1259 OID 62229)
-- Name: idx_task_attachments_attachment; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_attachments_attachment ON public.task_attachments USING btree (attachment_id);


--
-- TOC entry 4988 (class 1259 OID 62228)
-- Name: idx_task_attachments_task; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_attachments_task ON public.task_attachments USING btree (task_id);


--
-- TOC entry 4977 (class 1259 OID 62178)
-- Name: idx_task_equipment_equipment; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_equipment_equipment ON public.task_equipment USING btree (equipment_id);


--
-- TOC entry 4978 (class 1259 OID 62177)
-- Name: idx_task_equipment_task; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_equipment_task ON public.task_equipment USING btree (task_id);


--
-- TOC entry 4974 (class 1259 OID 62148)
-- Name: idx_task_history_task_changed; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_history_task_changed ON public.task_history USING btree (task_id, changed_at DESC);


--
-- TOC entry 4967 (class 1259 OID 62126)
-- Name: idx_tasks_executor; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tasks_executor ON public.tasks USING btree (executor_id, created_at DESC);


--
-- TOC entry 4968 (class 1259 OID 62127)
-- Name: idx_tasks_requester; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tasks_requester ON public.tasks USING btree (requester_id, created_at DESC);


--
-- TOC entry 4969 (class 1259 OID 62125)
-- Name: idx_tasks_status_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tasks_status_created ON public.tasks USING btree (status_id, created_at DESC);


--
-- TOC entry 4957 (class 1259 OID 62027)
-- Name: uq_equipment_serial_number_not_null; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX uq_equipment_serial_number_not_null ON public.equipment USING btree (serial_number) WHERE (serial_number IS NOT NULL);


--
-- TOC entry 5052 (class 2620 OID 62296)
-- Name: audit_events trg_audit_events_immutable; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_audit_events_immutable BEFORE DELETE OR UPDATE ON public.audit_events FOR EACH ROW EXECUTE FUNCTION public.prevent_update_delete();


--
-- TOC entry 5046 (class 2620 OID 62290)
-- Name: dic_equipment_status trg_dic_equipment_status_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_dic_equipment_status_set_updated_at BEFORE UPDATE ON public.dic_equipment_status FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 5047 (class 2620 OID 62291)
-- Name: dic_task_status trg_dic_task_status_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_dic_task_status_set_updated_at BEFORE UPDATE ON public.dic_task_status FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 5050 (class 2620 OID 62294)
-- Name: equipment trg_equipment_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_equipment_set_updated_at BEFORE UPDATE ON public.equipment FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 5045 (class 2620 OID 62289)
-- Name: locations trg_locations_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_locations_set_updated_at BEFORE UPDATE ON public.locations FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 5043 (class 2620 OID 62287)
-- Name: roles trg_roles_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_roles_set_updated_at BEFORE UPDATE ON public.roles FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 5049 (class 2620 OID 62293)
-- Name: spr_chars trg_spr_chars_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_spr_chars_set_updated_at BEFORE UPDATE ON public.spr_chars FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 5048 (class 2620 OID 62292)
-- Name: spr_parts trg_spr_parts_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_spr_parts_set_updated_at BEFORE UPDATE ON public.spr_parts FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 5051 (class 2620 OID 62295)
-- Name: tasks trg_tasks_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_tasks_set_updated_at BEFORE UPDATE ON public.tasks FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 5044 (class 2620 OID 62288)
-- Name: users trg_users_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_users_set_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 5040 (class 2606 OID 62241)
-- Name: audit_events audit_events_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_events
    ADD CONSTRAINT audit_events_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.users(id);


--
-- TOC entry 5035 (class 2606 OID 62196)
-- Name: desk_attachments desk_attachments_deleted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.desk_attachments
    ADD CONSTRAINT desk_attachments_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- TOC entry 5036 (class 2606 OID 62191)
-- Name: desk_attachments desk_attachments_uploaded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.desk_attachments
    ADD CONSTRAINT desk_attachments_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES public.users(id);


--
-- TOC entry 5020 (class 2606 OID 62048)
-- Name: equip_history equip_history_changed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equip_history
    ADD CONSTRAINT equip_history_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES public.users(id);


--
-- TOC entry 5021 (class 2606 OID 62043)
-- Name: equip_history equip_history_equipment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equip_history
    ADD CONSTRAINT equip_history_equipment_id_fkey FOREIGN KEY (equipment_id) REFERENCES public.equipment(id);


--
-- TOC entry 5015 (class 2606 OID 62017)
-- Name: equipment equipment_created_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_created_by_id_fkey FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- TOC entry 5016 (class 2606 OID 62012)
-- Name: equipment equipment_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- TOC entry 5017 (class 2606 OID 62007)
-- Name: equipment equipment_responsible_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_responsible_user_id_fkey FOREIGN KEY (responsible_user_id) REFERENCES public.users(id);


--
-- TOC entry 5018 (class 2606 OID 62002)
-- Name: equipment equipment_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.dic_equipment_status(id);


--
-- TOC entry 5019 (class 2606 OID 62022)
-- Name: equipment equipment_updated_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_updated_by_id_fkey FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- TOC entry 5042 (class 2606 OID 62281)
-- Name: import_errors import_errors_import_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.import_errors
    ADD CONSTRAINT import_errors_import_run_id_fkey FOREIGN KEY (import_run_id) REFERENCES public.import_runs(id);


--
-- TOC entry 5041 (class 2606 OID 62266)
-- Name: import_runs import_runs_initiated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.import_runs
    ADD CONSTRAINT import_runs_initiated_by_fkey FOREIGN KEY (initiated_by) REFERENCES public.users(id);


--
-- TOC entry 5012 (class 2606 OID 61897)
-- Name: locations locations_created_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_created_by_id_fkey FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- TOC entry 5013 (class 2606 OID 61902)
-- Name: locations locations_updated_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_updated_by_id_fkey FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- TOC entry 5014 (class 2606 OID 61980)
-- Name: nsi_change_log nsi_change_log_changed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nsi_change_log
    ADD CONSTRAINT nsi_change_log_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES public.users(id);


--
-- TOC entry 5022 (class 2606 OID 62077)
-- Name: part_char_values part_char_values_char_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.part_char_values
    ADD CONSTRAINT part_char_values_char_id_fkey FOREIGN KEY (char_id) REFERENCES public.spr_chars(id);


--
-- TOC entry 5023 (class 2606 OID 62067)
-- Name: part_char_values part_char_values_equipment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.part_char_values
    ADD CONSTRAINT part_char_values_equipment_id_fkey FOREIGN KEY (equipment_id) REFERENCES public.equipment(id);


--
-- TOC entry 5024 (class 2606 OID 62072)
-- Name: part_char_values part_char_values_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.part_char_values
    ADD CONSTRAINT part_char_values_part_id_fkey FOREIGN KEY (part_id) REFERENCES public.spr_parts(id);


--
-- TOC entry 5025 (class 2606 OID 62082)
-- Name: part_char_values part_char_values_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.part_char_values
    ADD CONSTRAINT part_char_values_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- TOC entry 5009 (class 2606 OID 61876)
-- Name: role_permissions role_permissions_granted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_granted_by_fkey FOREIGN KEY (granted_by) REFERENCES public.users(id);


--
-- TOC entry 5010 (class 2606 OID 61871)
-- Name: role_permissions role_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.permissions(id);


--
-- TOC entry 5011 (class 2606 OID 61866)
-- Name: role_permissions role_permissions_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- TOC entry 5037 (class 2606 OID 62218)
-- Name: task_attachments task_attachments_attachment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_attachments
    ADD CONSTRAINT task_attachments_attachment_id_fkey FOREIGN KEY (attachment_id) REFERENCES public.desk_attachments(id);


--
-- TOC entry 5038 (class 2606 OID 62223)
-- Name: task_attachments task_attachments_linked_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_attachments
    ADD CONSTRAINT task_attachments_linked_by_fkey FOREIGN KEY (linked_by) REFERENCES public.users(id);


--
-- TOC entry 5039 (class 2606 OID 62213)
-- Name: task_attachments task_attachments_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_attachments
    ADD CONSTRAINT task_attachments_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id);


--
-- TOC entry 5032 (class 2606 OID 62167)
-- Name: task_equipment task_equipment_equipment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_equipment
    ADD CONSTRAINT task_equipment_equipment_id_fkey FOREIGN KEY (equipment_id) REFERENCES public.equipment(id);


--
-- TOC entry 5033 (class 2606 OID 62172)
-- Name: task_equipment task_equipment_linked_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_equipment
    ADD CONSTRAINT task_equipment_linked_by_fkey FOREIGN KEY (linked_by) REFERENCES public.users(id);


--
-- TOC entry 5034 (class 2606 OID 62162)
-- Name: task_equipment task_equipment_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_equipment
    ADD CONSTRAINT task_equipment_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id);


--
-- TOC entry 5030 (class 2606 OID 62143)
-- Name: task_history task_history_changed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_history
    ADD CONSTRAINT task_history_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES public.users(id);


--
-- TOC entry 5031 (class 2606 OID 62138)
-- Name: task_history task_history_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_history
    ADD CONSTRAINT task_history_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id);


--
-- TOC entry 5026 (class 2606 OID 62120)
-- Name: tasks tasks_deleted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- TOC entry 5027 (class 2606 OID 62115)
-- Name: tasks tasks_executor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_executor_id_fkey FOREIGN KEY (executor_id) REFERENCES public.users(id);


--
-- TOC entry 5028 (class 2606 OID 62110)
-- Name: tasks tasks_requester_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_requester_id_fkey FOREIGN KEY (requester_id) REFERENCES public.users(id);


--
-- TOC entry 5029 (class 2606 OID 62105)
-- Name: tasks tasks_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.dic_task_status(id);


--
-- TOC entry 5006 (class 2606 OID 61851)
-- Name: user_roles user_roles_assigned_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_assigned_by_fkey FOREIGN KEY (assigned_by) REFERENCES public.users(id);


--
-- TOC entry 5007 (class 2606 OID 61846)
-- Name: user_roles user_roles_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- TOC entry 5008 (class 2606 OID 61841)
-- Name: user_roles user_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 5004 (class 2606 OID 61820)
-- Name: users users_created_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_created_by_id_fkey FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- TOC entry 5005 (class 2606 OID 61825)
-- Name: users users_updated_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_updated_by_id_fkey FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


-- Completed on 2026-02-12 10:47:01

--
-- PostgreSQL database dump complete
--

