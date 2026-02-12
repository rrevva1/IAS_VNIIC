<?php

use yii\db\Migration;

/**
 * Handles the creation of table `{{%roles}}`.
 */
class m251022_193200_create_roles_table extends Migration
{
    /**
     * {@inheritdoc}
     */
    public function safeUp()
    {
        $this->createTable('{{%roles}}', [
            'id' => $this->primaryKey(),
            'role_name' => $this->string(50)->notNull(),
        ]);
        
        // Добавляем уникальный индекс
        $this->createIndex('idx-roles-role_name', 'roles', 'role_name', true);
        
        // Добавляем базовые роли
        $this->insert('roles', ['role_name' => 'администратор']);
        $this->insert('roles', ['role_name' => 'пользователь']);
    }

    /**
     * {@inheritdoc}
     */
    public function safeDown()
    {
        $this->dropTable('{{%roles}}');
    }
}
