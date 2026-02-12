<?php

namespace app\controllers;

use app\models\entities\Equipment;
use app\models\entities\Users;
use app\models\entities\Location;
use app\models\dictionaries\DicEquipmentStatus;
use app\models\search\ArmSearch;
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
                        'allow' => true,
                        'roles' => ['@'],
                        'matchCallback' => function () {
                            return !Yii::$app->user->isGuest && Yii::$app->user->identity && Yii::$app->user->identity->isAdministrator();
                        },
                    ],
                ],
                'denyCallback' => function () {
                    throw new \yii\web\ForbiddenHttpException('Доступ разрешен только администраторам.');
                },
            ],
            'verbs' => [
                'class' => VerbFilter::class,
                'actions' => [
                    'delete' => ['POST'],
                ],
            ],
        ];
    }

    /**
     * Список ТС: страница с AG Grid (данные подгружаются через actionGetGridData).
     */
    public function actionIndex()
    {
        return $this->render('index');
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
            $searchModel = new ArmSearch();
            $dataProvider = $searchModel->search(Yii::$app->request->queryParams);
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

        if ($model->load(Yii::$app->request->post()) && $model->save()) {
            Yii::$app->session->setFlash('success', 'Техника успешно добавлена.');
            return $this->redirect(['index']);
        }

        return $this->render('create', [
            'model' => $model,
            'users' => $users,
            'locations' => $locations,
            'statuses' => $statuses,
        ]);
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
