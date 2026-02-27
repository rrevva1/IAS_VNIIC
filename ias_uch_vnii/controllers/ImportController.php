<?php

namespace app\controllers;

use app\models\entities\Equipment;
use app\models\entities\Location;
use app\models\entities\Users;
use app\models\entities\EquipHistory;
use app\models\entities\PartCharValues;
use app\models\dictionaries\DicEquipmentStatus;
use Yii;
use yii\filters\AccessControl;
use yii\web\Controller;
use yii\web\UploadedFile;
use PhpOffice\PhpSpreadsheet\IOFactory;

/**
 * Импорт данных из Excel (лист АРМ) и универсальный импорт (CSV, JSON, XML, XLSX). Только для администраторов.
 */
class ImportController extends Controller
{
    public function behaviors()
    {
        return [
            'access' => [
                'class' => AccessControl::class,
                'rules' => [
                    [
                        'allow' => true,
                        'roles' => ['@'],
                        'matchCallback' => function () {
                            return Yii::$app->user->identity && Yii::$app->user->identity->isAdministrator();
                        },
                    ],
                ],
            ],
        ];
    }

    public function actionIndex()
    {
        $message = '';
        $protocol = [];
        if (Yii::$app->request->isPost) {
            $file = UploadedFile::getInstanceByName('excel_file');
            if ($file && in_array(strtolower($file->extension), ['xlsx', 'xls'], true)) {
                $protocol = $this->processFile($file->tempName);
                $message = 'Обработано строк: ' . ($protocol['success'] ?? 0) . ', ошибок: ' . ($protocol['errors'] ?? 0);
            } else {
                $message = 'Выберите файл Excel (.xlsx или .xls).';
            }
        }
        return $this->render('index', ['message' => $message, 'protocol' => $protocol]);
    }

    /**
     * Универсальный импорт: CSV, JSON, XML, XLSX (UTF-8). Сущность: equipment.
     * Формирует протокол: количество обработанных, ошибок, перечень ошибок.
     */
    public function actionUniversal()
    {
        $message = '';
        $protocol = ['success' => 0, 'errors' => 0, 'messages' => []];
        if (Yii::$app->request->isPost) {
            $file = UploadedFile::getInstanceByName('import_file');
            $format = (string) Yii::$app->request->post('format', 'csv');
            $entity = (string) Yii::$app->request->post('entity', 'equipment');
            if (!$file) {
                $message = 'Выберите файл.';
            } elseif (!in_array($format, ['csv', 'json', 'xml', 'xlsx'], true)) {
                $message = 'Укажите формат: csv, json, xml или xlsx.';
            } elseif (!in_array($entity, ['equipment'], true)) {
                $message = 'Поддерживается сущность: equipment.';
            } else {
                $path = $file->tempName;
                $rows = $this->parseUniversalFile($path, $format);
                if ($rows === null) {
                    $protocol['errors']++;
                    $protocol['messages'][] = 'Ошибка разбора файла. Проверьте кодировку (UTF-8) и формат.';
                } else {
                    $protocol = $entity === 'equipment' ? $this->importEquipmentRows($rows) : $protocol;
                }
                $message = 'Обработано: ' . ($protocol['success'] ?? 0) . ', ошибок: ' . ($protocol['errors'] ?? 0);
            }
        }
        return $this->render('universal', ['message' => $message, 'protocol' => $protocol]);
    }

    /**
     * Парсинг файла в массив строк (каждая строка — ассоциативный массив полей).
     * @return array|null null при ошибке
     */
    private function parseUniversalFile(string $path, string $format): ?array
    {
        try {
            if ($format === 'csv') {
                return $this->parseCsv($path);
            }
            if ($format === 'json') {
                $raw = file_get_contents($path);
                if ($raw === false) {
                    return null;
                }
                $data = json_decode($raw, true);
                if (!is_array($data)) {
                    return null;
                }
                if (isset($data[0]) && is_array($data[0])) {
                    return $data;
                }
                if (isset($data['items']) && is_array($data['items'])) {
                    return $data['items'];
                }
                return [$data];
            }
            if ($format === 'xml') {
                return $this->parseXml($path);
            }
            if ($format === 'xlsx') {
                return $this->parseXlsx($path);
            }
        } catch (\Throwable $e) {
            Yii::warning('Universal import parse error: ' . $e->getMessage());
            return null;
        }
        return null;
    }

