<?php

use yii\db\Migration;

/**
 * Расширение лицензий: поставщик, даты, вложения, связь с техникой.
 */
class m260709_100000_license_fields_and_attachments extends Migration
{
    public function safeUp()
    {
        $licenseTable = $this->db->schema->getTableSchema('licenses', true);
        if ($licenseTable !== null) {
            if (!isset($licenseTable->columns['supplier'])) {
                $this->addColumn('licenses', 'supplier', $this->string(255));
            }
            if (!isset($licenseTable->columns['purchase_date'])) {
                $this->addColumn('licenses', 'purchase_date', $this->date());
            }
            if (!isset($licenseTable->columns['valid_from'])) {
                $this->addColumn('licenses', 'valid_from', $this->date());
            }
        }

        $esTable = $this->db->schema->getTableSchema('equipment_software', true);
        if ($esTable !== null && !isset($esTable->columns['license_id'])) {
            $this->addColumn('equipment_software', 'license_id', $this->bigInteger());
            $this->addForeignKey(
                'fk_equipment_software_license',
                'equipment_software',
                'license_id',
                'licenses',
                'id',
                'SET NULL',
                'CASCADE'
            );
        }

        if ($this->db->schema->getTableSchema('license_attachments', true) === null) {
            $this->createTable('license_attachments', [
                'id' => $this->bigPrimaryKey(),
                'license_id' => $this->bigInteger()->notNull(),
                'attachment_id' => $this->bigInteger()->notNull(),
                'linked_by' => $this->bigInteger(),
                'linked_at' => $this->timestamp()->defaultExpression('CURRENT_TIMESTAMP'),
            ]);
            $this->addForeignKey(
                'fk_license_attachments_license',
                'license_attachments',
                'license_id',
                'licenses',
                'id',
                'CASCADE',
                'CASCADE'
            );
            $this->addForeignKey(
                'fk_license_attachments_attachment',
                'license_attachments',
                'attachment_id',
                'desk_attachments',
                'id',
                'CASCADE',
                'CASCADE'
            );
            $this->createIndex('ux_license_attachments_pair', 'license_attachments', ['license_id', 'attachment_id'], true);
        }
    }

    public function safeDown()
    {
        if ($this->db->schema->getTableSchema('license_attachments', true) !== null) {
            $this->dropTable('license_attachments');
        }

        $esTable = $this->db->schema->getTableSchema('equipment_software', true);
        if ($esTable !== null && isset($esTable->columns['license_id'])) {
            $this->dropForeignKey('fk_equipment_software_license', 'equipment_software');
            $this->dropColumn('equipment_software', 'license_id');
        }

        $licenseTable = $this->db->schema->getTableSchema('licenses', true);
        if ($licenseTable !== null) {
            foreach (['valid_from', 'purchase_date', 'supplier'] as $col) {
                if (isset($licenseTable->columns[$col])) {
                    $this->dropColumn('licenses', $col);
                }
            }
        }
    }
}
