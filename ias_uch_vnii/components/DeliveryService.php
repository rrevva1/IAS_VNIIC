<?php

namespace app\components;

use app\models\dictionaries\DicEquipmentStatus;
use app\models\entities\Equipment;
use app\models\entities\EquipmentDelivery;
use app\models\entities\EquipmentDeliveryLine;
use app\models\entities\EquipmentDeliveryAttachment;
use app\models\entities\EquipmentDeliveryUnit;
use app\models\entities\EquipHistory;
use app\models\entities\EquipmentTypes;
use app\models\entities\Location;
use app\models\entities\DeskAttachments;
use Yii;
use yii\db\Exception as DbException;
use yii\web\UploadedFile;

/**
 * Операции раздела «Поставки»: строки, единицы, проведение, номера, синхронизация с equipment.
 */
class DeliveryService
{
    private EquipmentPartCharService $partCharService;

    public function __construct(?EquipmentPartCharService $partCharService = null)
    {
        $this->partCharService = $partCharService ?? new EquipmentPartCharService();
    }
    /**
     * @return array{success: bool, message: string, line_id?: int, errors?: array}
     */
    public function saveLine(EquipmentDelivery $delivery, array $data, ?int $lineId = null): array
    {
        if (!$delivery->isDraft()) {
            return ['success' => false, 'message' => 'Редактирование строк доступно только в черновике.'];
        }

        $line = $lineId ? EquipmentDeliveryLine::findOne(['id' => $lineId, 'delivery_id' => $delivery->id]) : new EquipmentDeliveryLine();
        if (!$line) {
            return ['success' => false, 'message' => 'Строка поставки не найдена.'];
        }

        $line->delivery_id = (int) $delivery->id;
        $payload = $data['EquipmentDeliveryLine'] ?? $data;
        $line->equipment_type = trim((string) ($payload['equipment_type'] ?? $line->equipment_type));
        $line->name = trim((string) ($payload['name'] ?? $line->name));
        if (isset($payload['quantity'])) {
            $line->quantity = (int) $payload['quantity'];
        }
        if (array_key_exists('description', $payload)) {
            $line->description = $payload['description'] !== '' ? (string) $payload['description'] : null;
        }
        if (array_key_exists('warehouse_location_id', $payload)) {
            $wh = (int) $payload['warehouse_location_id'];
            $line->warehouse_location_id = $wh > 0 ? $wh : null;
        }
        if (array_key_exists('warranty_years', $payload)) {
            $years = trim((string) $payload['warranty_years']);
            $line->warranty_years = $years !== '' && is_numeric(str_replace(',', '.', $years))
                ? (float) str_replace(',', '.', $years)
                : null;
        }

        $charTemplate = $this->partCharService->buildCharTemplateFromPost($data);
        $charTemplate = $this->stripDeliveryExcludedCharFields($charTemplate);
        if ($charTemplate !== [] || isset($data['PartChar']) || isset($data['PartCharDisks']) || isset($data['OrgTech'])) {
            $line->setCharTemplateData($charTemplate);
        }

        if (!$line->validate()) {
            return ['success' => false, 'message' => 'Проверьте поля строки.', 'errors' => $line->errors];
        }

        $transaction = Yii::$app->db->beginTransaction();
        try {
            $isNew = $line->isNewRecord;
            if ($isNew) {
                $maxSort = (int) EquipmentDeliveryLine::find()
                    ->where(['delivery_id' => $delivery->id])
                    ->max('sort_order');
                $line->sort_order = $maxSort + 1;
            }
            $line->save(false);
            $this->syncUnitsForLine($line);
            $transaction->commit();
        } catch (\Throwable $e) {
            $transaction->rollBack();

            return ['success' => false, 'message' => $e->getMessage()];
        }

        return [
            'success' => true,
            'message' => $isNew ? 'Строка добавлена.' : 'Строка сохранена.',
            'line_id' => (int) $line->id,
        ];
    }

