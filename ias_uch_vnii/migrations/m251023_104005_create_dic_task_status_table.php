<?php

use yii\db\Migration;

/**
 * Handles the creation of table `{{%dic_task_status}}`.
 */
class m251023_104005_create_dic_task_status_table extends Migration
{
    /**
     * {@inheritdoc}
     */
    public function safeUp()
    {
        $this->createTable('{{%dic_task_status}}', [
            'id_status' => $this->primaryKey(),
            'status_name' => $this->string(50)->notNull(),
        ]);
        
        // Добавляем уникальный индекс
        $this->createIndex('idx-dic_task_status-status_name', 'dic_task_status', 'status_name', true);
    }

    /**
     * {@inheritdoc}
     */
    public function safeDown()
    {
        $this->dropTable('{{%dic_task_status}}');
    }
}
