<?php

use yii\db\Migration;

/**
 * Handles the creation of table `{{%users}}`.
 */
class m251022_193211_create_users_table extends Migration
{
    /**
     * {@inheritdoc}
     */
    public function safeUp()
    {
        $this->createTable('{{%users}}', [
            'id' => $this->primaryKey(),
            'fio' => $this->string(100)->notNull(),
            'email' => $this->string(100)->notNull(),
            'role_id' => $this->integer(),
            'password' => $this->string(100),
            'auth_key' => $this->string(32),
            'access_token' => $this->string(255),
            'password_reset_token' => $this->string(255),
        ]);
        
        // Добавляем индексы
        $this->createIndex('idx-users-email', 'users', 'email', true); // уникальный индекс
        $this->createIndex('idx-users-role_id', 'users', 'role_id');
        $this->createIndex('idx-users-auth_key', 'users', 'auth_key');
        $this->createIndex('idx-users-access_token', 'users', 'access_token');
        $this->createIndex('idx-users-password_reset_token', 'users', 'password_reset_token');
        
        // Добавляем внешний ключ
        $this->addForeignKey('fk-users-role_id', 'users', 'role_id', 'roles', 'id', 'SET NULL', 'CASCADE');
    }

    /**
     * {@inheritdoc}
     */
    public function safeDown()
    {
        $this->dropForeignKey('fk-users-role_id', 'users');
        $this->dropTable('{{%users}}');
    }
}
