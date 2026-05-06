<?php

use yii\db\Migration;

class m260506_123000_add_equipment_links_user_cards_and_import_logs extends Migration
{
    public function safeUp()
    {
        if ($this->db->getTableSchema('equipment_links', true) === null) {
            $this->createTable('equipment_links', [
                'id' => $this->primaryKey(),
                'parent_equipment_id' => $this->integer()->notNull(),
                'child_equipment_id' => $this->integer()->notNull(),
                'link_type' => $this->string(32)->notNull(),
                'created_by' => $this->integer()->null(),
                'created_at' => $this->dateTime()->notNull()->defaultExpression('CURRENT_TIMESTAMP'),
                'updated_at' => $this->dateTime()->null(),
            ]);
        }

        $this->execute("
            CREATE UNIQUE INDEX IF NOT EXISTS uq_equipment_links_parent_child_type
            ON equipment_links (parent_equipment_id, child_equipment_id, link_type)
        ");
        $this->execute("CREATE INDEX IF NOT EXISTS idx_equipment_links_parent ON equipment_links (parent_equipment_id)");
        $this->execute("CREATE INDEX IF NOT EXISTS idx_equipment_links_child ON equipment_links (child_equipment_id)");
        $this->execute("CREATE INDEX IF NOT EXISTS idx_equipment_links_type ON equipment_links (link_type)");
        $this->addForeignKey(
            'fk_equipment_links_parent_equipment',
            'equipment_links',
            'parent_equipment_id',
            'equipment',
            'id',
            'CASCADE',
            'CASCADE'
        );
        $this->addForeignKey(
            'fk_equipment_links_child_equipment',
            'equipment_links',
            'child_equipment_id',
            'equipment',
            'id',
            'CASCADE',
            'CASCADE'
        );

        if ($this->db->getTableSchema('user_equipment_cards', true) === null) {
            $this->createTable('user_equipment_cards', [
                'id' => $this->primaryKey(),
                'user_id' => $this->integer()->notNull(),
                'is_signed' => $this->boolean()->notNull()->defaultValue(false),
                'signed_at' => $this->dateTime()->null(),
                'signed_by_admin_id' => $this->integer()->null(),
                'version_no' => $this->integer()->notNull()->defaultValue(1),
                'last_snapshot_hash' => $this->string(64)->null(),
                'created_at' => $this->dateTime()->notNull()->defaultExpression('CURRENT_TIMESTAMP'),
                'updated_at' => $this->dateTime()->null(),
            ]);
        }

        $this->execute("CREATE UNIQUE INDEX IF NOT EXISTS uq_user_equipment_cards_user_id ON user_equipment_cards (user_id)");
        $this->execute("CREATE INDEX IF NOT EXISTS idx_user_equipment_cards_is_signed ON user_equipment_cards (is_signed)");
        $this->addForeignKey(
            'fk_user_equipment_cards_user',
            'user_equipment_cards',
            'user_id',
            'users',
            'id',
            'CASCADE',
            'CASCADE'
        );
        $this->addForeignKey(
            'fk_user_equipment_cards_admin',
            'user_equipment_cards',
            'signed_by_admin_id',
            'users',
            'id',
            'SET NULL',
            'CASCADE'
        );

        if ($this->db->getTableSchema('equipment_import_logs', true) === null) {
            $this->createTable('equipment_import_logs', [
                'id' => $this->primaryKey(),
                'uploaded_by' => $this->integer()->null(),
                'file_name' => $this->string(255)->notNull(),
                'total_rows' => $this->integer()->notNull()->defaultValue(0),
                'valid_rows' => $this->integer()->notNull()->defaultValue(0),
                'error_rows' => $this->integer()->notNull()->defaultValue(0),
                'status' => $this->string(32)->notNull()->defaultValue('validated'),
                'payload_json' => $this->text()->null(),
                'created_at' => $this->dateTime()->notNull()->defaultExpression('CURRENT_TIMESTAMP'),
            ]);
        }

        $this->execute("CREATE INDEX IF NOT EXISTS idx_equipment_import_logs_created_at ON equipment_import_logs (created_at)");
        $this->execute("CREATE INDEX IF NOT EXISTS idx_equipment_import_logs_status ON equipment_import_logs (status)");
        $this->addForeignKey(
            'fk_equipment_import_logs_uploaded_by',
            'equipment_import_logs',
            'uploaded_by',
            'users',
            'id',
            'SET NULL',
            'CASCADE'
        );
    }

    public function safeDown()
    {
        $this->dropForeignKey('fk_equipment_import_logs_uploaded_by', 'equipment_import_logs');
        $this->dropTable('equipment_import_logs');

        $this->dropForeignKey('fk_user_equipment_cards_admin', 'user_equipment_cards');
        $this->dropForeignKey('fk_user_equipment_cards_user', 'user_equipment_cards');
        $this->dropTable('user_equipment_cards');

        $this->dropForeignKey('fk_equipment_links_child_equipment', 'equipment_links');
        $this->dropForeignKey('fk_equipment_links_parent_equipment', 'equipment_links');
        $this->dropTable('equipment_links');
    }
}

