<?php

namespace app\controllers;

use app\components\AuditLog;
use app\components\WorkTaskService;
use app\models\dictionaries\DicTaskStatus;
use app\models\dictionaries\DicWorkTaskStatus;
use app\models\entities\WorkTask;
use app\models\entities\WorkTaskComment;
use app\models\search\WorkTaskSearch;
use Yii;
use yii\filters\AccessControl;
use yii\filters\VerbFilter;
use yii\web\Controller;
use yii\web\UploadedFile;
use yii\web\ForbiddenHttpException;
use yii\web\NotFoundHttpException;
use yii\web\Response;

/**
 * Раздел «Задачи» — внутренние поручения исполнителям техподдержки.
 */
class WorkTasksController extends Controller
{
    private WorkTaskService $workTaskService;

    public function init()
    {
        parent::init();
        $this->workTaskService = new WorkTaskService();
    }

    public function beforeAction($action)
    {
        if (parent::beforeAction($action)) {
            DicWorkTaskStatus::syncCanonicalLabels();
            DicTaskStatus::ensureRequestSyncStatuses();

            return true;
        }

        return false;
    }

    public function behaviors()
    {
        return array_merge(parent::behaviors(), [
            'verbs' => [
                'class' => VerbFilter::class,
                'actions' => [
                    'create' => ['POST'],
                    'delete' => ['POST'],
                    'assign' => ['POST'],
                    'add-executor' => ['POST'],
                    'remove-executor' => ['POST'],
                    'transition' => ['POST'],
                    'add-comment' => ['POST'],
                    'bulk-confirm' => ['POST'],
                ],
            ],
            'access' => [
                'class' => AccessControl::class,
                'denyCallback' => static function () {
                    if (Yii::$app->user->isGuest) {
                        return Yii::$app->user->loginRequired();
                    }
                    Yii::$app->session->setFlash(
                        'error',
                        'Раздел «Задачи» доступен только сотрудникам технической поддержки и руководителю.'
                    );

                    $identity = Yii::$app->user->identity;
                    $home = $identity instanceof \app\models\entities\Users
                        ? $identity->getHomeUrl()
                        : ['/tasks/index'];

                    return Yii::$app->response->redirect($home);
                },
                'rules' => [
                    [
                        'allow' => true,
                        'roles' => ['@'],
                        'matchCallback' => static function () {
                            $user = Yii::$app->user->identity;

                            return $user && $user->isSupportStaff();
                        },
                    ],
                ],
            ],
        ]);
    }

    public function actionIndex()
    {
        $queryParams = Yii::$app->request->queryParams;
        $searchModel = new WorkTaskSearch();
        $searchModel->applyRequestParams($queryParams);
        $board = $searchModel->searchForBoard($queryParams);
        $user = Yii::$app->user->identity;
        $allowedByTask = [];
        foreach ($board['tasks'] as $task) {
            $allowedByTask[$task->id] = $this->workTaskService->getAllowedTransitions($task, $user);
        }

        $isManager = $this->isManager();
        $canCreateTask = $this->canCreateWorkTask();
        $pendingReviewCount = 0;
        if ($isManager && ($searchModel->filter ?: 'active') === 'active') {
            $pendingReviewCount = $searchModel->countPendingReview($queryParams);
        }

        return $this->render('index', [
            'searchModel' => $searchModel,
            'board' => $board,
            'timelineSteps' => DicWorkTaskStatus::getTimelineSteps(),
            'allowedByTask' => $allowedByTask,
            'isManager' => $isManager,
            'canCreateTask' => $canCreateTask,
            'pendingReviewCount' => $pendingReviewCount,
            'executors' => WorkTaskService::getExecutorList(),
            'createModel' => $canCreateTask ? new WorkTask() : null,
        ]);
    }

