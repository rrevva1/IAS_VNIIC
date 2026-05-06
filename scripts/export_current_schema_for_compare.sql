-- Вывод списка таблиц и столбцов текущей БД (схема tech_accounting) для сравнения с дампом.
-- Запуск: psql -U postgres -h localhost -p 5432 -d ias_vniic -f scripts/export_current_schema_for_compare.sql -o current_schema.txt
-- Сравните current_schema.txt с перечнем таблиц/столбцов из ias_vniic_14_02_26.sql.

SET search_path TO tech_accounting;

\echo '=== TABLES IN tech_accounting ==='
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'tech_accounting'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

\echo ''
\echo '=== COLUMNS PER TABLE (table_name, column_name, data_type, is_nullable) ==='
SELECT c.table_name, c.column_name, c.data_type, c.character_maximum_length, c.is_nullable
FROM information_schema.columns c
WHERE c.table_schema = 'tech_accounting'
ORDER BY c.table_name, c.ordinal_position;

\echo ''
\echo '=== SEQUENCES ==='
SELECT sequence_name
FROM information_schema.sequences
WHERE sequence_schema = 'tech_accounting'
ORDER BY sequence_name;

\echo ''
\echo '=== TRIGGERS ==='
SELECT event_object_table AS table_name, trigger_name, action_timing, event_manipulation
FROM information_schema.triggers
WHERE trigger_schema = 'tech_accounting'
ORDER BY event_object_table, trigger_name;
