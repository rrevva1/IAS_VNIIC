<?php

/**
 * Однократно снять UNIQUE с equipment.inventory_number (если migrate недоступен).
 * Запуск из ias_uch_vnii: php scripts/drop_inventory_unique.php
 */

require __DIR__ . '/../vendor/autoload.php';
require __DIR__ . '/../vendor/yiisoft/yii2/Yii.php';

$config = require __DIR__ . '/../config/console.php';
new yii\console\Application($config);

$db = Yii::$app->db;
$db->createCommand('SET search_path TO tech_accounting')->execute();

$exists = (bool) $db->createCommand(
    'SELECT 1 FROM pg_constraint WHERE conname = :name',
    [':name' => 'uq_equipment_inventory_number']
)->queryScalar();

if ($exists) {
    $db->createCommand('ALTER TABLE equipment DROP CONSTRAINT uq_equipment_inventory_number')->execute();
    echo "OK: ограничение uq_equipment_inventory_number снято.\n";
} else {
    echo "OK: ограничение uq_equipment_inventory_number уже отсутствует.\n";
}
