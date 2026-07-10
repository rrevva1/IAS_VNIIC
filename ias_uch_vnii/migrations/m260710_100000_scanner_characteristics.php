<?php

use yii\db\Migration;
use yii\db\Query;

/**
 * Справочники для учёта сканеров: часть «Сканер», характеристика «Тип сканера».
 * «Максимальный размер бумаги» уже есть в spr_chars (принтер / МФУ).
 */
class m260710_100000_scanner_characteristics extends Migration
{
    private const PART_NAME = 'Сканер';

    private const CHAR_NAME = 'Тип сканера';

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
                    'description' => 'Сканирующее устройство',
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
            'description' => 'Многопоточный, планшетный или комбинированный',
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
