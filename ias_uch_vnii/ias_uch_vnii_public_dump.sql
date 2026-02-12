--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.0

-- Started on 2025-10-27 16:29:12

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
--



--
--


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 319 (class 1259 OID 52888)
-- Name: arm; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.arm (
    id_arm integer NOT NULL,
    name character varying(200) NOT NULL,
    id_user integer,
    id_location integer NOT NULL,
    description text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public.arm OWNER TO postgres;

--
-- TOC entry 323 (class 1259 OID 52969)
-- Name: arm_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.arm_history (
    id_history integer NOT NULL,
    id_arm integer NOT NULL,
    changed_by integer,
    change_type character varying(50) NOT NULL,
    old_value text,
    new_value text,
    change_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    comment text
);

ALTER TABLE public.arm_history OWNER TO postgres;

--
-- TOC entry 322 (class 1259 OID 52968)
-- Name: arm_history_id_history_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.arm_history_id_history_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.arm_history_id_history_seq OWNER TO postgres;

--
-- TOC entry 5181 (class 0 OID 0)
-- Dependencies: 322
-- Name: arm_history_id_history_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.arm_history_id_history_seq OWNED BY public.arm_history.id_history;

--
-- TOC entry 318 (class 1259 OID 52887)
-- Name: arm_id_arm_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.arm_id_arm_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.arm_id_arm_seq OWNER TO postgres;

--
-- TOC entry 5182 (class 0 OID 0)
-- Dependencies: 318
-- Name: arm_id_arm_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.arm_id_arm_seq OWNED BY public.arm.id_arm;

--
-- TOC entry 329 (class 1259 OID 53032)
-- Name: desk_attachments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.desk_attachments (
    attach_id integer NOT NULL,
    path character varying(500) NOT NULL,
    name character varying(255) NOT NULL,
    extension character varying(10) NOT NULL,
    created_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public.desk_attachments OWNER TO postgres;

--
-- TOC entry 5183 (class 0 OID 0)
-- Dependencies: 329
-- Name: COLUMN desk_attachments.path; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.desk_attachments.path IS 'Путь к файлу';

--
-- TOC entry 5184 (class 0 OID 0)
-- Dependencies: 329
-- Name: COLUMN desk_attachments.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.desk_attachments.name IS 'Имя файла';

--
-- TOC entry 5185 (class 0 OID 0)
-- Dependencies: 329
-- Name: COLUMN desk_attachments.extension; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.desk_attachments.extension IS 'Расширение файла';

--
-- TOC entry 5186 (class 0 OID 0)
-- Dependencies: 329
-- Name: COLUMN desk_attachments.created_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.desk_attachments.created_at IS 'Дата создания';

--
-- TOC entry 328 (class 1259 OID 53031)
-- Name: desk_attachments_attach_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.desk_attachments_attach_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.desk_attachments_attach_id_seq OWNER TO postgres;

--
-- TOC entry 5187 (class 0 OID 0)
-- Dependencies: 328
-- Name: desk_attachments_attach_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.desk_attachments_attach_id_seq OWNED BY public.desk_attachments.attach_id;

--
-- TOC entry 331 (class 1259 OID 53043)
-- Name: dic_task_status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dic_task_status (
    id_status integer NOT NULL,
    status_name character varying(50) NOT NULL
);

ALTER TABLE public.dic_task_status OWNER TO postgres;

--
-- TOC entry 330 (class 1259 OID 53042)
-- Name: dic_task_status_id_status_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dic_task_status_id_status_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.dic_task_status_id_status_seq OWNER TO postgres;

--
-- TOC entry 5188 (class 0 OID 0)
-- Dependencies: 330
-- Name: dic_task_status_id_status_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dic_task_status_id_status_seq OWNED BY public.dic_task_status.id_status;

--
-- TOC entry 313 (class 1259 OID 52833)
-- Name: locations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.locations (
    id_location integer NOT NULL,
    name character varying(100) NOT NULL,
    location_type character varying(50) NOT NULL,
    floor integer,
    description text,
    CONSTRAINT chk_location_type CHECK (((location_type)::text = ANY ((ARRAY['кабинет'::character varying, 'склад'::character varying, 'серверная'::character varying, 'лаборатория'::character varying, 'другое'::character varying])::text[])))
);

ALTER TABLE public.locations OWNER TO postgres;

--
-- TOC entry 312 (class 1259 OID 52832)
-- Name: locations_id_location_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.locations_id_location_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.locations_id_location_seq OWNER TO postgres;

--
-- TOC entry 5189 (class 0 OID 0)
-- Dependencies: 312
-- Name: locations_id_location_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.locations_id_location_seq OWNED BY public.locations.id_location;

--
-- TOC entry 321 (class 1259 OID 52940)
-- Name: part_char_values; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.part_char_values (
    id_part_char integer NOT NULL,
    id_part integer NOT NULL,
    id_char integer NOT NULL,
    value_text text,
    id_arm integer NOT NULL
);

ALTER TABLE public.part_char_values OWNER TO postgres;

--
-- TOC entry 320 (class 1259 OID 52939)
-- Name: part_char_values_id_part_char_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.part_char_values_id_part_char_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.part_char_values_id_part_char_seq OWNER TO postgres;

--
-- TOC entry 5190 (class 0 OID 0)
-- Dependencies: 320
-- Name: part_char_values_id_part_char_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.part_char_values_id_part_char_seq OWNED BY public.part_char_values.id_part_char;

--
-- TOC entry 325 (class 1259 OID 53004)
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    id_role integer NOT NULL,
    role_name character varying
);

ALTER TABLE public.roles OWNER TO postgres;

--
-- TOC entry 324 (class 1259 OID 53003)
-- Name: roles_id_role_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.roles ALTER COLUMN id_role ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.roles_id_role_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

--
-- TOC entry 315 (class 1259 OID 52847)
-- Name: spr_char; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.spr_char (
    id_char integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    measurement_unit character varying
);

ALTER TABLE public.spr_char OWNER TO postgres;

--
-- TOC entry 314 (class 1259 OID 52846)
-- Name: spr_char_id_char_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.spr_char_id_char_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.spr_char_id_char_seq OWNER TO postgres;

--
-- TOC entry 5191 (class 0 OID 0)
-- Dependencies: 314
-- Name: spr_char_id_char_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.spr_char_id_char_seq OWNED BY public.spr_char.id_char;

--
-- TOC entry 317 (class 1259 OID 52876)
-- Name: spr_parts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.spr_parts (
    id_part integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    CONSTRAINT chk_name_not_empty CHECK ((length(TRIM(BOTH FROM name)) > 0))
);

ALTER TABLE public.spr_parts OWNER TO postgres;

--
-- TOC entry 316 (class 1259 OID 52875)
-- Name: spr_parts_id_part_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.spr_parts_id_part_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.spr_parts_id_part_seq OWNER TO postgres;

--
-- TOC entry 5192 (class 0 OID 0)
-- Dependencies: 316
-- Name: spr_parts_id_part_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.spr_parts_id_part_seq OWNED BY public.spr_parts.id_part;

--
-- TOC entry 327 (class 1259 OID 53020)
-- Name: tasks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tasks (
    id integer NOT NULL,
    id_status integer NOT NULL,
    description text NOT NULL,
    user_id integer NOT NULL,
    date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_time_update timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    comment text,
    executor_id integer,
    attachments text
);

ALTER TABLE public.tasks OWNER TO postgres;

--
-- TOC entry 5193 (class 0 OID 0)
-- Dependencies: 327
-- Name: COLUMN tasks.executor_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tasks.executor_id IS 'ID исполнителя';

--
-- TOC entry 5194 (class 0 OID 0)
-- Dependencies: 327
-- Name: COLUMN tasks.attachments; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tasks.attachments IS 'Массив ID вложений в формате JSON';

--
-- TOC entry 326 (class 1259 OID 53019)
-- Name: tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tasks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.tasks_id_seq OWNER TO postgres;

--
-- TOC entry 5195 (class 0 OID 0)
-- Dependencies: 326
-- Name: tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tasks_id_seq OWNED BY public.tasks.id;

--
-- TOC entry 311 (class 1259 OID 52818)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id_user integer NOT NULL,
    full_name character varying(200) NOT NULL,
    "position" character varying(100),
    department character varying(100),
    email character varying(100),
    phone character varying(50),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    password character varying(100),
    auth_key character varying(32) DEFAULT NULL::character varying,
    access_token character varying(255) DEFAULT NULL::character varying,
    password_reset_token character varying(255) DEFAULT NULL::character varying,
    id_role integer NOT NULL,
    CONSTRAINT chk_fullname_not_empty CHECK ((length(TRIM(BOTH FROM full_name)) > 0))
);

ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 5196 (class 0 OID 0)
-- Dependencies: 311
-- Name: TABLE users; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.users IS 'Работники организации';

--
-- TOC entry 310 (class 1259 OID 52817)
-- Name: users_id_user_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_user_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.users_id_user_seq OWNER TO postgres;

--
-- TOC entry 5197 (class 0 OID 0)
-- Dependencies: 310
-- Name: users_id_user_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_user_seq OWNED BY public.users.id_user;

--
-- TOC entry 4950 (class 2604 OID 52891)
-- Name: arm id_arm; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arm ALTER COLUMN id_arm SET DEFAULT nextval('public.arm_id_arm_seq'::regclass);

--
-- TOC entry 4953 (class 2604 OID 52972)
-- Name: arm_history id_history; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arm_history ALTER COLUMN id_history SET DEFAULT nextval('public.arm_history_id_history_seq'::regclass);

--
-- TOC entry 4958 (class 2604 OID 53035)
-- Name: desk_attachments attach_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.desk_attachments ALTER COLUMN attach_id SET DEFAULT nextval('public.desk_attachments_attach_id_seq'::regclass);

--
-- TOC entry 4960 (class 2604 OID 53046)
-- Name: dic_task_status id_status; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dic_task_status ALTER COLUMN id_status SET DEFAULT nextval('public.dic_task_status_id_status_seq'::regclass);

--
-- TOC entry 4947 (class 2604 OID 52836)
-- Name: locations id_location; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.locations ALTER COLUMN id_location SET DEFAULT nextval('public.locations_id_location_seq'::regclass);

--
-- TOC entry 4952 (class 2604 OID 52943)
-- Name: part_char_values id_part_char; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.part_char_values ALTER COLUMN id_part_char SET DEFAULT nextval('public.part_char_values_id_part_char_seq'::regclass);

--
-- TOC entry 4948 (class 2604 OID 52850)
-- Name: spr_char id_char; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spr_char ALTER COLUMN id_char SET DEFAULT nextval('public.spr_char_id_char_seq'::regclass);

--
-- TOC entry 4949 (class 2604 OID 52879)
-- Name: spr_parts id_part; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spr_parts ALTER COLUMN id_part SET DEFAULT nextval('public.spr_parts_id_part_seq'::regclass);

--
-- TOC entry 4955 (class 2604 OID 53023)
-- Name: tasks id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks ALTER COLUMN id SET DEFAULT nextval('public.tasks_id_seq'::regclass);

--
-- TOC entry 4942 (class 2604 OID 52821)
-- Name: users id_user; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id_user SET DEFAULT nextval('public.users_id_user_seq'::regclass);

