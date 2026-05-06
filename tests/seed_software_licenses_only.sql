-- Наполнение только таблиц ПО и лицензий (модуль «ПО и лицензии»).
-- Таблицы software и licenses должны существовать (миграция m260213_120000_add_software_licenses).
--
-- Запуск: psql -U postgres -d ias_vniic -f tests/seed_software_licenses_only.sql
-- Удаление этих данных: tests/remove_test_data.sql (блоки software/licenses) или см. TEST_DATA_REGISTRY.md

SET search_path TO tech_accounting;

BEGIN;

-- Программное обеспечение (10 записей, id 900001–900010)
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

-- Лицензии (срок действия по каждому ПО) — удаляем старые тестовые, чтобы не дублировать
DELETE FROM licenses WHERE software_id BETWEEN 900001 AND 900010;

INSERT INTO licenses (software_id, valid_until, notes)
SELECT id, CURRENT_DATE + 365 + (id % 180)::integer, 'Тестовая лицензия для проверки раздела'
FROM software
WHERE id BETWEEN 900001 AND 900010;

COMMIT;
