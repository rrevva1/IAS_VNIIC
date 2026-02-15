<?php

namespace app\controllers;

use app\models\entities\Equipment;
use app\models\entities\EquipmentTypes;
use app\models\entities\EquipHistory;
use app\models\entities\PartCharValues;
use app\models\entities\SprParts;
use app\models\entities\SprChars;
use app\models\entities\Users;
use app\models\entities\Location;
use app\models\dictionaries\DicEquipmentStatus;
use app\models\search\ArmSearch;
use app\components\AuditLog;
use Yii;
use yii\filters\AccessControl;
use yii\filters\VerbFilter;
use yii\helpers\ArrayHelper;
use yii\web\Controller;
use yii\web\Response;
use yii\web\NotFoundHttpException;

/**
 * ArmController — учёт техники (оборудование, таблица equipment).
 * Доступен только администраторам.
 * Колонки грида соответствуют Основному учёту: Пользователь, Помещение, ЦП, ОЗУ, Диск,
 * Системный блок, Инв. №, Монитор, Имя ПК, IP адрес, ОС, ДР техника (см. docs/МАППИНГ_КОЛОНОК_УЧЕТ_ТС.md).
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
                        'actions' => ['view', 'update'],
                        'allow' => true,
                        'roles' => ['@'],
                    ],
                    [
                        'actions' => ['index', 'create', 'get-grid-data', 'delete', 'archive', 'reassign'],
                        'allow' => true,
                        'roles' => ['@'],
                        'matchCallback' => function () {
                            return Yii::$app->user->identity && Yii::$app->user->identity->isAdministrator();
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
                    'archive' => ['POST'],
                    'reassign' => ['POST'],
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
        return $this->render('index', [
            'equipmentTypes' => $equipmentTypes,
            'users' => $users,
            'locations' => $locations,
            'statuses' => $statuses,
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
            // Вкладки передают equipment_type (строка) в корне; ArmSearch ожидает ArmSearch[equipment_type]
            if (array_key_exists('equipment_type', $params)) {
                $params['ArmSearch'] = $params['ArmSearch'] ?? [];
                $params['ArmSearch']['equipment_type'] = $params['equipment_type'];
            }
            $searchModel = new ArmSearch();
            $dataProvider = $searchModel->search($params);
            $dataProvider->pagination = false;
            $charsByEquipment = $this->loadPartCharValuesByEquipment(
                array_map(function ($m) { return $m->id; }, $dataProvider->models)
            );
            $data = [];
            foreach ($dataProvider->models as $model) {
                $chars = $charsByEquipment[$model->id] ?? [];
                $data[] = [
                    'id' => $model->id,
                    'user_name' => $model->responsibleUser ? $model->responsibleUser->getDisplayName() : '',
                    'location_name' => $model->location ? $model->location->name : '',
                    'cpu' => $chars['cpu'] ?? '',
                    'ram' => $chars['ram'] ?? '',
                    'disk' => $chars['disk'] ?? '',
                    'system_block' => $model->name ?? '',
                    'inventory_number' => $model->inventory_number ?? '',
                    'monitor' => $chars['monitor'] ?? '',
                    'hostname' => $chars['hostname'] ?? '',
                    'ip' => $chars['ip'] ?? '',
                    'os' => $chars['os'] ?? '',
                    'other_tech' => $model->description ?? '',
                ];
            }
            return ['success' => true, 'data' => $data, 'total' => count($data)];
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
            if ($part === 'Монитор') {
                $out[$id]['monitor'] = isset($out[$id]['monitor']) ? $out[$id]['monitor'] . ', ' . $val : $val;
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
            if ($part === 'ПК' && $char === 'ОС') {
                $out[$id]['os'] = $val;
                continue;
            }
            // ЦП (как в гриде) — в БД может быть: ЦП, Процессор, CPU и т.д.
            if (($p === 'цп' || $p === 'цпу' || strpos($p, 'процессор') !== false || $p === 'cpu') && (strpos($c, 'модель') !== false || strpos($c, 'частота') !== false)) {
                $out[$id]['cpu'] = isset($out[$id]['cpu']) ? $out[$id]['cpu'] . ' ' . $val : $val;
            } elseif (($p === 'озу' || strpos($p, 'оператив') !== false || strpos($p, 'память') !== false || $p === 'ram') && (strpos($c, 'объем') !== false || strpos($c, 'объём') !== false)) {
                $out[$id]['ram'] = $val;
            } elseif (strpos($p, 'диск') !== false || strpos($p, 'накопитель') !== false || strpos($p, 'жесткий') !== false || $p === 'hdd' || $p === 'ssd') {
                $out[$id]['disk'] = isset($out[$id]['disk']) ? $out[$id]['disk'] . ', ' . $val : $val;
            } elseif (strpos($p, 'монитор') !== false) {
                $out[$id]['monitor'] = isset($out[$id]['monitor']) ? $out[$id]['monitor'] . ', ' . $val : $val;
            } elseif (strpos($c, 'имя пк') !== false || $c === 'hostname' || ($p === 'пк' && (strpos($c, 'имя') !== false || $c === 'hostname'))) {
                $out[$id]['hostname'] = $val;
            } elseif (strpos($c, 'ip') !== false && strpos($c, 'адрес') !== false || $c === 'ip') {
                $out[$id]['ip'] = $val;
            } elseif ($c === 'ос' || strpos($c, 'операционн') !== false) {
                $out[$id]['os'] = $val;
            }
        }
        return $out;
    }

    public function actionCreate()
    {
        $model = new Equipment();
        $model->loadDefaultValues();

        $users = ArrayHelper::map(
            Users::find()->orderBy(['full_name' => SORT_ASC])->all(),
            'id',
            function (Users $u) {
                return $u->getDisplayName();
            }
        );

        $locations = ArrayHelper::map(
            Location::find()->orderBy(['name' => SORT_ASC])->all(),
            'id',
            'name'
        );

        $statuses = DicEquipmentStatus::getList();
        $equipmentTypes = EquipmentTypes::getList();

        if ($model->load(Yii::$app->request->post()) && $model->save()) {
            $this->savePartCharValuesFromPost($model->id, Yii::$app->request->post('PartChar', []));
            EquipHistory::log($model->id, 'create', null, ['inventory_number' => $model->inventory_number, 'name' => $model->name]);
            AuditLog::log('equipment.create', 'equipment', $model->id, 'success');
            Yii::$app->session->setFlash('success', 'Техника успешно добавлена.');
            return $this->redirect(['index']);
        }

        return $this->render('create', [
            'model' => $model,
            'users' => $users,
            'locations' => $locations,
            'statuses' => $statuses,
            'equipmentTypes' => $equipmentTypes,
            'chars' => [],
        ]);
    }

    /**
     * Просмотр карточки актива.
     */
    public function actionView($id)
    {
        $model = $this->findModel((int) $id);
        $this->ensureCanAccessEquipment($model);
        $chars = $this->loadPartCharValuesByEquipment([$model->id]);
        $history = EquipHistory::find()
            ->where(['equipment_id' => $model->id])
            ->orderBy(['changed_at' => SORT_DESC])
            ->limit(20)
            ->all();
        return $this->render('view', [
            'model' => $model,
            'chars' => $chars[$model->id] ?? [],
            'history' => $history,
        ]);
    }

    /**
     * Редактирование карточки актива.
     */
    public function actionUpdate($id)
    {
        $model = $this->findModel((int) $id);
        $this->ensureCanAccessEquipment($model);
        $users = ArrayHelper::map(
            Users::find()->orderBy(['full_name' => SORT_ASC])->all(),
            'id',
            function (Users $u) { return $u->getDisplayName(); }
        );
        $locations = ArrayHelper::map(Location::find()->orderBy(['name' => SORT_ASC])->all(), 'id', 'name');
        $statuses = DicEquipmentStatus::getList();
        $equipmentTypes = EquipmentTypes::getList();
        $chars = $this->loadPartCharValuesByEquipment([$model->id]);
        if ($model->load(Yii::$app->request->post())) {
            $oldStatus = $model->getOldAttribute('status_id');
            $oldLocation = $model->getOldAttribute('location_id');
            $oldResponsible = $model->getOldAttribute('responsible_user_id');
            if ($model->save()) {
                $this->savePartCharValuesFromPost($model->id, Yii::$app->request->post('PartChar', []));
                $eventType = 'update';
                if ($oldLocation !== $model->location_id) {
                    EquipHistory::log($model->id, 'move', ['location_id' => $oldLocation], ['location_id' => $model->location_id]);
                }
                if ($oldResponsible !== $model->responsible_user_id) {
                    EquipHistory::log($model->id, $model->responsible_user_id ? 'assign' : 'unassign', ['responsible_user_id' => $oldResponsible], ['responsible_user_id' => $model->responsible_user_id]);
                }
                if ($oldStatus !== $model->status_id) {
                    EquipHistory::log($model->id, 'status_change', ['status_id' => $oldStatus], ['status_id' => $model->status_id]);
                }
                if ($oldStatus === $model->status_id && $oldLocation === $model->location_id && $oldResponsible === $model->responsible_user_id) {
                    EquipHistory::log($model->id, 'update', null, ['inventory_number' => $model->inventory_number, 'name' => $model->name]);
                }
                AuditLog::log('equipment.update', 'equipment', $model->id, 'success');
                Yii::$app->session->setFlash('success', 'Данные обновлены.');
                return $this->redirect(['view', 'id' => $model->id]);
            }
        }
        return $this->render('update', [
            'model' => $model,
            'users' => $users,
            'locations' => $locations,
            'statuses' => $statuses,
            'equipmentTypes' => $equipmentTypes,
            'chars' => $chars[$model->id] ?? [],
        ]);
    }

    /**
     * Сохраняет значения характеристик из формы PartChar.
     * Маппинг: cpu->(ЦП,Модель), ram->(ОЗУ,Объём), disk->(Накопитель,Объём), monitor->(Монитор,Модель),
     * hostname->(ПК,Имя ПК), ip->(ПК,IP адрес), os->(ПК,ОС), model->(Монитор,Модель).
     */
    private function savePartCharValuesFromPost(int $equipmentId, array $partChar): void
    {
        $map = [
            'cpu' => ['ЦП', 'Модель'],
            'ram' => ['ОЗУ', 'Объём'],
            'disk' => ['Накопитель', 'Объём'],
            'monitor' => ['Монитор', 'Модель'],
            'hostname' => ['ПК', 'Имя ПК'],
            'ip' => ['ПК', 'IP адрес'],
            'os' => ['ПК', 'ОС'],
            'model' => ['Монитор', 'Модель'],
            'diagonal' => ['Монитор', '№ монитора'],
        ];
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

        $responsibleUserId = Yii::$app->request->post('responsible_user_id');
        $locationId = Yii::$app->request->post('location_id');
        $statusId = Yii::$app->request->post('status_id');

        $updated = 0;
        foreach ($ids as $id) {
            $model = Equipment::findOne($id);
            if (!$model) {
                continue;
            }
            $changed = false;
            if ($responsibleUserId !== null && $responsibleUserId !== '') {
                $newUser = (int) $responsibleUserId;
                if ($model->responsible_user_id !== $newUser) {
                    $oldUser = $model->responsible_user_id;
                    $model->responsible_user_id = $newUser ?: null;
                    EquipHistory::log($model->id, $model->responsible_user_id ? 'assign' : 'unassign', ['responsible_user_id' => $oldUser], ['responsible_user_id' => $model->responsible_user_id]);
                    $changed = true;
                }
            }
            if ($locationId !== null && $locationId !== '') {
                $newLoc = (int) $locationId;
                if ($model->location_id != $newLoc) {
                    $oldLoc = $model->location_id;
                    $model->location_id = $newLoc;
                    EquipHistory::log($model->id, 'move', ['location_id' => $oldLoc], ['location_id' => $model->location_id]);
                    $changed = true;
                }
            }
            if ($statusId !== null && $statusId !== '') {
                $newStatus = (int) $statusId;
                if ($model->status_id != $newStatus) {
                    $oldStatus = $model->status_id;
                    $model->status_id = $newStatus;
                    EquipHistory::log($model->id, 'status_change', ['status_id' => $oldStatus], ['status_id' => $model->status_id]);
                    $changed = true;
                }
            }
            if ($changed && $model->save(false)) {
                $updated++;
                AuditLog::log('equipment.reassign', 'equipment', $model->id, 'success');
            }
        }

        return [
            'success' => true,
            'message' => "Обновлено единиц техники: {$updated} из " . count($ids),
            'updated' => $updated,
        ];
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
