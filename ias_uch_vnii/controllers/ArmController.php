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
use yii\web\NotFoundHttpException;

/**
 * ArmController — учёт техники (оборудование, таблица equipment, схема tech_accounting).
 * Доступен только администраторам.
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

    public function actionIndex()
    {
        $searchModel = new ArmSearch();
        $dataProvider = $searchModel->search(Yii::$app->request->queryParams);

        return $this->render('index', [
            'searchModel' => $searchModel,
            'dataProvider' => $dataProvider,
        ]);
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
