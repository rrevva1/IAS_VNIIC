<?php

use yii\db\Migration;
use yii\db\Query;

/**
 * Удаление статуса «В архиве»: архивация учитывается флагом equipment.is_archived, не статусом эксплуатации.
 */
class m260710_140000_remove_archived_equipment_status extends Migration
{
    public function safeUp()
    {
        if ($this->db->getTableSchema('dic_equipment_status', true) === null) {
            return;
        }

        $inUseId = (new Query())
            ->from('dic_equipment_status')
            ->select('id')
            ->where(['status_code' => 'in_use'])
            ->scalar();

        $archivedId = (new Query())
            ->from('dic_equipment_status')
            ->select('id')
            ->where(['status_code' => 'archived'])
            ->scalar();

        if ($archivedId !== false && $archivedId !== null && $inUseId !== false && $inUseId !== null) {
            $this->update(
                'equipment',
                ['status_id' => (int) $inUseId],
                ['status_id' => (int) $archivedId]
            );
        }

        if ($archivedId !== false && $archivedId !== null) {
            $this->delete('dic_equipment_status', ['status_code' => 'archived']);
        }
    }

    public function safeDown()
    {
        if ($this->db->getTableSchema('dic_equipment_status', true) === null) {
            return;
        }

        $exists = (new Query())
            ->from('dic_equipment_status')
            ->where(['status_code' => 'archived'])
            ->exists($this->db);

        if (!$exists) {
            $this->insert('dic_equipment_status', [
                'status_code' => 'archived',
                'status_name' => 'В архиве',
                'sort_order' => 50,
                'is_final' => true,
                'is_archived' => false,
            ]);
        }
    }
}
