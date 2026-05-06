<?php

use yii\db\Migration;

/**
 * Индексы для ускорения загрузки AG Grid по «Учет ТС».
 *
 * Узкие места:
 * - part_char_values: выборка по id_arm/equipment_id и джойны на part_id/char_id
 * - equipment: базовые фильтры is_archived/is_deleted и фильтры по связующим полям
 */
class m260506_100000_add_performance_indexes_for_arm_equipment_grid extends Migration
{
    public function safeUp()
    {
        // part_char_values
        $schema = $this->db->getTableSchema('part_char_values', true);
        if ($schema) {
            if (isset($schema->columns['id_arm'])) {
                $this->execute('CREATE INDEX IF NOT EXISTS idx_part_char_values_id_arm ON part_char_values (id_arm)');
            }
            if (isset($schema->columns['equipment_id'])) {
                $this->execute('CREATE INDEX IF NOT EXISTS idx_part_char_values_equipment_id ON part_char_values (equipment_id)');
            }
            if (isset($schema->columns['part_id'])) {
                $this->execute('CREATE INDEX IF NOT EXISTS idx_part_char_values_part_id ON part_char_values (part_id)');
            }
            if (isset($schema->columns['char_id'])) {
                $this->execute('CREATE INDEX IF NOT EXISTS idx_part_char_values_char_id ON part_char_values (char_id)');
            }
        }

        // equipment
        $eqSchema = $this->db->getTableSchema('equipment', true);
        if ($eqSchema) {
            if (isset($eqSchema->columns['is_archived']) && isset($eqSchema->columns['is_deleted'])) {
                $this->execute('CREATE INDEX IF NOT EXISTS idx_equipment_is_archived_is_deleted ON equipment (is_archived, is_deleted)');
            }
            if (isset($eqSchema->columns['responsible_user_id'])) {
                $this->execute('CREATE INDEX IF NOT EXISTS idx_equipment_responsible_user_id ON equipment (responsible_user_id)');
            }
            if (isset($eqSchema->columns['location_id'])) {
                $this->execute('CREATE INDEX IF NOT EXISTS idx_equipment_location_id ON equipment (location_id)');
            }
            if (isset($eqSchema->columns['status_id'])) {
                $this->execute('CREATE INDEX IF NOT EXISTS idx_equipment_status_id ON equipment (status_id)');
            }
            if (isset($eqSchema->columns['equipment_type_id'])) {
                $this->execute('CREATE INDEX IF NOT EXISTS idx_equipment_equipment_type_id ON equipment (equipment_type_id)');
            }
        }
    }

    public function safeDown()
    {
        $this->execute('DROP INDEX IF EXISTS idx_part_char_values_char_id');
        $this->execute('DROP INDEX IF EXISTS idx_part_char_values_part_id');
        $this->execute('DROP INDEX IF EXISTS idx_part_char_values_equipment_id');
        $this->execute('DROP INDEX IF EXISTS idx_part_char_values_id_arm');

        $this->execute('DROP INDEX IF EXISTS idx_equipment_is_archived_is_deleted');
        $this->execute('DROP INDEX IF EXISTS idx_equipment_responsible_user_id');
        $this->execute('DROP INDEX IF EXISTS idx_equipment_location_id');
        $this->execute('DROP INDEX IF EXISTS idx_equipment_status_id');
        $this->execute('DROP INDEX IF EXISTS idx_equipment_equipment_type_id');
    }
}

