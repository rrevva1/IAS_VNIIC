<?php

use yii\db\Migration;

/**
 * Пустой serial_number в БД хранился как '' — нарушает uq_equipment_serial_number_not_null
 * (несколько пустых строк). Приводим к NULL.
 */
class m260518_100000_normalize_equipment_serial_number_null extends Migration
{
    public function safeUp()
    {
        $this->execute(
            "UPDATE equipment SET serial_number = NULL WHERE serial_number IS NOT NULL AND TRIM(serial_number) = ''"
        );
    }

    public function safeDown()
    {
        echo "m260518_100000_normalize_equipment_serial_number_null cannot be reverted.\n";

        return false;
    }
}
