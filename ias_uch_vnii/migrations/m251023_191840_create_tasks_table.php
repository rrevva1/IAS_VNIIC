<?php

use yii\db\Migration;

/**
 * Handles the creation of table `{{%tasks}}`.
 */
class m251023_191840_create_tasks_table extends Migration
{
    /**
     * {@inheritdoc}
     */
    public function safeUp()
    {
        $this->createTable('{{%tasks}}', [
            'id' => $this->primaryKey(),
            'id_status' => $this->integer()->notNull(),
            'description' => $this->text()->notNull(),
            'user_id' => $this->integer()->notNull(),
            'date' => $this->timestamp()->defaultExpression('CURRENT_TIMESTAMP'),
            'last_time_update' => $this->timestamp()->defaultExpression('CURRENT_TIMESTAMP'),
            'comment' => $this->text(),
            'attachments' => $this->text(),
        ]);
        
        // Добавляем индексы
        $this->createIndex('idx-tasks-id_status', 'tasks', 'id_status');
        $this->createIndex('idx-tasks-user_id', 'tasks', 'user_id');
        $this->createIndex('idx-tasks-date', 'tasks', 'date');
        
        // Добавляем внешние ключи
        $this->addForeignKey('fk-tasks-user_id', 'tasks', 'user_id', 'users', 'id', 'CASCADE', 'CASCADE');
    }

    /**
     * {@inheritdoc}
     */
    public function safeDown()
    {
        $this->dropForeignKey('fk-tasks-user_id', 'tasks');
        $this->dropTable('{{%tasks}}');
    }
}
