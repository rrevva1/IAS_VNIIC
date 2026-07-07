<?php

use yii\db\Migration;
use yii\db\Query;

/**
 * Справочники ИБП: дата замены и срок службы аккумулятора.
 */
class m260607_150000_ups_battery_service_characteristics extends Migration
{
    private const PART_NAME = 'ИБП';

    /** @var array<int, array{name: string, description: string, measurement_unit: ?string}> */
    private const CHARS = [
        [
            'name' => 'Дата замены аккумулятора',
            'description' => 'Дата последней замены аккумуляторной батареи ИБП',
            'measurement_unit' => null,
        ],
        [
            'name' => 'Срок службы аккумулятора',
            'description' => 'Нормативный срок службы аккумуляторной батареи ИБП',
            'measurement_unit' => 'лет',
        ],
    ];

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

        foreach (self::CHARS as $char) {
            $charExists = (new Query())
                ->from('spr_chars')
                ->where(['name' => $char['name']])
                ->exists($this->db);

            if ($charExists) {
                continue;
            }

            $this->insert('spr_chars', [
                'name' => $char['name'],
                'description' => $char['description'],
                'measurement_unit' => $char['measurement_unit'],
                'is_archived' => false,
            ]);
        }
    }

    public function safeDown()
    {
        if (!$this->db->getTableSchema('spr_chars', true)) {
            return;
        }

        foreach (self::CHARS as $char) {
            $this->delete('spr_chars', ['name' => $char['name']]);
        }
    }
}
