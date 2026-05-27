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
                    'transition' => ['POST'],
                    'add-comment' => ['POST'],
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

        return $this->render('index', [
            'searchModel' => $searchModel,
            'board' => $board,
            'timelineSteps' => DicWorkTaskStatus::getTimelineSteps(),
            'allowedByTask' => $allowedByTask,
            'isManager' => $isManager,
            'executors' => WorkTaskService::getExecutorList(),
            'createModel' => $isManager ? new WorkTask() : null,
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
        $this->workTaskService->assertManager();

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
                $executorId,
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
            $executorId = Yii::$app->request->post('executor_id');
            $executorId = $executorId !== '' && $executorId !== null ? (int) $executorId : null;
            $this->workTaskService->assignExecutor($model, $executorId);
            $model = WorkTask::find()
                ->where(['id' => $model->id])
                ->with(['status', 'executor'])
                ->one();
            AuditLog::log('work_task.assign', 'work_task', $model->id, 'success');

            $user = Yii::$app->user->identity;
            $allowed = $user ? $this->workTaskService->getAllowedTransitions($model, $user) : [];

            return array_merge([
                'success' => true,
                'message' => 'Исполнитель обновлён.',
                'status_code' => $model->getStatusCode(),
                'status_name' => $model->status ? $model->status->getDisplayName() : '',
                'allowed_transitions' => $allowed,
                'executor_name' => $model->executor ? $model->executor->full_name : null,
            ], WorkTaskService::boardTimeMeta($model));
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

            $user = Yii::$app->user->identity;
            $allowed = $user ? $this->workTaskService->getAllowedTransitions($model, $user) : [];

            return array_merge([
                'success' => true,
                'message' => 'Статус обновлён.',
                'status_code' => $model->getStatusCode() ?: $code,
                'status_name' => $model->status ? $model->status->getDisplayName() : '',
                'allowed_transitions' => $allowed,
                'redirect' => \yii\helpers\Url::to(['view', 'id' => $model->id]),
            ], WorkTaskService::boardTimeMeta($model));
        } catch (\Throwable $e) {
            return ['success' => false, 'message' => $e->getMessage()];
        }
    }

    protected function findModel(int $id): WorkTask
    {
        $model = WorkTask::find()
            ->where(['id' => $id, 'is_deleted' => false])
            ->with(['status', 'executor', 'creator', 'requestTask.requester'])
            ->one();
        if ($model === null) {
            throw new NotFoundHttpException('Задача не найдена.');
        }

        return $model;
    }

    private function isManager(): bool
    {
        $user = Yii::$app->user->identity;

        return $user && $user->isAdministrator();
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
