<?php

use yii\db\Migration;

/**
 * Модуль «Задачи»: внутренние поручения руководителя исполнителям (связь с заявками Help Desk).
 */
class m260526_140000_work_tasks_module extends Migration
{
    public function safeUp()
    {
        $this->createTable('dic_work_task_status', [
            'id' => $this->primaryKey(),
            'status_code' => $this->string(50)->notNull()->unique(),
            'status_name' => $this->string(100)->notNull()->unique(),
            'sort_order' => $this->integer()->notNull()->defaultValue(0),
            'timeline_step' => $this->smallInteger()->notNull()->defaultValue(0),
            'is_final' => $this->boolean()->notNull()->defaultValue(false),
            'is_archived' => $this->boolean()->notNull()->defaultValue(false),
            'created_at' => $this->timestamp()->defaultExpression('CURRENT_TIMESTAMP'),
            'updated_at' => $this->timestamp()->defaultExpression('CURRENT_TIMESTAMP'),
        ]);

        $this->batchInsert('dic_work_task_status', [
            'status_code', 'status_name', 'sort_order', 'timeline_step', 'is_final', 'is_archived',
        ], [
            ['queue', 'Очередь', 10, 1, false, false],
            ['assigned', 'Назначена', 20, 2, false, false],
            ['in_progress', 'В работе', 30, 3, false, false],
            ['pending_review', 'Выполнена', 40, 4, false, false],
            ['done', 'Закрыта', 50, 5, true, false],
            ['cancelled', 'Отменена', 60, 0, true, false],
        ]);

        $this->createTable('work_tasks', [
            'id' => $this->bigPrimaryKey(),
            'title' => $this->string(250)->notNull(),
            'description' => $this->text()->notNull(),
            'status_id' => $this->bigInteger()->notNull(),
            'request_task_id' => $this->bigInteger()->null(),
            'creator_id' => $this->bigInteger()->notNull(),
            'executor_id' => $this->bigInteger()->null(),
            'priority' => $this->string(20)->notNull()->defaultValue('medium'),
            'submitted_at' => $this->timestamp()->null(),
            'confirmed_at' => $this->timestamp()->null(),
            'confirmed_by' => $this->bigInteger()->null(),
            'is_deleted' => $this->boolean()->notNull()->defaultValue(false),
            'created_at' => $this->timestamp()->notNull()->defaultExpression('CURRENT_TIMESTAMP'),
            'updated_at' => $this->timestamp()->notNull()->defaultExpression('CURRENT_TIMESTAMP'),
        ]);

        $this->addForeignKey(
            'fk_work_tasks_status',
            'work_tasks',
            'status_id',
            'dic_work_task_status',
            'id',
            'RESTRICT',
            'CASCADE'
        );
        $this->addForeignKey(
            'fk_work_tasks_request',
            'work_tasks',
            'request_task_id',
            'tasks',
            'id',
            'SET NULL',
            'CASCADE'
        );
        $this->addForeignKey(
            'fk_work_tasks_creator',
            'work_tasks',
            'creator_id',
            'users',
            'id',
            'RESTRICT',
            'CASCADE'
        );
        $this->addForeignKey(
            'fk_work_tasks_executor',
            'work_tasks',
            'executor_id',
            'users',
            'id',
            'SET NULL',
            'CASCADE'
        );
        $this->addForeignKey(
            'fk_work_tasks_confirmed_by',
            'work_tasks',
            'confirmed_by',
            'users',
            'id',
            'SET NULL',
            'CASCADE'
        );

        $this->createIndex('idx_work_tasks_status', 'work_tasks', 'status_id');
        $this->createIndex('idx_work_tasks_executor', 'work_tasks', 'executor_id');
        $this->createIndex('idx_work_tasks_request', 'work_tasks', 'request_task_id');

        $this->createTable('work_task_history', [
            'id' => $this->bigPrimaryKey(),
            'work_task_id' => $this->bigInteger()->notNull(),
            'event_type' => $this->string(50)->notNull(),
            'old_status_id' => $this->bigInteger()->null(),
            'new_status_id' => $this->bigInteger()->null(),
            'comment' => $this->text()->null(),
            'changed_by' => $this->bigInteger()->null(),
            'changed_at' => $this->timestamp()->notNull()->defaultExpression('CURRENT_TIMESTAMP'),
        ]);
        $this->addForeignKey(
            'fk_work_task_history_task',
            'work_task_history',
            'work_task_id',
            'work_tasks',
            'id',
            'CASCADE',
            'CASCADE'
        );
    }

    public function safeDown()
    {
        $this->dropTable('work_task_history');
        $this->dropTable('work_tasks');
        $this->dropTable('dic_work_task_status');
    }
}
