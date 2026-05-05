<?php

use yii\db\Migration;

/**
 * Индексы для ускорения загрузки AG Grid по заявкам и вложениям.
 */
class m260505_090000_add_performance_indexes_for_tasks_grid extends Migration
{
    public function safeUp()
    {
        // tasks
        $this->execute('CREATE INDEX IF NOT EXISTS idx_tasks_requester_id ON tasks (requester_id)');
        $this->execute('CREATE INDEX IF NOT EXISTS idx_tasks_executor_id ON tasks (executor_id)');
        $this->execute('CREATE INDEX IF NOT EXISTS idx_tasks_status_id ON tasks (status_id)');
        $this->execute('CREATE INDEX IF NOT EXISTS idx_tasks_created_at ON tasks (created_at)');

        // task_attachments
        $this->execute('CREATE INDEX IF NOT EXISTS idx_task_attachments_task_id ON task_attachments (task_id)');
        $this->execute('CREATE INDEX IF NOT EXISTS idx_task_attachments_attachment_id ON task_attachments (attachment_id)');
        $this->execute('CREATE INDEX IF NOT EXISTS idx_task_attachments_task_attachment ON task_attachments (task_id, attachment_id)');
    }

    public function safeDown()
    {
        $this->execute('DROP INDEX IF EXISTS idx_task_attachments_task_attachment');
        $this->execute('DROP INDEX IF EXISTS idx_task_attachments_attachment_id');
        $this->execute('DROP INDEX IF EXISTS idx_task_attachments_task_id');

        $this->execute('DROP INDEX IF EXISTS idx_tasks_created_at');
        $this->execute('DROP INDEX IF EXISTS idx_tasks_status_id');
        $this->execute('DROP INDEX IF EXISTS idx_tasks_executor_id');
        $this->execute('DROP INDEX IF EXISTS idx_tasks_requester_id');
    }
}