    private function parseCsv(string $path): array
    {
        $rows = [];
        $content = file_get_contents($path);
        if ($content === false) {
            return [];
        }
        $enc = mb_detect_encoding($content, ['UTF-8', 'Windows-1251'], true);
        if ($enc && $enc !== 'UTF-8') {
            $content = mb_convert_encoding($content, 'UTF-8', $enc);
        }
        $line1 = strtok($content, "\n");
        $delim = (strpos($line1, ';') !== false) ? ';' : ',';
        $header = str_getcsv($line1, $delim);
        $header = array_map('trim', $header);
        while (($line = strtok("\n")) !== false) {
            $line = trim($line);
            if ($line === '') {
                continue;
            }
            $line = str_getcsv($line, $delim);
            $row = [];
            foreach ($header as $i => $key) {
                $row[$key] = isset($line[$i]) ? trim($line[$i]) : '';
            }
            $rows[] = $row;
        }
        return $rows;
    }

    private function parseXml(string $path): array
    {
        $xml = @simplexml_load_file($path);
        if ($xml === false) {
            return [];
        }
        $rows = [];
        $list = $xml->item ?? $xml->row ?? $xml->equipment ?? $xml->record ?? $xml->children();
        foreach ($list as $node) {
            $row = [];
            foreach ($node->children() as $name => $child) {
                $row[(string) $name] = (string) $child;
            }
            $rows[] = $row;
        }
        return $rows;
    }

    private function parseXlsx(string $path): array
    {
        $spreadsheet = IOFactory::load($path);
        $sheet = $spreadsheet->getSheet(0);
        $rows = [];
        $highestRow = $sheet->getHighestRow();
        $highestCol = $sheet->getHighestDataColumn();
        $colIndex = \PhpOffice\PhpSpreadsheet\Cell\Coordinate::columnIndexFromString($highestCol);
        $header = [];
        for ($c = 1; $c <= $colIndex; $c++) {
            $header[$c] = trim((string) $sheet->getCellByColumnAndRow($c, 1)->getValue());
        }
        for ($r = 2; $r <= $highestRow; $r++) {
            $row = [];
            foreach ($header as $c => $key) {
                $row[$key] = trim((string) $sheet->getCellByColumnAndRow($c, $r)->getValue());
            }
            $rows[] = $row;
        }
        return $rows;
    }

    /**
     * Импорт строк в equipment. Ожидаемые поля в строке: inventory_number (или inv), name, location (название помещения), опционально description, status_id.
     */
    private function importEquipmentRows(array $rows): array
    {
        $protocol = ['success' => 0, 'errors' => 0, 'messages' => []];
        $defaultStatusId = DicEquipmentStatus::getDefaultId();
        foreach ($rows as $idx => $row) {
            $n = $idx + 1;
            $inv = isset($row['inventory_number']) ? trim((string) $row['inventory_number']) : (isset($row['inv']) ? trim((string) $row['inv']) : '');
            $name = isset($row['name']) ? trim((string) $row['name']) : '';
            $locationName = isset($row['location']) ? trim((string) $row['location']) : (isset($row['location_name']) ? trim((string) $row['location_name']) : '');
            if ($inv === '' && $name === '') {
                continue;
            }
            if ($inv === '') {
                $inv = 'IMP-' . $n . '-' . substr(uniqid(), -6);
            }
            if (mb_strlen($inv) > 100) {
                $protocol['errors']++;
                $protocol['messages'][] = "Строка $n: инв. номер длиннее 100 символов";
                continue;
            }
            if ($name === '') {
                $name = $inv;
            }
            if (mb_strlen($name) > 200) {
                $name = mb_substr($name, 0, 200);
            }
            $locationId = null;
            if ($locationName !== '') {
                $loc = Location::find()->where(['name' => $locationName])->one();
                if (!$loc) {
                    $loc = new Location();
                    $loc->name = $locationName;
                    $loc->location_type = 'кабинет';
                    if (!$loc->save(false)) {
                        $protocol['errors']++;
                        $protocol['messages'][] = "Строка $n: не удалось создать локацию «$locationName»";
                        continue;
                    }
                }
                $locationId = $loc->id;
            }
            if ($locationId === null) {
                $protocol['errors']++;
                $protocol['messages'][] = "Строка $n: не указано помещение (location)";
                continue;
            }
            $statusId = isset($row['status_id']) ? (int) $row['status_id'] : $defaultStatusId;
            $description = isset($row['description']) ? trim((string) $row['description']) : null;
            if ($description !== null && mb_strlen($description) > 65535) {
                $description = mb_substr($description, 0, 65535);
            }
            $equip = Equipment::find()->where(['inventory_number' => $inv])->one();
            if (!$equip) {
                $equip = new Equipment();
                $equip->inventory_number = $inv;
                $equip->name = $name;
                $equip->status_id = $statusId;
                $equip->location_id = $locationId;
                $equip->description = $description;
                if (!$equip->save(false)) {
                    $protocol['errors']++;
                    $protocol['messages'][] = "Строка $n: ошибка сохранения (инв. $inv): " . implode(', ', $equip->getFirstErrors());
                    continue;
                }
                EquipHistory::log($equip->id, 'create', null, ['inventory_number' => $inv]);
            } else {
                $equip->name = $name;
                $equip->status_id = $statusId;
                $equip->location_id = $locationId;
                if ($description !== null) {
                    $equip->description = $description;
                }
                $equip->save(false);
            }
            $protocol['success']++;
        }
        return $protocol;
    }

