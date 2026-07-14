<?php

namespace app\controllers;

use app\models\entities\Equipment;
use app\models\entities\EquipmentTypes;
use app\models\entities\EquipmentLink;
use app\models\entities\EquipmentImportLog;
use app\models\entities\EquipHistory;
use app\models\entities\DeskAttachments;
use app\models\entities\PartCharValues;
use app\models\entities\SprParts;
use app\models\entities\SprChars;
use app\models\entities\Users;
use app\models\entities\Location;
use app\models\dictionaries\DicEquipmentStatus;
use app\models\search\ArmSearch;
use app\components\AuditLog;
use app\components\EquipmentAttachmentService;
use app\components\EquipmentCharCatalog;
use app\components\EquipmentKitHelper;
use app\components\EquipmentPartCharService;
use app\components\EquipmentReplacementService;
use app\components\UserEquipmentCardService;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use PhpOffice\PhpSpreadsheet\IOFactory;
use Yii;
use yii\filters\AccessControl;
use yii\filters\VerbFilter;
use yii\helpers\ArrayHelper;
use yii\web\Controller;
use yii\web\Response;
use yii\web\NotFoundHttpException;
use yii\web\UploadedFile;

/**
 * ArmController — учёт техники (оборудование, таблица equipment).
 * Доступен только администраторам.
 * Колонки грида соответствуют Основному учёту: Пользователь, Помещение, ЦП, ОЗУ, Диск,
 * Системный блок, Инв. №, Монитор, Имя ПК, IP адрес, ОС, Комментарий (см. docs/МАППИНГ_КОЛОНОК_УЧЕТ_ТС.md).
 */
class ArmController extends Controller
{
    private EquipmentAttachmentService $equipmentAttachmentService;

    public function init()
    {
        parent::init();
        $this->equipmentAttachmentService = new EquipmentAttachmentService();
    }

    public function behaviors()
    {
        return [
            'access' => [
                'class' => AccessControl::class,
                'rules' => [
                    [
                        'actions' => ['create', 'create-modal', 'delete', 'reassign', 'get-selected-info', 'system-blocks', 'user-primary-location', 'link-components', 'issue-kit', 'issue-kit-options', 'replace-options', 'export-xlsx', 'import-template-xlsx', 'import-preview', 'import-apply'],
                        'allow' => true,
                        'roles' => ['@'],
                        'matchCallback' => function () {
                            return Yii::$app->user->identity && Yii::$app->user->identity->isAdministrator();
                        },
                    ],
                    [
                        'allow' => true,
                        'roles' => ['@'],
                        'matchCallback' => function () {
                            return Yii::$app->user->identity && Yii::$app->user->identity->canAccessArm();
                        },
                    ],
                ],
                'denyCallback' => function () {
                    throw new \yii\web\ForbiddenHttpException('Доступ запрещён.');
                },
            ],
            'verbs' => [
                'class' => VerbFilter::class,
                'actions' => [
                    'delete' => ['POST'],
                    'update' => ['GET', 'POST'],
                    'update-modal' => ['GET', 'POST'],
                    'reassign' => ['POST'],
                    'get-selected-info' => ['POST'],
                    'link-components' => ['POST'],
                    'issue-kit' => ['POST'],
                    'issue-kit-options' => ['GET'],
                    'replace-options' => ['GET'],
                    'import-preview' => ['POST'],
                    'import-apply' => ['POST'],
                    'upload-photo' => ['POST'],
                    'delete-photo' => ['POST'],
                ],
            ],
        ];
    }

    /**
     * Список ТС: страница с AG Grid (данные подгружаются через actionGetGridData).
     */
    public function actionIndex()
    {
        return $this->renderEquipmentListPage('exclude_warehouse', 'Учет ТС', ['arm/get-grid-data'], ['arm/export-xlsx']);
    }

    /**
     * @param string[] $gridDataRoute
     * @param string[] $exportRoute
     */
    protected function renderEquipmentListPage(
        string $locationScope,
        string $pageTitle,
        array $gridDataRoute,
        array $exportRoute
    ): string {
        $equipmentTypes = EquipmentTypes::getListForTabs($locationScope);
        $users = ArrayHelper::map(
            Users::find()->orderBy(['full_name' => SORT_ASC])->all(),
            'id',
            function (Users $u) { return $u->getDisplayName(); }
        );
        $locations = ArrayHelper::map(Location::find()->orderBy(['name' => SORT_ASC])->all(), 'id', 'name');
        $warehouseLocations = ArrayHelper::map(
            Location::find()->where(['location_type' => 'склад'])->orderBy(['name' => SORT_ASC])->all(),
            'id',
            'name'
        );
        $statuses = DicEquipmentStatus::getList();
        $isAdmin = !Yii::$app->user->isGuest
            && Yii::$app->user->identity
            && Yii::$app->user->identity->isAdministrator();

        $hideAllEquipmentTab = $locationScope === 'warehouse_only';
        $defaultEquipmentTypeId = '';
        if ($hideAllEquipmentTab && $equipmentTypes !== []) {
            $defaultEquipmentTypeId = (string) ($equipmentTypes[0]['id'] ?? '');
        }

        return $this->render('@app/views/arm/index', [
            'pageTitle' => $pageTitle,
            'locationScope' => $locationScope,
            'gridDataRoute' => $gridDataRoute,
            'exportRoute' => $exportRoute,
            'hideAllEquipmentTab' => $hideAllEquipmentTab,
            'defaultEquipmentTypeId' => $defaultEquipmentTypeId,
            'equipmentTypes' => $equipmentTypes,
            'users' => $users,
            'locations' => $locations,
            'warehouseLocations' => $warehouseLocations,
            'statuses' => $statuses,
            'isAdmin' => $isAdmin,
        ]);
    }

    /**
     * Список типов техники для вкладок (из уникальных equipment.equipment_type, как в дампе).
     * Возвращает [['id' => тип, 'name' => тип], ...]
     *
     * @deprecated use EquipmentTypes::getListForTabs($locationScope)
     */
    private function getEquipmentTypesForTabs(?string $locationScope = null): array
    {
        return EquipmentTypes::getListForTabs($locationScope);
    }

    /**
     * JSON для AG Grid учёта ТС.
     * Поля соответствуют колонкам Основного учёта (маппинг — в docs/МАППИНГ_КОЛОНОК_УЧЕТ_ТС.md).
     * ЦП, ОЗУ, Диск, Монитор, Имя ПК, IP, ОС подтягиваются из part_char_values при наличии таблиц.
     */
    public function actionGetGridData()
    {
        return $this->buildGridDataJsonResponse('exclude_warehouse');
    }

