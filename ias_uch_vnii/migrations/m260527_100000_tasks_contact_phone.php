<?php

use yii\db\Migration;

/**
 * Телефон для обратной связи при создании заявки.
 */
class m260527_100000_tasks_contact_phone extends Migration
{
    public function safeUp()
    {
        $this->addColumn('tasks', 'contact_phone', $this->string(50)->null());
    }

    public function safeDown()
    {
        $this->dropColumn('tasks', 'contact_phone');
    }
}
