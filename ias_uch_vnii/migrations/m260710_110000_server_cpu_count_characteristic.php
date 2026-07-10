<?php

use yii\db\Migration;
use yii\db\Query;

/**
 * Характеристика «Количество процессоров» для серверов (часть «ЦП»).
 */
class m260710_110000_server_cpu_count_characteristic extends Migration
{
    private const CHAR_NAME = 'Количество процессоров';

    public function safeUp()
    {
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
            'description' => 'Количество установленных процессоров (один или два)',
            'measurement_unit' => null,
            'is_archived' => false,
        ]);
    }

    public function safeDown()
    {
        if ($this->db->getTableSchema('spr_chars', true)) {
            $this->delete('spr_chars', ['name' => self::CHAR_NAME]);
        }
    }
}
