<?php

namespace app\controllers;

use app\models\entities\Users;
use app\models\entities\Tasks;
use app\models\entities\Equipment;
use app\models\dictionaries\DicTaskStatus;
use app\models\entities\Location;
use app\models\entities\AuditEvent;
use app\models\dictionaries\DicEquipmentStatus;
use app\models\dictionaries\Roles;
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
                            'actions' => ['index', 'create', 'create-modal', 'view-modal', 'update-modal', 'profile-modal', 'update', 'delete', 'arm-create', 'get-grid-data'],
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

        $roles = Roles::find()
            ->where(['is_archived' => false])
            ->orderBy(['role_name' => SORT_ASC])
            ->all();

        return $this->render('index', [
            'roles' => $roles,
        ]);
    }

    /**
     * Форма создания пользователя в модальном окне (GET — HTML, POST — JSON).
     */
    public function actionCreateModal()
    {
        if (!Yii::$app->user->identity->isAdmin()) {
            throw new \yii\web\ForbiddenHttpException('Доступ разрешен только администраторам.');
        }

        $model = new Users();
        $model->setScenario('create');

        if ($this->request->isPost) {
            Yii::$app->response->format = Response::FORMAT_JSON;

            if ($model->load($this->request->post())) {
                if (empty($model->username) && !empty($model->email)) {
                    $model->username = $model->email;
                }
                if ($model->is_active === null) {
                    $model->is_active = true;
                }

                if ($model->save()) {
                    AuditLog::log('user.create', 'user', $model->id, 'success');

                    return [
                        'success' => true,
                        'message' => 'Пользователь «' . $model->full_name . '» создан.',
                        'user_id' => (int) $model->id,
                    ];
                }
            }

            $errors = $model->getFirstErrors();

            return [
                'success' => false,
                'errors' => $model->errors,
                'message' => 'Не удалось создать пользователя'
                    . ($errors ? ': ' . implode(' ', $errors) : ''),
            ];
        }

        $model->loadDefaultValues();
        $model->is_active = true;

        return $this->renderAjax('_form_modal', [
            'model' => $model,
            'roleItems' => Roles::getList(),
            'isUpdate' => false,
        ]);
    }

    /**
     * Форма редактирования пользователя в модальном окне (GET — HTML, POST — JSON).
     */
    public function actionUpdateModal($id)
    {
        if (!Yii::$app->user->identity->isAdmin()) {
            throw new \yii\web\ForbiddenHttpException('Доступ разрешен только администраторам.');
        }

        $model = $this->findModel($id);
        $model->setScenario('update');

        if ($this->request->isPost) {
            Yii::$app->response->format = Response::FORMAT_JSON;
            $post = $this->request->post();

            if (!$model->load($post)) {
                return [
                    'success' => false,
                    'message' => 'Не удалось принять данные формы. Обновите окно и повторите попытку.',
                ];
            }

            if (empty($model->username) && !empty($model->email)) {
                $model->username = $model->email;
            }

            if ($model->save()) {
                AuditLog::log('user.update', 'user', $model->id, 'success');

                return [
                    'success' => true,
                    'message' => 'Изменения пользователя «' . $model->full_name . '» сохранены.',
                    'user_id' => (int) $model->id,
                ];
            }

            $errors = $model->getFirstErrors();

            return [
                'success' => false,
                'errors' => $model->errors,
                'message' => 'Не удалось сохранить изменения'
                    . ($errors ? ': ' . implode(' ', $errors) : ''),
            ];
        }

        return $this->renderAjax('_form_modal', [
            'model' => $model,
            'roleItems' => Roles::getList(),
            'isUpdate' => true,
        ]);
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
                $roleCodes = [];
                foreach ($roles as $role) {
                    $roleNames[] = $role->role_name;
                    $roleCodes[] = $role->role_code;
                }
                $roleCode = null;
                if (count($roleCodes) === 1) {
                    $roleCode = $roleCodes[0];
                } elseif (count($roleCodes) > 1) {
                    $roleCode = 'other';
                }
                $data[] = [
                    'id' => $model->id,
                    'full_name' => $model->full_name,
                    'email' => $model->email,
                    'phone' => $model->phone,
                    'role_name' => $roleNames ? implode(', ', $roleNames) : null,
                    'role_code' => $roleCode,
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
        $model = $this->findModel($id);
        $this->ensureCanViewUser($model);

        $isOwnProfile = (int) Yii::$app->user->id === (int) $model->id;
        if (Yii::$app->user->identity->isAdmin() && !$isOwnProfile && !$this->request->isAjax) {
            return $this->redirect(['index', 'user' => $model->id]);
        }

        return $this->render('view', $this->getProfileViewParams($model));
    }

    /**
     * Карточка пользователя для модального окна (GET — HTML).
     */
    public function actionViewModal($id)
    {
        $model = $this->findModel($id);
        $this->ensureCanViewUser($model);

        return $this->renderAjax('_view_content', array_merge(
            $this->getProfileViewParams($model),
            ['isModal' => true]
        ));
    }

    /**
     * Создает нового пользователя.
     * В случае успеха браузер будет перенаправлен на страницу 'view'.
     * @return string|\yii\web\Response
     */
    public function actionCreate()
    {
        Yii::$app->session->setFlash('info', 'Создание пользователя выполняется в модальном окне на странице списка.');

        return $this->redirect(['index']);
    }

    /**
     * Форма редактирования собственного профиля (GET — HTML, POST — JSON).
     */
    public function actionProfileModal()
    {
        $model = $this->findModel((int) Yii::$app->user->id);
        $model->setScenario('ownProfile');

        if ($this->request->isPost) {
            Yii::$app->response->format = Response::FORMAT_JSON;

            if (!$model->load($this->request->post())) {
                return [
                    'success' => false,
                    'message' => 'Не удалось принять данные формы. Обновите окно и повторите попытку.',
                ];
            }

            if ($model->save()) {
                return [
                    'success' => true,
                    'message' => 'Профиль успешно обновлён.',
                    'phone' => $model->phone,
                ];
            }

            $errors = $model->getFirstErrors();

            return [
                'success' => false,
                'errors' => $model->errors,
                'message' => 'Не удалось сохранить изменения'
                    . ($errors ? ': ' . implode(' ', $errors) : ''),
            ];
        }

        return $this->renderAjax('_profile_form_modal', [
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

        $isOwnProfile = (int) Yii::$app->user->id === (int) $model->id;
        if ($isOwnProfile && !$this->request->isAjax) {
            return $this->redirect(['view', 'id' => $model->id, 'editProfile' => 1]);
        }

        if (Yii::$app->user->identity->isAdmin() && !$isOwnProfile && !$this->request->isAjax) {
            return $this->redirect(['index', 'edit' => $model->id]);
        }

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

    /**
     * @throws \yii\web\ForbiddenHttpException
     */
    private function ensureCanViewUser(Users $model): void
    {
        if (!Yii::$app->user->identity->isAdmin() && (int) $model->id !== (int) Yii::$app->user->id) {
            throw new \yii\web\ForbiddenHttpException('У вас нет прав для просмотра данных других пользователей.');
        }
    }

    /**
     * @return array<string, mixed>
     */
    private function getProfileViewParams(Users $model): array
    {
        $isOwnProfile = (int) Yii::$app->user->id === (int) $model->id;
        $isAdminViewer = Yii::$app->user->identity->isAdmin();

        $equipment = Equipment::find()
            ->where(['responsible_user_id' => $model->id, 'is_archived' => false])
            ->with('location')
            ->orderBy(['inventory_number' => SORT_ASC])
            ->limit(10)
            ->all();

        $taskStats = $this->buildProfileTaskStats((int) $model->id);

        $recentActions = [];
        if ($isAdminViewer && !$isOwnProfile) {
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
        }

        return [
            'model' => $model,
            'equipment' => $equipment,
            'recentActions' => $recentActions,
            'isOwnProfile' => $isOwnProfile,
            'isAdminViewer' => $isAdminViewer,
            'taskStats' => $taskStats,
        ];
    }

    /**
     * Сводка по заявкам пользователя для страницы профиля.
     *
     * @return array{total: int, open: int}
     */
    private function buildProfileTaskStats(int $userId): array
    {
        $baseQuery = Tasks::find()->where(['requester_id' => $userId]);
        $total = (int) (clone $baseQuery)->count();

        $completedIds = DicTaskStatus::getCompletedStatusIds();
        $openQuery = Tasks::find()->where(['requester_id' => $userId]);
        if ($completedIds !== []) {
            $openQuery->andWhere(['not in', 'status_id', $completedIds]);
        }

        return [
            'total' => $total,
            'open' => (int) $openQuery->count(),
        ];
    }
}


