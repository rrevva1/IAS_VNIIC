<?php

use yii\db\Migration;

/**
 * Срок действия лицензии: годы и признак «бессрочная».
 */
class m260709_130000_license_validity_years extends Migration
{
    public function safeUp()
    {
        $table = $this->db->schema->getTableSchema('licenses', true);
        if ($table === null) {
            return;
        }

        if (!isset($table->columns['validity_years'])) {
            $this->addColumn('licenses', 'validity_years', $this->decimal(5, 1));
        }
        if (!isset($table->columns['is_perpetual'])) {
            $this->addColumn('licenses', 'is_perpetual', $this->boolean()->notNull()->defaultValue(false));
        }

        if ($this->db->driverName === 'pgsql') {
            $this->execute("
                UPDATE licenses
                SET validity_years = ROUND(
                    (DATE_PART('year', AGE(valid_until, valid_from))
                     + DATE_PART('month', AGE(valid_until, valid_from)) / 12.0)::numeric,
                    1
                )
                WHERE valid_from IS NOT NULL
                  AND valid_until IS NOT NULL
                  AND validity_years IS NULL
                  AND is_perpetual = FALSE
            ");
        }
    }

    public function safeDown()
    {
        $table = $this->db->schema->getTableSchema('licenses', true);
        if ($table === null) {
            return;
        }
        if (isset($table->columns['is_perpetual'])) {
            $this->dropColumn('licenses', 'is_perpetual');
        }
        if (isset($table->columns['validity_years'])) {
            $this->dropColumn('licenses', 'validity_years');
        }
    }
}
