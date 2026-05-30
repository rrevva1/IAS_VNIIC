<?php

use yii\db\Migration;
use yii\db\Query;

/**
 * Характеристики принтера / МФУ в spr_chars (часть «Принтер»).
 */
class m260530_120000_printer_mfu_characteristics extends Migration
{
    /** @var array<string, string> */
    private const CHARS = [
        'Максимальный размер бумаги' => 'Формат бумаги (A4, A3 и т.д.)',
        'Технология печати' => 'Лазерный или струйный',
        'Цветность печати' => 'Чёрно-белый или цветной',
        'Подключение' => 'Сетевой или USB',
        'Модуль WiFi' => 'Наличие модуля Wi‑Fi',
    ];

    public function safeUp()
    {
        if (!$this->db->getTableSchema('spr_chars', true)) {
            return;
        }

        foreach (self::CHARS as $name => $description) {
            $exists = (new Query())
                ->from('spr_chars')
                ->where(['name' => $name])
                ->exists($this->db);
            if ($exists) {
                continue;
            }
            $this->insert('spr_chars', [
                'name' => $name,
                'description' => $description,
                'measurement_unit' => null,
                'is_archived' => false,
            ]);
        }
    }

    public function safeDown()
    {
        if (!$this->db->getTableSchema('spr_chars', true)) {
            return;
        }

        $this->delete('spr_chars', ['name' => array_keys(self::CHARS)]);
    }
}