    /**
     * Подгоняет количество equipment_delivery_units под quantity строки.
     */
    public function syncUnitsForLine(EquipmentDeliveryLine $line): void
    {
        $delivery = $line->delivery;
        if ($delivery === null || !$delivery->isDraft()) {
            return;
        }

        $targetQty = max(1, (int) $line->quantity);
        $existing = EquipmentDeliveryUnit::find()
            ->where(['line_id' => $line->id])
            ->orderBy(['seq_no' => SORT_ASC])
            ->all();

        $count = count($existing);
        if ($count < $targetQty) {
            for ($seq = $count + 1; $seq <= $targetQty; $seq++) {
                $unit = new EquipmentDeliveryUnit();
                $unit->line_id = (int) $line->id;
                $unit->seq_no = $seq;
                $unit->save(false);
            }
        } elseif ($count > $targetQty) {
            $toRemove = array_slice($existing, $targetQty);
            foreach ($toRemove as $unit) {
                if ($unit->equipment_id) {
                    continue;
                }
                $unit->delete();
            }
        }
    }

    /**
     * @return array{success: bool, message: string, applied?: int, errors?: string[]}
     */
    public function applyBulkSerials(int $lineId, string $text, string $mode = 'seq'): array
    {
        $line = EquipmentDeliveryLine::findOne($lineId);
        if (!$line || !$line->delivery) {
            return ['success' => false, 'message' => 'Строка не найдена.'];
        }

        $lines = $this->parseBulkLines($text);
        if ($lines === []) {
            return ['success' => false, 'message' => 'Нет данных для вставки.'];
        }

        $units = EquipmentDeliveryUnit::find()
            ->where(['line_id' => $line->id])
            ->orderBy(['seq_no' => SORT_ASC])
            ->all();

        $errors = [];
        $applied = 0;
        $transaction = Yii::$app->db->beginTransaction();
        try {
            if ($mode === 'serial_map') {
                $map = $this->parseSerialInventoryPairs($lines);
                foreach ($units as $unit) {
                    $serial = trim((string) ($unit->serial_number ?? ''));
                    if ($serial === '' || !isset($map[$serial])) {
                        continue;
                    }
                    $unit->serial_number = $serial;
                    $unit->inventory_number = $map[$serial];
                    if (!$this->saveUnitWithSync($unit, $line->delivery, $errors)) {
                        continue;
                    }
                    $applied++;
                }
            } else {
                foreach ($lines as $index => $value) {
                    if (!isset($units[$index])) {
                        break;
                    }
                    $units[$index]->serial_number = $value;
                    if ($this->saveUnitWithSync($units[$index], $line->delivery, $errors)) {
                        $applied++;
                    }
                }
            }
            $transaction->commit();
        } catch (\Throwable $e) {
            $transaction->rollBack();

            return ['success' => false, 'message' => $e->getMessage()];
        }

        $message = "Серийные номера: обновлено {$applied}.";
        if ($errors !== []) {
            $message .= ' Ошибки: ' . implode('; ', array_slice($errors, 0, 5));
        }

        return ['success' => true, 'message' => $message, 'applied' => $applied, 'errors' => $errors];
    }

