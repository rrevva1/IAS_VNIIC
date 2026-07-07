<?php

use yii\db\Migration;
use yii\db\Query;

/**
 * Удаление статуса «На складе»: учёт складской техники — по помещению (раздел «Склад»), не по статусу.
 */
class m260601_100000_remove_in_stock_equipment_status extends Migration
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

        $inStockId = (new Query())
            ->from('dic_equipment_status')
            ->select('id')
            ->where(['status_code' => 'in_stock'])
            ->scalar();

        if ($inStockId !== false && $inStockId !== null && $inUseId !== false && $inUseId !== null) {
            $this->update(
                'equipment',
                ['status_id' => (int) $inUseId],
                ['status_id' => (int) $inStockId]
            );
        }

        if ($inStockId !== false && $inStockId !== null) {
            $this->delete('dic_equipment_status', ['status_code' => 'in_stock']);
        }
    }

    public function safeDown()
    {
        if ($this->db->getTableSchema('dic_equipment_status', true) === null) {
            return;
        }

        $exists = (new Query())
            ->from('dic_equipment_status')
            ->where(['status_code' => 'in_stock'])
            ->exists($this->db);

        if (!$exists) {
            $this->insert('dic_equipment_status', [
                'status_code' => 'in_stock',
                'status_name' => 'На складе',
                'sort_order' => 20,
                'is_final' => false,
                'is_archived' => false,
            ]);
        }
    }
}
