<?php

use yii\db\Migration;

/**
 * Несколько исполнителей у внутренней задачи.
 */
class m260531_100000_work_task_executors extends Migration
{
    public function safeUp()
    {
        $this->createTable('work_task_executors', [
            'id' => $this->bigPrimaryKey(),
            'work_task_id' => $this->bigInteger()->notNull(),
            'user_id' => $this->bigInteger()->notNull(),
            'created_at' => $this->dateTime()->notNull()->defaultExpression('CURRENT_TIMESTAMP'),
        ]);

        $this->createIndex('idx_work_task_executors_task', 'work_task_executors', 'work_task_id');
        $this->createIndex('idx_work_task_executors_user', 'work_task_executors', 'user_id');
        $this->createIndex(
            'uidx_work_task_executors_task_user',
            'work_task_executors',
            ['work_task_id', 'user_id'],
            true
        );

        $this->addForeignKey(
            'fk_work_task_executors_task',
            'work_task_executors',
            'work_task_id',
            'work_tasks',
            'id',
            'CASCADE',
            'CASCADE'
        );
        $this->addForeignKey(
            'fk_work_task_executors_user',
            'work_task_executors',
            'user_id',
            'users',
            'id',
            'CASCADE',
            'CASCADE'
        );

        $this->execute("
            INSERT INTO work_task_executors (work_task_id, user_id, created_at)
            SELECT wt.id, wt.executor_id, COALESCE(wt.updated_at, wt.created_at, CURRENT_TIMESTAMP)
            FROM work_tasks wt
            WHERE wt.executor_id IS NOT NULL
              AND wt.executor_id > 0
              AND wt.is_deleted = false
        ");
    }

    public function safeDown()
    {
        $this->dropForeignKey('fk_work_task_executors_user', 'work_task_executors');
        $this->dropForeignKey('fk_work_task_executors_task', 'work_task_executors');
        $this->dropTable('work_task_executors');
    }
}
