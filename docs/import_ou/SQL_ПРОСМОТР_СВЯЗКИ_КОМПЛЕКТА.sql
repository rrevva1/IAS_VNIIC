-- Просмотр связки «системный блок → мониторы / ИБП» в СУБД ias_vniic (схема tech_accounting).
-- Подставьте ФИО или часть ФИО вместо :user_name.

SET search_path TO tech_accounting;

-- 1) Комплекты по пользователю (основной отчёт)
SELECT
    u.full_name AS пользователь,
    p.id AS id_пк,
    p.inventory_number AS инв_номер_пк,
    p.name AS системный_блок,
    p.equipment_type AS тип_пк,
    loc.name AS помещение,
    l.link_type AS тип_связи,
    c.id AS id_компонента,
    c.inventory_number AS инв_номер_компонента,
    c.name AS компонент,
    c.equipment_type AS тип_компонента
FROM users u
JOIN equipment p ON p.responsible_user_id = u.id
LEFT JOIN locations loc ON loc.id = p.location_id
LEFT JOIN equipment_links l ON l.parent_equipment_id = p.id
LEFT JOIN equipment c ON c.id = l.child_equipment_id
WHERE COALESCE(u.is_deleted, false) = false
  AND u.full_name ILIKE '%' || :user_name || '%'   -- например: '%Андросова%'
  AND (
      COALESCE(p.equipment_type, '') ILIKE '%систем%'
      OR COALESCE(p.equipment_type, '') ILIKE '%ноутбук%'
      OR COALESCE(p.equipment_type, '') ILIKE '%моноблок%'
  )
ORDER BY p.inventory_number, l.link_type, c.inventory_number;

-- 2) Сводка: сколько мониторов и ИБП привязано к каждому ПК пользователя
SELECT
    u.full_name,
    p.inventory_number AS пк,
    p.name AS пк_название,
    COUNT(*) FILTER (WHERE l.link_type = 'monitor') AS мониторов_связано,
    COUNT(*) FILTER (WHERE l.link_type = 'ups') AS ибп_связано,
    string_agg(c.name || ' (' || c.inventory_number || ')', E'\n' ORDER BY c.inventory_number)
        FILTER (WHERE l.link_type = 'monitor') AS мониторы,
    string_agg(c.name || ' (' || c.inventory_number || ')', E'\n' ORDER BY c.inventory_number)
        FILTER (WHERE l.link_type = 'ups') AS ибп
FROM users u
JOIN equipment p ON p.responsible_user_id = u.id
LEFT JOIN equipment_links l ON l.parent_equipment_id = p.id
LEFT JOIN equipment c ON c.id = l.child_equipment_id
WHERE u.full_name ILIKE '%' || :user_name || '%'
  AND (
      COALESCE(p.equipment_type, '') ILIKE '%систем%'
      OR COALESCE(p.equipment_type, '') ILIKE '%ноутбук%'
      OR COALESCE(p.equipment_type, '') ILIKE '%моноблок%'
  )
GROUP BY u.full_name, p.id, p.inventory_number, p.name
ORDER BY p.inventory_number;

-- 3) Мониторы без связи с ПК (не должны быть у «полного» комплекта)
SELECT e.id, e.inventory_number, e.name, u.full_name AS ответственный_без_связи
FROM equipment e
LEFT JOIN users u ON u.id = e.responsible_user_id
WHERE COALESCE(e.equipment_type, '') = 'Монитор'
  AND NOT EXISTS (
      SELECT 1 FROM equipment_links el
      WHERE el.child_equipment_id = e.id AND el.link_type = 'monitor'
  )
ORDER BY e.inventory_number;
