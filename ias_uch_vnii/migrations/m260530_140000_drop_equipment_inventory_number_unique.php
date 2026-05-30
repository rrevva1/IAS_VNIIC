<?php

use yii\db\Migration;

/**
 * Инвентарный номер не уникален: у малоценки несколько единиц с номером инвентарной ведомости.
 */
class m260530_140000_drop_equipment_inventory_number_unique extends Migration
{
    public function safeUp()
    {
        $schema = $this->db->schema;
        $table = $schema->getRawTableName('{{%equipment}}');
        $constraint = 'uq_equipment_inventory_number';

        if ($this->db->driverName === 'pgsql') {
            $exists = (bool) $this->db->createCommand(
                'SELECT 1 FROM pg_constraint WHERE conname = :name',
                [':name' => $constraint]
            )->queryScalar();
            if ($exists) {
                $this->execute('ALTER TABLE ' . $schema->quoteTableName($table)
                    . ' DROP CONSTRAINT ' . $schema->quoteColumnName($constraint));
            }

            return;
        }

        $tableSchema = $this->db->getTableSchema('{{%equipment}}', true);
        if ($tableSchema !== null && isset($tableSchema->indexes[$constraint])) {
            $this->dropIndex($constraint, '{{%equipment}}');
        }
    }

    public function safeDown()
    {
        echo "m260530_140000_drop_equipment_inventory_number_unique cannot be reverted "
            . "(duplicate inventory numbers may exist).\n";

        return false;
    }
}
