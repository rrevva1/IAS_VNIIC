<?php

namespace app\controllers;

use app\components\AuditLog;
use app\models\entities\PhoneDirectory;
use app\models\entities\Tasks;
use app\models\search\PhoneDirectorySearch;
use Yii;
use yii\filters\AccessControl;
use yii\filters\VerbFilter;
use yii\web\Controller;
use yii\web\NotFoundHttpException;
use yii\web\Response;

/**
 * Телефонный справочник (просмотр для всех авторизованных, CRUD — admin).
 */
class PhoneDirectoryController extends Controller
{
    public function behaviors()
    {
        return array_merge(parent::behaviors(), [
            'access' => [
                'class' => AccessControl::class,
                'rules' => [
                    [
                        'actions' => ['index', 'get-grid-data'],
                        'allow' => true,
                        'roles' => ['@'],
                    ],
                    [
                        'actions' => [
                            'create-modal',
                            'update-modal',
                            'delete',
                            'sync-from-users',
                        ],
                        'allow' => true,
                        'roles' => ['@'],
                        'matchCallback' => static function () {
                            $user = Yii::$app->user->identity;

                            return $user && $user->isAdministrator();
                        },
                    ],
                ],
            ],
            'verbs' => [
                'class' => VerbFilter::class,
                'actions' => [
                    'delete' => ['POST'],
                    'sync-from-users' => ['POST'],
                ],
            ],
        ]);
    }

    public function actionIndex()
    {
        $lastUpdated = PhoneDirectory::getLastUpdatedAt();
        $isAdmin = Yii::$app->user->identity && Yii::$app->user->identity->isAdministrator();

        return $this->render('index', [
            'lastUpdated' => $lastUpdated,
            'isAdmin' => $isAdmin,
            'reportIssueUrl' => \yii\helpers\Url::to([
                '/tasks/create',
                'request_category' => Tasks::CATEGORY_PHONE_DIRECTORY_UPDATE,
            ]),
        ]);
    }

    public function actionGetGridData()
    {
        Yii::$app->response->format = Response::FORMAT_JSON;

        try {
            $searchModel = new PhoneDirectorySearch();
            $isAdmin = Yii::$app->user->identity && Yii::$app->user->identity->isAdministrator();
            $publishedOnly = !$isAdmin || $this->request->get('include_unpublished') !== '1';
            $dataProvider = $searchModel->search($this->request->queryParams, $publishedOnly);
            $dataProvider->pagination = false;

            $data = [];
            foreach ($dataProvider->getModels() as $model) {
                /** @var PhoneDirectory $model */
                $data[] = [
                    'id' => (int) $model->id,
                    'entry_type' => $model->entry_type,
                    'entry_type_label' => PhoneDirectory::entryTypeLabels()[$model->entry_type] ?? $model->entry_type,
                    'full_name' => $model->full_name,
                    'position' => $model->position,
                    'department' => $model->department,
                    'room' => $model->room,
                    'internal_phone' => $model->internal_phone,
                    'external_phone' => $model->external_phone,
                    'is_published' => (bool) $model->is_published,
                    'user_id' => $model->user_id ? (int) $model->user_id : null,
                    'updated_at' => $model->updated_at,
                ];
            }

            return [
                'success' => true,
                'data' => $data,
                'total' => count($data),
                'last_updated' => PhoneDirectory::getLastUpdatedAt(),
            ];
        } catch (\Throwable $e) {
            return [
                'success' => false,
                'message' => $e->getMessage(),
                'data' => [],
                'total' => 0,
            ];
        }
    }

