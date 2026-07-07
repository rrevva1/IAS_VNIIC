<?php

use yii\db\Migration;

/**
 * Склад и шаблон характеристик на строке поставки; склад в шапке необязателен.
 */
class m260605_100000_delivery_line_warehouse_chars extends Migration
{
    public function safeUp()
    {
        $linesSchema = $this->db->getTableSchema('equipment_delivery_lines', true);
        if ($linesSchema !== null && !isset($linesSchema->columns['warehouse_location_id'])) {
            $this->addColumn('equipment_delivery_lines', 'warehouse_location_id', $this->integer()->null());
            $this->addForeignKey(
                'fk_equipment_delivery_lines_warehouse',
                'equipment_delivery_lines',
                'warehouse_location_id',
                'locations',
                'id',
                'RESTRICT',
                'CASCADE'
            );
        }
        if ($linesSchema !== null && !isset($linesSchema->columns['char_template'])) {
            $this->addColumn('equipment_delivery_lines', 'char_template', $this->text()->null());
        }

        $delSchema = $this->db->getTableSchema('equipment_deliveries', true);
        if ($delSchema !== null && isset($delSchema->columns['warehouse_location_id'])
            && !$delSchema->columns['warehouse_location_id']->allowNull) {
            $this->alterColumn('equipment_deliveries', 'warehouse_location_id', $this->integer()->null());
        }

        $this->execute(
            'UPDATE equipment_delivery_lines l
             SET warehouse_location_id = d.warehouse_location_id
             FROM equipment_deliveries d
             WHERE l.delivery_id = d.id
               AND l.warehouse_location_id IS NULL
               AND d.warehouse_location_id IS NOT NULL'
        );
    }

    public function safeDown()
    {
        if ($this->db->getTableSchema('equipment_delivery_lines', true) !== null) {
            $this->dropForeignKey('fk_equipment_delivery_lines_warehouse', 'equipment_delivery_lines');
            $this->dropColumn('equipment_delivery_lines', 'warehouse_location_id');
            $this->dropColumn('equipment_delivery_lines', 'char_template');
        }
    }
}
