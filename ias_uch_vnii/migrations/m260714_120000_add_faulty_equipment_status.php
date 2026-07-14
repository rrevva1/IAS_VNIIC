<?php

use yii\db\Migration;
use yii\db\Query;

/**
 * Статус «Неисправен»: техника не подлежит ремонту или ремонт экономически нецелесообразен.
 */
class m260714_120000_add_faulty_equipment_status extends Migration
{
    public function safeUp()
    {
        if ($this->db->getTableSchema('dic_equipment_status', true) === null) {
            return;
        }

        $exists = (new Query())
            ->from('dic_equipment_status')
            ->where(['status_code' => 'faulty'])
            ->exists($this->db);

        if ($exists) {
            return;
        }

        $maxSort = (new Query())
            ->from('dic_equipment_status')
            ->max('sort_order');
        $sortOrder = $maxSort !== null && $maxSort !== false
            ? ((int) $maxSort + 10)
            : 35;

        $this->insert('dic_equipment_status', [
            'status_code' => 'faulty',
            'status_name' => 'Неисправен',
            'sort_order' => $sortOrder,
            'is_final' => false,
            'is_archived' => false,
        ]);
    }

    public function safeDown()
    {
        if ($this->db->getTableSchema('dic_equipment_status', true) === null) {
            return;
        }

        $faultyId = (new Query())
            ->from('dic_equipment_status')
            ->select('id')
            ->where(['status_code' => 'faulty'])
            ->scalar();

        if ($faultyId === false || $faultyId === null) {
            return;
        }

        $inUseId = (new Query())
            ->from('dic_equipment_status')
            ->select('id')
            ->where(['status_code' => 'in_use'])
            ->scalar();

        if ($inUseId !== false && $inUseId !== null) {
            $this->update(
                'equipment',
                ['status_id' => (int) $inUseId],
                ['status_id' => (int) $faultyId]
            );
        }

        $this->delete('dic_equipment_status', ['status_code' => 'faulty']);
    }
}
