<?php

use yii\db\Migration;

/**
 * Категория заявки (в т.ч. актуализация телефонного справочника).
 */
class m260721_120000_tasks_request_category extends Migration
{
    public function safeUp()
    {
        $schema = $this->db->getTableSchema('tasks', true);
        if ($schema === null || isset($schema->columns['request_category'])) {
            return;
        }

        $this->addColumn('tasks', 'request_category', $this->string(50)->null());
        $this->createIndex('idx_tasks_request_category', 'tasks', 'request_category');
    }

    public function safeDown()
    {
        $schema = $this->db->getTableSchema('tasks', true);
        if ($schema === null || !isset($schema->columns['request_category'])) {
            return;
        }

        $this->dropIndex('idx_tasks_request_category', 'tasks');
        $this->dropColumn('tasks', 'request_category');
    }
}
