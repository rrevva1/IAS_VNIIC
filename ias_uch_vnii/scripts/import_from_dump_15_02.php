<?php
/**
 * Импорт данных из дампа 15.02.2026 в текущую БД проекта.
 * Маппинг: equipment_type (текст) -> equipment_type_id.
 *
 * Запуск: php scripts/import_from_dump_15_02.php
 * (из папки ias_uch_vnii)
 */
require __DIR__ . '/../vendor/autoload.php';
require __DIR__ . '/../vendor/yiisoft/yii2/Yii.php';
$config = require __DIR__ . '/../config/console.php';
new yii\console\Application($config);

$dumpPath = dirname(__DIR__, 2) . '/db/ias_vniic_mac_15_02_26.sql';
if (!is_file($dumpPath)) {
    echo "Ошибка: дамп не найден: $dumpPath\n";
    exit(1);
}

$db = Yii::$app->db;

/** Получить или создать equipment_type_id по имени */
function ensureEquipmentType($db, string $name): ?int {
    if (trim($name) === '') return null;
    $id = $db->createCommand(
        'SELECT id FROM equipment_types WHERE name = :n AND is_archived = false',
        [':n' => trim($name)]
    )->queryScalar();
    if ($id) return (int) $id;
    $maxSort = $db->createCommand('SELECT COALESCE(MAX(sort_order), 0) + 1 FROM equipment_types')->queryScalar();
    $db->createCommand()->insert('equipment_types', [
        'name' => trim($name),
        'sort_order' => (int) $maxSort,
        'is_archived' => false,
    ])->execute();
    return (int) $db->getLastInsertID('equipment_types_id_seq');
}

$content = file_get_contents($dumpPath);
if (!preg_match('/COPY tech_accounting\.equipment \(.*?equipment_type\) FROM stdin;\s*\n(.*?)\n\\\\\./s', $content, $m)) {
    echo "Не удалось извлечь блок equipment из дампа.\n";
    exit(1);
}

$lines = array_filter(explode("\n", trim($m[1])));
$cols = ['id','inventory_number','serial_number','name','status_id','responsible_user_id','location_id',
         'supplier','purchase_date','commissioning_date','warranty_until','description','archived_at',
         'archive_reason','is_archived','is_deleted','created_by_id','updated_by_id','created_at','updated_at','equipment_type'];
$eqCol = count($cols) - 1; // index of equipment_type

$inserted = 0;
$updated = 0;
$skipped = 0;

$transaction = $db->beginTransaction();
try {
    foreach ($lines as $line) {
        $fields = preg_split('/\t/', $line, -1, PREG_SPLIT_NO_EMPTY);
        if (count($fields) < $eqCol + 1) continue;
        $equipmentTypeName = $fields[$eqCol] ?? '';
        $typeId = ensureEquipmentType($db, $equipmentTypeName);
        $invNum = $fields[1] === '\\N' ? null : $fields[1];
        if (empty($invNum)) { $skipped++; continue; }
        $exists = $db->createCommand(
            'SELECT id FROM equipment WHERE inventory_number = :n',
            [':n' => $invNum]
        )->queryScalar();
        $row = [
            'inventory_number' => $invNum,
            'serial_number' => $fields[2] === '\\N' ? null : $fields[2],
            'name' => $fields[3] === '\\N' ? null : $fields[3],
            'status_id' => (int) $fields[4],
            'responsible_user_id' => $fields[5] === '\\N' ? null : (int) $fields[5],
            'location_id' => $fields[6] === '\\N' ? null : (int) $fields[6],
            'supplier' => $fields[7] === '\\N' ? null : $fields[7],
            'purchase_date' => $fields[8] === '\\N' ? null : $fields[8],
            'commissioning_date' => $fields[9] === '\\N' ? null : $fields[9],
            'warranty_until' => $fields[10] === '\\N' ? null : $fields[10],
            'description' => $fields[11] === '\\N' ? null : $fields[11],
            'is_archived' => ($fields[15] ?? 'f') === 't',
            'is_deleted' => ($fields[16] ?? 'f') === 't',
            'equipment_type_id' => $typeId,
        ];
        if ($exists) {
            $db->createCommand()->update('equipment', $row, ['inventory_number' => $invNum])->execute();
            $updated++;
        } else {
            $row['created_at'] = $fields[18] === '\\N' ? date('Y-m-d H:i:s') : $fields[18];
            $row['updated_at'] = $fields[19] === '\\N' ? date('Y-m-d H:i:s') : $fields[19];
            $db->createCommand()->insert('equipment', $row)->execute();
            $inserted++;
        }
    }
    $transaction->commit();
    echo "Импорт завершён: вставлено $inserted, обновлено $updated, пропущено $skipped.\n";
} catch (\Throwable $e) {
    $transaction->rollBack();
    echo "Ошибка: " . $e->getMessage() . "\n";
    exit(1);
}
