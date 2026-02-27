<?php
/**
 * Конвертация equipment.equipment_type (varchar) -> equipment_type_id (FK).
 * Выполняет логику safeDown миграции m260215_120000_revert.
 * Запускать после восстановления дампа, где схема с equipment_type.
 *
 * php scripts/convert_equipment_type_to_id.php
 */
require __DIR__ . '/../vendor/autoload.php';
require __DIR__ . '/../vendor/yiisoft/yii2/Yii.php';
$config = require __DIR__ . '/../config/console.php';
new yii\console\Application($config);

$db = Yii::$app->db;
$schema = $db->getSchema()->getTableSchema('equipment', true);
if (!$schema || !isset($schema->columns['equipment_type'])) {
    echo "В equipment нет столбца equipment_type — конвертация не требуется.\n";
    exit(0);
}

echo "Конвертация equipment_type -> equipment_type_id...\n";

$db->createCommand("
    CREATE TABLE IF NOT EXISTS equipment_types (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        is_archived BOOLEAN NOT NULL DEFAULT false,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
")->execute();

$db->createCommand("
    INSERT INTO equipment_types (name, sort_order, is_archived, created_at, updated_at)
    SELECT t.name, t.rn::integer, false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
    FROM (
        SELECT TRIM(equipment_type) AS name, row_number() OVER (ORDER BY MIN(id)) AS rn
        FROM equipment
        WHERE equipment_type IS NOT NULL AND TRIM(equipment_type) <> ''
        GROUP BY TRIM(equipment_type)
    ) t
")->execute();

$db->createCommand("ALTER TABLE equipment ADD COLUMN IF NOT EXISTS equipment_type_id BIGINT NULL")->execute();
$db->createCommand("
    UPDATE equipment e
    SET equipment_type_id = et.id
    FROM equipment_types et
    WHERE TRIM(e.equipment_type) = et.name
")->execute();
$db->createCommand("ALTER TABLE equipment DROP COLUMN IF EXISTS equipment_type")->execute();
try {
    $db->createCommand("
        ALTER TABLE equipment ADD CONSTRAINT equipment_equipment_type_id_fkey
        FOREIGN KEY (equipment_type_id) REFERENCES equipment_types(id)
    ")->execute();
} catch (\Exception $e) {
    if (strpos($e->getMessage(), 'already exists') === false) {
        throw $e;
    }
}

echo "Готово. Схема приведена к equipment_type_id.\n";
