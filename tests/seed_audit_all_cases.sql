-- Тестовые данные журнала аудита: по 3–5 записей на каждый тип события, попадающий в журнал.
-- Соответствует вызовам AuditLog::log() в коде (TasksController, ArmController, UsersController, SoftwareController).
--
-- Запуск: psql -U postgres -d ias_vniic -f tests/seed_audit_all_cases.sql
-- Требуется: схема tech_accounting, таблица audit_events, в users есть хотя бы один пользователь.

SET search_path TO tech_accounting;

BEGIN;

-- Вспомогательная переменная: id первого пользователя как actor_id
DO $$
DECLARE
  aid BIGINT;
  t TIMESTAMPTZ;
  i INT;
  actions TEXT[] := ARRAY[
    'task.create', 'task.update', 'task.delete', 'task.change_status', 'task.assign_executor', 'task.update_comment',
    'attachment.delete',
    'equipment.create', 'equipment.update', 'equipment.reassign', 'equipment.archive',
    'user.password_reset',
    'software.create', 'software.update', 'software.delete',
    'license.create', 'license.update', 'license.delete',
    'equipment_software.create', 'equipment_software.delete'
  ];
  obj_types TEXT[] := ARRAY[
    'task', 'task', 'task', 'task', 'task', 'task',
    'attachment',
    'equipment', 'equipment', 'equipment', 'equipment',
    'user',
    'software', 'software', 'software',
    'license', 'license', 'license',
    'equipment_software', 'equipment_software'
  ];
  statuses TEXT[] := ARRAY['success', 'success', 'success', 'error', 'denied'];
BEGIN
  SELECT id INTO aid FROM users ORDER BY id LIMIT 1;
  IF aid IS NULL THEN
    RAISE EXCEPTION 'Нет пользователей в users. Создайте пользователя перед загрузкой аудита.';
  END IF;

  t := CURRENT_TIMESTAMP - INTERVAL '3 days';

  -- По каждому кейсу (action_type + object_type): 4–5 записей с разными result_status и датами
  FOR i IN 1..array_length(actions, 1) LOOP
    INSERT INTO audit_events (event_time, actor_id, action_type, object_type, object_id, result_status, payload, error_message)
    VALUES
      (t + (i * INTERVAL '1 hour') + INTERVAL '0 min', aid, actions[i], obj_types[i], '1', 'success',
       jsonb_build_object('seed', true, 'case', i, 'note', 'Пример успешной операции'), NULL),
      (t + (i * INTERVAL '1 hour') + INTERVAL '10 min', aid, actions[i], obj_types[i], '2', 'success',
       jsonb_build_object('seed', true, 'case', i), NULL),
      (t + (i * INTERVAL '1 hour') + INTERVAL '20 min', aid, actions[i], obj_types[i], '3', 'success',
       jsonb_build_object('seed', true), NULL),
      (t + (i * INTERVAL '1 hour') + INTERVAL '30 min', aid, actions[i], obj_types[i], '4', 'error',
       jsonb_build_object('seed', true, 'case', i), 'Тестовое сообщение об ошибке для кейса ' || actions[i]),
      (t + (i * INTERVAL '1 hour') + INTERVAL '40 min', aid, actions[i], obj_types[i], '5', 'denied',
       jsonb_build_object('seed', true, 'reason', 'Недостаточно прав'), NULL);
  END LOOP;

  -- Дополнительные примеры с осмысленным payload для части кейсов (ещё по 1–2 на кейс)
  INSERT INTO audit_events (event_time, actor_id, action_type, object_type, object_id, result_status, payload, error_message)
  VALUES
    -- task.change_status
    (t + INTERVAL '1 day', aid, 'task.change_status', 'task', '10', 'success', '{"status_id": 2, "seed": true}'::jsonb, NULL),
    (t + INTERVAL '1 day' + INTERVAL '1 hour', aid, 'task.change_status', 'task', '11', 'success', '{"status_id": 4, "seed": true}'::jsonb, NULL),
    -- task.assign_executor
    (t + INTERVAL '1 day' + INTERVAL '2 hours', aid, 'task.assign_executor', 'task', '12', 'success', '{"executor_id": 1, "seed": true}'::jsonb, NULL),
    -- equipment.reassign
    (t + INTERVAL '1 day' + INTERVAL '3 hours', aid, 'equipment.reassign', 'equipment', '7', 'success', '{"responsible_user_id": 1, "location_id": 1, "seed": true}'::jsonb, NULL),
    -- equipment.archive
    (t + INTERVAL '1 day' + INTERVAL '4 hours', aid, 'equipment.archive', 'equipment', '8', 'success', '{"archive_reason": "Списание по истечении срока", "seed": true}'::jsonb, NULL),
    -- license.create / update (с software_id)
    (t + INTERVAL '2 days', aid, 'license.create', 'license', '101', 'success', '{"software_id": 1, "seed": true}'::jsonb, NULL),
    (t + INTERVAL '2 days' + INTERVAL '1 hour', aid, 'license.update', 'license', '102', 'success', '{"software_id": 1, "seed": true}'::jsonb, NULL),
    -- equipment_software
    (t + INTERVAL '2 days' + INTERVAL '2 hours', aid, 'equipment_software.create', 'equipment_software', '1', 'success', '{"software_id": 1, "equipment_id": 1, "seed": true}'::jsonb, NULL),
    (t + INTERVAL '2 days' + INTERVAL '3 hours', aid, 'equipment_software.delete', 'equipment_software', '2', 'success', '{"software_id": 1, "equipment_id": 2, "seed": true}'::jsonb, NULL);
END $$;

COMMIT;

-- Проверка: количество записей по типам операций
-- SELECT action_type, object_type, result_status, COUNT(*) FROM audit_events WHERE payload->>'seed' = 'true' GROUP BY 1,2,3 ORDER BY 1,3;
