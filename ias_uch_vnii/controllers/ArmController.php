<?php

namespace app\controllers;

use app\models\entities\Equipment;
use app\models\entities\EquipmentTypes;
use app\models\entities\EquipmentLink;
use app\models\entities\EquipmentImportLog;
use app\models\entities\EquipHistory;
use app\models\entities\PartCharValues;
use app\models\entities\SprParts;
use app\models\entities\SprChars;
use app\models\entities\Users;
use app\models\entities\Location;
use app\models\dictionaries\DicEquipmentStatus;
use app\models\search\ArmSearch;
use app\components\AuditLog;
use app\components\EquipmentCharCatalog;
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
    public function behaviors()
    {
        return [
            'access' => [
                'class' => AccessControl::class,
                'rules' => [
                    [
                        'actions' => ['create', 'create-modal', 'delete', 'archive', 'reassign', 'get-selected-info', 'system-blocks', 'user-primary-location', 'link-components', 'export-xlsx', 'import-template-xlsx', 'import-preview', 'import-apply'],
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
                    'archive' => ['POST'],
                    'reassign' => ['POST'],
                    'get-selected-info' => ['POST'],
                    'link-components' => ['POST'],
                    'import-preview' => ['POST'],
                    'import-apply' => ['POST'],
                ],
            ],
        ];
    }

    /**
     * Список ТС: страница с AG Grid (данные подгружаются через actionGetGridData).
     */
    public function actionIndex()
    {
        $equipmentTypes = $this->getEquipmentTypesForTabs();
        $users = ArrayHelper::map(
            Users::find()->orderBy(['full_name' => SORT_ASC])->all(),
            'id',
            function (Users $u) { return $u->getDisplayName(); }
        );
        $locations = ArrayHelper::map(Location::find()->orderBy(['name' => SORT_ASC])->all(), 'id', 'name');
        $statuses = DicEquipmentStatus::getList();
        $isAdmin = !Yii::$app->user->isGuest
            && Yii::$app->user->identity
            && Yii::$app->user->identity->isAdministrator();

        return $this->render('index', [
            'equipmentTypes' => $equipmentTypes,
            'users' => $users,
            'locations' => $locations,
            'statuses' => $statuses,
            'isAdmin' => $isAdmin,
        ]);
    }

    /**
     * Список типов техники для вкладок (из уникальных equipment.equipment_type, как в дампе).
     * Возвращает [['id' => тип, 'name' => тип], ...]
     */
    private function getEquipmentTypesForTabs(): array
    {
        return EquipmentTypes::getListForTabs();
    }

    /**
     * JSON для AG Grid учёта ТС.
     * Поля соответствуют колонкам Основного учёта (маппинг — в docs/МАППИНГ_КОЛОНОК_УЧЕТ_ТС.md).
     * ЦП, ОЗУ, Диск, Монитор, Имя ПК, IP, ОС подтягиваются из part_char_values при наличии таблиц.
     */
    public function actionGetGridData()
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        try {
            $params = Yii::$app->request->queryParams;
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

            $limit = max(1, min(500, (int)($params['limit'] ?? 20)));
            $offset = max(0, (int)($params['offset'] ?? 0));
            $page = (int) floor($offset / $limit);

            $searchModel = new ArmSearch();
            $dataProvider = $searchModel->search($params);
            if ($dataProvider->pagination !== false) {
                $dataProvider->pagination->pageSize = $limit;
                $dataProvider->pagination->page = $page;
            }

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
                $diskLines = EquipmentCharCatalog::formatDiskGridLines(
                    (string) ($chars['disk'] ?? ''),
                    $linked['disk']
                );
                $statusName = $model->equipmentStatus ? (string) $model->equipmentStatus->status_name : '';
                $statusCode = $model->equipmentStatus ? (string) $model->equipmentStatus->status_code : '';
                $data[] = [
                    'id' => $model->id,
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
                        (string) ($chars['monitor'] ?? ''),
                        $linked['monitor']
                    ),
                    'monitor_char' => (string) ($chars['monitor'] ?? ''),
                    'monitor_list' => $linked['monitor'],
                    'disk_list' => $linked['disk'],
                    'ups' => EquipmentCharCatalog::formatMonitorColumnValue('', $linked['ups']),
                    'ups_list' => $linked['ups'],
                    'hostname' => $chars['hostname'] ?? '',
                    'ip' => $chars['ip'] ?? '',
                    'os' => $chars['os'] ?? '',
                    'screen_diagonal' => $chars['screen_diagonal'] ?? '',
                    'cartridge_procurement' => $this->formatCartridgeProcurementForGrid($model),
                    'other_tech' => $this->formatOtherTechForGrid($model),
                ];
            }
            return ['success' => true, 'data' => $data, 'total' => $total, 'offset' => $offset, 'limit' => $limit];
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
            if ($part === 'ПК' && $char === 'ОС') {
                $out[$id]['os'] = $val;
                continue;
            }
            if ($part === 'ИБП' && $char === 'Модель аккумулятора') {
                $out[$id]['ups_battery'] = $val;
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
            } elseif (($p === 'ибп' || $p === 'ups' || strpos($p, 'ибп') !== false) && strpos($c, 'аккумулятор') !== false) {
                $out[$id]['ups_battery'] = $val;
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
            'writeoff' => 'red',
            'in_stock' => 'gray',
            'archived' => 'gray',
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
        if (strpos($s, 'списан') !== false) {
            return 'red';
        }
        if (strpos($s, 'склад') !== false || strpos($s, 'резерв') !== false) {
            return 'gray';
        }

        return 'gray';
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
        if (!$model->save()) {
            $firstErrors = $model->getFirstErrors();

            return [
                'success' => false,
                'message' => 'Не удалось сохранить технику'
                    . ($firstErrors ? ': ' . implode(' ', $firstErrors) : ''),
                'errors' => $model->errors,
            ];
        }

        $this->savePartCharValuesFromPost($model->id, $post['PartChar'] ?? []);
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
        ];
    }

    /**
     * @param array<string, mixed> $post
     * @return array{success: bool, message: string, equipment_id?: int, errors?: array}
     */
    private function persistUpdatedEquipment(Equipment $model, array $post): array
    {
        if (!$model->load($post)) {
            return [
                'success' => false,
                'message' => 'Не удалось загрузить данные формы.',
                'errors' => $model->errors,
            ];
        }

        $this->applyOrgTechDescriptionFromPost($model);
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

        $this->savePartCharValuesFromPost($model->id, $post['PartChar'] ?? []);

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
        $history = EquipHistory::find()
            ->where(['equipment_id' => $model->id])
            ->with('changedByUser')
            ->orderBy(['changed_at' => SORT_DESC])
            ->limit(50)
            ->all();

        return [
            'model' => $model,
            'chars' => $chars[$model->id] ?? [],
            'history' => $history,
        ];
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
        $isOrgTech = $equipment && EquipmentCharCatalog::isPrinterOrMfuType($equipment->resolveEquipmentTypeName());

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
        ];
        if ($isOrgTech) {
            $map = array_merge($map, EquipmentCharCatalog::getPrinterMfuPartCharSaveMap());
        }
        foreach ($partChar as $key => $value) {
            $value = is_string($value) ? trim($value) : '';
            if ($value === '') continue;
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

        $data = [];
        $responsibleUsers = [];
        $locations = [];
        $statuses = [];

        foreach ($equipment as $eq) {
            $isHost = $this->isHostEquipment($eq);
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
                'is_host' => $isHost,
                'is_component' => !$isHost && $this->isLinkableComponentEquipment($eq),
                'linked_components' => $isHost
                    ? ($linksByParent[(int) $eq->id] ?? ['monitor' => [], 'disk' => [], 'ups' => []])
                    : ['monitor' => [], 'disk' => [], 'ups' => []],
            ];
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
            if (count($ids) !== 1) {
                return [
                    'success' => false,
                    'message' => 'Для переноса компонента выберите один монитор, ИБП или системный блок в таблице.',
                ];
            }
            $moveEquipment = Equipment::findOne((int) $ids[0]);
            if (!$moveEquipment) {
                return ['success' => false, 'message' => 'Оборудование для переноса не найдено.'];
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
        } else {
            $ids = $this->expandReassignIdsWithLinkedComponents($ids, $operationMode);
        }
        $responsibleUserId = Yii::$app->request->post('responsible_user_id');
        $locationId = Yii::$app->request->post('location_id');
        $statusId = Yii::$app->request->post('status_id');
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
        $errors = [];

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
                    if ($responsibleUserId !== null && $responsibleUserId !== '') {
                        $newUser = ($responsibleUserId === '' || $responsibleUserId === '0') ? null : (int) $responsibleUserId;
                        if (!EquipHistory::idsEqual($model->responsible_user_id, $newUser)) {
                            $model->responsible_user_id = $newUser;
                            EquipHistory::log($model->id, $model->responsible_user_id ? 'assign' : 'unassign', ['responsible_user_id' => $oldResponsible], ['responsible_user_id' => $model->responsible_user_id]);
                            $changed = true;
                            $responsibleUserChanged++;
                        }
                    }
                    if ($locationId !== null && $locationId !== '') {
                        $newLoc = (int) $locationId;
                        if (!EquipHistory::idsEqual($model->location_id, $newLoc)) {
                            $oldLoc = $model->location_id;
                            $model->location_id = $newLoc;
                            EquipHistory::log($model->id, 'move', ['location_id' => $oldLoc], ['location_id' => $model->location_id]);
                            $changed = true;
                            $locationChanged++;
                        }
                    }
                    if ($statusId !== null && $statusId !== '') {
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

            $transaction->commit();
        } catch (\Throwable $e) {
            $transaction->rollBack();
            return ['success' => false, 'message' => 'Ошибка операции переназначения: ' . $e->getMessage()];
        }

        return [
            'success' => true,
            'message' => "Обновлено единиц техники: {$updated} из " . count($ids),
            'updated' => $updated,
            'details' => [
                'responsible_user_changed' => $responsibleUserChanged,
                'location_changed' => $locationChanged,
                'status_changed' => $statusChanged,
                'errors' => $errors,
            ],
        ];
    }

    public function actionSystemBlocks()
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        try {
            $userId = (int) Yii::$app->request->get('user_id', 0);
            $q = trim((string) Yii::$app->request->get('q', ''));

            $query = Equipment::find()
                ->alias('e')
                ->select(['e.id', 'e.name', 'e.inventory_number', 'e.location_id'])
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
     * Столбец «Комментарий» — «Другая техника» у ПК; у принтера/МФУ — примечание без строки про картриджи.
     */
    private function formatOtherTechForGrid(Equipment $equipment): string
    {
        $type = $equipment->resolveEquipmentTypeName();
        if (EquipmentCharCatalog::isPrinterOrMfuType($type)) {
            return EquipmentCharCatalog::formatPrinterComment($equipment->description);
        }
        if (!$this->isHostEquipment($equipment)) {
            return '';
        }

        return trim((string) ($equipment->description ?? ''));
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
            if (!empty($params['equipment_type'])) {
                $params['ArmSearch'] = $params['ArmSearch'] ?? [];
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
                EquipmentCharCatalog::formatDiskGridLines((string) ($chars['disk'] ?? ''), $links['disk'] ?? [])
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
                (string) ($chars['monitor'] ?? ''),
                $links['monitor'] ?? []
            )],
            'ups' => ['ИБП', static fn($m, $chars, $links) => EquipmentCharCatalog::formatMonitorColumnValue(
                '',
                $links['ups'] ?? []
            )],
            'hostname' => ['Имя ПК', static fn($m, $chars, $links) => $chars['hostname'] ?? ''],
            'ip' => ['IP адрес', static fn($m, $chars, $links) => $chars['ip'] ?? ''],
            'os' => ['ОС', static fn($m, $chars, $links) => $chars['os'] ?? ''],
            'screen_diagonal' => ['Диагональ экрана', static fn($m, $chars, $links) => $chars['screen_diagonal'] ?? ''],
            'cartridge_procurement' => ['Закупка картриджей', fn($m, $chars, $links) => $this->formatCartridgeProcurementForGrid($m)],
            'other_tech' => ['Комментарий', fn($m, $chars, $links) => $this->formatOtherTechForGrid($m)],
        ];

        $defaultCols = ['user_name', 'location_name', 'status_name', 'cpu', 'ram', 'disk', 'system_block', 'inventory_number', 'purchase_date', 'monitor', 'ups', 'hostname', 'ip', 'os', 'other_tech'];
        $scope = trim((string)($params['export_scope'] ?? 'all'));
        $colsParam = trim((string)($params['cols'] ?? ''));
        $selectedCols = $defaultCols;
        if ($scope === 'visible' && $colsParam !== '') {
            $requested = array_values(array_unique(array_filter(array_map('trim', explode(',', $colsParam)))));
            $filtered = array_values(array_filter($requested, static fn($c) => isset($columnMap[$c])));
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

    /**
     * Архивирование актива (вывод из актуального учета).
     */
    public function actionArchive($id)
    {
        $model = $this->findModel((int) $id);
        $this->ensureCanAccessEquipment($model);
        $reason = Yii::$app->request->post('archive_reason', '');
        $model->is_archived = true;
        $model->archived_at = date('Y-m-d H:i:s');
        $model->archive_reason = $reason;
        if ($model->save(false)) {
            EquipHistory::log($model->id, 'archive', ['is_archived' => false], ['is_archived' => true], $reason);
            AuditLog::log('equipment.archive', 'equipment', $model->id, 'success', ['archive_reason' => $reason]);
            Yii::$app->session->setFlash('success', 'Актив архивирован.');
        } else {
            Yii::$app->session->setFlash('error', 'Ошибка при архивировании.');
        }
        return $this->redirect(['view', 'id' => $model->id]);
    }

    private function ensureCanAccessEquipment(Equipment $model): void
    {
        $user = Yii::$app->user->identity;
        if (!$user) {
            throw new \yii\web\ForbiddenHttpException('Доступ запрещён.');
        }
        if ($user->isAdministrator()) {
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
