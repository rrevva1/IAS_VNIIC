<?php

namespace app\controllers;

use app\models\entities\Users;
use app\models\entities\Equipment;
use app\models\entities\Location;
use app\models\dictionaries\DicEquipmentStatus;
use app\models\search\UsersSearch;
use yii\web\Controller;
use yii\web\Response;
use yii\web\NotFoundHttpException;
use yii\filters\VerbFilter;
use yii\filters\AccessControl;
use yii\helpers\ArrayHelper;
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
                            'actions' => ['index', 'create', 'update', 'delete', 'test', 'arm-create', 'get-grid-data'],
                            'allow' => true,
                            'roles' => ['@'],
                            
                        ],
                        [
                            'actions' => ['view'],
                            'allow' => true,
                            'roles' => ['@'],
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
        
        return $this->render('view', [
            'model' => $this->findModel($id),
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
        
	/** Устанавливаем сценарий создания для правильной валидации */
	$model->setScenario('create');

        if ($this->request->isPost) {
            if ($model->load($this->request->post()) && $model->save()) {
return $this->redirect(['view', 'id' => $model->id]);
        }
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
        $model = $this->findModel($id);

        if ($this->request->isPost && $model->load($this->request->post()) && $model->save()) {
            return $this->redirect(['view', 'id' => $model->id]);
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
        $this->findModel($id)->delete();

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
            Yii::$app->session->setFlash('success', "Пароль пользователя {$user->full_name} сброшен. Новый пароль: {$newPassword}");
        } else {
            Yii::$app->session->setFlash('error', 'Ошибка при сбросе пароля');
        }
        
        return $this->redirect(['view', 'id' => $id]);
    }

    /**
     * Тестирование хешей паролей
     * Проверяет формат сохраненных паролей для отладки
     * 
     * @return void Выводит информацию и завершает выполнение
     */
    public function actionTestPasswords()
    {
        echo "<h2>Тестирование хешей паролей</h2>";
        
        $users = Users::find()->where(['not', ['password_hash' => null]])->all();
        
        foreach ($users as $user) {
            echo "<h3>Пользователь ID: {$user->id}, Email: {$user->email}</h3>";
            echo "<p>Хеш: " . substr($user->password_hash, 0, 20) . "...</p>";
            
            /** Проверяем формат хеша пароля */
            if (strlen($user->password_hash) === 32 && ctype_xdigit($user->password_hash)) {
                echo "<p style='color: orange;'>Формат: MD5 (старый)</p>";
            } else {
                try {
                    Yii::$app->security->validatePassword('test', $user->password_hash);
                    echo "<p style='color: green;'>Формат: Yii2 Security (новый)</p>";
                } catch (\Exception $e) {
                    echo "<p style='color: red;'>Формат: ПОВРЕЖДЕННЫЙ - " . $e->getMessage() . "</p>";
                }
            }
            echo "<hr>";
        }
        
        die;
    }
    
}