    public function actionCreateModal()
    {
        $model = new PhoneDirectory();
        $model->entry_type = PhoneDirectory::TYPE_PERSON;
        $model->is_published = true;
        $model->sort_order = 100;

        if ($this->request->isPost) {
            Yii::$app->response->format = Response::FORMAT_JSON;

            if ($model->load($this->request->post()) && $model->save()) {
                AuditLog::log('phone_directory.create', 'phone_directory', $model->id, 'success');

                return [
                    'success' => true,
                    'message' => 'Запись «' . $model->full_name . '» добавлена в справочник.',
                    'id' => (int) $model->id,
                ];
            }

            $errors = $model->getFirstErrors();

            return [
                'success' => false,
                'errors' => $model->errors,
                'message' => 'Не удалось создать запись'
                    . ($errors ? ': ' . implode(' ', $errors) : ''),
            ];
        }

        return $this->renderAjax('_form_modal', [
            'model' => $model,
            'isUpdate' => false,
        ]);
    }

    public function actionUpdateModal($id)
    {
        $model = $this->findModel($id);

        if ($this->request->isPost) {
            Yii::$app->response->format = Response::FORMAT_JSON;

            if ($model->load($this->request->post()) && $model->save()) {
                AuditLog::log('phone_directory.update', 'phone_directory', $model->id, 'success');

                return [
                    'success' => true,
                    'message' => 'Запись «' . $model->full_name . '» сохранена.',
                    'id' => (int) $model->id,
                ];
            }

            $errors = $model->getFirstErrors();

            return [
                'success' => false,
                'errors' => $model->errors,
                'message' => 'Не удалось сохранить запись'
                    . ($errors ? ': ' . implode(' ', $errors) : ''),
            ];
        }

        return $this->renderAjax('_form_modal', [
            'model' => $model,
            'isUpdate' => true,
        ]);
    }

    public function actionDelete($id)
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $model = $this->findModel($id);
        $name = $model->full_name;
        $modelId = (int) $model->id;

        if ($model->delete()) {
            AuditLog::log('phone_directory.delete', 'phone_directory', $modelId, 'success');

            return [
                'success' => true,
                'message' => 'Запись «' . $name . '» удалена.',
            ];
        }

        return [
            'success' => false,
            'message' => 'Не удалось удалить запись.',
        ];
    }

    /**
     * Повторный импорт/синхронизация из users (admin).
     */
    public function actionSyncFromUsers()
    {
        Yii::$app->response->format = Response::FORMAT_JSON;

        $users = \app\models\entities\Users::find()
            ->andWhere(['is_deleted' => false])
            ->all();

        $count = 0;
        foreach ($users as $user) {
            if (PhoneDirectory::syncFromUser($user) !== null) {
                $count++;
            }
        }

        // Служебные заглушки, если отсутствуют
        foreach (
            [
                ['Приёмная', 'Администрация', 10],
                ['Охрана', 'Охрана', 20],
                ['АТС', 'ИТ', 30],
            ] as [$name, $department, $sort]
        ) {
            $exists = PhoneDirectory::find()
                ->where(['entry_type' => PhoneDirectory::TYPE_SERVICE, 'full_name' => $name])
                ->exists();
            if ($exists) {
                continue;
            }
            $row = new PhoneDirectory();
            $row->entry_type = PhoneDirectory::TYPE_SERVICE;
            $row->full_name = $name;
            $row->department = $department;
            $row->is_published = true;
            $row->sort_order = $sort;
            $row->save(false);
        }

        AuditLog::log('phone_directory.sync_from_users', 'phone_directory', null, 'success', [
            'synced' => $count,
        ]);

        $total = (int) PhoneDirectory::find()->where(['is_published' => true])->count();

        return [
            'success' => true,
            'message' => 'Синхронизировано записей из пользователей: ' . $count
                . '. В справочнике опубликовано: ' . $total . '.',
            'synced' => $count,
            'published' => $total,
        ];
    }

    protected function findModel($id): PhoneDirectory
    {
        $model = PhoneDirectory::findOne(['id' => (int) $id]);
        if ($model === null) {
            throw new NotFoundHttpException('Запись справочника не найдена.');
        }

        return $model;
    }
}
