<?php

namespace app\controllers;

use Yii;
use app\models\entities\Tasks;
use app\models\entities\Users;
use app\models\entities\Equipment;
use app\models\search\TasksSearch;
use app\models\dictionaries\DicTaskStatus;
use app\models\entities\DeskAttachments;
use app\models\entities\TaskAttachments;
use app\models\entities\TaskHistory;
use app\components\AuditLog;
use yii\web\Controller;
use yii\web\NotFoundHttpException;
use yii\filters\VerbFilter;
use yii\web\UploadedFile;
use yii\web\Response;
use yii\helpers\Json;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use PhpOffice\PhpSpreadsheet\Style\Alignment;
use PhpOffice\PhpSpreadsheet\Style\Border;
use PhpOffice\PhpSpreadsheet\Style\Fill;

/**
 * TasksController реализует CRUD операции для модели Tasks.
 */
class TasksController extends Controller
{
    /**
     * Определяет поведения контроллера
     */
    public function behaviors()
    {
        return array_merge(
            parent::behaviors(),
            [
                'verbs' => [
                    'class' => VerbFilter::class,
                    'actions' => [
                        'delete' => ['POST'],
                        'delete-attachment' => ['POST'],
                        'change-status' => ['POST'],
                        'assign-executor' => ['POST'],
                        'update-comment' => ['POST'],
                    ],
                ],
                'access' => [
                    'class' => \yii\filters\AccessControl::class,
                    'rules' => [
                        [
                            'allow' => true,
                            'roles' => ['@'],
                        ],
                    ],
                    
                    
                ],
            ]
        );
    }

    /**
     * Отображает список заявок (AG Grid).
     *
     * @return string
     */
    public function actionIndex()
    {
        return $this->render('index');
    }

    /**
     * Отображает одну заявку.
     * @param int $id
     * @return string
     * @throws NotFoundHttpException если модель не найдена
     */
    public function actionView($id)
    {
        $model = $this->findModel($id);
        if (!$this->canUserAccessTask($model)) {
            throw new \yii\web\ForbiddenHttpException('Нет доступа к этой заявке.');
        }
        return $this->render('view', [
            'model' => $model,
        ]);
    }

    /**
     * Создает новую заявку.
     * В случае успеха браузер будет перенаправлен на страницу 'index'.
     * @return string|\yii\web\Response
     */
    public function actionCreate()
    {
        $model = new Tasks();

        if ($this->request->isPost) {
            if ($model->load($this->request->post())) {
                // Устанавливаем автора как текущего пользователя
                $model->requester_id = Yii::$app->user->id;
                if (empty($model->status_id)) {
                    $model->status_id = DicTaskStatus::getDefaultStatusId();
                }
                
                // Загружаем файлы
                Yii::info('=== КОНТРОЛЛЕР actionCreate ===', 'tasks');
                Yii::info('$_FILES: ' . json_encode($_FILES), 'tasks');
                
                $model->uploadFiles = UploadedFile::getInstances($model, 'uploadFiles');
                
                Yii::info('UploadedFile::getInstances вернул: ' . (is_array($model->uploadFiles) ? count($model->uploadFiles) : 'не массив') . ' файлов', 'tasks');
                if (is_array($model->uploadFiles)) {
                    foreach ($model->uploadFiles as $i => $file) {
                        Yii::info("  Файл #{$i}: {$file->name}", 'tasks');
                    }
                }
                
                if ($model->save()) {
                    $model->uploadFiles();
                    AuditLog::log('task.create', 'task', $model->id, 'success');
                    Yii::$app->session->setFlash('success', 'Заявка успешно создана.');
                    
                    /** Если это AJAX запрос, устанавливаем заголовок перенаправления */
                    if ($this->request->isAjax) {
                        $this->response->headers->set('X-Redirect-Url', \yii\helpers\Url::to(['index']));
                        return $this->redirect(['index']);
                    }
                    
                    return $this->redirect(['index']);
                }
            }
        } else {
            $model->loadDefaultValues();
        }

        return $this->render('create', [
            'model' => $model,
            'equipmentList' => $this->getEquipmentList(),
        ]);
    }

