<?php

namespace app\controllers;

use app\models\entities\Users;
use app\models\entities\Equipment;
use app\models\entities\Location;
use app\models\entities\AuditEvent;
use app\models\dictionaries\DicEquipmentStatus;
use app\models\search\UsersSearch;
use yii\web\Controller;
use yii\web\Response;
use yii\web\NotFoundHttpException;
use yii\filters\VerbFilter;
use yii\filters\AccessControl;
use yii\helpers\ArrayHelper;
use app\components\AuditLog;
use Yii;

/**
 * UsersController реализует CRUD операции для модели Users.
 */
class UsersController extends Controller
{
    
    /**
     * Определяет поведения контроллера
     */
    public function behaviors()
    {
        
        return array_merge(
            parent::behaviors(),
            [
                'access' => [
                    'class' => AccessControl::class,
                    'rules' => [
                        [
                            'actions' => ['reset-password'],
                            'allow' => true,
                            'roles' => ['@'],
                            'matchCallback' => function () {
                                return Yii::$app->user->identity && Yii::$app->user->identity->isAdministrator();
                            },
                        ],
                        [
                            'actions' => ['index', 'create', 'update', 'delete', 'arm-create', 'get-grid-data'],
                            'allow' => true,
                            'roles' => ['@'],
                        ],
                        [
                            'actions' => ['view'],
                            'allow' => true,
                            'roles' => ['@'],
                        ],
                        [
                            'actions' => ['test-passwords', 'index2'],
                            'allow' => false,
                        ],
                    ],
                ],
                'verbs' => [
                    'class' => VerbFilter::className(),
                    'actions' => [
                        'delete' => ['POST'],
                    ],
                ],
            ]
        );
    }

    /**
     * Отображает список всех пользователей.
     *
     * @return string
     */
    public function actionIndex()
    {
        /** Если пользователь не администратор, перенаправляем на просмотр только его данных */
        if (!Yii::$app->user->identity->isAdmin()) {
            return $this->redirect(['view', 'id' => Yii::$app->user->id]);
        }

        if ($this->request->isAjax) {
            $searchModel = new UsersSearch();
            $dataProvider = $searchModel->search($this->request->queryParams);
            return $this->renderAjax('index_ajax', [
                'searchModel' => $searchModel,
                'dataProvider' => $dataProvider,
            ]);
        }

        return $this->render('index');
    }

    /**
     * JSON для AG Grid пользователей.
     *
     * @return array
     */
    public function actionGetGridData()
    {
        if (!Yii::$app->user->identity->isAdmin()) {
            throw new \yii\web\ForbiddenHttpException('Доступ разрешен только администраторам.');
        }

        Yii::$app->response->format = Response::FORMAT_JSON;
        try {
            $searchModel = new UsersSearch();
            $dataProvider = $searchModel->search($this->request->queryParams);
            $dataProvider->pagination = false;
            $dataProvider->query->with('roles');

            $data = [];
            foreach ($dataProvider->getModels() as $model) {
                $roles = $model->roles ?? [];
                $roleNames = [];
                foreach ($roles as $role) {
                    $roleNames[] = $role->role_name;
                }
                $data[] = [
                    'id' => $model->id,
                    'full_name' => $model->full_name,
                    'email' => $model->email,
                    'role_name' => $roleNames ? implode(', ', $roleNames) : null,
                ];
            }

            return ['success' => true, 'data' => $data, 'total' => count($data)];
        } catch (\Throwable $e) {
            return ['success' => false, 'message' => $e->getMessage(), 'data' => [], 'total' => 0];
        }
    }

    /**
     * Отображает одного пользователя.
     * @param int $id ID
     * @return string
     * @throws NotFoundHttpException если модель не найдена
     */
    public function actionView($id)
    {
        /** Проверяем права доступа - обычные пользователи видят только свои данные */
        if (!Yii::$app->user->identity->isAdmin() && $id != Yii::$app->user->id) {
            throw new \yii\web\ForbiddenHttpException('У вас нет прав для просмотра данных других пользователей.');
        }

        $model = $this->findModel($id);
        $equipment = Equipment::find()
            ->where(['responsible_user_id' => $model->id, 'is_archived' => false])
            ->with('location')
            ->orderBy(['inventory_number' => SORT_ASC])
            ->limit(10)
            ->all();
        $recentActions = [];
        try {
            if (class_exists(AuditEvent::class)) {
                $recentActions = AuditEvent::find()
                    ->where(['actor_id' => $model->id])
                    ->orderBy(['event_time' => SORT_DESC])
                    ->limit(10)
                    ->all();
            }
        } catch (\Throwable $e) {
            // audit_events может отсутствовать
        }

        return $this->render('view', [
            'model' => $model,
            'equipment' => $equipment,
            'recentActions' => $recentActions,
        ]);
    }

    /**
     * Создает нового пользователя.
     * В случае успеха браузер будет перенаправлен на страницу 'view'.
     * @return string|\yii\web\Response
     */
    public function actionCreate()
    {
        $model = new Users();
        $model->setScenario('create');

        if ($this->request->isPost) {
            if ($model->load($this->request->post()) && $model->save()) {
                Yii::$app->session->setFlash('success', 'Пользователь успешно создан.');
                return $this->redirect(['view', 'id' => $model->id]);
            }
            $errors = $model->getFirstErrors();
            Yii::$app->session->setFlash('error', 'Не удалось создать пользователя: ' . implode(' ', $errors ?: ['проверьте введённые данные']));
        } else {
            $model->loadDefaultValues();
        }

        return $this->render('create', [
            'model' => $model,
        ]);
    }

