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
use yii\web\Controller;
use yii\web\ForbiddenHttpException;
use yii\web\NotFoundHttpException;

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
        $dataProvider = new \yii\data\ActiveDataProvider([
            'query' => DicTaskStatus::find()->orderBy(['sort_order' => SORT_ASC]),
            'pagination' => ['pageSize' => 50],
        ]);
        return $this->render('task-status', ['dataProvider' => $dataProvider]);
    }

    public function actionTaskStatusCreate()
    {
        $model = new DicTaskStatus();
        $model->sort_order = 100;
        $model->is_archived = false;
        if ($model->load(Yii::$app->request->post()) && $model->save()) {
            Yii::$app->session->setFlash('success', 'Статус заявки добавлен.');
            return $this->redirect(['task-status']);
        }
        return $this->render('task-status-form', ['model' => $model]);
    }

    public function actionTaskStatusUpdate($id)
    {
        $model = $this->findTaskStatus($id);
        if ($model->load(Yii::$app->request->post()) && $model->save()) {
            Yii::$app->session->setFlash('success', 'Статус заявки обновлён.');
            return $this->redirect(['task-status']);
        }
        return $this->render('task-status-form', ['model' => $model]);
    }

    public function actionTaskStatusArchive($id)
    {
        $model = $this->findTaskStatus($id);
        $count = Tasks::find()->where(['status_id' => $id])->count();
        $model->is_archived = true;
        $model->save(false);
        Yii::$app->session->setFlash('success', $count > 0
            ? 'Статус архивирован (на него ссылаются заявки).'
            : 'Статус архивирован.');
        return $this->redirect(['task-status']);
    }

    /** Локации */
    public function actionLocations()
    {
        $dataProvider = new \yii\data\ActiveDataProvider([
            'query' => Location::find()->orderBy(['name' => SORT_ASC]),
            'pagination' => ['pageSize' => 50],
        ]);
        return $this->render('locations', ['dataProvider' => $dataProvider]);
    }

    public function actionLocationCreate()
    {
        $model = new Location();
        $model->is_archived = false;
        if ($model->load(Yii::$app->request->post()) && $model->save()) {
            Yii::$app->session->setFlash('success', 'Локация добавлена.');
            return $this->redirect(['locations']);
        }
        return $this->render('location-form', ['model' => $model]);
    }

    public function actionLocationUpdate($id)
    {
        $model = $this->findLocation($id);
        if ($model->load(Yii::$app->request->post()) && $model->save()) {
            Yii::$app->session->setFlash('success', 'Локация обновлена.');
            return $this->redirect(['locations']);
        }
        return $this->render('location-form', ['model' => $model]);
    }

    public function actionLocationArchive($id)
    {
        $model = $this->findLocation($id);
        $count = Equipment::find()->where(['location_id' => $id])->count();
        $model->is_archived = true;
        $model->save(false);
        Yii::$app->session->setFlash('success', $count > 0
            ? 'Локация архивирована (на неё ссылаются активы).'
            : 'Локация архивирована.');
        return $this->redirect(['locations']);
    }

    /** Статусы оборудования */
    public function actionEquipmentStatus()
    {
        $dataProvider = new \yii\data\ActiveDataProvider([
            'query' => DicEquipmentStatus::find()->orderBy(['sort_order' => SORT_ASC]),
            'pagination' => ['pageSize' => 50],
        ]);
        return $this->render('equipment-status', ['dataProvider' => $dataProvider]);
    }

    public function actionEquipmentStatusCreate()
    {
        $model = new DicEquipmentStatus();
        $model->sort_order = 100;
        $model->is_archived = false;
        if ($model->load(Yii::$app->request->post()) && $model->save()) {
            Yii::$app->session->setFlash('success', 'Статус оборудования добавлен.');
            return $this->redirect(['equipment-status']);
        }
        return $this->render('equipment-status-form', ['model' => $model]);
    }

    public function actionEquipmentStatusUpdate($id)
    {
        $model = $this->findEquipmentStatus($id);
        if ($model->load(Yii::$app->request->post()) && $model->save()) {
            Yii::$app->session->setFlash('success', 'Статус оборудования обновлён.');
            return $this->redirect(['equipment-status']);
        }
        return $this->render('equipment-status-form', ['model' => $model]);
    }

    public function actionEquipmentStatusArchive($id)
    {
        $model = $this->findEquipmentStatus($id);
        $count = Equipment::find()->where(['status_id' => $id])->count();
        $model->is_archived = true;
        $model->save(false);
        Yii::$app->session->setFlash('success', $count > 0
            ? 'Статус архивирован (на него ссылаются активы).'
            : 'Статус архивирован.');
        return $this->redirect(['equipment-status']);
    }

    /** Типы частей (комплектующие) — spr_parts */
    public function actionParts()
    {
        $dataProvider = new \yii\data\ActiveDataProvider([
            'query' => SprParts::find()->orderBy(['name' => SORT_ASC]),
            'pagination' => ['pageSize' => 50],
        ]);
        return $this->render('parts', ['dataProvider' => $dataProvider]);
    }

    public function actionPartsCreate()
    {
        $model = new SprParts();
        $model->is_archived = false;
        if ($model->load(Yii::$app->request->post()) && $model->save()) {
            Yii::$app->session->setFlash('success', 'Тип части добавлен.');
            return $this->redirect(['parts']);
        }
        return $this->render('parts-form', ['model' => $model]);
    }

    public function actionPartsUpdate($id)
    {
        $model = $this->findPart($id);
        if ($model->load(Yii::$app->request->post()) && $model->save()) {
            Yii::$app->session->setFlash('success', 'Тип части обновлён.');
            return $this->redirect(['parts']);
        }
        return $this->render('parts-form', ['model' => $model]);
    }

    public function actionPartsArchive($id)
    {
        $model = $this->findPart($id);
        $count = PartCharValues::find()->where(['part_id' => $id])->count();
        $model->is_archived = true;
        $model->save(false);
        Yii::$app->session->setFlash('success', $count > 0
            ? 'Тип части архивирован (используется в характеристиках оборудования).'
            : 'Тип части архивирован.');
        return $this->redirect(['parts']);
    }

    /** Характеристики — spr_chars */
    public function actionChars()
    {
        $dataProvider = new \yii\data\ActiveDataProvider([
            'query' => SprChars::find()->orderBy(['name' => SORT_ASC]),
            'pagination' => ['pageSize' => 50],
        ]);
        return $this->render('chars', ['dataProvider' => $dataProvider]);
    }

    public function actionCharsCreate()
    {
        $model = new SprChars();
        $model->is_archived = false;
        if ($model->load(Yii::$app->request->post()) && $model->save()) {
            Yii::$app->session->setFlash('success', 'Характеристика добавлена.');
            return $this->redirect(['chars']);
        }
        return $this->render('chars-form', ['model' => $model]);
    }

    public function actionCharsUpdate($id)
    {
        $model = $this->findChar($id);
        if ($model->load(Yii::$app->request->post()) && $model->save()) {
            Yii::$app->session->setFlash('success', 'Характеристика обновлена.');
            return $this->redirect(['chars']);
        }
        return $this->render('chars-form', ['model' => $model]);
    }

    public function actionCharsArchive($id)
    {
        $model = $this->findChar($id);
        $count = PartCharValues::find()->where(['char_id' => $id])->count();
        $model->is_archived = true;
        $model->save(false);
        Yii::$app->session->setFlash('success', $count > 0
            ? 'Характеристика архивирована (используется в характеристиках оборудования).'
            : 'Характеристика архивирована.');
        return $this->redirect(['chars']);
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
