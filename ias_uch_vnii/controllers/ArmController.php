<?php

namespace app\controllers;

use app\models\entities\Arm;
use app\models\entities\Users;
use app\models\entities\Location;
use app\models\search\ArmSearch;
use Yii;
use yii\filters\AccessControl;
use yii\filters\VerbFilter;
use yii\helpers\ArrayHelper;
use yii\web\Controller;
use yii\web\NotFoundHttpException;

/**
 * ArmController — учет технических средств (АРМ).
 * Доступен только администраторам.
 */
class ArmController extends Controller
{
    /**
     * Поведения контроллера: доступ только авторизованным администраторам.
     */
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
     * Список техники (около 100 записей).
     * @return string
     */
    public function actionIndex()
    {
        $searchModel = new ArmSearch();
        $dataProvider = $searchModel->search(Yii::$app->request->queryParams);

        return $this->render('index', [
            'searchModel' => $searchModel,
            'dataProvider' => $dataProvider,
        ]);
    }

    /**
     * Создание записи техники с возможностью закрепления за пользователем.
     * @return string|\yii\web\Response
     */
    public function actionCreate()
    {
        $model = new Arm();

        $users = ArrayHelper::map(
            Users::find()->orderBy(['full_name' => SORT_ASC])->all(),
            'id_user',
            function (Users $u) {
                return $u->full_name ?: $u->email;
            }
        );

        $locations = ArrayHelper::map(
            Location::find()->orderBy(['name' => SORT_ASC])->all(),
            'id_location',
            'name'
        );

        if ($model->load(Yii::$app->request->post()) && $model->save()) {
            Yii::$app->session->setFlash('success', 'Техника успешно добавлена.');
            return $this->redirect(['index']);
        }

        return $this->render('create', [
            'model' => $model,
            'users' => $users,
            'locations' => $locations,
        ]);
    }

    /**
     * Поиск модели Arm по первичному ключу.
     * @param int $id
     * @return Arm
     * @throws NotFoundHttpException
     */
    protected function findModel(int $id): Arm
    {
        if (($model = Arm::findOne(['id_arm' => $id])) !== null) {
            return $model;
        }

        throw new NotFoundHttpException('Техника не найдена.');
    }
}





