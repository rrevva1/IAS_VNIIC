<?php

use yii\db\Migration;

/**
 * Справочник типов оборудования (equipment_types).
 * Если в equipment есть столбец equipment_type (varchar), заполняем справочник
 * из уникальных значений и переходим на equipment_type_id.
 */
class m260215_100000_equipment_types extends Migration
{
    public function safeUp()
    {
        $table = 'equipment_types';
        $this->createTable($table, [
            'id' => $this->primaryKey(),
            'name' => $this->string(100)->notNull(),
            'sort_order' => $this->integer()->notNull()->defaultValue(0),
            'is_archived' => $this->boolean()->notNull()->defaultValue(false),
            'created_at' => $this->timestamp()->defaultExpression('CURRENT_TIMESTAMP'),
            'updated_at' => $this->timestamp()->defaultExpression('CURRENT_TIMESTAMP'),
        ]);
        $this->addCommentOnTable($table, 'Справочник типов оборудования');
        $this->execute('ALTER TABLE ' . $this->db->schema->getRawTableName($table) . ' ADD CONSTRAINT chk_equipment_types_name_not_empty CHECK (length(trim(name)) > 0)');

        // Если в equipment есть столбец equipment_type (текст) — заполняем справочник и переходим на equipment_type_id
        $schema = $this->db->getSchema()->getTableSchema('equipment');
        if ($schema && isset($schema->columns['equipment_type'])) {
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
        } else {
            // Минимальный набор типов для работы вкладок на странице АРМ
            $this->batchInsert($table, ['name', 'sort_order', 'is_archived'], [
                ['Системный блок', 1, false],
                ['Моноблок', 2, false],
                ['Монитор', 3, false],
                ['Ноутбук', 4, false],
            ]);
        }
    }

    public function safeDown()
    {
        $schema = $this->db->getSchema()->getTableSchema('equipment');
        if ($schema && isset($schema->columns['equipment_type_id'])) {
            $this->addColumn('equipment', 'equipment_type', $this->string(100)->null());
            $this->execute("
                UPDATE equipment e
                SET equipment_type = et.name
                FROM equipment_types et
                WHERE e.equipment_type_id = et.id
            ");
            $this->dropColumn('equipment', 'equipment_type_id');
        }
        $this->dropTable('equipment_types');
    }
}
