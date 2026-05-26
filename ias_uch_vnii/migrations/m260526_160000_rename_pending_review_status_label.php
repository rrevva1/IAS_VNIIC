<?php

use yii\db\Migration;

/**
 * Переименование статуса pending_review: «На проверке» → «Выполнена».
 */
class m260526_160000_rename_pending_review_status_label extends Migration
{
    public function safeUp()
    {
        $this->update(
            'dic_work_task_status',
            ['status_name' => 'Выполнена'],
            ['status_code' => 'pending_review']
        );
    }

    public function safeDown()
    {
        $this->update(
            'dic_work_task_status',
            ['status_name' => 'На проверке'],
            ['status_code' => 'pending_review']
        );
    }
}