    private function getEquipmentList(): array
    {
        $rows = Equipment::find()
            ->where(['is_archived' => false])
            ->orderBy(['inventory_number' => SORT_ASC])
            ->all();
        $list = [];
        foreach ($rows as $e) {
            $list[$e->id] = $e->inventory_number . ' — ' . ($e->name ?: 'Без названия');
        }
        return $list;
    }

    /**
     * Создает новую заявку через AJAX в модальном окне
     * Обрабатывает как GET запросы (отображение формы), так и POST запросы (сохранение данных)
     * 
     * @return string|array Возвращает HTML формы для GET запроса или JSON ответ для POST
     */
    public function actionCreateModal()
    {
        $model = new Tasks();

        /** Если это POST запрос (отправка формы) */
        if ($this->request->isPost) {
            /** Логирование для отладки загрузки файлов */
            Yii::info('=== КОНТРОЛЛЕР actionCreateModal (POST) ===', 'tasks');
            Yii::info('$_FILES RAW: ' . json_encode($_FILES), 'tasks');
            Yii::info('$_POST RAW: ' . json_encode($_POST), 'tasks');
            
            if ($model->load($this->request->post())) {
                $model->requester_id = Yii::$app->user->id;
                if (empty($model->status_id)) {
                    $model->status_id = DicTaskStatus::getDefaultStatusId();
                }
                
                /** Загружаем файлы из запроса */
                $model->uploadFiles = UploadedFile::getInstances($model, 'uploadFiles');
                
                /** Логируем информацию о файлах для отладки */
                Yii::info('POST данные: ' . json_encode($this->request->post()), 'tasks');
                Yii::info('Загружено файлов: ' . (is_array($model->uploadFiles) ? count($model->uploadFiles) : 0), 'tasks');
                if (is_array($model->uploadFiles)) {
                    foreach ($model->uploadFiles as $i => $file) {
                        Yii::info("Файл #{$i}: {$file->name} ({$file->size} bytes)", 'tasks');
                    }
                }
                
                if ($model->save()) {
                    /** Загружаем файлы после сохранения задачи */
                    $uploadResult = $model->uploadFiles();
                    Yii::info("Результат загрузки файлов: " . ($uploadResult ? 'успешно' : 'ошибка'), 'tasks');
                    
                    /** Возвращаем JSON ответ об успехе */
                    Yii::$app->response->format = \yii\web\Response::FORMAT_JSON;
                    return [
                        'success' => true,
                        'message' => 'Заявка успешно создана!' . 
                            (is_array($model->uploadFiles) && count($model->uploadFiles) > 0 ? 
                            ' Загружено файлов: ' . count($model->uploadFiles) : ''),
                        'task_id' => $model->id,
                        'attachments_count' => count($model->getAttachmentsArray())
                    ];
                } else {
                    /** Возвращаем ошибки валидации в JSON формате */
                    Yii::error('Ошибки валидации модели: ' . json_encode($model->errors), 'tasks');
                    Yii::$app->response->format = \yii\web\Response::FORMAT_JSON;
                    return [
                        'success' => false,
                        'errors' => $model->errors,
                        'message' => 'Ошибка при создании заявки'
                    ];
                }
            } else {
                Yii::error('Не удалось загрузить данные в модель', 'tasks');
            }
        } else {
            /** Если это GET запрос - загружаем значения по умолчанию */
            $model->loadDefaultValues();
        }

        return $this->renderAjax('_form', [
            'model' => $model,
            'equipmentList' => $this->getEquipmentList(),
        ]);
    }