    public function actionView($id)
    {
        $model = $this->findModel((int) $id);
        if (!$this->workTaskService->canAccess($model)) {
            throw new ForbiddenHttpException('Нет доступа к задаче.');
        }

        $comments = $this->loadTaskComments((int) $model->id);

        $payload = [
            'model' => $model,
            'comments' => $comments,
            'timelineSteps' => DicWorkTaskStatus::getTimelineSteps(),
            'allowedTransitions' => $this->workTaskService->getAllowedTransitions($model, Yii::$app->user->identity),
            'isManager' => $this->isManager(),
            'executors' => WorkTaskService::getExecutorList(),
            'canComment' => $this->hasCommentsTable() && $this->workTaskService->canComment($model),
        ];

        if (Yii::$app->request->isAjax) {
            return $this->renderPartial('_view_content', $payload);
        }

        return $this->redirect(['index', 'task' => (int) $id]);
    }

    public function actionCreate()
    {
        $this->workTaskService->assertSupportStaff();

        if (!Yii::$app->request->isPost) {
            return $this->redirect(['index', 'create' => 1]);
        }

        $isAjax = Yii::$app->request->isAjax;
        $model = new WorkTask();

        if (!$model->load(Yii::$app->request->post())) {
            if ($isAjax) {
                Yii::$app->response->format = Response::FORMAT_JSON;

                return ['success' => false, 'message' => 'Некорректные данные формы.'];
            }

            return $this->redirect(['index', 'create' => 1]);
        }

        if (trim((string) $model->title) === '' || trim((string) $model->description) === '') {
            if ($isAjax) {
                Yii::$app->response->format = Response::FORMAT_JSON;

                return ['success' => false, 'message' => 'Укажите название и описание задачи.'];
            }
            Yii::$app->session->setFlash('error', 'Укажите название и описание задачи.');

            return $this->redirect(['index', 'create' => 1]);
        }

        $model->uploadFiles = UploadedFile::getInstances($model, 'uploadFiles');
        if (!$model->validate(['uploadFiles'])) {
            $uploadErrors = $model->getFirstErrors();
            $message = $uploadErrors ? implode(' ', $uploadErrors) : 'Некорректные вложения.';
            if ($isAjax) {
                Yii::$app->response->format = Response::FORMAT_JSON;

                return ['success' => false, 'message' => $message, 'errors' => $model->errors];
            }
            Yii::$app->session->setFlash('error', $message);

            return $this->redirect(['index', 'create' => 1]);
        }

        try {
            $executorId = $model->executor_id ? (int) $model->executor_id : null;
            $created = $this->workTaskService->createManual(
                (string) $model->title,
                (string) $model->description,
                $executorId !== null ? [$executorId] : [],
                null
            );
            if (!empty($model->uploadFiles)) {
                $created->uploadFiles = $model->uploadFiles;
                $created->persistUploadFiles();
            }
            AuditLog::log('work_task.create', 'work_task', $created->id, 'success');

            $attachmentsCount = count($created->getAllAttachments());
            $successMessage = 'Задача создана.';
            if ($attachmentsCount > 0) {
                $successMessage .= ' Загружено файлов: ' . $attachmentsCount . '.';
            }

            if ($isAjax) {
                Yii::$app->response->format = Response::FORMAT_JSON;

                return [
                    'success' => true,
                    'message' => $successMessage,
                    'task_id' => (int) $created->id,
                    'attachments_count' => $attachmentsCount,
                ];
            }

            Yii::$app->session->setFlash('success', $successMessage);

            return $this->redirect(['index']);
        } catch (\Throwable $e) {
            if ($isAjax) {
                Yii::$app->response->format = Response::FORMAT_JSON;

                return ['success' => false, 'message' => $e->getMessage()];
            }
            Yii::$app->session->setFlash('error', $e->getMessage());

            return $this->redirect(['index', 'create' => 1]);
        }
    }

    public function actionDelete($id)
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $model = $this->findModel((int) $id);

