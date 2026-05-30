-- Снять уникальность инвентарного номера (малоценка: один номер ведомости — несколько единиц).
-- Выполнить в pgAdmin / psql на БД ias_vniic (один раз).

SET search_path TO tech_accounting;

ALTER TABLE equipment DROP CONSTRAINT IF EXISTS uq_equipment_inventory_number;