--
-- TOC entry 5162 (class 0 OID 52888)
-- Dependencies: 319
-- Data for Name: arm; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.arm VALUES (103, 'АРМ-301', 301, 183, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (104, 'АРМ-302', 302, 184, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (105, 'АРМ-303', 303, 185, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (106, 'АРМ-304', 304, 186, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (107, 'АРМ-305', 305, 187, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (108, 'АРМ-306', 306, 188, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (109, 'АРМ-307', 307, 189, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (110, 'АРМ-308', 308, 190, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (111, 'АРМ-309', 309, 191, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (112, 'АРМ-310', 310, 192, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (113, 'АРМ-311', 311, 193, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (114, 'АРМ-312', 312, 194, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (115, 'АРМ-313', 313, 195, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (116, 'АРМ-314', 314, 196, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (117, 'АРМ-315', 315, 197, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (118, 'АРМ-316', 316, 198, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (119, 'АРМ-317', 317, 199, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (120, 'АРМ-318', 318, 200, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (121, 'АРМ-319', 319, 201, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (122, 'АРМ-320', 320, 202, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (123, 'АРМ-321', 321, 203, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (124, 'АРМ-322', 322, 204, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (125, 'АРМ-323', 323, 205, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (126, 'АРМ-324', 324, 206, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (127, 'АРМ-325', 325, 207, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (128, 'АРМ-326', 326, 208, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (129, 'АРМ-327', 327, 209, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (130, 'АРМ-328', 328, 210, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (131, 'АРМ-329', 329, 211, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (132, 'АРМ-330', 330, 212, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (133, 'АРМ-331', 331, 213, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (134, 'АРМ-332', 332, 214, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (135, 'АРМ-333', 333, 215, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (136, 'АРМ-334', 334, 216, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (137, 'АРМ-335', 335, 217, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (138, 'АРМ-336', 336, 218, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (139, 'АРМ-337', 337, 219, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (140, 'АРМ-338', 338, 220, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (141, 'АРМ-339', 339, 221, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (142, 'АРМ-340', 340, 222, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (143, 'АРМ-341', 341, 223, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (144, 'АРМ-342', 342, 224, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (145, 'АРМ-343', 343, 225, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (146, 'АРМ-344', 344, 226, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (147, 'АРМ-345', 345, 227, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (148, 'АРМ-346', 346, 228, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (149, 'АРМ-347', 347, 229, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (150, 'АРМ-348', 348, 230, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (151, 'АРМ-349', 349, 231, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (152, 'АРМ-350', 350, 232, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (153, 'АРМ-351', 351, 233, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (154, 'АРМ-352', 352, 234, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (155, 'АРМ-353', 353, 235, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (156, 'АРМ-354', 354, 236, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (157, 'АРМ-355', 355, 237, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (158, 'АРМ-356', 356, 238, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (159, 'АРМ-357', 357, 239, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (160, 'АРМ-358', 358, 240, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (161, 'АРМ-359', 359, 241, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (162, 'АРМ-360', 360, 242, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (163, 'АРМ-361', 361, 243, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (164, 'АРМ-362', 362, 244, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (165, 'АРМ-363', 363, 245, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (166, 'АРМ-364', 364, 246, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (167, 'АРМ-365', 365, 247, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (168, 'АРМ-366', 366, 248, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (169, 'АРМ-367', 367, 249, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (170, 'АРМ-368', 368, 250, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (171, 'АРМ-369', 369, 251, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (172, 'АРМ-370', 370, 252, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (173, 'АРМ-371', 371, 253, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (174, 'АРМ-372', 372, 254, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (175, 'АРМ-373', 373, 255, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (176, 'АРМ-374', 374, 256, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (177, 'АРМ-375', 375, 257, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (178, 'АРМ-376', 376, 258, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (179, 'АРМ-377', 377, 259, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (180, 'АРМ-378', 378, 260, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (181, 'АРМ-379', 379, 261, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (182, 'АРМ-380', 380, 262, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (183, 'АРМ-381', 381, 263, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (184, 'АРМ-382', 382, 264, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (185, 'АРМ-383', 383, 265, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (186, 'АРМ-384', 384, 266, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (187, 'АРМ-385', 385, 267, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (188, 'АРМ-386', 386, 268, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (189, 'АРМ-387', 387, 269, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (190, 'АРМ-388', 388, 270, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (191, 'АРМ-389', 389, 271, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (192, 'АРМ-390', 390, 272, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (193, 'АРМ-391', 391, 273, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (194, 'АРМ-392', 392, 274, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (195, 'АРМ-393', 393, 275, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (196, 'АРМ-394', 394, 276, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (197, 'АРМ-395', 395, 277, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (198, 'АРМ-396', 396, 278, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (199, 'АРМ-397', 397, 279, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (200, 'АРМ-398', 398, 280, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (201, 'АРМ-399', 399, 281, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');
INSERT INTO public.arm VALUES (202, 'АРМ-400', 400, 282, 'Рабочее место пользователя', '2025-10-27 11:44:19.826015');

--
-- TOC entry 5166 (class 0 OID 52969)
-- Dependencies: 323
-- Data for Name: arm_history; Type: TABLE DATA; Schema: public; Owner: postgres
--


--
-- TOC entry 5172 (class 0 OID 53032)
-- Dependencies: 329
-- Data for Name: desk_attachments; Type: TABLE DATA; Schema: public; Owner: postgres
--


--
-- TOC entry 5174 (class 0 OID 53043)
-- Dependencies: 331
-- Data for Name: dic_task_status; Type: TABLE DATA; Schema: public; Owner: postgres
--


--
-- TOC entry 5156 (class 0 OID 52833)
-- Dependencies: 313
-- Data for Name: locations; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.locations VALUES (183, 'Кабинет 100', 'кабинет', 1, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (184, 'Кабинет 101', 'кабинет', 1, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (185, 'Кабинет 102', 'кабинет', 1, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (186, 'Кабинет 103', 'кабинет', 1, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (187, 'Кабинет 104', 'кабинет', 1, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (188, 'Кабинет 105', 'кабинет', 1, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (189, 'Кабинет 106', 'кабинет', 1, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (190, 'Кабинет 107', 'кабинет', 1, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (191, 'Кабинет 108', 'кабинет', 1, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (192, 'Кабинет 109', 'кабинет', 1, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (193, 'Кабинет 110', 'кабинет', 1, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (194, 'Кабинет 111', 'кабинет', 1, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (195, 'Кабинет 112', 'кабинет', 1, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (196, 'Кабинет 113', 'кабинет', 1, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (197, 'Кабинет 114', 'кабинет', 1, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (198, 'Кабинет 115', 'кабинет', 1, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (199, 'Кабинет 116', 'кабинет', 1, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (200, 'Кабинет 117', 'кабинет', 1, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (201, 'Кабинет 118', 'кабинет', 1, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (202, 'Кабинет 119', 'кабинет', 1, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (203, 'Кабинет 120', 'кабинет', 1, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (204, 'Кабинет 199', 'кабинет', 1, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (205, 'Кабинет 200', 'кабинет', 2, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (206, 'Кабинет 201', 'кабинет', 2, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (207, 'Кабинет 202', 'кабинет', 2, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (208, 'Кабинет 203', 'кабинет', 2, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (209, 'Кабинет 204', 'кабинет', 2, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (210, 'Кабинет 205', 'кабинет', 2, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (211, 'Кабинет 206', 'кабинет', 2, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (212, 'Кабинет 207', 'кабинет', 2, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (213, 'Кабинет 208', 'кабинет', 2, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (214, 'Кабинет 209', 'кабинет', 2, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (215, 'Кабинет 210', 'кабинет', 2, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (216, 'Кабинет 211', 'кабинет', 2, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (217, 'Кабинет 212', 'кабинет', 2, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (218, 'Кабинет 213', 'кабинет', 2, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (219, 'Кабинет 214', 'кабинет', 2, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (220, 'Кабинет 215', 'кабинет', 2, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (221, 'Кабинет 216', 'кабинет', 2, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (222, 'Кабинет 217', 'кабинет', 2, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (223, 'Кабинет 218', 'кабинет', 2, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (224, 'Кабинет 219', 'кабинет', 2, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (225, 'Кабинет 220', 'кабинет', 2, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (226, 'Кабинет 299', 'кабинет', 2, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (227, 'Кабинет 300', 'кабинет', 3, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (228, 'Кабинет 301', 'кабинет', 3, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (229, 'Кабинет 302', 'кабинет', 3, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (230, 'Кабинет 303', 'кабинет', 3, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (231, 'Кабинет 304', 'кабинет', 3, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (232, 'Кабинет 305', 'кабинет', 3, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (233, 'Кабинет 306', 'кабинет', 3, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (234, 'Кабинет 307', 'кабинет', 3, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (235, 'Кабинет 308', 'кабинет', 3, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (236, 'Кабинет 309', 'кабинет', 3, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (237, 'Кабинет 310', 'кабинет', 3, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (238, 'Кабинет 311', 'кабинет', 3, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (239, 'Кабинет 312', 'кабинет', 3, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (240, 'Кабинет 313', 'кабинет', 3, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (241, 'Кабинет 314', 'кабинет', 3, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (242, 'Кабинет 315', 'кабинет', 3, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (243, 'Кабинет 316', 'кабинет', 3, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (244, 'Кабинет 317', 'кабинет', 3, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (245, 'Кабинет 318', 'кабинет', 3, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (246, 'Кабинет 319', 'кабинет', 3, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (247, 'Кабинет 320', 'кабинет', 3, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (248, 'Кабинет 399', 'кабинет', 3, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (249, 'Кабинет 400', 'кабинет', 4, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (250, 'Кабинет 401', 'кабинет', 4, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (251, 'Кабинет 402', 'кабинет', 4, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (252, 'Кабинет 403', 'кабинет', 4, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (253, 'Кабинет 404', 'кабинет', 4, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (254, 'Кабинет 405', 'кабинет', 4, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (255, 'Кабинет 406', 'кабинет', 4, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (256, 'Кабинет 407', 'кабинет', 4, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (257, 'Кабинет 408', 'кабинет', 4, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (258, 'Кабинет 409', 'кабинет', 4, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (259, 'Кабинет 410', 'кабинет', 4, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (260, 'Кабинет 411', 'кабинет', 4, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (261, 'Кабинет 412', 'кабинет', 4, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (262, 'Кабинет 413', 'кабинет', 4, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (263, 'Кабинет 414', 'кабинет', 4, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (264, 'Кабинет 415', 'кабинет', 4, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (265, 'Кабинет 416', 'кабинет', 4, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (266, 'Кабинет 417', 'кабинет', 4, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (267, 'Кабинет 418', 'кабинет', 4, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (268, 'Кабинет 419', 'кабинет', 4, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (269, 'Кабинет 420', 'кабинет', 4, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (270, 'Кабинет 499', 'кабинет', 4, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (271, 'Кабинет 500', 'кабинет', 5, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (272, 'Кабинет 501', 'кабинет', 5, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (273, 'Кабинет 502', 'кабинет', 5, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (274, 'Кабинет 503', 'кабинет', 5, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (275, 'Кабинет 504', 'кабинет', 5, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (276, 'Кабинет 505', 'кабинет', 5, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (277, 'Кабинет 506', 'кабинет', 5, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (278, 'Кабинет 507', 'кабинет', 5, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (279, 'Кабинет 508', 'кабинет', 5, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (280, 'Кабинет 509', 'кабинет', 5, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (281, 'Кабинет 510', 'кабинет', 5, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (282, 'Кабинет 511', 'кабинет', 5, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (283, 'Кабинет 512', 'кабинет', 5, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (284, 'Кабинет 513', 'кабинет', 5, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (285, 'Кабинет 514', 'кабинет', 5, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (286, 'Кабинет 515', 'кабинет', 5, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (287, 'Кабинет 516', 'кабинет', 5, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (288, 'Кабинет 517', 'кабинет', 5, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (289, 'Кабинет 518', 'кабинет', 5, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (290, 'Кабинет 519', 'кабинет', 5, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (291, 'Кабинет 520', 'кабинет', 5, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (292, 'Кабинет 599', 'кабинет', 5, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (293, 'Кабинет 600', 'кабинет', 6, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (294, 'Кабинет 601', 'кабинет', 6, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (295, 'Кабинет 602', 'кабинет', 6, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (296, 'Кабинет 603', 'кабинет', 6, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (297, 'Кабинет 604', 'кабинет', 6, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (298, 'Кабинет 605', 'кабинет', 6, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (299, 'Кабинет 606', 'кабинет', 6, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (300, 'Кабинет 607', 'кабинет', 6, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (301, 'Кабинет 608', 'кабинет', 6, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (302, 'Кабинет 609', 'кабинет', 6, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (303, 'Кабинет 610', 'кабинет', 6, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (304, 'Кабинет 611', 'кабинет', 6, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (305, 'Кабинет 612', 'кабинет', 6, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (306, 'Кабинет 613', 'кабинет', 6, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (307, 'Кабинет 614', 'кабинет', 6, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (308, 'Кабинет 615', 'кабинет', 6, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (309, 'Кабинет 616', 'кабинет', 6, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (310, 'Кабинет 617', 'кабинет', 6, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (311, 'Кабинет 618', 'кабинет', 6, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (312, 'Кабинет 619', 'кабинет', 6, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (313, 'Кабинет 620', 'кабинет', 6, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (314, 'Кабинет 699', 'кабинет', 6, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (315, 'Кабинет 700', 'кабинет', 7, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (316, 'Кабинет 701', 'кабинет', 7, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (317, 'Кабинет 702', 'кабинет', 7, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (318, 'Кабинет 703', 'кабинет', 7, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (319, 'Кабинет 704', 'кабинет', 7, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (320, 'Кабинет 705', 'кабинет', 7, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (321, 'Кабинет 706', 'кабинет', 7, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (322, 'Кабинет 707', 'кабинет', 7, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (323, 'Кабинет 708', 'кабинет', 7, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (324, 'Кабинет 709', 'кабинет', 7, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (325, 'Кабинет 710', 'кабинет', 7, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (326, 'Кабинет 711', 'кабинет', 7, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (327, 'Кабинет 712', 'кабинет', 7, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (328, 'Кабинет 713', 'кабинет', 7, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (329, 'Кабинет 714', 'кабинет', 7, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (330, 'Кабинет 715', 'кабинет', 7, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (331, 'Кабинет 716', 'кабинет', 7, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (332, 'Кабинет 717', 'кабинет', 7, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (333, 'Кабинет 718', 'кабинет', 7, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (334, 'Кабинет 719', 'кабинет', 7, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (335, 'Кабинет 720', 'кабинет', 7, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (336, 'Кабинет 799', 'кабинет', 7, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (337, 'Кабинет 800', 'кабинет', 8, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (338, 'Кабинет 801', 'кабинет', 8, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (339, 'Кабинет 802', 'кабинет', 8, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (340, 'Кабинет 803', 'кабинет', 8, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (341, 'Кабинет 804', 'кабинет', 8, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (342, 'Кабинет 805', 'кабинет', 8, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (343, 'Кабинет 806', 'кабинет', 8, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (344, 'Кабинет 807', 'кабинет', 8, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (345, 'Кабинет 808', 'кабинет', 8, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (346, 'Кабинет 809', 'кабинет', 8, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (347, 'Кабинет 810', 'кабинет', 8, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (348, 'Кабинет 811', 'кабинет', 8, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (349, 'Кабинет 812', 'кабинет', 8, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (350, 'Кабинет 813', 'кабинет', 8, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (351, 'Кабинет 814', 'кабинет', 8, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (352, 'Кабинет 815', 'кабинет', 8, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (353, 'Кабинет 816', 'кабинет', 8, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (354, 'Кабинет 817', 'кабинет', 8, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (355, 'Кабинет 818', 'кабинет', 8, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (356, 'Кабинет 819', 'кабинет', 8, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (357, 'Кабинет 820', 'кабинет', 8, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (358, 'Кабинет 899', 'кабинет', 8, 'Рабочий кабинет');
INSERT INTO public.locations VALUES (359, 'Склад А', 'склад', 1, 'Склад техники');
INSERT INTO public.locations VALUES (360, 'Склад Б', 'склад', 1, 'Склад техники');
INSERT INTO public.locations VALUES (361, 'Серверная 1', 'серверная', 2, 'Серверная комната');
INSERT INTO public.locations VALUES (362, 'Серверная 2', 'серверная', 5, 'Серверная комната');
INSERT INTO public.locations VALUES (363, 'Лаборатория 1', 'лаборатория', 3, 'Испытательная лаборатория');
INSERT INTO public.locations VALUES (364, 'Лаборатория 2', 'лаборатория', 6, 'Испытательная лаборатория');

--
-- TOC entry 5164 (class 0 OID 52940)
-- Dependencies: 321
-- Data for Name: part_char_values; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.part_char_values VALUES (1022, 1, 2, 'Intel', 103);
INSERT INTO public.part_char_values VALUES (1023, 1, 1, 'I5-12500', 103);
INSERT INTO public.part_char_values VALUES (1024, 1, 6, '4.5', 103);
INSERT INTO public.part_char_values VALUES (1025, 1, 54, '8', 103);
INSERT INTO public.part_char_values VALUES (1026, 2, 11, 'DDR4', 103);
INSERT INTO public.part_char_values VALUES (1027, 2, 4, '16', 103);
INSERT INTO public.part_char_values VALUES (1028, 2, 55, '3200', 103);
INSERT INTO public.part_char_values VALUES (1029, 3, 5, '1024', 103);
INSERT INTO public.part_char_values VALUES (1030, 3, 12, 'SSD', 103);
INSERT INTO public.part_char_values VALUES (1031, 5, 50, 'Цветной', 103);
INSERT INTO public.part_char_values VALUES (1032, 6, 13, '650', 103);
INSERT INTO public.part_char_values VALUES (1033, 3, 12, 'NVMe', 103);
INSERT INTO public.part_char_values VALUES (1034, 3, 5, '1024', 103);
INSERT INTO public.part_char_values VALUES (421, 4, 2, 'HP', 103);
INSERT INTO public.part_char_values VALUES (422, 4, 2, 'Samsung', 104);
INSERT INTO public.part_char_values VALUES (423, 4, 2, 'LG', 105);
INSERT INTO public.part_char_values VALUES (424, 4, 2, 'Dell', 106);
INSERT INTO public.part_char_values VALUES (425, 4, 2, 'HP', 107);
INSERT INTO public.part_char_values VALUES (426, 4, 2, 'Samsung', 108);
INSERT INTO public.part_char_values VALUES (427, 4, 2, 'LG', 109);
INSERT INTO public.part_char_values VALUES (428, 4, 2, 'Dell', 110);
INSERT INTO public.part_char_values VALUES (429, 4, 2, 'HP', 111);
INSERT INTO public.part_char_values VALUES (430, 4, 2, 'Samsung', 112);
INSERT INTO public.part_char_values VALUES (431, 4, 2, 'LG', 113);
INSERT INTO public.part_char_values VALUES (432, 4, 2, 'Dell', 114);
INSERT INTO public.part_char_values VALUES (433, 4, 2, 'HP', 115);
INSERT INTO public.part_char_values VALUES (434, 4, 2, 'Samsung', 116);
INSERT INTO public.part_char_values VALUES (435, 4, 2, 'LG', 117);
INSERT INTO public.part_char_values VALUES (436, 4, 2, 'Dell', 118);
INSERT INTO public.part_char_values VALUES (437, 4, 2, 'HP', 119);
INSERT INTO public.part_char_values VALUES (438, 4, 2, 'Samsung', 120);
INSERT INTO public.part_char_values VALUES (439, 4, 2, 'LG', 121);
INSERT INTO public.part_char_values VALUES (440, 4, 2, 'Dell', 122);
INSERT INTO public.part_char_values VALUES (441, 4, 2, 'HP', 123);
INSERT INTO public.part_char_values VALUES (442, 4, 2, 'Samsung', 124);
INSERT INTO public.part_char_values VALUES (443, 4, 2, 'LG', 125);
INSERT INTO public.part_char_values VALUES (444, 4, 2, 'Dell', 126);
INSERT INTO public.part_char_values VALUES (445, 4, 2, 'HP', 127);
INSERT INTO public.part_char_values VALUES (446, 4, 2, 'Samsung', 128);
INSERT INTO public.part_char_values VALUES (447, 4, 2, 'LG', 129);
INSERT INTO public.part_char_values VALUES (448, 4, 2, 'Dell', 130);
INSERT INTO public.part_char_values VALUES (449, 4, 2, 'HP', 131);
INSERT INTO public.part_char_values VALUES (450, 4, 2, 'Samsung', 132);
INSERT INTO public.part_char_values VALUES (451, 4, 2, 'LG', 133);
INSERT INTO public.part_char_values VALUES (452, 4, 2, 'Dell', 134);
INSERT INTO public.part_char_values VALUES (453, 4, 2, 'HP', 135);
INSERT INTO public.part_char_values VALUES (454, 4, 2, 'Samsung', 136);
INSERT INTO public.part_char_values VALUES (455, 4, 2, 'LG', 137);
INSERT INTO public.part_char_values VALUES (456, 4, 2, 'Dell', 138);
INSERT INTO public.part_char_values VALUES (457, 4, 2, 'HP', 139);
INSERT INTO public.part_char_values VALUES (458, 4, 2, 'Samsung', 140);
INSERT INTO public.part_char_values VALUES (459, 4, 2, 'LG', 141);
INSERT INTO public.part_char_values VALUES (460, 4, 2, 'Dell', 142);
INSERT INTO public.part_char_values VALUES (461, 4, 2, 'HP', 143);
INSERT INTO public.part_char_values VALUES (462, 4, 2, 'Samsung', 144);
INSERT INTO public.part_char_values VALUES (463, 4, 2, 'LG', 145);
INSERT INTO public.part_char_values VALUES (464, 4, 2, 'Dell', 146);
INSERT INTO public.part_char_values VALUES (465, 4, 2, 'HP', 147);
INSERT INTO public.part_char_values VALUES (466, 4, 2, 'Samsung', 148);
INSERT INTO public.part_char_values VALUES (467, 4, 2, 'LG', 149);
INSERT INTO public.part_char_values VALUES (468, 4, 2, 'Dell', 150);
INSERT INTO public.part_char_values VALUES (469, 4, 2, 'HP', 151);
INSERT INTO public.part_char_values VALUES (470, 4, 2, 'Samsung', 152);
INSERT INTO public.part_char_values VALUES (471, 4, 2, 'LG', 153);
INSERT INTO public.part_char_values VALUES (472, 4, 2, 'Dell', 154);
INSERT INTO public.part_char_values VALUES (473, 4, 2, 'HP', 155);
INSERT INTO public.part_char_values VALUES (474, 4, 2, 'Samsung', 156);
INSERT INTO public.part_char_values VALUES (475, 4, 2, 'LG', 157);
INSERT INTO public.part_char_values VALUES (476, 4, 2, 'Dell', 158);
INSERT INTO public.part_char_values VALUES (477, 4, 2, 'HP', 159);
INSERT INTO public.part_char_values VALUES (478, 4, 2, 'Samsung', 160);
INSERT INTO public.part_char_values VALUES (479, 4, 2, 'LG', 161);
INSERT INTO public.part_char_values VALUES (480, 4, 2, 'Dell', 162);
INSERT INTO public.part_char_values VALUES (481, 4, 2, 'HP', 163);
INSERT INTO public.part_char_values VALUES (482, 4, 2, 'Samsung', 164);
INSERT INTO public.part_char_values VALUES (483, 4, 2, 'LG', 165);
INSERT INTO public.part_char_values VALUES (484, 4, 2, 'Dell', 166);
INSERT INTO public.part_char_values VALUES (485, 4, 2, 'HP', 167);
INSERT INTO public.part_char_values VALUES (486, 4, 2, 'Samsung', 168);
INSERT INTO public.part_char_values VALUES (487, 4, 2, 'LG', 169);
INSERT INTO public.part_char_values VALUES (488, 4, 2, 'Dell', 170);
INSERT INTO public.part_char_values VALUES (489, 4, 2, 'HP', 171);
INSERT INTO public.part_char_values VALUES (490, 4, 2, 'Samsung', 172);
INSERT INTO public.part_char_values VALUES (491, 4, 2, 'LG', 173);
INSERT INTO public.part_char_values VALUES (492, 4, 2, 'Dell', 174);
INSERT INTO public.part_char_values VALUES (493, 4, 2, 'HP', 175);
INSERT INTO public.part_char_values VALUES (494, 4, 2, 'Samsung', 176);
INSERT INTO public.part_char_values VALUES (495, 4, 2, 'LG', 177);
INSERT INTO public.part_char_values VALUES (496, 4, 2, 'Dell', 178);
INSERT INTO public.part_char_values VALUES (497, 4, 2, 'HP', 179);
INSERT INTO public.part_char_values VALUES (498, 4, 2, 'Samsung', 180);
INSERT INTO public.part_char_values VALUES (499, 4, 2, 'LG', 181);
INSERT INTO public.part_char_values VALUES (500, 4, 2, 'Dell', 182);
INSERT INTO public.part_char_values VALUES (501, 4, 2, 'HP', 183);
INSERT INTO public.part_char_values VALUES (502, 4, 2, 'Samsung', 184);
INSERT INTO public.part_char_values VALUES (503, 4, 2, 'LG', 185);
INSERT INTO public.part_char_values VALUES (504, 4, 2, 'Dell', 186);
INSERT INTO public.part_char_values VALUES (505, 4, 2, 'HP', 187);
INSERT INTO public.part_char_values VALUES (506, 4, 2, 'Samsung', 188);
INSERT INTO public.part_char_values VALUES (507, 4, 2, 'LG', 189);
INSERT INTO public.part_char_values VALUES (508, 4, 2, 'Dell', 190);
INSERT INTO public.part_char_values VALUES (509, 4, 2, 'HP', 191);
INSERT INTO public.part_char_values VALUES (510, 4, 2, 'Samsung', 192);
INSERT INTO public.part_char_values VALUES (511, 4, 2, 'LG', 193);
INSERT INTO public.part_char_values VALUES (512, 4, 2, 'Dell', 194);
INSERT INTO public.part_char_values VALUES (513, 4, 2, 'HP', 195);
INSERT INTO public.part_char_values VALUES (514, 4, 2, 'Samsung', 196);
INSERT INTO public.part_char_values VALUES (515, 4, 2, 'LG', 197);
INSERT INTO public.part_char_values VALUES (516, 4, 2, 'Dell', 198);
INSERT INTO public.part_char_values VALUES (517, 4, 2, 'HP', 199);
INSERT INTO public.part_char_values VALUES (518, 4, 2, 'Samsung', 200);
INSERT INTO public.part_char_values VALUES (519, 4, 2, 'LG', 201);
INSERT INTO public.part_char_values VALUES (520, 4, 2, 'Dell', 202);
INSERT INTO public.part_char_values VALUES (521, 4, 1, 'MON-000103', 103);
INSERT INTO public.part_char_values VALUES (522, 4, 1, 'MON-000104', 104);
INSERT INTO public.part_char_values VALUES (523, 4, 1, 'MON-000105', 105);
INSERT INTO public.part_char_values VALUES (524, 4, 1, 'MON-000106', 106);
INSERT INTO public.part_char_values VALUES (525, 4, 1, 'MON-000107', 107);
INSERT INTO public.part_char_values VALUES (526, 4, 1, 'MON-000108', 108);
INSERT INTO public.part_char_values VALUES (527, 4, 1, 'MON-000109', 109);
INSERT INTO public.part_char_values VALUES (528, 4, 1, 'MON-000110', 110);
INSERT INTO public.part_char_values VALUES (529, 4, 1, 'MON-000111', 111);
INSERT INTO public.part_char_values VALUES (530, 4, 1, 'MON-000112', 112);
INSERT INTO public.part_char_values VALUES (531, 4, 1, 'MON-000113', 113);
INSERT INTO public.part_char_values VALUES (532, 4, 1, 'MON-000114', 114);
INSERT INTO public.part_char_values VALUES (533, 4, 1, 'MON-000115', 115);
INSERT INTO public.part_char_values VALUES (534, 4, 1, 'MON-000116', 116);
INSERT INTO public.part_char_values VALUES (535, 4, 1, 'MON-000117', 117);
INSERT INTO public.part_char_values VALUES (536, 4, 1, 'MON-000118', 118);
INSERT INTO public.part_char_values VALUES (537, 4, 1, 'MON-000119', 119);
INSERT INTO public.part_char_values VALUES (538, 4, 1, 'MON-000120', 120);
INSERT INTO public.part_char_values VALUES (539, 4, 1, 'MON-000121', 121);
INSERT INTO public.part_char_values VALUES (540, 4, 1, 'MON-000122', 122);
INSERT INTO public.part_char_values VALUES (541, 4, 1, 'MON-000123', 123);
INSERT INTO public.part_char_values VALUES (542, 4, 1, 'MON-000124', 124);
INSERT INTO public.part_char_values VALUES (543, 4, 1, 'MON-000125', 125);
INSERT INTO public.part_char_values VALUES (544, 4, 1, 'MON-000126', 126);
INSERT INTO public.part_char_values VALUES (545, 4, 1, 'MON-000127', 127);
INSERT INTO public.part_char_values VALUES (546, 4, 1, 'MON-000128', 128);
INSERT INTO public.part_char_values VALUES (547, 4, 1, 'MON-000129', 129);
INSERT INTO public.part_char_values VALUES (548, 4, 1, 'MON-000130', 130);
INSERT INTO public.part_char_values VALUES (549, 4, 1, 'MON-000131', 131);
INSERT INTO public.part_char_values VALUES (550, 4, 1, 'MON-000132', 132);
INSERT INTO public.part_char_values VALUES (551, 4, 1, 'MON-000133', 133);
INSERT INTO public.part_char_values VALUES (552, 4, 1, 'MON-000134', 134);
INSERT INTO public.part_char_values VALUES (553, 4, 1, 'MON-000135', 135);
INSERT INTO public.part_char_values VALUES (554, 4, 1, 'MON-000136', 136);
INSERT INTO public.part_char_values VALUES (555, 4, 1, 'MON-000137', 137);
INSERT INTO public.part_char_values VALUES (556, 4, 1, 'MON-000138', 138);
INSERT INTO public.part_char_values VALUES (557, 4, 1, 'MON-000139', 139);
INSERT INTO public.part_char_values VALUES (558, 4, 1, 'MON-000140', 140);
INSERT INTO public.part_char_values VALUES (559, 4, 1, 'MON-000141', 141);
INSERT INTO public.part_char_values VALUES (560, 4, 1, 'MON-000142', 142);
INSERT INTO public.part_char_values VALUES (561, 4, 1, 'MON-000143', 143);
INSERT INTO public.part_char_values VALUES (562, 4, 1, 'MON-000144', 144);
INSERT INTO public.part_char_values VALUES (563, 4, 1, 'MON-000145', 145);
INSERT INTO public.part_char_values VALUES (564, 4, 1, 'MON-000146', 146);
INSERT INTO public.part_char_values VALUES (565, 4, 1, 'MON-000147', 147);
INSERT INTO public.part_char_values VALUES (566, 4, 1, 'MON-000148', 148);
INSERT INTO public.part_char_values VALUES (567, 4, 1, 'MON-000149', 149);
INSERT INTO public.part_char_values VALUES (568, 4, 1, 'MON-000150', 150);
INSERT INTO public.part_char_values VALUES (569, 4, 1, 'MON-000151', 151);
INSERT INTO public.part_char_values VALUES (570, 4, 1, 'MON-000152', 152);
INSERT INTO public.part_char_values VALUES (571, 4, 1, 'MON-000153', 153);
INSERT INTO public.part_char_values VALUES (572, 4, 1, 'MON-000154', 154);
INSERT INTO public.part_char_values VALUES (573, 4, 1, 'MON-000155', 155);
INSERT INTO public.part_char_values VALUES (574, 4, 1, 'MON-000156', 156);
INSERT INTO public.part_char_values VALUES (575, 4, 1, 'MON-000157', 157);
INSERT INTO public.part_char_values VALUES (576, 4, 1, 'MON-000158', 158);
INSERT INTO public.part_char_values VALUES (577, 4, 1, 'MON-000159', 159);
INSERT INTO public.part_char_values VALUES (578, 4, 1, 'MON-000160', 160);
INSERT INTO public.part_char_values VALUES (579, 4, 1, 'MON-000161', 161);
INSERT INTO public.part_char_values VALUES (580, 4, 1, 'MON-000162', 162);
INSERT INTO public.part_char_values VALUES (581, 4, 1, 'MON-000163', 163);
INSERT INTO public.part_char_values VALUES (582, 4, 1, 'MON-000164', 164);
INSERT INTO public.part_char_values VALUES (583, 4, 1, 'MON-000165', 165);
INSERT INTO public.part_char_values VALUES (584, 4, 1, 'MON-000166', 166);
INSERT INTO public.part_char_values VALUES (585, 4, 1, 'MON-000167', 167);
INSERT INTO public.part_char_values VALUES (586, 4, 1, 'MON-000168', 168);
INSERT INTO public.part_char_values VALUES (587, 4, 1, 'MON-000169', 169);
INSERT INTO public.part_char_values VALUES (588, 4, 1, 'MON-000170', 170);
INSERT INTO public.part_char_values VALUES (589, 4, 1, 'MON-000171', 171);
INSERT INTO public.part_char_values VALUES (590, 4, 1, 'MON-000172', 172);
INSERT INTO public.part_char_values VALUES (591, 4, 1, 'MON-000173', 173);
INSERT INTO public.part_char_values VALUES (592, 4, 1, 'MON-000174', 174);
INSERT INTO public.part_char_values VALUES (593, 4, 1, 'MON-000175', 175);
INSERT INTO public.part_char_values VALUES (594, 4, 1, 'MON-000176', 176);
INSERT INTO public.part_char_values VALUES (595, 4, 1, 'MON-000177', 177);
INSERT INTO public.part_char_values VALUES (596, 4, 1, 'MON-000178', 178);
INSERT INTO public.part_char_values VALUES (597, 4, 1, 'MON-000179', 179);
INSERT INTO public.part_char_values VALUES (598, 4, 1, 'MON-000180', 180);
INSERT INTO public.part_char_values VALUES (599, 4, 1, 'MON-000181', 181);
INSERT INTO public.part_char_values VALUES (600, 4, 1, 'MON-000182', 182);
INSERT INTO public.part_char_values VALUES (601, 4, 1, 'MON-000183', 183);
INSERT INTO public.part_char_values VALUES (602, 4, 1, 'MON-000184', 184);
INSERT INTO public.part_char_values VALUES (603, 4, 1, 'MON-000185', 185);
INSERT INTO public.part_char_values VALUES (604, 4, 1, 'MON-000186', 186);
INSERT INTO public.part_char_values VALUES (605, 4, 1, 'MON-000187', 187);
INSERT INTO public.part_char_values VALUES (606, 4, 1, 'MON-000188', 188);
INSERT INTO public.part_char_values VALUES (607, 4, 1, 'MON-000189', 189);
INSERT INTO public.part_char_values VALUES (608, 4, 1, 'MON-000190', 190);
INSERT INTO public.part_char_values VALUES (609, 4, 1, 'MON-000191', 191);
INSERT INTO public.part_char_values VALUES (610, 4, 1, 'MON-000192', 192);
INSERT INTO public.part_char_values VALUES (611, 4, 1, 'MON-000193', 193);
INSERT INTO public.part_char_values VALUES (612, 4, 1, 'MON-000194', 194);
INSERT INTO public.part_char_values VALUES (613, 4, 1, 'MON-000195', 195);
INSERT INTO public.part_char_values VALUES (614, 4, 1, 'MON-000196', 196);
INSERT INTO public.part_char_values VALUES (615, 4, 1, 'MON-000197', 197);
INSERT INTO public.part_char_values VALUES (616, 4, 1, 'MON-000198', 198);
INSERT INTO public.part_char_values VALUES (617, 4, 1, 'MON-000199', 199);
INSERT INTO public.part_char_values VALUES (618, 4, 1, 'MON-000200', 200);
INSERT INTO public.part_char_values VALUES (619, 4, 1, 'MON-000201', 201);
INSERT INTO public.part_char_values VALUES (620, 4, 1, 'MON-000202', 202);
INSERT INTO public.part_char_values VALUES (621, 4, 3, '24', 103);
INSERT INTO public.part_char_values VALUES (622, 4, 3, '27', 104);
INSERT INTO public.part_char_values VALUES (623, 4, 3, '21.5', 105);
INSERT INTO public.part_char_values VALUES (624, 4, 3, '24', 106);
INSERT INTO public.part_char_values VALUES (625, 4, 3, '27', 107);
INSERT INTO public.part_char_values VALUES (626, 4, 3, '21.5', 108);
INSERT INTO public.part_char_values VALUES (627, 4, 3, '24', 109);
INSERT INTO public.part_char_values VALUES (628, 4, 3, '27', 110);
INSERT INTO public.part_char_values VALUES (629, 4, 3, '21.5', 111);
INSERT INTO public.part_char_values VALUES (630, 4, 3, '24', 112);
INSERT INTO public.part_char_values VALUES (631, 4, 3, '27', 113);
INSERT INTO public.part_char_values VALUES (632, 4, 3, '21.5', 114);
INSERT INTO public.part_char_values VALUES (633, 4, 3, '24', 115);
INSERT INTO public.part_char_values VALUES (634, 4, 3, '27', 116);
INSERT INTO public.part_char_values VALUES (635, 4, 3, '21.5', 117);
INSERT INTO public.part_char_values VALUES (636, 4, 3, '24', 118);
INSERT INTO public.part_char_values VALUES (637, 4, 3, '27', 119);
INSERT INTO public.part_char_values VALUES (638, 4, 3, '21.5', 120);
INSERT INTO public.part_char_values VALUES (639, 4, 3, '24', 121);
INSERT INTO public.part_char_values VALUES (640, 4, 3, '27', 122);
INSERT INTO public.part_char_values VALUES (641, 4, 3, '21.5', 123);
INSERT INTO public.part_char_values VALUES (642, 4, 3, '24', 124);
INSERT INTO public.part_char_values VALUES (643, 4, 3, '27', 125);
INSERT INTO public.part_char_values VALUES (644, 4, 3, '21.5', 126);
INSERT INTO public.part_char_values VALUES (645, 4, 3, '24', 127);
INSERT INTO public.part_char_values VALUES (646, 4, 3, '27', 128);
INSERT INTO public.part_char_values VALUES (647, 4, 3, '21.5', 129);
INSERT INTO public.part_char_values VALUES (648, 4, 3, '24', 130);
INSERT INTO public.part_char_values VALUES (649, 4, 3, '27', 131);
INSERT INTO public.part_char_values VALUES (650, 4, 3, '21.5', 132);
INSERT INTO public.part_char_values VALUES (651, 4, 3, '24', 133);
INSERT INTO public.part_char_values VALUES (652, 4, 3, '27', 134);
INSERT INTO public.part_char_values VALUES (653, 4, 3, '21.5', 135);
INSERT INTO public.part_char_values VALUES (654, 4, 3, '24', 136);
INSERT INTO public.part_char_values VALUES (655, 4, 3, '27', 137);
INSERT INTO public.part_char_values VALUES (656, 4, 3, '21.5', 138);
INSERT INTO public.part_char_values VALUES (657, 4, 3, '24', 139);
INSERT INTO public.part_char_values VALUES (658, 4, 3, '27', 140);
INSERT INTO public.part_char_values VALUES (659, 4, 3, '21.5', 141);
INSERT INTO public.part_char_values VALUES (660, 4, 3, '24', 142);
INSERT INTO public.part_char_values VALUES (661, 4, 3, '27', 143);
INSERT INTO public.part_char_values VALUES (662, 4, 3, '21.5', 144);
INSERT INTO public.part_char_values VALUES (663, 4, 3, '24', 145);
INSERT INTO public.part_char_values VALUES (664, 4, 3, '27', 146);
INSERT INTO public.part_char_values VALUES (665, 4, 3, '21.5', 147);
INSERT INTO public.part_char_values VALUES (666, 4, 3, '24', 148);
INSERT INTO public.part_char_values VALUES (667, 4, 3, '27', 149);
INSERT INTO public.part_char_values VALUES (668, 4, 3, '21.5', 150);
INSERT INTO public.part_char_values VALUES (669, 4, 3, '24', 151);
INSERT INTO public.part_char_values VALUES (670, 4, 3, '27', 152);
INSERT INTO public.part_char_values VALUES (671, 4, 3, '21.5', 153);
INSERT INTO public.part_char_values VALUES (672, 4, 3, '24', 154);
INSERT INTO public.part_char_values VALUES (673, 4, 3, '27', 155);
INSERT INTO public.part_char_values VALUES (674, 4, 3, '21.5', 156);
INSERT INTO public.part_char_values VALUES (675, 4, 3, '24', 157);
INSERT INTO public.part_char_values VALUES (676, 4, 3, '27', 158);
INSERT INTO public.part_char_values VALUES (677, 4, 3, '21.5', 159);
INSERT INTO public.part_char_values VALUES (678, 4, 3, '24', 160);
INSERT INTO public.part_char_values VALUES (679, 4, 3, '27', 161);
INSERT INTO public.part_char_values VALUES (680, 4, 3, '21.5', 162);
INSERT INTO public.part_char_values VALUES (681, 4, 3, '24', 163);
INSERT INTO public.part_char_values VALUES (682, 4, 3, '27', 164);
INSERT INTO public.part_char_values VALUES (683, 4, 3, '21.5', 165);
INSERT INTO public.part_char_values VALUES (684, 4, 3, '24', 166);
INSERT INTO public.part_char_values VALUES (685, 4, 3, '27', 167);
INSERT INTO public.part_char_values VALUES (686, 4, 3, '21.5', 168);
INSERT INTO public.part_char_values VALUES (687, 4, 3, '24', 169);
INSERT INTO public.part_char_values VALUES (688, 4, 3, '27', 170);
INSERT INTO public.part_char_values VALUES (689, 4, 3, '21.5', 171);
INSERT INTO public.part_char_values VALUES (690, 4, 3, '24', 172);
INSERT INTO public.part_char_values VALUES (691, 4, 3, '27', 173);
INSERT INTO public.part_char_values VALUES (692, 4, 3, '21.5', 174);
INSERT INTO public.part_char_values VALUES (693, 4, 3, '24', 175);
INSERT INTO public.part_char_values VALUES (694, 4, 3, '27', 176);
INSERT INTO public.part_char_values VALUES (695, 4, 3, '21.5', 177);
INSERT INTO public.part_char_values VALUES (696, 4, 3, '24', 178);
INSERT INTO public.part_char_values VALUES (697, 4, 3, '27', 179);
INSERT INTO public.part_char_values VALUES (698, 4, 3, '21.5', 180);
INSERT INTO public.part_char_values VALUES (699, 4, 3, '24', 181);
INSERT INTO public.part_char_values VALUES (700, 4, 3, '27', 182);
INSERT INTO public.part_char_values VALUES (701, 4, 3, '21.5', 183);
INSERT INTO public.part_char_values VALUES (702, 4, 3, '24', 184);
INSERT INTO public.part_char_values VALUES (703, 4, 3, '27', 185);
INSERT INTO public.part_char_values VALUES (704, 4, 3, '21.5', 186);
INSERT INTO public.part_char_values VALUES (705, 4, 3, '24', 187);
INSERT INTO public.part_char_values VALUES (706, 4, 3, '27', 188);
INSERT INTO public.part_char_values VALUES (707, 4, 3, '21.5', 189);
INSERT INTO public.part_char_values VALUES (708, 4, 3, '24', 190);
INSERT INTO public.part_char_values VALUES (709, 4, 3, '27', 191);
INSERT INTO public.part_char_values VALUES (710, 4, 3, '21.5', 192);
INSERT INTO public.part_char_values VALUES (711, 4, 3, '24', 193);
INSERT INTO public.part_char_values VALUES (712, 4, 3, '27', 194);
INSERT INTO public.part_char_values VALUES (713, 4, 3, '21.5', 195);
INSERT INTO public.part_char_values VALUES (714, 4, 3, '24', 196);
INSERT INTO public.part_char_values VALUES (715, 4, 3, '27', 197);
INSERT INTO public.part_char_values VALUES (716, 4, 3, '21.5', 198);
INSERT INTO public.part_char_values VALUES (717, 4, 3, '24', 199);
INSERT INTO public.part_char_values VALUES (718, 4, 3, '27', 200);
INSERT INTO public.part_char_values VALUES (719, 4, 3, '21.5', 201);
INSERT INTO public.part_char_values VALUES (720, 4, 3, '24', 202);
INSERT INTO public.part_char_values VALUES (721, 4, 10, '2560x1440', 103);
INSERT INTO public.part_char_values VALUES (722, 4, 10, '1920x1080', 104);
INSERT INTO public.part_char_values VALUES (723, 4, 10, '2560x1440', 105);
INSERT INTO public.part_char_values VALUES (724, 4, 10, '1920x1080', 106);
INSERT INTO public.part_char_values VALUES (725, 4, 10, '2560x1440', 107);
INSERT INTO public.part_char_values VALUES (726, 4, 10, '1920x1080', 108);
INSERT INTO public.part_char_values VALUES (727, 4, 10, '2560x1440', 109);
INSERT INTO public.part_char_values VALUES (728, 4, 10, '1920x1080', 110);
INSERT INTO public.part_char_values VALUES (729, 4, 10, '2560x1440', 111);
INSERT INTO public.part_char_values VALUES (730, 4, 10, '1920x1080', 112);
INSERT INTO public.part_char_values VALUES (731, 4, 10, '2560x1440', 113);
INSERT INTO public.part_char_values VALUES (732, 4, 10, '1920x1080', 114);
INSERT INTO public.part_char_values VALUES (733, 4, 10, '2560x1440', 115);
INSERT INTO public.part_char_values VALUES (734, 4, 10, '1920x1080', 116);
INSERT INTO public.part_char_values VALUES (735, 4, 10, '2560x1440', 117);
INSERT INTO public.part_char_values VALUES (736, 4, 10, '1920x1080', 118);
INSERT INTO public.part_char_values VALUES (737, 4, 10, '2560x1440', 119);
INSERT INTO public.part_char_values VALUES (738, 4, 10, '1920x1080', 120);
INSERT INTO public.part_char_values VALUES (739, 4, 10, '2560x1440', 121);
INSERT INTO public.part_char_values VALUES (740, 4, 10, '1920x1080', 122);
INSERT INTO public.part_char_values VALUES (741, 4, 10, '2560x1440', 123);
INSERT INTO public.part_char_values VALUES (742, 4, 10, '1920x1080', 124);
INSERT INTO public.part_char_values VALUES (743, 4, 10, '2560x1440', 125);
INSERT INTO public.part_char_values VALUES (744, 4, 10, '1920x1080', 126);
INSERT INTO public.part_char_values VALUES (745, 4, 10, '2560x1440', 127);
INSERT INTO public.part_char_values VALUES (746, 4, 10, '1920x1080', 128);
INSERT INTO public.part_char_values VALUES (747, 4, 10, '2560x1440', 129);
INSERT INTO public.part_char_values VALUES (748, 4, 10, '1920x1080', 130);
INSERT INTO public.part_char_values VALUES (749, 4, 10, '2560x1440', 131);
INSERT INTO public.part_char_values VALUES (750, 4, 10, '1920x1080', 132);
INSERT INTO public.part_char_values VALUES (751, 4, 10, '2560x1440', 133);
INSERT INTO public.part_char_values VALUES (752, 4, 10, '1920x1080', 134);
INSERT INTO public.part_char_values VALUES (753, 4, 10, '2560x1440', 135);
INSERT INTO public.part_char_values VALUES (754, 4, 10, '1920x1080', 136);
INSERT INTO public.part_char_values VALUES (755, 4, 10, '2560x1440', 137);
INSERT INTO public.part_char_values VALUES (756, 4, 10, '1920x1080', 138);
INSERT INTO public.part_char_values VALUES (757, 4, 10, '2560x1440', 139);
INSERT INTO public.part_char_values VALUES (758, 4, 10, '1920x1080', 140);
INSERT INTO public.part_char_values VALUES (759, 4, 10, '2560x1440', 141);
INSERT INTO public.part_char_values VALUES (760, 4, 10, '1920x1080', 142);
INSERT INTO public.part_char_values VALUES (761, 4, 10, '2560x1440', 143);
INSERT INTO public.part_char_values VALUES (762, 4, 10, '1920x1080', 144);
INSERT INTO public.part_char_values VALUES (763, 4, 10, '2560x1440', 145);
INSERT INTO public.part_char_values VALUES (764, 4, 10, '1920x1080', 146);
INSERT INTO public.part_char_values VALUES (765, 4, 10, '2560x1440', 147);
INSERT INTO public.part_char_values VALUES (766, 4, 10, '1920x1080', 148);
INSERT INTO public.part_char_values VALUES (767, 4, 10, '2560x1440', 149);
INSERT INTO public.part_char_values VALUES (768, 4, 10, '1920x1080', 150);
INSERT INTO public.part_char_values VALUES (769, 4, 10, '2560x1440', 151);
INSERT INTO public.part_char_values VALUES (770, 4, 10, '1920x1080', 152);
INSERT INTO public.part_char_values VALUES (771, 4, 10, '2560x1440', 153);
INSERT INTO public.part_char_values VALUES (772, 4, 10, '1920x1080', 154);
INSERT INTO public.part_char_values VALUES (773, 4, 10, '2560x1440', 155);
INSERT INTO public.part_char_values VALUES (774, 4, 10, '1920x1080', 156);
INSERT INTO public.part_char_values VALUES (775, 4, 10, '2560x1440', 157);
INSERT INTO public.part_char_values VALUES (776, 4, 10, '1920x1080', 158);
INSERT INTO public.part_char_values VALUES (777, 4, 10, '2560x1440', 159);
INSERT INTO public.part_char_values VALUES (778, 4, 10, '1920x1080', 160);
INSERT INTO public.part_char_values VALUES (779, 4, 10, '2560x1440', 161);
INSERT INTO public.part_char_values VALUES (780, 4, 10, '1920x1080', 162);
INSERT INTO public.part_char_values VALUES (781, 4, 10, '2560x1440', 163);
INSERT INTO public.part_char_values VALUES (782, 4, 10, '1920x1080', 164);
INSERT INTO public.part_char_values VALUES (783, 4, 10, '2560x1440', 165);
INSERT INTO public.part_char_values VALUES (784, 4, 10, '1920x1080', 166);
INSERT INTO public.part_char_values VALUES (785, 4, 10, '2560x1440', 167);
INSERT INTO public.part_char_values VALUES (786, 4, 10, '1920x1080', 168);
INSERT INTO public.part_char_values VALUES (787, 4, 10, '2560x1440', 169);
INSERT INTO public.part_char_values VALUES (788, 4, 10, '1920x1080', 170);
INSERT INTO public.part_char_values VALUES (789, 4, 10, '2560x1440', 171);
INSERT INTO public.part_char_values VALUES (790, 4, 10, '1920x1080', 172);
INSERT INTO public.part_char_values VALUES (791, 4, 10, '2560x1440', 173);
INSERT INTO public.part_char_values VALUES (792, 4, 10, '1920x1080', 174);
INSERT INTO public.part_char_values VALUES (793, 4, 10, '2560x1440', 175);
INSERT INTO public.part_char_values VALUES (794, 4, 10, '1920x1080', 176);
INSERT INTO public.part_char_values VALUES (795, 4, 10, '2560x1440', 177);
INSERT INTO public.part_char_values VALUES (796, 4, 10, '1920x1080', 178);
INSERT INTO public.part_char_values VALUES (797, 4, 10, '2560x1440', 179);
INSERT INTO public.part_char_values VALUES (798, 4, 10, '1920x1080', 180);
INSERT INTO public.part_char_values VALUES (799, 4, 10, '2560x1440', 181);
INSERT INTO public.part_char_values VALUES (800, 4, 10, '1920x1080', 182);
INSERT INTO public.part_char_values VALUES (801, 4, 10, '2560x1440', 183);
INSERT INTO public.part_char_values VALUES (802, 4, 10, '1920x1080', 184);
INSERT INTO public.part_char_values VALUES (803, 4, 10, '2560x1440', 185);
INSERT INTO public.part_char_values VALUES (804, 4, 10, '1920x1080', 186);
INSERT INTO public.part_char_values VALUES (805, 4, 10, '2560x1440', 187);
INSERT INTO public.part_char_values VALUES (806, 4, 10, '1920x1080', 188);
INSERT INTO public.part_char_values VALUES (807, 4, 10, '2560x1440', 189);
INSERT INTO public.part_char_values VALUES (808, 4, 10, '1920x1080', 190);
INSERT INTO public.part_char_values VALUES (809, 4, 10, '2560x1440', 191);
INSERT INTO public.part_char_values VALUES (810, 4, 10, '1920x1080', 192);
INSERT INTO public.part_char_values VALUES (811, 4, 10, '2560x1440', 193);
INSERT INTO public.part_char_values VALUES (812, 4, 10, '1920x1080', 194);
INSERT INTO public.part_char_values VALUES (813, 4, 10, '2560x1440', 195);
INSERT INTO public.part_char_values VALUES (814, 4, 10, '1920x1080', 196);
INSERT INTO public.part_char_values VALUES (815, 4, 10, '2560x1440', 197);
INSERT INTO public.part_char_values VALUES (816, 4, 10, '1920x1080', 198);
INSERT INTO public.part_char_values VALUES (817, 4, 10, '2560x1440', 199);
INSERT INTO public.part_char_values VALUES (818, 4, 10, '1920x1080', 200);
INSERT INTO public.part_char_values VALUES (819, 4, 10, '2560x1440', 201);
INSERT INTO public.part_char_values VALUES (820, 4, 10, '1920x1080', 202);
INSERT INTO public.part_char_values VALUES (821, 5, 2, 'Epson', 104);
INSERT INTO public.part_char_values VALUES (822, 5, 2, 'Canon', 106);
INSERT INTO public.part_char_values VALUES (823, 5, 2, 'HP', 108);
INSERT INTO public.part_char_values VALUES (824, 5, 2, 'Epson', 110);
INSERT INTO public.part_char_values VALUES (825, 5, 2, 'Canon', 112);
INSERT INTO public.part_char_values VALUES (826, 5, 2, 'HP', 114);
INSERT INTO public.part_char_values VALUES (827, 5, 2, 'Epson', 116);
INSERT INTO public.part_char_values VALUES (828, 5, 2, 'Canon', 118);
INSERT INTO public.part_char_values VALUES (829, 5, 2, 'HP', 120);
INSERT INTO public.part_char_values VALUES (830, 5, 2, 'Epson', 122);
INSERT INTO public.part_char_values VALUES (831, 5, 2, 'Canon', 124);
INSERT INTO public.part_char_values VALUES (832, 5, 2, 'HP', 126);
INSERT INTO public.part_char_values VALUES (833, 5, 2, 'Epson', 128);
INSERT INTO public.part_char_values VALUES (834, 5, 2, 'Canon', 130);
INSERT INTO public.part_char_values VALUES (835, 5, 2, 'HP', 132);
INSERT INTO public.part_char_values VALUES (836, 5, 2, 'Epson', 134);
INSERT INTO public.part_char_values VALUES (837, 5, 2, 'Canon', 136);
INSERT INTO public.part_char_values VALUES (838, 5, 2, 'HP', 138);
INSERT INTO public.part_char_values VALUES (839, 5, 2, 'Epson', 140);
INSERT INTO public.part_char_values VALUES (840, 5, 2, 'Canon', 142);
INSERT INTO public.part_char_values VALUES (841, 5, 2, 'HP', 144);
INSERT INTO public.part_char_values VALUES (842, 5, 2, 'Epson', 146);
INSERT INTO public.part_char_values VALUES (843, 5, 2, 'Canon', 148);
INSERT INTO public.part_char_values VALUES (844, 5, 2, 'HP', 150);
INSERT INTO public.part_char_values VALUES (845, 5, 2, 'Epson', 152);
INSERT INTO public.part_char_values VALUES (846, 5, 2, 'Canon', 154);
INSERT INTO public.part_char_values VALUES (847, 5, 2, 'HP', 156);
INSERT INTO public.part_char_values VALUES (848, 5, 2, 'Epson', 158);
INSERT INTO public.part_char_values VALUES (849, 5, 2, 'Canon', 160);
INSERT INTO public.part_char_values VALUES (850, 5, 2, 'HP', 162);
INSERT INTO public.part_char_values VALUES (851, 5, 2, 'Epson', 164);
INSERT INTO public.part_char_values VALUES (852, 5, 2, 'Canon', 166);
INSERT INTO public.part_char_values VALUES (853, 5, 2, 'HP', 168);
INSERT INTO public.part_char_values VALUES (854, 5, 2, 'Epson', 170);
INSERT INTO public.part_char_values VALUES (855, 5, 2, 'Canon', 172);
INSERT INTO public.part_char_values VALUES (856, 5, 2, 'HP', 174);
INSERT INTO public.part_char_values VALUES (857, 5, 2, 'Epson', 176);
INSERT INTO public.part_char_values VALUES (858, 5, 2, 'Canon', 178);
INSERT INTO public.part_char_values VALUES (859, 5, 2, 'HP', 180);
INSERT INTO public.part_char_values VALUES (860, 5, 2, 'Epson', 182);
INSERT INTO public.part_char_values VALUES (861, 5, 2, 'Canon', 184);
INSERT INTO public.part_char_values VALUES (862, 5, 2, 'HP', 186);
INSERT INTO public.part_char_values VALUES (863, 5, 2, 'Epson', 188);
INSERT INTO public.part_char_values VALUES (864, 5, 2, 'Canon', 190);
INSERT INTO public.part_char_values VALUES (865, 5, 2, 'HP', 192);
INSERT INTO public.part_char_values VALUES (866, 5, 2, 'Epson', 194);
INSERT INTO public.part_char_values VALUES (867, 5, 2, 'Canon', 196);
INSERT INTO public.part_char_values VALUES (868, 5, 2, 'HP', 198);
INSERT INTO public.part_char_values VALUES (869, 5, 2, 'Epson', 200);
INSERT INTO public.part_char_values VALUES (870, 5, 2, 'Canon', 202);
INSERT INTO public.part_char_values VALUES (871, 5, 1, 'PRN-000104', 104);
INSERT INTO public.part_char_values VALUES (872, 5, 1, 'PRN-000106', 106);
INSERT INTO public.part_char_values VALUES (873, 5, 1, 'PRN-000108', 108);
INSERT INTO public.part_char_values VALUES (874, 5, 1, 'PRN-000110', 110);
INSERT INTO public.part_char_values VALUES (875, 5, 1, 'PRN-000112', 112);
INSERT INTO public.part_char_values VALUES (876, 5, 1, 'PRN-000114', 114);
INSERT INTO public.part_char_values VALUES (877, 5, 1, 'PRN-000116', 116);
INSERT INTO public.part_char_values VALUES (878, 5, 1, 'PRN-000118', 118);
INSERT INTO public.part_char_values VALUES (879, 5, 1, 'PRN-000120', 120);
INSERT INTO public.part_char_values VALUES (880, 5, 1, 'PRN-000122', 122);
INSERT INTO public.part_char_values VALUES (881, 5, 1, 'PRN-000124', 124);
INSERT INTO public.part_char_values VALUES (882, 5, 1, 'PRN-000126', 126);
INSERT INTO public.part_char_values VALUES (883, 5, 1, 'PRN-000128', 128);
INSERT INTO public.part_char_values VALUES (884, 5, 1, 'PRN-000130', 130);
INSERT INTO public.part_char_values VALUES (885, 5, 1, 'PRN-000132', 132);
INSERT INTO public.part_char_values VALUES (886, 5, 1, 'PRN-000134', 134);
INSERT INTO public.part_char_values VALUES (887, 5, 1, 'PRN-000136', 136);
INSERT INTO public.part_char_values VALUES (888, 5, 1, 'PRN-000138', 138);
INSERT INTO public.part_char_values VALUES (889, 5, 1, 'PRN-000140', 140);
INSERT INTO public.part_char_values VALUES (890, 5, 1, 'PRN-000142', 142);
INSERT INTO public.part_char_values VALUES (891, 5, 1, 'PRN-000144', 144);
INSERT INTO public.part_char_values VALUES (892, 5, 1, 'PRN-000146', 146);
INSERT INTO public.part_char_values VALUES (893, 5, 1, 'PRN-000148', 148);
INSERT INTO public.part_char_values VALUES (894, 5, 1, 'PRN-000150', 150);
INSERT INTO public.part_char_values VALUES (895, 5, 1, 'PRN-000152', 152);
INSERT INTO public.part_char_values VALUES (896, 5, 1, 'PRN-000154', 154);
INSERT INTO public.part_char_values VALUES (897, 5, 1, 'PRN-000156', 156);
INSERT INTO public.part_char_values VALUES (898, 5, 1, 'PRN-000158', 158);
INSERT INTO public.part_char_values VALUES (899, 5, 1, 'PRN-000160', 160);
INSERT INTO public.part_char_values VALUES (900, 5, 1, 'PRN-000162', 162);
INSERT INTO public.part_char_values VALUES (901, 5, 1, 'PRN-000164', 164);
INSERT INTO public.part_char_values VALUES (902, 5, 1, 'PRN-000166', 166);
INSERT INTO public.part_char_values VALUES (903, 5, 1, 'PRN-000168', 168);
INSERT INTO public.part_char_values VALUES (904, 5, 1, 'PRN-000170', 170);
INSERT INTO public.part_char_values VALUES (905, 5, 1, 'PRN-000172', 172);
INSERT INTO public.part_char_values VALUES (906, 5, 1, 'PRN-000174', 174);
INSERT INTO public.part_char_values VALUES (907, 5, 1, 'PRN-000176', 176);
INSERT INTO public.part_char_values VALUES (908, 5, 1, 'PRN-000178', 178);
INSERT INTO public.part_char_values VALUES (909, 5, 1, 'PRN-000180', 180);
INSERT INTO public.part_char_values VALUES (910, 5, 1, 'PRN-000182', 182);
INSERT INTO public.part_char_values VALUES (911, 5, 1, 'PRN-000184', 184);
INSERT INTO public.part_char_values VALUES (912, 5, 1, 'PRN-000186', 186);
INSERT INTO public.part_char_values VALUES (913, 5, 1, 'PRN-000188', 188);
INSERT INTO public.part_char_values VALUES (914, 5, 1, 'PRN-000190', 190);
INSERT INTO public.part_char_values VALUES (915, 5, 1, 'PRN-000192', 192);
INSERT INTO public.part_char_values VALUES (916, 5, 1, 'PRN-000194', 194);
INSERT INTO public.part_char_values VALUES (917, 5, 1, 'PRN-000196', 196);
INSERT INTO public.part_char_values VALUES (918, 5, 1, 'PRN-000198', 198);
INSERT INTO public.part_char_values VALUES (919, 5, 1, 'PRN-000200', 200);
INSERT INTO public.part_char_values VALUES (920, 5, 1, 'PRN-000202', 202);
INSERT INTO public.part_char_values VALUES (921, 5, 49, 'лазерный', 104);
INSERT INTO public.part_char_values VALUES (922, 5, 49, 'лазерный', 106);
INSERT INTO public.part_char_values VALUES (923, 5, 49, 'лазерный', 108);
INSERT INTO public.part_char_values VALUES (924, 5, 49, 'лазерный', 110);
INSERT INTO public.part_char_values VALUES (925, 5, 49, 'лазерный', 112);
INSERT INTO public.part_char_values VALUES (926, 5, 49, 'лазерный', 114);
INSERT INTO public.part_char_values VALUES (927, 5, 49, 'лазерный', 116);
INSERT INTO public.part_char_values VALUES (928, 5, 49, 'лазерный', 118);
INSERT INTO public.part_char_values VALUES (929, 5, 49, 'лазерный', 120);
INSERT INTO public.part_char_values VALUES (930, 5, 49, 'лазерный', 122);
INSERT INTO public.part_char_values VALUES (931, 5, 49, 'лазерный', 124);
INSERT INTO public.part_char_values VALUES (932, 5, 49, 'лазерный', 126);
INSERT INTO public.part_char_values VALUES (933, 5, 49, 'лазерный', 128);
INSERT INTO public.part_char_values VALUES (934, 5, 49, 'лазерный', 130);
INSERT INTO public.part_char_values VALUES (935, 5, 49, 'лазерный', 132);
INSERT INTO public.part_char_values VALUES (936, 5, 49, 'лазерный', 134);
INSERT INTO public.part_char_values VALUES (937, 5, 49, 'лазерный', 136);
INSERT INTO public.part_char_values VALUES (938, 5, 49, 'лазерный', 138);
INSERT INTO public.part_char_values VALUES (939, 5, 49, 'лазерный', 140);
INSERT INTO public.part_char_values VALUES (940, 5, 49, 'лазерный', 142);
INSERT INTO public.part_char_values VALUES (941, 5, 49, 'лазерный', 144);
INSERT INTO public.part_char_values VALUES (942, 5, 49, 'лазерный', 146);
INSERT INTO public.part_char_values VALUES (943, 5, 49, 'лазерный', 148);
INSERT INTO public.part_char_values VALUES (944, 5, 49, 'лазерный', 150);
INSERT INTO public.part_char_values VALUES (945, 5, 49, 'лазерный', 152);
INSERT INTO public.part_char_values VALUES (946, 5, 49, 'лазерный', 154);
INSERT INTO public.part_char_values VALUES (947, 5, 49, 'лазерный', 156);
INSERT INTO public.part_char_values VALUES (948, 5, 49, 'лазерный', 158);
INSERT INTO public.part_char_values VALUES (949, 5, 49, 'лазерный', 160);
INSERT INTO public.part_char_values VALUES (950, 5, 49, 'лазерный', 162);
INSERT INTO public.part_char_values VALUES (951, 5, 49, 'лазерный', 164);
INSERT INTO public.part_char_values VALUES (952, 5, 49, 'лазерный', 166);
INSERT INTO public.part_char_values VALUES (953, 5, 49, 'лазерный', 168);
INSERT INTO public.part_char_values VALUES (954, 5, 49, 'лазерный', 170);
INSERT INTO public.part_char_values VALUES (955, 5, 49, 'лазерный', 172);
INSERT INTO public.part_char_values VALUES (956, 5, 49, 'лазерный', 174);
INSERT INTO public.part_char_values VALUES (957, 5, 49, 'лазерный', 176);
INSERT INTO public.part_char_values VALUES (958, 5, 49, 'лазерный', 178);
INSERT INTO public.part_char_values VALUES (959, 5, 49, 'лазерный', 180);
INSERT INTO public.part_char_values VALUES (960, 5, 49, 'лазерный', 182);
INSERT INTO public.part_char_values VALUES (961, 5, 49, 'лазерный', 184);
INSERT INTO public.part_char_values VALUES (962, 5, 49, 'лазерный', 186);
INSERT INTO public.part_char_values VALUES (963, 5, 49, 'лазерный', 188);
INSERT INTO public.part_char_values VALUES (964, 5, 49, 'лазерный', 190);
INSERT INTO public.part_char_values VALUES (965, 5, 49, 'лазерный', 192);
INSERT INTO public.part_char_values VALUES (966, 5, 49, 'лазерный', 194);
INSERT INTO public.part_char_values VALUES (967, 5, 49, 'лазерный', 196);
INSERT INTO public.part_char_values VALUES (968, 5, 49, 'лазерный', 198);
INSERT INTO public.part_char_values VALUES (969, 5, 49, 'лазерный', 200);
INSERT INTO public.part_char_values VALUES (970, 5, 49, 'лазерный', 202);
INSERT INTO public.part_char_values VALUES (971, 5, 50, 'черно-белый', 104);
INSERT INTO public.part_char_values VALUES (972, 5, 50, 'черно-белый', 106);
INSERT INTO public.part_char_values VALUES (973, 5, 50, 'черно-белый', 108);
INSERT INTO public.part_char_values VALUES (974, 5, 50, 'черно-белый', 110);
INSERT INTO public.part_char_values VALUES (975, 5, 50, 'черно-белый', 112);
INSERT INTO public.part_char_values VALUES (976, 5, 50, 'черно-белый', 114);
INSERT INTO public.part_char_values VALUES (977, 5, 50, 'черно-белый', 116);
INSERT INTO public.part_char_values VALUES (978, 5, 50, 'черно-белый', 118);
INSERT INTO public.part_char_values VALUES (979, 5, 50, 'черно-белый', 120);
INSERT INTO public.part_char_values VALUES (980, 5, 50, 'черно-белый', 122);
INSERT INTO public.part_char_values VALUES (981, 5, 50, 'черно-белый', 124);
INSERT INTO public.part_char_values VALUES (982, 5, 50, 'черно-белый', 126);
INSERT INTO public.part_char_values VALUES (983, 5, 50, 'черно-белый', 128);
INSERT INTO public.part_char_values VALUES (984, 5, 50, 'черно-белый', 130);
INSERT INTO public.part_char_values VALUES (985, 5, 50, 'черно-белый', 132);
INSERT INTO public.part_char_values VALUES (986, 5, 50, 'черно-белый', 134);
INSERT INTO public.part_char_values VALUES (987, 5, 50, 'черно-белый', 136);
INSERT INTO public.part_char_values VALUES (988, 5, 50, 'черно-белый', 138);
INSERT INTO public.part_char_values VALUES (989, 5, 50, 'черно-белый', 140);
INSERT INTO public.part_char_values VALUES (990, 5, 50, 'черно-белый', 142);
INSERT INTO public.part_char_values VALUES (991, 5, 50, 'черно-белый', 144);
INSERT INTO public.part_char_values VALUES (992, 5, 50, 'черно-белый', 146);
INSERT INTO public.part_char_values VALUES (993, 5, 50, 'черно-белый', 148);
INSERT INTO public.part_char_values VALUES (994, 5, 50, 'черно-белый', 150);
INSERT INTO public.part_char_values VALUES (995, 5, 50, 'черно-белый', 152);
INSERT INTO public.part_char_values VALUES (996, 5, 50, 'черно-белый', 154);
INSERT INTO public.part_char_values VALUES (997, 5, 50, 'черно-белый', 156);
INSERT INTO public.part_char_values VALUES (998, 5, 50, 'черно-белый', 158);
INSERT INTO public.part_char_values VALUES (999, 5, 50, 'черно-белый', 160);
INSERT INTO public.part_char_values VALUES (1000, 5, 50, 'черно-белый', 162);
INSERT INTO public.part_char_values VALUES (1001, 5, 50, 'черно-белый', 164);
INSERT INTO public.part_char_values VALUES (1002, 5, 50, 'черно-белый', 166);
INSERT INTO public.part_char_values VALUES (1003, 5, 50, 'черно-белый', 168);
INSERT INTO public.part_char_values VALUES (1004, 5, 50, 'черно-белый', 170);
INSERT INTO public.part_char_values VALUES (1005, 5, 50, 'черно-белый', 172);
INSERT INTO public.part_char_values VALUES (1006, 5, 50, 'черно-белый', 174);
INSERT INTO public.part_char_values VALUES (1007, 5, 50, 'черно-белый', 176);
INSERT INTO public.part_char_values VALUES (1008, 5, 50, 'черно-белый', 178);
INSERT INTO public.part_char_values VALUES (1009, 5, 50, 'черно-белый', 180);
INSERT INTO public.part_char_values VALUES (1010, 5, 50, 'черно-белый', 182);
INSERT INTO public.part_char_values VALUES (1011, 5, 50, 'черно-белый', 184);
INSERT INTO public.part_char_values VALUES (1012, 5, 50, 'черно-белый', 186);
INSERT INTO public.part_char_values VALUES (1013, 5, 50, 'черно-белый', 188);
INSERT INTO public.part_char_values VALUES (1014, 5, 50, 'черно-белый', 190);
INSERT INTO public.part_char_values VALUES (1015, 5, 50, 'черно-белый', 192);
INSERT INTO public.part_char_values VALUES (1016, 5, 50, 'черно-белый', 194);
INSERT INTO public.part_char_values VALUES (1017, 5, 50, 'черно-белый', 196);
INSERT INTO public.part_char_values VALUES (1018, 5, 50, 'черно-белый', 198);
INSERT INTO public.part_char_values VALUES (1019, 5, 50, 'черно-белый', 200);
INSERT INTO public.part_char_values VALUES (1020, 5, 50, 'черно-белый', 202);

--
-- TOC entry 5168 (class 0 OID 53004)
-- Dependencies: 325
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.roles OVERRIDING SYSTEM VALUE VALUES (4, 'Пользователь');
INSERT INTO public.roles OVERRIDING SYSTEM VALUE VALUES (5, 'Администратор');
INSERT INTO public.roles OVERRIDING SYSTEM VALUE VALUES (6, 'Оператор');

--
-- TOC entry 5158 (class 0 OID 52847)
-- Dependencies: 315
-- Data for Name: spr_char; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.spr_char VALUES (1, 'Модель', 'Модель устройства', NULL);
INSERT INTO public.spr_char VALUES (2, 'Производитель', 'Производитель оборудования', NULL);
INSERT INTO public.spr_char VALUES (7, 'Серийный номер', 'Серийный номер устройства', NULL);
INSERT INTO public.spr_char VALUES (8, 'Инвентарный номер', 'Инвентарный номер', NULL);
INSERT INTO public.spr_char VALUES (9, 'Дата производства', 'Дата производства', NULL);
INSERT INTO public.spr_char VALUES (10, 'Разрешение', 'Разрешение экрана (например: 1920x1080)', NULL);
INSERT INTO public.spr_char VALUES (11, 'Тип памяти', 'Тип памяти (DDR3, DDR4, DDR5)', NULL);
INSERT INTO public.spr_char VALUES (12, 'Тип накопителя', 'Тип накопителя (HDD, SSD, NVMe)', NULL);
INSERT INTO public.spr_char VALUES (47, 'Тип матрицы', 'Тип матрицы монитора', NULL);
INSERT INTO public.spr_char VALUES (48, 'Яркость', 'Яркость монитора', NULL);
INSERT INTO public.spr_char VALUES (49, 'Тип принтера', 'Тип принтера (лазерный, струйный, МФУ)', NULL);
INSERT INTO public.spr_char VALUES (50, 'Цветность', 'Цветность принтера', NULL);
INSERT INTO public.spr_char VALUES (51, 'Производительность печати', 'Скорость печати', NULL);
INSERT INTO public.spr_char VALUES (52, 'Вместимость ИБП', 'Вместимость ИБП в ВА', NULL);
INSERT INTO public.spr_char VALUES (53, 'Время работы', 'Время автономной работы ИБП', NULL);
INSERT INTO public.spr_char VALUES (54, 'Количество ядер', NULL, NULL);
INSERT INTO public.spr_char VALUES (3, 'Диагональ', 'Диагональ экрана', '"');
INSERT INTO public.spr_char VALUES (4, 'Объем памяти', 'Объем оперативной памяти', 'ГБ');
INSERT INTO public.spr_char VALUES (5, 'Объем диска', 'Объем жесткого диска или SSD', 'ГБ');
INSERT INTO public.spr_char VALUES (6, 'Частота процессора', 'Тактовая частота процессора', 'ГГц');
INSERT INTO public.spr_char VALUES (55, 'Частота памяти', NULL, 'МГц');
INSERT INTO public.spr_char VALUES (13, 'Мощность', 'Потребляемая мощность', 'Вт');

--
-- TOC entry 5160 (class 0 OID 52876)
-- Dependencies: 317
-- Data for Name: spr_parts; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.spr_parts VALUES (1, 'Процессор', 'Центральный процессор (CPU)');
INSERT INTO public.spr_parts VALUES (2, 'Оперативная память', 'Модули оперативной памяти (RAM)');
INSERT INTO public.spr_parts VALUES (3, 'Жесткий диск', 'Накопитель данных (HDD/SSD)');
INSERT INTO public.spr_parts VALUES (4, 'Монитор', 'Монитор');
INSERT INTO public.spr_parts VALUES (5, 'Принтер', 'Принтер/МФУ');
INSERT INTO public.spr_parts VALUES (6, 'ИБП', 'Источник бесперебойного питания');
INSERT INTO public.spr_parts VALUES (7, 'Клавиатура', 'Клавиатура');
INSERT INTO public.spr_parts VALUES (8, 'Мышь', 'Компьютерная мышь');
INSERT INTO public.spr_parts VALUES (9, 'Материнская плата', 'Материнская плата');
INSERT INTO public.spr_parts VALUES (10, 'Видеокарта', 'Видеокарта');
INSERT INTO public.spr_parts VALUES (11, 'Блок питания', 'Блок питания');
INSERT INTO public.spr_parts VALUES (12, 'Сетевая карта', 'Сетевая карта');

--
-- TOC entry 5170 (class 0 OID 53020)
-- Dependencies: 327
-- Data for Name: tasks; Type: TABLE DATA; Schema: public; Owner: postgres
--


--
-- TOC entry 5154 (class 0 OID 52818)
-- Dependencies: 311
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.users VALUES (301, 'Иванов Иван Иванович', 'Инженер', 'Отдел разработки', 'ivanov.ii@company.ru', '+7(999)111-11-01', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (302, 'Петров Петр Петрович', 'Программист', 'Отдел разработки', 'petrov.pp@company.ru', '+7(999)111-11-02', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (303, 'Сидоров Сидор Сидорович', 'Тестировщик', 'Отдел разработки', 'sidorov.ss@company.ru', '+7(999)111-11-03', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (304, 'Козлова Анна Сергеевна', 'Дизайнер', 'Отдел маркетинга', 'kozlova.as@company.ru', '+7(999)111-11-04', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (305, 'Смирнов Алексей Владимирович', 'Менеджер проектов', 'Отдел управления', 'smirnov.av@company.ru', '+7(999)111-11-05', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (306, 'Волкова Елена Николаевна', 'Бухгалтер', 'Финансовый отдел', 'volkova.en@company.ru', '+7(999)111-11-06', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (307, 'Новиков Дмитрий Алексеевич', 'Системный администратор', 'IT-отдел', 'novikov.da@company.ru', '+7(999)111-11-07', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (308, 'Морозова Мария Павловна', 'Юрист', 'Юридический отдел', 'morozova.mp@company.ru', '+7(999)111-11-08', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (309, 'Лебедев Сергей Михайлович', 'Инженер', 'Отдел разработки', 'lebedev.sm@company.ru', '+7(999)111-11-09', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (310, 'Соколова Ольга Ивановна', 'Аналитик', 'Отдел аналитики', 'sokolova.oi@company.ru', '+7(999)111-11-10', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (311, 'Павлов Андрей Викторович', 'Программист', 'Отдел разработки', 'pavlov.av@company.ru', '+7(999)111-11-11', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (312, 'Васильева Татьяна Сергеевна', 'HR-менеджер', 'Отдел кадров', 'vasileva.ts@company.ru', '+7(999)111-11-12', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (313, 'Семенов Игорь Петрович', 'Инженер', 'Отдел разработки', 'semenov.ip@company.ru', '+7(999)111-11-13', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (314, 'Голубева Наталья Александровна', 'Маркетолог', 'Отдел маркетинга', 'golubeva.na@company.ru', '+7(999)111-11-14', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (315, 'Виноградов Павел Дмитриевич', 'Программист', 'Отдел разработки', 'vinogradov.pd@company.ru', '+7(999)111-11-15', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (316, 'Федорова Юлия Олеговна', 'Менеджер', 'Отдел продаж', 'fedorova.yo@company.ru', '+7(999)111-11-16', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (317, 'Ильин Максим Сергеевич', 'Системный администратор', 'IT-отдел', 'ilin.ms@company.ru', '+7(999)111-11-17', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (318, 'Михайлова Екатерина Владимировна', 'Дизайнер', 'Отдел маркетинга', 'mihailova.ev@company.ru', '+7(999)111-11-18', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (319, 'Титов Роман Андреевич', 'Инженер', 'Отдел разработки', 'titov.ra@company.ru', '+7(999)111-11-19', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (320, 'Белова Анна Дмитриевна', 'Бухгалтер', 'Финансовый отдел', 'belova.ad@company.ru', '+7(999)111-11-20', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (321, 'Комаров Владимир Игоревич', 'Программист', 'Отдел разработки', 'komarov.vi@company.ru', '+7(999)111-11-21', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (322, 'Орлова Светлана Петровна', 'Аналитик', 'Отдел аналитики', 'orlova.sp@company.ru', '+7(999)111-11-22', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (323, 'Марков Станислав Николаевич', 'Менеджер проектов', 'Отдел управления', 'markov.sn@company.ru', '+7(999)111-11-23', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (324, 'Захарова Валентина Алексеевна', 'Тестировщик', 'Отдел разработки', 'zaharova.va@company.ru', '+7(999)111-11-24', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (325, 'Киселев Артем Максимович', 'Инженер', 'Отдел разработки', 'kiselev.am@company.ru', '+7(999)111-11-25', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (326, 'Макарова Ирина Сергеевна', 'HR-менеджер', 'Отдел кадров', 'makarova.is@company.ru', '+7(999)111-11-26', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (327, 'Борисов Константин Викторович', 'Программист', 'Отдел разработки', 'borisov.kv@company.ru', '+7(999)111-11-27', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (328, 'Ларина Евгения Ивановна', 'Юрист', 'Юридический отдел', 'larina.ei@company.ru', '+7(999)111-11-28', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (329, 'Степанов Григорий Павлович', 'Системный администратор', 'IT-отдел', 'stepanov.gp@company.ru', '+7(999)111-11-29', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (330, 'Рыбакова Надежда Михайловна', 'Маркетолог', 'Отдел маркетинга', 'rybakova.nm@company.ru', '+7(999)111-11-30', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (331, 'Григорьев Артур Александрович', 'Инженер', 'Отдел разработки', 'grigorev.aa@company.ru', '+7(999)111-11-31', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (332, 'Кудрявцева Лилия Олеговна', 'Дизайнер', 'Отдел маркетинга', 'kudryavceva.lo@company.ru', '+7(999)111-11-32', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (333, 'Данилов Егор Романович', 'Программист', 'Отдел разработки', 'danilov.er@company.ru', '+7(999)111-11-33', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (334, 'Жукова Марина Владимировна', 'Бухгалтер', 'Финансовый отдел', 'zhukova.mv@company.ru', '+7(999)111-11-34', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (335, 'Фомин Илья Дмитриевич', 'Менеджер', 'Отдел продаж', 'fomin.id@company.ru', '+7(999)111-11-35', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (336, 'Исаева Вероника Сергеевна', 'Аналитик', 'Отдел аналитики', 'isaeva.vs@company.ru', '+7(999)111-11-36', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (337, 'Журавлев Виктор Андреевич', 'Инженер', 'Отдел разработки', 'zhuravlev.va@company.ru', '+7(999)111-11-37', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (338, 'Тарасова Людмила Петровна', 'Тестировщик', 'Отдел разработки', 'tarasova.lp@company.ru', '+7(999)111-11-38', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (339, 'Савельев Олег Николаевич', 'Системный администратор', 'IT-отдел', 'savelyev.on@company.ru', '+7(999)111-11-39', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (340, 'Филиппова Тамара Алексеевна', 'HR-менеджер', 'Отдел кадров', 'filippova.ta@company.ru', '+7(999)111-11-40', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (341, 'Баранов Денис Максимович', 'Программист', 'Отдел разработки', 'baranov.dm@company.ru', '+7(999)111-11-41', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (342, 'Пономарева Алла Сергеевна', 'Маркетолог', 'Отдел маркетинга', 'ponomareva.as@company.ru', '+7(999)111-11-42', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (343, 'Андреев Никита Викторович', 'Инженер', 'Отдел разработки', 'andreev.nv@company.ru', '+7(999)111-11-43', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (344, 'Никитина Галина Ивановна', 'Юрист', 'Юридический отдел', 'nikitina.gi@company.ru', '+7(999)111-11-44', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (345, 'Сорокин Ростислав Павлович', 'Менеджер проектов', 'Отдел управления', 'sorokin.rp@company.ru', '+7(999)111-11-45', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (346, 'Сергеева Лариса Михайловна', 'Дизайнер', 'Отдел маркетинга', 'sergeeva.lm@company.ru', '+7(999)111-11-46', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (347, 'Ткачев Эдуард Александрович', 'Программист', 'Отдел разработки', 'tkachev.ea@company.ru', '+7(999)111-11-47', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (348, 'Карпова Римма Олеговна', 'Бухгалтер', 'Финансовый отдел', 'karpova.ro@company.ru', '+7(999)111-11-48', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (349, 'Гусев Тимур Романович', 'Инженер', 'Отдел разработки', 'gusev.tr@company.ru', '+7(999)111-11-49', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (350, 'Ефимова Зоя Владимировна', 'Аналитик', 'Отдел аналитики', 'efimova.zv@company.ru', '+7(999)111-11-50', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (351, 'Кузьмин Ян Дмитриевич', 'Программист', 'Отдел разработки', 'kuzmin.yd@company.ru', '+7(999)111-11-51', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (352, 'Зайцева Инна Сергеевна', 'Тестировщик', 'Отдел разработки', 'zayceva.is@company.ru', '+7(999)111-11-52', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (353, 'Романов Валерий Андреевич', 'Системный администратор', 'IT-отдел', 'romanov.va@company.ru', '+7(999)111-11-53', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (354, 'Логинова Нина Петровна', 'Менеджер', 'Отдел продаж', 'loginova.np@company.ru', '+7(999)111-11-54', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (355, 'Власов Игорь Николаевич', 'Инженер', 'Отдел разработки', 'vlasov.in@company.ru', '+7(999)111-11-55', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (356, 'Соловьева Эльвира Алексеевна', 'HR-менеджер', 'Отдел кадров', 'soloveva.ea@company.ru', '+7(999)111-11-56', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (357, 'Егоров Руслан Максимович', 'Программист', 'Отдел разработки', 'egorov.rm@company.ru', '+7(999)111-11-57', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (358, 'Петухова Валерия Сергеевна', 'Маркетолог', 'Отдел маркетинга', 'petuhova.vs@company.ru', '+7(999)111-11-58', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (359, 'Медведев Иван Викторович', 'Инженер', 'Отдел разработки', 'medvedev.iv@company.ru', '+7(999)111-11-59', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (360, 'Крылова Анжела Ивановна', 'Юрист', 'Юридический отдел', 'krylova.ai@company.ru', '+7(999)111-11-60', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (361, 'Казаков Геннадий Павлович', 'Менеджер проектов', 'Отдел управления', 'kazakov.gp@company.ru', '+7(999)111-11-61', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (362, 'Абрамова Любовь Михайловна', 'Дизайнер', 'Отдел маркетинга', 'abramova.lm@company.ru', '+7(999)111-11-62', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (363, 'Орехов Олег Александрович', 'Программист', 'Отдел разработки', 'orehov.oa@company.ru', '+7(999)111-11-63', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (364, 'Суворова Эмма Олеговна', 'Бухгалтер', 'Финансовый отдел', 'suvorova.eo@company.ru', '+7(999)111-11-64', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (365, 'Трофимов Аркадий Романович', 'Инженер', 'Отдел разработки', 'trofimov.ar@company.ru', '+7(999)111-11-65', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (366, 'Леонова Клавдия Владимировна', 'Аналитик', 'Отдел аналитики', 'leonova.kv@company.ru', '+7(999)111-11-66', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (367, 'Бирюков Всеволод Дмитриевич', 'Программист', 'Отдел разработки', 'biryukov.vd@company.ru', '+7(999)111-11-67', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (368, 'Котова Роза Сергеевна', 'Тестировщик', 'Отдел разработки', 'kotova.rs@company.ru', '+7(999)111-11-68', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (369, 'Сидоренко Георгий Андреевич', 'Системный администратор', 'IT-отдел', 'sidorenko.ga@company.ru', '+7(999)111-11-69', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (370, 'Мартынова Ксения Петровна', 'Менеджер', 'Отдел продаж', 'martynova.kp@company.ru', '+7(999)111-11-70', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (371, 'Герасимов Анатолий Николаевич', 'Инженер', 'Отдел разработки', 'gerasimov.an@company.ru', '+7(999)111-11-71', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (372, 'Мельникова Раиса Алексеевна', 'HR-менеджер', 'Отдел кадров', 'melnikova.ra@company.ru', '+7(999)111-11-72', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (373, 'Панов Федор Максимович', 'Программист', 'Отдел разработки', 'panov.fm@company.ru', '+7(999)111-11-73', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (374, 'Родионова Галина Сергеевна', 'Маркетолог', 'Отдел маркетинга', 'rodionova.gs@company.ru', '+7(999)111-11-74', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (375, 'Филатов Юрий Викторович', 'Инженер', 'Отдел разработки', 'filatov.yv@company.ru', '+7(999)111-11-75', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (376, 'Гончарова Наталья Ивановна', 'Юрист', 'Юридический отдел', 'goncharova.ni@company.ru', '+7(999)111-11-76', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (377, 'Краснов Борис Павлович', 'Менеджер проектов', 'Отдел управления', 'krasnov.bp@company.ru', '+7(999)111-11-77', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (378, 'Антонова Елена Михайловна', 'Дизайнер', 'Отдел маркетинга', 'antonova.em@company.ru', '+7(999)111-11-78', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (379, 'Щербаков Вадим Александрович', 'Программист', 'Отдел разработки', 'scherbakov.va@company.ru', '+7(999)111-11-79', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (380, 'Фролова Светлана Олеговна', 'Бухгалтер', 'Финансовый отдел', 'frolova.so@company.ru', '+7(999)111-11-80', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (381, 'Шаров Сергей Романович', 'Инженер', 'Отдел разработки', 'sharov.sr@company.ru', '+7(999)111-11-81', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (382, 'Горбачева Оксана Владимировна', 'Аналитик', 'Отдел аналитики', 'gorbacheva.ov@company.ru', '+7(999)111-11-82', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (383, 'Блохин Дмитрий Дмитриевич', 'Программист', 'Отдел разработки', 'blohin.dd@company.ru', '+7(999)111-11-83', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (384, 'Шилова Валентина Сергеевна', 'Тестировщик', 'Отдел разработки', 'shilova.vs@company.ru', '+7(999)111-11-84', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (385, 'Беляков Владимир Андреевич', 'Системный администратор', 'IT-отдел', 'belyakov.va@company.ru', '+7(999)111-11-85', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (386, 'Полякова Татьяна Петровна', 'Менеджер', 'Отдел продаж', 'polyakova.tp@company.ru', '+7(999)111-11-86', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (387, 'Осипов Олег Николаевич', 'Инженер', 'Отдел разработки', 'osipov.on@company.ru', '+7(999)111-11-87', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (388, 'Лаптева Лидия Алексеевна', 'HR-менеджер', 'Отдел кадров', 'lapteva.la@company.ru', '+7(999)111-11-88', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (389, 'Мамонтов Илья Максимович', 'Программист', 'Отдел разработки', 'mamontov.im@company.ru', '+7(999)111-11-89', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (390, 'Дорофеева Анастасия Сергеевна', 'Маркетолог', 'Отдел маркетинга', 'dorofeeva.as@company.ru', '+7(999)111-11-90', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (391, 'Петровский Станислав Викторович', 'Инженер', 'Отдел разработки', 'petrovsky.sv@company.ru', '+7(999)111-11-91', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (392, 'Козловская Вера Ивановна', 'Юрист', 'Юридический отдел', 'kozlovskaya.vi@company.ru', '+7(999)111-11-92', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (393, 'Воробьев Эдуард Павлович', 'Менеджер проектов', 'Отдел управления', 'vorobev.ep@company.ru', '+7(999)111-11-93', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (394, 'Федосеева Ирина Михайловна', 'Дизайнер', 'Отдел маркетинга', 'fedoseeva.im@company.ru', '+7(999)111-11-94', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (395, 'Носов Антон Александрович', 'Программист', 'Отдел разработки', 'nosov.aa@company.ru', '+7(999)111-11-95', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (396, 'Семенова Мария Олеговна', 'Бухгалтер', 'Финансовый отдел', 'semenova.mo@company.ru', '+7(999)111-11-96', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (397, 'Горшков Николай Романович', 'Инженер', 'Отдел разработки', 'gorshkov.nr@company.ru', '+7(999)111-11-97', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (398, 'Панова Елена Владимировна', 'Аналитик', 'Отдел аналитики', 'panova.ev@company.ru', '+7(999)111-11-98', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (399, 'Голубев Роман Дмитриевич', 'Программист', 'Отдел разработки', 'golubev.rd@company.ru', '+7(999)111-11-99', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);
INSERT INTO public.users VALUES (400, 'Иванова Тамара Сергеевна', 'Тестировщик', 'Отдел разработки', 'ivanova.ts@company.ru', '+7(999)111-11-00', '2025-10-27 11:40:00.596502', NULL, NULL, NULL, NULL, 4);

--
-- TOC entry 5198 (class 0 OID 0)
-- Dependencies: 322
-- Name: arm_history_id_history_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.arm_history_id_history_seq', 1, false);

--
-- TOC entry 5199 (class 0 OID 0)
-- Dependencies: 318
-- Name: arm_id_arm_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.arm_id_arm_seq', 202, true);

--
-- TOC entry 5200 (class 0 OID 0)
-- Dependencies: 328
-- Name: desk_attachments_attach_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.desk_attachments_attach_id_seq', 1, false);

--
-- TOC entry 5201 (class 0 OID 0)
-- Dependencies: 330
-- Name: dic_task_status_id_status_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dic_task_status_id_status_seq', 1, false);

--
-- TOC entry 5202 (class 0 OID 0)
-- Dependencies: 312
-- Name: locations_id_location_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.locations_id_location_seq', 364, true);

--
-- TOC entry 5203 (class 0 OID 0)
-- Dependencies: 320
-- Name: part_char_values_id_part_char_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.part_char_values_id_part_char_seq', 1035, true);

--
-- TOC entry 5204 (class 0 OID 0)
-- Dependencies: 324
-- Name: roles_id_role_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roles_id_role_seq', 6, true);

--
-- TOC entry 5205 (class 0 OID 0)
-- Dependencies: 314
-- Name: spr_char_id_char_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.spr_char_id_char_seq', 55, true);

--
-- TOC entry 5206 (class 0 OID 0)
-- Dependencies: 316
-- Name: spr_parts_id_part_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.spr_parts_id_part_seq', 36, true);

--
-- TOC entry 5207 (class 0 OID 0)
-- Dependencies: 326
-- Name: tasks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tasks_id_seq', 1, false);

--
-- TOC entry 5208 (class 0 OID 0)
-- Dependencies: 310
-- Name: users_id_user_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_user_seq', 400, true);

--
-- TOC entry 4981 (class 2606 OID 52977)
-- Name: arm_history arm_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arm_history
    ADD CONSTRAINT arm_history_pkey PRIMARY KEY (id_history);

--
-- TOC entry 4977 (class 2606 OID 52899)
-- Name: arm arm_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arm
    ADD CONSTRAINT arm_pkey PRIMARY KEY (id_arm);

--
-- TOC entry 4988 (class 2606 OID 53040)
-- Name: desk_attachments desk_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.desk_attachments
    ADD CONSTRAINT desk_attachments_pkey PRIMARY KEY (attach_id);

--
-- TOC entry 4991 (class 2606 OID 53048)
-- Name: dic_task_status dic_task_status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dic_task_status
    ADD CONSTRAINT dic_task_status_pkey PRIMARY KEY (id_status);

--
-- TOC entry 4993 (class 2606 OID 53050)
-- Name: dic_task_status dic_task_status_status_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dic_task_status
    ADD CONSTRAINT dic_task_status_status_name_key UNIQUE (status_name);

--
-- TOC entry 4967 (class 2606 OID 52843)
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id_location);

--
-- TOC entry 4979 (class 2606 OID 52950)
-- Name: part_char_values part_char_values_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.part_char_values
    ADD CONSTRAINT part_char_values_pkey PRIMARY KEY (id_part_char);

--
-- TOC entry 4983 (class 2606 OID 53010)
-- Name: roles roles_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pk PRIMARY KEY (id_role);

--
-- TOC entry 4971 (class 2606 OID 52858)
-- Name: spr_char spr_char_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spr_char
    ADD CONSTRAINT spr_char_name_key UNIQUE (name);

--
-- TOC entry 4973 (class 2606 OID 52856)
-- Name: spr_char spr_char_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spr_char
    ADD CONSTRAINT spr_char_pkey PRIMARY KEY (id_char);

--
-- TOC entry 4975 (class 2606 OID 52886)
-- Name: spr_parts spr_parts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spr_parts
    ADD CONSTRAINT spr_parts_pkey PRIMARY KEY (id_part);

--
-- TOC entry 4986 (class 2606 OID 53029)
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);

--
-- TOC entry 4969 (class 2606 OID 52845)
-- Name: locations uq_location_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT uq_location_name UNIQUE (name);

--
-- TOC entry 4965 (class 2606 OID 52829)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id_user);

--
-- TOC entry 4989 (class 1259 OID 53041)
-- Name: idx_desk_attachments_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_desk_attachments_name ON public.desk_attachments USING btree (name);

--
-- TOC entry 4984 (class 1259 OID 53030)
-- Name: idx_tasks_executor_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tasks_executor_id ON public.tasks USING btree (executor_id);

--
-- TOC entry 5000 (class 2606 OID 52983)
-- Name: arm_history arm_history_changed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arm_history
    ADD CONSTRAINT arm_history_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES public.users(id_user) ON DELETE SET NULL;

--
-- TOC entry 5001 (class 2606 OID 52978)
-- Name: arm_history arm_history_id_arm_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arm_history
    ADD CONSTRAINT arm_history_id_arm_fkey FOREIGN KEY (id_arm) REFERENCES public.arm(id_arm) ON DELETE CASCADE;

--
-- TOC entry 4995 (class 2606 OID 52905)
-- Name: arm arm_id_location_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arm
    ADD CONSTRAINT arm_id_location_fkey FOREIGN KEY (id_location) REFERENCES public.locations(id_location) ON DELETE RESTRICT;

--
-- TOC entry 4996 (class 2606 OID 52900)
-- Name: arm arm_id_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arm
    ADD CONSTRAINT arm_id_user_fkey FOREIGN KEY (id_user) REFERENCES public.users(id_user) ON DELETE SET NULL;

--
-- TOC entry 4997 (class 2606 OID 52998)
-- Name: part_char_values part_char_values_arm_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.part_char_values
    ADD CONSTRAINT part_char_values_arm_fk FOREIGN KEY (id_arm) REFERENCES public.arm(id_arm);

--
-- TOC entry 4998 (class 2606 OID 52953)
-- Name: part_char_values part_char_values_id_arm_part_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.part_char_values
    ADD CONSTRAINT part_char_values_id_arm_part_fkey FOREIGN KEY (id_part) REFERENCES public.spr_parts(id_part) ON DELETE CASCADE;

--
-- TOC entry 4999 (class 2606 OID 52958)
-- Name: part_char_values part_char_values_id_char_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.part_char_values
    ADD CONSTRAINT part_char_values_id_char_fkey FOREIGN KEY (id_char) REFERENCES public.spr_char(id_char) ON DELETE CASCADE;

--
-- TOC entry 5002 (class 2606 OID 53051)
-- Name: tasks tasks_dic_task_status_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_dic_task_status_fk FOREIGN KEY (id_status) REFERENCES public.dic_task_status(id_status);

--
-- TOC entry 5003 (class 2606 OID 53056)
-- Name: tasks tasks_users_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_users_fk FOREIGN KEY (user_id) REFERENCES public.users(id_user);

--
-- TOC entry 4994 (class 2606 OID 53014)
-- Name: users users_roles_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_roles_fk FOREIGN KEY (id_role) REFERENCES public.roles(id_role);

-- Completed on 2025-10-27 16:29:13

--
-- PostgreSQL database dump complete
--