    /**
     * Обновляет существующую заявку.
     * В случае успеха браузер будет перенаправлен на страницу 'view'.
     * @param int $id
     * @return string|\yii\web\Response
     * @throws NotFoundHttpException если модель не найдена
     */
    public function actionUpdate($id)
    {
        $model = $this->findModel($id);
        if (!$this->canUserAccessTask($model)) {
            throw new \yii\web\ForbiddenHttpException('Нет доступа к этой заявке.');
        }
        if ($this->request->isPost && $model->load($this->request->post())) {
            $model->uploadFiles = UploadedFile::getInstances($model, 'uploadFiles');
            if ($model->save()) {
                $model->uploadFiles();
                AuditLog::log('task.update', 'task', $model->id, 'success');
                Yii::$app->session->setFlash('success', 'Заявка успешно обновлена.');
                return $this->redirect(['view', 'id' => $model->id]);
            }
        }

        return $this->render('update', [
            'model' => $model,
            'equipmentList' => $this->getEquipmentList(),
        ]);
    }

    /**
     * Удаляет существующую заявку.
     * В случае успеха браузер будет перенаправлен на страницу 'index'.
     * @param int $id
     * @return \yii\web\Response
     * @throws NotFoundHttpException если модель не найдена
     */
    public function actionDelete($id)
    {
        $model = $this->findModel($id);
        if (!Yii::$app->user->identity || !Yii::$app->user->identity->isAdministrator()) {
            throw new \yii\web\ForbiddenHttpException('Удаление заявки разрешено только администратору.');
        }
        $taskId = $model->id;
        $attachments = $model->getAllAttachments();
        foreach ($attachments as $attachment) {
            $attachment->delete();
        }
        $model->delete();
        AuditLog::log('task.delete', 'task', $taskId, 'success');
        Yii::$app->session->setFlash('success', 'Заявка успешно удалена.');
        return $this->redirect(['index']);
    }

    /**
     * Удаление вложения из задачи
     * Удаляет файл из файловой системы и запись из базы данных
     * 
     * @param int $taskId ID задачи
     * @param int $attachmentId ID вложения
     * @return \yii\web\Response
     */
    public function actionDeleteAttachment($taskId, $attachmentId)
    {
        $model = $this->findModel($taskId);
        if (!$this->canUserAccessTask($model)) {
            throw new \yii\web\ForbiddenHttpException('Нет доступа к этой заявке.');
        }
        $attachment = DeskAttachments::findOne($attachmentId);
        if ($attachment) {
            $model->removeAttachment($attachmentId);
            $model->save(false);
            $attachment->delete();
            AuditLog::log('attachment.delete', 'attachment', $attachmentId, 'success', ['task_id' => $model->id]);
            Yii::$app->session->setFlash('success', 'Вложение успешно удалено.');
        } else {
            Yii::$app->session->setFlash('error', 'Вложение не найдено.');
        }
        
        return $this->redirect(['view', 'id' => $taskId]);
    }

    /**
     * Проверка доступа к заявке: автор, исполнитель или администратор.
     * @param Tasks $task
     * @return bool
     */
    private function canUserAccessTask($task)
    {
        if (Yii::$app->user->isGuest) {
            return false;
        }
        $userId = (int) Yii::$app->user->id;
        if ($task->requester_id == $userId || $task->executor_id == $userId) {
            return true;
        }
        $identity = Yii::$app->user->identity;
        return $identity && ($identity->isAdministrator() || $identity->isOperator());
    }

    /**
     * Возвращает заявку, к которой привязано вложение, или null.
     * @param int $attachmentId
     * @return Tasks|null
     */
    private function getTaskByAttachmentId($attachmentId)
    {
        $link = TaskAttachments::find()
            ->where(['attachment_id' => (int) $attachmentId])
            ->with('task')
            ->one();
        return $link ? $link->task : null;
    }

    /**
     * Скачивание вложения. Доступ только при наличии прав на заявку.
     * @param int $attachmentId ID вложения
     * @return \yii\web\Response
     */
    public function actionDownloadAttachment($attachmentId)
    {
        $attachment = DeskAttachments::findOne($attachmentId);
        if (!$attachment || !$attachment->fileExists()) {
            throw new NotFoundHttpException('Файл не найден.');
        }
        $task = $this->getTaskByAttachmentId($attachmentId);
        if (!$task || !$this->canUserAccessTask($task)) {
            throw new \yii\web\ForbiddenHttpException('Нет доступа к этому вложению.');
        }
        $response = Yii::$app->response;
        $response->headers->set('X-Content-Type-Options', 'nosniff');
        return $response->sendFile($attachment->getFullPath(), $attachment->original_name);
    }

