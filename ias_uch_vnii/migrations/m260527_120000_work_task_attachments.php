<?php

use yii\db\Migration;

/**
 * Вложения внутренних задач (модуль «Задачи»).
 */
class m260527_120000_work_task_attachments extends Migration
{
    public function safeUp()
    {
        $this->createTable('work_task_attachments', [
            'id' => $this->bigPrimaryKey(),
            'work_task_id' => $this->bigInteger()->notNull(),
            'attachment_id' => $this->bigInteger()->notNull(),
            'linked_by' => $this->bigInteger()->null(),
            'linked_at' => $this->timestamp()->notNull()->defaultExpression('CURRENT_TIMESTAMP'),
        ]);

        $this->addForeignKey(
            'fk_work_task_attachments_task',
            'work_task_attachments',
            'work_task_id',
            'work_tasks',
            'id',
            'CASCADE',
            'CASCADE'
        );
        $this->addForeignKey(
            'fk_work_task_attachments_attachment',
            'work_task_attachments',
            'attachment_id',
            'desk_attachments',
            'id',
            'CASCADE',
            'CASCADE'
        );
        $this->addForeignKey(
            'fk_work_task_attachments_linked_by',
            'work_task_attachments',
            'linked_by',
            'users',
            'id',
            'SET NULL',
            'CASCADE'
        );

        $this->createIndex('idx_work_task_attachments_task', 'work_task_attachments', 'work_task_id');
        $this->createIndex('idx_work_task_attachments_attachment', 'work_task_attachments', 'attachment_id');
        $this->createIndex(
            'idx_work_task_attachments_task_attachment',
            'work_task_attachments',
            ['work_task_id', 'attachment_id'],
            true
        );
    }

    public function safeDown()
    {
        $this->dropTable('work_task_attachments');
    }
}
