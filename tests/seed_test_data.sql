-- Наполнение БД ias_vniic (схема tech_accounting) тестовыми данными для проверки функционала.
-- Все тестовые записи имеют ID в диапазоне 900001+ (или привязаны к ним).
-- Удаление: см. tests/TEST_DATA_REGISTRY.md и tests/remove_test_data.sql
--
-- Запуск: psql -U postgres -d ias_vniic -f tests/seed_test_data.sql

SET search_path TO tech_accounting;

BEGIN;

-- ========== 1. Локации (15 записей, id 900001–900015) ==========
INSERT INTO locations (id, location_code, name, location_type, floor, description, is_archived)
VALUES
  (900001, 'SEED-L01', 'Тест. кабинет 101', 'кабинет', 1, 'Тестовая локация', false),
  (900002, 'SEED-L02', 'Тест. кабинет 102', 'кабинет', 1, NULL, false),
  (900003, 'SEED-L03', 'Тест. кабинет 201', 'кабинет', 2, NULL, false),
  (900004, 'SEED-L04', 'Тест. кабинет 202', 'кабинет', 2, NULL, false),
  (900005, 'SEED-L05', 'Тест. кабинет 301', 'кабинет', 3, NULL, false),
  (900006, 'SEED-L06', 'Тест. склад 1', 'склад', 0, 'Тестовый склад', false),
  (900007, 'SEED-L07', 'Тест. серверная', 'серверная', 1, NULL, false),
  (900008, 'SEED-L08', 'Тест. кабинет 302', 'кабинет', 3, NULL, false),
  (900009, 'SEED-L09', 'Тест. кабинет 401', 'кабинет', 4, NULL, false),
  (900010, 'SEED-L10', 'Тест. лаборатория', 'лаборатория', 2, NULL, false),
  (900011, 'SEED-L11', 'Тест. кабинет 402', 'кабинет', 4, NULL, false),
  (900012, 'SEED-L12', 'Тест. кабинет 501', 'кабинет', 5, NULL, false),
  (900013, 'SEED-L13', 'Тест. кабинет 502', 'кабинет', 5, NULL, false),
  (900014, 'SEED-L14', 'Тест. кабинет 601', 'кабинет', 6, NULL, false),
  (900015, 'SEED-L15', 'Тест. другое', 'другое', NULL, 'Прочее тест', false)
ON CONFLICT (id) DO NOTHING;

-- Переопределяем sequence для locations (чтобы следующие вставки не конфликтовали с 900001+)
SELECT setval('locations_id_seq', (SELECT COALESCE(MAX(id), 1) FROM locations));

-- ========== 2. Пользователи (15 записей, id 900001–900015) ==========
-- Пароль для всех тестовых: test123 (хеш MD5 для совместимости с текущим кодом — только для тестовой БД)
INSERT INTO users (id, username, full_name, position, department, email, password_hash, is_active, is_locked, is_deleted)
VALUES
  (900001, 'seed_user_01', 'Тестовый Пользователь 1', 'Специалист', 'Отдел теста', 'seed1@test.local', MD5('test123'), true, false, false),
  (900002, 'seed_user_02', 'Тестовый Пользователь 2', 'Специалист', 'Отдел теста', 'seed2@test.local', MD5('test123'), true, false, false),
  (900003, 'seed_user_03', 'Тестовый Пользователь 3', 'Инженер', 'Отдел теста', 'seed3@test.local', MD5('test123'), true, false, false),
  (900004, 'seed_user_04', 'Тестовый Пользователь 4', 'Инженер', 'Отдел теста', 'seed4@test.local', MD5('test123'), true, false, false),
  (900005, 'seed_user_05', 'Тестовый Пользователь 5', 'Менеджер', 'Отдел теста', 'seed5@test.local', MD5('test123'), true, false, false),
  (900006, 'seed_user_06', 'Тестовый Пользователь 6', 'Специалист', 'Отдел теста', 'seed6@test.local', MD5('test123'), true, false, false),
  (900007, 'seed_user_07', 'Тестовый Пользователь 7', 'Специалист', 'Отдел теста', 'seed7@test.local', MD5('test123'), true, false, false),
  (900008, 'seed_user_08', 'Тестовый Пользователь 8', 'Инженер', 'Отдел теста', 'seed8@test.local', MD5('test123'), true, false, false),
  (900009, 'seed_user_09', 'Тестовый Пользователь 9', 'Инженер', 'Отдел теста', 'seed9@test.local', MD5('test123'), true, false, false),
  (900010, 'seed_user_10', 'Тестовый Пользователь 10', 'Менеджер', 'Отдел теста', 'seed10@test.local', MD5('test123'), true, false, false),
  (900011, 'seed_user_11', 'Тестовый Пользователь 11', 'Специалист', 'Отдел теста', 'seed11@test.local', MD5('test123'), true, false, false),
  (900012, 'seed_user_12', 'Тестовый Пользователь 12', 'Специалист', 'Отдел теста', 'seed12@test.local', MD5('test123'), true, false, false),
  (900013, 'seed_user_13', 'Тестовый Пользователь 13', 'Инженер', 'Отдел теста', 'seed13@test.local', MD5('test123'), true, false, false),
  (900014, 'seed_user_14', 'Тестовый Пользователь 14', 'Оператор тест', 'Отдел теста', 'seed14@test.local', MD5('test123'), true, false, false),
  (900015, 'seed_user_15', 'Тестовый Админ', 'Администратор', 'Отдел теста', 'seed15@test.local', MD5('test123'), true, false, false)
