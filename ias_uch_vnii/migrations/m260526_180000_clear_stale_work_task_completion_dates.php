<?php

use yii\db\Migration;

/**
 * Сброс дат выполнения/закрытия у задач в активных статусах (после возврата на доработку).
 */
class m260526_180000_clear_stale_work_task_completion_dates extends Migration
{
    public function safeUp()
    {
        $this->execute("
            UPDATE work_tasks wt
            SET submitted_at = NULL,
                confirmed_at = NULL,
                confirmed_by = NULL
            FROM dic_work_task_status s
            WHERE wt.status_id = s.id
              AND wt.is_deleted = false
              AND s.status_code IN ('queue', 'assigned', 'in_progress', 'cancelled')
              AND (wt.submitted_at IS NOT NULL OR wt.confirmed_at IS NOT NULL)
        ");
    }

    public function safeDown()
    {
        echo "m260526_180000_clear_stale_work_task_completion_dates cannot be reverted.\n";

        return false;
    }
}
