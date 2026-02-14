-- Загрузка тестовых данных для проверки модулей «Журнал аудита» и «ПО и лицензии».
-- Соответствует данным из дампа ias_vniic_14_02_26.sql (аудит, ПО, лицензии — то, что не грузилось из ОУ).
--
-- Запуск: psql -U postgres -d ias_vniic -f tests/seed_audit_and_software_licenses.sql
-- Требуется: БД ias_vniic, схема tech_accounting, таблицы audit_events, software, licenses (миграция или восстановление из дампа).
-- В таблице users должен быть хотя бы один пользователь (actor_id=1 для записей аудита).

SET search_path TO tech_accounting;

BEGIN;

-- ========== 1. Журнал аудита (25 записей, как в дампе) ==========
INSERT INTO audit_events (event_time, actor_id, action_type, object_type, object_id, result_status, payload)
SELECT
  CURRENT_TIMESTAMP - (i || ' hours')::interval,
  (SELECT id FROM users ORDER BY id LIMIT 1),
  (ARRAY['task.create', 'task.update', 'task.view', 'user.login', 'user.view', 'equipment.view', 'equipment.update', 'attachment.upload'])[1 + (i % 8)],
  (ARRAY['task', 'task', 'task', 'user', 'user', 'equipment', 'equipment', 'attachment'])[1 + (i % 8)],
  (1 + (i % 20))::text,
  (ARRAY['success', 'success', 'success', 'error', 'denied'])[1 + (i % 5)],
  ('{"seed": true, "i": ' || i || '}')::jsonb
FROM generate_series(0, 24) i;

-- ========== 2. ПО (10 записей, id 900001–900010, как в дампе) ==========
INSERT INTO software (id, name, version)
VALUES
  (900001, 'Microsoft Windows 10 Pro', '21H2'),
  (900002, 'Microsoft Office', '2019'),
  (900003, 'Astra Linux', '1.7'),
  (900004, 'Kaspersky Endpoint Security', '12.3'),
  (900005, '1C:Предприятие', '8.3'),
  (900006, 'Adobe Acrobat Reader', 'DC'),
  (900007, 'Google Chrome', '120'),
  (900008, '7-Zip', '23.01'),
  (900009, 'VLC Media Player', '3.0'),
  (900010, 'SEED-SW-10', '1.0')
ON CONFLICT (id) DO NOTHING;

SELECT setval(pg_get_serial_sequence('software', 'id'), (SELECT COALESCE(MAX(id), 1) FROM software));

-- ========== 3. Лицензии (по одной на каждое ПО, как в дампе) ==========
DELETE FROM licenses WHERE software_id BETWEEN 900001 AND 900010;

INSERT INTO licenses (software_id, valid_until, notes)
SELECT id, CURRENT_DATE + 365 + (id % 180)::integer, 'Тестовая лицензия для проверки раздела'
FROM software
WHERE id BETWEEN 900001 AND 900010;

COMMIT;