    /**
     * Предпросмотр файла в браузере. SVG и опасные типы — только скачивание.
     * Доступ только при наличии прав на заявку.
     * @param int $id ID вложения
     * @return \yii\web\Response
     */
    public function actionPreview($id)
    {
        $attachment = DeskAttachments::findOne($id);
        if (!$attachment || !$attachment->fileExists()) {
            throw new NotFoundHttpException('Файл не найден.');
        }
        $task = $this->getTaskByAttachmentId($id);
        if (!$task || !$this->canUserAccessTask($task)) {
            throw new \yii\web\ForbiddenHttpException('Нет доступа к этому вложению.');
        }
        $extension = strtolower((string) $attachment->file_extension);
        $dangerousInline = ['svg'];
        $forceDownload = in_array($extension, $dangerousInline, true);
        $mimeTypes = [
            'pdf' => 'application/pdf',
            'png' => 'image/png',
            'jpg' => 'image/jpeg',
            'jpeg' => 'image/jpeg',
            'gif' => 'image/gif',
            'bmp' => 'image/bmp',
            'svg' => 'image/svg+xml',
        ];
        $mimeType = $mimeTypes[$extension] ?? 'application/octet-stream';
        $response = Yii::$app->response;
        $response->headers->set('Content-Type', $mimeType);
        $response->headers->set('X-Content-Type-Options', 'nosniff');
        if ($forceDownload) {
            $response->headers->set('Content-Disposition', 'attachment; filename="' . $attachment->original_name . '"');
            return $response->sendFile($attachment->getFullPath(), $attachment->original_name);
        }
        $response->headers->set('Content-Disposition', 'inline; filename="' . $attachment->original_name . '"');
        $response->headers->set('Cache-Control', 'public, max-age=3600');
        return $response->sendFile($attachment->getFullPath(), $attachment->original_name, ['inline' => true]);
    }

    /**
     * Скачивание файла вложения. Доступ только при наличии прав на заявку.
     * @param int $id ID вложения
     * @return \yii\web\Response
     */
    public function actionDownload($id)
    {
        $attachment = DeskAttachments::findOne($id);
        if (!$attachment || !$attachment->fileExists()) {
            throw new NotFoundHttpException('Файл не найден.');
        }
        $task = $this->getTaskByAttachmentId($id);
        if (!$task || !$this->canUserAccessTask($task)) {
            throw new \yii\web\ForbiddenHttpException('Нет доступа к этому вложению.');
        }
        $response = Yii::$app->response;
        $response->headers->set('X-Content-Type-Options', 'nosniff');
        return $response->sendFile($attachment->getFullPath(), $attachment->original_name);
    }

