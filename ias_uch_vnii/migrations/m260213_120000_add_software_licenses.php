<?php

use yii\db\Migration;

class m260213_120000_add_software_licenses extends Migration
{
    public function safeUp()
    {
        $this->createTable('software', [
            'id' => $this->bigPrimaryKey(),
            'name' => $this->string(200)->notNull(),
            'version' => $this->string(100),
            'created_at' => $this->timestamp()->defaultExpression('CURRENT_TIMESTAMP'),
        ]);
        $this->createTable('licenses', [
            'id' => $this->bigPrimaryKey(),
            'software_id' => $this->bigInteger()->notNull(),
            'valid_until' => $this->date(),
            'notes' => $this->text(),
            'created_at' => $this->timestamp()->defaultExpression('CURRENT_TIMESTAMP'),
        ]);
        $this->addForeignKey('fk_licenses_software', 'licenses', 'software_id', 'software', 'id');
        $this->createTable('equipment_software', [
            'id' => $this->bigPrimaryKey(),
            'equipment_id' => $this->bigInteger()->notNull(),
            'software_id' => $this->bigInteger()->notNull(),
            'installed_at' => $this->date(),
            'created_at' => $this->timestamp()->defaultExpression('CURRENT_TIMESTAMP'),
        ]);
        $this->addForeignKey('fk_equipment_software_equipment', 'equipment_software', 'equipment_id', 'equipment', 'id');
        $this->addForeignKey('fk_equipment_software_software', 'equipment_software', 'software_id', 'software', 'id');
    }

    public function safeDown()
    {
        $this->dropTable('equipment_software');
        $this->dropTable('licenses');
        $this->dropTable('software');
    }
}
