<?php

use yii\db\Migration;

class m251023_104012_update_tasks_table_add_executor_and_attachments extends Migration
{
    /**
     * {@inheritdoc}
     */
    public function safeUp()
    {
        // Добавляем поле исполнителя в таблицу tasks
        $this->addColumn('tasks', 'executor_id', $this->integer()->null()->comment('ID исполнителя'));
        
        // Создаем таблицу для вложений
        $this->createTable('desk_attachments', [
            'attach_id' => $this->primaryKey(),
            'path' => $this->string(500)->notNull()->comment('Путь к файлу'),
            'name' => $this->string(255)->notNull()->comment('Имя файла'),
            'extension' => $this->string(10)->notNull()->comment('Расширение файла'),
            'created_at' => $this->timestamp()->defaultExpression('CURRENT_TIMESTAMP')->comment('Дата создания'),
        ]);
        
        // Добавляем индексы для оптимизации
        $this->createIndex('idx_tasks_executor_id', 'tasks', 'executor_id');
        $this->createIndex('idx_desk_attachments_name', 'desk_attachments', 'name');
        
        // Добавляем внешние ключи
        $this->addForeignKey(
            'fk_tasks_executor_id',
            'tasks',
            'executor_id',
            'users',
            'id',
            'SET NULL',
            'CASCADE'
        );
    }

    /**
     * {@inheritdoc}
     */
    public function safeDown()
    {
        // Удаляем внешние ключи
        $this->dropForeignKey('fk_tasks_executor_id', 'tasks');
        
        // Удаляем индексы
        $this->dropIndex('idx_tasks_executor_id', 'tasks');
        $this->dropIndex('idx_desk_attachments_name', 'desk_attachments');
        
        // Удаляем таблицу вложений
        $this->dropTable('desk_attachments');
        
        // Удаляем добавленные колонки из таблицы tasks
        $this->dropColumn('tasks', 'executor_id');
    }

    /*
    // Use up()/down() to run migration code without a transaction.
    public function up()
    {

    }

    public function down()
    {
        echo "m251023_104012_update_tasks_table_add_executor_and_attachments cannot be reverted.\n";

        return false;
    }
    */
}