    /**
     * @return array{success: bool, message: string, applied?: int, errors?: string[]}
     */
    public function applyBulkInventory(int $deliveryId, string $text, ?int $lineId = null, string $mode = 'seq'): array
    {
        $delivery = EquipmentDelivery::findOne($deliveryId);
        if (!$delivery) {
            return ['success' => false, 'message' => 'Поставка не найдена.'];
        }

        $lines = $this->parseBulkLines($text);
        if ($lines === []) {
            return ['success' => false, 'message' => 'Нет данных для вставки.'];
        }

        $query = EquipmentDeliveryUnit::find()
            ->alias('u')
            ->innerJoin(['l' => EquipmentDeliveryLine::tableName()], 'l.id = u.line_id')
            ->where(['l.delivery_id' => $delivery->id])
            ->orderBy(['l.sort_order' => SORT_ASC, 'l.id' => SORT_ASC, 'u.seq_no' => SORT_ASC]);

        if ($lineId) {
            $query->andWhere(['u.line_id' => $lineId]);
        }

        $units = $query->all();
        $errors = [];
        $applied = 0;
        $transaction = Yii::$app->db->beginTransaction();
        try {
            if ($mode === 'serial_map') {
                $map = $this->parseSerialInventoryPairs($lines);
                foreach ($units as $unit) {
                    $serial = Equipment::normalizeSerialNumberValue($unit->serial_number);
                    if ($serial === null || $serial === '' || !isset($map[$serial])) {
                        continue;
                    }
                    $unit->inventory_number = $map[$serial];
                    if ($this->saveUnitWithSync($unit, $delivery, $errors)) {
                        $applied++;
                    }
                }
            } else {
                foreach ($lines as $index => $value) {
                    if (!isset($units[$index])) {
                        break;
                    }
                    $units[$index]->inventory_number = $value;
                    if ($this->saveUnitWithSync($units[$index], $delivery, $errors)) {
                        $applied++;
                    }
                }
            }
            $this->tryCloseDelivery($delivery);
            $transaction->commit();
        } catch (\Throwable $e) {
            $transaction->rollBack();

            return ['success' => false, 'message' => $e->getMessage()];
        }

        $message = "Инвентарные номера: обновлено {$applied}.";
        if ($errors !== []) {
            $message .= ' Ошибки: ' . implode('; ', array_slice($errors, 0, 5));
        }

        return ['success' => true, 'message' => $message, 'applied' => $applied, 'errors' => $errors];
    }

    /**
     * @param string[] $errors
     */
    private function saveUnitWithSync(EquipmentDeliveryUnit $unit, EquipmentDelivery $delivery, array &$errors): bool
    {
        $unit->serial_number = Equipment::normalizeSerialNumberValue($unit->serial_number);
        $unit->inventory_number = trim((string) $unit->inventory_number) !== ''
            ? trim((string) $unit->inventory_number)
            : null;
        $unit->refreshNumberStatus();

        if ($unit->serial_number !== null && $unit->serial_number !== '') {
            $dup = Equipment::find()
                ->where(['serial_number' => $unit->serial_number, 'is_deleted' => false])
                ->andFilterWhere(['<>', 'id', $unit->equipment_id])
                ->exists();
            if ($dup) {
                $errors[] = "Серийный «{$unit->serial_number}» уже в системе";

                return false;
            }
            $dupUnit = EquipmentDeliveryUnit::find()
                ->where(['serial_number' => $unit->serial_number])
                ->andWhere(['<>', 'id', $unit->id])
                ->exists();
            if ($dupUnit) {
                $errors[] = "Серийный «{$unit->serial_number}» дублируется в поставках";

                return false;
            }
        }

        if (!$unit->save()) {
            $errors[] = implode(' ', $unit->getFirstErrors());

            return false;
        }

        if ($unit->equipment_id) {
            $this->syncUnitToEquipment($unit, $delivery);
        }

        return true;
    }

    public function syncUnitToEquipment(EquipmentDeliveryUnit $unit, ?EquipmentDelivery $delivery = null): void
    {
        $equipment = Equipment::findOne((int) $unit->equipment_id);
        if (!$equipment) {
            return;
        }

        $line = $unit->deliveryLine;
        $delivery = $delivery ?? ($line ? $line->delivery : null);

        $old = [
            'serial_number' => $equipment->serial_number,
            'inventory_number' => $equipment->inventory_number,
            'name' => $equipment->name,
            'equipment_type' => $equipment->resolveEquipmentTypeName(),
        ];

        $equipment->serial_number = $unit->serial_number;
        $inv = trim((string) $unit->inventory_number);
        $equipment->inventory_number = $inv !== '' ? $inv : '';
        if ($line) {
            $equipment->name = $line->name;
            $equipment->equipment_type = $line->equipment_type;
        }
        if ($delivery) {
            $equipment->supplier = $delivery->supplier;
            $equipment->purchase_date = $delivery->delivery_date;
        }

        if ($equipment->save(false)) {
            EquipHistory::log($equipment->id, 'update', $old, [
                'serial_number' => $equipment->serial_number,
                'inventory_number' => $equipment->inventory_number,
                'name' => $equipment->name,
                'equipment_type' => $equipment->resolveEquipmentTypeName(),
            ], 'delivery_sync');
        }
    }

