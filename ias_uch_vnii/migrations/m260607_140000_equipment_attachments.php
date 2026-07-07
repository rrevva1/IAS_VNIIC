<?php

use yii\db\Migration;

/**
 * Фотографии техники (связь equipment ↔ desk_attachments).
 */
class m260607_140000_equipment_attachments extends Migration
{
    public function safeUp()
    {
        if ($this->db->getTableSchema('equipment_attachments', true) !== null) {
            return;
        }

        $this->createTable('equipment_attachments', [
            'id' => $this->primaryKey(),
            'equipment_id' => $this->integer()->notNull(),
            'attachment_id' => $this->bigInteger()->notNull(),
            'linked_by' => $this->integer()->null(),
            'linked_at' => $this->timestamp()->notNull()->defaultExpression('CURRENT_TIMESTAMP'),
        ]);

        $this->addForeignKey(
            'fk_equipment_attachments_equipment',
            'equipment_attachments',
            'equipment_id',
            'equipment',
            'id',
            'CASCADE',
            'CASCADE'
        );
        $this->addForeignKey(
            'fk_equipment_attachments_attachment',
            'equipment_attachments',
            'attachment_id',
            'desk_attachments',
            'id',
            'CASCADE',
            'CASCADE'
        );
        $this->addForeignKey(
            'fk_equipment_attachments_linked_by',
            'equipment_attachments',
            'linked_by',
            'users',
            'id',
            'SET NULL',
            'CASCADE'
        );

        $this->createIndex('idx_equipment_attachments_equipment', 'equipment_attachments', 'equipment_id');
        $this->createIndex(
            'idx_equipment_attachments_unique',
            'equipment_attachments',
            ['equipment_id', 'attachment_id'],
            true
        );
    }

    public function safeDown()
    {
        $this->dropTable('equipment_attachments');
    }
}
