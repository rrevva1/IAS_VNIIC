-- Удаление тестовых данных, созданных скриптом seed_test_data.sql.
-- Реестр и описание: tests/TEST_DATA_REGISTRY.md
--
-- Запуск: psql -U postgres -d ias_vniic -f tests/remove_test_data.sql

SET search_path TO tech_accounting;

BEGIN;

-- 1. Связи заявка–вложение
DELETE FROM task_attachments WHERE task_id BETWEEN 900001 AND 900020;

-- 2. Связи заявка–оборудование
DELETE FROM task_equipment WHERE task_id BETWEEN 900001 AND 900020;

-- 3. История заявок
DELETE FROM task_history WHERE task_id BETWEEN 900001 AND 900020;

-- 4. История оборудования
DELETE FROM equip_history WHERE equipment_id BETWEEN 900001 AND 900020;

-- 5. Значения характеристик оборудования
DELETE FROM part_char_values WHERE equipment_id BETWEEN 900001 AND 900020;

-- 6–8. ПО и лицензии (если таблицы есть)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'tech_accounting' AND table_name = 'equipment_software') THEN
    DELETE FROM equipment_software WHERE equipment_id BETWEEN 900001 AND 900020 OR software_id BETWEEN 900001 AND 900010;
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'tech_accounting' AND table_name = 'licenses') THEN
    DELETE FROM licenses WHERE software_id BETWEEN 900001 AND 900010;
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'tech_accounting' AND table_name = 'software') THEN
    DELETE FROM software WHERE id BETWEEN 900001 AND 900010;
  END IF;
END $$;

-- 9. Вложения (метаданные)
DELETE FROM desk_attachments WHERE id BETWEEN 900001 AND 900005;

-- 10. Аудит
DELETE FROM audit_events WHERE id BETWEEN 900001 AND 900015;

-- 11. Заявки
DELETE FROM tasks WHERE id BETWEEN 900001 AND 900020;

-- 12. Оборудование
DELETE FROM equipment WHERE id BETWEEN 900001 AND 900020;

-- 13. Роли пользователей
DELETE FROM user_roles WHERE user_id BETWEEN 900001 AND 900015;

-- 14. Пользователи
DELETE FROM users WHERE id BETWEEN 900001 AND 900015;

-- 15. Локации
DELETE FROM locations WHERE id BETWEEN 900001 AND 900015;

-- 16–17. Справочники частей и характеристик
DELETE FROM spr_parts WHERE id BETWEEN 900001 AND 900010;
DELETE FROM spr_chars WHERE id BETWEEN 900001 AND 900010;

-- Сброс последовательностей (чтобы новые записи не конфликтовали с освобождёнными ID)
SELECT setval('task_attachments_id_seq', (SELECT COALESCE(MAX(id), 1) FROM task_attachments));
SELECT setval('task_equipment_id_seq', (SELECT COALESCE(MAX(id), 1) FROM task_equipment));
SELECT setval('task_history_id_seq', (SELECT COALESCE(MAX(id), 1) FROM task_history));
SELECT setval('equip_history_id_seq', (SELECT COALESCE(MAX(id), 1) FROM equip_history));
SELECT setval('part_char_values_id_seq', (SELECT COALESCE(MAX(id), 1) FROM part_char_values));
SELECT setval('desk_attachments_id_seq', (SELECT COALESCE(MAX(id), 1) FROM desk_attachments));
SELECT setval('audit_events_id_seq', (SELECT COALESCE(MAX(id), 1) FROM audit_events));
SELECT setval('tasks_id_seq', (SELECT COALESCE(MAX(id), 1) FROM tasks));
SELECT setval('equipment_id_seq', (SELECT COALESCE(MAX(id), 1) FROM equipment));
SELECT setval('users_id_seq', (SELECT COALESCE(MAX(id), 1) FROM users));
SELECT setval('locations_id_seq', (SELECT COALESCE(MAX(id), 1) FROM locations));
SELECT setval('spr_parts_id_seq', (SELECT COALESCE(MAX(id), 1) FROM spr_parts));
SELECT setval('spr_chars_id_seq', (SELECT COALESCE(MAX(id), 1) FROM spr_chars));

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'tech_accounting' AND table_name = 'software') THEN
    PERFORM setval('software_id_seq', (SELECT COALESCE(MAX(id), 1) FROM software));
  END IF;
END $$;

COMMIT;
