<?php

namespace app\models\search;

use app\models\dictionaries\DicWorkTaskStatus;
use app\models\entities\WorkTask;
use Yii;
use yii\base\Model;
use yii\data\ActiveDataProvider;

class WorkTaskSearch extends Model
{
    public $filter = 'active';
    public $executor_id;
    public $q;

    public function rules()
    {
        return [
            [['filter', 'q'], 'string'],
            [['executor_id'], 'integer', 'skipOnEmpty' => true],
        ];
    }

    /**
     * Читает GET-параметры фильтра (плоские имена полей формы).
     */
    public function applyRequestParams(array $params): void
    {
        if (array_key_exists('filter', $params)) {
            $this->filter = trim((string) $params['filter']) ?: 'active';
        }
        if (array_key_exists('q', $params)) {
            $this->q = (string) $params['q'];
        }
        if (array_key_exists('executor_id', $params)) {
            $raw = $params['executor_id'];
            $this->executor_id = ($raw === '' || $raw === null) ? null : (int) $raw;
        }
    }

    public function search(array $params): ActiveDataProvider
    {
        $query = WorkTask::find()
            ->alias('wt')
            ->where(['wt.is_deleted' => false])
            ->with(['status', 'executor', 'creator', 'requestTask.requester']);

        $user = Yii::$app->user->identity;
        if ($user && $user->isOperator() && !$user->isAdministrator()) {
            $query->andWhere(['wt.executor_id' => (int) $user->id]);
        }

        $dataProvider = new ActiveDataProvider([
            'query' => $query,
            'pagination' => ['pageSize' => 25],
            'sort' => [
                'defaultOrder' => ['updated_at' => SORT_DESC],
                'attributes' => [
                    'id',
                    'title',
                    'updated_at',
                    'created_at',
                ],
            ],
        ]);

        $this->applyRequestParams($params);
        $this->validate();

        if ($this->executor_id !== null) {
            $query->andWhere(['wt.executor_id' => $this->executor_id]);
        }

        $q = trim((string) $this->q);
        if ($q !== '') {
            $query->andWhere([
                'or',
                ['ilike', 'wt.title', $q],
                ['ilike', 'wt.description', $q],
            ]);
        }

        $filter = $this->filter ?: 'active';
        if ($filter === 'review') {
            $reviewId = DicWorkTaskStatus::resolveIdByCode(DicWorkTaskStatus::CODE_PENDING_REVIEW);
            if ($reviewId) {
                $query->andWhere(['wt.status_id' => $reviewId]);
            }
        } elseif ($filter === 'done') {
            $doneId = DicWorkTaskStatus::resolveIdByCode(DicWorkTaskStatus::CODE_DONE);
            if ($doneId) {
                $query->andWhere(['wt.status_id' => $doneId]);
            }
        } elseif ($filter === 'active') {
            $finalIds = DicWorkTaskStatus::find()
                ->select('id')
                ->where(['is_final' => true])
                ->column();
            if ($finalIds !== []) {
                $query->andWhere(['not in', 'wt.status_id', $finalIds]);
            }
        }

        return $dataProvider;
    }

    /**
     * Задачи для Kanban-доски (без пагинации, сгруппированы по коду статуса).
     *
     * @return array{tasks: WorkTask[], byStatus: array<string, WorkTask[]>}
     */
    public function searchForBoard(array $params): array
    {
        $query = WorkTask::find()
            ->alias('wt')
            ->where(['wt.is_deleted' => false])
            ->with(['status', 'executor', 'creator', 'requestTask.requester']);

        $user = Yii::$app->user->identity;
        if ($user && $user->isOperator() && !$user->isAdministrator()) {
            $query->andWhere(['wt.executor_id' => (int) $user->id]);
        }

        $this->applyRequestParams($params);
        if (!$this->validate()) {
            $this->filter = 'active';
        }

        if ($this->executor_id !== null) {
            $query->andWhere(['wt.executor_id' => $this->executor_id]);
        }

        $q = trim((string) $this->q);
        if ($q !== '') {
            $query->andWhere([
                'or',
                ['ilike', 'wt.title', $q],
                ['ilike', 'wt.description', $q],
            ]);
        }

        $filter = $this->filter ?: 'active';
        if ($filter === 'review') {
            $reviewId = DicWorkTaskStatus::resolveIdByCode(DicWorkTaskStatus::CODE_PENDING_REVIEW);
            if ($reviewId) {
                $query->andWhere(['wt.status_id' => $reviewId]);
            }
        } elseif ($filter === 'done') {
            $doneId = DicWorkTaskStatus::resolveIdByCode(DicWorkTaskStatus::CODE_DONE);
            if ($doneId) {
                $query->andWhere(['wt.status_id' => $doneId]);
            }
        } elseif ($filter === 'active') {
            $finalIds = DicWorkTaskStatus::find()
                ->select('id')
                ->where(['is_final' => true])
                ->column();
            if ($finalIds !== []) {
                $query->andWhere(['not in', 'wt.status_id', $finalIds]);
            }
        }

        $tasks = $query
            ->orderBy(['wt.updated_at' => SORT_DESC])
            ->limit(200)
            ->all();

        $byStatus = [];
        foreach (DicWorkTaskStatus::TIMELINE_CODES as $code) {
            $byStatus[$code] = [];
        }
        $byStatus[DicWorkTaskStatus::CODE_CANCELLED] = [];

        foreach ($tasks as $task) {
            $code = $task->getStatusCode();
            if ($code === '') {
                continue;
            }
            if (!isset($byStatus[$code])) {
                $byStatus[$code] = [];
            }
            $byStatus[$code][] = $task;
        }

        return ['tasks' => $tasks, 'byStatus' => $byStatus];
    }
}
