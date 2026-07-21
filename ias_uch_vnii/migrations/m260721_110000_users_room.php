<?php

use yii\db\Migration;

/**
 * Кабинет / помещение в профиле пользователя (самообслуживание справочника).
 */
class m260721_110000_users_room extends Migration
{
    public function safeUp()
    {
        $schema = $this->db->getTableSchema('users', true);
        if ($schema === null || isset($schema->columns['room'])) {
            return;
        }

        $this->addColumn('users', 'room', $this->string(50)->null());
    }

    public function safeDown()
    {
        $schema = $this->db->getTableSchema('users', true);
        if ($schema === null || !isset($schema->columns['room'])) {
            return;
        }

        $this->dropColumn('users', 'room');
    }
}