    /**
     * @return array{success: bool, message: string, created?: int, errors?: string[]}
     */
    public function postDelivery(EquipmentDelivery $delivery): array
    {
        if (!$delivery->isDraft()) {
            return ['success' => false, 'message' => 'Поставка уже проведена.'];
        }

        $lines = EquipmentDeliveryLine::find()->where(['delivery_id' => $delivery->id])->all();
        if ($lines === []) {
            return ['success' => false, 'message' => 'Добавьте хотя бы одну строку с техникой.'];
        }

        $warehouseByLine = [];
        foreach ($lines as $line) {
            if (!$line->warehouse_location_id) {
                return [
                    'success' => false,
                    'message' => 'Укажите склад для каждой строки («' . $line->name . '»).',
                ];
            }
            if (!isset($warehouseByLine[$line->warehouse_location_id])) {
                $warehouse = Location::findOne([
                    'id' => $line->warehouse_location_id,
                    'location_type' => 'склад',
                    'is_archived' => false,
                ]);
                if (!$warehouse) {
                    return [
                        'success' => false,
                        'message' => 'Склад строки «' . $line->name . '» не найден или не является складом.',
                    ];
                }
                $warehouseByLine[$line->warehouse_location_id] = $warehouse;
            }
            $this->syncUnitsForLine($line);
        }

        $created = 0;
        $errors = [];
        $transaction = Yii::$app->db->beginTransaction();
        try {
            $units = EquipmentDeliveryUnit::find()
                ->alias('u')
                ->innerJoin(['l' => EquipmentDeliveryLine::tableName()], 'l.id = u.line_id')
                ->where(['l.delivery_id' => $delivery->id])
                ->with(['deliveryLine'])
                ->orderBy(['l.sort_order' => SORT_ASC, 'u.seq_no' => SORT_ASC])
                ->all();

            foreach ($units as $unit) {
                if ($unit->equipment_id) {
                    continue;
                }
                $line = $unit->deliveryLine;
                if (!$line) {
                    $errors[] = "Единица №{$unit->seq_no}: строка не найдена";
                    continue;
                }

                $lineWarehouse = $warehouseByLine[(int) $line->warehouse_location_id] ?? null;
                if (!$lineWarehouse) {
                    $errors[] = '№' . $unit->seq_no . ': склад строки не задан';
                    continue;
                }

                $equipment = new Equipment();
                $equipment->loadDefaultValues();
                $equipment->name = $line->name;
                $equipment->equipment_type = $line->equipment_type;
                $equipment->location_id = (int) $lineWarehouse->id;
                $equipment->location_name = $lineWarehouse->name;
                $equipment->responsible_user_id = null;
                $equipment->supplier = $delivery->supplier;
                $equipment->purchase_date = $delivery->delivery_date;
                if ($line->warranty_years !== null && $line->warranty_years !== '') {
                    $equipment->warranty_years = $line->warranty_years;
                }
                $equipment->description = $line->description;
                $equipment->delivery_id = (int) $delivery->id;
                $equipment->delivery_unit_id = (int) $unit->id;
                $equipment->serial_number = $unit->serial_number;
                $inv = trim((string) $unit->inventory_number);
                $equipment->inventory_number = $inv !== '' ? $inv : '';

                if (!$equipment->save()) {
                    $errors[] = '№' . $unit->seq_no . ': ' . implode(' ', $equipment->getFirstErrors());
                    continue;
                }

                $charTemplate = $line->getCharTemplateData();
                if ($charTemplate !== []) {
                    $this->partCharService->applyCharTemplate(
                        (int) $equipment->id,
                        $charTemplate,
                        $line->equipment_type
                    );
                }

                $unit->equipment_id = (int) $equipment->id;
                $unit->save(false);

                EquipHistory::log($equipment->id, 'create', null, [
                    'name' => $equipment->name,
                    'equipment_type' => $equipment->resolveEquipmentTypeName(),
                    'location_id' => $equipment->location_id,
                    'delivery_id' => $delivery->id,
                ], 'delivery_post');
                AuditLog::log('equipment.delivery_post', 'equipment', $equipment->id, 'success');
                $created++;
            }

            $delivery->status = EquipmentDelivery::STATUS_POSTED;
            $delivery->save(false);
            $this->tryCloseDelivery($delivery);

            if ($created === 0 && $errors !== []) {
                $transaction->rollBack();

                return ['success' => false, 'message' => 'Не удалось провести поставку.', 'errors' => $errors];
            }

            $transaction->commit();
        } catch (\Throwable $e) {
            $transaction->rollBack();

            return ['success' => false, 'message' => $e->getMessage()];
        }

        $message = "Поставка проведена. Создано единиц техники: {$created}.";
        if ($errors !== []) {
            $message .= ' Частичные ошибки: ' . implode('; ', array_slice($errors, 0, 3));
        }

        return ['success' => true, 'message' => $message, 'created' => $created, 'errors' => $errors];
    }

