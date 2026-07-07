<?php

use yii\db\Migration;

/**
 * Раздел «Поставки»: документы массового ввода техники на склад.
 */
class m260603_100000_equipment_deliveries extends Migration
{
    public function safeUp()
    {
        if ($this->db->getTableSchema('equipment_deliveries', true) === null) {
            $this->createTable('equipment_deliveries', [
                'id' => $this->primaryKey(),
                'name' => $this->string(200)->notNull(),
                'supplier' => $this->string(255)->null(),
                'delivery_date' => $this->date()->notNull(),
                'warehouse_location_id' => $this->integer()->notNull(),
                'status' => $this->string(16)->notNull()->defaultValue('draft'),
                'notes' => $this->text()->null(),
                'created_by' => $this->integer()->null(),
                'created_at' => $this->dateTime()->notNull()->defaultExpression('CURRENT_TIMESTAMP'),
                'updated_at' => $this->dateTime()->null(),
            ]);
        }

        $this->execute('CREATE INDEX IF NOT EXISTS idx_equipment_deliveries_status ON equipment_deliveries (status)');
        $this->execute('CREATE INDEX IF NOT EXISTS idx_equipment_deliveries_delivery_date ON equipment_deliveries (delivery_date)');
        $this->execute('CREATE INDEX IF NOT EXISTS idx_equipment_deliveries_supplier ON equipment_deliveries (supplier)');

        $this->addForeignKey(
            'fk_equipment_deliveries_warehouse_location',
            'equipment_deliveries',
            'warehouse_location_id',
            'locations',
            'id',
            'RESTRICT',
            'CASCADE'
        );
        $this->addForeignKey(
            'fk_equipment_deliveries_created_by',
            'equipment_deliveries',
            'created_by',
            'users',
            'id',
            'SET NULL',
            'CASCADE'
        );

        if ($this->db->getTableSchema('equipment_delivery_lines', true) === null) {
            $this->createTable('equipment_delivery_lines', [
                'id' => $this->primaryKey(),
                'delivery_id' => $this->integer()->notNull(),
                'equipment_type' => $this->string(100)->notNull(),
                'equipment_type_id' => $this->integer()->null(),
                'name' => $this->string(200)->notNull(),
                'quantity' => $this->integer()->notNull()->defaultValue(1),
                'description' => $this->text()->null(),
                'sort_order' => $this->integer()->notNull()->defaultValue(0),
                'created_at' => $this->dateTime()->notNull()->defaultExpression('CURRENT_TIMESTAMP'),
                'updated_at' => $this->dateTime()->null(),
            ]);
        }

        $this->execute('CREATE INDEX IF NOT EXISTS idx_equipment_delivery_lines_delivery ON equipment_delivery_lines (delivery_id)');

        $this->addForeignKey(
            'fk_equipment_delivery_lines_delivery',
            'equipment_delivery_lines',
            'delivery_id',
            'equipment_deliveries',
            'id',
            'CASCADE',
            'CASCADE'
        );

        if ($this->db->getTableSchema('equipment_delivery_units', true) === null) {
            $this->createTable('equipment_delivery_units', [
                'id' => $this->primaryKey(),
                'line_id' => $this->integer()->notNull(),
                'seq_no' => $this->integer()->notNull(),
                'internal_label' => $this->string(64)->notNull(),
                'serial_number' => $this->string(150)->null(),
                'inventory_number' => $this->string(100)->null(),
                'number_status' => $this->string(16)->notNull()->defaultValue('empty'),
                'equipment_id' => $this->integer()->null(),
                'created_at' => $this->dateTime()->notNull()->defaultExpression('CURRENT_TIMESTAMP'),
                'updated_at' => $this->dateTime()->null(),
            ]);
        }

        $this->execute('CREATE UNIQUE INDEX IF NOT EXISTS uq_equipment_delivery_units_internal_label ON equipment_delivery_units (internal_label)');
        $this->execute('CREATE UNIQUE INDEX IF NOT EXISTS uq_equipment_delivery_units_line_seq ON equipment_delivery_units (line_id, seq_no)');
        $this->execute('CREATE INDEX IF NOT EXISTS idx_equipment_delivery_units_equipment ON equipment_delivery_units (equipment_id)');
        $this->execute('CREATE INDEX IF NOT EXISTS idx_equipment_delivery_units_serial ON equipment_delivery_units (serial_number)');

        $this->addForeignKey(
            'fk_equipment_delivery_units_line',
            'equipment_delivery_units',
            'line_id',
            'equipment_delivery_lines',
            'id',
            'CASCADE',
            'CASCADE'
        );
        $this->addForeignKey(
            'fk_equipment_delivery_units_equipment',
            'equipment_delivery_units',
            'equipment_id',
            'equipment',
            'id',
            'SET NULL',
            'CASCADE'
        );

        $equipmentSchema = $this->db->getTableSchema('equipment', true);
        if ($equipmentSchema !== null && !isset($equipmentSchema->columns['delivery_id'])) {
            $this->addColumn('equipment', 'delivery_id', $this->integer()->null());
        }
        if ($equipmentSchema !== null && !isset($equipmentSchema->columns['delivery_unit_id'])) {
            $this->addColumn('equipment', 'delivery_unit_id', $this->integer()->null());
        }

        $this->execute('CREATE INDEX IF NOT EXISTS idx_equipment_delivery_id ON equipment (delivery_id)');
        $this->execute('CREATE UNIQUE INDEX IF NOT EXISTS uq_equipment_delivery_unit_id ON equipment (delivery_unit_id) WHERE delivery_unit_id IS NOT NULL');

        $this->addForeignKey(
            'fk_equipment_delivery_id',
            'equipment',
            'delivery_id',
            'equipment_deliveries',
            'id',
            'SET NULL',
            'CASCADE'
        );
        $this->addForeignKey(
            'fk_equipment_delivery_unit_id',
            'equipment',
            'delivery_unit_id',
            'equipment_delivery_units',
            'id',
            'SET NULL',
            'CASCADE'
        );
    }

    public function safeDown()
    {
        $this->dropForeignKey('fk_equipment_delivery_unit_id', 'equipment');
        $this->dropForeignKey('fk_equipment_delivery_id', 'equipment');
        $this->dropColumn('equipment', 'delivery_unit_id');
        $this->dropColumn('equipment', 'delivery_id');

        $this->dropTable('equipment_delivery_units');
        $this->dropTable('equipment_delivery_lines');
        $this->dropTable('equipment_deliveries');
    }
}
