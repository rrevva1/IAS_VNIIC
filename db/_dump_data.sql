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
-- Data for Name: audit_events; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.audit_events (id, event_time, actor_id, action_type, object_type, object_id, result_status, source_ip, user_agent, request_id, correlation_id, payload, error_message) FROM stdin;
1	2026-05-18 11:22:26.273754+03	1	equipment.update	equipment	65	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
2	2026-05-18 11:24:15.195695+03	1	equipment.reassign	equipment	65	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
3	2026-05-18 11:24:47.449243+03	1	equipment.update	equipment	65	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
4	2026-05-18 11:40:25.478867+03	1	equipment.update	equipment	36	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
5	2026-05-18 11:40:35.210232+03	1	equipment.update	equipment	36	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
6	2026-05-18 11:43:11.869934+03	1	equipment.update	equipment	36	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
7	2026-05-18 11:43:31.399169+03	1	equipment.update	equipment	36	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
8	2026-05-18 11:43:43.387994+03	1	equipment.update	equipment	36	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
9	2026-05-18 11:48:45.047483+03	1	equipment.update	equipment	7	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
10	2026-05-18 11:59:24.489646+03	1	equipment.update	equipment	36	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
11	2026-05-18 11:59:48.965007+03	1	equipment.update	equipment	4	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
12	2026-05-18 12:00:02.513612+03	1	equipment.update	equipment	4	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
13	2026-05-18 12:19:23.621234+03	1	equipment.update	equipment	65	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
14	2026-05-18 12:20:39.908261+03	1	equipment.update	equipment	65	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
15	2026-05-18 12:23:43.752437+03	1	equipment.update	equipment	65	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
16	2026-05-18 12:25:27.757843+03	1	equipment.update	equipment	52	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
17	2026-05-18 16:46:37.54213+03	1	equipment.update	equipment	36	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
18	2026-05-19 15:02:14.817418+03	1	equipment.reassign	equipment	41	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
19	2026-05-19 15:09:47.609827+03	1	equipment.reassign	equipment	63	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
20	2026-05-19 15:10:21.989429+03	1	equipment.update	equipment	63	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
21	2026-05-19 15:16:44.475375+03	1	equipment.update	equipment	63	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
22	2026-05-19 15:16:52.853897+03	1	equipment.update	equipment	63	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
23	2026-05-19 15:17:19.917198+03	1	equipment.update	equipment	63	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
24	2026-05-19 15:17:47.654954+03	1	equipment.update	equipment	4	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
25	2026-05-22 09:34:24.544751+03	1	equipment.update	equipment	2	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
26	2026-05-22 10:37:54.86835+03	1	equipment.update	equipment	4	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	\N	\N	\N	\N
27	2026-05-22 11:00:11.210742+03	1	equipment.reassign	equipment	59	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
28	2026-05-22 11:00:11.210742+03	1	equipment.reassign	equipment	4	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
29	2026-05-22 11:05:57.178989+03	1	equipment.reassign	equipment	4	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
30	2026-05-22 11:05:57.178989+03	1	equipment.reassign	equipment	5	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
31	2026-05-22 11:05:57.178989+03	1	equipment.reassign	equipment	6	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
32	2026-05-22 13:03:32.988227+03	1	equipment.reassign	equipment	41	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
33	2026-05-22 13:03:32.988227+03	1	equipment.reassign	equipment	17	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
34	2026-05-22 13:03:32.988227+03	1	equipment.reassign	equipment	1	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
35	2026-05-22 13:03:32.988227+03	1	equipment.reassign	equipment	9	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
36	2026-05-22 13:03:32.988227+03	1	equipment.reassign	equipment	11	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
37	2026-05-22 13:03:32.988227+03	1	equipment.reassign	equipment	14	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
38	2026-05-22 13:03:32.988227+03	1	equipment.reassign	equipment	3	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
39	2026-05-22 13:03:32.988227+03	1	equipment.reassign	equipment	2	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
40	2026-05-22 13:03:32.988227+03	1	equipment.reassign	equipment	10	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
41	2026-05-22 13:03:32.988227+03	1	equipment.reassign	equipment	12	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
42	2026-05-22 13:03:32.988227+03	1	equipment.reassign	equipment	13	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
43	2026-05-22 13:03:32.988227+03	1	equipment.reassign	equipment	15	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
44	2026-05-22 13:03:32.988227+03	1	equipment.reassign	equipment	16	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
45	2026-05-22 13:03:32.988227+03	1	equipment.reassign	equipment	18	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
46	2026-05-22 13:03:32.988227+03	1	equipment.reassign	equipment	19	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
47	2026-05-22 13:03:32.988227+03	1	equipment.reassign	equipment	42	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
48	2026-05-26 14:23:10.778935+03	1	task.assign_executor	task	1	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":\\"1\\"}"	\N
49	2026-05-26 14:23:25.827156+03	1	task.assign_executor	task	1	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":\\"2\\"}"	\N
50	2026-05-26 14:23:30.338042+03	1	task.assign_executor	task	1	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":\\"1\\"}"	\N
51	2026-05-26 14:24:20.881846+03	1	task.update_comment	task	1	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
52	2026-05-26 14:49:33.23378+03	1	work_task.create	work_task	1	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
53	2026-05-26 14:49:53.761288+03	1	work_task.assign	work_task	1	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
54	2026-05-26 14:49:55.465246+03	1	work_task.assign	work_task	1	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
55	2026-05-26 14:50:00.359426+03	1	work_task.transition	work_task	1	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
56	2026-05-26 14:50:02.727119+03	1	work_task.transition	work_task	1	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
57	2026-05-26 14:50:04.051001+03	1	work_task.transition	work_task	1	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
58	2026-05-26 14:54:31.49847+03	1	work_task.create	work_task	2	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
59	2026-05-26 14:54:31.755015+03	1	work_task.create	work_task	3	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
60	2026-05-26 14:57:01.147474+03	1	work_task.assign	work_task	3	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
61	2026-05-26 14:57:05.363198+03	1	work_task.transition	work_task	3	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
62	2026-05-26 14:57:10.526921+03	1	work_task.transition	work_task	3	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"assigned\\"}"	\N
63	2026-05-26 14:57:14.203263+03	1	work_task.transition	work_task	3	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
64	2026-05-26 14:57:15.098092+03	1	work_task.transition	work_task	3	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
65	2026-05-26 14:57:17.903132+03	1	work_task.transition	work_task	3	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
66	2026-05-26 14:57:22.826052+03	1	work_task.assign	work_task	3	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
67	2026-05-26 14:57:33.489398+03	1	work_task.assign	work_task	2	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
68	2026-05-26 14:59:18.054271+03	1	work_task.assign	work_task	2	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
69	2026-05-26 14:59:25.470441+03	1	work_task.transition	work_task	2	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
70	2026-05-26 14:59:31.788019+03	1	work_task.assign	work_task	2	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
71	2026-05-26 14:59:40.237651+03	1	work_task.transition	work_task	2	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
72	2026-05-26 14:59:52.876428+03	1	work_task.create	work_task	4	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
73	2026-05-26 14:59:53.207879+03	1	work_task.create	work_task	5	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
74	2026-05-26 15:01:59.534966+03	1	work_task.delete	work_task	4	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
75	2026-05-26 15:02:07.030865+03	1	work_task.delete	work_task	5	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
76	2026-05-26 15:02:13.173131+03	1	work_task.create	work_task	6	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
77	2026-05-26 15:03:09.650364+03	1	work_task.create	work_task	7	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
78	2026-05-26 15:04:06.728379+03	1	work_task.assign	work_task	6	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
79	2026-05-26 15:04:17.411206+03	1	work_task.transition	work_task	6	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
80	2026-05-26 15:04:22.754299+03	1	work_task.transition	work_task	3	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"assigned\\"}"	\N
81	2026-05-26 15:04:24.665072+03	1	work_task.transition	work_task	3	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
82	2026-05-26 15:04:27.553257+03	1	work_task.transition	work_task	3	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
83	2026-05-26 15:04:28.869184+03	1	work_task.transition	work_task	3	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
84	2026-05-26 15:07:25.882607+03	1	work_task.assign	work_task	7	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
85	2026-05-26 15:07:45.499751+03	1	work_task.transition	work_task	2	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
86	2026-05-26 15:07:53.029996+03	1	work_task.transition	work_task	1	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
87	2026-05-26 15:07:57.63659+03	1	work_task.transition	work_task	7	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
88	2026-05-26 15:08:10.958981+03	1	work_task.transition	work_task	1	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"assigned\\"}"	\N
89	2026-05-26 15:08:15.679302+03	1	work_task.transition	work_task	1	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
90	2026-05-26 15:08:18.82484+03	1	work_task.transition	work_task	1	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"assigned\\"}"	\N
91	2026-05-26 15:08:28.906855+03	1	work_task.create	work_task	8	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
92	2026-05-26 15:09:37.241193+03	1	work_task.assign	work_task	8	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
93	2026-05-26 15:10:03.600719+03	1	work_task.transition	work_task	8	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
94	2026-05-26 15:11:29.901064+03	1	work_task.transition	work_task	7	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
95	2026-05-26 15:11:33.261187+03	1	work_task.transition	work_task	7	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
96	2026-05-26 15:11:35.733824+03	1	work_task.transition	work_task	2	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
97	2026-05-26 15:11:52.929329+03	1	work_task.create	work_task	9	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
98	2026-05-26 15:11:57.886454+03	1	work_task.assign	work_task	9	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
99	2026-05-26 15:12:04.19728+03	1	work_task.transition	work_task	9	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
100	2026-05-26 15:12:57.107397+03	1	work_task.transition	work_task	1	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
101	2026-05-26 15:13:00.15644+03	1	work_task.transition	work_task	1	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
102	2026-05-26 15:13:03.032993+03	1	work_task.transition	work_task	1	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
103	2026-05-26 15:13:07.03981+03	1	work_task.transition	work_task	1	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
104	2026-05-26 15:21:53.344363+03	1	work_task.transition	work_task	1	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
105	2026-05-26 15:21:56.339542+03	1	work_task.transition	work_task	9	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
106	2026-05-26 15:21:57.723014+03	1	work_task.transition	work_task	1	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
107	2026-05-26 15:21:58.824549+03	1	work_task.transition	work_task	9	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
108	2026-05-26 15:22:03.099019+03	1	work_task.transition	work_task	2	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"assigned\\"}"	\N
109	2026-05-26 15:22:04.613965+03	1	work_task.transition	work_task	6	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"assigned\\"}"	\N
110	2026-05-26 15:22:05.568317+03	1	work_task.transition	work_task	8	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"assigned\\"}"	\N
111	2026-05-26 15:22:06.279942+03	1	work_task.transition	work_task	9	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"assigned\\"}"	\N
112	2026-05-26 15:22:07.280829+03	1	work_task.transition	work_task	1	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"assigned\\"}"	\N
113	2026-05-26 15:22:09.445132+03	1	work_task.transition	work_task	2	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
114	2026-05-26 15:22:11.209937+03	1	work_task.transition	work_task	8	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
115	2026-05-26 15:27:54.126721+03	1	work_task.transition	work_task	9	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
116	2026-05-26 15:27:56.96571+03	1	work_task.transition	work_task	9	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
117	2026-05-26 15:28:01.385129+03	1	work_task.transition	work_task	9	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
118	2026-05-26 15:28:08.597173+03	1	work_task.transition	work_task	3	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
119	2026-05-26 15:28:29.650974+03	1	work_task.transition	work_task	2	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
120	2026-05-26 15:33:47.503703+03	1	work_task.comment	work_task	1	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"comment_id\\":1}"	\N
121	2026-05-26 15:35:00.709259+03	1	work_task.transition	work_task	6	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
122	2026-05-26 15:37:29.440568+03	1	work_task.comment	work_task	6	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"comment_id\\":2}"	\N
123	2026-05-26 15:43:52.690445+03	1	work_task.assign	work_task	10	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
124	2026-05-26 15:46:23.95732+03	1	work_task.transition	work_task	10	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
125	2026-05-26 15:46:29.567711+03	1	work_task.transition	work_task	6	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"assigned\\"}"	\N
126	2026-05-26 15:46:37.329883+03	1	work_task.transition	work_task	10	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"assigned\\"}"	\N
127	2026-05-26 15:46:40.417587+03	1	work_task.transition	work_task	10	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
128	2026-05-26 15:46:43.839055+03	1	work_task.transition	work_task	2	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
129	2026-05-26 15:48:16.74611+03	1	task.delete	task	4	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
130	2026-05-26 15:48:22.519437+03	1	task.delete	task	3	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
131	2026-05-26 15:48:51.32131+03	1	task.delete	task	2	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
132	2026-05-26 15:50:19.878542+03	1	work_task.transition	work_task	8	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"assigned\\"}"	\N
133	2026-05-26 15:50:20.884879+03	1	work_task.transition	work_task	3	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"assigned\\"}"	\N
134	2026-05-26 15:50:23.439687+03	1	work_task.transition	work_task	1	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
135	2026-05-26 15:52:20.864116+03	1	task.delete	task	1	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
136	2026-05-26 15:52:43.693559+03	1	work_task.assign	work_task	11	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
137	2026-05-26 15:54:05.390778+03	1	work_task.transition	work_task	11	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
138	2026-05-26 15:54:11.76213+03	1	work_task.transition	work_task	11	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
139	2026-05-26 16:07:57.967504+03	1	work_task.assign	work_task	12	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
140	2026-05-26 16:12:19.755283+03	1	work_task.assign	work_task	13	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
141	2026-05-26 16:14:45.582025+03	1	work_task.transition	work_task	6	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
142	2026-05-26 16:15:05.645941+03	1	work_task.transition	work_task	11	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
143	2026-05-26 16:16:39.230624+03	1	work_task.transition	work_task	12	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
144	2026-05-26 16:16:43.326034+03	1	work_task.transition	work_task	12	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"assigned\\"}"	\N
145	2026-05-26 16:17:47.349788+03	1	work_task.transition	work_task	12	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
146	2026-05-26 16:17:58.652372+03	1	work_task.transition	work_task	12	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
147	2026-05-26 16:18:10.986566+03	1	work_task.transition	work_task	12	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
148	2026-05-26 16:21:21.872194+03	1	work_task.transition	work_task	3	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
149	2026-05-26 16:21:24.853316+03	1	work_task.transition	work_task	6	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
150	2026-05-26 16:48:28.035072+03	1	user.create	user	19	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
151	2026-05-26 16:51:46.868045+03	1	work_task.comment	work_task	3	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"comment_id\\":3}"	\N
152	2026-05-26 16:52:13.775251+03	1	work_task.delete	work_task	8	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
153	2026-05-26 16:52:17.529098+03	1	work_task.delete	work_task	13	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
154	2026-05-26 16:52:20.731109+03	1	work_task.delete	work_task	3	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
155	2026-05-26 16:52:23.464472+03	1	work_task.delete	work_task	1	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
156	2026-05-26 16:52:26.733606+03	1	work_task.delete	work_task	2	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
157	2026-05-26 16:52:29.825832+03	1	work_task.delete	work_task	10	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
158	2026-05-26 16:52:33.450542+03	1	work_task.delete	work_task	6	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
159	2026-05-26 16:52:38.4899+03	1	work_task.delete	work_task	12	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
160	2026-05-26 16:52:41.805659+03	1	work_task.delete	work_task	11	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
161	2026-05-26 16:52:44.806089+03	1	work_task.delete	work_task	9	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
162	2026-05-26 16:52:47.945389+03	1	work_task.delete	work_task	7	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
163	2026-05-26 16:52:56.686192+03	1	task.delete	task	7	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
164	2026-05-26 16:52:56.69358+03	1	task.delete	task	6	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
165	2026-05-26 16:52:56.701066+03	1	task.delete	task	5	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
166	2026-05-26 16:53:18.970581+03	1	task.assign_executor	task	8	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":19}"	\N
167	2026-05-26 16:53:37.415523+03	1	work_task.comment	work_task	14	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"comment_id\\":4}"	\N
168	2026-05-26 16:53:38.974824+03	1	work_task.transition	work_task	14	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
169	2026-05-26 16:53:43.094714+03	1	work_task.transition	work_task	14	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
170	2026-05-26 16:53:47.799559+03	1	work_task.transition	work_task	14	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
171	2026-05-26 16:53:51.356356+03	1	work_task.transition	work_task	14	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
172	2026-05-26 16:53:57.251981+03	1	work_task.transition	work_task	14	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
173	2026-05-26 16:54:34.585789+03	1	work_task.assign	work_task	15	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
174	2026-05-26 16:54:59.179143+03	1	work_task.transition	work_task	15	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
175	2026-05-26 16:55:00.124768+03	1	work_task.transition	work_task	15	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
176	2026-05-26 17:04:54.668199+03	1	task.assign_executor	task	10	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":19}"	\N
177	2026-05-26 17:15:31.999787+03	1	work_task.transition	work_task	16	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
178	2026-05-26 17:15:35.611954+03	1	work_task.transition	work_task	16	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
179	2026-05-26 17:17:07.641502+03	1	work_task.assign	work_task	17	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
180	2026-05-27 11:05:34.927396+03	1	task.delete	task	11	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
181	2026-05-27 11:05:34.939229+03	1	task.delete	task	10	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
182	2026-05-27 11:05:34.945986+03	1	task.delete	task	9	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
183	2026-05-27 11:05:34.952675+03	1	task.delete	task	8	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
184	2026-05-27 11:05:45.893003+03	1	work_task.delete	work_task	14	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
185	2026-05-27 11:05:50.146786+03	1	work_task.delete	work_task	16	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
186	2026-05-27 11:05:57.12363+03	1	work_task.delete	work_task	15	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
187	2026-05-27 11:06:04.427165+03	1	work_task.delete	work_task	17	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
188	2026-05-27 11:59:26.560372+03	1	work_task.assign	work_task	18	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
189	2026-05-27 11:59:29.739954+03	1	work_task.transition	work_task	18	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
190	2026-05-27 11:59:45.756331+03	1	work_task.transition	work_task	18	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
191	2026-05-27 12:00:12.09634+03	1	work_task.comment	work_task	18	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"comment_id\\":5}"	\N
192	2026-05-27 12:00:23.068664+03	1	work_task.delete	work_task	18	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
193	2026-05-27 12:00:48.7956+03	1	task.delete	task	12	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
194	2026-05-27 12:01:03.645755+03	1	work_task.assign	work_task	19	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
195	2026-05-27 12:01:06.587213+03	1	work_task.transition	work_task	19	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
196	2026-05-27 12:01:07.812341+03	1	work_task.transition	work_task	19	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
197	2026-05-27 12:01:13.024259+03	1	work_task.transition	work_task	19	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
198	2026-05-27 12:01:58.93588+03	1	task.assign_executor	task	14	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":15}"	\N
199	2026-05-27 12:02:05.070631+03	1	work_task.transition	work_task	20	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
200	2026-05-27 12:02:10.077429+03	1	work_task.transition	work_task	20	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
201	2026-05-27 12:02:13.347528+03	1	work_task.transition	work_task	20	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
202	2026-05-27 12:20:54.225055+03	1	task.delete	task	14	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
203	2026-05-27 12:20:54.232507+03	1	task.delete	task	13	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
204	2026-05-27 12:29:38.248097+03	1	task.delete	task	15	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
205	2026-05-27 12:30:07.068624+03	1	work_task.delete	work_task	21	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
206	2026-05-27 12:31:35.88594+03	1	work_task.delete	work_task	22	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
207	2026-05-27 12:31:43.904321+03	1	task.delete	task	16	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
208	2026-05-27 12:36:03.502098+03	1	work_task.delete	work_task	23	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
209	2026-05-27 12:36:09.0997+03	1	task.delete	task	17	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
210	2026-05-27 13:22:59.448687+03	1	work_task.create	work_task	24	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
211	2026-05-27 13:23:11.107101+03	1	work_task.assign	work_task	24	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
212	2026-05-27 13:23:14.046007+03	1	work_task.transition	work_task	24	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
213	2026-05-27 13:23:15.131422+03	1	work_task.transition	work_task	24	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
214	2026-05-27 13:23:19.455184+03	1	work_task.transition	work_task	24	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
215	2026-05-27 13:29:28.971157+03	1	work_task.transition	work_task	24	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
216	2026-05-27 13:34:17.237468+03	1	work_task.transition	work_task	24	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
217	2026-05-27 13:34:18.67105+03	1	work_task.transition	work_task	24	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
218	2026-05-27 13:34:20.086701+03	1	work_task.transition	work_task	24	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
219	2026-05-27 13:34:24.950884+03	1	work_task.transition	work_task	24	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
220	2026-05-27 13:34:43.219845+03	1	work_task.transition	work_task	24	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
221	2026-05-27 13:34:51.937585+03	1	work_task.delete	work_task	19	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
222	2026-05-27 13:34:55.553975+03	1	work_task.delete	work_task	20	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
223	2026-05-27 13:34:58.721175+03	1	work_task.delete	work_task	24	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
224	2026-05-27 14:23:40.85809+03	1	work_task.create	work_task	25	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
225	2026-05-27 14:26:24.890612+03	1	work_task.create	work_task	28	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
226	2026-05-27 14:28:40.13639+03	1	work_task.assign	work_task	27	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
227	2026-05-27 14:28:42.802357+03	1	work_task.transition	work_task	27	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
228	2026-05-27 14:28:44.768059+03	1	work_task.transition	work_task	27	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
229	2026-05-27 14:28:47.163686+03	1	work_task.transition	work_task	27	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
230	2026-05-27 15:34:11.891885+03	1	work_task.assign	work_task	25	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
231	2026-05-27 15:34:14.594515+03	1	work_task.transition	work_task	25	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
232	2026-05-27 15:34:16.982937+03	1	work_task.transition	work_task	25	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
233	2026-05-27 15:36:52.970592+03	1	task.assign_executor	task	18	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":15}"	\N
234	2026-05-27 15:51:28.280102+03	1	work_task.comment	work_task	26	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"comment_id\\":6}"	\N
235	2026-05-27 15:57:54.990354+03	1	work_task.delete	work_task	26	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
236	2026-05-27 16:00:22.297533+03	1	work_task.comment	work_task	28	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"comment_id\\":7}"	\N
237	2026-05-27 16:03:33.750509+03	1	work_task.assign	work_task	28	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
238	2026-05-27 16:04:00.408315+03	1	work_task.comment	work_task	28	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"comment_id\\":8}"	\N
239	2026-05-27 16:04:14.149133+03	1	work_task.comment	work_task	28	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"comment_id\\":9}"	\N
240	2026-05-27 16:04:16.638296+03	1	work_task.comment	work_task	28	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"comment_id\\":10}"	\N
241	2026-05-27 16:23:50.436588+03	1	work_task.create	work_task	29	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
242	2026-05-27 16:23:59.209343+03	1	work_task.create	work_task	30	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
243	2026-05-27 16:24:05.471911+03	1	work_task.create	work_task	31	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
244	2026-05-27 16:24:14.402523+03	1	work_task.create	work_task	32	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
245	2026-05-27 16:26:00.815919+03	1	work_task.create	work_task	33	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
246	2026-05-27 16:26:06.029875+03	1	work_task.create	work_task	34	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
247	2026-05-27 16:27:57.342782+03	1	work_task.assign	work_task	32	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
248	2026-05-27 16:28:07.176487+03	1	work_task.transition	work_task	32	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
249	2026-05-27 16:28:09.927484+03	1	work_task.transition	work_task	28	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
250	2026-05-27 16:48:01.423204+03	1	work_task.create	work_task	35	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
251	2026-05-27 16:56:54.003404+03	1	work_task.transition	work_task	25	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
252	2026-05-27 16:56:55.885256+03	1	work_task.transition	work_task	25	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
253	2026-05-27 16:56:57.019576+03	1	work_task.transition	work_task	25	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
254	2026-05-27 16:57:05.709924+03	1	work_task.comment	work_task	25	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"comment_id\\":11}"	\N
255	2026-05-27 16:57:08.05736+03	1	work_task.comment	work_task	25	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"comment_id\\":12}"	\N
256	2026-05-27 16:57:10.508454+03	1	work_task.comment	work_task	25	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"comment_id\\":13}"	\N
257	2026-05-27 16:57:12.717762+03	1	work_task.comment	work_task	25	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"comment_id\\":14}"	\N
258	2026-05-27 16:57:14.949525+03	1	work_task.comment	work_task	25	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"comment_id\\":15}"	\N
259	2026-05-27 16:57:17.442493+03	1	work_task.comment	work_task	25	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"comment_id\\":16}"	\N
260	2026-05-27 16:57:38.805509+03	1	work_task.transition	work_task	25	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"assigned\\"}"	\N
261	2026-05-27 16:57:50.747288+03	1	work_task.transition	work_task	25	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
262	2026-05-27 17:03:31.345457+03	1	work_task.transition	work_task	28	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
263	2026-05-27 17:03:35.796483+03	1	work_task.assign	work_task	35	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
264	2026-05-27 17:03:37.087836+03	1	work_task.transition	work_task	35	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
265	2026-05-27 17:03:38.122686+03	1	work_task.transition	work_task	35	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
266	2026-05-27 17:03:38.919264+03	1	work_task.transition	work_task	32	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
267	2026-05-27 17:03:39.914739+03	1	work_task.transition	work_task	25	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
268	2026-05-27 17:03:49.458378+03	1	work_task.transition	work_task	25	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
269	2026-05-27 17:03:51.698965+03	1	work_task.transition	work_task	32	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
270	2026-05-27 17:03:53.891827+03	1	work_task.transition	work_task	35	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
271	2026-05-27 17:03:56.339733+03	1	work_task.transition	work_task	28	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
272	2026-05-27 17:06:12.47314+03	1	work_task.assign	work_task	36	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
273	2026-05-27 17:06:15.694632+03	1	work_task.assign	work_task	31	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
274	2026-05-27 17:06:18.140898+03	1	work_task.transition	work_task	36	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
275	2026-05-27 17:06:19.531873+03	1	work_task.transition	work_task	31	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
276	2026-05-27 17:06:20.459446+03	1	work_task.transition	work_task	31	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
277	2026-05-27 17:06:21.502867+03	1	work_task.transition	work_task	36	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
278	2026-05-27 17:06:24.741938+03	1	work_task.transition	work_task	31	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
279	2026-05-27 17:06:26.921924+03	1	work_task.transition	work_task	36	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
280	2026-05-27 17:08:04.08216+03	1	work_task.assign	work_task	34	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
281	2026-05-27 17:08:05.35386+03	1	work_task.transition	work_task	34	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
282	2026-05-27 17:08:06.501711+03	1	work_task.transition	work_task	34	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
283	2026-05-27 17:08:09.21378+03	1	work_task.transition	work_task	34	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
284	2026-05-28 11:11:59.262584+03	1	work_task.assign	work_task	33	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
285	2026-05-28 11:16:08.114141+03	1	work_task.transition	work_task	33	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
286	2026-05-28 11:16:09.014309+03	1	work_task.transition	work_task	33	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
287	2026-05-28 11:16:10.937594+03	1	work_task.transition	work_task	33	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
288	2026-05-28 11:50:07.330519+03	1	equipment.reassign	equipment	78	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
289	2026-05-28 12:13:06.38205+03	1	work_task.assign	work_task	30	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
290	2026-05-28 12:13:07.822369+03	1	work_task.transition	work_task	30	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
291	2026-05-28 12:13:08.872639+03	1	work_task.transition	work_task	30	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
292	2026-05-28 12:13:12.012328+03	1	work_task.assign	work_task	30	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
293	2026-05-28 12:13:14.684712+03	1	work_task.transition	work_task	30	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
294	2026-05-28 12:16:53.36434+03	1	work_task.assign	work_task	29	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
295	2026-05-28 12:16:54.590168+03	1	work_task.transition	work_task	29	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
296	2026-05-28 12:16:55.320853+03	1	work_task.transition	work_task	29	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
297	2026-05-28 12:16:58.283766+03	1	work_task.transition	work_task	29	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
298	2026-05-28 12:18:19.02903+03	1	work_task.create	work_task	37	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
299	2026-05-28 12:18:21.01633+03	1	work_task.transition	work_task	37	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
300	2026-05-28 12:18:21.761381+03	1	work_task.transition	work_task	37	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
301	2026-05-28 12:18:24.594534+03	1	work_task.transition	work_task	37	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
302	2026-05-28 12:18:42.291922+03	1	work_task.create	work_task	38	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
303	2026-05-28 12:18:44.310718+03	1	work_task.transition	work_task	38	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
304	2026-05-28 12:18:45.277197+03	1	work_task.transition	work_task	38	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
305	2026-05-28 12:25:21.729933+03	1	work_task.transition	work_task	38	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
306	2026-05-28 12:26:51.834049+03	1	work_task.create	work_task	39	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
307	2026-05-28 12:30:31.896469+03	1	work_task.create	work_task	40	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
308	2026-05-28 12:30:35.677254+03	1	work_task.assign	work_task	39	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
309	2026-05-28 12:30:46.66436+03	1	work_task.create	work_task	41	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
310	2026-05-28 12:30:48.638562+03	1	work_task.transition	work_task	39	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
311	2026-05-28 12:30:54.426324+03	1	work_task.create	work_task	42	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
312	2026-05-28 12:30:56.792898+03	1	work_task.transition	work_task	41	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
313	2026-05-28 12:30:57.88456+03	1	work_task.transition	work_task	41	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
314	2026-05-28 13:09:53.075531+03	1	equipment.reassign	equipment	80	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
315	2026-05-28 14:35:23.32482+03	1	equipment.reassign	equipment	57	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
316	2026-05-28 14:35:23.32482+03	1	equipment.reassign	equipment	61	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
317	2026-05-28 14:35:23.32482+03	1	equipment.reassign	equipment	56	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
318	2026-05-28 14:35:23.32482+03	1	equipment.reassign	equipment	74	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
319	2026-05-28 14:35:23.32482+03	1	equipment.reassign	equipment	76	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
320	2026-05-28 14:35:23.32482+03	1	equipment.reassign	equipment	59	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
321	2026-05-28 14:36:07.081845+03	1	equipment.reassign	equipment	20	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
322	2026-05-28 14:36:07.081845+03	1	equipment.reassign	equipment	21	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
323	2026-05-28 14:36:07.081845+03	1	equipment.reassign	equipment	22	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
324	2026-05-28 14:37:13.92243+03	1	equipment.reassign	equipment	20	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
325	2026-05-28 14:37:13.92243+03	1	equipment.reassign	equipment	21	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
326	2026-05-28 14:37:13.92243+03	1	equipment.reassign	equipment	22	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
327	2026-05-28 14:40:29.608314+03	1	equipment.reassign	equipment	7	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
328	2026-05-28 14:40:29.608314+03	1	equipment.reassign	equipment	8	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
329	2026-05-28 14:44:54.368727+03	1	equipment.reassign	equipment	66	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
330	2026-05-28 15:00:53.852295+03	1	equipment.reassign	equipment	62	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
331	2026-05-28 15:04:32.794604+03	1	equipment.reassign	equipment	36	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
332	2026-05-28 15:04:32.794604+03	1	equipment.reassign	equipment	37	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
333	2026-05-28 15:04:32.794604+03	1	equipment.reassign	equipment	38	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
334	2026-05-30 11:14:54.1106+03	1	equipment.create	equipment	85	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
335	2026-05-30 11:14:54.341253+03	1	equipment.create	equipment	86	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
336	2026-05-30 11:21:35.190658+03	1	equipment.create	equipment	87	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
337	2026-05-30 11:29:23.524317+03	1	equipment.reassign	equipment	87	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"move_component\\"}"	\N
338	2026-05-30 11:29:23.524317+03	1	equipment.reassign	equipment	87	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"move_component_sync\\",\\"parent_id\\":34}"	\N
339	2026-05-30 11:31:39.646487+03	1	equipment.reassign	equipment	43	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
340	2026-05-30 11:31:39.646487+03	1	equipment.reassign	equipment	20	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
341	2026-05-30 11:31:39.646487+03	1	equipment.reassign	equipment	44	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
342	2026-05-30 11:31:39.646487+03	1	equipment.reassign	equipment	21	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
343	2026-05-30 11:31:39.646487+03	1	equipment.reassign	equipment	22	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
344	2026-05-30 11:54:19.147008+03	1	equipment.update	equipment	82	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
345	2026-05-30 11:55:00.065368+03	1	equipment.update	equipment	82	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
346	2026-05-30 11:55:56.426189+03	1	equipment.update	equipment	66	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
347	2026-05-30 11:57:23.128729+03	1	equipment.update	equipment	4	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
348	2026-05-30 12:12:54.119552+03	1	user.create	user	21	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
349	2026-05-30 12:14:07.912202+03	1	task.assign_executor	task	26	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":19}"	\N
350	2026-05-30 12:14:47.493185+03	1	work_task.transition	work_task	48	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
351	2026-05-30 12:15:02.36857+03	1	work_task.transition	work_task	48	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
352	2026-05-30 12:15:17.478601+03	1	work_task.transition	work_task	48	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
353	2026-05-30 12:16:20.713874+03	1	equipment.reassign	equipment	4	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
354	2026-05-30 12:16:20.713874+03	1	equipment.reassign	equipment	5	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
355	2026-05-30 12:16:20.713874+03	1	equipment.reassign	equipment	6	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
356	2026-05-30 12:17:40.848714+03	1	equipment.update	equipment	4	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
357	2026-05-30 12:33:50.215597+03	1	equipment.update	equipment	63	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
358	2026-05-30 12:34:40.656729+03	1	equipment.reassign	equipment	82	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
359	2026-05-30 12:54:31.320146+03	1	work_task.delete	work_task	47	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
360	2026-05-30 13:00:12.078334+03	1	equipment.update	equipment	23	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
361	2026-05-30 13:00:30.299792+03	1	equipment.archive	equipment	24	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"archive_reason\\":\\"\\"}"	\N
362	2026-05-30 13:02:55.327623+03	1	equipment.archive	equipment	62	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"archive_reason\\":\\"\\"}"	\N
363	2026-05-30 13:13:09.488566+03	1	equipment.update	equipment	65	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
364	2026-05-30 13:22:04.848976+03	1	work_task.transition	work_task	39	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
365	2026-05-30 13:22:07.501339+03	1	work_task.transition	work_task	39	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
366	2026-05-30 13:22:10.478656+03	1	work_task.transition	work_task	41	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
367	2026-05-30 13:47:09.318915+03	1	equipment.update	equipment	23	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
368	2026-05-30 13:49:35.196668+03	1	work_task.comment	work_task	46	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"comment_id\\":17}"	\N
369	2026-05-30 13:49:40.250132+03	1	work_task.assign	work_task	46	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
370	2026-06-01 08:28:38.10936+03	1	equipment.create	equipment	88	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
371	2026-06-01 08:29:17.728328+03	1	equipment.reassign	equipment	88	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"move_component\\"}"	\N
372	2026-06-01 08:29:17.728328+03	1	equipment.reassign	equipment	88	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"move_component_sync\\",\\"parent_id\\":9}"	\N
373	2026-06-01 08:31:11.319597+03	1	equipment.create	equipment	89	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
374	2026-06-01 08:41:35.269234+03	1	equipment.create	equipment	90	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
375	2026-06-01 12:24:14.098881+03	1	work_task.add_executor	work_task	46	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":15}"	\N
376	2026-06-01 12:27:48.570885+03	1	work_task.add_executor	work_task	46	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":1}"	\N
377	2026-06-01 12:29:31.166707+03	1	work_task.remove_executor	work_task	46	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":19}"	\N
378	2026-06-01 12:30:47.626751+03	1	work_task.remove_executor	work_task	46	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":15}"	\N
379	2026-06-01 12:30:58.299739+03	1	work_task.add_executor	work_task	42	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":15}"	\N
380	2026-06-01 12:31:11.866591+03	1	task.assign_executor	task	23	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":15}"	\N
381	2026-06-01 12:33:13.050003+03	1	task.update_comment	task	24	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
382	2026-06-01 12:33:41.714255+03	1	work_task.add_executor	work_task	46	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":19}"	\N
383	2026-06-01 12:35:31.68945+03	1	task.assign_executor	task	25	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":15}"	\N
384	2026-06-01 12:42:56.359207+03	1	work_task.add_executor	work_task	45	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":19}"	\N
385	2026-06-01 12:45:29.463869+03	1	task.update	task	27	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
386	2026-06-01 12:47:34.510897+03	1	work_task.add_executor	work_task	49	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":19}"	\N
387	2026-06-01 12:50:58.079307+03	1	user.update	user	19	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
388	2026-06-01 12:51:36.947938+03	19	task.update	task	24	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
389	2026-06-01 12:51:42.601634+03	19	work_task.transition	work_task	40	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
390	2026-06-01 12:51:51.863521+03	19	work_task.transition	work_task	43	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
391	2026-06-01 12:53:59.603973+03	19	work_task.create	work_task	50	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
392	2026-06-01 12:54:03.52599+03	19	work_task.transition	work_task	50	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
393	2026-06-01 12:59:20.128128+03	19	task.update_comment	task	24	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
394	2026-06-01 13:02:06.417499+03	19	work_task.transition	work_task	40	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
395	2026-06-01 13:02:08.705468+03	19	work_task.transition	work_task	43	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
396	2026-06-01 13:02:11.069564+03	19	work_task.transition	work_task	50	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
397	2026-06-01 13:02:26.62988+03	1	task.assign_executor	task	22	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":15}"	\N
398	2026-06-01 13:02:59.295983+03	1	task.assign_executor	task	28	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":15}"	\N
399	2026-06-01 13:03:14.878315+03	1	work_task.transition	work_task	51	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
400	2026-06-01 13:05:40.81977+03	1	work_task.transition	work_task	46	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
401	2026-06-01 13:05:49.304089+03	1	work_task.remove_executor	work_task	51	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":1}"	\N
402	2026-06-01 13:07:48.361455+03	19	work_task.create	work_task	52	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
403	2026-06-01 13:08:10.384932+03	19	work_task.transition	work_task	46	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
404	2026-06-01 13:09:41.900383+03	19	work_task.comment	work_task	44	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"comment_id\\":18}"	\N
405	2026-06-01 13:10:47.630615+03	19	work_task.transition	work_task	49	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
406	2026-06-01 13:11:26.057693+03	1	work_task.add_executor	work_task	44	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":19}"	\N
407	2026-06-01 13:11:46.678704+03	1	work_task.add_executor	work_task	49	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":1}"	\N
408	2026-06-01 13:11:56.957327+03	1	work_task.add_executor	work_task	45	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":1}"	\N
409	2026-06-01 13:12:06.429075+03	1	work_task.add_executor	work_task	44	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":1}"	\N
410	2026-06-01 13:12:13.930004+03	1	work_task.add_executor	work_task	42	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":1}"	\N
411	2026-06-01 13:12:17.644594+03	1	work_task.transition	work_task	45	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
412	2026-06-01 13:12:21.770756+03	1	work_task.transition	work_task	51	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
413	2026-06-01 13:12:24.989685+03	1	work_task.transition	work_task	49	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
414	2026-06-01 13:12:27.077417+03	1	work_task.transition	work_task	45	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
415	2026-06-01 13:12:31.803144+03	1	work_task.transition	work_task	46	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
416	2026-06-01 13:12:33.964544+03	1	work_task.transition	work_task	42	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
417	2026-06-01 13:12:37.538255+03	1	work_task.transition	work_task	44	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
418	2026-06-01 13:12:38.917598+03	1	work_task.transition	work_task	44	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
419	2026-06-01 13:12:40.501828+03	1	work_task.transition	work_task	42	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
420	2026-06-01 13:12:45.072335+03	1	work_task.transition	work_task	50	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
421	2026-06-01 13:12:47.081173+03	1	work_task.transition	work_task	43	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
422	2026-06-01 13:12:49.386833+03	1	work_task.transition	work_task	40	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
423	2026-06-01 13:12:51.54666+03	1	work_task.transition	work_task	51	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
424	2026-06-01 13:12:53.498172+03	1	work_task.transition	work_task	49	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
425	2026-06-01 13:12:56.122992+03	1	work_task.transition	work_task	45	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
426	2026-06-01 13:12:58.324562+03	1	work_task.transition	work_task	44	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
427	2026-06-01 13:13:00.393465+03	1	work_task.transition	work_task	42	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
428	2026-06-01 13:13:59.522836+03	1	task.delete	task	18	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
429	2026-06-01 13:13:59.530352+03	1	task.delete	task	28	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
430	2026-06-01 13:13:59.53921+03	1	task.delete	task	27	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
431	2026-06-01 13:13:59.545224+03	1	task.delete	task	26	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
432	2026-06-01 13:13:59.552225+03	1	task.delete	task	25	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
433	2026-06-01 13:13:59.557919+03	1	task.delete	task	24	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
434	2026-06-01 13:13:59.561713+03	1	task.delete	task	23	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
435	2026-06-01 13:13:59.566679+03	1	task.delete	task	22	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
436	2026-06-01 13:13:59.573178+03	1	task.delete	task	21	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
437	2026-06-01 13:13:59.57797+03	1	task.delete	task	20	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
438	2026-06-01 13:13:59.582412+03	1	task.delete	task	19	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
439	2026-06-01 13:14:14.772019+03	1	work_task.delete	work_task	52	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
440	2026-06-01 13:14:29.203899+03	1	work_task.transition	work_task	42	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
441	2026-06-01 13:14:36.296554+03	1	work_task.transition	work_task	42	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
442	2026-06-01 13:14:40.45155+03	1	work_task.transition	work_task	42	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
443	2026-06-01 13:18:18.604818+03	19	work_task.transition	work_task	53	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
444	2026-06-01 13:18:22.566812+03	19	work_task.transition	work_task	53	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
445	2026-06-01 13:18:37.760708+03	19	work_task.create	work_task	54	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
446	2026-06-01 13:18:57.244384+03	1	work_task.bulk_confirm	work_task		success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"confirmed\\":1,\\"failed\\":0}"	\N
447	2026-06-01 13:19:33.624474+03	1	work_task.add_executor	work_task	54	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":19}"	\N
448	2026-06-01 13:19:36.989699+03	1	work_task.add_executor	work_task	54	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":15}"	\N
449	2026-06-01 13:20:05.228325+03	19	work_task.transition	work_task	54	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
450	2026-06-01 16:33:42.717603+03	1	equipment.update	equipment	1	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
451	2026-06-01 16:34:13.958939+03	1	equipment.update	equipment	14	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
452	2026-06-01 16:36:19.046351+03	1	work_task.transition	work_task	54	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
453	2026-06-01 16:39:06.121431+03	1	user.create	user	22	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
454	2026-06-01 16:40:53.433987+03	1	user.update	user	10	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
455	2026-06-01 17:25:49.637903+03	1	equipment.move_to_warehouse	equipment	82	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
456	2026-06-01 17:26:37.948539+03	1	equipment.move_to_warehouse	equipment	44	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"action\\":\\"detach_kit_link\\",\\"parent_id\\":43,\\"link_type\\":\\"monitor\\"}"	\N
457	2026-06-01 17:26:37.948539+03	1	equipment.move_to_warehouse	equipment	43	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
458	2026-06-01 17:26:37.948539+03	1	equipment.move_to_warehouse	equipment	44	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
459	2026-06-01 17:27:00.862857+03	1	equipment.move_to_warehouse	equipment	37	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"action\\":\\"detach_kit_link\\",\\"parent_id\\":36,\\"link_type\\":\\"monitor\\"}"	\N
460	2026-06-01 17:27:00.862857+03	1	equipment.move_to_warehouse	equipment	38	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"action\\":\\"detach_kit_link\\",\\"parent_id\\":36,\\"link_type\\":\\"ups\\"}"	\N
461	2026-06-01 17:27:00.862857+03	1	equipment.move_to_warehouse	equipment	36	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
462	2026-06-01 17:27:00.862857+03	1	equipment.move_to_warehouse	equipment	37	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
463	2026-06-01 17:27:00.862857+03	1	equipment.move_to_warehouse	equipment	38	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
464	2026-06-02 08:39:04.979758+03	1	equipment.update	equipment	36	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
465	2026-06-02 08:41:36.409292+03	1	equipment.move_to_warehouse	equipment	63	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
466	2026-06-02 08:44:03.824038+03	1	equipment.move_to_warehouse	equipment	26	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"action\\":\\"detach_kit_link\\",\\"parent_id\\":25,\\"link_type\\":\\"monitor\\"}"	\N
467	2026-06-02 08:44:03.824038+03	1	equipment.move_to_warehouse	equipment	27	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"action\\":\\"detach_kit_link\\",\\"parent_id\\":25,\\"link_type\\":\\"ups\\"}"	\N
468	2026-06-02 08:44:03.824038+03	1	equipment.move_to_warehouse	equipment	25	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
469	2026-06-02 08:44:03.824038+03	1	equipment.move_to_warehouse	equipment	26	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
470	2026-06-02 08:44:03.824038+03	1	equipment.move_to_warehouse	equipment	27	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
471	2026-06-02 09:21:49.335788+03	1	equipment.move_to_warehouse	equipment	21	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"action\\":\\"detach_kit_link\\",\\"parent_id\\":20,\\"link_type\\":\\"monitor\\"}"	\N
472	2026-06-02 09:21:49.335788+03	1	equipment.move_to_warehouse	equipment	22	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"action\\":\\"detach_kit_link\\",\\"parent_id\\":20,\\"link_type\\":\\"ups\\"}"	\N
473	2026-06-02 09:21:49.335788+03	1	equipment.move_to_warehouse	equipment	20	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
474	2026-06-02 09:21:49.335788+03	1	equipment.move_to_warehouse	equipment	21	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
475	2026-06-02 09:21:49.335788+03	1	equipment.move_to_warehouse	equipment	22	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
476	2026-06-03 11:13:42.936732+03	1	equipment.delivery_post	equipment	91	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
477	2026-06-03 11:13:42.936732+03	1	equipment.delivery_post	equipment	92	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
478	2026-06-03 11:13:42.936732+03	1	equipment.delivery_post	equipment	93	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
479	2026-06-03 11:13:42.936732+03	1	equipment.delivery_post	equipment	94	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
480	2026-06-03 11:13:42.936732+03	1	equipment.delivery_post	equipment	95	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
481	2026-06-03 11:13:42.936732+03	1	equipment.delivery_post	equipment	96	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
482	2026-06-03 11:13:42.936732+03	1	equipment.delivery_post	equipment	97	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
483	2026-06-03 11:13:42.936732+03	1	equipment.delivery_post	equipment	98	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
484	2026-06-03 11:13:42.936732+03	1	equipment.delivery_post	equipment	99	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
485	2026-06-03 11:13:42.936732+03	1	equipment.delivery_post	equipment	100	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
486	2026-06-03 11:13:43.455581+03	1	delivery.post	equipment_deliveries	4	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
487	2026-06-03 11:21:00.487877+03	1	equipment.reassign	equipment	93	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
488	2026-07-07 13:16:32.958045+03	1	task.delete	task	33	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
489	2026-07-07 13:16:33.001399+03	1	task.delete	task	32	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
490	2026-07-07 13:16:33.010384+03	1	task.delete	task	31	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
491	2026-07-07 13:16:33.016418+03	1	task.delete	task	30	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
492	2026-07-07 13:16:33.021165+03	1	task.delete	task	29	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
493	2026-07-07 13:16:40.087585+03	1	work_task.bulk_confirm	work_task		success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"confirmed\\":1,\\"failed\\":0}"	\N
494	2026-07-07 13:16:45.325221+03	1	work_task.transition	work_task	58	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
495	2026-07-07 13:16:47.075048+03	1	work_task.transition	work_task	57	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
496	2026-07-07 13:16:48.731199+03	1	work_task.transition	work_task	56	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
497	2026-07-07 13:16:50.37847+03	1	work_task.transition	work_task	55	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
498	2026-07-07 13:16:56.408039+03	1	work_task.transition	work_task	58	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
499	2026-07-07 13:16:57.642832+03	1	work_task.transition	work_task	57	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
500	2026-07-07 13:16:58.587522+03	1	work_task.transition	work_task	56	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
501	2026-07-07 13:16:59.753382+03	1	work_task.transition	work_task	55	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
502	2026-07-07 13:17:02.187765+03	1	work_task.bulk_confirm	work_task		success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"confirmed\\":4,\\"failed\\":0}"	\N
503	2026-07-07 13:18:43.810566+03	1	equipment.update	equipment	66	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
504	2026-07-07 13:19:05.085748+03	1	equipment.update	equipment	34	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
505	2026-07-07 13:19:17.92622+03	1	equipment.update	equipment	35	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
506	2026-07-07 13:19:33.080545+03	1	equipment.update	equipment	78	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
507	2026-07-07 13:19:48.713548+03	1	equipment.update	equipment	41	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
508	2026-07-07 14:34:28.726845+03	1	equipment.update	equipment	33	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
509	2026-07-07 14:35:04.938939+03	1	equipment.update	equipment	23	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
510	2026-07-07 14:39:07.805943+03	1	equipment.update	equipment	23	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
511	2026-07-07 14:42:58.401474+03	1	equipment.update	equipment	23	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
512	2026-07-07 14:45:46.595529+03	1	equipment.update	equipment	23	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
513	2026-07-07 14:54:48.779875+03	1	equipment.delivery_post	equipment	101	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
514	2026-07-07 14:54:48.779875+03	1	equipment.delivery_post	equipment	102	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
515	2026-07-07 14:54:48.779875+03	1	equipment.delivery_post	equipment	103	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
516	2026-07-07 14:54:48.779875+03	1	equipment.delivery_post	equipment	104	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
517	2026-07-07 14:54:48.779875+03	1	equipment.delivery_post	equipment	105	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
518	2026-07-07 14:54:48.779875+03	1	equipment.delivery_post	equipment	106	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
519	2026-07-07 14:54:48.779875+03	1	equipment.delivery_post	equipment	107	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
520	2026-07-07 14:54:48.779875+03	1	equipment.delivery_post	equipment	108	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
521	2026-07-07 14:54:48.779875+03	1	equipment.delivery_post	equipment	109	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
522	2026-07-07 14:54:48.779875+03	1	equipment.delivery_post	equipment	110	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
523	2026-07-07 14:54:48.779875+03	1	equipment.delivery_post	equipment	111	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
524	2026-07-07 14:54:48.779875+03	1	equipment.delivery_post	equipment	112	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
525	2026-07-07 14:54:48.779875+03	1	equipment.delivery_post	equipment	113	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
526	2026-07-07 14:54:48.779875+03	1	equipment.delivery_post	equipment	114	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
527	2026-07-07 14:54:48.779875+03	1	equipment.delivery_post	equipment	115	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
528	2026-07-07 14:54:48.779875+03	1	equipment.delivery_post	equipment	116	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
529	2026-07-07 14:54:48.779875+03	1	equipment.delivery_post	equipment	117	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
530	2026-07-07 14:54:48.779875+03	1	equipment.delivery_post	equipment	118	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
531	2026-07-07 14:54:48.779875+03	1	equipment.delivery_post	equipment	119	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
532	2026-07-07 14:54:48.779875+03	1	equipment.delivery_post	equipment	120	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
533	2026-07-07 14:54:49.515319+03	1	delivery.post	equipment_deliveries	8	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
534	2026-07-07 14:55:38.233748+03	1	equipment.reassign	equipment	111	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"move_component\\"}"	\N
535	2026-07-07 14:55:38.233748+03	1	equipment.reassign	equipment	111	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"move_component_sync\\",\\"parent_id\\":93}"	\N
536	2026-07-07 16:29:34.869043+03	1	equipment.update	equipment	56	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
537	2026-07-07 16:50:53.721549+03	1	equipment.update	equipment	56	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
538	2026-07-09 13:02:16.10583+03	1	license.create	license	1	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"software_id\\":1}"	\N
539	2026-07-09 13:03:22.203876+03	1	license.update	license	1	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"software_id\\":1}"	\N
540	2026-07-09 13:18:59.516115+03	1	license.update	license	1	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"software_id\\":1}"	\N
541	2026-07-09 13:44:59.322611+03	1	equipment.reassign	equipment	65	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
542	2026-07-09 14:00:34.132008+03	1	work_task.transition	work_task	59	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
543	2026-07-09 14:11:38.354117+03	1	equipment.update	equipment	36	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
544	2026-07-09 14:11:39.03719+03	1	equipment.update	equipment	36	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
545	2026-07-09 14:12:22.451001+03	1	equipment.update	equipment	34	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
546	2026-07-09 14:12:23.116578+03	1	equipment.update	equipment	34	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
547	2026-07-09 14:13:51.468933+03	1	equipment.update	equipment	33	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
548	2026-07-09 14:13:52.106655+03	1	equipment.update	equipment	33	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
549	2026-07-09 14:29:34.196271+03	1	equipment.update	equipment	33	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
550	2026-07-09 14:29:34.800172+03	1	equipment.update	equipment	33	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
551	2026-07-09 14:39:24.66963+03	1	work_task.transition	work_task	59	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
552	2026-07-09 14:39:42.131796+03	1	work_task.transition	work_task	59	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"done\\"}"	\N
553	2026-07-09 14:41:49.880944+03	1	equipment.update	equipment	28	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
554	2026-07-09 14:41:50.586748+03	1	equipment.update	equipment	28	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
555	2026-07-09 15:20:11.24916+03	1	equipment.update	equipment	34	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
556	2026-07-09 15:20:12.267692+03	1	equipment.update	equipment	34	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
557	2026-07-10 09:46:49.163844+03	1	equipment.create	equipment	121	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
558	2026-07-10 09:46:49.705615+03	1	equipment.create	equipment	122	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
559	2026-07-10 09:54:36.280163+03	1	user.create	user	23	success	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
560	2026-07-10 10:25:40.454001+03	1	user.create	user	24	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
561	2026-07-10 10:28:18.433161+03	24	work_task.create	work_task	60	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
562	2026-07-10 10:28:26.095793+03	24	work_task.transition	work_task	60	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
563	2026-07-10 10:29:54.278889+03	24	work_task.transition	work_task	60	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
564	2026-07-10 10:30:00.736189+03	24	work_task.bulk_confirm	work_task		success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"confirmed\\":1,\\"failed\\":0}"	\N
565	2026-07-10 10:33:20.628105+03	24	equipment.reassign	equipment	101	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
566	2026-07-10 10:37:26.294551+03	24	equipment.reassign	equipment	116	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"move_component\\"}"	\N
567	2026-07-10 10:37:26.294551+03	24	equipment.reassign	equipment	116	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"move_component_sync\\",\\"parent_id\\":101}"	\N
568	2026-07-10 10:44:55.30153+03	24	equipment.delivery_post	equipment	123	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
569	2026-07-10 10:44:55.30153+03	24	equipment.delivery_post	equipment	124	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
570	2026-07-10 10:44:55.30153+03	24	equipment.delivery_post	equipment	125	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
571	2026-07-10 10:44:55.30153+03	24	equipment.delivery_post	equipment	126	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
572	2026-07-10 10:44:55.30153+03	24	equipment.delivery_post	equipment	127	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
573	2026-07-10 10:44:55.30153+03	24	equipment.delivery_post	equipment	128	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
574	2026-07-10 10:44:55.30153+03	24	equipment.delivery_post	equipment	129	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
575	2026-07-10 10:44:55.30153+03	24	equipment.delivery_post	equipment	130	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
576	2026-07-10 10:44:55.30153+03	24	equipment.delivery_post	equipment	131	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
577	2026-07-10 10:44:55.30153+03	24	equipment.delivery_post	equipment	132	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
578	2026-07-10 10:44:55.30153+03	24	equipment.delivery_post	equipment	133	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
579	2026-07-10 10:44:55.30153+03	24	equipment.delivery_post	equipment	134	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
580	2026-07-10 10:44:55.30153+03	24	equipment.delivery_post	equipment	135	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
581	2026-07-10 10:44:55.30153+03	24	equipment.delivery_post	equipment	136	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
582	2026-07-10 10:44:55.30153+03	24	equipment.delivery_post	equipment	137	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
583	2026-07-10 10:44:55.30153+03	24	equipment.delivery_post	equipment	138	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
584	2026-07-10 10:44:55.30153+03	24	equipment.delivery_post	equipment	139	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
585	2026-07-10 10:44:55.30153+03	24	equipment.delivery_post	equipment	140	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
586	2026-07-10 10:44:55.30153+03	24	equipment.delivery_post	equipment	141	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
587	2026-07-10 10:44:55.30153+03	24	equipment.delivery_post	equipment	142	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
588	2026-07-10 10:44:55.994263+03	24	delivery.post	equipment_deliveries	11	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
589	2026-07-10 10:46:35.454235+03	24	task.assign_executor	task	35	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":23}"	\N
590	2026-07-10 10:47:54.614341+03	24	task.assign_executor	task	36	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":19}"	\N
591	2026-07-10 10:48:16.179039+03	24	task.assign_executor	task	37	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":24}"	\N
592	2026-07-10 10:48:32.366462+03	24	task.assign_executor	task	38	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":22}"	\N
593	2026-07-10 10:48:52.955255+03	24	work_task.transition	work_task	63	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
594	2026-07-10 10:48:54.947701+03	24	work_task.transition	work_task	63	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"assigned\\"}"	\N
595	2026-07-10 10:49:19.8885+03	24	work_task.remove_executor	work_task	61	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":23}"	\N
596	2026-07-10 10:49:25.00405+03	24	work_task.add_executor	work_task	61	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":24}"	\N
597	2026-07-10 10:49:30.134854+03	24	work_task.add_executor	work_task	61	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":22}"	\N
598	2026-07-10 10:49:34.440124+03	24	work_task.transition	work_task	61	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
599	2026-07-10 10:49:45.881478+03	24	work_task.transition	work_task	63	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
600	2026-07-10 10:49:48.182324+03	24	work_task.transition	work_task	63	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"assigned\\"}"	\N
601	2026-07-10 10:49:53.112195+03	24	work_task.transition	work_task	63	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
602	2026-07-10 10:50:15.03071+03	24	work_task.transition	work_task	63	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
603	2026-07-10 10:50:19.195907+03	24	work_task.bulk_confirm	work_task		success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"confirmed\\":1,\\"failed\\":0}"	\N
604	2026-07-10 10:50:39.233301+03	24	work_task.transition	work_task	63	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
605	2026-07-10 10:50:52.769626+03	24	work_task.add_executor	work_task	64	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":24}"	\N
606	2026-07-10 10:50:57.946053+03	24	work_task.add_executor	work_task	64	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":19}"	\N
607	2026-07-10 10:51:57.327635+03	24	user.create	user	25	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
608	2026-07-10 10:53:19.310293+03	24	equipment.reassign	equipment	123	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
609	2026-07-10 10:53:35.77719+03	24	equipment.reassign	equipment	136	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"move_component\\"}"	\N
610	2026-07-10 10:53:35.77719+03	24	equipment.reassign	equipment	136	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"move_component_sync\\",\\"parent_id\\":123}"	\N
611	2026-07-10 10:53:48.987658+03	24	equipment.reassign	equipment	27	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"move_component\\"}"	\N
612	2026-07-10 10:53:48.987658+03	24	equipment.reassign	equipment	27	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"move_component_sync\\",\\"parent_id\\":123}"	\N
613	2026-07-10 10:54:12.0349+03	24	equipment.reassign	equipment	82	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
614	2026-07-10 10:56:19.462848+03	24	equipment.update	equipment	82	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
615	2026-07-10 10:57:04.709521+03	24	equipment.update	equipment	82	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
616	2026-07-10 10:57:39.499104+03	24	equipment.update	equipment	82	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
617	2026-07-10 10:57:59.64634+03	24	equipment.update	equipment	82	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
618	2026-07-10 10:58:14.801996+03	24	equipment.update	equipment	82	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
619	2026-07-10 10:58:35.447691+03	24	equipment.update	equipment	82	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
620	2026-07-10 10:59:11.013082+03	24	equipment.update	equipment	82	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
621	2026-07-10 11:05:09.012982+03	24	equipment.update	equipment	82	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
622	2026-07-10 11:07:31.755264+03	24	equipment.create	equipment	143	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
623	2026-07-10 11:10:43.73192+03	23	task.delete	task	38	success	192.168.206.236	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
624	2026-07-10 11:12:19.436522+03	24	equipment.reassign	equipment	31	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
625	2026-07-10 11:12:19.436522+03	24	equipment.reassign	equipment	32	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
626	2026-07-10 11:12:19.436522+03	24	equipment.reassign	equipment	33	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
627	2026-07-10 11:16:51.398535+03	24	work_task.transition	work_task	64	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
628	2026-07-10 11:16:53.705057+03	24	work_task.transition	work_task	64	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
629	2026-07-10 11:16:58.176956+03	24	work_task.transition	work_task	64	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
630	2026-07-10 11:17:00.13799+03	24	work_task.transition	work_task	64	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"assigned\\"}"	\N
631	2026-07-10 11:17:02.202792+03	24	work_task.transition	work_task	61	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
632	2026-07-10 11:17:05.805765+03	24	work_task.bulk_confirm	work_task		success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"confirmed\\":1,\\"failed\\":0}"	\N
633	2026-07-10 11:17:25.233387+03	24	work_task.transition	work_task	61	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
634	2026-07-10 11:18:09.137188+03	24	work_task.remove_executor	work_task	64	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":24}"	\N
635	2026-07-10 11:18:10.42784+03	24	work_task.remove_executor	work_task	64	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":22}"	\N
636	2026-07-10 11:18:22.169939+03	24	work_task.remove_executor	work_task	64	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":19}"	\N
637	2026-07-10 11:18:25.990363+03	24	work_task.add_executor	work_task	64	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":24}"	\N
638	2026-07-10 11:18:28.619508+03	24	work_task.transition	work_task	64	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
639	2026-07-10 11:19:12.237812+03	24	work_task.create	work_task	65	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
640	2026-07-10 11:20:54.788311+03	24	equipment.update	equipment	82	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
641	2026-07-10 11:21:08.301742+03	24	equipment.update	equipment	82	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
642	2026-07-10 11:23:09.024083+03	24	equipment.update	equipment	82	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
643	2026-07-10 11:25:46.514382+03	24	equipment.update	equipment	121	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
644	2026-07-10 11:31:48.746798+03	1	equipment.update	equipment	65	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
645	2026-07-10 11:43:12.827006+03	1	user.update	user	25	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
646	2026-07-10 11:46:56.228011+03	24	work_task.transition	work_task	66	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
647	2026-07-10 11:47:10.302149+03	24	work_task.transition	work_task	66	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
648	2026-07-10 11:47:19.793074+03	24	work_task.transition	work_task	66	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
649	2026-07-10 11:47:26.193347+03	24	work_task.transition	work_task	66	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"assigned\\"}"	\N
650	2026-07-10 11:51:45.973914+03	24	equipment.update	equipment	65	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
651	2026-07-10 11:52:00.154279+03	24	equipment.update	equipment	65	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
652	2026-07-10 11:54:51.68135+03	24	work_task.transition	work_task	64	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
653	2026-07-10 11:54:57.083445+03	24	work_task.bulk_confirm	work_task		success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"confirmed\\":1,\\"failed\\":0}"	\N
654	2026-07-10 11:57:54.397035+03	24	equipment.update	equipment	46	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
655	2026-07-10 11:59:54.445145+03	24	equipment.update	equipment	46	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
656	2026-07-10 12:04:27.598306+03	24	equipment.update	equipment	46	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
657	2026-07-10 12:15:59.036932+03	24	equipment.reassign	equipment	34	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
658	2026-07-10 12:15:59.036932+03	24	equipment.reassign	equipment	28	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
659	2026-07-10 12:15:59.036932+03	24	equipment.reassign	equipment	29	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
660	2026-07-10 12:15:59.036932+03	24	equipment.reassign	equipment	30	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
661	2026-07-10 12:15:59.036932+03	24	equipment.reassign	equipment	35	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
662	2026-07-10 12:15:59.036932+03	24	equipment.reassign	equipment	87	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
663	2026-07-10 14:07:26.266286+03	1	work_task.remove_executor	work_task	62	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":19}"	\N
664	2026-07-10 14:07:53.020819+03	1	work_task.transition	work_task	62	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
665	2026-07-10 14:09:22.101407+03	1	work_task.transition	work_task	62	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"assigned\\"}"	\N
666	2026-07-10 14:09:35.964487+03	1	work_task.transition	work_task	62	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
667	2026-07-10 14:09:48.580573+03	1	work_task.transition	work_task	62	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"assigned\\"}"	\N
668	2026-07-10 14:17:25.884627+03	1	work_task.remove_executor	work_task	65	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":24}"	\N
669	2026-07-10 14:17:30.197414+03	1	work_task.add_executor	work_task	65	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":1}"	\N
670	2026-07-10 14:17:37.466443+03	1	work_task.transition	work_task	65	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
671	2026-07-10 14:18:29.739638+03	1	work_task.transition	work_task	65	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"assigned\\"}"	\N
672	2026-07-10 14:25:07.03279+03	1	work_task.transition	work_task	65	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
673	2026-07-10 14:25:31.384907+03	1	work_task.transition	work_task	65	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"assigned\\"}"	\N
674	2026-07-10 14:28:51.079252+03	1	work_task.transition	work_task	65	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
675	2026-07-10 14:28:59.869917+03	1	work_task.transition	work_task	65	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"assigned\\"}"	\N
676	2026-07-10 14:29:19.079364+03	1	work_task.transition	work_task	61	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
677	2026-07-10 14:29:20.80175+03	1	work_task.transition	work_task	63	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
678	2026-07-10 14:29:23.914976+03	1	work_task.transition	work_task	62	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
679	2026-07-10 14:29:24.928674+03	1	work_task.transition	work_task	65	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
680	2026-07-10 14:29:26.242744+03	1	work_task.transition	work_task	69	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
681	2026-07-10 14:29:41.840923+03	1	work_task.transition	work_task	62	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"assigned\\"}"	\N
682	2026-07-10 14:29:48.498651+03	24	work_task.transition	work_task	65	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"assigned\\"}"	\N
683	2026-07-10 14:29:49.947032+03	24	work_task.transition	work_task	61	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
684	2026-07-10 14:30:15.239608+03	24	work_task.transition	work_task	66	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
685	2026-07-10 14:30:23.260078+03	24	work_task.transition	work_task	69	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
686	2026-07-10 14:30:32.53366+03	24	work_task.transition	work_task	63	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
687	2026-07-10 14:30:38.786074+03	24	work_task.transition	work_task	67	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
688	2026-07-10 14:30:44.503624+03	24	work_task.transition	work_task	67	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"assigned\\"}"	\N
689	2026-07-10 14:31:09.880777+03	24	work_task.transition	work_task	61	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"assigned\\"}"	\N
690	2026-07-10 14:31:14.334902+03	1	work_task.transition	work_task	66	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
691	2026-07-10 14:31:14.720235+03	24	work_task.transition	work_task	61	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
692	2026-07-10 14:31:14.961783+03	1	work_task.transition	work_task	63	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"pending_review\\"}"	\N
693	2026-07-10 14:31:17.321048+03	1	work_task.transition	work_task	62	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
694	2026-07-10 14:31:18.243267+03	1	work_task.transition	work_task	65	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
695	2026-07-10 14:31:22.646208+03	24	work_task.transition	work_task	62	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"assigned\\"}"	\N
696	2026-07-10 14:31:24.512099+03	24	work_task.transition	work_task	61	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"assigned\\"}"	\N
697	2026-07-10 14:31:26.49039+03	24	work_task.transition	work_task	66	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
698	2026-07-10 14:31:31.729714+03	24	work_task.transition	work_task	65	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"assigned\\"}"	\N
699	2026-07-10 14:31:39.469752+03	24	work_task.transition	work_task	67	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
700	2026-07-10 14:31:45.470762+03	24	work_task.transition	work_task	61	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
701	2026-07-10 14:32:25.892656+03	24	work_task.transition	work_task	66	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"assigned\\"}"	\N
702	2026-07-10 14:32:55.41866+03	24	work_task.transition	work_task	66	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
703	2026-07-10 14:35:12.324306+03	24	work_task.transition	work_task	67	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"assigned\\"}"	\N
704	2026-07-10 15:22:52.850238+03	1	equipment.update	equipment	34	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
705	2026-07-10 15:53:58.138431+03	24	equipment.issue_kit	equipment	20	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"monitor_id\\":37,\\"ups_id\\":22,\\"user_id\\":3,\\"location_id\\":4}"	\N
706	2026-07-10 15:59:40.546234+03	1	equipment.move_to_warehouse	equipment	32	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"action\\":\\"detach_kit_link\\",\\"parent_id\\":31,\\"link_type\\":\\"monitor\\"}"	\N
707	2026-07-10 15:59:40.546234+03	1	equipment.move_to_warehouse	equipment	33	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"action\\":\\"detach_kit_link\\",\\"parent_id\\":31,\\"link_type\\":\\"ups\\"}"	\N
708	2026-07-10 15:59:40.546234+03	1	equipment.move_to_warehouse	equipment	31	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
709	2026-07-10 15:59:40.546234+03	1	equipment.move_to_warehouse	equipment	32	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
710	2026-07-10 15:59:40.546234+03	1	equipment.move_to_warehouse	equipment	33	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
711	2026-07-10 16:00:34.747588+03	1	equipment.issue_kit	equipment	43	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"monitor_id\\":44,\\"ups_id\\":38,\\"user_id\\":8,\\"location_id\\":9}"	\N
712	2026-07-10 16:01:06.462548+03	1	equipment.move_to_warehouse	equipment	44	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"action\\":\\"detach_kit_link\\",\\"parent_id\\":43,\\"link_type\\":\\"monitor\\"}"	\N
713	2026-07-10 16:01:06.462548+03	1	equipment.move_to_warehouse	equipment	38	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"action\\":\\"detach_kit_link\\",\\"parent_id\\":43,\\"link_type\\":\\"ups\\"}"	\N
714	2026-07-10 16:01:06.462548+03	1	equipment.move_to_warehouse	equipment	43	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
715	2026-07-10 16:01:06.462548+03	1	equipment.move_to_warehouse	equipment	44	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
716	2026-07-10 16:01:06.462548+03	1	equipment.move_to_warehouse	equipment	38	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
717	2026-07-10 16:04:44.243972+03	1	equipment.issue_kit	equipment	31	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"monitor_id\\":118,\\"ups_id\\":33,\\"user_id\\":8,\\"location_id\\":4}"	\N
718	2026-07-10 16:05:28.947397+03	1	work_task.transition	work_task	65	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"in_progress\\"}"	\N
719	2026-07-14 11:25:48.908708+03	24	equipment.reassign	equipment	45	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
720	2026-07-14 11:25:48.908708+03	24	equipment.reassign	equipment	46	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
721	2026-07-14 11:26:30.547297+03	24	equipment.reassign	equipment	62	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
722	2026-07-14 11:26:30.547297+03	24	equipment.reassign	equipment	80	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
723	2026-07-14 11:37:01.017999+03	1	task.assign_executor	task	41	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"executor_id\\":15}"	\N
724	2026-07-14 11:37:12.656785+03	1	work_task.bulk_confirm	work_task		success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"confirmed\\":2,\\"failed\\":0}"	\N
725	2026-07-14 11:42:26.601773+03	1	equipment.update	equipment	45	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
726	2026-07-14 13:36:09.318742+03	1	equipment.create	equipment	144	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
727	2026-07-14 13:49:34.220518+03	1	user.update	user	22	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
728	2026-07-14 13:49:39.933812+03	1	user.update	user	22	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
729	2026-07-14 14:07:58.359757+03	24	equipment.replace_from_warehouse	equipment	118	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"old_id\\":118,\\"new_id\\":26,\\"kind\\":\\"monitor\\",\\"replaced_status_id\\":3}"	\N
730	2026-07-14 14:07:58.359757+03	24	equipment.replace_from_warehouse	equipment	26	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"old_id\\":118,\\"new_id\\":26,\\"kind\\":\\"monitor\\"}"	\N
731	2026-07-14 14:09:45.741549+03	24	equipment.update	equipment	118	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
732	2026-07-14 14:13:49.876214+03	24	work_task.transition	work_task	65	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"status_code\\":\\"assigned\\"}"	\N
733	2026-07-14 14:15:03.599701+03	24	equipment.update	equipment	118	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
734	2026-07-14 14:15:44.681484+03	24	equipment.replace_from_warehouse	equipment	37	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"old_id\\":37,\\"new_id\\":21,\\"kind\\":\\"monitor\\",\\"replaced_status_id\\":0}"	\N
735	2026-07-14 14:15:44.681484+03	24	equipment.replace_from_warehouse	equipment	21	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"old_id\\":37,\\"new_id\\":21,\\"kind\\":\\"monitor\\"}"	\N
736	2026-07-14 14:17:01.800909+03	24	equipment.replace_from_warehouse	equipment	7	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"old_id\\":7,\\"new_id\\":36,\\"kind\\":\\"host\\",\\"replaced_status_id\\":6}"	\N
737	2026-07-14 14:17:01.800909+03	24	equipment.replace_from_warehouse	equipment	36	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"old_id\\":7,\\"new_id\\":36,\\"kind\\":\\"host\\"}"	\N
738	2026-07-14 14:17:28.764384+03	24	equipment.update	equipment	37	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	\N	\N
739	2026-07-14 14:27:08.503842+03	24	equipment.replace_from_warehouse	equipment	47	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"old_id\\":47,\\"new_id\\":91,\\"kind\\":\\"host\\",\\"replaced_status_id\\":6}"	\N
740	2026-07-14 14:27:08.503842+03	24	equipment.replace_from_warehouse	equipment	91	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"old_id\\":47,\\"new_id\\":91,\\"kind\\":\\"host\\"}"	\N
741	2026-07-15 11:18:52.41132+03	1	equipment.update	equipment	8	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
742	2026-07-15 11:19:00.046259+03	1	equipment.update	equipment	8	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
743	2026-07-15 11:30:16.117405+03	1	equipment.reassign	equipment	26	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
744	2026-07-15 11:30:55.314851+03	1	equipment.reassign	equipment	31	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
745	2026-07-15 11:30:55.314851+03	1	equipment.reassign	equipment	33	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"mode\\":\\"reassign\\"}"	\N
746	2026-07-15 11:36:05.304514+03	1	equipment.create	equipment	145	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
747	2026-07-15 11:37:21.336669+03	1	equipment.issue_from_warehouse	equipment	20	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"component_id\\":133,\\"kind\\":\\"monitor\\"}"	\N
748	2026-07-15 11:37:21.338856+03	1	equipment.issue_from_warehouse	equipment	133	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"host_id\\":20,\\"kind\\":\\"monitor\\"}"	\N
749	2026-07-15 11:40:13.624337+03	1	equipment.move_to_warehouse	equipment	143	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
750	2026-07-15 11:49:25.458434+03	1	equipment.issue_from_warehouse	equipment	36	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"component_id\\":143,\\"kind\\":\\"ups\\"}"	\N
751	2026-07-15 11:49:25.459924+03	1	equipment.issue_from_warehouse	equipment	143	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"host_id\\":36,\\"kind\\":\\"ups\\"}"	\N
752	2026-07-15 11:59:05.903897+03	24	equipment.issue_from_warehouse	equipment	36	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"component_id\\":37,\\"kind\\":\\"monitor\\"}"	\N
753	2026-07-15 11:59:05.905386+03	24	equipment.issue_from_warehouse	equipment	37	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"host_id\\":36,\\"kind\\":\\"monitor\\"}"	\N
754	2026-07-15 11:59:31.296174+03	24	equipment.issue_from_warehouse	equipment	28	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"component_id\\":118,\\"kind\\":\\"monitor\\"}"	\N
755	2026-07-15 11:59:31.297574+03	24	equipment.issue_from_warehouse	equipment	118	success	192.168.206.250	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 YaBrowser/26.6.0.0 Safari/537.36	\N	\N	"{\\"host_id\\":28,\\"kind\\":\\"monitor\\"}"	\N
756	2026-07-15 12:02:45.591156+03	1	equipment.update	equipment	51	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
757	2026-07-15 12:03:21.823483+03	1	equipment.update	equipment	66	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
758	2026-07-15 13:03:10.430025+03	1	equipment.move_to_warehouse	equipment	8	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	"{\\"action\\":\\"detach_kit_link\\",\\"parent_id\\":36,\\"link_type\\":\\"monitor\\"}"	\N
759	2026-07-15 13:03:10.430025+03	1	equipment.move_to_warehouse	equipment	8	success	192.168.206.253	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 YaBrowser/26.4.0.0 Safari/537.36	\N	\N	\N	\N
\.


--
-- Data for Name: desk_attachments; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.desk_attachments (id, storage_path, original_name, file_extension, mime_type, size_bytes, checksum_sha256, uploaded_by, uploaded_at, is_deleted, deleted_at, deleted_by) FROM stdin;
6	/uploads/equipment/1783424064_6a4ce440ed9d10.34539802_photo_4_2026-07-07_14-33-50.jpg	photo_4_2026-07-07_14-33-50.jpg	jpg	image/jpeg	131797	\N	1	2026-07-07 13:34:24+03	f	\N	\N
\.


--
-- Data for Name: dic_equipment_status; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.dic_equipment_status (id, status_code, status_name, sort_order, is_final, is_archived, created_at, updated_at) FROM stdin;
1	in_use	В эксплуатации	10	f	f	2026-02-12 11:12:45.835301+03	2026-02-12 11:12:45.835301+03
3	in_repair	В ремонте	30	f	f	2026-02-12 11:12:45.835301+03	2026-02-12 11:12:45.835301+03
4	writeoff	Списано	40	t	f	2026-02-12 11:12:45.835301+03	2026-02-12 11:12:45.835301+03
6	faulty	Неисправен	50	f	f	2026-07-14 14:14:21.319019+03	2026-07-14 14:14:21.319019+03
\.


--
-- Data for Name: dic_task_status; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.dic_task_status (id, status_code, status_name, sort_order, is_final, is_archived, created_at, updated_at) FROM stdin;
1	new	Новая	10	f	f	2026-02-12 11:12:45.835301+03	2026-02-12 11:12:45.835301+03
2	in_progress	В работе	20	f	f	2026-02-12 11:12:45.835301+03	2026-02-12 11:12:45.835301+03
3	on_hold	На паузе	30	f	f	2026-02-12 11:12:45.835301+03	2026-02-12 11:12:45.835301+03
5	closed	Закрыта	50	t	f	2026-02-12 11:12:45.835301+03	2026-02-12 11:12:45.835301+03
6	cancelled	Отменена	60	t	f	2026-02-12 11:12:45.835301+03	2026-02-12 11:12:45.835301+03
7	executor_assigned	Назначен исполнитель	15	f	f	2026-05-26 16:11:26.644705+03	2026-05-26 16:52:10.121378+03
4	resolved	Выполнена	40	t	f	2026-02-12 11:12:45.835301+03	2026-05-26 16:52:10.121378+03
\.


--
-- Data for Name: dic_work_task_status; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.dic_work_task_status (id, status_code, status_name, sort_order, timeline_step, is_final, is_archived, created_at, updated_at) FROM stdin;
1	queue	Очередь	10	1	f	f	2026-05-26 14:44:19	2026-05-26 14:44:19
2	assigned	Назначена	20	2	f	f	2026-05-26 14:44:19	2026-05-26 14:44:19
3	in_progress	В работе	30	3	f	f	2026-05-26 14:44:19	2026-05-26 14:44:19
6	cancelled	Отменена	60	0	t	f	2026-05-26 14:44:19	2026-05-26 14:44:19
4	pending_review	Выполнена	40	4	f	f	2026-05-26 14:44:19	2026-05-26 14:44:19
5	done	Закрыта	50	5	t	f	2026-05-26 14:44:19	2026-05-26 14:44:19
\.


--
-- Data for Name: equip_history; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.equip_history (id, equipment_id, event_type, old_value, new_value, changed_by, changed_at, comment) FROM stdin;
1	65	move	"{\\"location_id\\":8}"	"{\\"location_id\\":\\"8\\"}"	1	2026-05-18 11:22:26.190309+03	\N
2	65	assign	"{\\"responsible_user_id\\":17}"	"{\\"responsible_user_id\\":\\"17\\"}"	1	2026-05-18 11:22:26.212754+03	\N
3	65	status_change	"{\\"status_id\\":1}"	"{\\"status_id\\":\\"4\\"}"	1	2026-05-18 11:22:26.261124+03	\N
4	65	assign	"{\\"responsible_user_id\\":17}"	"{\\"responsible_user_id\\":9}"	1	2026-05-18 11:24:15.195695+03	\N
5	65	move	"{\\"location_id\\":8}"	"{\\"location_id\\":2}"	1	2026-05-18 11:24:15.195695+03	\N
6	65	status_change	"{\\"status_id\\":4}"	"{\\"status_id\\":1}"	1	2026-05-18 11:24:15.195695+03	\N
7	65	move	"{\\"location_id\\":2}"	"{\\"location_id\\":\\"2\\"}"	1	2026-05-18 11:24:47.386142+03	\N
8	65	assign	"{\\"responsible_user_id\\":9}"	"{\\"responsible_user_id\\":\\"9\\"}"	1	2026-05-18 11:24:47.398946+03	\N
9	65	status_change	"{\\"status_id\\":1}"	"{\\"status_id\\":\\"4\\"}"	1	2026-05-18 11:24:47.447169+03	\N
10	36	move	"{\\"location_id\\":2}"	"{\\"location_id\\":\\"2\\"}"	1	2026-05-18 11:40:25.410101+03	\N
11	36	assign	"{\\"responsible_user_id\\":10}"	"{\\"responsible_user_id\\":\\"10\\"}"	1	2026-05-18 11:40:25.423194+03	\N
12	36	status_change	"{\\"status_id\\":1}"	"{\\"status_id\\":\\"1\\"}"	1	2026-05-18 11:40:25.467625+03	\N
13	36	move	"{\\"location_id\\":2}"	"{\\"location_id\\":\\"2\\"}"	1	2026-05-18 11:40:35.147777+03	\N
14	36	assign	"{\\"responsible_user_id\\":10}"	"{\\"responsible_user_id\\":\\"10\\"}"	1	2026-05-18 11:40:35.161583+03	\N
15	36	status_change	"{\\"status_id\\":1}"	"{\\"status_id\\":\\"1\\"}"	1	2026-05-18 11:40:35.208476+03	\N
16	36	move	"{\\"location_id\\":2}"	"{\\"location_id\\":\\"2\\"}"	1	2026-05-18 11:43:11.814283+03	\N
17	36	assign	"{\\"responsible_user_id\\":10}"	"{\\"responsible_user_id\\":\\"10\\"}"	1	2026-05-18 11:43:11.826671+03	\N
18	36	status_change	"{\\"status_id\\":1}"	"{\\"status_id\\":\\"1\\"}"	1	2026-05-18 11:43:11.868208+03	\N
19	36	move	"{\\"location_id\\":2}"	"{\\"location_id\\":\\"2\\"}"	1	2026-05-18 11:43:31.339399+03	\N
20	36	assign	"{\\"responsible_user_id\\":10}"	"{\\"responsible_user_id\\":\\"10\\"}"	1	2026-05-18 11:43:31.356253+03	\N
21	36	status_change	"{\\"status_id\\":1}"	"{\\"status_id\\":\\"1\\"}"	1	2026-05-18 11:43:31.397517+03	\N
22	36	move	"{\\"location_id\\":2}"	"{\\"location_id\\":\\"2\\"}"	1	2026-05-18 11:43:43.322508+03	\N
23	36	assign	"{\\"responsible_user_id\\":10}"	"{\\"responsible_user_id\\":\\"10\\"}"	1	2026-05-18 11:43:43.33665+03	\N
24	36	status_change	"{\\"status_id\\":1}"	"{\\"status_id\\":\\"1\\"}"	1	2026-05-18 11:43:43.386012+03	\N
25	7	move	"{\\"location_id\\":1}"	"{\\"location_id\\":\\"1\\"}"	1	2026-05-18 11:48:44.990542+03	\N
26	7	assign	"{\\"responsible_user_id\\":4}"	"{\\"responsible_user_id\\":\\"4\\"}"	1	2026-05-18 11:48:45.003099+03	\N
27	7	status_change	"{\\"status_id\\":1}"	"{\\"status_id\\":\\"1\\"}"	1	2026-05-18 11:48:45.045522+03	\N
28	36	move	"{\\"location_id\\":2}"	"{\\"location_id\\":\\"2\\"}"	1	2026-05-18 11:59:24.430583+03	\N
29	36	assign	"{\\"responsible_user_id\\":10}"	"{\\"responsible_user_id\\":\\"10\\"}"	1	2026-05-18 11:59:24.443465+03	\N
30	36	status_change	"{\\"status_id\\":1}"	"{\\"status_id\\":\\"1\\"}"	1	2026-05-18 11:59:24.487727+03	\N
31	4	move	"{\\"location_id\\":1}"	"{\\"location_id\\":\\"1\\"}"	1	2026-05-18 11:59:48.90963+03	\N
32	4	assign	"{\\"responsible_user_id\\":3}"	"{\\"responsible_user_id\\":\\"3\\"}"	1	2026-05-18 11:59:48.921386+03	\N
33	4	status_change	"{\\"status_id\\":1}"	"{\\"status_id\\":\\"1\\"}"	1	2026-05-18 11:59:48.963306+03	\N
34	4	move	"{\\"location_id\\":1}"	"{\\"location_id\\":\\"1\\"}"	1	2026-05-18 12:00:02.452118+03	\N
35	4	assign	"{\\"responsible_user_id\\":3}"	"{\\"responsible_user_id\\":\\"3\\"}"	1	2026-05-18 12:00:02.465356+03	\N
36	4	status_change	"{\\"status_id\\":1}"	"{\\"status_id\\":\\"1\\"}"	1	2026-05-18 12:00:02.511802+03	\N
37	65	move	"{\\"location_id\\":2}"	"{\\"location_id\\":\\"2\\"}"	1	2026-05-18 12:19:23.562718+03	\N
38	65	assign	"{\\"responsible_user_id\\":9}"	"{\\"responsible_user_id\\":\\"9\\"}"	1	2026-05-18 12:19:23.575328+03	\N
39	65	status_change	"{\\"status_id\\":4}"	"{\\"status_id\\":\\"4\\"}"	1	2026-05-18 12:19:23.619188+03	\N
40	65	move	"{\\"location_id\\":2}"	"{\\"location_id\\":\\"2\\"}"	1	2026-05-18 12:20:39.845394+03	\N
41	65	assign	"{\\"responsible_user_id\\":9}"	"{\\"responsible_user_id\\":\\"9\\"}"	1	2026-05-18 12:20:39.859774+03	\N
42	65	status_change	"{\\"status_id\\":4}"	"{\\"status_id\\":\\"4\\"}"	1	2026-05-18 12:20:39.906444+03	\N
43	65	move	"{\\"location_id\\":2}"	"{\\"location_id\\":\\"2\\"}"	1	2026-05-18 12:23:43.692681+03	\N
44	65	assign	"{\\"responsible_user_id\\":9}"	"{\\"responsible_user_id\\":\\"9\\"}"	1	2026-05-18 12:23:43.705457+03	\N
45	65	status_change	"{\\"status_id\\":4}"	"{\\"status_id\\":\\"4\\"}"	1	2026-05-18 12:23:43.74995+03	\N
46	52	move	"{\\"location_id\\":7}"	"{\\"location_id\\":\\"7\\"}"	1	2026-05-18 12:25:27.685109+03	\N
47	52	assign	"{\\"responsible_user_id\\":14}"	"{\\"responsible_user_id\\":\\"14\\"}"	1	2026-05-18 12:25:27.700093+03	\N
48	52	status_change	"{\\"status_id\\":1}"	"{\\"status_id\\":\\"1\\"}"	1	2026-05-18 12:25:27.754122+03	\N
49	36	move	"{\\"location_id\\":2}"	"{\\"location_id\\":\\"2\\"}"	1	2026-05-18 16:46:37.476624+03	\N
50	36	assign	"{\\"responsible_user_id\\":10}"	"{\\"responsible_user_id\\":\\"10\\"}"	1	2026-05-18 16:46:37.489175+03	\N
51	36	status_change	"{\\"status_id\\":1}"	"{\\"status_id\\":\\"1\\"}"	1	2026-05-18 16:46:37.531755+03	\N
52	41	assign	"{\\"responsible_user_id\\":11}"	"{\\"responsible_user_id\\":16}"	1	2026-05-19 15:02:14.817418+03	\N
53	41	move	"{\\"location_id\\":4}"	"{\\"location_id\\":1}"	1	2026-05-19 15:02:14.817418+03	\N
54	63	assign	"{\\"responsible_user_id\\":4,\\"responsible_user_name\\":\\"Елистратова Мария Сергеевна\\"}"	"{\\"responsible_user_id\\":10,\\"responsible_user_name\\":\\"Андросова Наталья Вячеславовна\\"}"	1	2026-05-19 15:09:47.609827+03	\N
55	63	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":2,\\"location_name\\":\\"105\\"}"	1	2026-05-19 15:09:47.609827+03	\N
56	63	move	"{\\"location_id\\":2,\\"location_name\\":\\"105\\"}"	"{\\"location_id\\":\\"8\\",\\"location_name\\":\\"104\\"}"	1	2026-05-19 15:10:21.926339+03	\N
57	63	assign	"{\\"responsible_user_id\\":10,\\"responsible_user_name\\":\\"Андросова Наталья Вячеславовна\\"}"	"{\\"responsible_user_id\\":\\"10\\",\\"responsible_user_name\\":\\"Андросова Наталья Вячеславовна\\"}"	1	2026-05-19 15:10:21.941443+03	\N
58	63	status_change	"{\\"status_id\\":1,\\"status_name\\":\\"В эксплуатации\\"}"	"{\\"status_id\\":\\"1\\",\\"status_name\\":\\"В эксплуатации\\"}"	1	2026-05-19 15:10:21.987779+03	\N
59	63	move	"{\\"location_id\\":8,\\"location_name\\":\\"104\\"}"	"{\\"location_id\\":\\"2\\",\\"location_name\\":\\"105\\"}"	1	2026-05-19 15:16:44.456508+03	\N
60	63	status_change	"{\\"status_id\\":1,\\"status_name\\":\\"В эксплуатации\\"}"	"{\\"status_id\\":\\"4\\",\\"status_name\\":\\"Списано\\"}"	1	2026-05-19 15:16:52.850682+03	\N
61	63	assign	"{\\"responsible_user_id\\":10,\\"responsible_user_name\\":\\"Андросова Наталья Вячеславовна\\"}"	"{\\"responsible_user_id\\":\\"3\\",\\"responsible_user_name\\":\\"Аптекарева Виктория Михайловна\\"}"	1	2026-05-19 15:17:19.854634+03	\N
62	4	update	\N	"{\\"inventory_number\\":\\"МЦ.04.2-строка3\\",\\"name\\":\\"USN Computers (mini)\\"}"	1	2026-05-19 15:17:47.652903+03	\N
63	2	update	\N	"{\\"inventory_number\\":\\"МЦ.04-mon-1\\",\\"name\\":\\"BENQ BL2201M\\"}"	1	2026-05-22 09:34:24.515329+03	\N
64	4	update	\N	"{\\"inventory_number\\":\\"МЦ.04.2-строка3\\",\\"name\\":\\"USN Computers (mini)\\"}"	1	2026-05-22 10:37:54.857673+03	\N
65	59	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":8,\\"location_name\\":\\"104\\"}"	1	2026-05-22 11:00:11.210742+03	\N
66	4	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":8,\\"location_name\\":\\"104\\"}"	1	2026-05-22 11:00:11.210742+03	\N
67	4	move	"{\\"location_id\\":8,\\"location_name\\":\\"104\\"}"	"{\\"location_id\\":2,\\"location_name\\":\\"105\\"}"	1	2026-05-22 11:05:57.178989+03	\N
68	5	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":2,\\"location_name\\":\\"105\\"}"	1	2026-05-22 11:05:57.178989+03	\N
69	6	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":2,\\"location_name\\":\\"105\\"}"	1	2026-05-22 11:05:57.178989+03	\N
70	41	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":5,\\"location_name\\":\\"303\\"}"	1	2026-05-22 13:03:32.988227+03	\N
71	17	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":5,\\"location_name\\":\\"303\\"}"	1	2026-05-22 13:03:32.988227+03	\N
72	1	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":5,\\"location_name\\":\\"303\\"}"	1	2026-05-22 13:03:32.988227+03	\N
73	9	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":5,\\"location_name\\":\\"303\\"}"	1	2026-05-22 13:03:32.988227+03	\N
74	11	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":5,\\"location_name\\":\\"303\\"}"	1	2026-05-22 13:03:32.988227+03	\N
75	14	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":5,\\"location_name\\":\\"303\\"}"	1	2026-05-22 13:03:32.988227+03	\N
76	3	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":5,\\"location_name\\":\\"303\\"}"	1	2026-05-22 13:03:32.988227+03	\N
77	2	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":5,\\"location_name\\":\\"303\\"}"	1	2026-05-22 13:03:32.988227+03	\N
78	10	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":5,\\"location_name\\":\\"303\\"}"	1	2026-05-22 13:03:32.988227+03	\N
79	12	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":5,\\"location_name\\":\\"303\\"}"	1	2026-05-22 13:03:32.988227+03	\N
80	13	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":5,\\"location_name\\":\\"303\\"}"	1	2026-05-22 13:03:32.988227+03	\N
81	15	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":5,\\"location_name\\":\\"303\\"}"	1	2026-05-22 13:03:32.988227+03	\N
82	16	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":5,\\"location_name\\":\\"303\\"}"	1	2026-05-22 13:03:32.988227+03	\N
83	18	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":5,\\"location_name\\":\\"303\\"}"	1	2026-05-22 13:03:32.988227+03	\N
84	19	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":5,\\"location_name\\":\\"303\\"}"	1	2026-05-22 13:03:32.988227+03	\N
85	42	move	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	"{\\"location_id\\":5,\\"location_name\\":\\"303\\"}"	1	2026-05-22 13:03:32.988227+03	\N
86	78	assign	"{\\"responsible_user_id\\":16,\\"responsible_user_name\\":\\"Абрамова Дарья Алексанровна\\"}"	"{\\"responsible_user_id\\":8,\\"responsible_user_name\\":\\"Иваненко Константин Викторович\\"}"	1	2026-05-28 11:50:07.330519+03	\N
87	78	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	1	2026-05-28 11:50:07.330519+03	\N
88	80	assign	"{\\"responsible_user_id\\":2,\\"responsible_user_name\\":\\"Яшкина Елизавета  Вячеславовна\\"}"	"{\\"responsible_user_id\\":10,\\"responsible_user_name\\":\\"Андросова Наталья Вячеславовна\\"}"	1	2026-05-28 13:09:53.075531+03	\N
89	80	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":2,\\"location_name\\":\\"105\\"}"	1	2026-05-28 13:09:53.075531+03	\N
90	57	assign	"{\\"responsible_user_id\\":2,\\"responsible_user_name\\":\\"Яшкина Елизавета  Вячеславовна\\"}"	"{\\"responsible_user_id\\":19,\\"responsible_user_name\\":\\"Кулаков Дмитрий Дмитриевич\\"}"	1	2026-05-28 14:35:23.32482+03	\N
91	57	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":5,\\"location_name\\":\\"303\\"}"	1	2026-05-28 14:35:23.32482+03	\N
92	61	assign	"{\\"responsible_user_id\\":2,\\"responsible_user_name\\":\\"Яшкина Елизавета  Вячеславовна\\"}"	"{\\"responsible_user_id\\":19,\\"responsible_user_name\\":\\"Кулаков Дмитрий Дмитриевич\\"}"	1	2026-05-28 14:35:23.32482+03	\N
93	61	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":5,\\"location_name\\":\\"303\\"}"	1	2026-05-28 14:35:23.32482+03	\N
94	56	assign	"{\\"responsible_user_id\\":2,\\"responsible_user_name\\":\\"Яшкина Елизавета  Вячеславовна\\"}"	"{\\"responsible_user_id\\":19,\\"responsible_user_name\\":\\"Кулаков Дмитрий Дмитриевич\\"}"	1	2026-05-28 14:35:23.32482+03	\N
95	56	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":5,\\"location_name\\":\\"303\\"}"	1	2026-05-28 14:35:23.32482+03	\N
96	74	assign	"{\\"responsible_user_id\\":2,\\"responsible_user_name\\":\\"Яшкина Елизавета  Вячеславовна\\"}"	"{\\"responsible_user_id\\":19,\\"responsible_user_name\\":\\"Кулаков Дмитрий Дмитриевич\\"}"	1	2026-05-28 14:35:23.32482+03	\N
97	74	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":5,\\"location_name\\":\\"303\\"}"	1	2026-05-28 14:35:23.32482+03	\N
98	76	assign	"{\\"responsible_user_id\\":2,\\"responsible_user_name\\":\\"Яшкина Елизавета  Вячеславовна\\"}"	"{\\"responsible_user_id\\":19,\\"responsible_user_name\\":\\"Кулаков Дмитрий Дмитриевич\\"}"	1	2026-05-28 14:35:23.32482+03	\N
99	76	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":5,\\"location_name\\":\\"303\\"}"	1	2026-05-28 14:35:23.32482+03	\N
100	59	assign	"{\\"responsible_user_id\\":3,\\"responsible_user_name\\":\\"Аптекарева Виктория Михайловна\\"}"	"{\\"responsible_user_id\\":19,\\"responsible_user_name\\":\\"Кулаков Дмитрий Дмитриевич\\"}"	1	2026-05-28 14:35:23.32482+03	\N
101	59	move	"{\\"location_id\\":8,\\"location_name\\":\\"104\\"}"	"{\\"location_id\\":5,\\"location_name\\":\\"303\\"}"	1	2026-05-28 14:35:23.32482+03	\N
102	20	assign	"{\\"responsible_user_id\\":2,\\"responsible_user_name\\":\\"Яшкина Елизавета  Вячеславовна\\"}"	"{\\"responsible_user_id\\":4,\\"responsible_user_name\\":\\"Елистратова Мария Сергеевна\\"}"	1	2026-05-28 14:36:07.081845+03	\N
103	21	assign	"{\\"responsible_user_id\\":2,\\"responsible_user_name\\":\\"Яшкина Елизавета  Вячеславовна\\"}"	"{\\"responsible_user_id\\":4,\\"responsible_user_name\\":\\"Елистратова Мария Сергеевна\\"}"	1	2026-05-28 14:36:07.081845+03	\N
104	22	assign	"{\\"responsible_user_id\\":2,\\"responsible_user_name\\":\\"Яшкина Елизавета  Вячеславовна\\"}"	"{\\"responsible_user_id\\":4,\\"responsible_user_name\\":\\"Елистратова Мария Сергеевна\\"}"	1	2026-05-28 14:36:07.081845+03	\N
105	20	assign	"{\\"responsible_user_id\\":4,\\"responsible_user_name\\":\\"Елистратова Мария Сергеевна\\"}"	"{\\"responsible_user_id\\":3,\\"responsible_user_name\\":\\"Аптекарева Виктория Михайловна\\"}"	1	2026-05-28 14:37:13.92243+03	\N
106	20	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	1	2026-05-28 14:37:13.92243+03	\N
107	21	assign	"{\\"responsible_user_id\\":4,\\"responsible_user_name\\":\\"Елистратова Мария Сергеевна\\"}"	"{\\"responsible_user_id\\":3,\\"responsible_user_name\\":\\"Аптекарева Виктория Михайловна\\"}"	1	2026-05-28 14:37:13.92243+03	\N
108	21	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	1	2026-05-28 14:37:13.92243+03	\N
109	22	assign	"{\\"responsible_user_id\\":4,\\"responsible_user_name\\":\\"Елистратова Мария Сергеевна\\"}"	"{\\"responsible_user_id\\":3,\\"responsible_user_name\\":\\"Аптекарева Виктория Михайловна\\"}"	1	2026-05-28 14:37:13.92243+03	\N
110	22	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	1	2026-05-28 14:37:13.92243+03	\N
111	7	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	1	2026-05-28 14:40:29.608314+03	\N
112	8	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	1	2026-05-28 14:40:29.608314+03	\N
113	66	assign	"{\\"responsible_user_id\\":18,\\"responsible_user_name\\":\\"Сергеев Андрей Анатольевич\\"}"	"{\\"responsible_user_id\\":3,\\"responsible_user_name\\":\\"Аптекарева Виктория Михайловна\\"}"	1	2026-05-28 14:44:54.368727+03	\N
114	66	move	"{\\"location_id\\":8,\\"location_name\\":\\"104\\"}"	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	1	2026-05-28 14:44:54.368727+03	\N
115	62	assign	"{\\"responsible_user_id\\":16,\\"responsible_user_name\\":\\"Абрамова Дарья Алексанровна\\"}"	"{\\"responsible_user_id\\":10,\\"responsible_user_name\\":\\"Андросова Наталья Вячеславовна\\"}"	1	2026-05-28 15:00:53.852295+03	\N
116	62	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":2,\\"location_name\\":\\"105\\"}"	1	2026-05-28 15:00:53.852295+03	\N
117	36	assign	"{\\"responsible_user_id\\":10,\\"responsible_user_name\\":\\"Андросова Наталья Вячеславовна\\"}"	"{\\"responsible_user_id\\":3,\\"responsible_user_name\\":\\"Аптекарева Виктория Михайловна\\"}"	1	2026-05-28 15:04:32.794604+03	\N
118	37	assign	"{\\"responsible_user_id\\":10,\\"responsible_user_name\\":\\"Андросова Наталья Вячеславовна\\"}"	"{\\"responsible_user_id\\":3,\\"responsible_user_name\\":\\"Аптекарева Виктория Михайловна\\"}"	1	2026-05-28 15:04:32.794604+03	\N
119	38	assign	"{\\"responsible_user_id\\":10,\\"responsible_user_name\\":\\"Андросова Наталья Вячеславовна\\"}"	"{\\"responsible_user_id\\":3,\\"responsible_user_name\\":\\"Аптекарева Виктория Михайловна\\"}"	1	2026-05-28 15:04:32.794604+03	\N
120	85	create	\N	"{\\"inventory_number\\":\\"МЦ.04\\",\\"name\\":\\"DELL E2441\\"}"	1	2026-05-30 11:14:54.094277+03	\N
121	86	create	\N	"{\\"inventory_number\\":\\"МЦ.04\\",\\"name\\":\\"DELL E2441\\"}"	1	2026-05-30 11:14:54.337218+03	\N
122	87	create	\N	"{\\"inventory_number\\":\\"МЦ.04\\",\\"name\\":\\"MSI 3201\\"}"	1	2026-05-30 11:21:35.188433+03	\N
123	87	assign	"{\\"responsible_user_id\\":19,\\"responsible_user_name\\":\\"Кулаков Дмитрий Дмитриевич\\"}"	"{\\"responsible_user_id\\":9,\\"responsible_user_name\\":\\"Тютчев Сергей Николаевич\\"}"	1	2026-05-30 11:29:23.524317+03	\N
124	87	update	\N	"{\\"parent_equipment_id\\":34,\\"link_type\\":\\"monitor\\"}"	1	2026-05-30 11:29:23.524317+03	move_component_attach
125	87	move	"{\\"location_id\\":9,\\"location_name\\":\\"306\\"}"	"{\\"location_id\\":2,\\"location_name\\":\\"105\\"}"	1	2026-05-30 11:29:23.524317+03	move_component_to_host
126	43	assign	"{\\"responsible_user_id\\":11,\\"responsible_user_name\\":\\"Котов Михаил Ювинальевич\\"}"	"{\\"responsible_user_id\\":16,\\"responsible_user_name\\":\\"Абрамова Дарья Алексанровна\\"}"	1	2026-05-30 11:31:39.646487+03	\N
127	43	move	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	1	2026-05-30 11:31:39.646487+03	\N
128	20	assign	"{\\"responsible_user_id\\":3,\\"responsible_user_name\\":\\"Аптекарева Виктория Михайловна\\"}"	"{\\"responsible_user_id\\":16,\\"responsible_user_name\\":\\"Абрамова Дарья Алексанровна\\"}"	1	2026-05-30 11:31:39.646487+03	\N
129	20	move	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	1	2026-05-30 11:31:39.646487+03	\N
130	44	assign	"{\\"responsible_user_id\\":11,\\"responsible_user_name\\":\\"Котов Михаил Ювинальевич\\"}"	"{\\"responsible_user_id\\":16,\\"responsible_user_name\\":\\"Абрамова Дарья Алексанровна\\"}"	1	2026-05-30 11:31:39.646487+03	\N
131	44	move	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	1	2026-05-30 11:31:39.646487+03	\N
132	21	assign	"{\\"responsible_user_id\\":3,\\"responsible_user_name\\":\\"Аптекарева Виктория Михайловна\\"}"	"{\\"responsible_user_id\\":16,\\"responsible_user_name\\":\\"Абрамова Дарья Алексанровна\\"}"	1	2026-05-30 11:31:39.646487+03	\N
133	21	move	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	1	2026-05-30 11:31:39.646487+03	\N
134	22	assign	"{\\"responsible_user_id\\":3,\\"responsible_user_name\\":\\"Аптекарева Виктория Михайловна\\"}"	"{\\"responsible_user_id\\":16,\\"responsible_user_name\\":\\"Абрамова Дарья Алексанровна\\"}"	1	2026-05-30 11:31:39.646487+03	\N
135	22	move	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	1	2026-05-30 11:31:39.646487+03	\N
136	82	update	\N	"{\\"inventory_number\\":\\"МЦ.04\\",\\"name\\":\\"МФУ Canon i-Sensys MF744cdw (МФУ, цвет,А4, LAN, WiFi)\\"}"	1	2026-05-30 11:54:19.144041+03	\N
137	82	update	\N	"{\\"inventory_number\\":\\"МЦ.04\\",\\"name\\":\\"Canon i-Sensys MF744cdw\\"}"	1	2026-05-30 11:55:00.063059+03	\N
138	66	update	\N	"{\\"inventory_number\\":\\"МЦ.04-строка17\\",\\"name\\":\\"Canon i-Sensys MF744cdw\\"}"	1	2026-05-30 11:55:56.423925+03	\N
139	4	update	\N	"{\\"inventory_number\\":\\"МЦ.04.2-строка3\\",\\"name\\":\\"USN Computers (mini)\\"}"	1	2026-05-30 11:57:23.126595+03	\N
140	4	assign	"{\\"responsible_user_id\\":3,\\"responsible_user_name\\":\\"Аптекарева Виктория Михайловна\\"}"	"{\\"responsible_user_id\\":21,\\"responsible_user_name\\":\\"Селиванов Владислав Геннадьевич\\"}"	1	2026-05-30 12:16:20.713874+03	\N
141	4	move	"{\\"location_id\\":2,\\"location_name\\":\\"105\\"}"	"{\\"location_id\\":5,\\"location_name\\":\\"303\\"}"	1	2026-05-30 12:16:20.713874+03	\N
142	5	assign	"{\\"responsible_user_id\\":3,\\"responsible_user_name\\":\\"Аптекарева Виктория Михайловна\\"}"	"{\\"responsible_user_id\\":21,\\"responsible_user_name\\":\\"Селиванов Владислав Геннадьевич\\"}"	1	2026-05-30 12:16:20.713874+03	\N
143	5	move	"{\\"location_id\\":2,\\"location_name\\":\\"105\\"}"	"{\\"location_id\\":5,\\"location_name\\":\\"303\\"}"	1	2026-05-30 12:16:20.713874+03	\N
144	6	assign	"{\\"responsible_user_id\\":3,\\"responsible_user_name\\":\\"Аптекарева Виктория Михайловна\\"}"	"{\\"responsible_user_id\\":21,\\"responsible_user_name\\":\\"Селиванов Владислав Геннадьевич\\"}"	1	2026-05-30 12:16:20.713874+03	\N
145	6	move	"{\\"location_id\\":2,\\"location_name\\":\\"105\\"}"	"{\\"location_id\\":5,\\"location_name\\":\\"303\\"}"	1	2026-05-30 12:16:20.713874+03	\N
146	4	update	\N	"{\\"inventory_number\\":\\"МЦ.04.2-строка3\\",\\"name\\":\\"USN Computers (mini)\\"}"	1	2026-05-30 12:17:40.845795+03	\N
147	63	update	\N	"{\\"inventory_number\\":\\"НИИСУ-строка14\\",\\"name\\":\\"Fujitsu fi-6130\\"}"	1	2026-05-30 12:33:50.212729+03	\N
148	82	assign	"{\\"responsible_user_id\\":18,\\"responsible_user_name\\":\\"Сергеев Андрей Анатольевич\\"}"	"{\\"responsible_user_id\\":1,\\"responsible_user_name\\":\\"Администратор\\"}"	1	2026-05-30 12:34:40.656729+03	\N
149	23	update	\N	"{\\"inventory_number\\":\\"МЦ.04\\",\\"name\\":\\"LAPTOP-VU5M0UKQ\\"}"	1	2026-05-30 13:00:12.075368+03	\N
150	24	archive	"{\\"is_archived\\":false}"	"{\\"is_archived\\":true}"	1	2026-05-30 13:00:30.297567+03	
151	62	archive	"{\\"is_archived\\":false}"	"{\\"is_archived\\":true}"	1	2026-05-30 13:02:55.32497+03	
152	65	update	\N	"{\\"inventory_number\\":\\"(списанная МЦ)\\",\\"name\\":\\"Canon i-Sensys MF4690PL\\"}"	1	2026-05-30 13:13:09.485684+03	\N
153	23	update	\N	"{\\"inventory_number\\":\\"МЦ.04\\",\\"name\\":\\"Lenovo ThinkBook 240\\"}"	1	2026-05-30 13:47:09.31553+03	\N
154	88	create	\N	"{\\"inventory_number\\":\\"МЦ.04\\",\\"name\\":\\"APC Back-UPS 650 ВА (белый)\\"}"	1	2026-06-01 08:28:38.104114+03	\N
155	88	assign	"{\\"responsible_user_id\\":19,\\"responsible_user_name\\":\\"Кулаков Дмитрий Дмитриевич\\"}"	"{\\"responsible_user_id\\":2,\\"responsible_user_name\\":\\"Яшкина Елизавета  Вячеславовна\\"}"	1	2026-06-01 08:29:17.728328+03	\N
156	88	update	\N	"{\\"parent_equipment_id\\":9,\\"link_type\\":\\"ups\\"}"	1	2026-06-01 08:29:17.728328+03	move_component_attach
157	88	move	"{\\"location_id\\":9,\\"location_name\\":\\"306\\"}"	"{\\"location_id\\":5,\\"location_name\\":\\"303\\"}"	1	2026-06-01 08:29:17.728328+03	move_component_to_host
158	89	create	\N	"{\\"inventory_number\\":\\"МЦ.04\\",\\"name\\":\\"МИР4\\"}"	1	2026-06-01 08:31:11.317388+03	\N
159	90	create	\N	"{\\"inventory_number\\":\\"МЦ.04\\",\\"name\\":\\"APC Back-UPS 650 ВА (BX650CI-RS)\\"}"	1	2026-06-01 08:41:35.266825+03	\N
160	1	update	\N	"{\\"inventory_number\\":\\"МЦ.04.2\\",\\"name\\":\\"105-w7u32-12\\"}"	1	2026-06-01 16:33:42.710422+03	\N
161	14	update	\N	"{\\"inventory_number\\":\\"МЦ.04.1\\",\\"name\\":\\"103-w10p64-17\\"}"	1	2026-06-01 16:34:13.956511+03	\N
162	82	move	"{\\"location_id\\":8,\\"location_name\\":\\"104\\"}"	"{\\"location_id\\":11,\\"location_name\\":\\"306 склад\\"}"	1	2026-06-01 17:25:49.637903+03	move_to_warehouse
163	82	unassign	"{\\"responsible_user_id\\":1,\\"responsible_user_name\\":\\"Администратор\\"}"	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	1	2026-06-01 17:25:49.637903+03	move_to_warehouse
164	82	status_change	"{\\"status_id\\":1,\\"status_name\\":\\"В эксплуатации\\"}"	"{\\"status_id\\":2,\\"status_name\\":\\"На складе\\"}"	1	2026-06-01 17:25:49.637903+03	move_to_warehouse
165	44	update	"{\\"parent_equipment_id\\":43,\\"link_type\\":\\"monitor\\"}"	"{\\"parent_equipment_id\\":null,\\"link_type\\":null}"	1	2026-06-01 17:26:37.948539+03	move_to_warehouse_detach_kit
166	43	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":11,\\"location_name\\":\\"306 склад\\"}"	1	2026-06-01 17:26:37.948539+03	move_to_warehouse
167	43	unassign	"{\\"responsible_user_id\\":16,\\"responsible_user_name\\":\\"Абрамова Дарья Алексанровна\\"}"	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	1	2026-06-01 17:26:37.948539+03	move_to_warehouse
168	43	status_change	"{\\"status_id\\":1,\\"status_name\\":\\"В эксплуатации\\"}"	"{\\"status_id\\":2,\\"status_name\\":\\"На складе\\"}"	1	2026-06-01 17:26:37.948539+03	move_to_warehouse
169	44	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":11,\\"location_name\\":\\"306 склад\\"}"	1	2026-06-01 17:26:37.948539+03	move_to_warehouse
170	44	unassign	"{\\"responsible_user_id\\":16,\\"responsible_user_name\\":\\"Абрамова Дарья Алексанровна\\"}"	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	1	2026-06-01 17:26:37.948539+03	move_to_warehouse
171	44	status_change	"{\\"status_id\\":1,\\"status_name\\":\\"В эксплуатации\\"}"	"{\\"status_id\\":2,\\"status_name\\":\\"На складе\\"}"	1	2026-06-01 17:26:37.948539+03	move_to_warehouse
172	37	update	"{\\"parent_equipment_id\\":36,\\"link_type\\":\\"monitor\\"}"	"{\\"parent_equipment_id\\":null,\\"link_type\\":null}"	1	2026-06-01 17:27:00.862857+03	move_to_warehouse_detach_kit
173	38	update	"{\\"parent_equipment_id\\":36,\\"link_type\\":\\"ups\\"}"	"{\\"parent_equipment_id\\":null,\\"link_type\\":null}"	1	2026-06-01 17:27:00.862857+03	move_to_warehouse_detach_kit
174	36	move	"{\\"location_id\\":2,\\"location_name\\":\\"105\\"}"	"{\\"location_id\\":11,\\"location_name\\":\\"306 склад\\"}"	1	2026-06-01 17:27:00.862857+03	move_to_warehouse
175	36	unassign	"{\\"responsible_user_id\\":3,\\"responsible_user_name\\":\\"Аптекарева Виктория Михайловна\\"}"	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	1	2026-06-01 17:27:00.862857+03	move_to_warehouse
176	36	status_change	"{\\"status_id\\":1,\\"status_name\\":\\"В эксплуатации\\"}"	"{\\"status_id\\":2,\\"status_name\\":\\"На складе\\"}"	1	2026-06-01 17:27:00.862857+03	move_to_warehouse
177	37	move	"{\\"location_id\\":2,\\"location_name\\":\\"105\\"}"	"{\\"location_id\\":11,\\"location_name\\":\\"306 склад\\"}"	1	2026-06-01 17:27:00.862857+03	move_to_warehouse
178	37	unassign	"{\\"responsible_user_id\\":3,\\"responsible_user_name\\":\\"Аптекарева Виктория Михайловна\\"}"	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	1	2026-06-01 17:27:00.862857+03	move_to_warehouse
179	37	status_change	"{\\"status_id\\":1,\\"status_name\\":\\"В эксплуатации\\"}"	"{\\"status_id\\":2,\\"status_name\\":\\"На складе\\"}"	1	2026-06-01 17:27:00.862857+03	move_to_warehouse
180	38	move	"{\\"location_id\\":2,\\"location_name\\":\\"105\\"}"	"{\\"location_id\\":11,\\"location_name\\":\\"306 склад\\"}"	1	2026-06-01 17:27:00.862857+03	move_to_warehouse
181	38	unassign	"{\\"responsible_user_id\\":3,\\"responsible_user_name\\":\\"Аптекарева Виктория Михайловна\\"}"	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	1	2026-06-01 17:27:00.862857+03	move_to_warehouse
182	38	status_change	"{\\"status_id\\":1,\\"status_name\\":\\"В эксплуатации\\"}"	"{\\"status_id\\":2,\\"status_name\\":\\"На складе\\"}"	1	2026-06-01 17:27:00.862857+03	move_to_warehouse
183	36	status_change	"{\\"status_id\\":2,\\"status_name\\":\\"На складе\\"}"	"{\\"status_id\\":\\"3\\",\\"status_name\\":\\"В ремонте\\"}"	1	2026-06-02 08:39:04.967606+03	\N
184	63	move	"{\\"location_id\\":2,\\"location_name\\":\\"105\\"}"	"{\\"location_id\\":11,\\"location_name\\":\\"306 склад\\"}"	1	2026-06-02 08:41:36.409292+03	move_to_warehouse
185	63	unassign	"{\\"responsible_user_id\\":3,\\"responsible_user_name\\":\\"Аптекарева Виктория Михайловна\\"}"	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	1	2026-06-02 08:41:36.409292+03	move_to_warehouse
186	63	status_change	"{\\"status_id\\":4,\\"status_name\\":\\"Списано\\"}"	"{\\"status_id\\":2,\\"status_name\\":\\"На складе\\"}"	1	2026-06-02 08:41:36.409292+03	move_to_warehouse
187	26	update	"{\\"parent_equipment_id\\":25,\\"link_type\\":\\"monitor\\"}"	"{\\"parent_equipment_id\\":null,\\"link_type\\":null}"	1	2026-06-02 08:44:03.824038+03	move_to_warehouse_detach_kit
188	27	update	"{\\"parent_equipment_id\\":25,\\"link_type\\":\\"ups\\"}"	"{\\"parent_equipment_id\\":null,\\"link_type\\":null}"	1	2026-06-02 08:44:03.824038+03	move_to_warehouse_detach_kit
189	25	move	"{\\"location_id\\":2,\\"location_name\\":\\"105\\"}"	"{\\"location_id\\":11,\\"location_name\\":\\"306 склад\\"}"	1	2026-06-02 08:44:03.824038+03	move_to_warehouse
190	25	unassign	"{\\"responsible_user_id\\":6,\\"responsible_user_name\\":\\"Катлинская Маргарита Александровна\\"}"	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	1	2026-06-02 08:44:03.824038+03	move_to_warehouse
191	25	status_change	"{\\"status_id\\":1,\\"status_name\\":\\"В эксплуатации\\"}"	"{\\"status_id\\":2,\\"status_name\\":\\"На складе\\"}"	1	2026-06-02 08:44:03.824038+03	move_to_warehouse
192	26	move	"{\\"location_id\\":2,\\"location_name\\":\\"105\\"}"	"{\\"location_id\\":11,\\"location_name\\":\\"306 склад\\"}"	1	2026-06-02 08:44:03.824038+03	move_to_warehouse
193	26	unassign	"{\\"responsible_user_id\\":6,\\"responsible_user_name\\":\\"Катлинская Маргарита Александровна\\"}"	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	1	2026-06-02 08:44:03.824038+03	move_to_warehouse
194	26	status_change	"{\\"status_id\\":1,\\"status_name\\":\\"В эксплуатации\\"}"	"{\\"status_id\\":2,\\"status_name\\":\\"На складе\\"}"	1	2026-06-02 08:44:03.824038+03	move_to_warehouse
195	27	move	"{\\"location_id\\":2,\\"location_name\\":\\"105\\"}"	"{\\"location_id\\":11,\\"location_name\\":\\"306 склад\\"}"	1	2026-06-02 08:44:03.824038+03	move_to_warehouse
196	27	unassign	"{\\"responsible_user_id\\":6,\\"responsible_user_name\\":\\"Катлинская Маргарита Александровна\\"}"	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	1	2026-06-02 08:44:03.824038+03	move_to_warehouse
197	27	status_change	"{\\"status_id\\":1,\\"status_name\\":\\"В эксплуатации\\"}"	"{\\"status_id\\":2,\\"status_name\\":\\"На складе\\"}"	1	2026-06-02 08:44:03.824038+03	move_to_warehouse
198	21	update	"{\\"parent_equipment_id\\":20,\\"link_type\\":\\"monitor\\"}"	"{\\"parent_equipment_id\\":null,\\"link_type\\":null}"	1	2026-06-02 09:21:49.335788+03	move_to_warehouse_detach_kit
199	22	update	"{\\"parent_equipment_id\\":20,\\"link_type\\":\\"ups\\"}"	"{\\"parent_equipment_id\\":null,\\"link_type\\":null}"	1	2026-06-02 09:21:49.335788+03	move_to_warehouse_detach_kit
200	20	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":11,\\"location_name\\":\\"306 склад\\"}"	1	2026-06-02 09:21:49.335788+03	move_to_warehouse
201	20	unassign	"{\\"responsible_user_id\\":16,\\"responsible_user_name\\":\\"Абрамова Дарья Алексанровна\\"}"	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	1	2026-06-02 09:21:49.335788+03	move_to_warehouse
202	21	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":11,\\"location_name\\":\\"306 склад\\"}"	1	2026-06-02 09:21:49.335788+03	move_to_warehouse
203	21	unassign	"{\\"responsible_user_id\\":16,\\"responsible_user_name\\":\\"Абрамова Дарья Алексанровна\\"}"	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	1	2026-06-02 09:21:49.335788+03	move_to_warehouse
204	22	move	"{\\"location_id\\":1,\\"location_name\\":\\"103\\"}"	"{\\"location_id\\":11,\\"location_name\\":\\"306 склад\\"}"	1	2026-06-02 09:21:49.335788+03	move_to_warehouse
205	22	unassign	"{\\"responsible_user_id\\":16,\\"responsible_user_name\\":\\"Абрамова Дарья Алексанровна\\"}"	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	1	2026-06-02 09:21:49.335788+03	move_to_warehouse
206	91	create	\N	"{\\"name\\":\\"МИР 10\\",\\"equipment_type\\":\\"Системный блок\\",\\"location_id\\":11,\\"delivery_id\\":4,\\"location_name\\":\\"306 склад\\"}"	1	2026-06-03 11:13:42.936732+03	delivery_post
207	92	create	\N	"{\\"name\\":\\"МИР 10\\",\\"equipment_type\\":\\"Системный блок\\",\\"location_id\\":11,\\"delivery_id\\":4,\\"location_name\\":\\"306 склад\\"}"	1	2026-06-03 11:13:42.936732+03	delivery_post
208	93	create	\N	"{\\"name\\":\\"МИР 10\\",\\"equipment_type\\":\\"Системный блок\\",\\"location_id\\":11,\\"delivery_id\\":4,\\"location_name\\":\\"306 склад\\"}"	1	2026-06-03 11:13:42.936732+03	delivery_post
209	94	create	\N	"{\\"name\\":\\"МИР 10\\",\\"equipment_type\\":\\"Системный блок\\",\\"location_id\\":11,\\"delivery_id\\":4,\\"location_name\\":\\"306 склад\\"}"	1	2026-06-03 11:13:42.936732+03	delivery_post
210	95	create	\N	"{\\"name\\":\\"МИР 10\\",\\"equipment_type\\":\\"Системный блок\\",\\"location_id\\":11,\\"delivery_id\\":4,\\"location_name\\":\\"306 склад\\"}"	1	2026-06-03 11:13:42.936732+03	delivery_post
211	96	create	\N	"{\\"name\\":\\"МИР 10\\",\\"equipment_type\\":\\"Системный блок\\",\\"location_id\\":11,\\"delivery_id\\":4,\\"location_name\\":\\"306 склад\\"}"	1	2026-06-03 11:13:42.936732+03	delivery_post
212	97	create	\N	"{\\"name\\":\\"МИР 10\\",\\"equipment_type\\":\\"Системный блок\\",\\"location_id\\":11,\\"delivery_id\\":4,\\"location_name\\":\\"306 склад\\"}"	1	2026-06-03 11:13:42.936732+03	delivery_post
213	98	create	\N	"{\\"name\\":\\"МИР 10\\",\\"equipment_type\\":\\"Системный блок\\",\\"location_id\\":11,\\"delivery_id\\":4,\\"location_name\\":\\"306 склад\\"}"	1	2026-06-03 11:13:42.936732+03	delivery_post
214	99	create	\N	"{\\"name\\":\\"МИР 10\\",\\"equipment_type\\":\\"Системный блок\\",\\"location_id\\":11,\\"delivery_id\\":4,\\"location_name\\":\\"306 склад\\"}"	1	2026-06-03 11:13:42.936732+03	delivery_post
215	100	create	\N	"{\\"name\\":\\"МИР 10\\",\\"equipment_type\\":\\"Системный блок\\",\\"location_id\\":11,\\"delivery_id\\":4,\\"location_name\\":\\"306 склад\\"}"	1	2026-06-03 11:13:42.936732+03	delivery_post
216	100	update	"{\\"supplier\\":null,\\"purchase_date\\":\\"2026-06-03\\"}"	"{\\"supplier\\":\\"Рога и копыта\\",\\"purchase_date\\":\\"2026-06-03\\"}"	1	2026-06-03 11:15:41.655576+03	delivery_sync
217	91	update	"{\\"supplier\\":null,\\"purchase_date\\":\\"2026-06-03\\"}"	"{\\"supplier\\":\\"Рога и копыта\\",\\"purchase_date\\":\\"2026-06-03\\"}"	1	2026-06-03 11:15:41.658264+03	delivery_sync
218	92	update	"{\\"supplier\\":null,\\"purchase_date\\":\\"2026-06-03\\"}"	"{\\"supplier\\":\\"Рога и копыта\\",\\"purchase_date\\":\\"2026-06-03\\"}"	1	2026-06-03 11:15:41.660187+03	delivery_sync
219	93	update	"{\\"supplier\\":null,\\"purchase_date\\":\\"2026-06-03\\"}"	"{\\"supplier\\":\\"Рога и копыта\\",\\"purchase_date\\":\\"2026-06-03\\"}"	1	2026-06-03 11:15:41.66202+03	delivery_sync
220	94	update	"{\\"supplier\\":null,\\"purchase_date\\":\\"2026-06-03\\"}"	"{\\"supplier\\":\\"Рога и копыта\\",\\"purchase_date\\":\\"2026-06-03\\"}"	1	2026-06-03 11:15:41.663765+03	delivery_sync
221	95	update	"{\\"supplier\\":null,\\"purchase_date\\":\\"2026-06-03\\"}"	"{\\"supplier\\":\\"Рога и копыта\\",\\"purchase_date\\":\\"2026-06-03\\"}"	1	2026-06-03 11:15:41.665544+03	delivery_sync
222	96	update	"{\\"supplier\\":null,\\"purchase_date\\":\\"2026-06-03\\"}"	"{\\"supplier\\":\\"Рога и копыта\\",\\"purchase_date\\":\\"2026-06-03\\"}"	1	2026-06-03 11:15:41.668615+03	delivery_sync
223	97	update	"{\\"supplier\\":null,\\"purchase_date\\":\\"2026-06-03\\"}"	"{\\"supplier\\":\\"Рога и копыта\\",\\"purchase_date\\":\\"2026-06-03\\"}"	1	2026-06-03 11:15:41.670733+03	delivery_sync
224	98	update	"{\\"supplier\\":null,\\"purchase_date\\":\\"2026-06-03\\"}"	"{\\"supplier\\":\\"Рога и копыта\\",\\"purchase_date\\":\\"2026-06-03\\"}"	1	2026-06-03 11:15:41.672568+03	delivery_sync
225	99	update	"{\\"supplier\\":null,\\"purchase_date\\":\\"2026-06-03\\"}"	"{\\"supplier\\":\\"Рога и копыта\\",\\"purchase_date\\":\\"2026-06-03\\"}"	1	2026-06-03 11:15:41.674328+03	delivery_sync
226	93	assign	"{\\"responsible_user_id\\":0,\\"responsible_user_name\\":\\"не назначен\\"}"	"{\\"responsible_user_id\\":19,\\"responsible_user_name\\":\\"Кулаков Дмитрий Дмитриевич\\"}"	1	2026-06-03 11:21:00.487877+03	\N
227	93	move	"{\\"location_id\\":11,\\"location_name\\":\\"306 склад\\"}"	"{\\"location_id\\":9,\\"location_name\\":\\"306\\"}"	1	2026-06-03 11:21:00.487877+03	\N
228	66	update	\N	"{\\"inventory_number\\":\\"МЦ.04\\",\\"name\\":\\"Canon i-Sensys MF744cdw\\"}"	1	2026-07-07 13:18:43.799632+03	\N
229	34	update	\N	"{\\"inventory_number\\":\\"МЦ.04.1\\",\\"name\\":\\"ARBYTE\\"}"	1	2026-07-07 13:19:05.083371+03	\N
230	35	update	\N	"{\\"inventory_number\\":\\"МЦ.04\\",\\"name\\":\\"Nec MultiSync E222W\\"}"	1	2026-07-07 13:19:17.923937+03	\N
231	78	update	\N	"{\\"inventory_number\\":\\"МЦ.04.1\\",\\"name\\":\\"Сканер Fujitsu fi-6130\\"}"	1	2026-07-07 13:19:33.078303+03	\N
232	41	update	\N	"{\\"inventory_number\\":\\"99036\\",\\"name\\":\\"Flextron\\"}"	1	2026-07-07 13:19:48.710759+03	\N
233	33	update	\N	"{\\"inventory_number\\":\\"МЦ.04-ups-9\\",\\"name\\":\\"APC Back-UPS 650 ВА (BX650CI-RS)\\"}"	1	2026-07-07 14:34:28.713859+03	\N
234	23	update	\N	"{\\"inventory_number\\":\\"МЦ.04\\",\\"name\\":\\"Lenovo ThinkBook 240\\"}"	1	2026-07-07 14:35:04.936565+03	\N
235	23	update	\N	"{\\"inventory_number\\":\\"МЦ.04\\",\\"name\\":\\"Lenovo ThinkBook 240\\"}"	1	2026-07-07 14:39:07.802764+03	\N
236	23	update	\N	"{\\"inventory_number\\":\\"МЦ.04\\",\\"name\\":\\"Lenovo ThinkBook 240\\"}"	1	2026-07-07 14:42:58.397825+03	\N
237	23	update	\N	"{\\"inventory_number\\":\\"МЦ.04\\",\\"name\\":\\"Lenovo ThinkBook 240\\"}"	1	2026-07-07 14:45:46.593087+03	\N
238	101	create	\N	"{\\"name\\":\\"Inwin Pro\\",\\"equipment_type\\":\\"Системный блок\\",\\"location_id\\":12,\\"delivery_id\\":8,\\"location_name\\":\\"116 склад\\"}"	1	2026-07-07 14:54:48.779875+03	delivery_post
239	102	create	\N	"{\\"name\\":\\"Inwin Pro\\",\\"equipment_type\\":\\"Системный блок\\",\\"location_id\\":12,\\"delivery_id\\":8,\\"location_name\\":\\"116 склад\\"}"	1	2026-07-07 14:54:48.779875+03	delivery_post
240	103	create	\N	"{\\"name\\":\\"Inwin Pro\\",\\"equipment_type\\":\\"Системный блок\\",\\"location_id\\":12,\\"delivery_id\\":8,\\"location_name\\":\\"116 склад\\"}"	1	2026-07-07 14:54:48.779875+03	delivery_post
241	104	create	\N	"{\\"name\\":\\"Inwin Pro\\",\\"equipment_type\\":\\"Системный блок\\",\\"location_id\\":12,\\"delivery_id\\":8,\\"location_name\\":\\"116 склад\\"}"	1	2026-07-07 14:54:48.779875+03	delivery_post
242	105	create	\N	"{\\"name\\":\\"Inwin Pro\\",\\"equipment_type\\":\\"Системный блок\\",\\"location_id\\":12,\\"delivery_id\\":8,\\"location_name\\":\\"116 склад\\"}"	1	2026-07-07 14:54:48.779875+03	delivery_post
243	106	create	\N	"{\\"name\\":\\"Inwin Pro\\",\\"equipment_type\\":\\"Системный блок\\",\\"location_id\\":12,\\"delivery_id\\":8,\\"location_name\\":\\"116 склад\\"}"	1	2026-07-07 14:54:48.779875+03	delivery_post
244	107	create	\N	"{\\"name\\":\\"Inwin Pro\\",\\"equipment_type\\":\\"Системный блок\\",\\"location_id\\":12,\\"delivery_id\\":8,\\"location_name\\":\\"116 склад\\"}"	1	2026-07-07 14:54:48.779875+03	delivery_post
245	108	create	\N	"{\\"name\\":\\"Inwin Pro\\",\\"equipment_type\\":\\"Системный блок\\",\\"location_id\\":12,\\"delivery_id\\":8,\\"location_name\\":\\"116 склад\\"}"	1	2026-07-07 14:54:48.779875+03	delivery_post
246	109	create	\N	"{\\"name\\":\\"Inwin Pro\\",\\"equipment_type\\":\\"Системный блок\\",\\"location_id\\":12,\\"delivery_id\\":8,\\"location_name\\":\\"116 склад\\"}"	1	2026-07-07 14:54:48.779875+03	delivery_post
247	110	create	\N	"{\\"name\\":\\"Inwin Pro\\",\\"equipment_type\\":\\"Системный блок\\",\\"location_id\\":12,\\"delivery_id\\":8,\\"location_name\\":\\"116 склад\\"}"	1	2026-07-07 14:54:48.779875+03	delivery_post
248	111	create	\N	"{\\"name\\":\\"Lenovo G30\\",\\"equipment_type\\":\\"Монитор\\",\\"location_id\\":12,\\"delivery_id\\":8,\\"location_name\\":\\"116 склад\\"}"	1	2026-07-07 14:54:48.779875+03	delivery_post
249	112	create	\N	"{\\"name\\":\\"Lenovo G30\\",\\"equipment_type\\":\\"Монитор\\",\\"location_id\\":12,\\"delivery_id\\":8,\\"location_name\\":\\"116 склад\\"}"	1	2026-07-07 14:54:48.779875+03	delivery_post
250	113	create	\N	"{\\"name\\":\\"Lenovo G30\\",\\"equipment_type\\":\\"Монитор\\",\\"location_id\\":12,\\"delivery_id\\":8,\\"location_name\\":\\"116 склад\\"}"	1	2026-07-07 14:54:48.779875+03	delivery_post
251	114	create	\N	"{\\"name\\":\\"Lenovo G30\\",\\"equipment_type\\":\\"Монитор\\",\\"location_id\\":12,\\"delivery_id\\":8,\\"location_name\\":\\"116 склад\\"}"	1	2026-07-07 14:54:48.779875+03	delivery_post
252	115	create	\N	"{\\"name\\":\\"Lenovo G30\\",\\"equipment_type\\":\\"Монитор\\",\\"location_id\\":12,\\"delivery_id\\":8,\\"location_name\\":\\"116 склад\\"}"	1	2026-07-07 14:54:48.779875+03	delivery_post
253	116	create	\N	"{\\"name\\":\\"Lenovo G30\\",\\"equipment_type\\":\\"Монитор\\",\\"location_id\\":12,\\"delivery_id\\":8,\\"location_name\\":\\"116 склад\\"}"	1	2026-07-07 14:54:48.779875+03	delivery_post
254	117	create	\N	"{\\"name\\":\\"Lenovo G30\\",\\"equipment_type\\":\\"Монитор\\",\\"location_id\\":12,\\"delivery_id\\":8,\\"location_name\\":\\"116 склад\\"}"	1	2026-07-07 14:54:48.779875+03	delivery_post
255	118	create	\N	"{\\"name\\":\\"Lenovo G30\\",\\"equipment_type\\":\\"Монитор\\",\\"location_id\\":12,\\"delivery_id\\":8,\\"location_name\\":\\"116 склад\\"}"	1	2026-07-07 14:54:48.779875+03	delivery_post
256	119	create	\N	"{\\"name\\":\\"Lenovo G30\\",\\"equipment_type\\":\\"Монитор\\",\\"location_id\\":12,\\"delivery_id\\":8,\\"location_name\\":\\"116 склад\\"}"	1	2026-07-07 14:54:48.779875+03	delivery_post
257	120	create	\N	"{\\"name\\":\\"Lenovo G30\\",\\"equipment_type\\":\\"Монитор\\",\\"location_id\\":12,\\"delivery_id\\":8,\\"location_name\\":\\"116 склад\\"}"	1	2026-07-07 14:54:48.779875+03	delivery_post
258	111	assign	"{\\"responsible_user_id\\":0,\\"responsible_user_name\\":\\"не назначен\\"}"	"{\\"responsible_user_id\\":19,\\"responsible_user_name\\":\\"Кулаков Дмитрий Дмитриевич\\"}"	1	2026-07-07 14:55:38.233748+03	\N
259	111	update	\N	"{\\"parent_equipment_id\\":93,\\"link_type\\":\\"monitor\\"}"	1	2026-07-07 14:55:38.233748+03	move_component_attach
260	111	move	"{\\"location_id\\":12,\\"location_name\\":\\"116 склад\\"}"	"{\\"location_id\\":9,\\"location_name\\":\\"306\\"}"	1	2026-07-07 14:55:38.233748+03	move_component_to_host
261	56	update	\N	"{\\"inventory_number\\":\\"00-001095\\",\\"name\\":\\"Катюша M247 (МФУ, А4, лазер, ч/б, LAN, Wi-Fi)\\"}"	1	2026-07-07 16:29:34.856134+03	\N
262	56	update	\N	"{\\"inventory_number\\":\\"00-001095\\",\\"name\\":\\"Катюша M247 (МФУ, А4, лазер, ч/б, LAN, Wi-Fi)\\"}"	1	2026-07-07 16:50:53.71725+03	\N
263	65	assign	"{\\"responsible_user_id\\":9,\\"responsible_user_name\\":\\"Тютчев Сергей Николаевич\\"}"	"{\\"responsible_user_id\\":3,\\"responsible_user_name\\":\\"Аптекарева Виктория Михайловна\\"}"	1	2026-07-09 13:44:59.322611+03	\N
264	65	move	"{\\"location_id\\":2,\\"location_name\\":\\"105\\"}"	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	1	2026-07-09 13:44:59.322611+03	\N
265	36	status_change	"{\\"status_id\\":3,\\"status_name\\":\\"В ремонте\\"}"	"{\\"status_id\\":\\"1\\",\\"status_name\\":\\"В эксплуатации\\"}"	1	2026-07-09 14:11:38.341707+03	\N
266	36	update	\N	"{\\"inventory_number\\":\\"МЦ.04-строка15\\",\\"name\\":\\"UNIVERSAL D1\\"}"	1	2026-07-09 14:11:39.034811+03	\N
267	34	status_change	"{\\"status_id\\":1,\\"status_name\\":\\"В эксплуатации\\"}"	"{\\"status_id\\":\\"3\\",\\"status_name\\":\\"В ремонте\\"}"	1	2026-07-09 14:12:22.448359+03	\N
268	34	update	\N	"{\\"inventory_number\\":\\"МЦ.04.1\\",\\"name\\":\\"ARBYTE\\"}"	1	2026-07-09 14:12:23.114287+03	\N
269	33	update	\N	"{\\"inventory_number\\":\\"МЦ.04-ups-9\\",\\"name\\":\\"APC Back-UPS 650 ВА (BX650CI-RS)\\"}"	1	2026-07-09 14:13:51.466678+03	\N
270	33	update	\N	"{\\"inventory_number\\":\\"МЦ.04-ups-9\\",\\"name\\":\\"APC Back-UPS 650 ВА (BX650CI-RS)\\"}"	1	2026-07-09 14:13:52.102349+03	\N
271	33	update	\N	"{\\"inventory_number\\":\\"МЦ.04-ups-9\\",\\"name\\":\\"APC Back-UPS 650 ВА (BX650CI-RS)\\"}"	1	2026-07-09 14:29:34.190773+03	\N
272	33	update	\N	"{\\"inventory_number\\":\\"МЦ.04-ups-9\\",\\"name\\":\\"APC Back-UPS 650 ВА (BX650CI-RS)\\"}"	1	2026-07-09 14:29:34.797909+03	\N
273	28	status_change	"{\\"status_id\\":1,\\"status_name\\":\\"В эксплуатации\\"}"	"{\\"status_id\\":\\"3\\",\\"status_name\\":\\"В ремонте\\"}"	1	2026-07-09 14:41:49.87835+03	\N
274	28	update	\N	"{\\"inventory_number\\":\\"99036\\",\\"name\\":\\"Flextron\\"}"	1	2026-07-09 14:41:50.584745+03	\N
275	34	update	\N	"{\\"inventory_number\\":\\"МЦ.04.1\\",\\"name\\":\\"ARBYTE\\"}"	1	2026-07-09 15:20:11.232297+03	\N
276	34	update	\N	"{\\"inventory_number\\":\\"МЦ.04.1\\",\\"name\\":\\"ARBYTE\\"}"	1	2026-07-09 15:20:12.265553+03	\N
277	121	create	\N	"{\\"inventory_number\\":\\"МЦ.04\\",\\"name\\":\\"Коммутатор HPE 1920S-48G-4SFP\\"}"	1	2026-07-10 09:46:49.149697+03	\N
278	122	create	\N	"{\\"inventory_number\\":\\"МЦ.04\\",\\"name\\":\\"Коммутатор HPE 1920S-48G-4SFP\\"}"	1	2026-07-10 09:46:49.703454+03	\N
279	101	assign	"{\\"responsible_user_id\\":0,\\"responsible_user_name\\":\\"не назначен\\"}"	"{\\"responsible_user_id\\":24,\\"responsible_user_name\\":\\"Шворнев Владислав Николаевич\\"}"	24	2026-07-10 10:33:20.628105+03	\N
280	101	move	"{\\"location_id\\":12,\\"location_name\\":\\"116 склад\\"}"	"{\\"location_id\\":9,\\"location_name\\":\\"306\\"}"	24	2026-07-10 10:33:20.628105+03	\N
281	116	assign	"{\\"responsible_user_id\\":0,\\"responsible_user_name\\":\\"не назначен\\"}"	"{\\"responsible_user_id\\":24,\\"responsible_user_name\\":\\"Шворнев Владислав Николаевич\\"}"	24	2026-07-10 10:37:26.294551+03	\N
282	116	update	\N	"{\\"parent_equipment_id\\":101,\\"link_type\\":\\"monitor\\"}"	24	2026-07-10 10:37:26.294551+03	move_component_attach
283	116	move	"{\\"location_id\\":12,\\"location_name\\":\\"116 склад\\"}"	"{\\"location_id\\":9,\\"location_name\\":\\"306\\"}"	24	2026-07-10 10:37:26.294551+03	move_component_to_host
284	123	create	\N	"{\\"name\\":\\"RDW 2100\\",\\"equipment_type\\":\\"Системный блок\\",\\"location_id\\":12,\\"delivery_id\\":11,\\"location_name\\":\\"116 склад\\"}"	24	2026-07-10 10:44:55.30153+03	delivery_post
285	124	create	\N	"{\\"name\\":\\"RDW 2100\\",\\"equipment_type\\":\\"Системный блок\\",\\"location_id\\":12,\\"delivery_id\\":11,\\"location_name\\":\\"116 склад\\"}"	24	2026-07-10 10:44:55.30153+03	delivery_post
286	125	create	\N	"{\\"name\\":\\"RDW 2100\\",\\"equipment_type\\":\\"Системный блок\\",\\"location_id\\":12,\\"delivery_id\\":11,\\"location_name\\":\\"116 склад\\"}"	24	2026-07-10 10:44:55.30153+03	delivery_post
287	126	create	\N	"{\\"name\\":\\"RDW 2100\\",\\"equipment_type\\":\\"Системный блок\\",\\"location_id\\":12,\\"delivery_id\\":11,\\"location_name\\":\\"116 склад\\"}"	24	2026-07-10 10:44:55.30153+03	delivery_post
288	127	create	\N	"{\\"name\\":\\"RDW 2100\\",\\"equipment_type\\":\\"Системный блок\\",\\"location_id\\":12,\\"delivery_id\\":11,\\"location_name\\":\\"116 склад\\"}"	24	2026-07-10 10:44:55.30153+03	delivery_post
289	128	create	\N	"{\\"name\\":\\"RDW 2100\\",\\"equipment_type\\":\\"Системный блок\\",\\"location_id\\":12,\\"delivery_id\\":11,\\"location_name\\":\\"116 склад\\"}"	24	2026-07-10 10:44:55.30153+03	delivery_post
290	129	create	\N	"{\\"name\\":\\"RDW 2100\\",\\"equipment_type\\":\\"Системный блок\\",\\"location_id\\":12,\\"delivery_id\\":11,\\"location_name\\":\\"116 склад\\"}"	24	2026-07-10 10:44:55.30153+03	delivery_post
291	130	create	\N	"{\\"name\\":\\"RDW 2100\\",\\"equipment_type\\":\\"Системный блок\\",\\"location_id\\":12,\\"delivery_id\\":11,\\"location_name\\":\\"116 склад\\"}"	24	2026-07-10 10:44:55.30153+03	delivery_post
292	131	create	\N	"{\\"name\\":\\"RDW 2100\\",\\"equipment_type\\":\\"Системный блок\\",\\"location_id\\":12,\\"delivery_id\\":11,\\"location_name\\":\\"116 склад\\"}"	24	2026-07-10 10:44:55.30153+03	delivery_post
293	132	create	\N	"{\\"name\\":\\"RDW 2100\\",\\"equipment_type\\":\\"Системный блок\\",\\"location_id\\":12,\\"delivery_id\\":11,\\"location_name\\":\\"116 склад\\"}"	24	2026-07-10 10:44:55.30153+03	delivery_post
294	133	create	\N	"{\\"name\\":\\"MSI 27P\\",\\"equipment_type\\":\\"Монитор\\",\\"location_id\\":12,\\"delivery_id\\":11,\\"location_name\\":\\"116 склад\\"}"	24	2026-07-10 10:44:55.30153+03	delivery_post
295	134	create	\N	"{\\"name\\":\\"MSI 27P\\",\\"equipment_type\\":\\"Монитор\\",\\"location_id\\":12,\\"delivery_id\\":11,\\"location_name\\":\\"116 склад\\"}"	24	2026-07-10 10:44:55.30153+03	delivery_post
296	135	create	\N	"{\\"name\\":\\"MSI 27P\\",\\"equipment_type\\":\\"Монитор\\",\\"location_id\\":12,\\"delivery_id\\":11,\\"location_name\\":\\"116 склад\\"}"	24	2026-07-10 10:44:55.30153+03	delivery_post
297	136	create	\N	"{\\"name\\":\\"MSI 27P\\",\\"equipment_type\\":\\"Монитор\\",\\"location_id\\":12,\\"delivery_id\\":11,\\"location_name\\":\\"116 склад\\"}"	24	2026-07-10 10:44:55.30153+03	delivery_post
298	137	create	\N	"{\\"name\\":\\"MSI 27P\\",\\"equipment_type\\":\\"Монитор\\",\\"location_id\\":12,\\"delivery_id\\":11,\\"location_name\\":\\"116 склад\\"}"	24	2026-07-10 10:44:55.30153+03	delivery_post
299	138	create	\N	"{\\"name\\":\\"MSI 27P\\",\\"equipment_type\\":\\"Монитор\\",\\"location_id\\":12,\\"delivery_id\\":11,\\"location_name\\":\\"116 склад\\"}"	24	2026-07-10 10:44:55.30153+03	delivery_post
300	139	create	\N	"{\\"name\\":\\"MSI 27P\\",\\"equipment_type\\":\\"Монитор\\",\\"location_id\\":12,\\"delivery_id\\":11,\\"location_name\\":\\"116 склад\\"}"	24	2026-07-10 10:44:55.30153+03	delivery_post
301	140	create	\N	"{\\"name\\":\\"MSI 27P\\",\\"equipment_type\\":\\"Монитор\\",\\"location_id\\":12,\\"delivery_id\\":11,\\"location_name\\":\\"116 склад\\"}"	24	2026-07-10 10:44:55.30153+03	delivery_post
302	141	create	\N	"{\\"name\\":\\"MSI 27P\\",\\"equipment_type\\":\\"Монитор\\",\\"location_id\\":12,\\"delivery_id\\":11,\\"location_name\\":\\"116 склад\\"}"	24	2026-07-10 10:44:55.30153+03	delivery_post
303	142	create	\N	"{\\"name\\":\\"MSI 27P\\",\\"equipment_type\\":\\"Монитор\\",\\"location_id\\":12,\\"delivery_id\\":11,\\"location_name\\":\\"116 склад\\"}"	24	2026-07-10 10:44:55.30153+03	delivery_post
304	123	assign	"{\\"responsible_user_id\\":0,\\"responsible_user_name\\":\\"не назначен\\"}"	"{\\"responsible_user_id\\":25,\\"responsible_user_name\\":\\"Покушать Пиццу Николашич\\"}"	24	2026-07-10 10:53:19.310293+03	\N
305	123	move	"{\\"location_id\\":12,\\"location_name\\":\\"116 склад\\"}"	"{\\"location_id\\":9,\\"location_name\\":\\"306\\"}"	24	2026-07-10 10:53:19.310293+03	\N
306	136	assign	"{\\"responsible_user_id\\":0,\\"responsible_user_name\\":\\"не назначен\\"}"	"{\\"responsible_user_id\\":25,\\"responsible_user_name\\":\\"Покушать Пиццу Николашич\\"}"	24	2026-07-10 10:53:35.77719+03	\N
307	136	update	\N	"{\\"parent_equipment_id\\":123,\\"link_type\\":\\"monitor\\"}"	24	2026-07-10 10:53:35.77719+03	move_component_attach
308	136	move	"{\\"location_id\\":12,\\"location_name\\":\\"116 склад\\"}"	"{\\"location_id\\":9,\\"location_name\\":\\"306\\"}"	24	2026-07-10 10:53:35.77719+03	move_component_to_host
309	27	assign	"{\\"responsible_user_id\\":0,\\"responsible_user_name\\":\\"не назначен\\"}"	"{\\"responsible_user_id\\":25,\\"responsible_user_name\\":\\"Покушать Пиццу Николашич\\"}"	24	2026-07-10 10:53:48.987658+03	\N
310	27	update	\N	"{\\"parent_equipment_id\\":123,\\"link_type\\":\\"ups\\"}"	24	2026-07-10 10:53:48.987658+03	move_component_attach
311	27	move	"{\\"location_id\\":11,\\"location_name\\":\\"306 склад\\"}"	"{\\"location_id\\":9,\\"location_name\\":\\"306\\"}"	24	2026-07-10 10:53:48.987658+03	move_component_to_host
312	82	assign	"{\\"responsible_user_id\\":0,\\"responsible_user_name\\":\\"не назначен\\"}"	"{\\"responsible_user_id\\":25,\\"responsible_user_name\\":\\"Покушать Пиццу Николашич\\"}"	24	2026-07-10 10:54:12.0349+03	\N
313	82	move	"{\\"location_id\\":11,\\"location_name\\":\\"306 склад\\"}"	"{\\"location_id\\":9,\\"location_name\\":\\"306\\"}"	24	2026-07-10 10:54:12.0349+03	\N
314	82	update	\N	"{\\"inventory_number\\":\\"МЦ.04\\",\\"name\\":\\"Canon i-Sensys MF744cdw\\"}"	24	2026-07-10 10:56:19.460611+03	\N
315	82	update	\N	"{\\"inventory_number\\":\\"МЦ.04\\",\\"name\\":\\"Canon i-Sensys MF744cdw\\"}"	24	2026-07-10 10:57:04.707198+03	\N
316	82	update	\N	"{\\"inventory_number\\":\\"МЦ.04\\",\\"name\\":\\"Canon i-Sensys MF744cdw\\"}"	24	2026-07-10 10:57:39.497097+03	\N
317	82	update	\N	"{\\"inventory_number\\":\\"МЦ.04\\",\\"name\\":\\"Canon i-Sensys MF744cdw\\"}"	24	2026-07-10 10:57:59.644386+03	\N
318	82	update	\N	"{\\"inventory_number\\":\\"МЦ.04\\",\\"name\\":\\"Canon i-Sensys MF744cdw\\"}"	24	2026-07-10 10:58:14.799859+03	\N
319	82	update	\N	"{\\"inventory_number\\":\\"МЦ.04\\",\\"name\\":\\"Canon i-Sensys MF744cdw\\"}"	24	2026-07-10 10:58:35.445627+03	\N
320	82	update	\N	"{\\"inventory_number\\":\\"МЦ.04\\",\\"name\\":\\"Canon i-Sensys MF744cdw\\"}"	24	2026-07-10 10:59:11.010806+03	\N
321	82	update	\N	"{\\"inventory_number\\":\\"МЦ.04\\",\\"name\\":\\"Canon i-Sensys MF744cdw\\"}"	24	2026-07-10 11:05:09.007379+03	\N
322	143	create	\N	"{\\"inventory_number\\":\\"М.Ц\\",\\"name\\":\\"APC Back-UPS 650 ВА (BX650CI-RS)\\"}"	24	2026-07-10 11:07:31.753047+03	\N
323	31	move	"{\\"location_id\\":2,\\"location_name\\":\\"105\\"}"	"{\\"location_id\\":9,\\"location_name\\":\\"306\\"}"	24	2026-07-10 11:12:19.436522+03	\N
324	32	move	"{\\"location_id\\":2,\\"location_name\\":\\"105\\"}"	"{\\"location_id\\":9,\\"location_name\\":\\"306\\"}"	24	2026-07-10 11:12:19.436522+03	\N
325	33	move	"{\\"location_id\\":2,\\"location_name\\":\\"105\\"}"	"{\\"location_id\\":9,\\"location_name\\":\\"306\\"}"	24	2026-07-10 11:12:19.436522+03	\N
326	82	update	\N	"{\\"inventory_number\\":\\"МЦ.04\\",\\"name\\":\\"Canon i-Sensys MF744cdw\\"}"	24	2026-07-10 11:20:54.785146+03	\N
327	82	update	\N	"{\\"inventory_number\\":\\"МЦ.04\\",\\"name\\":\\"Canon i-Sensys MF744cdw\\"}"	24	2026-07-10 11:21:08.299364+03	\N
328	82	update	\N	"{\\"inventory_number\\":\\"МЦ.04\\",\\"name\\":\\"Canon i-Sensys MF744cdw\\"}"	24	2026-07-10 11:23:09.021972+03	\N
329	121	update	\N	"{\\"inventory_number\\":\\"МЦ.04\\",\\"name\\":\\"Коммутатор HPE 1920S-48G-4SFP\\"}"	24	2026-07-10 11:25:46.511906+03	\N
330	65	update	\N	"{\\"inventory_number\\":\\"(списанная МЦ)\\",\\"name\\":\\"Canon i-Sensys MF4690PL\\"}"	1	2026-07-10 11:31:48.744277+03	\N
331	65	update	\N	"{\\"inventory_number\\":\\"(списанная МЦ)\\",\\"name\\":\\"Canon i-Sensys MF4690PL\\"}"	24	2026-07-10 11:51:45.971032+03	\N
332	65	update	\N	"{\\"inventory_number\\":\\"(списанная МЦ)\\",\\"name\\":\\"Canon i-Sensys MF4690PL\\"}"	24	2026-07-10 11:52:00.152015+03	\N
333	46	move	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	"{\\"location_id\\":14,\\"location_name\\":\\"534\\"}"	24	2026-07-10 11:57:54.383227+03	\N
334	46	assign	"{\\"responsible_user_id\\":12,\\"responsible_user_name\\":\\"Печерский Виталий Васильевич\\"}"	"{\\"responsible_user_id\\":\\"17\\",\\"responsible_user_name\\":\\"Новгородова Елена Викторовна\\"}"	24	2026-07-10 11:59:54.398033+03	\N
335	46	move	"{\\"location_id\\":14,\\"location_name\\":\\"534\\"}"	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	24	2026-07-10 12:04:27.544431+03	\N
336	46	assign	"{\\"responsible_user_id\\":17,\\"responsible_user_name\\":\\"Новгородова Елена Викторовна\\"}"	"{\\"responsible_user_id\\":\\"12\\",\\"responsible_user_name\\":\\"Печерский Виталий Васильевич\\"}"	24	2026-07-10 12:04:27.558126+03	\N
337	34	move	"{\\"location_id\\":2,\\"location_name\\":\\"105\\"}"	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	24	2026-07-10 12:15:59.036932+03	\N
338	28	move	"{\\"location_id\\":2,\\"location_name\\":\\"105\\"}"	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	24	2026-07-10 12:15:59.036932+03	\N
339	29	move	"{\\"location_id\\":2,\\"location_name\\":\\"105\\"}"	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	24	2026-07-10 12:15:59.036932+03	\N
340	30	move	"{\\"location_id\\":2,\\"location_name\\":\\"105\\"}"	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	24	2026-07-10 12:15:59.036932+03	\N
341	35	move	"{\\"location_id\\":2,\\"location_name\\":\\"105\\"}"	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	24	2026-07-10 12:15:59.036932+03	\N
342	87	move	"{\\"location_id\\":2,\\"location_name\\":\\"105\\"}"	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	24	2026-07-10 12:15:59.036932+03	\N
343	34	status_change	"{\\"status_id\\":3,\\"status_name\\":\\"В ремонте\\"}"	"{\\"status_id\\":\\"1\\",\\"status_name\\":\\"В эксплуатации\\"}"	1	2026-07-10 15:22:52.831127+03	\N
344	20	assign	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	"{\\"responsible_user_id\\":3,\\"responsible_user_name\\":\\"Аптекарева Виктория Михайловна\\"}"	24	2026-07-10 15:53:57.964242+03	issue_kit
345	20	move	"{\\"location_id\\":11,\\"location_name\\":\\"306 склад\\"}"	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	24	2026-07-10 15:53:57.964242+03	issue_kit
346	37	update	\N	"{\\"parent_equipment_id\\":20,\\"link_type\\":\\"monitor\\"}"	24	2026-07-10 15:53:57.964242+03	issue_kit
347	37	assign	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	"{\\"responsible_user_id\\":3,\\"responsible_user_name\\":\\"Аптекарева Виктория Михайловна\\"}"	24	2026-07-10 15:53:57.964242+03	issue_kit
348	37	move	"{\\"location_id\\":11,\\"location_name\\":\\"306 склад\\"}"	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	24	2026-07-10 15:53:57.964242+03	issue_kit
349	22	update	\N	"{\\"parent_equipment_id\\":20,\\"link_type\\":\\"ups\\"}"	24	2026-07-10 15:53:57.964242+03	issue_kit
350	22	assign	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	"{\\"responsible_user_id\\":3,\\"responsible_user_name\\":\\"Аптекарева Виктория Михайловна\\"}"	24	2026-07-10 15:53:57.964242+03	issue_kit
351	22	move	"{\\"location_id\\":11,\\"location_name\\":\\"306 склад\\"}"	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	24	2026-07-10 15:53:57.964242+03	issue_kit
352	32	update	"{\\"parent_equipment_id\\":31,\\"link_type\\":\\"monitor\\"}"	"{\\"parent_equipment_id\\":null,\\"link_type\\":null}"	1	2026-07-10 15:59:40.546234+03	move_to_warehouse_detach_kit
353	33	update	"{\\"parent_equipment_id\\":31,\\"link_type\\":\\"ups\\"}"	"{\\"parent_equipment_id\\":null,\\"link_type\\":null}"	1	2026-07-10 15:59:40.546234+03	move_to_warehouse_detach_kit
354	31	move	"{\\"location_id\\":9,\\"location_name\\":\\"306\\"}"	"{\\"location_id\\":12,\\"location_name\\":\\"116 склад\\"}"	1	2026-07-10 15:59:40.546234+03	move_to_warehouse
355	31	unassign	"{\\"responsible_user_id\\":8,\\"responsible_user_name\\":\\"Иваненко Константин Викторович\\"}"	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	1	2026-07-10 15:59:40.546234+03	move_to_warehouse
356	32	move	"{\\"location_id\\":9,\\"location_name\\":\\"306\\"}"	"{\\"location_id\\":12,\\"location_name\\":\\"116 склад\\"}"	1	2026-07-10 15:59:40.546234+03	move_to_warehouse
357	32	unassign	"{\\"responsible_user_id\\":8,\\"responsible_user_name\\":\\"Иваненко Константин Викторович\\"}"	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	1	2026-07-10 15:59:40.546234+03	move_to_warehouse
358	33	move	"{\\"location_id\\":9,\\"location_name\\":\\"306\\"}"	"{\\"location_id\\":12,\\"location_name\\":\\"116 склад\\"}"	1	2026-07-10 15:59:40.546234+03	move_to_warehouse
359	33	unassign	"{\\"responsible_user_id\\":8,\\"responsible_user_name\\":\\"Иваненко Константин Викторович\\"}"	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	1	2026-07-10 15:59:40.546234+03	move_to_warehouse
360	43	assign	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	"{\\"responsible_user_id\\":8,\\"responsible_user_name\\":\\"Иваненко Константин Викторович\\"}"	1	2026-07-10 16:00:34.560002+03	issue_kit
361	43	move	"{\\"location_id\\":11,\\"location_name\\":\\"306 склад\\"}"	"{\\"location_id\\":9,\\"location_name\\":\\"306\\"}"	1	2026-07-10 16:00:34.560002+03	issue_kit
362	44	update	\N	"{\\"parent_equipment_id\\":43,\\"link_type\\":\\"monitor\\"}"	1	2026-07-10 16:00:34.560002+03	issue_kit
363	44	assign	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	"{\\"responsible_user_id\\":8,\\"responsible_user_name\\":\\"Иваненко Константин Викторович\\"}"	1	2026-07-10 16:00:34.560002+03	issue_kit
364	44	move	"{\\"location_id\\":11,\\"location_name\\":\\"306 склад\\"}"	"{\\"location_id\\":9,\\"location_name\\":\\"306\\"}"	1	2026-07-10 16:00:34.560002+03	issue_kit
365	38	update	\N	"{\\"parent_equipment_id\\":43,\\"link_type\\":\\"ups\\"}"	1	2026-07-10 16:00:34.560002+03	issue_kit
366	38	assign	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	"{\\"responsible_user_id\\":8,\\"responsible_user_name\\":\\"Иваненко Константин Викторович\\"}"	1	2026-07-10 16:00:34.560002+03	issue_kit
367	38	move	"{\\"location_id\\":11,\\"location_name\\":\\"306 склад\\"}"	"{\\"location_id\\":9,\\"location_name\\":\\"306\\"}"	1	2026-07-10 16:00:34.560002+03	issue_kit
368	44	update	"{\\"parent_equipment_id\\":43,\\"link_type\\":\\"monitor\\"}"	"{\\"parent_equipment_id\\":null,\\"link_type\\":null}"	1	2026-07-10 16:01:06.462548+03	move_to_warehouse_detach_kit
369	38	update	"{\\"parent_equipment_id\\":43,\\"link_type\\":\\"ups\\"}"	"{\\"parent_equipment_id\\":null,\\"link_type\\":null}"	1	2026-07-10 16:01:06.462548+03	move_to_warehouse_detach_kit
370	43	move	"{\\"location_id\\":9,\\"location_name\\":\\"306\\"}"	"{\\"location_id\\":12,\\"location_name\\":\\"116 склад\\"}"	1	2026-07-10 16:01:06.462548+03	move_to_warehouse
371	43	unassign	"{\\"responsible_user_id\\":8,\\"responsible_user_name\\":\\"Иваненко Константин Викторович\\"}"	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	1	2026-07-10 16:01:06.462548+03	move_to_warehouse
372	44	move	"{\\"location_id\\":9,\\"location_name\\":\\"306\\"}"	"{\\"location_id\\":12,\\"location_name\\":\\"116 склад\\"}"	1	2026-07-10 16:01:06.462548+03	move_to_warehouse
373	44	unassign	"{\\"responsible_user_id\\":8,\\"responsible_user_name\\":\\"Иваненко Константин Викторович\\"}"	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	1	2026-07-10 16:01:06.462548+03	move_to_warehouse
374	38	move	"{\\"location_id\\":9,\\"location_name\\":\\"306\\"}"	"{\\"location_id\\":12,\\"location_name\\":\\"116 склад\\"}"	1	2026-07-10 16:01:06.462548+03	move_to_warehouse
375	38	unassign	"{\\"responsible_user_id\\":8,\\"responsible_user_name\\":\\"Иваненко Константин Викторович\\"}"	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	1	2026-07-10 16:01:06.462548+03	move_to_warehouse
376	31	assign	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	"{\\"responsible_user_id\\":8,\\"responsible_user_name\\":\\"Иваненко Константин Викторович\\"}"	1	2026-07-10 16:04:44.046911+03	issue_kit
377	31	move	"{\\"location_id\\":12,\\"location_name\\":\\"116 склад\\"}"	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	1	2026-07-10 16:04:44.046911+03	issue_kit
378	118	update	\N	"{\\"parent_equipment_id\\":31,\\"link_type\\":\\"monitor\\"}"	1	2026-07-10 16:04:44.046911+03	issue_kit
379	118	assign	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	"{\\"responsible_user_id\\":8,\\"responsible_user_name\\":\\"Иваненко Константин Викторович\\"}"	1	2026-07-10 16:04:44.046911+03	issue_kit
380	118	move	"{\\"location_id\\":12,\\"location_name\\":\\"116 склад\\"}"	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	1	2026-07-10 16:04:44.046911+03	issue_kit
381	33	update	\N	"{\\"parent_equipment_id\\":31,\\"link_type\\":\\"ups\\"}"	1	2026-07-10 16:04:44.046911+03	issue_kit
382	33	assign	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	"{\\"responsible_user_id\\":8,\\"responsible_user_name\\":\\"Иваненко Константин Викторович\\"}"	1	2026-07-10 16:04:44.046911+03	issue_kit
383	33	move	"{\\"location_id\\":12,\\"location_name\\":\\"116 склад\\"}"	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	1	2026-07-10 16:04:44.046911+03	issue_kit
384	45	move	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	"{\\"location_id\\":7,\\"location_name\\":\\"118\\"}"	24	2026-07-14 11:25:48.908708+03	\N
385	46	move	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	"{\\"location_id\\":7,\\"location_name\\":\\"118\\"}"	24	2026-07-14 11:25:48.908708+03	\N
386	62	move	"{\\"location_id\\":2,\\"location_name\\":\\"105\\"}"	"{\\"location_id\\":14,\\"location_name\\":\\"534\\"}"	24	2026-07-14 11:26:30.547297+03	\N
387	80	move	"{\\"location_id\\":2,\\"location_name\\":\\"105\\"}"	"{\\"location_id\\":14,\\"location_name\\":\\"534\\"}"	24	2026-07-14 11:26:30.547297+03	\N
388	45	update	\N	"{\\"inventory_number\\":\\"00-000959\\",\\"name\\":\\"Некстген3\\"}"	1	2026-07-14 11:42:26.598982+03	\N
389	144	create	\N	"{\\"inventory_number\\":\\"МЦ.04\\",\\"name\\":\\"Dell DQ200\\"}"	1	2026-07-14 13:36:09.305908+03	\N
390	118	update	"{\\"parent_equipment_id\\":31,\\"link_type\\":\\"monitor\\"}"	"{\\"parent_equipment_id\\":null}"	24	2026-07-14 14:07:58.359757+03	replace_from_warehouse_detach
391	26	assign	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	"{\\"responsible_user_id\\":8,\\"responsible_user_name\\":\\"Иваненко Константин Викторович\\"}"	24	2026-07-14 14:07:58.359757+03	replace_from_warehouse
392	26	move	"{\\"location_id\\":11,\\"location_name\\":\\"306 склад\\"}"	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	24	2026-07-14 14:07:58.359757+03	replace_from_warehouse
393	26	update	\N	"{\\"parent_equipment_id\\":31,\\"link_type\\":\\"monitor\\"}"	24	2026-07-14 14:07:58.359757+03	replace_from_warehouse_attach
394	118	move	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	"{\\"location_id\\":11,\\"location_name\\":\\"306 склад\\"}"	24	2026-07-14 14:07:58.359757+03	replace_from_warehouse
395	118	unassign	"{\\"responsible_user_id\\":8,\\"responsible_user_name\\":\\"Иваненко Константин Викторович\\"}"	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	24	2026-07-14 14:07:58.359757+03	replace_from_warehouse
396	118	status_change	"{\\"status_id\\":1,\\"status_name\\":\\"В эксплуатации\\"}"	"{\\"status_id\\":3,\\"status_name\\":\\"В ремонте\\"}"	24	2026-07-14 14:07:58.359757+03	replace_from_warehouse
397	118	update	"{\\"description\\":null}"	"{\\"description\\":\\"Битая матрица, замена по служебке\\"}"	24	2026-07-14 14:07:58.359757+03	replace_from_warehouse
398	118	update	\N	"{\\"inventory_number\\":\\"М.Ц\\",\\"name\\":\\"Lenovo G30\\"}"	24	2026-07-14 14:09:45.738937+03	\N
399	118	status_change	"{\\"status_id\\":3,\\"status_name\\":\\"В ремонте\\"}"	"{\\"status_id\\":\\"6\\",\\"status_name\\":\\"Неисправен\\"}"	24	2026-07-14 14:15:03.589161+03	\N
400	37	update	"{\\"parent_equipment_id\\":20,\\"link_type\\":\\"monitor\\"}"	"{\\"parent_equipment_id\\":null}"	24	2026-07-14 14:15:44.681484+03	replace_from_warehouse_detach
401	21	assign	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	"{\\"responsible_user_id\\":3,\\"responsible_user_name\\":\\"Аптекарева Виктория Михайловна\\"}"	24	2026-07-14 14:15:44.681484+03	replace_from_warehouse
402	21	move	"{\\"location_id\\":11,\\"location_name\\":\\"306 склад\\"}"	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	24	2026-07-14 14:15:44.681484+03	replace_from_warehouse
403	21	update	\N	"{\\"parent_equipment_id\\":20,\\"link_type\\":\\"monitor\\"}"	24	2026-07-14 14:15:44.681484+03	replace_from_warehouse_attach
404	37	move	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	"{\\"location_id\\":11,\\"location_name\\":\\"306 склад\\"}"	24	2026-07-14 14:15:44.681484+03	replace_from_warehouse
405	37	unassign	"{\\"responsible_user_id\\":3,\\"responsible_user_name\\":\\"Аптекарева Виктория Михайловна\\"}"	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	24	2026-07-14 14:15:44.681484+03	replace_from_warehouse
406	37	update	"{\\"description\\":null}"	"{\\"description\\":\\"Сломалась ножка\\"}"	24	2026-07-14 14:15:44.681484+03	replace_from_warehouse
407	8	update	"{\\"parent_equipment_id\\":7,\\"link_type\\":\\"monitor\\"}"	"{\\"parent_equipment_id\\":null}"	24	2026-07-14 14:17:01.800909+03	replace_from_warehouse_detach
408	36	assign	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	"{\\"responsible_user_id\\":4,\\"responsible_user_name\\":\\"Елистратова Мария Сергеевна\\"}"	24	2026-07-14 14:17:01.800909+03	replace_from_warehouse
409	36	move	"{\\"location_id\\":11,\\"location_name\\":\\"306 склад\\"}"	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	24	2026-07-14 14:17:01.800909+03	replace_from_warehouse
410	8	update	\N	"{\\"parent_equipment_id\\":36,\\"link_type\\":\\"monitor\\"}"	24	2026-07-14 14:17:01.800909+03	replace_from_warehouse_attach
411	7	move	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	"{\\"location_id\\":11,\\"location_name\\":\\"306 склад\\"}"	24	2026-07-14 14:17:01.800909+03	replace_from_warehouse
412	7	unassign	"{\\"responsible_user_id\\":4,\\"responsible_user_name\\":\\"Елистратова Мария Сергеевна\\"}"	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	24	2026-07-14 14:17:01.800909+03	replace_from_warehouse
413	7	status_change	"{\\"status_id\\":1,\\"status_name\\":\\"В эксплуатации\\"}"	"{\\"status_id\\":6,\\"status_name\\":\\"Неисправен\\"}"	24	2026-07-14 14:17:01.800909+03	replace_from_warehouse
414	7	update	"{\\"description\\":\\"\\"}"	"{\\"description\\":\\"Взорвался БП\\"}"	24	2026-07-14 14:17:01.800909+03	replace_from_warehouse
415	37	status_change	"{\\"status_id\\":1,\\"status_name\\":\\"В эксплуатации\\"}"	"{\\"status_id\\":\\"6\\",\\"status_name\\":\\"Неисправен\\"}"	24	2026-07-14 14:17:28.76179+03	\N
416	48	update	"{\\"parent_equipment_id\\":47,\\"link_type\\":\\"monitor\\"}"	"{\\"parent_equipment_id\\":null}"	24	2026-07-14 14:27:08.503842+03	replace_from_warehouse_detach
417	49	update	"{\\"parent_equipment_id\\":47,\\"link_type\\":\\"monitor\\"}"	"{\\"parent_equipment_id\\":null}"	24	2026-07-14 14:27:08.503842+03	replace_from_warehouse_detach
418	50	update	"{\\"parent_equipment_id\\":47,\\"link_type\\":\\"ups\\"}"	"{\\"parent_equipment_id\\":null}"	24	2026-07-14 14:27:08.503842+03	replace_from_warehouse_detach
419	91	assign	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	"{\\"responsible_user_id\\":13,\\"responsible_user_name\\":\\"Козлова Ангелина Вячеславовна\\"}"	24	2026-07-14 14:27:08.503842+03	replace_from_warehouse
420	91	move	"{\\"location_id\\":11,\\"location_name\\":\\"306 склад\\"}"	"{\\"location_id\\":5,\\"location_name\\":\\"303\\"}"	24	2026-07-14 14:27:08.503842+03	replace_from_warehouse
421	48	update	\N	"{\\"parent_equipment_id\\":91,\\"link_type\\":\\"monitor\\"}"	24	2026-07-14 14:27:08.503842+03	replace_from_warehouse_attach
422	49	update	\N	"{\\"parent_equipment_id\\":91,\\"link_type\\":\\"monitor\\"}"	24	2026-07-14 14:27:08.503842+03	replace_from_warehouse_attach
423	50	update	\N	"{\\"parent_equipment_id\\":91,\\"link_type\\":\\"ups\\"}"	24	2026-07-14 14:27:08.503842+03	replace_from_warehouse_attach
424	91	update	\N	"{\\"hostname\\":\\"303-w10p64-96\\",\\"ip\\":\\"10.2.2.96\\"}"	24	2026-07-14 14:27:08.503842+03	replace_from_warehouse
425	47	update	\N	"{\\"hostname\\":null,\\"ip\\":null}"	24	2026-07-14 14:27:08.503842+03	replace_from_warehouse
426	47	move	"{\\"location_id\\":5,\\"location_name\\":\\"303\\"}"	"{\\"location_id\\":11,\\"location_name\\":\\"306 склад\\"}"	24	2026-07-14 14:27:08.503842+03	replace_from_warehouse
427	47	unassign	"{\\"responsible_user_id\\":13,\\"responsible_user_name\\":\\"Козлова Ангелина Вячеславовна\\"}"	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	24	2026-07-14 14:27:08.503842+03	replace_from_warehouse
428	47	status_change	"{\\"status_id\\":1,\\"status_name\\":\\"В эксплуатации\\"}"	"{\\"status_id\\":6,\\"status_name\\":\\"Неисправен\\"}"	24	2026-07-14 14:27:08.503842+03	replace_from_warehouse
429	47	update	"{\\"description\\":null}"	"{\\"description\\":\\"Снова материнка\\"}"	24	2026-07-14 14:27:08.503842+03	replace_from_warehouse
430	8	update	\N	"{\\"inventory_number\\":\\"МЦ.04-mon-3\\",\\"name\\":\\"Samsung SyncMaster SA200\\"}"	1	2026-07-15 11:18:52.39121+03	\N
431	8	update	\N	"{\\"inventory_number\\":\\"МЦ.04\\",\\"name\\":\\"Samsung SyncMaster SA200\\"}"	1	2026-07-15 11:19:00.042218+03	\N
432	26	assign	"{\\"responsible_user_id\\":8,\\"responsible_user_name\\":\\"Иваненко Константин Викторович\\"}"	"{\\"responsible_user_id\\":19,\\"responsible_user_name\\":\\"Кулаков Дмитрий Дмитриевич\\"}"	1	2026-07-15 11:30:16.117405+03	\N
433	26	move	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	"{\\"location_id\\":9,\\"location_name\\":\\"306\\"}"	1	2026-07-15 11:30:16.117405+03	\N
434	31	assign	"{\\"responsible_user_id\\":8,\\"responsible_user_name\\":\\"Иваненко Константин Викторович\\"}"	"{\\"responsible_user_id\\":19,\\"responsible_user_name\\":\\"Кулаков Дмитрий Дмитриевич\\"}"	1	2026-07-15 11:30:55.314851+03	\N
435	31	move	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	"{\\"location_id\\":9,\\"location_name\\":\\"306\\"}"	1	2026-07-15 11:30:55.314851+03	\N
436	33	assign	"{\\"responsible_user_id\\":8,\\"responsible_user_name\\":\\"Иваненко Константин Викторович\\"}"	"{\\"responsible_user_id\\":19,\\"responsible_user_name\\":\\"Кулаков Дмитрий Дмитриевич\\"}"	1	2026-07-15 11:30:55.314851+03	\N
437	33	move	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	"{\\"location_id\\":9,\\"location_name\\":\\"306\\"}"	1	2026-07-15 11:30:55.314851+03	\N
438	145	create	\N	"{\\"inventory_number\\":\\"МЦ.04\\",\\"name\\":\\"Powercom Raptor RPT-1000A EURO 600Вт 1000ВА\\"}"	1	2026-07-15 11:36:05.30102+03	\N
439	133	update	\N	"{\\"parent_equipment_id\\":20,\\"link_type\\":\\"monitor\\"}"	1	2026-07-15 11:37:21.250064+03	issue_from_warehouse
440	133	assign	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	"{\\"responsible_user_id\\":3,\\"responsible_user_name\\":\\"Аптекарева Виктория Михайловна\\"}"	1	2026-07-15 11:37:21.250064+03	issue_from_warehouse
441	133	move	"{\\"location_id\\":12,\\"location_name\\":\\"116 склад\\"}"	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	1	2026-07-15 11:37:21.250064+03	issue_from_warehouse
442	143	move	"{\\"location_id\\":5,\\"location_name\\":\\"303\\"}"	"{\\"location_id\\":12,\\"location_name\\":\\"116 склад\\"}"	1	2026-07-15 11:40:13.624337+03	move_to_warehouse
443	143	unassign	"{\\"responsible_user_id\\":3,\\"responsible_user_name\\":\\"Аптекарева Виктория Михайловна\\"}"	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	1	2026-07-15 11:40:13.624337+03	move_to_warehouse
444	143	update	\N	"{\\"parent_equipment_id\\":36,\\"link_type\\":\\"ups\\"}"	1	2026-07-15 11:49:25.385495+03	issue_from_warehouse
445	143	assign	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	"{\\"responsible_user_id\\":4,\\"responsible_user_name\\":\\"Елистратова Мария Сергеевна\\"}"	1	2026-07-15 11:49:25.385495+03	issue_from_warehouse
446	143	move	"{\\"location_id\\":12,\\"location_name\\":\\"116 склад\\"}"	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	1	2026-07-15 11:49:25.385495+03	issue_from_warehouse
447	37	update	\N	"{\\"parent_equipment_id\\":36,\\"link_type\\":\\"monitor\\"}"	24	2026-07-15 11:59:05.822152+03	issue_from_warehouse
448	37	assign	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	"{\\"responsible_user_id\\":4,\\"responsible_user_name\\":\\"Елистратова Мария Сергеевна\\"}"	24	2026-07-15 11:59:05.822152+03	issue_from_warehouse
449	37	move	"{\\"location_id\\":11,\\"location_name\\":\\"306 склад\\"}"	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	24	2026-07-15 11:59:05.822152+03	issue_from_warehouse
450	37	status_change	"{\\"status_id\\":6,\\"status_name\\":\\"Неисправен\\"}"	"{\\"status_id\\":1,\\"status_name\\":\\"В эксплуатации\\"}"	24	2026-07-15 11:59:05.822152+03	issue_from_warehouse
451	118	update	\N	"{\\"parent_equipment_id\\":28,\\"link_type\\":\\"monitor\\"}"	24	2026-07-15 11:59:31.218081+03	issue_from_warehouse
452	118	assign	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	"{\\"responsible_user_id\\":7,\\"responsible_user_name\\":\\"Якушина Ирина Станиславовна\\"}"	24	2026-07-15 11:59:31.218081+03	issue_from_warehouse
453	118	move	"{\\"location_id\\":11,\\"location_name\\":\\"306 склад\\"}"	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	24	2026-07-15 11:59:31.218081+03	issue_from_warehouse
454	118	status_change	"{\\"status_id\\":6,\\"status_name\\":\\"Неисправен\\"}"	"{\\"status_id\\":1,\\"status_name\\":\\"В эксплуатации\\"}"	24	2026-07-15 11:59:31.218081+03	issue_from_warehouse
455	51	update	\N	"{\\"inventory_number\\":\\"МЦ.04-принтер-2\\",\\"name\\":\\"HP LaserJet Pro MFP M428fdn\\"}"	1	2026-07-15 12:02:45.587837+03	\N
456	66	update	\N	"{\\"inventory_number\\":\\"МЦ.04\\",\\"name\\":\\"Canon i-Sensys MF744cdw\\"}"	1	2026-07-15 12:03:21.82007+03	\N
457	8	update	"{\\"parent_equipment_id\\":36,\\"link_type\\":\\"monitor\\"}"	"{\\"parent_equipment_id\\":null,\\"link_type\\":null}"	1	2026-07-15 13:03:10.430025+03	move_to_warehouse_detach_kit
458	8	move	"{\\"location_id\\":4,\\"location_name\\":\\"106\\"}"	"{\\"location_id\\":12,\\"location_name\\":\\"116 склад\\"}"	1	2026-07-15 13:03:10.430025+03	move_to_warehouse
459	8	unassign	"{\\"responsible_user_id\\":4,\\"responsible_user_name\\":\\"Елистратова Мария Сергеевна\\"}"	"{\\"responsible_user_id\\":null,\\"responsible_user_name\\":\\"не назначен\\"}"	1	2026-07-15 13:03:10.430025+03	move_to_warehouse
460	8	status_change	"{\\"status_id\\":1,\\"status_name\\":\\"В эксплуатации\\"}"	"{\\"status_id\\":6,\\"status_name\\":\\"Неисправен\\"}"	1	2026-07-15 13:03:10.430025+03	move_to_warehouse
461	8	update	"{\\"description\\":null}"	"{\\"description\\":\\"Разбилась матрица\\"}"	1	2026-07-15 13:03:10.430025+03	move_to_warehouse
\.


--
-- Data for Name: equipment; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.equipment (id, inventory_number, serial_number, name, status_id, responsible_user_id, location_id, supplier, purchase_date, commissioning_date, warranty_until, description, archived_at, archive_reason, is_archived, is_deleted, created_by_id, updated_by_id, created_at, updated_at, equipment_type, id_type, parent_equipment_id, delivery_id, delivery_unit_id) FROM stdin;
4	МЦ.04.2-строка3	\N	USN Computers (mini)	1	21	5		2013-01-01	\N	2015-01-01	Тестовый коммент	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-30 12:17:40.785208+03	Системный блок	\N	\N	\N	\N
100		\N	МИР 10	1	\N	11	Рога и копыта	2026-06-03	\N	\N	\N	\N	\N	f	f	\N	\N	2026-06-03 11:13:42.936732+03	2026-06-03 11:15:41.608919+03	Системный блок	\N	\N	4	20
20	БП-001171	\N	RDW Xpert GE	1	3	4	\N	2024-05-14	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-07-10 15:53:57.964242+03	Системный блок	\N	\N	\N	\N
88	МЦ.04	\N	APC Back-UPS 650 ВА (белый)	1	2	5		\N	\N	\N		\N	\N	f	f	\N	\N	2026-06-01 08:28:38.085739+03	2026-06-01 08:29:17.728328+03	ИБП	\N	\N	\N	\N
1	МЦ.04.2	\N	105-w7u32-12	1	2	5		2011-12-30	\N	\N		\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-06-01 16:33:42.65171+03	Системный блок	\N	\N	\N	\N
14	МЦ.04.1	\N	103-w10p64-17	1	2	5		\N	\N	\N		\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-06-01 16:34:13.918466+03	Системный блок	\N	\N	\N	\N
43	МЦ.04.2-строка18	\N	Flextron (Integro)	1	\N	12	\N	2010-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-07-10 16:01:06.462548+03	Системный блок	\N	\N	\N	\N
25	МЦ.04 (00-000803)	\N	МИР4	1	\N	11	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-06-02 08:49:05.544563+03	Системный блок	\N	\N	\N	\N
45	00-000959	\N	Некстген3	1	12	7		2022-03-17	\N	\N		\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-07-14 11:42:26.535868+03	Системный блок	\N	\N	\N	\N
144	МЦ.04	\N	Dell DQ200	1	19	9		\N	\N	\N		\N	\N	f	f	\N	\N	2026-07-14 13:36:09.229734+03	2026-07-14 13:36:09.229734+03	Моноблок	\N	\N	\N	\N
36	МЦ.04-строка15	\N	UNIVERSAL D1	1	4	4		2025-09-15	\N	2026-09-15		\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-07-14 14:17:01.800909+03	Системный блок	\N	\N	\N	\N
31	МЦ.04 (00-000804)	\N	МИР4	1	19	9	\N	2020-06-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-07-15 11:30:55.314851+03	Системный блок	\N	\N	\N	\N
92		\N	МИР 10	1	\N	11	Рога и копыта	2026-06-03	\N	\N	\N	\N	\N	f	f	\N	\N	2026-06-03 11:13:42.936732+03	2026-06-03 11:15:41.659313+03	Системный блок	\N	\N	4	12
91		\N	МИР 10	1	13	5	Рога и копыта	2026-06-03	\N	\N	\N	\N	\N	f	f	\N	\N	2026-06-03 11:13:42.936732+03	2026-07-14 14:27:08.503842+03	Системный блок	\N	\N	4	11
110		\N	Inwin Pro	1	\N	12	Мистер Слойкин	2026-07-07	\N	2029-07-07	\N	\N	\N	f	f	\N	\N	2026-07-07 14:54:48.779875+03	2026-07-07 14:54:48.779875+03	Системный блок	\N	\N	8	50
94		\N	МИР 10	1	\N	11	Рога и копыта	2026-06-03	\N	\N	\N	\N	\N	f	f	\N	\N	2026-06-03 11:13:42.936732+03	2026-06-03 11:15:41.662924+03	Системный блок	\N	\N	4	14
47	00-001062	\N	ICL  B102 тип1	6	\N	11	\N	2022-08-30	\N	\N	Снова материнка	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-07-14 14:27:08.503842+03	Системный блок	\N	\N	\N	\N
95		\N	МИР 10	1	\N	11	Рога и копыта	2026-06-03	\N	\N	\N	\N	\N	f	f	\N	\N	2026-06-03 11:13:42.936732+03	2026-06-03 11:15:41.664619+03	Системный блок	\N	\N	4	15
96		\N	МИР 10	1	\N	11	Рога и копыта	2026-06-03	\N	\N	\N	\N	\N	f	f	\N	\N	2026-06-03 11:13:42.936732+03	2026-06-03 11:15:41.666956+03	Системный блок	\N	\N	4	16
97		\N	МИР 10	1	\N	11	Рога и копыта	2026-06-03	\N	\N	\N	\N	\N	f	f	\N	\N	2026-06-03 11:13:42.936732+03	2026-06-03 11:15:41.669703+03	Системный блок	\N	\N	4	17
98		\N	МИР 10	1	\N	11	Рога и копыта	2026-06-03	\N	\N	\N	\N	\N	f	f	\N	\N	2026-06-03 11:13:42.936732+03	2026-06-03 11:15:41.671629+03	Системный блок	\N	\N	4	18
39	МЦ.04-строка16	\N	ООО "ГКС" (ГИГАНТ)	1	11	3	\N	2017-10-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-16 14:24:43.656427+03	Системный блок	\N	\N	\N	\N
99		\N	МИР 10	1	\N	11	Рога и копыта	2026-06-03	\N	\N	\N	\N	\N	f	f	\N	\N	2026-06-03 11:13:42.936732+03	2026-06-03 11:15:41.673347+03	Системный блок	\N	\N	4	19
93		\N	МИР 10	1	19	9	Рога и копыта	2026-06-03	\N	\N	\N	\N	\N	f	f	\N	\N	2026-06-03 11:13:42.936732+03	2026-06-03 11:21:00.487877+03	Системный блок	\N	\N	4	13
41	99036	\N	Flextron	1	16	5		2010-01-01	\N	\N		\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-07-07 13:19:48.672903+03	Системный блок	\N	\N	\N	\N
112		\N	Lenovo G30	1	\N	12	Мистер Слойкин	2026-07-07	\N	2031-07-07	\N	\N	\N	f	f	\N	\N	2026-07-07 14:54:48.779875+03	2026-07-07 14:54:48.779875+03	Монитор	\N	\N	8	52
23	МЦ.04	\N	Lenovo ThinkBook 240	1	2	1		2024-06-04	\N	\N		\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-07-07 14:45:46.546296+03	Ноутбук	\N	\N	\N	\N
102		\N	Inwin Pro	1	\N	12	Мистер Слойкин	2026-07-07	\N	2029-07-07	\N	\N	\N	f	f	\N	\N	2026-07-07 14:54:48.779875+03	2026-07-07 14:54:48.779875+03	Системный блок	\N	\N	8	42
103		\N	Inwin Pro	1	\N	12	Мистер Слойкин	2026-07-07	\N	2029-07-07	\N	\N	\N	f	f	\N	\N	2026-07-07 14:54:48.779875+03	2026-07-07 14:54:48.779875+03	Системный блок	\N	\N	8	43
104		\N	Inwin Pro	1	\N	12	Мистер Слойкин	2026-07-07	\N	2029-07-07	\N	\N	\N	f	f	\N	\N	2026-07-07 14:54:48.779875+03	2026-07-07 14:54:48.779875+03	Системный блок	\N	\N	8	44
105		\N	Inwin Pro	1	\N	12	Мистер Слойкин	2026-07-07	\N	2029-07-07	\N	\N	\N	f	f	\N	\N	2026-07-07 14:54:48.779875+03	2026-07-07 14:54:48.779875+03	Системный блок	\N	\N	8	45
106		\N	Inwin Pro	1	\N	12	Мистер Слойкин	2026-07-07	\N	2029-07-07	\N	\N	\N	f	f	\N	\N	2026-07-07 14:54:48.779875+03	2026-07-07 14:54:48.779875+03	Системный блок	\N	\N	8	46
107		\N	Inwin Pro	1	\N	12	Мистер Слойкин	2026-07-07	\N	2029-07-07	\N	\N	\N	f	f	\N	\N	2026-07-07 14:54:48.779875+03	2026-07-07 14:54:48.779875+03	Системный блок	\N	\N	8	47
108		\N	Inwin Pro	1	\N	12	Мистер Слойкин	2026-07-07	\N	2029-07-07	\N	\N	\N	f	f	\N	\N	2026-07-07 14:54:48.779875+03	2026-07-07 14:54:48.779875+03	Системный блок	\N	\N	8	48
109		\N	Inwin Pro	1	\N	12	Мистер Слойкин	2026-07-07	\N	2029-07-07	\N	\N	\N	f	f	\N	\N	2026-07-07 14:54:48.779875+03	2026-07-07 14:54:48.779875+03	Системный блок	\N	\N	8	49
113		\N	Lenovo G30	1	\N	12	Мистер Слойкин	2026-07-07	\N	2031-07-07	\N	\N	\N	f	f	\N	\N	2026-07-07 14:54:48.779875+03	2026-07-07 14:54:48.779875+03	Монитор	\N	\N	8	53
17	МЦ.04.2-строка8	\N	INWIN	1	5	5	\N	2014-01-01	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-22 13:03:32.988227+03	Системный блок	\N	\N	\N	\N
9	00-000518	\N	ARBYTE	1	2	5	\N	2012-01-01	\N	\N	APC Back-UPS CS	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-22 13:03:32.988227+03	Системный блок	\N	\N	\N	\N
11	00-001028	\N	ICL  B102 тип1	1	2	5	\N	2022-08-30	\N	\N	АСТ ГОЗ	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-22 13:03:32.988227+03	Системный блок	\N	\N	\N	\N
114		\N	Lenovo G30	1	\N	12	Мистер Слойкин	2026-07-07	\N	2031-07-07	\N	\N	\N	f	f	\N	\N	2026-07-07 14:54:48.779875+03	2026-07-07 14:54:48.779875+03	Монитор	\N	\N	8	54
3	МЦ.04-ups-1	\N	Powercom RPT-1000A EURO	1	2	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-22 13:03:32.988227+03	ИБП	\N	\N	\N	\N
2	МЦ.04-mon-1	\N	BENQ BL2201M	1	2	5		2026-05-05	\N	\N		\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-22 13:03:32.988227+03	Монитор	\N	\N	\N	\N
115		\N	Lenovo G30	1	\N	12	Мистер Слойкин	2026-07-07	\N	2031-07-07	\N	\N	\N	f	f	\N	\N	2026-07-07 14:54:48.779875+03	2026-07-07 14:54:48.779875+03	Монитор	\N	\N	8	55
117		\N	Lenovo G30	1	\N	12	Мистер Слойкин	2026-07-07	\N	2031-07-07	\N	\N	\N	f	f	\N	\N	2026-07-07 14:54:48.779875+03	2026-07-07 14:54:48.779875+03	Монитор	\N	\N	8	57
101		\N	Inwin Pro	1	24	9	Мистер Слойкин	2026-07-07	\N	2029-07-07	\N	\N	\N	f	f	\N	\N	2026-07-07 14:54:48.779875+03	2026-07-10 10:33:20.628105+03	Системный блок	\N	\N	8	41
28	99036	\N	Flextron	3	7	4		2010-01-01	\N	\N		\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-07-10 12:15:59.036932+03	Системный блок	\N	\N	\N	\N
5	МЦ.04-mon-2	\N	Nec MultiSync E222W	1	21	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-30 12:16:20.713874+03	Монитор	\N	\N	\N	\N
6	МЦ.04-ups-2	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	1	21	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-30 12:16:20.713874+03	ИБП	\N	\N	\N	\N
89	МЦ.04	\N	МИР4	1	19	9		\N	\N	\N		\N	\N	f	f	\N	\N	2026-06-01 08:31:11.272249+03	2026-06-01 08:31:11.272249+03	Системный блок	\N	\N	\N	\N
24	МЦ.04-mon-9	\N	15,6"	1	2	1	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-07-10 15:07:00.89933+03	Монитор	\N	\N	\N	\N
34	МЦ.04.1	\N	ARBYTE	1	9	4		2010-01-01	\N	\N		\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-07-10 15:22:52.762593+03	Системный блок	\N	\N	\N	\N
22	МЦ.04-ups-6	\N	APC Back-UPS 650 ВА (белый)	1	3	4	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-07-10 15:53:57.964242+03	ИБП	\N	\N	\N	\N
32	МЦ.04-mon-12	\N	Philips 23.8" 241B8QJEB	1	\N	12	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-07-10 15:59:40.546234+03	Монитор	\N	\N	\N	\N
44	МЦ.04-mon-17	\N	Samsung S22C200	1	\N	12	\N	\N	\N	\N	Исходный учётный номер: МЦ.04.2	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-07-10 16:01:06.462548+03	Монитор	\N	\N	\N	\N
38	МЦ.04-ups-10	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	1	\N	12	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-07-10 16:01:06.462548+03	ИБП	\N	\N	\N	\N
40	МЦ.04-mon-15	\N	Samsung S22C200	1	11	3	\N	\N	\N	\N	Исходный учётный номер: МЦ.04.2	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-16 14:24:43.656427+03	Монитор	\N	\N	\N	\N
46	МЦ.04-mon-18	\N	Lenovo L27e-30 27"	1	12	7		\N	\N	\N		\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-07-14 11:25:48.908708+03	Монитор	\N	\N	\N	\N
62	МЦ.04.1-строка13	\N	Сканер Fujitsu fi-6130	1	10	14	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-18 10:23:37.024362+03	2026-07-14 11:26:30.547297+03	Сканер	\N	\N	\N	\N
48	МЦ.04-mon-19	\N	Iiyama ProLite XB3270QS-B1	1	13	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-16 14:24:43.656427+03	Монитор	\N	\N	\N	\N
49	МЦ.04-mon-20	\N	Samsung S22C200	1	13	5	\N	\N	\N	\N	Исходный учётный номер: МЦ.04.2	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-16 14:24:43.656427+03	Монитор	\N	\N	\N	\N
50	МЦ.04-ups-11	\N	Powercom RPT-1000A EURO	1	13	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-16 14:24:43.656427+03	ИБП	\N	\N	\N	\N
119		\N	Lenovo G30	1	\N	12	Мистер Слойкин	2026-07-07	\N	2031-07-07	\N	\N	\N	f	f	\N	\N	2026-07-07 14:54:48.779875+03	2026-07-07 14:54:48.779875+03	Монитор	\N	\N	8	59
120		\N	Lenovo G30	1	\N	12	Мистер Слойкин	2026-07-07	\N	2031-07-07	\N	\N	\N	f	f	\N	\N	2026-07-07 14:54:48.779875+03	2026-07-07 14:54:48.779875+03	Монитор	\N	\N	8	60
66	МЦ.04	\N	Canon i-Sensys MF744cdw	1	3	4		2021-03-02	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-18 10:23:37.024362+03	2026-07-15 12:03:21.799894+03	МФУ	\N	\N	\N	\N
19	МЦ.04-ups-5	\N	APC Back-UPS CS500 (Белый)	1	5	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-22 13:03:32.988227+03	ИБП	\N	\N	\N	\N
53	РБК6950	\N	Konica Minolta bizhub Press C1070	1	14	7	\N	2015-01-26	\N	\N	Учтен для картриджей	\N	\N	f	f	\N	\N	2026-05-18 10:23:37.024362+03	2026-05-18 10:28:52.623708+03	Принтер	\N	\N	\N	\N
54	МОЛ Рыбаков	\N	Konica Minolta bizhub C250i (МФУ, А3, лазер, цвет., LAN)	1	15	7	\N	2024-07-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-18 10:23:37.024362+03	2026-05-18 10:28:52.623708+03	МФУ	\N	\N	\N	\N
55	МОЛ Рыбаков-строка6	\N	Konica Minolta bizhub C250i (МФУ, А3, лазер, цвет., LAN)	1	15	7	\N	2024-07-18	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-18 10:23:37.024362+03	2026-05-18 10:28:52.623708+03	МФУ	\N	\N	\N	\N
52	19099	\N	Konica Minolta bizhub PRO C5501	1	14	7		2008-11-18	\N	\N	Учтен; Тестовый комментарий 2	\N	\N	f	f	\N	\N	2026-05-18 10:23:37.024362+03	2026-05-18 12:25:27.679317+03	Принтер	\N	\N	\N	\N
21	МЦ.04-mon-8	\N	MB27V13FS51	1	3	4	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-07-14 14:15:44.681484+03	Монитор	\N	\N	\N	\N
10	МЦ.04-mon-4	\N	Nec MultiSync E224wi	1	2	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-22 13:03:32.988227+03	Монитор	\N	\N	\N	\N
12	МЦ.04-mon-5	\N	DELL E2313Hf	1	2	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-22 13:03:32.988227+03	Монитор	\N	\N	\N	\N
13	МЦ.04-ups-3	\N	Powercom RPT-1000A EURO	1	2	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-22 13:03:32.988227+03	ИБП	\N	\N	\N	\N
15	МЦ.04-mon-6	\N	LG 22m35	1	2	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-22 13:03:32.988227+03	Монитор	\N	\N	\N	\N
16	МЦ.04-ups-4	\N	Powercom RPT-1000A EURO	1	2	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-22 13:03:32.988227+03	ИБП	\N	\N	\N	\N
18	МЦ.04-mon-7	\N	Iiyama ProLite E2483HS	1	5	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-22 13:03:32.988227+03	Монитор	\N	\N	\N	\N
42	МЦ.04-mon-16	\N	Samsung 24"S24D300H	1	11	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-22 13:03:32.988227+03	Монитор	\N	\N	\N	\N
57	МЦ.04-принтер-8	\N	МФУ HP Color LaserJet Pro MFP M477	1	19	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-18 10:23:37.024362+03	2026-05-28 14:35:23.32482+03	МФУ	\N	\N	\N	\N
7	МЦ.04 (00-000509)	\N	HP Elite Desk 800 G2	6	\N	11		2016-01-01	\N	\N	Взорвался БП	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-07-14 14:17:01.800909+03	Системный блок	\N	\N	\N	\N
124		\N	RDW 2100	1	\N	12	Море-Море231	2026-07-10	\N	2029-07-10	\N	\N	\N	f	f	\N	\N	2026-07-10 10:44:55.30153+03	2026-07-10 10:44:55.30153+03	Системный блок	\N	\N	11	62
125		R54534	RDW 2100	1	\N	12	Море-Море231	2026-07-10	\N	2029-07-10	\N	\N	\N	f	f	\N	\N	2026-07-10 10:44:55.30153+03	2026-07-10 10:44:55.30153+03	Системный блок	\N	\N	11	63
26	МЦ.04-mon-10	\N	ASUS 23.8" BE249QLB	1	19	9	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-07-15 11:30:16.117405+03	Монитор	\N	\N	\N	\N
33	МЦ.04-ups-9	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	19	9		\N	\N	\N		\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-07-15 11:30:55.314851+03	ИБП	\N	\N	\N	\N
37	МЦ.04-mon-14	\N	MSI PRO MP271AP	1	4	4		\N	\N	\N	Сломалась ножка	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-07-15 11:59:05.822152+03	Монитор	\N	\N	\N	\N
118	М.Ц	\N	Lenovo G30	1	7	4	Мистер Слойкин	2026-07-07	\N	2031-07-07	Битая матрица, замена по служебке	\N	\N	f	f	\N	\N	2026-07-07 14:54:48.779875+03	2026-07-15 11:59:31.218081+03	Монитор	\N	\N	8	58
51	МЦ.04-принтер-2	\N	HP LaserJet Pro MFP M428fdn	1	2	6		\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-18 10:23:37.024362+03	2026-07-15 12:02:45.527768+03	МФУ	\N	\N	\N	\N
126		R54335	RDW 2100	1	\N	12	Море-Море231	2026-07-10	\N	2029-07-10	\N	\N	\N	f	f	\N	\N	2026-07-10 10:44:55.30153+03	2026-07-10 10:44:55.30153+03	Системный блок	\N	\N	11	64
127		R54535	RDW 2100	1	\N	12	Море-Море231	2026-07-10	\N	2029-07-10	\N	\N	\N	f	f	\N	\N	2026-07-10 10:44:55.30153+03	2026-07-10 10:44:55.30153+03	Системный блок	\N	\N	11	65
128		R23134	RDW 2100	1	\N	12	Море-Море231	2026-07-10	\N	2029-07-10	\N	\N	\N	f	f	\N	\N	2026-07-10 10:44:55.30153+03	2026-07-10 10:44:55.30153+03	Системный блок	\N	\N	11	66
8	МЦ.04	\N	Samsung SyncMaster SA200	6	\N	12		\N	\N	\N	Разбилась матрица	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-07-15 13:03:10.430025+03	Монитор	\N	\N	\N	\N
122	МЦ.04	\N	Коммутатор HPE 1920S-48G-4SFP	1	19	13		\N	\N	\N		\N	\N	f	f	\N	\N	2026-07-10 09:46:49.682024+03	2026-07-10 11:08:52.52318+03	Прочее	\N	\N	\N	\N
29	МЦ.04-mon-11	\N	Samsung SyncMaster 226cw	1	7	4	\N	\N	\N	\N	Исходный учётный номер: МЦ.04.2	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-07-10 12:15:59.036932+03	Монитор	\N	\N	\N	\N
80	МЦ.04.2-оргтехника-15	\N	Konica Minolta bizhub C280	1	10	14	\N	2011-12-30	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-18 10:28:52.623708+03	2026-07-14 11:26:30.547297+03	Принтер	\N	\N	\N	\N
145	МЦ.04	\N	Powercom Raptor RPT-1000A EURO 600Вт 1000ВА	1	\N	12		\N	\N	\N		\N	\N	f	f	\N	\N	2026-07-15 11:36:05.286389+03	2026-07-15 11:36:05.286389+03	ИБП	\N	\N	\N	\N
133	М.Ц	\N	MSI 27P	1	3	4	Море-Море231	2026-07-10	\N	2028-07-10	\N	\N	\N	f	f	\N	\N	2026-07-10 10:44:55.30153+03	2026-07-15 11:37:21.250064+03	Монитор	\N	\N	11	71
90	МЦ.04	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	19	9		\N	\N	\N		\N	\N	f	f	\N	\N	2026-06-01 08:41:35.254637+03	2026-06-01 08:41:35.254637+03	ИБП	\N	\N	\N	\N
143	М.Ц	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	4	4		\N	\N	\N		\N	\N	f	f	\N	\N	2026-07-10 11:07:31.744695+03	2026-07-15 11:49:25.385495+03	ИБП	\N	\N	\N	\N
63	НИИСУ-строка14	\N	Fujitsu fi-6130	1	\N	11		\N	\N	\N		\N	\N	f	f	\N	\N	2026-05-18 10:23:37.024362+03	2026-06-02 08:49:05.544563+03	Сканер	\N	\N	\N	\N
78	МЦ.04.1	\N	Сканер Fujitsu fi-6130	1	8	4		\N	\N	\N		\N	\N	f	f	\N	\N	2026-05-18 10:28:52.623708+03	2026-07-07 13:19:33.065702+03	Сканер	\N	\N	\N	\N
111		\N	Lenovo G30	1	19	9	Мистер Слойкин	2026-07-07	\N	2031-07-07	\N	\N	\N	f	f	\N	\N	2026-07-07 14:54:48.779875+03	2026-07-07 14:55:38.233748+03	Монитор	\N	\N	8	51
56	00-001095	\N	Катюша M247 (МФУ, А4, лазер, ч/б, LAN, Wi-Fi)	1	19	5		2023-01-17	\N	\N		\N	\N	f	f	\N	\N	2026-05-18 10:23:37.024362+03	2026-07-07 16:50:53.693545+03	МФУ	\N	\N	\N	\N
136	М.Ц	\N	MSI 27P	1	25	9	Море-Море231	2026-07-10	\N	2028-07-10	\N	\N	\N	f	f	\N	\N	2026-07-10 10:44:55.30153+03	2026-07-10 10:53:35.77719+03	Монитор	\N	\N	11	74
116		\N	Lenovo G30	1	24	9	Мистер Слойкин	2026-07-07	\N	2031-07-07	\N	\N	\N	f	f	\N	\N	2026-07-07 14:54:48.779875+03	2026-07-10 10:37:26.294551+03	Монитор	\N	\N	8	56
129		R23138	RDW 2100	1	\N	12	Море-Море231	2026-07-10	\N	2029-07-10	\N	\N	\N	f	f	\N	\N	2026-07-10 10:44:55.30153+03	2026-07-10 10:44:55.30153+03	Системный блок	\N	\N	11	67
130		R54537	RDW 2100	1	\N	12	Море-Море231	2026-07-10	\N	2029-07-10	\N	\N	\N	f	f	\N	\N	2026-07-10 10:44:55.30153+03	2026-07-10 10:44:55.30153+03	Системный блок	\N	\N	11	68
131		R54333	RDW 2100	1	\N	12	Море-Море231	2026-07-10	\N	2029-07-10	\N	\N	\N	f	f	\N	\N	2026-07-10 10:44:55.30153+03	2026-07-10 10:44:55.30153+03	Системный блок	\N	\N	11	69
132		\N	RDW 2100	1	\N	12	Море-Море231	2026-07-10	\N	2029-07-10	\N	\N	\N	f	f	\N	\N	2026-07-10 10:44:55.30153+03	2026-07-10 10:44:55.30153+03	Системный блок	\N	\N	11	70
61	00-001093	\N	МФУ Катюша M247 (МФУ, А4, лазер, ч/б, LAN, Wi-Fi)	1	19	5	\N	2023-01-17	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-18 10:23:37.024362+03	2026-05-28 14:35:23.32482+03	МФУ	\N	\N	\N	\N
74	МЦ.04-оргтехника-9	\N	Сканер Canon imageFORMULA DR-M260	1	19	5	\N	2024-06-04	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-18 10:28:52.623708+03	2026-05-28 14:35:23.32482+03	Сканер	\N	\N	\N	\N
76	МЦ.04.1-оргтехника-11	\N	Сканер Fujitsu fi-6130	1	19	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-18 10:28:52.623708+03	2026-05-28 14:35:23.32482+03	Сканер	\N	\N	\N	\N
59	НИИСУ	\N	Сканер Fujitsu fi-7160	1	19	5	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-18 10:23:37.024362+03	2026-05-28 14:35:23.32482+03	Сканер	\N	\N	\N	\N
134	М.Ц	\N	MSI 27P	1	\N	12	Море-Море231	2026-07-10	\N	2028-07-10	\N	\N	\N	f	f	\N	\N	2026-07-10 10:44:55.30153+03	2026-07-10 10:44:55.30153+03	Монитор	\N	\N	11	72
85	МЦ.04	\N	DELL E2441	1	19	9		\N	\N	\N		\N	\N	f	f	\N	\N	2026-05-30 11:14:54.028056+03	2026-05-30 11:14:54.028056+03	Монитор	\N	\N	\N	\N
86	МЦ.04	\N	DELL E2441	1	19	9		\N	\N	\N		\N	\N	f	f	\N	\N	2026-05-30 11:14:54.318117+03	2026-05-30 11:14:54.318117+03	Монитор	\N	\N	\N	\N
135	М.Ц	\N	MSI 27P	1	\N	12	Море-Море231	2026-07-10	\N	2028-07-10	\N	\N	\N	f	f	\N	\N	2026-07-10 10:44:55.30153+03	2026-07-10 10:44:55.30153+03	Монитор	\N	\N	11	73
137	М.Ц	\N	MSI 27P	1	\N	12	Море-Море231	2026-07-10	\N	2028-07-10	\N	\N	\N	f	f	\N	\N	2026-07-10 10:44:55.30153+03	2026-07-10 10:44:55.30153+03	Монитор	\N	\N	11	75
138	М.Ц	\N	MSI 27P	1	\N	12	Море-Море231	2026-07-10	\N	2028-07-10	\N	\N	\N	f	f	\N	\N	2026-07-10 10:44:55.30153+03	2026-07-10 10:44:55.30153+03	Монитор	\N	\N	11	76
139	М.Ц	\N	MSI 27P	1	\N	12	Море-Море231	2026-07-10	\N	2028-07-10	\N	\N	\N	f	f	\N	\N	2026-07-10 10:44:55.30153+03	2026-07-10 10:44:55.30153+03	Монитор	\N	\N	11	77
140	М.Ц	\N	MSI 27P	1	\N	12	Море-Море231	2026-07-10	\N	2028-07-10	\N	\N	\N	f	f	\N	\N	2026-07-10 10:44:55.30153+03	2026-07-10 10:44:55.30153+03	Монитор	\N	\N	11	78
141	М.Ц	\N	MSI 27P	1	\N	12	Море-Море231	2026-07-10	\N	2028-07-10	\N	\N	\N	f	f	\N	\N	2026-07-10 10:44:55.30153+03	2026-07-10 10:44:55.30153+03	Монитор	\N	\N	11	79
142	М.Ц	\N	MSI 27P	1	\N	12	Море-Море231	2026-07-10	\N	2028-07-10	\N	\N	\N	f	f	\N	\N	2026-07-10 10:44:55.30153+03	2026-07-10 10:44:55.30153+03	Монитор	\N	\N	11	80
123		R23133	RDW 2100	1	25	9	Море-Море231	2026-07-10	\N	2029-07-10	\N	\N	\N	f	f	\N	\N	2026-07-10 10:44:55.30153+03	2026-07-10 10:53:19.310293+03	Системный блок	\N	\N	11	61
27	МЦ.04-ups-7	\N	APC Back-UPS 650 ВА (BX650CI-RS)	1	25	9	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-07-10 10:53:48.987658+03	ИБП	\N	\N	\N	\N
82	МЦ.04	\N	Canon i-Sensys MF744cdw	1	25	9		2021-03-02	\N	\N	Учтен	\N	\N	f	f	\N	\N	2026-05-18 10:28:52.623708+03	2026-07-10 11:23:08.989327+03	МФУ	\N	\N	\N	\N
121	МЦ.04	\N	Коммутатор HPE 1920S-48G-4SFP	1	19	13		\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-07-10 09:46:49.123577+03	2026-07-10 11:25:46.491011+03	Прочее	\N	\N	\N	\N
65	(списанная МЦ)	\N	Canon i-Sensys MF4690PL	4	3	4	Рога и копыта	2008-01-01	\N	2012-01-01	=====	\N	\N	f	f	\N	\N	2026-05-18 10:23:37.024362+03	2026-07-10 11:52:00.116129+03	МФУ	\N	\N	\N	\N
30	МЦ.04-ups-8	\N	SVEN	1	7	4	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-07-10 12:15:59.036932+03	ИБП	\N	\N	\N	\N
35	МЦ.04	\N	Nec MultiSync E222W	1	9	4		\N	\N	\N	Исходный учётный номер: МЦ.04.1	\N	\N	f	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-07-10 12:15:59.036932+03	Монитор	\N	\N	\N	\N
87	МЦ.04	\N	MSI 3201	1	9	4		\N	\N	\N		\N	\N	f	f	\N	\N	2026-05-30 11:21:35.171481+03	2026-07-10 12:15:59.036932+03	Монитор	\N	\N	\N	\N
\.


--
-- Data for Name: equipment_attachments; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.equipment_attachments (id, equipment_id, attachment_id, linked_by, linked_at) FROM stdin;
1	33	6	1	2026-07-07 14:34:25
\.


--
-- Data for Name: equipment_deliveries; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.equipment_deliveries (id, name, supplier, delivery_date, warehouse_location_id, status, notes, created_by, created_at, updated_at) FROM stdin;
4	Новая поставка	Рога и копыта	2026-06-03	11	posted		1	2026-06-03 10:48:13	2026-06-03 10:15:41
8	Мониторы и компы	Мистер Слойкин	2026-07-07	\N	posted		1	2026-07-07 14:52:12	2026-07-07 13:54:49
10	Новая поставка	\N	2026-07-10	\N	draft	\N	1	2026-07-10 09:39:19	2026-07-10 08:39:18
11	Море-Море	Море-Море231	2026-07-10	\N	posted		24	2026-07-10 10:39:33	2026-07-10 09:44:55
\.


--
-- Data for Name: equipment_delivery_attachments; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.equipment_delivery_attachments (id, delivery_id, attachment_id, linked_by, linked_at) FROM stdin;
\.


--
-- Data for Name: equipment_delivery_lines; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.equipment_delivery_lines (id, delivery_id, equipment_type, equipment_type_id, name, quantity, description, sort_order, created_at, updated_at, warehouse_location_id, char_template, warranty_years) FROM stdin;
2	4	Системный блок	\N	МИР 10	10	\N	1	2026-06-03 11:13:22	2026-06-03 10:13:21	11	{"PartChar":{"cpu":"Core i5-7400 3,0 ГГц","ram":"16 ГБ","os":"Win11H(x64)"},"PartCharDisks":["SSD 240 ГБ"],"PartCharDisksSubmitted":"1"}	\N
5	8	Системный блок	\N	Inwin Pro	10	\N	1	2026-07-07 14:52:49	2026-07-07 13:52:48	12	{"PartChar":{"cpu":"Core i3-3220 3,3 ГГц","ram":"16 ГБ","os":"Win10pro (x64)"},"PartCharDisks":["SSD 240 ГБ"],"PartCharDisksSubmitted":"1"}	3.0
6	8	Монитор	\N	Lenovo G30	10	\N	2	2026-07-07 14:53:21	2026-07-07 13:53:20	12	{"PartChar":{"screen_diagonal":"30"}}	5.0
7	11	Системный блок	\N	RDW 2100	10	\N	1	2026-07-10 10:40:55	2026-07-10 09:40:55	12	{"PartChar":{"cpu":"Core i5-12500 3,00 ГГц","ram":"64 ГБ","os":"Astra Linux Special Edition 1.8"},"PartCharDisks":["SSD 512 ГБ"],"PartCharDisksSubmitted":"1"}	3.0
8	11	Монитор	\N	MSI 27P	10	\N	2	2026-07-10 10:41:38	2026-07-10 09:41:37	12	{"PartChar":{"screen_diagonal":"24"}}	2.0
\.


--
-- Data for Name: equipment_delivery_units; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.equipment_delivery_units (id, line_id, seq_no, serial_number, inventory_number, number_status, equipment_id, created_at, updated_at) FROM stdin;
11	2	1	\N	\N	empty	91	2026-06-03 11:13:22	2026-06-03 10:13:43
12	2	2	\N	\N	empty	92	2026-06-03 11:13:22	2026-06-03 10:13:43
13	2	3	\N	\N	empty	93	2026-06-03 11:13:22	2026-06-03 10:13:43
14	2	4	\N	\N	empty	94	2026-06-03 11:13:22	2026-06-03 10:13:43
15	2	5	\N	\N	empty	95	2026-06-03 11:13:22	2026-06-03 10:13:43
16	2	6	\N	\N	empty	96	2026-06-03 11:13:22	2026-06-03 10:13:43
17	2	7	\N	\N	empty	97	2026-06-03 11:13:22	2026-06-03 10:13:43
18	2	8	\N	\N	empty	98	2026-06-03 11:13:22	2026-06-03 10:13:43
19	2	9	\N	\N	empty	99	2026-06-03 11:13:22	2026-06-03 10:13:43
20	2	10	\N	\N	empty	100	2026-06-03 11:13:22	2026-06-03 10:13:43
61	7	1	R23133	\N	serial_only	123	2026-07-10 10:40:55	2026-07-10 09:44:55
62	7	2	\N	\N	empty	124	2026-07-10 10:40:55	2026-07-10 09:44:55
63	7	3	R54534	\N	serial_only	125	2026-07-10 10:40:55	2026-07-10 09:44:55
64	7	4	R54335	\N	serial_only	126	2026-07-10 10:40:55	2026-07-10 09:44:55
65	7	5	R54535	\N	serial_only	127	2026-07-10 10:40:55	2026-07-10 09:44:55
66	7	6	R23134	\N	serial_only	128	2026-07-10 10:40:55	2026-07-10 09:44:55
67	7	7	R23138	\N	serial_only	129	2026-07-10 10:40:55	2026-07-10 09:44:55
68	7	8	R54537	\N	serial_only	130	2026-07-10 10:40:55	2026-07-10 09:44:55
69	7	9	R54333	\N	serial_only	131	2026-07-10 10:40:55	2026-07-10 09:44:55
70	7	10	\N	\N	empty	132	2026-07-10 10:40:55	2026-07-10 09:44:55
71	8	1	\N	М.Ц	empty	133	2026-07-10 10:41:38	2026-07-10 09:44:55
72	8	2	\N	М.Ц	empty	134	2026-07-10 10:41:38	2026-07-10 09:44:55
45	5	5	\N	\N	empty	105	2026-07-07 14:52:49	2026-07-07 13:54:49
46	5	6	\N	\N	empty	106	2026-07-07 14:52:49	2026-07-07 13:54:49
47	5	7	\N	\N	empty	107	2026-07-07 14:52:49	2026-07-07 13:54:49
48	5	8	\N	\N	empty	108	2026-07-07 14:52:49	2026-07-07 13:54:49
49	5	9	\N	\N	empty	109	2026-07-07 14:52:49	2026-07-07 13:54:49
50	5	10	\N	\N	empty	110	2026-07-07 14:52:49	2026-07-07 13:54:49
51	6	1	\N	\N	empty	111	2026-07-07 14:53:21	2026-07-07 13:54:49
73	8	3	\N	М.Ц	empty	135	2026-07-10 10:41:38	2026-07-10 09:44:55
74	8	4	\N	М.Ц	empty	136	2026-07-10 10:41:38	2026-07-10 09:44:55
75	8	5	\N	М.Ц	empty	137	2026-07-10 10:41:38	2026-07-10 09:44:55
76	8	6	\N	М.Ц	empty	138	2026-07-10 10:41:38	2026-07-10 09:44:55
77	8	7	\N	М.Ц	empty	139	2026-07-10 10:41:38	2026-07-10 09:44:55
78	8	8	\N	М.Ц	empty	140	2026-07-10 10:41:38	2026-07-10 09:44:55
79	8	9	\N	М.Ц	empty	141	2026-07-10 10:41:38	2026-07-10 09:44:55
80	8	10	\N	М.Ц	empty	142	2026-07-10 10:41:38	2026-07-10 09:44:55
41	5	1	\N	\N	empty	101	2026-07-07 14:52:49	2026-07-07 13:54:48
42	5	2	\N	\N	empty	102	2026-07-07 14:52:49	2026-07-07 13:54:48
43	5	3	\N	\N	empty	103	2026-07-07 14:52:49	2026-07-07 13:54:48
44	5	4	\N	\N	empty	104	2026-07-07 14:52:49	2026-07-07 13:54:49
52	6	2	\N	\N	empty	112	2026-07-07 14:53:21	2026-07-07 13:54:49
53	6	3	\N	\N	empty	113	2026-07-07 14:53:21	2026-07-07 13:54:49
54	6	4	\N	\N	empty	114	2026-07-07 14:53:21	2026-07-07 13:54:49
55	6	5	\N	\N	empty	115	2026-07-07 14:53:21	2026-07-07 13:54:49
56	6	6	\N	\N	empty	116	2026-07-07 14:53:21	2026-07-07 13:54:49
57	6	7	\N	\N	empty	117	2026-07-07 14:53:21	2026-07-07 13:54:49
58	6	8	\N	\N	empty	118	2026-07-07 14:53:21	2026-07-07 13:54:49
59	6	9	\N	\N	empty	119	2026-07-07 14:53:21	2026-07-07 13:54:49
60	6	10	\N	\N	empty	120	2026-07-07 14:53:21	2026-07-07 13:54:49
\.


--
-- Data for Name: equipment_import_logs; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.equipment_import_logs (id, uploaded_by, file_name, total_rows, valid_rows, error_rows, status, payload_json, created_at) FROM stdin;
\.


--
-- Data for Name: equipment_links; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.equipment_links (id, parent_equipment_id, child_equipment_id, link_type, created_by, created_at, updated_at) FROM stdin;
1	1	2	monitor	\N	2026-05-16 14:24:44	\N
2	1	3	ups	\N	2026-05-16 14:24:44	\N
3	4	5	monitor	\N	2026-05-16 14:24:44	\N
4	4	6	ups	\N	2026-05-16 14:24:44	\N
6	9	10	monitor	\N	2026-05-16 14:24:44	\N
7	11	12	monitor	\N	2026-05-16 14:24:44	\N
8	11	13	ups	\N	2026-05-16 14:24:44	\N
9	14	15	monitor	\N	2026-05-16 14:24:44	\N
10	14	16	ups	\N	2026-05-16 14:24:44	\N
11	17	18	monitor	\N	2026-05-16 14:24:44	\N
12	17	19	ups	\N	2026-05-16 14:24:44	\N
15	23	24	monitor	\N	2026-05-16 14:24:44	\N
18	28	29	monitor	\N	2026-05-16 14:24:44	\N
19	28	30	ups	\N	2026-05-16 14:24:44	\N
22	34	35	monitor	\N	2026-05-16 14:24:44	\N
25	39	40	monitor	\N	2026-05-16 14:24:44	\N
26	41	42	monitor	\N	2026-05-16 14:24:44	\N
28	45	46	monitor	\N	2026-05-16 14:24:44	\N
63	34	87	monitor	1	2026-05-30 11:29:24	\N
64	9	88	ups	1	2026-06-01 08:29:18	\N
65	93	111	monitor	1	2026-07-07 14:55:38	\N
66	101	116	monitor	24	2026-07-10 10:37:26	\N
67	123	136	monitor	24	2026-07-10 10:53:36	\N
68	123	27	ups	24	2026-07-10 10:53:49	\N
70	20	22	ups	24	2026-07-10 15:53:58	\N
74	31	33	ups	1	2026-07-10 16:04:44	\N
75	31	26	monitor	24	2026-07-14 14:07:58	\N
76	20	21	monitor	24	2026-07-14 14:15:45	\N
78	91	48	monitor	24	2026-07-14 14:27:09	\N
79	91	49	monitor	24	2026-07-14 14:27:09	\N
80	91	50	ups	24	2026-07-14 14:27:09	\N
81	20	133	monitor	1	2026-07-15 11:37:21	\N
82	36	143	ups	1	2026-07-15 11:49:25	\N
83	36	37	monitor	24	2026-07-15 11:59:06	\N
84	28	118	monitor	24	2026-07-15 11:59:31	\N
\.


--
-- Data for Name: equipment_software; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.equipment_software (id, equipment_id, software_id, installed_at, created_at, license_id) FROM stdin;
\.


--
-- Data for Name: equipment_types; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.equipment_types (id, name) FROM stdin;
1	Принтер
2	МФУ
3	Ноутбук
4	ИБП
5	Монитор
6	Моноблок
7	Системный блок
8	Сканер
9	Сервер
10	Прочее
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
-- Data for Name: license_attachments; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.license_attachments (id, license_id, attachment_id, linked_by, linked_at) FROM stdin;
\.


--
-- Data for Name: licenses; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.licenses (id, software_id, valid_until, notes, created_at, supplier, purchase_date, valid_from, seats, validity_years, is_perpetual) FROM stdin;
1	1	2030-05-06		2026-07-09 13:02:16	Мистер Слойкин	2026-05-06	2026-05-06	1	4.0	f
\.


--
-- Data for Name: locations; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.locations (id, location_code, name, location_type, floor, description, is_archived, created_by_id, updated_by_id, created_at, updated_at) FROM stdin;
1	\N	103	кабинет	\N	\N	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-16 14:24:43.656427+03
2	\N	105	кабинет	\N	\N	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-16 14:24:43.656427+03
3	\N	Пост охраны	кабинет	\N	\N	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-16 14:24:43.656427+03
4	\N	106	кабинет	\N	\N	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-16 14:24:43.656427+03
5	\N	303	кабинет	\N	\N	f	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-16 14:24:43.656427+03
6	\N	подвал	кабинет	\N	\N	f	\N	\N	2026-05-18 10:23:37.024362+03	2026-05-18 10:23:37.024362+03
7	\N	118	кабинет	\N	\N	f	\N	\N	2026-05-18 10:23:37.024362+03	2026-05-18 10:23:37.024362+03
8	\N	104	кабинет	\N	\N	f	\N	\N	2026-05-18 10:23:37.024362+03	2026-05-18 10:23:37.024362+03
9	\N	306	кабинет	\N	\N	f	\N	\N	2026-05-30 11:05:42.599809+03	2026-05-30 11:05:42.599809+03
11		306 склад	склад	\N		f	\N	\N	2026-06-01 17:16:13.712228+03	2026-06-01 17:16:13.712228+03
12		116 склад	склад	\N		f	\N	\N	2026-06-03 11:31:42.275024+03	2026-06-03 11:31:42.275024+03
13	\N	303 с	кабинет	\N	\N	f	\N	\N	2026-07-10 09:46:49.110427+03	2026-07-10 09:46:49.110427+03
14	\N	534	кабинет	\N	\N	f	\N	\N	2026-07-10 11:57:54.363082+03	2026-07-10 11:57:54.363082+03
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
m260318_100000_add_parent_equipment_id	1773142303
m260318_100001_link_monitors_to_system_blocks	1773142452
m260505_090000_add_performance_indexes_for_tasks_grid	1778070131
m260506_100000_add_performance_indexes_for_arm_equipment_grid	1778070131
m260506_123000_add_equipment_links_user_cards_and_import_logs	1778070131
m260506_130000_ensure_user_equipment_cards_table	1778070131
m260518_100000_normalize_equipment_serial_number_null	1779093601
m260526_120000_add_screen_diagonal_char	1779794986
m260526_140000_work_tasks_module	1779795859
m260526_160000_rename_pending_review_status_label	1779797364
m260526_170000_rename_done_status_label	1779798744
m260526_180000_clear_stale_work_task_completion_dates	1779798745
m260526_190000_work_task_comments	1779798745
m260526_200000_add_work_tasks_status_changed_at	1779799461
m260526_210000_task_statuses_for_work_task_sync	1779803530
m260527_100000_tasks_contact_phone	1779803530
m260527_120000_work_task_attachments	1779881104
m260530_100000_normalize_arm_equipment_type	1780128849
m260530_120000_printer_mfu_characteristics	1780128849
m260530_130000_ups_battery_characteristic	1780128849
m260530_140000_drop_equipment_inventory_number_unique	1780128849
m260530_160000_tasks_room_number	1780299810
m260531_100000_work_task_executors	1780299810
m260601_100000_remove_in_stock_equipment_status	1780379345
m260603_100000_equipment_deliveries	1780469942
m260604_100000_drop_delivery_unit_internal_label	1780471633
m260605_100000_delivery_line_warehouse_chars	1780473399
m260606_100000_delivery_warranty_and_attachments	1780474840
m260607_140000_equipment_attachments	1783420275
m260607_150000_ups_battery_service_characteristics	1783426980
m260709_100000_license_fields_and_attachments	1783586697
m260709_120000_license_seats	1783587279
m260709_130000_license_validity_years	1783587815
m260710_100000_scanner_characteristics	1783664948
m260710_110000_server_cpu_count_characteristic	1783665146
m260710_120000_misc_equipment_type	1783665362
m260710_130000_printer_mfu_login_password	1783671005
m260710_140000_remove_archived_equipment_status	1783685041
m260710_150000_remove_equipment_archiving	1783685220
m260714_120000_add_faulty_equipment_status	1784027661
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
1	1	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-05-16 14:24:43.656427+03
2	1	7	9	8 ГБ	\N	manual	\N	2026-05-16 14:24:43.656427+03
4	1	9	8	BENQ BL2201M	\N	manual	\N	2026-05-16 14:24:43.656427+03
5	1	9	10	НИИСУ	\N	manual	\N	2026-05-16 14:24:43.656427+03
6	1	10	11	105-w7u32-12	\N	manual	\N	2026-05-16 14:24:43.656427+03
8	1	10	13	Win10Pro (x64)	\N	manual	\N	2026-05-16 14:24:43.656427+03
9	1	10	14	KES11	\N	manual	\N	2026-05-16 14:24:43.656427+03
13	4	9	8	Nec MultiSync E222W	\N	manual	\N	2026-05-16 14:24:43.656427+03
14	4	9	10	НИИСУ	\N	manual	\N	2026-05-16 14:24:43.656427+03
15	4	10	11	105-w7p64-10	\N	manual	\N	2026-05-16 14:24:43.656427+03
17	4	10	13	Win7 Pro (x64)	\N	manual	\N	2026-05-16 14:24:43.656427+03
18	4	10	14	KES11	\N	manual	\N	2026-05-16 14:24:43.656427+03
19	7	6	8	Core i5-6500 3,2 ГГц	\N	manual	\N	2026-05-16 14:24:43.656427+03
20	7	7	9	4 ГБ	\N	manual	\N	2026-05-16 14:24:43.656427+03
22	7	9	8	Samsung SyncMaster SA200	\N	manual	\N	2026-05-16 14:24:43.656427+03
23	7	9	10	МЦ.04.2	\N	manual	\N	2026-05-16 14:24:43.656427+03
24	7	10	11	105-w10p64-143	\N	manual	\N	2026-05-16 14:24:43.656427+03
25	7	10	12	192.168.20.16	\N	manual	\N	2026-05-16 14:24:43.656427+03
26	7	10	13	Win10Pro (x64)	\N	manual	\N	2026-05-16 14:24:43.656427+03
27	7	10	14	KES10	\N	manual	\N	2026-05-16 14:24:43.656427+03
28	9	6	8	Core i5 2500 3,3 ГГц	\N	manual	\N	2026-05-16 14:24:43.656427+03
29	9	7	9	8 ГБ	\N	manual	\N	2026-05-16 14:24:43.656427+03
30	9	8	8	1 ТБ	\N	manual	\N	2026-05-16 14:24:43.656427+03
31	9	9	8	Nec MultiSync E224wi	\N	manual	\N	2026-05-16 14:24:43.656427+03
32	9	9	10	НИИСУ	\N	manual	\N	2026-05-16 14:24:43.656427+03
33	9	10	11	105-W10P64-243	\N	manual	\N	2026-05-16 14:24:43.656427+03
34	9	10	12	10.1.4.243	\N	manual	\N	2026-05-16 14:24:43.656427+03
35	9	10	13	Win10pro (x64)	\N	manual	\N	2026-05-16 14:24:43.656427+03
36	9	10	14	KES11	\N	manual	\N	2026-05-16 14:24:43.656427+03
37	11	6	8	Core i5-10500 3,1 ГГц	\N	manual	\N	2026-05-16 14:24:43.656427+03
38	11	7	9	16 ГБ	\N	manual	\N	2026-05-16 14:24:43.656427+03
39	11	8	8	SSD 250 ГБ; HDD 1ТБ	\N	manual	\N	2026-05-16 14:24:43.656427+03
40	11	9	8	DELL E2313Hf	\N	manual	\N	2026-05-16 14:24:43.656427+03
41	11	9	10	НИИСУ	\N	manual	\N	2026-05-16 14:24:43.656427+03
42	11	10	11	103-w10p64-95	\N	manual	\N	2026-05-16 14:24:43.656427+03
43	11	10	12	10.1.4.95	\N	manual	\N	2026-05-16 14:24:43.656427+03
44	11	10	13	Win10 Pro (x64)	\N	manual	\N	2026-05-16 14:24:43.656427+03
45	11	10	14	KES12	\N	manual	\N	2026-05-16 14:24:43.656427+03
46	14	6	8	Core i5-2300 2,8 ГГц	\N	manual	\N	2026-05-16 14:24:43.656427+03
47	14	7	9	4 ГБ	\N	manual	\N	2026-05-16 14:24:43.656427+03
49	14	9	8	LG 22m35	\N	manual	\N	2026-05-16 14:24:43.656427+03
50	14	9	10	МЦ.04	\N	manual	\N	2026-05-16 14:24:43.656427+03
51	14	10	11	103-w10p64-17	\N	manual	\N	2026-05-16 14:24:43.656427+03
52	14	10	12	192.168.20.17	\N	manual	\N	2026-05-16 14:24:43.656427+03
53	14	10	13	Win10 Pro (x64)	\N	manual	\N	2026-05-16 14:24:43.656427+03
54	14	10	14	KES11	\N	manual	\N	2026-05-16 14:24:43.656427+03
55	17	6	8	Core i3-4160 3,6 ГГц	\N	manual	\N	2026-05-16 14:24:43.656427+03
56	17	7	9	8 ГБ	\N	manual	\N	2026-05-16 14:24:43.656427+03
57	17	8	8	SSD 500 ГБ	\N	manual	\N	2026-05-16 14:24:43.656427+03
58	17	9	8	Iiyama ProLite E2483HS	\N	manual	\N	2026-05-16 14:24:43.656427+03
59	17	10	11	103-w10p64	\N	manual	\N	2026-05-16 14:24:43.656427+03
60	17	10	12	не в сети	\N	manual	\N	2026-05-16 14:24:43.656427+03
61	17	10	13	Win10 Pro (x64)	\N	manual	\N	2026-05-16 14:24:43.656427+03
62	17	10	14	KES12	\N	manual	\N	2026-05-16 14:24:43.656427+03
63	20	6	8	Core i5-12500 3,0 ГГц	\N	manual	\N	2026-05-16 14:24:43.656427+03
64	20	7	9	16 ГБ	\N	manual	\N	2026-05-16 14:24:43.656427+03
65	20	8	8	SSD 512 ГБ; HDD 1 ТБ	\N	manual	\N	2026-05-16 14:24:43.656427+03
68	20	10	11	511-astra	\N	manual	\N	2026-05-16 14:24:43.656427+03
69	20	10	12	10.1.4.82	\N	manual	\N	2026-05-16 14:24:43.656427+03
70	20	10	13	Astra Linux Special Edition 1.8	\N	manual	\N	2026-05-16 14:24:43.656427+03
71	20	10	14	KES12	\N	manual	\N	2026-05-16 14:24:43.656427+03
72	23	6	8	AMD Athlon 3150U 2.40 ГГц	\N	manual	\N	2026-05-16 14:24:43.656427+03
73	23	7	9	4 ГБ	\N	manual	\N	2026-05-16 14:24:43.656427+03
75	23	9	8	15,6"	\N	manual	\N	2026-05-16 14:24:43.656427+03
76	23	10	11	LAPTOP-VU5M0UKQ	\N	manual	\N	2026-05-16 14:24:43.656427+03
77	23	10	12	не в сети	\N	manual	\N	2026-05-16 14:24:43.656427+03
78	23	10	13	Win11H(x64)	\N	manual	\N	2026-05-16 14:24:43.656427+03
79	23	10	14	KES12	\N	manual	\N	2026-05-16 14:24:43.656427+03
80	25	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-05-16 14:24:43.656427+03
81	25	7	9	16 ГБ	\N	manual	\N	2026-05-16 14:24:43.656427+03
82	25	8	8	1 Тб	\N	manual	\N	2026-05-16 14:24:43.656427+03
7	1	10	12	10.1.4.244	\N	manual	\N	2026-05-16 14:24:43.656427+03
16	4	10	12	192.168.20.11	\N	manual	\N	2026-05-16 14:24:43.656427+03
10	4	6	8	Core i3-2100 3,1 ГГц	\N	manual	\N	2026-05-16 14:24:43.656427+03
11	4	7	9	128 ГБ	\N	manual	\N	2026-05-16 14:24:43.656427+03
85	25	10	11	105-w10p64-46	\N	manual	\N	2026-05-16 14:24:43.656427+03
86	25	10	12	10.1.4.46	\N	manual	\N	2026-05-16 14:24:43.656427+03
87	25	10	13	Win10 Pro (x64)	\N	manual	\N	2026-05-16 14:24:43.656427+03
88	25	10	14	KES11	\N	manual	\N	2026-05-16 14:24:43.656427+03
89	28	6	8	Pentium Dual-Core E5700  3,25 ГГц	\N	manual	\N	2026-05-16 14:24:43.656427+03
90	28	7	9	4 ГБ	\N	manual	\N	2026-05-16 14:24:43.656427+03
92	28	9	8	Samsung SyncMaster 226cw	\N	manual	\N	2026-05-16 14:24:43.656427+03
93	28	9	10	МЦ.04.2	\N	manual	\N	2026-05-16 14:24:43.656427+03
94	28	10	11	105-w7p32-10	\N	manual	\N	2026-05-16 14:24:43.656427+03
95	28	10	12	10.10.10.10	\N	manual	\N	2026-05-16 14:24:43.656427+03
96	28	10	13	Win 7 pro (x32)	\N	manual	\N	2026-05-16 14:24:43.656427+03
97	28	10	14	KES11	\N	manual	\N	2026-05-16 14:24:43.656427+03
98	31	6	8	Core i5-9600K 3,7 ГГц	\N	manual	\N	2026-05-16 14:24:43.656427+03
99	31	7	9	16 ГБ	\N	manual	\N	2026-05-16 14:24:43.656427+03
100	31	8	8	1 Тб	\N	manual	\N	2026-05-16 14:24:43.656427+03
105	31	10	13	Win10 Pro (x64)	\N	manual	\N	2026-05-16 14:24:43.656427+03
106	31	10	14	KES11	\N	manual	\N	2026-05-16 14:24:43.656427+03
107	34	6	8	Core i3-540 3,07 ГГц	\N	manual	\N	2026-05-16 14:24:43.656427+03
110	34	9	8	Nec MultiSync E222W	\N	manual	\N	2026-05-16 14:24:43.656427+03
111	34	9	10	МЦ.04.1	\N	manual	\N	2026-05-16 14:24:43.656427+03
112	34	10	11	105-w10p64-31	\N	manual	\N	2026-05-16 14:24:43.656427+03
113	34	10	12	10.1.4.229	\N	manual	\N	2026-05-16 14:24:43.656427+03
114	34	10	13	Win10 Pro (x64)	\N	manual	\N	2026-05-16 14:24:43.656427+03
115	34	10	14	KES12	\N	manual	\N	2026-05-16 14:24:43.656427+03
116	36	6	8	Core i5-12500 3,00 ГГц	\N	manual	\N	2026-05-16 14:24:43.656427+03
121	36	10	11	105-AndrosovaNV	\N	manual	\N	2026-05-16 14:24:43.656427+03
122	36	10	12	10.1.4.30	\N	manual	\N	2026-05-16 14:24:43.656427+03
123	36	10	13	Astra Linux Special Edition 1.8	\N	manual	\N	2026-05-16 14:24:43.656427+03
124	36	10	14	KES12	\N	manual	\N	2026-05-16 14:24:43.656427+03
125	39	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-05-16 14:24:43.656427+03
126	39	7	9	8 ГБ	\N	manual	\N	2026-05-16 14:24:43.656427+03
127	39	8	8	1 ТБ	\N	manual	\N	2026-05-16 14:24:43.656427+03
128	39	9	8	Samsung S22C200	\N	manual	\N	2026-05-16 14:24:43.656427+03
129	39	9	10	МЦ.04.2	\N	manual	\N	2026-05-16 14:24:43.656427+03
130	39	10	11	ohr-W10Px64-1	\N	manual	\N	2026-05-16 14:24:43.656427+03
131	39	10	12	не в сети	\N	manual	\N	2026-05-16 14:24:43.656427+03
132	39	10	13	Win10 Pro (x64)	\N	manual	\N	2026-05-16 14:24:43.656427+03
133	41	6	8	AMD Athlon 64X2Dual Core 2,90 ГГц	\N	manual	\N	2026-05-16 14:24:43.656427+03
134	41	7	9	2 ГБ	\N	manual	\N	2026-05-16 14:24:43.656427+03
136	41	9	8	Samsung 24"S24D300H	\N	manual	\N	2026-05-16 14:24:43.656427+03
137	41	9	10	МЦ.04	\N	manual	\N	2026-05-16 14:24:43.656427+03
138	41	10	11	501d-W7Ux32-2	\N	manual	\N	2026-05-16 14:24:43.656427+03
139	41	10	12	192.168.0.2	\N	manual	\N	2026-05-16 14:24:43.656427+03
140	41	10	13	Win7 Ultimate (x32)	\N	manual	\N	2026-05-16 14:24:43.656427+03
141	41	10	14	KES10	\N	manual	\N	2026-05-16 14:24:43.656427+03
142	43	6	8	Core i3-2100 3,1 ГГц	\N	manual	\N	2026-05-16 14:24:43.656427+03
143	43	7	9	8 ГБ	\N	manual	\N	2026-05-16 14:24:43.656427+03
144	43	8	8	500 ГБ	\N	manual	\N	2026-05-16 14:24:43.656427+03
147	43	10	11	106-W7P32-223	\N	manual	\N	2026-05-16 14:24:43.656427+03
148	43	10	12	10.2.2.223	\N	manual	\N	2026-05-16 14:24:43.656427+03
149	43	10	13	Win10Pro (x64)	\N	manual	\N	2026-05-16 14:24:43.656427+03
150	43	10	14	KES12	\N	manual	\N	2026-05-16 14:24:43.656427+03
151	45	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-05-16 14:24:43.656427+03
152	45	7	9	8 ГБ	\N	manual	\N	2026-05-16 14:24:43.656427+03
154	45	9	8	Lenovo L27e-30 27"	\N	manual	\N	2026-05-16 14:24:43.656427+03
155	45	9	10	МЦ.04	\N	manual	\N	2026-05-16 14:24:43.656427+03
156	45	10	11	106-w10p64-240	\N	manual	\N	2026-05-16 14:24:43.656427+03
157	45	10	12	10.2.2.240	\N	manual	\N	2026-05-16 14:24:43.656427+03
158	45	10	13	Win10Pro (x64)	\N	manual	\N	2026-05-16 14:24:43.656427+03
159	45	10	14	KES11	\N	manual	\N	2026-05-16 14:24:43.656427+03
160	47	6	8	Core i5-10500 3,10 ГГц	\N	manual	\N	2026-05-16 14:24:43.656427+03
161	47	7	9	16 ГБ	\N	manual	\N	2026-05-16 14:24:43.656427+03
162	47	8	8	SSD 240 ГБ; 1 ТБ	\N	manual	\N	2026-05-16 14:24:43.656427+03
163	47	9	8	Iiyama ProLite XB3270QS-B1; Samsung S22C200	\N	manual	\N	2026-05-16 14:24:43.656427+03
117	36	7	9	64 ГБ	\N	manual	\N	2026-05-16 14:24:43.656427+03
108	34	7	9	16 ГБ	\N	manual	\N	2026-05-16 14:24:43.656427+03
103	31	10	11	SosalPC	\N	manual	\N	2026-05-16 14:24:43.656427+03
104	31	10	12	VLAN GOVNA	\N	manual	\N	2026-05-16 14:24:43.656427+03
164	47	9	10	МЦ.04\nМЦ.04.2	\N	manual	\N	2026-05-16 14:24:43.656427+03
167	47	10	13	Win10 Pro (x64)	\N	manual	\N	2026-05-16 14:24:43.656427+03
168	47	10	14	KES12	\N	manual	\N	2026-05-16 14:24:43.656427+03
175	1	12	12	10.1.4.244	\N	manual	\N	2026-05-18 10:23:37.024362+03
178	51	12	12	USB	\N	manual	\N	2026-05-18 10:28:52.623708+03
179	54	12	12	192.168.0.9	\N	manual	\N	2026-05-18 10:28:52.623708+03
180	55	12	12	192.168.0.10	\N	manual	\N	2026-05-18 10:28:52.623708+03
181	56	12	12	192.168.20.5	\N	manual	\N	2026-05-18 10:28:52.623708+03
182	57	12	12	USB	\N	manual	\N	2026-05-18 10:28:52.623708+03
183	61	12	12	10.1.4.161	\N	manual	\N	2026-05-18 10:28:52.623708+03
184	80	12	12	10.1.4.244	\N	manual	\N	2026-05-18 10:28:52.623708+03
185	65	12	12	10.1.4.38	\N	manual	\N	2026-05-18 10:28:52.623708+03
191	7	8	8	500 ГБ; SSD 240 ГБ	\N	manual	\N	2026-05-18 11:48:44.979313+03
198	85	9	15	24	\N	manual	\N	2026-05-30 11:14:54.065722+03
199	86	9	15	24	\N	manual	\N	2026-05-30 11:14:54.33345+03
200	87	9	15	32	\N	manual	\N	2026-05-30 11:21:35.183804+03
201	82	12	16	A4	\N	manual	\N	2026-05-30 11:55:00.045473+03
202	82	12	17	Лазерный	\N	manual	\N	2026-05-30 11:55:00.049569+03
203	82	12	18	Цветной	\N	manual	\N	2026-05-30 11:55:00.053595+03
204	82	12	19	Сетевой	\N	manual	\N	2026-05-30 11:55:00.056875+03
206	66	12	16	A4	\N	manual	\N	2026-05-30 11:55:56.407017+03
207	66	12	17	Лазерный	\N	manual	\N	2026-05-30 11:55:56.411031+03
208	66	12	18	Цветной	\N	manual	\N	2026-05-30 11:55:56.414353+03
209	66	12	19	Сетевой	\N	manual	\N	2026-05-30 11:55:56.417078+03
212	4	8	8	500 ГБ	\N	manual	\N	2026-05-30 12:17:40.825829+03
214	23	9	15	15,6	\N	manual	\N	2026-05-30 13:00:12.069606+03
215	65	12	16	A4	\N	manual	\N	2026-05-30 13:13:09.468748+03
216	65	12	17	Лазерный	\N	manual	\N	2026-05-30 13:13:09.47255+03
217	65	12	18	Чёрно-белый	\N	manual	\N	2026-05-30 13:13:09.47552+03
218	65	12	19	Сетевой	\N	manual	\N	2026-05-30 13:13:09.479329+03
219	65	12	20	Нет	\N	manual	\N	2026-05-30 13:13:09.482469+03
221	89	8	8	SSD 240 ГБ	\N	manual	\N	2026-06-01 08:31:11.304487+03
222	89	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-06-01 08:31:11.311317+03
223	89	7	9	16 ГБ	\N	manual	\N	2026-06-01 08:31:11.314109+03
224	1	8	8	SSD 480 ГБ; HDD 500 ГБ	\N	manual	\N	2026-06-01 16:33:42.689414+03
225	14	8	8	500 ГБ	\N	manual	\N	2026-06-01 16:34:13.94083+03
227	91	8	8	SSD 240 ГБ	\N	manual	\N	2026-06-03 11:13:42.936732+03
228	91	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-06-03 11:13:42.936732+03
229	91	7	9	16 ГБ	\N	manual	\N	2026-06-03 11:13:42.936732+03
230	91	10	13	Win11H(x64)	\N	manual	\N	2026-06-03 11:13:42.936732+03
231	92	8	8	SSD 240 ГБ	\N	manual	\N	2026-06-03 11:13:42.936732+03
232	92	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-06-03 11:13:42.936732+03
233	92	7	9	16 ГБ	\N	manual	\N	2026-06-03 11:13:42.936732+03
234	92	10	13	Win11H(x64)	\N	manual	\N	2026-06-03 11:13:42.936732+03
235	93	8	8	SSD 240 ГБ	\N	manual	\N	2026-06-03 11:13:42.936732+03
236	93	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-06-03 11:13:42.936732+03
237	93	7	9	16 ГБ	\N	manual	\N	2026-06-03 11:13:42.936732+03
238	93	10	13	Win11H(x64)	\N	manual	\N	2026-06-03 11:13:42.936732+03
239	94	8	8	SSD 240 ГБ	\N	manual	\N	2026-06-03 11:13:42.936732+03
240	94	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-06-03 11:13:42.936732+03
241	94	7	9	16 ГБ	\N	manual	\N	2026-06-03 11:13:42.936732+03
242	94	10	13	Win11H(x64)	\N	manual	\N	2026-06-03 11:13:42.936732+03
243	95	8	8	SSD 240 ГБ	\N	manual	\N	2026-06-03 11:13:42.936732+03
244	95	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-06-03 11:13:42.936732+03
245	95	7	9	16 ГБ	\N	manual	\N	2026-06-03 11:13:42.936732+03
246	95	10	13	Win11H(x64)	\N	manual	\N	2026-06-03 11:13:42.936732+03
247	96	8	8	SSD 240 ГБ	\N	manual	\N	2026-06-03 11:13:42.936732+03
248	96	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-06-03 11:13:42.936732+03
249	96	7	9	16 ГБ	\N	manual	\N	2026-06-03 11:13:42.936732+03
250	96	10	13	Win11H(x64)	\N	manual	\N	2026-06-03 11:13:42.936732+03
251	97	8	8	SSD 240 ГБ	\N	manual	\N	2026-06-03 11:13:42.936732+03
252	97	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-06-03 11:13:42.936732+03
253	97	7	9	16 ГБ	\N	manual	\N	2026-06-03 11:13:42.936732+03
254	97	10	13	Win11H(x64)	\N	manual	\N	2026-06-03 11:13:42.936732+03
255	98	8	8	SSD 240 ГБ	\N	manual	\N	2026-06-03 11:13:42.936732+03
256	98	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-06-03 11:13:42.936732+03
257	98	7	9	16 ГБ	\N	manual	\N	2026-06-03 11:13:42.936732+03
258	98	10	13	Win11H(x64)	\N	manual	\N	2026-06-03 11:13:42.936732+03
259	99	8	8	SSD 240 ГБ	\N	manual	\N	2026-06-03 11:13:42.936732+03
260	99	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-06-03 11:13:42.936732+03
261	99	7	9	16 ГБ	\N	manual	\N	2026-06-03 11:13:42.936732+03
262	99	10	13	Win11H(x64)	\N	manual	\N	2026-06-03 11:13:42.936732+03
263	100	8	8	SSD 240 ГБ	\N	manual	\N	2026-06-03 11:13:42.936732+03
264	100	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-06-03 11:13:42.936732+03
186	82	12	12	10.2.2.18	\N	manual	\N	2026-05-18 10:28:52.623708+03
205	82	12	20	Отключен	\N	manual	\N	2026-05-30 11:55:00.059903+03
210	66	12	20	Отключен	\N	manual	\N	2026-05-30 11:55:56.419691+03
265	100	7	9	16 ГБ	\N	manual	\N	2026-06-03 11:13:42.936732+03
266	100	10	13	Win11H(x64)	\N	manual	\N	2026-06-03 11:13:42.936732+03
268	41	8	8	250 ГБ	\N	manual	\N	2026-07-07 13:19:48.69453+03
272	23	8	8	SSD 240 ГБ	\N	manual	\N	2026-07-07 14:45:46.575469+03
273	101	8	8	SSD 240 ГБ	\N	manual	\N	2026-07-07 14:54:48.779875+03
274	101	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-07-07 14:54:48.779875+03
275	101	7	9	16 ГБ	\N	manual	\N	2026-07-07 14:54:48.779875+03
276	101	10	13	Win10pro (x64)	\N	manual	\N	2026-07-07 14:54:48.779875+03
277	102	8	8	SSD 240 ГБ	\N	manual	\N	2026-07-07 14:54:48.779875+03
278	102	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-07-07 14:54:48.779875+03
279	102	7	9	16 ГБ	\N	manual	\N	2026-07-07 14:54:48.779875+03
280	102	10	13	Win10pro (x64)	\N	manual	\N	2026-07-07 14:54:48.779875+03
281	103	8	8	SSD 240 ГБ	\N	manual	\N	2026-07-07 14:54:48.779875+03
282	103	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-07-07 14:54:48.779875+03
283	103	7	9	16 ГБ	\N	manual	\N	2026-07-07 14:54:48.779875+03
284	103	10	13	Win10pro (x64)	\N	manual	\N	2026-07-07 14:54:48.779875+03
285	104	8	8	SSD 240 ГБ	\N	manual	\N	2026-07-07 14:54:48.779875+03
286	104	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-07-07 14:54:48.779875+03
287	104	7	9	16 ГБ	\N	manual	\N	2026-07-07 14:54:48.779875+03
288	104	10	13	Win10pro (x64)	\N	manual	\N	2026-07-07 14:54:48.779875+03
289	105	8	8	SSD 240 ГБ	\N	manual	\N	2026-07-07 14:54:48.779875+03
290	105	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-07-07 14:54:48.779875+03
291	105	7	9	16 ГБ	\N	manual	\N	2026-07-07 14:54:48.779875+03
292	105	10	13	Win10pro (x64)	\N	manual	\N	2026-07-07 14:54:48.779875+03
293	106	8	8	SSD 240 ГБ	\N	manual	\N	2026-07-07 14:54:48.779875+03
294	106	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-07-07 14:54:48.779875+03
295	106	7	9	16 ГБ	\N	manual	\N	2026-07-07 14:54:48.779875+03
296	106	10	13	Win10pro (x64)	\N	manual	\N	2026-07-07 14:54:48.779875+03
297	107	8	8	SSD 240 ГБ	\N	manual	\N	2026-07-07 14:54:48.779875+03
298	107	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-07-07 14:54:48.779875+03
299	107	7	9	16 ГБ	\N	manual	\N	2026-07-07 14:54:48.779875+03
300	107	10	13	Win10pro (x64)	\N	manual	\N	2026-07-07 14:54:48.779875+03
301	108	8	8	SSD 240 ГБ	\N	manual	\N	2026-07-07 14:54:48.779875+03
302	108	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-07-07 14:54:48.779875+03
303	108	7	9	16 ГБ	\N	manual	\N	2026-07-07 14:54:48.779875+03
304	108	10	13	Win10pro (x64)	\N	manual	\N	2026-07-07 14:54:48.779875+03
305	109	8	8	SSD 240 ГБ	\N	manual	\N	2026-07-07 14:54:48.779875+03
306	109	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-07-07 14:54:48.779875+03
307	109	7	9	16 ГБ	\N	manual	\N	2026-07-07 14:54:48.779875+03
308	109	10	13	Win10pro (x64)	\N	manual	\N	2026-07-07 14:54:48.779875+03
309	110	8	8	SSD 240 ГБ	\N	manual	\N	2026-07-07 14:54:48.779875+03
310	110	6	8	Core i3-3220 3,3 ГГц	\N	manual	\N	2026-07-07 14:54:48.779875+03
311	110	7	9	16 ГБ	\N	manual	\N	2026-07-07 14:54:48.779875+03
312	110	10	13	Win10pro (x64)	\N	manual	\N	2026-07-07 14:54:48.779875+03
313	111	9	15	30	\N	manual	\N	2026-07-07 14:54:48.779875+03
314	112	9	15	30	\N	manual	\N	2026-07-07 14:54:48.779875+03
315	113	9	15	30	\N	manual	\N	2026-07-07 14:54:48.779875+03
316	114	9	15	30	\N	manual	\N	2026-07-07 14:54:48.779875+03
317	115	9	15	30	\N	manual	\N	2026-07-07 14:54:48.779875+03
318	116	9	15	30	\N	manual	\N	2026-07-07 14:54:48.779875+03
319	117	9	15	30	\N	manual	\N	2026-07-07 14:54:48.779875+03
320	118	9	15	30	\N	manual	\N	2026-07-07 14:54:48.779875+03
321	119	9	15	30	\N	manual	\N	2026-07-07 14:54:48.779875+03
322	120	9	15	30	\N	manual	\N	2026-07-07 14:54:48.779875+03
324	36	8	8	SSD 512 ГБ; HDD 1 ТБ	\N	manual	\N	2026-07-09 14:11:39.016747+03
327	33	15	21	RBC17	\N	manual	\N	2026-07-09 14:13:51.456398+03
329	33	15	23	1	\N	manual	\N	2026-07-09 14:13:51.463019+03
328	33	15	22	2025-07-01	\N	manual	\N	2026-07-09 14:13:51.459883+03
331	28	8	8	300 ГБ	\N	manual	\N	2026-07-09 14:41:50.571665+03
334	121	16	12	192.168.120.5	\N	manual	\N	2026-07-10 09:46:49.134191+03
335	122	16	12	192.168.120.5	\N	manual	\N	2026-07-10 09:46:49.699866+03
336	123	8	8	SSD 512 ГБ	\N	manual	\N	2026-07-10 10:44:55.30153+03
337	123	6	8	Core i5-12500 3,00 ГГц	\N	manual	\N	2026-07-10 10:44:55.30153+03
338	123	7	9	64 ГБ	\N	manual	\N	2026-07-10 10:44:55.30153+03
339	123	10	13	Astra Linux Special Edition 1.8	\N	manual	\N	2026-07-10 10:44:55.30153+03
340	124	8	8	SSD 512 ГБ	\N	manual	\N	2026-07-10 10:44:55.30153+03
341	124	6	8	Core i5-12500 3,00 ГГц	\N	manual	\N	2026-07-10 10:44:55.30153+03
342	124	7	9	64 ГБ	\N	manual	\N	2026-07-10 10:44:55.30153+03
343	124	10	13	Astra Linux Special Edition 1.8	\N	manual	\N	2026-07-10 10:44:55.30153+03
344	125	8	8	SSD 512 ГБ	\N	manual	\N	2026-07-10 10:44:55.30153+03
345	125	6	8	Core i5-12500 3,00 ГГц	\N	manual	\N	2026-07-10 10:44:55.30153+03
346	125	7	9	64 ГБ	\N	manual	\N	2026-07-10 10:44:55.30153+03
347	125	10	13	Astra Linux Special Edition 1.8	\N	manual	\N	2026-07-10 10:44:55.30153+03
348	126	8	8	SSD 512 ГБ	\N	manual	\N	2026-07-10 10:44:55.30153+03
349	126	6	8	Core i5-12500 3,00 ГГц	\N	manual	\N	2026-07-10 10:44:55.30153+03
350	126	7	9	64 ГБ	\N	manual	\N	2026-07-10 10:44:55.30153+03
351	126	10	13	Astra Linux Special Edition 1.8	\N	manual	\N	2026-07-10 10:44:55.30153+03
352	127	8	8	SSD 512 ГБ	\N	manual	\N	2026-07-10 10:44:55.30153+03
353	127	6	8	Core i5-12500 3,00 ГГц	\N	manual	\N	2026-07-10 10:44:55.30153+03
354	127	7	9	64 ГБ	\N	manual	\N	2026-07-10 10:44:55.30153+03
355	127	10	13	Astra Linux Special Edition 1.8	\N	manual	\N	2026-07-10 10:44:55.30153+03
356	128	8	8	SSD 512 ГБ	\N	manual	\N	2026-07-10 10:44:55.30153+03
357	128	6	8	Core i5-12500 3,00 ГГц	\N	manual	\N	2026-07-10 10:44:55.30153+03
358	128	7	9	64 ГБ	\N	manual	\N	2026-07-10 10:44:55.30153+03
359	128	10	13	Astra Linux Special Edition 1.8	\N	manual	\N	2026-07-10 10:44:55.30153+03
360	129	8	8	SSD 512 ГБ	\N	manual	\N	2026-07-10 10:44:55.30153+03
361	129	6	8	Core i5-12500 3,00 ГГц	\N	manual	\N	2026-07-10 10:44:55.30153+03
362	129	7	9	64 ГБ	\N	manual	\N	2026-07-10 10:44:55.30153+03
363	129	10	13	Astra Linux Special Edition 1.8	\N	manual	\N	2026-07-10 10:44:55.30153+03
364	130	8	8	SSD 512 ГБ	\N	manual	\N	2026-07-10 10:44:55.30153+03
365	130	6	8	Core i5-12500 3,00 ГГц	\N	manual	\N	2026-07-10 10:44:55.30153+03
366	130	7	9	64 ГБ	\N	manual	\N	2026-07-10 10:44:55.30153+03
367	130	10	13	Astra Linux Special Edition 1.8	\N	manual	\N	2026-07-10 10:44:55.30153+03
368	131	8	8	SSD 512 ГБ	\N	manual	\N	2026-07-10 10:44:55.30153+03
369	131	6	8	Core i5-12500 3,00 ГГц	\N	manual	\N	2026-07-10 10:44:55.30153+03
370	131	7	9	64 ГБ	\N	manual	\N	2026-07-10 10:44:55.30153+03
371	131	10	13	Astra Linux Special Edition 1.8	\N	manual	\N	2026-07-10 10:44:55.30153+03
372	132	8	8	SSD 512 ГБ	\N	manual	\N	2026-07-10 10:44:55.30153+03
373	132	6	8	Core i5-12500 3,00 ГГц	\N	manual	\N	2026-07-10 10:44:55.30153+03
374	132	7	9	64 ГБ	\N	manual	\N	2026-07-10 10:44:55.30153+03
375	132	10	13	Astra Linux Special Edition 1.8	\N	manual	\N	2026-07-10 10:44:55.30153+03
376	133	9	15	24	\N	manual	\N	2026-07-10 10:44:55.30153+03
377	134	9	15	24	\N	manual	\N	2026-07-10 10:44:55.30153+03
378	135	9	15	24	\N	manual	\N	2026-07-10 10:44:55.30153+03
379	136	9	15	24	\N	manual	\N	2026-07-10 10:44:55.30153+03
380	137	9	15	24	\N	manual	\N	2026-07-10 10:44:55.30153+03
381	138	9	15	24	\N	manual	\N	2026-07-10 10:44:55.30153+03
382	139	9	15	24	\N	manual	\N	2026-07-10 10:44:55.30153+03
383	140	9	15	24	\N	manual	\N	2026-07-10 10:44:55.30153+03
384	141	9	15	24	\N	manual	\N	2026-07-10 10:44:55.30153+03
385	142	9	15	24	\N	manual	\N	2026-07-10 10:44:55.30153+03
386	82	12	27	admin	\N	manual	\N	2026-07-10 11:23:09.014631+03
387	82	12	28	admin	\N	manual	\N	2026-07-10 11:23:09.0184+03
388	121	16	26	Тестовый коммент	\N	manual	\N	2026-07-10 11:25:46.504214+03
389	65	12	27	admin	\N	manual	\N	2026-07-10 11:52:00.14422+03
390	65	12	28	admin	\N	manual	\N	2026-07-10 11:52:00.148548+03
391	46	9	15	32	\N	manual	\N	2026-07-10 11:57:54.378069+03
392	34	8	8	1 ТБ	\N	manual	\N	2026-07-10 15:22:52.80731+03
393	45	8	8	SSD 256 ГБ	\N	manual	\N	2026-07-14 11:42:26.579315+03
394	144	8	8	HDD 1 ТБ	\N	manual	\N	2026-07-14 13:36:09.273785+03
395	144	6	8	Core i5-7400 3,0 ГГц	\N	manual	\N	2026-07-14 13:36:09.281182+03
396	144	7	9	16 ГБ	\N	manual	\N	2026-07-14 13:36:09.284194+03
397	144	10	11	Mono	\N	manual	\N	2026-07-14 13:36:09.286996+03
398	144	10	13	Win10pro (x64)	\N	manual	\N	2026-07-14 13:36:09.28978+03
399	144	9	15	30	\N	manual	\N	2026-07-14 13:36:09.29246+03
400	91	10	11	303-w10p64-96	\N	manual	\N	2026-07-14 14:27:08.503842+03
401	91	10	12	10.2.2.96	\N	manual	\N	2026-07-14 14:27:08.503842+03
402	51	12	16	A4	\N	manual	\N	2026-07-15 12:02:45.564867+03
403	51	12	17	Лазерный	\N	manual	\N	2026-07-15 12:02:45.574298+03
404	51	12	18	Чёрно-белый	\N	manual	\N	2026-07-15 12:02:45.577856+03
405	51	12	19	USB	\N	manual	\N	2026-07-15 12:02:45.58116+03
406	51	12	20	Отключен	\N	manual	\N	2026-07-15 12:02:45.584417+03
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
1	Ideco	\N	2026-07-09 13:02:16
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
15	Диагональ экрана	Диагональ экрана, дюймы (ноутбук, моноблок, монитор)	\N	f	2026-05-26 14:29:46.807507+03	2026-05-26 14:29:46.807507+03
16	Максимальный размер бумаги	Формат бумаги (A4, A3 и т.д.)	\N	f	2026-05-30 11:14:09.704308+03	2026-05-30 11:14:09.704308+03
17	Технология печати	Лазерный или струйный	\N	f	2026-05-30 11:14:09.704308+03	2026-05-30 11:14:09.704308+03
18	Цветность печати	Чёрно-белый или цветной	\N	f	2026-05-30 11:14:09.704308+03	2026-05-30 11:14:09.704308+03
19	Подключение	Сетевой или USB	\N	f	2026-05-30 11:14:09.704308+03	2026-05-30 11:14:09.704308+03
20	Модуль WiFi	Наличие модуля Wi‑Fi	\N	f	2026-05-30 11:14:09.704308+03	2026-05-30 11:14:09.704308+03
21	Модель аккумулятора	Модель аккумуляторной батареи ИБП	\N	f	2026-05-30 11:14:09.735911+03	2026-05-30 11:14:09.735911+03
22	Дата замены аккумулятора	Дата последней замены аккумуляторной батареи ИБП	\N	f	2026-07-07 15:23:00.441972+03	2026-07-07 15:23:00.441972+03
23	Срок службы аккумулятора	Нормативный срок службы аккумуляторной батареи ИБП	лет	f	2026-07-07 15:23:00.441972+03	2026-07-07 15:23:00.441972+03
24	Тип сканера	Многопоточный, планшетный или комбинированный	\N	f	2026-07-10 09:29:08.121546+03	2026-07-10 09:29:08.121546+03
25	Количество процессоров	Количество установленных процессоров (один или два)	\N	f	2026-07-10 09:32:26.796095+03	2026-07-10 09:32:26.796095+03
26	Описание	Описание прочей техники	\N	f	2026-07-10 09:36:02.415145+03	2026-07-10 09:36:02.415145+03
27	Логин	Логин доступа к веб-интерфейсу устройства	\N	f	2026-07-10 11:10:05.411231+03	2026-07-10 11:10:05.411231+03
28	Пароль	Пароль доступа к веб-интерфейсу устройства	\N	f	2026-07-10 11:10:05.411231+03	2026-07-10 11:10:05.411231+03
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
13	Сканер		f	2026-05-18 10:15:54.76481+03	2026-05-18 10:15:54.76481+03
14	МФУ		f	2026-05-18 10:15:59.747743+03	2026-05-18 10:15:59.747743+03
15	ИБП	Источник бесперебойного питания	f	2026-05-30 11:14:09.735911+03	2026-05-30 11:14:09.735911+03
16	Прочее	Прочая техника	f	2026-07-10 09:36:02.415145+03	2026-07-10 09:36:02.415145+03
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
\.


--
-- Data for Name: task_history; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.task_history (id, task_id, field_name, old_value, new_value, changed_by, changed_at, comment) FROM stdin;
92	34	executor_id		1	1	2026-07-09 14:00:34.093996+03	Синхронизация исполнителя из задачи #59
93	34	status_id	1	7	1	2026-07-09 14:00:34.114374+03	Статус заявки при назначении исполнителя из задачи #59
94	34	status_id	7	2	1	2026-07-09 14:00:34.126162+03	Статус заявки по задаче #59: «В работе»
95	34	status_id	2	4	1	2026-07-09 14:39:24.660702+03	Статус заявки по задаче #59: «Выполнена»
96	35	executor_id		23	24	2026-07-10 10:46:35.449336+03	\N
97	35	status_id	1	7	24	2026-07-10 10:46:35.451648+03	Статус при назначении исполнителя
98	36	executor_id		19	24	2026-07-10 10:47:54.595412+03	\N
99	36	status_id	1	7	24	2026-07-10 10:47:54.596621+03	Статус при назначении исполнителя
100	37	executor_id		24	24	2026-07-10 10:48:16.175864+03	\N
101	37	status_id	1	7	24	2026-07-10 10:48:16.176983+03	Статус при назначении исполнителя
104	37	status_id	7	2	24	2026-07-10 10:48:52.948195+03	Статус заявки по задаче #63: «В работе»
105	37	status_id	2	7	24	2026-07-10 10:48:54.940601+03	Статус заявки по задаче #63: «Назначен исполнитель»
106	35	executor_id	23	24	24	2026-07-10 10:49:24.997196+03	Синхронизация исполнителя из задачи #61
107	35	status_id	7	2	24	2026-07-10 10:49:34.432753+03	Статус заявки по задаче #61: «В работе»
108	37	status_id	7	2	24	2026-07-10 10:49:45.874847+03	Статус заявки по задаче #63: «В работе»
109	37	status_id	2	7	24	2026-07-10 10:49:48.175333+03	Статус заявки по задаче #63: «Назначен исполнитель»
110	37	status_id	7	2	24	2026-07-10 10:49:53.104988+03	Статус заявки по задаче #63: «В работе»
111	37	status_id	2	4	24	2026-07-10 10:50:15.02414+03	Статус заявки по задаче #63: «Выполнена»
112	37	status_id	4	2	24	2026-07-10 10:50:39.227501+03	Статус заявки по задаче #63: «В работе»
113	35	executor_id	24	22	24	2026-07-10 11:17:02.191553+03	Синхронизация исполнителя из задачи #61
114	35	status_id	2	7	24	2026-07-10 11:17:02.194105+03	Статус заявки при назначении исполнителя из задачи #61
115	35	status_id	7	4	24	2026-07-10 11:17:02.195608+03	Статус заявки по задаче #61: «Выполнена»
116	35	executor_id	22	24	24	2026-07-10 11:17:05.783603+03	Синхронизация исполнителя из задачи #61
117	35	status_id	4	7	24	2026-07-10 11:17:05.783603+03	Статус заявки при назначении исполнителя из задачи #61
118	35	status_id	7	4	24	2026-07-10 11:17:05.783603+03	Статус заявки по задаче #61: «Выполнена»
119	35	status_id	4	2	24	2026-07-10 11:17:25.226224+03	Статус заявки по задаче #61: «В работе»
120	39	executor_id		24	24	2026-07-10 11:46:56.208046+03	Синхронизация исполнителя из задачи #66
121	39	status_id	1	7	24	2026-07-10 11:46:56.210274+03	Статус заявки при назначении исполнителя из задачи #66
122	39	status_id	7	2	24	2026-07-10 11:46:56.22145+03	Статус заявки по задаче #66: «В работе»
123	39	status_id	2	4	24	2026-07-10 11:47:10.294924+03	Статус заявки по задаче #66: «Выполнена»
124	39	status_id	4	2	24	2026-07-10 11:47:19.786458+03	Статус заявки по задаче #66: «В работе»
125	39	status_id	2	7	24	2026-07-10 11:47:26.187179+03	Статус заявки по задаче #66: «Назначен исполнитель»
126	36	executor_id	19	1	1	2026-07-10 14:07:52.970752+03	Синхронизация исполнителя из задачи #62
127	36	status_id	7	2	1	2026-07-10 14:07:53.016622+03	Статус заявки по задаче #62: «В работе»
128	36	status_id	2	7	1	2026-07-10 14:09:22.093808+03	Статус заявки по задаче #62: «Назначен исполнитель»
129	36	status_id	7	2	1	2026-07-10 14:09:35.955419+03	Статус заявки по задаче #62: «В работе»
130	36	status_id	2	7	1	2026-07-10 14:09:48.573073+03	Статус заявки по задаче #62: «Назначен исполнитель»
131	35	executor_id	24	22	1	2026-07-10 14:29:19.066191+03	Синхронизация исполнителя из задачи #61
132	35	status_id	2	7	1	2026-07-10 14:29:19.068482+03	Статус заявки при назначении исполнителя из задачи #61
133	35	status_id	7	4	1	2026-07-10 14:29:19.071303+03	Статус заявки по задаче #61: «Выполнена»
134	37	status_id	2	4	1	2026-07-10 14:29:20.79424+03	Статус заявки по задаче #63: «Выполнена»
135	36	status_id	7	2	1	2026-07-10 14:29:23.907081+03	Статус заявки по задаче #62: «В работе»
136	42	executor_id		1	1	2026-07-10 14:29:26.225745+03	Синхронизация исполнителя из задачи #69
137	42	status_id	1	7	1	2026-07-10 14:29:26.228015+03	Статус заявки при назначении исполнителя из задачи #69
138	42	status_id	7	2	1	2026-07-10 14:29:26.237846+03	Статус заявки по задаче #69: «В работе»
139	36	status_id	2	7	1	2026-07-10 14:29:41.833226+03	Статус заявки по задаче #62: «Назначен исполнитель»
140	35	executor_id	22	24	24	2026-07-10 14:29:49.936095+03	Синхронизация исполнителя из задачи #61
141	35	status_id	4	7	24	2026-07-10 14:29:49.938286+03	Статус заявки при назначении исполнителя из задачи #61
142	35	status_id	7	2	24	2026-07-10 14:29:49.940241+03	Статус заявки по задаче #61: «В работе»
143	39	status_id	7	2	24	2026-07-10 14:30:15.230607+03	Статус заявки по задаче #66: «В работе»
144	42	status_id	2	4	24	2026-07-10 14:30:23.253956+03	Статус заявки по задаче #69: «Выполнена»
145	37	status_id	4	2	24	2026-07-10 14:30:32.526875+03	Статус заявки по задаче #63: «В работе»
146	40	executor_id		24	24	2026-07-10 14:30:38.767542+03	Синхронизация исполнителя из задачи #67
147	40	status_id	1	7	24	2026-07-10 14:30:38.769503+03	Статус заявки при назначении исполнителя из задачи #67
148	40	status_id	7	2	24	2026-07-10 14:30:38.78025+03	Статус заявки по задаче #67: «В работе»
149	40	status_id	2	7	24	2026-07-10 14:30:44.496288+03	Статус заявки по задаче #67: «Назначен исполнитель»
150	35	executor_id	24	22	24	2026-07-10 14:31:09.867682+03	Синхронизация исполнителя из задачи #61
151	35	status_id	2	7	24	2026-07-10 14:31:09.870005+03	Статус заявки при назначении исполнителя из задачи #61
152	39	status_id	2	4	1	2026-07-10 14:31:14.328127+03	Статус заявки по задаче #66: «Выполнена»
153	35	executor_id	22	24	24	2026-07-10 14:31:14.710477+03	Синхронизация исполнителя из задачи #61
154	35	status_id	7	2	24	2026-07-10 14:31:14.713344+03	Статус заявки по задаче #61: «В работе»
155	37	status_id	2	4	1	2026-07-10 14:31:14.952998+03	Статус заявки по задаче #63: «Выполнена»
156	36	status_id	7	2	1	2026-07-10 14:31:17.314809+03	Статус заявки по задаче #62: «В работе»
157	36	status_id	2	7	24	2026-07-10 14:31:22.6389+03	Статус заявки по задаче #62: «Назначен исполнитель»
158	35	executor_id	24	22	24	2026-07-10 14:31:24.50206+03	Синхронизация исполнителя из задачи #61
159	35	status_id	2	7	24	2026-07-10 14:31:24.504623+03	Статус заявки при назначении исполнителя из задачи #61
160	39	status_id	4	2	24	2026-07-10 14:31:26.482729+03	Статус заявки по задаче #66: «В работе»
161	40	status_id	7	2	24	2026-07-10 14:31:39.456845+03	Статус заявки по задаче #67: «В работе»
162	35	executor_id	22	24	24	2026-07-10 14:31:45.459261+03	Синхронизация исполнителя из задачи #61
163	35	status_id	7	2	24	2026-07-10 14:31:45.462353+03	Статус заявки по задаче #61: «В работе»
164	39	status_id	2	7	24	2026-07-10 14:32:25.882531+03	Статус заявки по задаче #66: «Назначен исполнитель»
165	39	status_id	7	2	24	2026-07-10 14:32:55.40878+03	Статус заявки по задаче #66: «В работе»
166	40	status_id	2	7	24	2026-07-10 14:35:12.317194+03	Статус заявки по задаче #67: «Назначен исполнитель»
167	41	executor_id		15	1	2026-07-14 11:37:01.003339+03	\N
168	41	status_id	1	7	1	2026-07-14 11:37:01.014883+03	Статус при назначении исполнителя
\.


--
-- Data for Name: tasks; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.tasks (id, task_number, title, description, status_id, requester_id, executor_id, priority, due_at, closed_at, comment, attachments_legacy, is_deleted, deleted_at, deleted_by, delete_reason, created_at, updated_at, contact_phone, room_number) FROM stdin;
39	\N	\N	Спасите, умер системник, перевставлял провод - результат нулевой	2	25	24	medium	\N	\N	\N	\N	f	\N	\N	\N	2026-07-10 11:45:12.875405+03	2026-07-10 14:32:55.410509+03	7-54	643
40	\N	\N	Сломался комп	7	25	24	medium	\N	\N	\N	\N	f	\N	\N	\N	2026-07-10 12:46:01.147557+03	2026-07-10 14:35:12.318512+03	\N	306
41	\N	\N	4324234	7	25	15	medium	\N	\N	\N	\N	f	\N	\N	\N	2026-07-10 12:46:13.938777+03	2026-07-14 11:37:00.965252+03	\N	306
34	\N	\N	Не работает МФУ	4	1	1	medium	\N	2026-07-09 13:39:24+03	\N	\N	f	\N	\N	\N	2026-07-09 13:59:43.628719+03	2026-07-09 14:39:24.66231+03	\N	101
42	\N	\N	65464	4	25	1	medium	\N	2026-07-10 13:30:23+03	\N	\N	f	\N	\N	\N	2026-07-10 12:46:31.585655+03	2026-07-10 14:30:23.255015+03	\N	306
37	\N	\N	Застрял диск в компьютере	4	24	24	medium	\N	2026-07-10 13:31:14+03	\N	\N	f	\N	\N	\N	2026-07-10 10:48:13.256817+03	2026-07-10 14:31:14.954287+03	\N	810
36	\N	\N	НЕТ ИНТЕРНЕТА!	7	24	1	medium	\N	\N	\N	\N	f	\N	\N	\N	2026-07-10 10:47:51.762755+03	2026-07-10 14:31:22.640147+03	\N	612
35	\N	\N	Помогите, сломался монитор!!	2	24	24	medium	\N	\N	\N	\N	f	\N	\N	\N	2026-07-10 10:46:28.815518+03	2026-07-10 14:31:45.46324+03	\N	306
\.


--
-- Data for Name: user_equipment_cards; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.user_equipment_cards (id, user_id, is_signed, signed_at, signed_by_admin_id, version_no, last_snapshot_hash, created_at, updated_at) FROM stdin;
10	2	f	\N	\N	30	943aaa58a6eac88248bc2149ad0e8921031b7e07cd212bcbe2d6e3b64a48df3c	2026-05-22 13:03:33	\N
3	10	t	2026-07-14 10:41:55	1	15	d2579622b7a5d4635afcfafbd2b7957df4ec6bd49dad522d6ada65198395852b	2026-05-18 11:40:25	\N
19	12	t	2026-07-14 10:41:57	1	6	a453d7915917f36452ad7d4d7652f3b3294d7321d2f165d91123a47e05c1c4f4	2026-07-10 11:59:54	\N
2	9	t	2026-07-14 10:11:02	1	15	ffcccf711131cb42915a468b408cb8d6806bc256a99f45e0d973b52cb6c39f4d	2026-05-18 11:24:15	\N
18	25	t	2026-07-10 09:55:16	24	7	8f33d511806808f586f54c5a4c40186277d8b7068a358a40785082311af4b465	2026-07-10 10:53:19	\N
5	3	t	2026-07-15 10:41:20	1	41	bef9688afe90de1374ad7cffe16dc9fac8e6801166bd8b6706c8d4fd9c154126	2026-05-18 11:59:49	\N
11	8	t	2026-07-15 10:41:21	1	25	02f60f10a696e12479821a707aa0c0b8a017ac12bc5bbbf5fedeaca80b0fd7ff	2026-05-28 11:50:07	\N
22	13	t	2026-07-15 10:41:22	1	2	bc43d82fc97cc4c96ea402dbc1c3adb6b218cec57356f59fb4e3800c5a2e27f6	2026-07-14 14:27:09	\N
12	19	t	2026-07-15 10:41:22	1	26	307434276a19a7812a5a0dd0adc0d489cf0eb5b3c640591a95fe4c69d9988186	2026-05-28 14:35:23	\N
21	7	f	\N	\N	6	db0a5b80a0f00025f5ad1c2dcbf5ae80069650adf7e5da82f191c348fb6f7dc3	2026-07-10 12:15:59	\N
7	11	t	2026-05-30 12:33:38	1	5	4efa0da5142ad58c4d0ffb96c03b32d265dbe5430b8597bd6ef93b70953eae8e	2026-05-19 15:02:15	\N
6	14	t	2026-05-30 12:33:38	1	2	05cf125a47992c46edde507d63b08c7d8ce3b7f2a80d0150a1694c4c3de2b66f	2026-05-18 12:25:28	\N
9	5	t	2026-05-30 12:33:39	1	4	9dc73a2e6d85ffd2d2f3c17cb4e2848f03ba6eea7d1ee0275264821ec4b8b6f6	2026-05-22 13:03:33	\N
14	21	t	2026-05-30 12:33:39	1	4	30613b7e0881933a74b9aa7118363979a8752b3fa33e55ff6167ec9244baaf48	2026-05-30 12:16:21	\N
4	4	f	\N	\N	18	9c1de5fa6e4b76c1b3c6be7d2fba719accf0d07c9aa6d7f9bb524e2b8b08b669	2026-05-18 11:48:45	\N
8	16	t	2026-07-09 10:30:37	1	17	b75255204af54df43148996926d2470e55086df4e5ddffbceb7d5f4ba2ebf03b	2026-05-19 15:02:15	\N
17	24	t	2026-07-10 10:33:21	1	5	b5e5d7a20eb920515e9fae627c5000c0f07fe13d6e24ca0e136b330132ef3b74	2026-07-10 10:33:21	\N
\.


--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.user_roles (id, user_id, role_id, assigned_by, assigned_at, revoked_at, is_active) FROM stdin;
1	1	1	\N	2026-02-12 09:34:07+03	\N	t
496	14	3	\N	2026-05-18 10:23:37.024362+03	\N	t
498	16	3	\N	2026-05-18 10:23:37.024362+03	\N	t
499	17	3	\N	2026-05-18 10:23:37.024362+03	\N	t
500	18	3	\N	2026-05-18 10:23:37.024362+03	\N	t
497	15	3	\N	2026-05-18 10:23:37.024362+03	2026-05-26 13:53:56+03	f
501	15	2	\N	2026-05-26 13:53:56+03	\N	t
502	19	2	\N	2026-05-26 15:48:28+03	\N	t
503	21	3	\N	2026-05-30 11:12:54+03	\N	t
505	23	1	\N	2026-07-10 08:54:36+03	\N	t
506	24	1	\N	2026-07-10 09:25:40+03	\N	t
507	25	3	\N	2026-07-10 09:51:57+03	\N	t
504	22	2	\N	2026-06-01 15:39:06+03	2026-07-14 12:49:39+03	f
508	22	1	\N	2026-07-14 12:49:39+03	\N	t
484	2	3	\N	2026-05-16 14:24:43.656427+03	\N	t
485	3	3	\N	2026-05-16 14:24:43.656427+03	\N	t
486	4	3	\N	2026-05-16 14:24:43.656427+03	\N	t
487	5	3	\N	2026-05-16 14:24:43.656427+03	\N	t
488	6	3	\N	2026-05-16 14:24:43.656427+03	\N	t
489	7	3	\N	2026-05-16 14:24:43.656427+03	\N	t
490	8	3	\N	2026-05-16 14:24:43.656427+03	\N	t
491	9	3	\N	2026-05-16 14:24:43.656427+03	\N	t
492	10	3	\N	2026-05-16 14:24:43.656427+03	\N	t
493	11	3	\N	2026-05-16 14:24:43.656427+03	\N	t
494	12	3	\N	2026-05-16 14:24:43.656427+03	\N	t
495	13	3	\N	2026-05-16 14:24:43.656427+03	\N	t
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.users (id, username, full_name, "position", department, email, phone, password_hash, is_active, is_locked, failed_login_attempts, lock_until, password_changed_at, last_login_at, created_by_id, updated_by_id, created_at, updated_at, is_deleted) FROM stdin;
16	\N	Абрамова Дарья Алексанровна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-05-18 10:23:37.024362+03	2026-05-18 10:23:37.024362+03	f
17	\N	Новгородова Елена Викторовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-05-18 10:23:37.024362+03	2026-05-18 10:23:37.024362+03	f
18	\N	Сергеев Андрей Анатольевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-05-18 10:23:37.024362+03	2026-05-18 10:23:37.024362+03	f
1	admin	Администратор	\N	\N	admin@local	6-85	$2y$13$/H5GGlnZY8NaAyHUVzOQkegg7mbLlEC9VSAt9u22boIESKrG9gZKu	t	f	0	\N	\N	\N	\N	\N	2026-02-12 11:34:07.204663+03	2026-07-15 12:17:21.399357+03	f
15	\N	Рыбаков Руслан Анатольевич	\N	\N		\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-05-18 10:23:37.024362+03	2026-05-26 14:53:56.44013+03	f
14	\N	Ларин Игорь Сергеевич	\N	\N	larin@local.ru	6-85	$2y$13$zN8x6hdA/7VWf.0XZlFIQOJWZueBRtpd7hLj6t/tP6YT2/lqoacSe	t	f	0	\N	\N	\N	\N	\N	2026-05-18 10:23:37.024362+03	2026-05-26 17:12:13.923699+03	f
21	vselivanov@vniicentr.ru	Селиванов Владислав Геннадьевич	\N	\N	vselivanov@vniicentr.ru	6-85	$2y$13$2Qg30kypGbyutYAvAaP2veaad8uOoZ/Voa/T.Cf6bowv2ZWcGsTMC	t	f	0	\N	\N	\N	\N	\N	2026-05-30 12:12:54.088147+03	2026-05-30 12:16:47.754619+03	f
19	dkulakov@vniicentr.ru	Кулаков Дмитрий Дмитриевич	\N	\N	dkulakov@vniicentr.ru		$2y$13$Iq4YvUxV2bNJkKX0cSmtOObH/y0cx8zGB1RhZTOEfUiHILpCL4tk6	t	f	0	\N	\N	\N	\N	\N	2026-05-26 16:48:27.989735+03	2026-06-01 12:50:58.041213+03	f
10		Андросова Наталья Вячеславовна	\N	\N		6-66	\N	t	f	0	\N	\N	\N	\N	\N	2026-05-16 14:24:43.656427+03	2026-06-01 16:40:53.428937+03	f
23	akrutov@vniicentr.ru	Крутов Алексей Михайлович	\N	\N	akrutov@vniicentr.ru		$2y$13$A6Eekz0uARq5npTvQQ72Z.oZWB0CRHXEFIypEEe6Rbh2z8yYjpG22	t	f	0	\N	\N	\N	\N	\N	2026-07-10 09:54:36.236962+03	2026-07-10 09:54:36.236962+03	f
24	vshvornev@vniicentr.ru	Шворнев Владислав Николаевич	\N	\N	vshvornev@vniicentr.ru		$2y$13$gJ05nb/cUf.DocAikLPpKOcG3pat1IAApWpqnvwgT8jeo2UdDUVDO	t	f	0	\N	\N	\N	\N	\N	2026-07-10 10:25:40.443839+03	2026-07-10 10:25:40.443839+03	f
25	ZPizzza@vniicentr.ru	Покушать Пиццу Николашич	\N	\N	ZPizzza@vniicentr.ru		$2y$13$35.x5JUgxM8uVhnTIgPMx.w772G2oEmXzyqsk0TmV5NHrDdmA.kLW	t	f	0	\N	\N	\N	\N	\N	2026-07-10 10:51:57.318913+03	2026-07-10 11:50:07.428425+03	f
22	ikalugin@vniicentr.ru	Калугин Илья Игоревич	\N	\N	ikalugin@vniicentr.ru	6-85	$2y$13$PcYsKBp08gJny50QF0ohsODfYbjcFUj2V5cYvxiMXc/a9UVYeB6yS	t	f	0	\N	\N	\N	\N	\N	2026-06-01 16:39:06.091692+03	2026-07-14 13:49:34.194376+03	f
2	\N	Яшкина Елизавета  Вячеславовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-16 14:24:43.656427+03	f
3	\N	Аптекарева Виктория Михайловна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-16 14:24:43.656427+03	f
4	\N	Елистратова Мария Сергеевна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-16 14:24:43.656427+03	f
5	\N	Мохова Елена Александровна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-16 14:24:43.656427+03	f
6	\N	Катлинская Маргарита Александровна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-16 14:24:43.656427+03	f
7	\N	Якушина Ирина Станиславовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-16 14:24:43.656427+03	f
8	\N	Иваненко Константин Викторович	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-16 14:24:43.656427+03	f
9	\N	Тютчев Сергей Николаевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-16 14:24:43.656427+03	f
11	\N	Котов Михаил Ювинальевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-16 14:24:43.656427+03	f
12	\N	Печерский Виталий Васильевич	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-16 14:24:43.656427+03	f
13	\N	Козлова Ангелина Вячеславовна	\N	\N	\N	\N	\N	t	f	0	\N	\N	\N	\N	\N	2026-05-16 14:24:43.656427+03	2026-05-16 14:24:43.656427+03	f
\.


--
-- Data for Name: work_task_attachments; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.work_task_attachments (id, work_task_id, attachment_id, linked_by, linked_at) FROM stdin;
\.


--
-- Data for Name: work_task_comments; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.work_task_comments (id, work_task_id, author_id, body, created_at) FROM stdin;
1	1	1	Нужно доделать	2026-05-26 15:33:47
2	6	1	123	2026-05-26 15:37:29
3	3	1	Опа	2026-05-26 16:51:47
4	14	1	Работаю Босс	2026-05-26 16:53:37
5	18	1	Руслан стоит пиздит	2026-05-27 12:00:12
6	26	1	123	2026-05-27 15:51:28
7	28	1	123	2026-05-27 16:00:22
8	28	1	142	2026-05-27 16:04:00
9	28	1	124	2026-05-27 16:04:14
10	28	1	124124	2026-05-27 16:04:17
11	25	1	123123	2026-05-27 16:57:06
12	25	1	123123	2026-05-27 16:57:08
13	25	1	123123123	2026-05-27 16:57:10
14	25	1	123123123	2026-05-27 16:57:13
15	25	1	123123123	2026-05-27 16:57:15
16	25	1	123123123	2026-05-27 16:57:17
17	46	1	Проверка	2026-05-30 13:49:35
18	44	19	124124	2026-06-01 13:09:42
\.


--
-- Data for Name: work_task_executors; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.work_task_executors (id, work_task_id, user_id, created_at) FROM stdin;
1	34	19	2026-05-27 17:08:09
2	33	19	2026-05-28 11:16:11
3	30	19	2026-05-28 12:13:15
4	29	19	2026-05-28 12:16:58
5	37	19	2026-05-28 12:18:25
6	38	15	2026-05-28 12:25:22
7	42	19	2026-05-28 12:30:54
8	27	19	2026-05-27 14:28:47
9	48	19	2026-05-30 12:15:17
10	39	19	2026-05-30 13:22:07
11	41	15	2026-05-30 13:22:10
13	25	19	2026-05-27 17:03:49
14	32	15	2026-05-27 17:03:52
15	35	19	2026-05-27 17:03:54
16	28	19	2026-05-27 17:03:56
17	31	19	2026-05-27 17:06:25
18	36	15	2026-05-27 17:06:27
20	46	1	2026-06-01 12:27:49
21	42	15	2026-06-01 12:30:58
22	45	15	2026-06-01 12:31:12
23	46	19	2026-06-01 12:33:42
24	45	19	2026-06-01 12:42:56
25	49	19	2026-06-01 12:47:34
26	40	19	2026-06-01 12:51:43
27	43	19	2026-06-01 12:51:52
28	50	19	2026-06-01 12:54:04
29	44	15	2026-06-01 13:02:27
30	51	15	2026-06-01 13:02:59
32	44	19	2026-06-01 13:11:26
33	49	1	2026-06-01 13:11:47
34	45	1	2026-06-01 13:11:57
35	44	1	2026-06-01 13:12:06
36	42	1	2026-06-01 13:12:14
37	53	19	2026-06-01 13:18:19
38	54	19	2026-06-01 13:19:34
39	54	15	2026-06-01 13:19:37
40	58	1	2026-07-07 13:16:45
41	57	1	2026-07-07 13:16:47
42	56	1	2026-07-07 13:16:49
43	55	1	2026-07-07 13:16:50
44	59	1	2026-07-09 14:00:34
45	60	24	2026-07-10 10:28:18
48	63	24	2026-07-10 10:48:16
50	61	24	2026-07-10 10:49:25
51	61	22	2026-07-10 10:49:30
54	64	24	2026-07-10 11:18:26
56	66	24	2026-07-10 11:46:56
57	62	1	2026-07-10 14:07:53
58	65	1	2026-07-10 14:17:30
59	69	1	2026-07-10 14:29:26
60	67	24	2026-07-10 14:30:39
61	68	15	2026-07-14 11:37:01
\.


--
-- Data for Name: work_task_history; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.work_task_history (id, work_task_id, event_type, old_status_id, new_status_id, comment, changed_by, changed_at) FROM stdin;
1	1	created	\N	1	\N	1	2026-05-26 14:49:33
2	1	assign_executor	1	2	\N	1	2026-05-26 14:49:54
3	1	assign_executor	2	2	\N	1	2026-05-26 14:49:55
4	1	status_change	2	3	\N	1	2026-05-26 14:50:00
5	1	status_change	3	4	\N	1	2026-05-26 14:50:03
6	1	status_change	4	5	\N	1	2026-05-26 14:50:04
7	2	created	\N	1	\N	1	2026-05-26 14:54:31
8	3	created	\N	1	\N	1	2026-05-26 14:54:32
9	3	assign_executor	1	2	\N	1	2026-05-26 14:57:01
10	3	status_change	2	3	\N	1	2026-05-26 14:57:05
11	3	status_change	3	2	\N	1	2026-05-26 14:57:11
12	3	status_change	2	3	\N	1	2026-05-26 14:57:14
13	3	status_change	3	4	\N	1	2026-05-26 14:57:15
14	3	status_change	4	3	\N	1	2026-05-26 14:57:18
15	3	assign_executor	3	3	\N	1	2026-05-26 14:57:23
16	2	assign_executor	1	2	\N	1	2026-05-26 14:57:33
17	2	assign_executor	2	2	\N	1	2026-05-26 14:59:18
18	2	status_change	2	3	\N	1	2026-05-26 14:59:25
19	2	assign_executor	3	3	\N	1	2026-05-26 14:59:32
20	2	status_change	3	4	\N	1	2026-05-26 14:59:40
21	4	created	\N	1	\N	1	2026-05-26 14:59:53
22	5	created	\N	1	\N	1	2026-05-26 14:59:53
23	4	deleted	1	\N	Задача удалена	1	2026-05-26 15:02:00
24	5	deleted	1	\N	Задача удалена	1	2026-05-26 15:02:07
25	6	created	\N	1	\N	1	2026-05-26 15:02:13
26	7	created	\N	1	\N	1	2026-05-26 15:03:10
27	6	assign_executor	1	2	\N	1	2026-05-26 15:04:07
28	6	status_change	2	3	\N	1	2026-05-26 15:04:17
29	3	status_change	3	2	\N	1	2026-05-26 15:04:23
30	3	status_change	2	3	\N	1	2026-05-26 15:04:25
31	3	status_change	3	4	\N	1	2026-05-26 15:04:28
32	3	status_change	4	5	\N	1	2026-05-26 15:04:29
33	7	assign_executor	1	2	\N	1	2026-05-26 15:07:26
34	2	status_change	4	5	\N	1	2026-05-26 15:07:45
35	1	status_change	5	3	\N	1	2026-05-26 15:07:53
36	7	status_change	2	3	\N	1	2026-05-26 15:07:58
37	1	status_change	3	2	\N	1	2026-05-26 15:08:11
38	1	status_change	2	3	\N	1	2026-05-26 15:08:16
39	1	status_change	3	2	\N	1	2026-05-26 15:08:19
40	8	created	\N	1	\N	1	2026-05-26 15:08:29
41	8	assign_executor	1	2	\N	1	2026-05-26 15:09:37
42	8	status_change	2	3	\N	1	2026-05-26 15:10:04
43	7	status_change	3	4	\N	1	2026-05-26 15:11:30
44	7	status_change	4	5	\N	1	2026-05-26 15:11:33
45	2	status_change	5	3	\N	1	2026-05-26 15:11:36
46	9	created	\N	1	\N	1	2026-05-26 15:11:53
47	9	assign_executor	1	2	\N	1	2026-05-26 15:11:58
48	9	status_change	2	3	\N	1	2026-05-26 15:12:04
49	1	status_change	2	3	\N	1	2026-05-26 15:12:57
50	1	status_change	3	4	\N	1	2026-05-26 15:13:00
51	1	status_change	4	5	\N	1	2026-05-26 15:13:03
52	1	status_change	5	3	\N	1	2026-05-26 15:13:07
53	1	status_change	3	4	\N	1	2026-05-26 15:21:53
54	9	status_change	3	4	\N	1	2026-05-26 15:21:56
55	1	status_change	4	3	\N	1	2026-05-26 15:21:58
56	9	status_change	4	3	\N	1	2026-05-26 15:21:59
57	2	status_change	3	2	\N	1	2026-05-26 15:22:03
58	6	status_change	3	2	\N	1	2026-05-26 15:22:05
59	8	status_change	3	2	\N	1	2026-05-26 15:22:06
60	9	status_change	3	2	\N	1	2026-05-26 15:22:06
61	1	status_change	3	2	\N	1	2026-05-26 15:22:07
62	2	status_change	2	3	\N	1	2026-05-26 15:22:09
63	8	status_change	2	3	\N	1	2026-05-26 15:22:11
64	9	status_change	2	3	\N	1	2026-05-26 15:27:54
65	9	status_change	3	4	\N	1	2026-05-26 15:27:57
66	9	status_change	4	5	\N	1	2026-05-26 15:28:01
67	3	status_change	5	3	\N	1	2026-05-26 15:28:09
68	2	status_change	3	4	\N	1	2026-05-26 15:28:30
69	1	comment	\N	\N	Нужно доделать	1	2026-05-26 15:33:47
70	6	status_change	2	3	\N	1	2026-05-26 15:35:01
71	6	comment	\N	\N	123	1	2026-05-26 15:37:29
72	10	created_from_request	\N	1	Создана по заявке #4	1	2026-05-26 15:41:23
73	10	assign_executor	1	2	\N	1	2026-05-26 15:43:53
74	10	status_change	2	3	\N	1	2026-05-26 15:46:24
75	6	status_change	3	2	\N	1	2026-05-26 15:46:30
76	10	status_change	3	2	\N	1	2026-05-26 15:46:37
77	10	status_change	2	3	\N	1	2026-05-26 15:46:40
78	2	status_change	4	3	\N	1	2026-05-26 15:46:44
79	8	status_change	3	2	\N	1	2026-05-26 15:50:20
80	3	status_change	3	2	\N	1	2026-05-26 15:50:21
81	1	status_change	2	3	\N	1	2026-05-26 15:50:23
82	11	created_from_request	\N	1	Создана по заявке #5	1	2026-05-26 15:52:31
83	11	assign_executor	1	2	\N	1	2026-05-26 15:52:44
84	11	status_change	2	3	\N	1	2026-05-26 15:54:05
85	11	status_change	3	4	\N	1	2026-05-26 15:54:12
86	12	created_from_request	\N	1	Создана по заявке #6	1	2026-05-26 16:07:48
87	12	assign_executor	1	2	\N	1	2026-05-26 16:07:58
88	13	created_from_request	\N	1	Создана по заявке #7	1	2026-05-26 16:09:27
89	13	assign_executor	1	2	\N	1	2026-05-26 16:12:20
90	6	status_change	2	3	\N	1	2026-05-26 16:14:46
91	11	status_change	4	5	\N	1	2026-05-26 16:15:06
92	12	status_change	2	3	\N	1	2026-05-26 16:16:39
93	12	status_change	3	2	\N	1	2026-05-26 16:16:43
94	12	status_change	2	3	\N	1	2026-05-26 16:17:47
95	12	status_change	3	4	\N	1	2026-05-26 16:17:59
96	12	status_change	4	5	\N	1	2026-05-26 16:18:11
97	3	status_change	2	3	\N	1	2026-05-26 16:21:22
98	6	status_change	3	4	\N	1	2026-05-26 16:21:25
99	13	status_change	2	3	\N	1	2026-05-26 16:51:29
100	3	comment	\N	\N	Опа	1	2026-05-26 16:51:47
101	8	deleted	2	\N	Задача удалена	1	2026-05-26 16:52:14
102	13	deleted	3	\N	Задача удалена	1	2026-05-26 16:52:18
103	3	deleted	3	\N	Задача удалена	1	2026-05-26 16:52:21
104	1	deleted	3	\N	Задача удалена	1	2026-05-26 16:52:23
105	2	deleted	3	\N	Задача удалена	1	2026-05-26 16:52:27
106	10	deleted	3	\N	Задача удалена	1	2026-05-26 16:52:30
107	6	deleted	4	\N	Задача удалена	1	2026-05-26 16:52:33
108	12	deleted	5	\N	Задача удалена	1	2026-05-26 16:52:38
109	11	deleted	5	\N	Задача удалена	1	2026-05-26 16:52:42
110	9	deleted	5	\N	Задача удалена	1	2026-05-26 16:52:45
111	7	deleted	5	\N	Задача удалена	1	2026-05-26 16:52:48
112	14	created_from_request	\N	1	Создана по заявке #8	1	2026-05-26 16:53:10
113	14	assign_executor	1	2	Назначен исполнитель из заявки #8	1	2026-05-26 16:53:19
114	14	comment	\N	\N	Работаю Босс	1	2026-05-26 16:53:37
115	14	status_change	2	3	\N	1	2026-05-26 16:53:39
116	14	status_change	3	4	\N	1	2026-05-26 16:53:43
117	14	status_change	4	3	\N	1	2026-05-26 16:53:48
118	14	status_change	3	4	\N	1	2026-05-26 16:53:51
119	14	status_change	4	5	\N	1	2026-05-26 16:53:57
120	15	created_from_request	\N	1	Создана по заявке #9	1	2026-05-26 16:54:25
121	15	assign_executor	1	2	\N	1	2026-05-26 16:54:35
122	15	status_change	2	3	\N	1	2026-05-26 16:54:59
123	15	status_change	3	4	\N	1	2026-05-26 16:55:00
124	16	created_from_request	\N	1	Создана по заявке #10	14	2026-05-26 17:04:25
125	16	assign_executor	1	2	Назначен исполнитель из заявки #10	1	2026-05-26 17:04:55
126	16	status_change	2	3	\N	1	2026-05-26 17:15:32
127	16	status_change	3	4	\N	1	2026-05-26 17:15:36
128	17	created_from_request	\N	1	Создана по заявке #11	1	2026-05-26 17:16:58
129	17	assign_executor	1	2	\N	1	2026-05-26 17:17:08
130	14	deleted	5	\N	Задача удалена	1	2026-05-27 11:05:46
131	16	deleted	4	\N	Задача удалена	1	2026-05-27 11:05:50
132	15	deleted	4	\N	Задача удалена	1	2026-05-27 11:05:57
133	17	deleted	2	\N	Задача удалена	1	2026-05-27 11:06:04
134	18	created_from_request	\N	1	Создана по заявке #12	1	2026-05-27 11:59:17
135	18	assign_executor	1	2	\N	1	2026-05-27 11:59:26
136	18	status_change	2	3	\N	1	2026-05-27 11:59:30
137	18	status_change	3	4	\N	1	2026-05-27 11:59:46
138	18	comment	\N	\N	Руслан стоит пиздит	1	2026-05-27 12:00:12
139	18	deleted	4	\N	Задача удалена	1	2026-05-27 12:00:23
140	19	created_from_request	\N	1	Создана по заявке #13	1	2026-05-27 12:00:54
141	19	assign_executor	1	2	\N	1	2026-05-27 12:01:04
142	19	status_change	2	3	\N	1	2026-05-27 12:01:07
143	19	status_change	3	4	\N	1	2026-05-27 12:01:08
144	19	status_change	4	5	\N	1	2026-05-27 12:01:13
145	20	created_from_request	\N	1	Создана по заявке #14	1	2026-05-27 12:01:54
146	20	assign_executor	1	2	Назначен исполнитель из заявки #14	1	2026-05-27 12:01:59
147	20	status_change	2	3	\N	1	2026-05-27 12:02:05
148	20	status_change	3	4	\N	1	2026-05-27 12:02:10
149	20	status_change	4	5	\N	1	2026-05-27 12:02:13
150	21	created_from_request	\N	1	Создана по заявке #15	1	2026-05-27 12:26:45
151	21	deleted	1	\N	Задача удалена	1	2026-05-27 12:30:07
152	22	created_from_request	\N	1	Создана по заявке #16	1	2026-05-27 12:30:32
153	22	deleted	1	\N	Задача удалена	1	2026-05-27 12:31:36
154	23	created_from_request	\N	1	Создана по заявке #17	1	2026-05-27 12:35:29
155	23	deleted	1	\N	Задача удалена	1	2026-05-27 12:36:03
156	24	created	\N	1	\N	1	2026-05-27 13:22:59
157	24	assign_executor	1	2	\N	1	2026-05-27 13:23:11
158	24	status_change	2	3	\N	1	2026-05-27 13:23:14
159	24	status_change	3	4	\N	1	2026-05-27 13:23:15
160	24	status_change	4	3	\N	1	2026-05-27 13:23:19
161	24	status_change	3	4	\N	1	2026-05-27 13:29:29
162	24	status_change	4	3	\N	1	2026-05-27 13:34:17
163	24	status_change	3	4	\N	1	2026-05-27 13:34:19
164	24	status_change	4	3	\N	1	2026-05-27 13:34:20
165	24	status_change	3	4	\N	1	2026-05-27 13:34:25
166	24	status_change	4	5	\N	1	2026-05-27 13:34:43
167	19	deleted	5	\N	Задача удалена	1	2026-05-27 13:34:52
168	20	deleted	5	\N	Задача удалена	1	2026-05-27 13:34:56
169	24	deleted	5	\N	Задача удалена	1	2026-05-27 13:34:59
170	25	created	\N	1	\N	1	2026-05-27 14:23:41
171	26	created_from_request	\N	1	Создана по заявке #18	1	2026-05-27 14:24:19
172	27	created_from_request	\N	1	Создана по заявке #19	1	2026-05-27 14:24:25
173	28	created	\N	1	\N	1	2026-05-27 14:26:25
174	27	assign_executor	1	2	\N	1	2026-05-27 14:28:40
175	27	status_change	2	3	\N	1	2026-05-27 14:28:43
176	27	status_change	3	4	\N	1	2026-05-27 14:28:45
177	27	status_change	4	5	\N	1	2026-05-27 14:28:47
178	25	assign_executor	1	2	\N	1	2026-05-27 15:34:12
179	25	status_change	2	3	\N	1	2026-05-27 15:34:15
180	25	status_change	3	4	\N	1	2026-05-27 15:34:17
181	26	assign_executor	1	2	Назначен исполнитель из заявки #18	1	2026-05-27 15:36:53
182	26	comment	\N	\N	123	1	2026-05-27 15:51:28
183	26	deleted	2	\N	Задача удалена	1	2026-05-27 15:57:55
184	28	comment	\N	\N	123	1	2026-05-27 16:00:22
185	28	assign_executor	1	2	\N	1	2026-05-27 16:03:34
186	28	comment	\N	\N	142	1	2026-05-27 16:04:00
187	28	comment	\N	\N	124	1	2026-05-27 16:04:14
188	28	comment	\N	\N	124124	1	2026-05-27 16:04:17
189	29	created	\N	1	\N	1	2026-05-27 16:23:50
190	30	created	\N	1	\N	1	2026-05-27 16:23:59
191	31	created	\N	1	\N	1	2026-05-27 16:24:05
192	32	created	\N	1	\N	1	2026-05-27 16:24:14
193	33	created	\N	1	\N	1	2026-05-27 16:26:01
194	34	created	\N	1	\N	1	2026-05-27 16:26:06
195	32	assign_executor	1	2	\N	1	2026-05-27 16:27:57
196	32	status_change	2	3	\N	1	2026-05-27 16:28:07
197	28	status_change	2	3	\N	1	2026-05-27 16:28:10
198	35	created	\N	1	\N	1	2026-05-27 16:48:01
199	36	created_from_request	\N	1	Создана по заявке #20	1	2026-05-27 16:49:25
200	25	status_change	4	3	\N	1	2026-05-27 16:56:54
201	25	status_change	3	4	\N	1	2026-05-27 16:56:56
202	25	status_change	4	3	\N	1	2026-05-27 16:56:57
203	25	comment	\N	\N	123123	1	2026-05-27 16:57:06
204	25	comment	\N	\N	123123	1	2026-05-27 16:57:08
205	25	comment	\N	\N	123123123	1	2026-05-27 16:57:11
206	25	comment	\N	\N	123123123	1	2026-05-27 16:57:13
207	25	comment	\N	\N	123123123	1	2026-05-27 16:57:15
208	25	comment	\N	\N	123123123	1	2026-05-27 16:57:17
209	25	status_change	3	2	\N	1	2026-05-27 16:57:39
210	25	status_change	2	3	\N	1	2026-05-27 16:57:51
211	28	status_change	3	4	\N	1	2026-05-27 17:03:31
212	35	assign_executor	1	2	\N	1	2026-05-27 17:03:36
213	35	status_change	2	3	\N	1	2026-05-27 17:03:37
214	35	status_change	3	4	\N	1	2026-05-27 17:03:38
215	32	status_change	3	4	\N	1	2026-05-27 17:03:39
216	25	status_change	3	4	\N	1	2026-05-27 17:03:40
217	25	status_change	4	5	\N	1	2026-05-27 17:03:49
218	32	status_change	4	5	\N	1	2026-05-27 17:03:52
219	35	status_change	4	5	\N	1	2026-05-27 17:03:54
220	28	status_change	4	5	\N	1	2026-05-27 17:03:56
221	36	assign_executor	1	2	\N	1	2026-05-27 17:06:12
222	31	assign_executor	1	2	\N	1	2026-05-27 17:06:16
223	36	status_change	2	3	\N	1	2026-05-27 17:06:18
224	31	status_change	2	3	\N	1	2026-05-27 17:06:20
225	31	status_change	3	4	\N	1	2026-05-27 17:06:20
226	36	status_change	3	4	\N	1	2026-05-27 17:06:21
227	31	status_change	4	5	\N	1	2026-05-27 17:06:25
228	36	status_change	4	5	\N	1	2026-05-27 17:06:27
229	34	assign_executor	1	2	\N	1	2026-05-27 17:08:04
230	34	status_change	2	3	\N	1	2026-05-27 17:08:05
231	34	status_change	3	4	\N	1	2026-05-27 17:08:06
232	34	status_change	4	5	\N	1	2026-05-27 17:08:09
233	33	assign_executor	1	2	\N	1	2026-05-28 11:11:59
234	33	status_change	2	3	\N	1	2026-05-28 11:16:08
235	33	status_change	3	4	\N	1	2026-05-28 11:16:09
236	33	status_change	4	5	\N	1	2026-05-28 11:16:11
237	30	assign_executor	1	2	\N	1	2026-05-28 12:13:06
238	30	status_change	2	3	\N	1	2026-05-28 12:13:08
239	30	status_change	3	4	\N	1	2026-05-28 12:13:09
240	30	assign_executor	4	4	\N	1	2026-05-28 12:13:12
241	30	status_change	4	5	\N	1	2026-05-28 12:13:15
242	29	assign_executor	1	2	\N	1	2026-05-28 12:16:53
243	29	status_change	2	3	\N	1	2026-05-28 12:16:55
244	29	status_change	3	4	\N	1	2026-05-28 12:16:55
245	29	status_change	4	5	\N	1	2026-05-28 12:16:58
246	37	created	\N	2	\N	1	2026-05-28 12:18:19
247	37	status_change	2	3	\N	1	2026-05-28 12:18:21
248	37	status_change	3	4	\N	1	2026-05-28 12:18:22
249	37	status_change	4	5	\N	1	2026-05-28 12:18:25
250	38	created	\N	2	\N	1	2026-05-28 12:18:42
251	38	status_change	2	3	\N	1	2026-05-28 12:18:44
252	38	status_change	3	4	\N	1	2026-05-28 12:18:45
253	38	status_change	4	5	\N	1	2026-05-28 12:25:22
254	39	created	\N	1	\N	1	2026-05-28 12:26:52
255	40	created	\N	1	\N	1	2026-05-28 12:30:32
256	39	assign_executor	1	2	\N	1	2026-05-28 12:30:36
257	41	created	\N	2	\N	1	2026-05-28 12:30:47
258	39	status_change	2	3	\N	1	2026-05-28 12:30:49
259	42	created	\N	2	\N	1	2026-05-28 12:30:54
260	41	status_change	2	3	\N	1	2026-05-28 12:30:57
261	41	status_change	3	4	\N	1	2026-05-28 12:30:58
262	43	created_from_request	\N	1	Создана по заявке #21	1	2026-05-28 12:40:16
263	44	created_from_request	\N	1	Создана по заявке #22	1	2026-05-28 12:43:58
264	45	created_from_request	\N	1	Создана по заявке #23	14	2026-05-28 12:49:18
265	46	created_from_request	\N	1	Создана по заявке #24	1	2026-05-28 12:53:21
266	47	created_from_request	\N	1	Создана по заявке #25	1	2026-05-28 12:57:25
267	48	created_from_request	\N	1	Создана по заявке #26	21	2026-05-30 12:13:46
268	48	assign_executor	1	2	Назначен исполнитель из заявки #26	1	2026-05-30 12:14:08
269	48	status_change	2	3	\N	1	2026-05-30 12:14:47
270	48	status_change	3	4	\N	1	2026-05-30 12:15:02
271	48	status_change	4	5	\N	1	2026-05-30 12:15:17
272	47	deleted	1	\N	Задача удалена	1	2026-05-30 12:54:31
273	39	status_change	3	4	\N	1	2026-05-30 13:22:05
274	39	status_change	4	5	\N	1	2026-05-30 13:22:07
275	41	status_change	4	5	\N	1	2026-05-30 13:22:10
276	46	comment	\N	\N	Проверка	1	2026-05-30 13:49:35
277	46	assign_executor	1	2	\N	1	2026-05-30 13:49:40
278	46	assign_executor	2	2	Добавлен исполнитель: Рыбаков Руслан Анатольевич	1	2026-06-01 12:24:14
279	46	assign_executor	2	2	Добавлен исполнитель: Администратор	1	2026-06-01 12:27:49
280	46	assign_executor	2	2	Снят исполнитель: Кулаков Дмитрий Дмитриевич	1	2026-06-01 12:29:31
281	46	assign_executor	2	2	Снят исполнитель: Рыбаков Руслан Анатольевич	1	2026-06-01 12:30:48
282	42	assign_executor	2	2	Добавлен исполнитель: Рыбаков Руслан Анатольевич	1	2026-06-01 12:30:58
283	45	assign_executor	1	2	Назначен исполнитель из заявки #23	1	2026-06-01 12:31:12
284	46	assign_executor	2	2	Добавлен исполнитель: Кулаков Дмитрий Дмитриевич	1	2026-06-01 12:33:42
285	45	assign_executor	2	2	Добавлен исполнитель: Кулаков Дмитрий Дмитриевич	1	2026-06-01 12:42:56
286	49	created_from_request	\N	1	Создана по заявке #27	21	2026-06-01 12:45:10
287	49	assign_executor	1	2	Добавлен исполнитель: Кулаков Дмитрий Дмитриевич	1	2026-06-01 12:47:34
288	40	assign_executor	1	2	Взята в работу: Кулаков Дмитрий Дмитриевич	19	2026-06-01 12:51:43
289	40	status_change	1	3	\N	19	2026-06-01 12:51:43
290	43	assign_executor	1	2	Взята в работу: Кулаков Дмитрий Дмитриевич	19	2026-06-01 12:51:52
291	43	status_change	1	3	\N	19	2026-06-01 12:51:52
292	50	created	\N	1	\N	19	2026-06-01 12:54:00
293	50	assign_executor	1	2	Взята в работу: Кулаков Дмитрий Дмитриевич	19	2026-06-01 12:54:04
294	50	status_change	1	3	\N	19	2026-06-01 12:54:04
295	40	status_change	3	4	\N	19	2026-06-01 13:02:06
296	43	status_change	3	4	\N	19	2026-06-01 13:02:09
297	50	status_change	3	4	\N	19	2026-06-01 13:02:11
298	44	assign_executor	1	2	Назначен исполнитель из заявки #22	1	2026-06-01 13:02:27
299	51	created_from_request	\N	1	Создана по заявке #28	1	2026-06-01 13:02:56
300	51	assign_executor	1	2	Назначен исполнитель из заявки #28	1	2026-06-01 13:02:59
301	51	assign_executor	2	2	Взята в работу: Администратор	1	2026-06-01 13:03:15
302	51	status_change	2	3	\N	1	2026-06-01 13:03:15
303	46	status_change	2	3	\N	1	2026-06-01 13:05:41
304	51	assign_executor	3	3	Снят исполнитель: Администратор	1	2026-06-01 13:05:49
305	52	created	\N	1	\N	19	2026-06-01 13:07:48
306	46	status_change	3	4	\N	19	2026-06-01 13:08:10
307	44	comment	\N	\N	124124	19	2026-06-01 13:09:42
308	49	status_change	2	3	\N	19	2026-06-01 13:10:48
309	44	assign_executor	2	2	Добавлен исполнитель: Кулаков Дмитрий Дмитриевич	1	2026-06-01 13:11:26
310	49	assign_executor	3	3	Добавлен исполнитель: Администратор	1	2026-06-01 13:11:47
311	45	assign_executor	2	2	Добавлен исполнитель: Администратор	1	2026-06-01 13:11:57
312	44	assign_executor	2	2	Добавлен исполнитель: Администратор	1	2026-06-01 13:12:06
313	42	assign_executor	2	2	Добавлен исполнитель: Администратор	1	2026-06-01 13:12:14
314	45	status_change	2	3	\N	1	2026-06-01 13:12:18
315	51	status_change	3	4	\N	1	2026-06-01 13:12:22
316	49	status_change	3	4	\N	1	2026-06-01 13:12:25
317	45	status_change	3	4	\N	1	2026-06-01 13:12:27
318	46	status_change	4	5	\N	1	2026-06-01 13:12:32
319	42	status_change	2	3	\N	1	2026-06-01 13:12:34
320	44	status_change	2	3	\N	1	2026-06-01 13:12:38
321	44	status_change	3	4	\N	1	2026-06-01 13:12:39
322	42	status_change	3	4	\N	1	2026-06-01 13:12:40
323	50	status_change	4	5	\N	1	2026-06-01 13:12:45
324	43	status_change	4	5	\N	1	2026-06-01 13:12:47
325	40	status_change	4	5	\N	1	2026-06-01 13:12:49
326	51	status_change	4	5	\N	1	2026-06-01 13:12:52
327	49	status_change	4	5	\N	1	2026-06-01 13:12:53
328	45	status_change	4	5	\N	1	2026-06-01 13:12:56
329	44	status_change	4	5	\N	1	2026-06-01 13:12:58
330	42	status_change	4	5	\N	1	2026-06-01 13:13:00
331	52	deleted	1	\N	Задача удалена	1	2026-06-01 13:14:15
332	42	status_change	5	3	\N	1	2026-06-01 13:14:29
333	42	status_change	3	4	\N	1	2026-06-01 13:14:36
334	42	status_change	4	5	\N	1	2026-06-01 13:14:40
335	53	created_from_request	\N	1	Создана по заявке #29	19	2026-06-01 13:18:11
336	53	assign_executor	1	2	Взята в работу: Кулаков Дмитрий Дмитриевич	19	2026-06-01 13:18:19
337	53	status_change	1	3	\N	19	2026-06-01 13:18:19
338	53	status_change	3	4	\N	19	2026-06-01 13:18:23
339	54	created	\N	1	\N	19	2026-06-01 13:18:38
340	53	status_change	4	5	Массовое подтверждение руководителем	1	2026-06-01 13:18:57
341	54	assign_executor	1	2	Добавлен исполнитель: Кулаков Дмитрий Дмитриевич	1	2026-06-01 13:19:34
342	54	assign_executor	2	2	Добавлен исполнитель: Рыбаков Руслан Анатольевич	1	2026-06-01 13:19:37
343	54	status_change	2	3	\N	19	2026-06-01 13:20:05
344	55	created_from_request	\N	1	Создана по заявке #30	19	2026-06-01 13:20:27
345	56	created_from_request	\N	1	Создана по заявке #31	19	2026-06-01 13:27:12
346	57	created_from_request	\N	1	Создана по заявке #32	19	2026-06-01 13:27:41
347	58	created_from_request	\N	1	Создана по заявке #33	1	2026-06-01 16:19:43
348	54	status_change	3	4	\N	1	2026-06-01 16:36:19
349	54	status_change	4	5	Массовое подтверждение руководителем	1	2026-07-07 13:16:40
350	58	assign_executor	1	2	Взята в работу: Администратор	1	2026-07-07 13:16:45
351	58	status_change	1	3	\N	1	2026-07-07 13:16:45
352	57	assign_executor	1	2	Взята в работу: Администратор	1	2026-07-07 13:16:47
353	57	status_change	1	3	\N	1	2026-07-07 13:16:47
354	56	assign_executor	1	2	Взята в работу: Администратор	1	2026-07-07 13:16:49
355	56	status_change	1	3	\N	1	2026-07-07 13:16:49
356	55	assign_executor	1	2	Взята в работу: Администратор	1	2026-07-07 13:16:50
357	55	status_change	1	3	\N	1	2026-07-07 13:16:50
358	58	status_change	3	4	\N	1	2026-07-07 13:16:56
359	57	status_change	3	4	\N	1	2026-07-07 13:16:58
360	56	status_change	3	4	\N	1	2026-07-07 13:16:59
361	55	status_change	3	4	\N	1	2026-07-07 13:17:00
362	58	status_change	4	5	Массовое подтверждение руководителем	1	2026-07-07 13:17:02
363	57	status_change	4	5	Массовое подтверждение руководителем	1	2026-07-07 13:17:02
364	56	status_change	4	5	Массовое подтверждение руководителем	1	2026-07-07 13:17:02
365	55	status_change	4	5	Массовое подтверждение руководителем	1	2026-07-07 13:17:02
366	59	created_from_request	\N	1	Создана по заявке #34	1	2026-07-09 13:59:44
367	59	assign_executor	1	2	Взята в работу: Администратор	1	2026-07-09 14:00:34
368	59	status_change	1	3	\N	1	2026-07-09 14:00:34
369	59	status_change	3	4	\N	1	2026-07-09 14:39:25
370	59	status_change	4	5	\N	1	2026-07-09 14:39:42
371	60	created	\N	2	\N	24	2026-07-10 10:28:18
372	60	status_change	2	3	\N	24	2026-07-10 10:28:26
373	60	status_change	3	4	\N	24	2026-07-10 10:29:54
374	60	status_change	4	5	Массовое подтверждение руководителем	24	2026-07-10 10:30:01
375	61	created_from_request	\N	1	Создана по заявке #35	24	2026-07-10 10:46:29
376	61	assign_executor	1	2	Назначен исполнитель из заявки #35	24	2026-07-10 10:46:35
377	62	created_from_request	\N	1	Создана по заявке #36	24	2026-07-10 10:47:52
378	62	assign_executor	1	2	Назначен исполнитель из заявки #36	24	2026-07-10 10:47:55
379	63	created_from_request	\N	1	Создана по заявке #37	24	2026-07-10 10:48:13
380	63	assign_executor	1	2	Назначен исполнитель из заявки #37	24	2026-07-10 10:48:16
381	64	created_from_request	\N	1	Создана по заявке #38	24	2026-07-10 10:48:30
382	64	assign_executor	1	2	Назначен исполнитель из заявки #38	24	2026-07-10 10:48:32
383	63	status_change	2	3	\N	24	2026-07-10 10:48:53
384	63	status_change	3	2	\N	24	2026-07-10 10:48:55
385	61	assign_executor	2	1	Снят исполнитель: Крутов Алексей Михайлович	24	2026-07-10 10:49:20
386	61	assign_executor	1	2	Добавлен исполнитель: Шворнев Владислав Николаевич	24	2026-07-10 10:49:25
387	61	assign_executor	2	2	Добавлен исполнитель: Калугин Илья Игоревич	24	2026-07-10 10:49:30
388	61	status_change	2	3	\N	24	2026-07-10 10:49:34
389	63	status_change	2	3	\N	24	2026-07-10 10:49:46
390	63	status_change	3	2	\N	24	2026-07-10 10:49:48
391	63	status_change	2	3	\N	24	2026-07-10 10:49:53
392	63	status_change	3	4	\N	24	2026-07-10 10:50:15
393	63	status_change	4	5	Массовое подтверждение руководителем	24	2026-07-10 10:50:19
394	63	status_change	5	3	\N	24	2026-07-10 10:50:39
395	64	assign_executor	2	2	Добавлен исполнитель: Шворнев Владислав Николаевич	24	2026-07-10 10:50:53
396	64	assign_executor	2	2	Добавлен исполнитель: Кулаков Дмитрий Дмитриевич	24	2026-07-10 10:50:58
397	64	status_change	2	3	\N	24	2026-07-10 11:16:51
398	64	status_change	3	4	\N	24	2026-07-10 11:16:54
399	64	status_change	4	3	\N	24	2026-07-10 11:16:58
400	64	status_change	3	2	\N	24	2026-07-10 11:17:00
401	61	status_change	3	4	\N	24	2026-07-10 11:17:02
402	61	status_change	4	5	Массовое подтверждение руководителем	24	2026-07-10 11:17:06
403	61	status_change	5	3	\N	24	2026-07-10 11:17:25
404	64	assign_executor	2	2	Снят исполнитель: Шворнев Владислав Николаевич	24	2026-07-10 11:18:09
405	64	assign_executor	2	2	Снят исполнитель: Калугин Илья Игоревич	24	2026-07-10 11:18:10
406	64	assign_executor	2	1	Снят исполнитель: Кулаков Дмитрий Дмитриевич	24	2026-07-10 11:18:22
407	64	assign_executor	1	2	Добавлен исполнитель: Шворнев Владислав Николаевич	24	2026-07-10 11:18:26
408	64	status_change	2	3	\N	24	2026-07-10 11:18:29
409	65	created	\N	2	\N	24	2026-07-10 11:19:12
410	66	created_from_request	\N	1	Создана по заявке #39	25	2026-07-10 11:45:13
411	66	assign_executor	1	2	Взята в работу: Шворнев Владислав Николаевич	24	2026-07-10 11:46:56
412	66	status_change	1	3	\N	24	2026-07-10 11:46:56
413	66	status_change	3	4	\N	24	2026-07-10 11:47:10
414	66	status_change	4	3	\N	24	2026-07-10 11:47:20
415	66	status_change	3	2	\N	24	2026-07-10 11:47:26
416	64	status_change	3	4	\N	24	2026-07-10 11:54:52
417	64	status_change	4	5	Массовое подтверждение руководителем	24	2026-07-10 11:54:57
418	67	created_from_request	\N	1	Создана по заявке #40	25	2026-07-10 12:46:01
419	68	created_from_request	\N	1	Создана по заявке #41	25	2026-07-10 12:46:14
420	69	created_from_request	\N	1	Создана по заявке #42	25	2026-07-10 12:46:32
421	62	assign_executor	2	1	Снят исполнитель: Кулаков Дмитрий Дмитриевич	1	2026-07-10 14:07:26
422	62	assign_executor	1	2	Взята в работу: Администратор	1	2026-07-10 14:07:53
423	62	status_change	1	3	\N	1	2026-07-10 14:07:53
424	62	status_change	3	2	\N	1	2026-07-10 14:09:22
425	62	status_change	2	3	\N	1	2026-07-10 14:09:36
426	62	status_change	3	2	\N	1	2026-07-10 14:09:49
427	65	assign_executor	2	1	Снят исполнитель: Шворнев Владислав Николаевич	1	2026-07-10 14:17:26
428	65	assign_executor	1	2	Добавлен исполнитель: Администратор	1	2026-07-10 14:17:30
429	65	status_change	2	3	\N	1	2026-07-10 14:17:37
430	65	status_change	3	2	\N	1	2026-07-10 14:18:30
431	65	status_change	2	3	\N	1	2026-07-10 14:25:07
432	65	status_change	3	2	\N	1	2026-07-10 14:25:31
433	65	status_change	2	3	\N	1	2026-07-10 14:28:51
434	65	status_change	3	2	\N	1	2026-07-10 14:29:00
435	61	status_change	3	4	\N	1	2026-07-10 14:29:19
436	63	status_change	3	4	\N	1	2026-07-10 14:29:21
437	62	status_change	2	3	\N	1	2026-07-10 14:29:24
438	65	status_change	2	3	\N	1	2026-07-10 14:29:25
439	69	assign_executor	1	2	Взята в работу: Администратор	1	2026-07-10 14:29:26
440	69	status_change	1	3	\N	1	2026-07-10 14:29:26
441	62	status_change	3	2	\N	1	2026-07-10 14:29:42
442	65	status_change	3	2	\N	24	2026-07-10 14:29:48
443	61	status_change	4	3	\N	24	2026-07-10 14:29:50
444	66	status_change	2	3	\N	24	2026-07-10 14:30:15
445	69	status_change	3	4	\N	24	2026-07-10 14:30:23
446	63	status_change	4	3	\N	24	2026-07-10 14:30:33
447	67	assign_executor	1	2	Взята в работу: Шворнев Владислав Николаевич	24	2026-07-10 14:30:39
448	67	status_change	1	3	\N	24	2026-07-10 14:30:39
449	67	status_change	3	2	\N	24	2026-07-10 14:30:44
450	61	status_change	3	2	\N	24	2026-07-10 14:31:10
451	66	status_change	3	4	\N	1	2026-07-10 14:31:14
452	61	status_change	2	3	\N	24	2026-07-10 14:31:15
453	63	status_change	3	4	\N	1	2026-07-10 14:31:15
454	62	status_change	2	3	\N	1	2026-07-10 14:31:17
455	65	status_change	2	3	\N	1	2026-07-10 14:31:18
456	62	status_change	3	2	\N	24	2026-07-10 14:31:23
457	61	status_change	3	2	\N	24	2026-07-10 14:31:24
458	66	status_change	4	3	\N	24	2026-07-10 14:31:26
459	65	status_change	3	2	\N	24	2026-07-10 14:31:32
460	67	status_change	2	3	\N	24	2026-07-10 14:31:39
461	61	status_change	2	3	\N	24	2026-07-10 14:31:45
462	66	status_change	3	2	\N	24	2026-07-10 14:32:26
463	66	status_change	2	3	\N	24	2026-07-10 14:32:55
464	67	status_change	3	2	\N	24	2026-07-10 14:35:12
465	65	status_change	2	3	\N	1	2026-07-10 16:05:29
466	68	assign_executor	1	2	Назначен исполнитель из заявки #41	1	2026-07-14 11:37:01
467	69	status_change	4	5	Массовое подтверждение руководителем	1	2026-07-14 11:37:13
468	63	status_change	4	5	Массовое подтверждение руководителем	1	2026-07-14 11:37:13
469	65	status_change	3	2	\N	24	2026-07-14 14:13:50
\.


--
-- Data for Name: work_tasks; Type: TABLE DATA; Schema: tech_accounting; Owner: -
--

COPY tech_accounting.work_tasks (id, title, description, status_id, request_task_id, creator_id, executor_id, priority, submitted_at, confirmed_at, confirmed_by, is_deleted, created_at, updated_at, status_changed_at) FROM stdin;
14	Заявка #8	У Кости сгорел анус	5	\N	1	19	medium	2026-05-26 15:53:51	2026-05-26 15:53:57	1	t	2026-05-26 16:53:10	2026-05-27 11:05:46	2026-05-26 15:53:57
18	Заявка #12	321	4	\N	1	19	medium	2026-05-27 10:59:45	\N	\N	t	2026-05-27 11:59:17	2026-05-27 12:00:23	2026-05-27 10:59:45
3	Нет интернета	Нет интернета	3	\N	1	15	medium	\N	\N	\N	t	2026-05-26 14:54:32	2026-05-26 16:52:21	2026-05-26 15:21:21
1	Отремонтировать МФУ	фыа	3	\N	1	1	medium	\N	\N	\N	t	2026-05-26 14:49:33	2026-05-26 16:52:23	2026-05-26 14:50:23
2	Нет интернета	Нет интернета	3	\N	1	1	medium	\N	\N	\N	t	2026-05-26 14:54:31	2026-05-26 16:52:27	2026-05-26 14:46:43
4	123	123	1	\N	1	\N	medium	\N	\N	\N	t	2026-05-26 14:59:53	2026-05-26 15:02:00	2026-05-26 14:59:53
5	123	123	1	\N	1	\N	medium	\N	\N	\N	t	2026-05-26 14:59:53	2026-05-26 15:02:07	2026-05-26 14:59:53
16	Заявка #10	Спасите!!!!!	4	\N	14	19	medium	2026-05-26 16:15:35	\N	\N	t	2026-05-26 17:04:25	2026-05-27 11:05:50	2026-05-26 16:15:35
10	Заявка #4	Новая заявка	3	\N	1	15	medium	\N	\N	\N	t	2026-05-26 15:41:23	2026-05-26 16:52:30	2026-05-26 14:46:40
15	Заявка #9	Проблема	4	\N	1	15	medium	2026-05-26 15:55:00	\N	\N	t	2026-05-26 16:54:25	2026-05-27 11:05:57	2026-05-26 15:55:00
6	14124	124123	4	\N	1	15	medium	2026-05-26 15:21:24	\N	\N	t	2026-05-26 15:02:13	2026-05-26 16:52:33	2026-05-26 15:21:24
17	Заявка #11	Горштейн не справляется с убунтой	2	\N	1	19	medium	\N	\N	\N	t	2026-05-26 17:16:58	2026-05-27 11:06:04	2026-05-26 16:17:07
40	123	123	5	\N	1	19	medium	2026-06-01 12:02:06	2026-06-01 12:12:49	1	f	2026-05-28 12:30:32	2026-06-01 13:12:49	2026-06-01 12:12:49
34	123123213	21312312313	5	\N	1	19	medium	2026-05-27 16:08:06	2026-05-27 16:08:09	1	f	2026-05-27 16:26:06	2026-05-27 17:08:09	2026-05-27 16:08:09
9	414214124	124124214	5	\N	1	1	medium	2026-05-26 14:27:56	2026-05-26 14:28:01	1	t	2026-05-26 15:11:53	2026-05-26 16:52:45	2026-05-26 15:28:01
26	Заявка #18	1234124124	2	\N	1	15	medium	\N	\N	\N	t	2026-05-27 14:24:19	2026-05-27 15:57:55	2026-05-27 14:36:52
33	123123	123123123	5	\N	1	19	medium	2026-05-28 10:16:08	2026-05-28 10:16:10	1	f	2026-05-27 16:26:01	2026-05-28 11:16:11	2026-05-28 10:16:10
48	Заявка #26	У меня сломался принтер, спасите	5	\N	21	19	medium	2026-05-30 11:15:02	2026-05-30 11:15:17	1	f	2026-05-30 12:13:46	2026-05-30 12:15:17	2026-05-30 11:15:17
47	Заявка #25	123123	1	\N	1	\N	medium	\N	\N	\N	t	2026-05-28 12:57:25	2026-05-30 12:54:31	2026-05-28 11:57:25
45	Заявка #23	123123	5	\N	14	15	medium	2026-06-01 12:12:27	2026-06-01 12:12:56	1	f	2026-05-28 12:49:18	2026-06-01 13:12:56	2026-06-01 12:12:56
21	Заявка #15	4654544	1	\N	1	\N	medium	\N	\N	\N	t	2026-05-27 12:26:45	2026-05-27 12:30:07	2026-05-27 11:26:44
30	213	1231231232122222222222222222222222222222222222222222222222222222222222	5	\N	1	19	medium	2026-05-28 11:13:08	2026-05-28 11:13:14	1	f	2026-05-27 16:23:59	2026-05-28 12:13:15	2026-05-28 11:13:14
19	Заявка #13	12141242142214	5	\N	1	19	medium	2026-05-27 11:01:07	2026-05-27 11:01:13	1	t	2026-05-27 12:00:54	2026-05-27 13:34:52	2026-05-27 11:01:13
22	Заявка #16	123123123123	1	\N	1	\N	medium	\N	\N	\N	t	2026-05-27 12:30:32	2026-05-27 12:31:36	2026-05-27 11:30:31
44	Заявка #22	123213	5	\N	1	15	medium	2026-06-01 12:12:38	2026-06-01 12:12:58	1	f	2026-05-28 12:43:58	2026-06-01 13:12:58	2026-06-01 12:12:58
20	Заявка #14	24124124124214	5	\N	1	15	medium	2026-05-27 11:02:10	2026-05-27 11:02:13	1	t	2026-05-27 12:01:54	2026-05-27 13:34:56	2026-05-27 11:02:13
23	Заявка #17	цукуцкцукуцкуцкуцкц	1	\N	1	\N	medium	\N	\N	\N	t	2026-05-27 12:35:29	2026-05-27 12:36:03	2026-05-27 11:35:28
43	Заявка #21	123	5	\N	1	19	medium	2026-06-01 12:02:08	2026-06-01 12:12:47	1	f	2026-05-28 12:40:16	2026-06-01 13:12:47	2026-06-01 12:12:47
36	Заявка #20	2141241241241111111111111111111	5	\N	1	15	medium	2026-05-27 16:06:21	2026-05-27 16:06:26	1	f	2026-05-27 16:49:25	2026-05-27 17:06:27	2026-05-27 16:06:26
8	123124124	1241241	2	\N	1	1	medium	\N	\N	\N	t	2026-05-26 15:08:29	2026-05-26 16:52:14	2026-05-26 14:50:19
7	123	123	5	\N	1	15	medium	2026-05-26 14:11:29	2026-05-26 14:11:33	1	t	2026-05-26 15:03:10	2026-05-26 16:52:48	2026-05-26 15:11:33
13	Заявка #7	Проблема	3	\N	1	15	medium	\N	\N	\N	t	2026-05-26 16:09:27	2026-05-26 16:52:18	2026-05-26 15:51:29
12	Заявка #6	У Кости сгорел анус	5	\N	1	1	medium	2026-05-26 15:17:58	2026-05-26 15:18:10	1	t	2026-05-26 16:07:48	2026-05-26 16:52:38	2026-05-26 15:18:10
11	Заявка #5	Сломался компьютер	5	\N	1	1	medium	2026-05-26 14:54:11	2026-05-26 15:15:05	1	t	2026-05-26 15:52:31	2026-05-26 16:52:42	2026-05-26 15:15:05
29	1232131	123213	5	\N	1	19	medium	2026-05-28 11:16:55	2026-05-28 11:16:58	1	f	2026-05-27 16:23:50	2026-05-28 12:16:58	2026-05-28 11:16:58
27	Заявка #19	21412414	5	\N	1	19	medium	2026-05-27 13:28:44	2026-05-27 13:28:47	1	f	2026-05-27 14:24:25	2026-05-27 14:28:47	2026-05-27 13:28:47
52	777	777	1	\N	19	\N	medium	\N	\N	\N	t	2026-06-01 13:07:48	2026-06-01 13:14:15	2026-06-01 12:07:48
37	123123	2131231231	5	\N	1	19	medium	2026-05-28 11:18:21	2026-05-28 11:18:24	1	f	2026-05-28 12:18:19	2026-05-28 12:18:25	2026-05-28 11:18:24
42	123	123	5	\N	1	15	medium	2026-06-01 12:14:36	2026-06-01 12:14:40	1	f	2026-05-28 12:30:54	2026-06-01 13:14:40	2026-06-01 12:14:40
24	Проверка	123	5	\N	1	19	medium	2026-05-27 12:34:24	2026-05-27 12:34:43	1	t	2026-05-27 13:22:59	2026-05-27 13:34:59	2026-05-27 12:34:43
38	впвапв	вапвапвап	5	\N	1	15	medium	2026-05-28 11:18:45	2026-05-28 11:25:21	1	f	2026-05-28 12:18:42	2026-05-28 12:25:22	2026-05-28 11:25:21
39	213	123	5	\N	1	19	medium	2026-05-30 12:22:04	2026-05-30 12:22:07	1	f	2026-05-28 12:26:52	2026-05-30 13:22:07	2026-05-30 12:22:07
41	123	123	5	\N	1	15	medium	2026-05-28 11:30:57	2026-05-30 12:22:10	1	f	2026-05-28 12:30:47	2026-05-30 13:22:10	2026-05-30 12:22:10
25	123	123	5	\N	1	19	medium	2026-05-27 16:03:39	2026-05-27 16:03:49	1	f	2026-05-27 14:23:41	2026-05-27 17:03:49	2026-05-27 16:03:49
32	123123123123	123213123123123	5	\N	1	15	medium	2026-05-27 16:03:38	2026-05-27 16:03:51	1	f	2026-05-27 16:24:14	2026-05-27 17:03:52	2026-05-27 16:03:51
35	222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222	222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222	5	\N	1	19	medium	2026-05-27 16:03:38	2026-05-27 16:03:53	1	f	2026-05-27 16:48:01	2026-05-27 17:03:54	2026-05-27 16:03:53
28	123	123	5	\N	1	19	medium	2026-05-27 16:03:31	2026-05-27 16:03:56	1	f	2026-05-27 14:26:25	2026-05-27 17:03:56	2026-05-27 16:03:56
31	213123123123	213123123	5	\N	1	19	medium	2026-05-27 16:06:20	2026-05-27 16:06:24	1	f	2026-05-27 16:24:05	2026-05-27 17:06:25	2026-05-27 16:06:24
50	Проверка 2	1123123123	5	\N	19	19	medium	2026-06-01 12:02:11	2026-06-01 12:12:45	1	f	2026-06-01 12:54:00	2026-06-01 13:12:45	2026-06-01 12:12:45
66	Заявка #39	Спасите, умер системник, перевставлял провод - результат нулевой	3	39	25	24	medium	\N	\N	\N	f	2026-07-10 11:45:13	2026-07-10 14:32:55	2026-07-10 13:32:55
51	Заявка #28	57567567	5	\N	1	15	medium	2026-06-01 12:12:21	2026-06-01 12:12:51	1	f	2026-06-01 13:02:56	2026-06-01 13:12:52	2026-06-01 12:12:51
49	Заявка #27	Проверка	5	\N	21	19	medium	2026-06-01 12:12:24	2026-06-01 12:12:53	1	f	2026-06-01 12:45:10	2026-06-01 13:12:53	2026-06-01 12:12:53
46	Заявка #24	123123123	5	\N	1	1	medium	2026-06-01 12:08:10	2026-06-01 12:12:31	1	f	2026-05-28 12:53:21	2026-06-01 13:12:32	2026-06-01 12:12:31
67	Заявка #40	Сломался комп	2	40	25	24	medium	\N	\N	\N	f	2026-07-10 12:46:01	2026-07-10 14:35:12	2026-07-10 13:35:12
68	Заявка #41	4324234	2	41	25	15	medium	\N	\N	\N	f	2026-07-10 12:46:14	2026-07-14 11:37:01	2026-07-14 10:37:01
69	Заявка #42	65464	5	42	25	1	medium	2026-07-10 13:30:23	2026-07-14 10:37:12	1	f	2026-07-10 12:46:32	2026-07-14 11:37:13	2026-07-14 10:37:12
63	Заявка #37	Застрял диск в компьютере	5	37	24	24	medium	2026-07-10 13:31:14	2026-07-14 10:37:12	1	f	2026-07-10 10:48:13	2026-07-14 11:37:13	2026-07-14 10:37:12
65	Разбудите черепаху	Разбудите черепаху 112 кабинет	2	\N	24	1	medium	\N	\N	\N	f	2026-07-10 11:19:12	2026-07-14 14:13:50	2026-07-14 13:13:49
53	Заявка #29	Задача	5	\N	19	19	medium	2026-06-01 12:18:22	2026-06-01 12:18:57	1	f	2026-06-01 13:18:11	2026-06-01 13:18:57	2026-06-01 12:18:57
54	1231231	123123	5	\N	19	19	medium	2026-06-01 15:36:19	2026-07-07 12:16:40	1	f	2026-06-01 13:18:38	2026-07-07 13:16:40	2026-07-07 12:16:40
58	Заявка #33	123	5	\N	1	1	medium	2026-07-07 12:16:56	2026-07-07 12:17:02	1	f	2026-06-01 16:19:43	2026-07-07 13:17:02	2026-07-07 12:17:02
57	Заявка #32	34234234	5	\N	19	1	medium	2026-07-07 12:16:57	2026-07-07 12:17:02	1	f	2026-06-01 13:27:41	2026-07-07 13:17:02	2026-07-07 12:17:02
56	Заявка #31	123	5	\N	19	1	medium	2026-07-07 12:16:58	2026-07-07 12:17:02	1	f	2026-06-01 13:27:12	2026-07-07 13:17:02	2026-07-07 12:17:02
55	Заявка #30	Проверка	5	\N	19	1	medium	2026-07-07 12:16:59	2026-07-07 12:17:02	1	f	2026-06-01 13:20:27	2026-07-07 13:17:02	2026-07-07 12:17:02
64	Заявка #38	Черепаха уснула	5	\N	24	24	medium	2026-07-10 10:54:51	2026-07-10 10:54:57	24	f	2026-07-10 10:48:30	2026-07-10 11:54:57	2026-07-10 10:54:57
59	Заявка #34	Не работает МФУ	5	34	1	1	medium	2026-07-09 13:39:24	2026-07-09 13:39:42	1	f	2026-07-09 13:59:44	2026-07-09 14:39:42	2026-07-09 13:39:42
60	501к подключить принтер	Запросили принтер новому пользователю, служебка есть	5	\N	24	24	medium	2026-07-10 09:29:54	2026-07-10 09:30:00	24	f	2026-07-10 10:28:18	2026-07-10 10:30:01	2026-07-10 09:30:00
62	Заявка #36	НЕТ ИНТЕРНЕТА!	2	36	24	1	medium	\N	\N	\N	f	2026-07-10 10:47:52	2026-07-10 14:31:23	2026-07-10 13:31:22
61	Заявка #35	Помогите, сломался монитор!!	3	35	24	24	medium	\N	\N	\N	f	2026-07-10 10:46:29	2026-07-10 14:31:45	2026-07-10 13:31:45
\.


--
-- Name: audit_events_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.audit_events_id_seq', 759, true);


--
-- Name: desk_attachments_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.desk_attachments_id_seq', 12, true);


--
-- Name: dic_equipment_status_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.dic_equipment_status_id_seq', 6, true);


--
-- Name: dic_task_status_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.dic_task_status_id_seq', 8, true);


--
-- Name: dic_work_task_status_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.dic_work_task_status_id_seq', 6, true);


--
-- Name: equip_history_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.equip_history_id_seq', 461, true);


--
-- Name: equipment_attachments_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.equipment_attachments_id_seq', 7, true);


--
-- Name: equipment_deliveries_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.equipment_deliveries_id_seq', 11, true);


--
-- Name: equipment_delivery_attachments_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.equipment_delivery_attachments_id_seq', 1, false);


--
-- Name: equipment_delivery_lines_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.equipment_delivery_lines_id_seq', 8, true);


--
-- Name: equipment_delivery_units_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.equipment_delivery_units_id_seq', 80, true);


--
-- Name: equipment_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.equipment_id_seq', 145, true);


--
-- Name: equipment_import_logs_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.equipment_import_logs_id_seq', 1, false);


--
-- Name: equipment_links_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.equipment_links_id_seq', 84, true);


--
-- Name: equipment_software_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.equipment_software_id_seq', 1, false);


--
-- Name: equipment_types_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.equipment_types_id_seq', 10, true);


--
-- Name: import_errors_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.import_errors_id_seq', 1, false);


--
-- Name: import_runs_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.import_runs_id_seq', 1, false);


--
-- Name: license_attachments_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.license_attachments_id_seq', 1, false);


--
-- Name: licenses_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.licenses_id_seq', 1, true);


--
-- Name: locations_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.locations_id_seq', 14, true);


--
-- Name: nsi_change_log_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.nsi_change_log_id_seq', 1, false);


--
-- Name: part_char_values_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.part_char_values_id_seq', 406, true);


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

SELECT pg_catalog.setval('tech_accounting.software_id_seq', 1, true);


--
-- Name: spr_chars_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.spr_chars_id_seq', 28, true);


--
-- Name: spr_parts_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.spr_parts_id_seq', 16, true);


--
-- Name: task_attachments_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.task_attachments_id_seq', 5, true);


--
-- Name: task_equipment_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.task_equipment_id_seq', 5, true);


--
-- Name: task_history_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.task_history_id_seq', 168, true);


--
-- Name: tasks_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.tasks_id_seq', 42, true);


--
-- Name: user_equipment_cards_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.user_equipment_cards_id_seq', 22, true);


--
-- Name: user_roles_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.user_roles_id_seq', 508, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.users_id_seq', 25, true);


--
-- Name: work_task_attachments_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.work_task_attachments_id_seq', 1, false);


--
-- Name: work_task_comments_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.work_task_comments_id_seq', 18, true);


--
-- Name: work_task_executors_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.work_task_executors_id_seq', 61, true);


--
-- Name: work_task_history_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.work_task_history_id_seq', 469, true);


--
-- Name: work_tasks_id_seq; Type: SEQUENCE SET; Schema: tech_accounting; Owner: -
--

SELECT pg_catalog.setval('tech_accounting.work_tasks_id_seq', 69, true);


--
-- PostgreSQL database dump complete
--