    public function syncDeliveryHeaderToEquipment(EquipmentDelivery $delivery): void
    {
        if (!$delivery->isPosted()) {
            return;
        }

        foreach ($delivery->equipmentItems as $equipment) {
            $old = ['supplier' => $equipment->supplier, 'purchase_date' => $equipment->purchase_date];
            $equipment->supplier = $delivery->supplier;
            $equipment->purchase_date = $delivery->delivery_date;
            if ($equipment->save(false)) {
                EquipHistory::log($equipment->id, 'update', $old, [
                    'supplier' => $equipment->supplier,
                    'purchase_date' => $equipment->purchase_date,
                ], 'delivery_sync');
            }
        }
    }

    public function tryCloseDelivery(EquipmentDelivery $delivery): void
    {
        if ($delivery->status !== EquipmentDelivery::STATUS_POSTED) {
            return;
        }

        $pending = (int) EquipmentDeliveryUnit::find()
            ->alias('u')
            ->innerJoin(['l' => EquipmentDeliveryLine::tableName()], 'l.id = u.line_id')
            ->where(['l.delivery_id' => $delivery->id])
            ->andWhere(['or',
                ['u.number_status' => EquipmentDeliveryUnit::NUMBER_EMPTY],
                ['u.number_status' => EquipmentDeliveryUnit::NUMBER_SERIAL_ONLY],
            ])
            ->count();

        if ($pending === 0) {
            $delivery->status = EquipmentDelivery::STATUS_CLOSED;
            $delivery->save(false);
        }
    }

    /**
     * @return string[]
     */
    private function parseBulkLines(string $text): array
    {
        $text = str_replace(["\r\n", "\r"], "\n", $text);
        $rows = explode("\n", $text);
        $result = [];
        foreach ($rows as $row) {
            $row = trim($row);
            if ($row === '') {
                continue;
            }
            $result[] = $row;
        }

        return $result;
    }

