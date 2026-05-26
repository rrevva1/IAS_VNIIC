<?php

use yii\db\Migration;

/**
 * Время входа задачи в текущий статус (колонку Kanban).
 */
class m260526_200000_add_work_tasks_status_changed_at extends Migration
{
    public function safeUp()
    {
        $this->addColumn('work_tasks', 'status_changed_at', $this->timestamp()->null());

        $this->execute("
            UPDATE work_tasks wt
            SET status_changed_at = COALESCE(
                (
                    SELECT h.changed_at
                    FROM work_task_history h
                    WHERE h.work_task_id = wt.id
                      AND h.new_status_id = wt.status_id
                    ORDER BY h.changed_at DESC
                    LIMIT 1
                ),
                wt.created_at
            )
        ");

        $this->alterColumn('work_tasks', 'status_changed_at', $this->timestamp()->notNull());
    }

    public function safeDown()
    {
        $this->dropColumn('work_tasks', 'status_changed_at');
    }
}
