-- Наполнение журнала аудита (таблица audit_events) тестовыми записями.
-- Удаление: в таблице audit_events стоит триггер неизменяемости (UPDATE/DELETE запрещены).
-- Тестовые записи можно оставить или удалить вручную, отключив триггер (только для тестовой БД).
--
-- Запуск: psql -U postgres -d ias_vniic -f tests/seed_audit_only.sql

SET search_path TO tech_accounting;

BEGIN;

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

COMMIT;
