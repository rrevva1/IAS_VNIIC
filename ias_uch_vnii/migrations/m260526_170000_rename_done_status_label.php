<?php

use yii\db\Migration;

/**
 * Переименование статуса done: «Принята» → «Закрыта».
 */
class m260526_170000_rename_done_status_label extends Migration
{
    public function safeUp()
    {
        $this->update(
            'dic_work_task_status',
            ['status_name' => 'Закрыта'],
            ['status_code' => 'done']
        );
    }

    public function safeDown()
    {
        $this->update(
            'dic_work_task_status',
            ['status_name' => 'Принята'],
            ['status_code' => 'done']
        );
    }
}