    /**
     * Пары serial + inventory в одной строке, разделитель — табуляция (вставка из Excel).
     *
     * @param string[] $lines
     * @return array<string, string>
     */
    private function parseSerialInventoryPairs(array $lines): array
    {
        $map = [];
        foreach ($lines as $line) {
            if (strpos($line, "\t") === false) {
                continue;
            }
            $parts = preg_split('/\t+/', $line);
            $serial = trim((string) ($parts[0] ?? ''));
            $inventory = trim((string) ($parts[1] ?? ''));
            $serial = Equipment::normalizeSerialNumberValue($serial);
            if ($serial === null || $serial === '' || $inventory === '') {
                continue;
            }
            $map[$serial] = $inventory;
        }

        return $map;
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    public function getUnitsGridRows(int $deliveryId, ?int $lineId = null, ?string $search = null): array
    {
        $query = EquipmentDeliveryUnit::find()
            ->alias('u')
            ->innerJoin(['l' => EquipmentDeliveryLine::tableName()], 'l.id = u.line_id')
            ->where(['l.delivery_id' => $deliveryId])
            ->with(['deliveryLine', 'equipment.responsibleUser', 'equipment.location'])
            ->orderBy(['l.sort_order' => SORT_ASC, 'l.id' => SORT_ASC, 'u.seq_no' => SORT_ASC]);

        if ($lineId) {
            $query->andWhere(['u.line_id' => $lineId]);
        }

        if ($search !== null && trim($search) !== '') {
            $term = '%' . str_replace(['%', '_'], ['\\%', '\\_'], trim($search)) . '%';
            $query->andWhere(['or',
                ['ilike', 'u.serial_number', $term, false],
                ['ilike', 'u.inventory_number', $term, false],
                ['ilike', 'l.name', $term, false],
                ['ilike', 'l.equipment_type', $term, false],
            ]);
        }

        $rows = [];
        foreach ($query->all() as $unit) {
            $line = $unit->deliveryLine;
            $equipment = $unit->equipment;
            $holder = '—';
            $locationName = '—';
            if ($equipment) {
                if ($equipment->responsibleUser) {
                    $holder = $equipment->responsibleUser->getDisplayName();
                } elseif ($equipment->location) {
                    $holder = 'На складе';
                }
                $locationName = $equipment->location ? $equipment->location->name : '—';
            }

            $rows[] = [
                'id' => (int) $unit->id,
                'line_id' => (int) $unit->line_id,
                'seq_no' => (int) $unit->seq_no,
                'line_type' => $line ? $line->equipment_type : '',
                'line_name' => $line ? $line->name : '',
                'serial_number' => $unit->serial_number ?? '',
                'inventory_number' => $unit->inventory_number ?? '',
                'number_status' => $unit->number_status,
                'equipment_id' => $unit->equipment_id ? (int) $unit->equipment_id : null,
                'holder' => $holder,
                'location_name' => $locationName,
            ];
        }

        return $rows;
    }

    /**
     * @param array<string, mixed> $template
     * @return array<string, mixed>
     */
    private function stripDeliveryExcludedCharFields(array $template): array
    {
        if (isset($template['PartChar']) && is_array($template['PartChar'])) {
            unset($template['PartChar']['hostname'], $template['PartChar']['ip']);
        }

        return $template;
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    public function getAttachmentRows(EquipmentDelivery $delivery): array
    {
        $attachments = DeskAttachments::find()
            ->alias('da')
            ->innerJoin(
                ['l' => 'equipment_delivery_attachments'],
                'l.attachment_id = da.id AND l.delivery_id = :did',
                [':did' => (int) $delivery->id]
            )
            ->orderBy(['da.uploaded_at' => SORT_DESC])
            ->all();

        $rows = [];
        foreach ($attachments as $attachment) {
            $rows[] = $this->formatAttachmentRow($attachment);
        }

        return $rows;
    }

    /**
     * @param UploadedFile[] $files
     * @return array{success: bool, message: string, attachments?: array, errors?: string[]}
     */
    public function uploadAttachments(EquipmentDelivery $delivery, array $files): array
    {
        if (!$delivery->canEditAttachments()) {
            return ['success' => false, 'message' => 'Документы нельзя добавить к закрытой поставке.'];
        }

        $files = array_values(array_filter($files, static function ($file): bool {
            return $file instanceof UploadedFile;
        }));
        if ($files === []) {
            return ['success' => false, 'message' => 'Выберите файлы для загрузки.'];
        }

        $currentCount = (int) EquipmentDeliveryAttachment::find()
            ->where(['delivery_id' => $delivery->id])
            ->count();
        $maxFiles = EquipmentDelivery::getAttachmentMaxFiles();
        if ($currentCount >= $maxFiles) {
            return ['success' => false, 'message' => 'Достигнут лимит файлов (' . $maxFiles . ').'];
        }

        $allowed = EquipmentDelivery::getAttachmentExtensions();
        DeskAttachments::ensureUploadDirectory('deliveries');
        $uploaded = 0;
        $errors = [];

        foreach ($files as $file) {
            if ($currentCount + $uploaded >= $maxFiles) {
                break;
            }
            $ext = strtolower((string) $file->extension);
            if (!in_array($ext, $allowed, true)) {
                $errors[] = $file->name . ': недопустимый тип файла';
                continue;
            }
            $fileName = time() . '_' . uniqid('', true) . '_' . $file->baseName . '.' . $file->extension;
            $relativePath = DeskAttachments::buildStoragePath('deliveries', $fileName);
            $fullPath = DeskAttachments::resolveStoragePath($relativePath);
            if (!$file->saveAs($fullPath)) {
                $errors[] = $file->name . ': не удалось сохранить';
                continue;
            }
            $att = new DeskAttachments();
            $att->storage_path = $relativePath;
            $att->original_name = $file->baseName . '.' . $file->extension;
            $att->file_extension = $file->extension;
            $att->mime_type = $file->type;
            $att->size_bytes = (int) $file->size;
            $att->uploaded_by = Yii::$app->user->isGuest ? null : (int) Yii::$app->user->id;
            $att->uploaded_at = date('Y-m-d H:i:s');
            if (!$att->save(false)) {
                @unlink($fullPath);
                $errors[] = $file->name . ': ошибка записи в БД';
                continue;
            }
            $delivery->addAttachment((int) $att->id);
            $uploaded++;
        }

        if ($uploaded === 0) {
            return [
                'success' => false,
                'message' => 'Не удалось загрузить файлы.',
                'errors' => $errors,
            ];
        }

        $message = $uploaded === 1 ? 'Файл загружен.' : 'Загружено файлов: ' . $uploaded . '.';
        if ($errors !== []) {
            $message .= ' ' . implode('; ', array_slice($errors, 0, 3));
        }

        return [
            'success' => true,
            'message' => $message,
            'attachments' => $this->getAttachmentRows($delivery),
        ];
    }

    /**
     * @return array{success: bool, message: string, attachments?: array}
     */
    public function deleteAttachment(EquipmentDelivery $delivery, int $attachmentId): array
    {
        if (!$delivery->canEditAttachments()) {
            return ['success' => false, 'message' => 'Документы нельзя удалить у закрытой поставки.'];
        }

        $linked = EquipmentDeliveryAttachment::find()
            ->where(['delivery_id' => $delivery->id, 'attachment_id' => $attachmentId])
            ->exists();
        if (!$linked) {
            return ['success' => false, 'message' => 'Вложение не найдено.'];
        }

        $attachment = DeskAttachments::findOne($attachmentId);
        $delivery->removeAttachment($attachmentId);
        if ($attachment) {
            $attachment->delete();
        }

        return [
            'success' => true,
            'message' => 'Файл удалён.',
            'attachments' => $this->getAttachmentRows($delivery),
        ];
    }

    public function deliveryOwnsAttachment(int $deliveryId, int $attachmentId): bool
    {
        return EquipmentDeliveryAttachment::find()
            ->where(['delivery_id' => $deliveryId, 'attachment_id' => $attachmentId])
            ->exists();
    }

    /**
     * @return array<string, mixed>
     */
    private function formatAttachmentRow(DeskAttachments $attachment): array
    {
        return [
            'id' => (int) $attachment->id,
            'original_name' => $attachment->original_name,
            'file_extension' => $attachment->file_extension,
            'size_label' => $attachment->getFormattedFileSize(),
            'icon' => $attachment->getFileIcon(),
            'is_preview' => $attachment->isImageOrScan(),
            'uploaded_at' => $attachment->uploaded_at,
        ];
    }
}