        if (!$this->workTaskService->canAccess($model)) {
            throw new ForbiddenHttpException('Нет доступа к задаче.');
        }

        try {
            $taskId = (int) $model->id;
            $this->workTaskService->delete($model);
            AuditLog::log('work_task.delete', 'work_task', $taskId, 'success');

            return [
                'success' => true,
                'message' => 'Задача удалена.',
                'task_id' => $taskId,
            ];
        } catch (\Throwable $e) {
            return ['success' => false, 'message' => $e->getMessage()];
        }
    }

    public function actionAssign($id)
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $model = $this->findModel((int) $id);

        try {
            $executorIds = $this->normalizeExecutorIdsFromPost();
            $this->workTaskService->assignExecutors($model, $executorIds);
            AuditLog::log('work_task.assign', 'work_task', $model->id, 'success');

            return $this->buildTaskStateResponse($model, 'Исполнители обновлены.');
        } catch (\Throwable $e) {
            return ['success' => false, 'message' => $e->getMessage()];
        }
    }

    public function actionAddExecutor($id)
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $model = $this->findModel((int) $id);

        try {
            $executorId = (int) Yii::$app->request->post('executor_id', 0);
            $this->workTaskService->addExecutor($model, $executorId);
            AuditLog::log('work_task.add_executor', 'work_task', $model->id, 'success', ['executor_id' => $executorId]);

            return $this->buildTaskStateResponse($model, 'Исполнитель добавлен.');
        } catch (\Throwable $e) {
            return ['success' => false, 'message' => $e->getMessage()];
        }
    }

    public function actionRemoveExecutor($id, $userId)
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $model = $this->findModel((int) $id);

        try {
            $this->workTaskService->removeExecutor($model, (int) $userId);
            AuditLog::log('work_task.remove_executor', 'work_task', $model->id, 'success', ['executor_id' => (int) $userId]);

            return $this->buildTaskStateResponse($model, 'Исполнитель снят.');
        } catch (\Throwable $e) {
            return ['success' => false, 'message' => $e->getMessage()];
        }
    }

    public function actionAddComment($id)
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $model = $this->findModel((int) $id);

        if (!$this->workTaskService->canAccess($model)) {
            throw new ForbiddenHttpException('Нет доступа к задаче.');
        }

        if (!$this->hasCommentsTable()) {
            return [
                'success' => false,
                'message' => 'Таблица комментариев не создана. Выполните миграцию: php yii migrate',
            ];
        }

        try {
            $body = trim((string) Yii::$app->request->post('body', ''));
            $comment = $this->workTaskService->addComment($model, $body);
            AuditLog::log('work_task.comment', 'work_task', $model->id, 'success', ['comment_id' => $comment->id]);

            return [
                'success' => true,
                'message' => 'Комментарий добавлен.',
                'comment_id' => (int) $comment->id,
            ];
        } catch (\Throwable $e) {
            return ['success' => false, 'message' => $e->getMessage()];
        }
    }

    /**
     * Массовое подтверждение выполнения задач в статусе «Выполнена» (руководитель).
     */
    public function actionBulkConfirm()
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        if (!$this->isManager()) {
            throw new ForbiddenHttpException('Массовое подтверждение доступно только руководителю.');
        }

        try {
            $searchModel = new WorkTaskSearch();
            $params = Yii::$app->request->post();
            $result = $this->workTaskService->confirmAllPendingReview($searchModel, $params);

            $confirmed = (int) $result['confirmed'];
            $failed = (int) $result['failed'];

            if ($confirmed > 0) {
                AuditLog::log('work_task.bulk_confirm', 'work_task', null, 'success', [
                    'confirmed' => $confirmed,
                    'failed' => $failed,
                ]);
            }

            if ($confirmed === 0 && $failed === 0) {
                return [
                    'success' => true,
                    'confirmed' => 0,
                    'failed' => 0,
                    'message' => 'Нет задач в статусе «Выполнена» для подтверждения.',
                ];
            }

            $message = 'Подтверждено задач: ' . $confirmed . '.';
            if ($failed > 0) {
                $message .= ' Не удалось: ' . $failed . '.';
            }

            return [
                'success' => $failed === 0,
                'confirmed' => $confirmed,
                'failed' => $failed,
                'errors' => $result['errors'],
                'message' => $message,
            ];
        } catch (\Throwable $e) {
            return [
                'success' => false,
                'message' => $e->getMessage(),
            ];
        }
    }

    public function actionTransition($id)
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $model = $this->findModel((int) $id);

        try {
            $code = (string) Yii::$app->request->post('status_code', '');
            $comment = trim((string) Yii::$app->request->post('comment', ''));
            $this->workTaskService->transition($model, $code, $comment !== '' ? $comment : null);
            $model = WorkTask::find()
                ->where(['id' => $model->id])
                ->with(['status'])
                ->one();
            AuditLog::log('work_task.transition', 'work_task', $model->id, 'success', ['status_code' => $code]);

            $message = 'Статус обновлён.';
            if ($code === DicWorkTaskStatus::CODE_IN_PROGRESS) {
                $message = 'Задача взята в работу.';
            }

            return $this->buildTaskStateResponse($model, $message);
        } catch (\Throwable $e) {
            return ['success' => false, 'message' => $e->getMessage()];
        }
    }

    protected function findModel(int $id): WorkTask
    {
        $model = WorkTask::find()
            ->where(['id' => $id, 'is_deleted' => false])
            ->with(['status', 'executor', 'executors', 'creator', 'requestTask.requester'])
            ->one();
        if ($model === null) {
            throw new NotFoundHttpException('Задача не найдена.');
        }

        return $model;
    }

    /**
     * @return int[]
     */
    private function normalizeExecutorIdsFromPost(): array
    {
        $raw = Yii::$app->request->post('executor_ids');
        if (is_array($raw)) {
            return (new WorkTaskService())->normalizeExecutorIds($raw);
        }

        $legacy = Yii::$app->request->post('executor_id');
        if ($legacy === '' || $legacy === null) {
            return [];
        }

        return [(int) $legacy];
    }

    private function buildTaskStateResponse(WorkTask $model, string $message): array
    {
        $model = WorkTask::find()
            ->where(['id' => $model->id])
            ->with(['status', 'executor', 'executors'])
            ->one();

        $user = Yii::$app->user->identity;
        $allowed = $user ? $this->workTaskService->getAllowedTransitions($model, $user) : [];
        $executorNames = $model->getExecutorNames();
        $executorName = $model->getExecutorName();

        return array_merge([
            'success' => true,
            'message' => $message,
            'status_code' => $model->getStatusCode(),
            'status_name' => $model->status ? $model->status->getDisplayName() : '',
            'allowed_transitions' => $allowed,
            'executor_names' => $executorNames,
            'executor_name' => $executorName !== '—' ? $executorName : null,
        ], WorkTaskService::boardTimeMeta($model));
    }

    private function isManager(): bool
    {
        $user = Yii::$app->user->identity;

        return $user && $user->isAdministrator();
    }

    private function canCreateWorkTask(): bool
    {
        $user = Yii::$app->user->identity;

        return $user && $user->isSupportStaff();
    }

    private function hasCommentsTable(): bool
    {
        static $exists = null;
        if ($exists === null) {
            $exists = Yii::$app->db->getTableSchema('work_task_comments', true) !== null;
        }

        return $exists;
    }

    /**
     * @return WorkTaskComment[]
     */
    private function loadTaskComments(int $workTaskId): array
    {
        if (!$this->hasCommentsTable()) {
            return [];
        }

        return WorkTaskComment::find()
            ->where(['work_task_id' => $workTaskId])
            ->with('author')
            ->orderBy(['created_at' => SORT_ASC, 'id' => SORT_ASC])
            ->all();
    }

}
