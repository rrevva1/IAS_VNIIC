<?php

use yii\db\Migration;
use yii\db\Query;

/**
 * Справочник характеристик: «Диагональ экрана» (часть «Монитор») для ноутбуков, моноблоков и мониторов.
 */
class m260526_120000_add_screen_diagonal_char extends Migration
{
    private const CHAR_NAME = 'Диагональ экрана';

    public function safeUp()
    {
        if (!$this->db->getTableSchema('spr_chars', true)) {
            return;
        }

        $exists = (new Query())
            ->from('spr_chars')
            ->where(['name' => self::CHAR_NAME])
            ->exists($this->db);

        if ($exists) {
            return;
        }

        $this->insert('spr_chars', [
            'name' => self::CHAR_NAME,
            'description' => 'Диагональ экрана, дюймы (ноутбук, моноблок, монитор)',
            'measurement_unit' => null,
            'is_archived' => false,
        ]);
    }

    public function safeDown()
    {
        if (!$this->db->getTableSchema('spr_chars', true)) {
            return;
        }

        $this->delete('spr_chars', ['name' => self::CHAR_NAME]);
    }
}
