<?php

use yii\db\Migration;

/**
 * Отключение архивирования техники: все записи возвращаются в активный учёт.
 */
class m260710_150000_remove_equipment_archiving extends Migration
{
    public function safeUp()
    {
        if ($this->db->getTableSchema('equipment', true) === null) {
            return;
        }

        $this->update('equipment', [
            'is_archived' => false,
            'archived_at' => null,
            'archive_reason' => null,
        ], ['is_archived' => true]);
    }

    public function safeDown()
    {
        // Не восстанавливаем архивные записи — данные необратимы без резервной копии.
    }
}
