<?php

use yii\db\Migration;
use yii\db\Query;

/**
 * Характеристики принтера / МФУ: логин и пароль веб-интерфейса (часть «Принтер»).
 */
class m260710_130000_printer_mfu_login_password extends Migration
{
    /** @var array<string, string> */
    private const CHARS = [
        'Логин' => 'Логин доступа к веб-интерфейсу устройства',
        'Пароль' => 'Пароль доступа к веб-интерфейсу устройства',
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
