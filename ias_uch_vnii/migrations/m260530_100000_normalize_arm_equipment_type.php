<?php

use yii\db\Migration;
use yii\db\Query;

/**
 * Тип «АРМ» не является отдельным активом; добавление недостающих типов в справочник.
 */
class m260530_100000_normalize_arm_equipment_type extends Migration
{
    private const CANONICAL_TYPES = [
        ['Системный блок', 10],
        ['Ноутбук', 20],
        ['Моноблок', 30],
        ['Монитор', 40],
        ['Принтер', 50],
        ['МФУ', 60],
        ['ИБП', 70],
        ['Сканер', 80],
        ['Сервер', 90],
    ];

    public function safeUp()
    {
        if ($this->db->getTableSchema('equipment_types', true) === null) {
            return;
        }

        $typeColumns = $this->db->getTableSchema('equipment_types', true)->columns;

        foreach (self::CANONICAL_TYPES as [$name, $sortOrder]) {
            $exists = (new Query())
                ->from('equipment_types')
                ->where(['name' => $name])
                ->exists($this->db);
            if ($exists) {
                continue;
            }

            $row = ['name' => $name];
            if (isset($typeColumns['sort_order'])) {
                $row['sort_order'] = $sortOrder;
            }
            if (isset($typeColumns['is_archived'])) {
                $row['is_archived'] = false;
            }
            $this->insert('equipment_types', $row);
        }

        $armId = (new Query())
            ->from('equipment_types')
            ->select('id')
            ->where(['name' => 'АРМ'])
            ->scalar($this->db);
        if ($armId === false) {
            return;
        }

        $systemBlockId = (new Query())
            ->from('equipment_types')
            ->select('id')
            ->where(['name' => 'Системный блок'])
            ->scalar($this->db);

        if ($systemBlockId !== false && $this->db->getTableSchema('equipment', true) !== null) {
            if (isset($this->db->getTableSchema('equipment')->columns['equipment_type_id'])) {
                $this->update(
                    'equipment',
                    ['equipment_type_id' => (int) $systemBlockId],
                    ['equipment_type_id' => (int) $armId]
                );
            } elseif (isset($this->db->getTableSchema('equipment')->columns['equipment_type'])) {
                $this->update(
                    'equipment',
                    ['equipment_type' => 'Системный блок'],
                    ['equipment_type' => 'АРМ']
                );
            }
        }

        $this->delete('equipment_types', ['id' => (int) $armId]);
    }

    public function safeDown()
    {
        echo "m260530_100000_normalize_arm_equipment_type cannot be reverted.\n";

        return false;
    }
}