    /**
     * Обработка файла по регламенту (лист АРМ). Упрощённый маппинг: колонки 0=Пользователь, 2=Помещение, 3=ЦП, 4=ОЗУ, 5=Диск, 6=Системный блок, 8=№ системн. блока.
     */
    private function processFile(string $path): array
    {
        $protocol = ['success' => 0, 'errors' => 0, 'messages' => []];
        try {
            $spreadsheet = IOFactory::load($path);
            $sheet = $spreadsheet->getSheetByName('АРМ') ?: $spreadsheet->getSheet(0);
            $highestRow = $sheet->getHighestRow();
            $defaultStatusId = \app\models\dictionaries\DicEquipmentStatus::getDefaultId();
            for ($row = 2; $row <= $highestRow; $row++) {
                $userName = trim((string) $sheet->getCellByColumnAndRow(1, $row)->getValue());
                $room = trim((string) $sheet->getCellByColumnAndRow(3, $row)->getValue());
                $cpu = trim((string) $sheet->getCellByColumnAndRow(4, $row)->getValue());
                $ram = trim((string) $sheet->getCellByColumnAndRow(5, $row)->getValue());
                $disk = trim((string) $sheet->getCellByColumnAndRow(6, $row)->getValue());
                $systemBlock = trim((string) $sheet->getCellByColumnAndRow(7, $row)->getValue());
                $invNumber = trim((string) $sheet->getCellByColumnAndRow(9, $row)->getValue());
                if ($invNumber === '' && $systemBlock === '') {
                    continue;
                }
                $locationId = null;
                if ($room !== '') {
                    $loc = Location::find()->where(['name' => (string) $room])->one();
                    if (!$loc) {
                        $loc = new Location();
                        $loc->name = (string) $room;
                        $loc->location_type = 'кабинет';
                        if (!$loc->save(false)) {
                            $protocol['errors']++;
                            $protocol['messages'][] = "Строка $row: не удалось создать локацию «$room»";
                            continue;
                        }
                    }
                    $locationId = $loc->id;
                } else {
                    $protocol['messages'][] = "Строка $row: пустое помещение, пропуск";
                    continue;
                }
                $userId = null;
                if ($userName !== '') {
                    $parts = explode("\n", $userName);
                    $userName = trim($parts[0]);
                    $user = Users::find()->where(['full_name' => $userName])->one();
                    if (!$user) {
                        $user = new Users();
                        $user->full_name = $userName;
                        $user->username = 'import_' . preg_replace('/\s+/', '_', $userName) . '_' . $row;
                        if (!$user->save(false)) {
                            $protocol['messages'][] = "Строка $row: не удалось создать пользователя «$userName»";
                        } else {
                            $userId = $user->id;
                        }
                    } else {
                        $userId = $user->id;
                    }
                }
                if ($invNumber === '') {
                    $invNumber = 'IMP-' . $row . '-' . uniqid();
                }
                $equip = Equipment::find()->where(['inventory_number' => $invNumber])->one();
                if (!$equip) {
                    $equip = new Equipment();
                    $equip->inventory_number = $invNumber;
                    $equip->name = $systemBlock ?: $invNumber;
                    $equip->status_id = $defaultStatusId;
                    $equip->location_id = $locationId;
                    $equip->responsible_user_id = $userId;
                    if (!$equip->save(false)) {
                        $protocol['errors']++;
                        $protocol['messages'][] = "Строка $row: ошибка сохранения оборудования (инв. $invNumber)";
                        continue;
                    }
                    EquipHistory::log($equip->id, 'create', null, ['inventory_number' => $invNumber]);
                } else {
                    $equip->location_id = $locationId;
                    $equip->responsible_user_id = $userId;
                    $equip->name = $systemBlock ?: $equip->name;
                    $equip->save(false);
                }
                $protocol['success']++;
            }
        } catch (\Throwable $e) {
            $protocol['errors']++;
            $protocol['messages'][] = 'Исключение: ' . $e->getMessage();
        }
        return $protocol;
    }
}
