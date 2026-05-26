<?php

use yii\db\Migration;

/**
 * Комментарии к внутренним задачам (контекст выполнения).
 */
class m260526_190000_work_task_comments extends Migration
{
    public function safeUp()
    {
        $this->createTable('work_task_comments', [
            'id' => $this->bigPrimaryKey(),
            'work_task_id' => $this->bigInteger()->notNull(),
            'author_id' => $this->bigInteger()->notNull(),
            'body' => $this->text()->notNull(),
            'created_at' => $this->timestamp()->notNull()->defaultExpression('CURRENT_TIMESTAMP'),
        ]);

        $this->addForeignKey(
            'fk_work_task_comments_task',
            'work_task_comments',
            'work_task_id',
            'work_tasks',
            'id',
            'CASCADE',
            'CASCADE'
        );
        $this->addForeignKey(
            'fk_work_task_comments_author',
            'work_task_comments',
            'author_id',
            'users',
            'id',
            'RESTRICT',
            'CASCADE'
        );

        $this->createIndex('idx_work_task_comments_task', 'work_task_comments', 'work_task_id');
        $this->createIndex('idx_work_task_comments_created', 'work_task_comments', ['work_task_id', 'created_at']);
    }

    public function safeDown()
    {
        $this->dropTable('work_task_comments');
    }
}
