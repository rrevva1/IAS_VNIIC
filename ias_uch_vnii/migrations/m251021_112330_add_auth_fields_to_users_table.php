<?php

use yii\db\Migration;

class m251021_112330_add_auth_fields_to_users_table extends Migration
{
    /**
     * {@inheritdoc}
     */
    public function safeUp()
    {
        $this->addColumn('users', 'auth_key', $this->string(32)->null());
        $this->addColumn('users', 'access_token', $this->string(255)->null());
        $this->addColumn('users', 'password_reset_token', $this->string(255)->null());
        
        // Добавляем индексы для производительности
        $this->createIndex('idx-users-auth_key', 'users', 'auth_key');
        $this->createIndex('idx-users-access_token', 'users', 'access_token');
        $this->createIndex('idx-users-password_reset_token', 'users', 'password_reset_token');
    }

    /**
     * {@inheritdoc}
     */
    public function safeDown()
    {
        $this->dropIndex('idx-users-password_reset_token', 'users');
        $this->dropIndex('idx-users-access_token', 'users');
        $this->dropIndex('idx-users-auth_key', 'users');
        
        $this->dropColumn('users', 'password_reset_token');
        $this->dropColumn('users', 'access_token');
        $this->dropColumn('users', 'auth_key');
    }

    /*
    // Use up()/down() to run migration code without a transaction.
    public function up()
    {

    }

    public function down()
    {
        echo "m251021_112330_add_auth_fields_to_users_table cannot be reverted.\n";

        return false;
    }
    */
}
