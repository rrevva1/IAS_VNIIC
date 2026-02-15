<?php

use yii\db\Migration;

/**
 * Приведение к схеме дампа: убрать equipment_types, вернуть equipment.equipment_type (varchar).
 */
class m260215_120000_revert_to_dump_equipment_type extends Migration
{
    public function safeUp()
    {
        $schema = $this->db->getSchema()->getTableSchema('equipment');
        if (!$schema || !isset($schema->columns['equipment_type_id'])) {
            return;
        }
        $this->addColumn('equipment', 'equipment_type', $this->string(100)->null());
        $this->execute("
            UPDATE equipment e
            SET equipment_type = et.name
            FROM equipment_types et
            WHERE e.equipment_type_id = et.id
        ");
        $this->dropColumn('equipment', 'equipment_type_id');
        $this->dropTable('equipment_types');
    }

    public function safeDown()
    {
        // Повтор миграции m260215_100000_equipment_types при необходимости отката
        $this->createTable('equipment_types', [
            'id' => $this->primaryKey(),
            'name' => $this->string(100)->notNull(),
            'sort_order' => $this->integer()->notNull()->defaultValue(0),
            'is_archived' => $this->boolean()->notNull()->defaultValue(false),
            'created_at' => $this->timestamp()->defaultExpression('CURRENT_TIMESTAMP'),
            'updated_at' => $this->timestamp()->defaultExpression('CURRENT_TIMESTAMP'),
        ]);
        $this->execute('ALTER TABLE equipment_types ADD CONSTRAINT chk_equipment_types_name_not_empty CHECK (length(trim(name)) > 0)');
        $this->execute("
            INSERT INTO equipment_types (name, sort_order, is_archived, created_at, updated_at)
            SELECT t.name, t.rn::integer, false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
            FROM (
                SELECT TRIM(equipment_type) AS name, row_number() OVER (ORDER BY MIN(id)) AS rn
                FROM equipment
                WHERE equipment_type IS NOT NULL AND TRIM(equipment_type) <> ''
                GROUP BY TRIM(equipment_type)
            ) t
        ");
        $this->addColumn('equipment', 'equipment_type_id', $this->bigInteger()->null());
        $this->execute("
            UPDATE equipment e
            SET equipment_type_id = et.id
            FROM equipment_types et
            WHERE TRIM(e.equipment_type) = et.name
        ");
        $this->dropColumn('equipment', 'equipment_type');
    }
}
