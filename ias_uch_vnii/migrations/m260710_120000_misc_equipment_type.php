<?php

use yii\db\Migration;
use yii\db\Query;

/**
 * Тип техники «Прочее» и характеристика «Описание» (часть «Прочее»).
 */
class m260710_120000_misc_equipment_type extends Migration
{
    private const TYPE_NAME = 'Прочее';

    private const PART_NAME = 'Прочее';

    private const CHAR_NAME = 'Описание';

    public function safeUp()
    {
        if ($this->db->getTableSchema('equipment_types', true)) {
            $exists = (new Query())
                ->from('equipment_types')
                ->where(['name' => self::TYPE_NAME])
                ->exists($this->db);
            if (!$exists) {
                $row = ['name' => self::TYPE_NAME];
                $columns = $this->db->getTableSchema('equipment_types', true)->columns;
                if (isset($columns['sort_order'])) {
                    $row['sort_order'] = 100;
                }
                if (isset($columns['is_archived'])) {
                    $row['is_archived'] = false;
                }
                $this->insert('equipment_types', $row);
            }
        }

        if ($this->db->getTableSchema('spr_parts', true)) {
            $partExists = (new Query())
                ->from('spr_parts')
                ->where(['name' => self::PART_NAME])
                ->exists($this->db);
            if (!$partExists) {
                $this->insert('spr_parts', [
                    'name' => self::PART_NAME,
                    'description' => 'Прочая техника',
                    'is_archived' => false,
                ]);
            }
        }

        if (!$this->db->getTableSchema('spr_chars', true)) {
            return;
        }

        $charExists = (new Query())
            ->from('spr_chars')
            ->where(['name' => self::CHAR_NAME])
            ->exists($this->db);

        if ($charExists) {
            return;
        }

        $this->insert('spr_chars', [
            'name' => self::CHAR_NAME,
            'description' => 'Описание прочей техники',
            'measurement_unit' => null,
            'is_archived' => false,
        ]);
    }

    public function safeDown()
    {
        if ($this->db->getTableSchema('spr_chars', true)) {
            $this->delete('spr_chars', ['name' => self::CHAR_NAME]);
        }

        if ($this->db->getTableSchema('spr_parts', true)) {
            $partId = (new Query())
                ->select('id')
                ->from('spr_parts')
                ->where(['name' => self::PART_NAME])
                ->scalar($this->db);
            if ($partId !== false && $partId !== null && $this->db->getTableSchema('part_char_values', true)) {
                $used = (new Query())
                    ->from('part_char_values')
                    ->where(['part_id' => (int) $partId])
                    ->exists($this->db);
                if (!$used) {
                    $this->delete('spr_parts', ['id' => (int) $partId]);
                }
            }
        }

        if ($this->db->getTableSchema('equipment_types', true)) {
            $this->delete('equipment_types', ['name' => self::TYPE_NAME]);
        }
    }
}
