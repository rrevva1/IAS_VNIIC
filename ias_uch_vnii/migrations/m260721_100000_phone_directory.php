<?php

use yii\db\Migration;

/**
 * Отдельный телефонный справочник (вариант Б концепции).
 */
class m260721_100000_phone_directory extends Migration
{
    public function safeUp()
    {
        $this->createTable('phone_directory', [
            'id' => $this->primaryKey(),
            'entry_type' => $this->string(20)->notNull()->defaultValue('person'),
            'full_name' => $this->string(200)->notNull(),
            'position' => $this->string(100)->null(),
            'department' => $this->string(100)->null(),
            'room' => $this->string(50)->null(),
            'internal_phone' => $this->string(50)->null(),
            'external_phone' => $this->string(50)->null(),
            'user_id' => $this->integer()->null(),
            'is_published' => $this->boolean()->notNull()->defaultValue(true),
            'sort_order' => $this->integer()->notNull()->defaultValue(0),
            'created_at' => $this->timestamp()->null()->defaultExpression('CURRENT_TIMESTAMP'),
            'updated_at' => $this->timestamp()->null()->defaultExpression('CURRENT_TIMESTAMP'),
        ]);

        $this->createIndex('idx_phone_directory_published', 'phone_directory', 'is_published');
        $this->createIndex('idx_phone_directory_department', 'phone_directory', 'department');
        $this->createIndex('idx_phone_directory_internal_phone', 'phone_directory', 'internal_phone');
        $this->createIndex('idx_phone_directory_full_name', 'phone_directory', 'full_name');
        $this->createIndex('idx_phone_directory_entry_type', 'phone_directory', 'entry_type');
        $this->createIndex('idx_phone_directory_user_id', 'phone_directory', 'user_id', true);

        $this->addForeignKey(
            'fk_phone_directory_user',
            'phone_directory',
            'user_id',
            'users',
            'id',
            'SET NULL',
            'CASCADE'
        );

        // Служебные номера (заглушки)
        $this->batchInsert('phone_directory', [
            'entry_type', 'full_name', 'department', 'internal_phone', 'is_published', 'sort_order',
        ], [
            ['service', 'Приёмная', 'Администрация', null, true, 10],
            ['service', 'Охрана', 'Охрана', null, true, 20],
            ['service', 'АТС', 'ИТ', null, true, 30],
        ]);

        // Импорт из активных пользователей
        $this->execute("
            INSERT INTO phone_directory (
                entry_type, full_name, position, department, internal_phone,
                user_id, is_published, sort_order, created_at, updated_at
            )
            SELECT
                'person',
                u.full_name,
                u.position,
                u.department,
                u.phone,
                u.id,
                TRUE,
                100,
                CURRENT_TIMESTAMP,
                CURRENT_TIMESTAMP
            FROM users u
            WHERE COALESCE(u.is_deleted, FALSE) = FALSE
              AND COALESCE(u.is_active, TRUE) = TRUE
              AND NOT EXISTS (
                  SELECT 1 FROM phone_directory pd WHERE pd.user_id = u.id
              )
        ");
    }

    public function safeDown()
    {
        $this->dropForeignKey('fk_phone_directory_user', 'phone_directory');
        $this->dropTable('phone_directory');
    }
}
