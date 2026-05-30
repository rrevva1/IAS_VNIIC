<?php

use yii\db\Migration;

/**
 * Номер помещения при создании заявки.
 */
class m260530_160000_tasks_room_number extends Migration
{
    public function safeUp()
    {
        $this->addColumn('tasks', 'room_number', $this->string(50)->null());
    }

    public function safeDown()
    {
        $this->dropColumn('tasks', 'room_number');
    }
}
