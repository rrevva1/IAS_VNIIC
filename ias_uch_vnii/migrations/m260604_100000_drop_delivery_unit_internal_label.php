<?php

use yii\db\Migration;

/**
 * Удаление служебного поля internal_label у единиц поставки.
 */
class m260604_100000_drop_delivery_unit_internal_label extends Migration
{
    public function safeUp()
    {
        $schema = $this->db->getTableSchema('equipment_delivery_units', true);
        if ($schema === null || !isset($schema->columns['internal_label'])) {
            return;
        }

        $this->execute('DROP INDEX IF EXISTS uq_equipment_delivery_units_internal_label');
        $this->dropColumn('equipment_delivery_units', 'internal_label');
    }

    public function safeDown()
    {
        echo "m260604_100000_drop_delivery_unit_internal_label cannot be reverted.\n";

        return false;
    }
}