    /**
     * Обновляет существующего пользователя.
     * В случае успеха браузер будет перенаправлен на страницу 'view'.
     * @param int $id ID
     * @return string|\yii\web\Response
     * @throws NotFoundHttpException если модель не найдена
     */
    public function actionUpdate($id)
    {
        /** Обычный пользователь может редактировать только свой профиль */
        if (!Yii::$app->user->identity->isAdmin() && (int) $id !== (int) Yii::$app->user->id) {
            throw new \yii\web\ForbiddenHttpException('У вас нет прав для редактирования данных других пользователей.');
        }

        $model = $this->findModel($id);
        $model->setScenario('update');

        if ($this->request->isPost && $model->load($this->request->post())) {
            if ($model->save()) {
                Yii::$app->session->setFlash('success', 'Изменения пользователя успешно сохранены.');
                return $this->redirect(['view', 'id' => $model->id]);
            }
            $errors = $model->getFirstErrors();
            Yii::$app->session->setFlash('error', 'Не удалось сохранить изменения: ' . implode(' ', $errors ?: ['проверьте введённые данные']));
        }

        return $this->render('update', [
            'model' => $model,
        ]);
    }

    /**
     * Удаляет существующего пользователя.
     * В случае успеха браузер будет перенаправлен на страницу 'index'.
     * @param int $id ID
     * @return \yii\web\Response
     * @throws NotFoundHttpException если модель не найдена
     */
    public function actionDelete($id)
    {
        $model = $this->findModel($id);
        $name = $model->full_name;
        $model->delete();
        Yii::$app->session->setFlash('success', "Пользователь «{$name}» успешно удалён.");
        return $this->redirect(['index']);
    }

    /**
     * Находит модель Users по значению первичного ключа.
     * Если модель не найдена, будет выброшено исключение 404 HTTP.
     * @param int $id ID
     * @return Users загруженная модель
     * @throws NotFoundHttpException если модель не найдена
     */
    protected function findModel($id)
    {
        if (($model = Users::findOne(['id' => $id])) !== null) {
            return $model;
        }


        throw new NotFoundHttpException('Запрашиваемая страница не существует.');
    }



    /**
     * Создание записи техники (АРМ) для пользователя
     * @param int $userId ID пользователя, которому назначается техника
     * @return string|\yii\web\Response|\yii\web\Response
     */
    public function actionArmCreate($userId)
    {
        /** Проверка прав: пользователь может добавлять технику только себе, админ — кому угодно */
        if (!Yii::$app->user->identity->isAdmin() && (int)$userId !== (int)Yii::$app->user->id) {
            throw new \yii\web\ForbiddenHttpException('Недостаточно прав для добавления техники этому пользователю.');
        }

        $model = new Equipment();
        $model->responsible_user_id = (int)$userId;
        $model->loadDefaultValues();

        $locations = ArrayHelper::map(Location::find()->orderBy(['name' => SORT_ASC])->all(), 'id', 'name');
        $statuses = DicEquipmentStatus::getList();

        if ($model->load($this->request->post()) && $model->save()) {
            Yii::$app->session->setFlash('success', 'Техника успешно добавлена.');

            if ($this->request->isAjax) {
                return $this->asJson([
                    'success' => true,
                    'id' => $model->id,
                ]);
            }
            return $this->redirect(['view', 'id' => $userId]);
        }

        if ($this->request->isAjax) {
            return $this->renderAjax('_arm_form', [
                'model' => $model,
                'locations' => $locations,
                'statuses' => $statuses,
                'userId' => $userId,
            ]);
        }

        return $this->render('arm_create', [
            'model' => $model,
            'locations' => $locations,
            'statuses' => $statuses,
            'userId' => $userId,
        ]);
    }

    /**
     * Сброс пароля пользователя
     * Устанавливает новый пароль и отображает его администратору
     * 
     * @param int $id ID пользователя
     * @return \yii\web\Response
     */
    public function actionResetPassword($id)
    {
        $user = $this->findModel($id);
        
        /** Устанавливаем новый пароль (в продакшене лучше сделать случайным) */
        $newPassword = 'password123';
        $user->setPassword($newPassword);
        
        if ($user->save(false)) {
            AuditLog::log('user.password_reset', 'user', $user->id, 'success', ['target_user_id' => $user->id]);
            Yii::$app->session->setFlash('success', "Пароль пользователя {$user->full_name} сброшен. Новый пароль: {$newPassword}");
        } else {
            Yii::$app->session->setFlash('error', 'Ошибка при сбросе пароля');
        }
        
        return $this->redirect(['view', 'id' => $id]);
    }

    /**
     * Тестирование хешей паролей — отключено в production (доступ запрещён).
     */
    public function actionTestPasswords()
    {
        throw new \yii\web\ForbiddenHttpException('Доступ запрещён.');
    }

    /**
     * Альтернативное представление списка — отключено (доступ запрещён).
     */
    public function actionIndex2()
    {
        throw new \yii\web\ForbiddenHttpException('Доступ запрещён.');
    }
}