ON CONFLICT (id) DO NOTHING;

SELECT setval('users_id_seq', (SELECT COALESCE(MAX(id), 1) FROM users));

-- Роли: привязка seed-пользователей к ролям (1–13: user, 14: operator, 15: admin)
INSERT INTO user_roles (user_id, role_id, is_active)
SELECT u.id, r.id, true
FROM users u
CROSS JOIN LATERAL (SELECT id FROM roles WHERE role_code = CASE WHEN u.username = 'seed_user_15' THEN 'admin' WHEN u.username = 'seed_user_14' THEN 'operator' ELSE 'user' END LIMIT 1) r
WHERE u.id BETWEEN 900001 AND 900015
ON CONFLICT (user_id, role_id, is_active) DO NOTHING;

-- ========== 3. Справочники частей и характеристик (id 900001–900010) ==========
INSERT INTO spr_parts (id, name, description, is_archived)
VALUES
  (900001, 'SEED Процессор', 'Тест: тип части ЦП', false),
  (900002, 'SEED ОЗУ', 'Тест: тип части ОЗУ', false),
  (900003, 'SEED Жесткий диск', 'Тест: тип части диск', false),
  (900004, 'SEED Монитор', 'Тест: тип части монитор', false),
  (900005, 'SEED ОС', 'Тест: тип части ОС', false),
  (900006, 'SEED Имя ПК', 'Тест: hostname', false),
  (900007, 'SEED IP-адрес', 'Тест: сетевой адрес', false),
  (900008, 'SEED Антивирус', 'Тест: антивирус', false),
  (900009, 'SEED Системный блок', 'Тест: модель СБ', false),
  (900010, 'SEED Поставщик', 'Тест: поставщик', false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO spr_chars (id, name, description, measurement_unit, is_archived)
VALUES
  (900001, 'SEED Модель', 'Тест: модель', NULL, false),
  (900002, 'SEED Объём ГБ', 'Тест: объём', 'ГБ', false),
  (900003, 'SEED Тип', 'Тест: тип', NULL, false),
  (900004, 'SEED Разрешение', 'Тест: разрешение', NULL, false),
  (900005, 'SEED Значение', 'Тест: значение', NULL, false),
  (900006, 'SEED Версия', 'Тест: версия', NULL, false),
  (900007, 'SEED Адрес', 'Тест: адрес', NULL, false),
  (900008, 'SEED Имя', 'Тест: имя', NULL, false),
  (900009, 'SEED Производитель', 'Тест: производитель', NULL, false),
  (900010, 'SEED Инв. номер', 'Тест: инв. номер', NULL, false)
ON CONFLICT (id) DO NOTHING;

SELECT setval('spr_parts_id_seq', (SELECT COALESCE(MAX(id), 1) FROM spr_parts));
SELECT setval('spr_chars_id_seq', (SELECT COALESCE(MAX(id), 1) FROM spr_chars));

-- ========== 4. Оборудование (20 записей, id 900001–900020) ==========
INSERT INTO equipment (id, inventory_number, serial_number, name, equipment_type, status_id, responsible_user_id, location_id, supplier, purchase_date, commissioning_date, warranty_until, description, is_archived, is_deleted)
SELECT
  n,
  'SEED-INV-' || LPAD(n::text, 3, '0'),
  'SEED-SN-' || n,
  'Тестовый ПК ' || n,
  CASE (n % 3) WHEN 0 THEN 'Системный блок' WHEN 1 THEN 'Ноутбук' ELSE 'Моноблок' END,
  (SELECT id FROM dic_equipment_status WHERE status_code = 'in_use' LIMIT 1),
  900001 + ((n - 900001) % 15),
  900001 + ((n - 900001) % 15),
  'ООО Тест-поставщик',
  CURRENT_DATE - (n * 30),
  CURRENT_DATE - (n * 20),
  CURRENT_DATE + 365,
  'Тестовое оборудование для проверки модуля АРМ',
  false,
  false
FROM generate_series(900001, 900020) AS n
ON CONFLICT (id) DO NOTHING;

SELECT setval('equipment_id_seq', (SELECT COALESCE(MAX(id), 1) FROM equipment));

-- ========== 5. part_char_values (25 записей: привязка оборудования к частям/характеристикам) ==========
INSERT INTO part_char_values (equipment_id, part_id, char_id, value_text, value_num, source)
SELECT e.id, p.id, c.id, 'SEED value ' || e.id || '-' || p.id || '-' || c.id, NULL, 'manual'
FROM equipment e
CROSS JOIN (SELECT id FROM spr_parts WHERE id BETWEEN 900001 AND 900003) p
CROSS JOIN (SELECT id FROM spr_chars WHERE id BETWEEN 900001 AND 900002) c
WHERE e.id BETWEEN 900001 AND 900005
LIMIT 25
ON CONFLICT (equipment_id, part_id, char_id) DO NOTHING;

-- ========== 6. Заявки (20 записей, id 900001–900020) ==========
INSERT INTO tasks (id, task_number, title, description, status_id, requester_id, executor_id, priority, due_at, is_deleted)
SELECT
  n,
  'SEED-T-' || LPAD((n - 900000)::text, 3, '0'),
  'Тестовая заявка ' || (n - 900000),
  'Описание тестовой заявки для проверки модуля Help Desk. Запись №' || (n - 900000),
  (SELECT id FROM dic_task_status ORDER BY sort_order LIMIT 1 OFFSET (n % 3)),
  900001 + ((n - 900001) % 15),
  CASE WHEN n % 4 = 0 THEN 900002 + ((n - 900001) % 14) ELSE NULL END,
  CASE (n % 4) WHEN 0 THEN 'high' WHEN 1 THEN 'medium' ELSE 'low' END,
  CURRENT_TIMESTAMP + ((n % 7) || ' days')::interval,
  false
FROM generate_series(900001, 900020) AS n
ON CONFLICT (id) DO NOTHING;

SELECT setval('tasks_id_seq', (SELECT COALESCE(MAX(id), 1) FROM tasks));

-- ========== 7. task_equipment (связь заявка–оборудование, 15 записей) ==========
INSERT INTO task_equipment (task_id, equipment_id, relation_type, is_primary)
SELECT 900001 + (i % 20), 900001 + (i % 20), 'related', (i % 2 = 0)
FROM generate_series(0, 14) i
ON CONFLICT (task_id, equipment_id) DO NOTHING;

-- ========== 8. equip_history (15 записей) ==========
INSERT INTO equip_history (equipment_id, event_type, old_value, new_value, changed_by, comment)
SELECT 900001 + (i % 20), 'create', NULL, '{"inventory_number":"SEED-INV-xxx"}'::jsonb, 900001, 'Тестовое событие истории'
FROM generate_series(0, 14) i;

-- ========== 9. task_history (10 записей) ==========
INSERT INTO task_history (task_id, field_name, old_value, new_value, changed_by, comment)
SELECT 900001 + (i % 20), 'status_id', '1', '2', 900001, 'Тестовое изменение статуса'
FROM generate_series(0, 9) i;

-- ========== 10. desk_attachments (5 записей, id 900001–900005) — заглушки для теста связей ==========
INSERT INTO desk_attachments (id, storage_path, original_name, file_extension, mime_type, size_bytes, uploaded_by)
VALUES
  (900001, 'seed/test1.txt', 'SEED-file-1.txt', 'txt', 'text/plain', 100, 900001),
  (900002, 'seed/test2.txt', 'SEED-file-2.txt', 'txt', 'text/plain', 200, 900001),
  (900003, 'seed/test3.pdf', 'SEED-file-3.pdf', 'pdf', 'application/pdf', 300, 900002),
  (900004, 'seed/test4.txt', 'SEED-file-4.txt', 'txt', 'text/plain', 150, 900002),
  (900005, 'seed/test5.txt', 'SEED-file-5.txt', 'txt', 'text/plain', 250, 900003)
ON CONFLICT (id) DO NOTHING;

SELECT setval('desk_attachments_id_seq', (SELECT COALESCE(MAX(id), 1) FROM desk_attachments));

INSERT INTO task_attachments (task_id, attachment_id, linked_by)
SELECT 900001 + (i % 5), 900001 + i, 900001
FROM generate_series(0, 4) i
ON CONFLICT (task_id, attachment_id) DO NOTHING;

-- ========== 11. ПО и лицензии (таблицы из миграции m260213_120000) ==========
-- Проверяем наличие таблиц (миграция могла не выполняться)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'tech_accounting' AND table_name = 'software') THEN
    INSERT INTO software (id, name, version)
    SELECT n, 'SEED-SW-' || (n - 900000), '1.0'
    FROM generate_series(900001, 900010) n
    ON CONFLICT (id) DO NOTHING;
    PERFORM setval('software_id_seq', (SELECT COALESCE(MAX(id), 1) FROM software));
  END IF;
