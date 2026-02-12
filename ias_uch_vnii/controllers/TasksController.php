<?php

namespace app\controllers;

use Yii;
use app\models\entities\Tasks;
use app\models\entities\Users;
use app\models\entities\Arm;
use app\models\search\TasksSearch;
use app\models\dictionaries\DicTaskStatus;
use app\models\entities\DeskAttachments;
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
     * Отображает список всех заявок.
     *
     * @return string
     */
    public function actionIndex()
    {
        $searchModel = new TasksSearch();
        $dataProvider = $searchModel->search($this->request->queryParams);

        return $this->render('index', [
            'searchModel' => $searchModel,
            'dataProvider' => $dataProvider,
        ]);
    }

    /**
     * Отображает список заявок с использованием AG Grid
     * Возвращает представление с таблицей AG Grid для более продвинутого управления данными
     *
     * @return string
     */
    public function actionIndexAggrid()
    {
        return $this->render('index-aggrid');
    }

    /**
     * Отображает одну заявку.
     * @param int $id
     * @return string
     * @throws NotFoundHttpException если модель не найдена
     */
    public function actionView($id)
    {
        return $this->render('view', [
            'model' => $this->findModel($id),
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
                $model->id_user = Yii::$app->user->id;
            
                // Устанавливаем статус по умолчанию
                if (empty($model->id_status)) {
                    $model->id_status = DicTaskStatus::getDefaultStatusId();
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
                    /** Загружаем файлы после сохранения задачи */
                    $model->uploadFiles();
                    
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
        ]);
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
                /** Устанавливаем автора как текущего пользователя */
                $model->id_user = Yii::$app->user->id;
            
                /** Устанавливаем статус по умолчанию, если не указан */
                if (empty($model->id_status)) {
                    $model->id_status = DicTaskStatus::getDefaultStatusId();
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

        /** Рендерим только форму без layout для модального окна */
        return $this->renderAjax('_form', [
            'model' => $model,
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

        if ($this->request->isPost && $model->load($this->request->post())) {
            /** Загружаем новые файлы из запроса */
            $model->uploadFiles = UploadedFile::getInstances($model, 'uploadFiles');
            
            if ($model->save()) {
                /** Загружаем файлы после успешного сохранения модели */
                $model->uploadFiles();
                
                Yii::$app->session->setFlash('success', 'Заявка успешно обновлена.');
                return $this->redirect(['view', 'id' => $model->id]);
            }
        }

        return $this->render('update', [
            'model' => $model,
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
        
        /** Удаляем все вложения перед удалением задачи */
        $attachments = $model->getAllAttachments();
        foreach ($attachments as $attachment) {
            $attachment->delete();
        }
        
        $model->delete();
        
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
        $attachment = DeskAttachments::findOne($attachmentId);
        
        if ($attachment) {
            $model->removeAttachment($attachmentId);
            $model->save(false);
            $attachment->delete();
            
            Yii::$app->session->setFlash('success', 'Вложение успешно удалено.');
        } else {
            Yii::$app->session->setFlash('error', 'Вложение не найдено.');
        }
        
        return $this->redirect(['view', 'id' => $taskId]);
    }

    /**
     * Скачивание вложения
     * Отправляет файл пользователю для скачивания
     * 
     * @param int $attachmentId ID вложения
     * @return \yii\web\Response
     */
    public function actionDownloadAttachment($attachmentId)
    {
        $attachment = DeskAttachments::findOne($attachmentId);
        
        if (!$attachment || !$attachment->fileExists()) {
            throw new NotFoundHttpException('Файл не найден.');
        }
        
        return Yii::$app->response->sendFile($attachment->getFullPath(), $attachment->name);
    }

    /**
     * Предпросмотр файла в браузере (изображения и PDF)
     * Отправляет файл с заголовком inline для отображения в браузере
     * 
     * @param int $id ID вложения
     * @return \yii\web\Response
     */
    public function actionPreview($id)
    {
        $attachment = DeskAttachments::findOne($id);
        
        if (!$attachment || !$attachment->fileExists()) {
            throw new NotFoundHttpException('Файл не найден.');
        }
        
        $extension = strtolower($attachment->extension);
        
        /** Определяем MIME-тип файла по расширению */
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
        $response->headers->set('Content-Disposition', 'inline; filename="' . $attachment->name . '"');
        $response->headers->set('Cache-Control', 'public, max-age=3600');
        
        return $response->sendFile($attachment->getFullPath(), $attachment->name, ['inline' => true]);
    }

    /**
     * Скачивание файла вложения
     * Отправляет файл пользователю для скачивания
     * 
     * @param int $id ID вложения
     * @return \yii\web\Response
     */
    public function actionDownload($id)
    {
        $attachment = DeskAttachments::findOne($id);
        
        if (!$attachment || !$attachment->fileExists()) {
            throw new NotFoundHttpException('Файл не найден.');
        }
        
        return Yii::$app->response->sendFile($attachment->getFullPath(), $attachment->name);
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
            
            if ($this->request->isPost) {
            $statusId = $this->request->post('status_id');
            $status = DicTaskStatus::findOne($statusId);
            
            if ($status) {
                $model->id_status = $statusId;
                $model->last_time_update = date('Y-m-d H:i:s');
                if ($model->save(false)) {
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
            
            $model->executor_id = $executorId ?: null;
            $model->last_time_update = date('Y-m-d H:i:s');
            
            if ($model->save(false)) {
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
            
            if ($this->request->isPost) {
            $comment = $this->request->post('comment');
            $model->comment = $comment;
            $model->last_time_update = date('Y-m-d H:i:s');
            
            if ($model->save(false)) {
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
            ->select(['id_user', 'COUNT(*) as count'])
            ->groupBy('id_user')
            ->with('user')
            ->asArray()
            ->all();

        $userChartData = [];
        foreach ($userStats as $stat) {
            $user = Users::findOne($stat['id_user']);
            $userChartData[] = [
                'name' => $user ? $user->full_name : 'Неизвестный пользователь',
                'y' => (int)$stat['count']
            ];
        }

        /** Получаем данные для диаграммы завершенных заявок по исполнителям */
        $executorStats = Tasks::find()
            ->select(['executor_id', 'COUNT(*) as count'])
            ->where(['id_status' => 4]) // Статус "Завершено"
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
                    'status_id' => $model->id_status,
                    'status_name' => $model->status ? $model->status->status_name : '',
                    'user_id' => $model->id_user,
                    'user_name' => $model->user ? $model->user->full_name : '',
                    'executor_id' => $model->executor_id,
                    'executor_name' => $model->executor ? $model->executor->full_name : '',
                    'date' => $model->date ? Yii::$app->formatter->asDatetime($model->date, 'php:d.m.Y H:i') : '',
                    'last_time_update' => $model->last_time_update ? Yii::$app->formatter->asDatetime($model->last_time_update, 'php:d.m.Y H:i') : '',
                    'comment' => $model->comment,
                    'attachments' => array_map(function($attachment) {
                        return [
                            'id' => $attachment->attach_id,
                            'name' => $attachment->name,
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
            ->select(['id_user', 'COUNT(*) as count'])
            ->groupBy('id_user')
            ->with('user')
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

        /** Заполняем данные пользователей */
        $row = 2;
        foreach ($userStats as $stat) {
            $user = Users::findOne($stat['id_user']);
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
        $executorStats = Tasks::find()
            ->select(['executor_id', 'COUNT(*) as count'])
            ->where(['id_status' => 4]) // Статус "Завершено"
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
        
        try {
            /** Получаем всю технику пользователя с загруженными связями */
            $equipment = Arm::find()
                ->where(['id_user' => $userId])
                ->with(['location'])
                ->all();
            
            $data = [];
            
            /** Если техники нет - возвращаем пустой массив */
            if (empty($equipment)) {
                return [
                    'success' => true,
                    'data' => [],
                    'message' => 'У пользователя нет закрепленной техники'
                ];
            }
            
            /** Формируем массив данных для отображения */
            foreach ($equipment as $arm) {
                $data[] = [
                    'id' => $arm->id_arm,
                    'name' => $arm->name,
                    'location' => $arm->location ? $arm->location->name : 'Не указано',
                    'description' => $arm->description ?: 'Нет описания',
                    'created_at' => $arm->created_at,
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
