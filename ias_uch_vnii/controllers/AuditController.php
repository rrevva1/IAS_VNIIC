<?php

namespace app\controllers;

use app\models\entities\AuditEvent;
use app\models\entities\Users;
use Yii;
use yii\data\ActiveDataProvider;
use yii\filters\AccessControl;
use yii\web\Controller;
use yii\web\Response;

/**
 * Просмотр журнала аудита (только для администраторов).
 * Список событий отображается в AG Grid; данные — actionGetGridData.
 */
class AuditController extends Controller
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
                            return Yii::$app->user->identity && Yii::$app->user->identity->isAdministrator();
                        },
                    ],
                ],
                'denyCallback' => function () {
                    throw new \yii\web\ForbiddenHttpException('Доступ запрещён.');
                },
            ],
        ];
    }

    /**
     * Список событий с фильтрами. Данные для AG Grid.
     */
    public function actionGetGridData()
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        try {
            $query = $this->buildFilteredQuery();
            $models = $query->with('actor')->orderBy(['event_time' => SORT_DESC])->all();
            $data = [];
            foreach ($models as $model) {
                $data[] = [
                    'id' => $model->id,
                    'event_time' => $model->event_time,
                    'actor_name' => $model->actor ? $model->actor->full_name : '—',
                    'action_type' => $model->action_type,
                    'object_type' => $model->object_type,
                    'object_id' => $model->object_id,
                    'result_status' => $model->result_status,
                    'payload' => $model->payload ?? '',
                    'error_message' => isset($model->error_message) ? (string) $model->error_message : '',
                ];
            }
            return ['success' => true, 'data' => $data, 'total' => count($data)];
        } catch (\Exception $e) {
            return ['success' => false, 'message' => $e->getMessage(), 'data' => [], 'total' => 0];
        }
    }

    /**
     * Построение запроса с учётом фильтров из GET.
     */
    private function buildFilteredQuery()
    {
        $query = AuditEvent::find();
        $from = Yii::$app->request->get('from');
        $to = Yii::$app->request->get('to');
        $actorId = Yii::$app->request->get('actor_id');
        $actionType = Yii::$app->request->get('action_type');
        $objectType = Yii::$app->request->get('object_type');
        if ($from !== null && $from !== '') {
            $query->andWhere(['>=', 'event_time', $from . ' 00:00:00']);
        }
        if ($to !== null && $to !== '') {
            $query->andWhere(['<=', 'event_time', $to . ' 23:59:59']);
        }
        if ($actorId !== null && $actorId !== '') {
            $query->andWhere(['actor_id' => (int) $actorId]);
        }
        if ($actionType !== null && $actionType !== '') {
            $query->andWhere(['action_type' => $actionType]);
        }
        if ($objectType !== null && $objectType !== '') {
            $query->andWhere(['object_type' => $objectType]);
        }
        return $query;
    }

    public function actionIndex()
    {
        $users = Users::find()->select(['full_name', 'id'])->indexBy('id')->orderBy('full_name')->column();
        return $this->render('index', [
            'users' => $users,
        ]);
    }
}