END $$;

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'tech_accounting' AND table_name = 'licenses') THEN
    INSERT INTO licenses (software_id, valid_until, notes)
    SELECT 900001 + (i % 10), CURRENT_DATE + 365, 'Тестовая лицензия'
    FROM generate_series(0, 9) i;
  END IF;
END $$;

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'tech_accounting' AND table_name = 'equipment_software') THEN
    INSERT INTO equipment_software (equipment_id, software_id, installed_at)
    SELECT 900001 + (i % 20), 900001 + (i % 10), CURRENT_DATE - (i * 10)
    FROM generate_series(0, 14) i
    ON CONFLICT DO NOTHING;
  END IF;
END $$;

-- ========== 12. Аудит (15 записей) ==========
INSERT INTO audit_events (id, event_time, actor_id, action_type, object_type, object_id, result_status, payload)
SELECT 900001 + i, CURRENT_TIMESTAMP - (i || ' hours')::interval, 900001, 'seed_test_action', 'task', (900001 + i)::text, 'success', '{"seed": true}'::jsonb
FROM generate_series(0, 14) i
ON CONFLICT (id) DO NOTHING;

SELECT setval('audit_events_id_seq', (SELECT COALESCE(MAX(id), 1) FROM audit_events));

COMMIT;

-- Проверка: количество записей по таблицам (для справки)
-- SELECT 'locations' t, COUNT(*) FROM locations WHERE id BETWEEN 900001 AND 900015
-- UNION ALL SELECT 'users', COUNT(*) FROM users WHERE id BETWEEN 900001 AND 900015
-- UNION ALL SELECT 'equipment', COUNT(*) FROM equipment WHERE id BETWEEN 900001 AND 900020
-- UNION ALL SELECT 'tasks', COUNT(*) FROM tasks WHERE id BETWEEN 900001 AND 900020;