    /**
     * Изменение статуса задачи через AJAX
     * Обновляет статус задачи и возвращает результат в формате JSON
     * 
     * @param int $id ID задачи
     * @return array JSON ответ с результатом операции
     */
    public function actionChangeStatus($id)
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        try {
            $model = $this->findModel($id);
            if (!$this->canUserAccessTask($model)) {
                return ['success' => false, 'message' => 'Нет доступа к этой заявке.'];
            }
            if ($this->request->isPost) {
            $statusId = $this->request->post('status_id');
            $status = DicTaskStatus::findOne($statusId);
            
            if ($status) {
                $oldStatus = $model->status_id;
                $model->status_id = $statusId;
                $model->updated_at = date('Y-m-d H:i:s');
                if ($model->save(false)) {
                    TaskHistory::log($model->id, 'status_id', (string) $oldStatus, (string) $statusId);
                    AuditLog::log('task.change_status', 'task', $model->id, 'success', ['status_id' => $statusId]);
                    return [
                        'success' => true,
                        'message' => 'Статус успешно изменен.',
                        'status_name' => $status->status_name
                    ];
                }
            }
            }
            
            return [
                'success' => false,
                'message' => 'Ошибка при изменении статуса.'
            ];
        } catch (\Exception $e) {
            return [
                'success' => false,
                'message' => 'Ошибка сервера: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Назначение исполнителя задаче через AJAX
     * Обновляет исполнителя задачи и возвращает результат в формате JSON
     * 
     * @param int $id ID задачи
     * @return array JSON ответ с результатом операции
     */
    public function actionAssignExecutor($id)
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        try {
            $model = $this->findModel($id);
            if (!$this->canUserAccessTask($model)) {
                return ['success' => false, 'message' => 'Нет доступа к этой заявке.'];
            }
            if ($this->request->isPost) {
            $executorId = $this->request->post('executor_id');
            
            // Проверяем, что исполнитель существует (если указан)
            if ($executorId) {
                $executor = Users::findOne($executorId);
                if (!$executor) {
                    return [
                        'success' => false,
                        'message' => 'Исполнитель не найден.'
                    ];
                }
            }
            
            $oldExecutor = $model->executor_id;
            $model->executor_id = $executorId ?: null;
            $model->updated_at = date('Y-m-d H:i:s');
            if ($model->save(false)) {
                TaskHistory::log($model->id, 'executor_id', (string) $oldExecutor, (string) $model->executor_id);
                AuditLog::log('task.assign_executor', 'task', $model->id, 'success', ['executor_id' => $model->executor_id]);
                $executorName = $executorId ? Users::findOne($executorId)->full_name : 'Не назначен';
                return [
                    'success' => true,
                    'message' => 'Исполнитель успешно назначен.',
                    'executor_name' => $executorName
                ];
            }
            }
            
            return [
                'success' => false,
                'message' => 'Ошибка при назначении исполнителя.'
            ];
        } catch (\Exception $e) {
            return [
                'success' => false,
                'message' => 'Ошибка сервера: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Обновление комментария задачи через AJAX
     * Сохраняет новый комментарий и возвращает результат в формате JSON
     * 
     * @param int $id ID задачи
     * @return array JSON ответ с результатом операции
     */
    public function actionUpdateComment($id)
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        try {
            $model = $this->findModel($id);
            if (!$this->canUserAccessTask($model)) {
                return ['success' => false, 'message' => 'Нет доступа к этой заявке.'];
            }
            if ($this->request->isPost) {
            $comment = $this->request->post('comment');
            $oldComment = $model->comment;
            $model->comment = $comment;
            $model->updated_at = date('Y-m-d H:i:s');
            if ($model->save(false)) {
                TaskHistory::log($model->id, 'comment', $oldComment, $comment);
                AuditLog::log('task.update_comment', 'task', $model->id, 'success');
                return [
                    'success' => true,
                    'message' => 'Комментарий успешно обновлен.'
                ];
            }
            }
            
            return [
                'success' => false,
                'message' => 'Ошибка при обновлении комментария.'
            ];
        } catch (\Exception $e) {
            return [
                'success' => false,
                'message' => 'Ошибка сервера: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Находит модель Tasks по значению первичного ключа.
     * Если модель не найдена, будет выброшено исключение 404 HTTP.
     * @param int $id
     * @return Tasks загруженная модель
     * @throws NotFoundHttpException если модель не найдена
     */
    protected function findModel($id)
    {
        if (($model = Tasks::findOne($id)) !== null) {
            return $model;
        }

        throw new NotFoundHttpException('Запрашиваемая страница не найдена.');
    }

    /**
     * Получить список пользователей для выпадающего списка
     * Возвращает массив с ID пользователей в качестве ключей и ФИО в качестве значений
     * 
     * @return array Массив пользователей [id => full_name]
     */
    public function getUsersList()
    {
        return Users::find()
            ->select(['full_name', 'id'])
            ->indexBy('id')
            ->column();
    }

    /**
     * Получить список статусов для выпадающего списка
     * Возвращает массив всех возможных статусов задач
     * 
     * @return array Массив статусов [id => название]
     */
    public function getStatusList()
    {
        return DicTaskStatus::getStatusList();
    }

    /**
     * Отображает страницу статистики заявок
     * Показывает диаграммы количества заявок по пользователям и завершенных заявок по исполнителям
     * 
     * @return string HTML страницы статистики
     */
    public function actionStatistics()
    {
        /** Получаем данные для диаграммы количества заявок по пользователям */
        $userStats = Tasks::find()
            ->select(['requester_id', 'COUNT(*) as count'])
            ->groupBy('requester_id')
            ->with('requester')
            ->asArray()
            ->all();

        $userChartData = [];
        foreach ($userStats as $stat) {
            $user = Users::findOne($stat['requester_id']);
            $userChartData[] = [
                'name' => $user ? $user->full_name : 'Неизвестный пользователь',
                'y' => (int)$stat['count']
            ];
        }

        $resolvedStatusId = (int) (DicTaskStatus::find()->where(['status_code' => 'resolved'])->select('id')->scalar() ?: DicTaskStatus::find()->where(['status_code' => 'closed'])->select('id')->scalar());
        $executorStats = Tasks::find()
            ->select(['executor_id', 'COUNT(*) as count'])
            ->where(['status_id' => $resolvedStatusId])
            ->andWhere(['not', ['executor_id' => null]])
            ->groupBy('executor_id')
            ->with('executor')
            ->asArray()
            ->all();

        $executorChartData = [];
        foreach ($executorStats as $stat) {
            $executor = Users::findOne($stat['executor_id']);
            $executorChartData[] = [
                'name' => $executor ? $executor->full_name : 'Неизвестный исполнитель',
                'y' => (int)$stat['count']
            ];
        }

        return $this->render('statistics', [
            'userChartData' => $userChartData,
            'executorChartData' => $executorChartData,
        ]);
    }

    /**
     * API endpoint для получения данных заявок в формате JSON для AG Grid
     * Возвращает все заявки с полной информацией для отображения в таблице AG Grid
     * 
     * @return array JSON массив с данными заявок
     */
    public function actionGetGridData()
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        
        try {
            $searchModel = new TasksSearch();
            $dataProvider = $searchModel->search($this->request->queryParams);
            
            /** Отключаем пагинацию для получения всех данных */
            $dataProvider->pagination = false;
            
            $models = $dataProvider->models;
            $data = [];
            
            foreach ($models as $model) {
                $data[] = [
                    'id' => $model->id,
                    'description' => $model->description,
                    'status_id' => $model->status_id,
                    'status_name' => $model->status ? $model->status->status_name : '',
                    'user_id' => $model->requester_id,
                    'user_name' => $model->requester ? $model->requester->full_name : '',
                    'executor_id' => $model->executor_id,
                    'executor_name' => $model->executor ? $model->executor->full_name : '',
                    'date' => $model->created_at ? Yii::$app->formatter->asDatetime($model->created_at, 'php:d.m.Y H:i') : '',
                    'last_time_update' => $model->updated_at ? Yii::$app->formatter->asDatetime($model->updated_at, 'php:d.m.Y H:i') : '',
                    'comment' => $model->comment,
                    'attachments' => array_map(function($attachment) {
                        return [
                            'id' => $attachment->id,
                            'name' => $attachment->original_name,
                            'icon' => $attachment->getFileIcon(),
                            'is_previewable' => $attachment->isImageOrScan(),
                            'preview_url' => $attachment->getPreviewUrl(),
                            'download_url' => $attachment->getDownloadUrl(),
                        ];
                    }, $model->getAllAttachments()),
                ];
            }
            
            return [
                'success' => true,
                'data' => $data,
                'total' => count($data),
            ];
            
        } catch (\Exception $e) {
            return [
                'success' => false,
                'message' => 'Ошибка при загрузке данных: ' . $e->getMessage(),
                'data' => [],
                'total' => 0,
            ];
        }
    }

    /**
     * Экспорт статистики по пользователям в Excel
     * Создает Excel файл с таблицей количества заявок по каждому пользователю
     * 
     * @return void Отправляет файл на скачивание
     */
    public function actionExportUserStats()
    {
        $userStats = Tasks::find()
            ->select(['requester_id', 'COUNT(*) as count'])
            ->groupBy('requester_id')
            ->with('requester')
            ->asArray()
            ->all();

        $spreadsheet = new Spreadsheet();
        $sheet = $spreadsheet->getActiveSheet();
        $sheet->setTitle('Статистика по пользователям');

        /** Устанавливаем заголовки таблицы */
        $sheet->setCellValue('A1', 'Пользователь');
        $sheet->setCellValue('B1', 'Количество заявок');
        $sheet->setCellValue('C1', 'Процент от общего количества');

        /** Применяем стили к заголовкам */
        $headerStyle = [
            'font' => ['bold' => true],
            'fill' => [
                'fillType' => Fill::FILL_SOLID,
                'startColor' => ['rgb' => 'E3F2FD']
            ],
            'borders' => [
                'allBorders' => [
                    'borderStyle' => Border::BORDER_THIN,
                    'color' => ['rgb' => '000000']
                ]
            ],
            'alignment' => [
                'horizontal' => Alignment::HORIZONTAL_CENTER,
                'vertical' => Alignment::VERTICAL_CENTER
            ]
        ];
        $sheet->getStyle('A1:C1')->applyFromArray($headerStyle);

        /** Подсчитываем общее количество заявок для расчета процентов */
        $totalTasks = array_sum(array_column($userStats, 'count'));

        $row = 2;
        foreach ($userStats as $stat) {
            $user = Users::findOne($stat['requester_id']);
            $percentage = $totalTasks > 0 ? round(($stat['count'] / $totalTasks) * 100, 2) : 0;
            
            $sheet->setCellValue('A' . $row, $user ? $user->full_name : 'Неизвестный пользователь');
            $sheet->setCellValue('B' . $row, $stat['count']);
            $sheet->setCellValue('C' . $row, $percentage . '%');
            $row++;
        }

        // Автоширина колонок
        foreach (range('A', 'C') as $col) {
            $sheet->getColumnDimension($col)->setAutoSize(true);
        }

        // Стили для данных
        $dataStyle = [
            'borders' => [
                'allBorders' => [
                    'borderStyle' => Border::BORDER_THIN,
                    'color' => ['rgb' => '000000']
                ]
            ],
            'alignment' => [
                'horizontal' => Alignment::HORIZONTAL_CENTER,
                'vertical' => Alignment::VERTICAL_CENTER
            ]
        ];
        $sheet->getStyle('A2:C' . ($row - 1))->applyFromArray($dataStyle);

        $filename = 'Статистика_по_пользователям_' . date('Y-m-d_H-i-s') . '.xlsx';
        
        $writer = new Xlsx($spreadsheet);
        
        header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        header('Content-Disposition: attachment; filename="' . $filename . '"');
        header('Cache-Control: max-age=0');
        
        $writer->save('php://output');
        exit;
    }

    /**
     * Экспорт статистики по исполнителям в Excel
     * Создает Excel файл с таблицей завершенных заявок по каждому исполнителю
     * 
     * @return void Отправляет файл на скачивание
     */
    public function actionExportExecutorStats()
    {
        $resolvedId = (int) (DicTaskStatus::find()->where(['status_code' => 'resolved'])->select('id')->scalar() ?: DicTaskStatus::find()->where(['status_code' => 'closed'])->select('id')->scalar());
        $executorStats = Tasks::find()
            ->select(['executor_id', 'COUNT(*) as count'])
            ->where(['status_id' => $resolvedId])
            ->andWhere(['not', ['executor_id' => null]])
            ->groupBy('executor_id')
            ->with('executor')
            ->asArray()
            ->all();

        $spreadsheet = new Spreadsheet();
        $sheet = $spreadsheet->getActiveSheet();
        $sheet->setTitle('Статистика по исполнителям');

        // Заголовки
        $sheet->setCellValue('A1', 'Исполнитель');
        $sheet->setCellValue('B1', 'Количество завершенных заявок');
        $sheet->setCellValue('C1', 'Процент от общего количества');

        // Стили для заголовков
        $headerStyle = [
            'font' => ['bold' => true],
            'fill' => [
                'fillType' => Fill::FILL_SOLID,
                'startColor' => ['rgb' => 'E8F5E8']
            ],
            'borders' => [
                'allBorders' => [
                    'borderStyle' => Border::BORDER_THIN,
                    'color' => ['rgb' => '000000']
                ]
            ],
            'alignment' => [
                'horizontal' => Alignment::HORIZONTAL_CENTER,
                'vertical' => Alignment::VERTICAL_CENTER
            ]
        ];
        $sheet->getStyle('A1:C1')->applyFromArray($headerStyle);

        // Подсчитываем общее количество завершенных заявок
        $totalCompletedTasks = array_sum(array_column($executorStats, 'count'));

        // Данные
        $row = 2;
        foreach ($executorStats as $stat) {
            $executor = Users::findOne($stat['executor_id']);
            $percentage = $totalCompletedTasks > 0 ? round(($stat['count'] / $totalCompletedTasks) * 100, 2) : 0;
            
            $sheet->setCellValue('A' . $row, $executor ? $executor->full_name : 'Неизвестный исполнитель');
            $sheet->setCellValue('B' . $row, $stat['count']);
            $sheet->setCellValue('C' . $row, $percentage . '%');
            $row++;
        }

        // Автоширина колонок
        foreach (range('A', 'C') as $col) {
            $sheet->getColumnDimension($col)->setAutoSize(true);
        }

        // Стили для данных
        $dataStyle = [
            'borders' => [
                'allBorders' => [
                    'borderStyle' => Border::BORDER_THIN,
                    'color' => ['rgb' => '000000']
                ]
            ],
            'alignment' => [
                'horizontal' => Alignment::HORIZONTAL_CENTER,
                'vertical' => Alignment::VERTICAL_CENTER
            ]
        ];
        $sheet->getStyle('A2:C' . ($row - 1))->applyFromArray($dataStyle);

        $filename = 'Статистика_по_исполнителям_' . date('Y-m-d_H-i-s') . '.xlsx';
        
        $writer = new Xlsx($spreadsheet);
        
        header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        header('Content-Disposition: attachment; filename="' . $filename . '"');
        header('Cache-Control: max-age=0');
        
        $writer->save('php://output');
        exit;
    }

    /**
     * Получить информацию о технике пользователя (для AG-Grid Detail Panel)
     * Возвращает список всех АРМ (техники), закрепленных за указанным пользователем
     * 
     * @param int $userId ID пользователя
     * @return array JSON ответ с данными о технике
     */
    public function actionGetUserEquipment($userId)
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $userId = (int) $userId;
        $currentId = Yii::$app->user->isGuest ? null : (int) Yii::$app->user->id;
        $identity = Yii::$app->user->identity;
        $canAccessOther = $identity && ($identity->isAdministrator() || $identity->isOperator());
        if ($currentId === null || ($userId !== $currentId && !$canAccessOther)) {
            throw new \yii\web\ForbiddenHttpException('Доступ к технике другого пользователя запрещён.');
        }
        try {
            $equipment = Equipment::find()
                ->where(['responsible_user_id' => $userId])
                ->with(['location'])
                ->all();
            
            $data = [];
            if (empty($equipment)) {
                return [
                    'success' => true,
                    'data' => [],
                    'message' => 'У пользователя нет закрепленной техники'
                ];
            }
            
            foreach ($equipment as $eq) {
                $data[] = [
                    'id' => $eq->id,
                    'name' => $eq->name,
                    'location' => $eq->location ? $eq->location->name : 'Не указано',
                    'description' => $eq->description ?: 'Нет описания',
                    'created_at' => $eq->created_at,
                ];
            }
            
            return [
                'success' => true,
                'data' => $data,
                'total' => count($data),
            ];
            
        } catch (\Exception $e) {
            Yii::error('Ошибка получения техники пользователя: ' . $e->getMessage(), 'equipment');
            return [
                'success' => false,
                'message' => 'Ошибка загрузки данных: ' . $e->getMessage(),
                'data' => [],
            ];
        }
    }
}
