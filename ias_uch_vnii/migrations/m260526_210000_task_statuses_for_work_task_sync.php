<?php

use yii\db\Migration;

/**
 * Статусы заявок для синхронизации с колонками внутренних задач.
 */
class m260526_210000_task_statuses_for_work_task_sync extends Migration
{
    public function safeUp()
    {
        $this->execute("
            INSERT INTO dic_task_status (status_code, status_name, sort_order, is_final, is_archived)
            VALUES ('executor_assigned', 'Назначен исполнитель', 15, false, false)
            ON CONFLICT (status_code) DO UPDATE
            SET status_name = EXCLUDED.status_name,
                sort_order = EXCLUDED.sort_order
        ");

        $this->update(
            'dic_task_status',
            ['status_name' => 'Выполнена'],
            ['status_code' => 'resolved']
        );
    }

    public function safeDown()
    {
        $this->update(
            'dic_task_status',
            ['status_name' => 'Решена'],
            ['status_code' => 'resolved']
        );

        $this->delete('dic_task_status', ['status_code' => 'executor_assigned']);
    }
}
