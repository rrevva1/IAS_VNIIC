<?php

use yii\db\Migration;
use yii\db\Query;

/**
 * Справочники для учёта ИБП: часть «ИБП», характеристика «Модель аккумулятора».
 */
class m260530_130000_ups_battery_characteristic extends Migration
{
    private const PART_NAME = 'ИБП';

    private const CHAR_NAME = 'Модель аккумулятора';

    public function safeUp()
    {
        if ($this->db->getTableSchema('spr_parts', true)) {
            $partExists = (new Query())
                ->from('spr_parts')
                ->where(['name' => self::PART_NAME])
                ->exists($this->db);
            if (!$partExists) {
                $this->insert('spr_parts', [
                    'name' => self::PART_NAME,
                    'description' => 'Источник бесперебойного питания',
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
            'description' => 'Модель аккумуляторной батареи ИБП',
            'measurement_unit' => null,
            'is_archived' => false,
        ]);
    }

    public function safeDown()
    {
        if ($this->db->getTableSchema('spr_chars', true)) {
            $this->delete('spr_chars', ['name' => self::CHAR_NAME]);
        }

        if (!$this->db->getTableSchema('spr_parts', true)) {
            return;
        }

        $partId = (new Query())
            ->select('id')
            ->from('spr_parts')
            ->where(['name' => self::PART_NAME])
            ->scalar($this->db);

        if ($partId === false || $partId === null) {
            return;
        }

        $partId = (int) $partId;
        if ($this->db->getTableSchema('part_char_values', true)) {
            $used = (new Query())
                ->from('part_char_values')
                ->where(['part_id' => $partId])
                ->exists($this->db);
            if (!$used) {
                $this->delete('spr_parts', ['id' => $partId]);
            }
        }
    }
}
