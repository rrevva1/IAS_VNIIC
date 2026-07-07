<?php

use yii\db\Migration;

/**
 * Срок гарантии на строке поставки и вложения к документу поставки.
 */
class m260606_100000_delivery_warranty_and_attachments extends Migration
{
    public function safeUp()
    {
        $linesSchema = $this->db->getTableSchema('equipment_delivery_lines', true);
        if ($linesSchema !== null && !isset($linesSchema->columns['warranty_years'])) {
            $this->addColumn('equipment_delivery_lines', 'warranty_years', $this->decimal(4, 1)->null());
        }

        if ($this->db->getTableSchema('equipment_delivery_attachments', true) === null) {
            $this->createTable('equipment_delivery_attachments', [
                'id' => $this->primaryKey(),
                'delivery_id' => $this->integer()->notNull(),
                'attachment_id' => $this->bigInteger()->notNull(),
                'linked_by' => $this->integer()->null(),
                'linked_at' => $this->timestamp()->notNull()->defaultExpression('CURRENT_TIMESTAMP'),
            ]);
        }

        $this->addForeignKey(
            'fk_equipment_delivery_attachments_delivery',
            'equipment_delivery_attachments',
            'delivery_id',
            'equipment_deliveries',
            'id',
            'CASCADE',
            'CASCADE'
        );
        $this->addForeignKey(
            'fk_equipment_delivery_attachments_attachment',
            'equipment_delivery_attachments',
            'attachment_id',
            'desk_attachments',
            'id',
            'CASCADE',
            'CASCADE'
        );
        $this->addForeignKey(
            'fk_equipment_delivery_attachments_linked_by',
            'equipment_delivery_attachments',
            'linked_by',
            'users',
            'id',
            'SET NULL',
            'CASCADE'
        );

        $this->createIndex('idx_equipment_delivery_attachments_delivery', 'equipment_delivery_attachments', 'delivery_id');
        $this->createIndex(
            'idx_equipment_delivery_attachments_unique',
            'equipment_delivery_attachments',
            ['delivery_id', 'attachment_id'],
            true
        );
    }

    public function safeDown()
    {
        $this->dropTable('equipment_delivery_attachments');
        if ($this->db->getTableSchema('equipment_delivery_lines', true) !== null) {
            $this->dropColumn('equipment_delivery_lines', 'warranty_years');
        }
    }
}
