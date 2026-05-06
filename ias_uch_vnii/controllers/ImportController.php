<?php

namespace app\controllers;

use app\models\entities\Equipment;
use app\models\entities\Location;
use app\models\entities\Users;
use app\models\entities\EquipHistory;
use app\models\entities\PartCharValues;
use Yii;
use yii\filters\AccessControl;
use yii\web\Controller;
use yii\web\UploadedFile;
use PhpOffice\PhpSpreadsheet\IOFactory;

/**
 * Импорт данных из Excel (лист АРМ). Только для администраторов.
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