    /**
     * @param string $defaultLocationScope exclude_warehouse|warehouse_only
     */
    protected function buildGridDataJsonResponse(string $defaultLocationScope): array
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        try {
            $params = Yii::$app->request->queryParams;
            $params['ArmSearch'] = $params['ArmSearch'] ?? [];
            $scopeFromRequest = trim((string) ($params['location_scope'] ?? $params['ArmSearch']['location_scope'] ?? ''));
            $params['ArmSearch']['location_scope'] = $scopeFromRequest !== ''
                ? $scopeFromRequest
                : $defaultLocationScope;
            // Вкладки передают equipment_type в корне; ArmSearch ожидает ArmSearch[equipment_type]. Для «Вся техника» не передаём пустое значение.
            $eqType = isset($params['equipment_type']) ? trim((string) $params['equipment_type']) : '';
            if ($eqType !== '') {
                $params['ArmSearch'] = $params['ArmSearch'] ?? [];
                $params['ArmSearch']['equipment_type'] = $eqType;
            }
            $filterModelRaw = isset($params['filterModel']) ? trim((string) $params['filterModel']) : '';
            $sortModelRaw = isset($params['sortModel']) ? trim((string) $params['sortModel']) : '';
            if ($filterModelRaw !== '') {
                $params['ArmSearch'] = $params['ArmSearch'] ?? [];
                $params['ArmSearch']['ag_filter_model'] = $filterModelRaw;
            }
            if ($sortModelRaw !== '') {
                $params['ArmSearch'] = $params['ArmSearch'] ?? [];
                $params['ArmSearch']['ag_sort_model'] = $sortModelRaw;
            }
            $quickSearch = isset($params['quickSearch']) ? trim((string) $params['quickSearch']) : '';
            if ($quickSearch !== '') {
                $params['ArmSearch'] = $params['ArmSearch'] ?? [];
                $params['ArmSearch']['quick_search'] = $quickSearch;
            }

            $searchModel = new ArmSearch();
            $dataProvider = $searchModel->search($params);
            $dataProvider->pagination = false;

            $showTypeWithNameInGrid = trim((string) $searchModel->equipment_type) === '';

            $total = (int) $dataProvider->getTotalCount();
            $models = $dataProvider->getModels();
            $charsByEquipment = $this->loadPartCharValuesByEquipment(
                array_map(function ($m) { return $m->id; }, $models)
            );
            $linksByParent = $this->loadLinkedComponents(
                array_map(function ($m) { return (int) $m->id; }, $models)
            );
            $data = [];
            foreach ($models as $model) {
                $chars = $charsByEquipment[$model->id] ?? [];
                $linked = $linksByParent[(int) $model->id] ?? ['monitor' => [], 'disk' => [], 'ups' => []];
                $hasLinkedMonitors = !empty($linked['monitor']);
                $monitorCharForGrid = $hasLinkedMonitors ? (string) ($chars['monitor'] ?? '') : '';
                // Встроенные накопители ПК — в part_char_values; связи equipment_links — отдельные единицы учёта.
                $diskLines = EquipmentCharCatalog::formatDiskGridLines(
                    (string) ($chars['disk'] ?? ''),
                    $linked['disk']
                );
                $statusName = $model->equipmentStatus ? (string) $model->equipmentStatus->status_name : '';
                $statusCode = $model->equipmentStatus ? (string) $model->equipmentStatus->status_code : '';
                $row = [
                    'id' => $model->id,
                    'is_host' => EquipmentKitHelper::isHostEquipment($model),
                    'user_name' => $model->responsibleUser ? $model->responsibleUser->getDisplayName() : '',
                    'location_name' => $model->location ? $model->location->name : '',
                    'status_id' => (int) $model->status_id,
                    'status_name' => $statusName,
                    'status_code' => $statusCode,
                    'status_color' => $this->resolveStatusColor($statusCode, $statusName),
                    'cpu' => $chars['cpu'] ?? '',
                    'ram' => $chars['ram'] ?? '',
                    'disk' => $diskLines !== [] ? implode("\n", $diskLines) : '',
                    'disk_lines' => $diskLines,
                    'system_block' => $showTypeWithNameInGrid
                        ? $this->formatEquipmentTypeAndNameForGrid($model)
                        : (string) ($model->name ?? ''),
                    'inventory_number' => $model->inventory_number ?? '',
                    'purchase_date' => $this->formatPurchaseDateForGrid($model),
                    'monitor' => EquipmentCharCatalog::formatMonitorColumnValue(
                        $monitorCharForGrid,
                        $linked['monitor']
                    ),
                    'monitor_char' => $monitorCharForGrid,
                    'monitor_list' => $linked['monitor'],
                    'disk_list' => $linked['disk'],
                    'ups' => EquipmentCharCatalog::formatMonitorColumnValue('', $linked['ups']),
                    'ups_list' => $linked['ups'],
                    'hostname' => $chars['hostname'] ?? '',
                    'ip' => $this->formatIpForGrid($model, $chars),
                    'os' => $chars['os'] ?? '',
                    'screen_diagonal' => $chars['screen_diagonal'] ?? '',
                    'cartridge_procurement' => $this->formatCartridgeProcurementForGrid($model),
                    'other_tech' => $this->formatOtherTechForGrid($model, $chars),
                ];
                foreach (EquipmentCharCatalog::getArmGridExtraPartCharFields() as $extraField) {
                    $row[$extraField] = $chars[$extraField] ?? '';
                }
                $data[] = $row;
            }
            return ['success' => true, 'data' => $data, 'total' => $total];
        } catch (\Exception $e) {
            return ['success' => false, 'message' => $e->getMessage(), 'data' => [], 'total' => 0];
        }
    }

    /**
     * Загружает значения из part_char_values по списку id оборудования.
     * Поддерживаются схемы: part_char_values.id_arm = equipment.id или part_char_values.equipment_id = equipment.id.
     * Возвращает [ equipment_id => [ 'cpu' => ..., 'ram' => ..., ... ], ... ].
     */
    private function loadPartCharValuesByEquipment(array $equipmentIds): array
    {
        if (empty($equipmentIds)) {
            return [];
        }
        $db = Yii::$app->db;
        $idCol = 'id_arm';
        try {
            $schema = $db->getTableSchema('part_char_values', true);
            if (!$schema) {
                return array_fill_keys($equipmentIds, []);
            }
            if (isset($schema->columns['equipment_id'])) {
                $idCol = 'equipment_id';
            }
        } catch (\Throwable $e) {
            return array_fill_keys($equipmentIds, []);
        }
        try {
            $rows = (new \yii\db\Query())
                ->select([
                    'eq_id' => 'pcv.' . $idCol,
                    'part_name' => 'sp.name',
                    'char_name' => 'sc.name',
                    'value_text' => new \yii\db\Expression('COALESCE(pcv.value_text, pcv.value_num::text)'),
                ])
                ->from(['pcv' => 'part_char_values'])
                ->innerJoin(['sp' => 'spr_parts'], 'sp.id = pcv.part_id')
                ->innerJoin(['sc' => 'spr_chars'], 'sc.id = pcv.char_id')
                ->where(['pcv.' . $idCol => $equipmentIds])
                // Ограничиваем выборку только релевантными частями (CPU/RAM/Disk/Monitor/ПК).
                // Это снижает количество строк, которые потом фильтруются в PHP.
                ->andWhere(new \yii\db\Expression(
                    "(" .
                    "sp.name IN ('ЦП', 'ОЗУ', 'Накопитель', 'Монитор', 'ПК') " .
                    "OR LOWER(sp.name) LIKE '%cpu%' " .
                    "OR LOWER(sp.name) LIKE '%процессор%' " .
                    "OR LOWER(sp.name) LIKE '%цпу%' " .
                    "OR LOWER(sp.name) LIKE '%цп%' " .
                    "OR LOWER(sp.name) LIKE '%оператив%' " .
                    "OR LOWER(sp.name) LIKE '%память%' " .
                    "OR LOWER(sp.name) LIKE '%озу%' " .
                    "OR LOWER(sp.name) LIKE '%ram%' " .
                    "OR LOWER(sp.name) LIKE '%диск%' " .
                    "OR LOWER(sp.name) LIKE '%накопитель%' " .
                    "OR LOWER(sp.name) LIKE '%жестк%' " .
                    "OR LOWER(sp.name) LIKE '%hdd%' " .
                    "OR LOWER(sp.name) LIKE '%ssd%' " .
                    "OR LOWER(sp.name) LIKE '%монитор%' " .
                    "OR LOWER(sp.name) LIKE '%пк%' " .
                    "OR LOWER(sp.name) LIKE '%компьют%' " .
                    "OR sp.name = 'Принтер' " .
                    "OR sp.name = 'Сканер' " .
                    "OR sp.name = 'Прочее' " .
                    "OR sp.name = 'ИБП' " .
                    "OR LOWER(sp.name) LIKE '%ибп%' " .
                    "OR LOWER(sp.name) LIKE '%ups%'" .
                    ")"
                ))
                ->all($db);
        } catch (\Throwable $e) {
            return array_fill_keys($equipmentIds, []);
        }
        $out = array_fill_keys($equipmentIds, []);
        foreach ($rows as $row) {
            $id = (int) $row['eq_id'];
            if (!isset($out[$id])) {
                continue;
            }
            $part = trim((string) $row['part_name']);
            $char = trim((string) $row['char_name']);
            $val = trim((string) ($row['value_text'] ?? ''));
            if ($val === '') {
                continue;
            }
            $p = mb_strtolower($part, 'UTF-8');
            $c = mb_strtolower($char, 'UTF-8');
            // Быстрый путь под текущие справочники БД (tech_accounting)
            if ($part === 'ЦП' && $char === 'Модель') {
                $out[$id]['cpu'] = $val;
                continue;
            }
            if ($part === 'ЦП' && $char === 'Количество процессоров') {
                $out[$id]['cpu_count'] = $val;
                continue;
            }
            if ($part === 'ОЗУ' && $char === 'Объём') {
                $out[$id]['ram'] = $val;
                continue;
            }
            if ($part === 'Накопитель') {
                $out[$id]['disk'] = isset($out[$id]['disk']) ? $out[$id]['disk'] . ', ' . $val : $val;
                continue;
            }
            if ($part === 'Монитор' && (strpos($c, 'диагональ') !== false)) {
                $out[$id]['screen_diagonal'] = $val;
                continue;
            }
            if ($part === 'Монитор' && ($char === 'Модель' || strpos($c, 'модель') !== false)) {
                $out[$id]['monitor'] = isset($out[$id]['monitor']) ? $out[$id]['monitor'] . ', ' . $val : $val;
                continue;
            }
            if ($part === 'Монитор' && (strpos($c, '№ монитора') !== false || (strpos($c, 'номер') !== false && strpos($c, 'диагональ') === false))) {
                $out[$id]['monitor_inv'] = isset($out[$id]['monitor_inv']) ? $out[$id]['monitor_inv'] . ', ' . $val : $val;
                continue;
            }
            if ($part === 'ПК' && $char === 'Имя ПК') {
                $out[$id]['hostname'] = $val;
                continue;
            }
            if ($part === 'ПК' && $char === 'IP адрес') {
                $out[$id]['ip'] = $val;
                continue;
            }
            if ($part === 'Принтер') {
                $printerKeys = EquipmentCharCatalog::getPrinterMfuPartCharKeyByCharName();
                if (isset($printerKeys[$char])) {
                    $out[$id][$printerKeys[$char]] = $val;
                    continue;
                }
                if ($char === 'IP адрес') {
                    $out[$id]['ip'] = $val;
                    continue;
                }
            }
            if ($part === 'Сканер') {
                $scannerKeys = EquipmentCharCatalog::getScannerPartCharKeyByCharName();
                if (isset($scannerKeys[$char])) {
                    $out[$id][$scannerKeys[$char]] = $val;
                }
                continue;
            }
            if ($part === 'Прочее') {
                $miscKeys = EquipmentCharCatalog::getMiscPartCharKeyByCharName();
                if (isset($miscKeys[$char])) {
                    $out[$id][$miscKeys[$char]] = $val;
                }
                continue;
            }
            if ($part === 'ПК' && $char === 'ОС') {
                $out[$id]['os'] = $val;
                continue;
            }
            if ($part === 'ИБП' && $char === 'Модель аккумулятора') {
                $out[$id]['ups_battery'] = $val;
                continue;
            }
            if ($part === 'ИБП' && $char === 'Дата замены аккумулятора') {
                $out[$id]['ups_battery_replaced_at'] = $val;
                continue;
            }
            if ($part === 'ИБП' && $char === 'Срок службы аккумулятора') {
                $out[$id]['ups_battery_service_life'] = $val;
                continue;
            }
            // ЦП (как в гриде) — в БД может быть: ЦП, Процессор, CPU и т.д.
            if (($p === 'цп' || $p === 'цпу' || strpos($p, 'процессор') !== false || $p === 'cpu') && (strpos($c, 'модель') !== false || strpos($c, 'частота') !== false)) {
                $out[$id]['cpu'] = isset($out[$id]['cpu']) ? $out[$id]['cpu'] . ' ' . $val : $val;
            } elseif (($p === 'озу' || strpos($p, 'оператив') !== false || strpos($p, 'память') !== false || $p === 'ram') && (strpos($c, 'объем') !== false || strpos($c, 'объём') !== false)) {
                $out[$id]['ram'] = $val;
            } elseif (strpos($p, 'диск') !== false || strpos($p, 'накопитель') !== false || strpos($p, 'жесткий') !== false || $p === 'hdd' || $p === 'ssd') {
                $out[$id]['disk'] = isset($out[$id]['disk']) ? $out[$id]['disk'] . ', ' . $val : $val;
            } elseif (strpos($p, 'монитор') !== false && strpos($c, 'диагональ') !== false) {
                $out[$id]['screen_diagonal'] = $val;
            } elseif (strpos($p, 'монитор') !== false && (strpos($c, 'модель') !== false || $c === '')) {
                $out[$id]['monitor'] = isset($out[$id]['monitor']) ? $out[$id]['monitor'] . ', ' . $val : $val;
            } elseif (strpos($p, 'монитор') !== false && (strpos($c, '№') !== false || strpos($c, 'номер') !== false)) {
                $out[$id]['monitor_inv'] = isset($out[$id]['monitor_inv']) ? $out[$id]['monitor_inv'] . ', ' . $val : $val;
            } elseif (strpos($c, 'имя пк') !== false || $c === 'hostname' || ($p === 'пк' && (strpos($c, 'имя') !== false || $c === 'hostname'))) {
                $out[$id]['hostname'] = $val;
            } elseif (strpos($c, 'ip') !== false && strpos($c, 'адрес') !== false || $c === 'ip') {
                $out[$id]['ip'] = $val;
            } elseif ($c === 'ос' || strpos($c, 'операционн') !== false) {
                $out[$id]['os'] = $val;
            } elseif (($p === 'ибп' || $p === 'ups' || strpos($p, 'ибп') !== false) && strpos($c, 'модель') !== false && strpos($c, 'аккумулятор') !== false) {
                $out[$id]['ups_battery'] = $val;
            } elseif (($p === 'ибп' || $p === 'ups' || strpos($p, 'ибп') !== false) && strpos($c, 'дата') !== false && strpos($c, 'замен') !== false && strpos($c, 'аккумулятор') !== false) {
                $out[$id]['ups_battery_replaced_at'] = $val;
            } elseif (($p === 'ибп' || $p === 'ups' || strpos($p, 'ибп') !== false) && strpos($c, 'срок') !== false && strpos($c, 'служб') !== false && strpos($c, 'аккумулятор') !== false) {
                $out[$id]['ups_battery_service_life'] = $val;
            }
        }
        return $out;
    }

    /**
     * Тон подсветки статуса в гриде: green | yellow | red | gray.
     */
    private function resolveStatusColor(string $statusCode, string $statusName): string
    {
        $code = mb_strtolower(trim($statusCode), 'UTF-8');
        $byCode = [
            'in_use' => 'green',
            'in_repair' => 'yellow',
            'faulty' => 'red',
            'writeoff' => 'red',
            'in_stock' => 'gray',
        ];
        if ($code !== '' && isset($byCode[$code])) {
            return $byCode[$code];
        }

        $s = mb_strtolower(trim($statusName), 'UTF-8');
        if (strpos($s, 'эксплуатац') !== false) {
            return 'green';
        }
        if (strpos($s, 'ремонт') !== false) {
            return 'yellow';
        }
        if (strpos($s, 'неисправ') !== false || strpos($s, 'списан') !== false) {
            return 'red';
        }
        if (strpos($s, 'склад') !== false || strpos($s, 'резерв') !== false) {
            return 'gray';
        }

        return 'gray';
    }

    private function isWarehouseLocationId(int $locationId): bool
    {
        $location = Location::findOne($locationId);
        if ($location === null) {
            return false;
        }

        return (string) $location->location_type === 'склад';
    }

    private function isEquipmentOnWarehouse(Equipment $model): bool
    {
        $locationId = $model->location_id;
        if ($locationId === null || (int) $locationId <= 0) {
            return false;
        }

        return $this->isWarehouseLocationId((int) $locationId);
    }

    /**
     * @param int[] $ids
     * @return array{success: bool, message: string, updated?: int, details?: array}
     */
    private function applyMoveToWarehouse(array $ids, int $warehouseLocationId): array
    {
        $updated = 0;
        $responsibleUserChanged = 0;
        $locationChanged = 0;
        $errors = [];

        $transaction = Yii::$app->db->beginTransaction();
        try {
            $linksDetached = $this->detachEquipmentLinksForWarehouseMoveBatch($ids);
            $this->clearHostKitBindingsAfterWarehouseMove($ids);

            foreach ($ids as $id) {
                $model = Equipment::findOne((int) $id);
                if (!$model || $model->is_deleted || $model->is_archived) {
                    $errors[] = ['equipment_id' => $id, 'message' => 'Оборудование не найдено'];
                    continue;
                }

                $changed = false;
                $oldResponsible = $model->responsible_user_id;
                $oldLocation = $model->location_id;
                if (!EquipHistory::idsEqual($model->location_id, $warehouseLocationId)) {
                    $model->location_id = $warehouseLocationId;
                    EquipHistory::log(
                        $model->id,
                        'move',
                        ['location_id' => $oldLocation],
                        ['location_id' => $model->location_id],
                        'move_to_warehouse'
                    );
                    $locationChanged++;
                    $changed = true;
                }

                if ($model->responsible_user_id !== null) {
                    $model->responsible_user_id = null;
                    EquipHistory::log(
                        $model->id,
                        'unassign',
                        ['responsible_user_id' => $oldResponsible],
                        ['responsible_user_id' => null],
                        'move_to_warehouse'
                    );
                    $responsibleUserChanged++;
                    $changed = true;
                }

                if ($changed && $model->save(false)) {
                    $updated++;
                    AuditLog::log('equipment.move_to_warehouse', 'equipment', $model->id, 'success');
                    UserEquipmentCardService::invalidateByUserId((int) $oldResponsible);
                    UserEquipmentCardService::ensureCardForUser((int) $oldResponsible);
                } elseif ($changed) {
                    $errors[] = ['equipment_id' => $id, 'message' => 'Ошибка при сохранении'];
                }
            }

            $transaction->commit();
        } catch (\Throwable $e) {
            $transaction->rollBack();

            return ['success' => false, 'message' => 'Ошибка перемещения на склад: ' . $e->getMessage()];
        }

        return [
            'success' => true,
            'message' => "На склад перемещено единиц техники: {$updated} из " . count($ids),
            'updated' => $updated,
            'details' => [
                'responsible_user_changed' => $responsibleUserChanged,
                'location_changed' => $locationChanged,
                'status_changed' => 0,
                'links_detached' => $linksDetached,
                'errors' => $errors,
            ],
        ];
    }

    /**
     * Снимает связи комплекта (СБ ↔ монитор/ИБП/диск) для всех перемещаемых на склад единиц.
     *
     * @param int[] $ids
     */
    private function detachEquipmentLinksForWarehouseMoveBatch(array $ids): int
    {
        if (Yii::$app->db->getTableSchema('equipment_links', true) === null) {
            return 0;
        }

        $ids = array_values(array_unique(array_filter(array_map('intval', $ids), static function (int $id): bool {
            return $id > 0;
        })));
        if ($ids === []) {
            return 0;
        }

        $links = EquipmentLink::find()
            ->where([
                'or',
                ['parent_equipment_id' => $ids],
                ['child_equipment_id' => $ids],
            ])
            ->all();

        $detached = 0;
        foreach ($links as $link) {
            $childId = (int) $link->child_equipment_id;
            $parentId = (int) $link->parent_equipment_id;
            $linkType = (string) $link->link_type;
            if ($link->delete()) {
                $detached++;
                EquipHistory::log(
                    $childId,
                    'update',
                    ['parent_equipment_id' => $parentId, 'link_type' => $linkType],
                    ['parent_equipment_id' => null, 'link_type' => null],
                    'move_to_warehouse_detach_kit'
                );
                AuditLog::log('equipment.move_to_warehouse', 'equipment', $childId, 'success', [
                    'action' => 'detach_kit_link',
                    'parent_id' => $parentId,
                    'link_type' => $linkType,
                ]);
                $this->clearHostKitPartCharsOnLinkDetach($parentId, $linkType);
            }
        }

        return $detached;
    }

    /**
     * @param int[] $ids
     */
    private function clearHostKitBindingsAfterWarehouseMove(array $ids): void
    {
        foreach ($ids as $id) {
            $model = Equipment::findOne((int) $id);
            if ($model === null || !$this->isHostEquipment($model)) {
                continue;
            }
            $this->clearHostPartCharsByPartName((int) $model->id, 'Монитор');
            $this->clearHostPartCharsByPartName((int) $model->id, 'ИБП');
        }
    }

    /**
     * Убирает с ПК дублирующие характеристики монитора/ИБП после снятия связи (иначе в гриде остаётся
     * неактивный текст без ссылки на карточку). Накопители в part_char не трогаем — это конфигурация ПК.
     */
    private function clearHostKitPartCharsOnLinkDetach(int $parentId, string $linkType): void
    {
        if ($parentId <= 0) {
            return;
        }

        $partName = match ($linkType) {
            EquipmentLink::TYPE_MONITOR => 'Монитор',
            EquipmentLink::TYPE_UPS => 'ИБП',
            default => null,
        };
        if ($partName === null) {
            return;
        }

        $this->clearHostPartCharsByPartName($parentId, $partName);
    }

    private function clearHostPartCharsByPartName(int $parentId, string $partName): void
    {
        if ($parentId <= 0 || Yii::$app->db->getTableSchema('part_char_values', true) === null) {
            return;
        }

        $part = SprParts::find()->where(['name' => $partName])->one();
        if ($part === null) {
            return;
        }

        $eqCol = $this->resolvePartCharEquipmentIdColumn();
        PartCharValues::deleteAll([
            $eqCol => $parentId,
            'part_id' => (int) $part->id,
        ]);
    }

    /**
     * Обычное переназначение: вместе с ПК/хостом переносятся привязанные монитор, диск, ИБП.
     *
     * @param int[] $ids
     * @return int[]
     */
    private function expandReassignIdsWithLinkedComponents(array $ids, string $operationMode): array
    {
        if ($operationMode !== 'reassign' || $ids === []) {
            return $ids;
        }

        if (Yii::$app->db->getTableSchema('equipment_links', true) === null) {
            return $ids;
        }

        $hostIds = [];
        $models = Equipment::find()
            ->where(['id' => $ids, 'is_deleted' => false, 'is_archived' => false])
            ->all();
        foreach ($models as $model) {
            if ($this->isHostEquipment($model)) {
                $hostIds[] = (int) $model->id;
            }
        }
        if ($hostIds === []) {
            return $ids;
        }

        $childIds = EquipmentLink::find()
            ->select('child_equipment_id')
            ->where(['parent_equipment_id' => $hostIds])
            ->column();
        $childIds = array_map('intval', $childIds);
        if ($childIds === []) {
            return $ids;
        }

        $activeChildIds = Equipment::find()
            ->select('id')
            ->where(['id' => $childIds, 'is_deleted' => false, 'is_archived' => false])
            ->column();

        return array_values(array_unique(array_merge($ids, array_map('intval', $activeChildIds))));
    }

    private function loadLinkedComponents(array $parentIds): array
    {
        if (empty($parentIds)) {
            return [];
        }
        $result = [];
        foreach ($parentIds as $pid) {
            $result[(int) $pid] = ['monitor' => [], 'disk' => [], 'ups' => []];
        }

        $linksSchema = Yii::$app->db->getTableSchema('equipment_links', true);
        if ($linksSchema === null) {
            return $result;
        }

        try {
            $rows = EquipmentLink::find()
                ->alias('l')
                ->select([
                    'l.parent_equipment_id',
                    'l.link_type',
                    'e.id AS child_id',
                    'e.name AS child_name',
                    'e.inventory_number AS child_inventory_number',
                    'e.description AS child_description',
                ])
                ->leftJoin(['e' => Equipment::tableName()], 'e.id = l.child_equipment_id')
                ->where(['l.parent_equipment_id' => $parentIds])
                ->asArray()
                ->all();
        } catch (\Throwable $e) {
            Yii::warning('loadLinkedComponents skipped: ' . $e->getMessage(), __METHOD__);
            return $result;
        }

        foreach ($rows as $row) {
            $pid = (int) $row['parent_equipment_id'];
            $type = (string) $row['link_type'];
            if (!isset($result[$pid][$type])) {
                continue;
            }
            $result[$pid][$type][] = [
                'id' => (int) $row['child_id'],
                'name' => (string) ($row['child_name'] ?? ''),
                'inventory_number' => (string) ($row['child_inventory_number'] ?? ''),
                'description' => (string) ($row['child_description'] ?? ''),
            ];
        }
        return $result;
    }

    /**
     * @deprecated Используйте модальное окно на странице списка (actionCreateModal).
     */
    public function actionCreate()
    {
        if (Yii::$app->request->isPost) {
            $model = new Equipment();
            $model->loadDefaultValues();
            $result = $this->persistNewEquipment($model, Yii::$app->request->post());
            if ($result['success']) {
                Yii::$app->session->setFlash('success', $result['message']);
                return $this->redirect(['index']);
            }
            Yii::$app->session->setFlash('error', $result['message']);
        }

        return $this->redirect(['index']);
    }

    /**
     * Создание техники в модальном окне (GET — форма, POST — JSON).
     */
    public function actionCreateModal()
    {
        $model = new Equipment();
        $model->loadDefaultValues();

        if (Yii::$app->request->isPost) {
            Yii::$app->response->format = Response::FORMAT_JSON;
            $result = $this->persistNewEquipment($model, Yii::$app->request->post());
            if ($result['success']) {
                return [
                    'success' => true,
                    'message' => $result['message'],
                    'equipment_id' => $result['equipment_id'],
                ];
            }

            return [
                'success' => false,
                'errors' => $result['errors'] ?? [],
                'message' => $result['message'],
            ];
        }

        return $this->renderAjax('_form', $this->getEquipmentFormViewParams($model, true));
    }

    /**
     * Редактирование техники в модальном окне (GET — форма, POST — JSON).
     */
    public function actionUpdateModal($id)
    {
        $model = $this->findModel((int) $id);
        $this->ensureCanEditEquipment($model);

        if (Yii::$app->request->isPost) {
            Yii::$app->response->format = Response::FORMAT_JSON;
            $result = $this->persistUpdatedEquipment($model, Yii::$app->request->post());
            if ($result['success']) {
                return [
                    'success' => true,
                    'message' => $result['message'],
                    'equipment_id' => $result['equipment_id'],
                ];
            }

            return [
                'success' => false,
                'errors' => $result['errors'] ?? [],
                'message' => $result['message'],
            ];
        }

        return $this->renderAjax('_form', $this->getEquipmentFormViewParams($model, true));
    }

    /**
     * @param array<string, mixed> $post
     * @return array{success: bool, message: string, equipment_id?: int, errors?: array}
     */
    private function persistNewEquipment(Equipment $model, array $post): array
    {
        if (!$model->load($post)) {
            return [
                'success' => false,
                'message' => 'Не удалось загрузить данные формы.',
                'errors' => $model->errors,
            ];
        }

        $this->applyOrgTechDescriptionFromPost($model);
        $partChar = is_array($post['PartChar'] ?? null) ? $post['PartChar'] : [];
        $this->syncMiscEquipmentDescriptionOnSave($model, $partChar);
        if (!$model->save()) {
            $firstErrors = $model->getFirstErrors();

            return [
                'success' => false,
                'message' => 'Не удалось сохранить технику'
                    . ($firstErrors ? ': ' . implode(' ', $firstErrors) : ''),
                'errors' => $model->errors,
            ];
        }

        $this->savePartCharValuesFromPost($model->id, $partChar);
        EquipHistory::log($model->id, 'create', null, [
            'inventory_number' => $model->inventory_number,
            'name' => $model->name,
        ]);
        AuditLog::log('equipment.create', 'equipment', $model->id, 'success');
        UserEquipmentCardService::ensureCardForUser((int) $model->responsible_user_id);

        return [
            'success' => true,
            'message' => 'Техника успешно добавлена.',
            'equipment_id' => (int) $model->id,
        ];
    }

    /**
     * @return array<string, mixed>
     */
    private function getEquipmentFormViewParams(Equipment $model, bool $isModal = false): array
    {
        $chars = [];
        if (!$model->isNewRecord) {
            $loaded = $this->loadPartCharValuesByEquipment([$model->id]);
            $chars = $loaded[$model->id] ?? [];
            $this->hydrateMiscCharsFromEquipment($model, $chars);
        }

        return [
            'model' => $model,
            'users' => ArrayHelper::map(
                Users::find()->orderBy(['full_name' => SORT_ASC])->all(),
                'id',
                static function (Users $u) {
                    return $u->getDisplayName();
                }
            ),
            'locations' => ArrayHelper::map(
                Location::find()->orderBy(['name' => SORT_ASC])->all(),
                'id',
                'name'
            ),
            'statuses' => DicEquipmentStatus::getList(),
            'equipmentTypes' => EquipmentTypes::getList(),
            'chars' => $chars,
            'cpuModels' => EquipmentCharCatalog::getDistinctCpuModels(),
            'ramModels' => EquipmentCharCatalog::getDistinctRamValues(),
            'osModels' => EquipmentCharCatalog::getDistinctOsValues(),
            'diskModels' => EquipmentCharCatalog::getDistinctDiskModels(),
            'supplierNames' => EquipmentCharCatalog::getDistinctSuppliers(),
            'ipAddresses' => EquipmentCharCatalog::getDistinctIpAddresses(),
            'upsBatteryModels' => EquipmentCharCatalog::getDistinctUpsBatteryModels(),
            'inventoryNumbers' => EquipmentCharCatalog::getDistinctInventoryNumbers(),
            'equipmentNames' => EquipmentCharCatalog::getDistinctEquipmentNames(),
            'screenDiagonalValues' => EquipmentCharCatalog::getDistinctScreenDiagonalValues(),
            'isModal' => $isModal,
            'photos' => $model->isNewRecord ? [] : $this->equipmentAttachmentService->getPhotoRows($model),
            'canEditPhotos' => $model->canEditPhotos(),
        ];
    }

    /**
     * @param array<string, mixed> $post
     * @return array{success: bool, message: string, equipment_id?: int, errors?: array}
     */
    private function persistUpdatedEquipment(Equipment $model, array $post): array
    {
        $preservedResponsible = $model->responsible_user_id;
        $preservedLocationId = $model->location_id;

        if (!$model->load($post)) {
            return [
                'success' => false,
                'message' => 'Не удалось загрузить данные формы.',
                'errors' => $model->errors,
            ];
        }

        $model->responsible_user_id = $preservedResponsible;
        $model->location_id = $preservedLocationId;
        $model->location_name = null;

        $this->applyOrgTechDescriptionFromPost($model);
        $partChar = is_array($post['PartChar'] ?? null) ? $post['PartChar'] : [];
        $this->syncMiscEquipmentDescriptionOnSave($model, $partChar);
        $oldStatus = $model->getOldAttribute('status_id');
        $oldLocation = $model->getOldAttribute('location_id');
        $oldResponsible = $model->getOldAttribute('responsible_user_id');

        if (!$model->save()) {
            $firstErrors = $model->getFirstErrors();

            return [
                'success' => false,
                'message' => 'Не удалось сохранить изменения'
                    . ($firstErrors ? ': ' . implode(' ', $firstErrors) : ''),
                'errors' => $model->errors,
            ];
        }

        $this->savePartCharValuesFromPost($model->id, $partChar);

        if (!EquipHistory::idsEqual($oldLocation, $model->location_id)) {
            EquipHistory::log($model->id, 'move', ['location_id' => $oldLocation], ['location_id' => $model->location_id]);
            UserEquipmentCardService::invalidateByUserId((int) $model->responsible_user_id);
        }
        if (!EquipHistory::idsEqual($oldResponsible, $model->responsible_user_id)) {
            EquipHistory::log(
                $model->id,
                $model->responsible_user_id ? 'assign' : 'unassign',
                ['responsible_user_id' => $oldResponsible],
                ['responsible_user_id' => $model->responsible_user_id]
            );
            UserEquipmentCardService::invalidateByUserId((int) $oldResponsible);
            UserEquipmentCardService::ensureCardForUser((int) $oldResponsible);
            UserEquipmentCardService::invalidateByUserId((int) $model->responsible_user_id);
            UserEquipmentCardService::ensureCardForUser((int) $model->responsible_user_id);
        }
        if (!EquipHistory::idsEqual($oldStatus, $model->status_id)) {
            EquipHistory::log($model->id, 'status_change', ['status_id' => $oldStatus], ['status_id' => $model->status_id]);
        }
        if (EquipHistory::idsEqual($oldStatus, $model->status_id)
            && EquipHistory::idsEqual($oldLocation, $model->location_id)
            && EquipHistory::idsEqual($oldResponsible, $model->responsible_user_id)) {
            EquipHistory::log($model->id, 'update', null, [
                'inventory_number' => $model->inventory_number,
                'name' => $model->name,
            ]);
        }

        AuditLog::log('equipment.update', 'equipment', $model->id, 'success');

        return [
            'success' => true,
            'message' => 'Данные техники обновлены.',
            'equipment_id' => (int) $model->id,
        ];
    }

    /**
     * Просмотр карточки актива.
     */
    public function actionView($id)
    {
        $model = $this->findModel((int) $id);
        $this->ensureCanAccessEquipment($model);

        return $this->redirect(['index', 'equipment' => $model->id]);
    }

    /**
     * Карточка техники для модального окна (GET — HTML).
     */
    public function actionViewModal($id)
    {
        $model = $this->findModel((int) $id);
        $this->ensureCanAccessEquipment($model);

        return $this->renderAjax('_view_content', array_merge(
            $this->getEquipmentViewParams($model),
            ['isModal' => true]
        ));
    }

    /**
     * @return array<string, mixed>
     */
    private function getEquipmentViewParams(Equipment $model): array
    {
        $chars = $this->loadPartCharValuesByEquipment([$model->id]);
        $charsForModel = $chars[$model->id] ?? [];
        $history = EquipHistory::find()
            ->where(['equipment_id' => $model->id])
            ->with('changedByUser')
            ->orderBy(['changed_at' => SORT_DESC])
            ->limit(50)
            ->all();

        $isHost = $this->isHostEquipment($model);
        $isOnWarehouse = $this->isEquipmentOnWarehouse($model);
        $linkedComponents = ['monitor' => [], 'disk' => [], 'ups' => []];
        $linkedComponentRows = [];
        if ($isHost && !$isOnWarehouse) {
            $linksByParent = $this->loadLinkedComponents([(int) $model->id]);
            $linkedComponents = $linksByParent[(int) $model->id] ?? $linkedComponents;
            $linkedComponentRows = EquipmentCharCatalog::buildHostLinkedComponentsViewRows(
                $linkedComponents,
                $charsForModel
            );
        }

        return [
            'model' => $model,
            'chars' => $charsForModel,
            'history' => $history,
            'isHost' => $isHost,
            'isOnWarehouse' => $isOnWarehouse,
            'linkedComponents' => $linkedComponents,
            'linkedComponentRows' => $linkedComponentRows,
            'photos' => $this->equipmentAttachmentService->getPhotoRows($model),
            'canEditPhotos' => $model->canEditPhotos(),
        ];
    }

    public function actionUploadPhoto($id)
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $model = $this->findModel((int) $id);
        $this->ensureCanEditEquipment($model);
        $files = UploadedFile::getInstancesByName('uploadPhotos');
        if ($files === []) {
            $single = UploadedFile::getInstanceByName('uploadPhotos');
            if ($single) {
                $files = [$single];
            }
        }

        return $this->equipmentAttachmentService->uploadPhotos($model, $files);
    }

    public function actionDeletePhoto($id)
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $model = $this->findModel((int) $id);
        $this->ensureCanEditEquipment($model);
        $attachmentId = (int) Yii::$app->request->post('attachment_id', 0);

        return $this->equipmentAttachmentService->deletePhoto($model, $attachmentId);
    }

    public function actionDownloadPhoto($id, $attachmentId)
    {
        $model = $this->findModel((int) $id);
        $this->ensureCanAccessEquipment($model);
        $attachment = $this->findEquipmentPhoto($model, (int) $attachmentId);
        if (!$attachment->fileExists()) {
            throw new NotFoundHttpException('Файл не найден.');
        }
        $response = Yii::$app->response;
        $response->headers->set('X-Content-Type-Options', 'nosniff');

        return $response->sendFile($attachment->getFullPath(), $attachment->original_name);
    }

    public function actionPreviewPhoto($id, $attachmentId)
    {
        $model = $this->findModel((int) $id);
        $this->ensureCanAccessEquipment($model);
        $attachment = $this->findEquipmentPhoto($model, (int) $attachmentId);
        if (!$attachment->fileExists()) {
            throw new NotFoundHttpException('Файл не найден.');
        }

        $extension = strtolower((string) $attachment->file_extension);
        $mimeTypes = [
            'png' => 'image/png',
            'jpg' => 'image/jpeg',
            'jpeg' => 'image/jpeg',
            'gif' => 'image/gif',
            'webp' => 'image/webp',
        ];
        $mimeType = $mimeTypes[$extension] ?? 'application/octet-stream';
        $response = Yii::$app->response;
        $response->headers->set('Content-Type', $mimeType);
        $response->headers->set('X-Content-Type-Options', 'nosniff');

        return $response->sendFile($attachment->getFullPath(), $attachment->original_name, ['inline' => true]);
    }

    private function findEquipmentPhoto(Equipment $model, int $attachmentId): DeskAttachments
    {
        if (!$this->equipmentAttachmentService->equipmentOwnsPhoto((int) $model->id, $attachmentId)) {
            throw new NotFoundHttpException('Фотография не найдена.');
        }
        $attachment = DeskAttachments::findOne($attachmentId);
        if ($attachment === null) {
            throw new NotFoundHttpException('Фотография не найдена.');
        }

        return $attachment;
    }

    /**
     * Редактирование карточки актива.
     */
    public function actionUpdate($id)
    {
        $model = $this->findModel((int) $id);
        $this->ensureCanEditEquipment($model);

        if (Yii::$app->request->isPost) {
            Yii::$app->response->format = Response::FORMAT_JSON;
            $result = $this->persistUpdatedEquipment($model, Yii::$app->request->post());
            if ($result['success']) {
                return $result;
            }

            Yii::$app->response->statusCode = 422;

            return [
                'success' => false,
                'errors' => $result['errors'] ?? [],
                'message' => $result['message'],
            ];
        }

        return $this->redirect(['index', 'edit' => $model->id]);
    }

    /**
     * Сохраняет значения характеристик из формы PartChar.
     * Маппинг: cpu->(ЦП,Модель), ram->(ОЗУ,Объём), disk->(Накопитель,Объём), monitor->(Монитор,Модель),
     * hostname->(ПК,Имя ПК), ip->(ПК,IP адрес), os->(ПК,ОС), model->(Монитор,Модель),
     * screen_diagonal->(Монитор,Диагональ экрана), monitor_inv->(Монитор,№ монитора),
     * ups_battery->(ИБП,Модель аккумулятора).
     */
    private function applyOrgTechDescriptionFromPost(Equipment $model): void
    {
        if (!EquipmentCharCatalog::isPrinterOrMfuType($model->resolveEquipmentTypeName())) {
            return;
        }

        if (Yii::$app->request->post('OrgTechSubmitted') === null) {
            return;
        }

        $orgTech = Yii::$app->request->post('OrgTech', []);
        if (!is_array($orgTech)) {
            $orgTech = [];
        }

        $code = trim((string) ($orgTech['cartridge_procurement'] ?? ''));
        if ($code !== 'yes' && $code !== 'no') {
            $code = '';
        }

        $model->description = EquipmentCharCatalog::buildPrinterDescription(
            $code,
            (string) ($model->description ?? '')
        );
    }

    private function savePartCharValuesFromPost(int $equipmentId, array $partChar): void
    {
        if (Yii::$app->request->post('PartCharDisksSubmitted') !== null
            || Yii::$app->request->post('PartCharDisks') !== null) {
            $this->saveDiskPartCharValuesFromPost($equipmentId);
            unset($partChar['disk']);
        }

        $equipment = Equipment::findOne($equipmentId);
        $typeName = $equipment ? $equipment->resolveEquipmentTypeName() : '';
        $isOrgTech = $equipment && EquipmentCharCatalog::isPrinterOrMfuType($typeName);
        $isScanner = $equipment && EquipmentCharCatalog::isScannerType($typeName);

        $map = [
            'cpu' => ['ЦП', 'Модель'],
            'ram' => ['ОЗУ', 'Объём'],
            'monitor' => ['Монитор', 'Модель'],
            'hostname' => ['ПК', 'Имя ПК'],
            'ip' => $isOrgTech ? ['Принтер', 'IP адрес'] : ['ПК', 'IP адрес'],
            'os' => ['ПК', 'ОС'],
            'model' => ['Монитор', 'Модель'],
            'screen_diagonal' => ['Монитор', 'Диагональ экрана'],
            'monitor_inv' => ['Монитор', '№ монитора'],
            'ups_battery' => ['ИБП', 'Модель аккумулятора'],
            'ups_battery_replaced_at' => ['ИБП', 'Дата замены аккумулятора'],
            'ups_battery_service_life' => ['ИБП', 'Срок службы аккумулятора'],
            'cpu_count' => ['ЦП', 'Количество процессоров'],
            'misc_description' => ['Прочее', 'Описание'],
            'misc_ip' => ['Прочее', 'IP адрес'],
        ];
        if ($isOrgTech) {
            $map = array_merge($map, EquipmentCharCatalog::getPrinterMfuPartCharSaveMap());
        }
        if ($isScanner) {
            $map = array_merge($map, EquipmentCharCatalog::getScannerPartCharSaveMap());
        }
        foreach ($partChar as $key => $value) {
            if (!is_string($value)) {
                continue;
            }
            $value = in_array($key, EquipmentCharCatalog::getMultilinePartCharFieldNames(), true)
                ? EquipmentCharCatalog::normalizeEquipmentComment($value)
                : trim($value);
            if ($value === '') {
                continue;
            }
            $m = $map[$key] ?? null;
            if (!$m) continue;
            $part = SprParts::find()->where(['name' => $m[0]])->one();
            $char = SprChars::find()->where(['name' => $m[1]])->one();
            if (!$part || !$char) continue;
            $existing = PartCharValues::findOne([
                'equipment_id' => $equipmentId,
                'part_id' => $part->id,
                'char_id' => $char->id,
            ]);
            if ($existing) {
                $existing->value_text = $value;
                $existing->save(false);
            } else {
                $pcv = new PartCharValues();
                $pcv->equipment_id = $equipmentId;
                $pcv->part_id = $part->id;
                $pcv->char_id = $char->id;
                $pcv->value_text = $value;
                $pcv->save(false);
            }
        }
    }

    /**
     * Сохранение накопителей: удаляет все старые записи «Накопитель» и пишет актуальный список.
     * Иначе при удалении диска остаются строки из импорта (часто с характеристикой «Модель»).
     */
    private function saveDiskPartCharValuesFromPost(int $equipmentId): void
    {
        $disksRaw = Yii::$app->request->post('PartCharDisks', []);
        if (!is_array($disksRaw)) {
            $disksRaw = [];
        }
        $value = EquipmentCharCatalog::joinDiskList($disksRaw);

        $part = SprParts::find()->where(['name' => 'Накопитель'])->one();
        if (!$part) {
            return;
        }

        $eqCol = $this->resolvePartCharEquipmentIdColumn();
        PartCharValues::deleteAll([
            $eqCol => $equipmentId,
            'part_id' => $part->id,
        ]);

        if ($value === '') {
            return;
        }

        $char = SprChars::find()->where(['name' => 'Модель'])->one()
            ?? SprChars::find()->where(['name' => 'Объём'])->one();
        if (!$char) {
            return;
        }

        $pcv = new PartCharValues();
        $pcv->setAttribute($eqCol, $equipmentId);
        $pcv->part_id = $part->id;
        $pcv->char_id = $char->id;
        $pcv->value_text = $value;
        $pcv->save(false);
    }

    private function resolvePartCharEquipmentIdColumn(): string
    {
        $schema = Yii::$app->db->getTableSchema('part_char_values', true);
        if ($schema && isset($schema->columns['equipment_id'])) {
            return 'equipment_id';
        }

        return 'id_arm';
    }

    /**
     * Получение информации о выбранных единицах техники для модального окна перезакрепления.
     * POST: ids[] (массив id оборудования)
     */
    public function actionGetSelectedInfo()
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $ids = Yii::$app->request->post('ids', []);
        if (!is_array($ids)) {
            $ids = array_filter([(int) $ids]);
        }
        $ids = array_map('intval', array_filter($ids));
        if (empty($ids)) {
            return ['success' => false, 'message' => 'Не выбрано ни одной единицы техники.', 'data' => [], 'summary' => []];
        }

        $requestedIds = $ids;

        $equipment = Equipment::find()
            ->where(['id' => $ids])
            ->with(['responsibleUser', 'location', 'equipmentStatus'])
            ->all();

        $hostIds = [];
        foreach ($equipment as $eq) {
            if ($this->isHostEquipment($eq)) {
                $hostIds[] = (int) $eq->id;
            }
        }
        $linksByParent = $this->loadLinkedComponents($hostIds);
        $charsByEquipment = $this->loadPartCharValuesByEquipment($ids);

        $data = [];
        $responsibleUsers = [];
        $locations = [];
        $statuses = [];

        foreach ($equipment as $eq) {
            $isHost = $this->isHostEquipment($eq);
            $isOnWarehouse = $this->isEquipmentOnWarehouse($eq);
            $replaceKind = null;
            if (!$isOnWarehouse) {
                if ($isHost) {
                    $replaceKind = EquipmentReplacementService::KIND_HOST;
                } elseif (EquipmentKitHelper::isMonitorEquipment($eq)) {
                    $replaceKind = EquipmentReplacementService::KIND_MONITOR;
                } elseif (EquipmentKitHelper::isUpsEquipment($eq)) {
                    $replaceKind = EquipmentReplacementService::KIND_UPS;
                }
            }
            $item = [
                'id' => $eq->id,
                'inventory_number' => $eq->inventory_number,
                'name' => $eq->name,
                'equipment_type' => $eq->equipment_type,
                'responsible_user_id' => $eq->responsible_user_id,
                'responsible_user_name' => $eq->responsibleUser ? $eq->responsibleUser->getDisplayName() : null,
                'location_id' => $eq->location_id,
                'location_name' => $eq->location ? $eq->location->name : null,
                'status_id' => $eq->status_id,
                'status_name' => $eq->equipmentStatus ? $eq->equipmentStatus->status_name : null,
                'description' => (string) ($eq->description ?? ''),
                'is_host' => $isHost,
                'is_component' => !$isHost && $this->isLinkableComponentEquipment($eq),
                'is_on_warehouse' => $isOnWarehouse,
                'replace_kind' => $replaceKind,
                'linked_components' => $isHost
                    ? ($linksByParent[(int) $eq->id] ?? ['monitor' => [], 'disk' => [], 'ups' => []])
                    : ['monitor' => [], 'disk' => [], 'ups' => []],
            ];
            if ($isHost) {
                $chars = $charsByEquipment[(int) $eq->id] ?? [];
                $item['hostname'] = $chars['hostname'] ?? '';
                $item['ip'] = $chars['ip'] ?? '';
            }
            $data[] = $item;

            if ($eq->responsible_user_id) {
                $responsibleUsers[$eq->responsible_user_id] = $eq->responsibleUser ? $eq->responsibleUser->getDisplayName() : null;
            }
            if ($eq->location_id) {
                $locations[$eq->location_id] = $eq->location ? $eq->location->name : null;
            }
            if ($eq->status_id) {
                $statuses[$eq->status_id] = $eq->equipmentStatus ? $eq->equipmentStatus->status_name : null;
            }
        }

        $summary = [
            'total' => count($data),
            'unique_responsible_users' => count($responsibleUsers),
            'unique_locations' => count($locations),
            'unique_statuses' => count($statuses),
            'has_responsible' => count(array_filter($data, function($item) { return $item['responsible_user_id'] !== null; })),
            'without_responsible' => count(array_filter($data, function($item) { return $item['responsible_user_id'] === null; })),
        ];

        return [
            'success' => true,
            'ids' => $requestedIds,
            'data' => $data,
            'summary' => $summary,
        ];
    }

    /**
     * Массовое/одиночное переназначение техники (пользователь, локация, статус).
     * POST: ids[] (массив id оборудования), responsible_user_id?, location_id?, status_id?
     */
    public function actionReassign()
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $ids = Yii::$app->request->post('ids', []);
        if (!is_array($ids)) {
            $ids = array_filter([(int) $ids]);
        }
        $ids = array_map('intval', array_filter($ids));
        if (empty($ids)) {
            return ['success' => false, 'message' => 'Не выбрано ни одной единицы техники.'];
        }

        $operationMode = (string) Yii::$app->request->post('operation_mode', 'reassign');
        if ($operationMode === 'move_component') {
            if (empty($ids)) {
                return [
                    'success' => false,
                    'message' => 'Для переноса выберите один или несколько мониторов/ИБП.',
                ];
            }
            foreach ($ids as $moveId) {
                $moveEquipment = Equipment::findOne((int) $moveId);
                if (!$moveEquipment) {
                    return ['success' => false, 'message' => 'Оборудование для переноса не найдено (id=' . (int) $moveId . ').'];
                }
                if ($this->isHostEquipment($moveEquipment)) {
                    return [
                        'success' => false,
                        'message' => 'При переносе с ПК укажите в форме, какой монитор или ИБП переносится.',
                    ];
                }
                if (!$this->isLinkableComponentEquipment($moveEquipment)) {
                    return [
                        'success' => false,
                        'message' => 'Перенос компонента доступен только для мониторов и ИБП.',
                    ];
                }
            }
        } elseif ($operationMode === 'replace_from_warehouse') {
            if (count($ids) !== 1) {
                return [
                    'success' => false,
                    'message' => 'Для замены со склада выберите одну единицу техники в таблице.',
                ];
            }
            $replacementId = (int) Yii::$app->request->post('replacement_equipment_id', 0);
            $replacedStatusId = (int) Yii::$app->request->post('replaced_status_id', 0);
            $oldWarehouseLocationId = (int) Yii::$app->request->post('location_id', 0);
            $changeDescription = Yii::$app->request->post('replaced_description_changed') === '1';
            $replacedDescription = $changeDescription
                ? (string) Yii::$app->request->post('replaced_description', '')
                : null;
            $applyNetworkProfile = Yii::$app->request->post('network_profile_changed') === '1';
            $hostname = $applyNetworkProfile
                ? trim((string) Yii::$app->request->post('hostname', ''))
                : null;
            $ipAddress = $applyNetworkProfile
                ? trim((string) Yii::$app->request->post('ip', ''))
                : null;
            $service = new EquipmentReplacementService();

            return $service->replace(
                (int) $ids[0],
                $replacementId,
                $replacedStatusId,
                $oldWarehouseLocationId > 0 ? $oldWarehouseLocationId : null,
                $changeDescription,
                $replacedDescription,
                $applyNetworkProfile,
                $hostname,
                $ipAddress
            );
        } elseif ($operationMode === 'move_to_warehouse') {
            if (empty($ids)) {
                return ['success' => false, 'message' => 'Не выбрано оборудование для перемещения на склад.'];
            }
            $warehouseLocationId = (int) Yii::$app->request->post('location_id', 0);
            if ($warehouseLocationId <= 0) {
                return ['success' => false, 'message' => 'Укажите складское помещение.'];
            }
            if (!$this->isWarehouseLocationId($warehouseLocationId)) {
                return ['success' => false, 'message' => 'Выбранное помещение не является складом.'];
            }
            return $this->applyMoveToWarehouse($ids, $warehouseLocationId);
        } else {
            $ids = $this->expandReassignIdsWithLinkedComponents($ids, $operationMode);
        }
        $responsibleUserId = Yii::$app->request->post('responsible_user_id');
        $locationId = Yii::$app->request->post('location_id');
        $statusId = Yii::$app->request->post('status_id');
        $responsibleUsersById = $this->parseResponsibleUsersPost(Yii::$app->request->post('responsible_users', []));
        $responsibleUsersChanged = Yii::$app->request->post('responsible_users_changed') === '1';
        if ($responsibleUsersChanged && $responsibleUsersById !== []) {
            $responsibleUsersById = $this->expandResponsibleUsersWithLinkedComponents($responsibleUsersById);
        }
        $locationsById = $this->parseLocationsPost(Yii::$app->request->post('locations', []));
        $locationsChanged = Yii::$app->request->post('locations_changed') === '1';
        if ($locationsChanged && $locationsById !== []) {
            $locationsById = $this->expandLocationsWithLinkedComponents($locationsById);
        }
        // Обычное переназначение: смена статуса не поддерживается
        if ($operationMode === 'reassign') {
            $statusId = null;
        }
        $dismissalTargetUserId = Yii::$app->request->post('dismissal_target_user_id');
        $sendToWarehouse = (bool) Yii::$app->request->post('dismissal_to_warehouse', false);
        $targetSystemBlockId = Yii::$app->request->post('target_system_block_id');
        $linkType = (string) Yii::$app->request->post('link_type', '');
        $linkAction = (string) Yii::$app->request->post('link_action', 'attach');
        if (!in_array($linkAction, ['attach', 'detach'], true)) {
            $linkAction = 'attach';
        }

        $updated = 0;
        $responsibleUserChanged = 0;
        $locationChanged = 0;
        $statusChanged = 0;
        $networkProfileChanged = 0;
        $errors = [];
        $networkProfiles = Yii::$app->request->post('network_profiles', []);
        if (!is_array($networkProfiles)) {
            $networkProfiles = [];
        }
        $networkProfileSubmitted = Yii::$app->request->post('network_profile_changed') === '1';
        // Совместимость со старым одиночным форматом
        if ($networkProfiles === [] && $networkProfileSubmitted) {
            $legacyHostId = (int) Yii::$app->request->post('network_host_id', 0);
            if ($legacyHostId > 0) {
                $networkProfiles[$legacyHostId] = [
                    'hostname' => trim((string) Yii::$app->request->post('hostname', '')),
                    'ip' => trim((string) Yii::$app->request->post('ip', '')),
                ];
            }
        }

        $transaction = Yii::$app->db->beginTransaction();
        try {
            foreach ($ids as $id) {
                $model = Equipment::findOne($id);
                if (!$model) {
                    $errors[] = ['equipment_id' => $id, 'message' => 'Оборудование не найдено'];
                    continue;
                }
                $changed = false;
                $oldResponsible = (int) $model->responsible_user_id;

                if ($operationMode === 'dismissal') {
                    if ($sendToWarehouse) {
                        if ($locationId !== null && $locationId !== '' && (int) $model->location_id !== (int) $locationId) {
                            $oldLoc = $model->location_id;
                            $model->location_id = (int) $locationId;
                            EquipHistory::log($model->id, 'move', ['location_id' => $oldLoc], ['location_id' => $model->location_id], 'dismissal_to_warehouse');
                            $locationChanged++;
                            $changed = true;
                        }
                        if ($model->responsible_user_id !== null) {
                            $model->responsible_user_id = null;
                            EquipHistory::log($model->id, 'unassign', ['responsible_user_id' => $oldResponsible], ['responsible_user_id' => null], 'dismissal_to_warehouse');
                            $responsibleUserChanged++;
                            $changed = true;
                        }
                    } elseif ($dismissalTargetUserId !== null && $dismissalTargetUserId !== '') {
                        $newUser = (int) $dismissalTargetUserId;
                        if ((int) $model->responsible_user_id !== $newUser) {
                            $model->responsible_user_id = $newUser;
                            EquipHistory::log($model->id, 'assign', ['responsible_user_id' => $oldResponsible], ['responsible_user_id' => $newUser], 'dismissal_transfer');
                            $responsibleUserChanged++;
                            $changed = true;
                        }
                        if ($locationId !== null && $locationId !== '' && (int) $model->location_id !== (int) $locationId) {
                            $oldLoc = $model->location_id;
                            $model->location_id = (int) $locationId;
                            EquipHistory::log($model->id, 'move', ['location_id' => $oldLoc], ['location_id' => $model->location_id], 'dismissal_transfer');
                            $locationChanged++;
                            $changed = true;
                        }
                    }
                } else {
                    $equipmentId = (int) $model->id;
                    if ($responsibleUsersChanged && array_key_exists($equipmentId, $responsibleUsersById)) {
                        $newUser = $responsibleUsersById[$equipmentId];
                        if (!EquipHistory::idsEqual($model->responsible_user_id, $newUser)) {
                            $model->responsible_user_id = $newUser;
                            EquipHistory::log($model->id, $model->responsible_user_id ? 'assign' : 'unassign', ['responsible_user_id' => $oldResponsible], ['responsible_user_id' => $model->responsible_user_id]);
                            $changed = true;
                            $responsibleUserChanged++;
                        }
                    } elseif (!$responsibleUsersChanged && $responsibleUserId !== null && $responsibleUserId !== '') {
                        $newUser = ($responsibleUserId === '' || $responsibleUserId === '0') ? null : (int) $responsibleUserId;
                        if (!EquipHistory::idsEqual($model->responsible_user_id, $newUser)) {
                            $model->responsible_user_id = $newUser;
                            EquipHistory::log($model->id, $model->responsible_user_id ? 'assign' : 'unassign', ['responsible_user_id' => $oldResponsible], ['responsible_user_id' => $model->responsible_user_id]);
                            $changed = true;
                            $responsibleUserChanged++;
                        }
                    }
                    if ($locationsChanged && array_key_exists($equipmentId, $locationsById)) {
                        $newLoc = $locationsById[$equipmentId];
                        if ($newLoc !== null && !EquipHistory::idsEqual($model->location_id, $newLoc)) {
                            $oldLoc = $model->location_id;
                            $model->location_id = $newLoc;
                            EquipHistory::log($model->id, 'move', ['location_id' => $oldLoc], ['location_id' => $model->location_id]);
                            $changed = true;
                            $locationChanged++;
                        }
                    } elseif (!$locationsChanged && $locationId !== null && $locationId !== '') {
                        $newLoc = (int) $locationId;
                        if (!EquipHistory::idsEqual($model->location_id, $newLoc)) {
                            $oldLoc = $model->location_id;
                            $model->location_id = $newLoc;
                            EquipHistory::log($model->id, 'move', ['location_id' => $oldLoc], ['location_id' => $model->location_id]);
                            $changed = true;
                            $locationChanged++;
                        }
                    }
                    if ($operationMode !== 'reassign' && $statusId !== null && $statusId !== '') {
                        $newStatus = (int) $statusId;
                        if (!EquipHistory::idsEqual($model->status_id, $newStatus)) {
                            $oldStatus = $model->status_id;
                            $model->status_id = $newStatus;
                            EquipHistory::log($model->id, 'status_change', ['status_id' => $oldStatus], ['status_id' => $model->status_id]);
                            $changed = true;
                            $statusChanged++;
                        }
                    }
                }

                if ($changed) {
                    if ($model->save(false)) {
                        $updated++;
                        AuditLog::log('equipment.reassign', 'equipment', $model->id, 'success', ['mode' => $operationMode]);
                        UserEquipmentCardService::invalidateByUserId($oldResponsible);
                        UserEquipmentCardService::ensureCardForUser($oldResponsible);
                        UserEquipmentCardService::invalidateByUserId((int) $model->responsible_user_id);
                        UserEquipmentCardService::ensureCardForUser((int) $model->responsible_user_id);
                    } else {
                        $errors[] = ['equipment_id' => $id, 'message' => 'Ошибка при сохранении'];
                    }
                }
            }

            if ($operationMode === 'move_component') {
                $this->applyMoveComponentLinkAction(
                    $ids,
                    $linkAction,
                    $linkType,
                    $targetSystemBlockId,
                    $updated
                );
            }

            if ($operationMode === 'reassign' && $networkProfileSubmitted && $networkProfiles !== []) {
                foreach ($networkProfiles as $rawHostId => $profile) {
                    if (!is_array($profile)) {
                        continue;
                    }
                    $hostId = (int) $rawHostId;
                    $hostname = trim((string) ($profile['hostname'] ?? ''));
                    $ipAddress = trim((string) ($profile['ip'] ?? ''));
                    if ($hostId <= 0 || ($hostname === '' && $ipAddress === '')) {
                        continue;
                    }
                    $networkProfileChanged += $this->applyReassignHostNetworkProfile(
                        $hostId,
                        $hostname,
                        $ipAddress
                    );
                }
            }

            $transaction->commit();
        } catch (\Throwable $e) {
            $transaction->rollBack();
            return ['success' => false, 'message' => 'Ошибка операции переназначения: ' . $e->getMessage()];
        }

        $updated += $networkProfileChanged;

        return [
            'success' => true,
            'message' => "Обновлено единиц техники: {$updated} из " . count($ids),
            'updated' => $updated,
            'details' => [
                'responsible_user_changed' => $responsibleUserChanged,
                'location_changed' => $locationChanged,
                'status_changed' => $statusChanged,
                'network_profile_changed' => $networkProfileChanged,
                'errors' => $errors,
            ],
        ];
    }

    private function applyReassignHostNetworkProfile(int $hostId, string $hostname, string $ipAddress): int
    {
        $host = Equipment::findOne($hostId);
        if ($host === null || $host->is_deleted || $host->is_archived || !$this->isHostEquipment($host)) {
            return 0;
        }

        $partChar = [];
        if ($hostname !== '') {
            $partChar['hostname'] = $hostname;
        }
        if ($ipAddress !== '') {
            $partChar['ip'] = $ipAddress;
        }
        if ($partChar === []) {
            return 0;
        }

        (new EquipmentPartCharService())->savePartCharValues(
            $hostId,
            $partChar,
            $host->resolveEquipmentTypeName()
        );
        AuditLog::log('equipment.reassign', 'equipment', $hostId, 'success', [
            'mode' => 'reassign',
            'network_profile' => true,
        ]);

        return 1;
    }

    /**
     * @param mixed $raw
     * @return array<int, int>
     */
    private function parseLocationsPost($raw): array
    {
        if (!is_array($raw)) {
            return [];
        }

        $out = [];
        foreach ($raw as $equipmentId => $locationValue) {
            $id = (int) $equipmentId;
            if ($id <= 0) {
                continue;
            }
            $value = is_scalar($locationValue) ? trim((string) $locationValue) : '';
            if ($value === '' || $value === '0') {
                continue;
            }
            $out[$id] = (int) $value;
        }

        return $out;
    }

    /**
     * Для переназначения ПК распространяет помещение на привязанные мониторы и ИБП.
     *
     * @param array<int, int> $locationsById
     * @return array<int, int>
     */
    private function expandLocationsWithLinkedComponents(array $locationsById): array
    {
        if ($locationsById === [] || Yii::$app->db->getTableSchema('equipment_links', true) === null) {
            return $locationsById;
        }

        $hostIds = [];
        foreach (array_keys($locationsById) as $equipmentId) {
            $equipment = Equipment::findOne((int) $equipmentId);
            if ($equipment !== null && $this->isHostEquipment($equipment)) {
                $hostIds[] = (int) $equipmentId;
            }
        }
        if ($hostIds === []) {
            return $locationsById;
        }

        $links = EquipmentLink::find()
            ->select(['parent_equipment_id', 'child_equipment_id'])
            ->where(['parent_equipment_id' => $hostIds])
            ->asArray()
            ->all();
        if ($links === []) {
            return $locationsById;
        }

        $childIds = array_values(array_unique(array_map(static fn(array $row): int => (int) $row['child_equipment_id'], $links)));
        $activeChildIds = Equipment::find()
            ->select('id')
            ->where(['id' => $childIds, 'is_deleted' => false, 'is_archived' => false])
            ->column();
        $activeChildIds = array_map('intval', $activeChildIds);
        if ($activeChildIds === []) {
            return $locationsById;
        }

        $activeChildSet = array_fill_keys($activeChildIds, true);
        foreach ($links as $link) {
            $parentId = (int) $link['parent_equipment_id'];
            $childId = (int) $link['child_equipment_id'];
            if (!isset($activeChildSet[$childId]) || !array_key_exists($parentId, $locationsById)) {
                continue;
            }
            if (!array_key_exists($childId, $locationsById)) {
                $locationsById[$childId] = $locationsById[$parentId];
            }
        }

        return $locationsById;
    }

    /**
     * @param mixed $raw
     * @return array<int, int|null>
     */
    private function parseResponsibleUsersPost($raw): array
    {
        if (!is_array($raw)) {
            return [];
        }

        $out = [];
        foreach ($raw as $equipmentId => $userValue) {
            $id = (int) $equipmentId;
            if ($id <= 0) {
                continue;
            }
            $value = is_scalar($userValue) ? trim((string) $userValue) : '';
            if ($value === '') {
                continue;
            }
            $out[$id] = ($value === '0') ? null : (int) $value;
        }

        return $out;
    }

    /**
     * Для переназначения ПК распространяет ответственного на привязанные мониторы и ИБП.
     *
     * @param array<int, int|null> $responsibleUsersById
     * @return array<int, int|null>
     */
    private function expandResponsibleUsersWithLinkedComponents(array $responsibleUsersById): array
    {
        if ($responsibleUsersById === [] || Yii::$app->db->getTableSchema('equipment_links', true) === null) {
            return $responsibleUsersById;
        }

        $hostIds = [];
        foreach (array_keys($responsibleUsersById) as $equipmentId) {
            $equipment = Equipment::findOne((int) $equipmentId);
            if ($equipment !== null && $this->isHostEquipment($equipment)) {
                $hostIds[] = (int) $equipmentId;
            }
        }
        if ($hostIds === []) {
            return $responsibleUsersById;
        }

        $links = EquipmentLink::find()
            ->select(['parent_equipment_id', 'child_equipment_id'])
            ->where(['parent_equipment_id' => $hostIds])
            ->asArray()
            ->all();
        if ($links === []) {
            return $responsibleUsersById;
        }

        $childIds = array_values(array_unique(array_map(static fn(array $row): int => (int) $row['child_equipment_id'], $links)));
        $activeChildIds = Equipment::find()
            ->select('id')
            ->where(['id' => $childIds, 'is_deleted' => false, 'is_archived' => false])
            ->column();
        $activeChildIds = array_map('intval', $activeChildIds);
        if ($activeChildIds === []) {
            return $responsibleUsersById;
        }

        $activeChildSet = array_fill_keys($activeChildIds, true);
        foreach ($links as $link) {
            $parentId = (int) $link['parent_equipment_id'];
            $childId = (int) $link['child_equipment_id'];
            if (!isset($activeChildSet[$childId]) || !array_key_exists($parentId, $responsibleUsersById)) {
                continue;
            }
            if (!array_key_exists($childId, $responsibleUsersById)) {
                $responsibleUsersById[$childId] = $responsibleUsersById[$parentId];
            }
        }

        return $responsibleUsersById;
    }

    /**
     * Список техники на складе для замены (СБ / монитор / ИБП).
     * GET: kind=host|monitor|ups, warehouse_location_id?, match_equipment_id?
     */
    public function actionReplaceOptions()
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $kind = (string) Yii::$app->request->get('kind', '');
        $warehouseLocationId = (int) Yii::$app->request->get('warehouse_location_id', 0);
        $matchEquipmentId = (int) Yii::$app->request->get('match_equipment_id', 0);
        $service = new EquipmentReplacementService();

        return $service->getWarehouseOptions(
            $kind,
            $warehouseLocationId > 0 ? $warehouseLocationId : null,
            $matchEquipmentId > 0 ? $matchEquipmentId : null
        );
    }

    public function actionSystemBlocks()
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        try {
            $userId = (int) Yii::$app->request->get('user_id', 0);
            $q = trim((string) Yii::$app->request->get('q', ''));

            $query = Equipment::find()
                ->alias('e')
                ->select(['e.id', 'e.name', 'e.inventory_number', 'e.serial_number', 'e.location_id'])
                ->where(['e.is_deleted' => false, 'e.is_archived' => false]);

            $hostCondition = $this->buildHostEquipmentSqlCondition('e', EquipmentTypes::usesDictionary() ? 'et' : null);
            if (EquipmentTypes::usesDictionary()) {
                $query->leftJoin(['et' => 'equipment_types'], 'et.id = e.equipment_type_id');
            }
            $query->andWhere($hostCondition);

            if ($userId > 0) {
                $query->andWhere(['e.responsible_user_id' => $userId]);
            }
            if ($q !== '') {
                $query->andWhere(['or',
                    ['ilike', 'e.name', $q],
                    ['ilike', 'e.inventory_number', $q],
                    ['ilike', 'e.serial_number', $q],
                ]);
            }

            $rows = $query->orderBy(['e.name' => SORT_ASC])->limit(200)->asArray()->all();
            return ['success' => true, 'data' => $rows];
        } catch (\Throwable $e) {
            Yii::error('actionSystemBlocks failed: ' . $e->getMessage(), __METHOD__);
            return ['success' => false, 'message' => 'Не удалось загрузить список системных блоков', 'data' => []];
        }
    }

    /**
     * Подсказка помещения для обычного переназначения: наиболее частое location_id среди техники пользователя.
     */
    public function actionUserPrimaryLocation()
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $userId = (int) Yii::$app->request->get('user_id', 0);
        if ($userId <= 0) {
            return ['success' => true, 'location_id' => null];
        }
        try {
            $row = (new \yii\db\Query())
                ->from(['e' => Equipment::tableName()])
                ->select(['e.location_id', 'cnt' => 'COUNT(*)'])
                ->where([
                    'e.responsible_user_id' => $userId,
                    'e.is_deleted' => false,
                ])
                ->andWhere(['not', ['e.location_id' => null]])
                ->groupBy(['e.location_id'])
                ->orderBy(['cnt' => SORT_DESC, 'e.location_id' => SORT_ASC])
                ->limit(1)
                ->one();
            $locId = $row && isset($row['location_id']) ? (int) $row['location_id'] : null;
            return ['success' => true, 'location_id' => $locId ?: null];
        } catch (\Throwable $e) {
            Yii::error('actionUserPrimaryLocation failed: ' . $e->getMessage(), __METHOD__);
            return ['success' => false, 'location_id' => null, 'message' => 'Не удалось определить помещение'];
        }
    }

    /**
     * Монитор или ИБП как отдельная единица учёта (переносимый компонент).
     */
    private function isLinkableComponentEquipment(Equipment $equipment): bool
    {
        if ($this->isHostEquipment($equipment)) {
            return false;
        }

        $name = mb_strtolower(trim((string) $equipment->name), 'UTF-8');
        $typeLower = mb_strtolower(trim((string) $equipment->equipment_type), 'UTF-8');
        foreach (['монитор', 'monitor', 'ибп', 'ups'] as $pattern) {
            if ($typeLower !== '' && mb_strpos($typeLower, $pattern, 0, 'UTF-8') !== false) {
                return true;
            }
            if ($name !== '' && mb_strpos($name, $pattern, 0, 'UTF-8') !== false) {
                return true;
            }
        }

        return false;
    }

    /**
     * ПК/хост, к которому можно привязать монитор, диск, ИБП.
     */
    private function isHostEquipment(Equipment $equipment): bool
    {
        $type = trim((string) $equipment->equipment_type);
        if (in_array($type, $this->getPeripheralEquipmentTypes(), true)) {
            return false;
        }
        if (in_array($type, $this->getKitHostEquipmentTypes(), true)) {
            return true;
        }

        $name = mb_strtolower(trim((string) $equipment->name), 'UTF-8');
        $typeLower = mb_strtolower($type, 'UTF-8');
        foreach ($this->getHostEquipmentLabelPatterns() as $pattern) {
            if ($typeLower !== '' && mb_strpos($typeLower, $pattern, 0, 'UTF-8') !== false) {
                return true;
            }
            if ($name !== '' && mb_strpos($name, $pattern, 0, 'UTF-8') !== false) {
                return true;
            }
        }

        return false;
    }

    /**
     * Колонка «Тип/Название техники» на вкладке «Вся техника»: тип, затем наименование.
     */
    private function formatEquipmentTypeAndNameForGrid(Equipment $equipment): string
    {
        $type = trim((string) ($equipment->resolveEquipmentTypeName() ?? ''));
        $name = trim((string) ($equipment->name ?? ''));
        if (EquipmentCharCatalog::isMiscType($type)) {
            return $name !== '' ? $name : $type;
        }
        if ($type !== '' && $name !== '') {
            return $type . ' · ' . $name;
        }
        if ($name !== '') {
            return $name;
        }

        return $type;
    }

    /**
     * Дата закупки для грида и экспорта (дд.мм.гггг).
     */
    private function formatPurchaseDateForGrid(Equipment $equipment): string
    {
        $raw = $equipment->purchase_date;
        if ($raw === null || trim((string) $raw) === '') {
            return '';
        }
        try {
            return (new \DateTimeImmutable(trim((string) $raw)))->format('d.m.Y');
        } catch (\Exception $e) {
            return trim((string) $raw);
        }
    }

    /**
     * Столбец «Описание» для типа «Прочее» — из part_char с запасным вариантом из equipment.description.
     *
     * @param array<string, string> $chars
     */
    private function formatMiscDescriptionForGrid(Equipment $equipment, array $chars): string
    {
        $fromChars = EquipmentCharCatalog::normalizeEquipmentComment($chars['misc_description'] ?? '');
        if ($fromChars !== '') {
            return $fromChars;
        }

        if (!EquipmentCharCatalog::isMiscType($equipment->resolveEquipmentTypeName())) {
            return '';
        }

        return EquipmentCharCatalog::normalizeEquipmentComment($equipment->description);
    }

    /**
     * При открытии формы «Прочее» подставляет комментарий из equipment.description, если в part_char пусто.
     *
     * @param array<string, string> $chars
     */
    private function hydrateMiscCharsFromEquipment(Equipment $model, array &$chars): void
    {
        if (!EquipmentCharCatalog::isMiscType($model->resolveEquipmentTypeName())) {
            return;
        }

        if (EquipmentCharCatalog::normalizeEquipmentComment($chars['misc_description'] ?? '') !== '') {
            return;
        }

        $desc = EquipmentCharCatalog::normalizeEquipmentComment($model->description);
        if ($desc !== '') {
            $chars['misc_description'] = $desc;
        }
    }

    /**
     * Сохраняет комментарий «Прочее» только в part_char (без дублирования в equipment.description).
     *
     * @param array<string, mixed> $partChar
     */
    private function syncMiscEquipmentDescriptionOnSave(Equipment $model, array &$partChar): void
    {
        if (!EquipmentCharCatalog::isMiscType($model->resolveEquipmentTypeName())) {
            return;
        }

        $comment = EquipmentCharCatalog::normalizeEquipmentComment($partChar['misc_description'] ?? '');
        if ($comment === '') {
            $comment = EquipmentCharCatalog::normalizeEquipmentComment($model->description);
        }

        if ($comment === '') {
            $partChar['misc_description'] = '';
            $model->description = null;

            return;
        }

        $partChar['misc_description'] = $comment;
        $model->description = null;
    }

    /**
     * Столбец «IP адрес» — ПК, принтер/МФУ, тип «Прочее».
     *
     * @param array<string, string> $chars
     */
    private function formatIpForGrid(Equipment $equipment, array $chars): string
    {
        if (EquipmentCharCatalog::isMiscType($equipment->resolveEquipmentTypeName())) {
            return trim((string) ($chars['misc_ip'] ?? ''));
        }

        return trim((string) ($chars['ip'] ?? ''));
    }

    /**
     * Столбец «Комментарий» — «Другая техника» у ПК; у принтера/МФУ — примечание без строки про картриджи;
     * у типа «Прочее» — из part_char; у монитора/ИБП и пр. — equipment.description.
     *
     * @param array<string, string> $chars
     */
    private function formatOtherTechForGrid(Equipment $equipment, array $chars = []): string
    {
        $type = $equipment->resolveEquipmentTypeName();
        if (EquipmentCharCatalog::isPrinterOrMfuType($type)) {
            return EquipmentCharCatalog::formatPrinterComment($equipment->description);
        }
        if (EquipmentCharCatalog::isMiscType($type)) {
            return $this->formatMiscDescriptionForGrid($equipment, $chars);
        }

        return EquipmentCharCatalog::normalizeEquipmentComment($equipment->description);
    }

    /**
     * Столбец «Закупка картриджей» — только принтер и МФУ.
     */
    private function formatCartridgeProcurementForGrid(Equipment $equipment): string
    {
        if (!EquipmentCharCatalog::isPrinterOrMfuType($equipment->resolveEquipmentTypeName())) {
            return '';
        }

        return EquipmentCharCatalog::formatCartridgeProcurementStatus($equipment->description);
    }

    /** @return string[] */
    private function getKitHostEquipmentTypes(): array
    {
        return ['ПК', 'Моноблок', 'Системный блок', 'Ноутбук', 'Сервер'];
    }

    /** @return string[] */
    private function getPeripheralEquipmentTypes(): array
    {
        return ['Монитор', 'ИБП', 'Принтер', 'МФУ', 'Сканер'];
    }

    /** @return string[] */
    private function getHostEquipmentLabelPatterns(): array
    {
        return ['систем', 'system', 'моноблок', 'monoblock', 'ноутбук', 'ноут', 'laptop', 'пк', 'computer'];
    }

    /**
     * Условие SQL для выборки хостов (системный блок, ноутбук, моноблок).
     *
     * @param string|null $typeTableAlias алиас equipment_types при справочнике типов
     */
    private function buildHostEquipmentSqlCondition(string $equipmentAlias, ?string $typeTableAlias = null): array
    {
        $or = ['or'];
        foreach ($this->getHostEquipmentLabelPatterns() as $pattern) {
            $or[] = ['ilike', $equipmentAlias . '.name', $pattern];
            $or[] = ['ilike', $equipmentAlias . '.equipment_type', $pattern];
            if ($typeTableAlias !== null) {
                $or[] = ['ilike', $typeTableAlias . '.name', $pattern];
            }
        }

        return $or;
    }

    /**
     * @param int[] $childIds
     */
    private function applyMoveComponentLinkAction(
        array $childIds,
        string $linkAction,
        string $linkType,
        $targetSystemBlockId,
        int &$updated
    ): void {
        if (Yii::$app->db->getTableSchema('equipment_links', true) === null) {
            throw new \RuntimeException('Таблица связей оборудования недоступна.');
        }

        foreach ($childIds as $childId) {
            $child = Equipment::findOne((int) $childId);
            if (!$child || !$this->isLinkableComponentEquipment($child)) {
                continue;
            }

            $resolvedLinkType = $linkType !== ''
                ? $linkType
                : $this->detectLinkTypeForEquipment($child);
            if (!in_array($resolvedLinkType, [EquipmentLink::TYPE_MONITOR, EquipmentLink::TYPE_UPS], true)) {
                continue;
            }

            if ($linkAction === 'detach') {
                $links = EquipmentLink::find()
                    ->where([
                        'child_equipment_id' => (int) $childId,
                        'link_type' => $resolvedLinkType,
                    ])
                    ->all();
                foreach ($links as $link) {
                    $parentId = (int) $link->parent_equipment_id;
                    $link->delete();
                    EquipHistory::log(
                        (int) $childId,
                        'update',
                        ['parent_equipment_id' => $parentId, 'link_type' => $resolvedLinkType],
                        ['parent_equipment_id' => null],
                        'move_component_detach'
                    );
                    $updated++;
                    AuditLog::log('equipment.reassign', 'equipment', (int) $childId, 'success', [
                        'mode' => 'move_component_detach',
                        'parent_id' => $parentId,
                    ]);
                }
                continue;
            }

            if (!$targetSystemBlockId) {
                throw new \RuntimeException('Укажите целевой системный блок для привязки компонента.');
            }

            $targetSystemBlock = Equipment::findOne((int) $targetSystemBlockId);
            if (!$targetSystemBlock || $targetSystemBlock->is_deleted || $targetSystemBlock->is_archived || !$this->isHostEquipment($targetSystemBlock)) {
                throw new \RuntimeException('Целевой ПК не найден или недоступен для привязки компонента.');
            }

            EquipmentLink::deleteAll([
                'child_equipment_id' => (int) $childId,
                'link_type' => $resolvedLinkType,
            ]);

            $equipmentLink = new EquipmentLink();
            $equipmentLink->parent_equipment_id = (int) $targetSystemBlockId;
            $equipmentLink->child_equipment_id = (int) $childId;
            $equipmentLink->link_type = $resolvedLinkType;
            $equipmentLink->created_by = Yii::$app->user->id;
            $equipmentLink->save(false);

            EquipHistory::log(
                (int) $childId,
                'update',
                null,
                ['parent_equipment_id' => (int) $targetSystemBlockId, 'link_type' => $resolvedLinkType],
                'move_component_attach'
            );
            $updated++;

            if ($this->syncComponentToHost($child, $targetSystemBlock)) {
                AuditLog::log('equipment.reassign', 'equipment', $child->id, 'success', [
                    'mode' => 'move_component_sync',
                    'parent_id' => (int) $targetSystemBlockId,
                ]);
            }
        }
    }

    private function detectLinkTypeForEquipment(Equipment $equipment): string
    {
        $typeLower = mb_strtolower(trim((string) $equipment->equipment_type), 'UTF-8');
        if (mb_strpos($typeLower, 'ибп', 0, 'UTF-8') !== false || mb_strpos($typeLower, 'ups', 0, 'UTF-8') !== false) {
            return EquipmentLink::TYPE_UPS;
        }

        return EquipmentLink::TYPE_MONITOR;
    }

    /**
     * Переносит компонент на учёт пользователя и помещения целевого ПК.
     */
    private function syncComponentToHost(Equipment $component, Equipment $host): bool
    {
        $changed = false;
        $oldResponsible = $component->responsible_user_id;
        $hostUserId = $host->responsible_user_id !== null ? (int) $host->responsible_user_id : null;

        if ($component->responsible_user_id !== $hostUserId) {
            $component->responsible_user_id = $hostUserId;
            EquipHistory::log(
                $component->id,
                $hostUserId ? 'assign' : 'unassign',
                ['responsible_user_id' => $oldResponsible],
                ['responsible_user_id' => $hostUserId],
                'move_component_to_host'
            );
            $changed = true;
        }

        if ($host->location_id && (int) $component->location_id !== (int) $host->location_id) {
            $oldLoc = $component->location_id;
            $component->location_id = (int) $host->location_id;
            EquipHistory::log(
                $component->id,
                'move',
                ['location_id' => $oldLoc],
                ['location_id' => $component->location_id],
                'move_component_to_host'
            );
            $changed = true;
        }

        if (!$changed) {
            return false;
        }

        if (!$component->save(false)) {
            return false;
        }

        UserEquipmentCardService::invalidateByUserId((int) $oldResponsible);
        UserEquipmentCardService::ensureCardForUser((int) $oldResponsible);
        UserEquipmentCardService::invalidateByUserId((int) $hostUserId);
        UserEquipmentCardService::ensureCardForUser((int) $hostUserId);

        return true;
    }

    /** @deprecated use isHostEquipment() */
    private function isSystemBlockEquipment(Equipment $equipment): bool
    {
        return $this->isHostEquipment($equipment);
    }

    public function actionLinkComponents()
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $parentId = (int) Yii::$app->request->post('parent_equipment_id');
        $childIds = Yii::$app->request->post('child_ids', []);
        $linkType = (string) Yii::$app->request->post('link_type', '');

        if (!in_array($linkType, [EquipmentLink::TYPE_MONITOR, EquipmentLink::TYPE_DISK, EquipmentLink::TYPE_UPS], true)) {
            return ['success' => false, 'message' => 'Неверный тип связи.'];
        }
        if ($parentId <= 0 || empty($childIds)) {
            return ['success' => false, 'message' => 'Укажите системный блок и список компонентов.'];
        }

        $childIds = array_map('intval', (array) $childIds);
        $host = Equipment::findOne($parentId);
        if (!$host || $host->is_deleted || $host->is_archived || !$this->isHostEquipment($host)) {
            return ['success' => false, 'message' => 'Целевой ПК не найден или недоступен для привязки.'];
        }

        $transaction = Yii::$app->db->beginTransaction();
        try {
            foreach ($childIds as $childId) {
                EquipmentLink::deleteAll(['child_equipment_id' => $childId, 'link_type' => $linkType]);
                $link = new EquipmentLink();
                $link->parent_equipment_id = $parentId;
                $link->child_equipment_id = $childId;
                $link->link_type = $linkType;
                $link->created_by = Yii::$app->user->id;
                $link->save(false);

                $child = Equipment::findOne((int) $childId);
                if ($child) {
                    $this->syncComponentToHost($child, $host);
                }
            }
            $transaction->commit();
            return ['success' => true, 'message' => 'Компоненты успешно привязаны к ПК.'];
        } catch (\Throwable $e) {
            $transaction->rollBack();
            return ['success' => false, 'message' => $e->getMessage()];
        }
    }

    public function actionExportXlsx()
    {
        $params = Yii::$app->request->queryParams;
        $idsRaw = trim((string)($params['ids'] ?? ''));
        $ids = [];
        if ($idsRaw !== '') {
            $ids = array_values(array_unique(array_filter(array_map('intval', explode(',', $idsRaw)))));
        }

        if (!empty($ids)) {
            $models = Equipment::find()
                ->with(['responsibleUser', 'location', 'equipmentStatus'])
                ->where(['id' => $ids, 'is_deleted' => false])
                ->orderBy(['id' => SORT_ASC])
                ->all();
        } else {
            $searchModel = new ArmSearch();
            $params['ArmSearch'] = $params['ArmSearch'] ?? [];
            $scopeFromRequest = trim((string) ($params['location_scope'] ?? $params['ArmSearch']['location_scope'] ?? ''));
            $params['ArmSearch']['location_scope'] = $scopeFromRequest !== ''
                ? $scopeFromRequest
                : ($this->id === 'warehouse' ? 'warehouse_only' : 'exclude_warehouse');
            if (!empty($params['equipment_type'])) {
                $params['ArmSearch']['equipment_type'] = (string) $params['equipment_type'];
            }
            $filterModelRaw = isset($params['filterModel']) ? trim((string) $params['filterModel']) : '';
            $sortModelRaw = isset($params['sortModel']) ? trim((string) $params['sortModel']) : '';
            if ($filterModelRaw !== '' || $sortModelRaw !== '') {
                $params['ArmSearch'] = $params['ArmSearch'] ?? [];
                if ($filterModelRaw !== '') {
                    $params['ArmSearch']['ag_filter_model'] = $filterModelRaw;
                }
                if ($sortModelRaw !== '') {
                    $params['ArmSearch']['ag_sort_model'] = $sortModelRaw;
                }
            }
            $quickSearch = isset($params['quickSearch']) ? trim((string) $params['quickSearch']) : '';
            if ($quickSearch !== '') {
                $params['ArmSearch'] = $params['ArmSearch'] ?? [];
                $params['ArmSearch']['quick_search'] = $quickSearch;
            }
            $provider = $searchModel->search($params);
            $provider->pagination = false;
            $models = $provider->getModels();
        }

        $showTypeWithNameInGrid = empty($ids)
            && (!isset($searchModel) || trim((string) $searchModel->equipment_type) === '');

        $charsByEquipment = $this->loadPartCharValuesByEquipment(array_map(static fn($m) => (int)$m->id, $models));
        $linksByParent = $this->loadLinkedComponents(array_map(static fn($m) => (int)$m->id, $models));

        $columnMap = [
            'user_name' => ['Пользователь', static fn($m, $chars, $links) => $m->responsibleUser ? $m->responsibleUser->getDisplayName() : ''],
            'location_name' => ['Помещение', static fn($m, $chars, $links) => $m->location ? $m->location->name : ''],
            'status_name' => ['Статус', static fn($m, $chars, $links) => $m->equipmentStatus ? $m->equipmentStatus->status_name : ''],
            'cpu' => ['ЦП', static fn($m, $chars, $links) => $chars['cpu'] ?? ''],
            'ram' => ['ОЗУ', static fn($m, $chars, $links) => $chars['ram'] ?? ''],
            'disk' => ['Диск', static fn($m, $chars, $links) => implode(
                "\n",
                EquipmentCharCatalog::formatDiskGridLines(
                    (string) ($chars['disk'] ?? ''),
                    $links['disk'] ?? []
                )
            )],
            'system_block' => [
                'Тип/Название техники',
                fn($m, $chars, $links) => $showTypeWithNameInGrid
                    ? $this->formatEquipmentTypeAndNameForGrid($m)
                    : (string) ($m->name ?? ''),
            ],
            'inventory_number' => ['Инв. №', static fn($m, $chars, $links) => $m->inventory_number ?? ''],
            'purchase_date' => ['Дата закупки', fn($m, $chars, $links) => $this->formatPurchaseDateForGrid($m)],
            'monitor' => ['Монитор', static fn($m, $chars, $links) => EquipmentCharCatalog::formatMonitorColumnValue(
                !empty($links['monitor']) ? (string) ($chars['monitor'] ?? '') : '',
                $links['monitor'] ?? []
            )],
            'ups' => ['ИБП', static fn($m, $chars, $links) => EquipmentCharCatalog::formatMonitorColumnValue(
                '',
                $links['ups'] ?? []
            )],
            'hostname' => ['Имя ПК', static fn($m, $chars, $links) => $chars['hostname'] ?? ''],
            'ip' => ['IP адрес', fn($m, $chars, $links) => $this->formatIpForGrid($m, $chars)],
            'os' => ['ОС', static fn($m, $chars, $links) => $chars['os'] ?? ''],
            'screen_diagonal' => ['Диагональ экрана', static fn($m, $chars, $links) => $chars['screen_diagonal'] ?? ''],
            'cartridge_procurement' => ['Закупка картриджей', fn($m, $chars, $links) => $this->formatCartridgeProcurementForGrid($m)],
            'other_tech' => ['Комментарий', fn($m, $chars, $links) => $this->formatOtherTechForGrid($m, $chars)],
        ];

        $catalog = EquipmentCharCatalog::getArmGridColumnCatalog();
        foreach (EquipmentCharCatalog::getArmGridExtraPartCharFields() as $field) {
            if (isset($columnMap[$field])) {
                continue;
            }
            $header = $catalog['labels'][$field] ?? $field;
            $columnMap[$field] = [$header, static fn($m, $chars, $links) => $chars[$field] ?? ''];
        }

        $defaultCols = ['user_name', 'location_name', 'status_name', 'cpu', 'ram', 'disk', 'system_block', 'inventory_number', 'purchase_date', 'monitor', 'ups', 'hostname', 'ip', 'os', 'other_tech'];
        if ($this->id === 'warehouse') {
            $defaultCols = array_values(array_filter(
                $defaultCols,
                static fn(string $colId): bool => $colId !== 'user_name'
            ));
        }
        $scope = trim((string)($params['export_scope'] ?? 'all'));
        $colsParam = trim((string)($params['cols'] ?? ''));
        $selectedCols = $defaultCols;
        if ($scope === 'visible' && $colsParam !== '') {
            $requested = array_values(array_unique(array_filter(array_map('trim', explode(',', $colsParam)))));
            $filtered = array_values(array_filter($requested, static fn($c) => isset($columnMap[$c])));
            if ($this->id === 'warehouse') {
                $filtered = array_values(array_filter($filtered, static fn($c) => $c !== 'user_name'));
            }
            if (!empty($filtered)) {
                $selectedCols = $filtered;
            }
        }

        $spreadsheet = new Spreadsheet();
        $sheet = $spreadsheet->getActiveSheet();
        foreach ($selectedCols as $idx => $colId) {
            $sheet->setCellValue([$idx + 1, 1], $columnMap[$colId][0]);
        }

        $row = 2;
        foreach ($models as $model) {
            $chars = $charsByEquipment[$model->id] ?? [];
            $links = $linksByParent[(int)$model->id] ?? ['monitor' => [], 'disk' => [], 'ups' => []];
            foreach ($selectedCols as $idx => $colId) {
                $valueFactory = $columnMap[$colId][1];
                $sheet->setCellValue([$idx + 1, $row], $valueFactory($model, $chars, $links));
            }
            $row++;
        }

        $file = Yii::getAlias('@runtime') . '/equipment_export_' . date('Ymd_His') . '.xlsx';
        (new Xlsx($spreadsheet))->save($file);
        return Yii::$app->response->sendFile($file, 'equipment_export.xlsx');
    }

    public function actionImportTemplateXlsx()
    {
        $spreadsheet = new Spreadsheet();
        $sheet = $spreadsheet->getActiveSheet();
        $headers = ['inventory_number', 'name', 'responsible_user_id', 'location_id', 'status_id', 'description'];
        foreach ($headers as $idx => $header) {
            $sheet->setCellValue([$idx + 1, 1], $header);
        }
        $sheet->setCellValue([1, 2], 'INV-00001');
        $sheet->setCellValue([2, 2], 'Системный блок 01');
        $sheet->setCellValue([3, 2], '');
        $sheet->setCellValue([4, 2], '1');
        $sheet->setCellValue([5, 2], '1');
        $sheet->setCellValue([6, 2], 'пример');

        $file = Yii::getAlias('@runtime') . '/equipment_import_template.xlsx';
        (new Xlsx($spreadsheet))->save($file);
        return Yii::$app->response->sendFile($file, 'equipment_import_template.xlsx');
    }

    public function actionImportPreview()
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $upload = \yii\web\UploadedFile::getInstanceByName('import_file');
        if (!$upload) {
            return ['success' => false, 'message' => 'Файл импорта не передан.'];
        }
        $spreadsheet = IOFactory::load($upload->tempName);
        $sheet = $spreadsheet->getActiveSheet();
        $highestRow = $sheet->getHighestRow();
        $rows = [];
        $errors = [];
        for ($r = 2; $r <= $highestRow; $r++) {
            $inventory = trim((string) $sheet->getCell([1, $r])->getValue());
            $name = trim((string) $sheet->getCell([2, $r])->getValue());
            $locationId = (int) $sheet->getCell([4, $r])->getValue();
            $statusId = (int) $sheet->getCell([5, $r])->getValue();
            if ($inventory === '' || $name === '') {
                $errors[] = ['row' => $r, 'message' => 'Пустой inventory_number или name'];
                continue;
            }
            if (!Location::find()->where(['id' => $locationId])->exists()) {
                $errors[] = ['row' => $r, 'message' => 'Не найдено помещение'];
                continue;
            }
            if (!DicEquipmentStatus::find()->where(['id' => $statusId])->exists()) {
                $errors[] = ['row' => $r, 'message' => 'Не найден статус'];
                continue;
            }
            $rows[] = [
                'inventory_number' => $inventory,
                'name' => $name,
                'responsible_user_id' => (int) $sheet->getCell([3, $r])->getValue() ?: null,
                'location_id' => $locationId,
                'status_id' => $statusId,
                'description' => trim((string) $sheet->getCell([6, $r])->getValue()),
            ];
        }
        return ['success' => true, 'rows' => $rows, 'errors' => $errors];
    }

    public function actionImportApply()
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $rows = Yii::$app->request->post('rows', []);
        if (is_string($rows)) {
            $decoded = json_decode($rows, true);
            if (is_array($decoded)) {
                $rows = $decoded;
            }
        }
        if (!is_array($rows) || empty($rows)) {
            return ['success' => false, 'message' => 'Нет данных для импорта.'];
        }

        $ok = 0;
        $errors = [];
        $transaction = Yii::$app->db->beginTransaction();
        try {
            foreach ($rows as $row) {
                $model = Equipment::findOne(['inventory_number' => (string) ($row['inventory_number'] ?? '')]);
                if (!$model) {
                    $model = new Equipment();
                    $model->inventory_number = (string) $row['inventory_number'];
                }
                $model->name = (string) $row['name'];
                $model->responsible_user_id = $row['responsible_user_id'] !== null ? (int) $row['responsible_user_id'] : null;
                $model->location_id = (int) $row['location_id'];
                $model->status_id = (int) $row['status_id'];
                $model->description = (string) ($row['description'] ?? '');
                if (!$model->save(false)) {
                    $errors[] = ['inventory_number' => $row['inventory_number'] ?? '', 'message' => 'Ошибка сохранения'];
                    continue;
                }
                $ok++;
                UserEquipmentCardService::ensureCardForUser((int) $model->responsible_user_id);
            }

            $log = new EquipmentImportLog();
            $log->uploaded_by = Yii::$app->user->id;
            $log->file_name = 'manual_apply_' . date('Ymd_His') . '.xlsx';
            $log->total_rows = count($rows);
            $log->valid_rows = $ok;
            $log->error_rows = count($errors);
            $log->status = empty($errors) ? 'applied' : 'applied_with_errors';
            $log->payload_json = json_encode(['errors' => $errors], JSON_UNESCAPED_UNICODE);
            $log->save(false);

            $transaction->commit();
            return ['success' => true, 'imported' => $ok, 'errors' => $errors];
        } catch (\Throwable $e) {
            $transaction->rollBack();
            return ['success' => false, 'message' => $e->getMessage()];
        }
    }

    private function ensureCanAccessEquipment(Equipment $model): void
    {
        $user = Yii::$app->user->identity;
        if (!$user) {
            throw new \yii\web\ForbiddenHttpException('Доступ запрещён.');
        }
        // Руководитель и сотрудник техподдержки — просмотр любой карточки в разделе «Учёт ТС».
        if ($user->canAccessArm()) {
            return;
        }
        if ((int) $model->responsible_user_id === (int) $user->id) {
            return;
        }
        throw new \yii\web\ForbiddenHttpException('Нет доступа к этой карточке актива.');
    }

    private function ensureCanEditEquipment(Equipment $model): void
    {
        $this->ensureCanAccessEquipment($model);
        $user = Yii::$app->user->identity;
        if ($user && $user->isAdministrator()) {
            return;
        }
        if ($user && (int) $model->responsible_user_id === (int) $user->id) {
            return;
        }
        throw new \yii\web\ForbiddenHttpException('Нет прав на редактирование этой техники.');
    }

    /**
     * @param int $id
     * @return Equipment
     * @throws NotFoundHttpException
     */
    protected function findModel(int $id): Equipment
    {
        if (($model = Equipment::findOne($id)) !== null) {
            return $model;
        }
        throw new NotFoundHttpException('Техника не найдена.');
    }
}
