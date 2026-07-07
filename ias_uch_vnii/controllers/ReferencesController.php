<?php

namespace app\controllers;

use app\models\dictionaries\DicTaskStatus;
use app\models\dictionaries\DicEquipmentStatus;
use app\models\entities\Location;
use app\models\entities\Tasks;
use app\models\entities\Equipment;
use app\models\entities\SprParts;
use app\models\entities\SprChars;
use app\models\entities\PartCharValues;
use Yii;
use yii\filters\AccessControl;
use yii\filters\VerbFilter;
use yii\db\ActiveRecord;
use yii\web\Controller;
use yii\web\ForbiddenHttpException;
use yii\web\NotFoundHttpException;
use yii\web\Response;

/**
 * Модуль справочников (ТЗ 5.1.2). Только для администраторов.
 * Справочники: статусы заявок, локации, статусы оборудования, типы частей (комплектующие), характеристики.
 */
class ReferencesController extends Controller
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
                'denyCallback' => function () {
                    throw new ForbiddenHttpException('Доступ только для администраторов.');
                },
            ],
            'verbs' => [
                'class' => VerbFilter::class,
                'actions' => [
                    'task-status-archive' => ['POST'],
                    'location-archive' => ['POST'],
                    'equipment-status-archive' => ['POST'],
                    'parts-archive' => ['POST'],
                    'chars-archive' => ['POST'],
                ],
            ],
        ];
    }

    public function actionIndex()
    {
        return $this->render('index');
    }

    /** Статусы заявок */
    public function actionTaskStatus()
    {
        return $this->render('task-status');
    }

    /**
     * JSON для AG Grid: статусы заявок.
     */
    public function actionTaskStatusGetGridData()
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $models = DicTaskStatus::find()->orderBy(['sort_order' => SORT_ASC])->all();
        $data = array_map(function (DicTaskStatus $m) {
            return [
                'id' => (int) $m->id,
                'status_code' => $m->status_code ?? '',
                'status_name' => $m->status_name ?? '',
                'sort_order' => (int) $m->sort_order,
                'is_archived' => (bool) $m->is_archived,
            ];
        }, $models);
        return ['success' => true, 'data' => $data, 'total' => count($data)];
    }

    /** @deprecated Открывайте список и используйте модальное окно */
    public function actionTaskStatusCreate()
    {
        return $this->redirect(['task-status']);
    }

    /** @deprecated Открывайте список и используйте модальное окно */
    public function actionTaskStatusUpdate($id)
    {
        return $this->redirect(['task-status']);
    }

    public function actionTaskStatusCreateModal()
    {
        $model = new DicTaskStatus();
        $model->sort_order = 100;
        $model->is_archived = false;

        return $this->handleReferenceModal(
            $model,
            '_forms/task_status',
            'Статус заявки добавлен.',
            'Добавить статус заявки'
        );
    }

    public function actionTaskStatusUpdateModal($id)
    {
        $model = $this->findTaskStatus($id);

        return $this->handleReferenceModal(
            $model,
            '_forms/task_status',
            'Статус заявки обновлён.',
            'Редактировать статус заявки'
        );
    }

    public function actionTaskStatusArchive($id)
    {
        $model = $this->findTaskStatus($id);
        $count = (int) Tasks::find()->where(['status_id' => $id])->count();
        $message = $count > 0
            ? 'Статус архивирован (на него ссылаются заявки).'
            : 'Статус архивирован.';

        return $this->archiveReference($model, ['task-status'], $message);
    }

    /** Локации */
    public function actionLocations()
    {
        return $this->render('locations');
    }

    /**
     * JSON для AG Grid: локации.
     */
    public function actionLocationsGetGridData()
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $models = Location::find()->orderBy(['name' => SORT_ASC])->all();
        $data = array_map(function (Location $m) {
            return [
                'id' => (int) $m->id,
                'name' => $m->name ?? '',
                'location_code' => $m->location_code ?? '',
                'location_type' => $m->location_type ?? '',
                'is_archived' => (bool) $m->is_archived,
            ];
        }, $models);
        return ['success' => true, 'data' => $data, 'total' => count($data)];
    }

    /** @deprecated */
    public function actionLocationCreate()
    {
        return $this->redirect(['locations']);
    }

    /** @deprecated */
    public function actionLocationUpdate($id)
    {
        return $this->redirect(['locations']);
    }

    public function actionLocationCreateModal()
    {
        $model = new Location();
        $model->is_archived = false;

        return $this->handleReferenceModal($model, '_forms/location', 'Локация добавлена.', 'Добавить локацию');
    }

    public function actionLocationUpdateModal($id)
    {
        $model = $this->findLocation($id);

        return $this->handleReferenceModal($model, '_forms/location', 'Локация обновлена.', 'Редактировать локацию');
    }

    public function actionLocationArchive($id)
    {
        $model = $this->findLocation($id);
        $count = (int) Equipment::find()->where(['location_id' => $id])->count();
        $message = $count > 0
            ? 'Локация архивирована (на неё ссылаются активы).'
            : 'Локация архивирована.';

        return $this->archiveReference($model, ['locations'], $message);
    }

    /** Статусы оборудования */
    public function actionEquipmentStatus()
    {
        return $this->render('equipment-status');
    }

    /**
     * JSON для AG Grid: статусы оборудования.
     */
    public function actionEquipmentStatusGetGridData()
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $models = DicEquipmentStatus::find()->orderBy(['sort_order' => SORT_ASC])->all();
        $data = array_map(function (DicEquipmentStatus $m) {
            return [
                'id' => (int) $m->id,
                'status_code' => $m->status_code ?? '',
                'status_name' => $m->status_name ?? '',
                'sort_order' => (int) $m->sort_order,
                'is_archived' => (bool) $m->is_archived,
            ];
        }, $models);
        return ['success' => true, 'data' => $data, 'total' => count($data)];
    }

    /** @deprecated */
    public function actionEquipmentStatusCreate()
    {
        return $this->redirect(['equipment-status']);
    }

    /** @deprecated */
    public function actionEquipmentStatusUpdate($id)
    {
        return $this->redirect(['equipment-status']);
    }

    public function actionEquipmentStatusCreateModal()
    {
        $model = new DicEquipmentStatus();
        $model->sort_order = 100;
        $model->is_archived = false;

        return $this->handleReferenceModal(
            $model,
            '_forms/equipment_status',
            'Статус оборудования добавлен.',
            'Добавить статус оборудования'
        );
    }

    public function actionEquipmentStatusUpdateModal($id)
    {
        $model = $this->findEquipmentStatus($id);

        return $this->handleReferenceModal(
            $model,
            '_forms/equipment_status',
            'Статус оборудования обновлён.',
            'Редактировать статус оборудования'
        );
    }

    public function actionEquipmentStatusArchive($id)
    {
        $model = $this->findEquipmentStatus($id);
        $count = (int) Equipment::find()->where(['status_id' => $id])->count();
        $message = $count > 0
            ? 'Статус архивирован (на него ссылаются активы).'
            : 'Статус архивирован.';

        return $this->archiveReference($model, ['equipment-status'], $message);
    }

    /** Типы частей (комплектующие) — spr_parts */
    public function actionParts()
    {
        return $this->render('parts');
    }

    /**
     * JSON для AG Grid: типы частей.
     */
    public function actionPartsGetGridData()
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $models = SprParts::find()->orderBy(['name' => SORT_ASC])->all();
        $data = array_map(function (SprParts $m) {
            return [
                'id' => (int) $m->id,
                'name' => $m->name ?? '',
                'description' => $m->description ?? '',
                'is_archived' => (bool) $m->is_archived,
            ];
        }, $models);
        return ['success' => true, 'data' => $data, 'total' => count($data)];
    }

    /** @deprecated */
    public function actionPartsCreate()
    {
        return $this->redirect(['parts']);
    }

    /** @deprecated */
    public function actionPartsUpdate($id)
    {
        return $this->redirect(['parts']);
    }

    public function actionPartsCreateModal()
    {
        $model = new SprParts();
        $model->is_archived = false;

        return $this->handleReferenceModal($model, '_forms/parts', 'Тип части добавлен.', 'Добавить тип части');
    }

    public function actionPartsUpdateModal($id)
    {
        $model = $this->findPart($id);

        return $this->handleReferenceModal($model, '_forms/parts', 'Тип части обновлён.', 'Редактировать тип части');
    }

    public function actionPartsArchive($id)
    {
        $model = $this->findPart($id);
        $count = (int) PartCharValues::find()->where(['part_id' => $id])->count();
        $message = $count > 0
            ? 'Тип части архивирован (используется в характеристиках оборудования).'
            : 'Тип части архивирован.';

        return $this->archiveReference($model, ['parts'], $message);
    }

    /** Характеристики — spr_chars */
    public function actionChars()
    {
        return $this->render('chars');
    }

    /**
     * JSON для AG Grid: характеристики.
     */
    public function actionCharsGetGridData()
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $models = SprChars::find()->orderBy(['name' => SORT_ASC])->all();
        $data = array_map(function (SprChars $m) {
            return [
                'id' => (int) $m->id,
                'name' => $m->name ?? '',
                'measurement_unit' => $m->measurement_unit ?? '',
                'description' => $m->description ?? '',
                'is_archived' => (bool) $m->is_archived,
            ];
        }, $models);
        return ['success' => true, 'data' => $data, 'total' => count($data)];
    }

    /** @deprecated */
    public function actionCharsCreate()
    {
        return $this->redirect(['chars']);
    }

    /** @deprecated */
    public function actionCharsUpdate($id)
    {
        return $this->redirect(['chars']);
    }

    public function actionCharsCreateModal()
    {
        $model = new SprChars();
        $model->is_archived = false;

        return $this->handleReferenceModal($model, '_forms/chars', 'Характеристика добавлена.', 'Добавить характеристику');
    }

    public function actionCharsUpdateModal($id)
    {
        $model = $this->findChar($id);

        return $this->handleReferenceModal($model, '_forms/chars', 'Характеристика обновлена.', 'Редактировать характеристику');
    }

    public function actionCharsArchive($id)
    {
        $model = $this->findChar($id);
        $count = (int) PartCharValues::find()->where(['char_id' => $id])->count();
        $message = $count > 0
            ? 'Характеристика архивирована (используется в характеристиках оборудования).'
            : 'Характеристика архивирована.';

        return $this->archiveReference($model, ['chars'], $message);
    }

    /**
     * GET — форма в модальном окне, POST — JSON.
     *
     * @return array|string|Response
     */
    protected function handleReferenceModal(
        ActiveRecord $model,
        string $formView,
        string $successMessage,
        string $modalTitle
    ) {
        if (Yii::$app->request->isPost) {
            Yii::$app->response->format = Response::FORMAT_JSON;
            if ($model->load(Yii::$app->request->post()) && $model->save()) {
                return [
                    'success' => true,
                    'message' => $successMessage,
                    'id' => (int) $model->primaryKey,
                ];
            }

            return [
                'success' => false,
                'errors' => $model->errors,
                'message' => 'Не удалось сохранить'
                    . ($model->getFirstErrors() ? ': ' . implode(' ', $model->getFirstErrors()) : ''),
            ];
        }

        return $this->renderAjax($formView, [
            'model' => $model,
            'isUpdate' => !$model->isNewRecord,
            'modalTitle' => $modalTitle,
        ]);
    }

    /**
     * @param array<int|string, string> $redirectRoute
     */
    protected function archiveReference(ActiveRecord $model, array $redirectRoute, string $message): Response
    {
        $model->is_archived = true;
        $model->save(false);

        if (Yii::$app->request->isAjax) {
            Yii::$app->response->format = Response::FORMAT_JSON;

            return ['success' => true, 'message' => $message];
        }

        Yii::$app->session->setFlash('success', $message);

        return $this->redirect($redirectRoute);
    }

    protected function findTaskStatus($id): DicTaskStatus
    {
        if (($m = DicTaskStatus::findOne($id)) !== null) {
            return $m;
        }
        throw new NotFoundHttpException('Статус не найден.');
    }

    protected function findLocation($id): Location
    {
        if (($m = Location::findOne($id)) !== null) {
            return $m;
        }
        throw new NotFoundHttpException('Локация не найдена.');
    }

    protected function findEquipmentStatus($id): DicEquipmentStatus
    {
        if (($m = DicEquipmentStatus::findOne($id)) !== null) {
            return $m;
        }
        throw new NotFoundHttpException('Статус не найден.');
    }

    protected function findPart($id): SprParts
    {
        if (($m = SprParts::findOne($id)) !== null) {
            return $m;
        }
        throw new NotFoundHttpException('Тип части не найден.');
    }

    protected function findChar($id): SprChars
    {
        if (($m = SprChars::findOne($id)) !== null) {
            return $m;
        }
        throw new NotFoundHttpException('Характеристика не найдена.');
    }
}
