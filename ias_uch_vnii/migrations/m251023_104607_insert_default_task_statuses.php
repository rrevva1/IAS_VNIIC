<?php

use yii\db\Migration;

class m251023_104607_insert_default_task_statuses extends Migration
{
    /**
     * {@inheritdoc}
     */
    public function safeUp()
    {
        // Вставляем стандартные статусы заявок
        $this->insert('dic_task_status', [
            'status_name' => 'Открыта'
        ]);
        
        $this->insert('dic_task_status', [
            'status_name' => 'В работе'
        ]);
        
        $this->insert('dic_task_status', [
            'status_name' => 'Отменено'
        ]);
        
        $this->insert('dic_task_status', [
            'status_name' => 'Завершено'
        ]);
    }

    /**
     * {@inheritdoc}
     */
    public function safeDown()
    {
        // Удаляем вставленные статусы
        $this->delete('dic_task_status', ['status_name' => 'Открыта']);
        $this->delete('dic_task_status', ['status_name' => 'В работе']);
        $this->delete('dic_task_status', ['status_name' => 'Отменено']);
        $this->delete('dic_task_status', ['status_name' => 'Завершено']);
    }

    /*
    // Use up()/down() to run migration code without a transaction.
    public function up()
    {

    }

    public function down()
    {
        echo "m251023_104607_insert_default_task_statuses cannot be reverted.\n";

        return false;
    }
    */
}
