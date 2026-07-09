<?php

use yii\db\Migration;

/**
 * Количество приобретённых лицензий (мест).
 */
class m260709_120000_license_seats extends Migration
{
    public function safeUp()
    {
        $table = $this->db->schema->getTableSchema('licenses', true);
        if ($table !== null && !isset($table->columns['seats'])) {
            $this->addColumn('licenses', 'seats', $this->integer()->notNull()->defaultValue(1));
        }
    }

    public function safeDown()
    {
        $table = $this->db->schema->getTableSchema('licenses', true);
        if ($table !== null && isset($table->columns['seats'])) {
            $this->dropColumn('licenses', 'seats');
        }
    }
}
