<?php

namespace app\models\search;

use app\models\dictionaries\DicWorkTaskStatus;
use app\models\entities\WorkTask;
use Yii;
use yii\base\Model;
use yii\data\ActiveDataProvider;
use yii\db\Expression;

class WorkTaskSearch extends Model
{
    public $filter = 'active';
    public $executor_id;
    public $q;
    /** @var string|null Дата закрытия от (Y-m-d) */
    public $closed_from;
    /** @var string|null Дата закрытия до (Y-m-d) */
    public $closed_to;
    /** @var string Сортировка на вкладке «Закрытые» */
    public $sort = 'closed_desc';

    public const SORT_CLOSED_DESC = 'closed_desc';
    public const SORT_CLOSED_ASC = 'closed_asc';
    public const SORT_CREATED_DESC = 'created_desc';
    public const SORT_CREATED_ASC = 'created_asc';

    public function rules()
    {
        return [
            [['filter', 'q', 'sort', 'closed_from', 'closed_to'], 'string'],
            [['executor_id'], 'integer', 'skipOnEmpty' => true],
            [['sort'], 'in', 'range' => [
                self::SORT_CLOSED_DESC,
                self::SORT_CLOSED_ASC,
                self::SORT_CREATED_DESC,
                self::SORT_CREATED_ASC,
            ], 'skipOnEmpty' => true],
            [['closed_from', 'closed_to'], 'date', 'format' => 'php:Y-m-d', 'skipOnEmpty' => true],
        ];
    }

    /**
     * Читает GET-параметры фильтра (плоские имена полей формы).
     */
    public function applyRequestParams(array $params): void
    {
        if (array_key_exists('filter', $params)) {
            $filter = trim((string) $params['filter']) ?: 'active';
            $this->filter = in_array($filter, ['active', 'done'], true) ? $filter : 'active';
        }
        if (array_key_exists('q', $params)) {
            $this->q = (string) $params['q'];
        }
        if (array_key_exists('executor_id', $params)) {
            $raw = $params['executor_id'];
            $this->executor_id = ($raw === '' || $raw === null) ? null : (int) $raw;
        }
        if (array_key_exists('sort', $params)) {
            $sort = trim((string) $params['sort']);
            $this->sort = $sort !== '' ? $sort : self::SORT_CLOSED_DESC;
        }
        if (array_key_exists('closed_from', $params)) {
            $value = trim((string) $params['closed_from']);
            $this->closed_from = $value !== '' ? $value : null;
        }
        if (array_key_exists('closed_to', $params)) {
            $value = trim((string) $params['closed_to']);
            $this->closed_to = $value !== '' ? $value : null;
        }
    }

    /**
     * @return array<string, string>
     */
    public static function sortLabels(): array
    {
        return [
            self::SORT_CLOSED_DESC => 'Сначала недавно закрытые',
            self::SORT_CLOSED_ASC => 'Сначала давно закрытые',
            self::SORT_CREATED_DESC => 'Сначала недавно созданные',
            self::SORT_CREATED_ASC => 'Сначала давно созданные',
        ];
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

        $this->applyStatusFilter($query);

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

        $this->applyStatusFilter($query);
        $this->applyClosedPeriodFilter($query);

        if (($this->filter ?: 'active') === 'done') {
            $query->with([
                'history' => static function ($historyQuery) {
                    $historyQuery
                        ->with(['changedByUser', 'oldStatus', 'newStatus'])
                        ->orderBy(['changed_at' => SORT_ASC, 'id' => SORT_ASC])
                        ->limit(15);
                },
            ]);
        }

        $this->applyBoardSort($query);

        $tasks = $query
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

    /**
     * Фильтр вкладки: active — нефинальные; done — финальные (закрытые и отменённые).
     *
     * @param \yii\db\ActiveQuery $query
     */
    private function applyStatusFilter($query): void
    {
        $filter = $this->filter ?: 'active';
        if (!in_array($filter, ['active', 'done'], true)) {
            $filter = 'active';
            $this->filter = 'active';
        }

        $finalIds = DicWorkTaskStatus::find()
            ->select('id')
            ->where(['is_final' => true])
            ->column();

        if ($filter === 'done') {
            if ($finalIds !== []) {
                $query->andWhere(['wt.status_id' => $finalIds]);
            }
            return;
        }

        if ($finalIds !== []) {
            $query->andWhere(['not in', 'wt.status_id', $finalIds]);
        }
    }

    /**
     * @param \yii\db\ActiveQuery $query
     */
    private function applyBoardSort($query): void
    {
        $filter = $this->filter ?: 'active';
        if ($filter !== 'done') {
            $query->orderBy(['wt.updated_at' => SORT_DESC, 'wt.id' => SORT_DESC]);

            return;
        }

        $sort = $this->sort ?: self::SORT_CLOSED_DESC;
        if (!isset(self::sortLabels()[$sort])) {
            $sort = self::SORT_CLOSED_DESC;
            $this->sort = $sort;
        }

        if ($sort === self::SORT_CREATED_ASC) {
            $query->orderBy(['wt.created_at' => SORT_ASC, 'wt.id' => SORT_ASC]);

            return;
        }
        if ($sort === self::SORT_CREATED_DESC) {
            $query->orderBy(['wt.created_at' => SORT_DESC, 'wt.id' => SORT_DESC]);

            return;
        }

        $this->ensureClosedStatusJoin($query);

        $closedAtSql = $this->getClosedAtSql();

        $dir = $sort === self::SORT_CLOSED_ASC ? SORT_ASC : SORT_DESC;
        $query->orderBy([$closedAtSql => $dir, 'wt.id' => $dir]);
    }

    /**
     * @param \yii\db\ActiveQuery $query
     */
    private function applyClosedPeriodFilter($query): void
    {
        if (($this->filter ?: 'active') !== 'done') {
            return;
        }

        if ($this->closed_from === null && $this->closed_to === null) {
            return;
        }

        $this->ensureClosedStatusJoin($query);

        $closedAtSql = $this->getClosedAtSql();
        if ($this->closed_from !== null) {
            $query->andWhere(new Expression($closedAtSql . ' >= :closed_from', [
                ':closed_from' => $this->closed_from . ' 00:00:00',
            ]));
        }
        if ($this->closed_to !== null) {
            $query->andWhere(new Expression($closedAtSql . ' <= :closed_to', [
                ':closed_to' => $this->closed_to . ' 23:59:59',
            ]));
        }
    }

    private function getClosedAtSql(): string
    {
        return 'COALESCE('
            . 'CASE WHEN dwt_status.status_code = \'' . DicWorkTaskStatus::CODE_DONE . '\' THEN wt.confirmed_at END, '
            . 'CASE WHEN dwt_status.status_code = \'' . DicWorkTaskStatus::CODE_CANCELLED . '\' THEN wt.status_changed_at END, '
            . 'wt.status_changed_at, '
            . 'wt.updated_at'
            . ')';
    }

    /**
     * Добавляет join к словарю статусов один раз.
     *
     * @param \yii\db\ActiveQuery $query
     */
    private function ensureClosedStatusJoin($query): void
    {
        $joins = $query->join ?? [];
        foreach ($joins as $join) {
            if (!is_array($join) || count($join) < 2) {
                continue;
            }
            $table = $join[1];
            if (is_array($table) && array_key_exists('dwt_status', $table)) {
                return;
            }
            if (is_string($table) && stripos($table, 'dwt_status') !== false) {
                return;
            }
        }

        $query->leftJoin(
            ['dwt_status' => DicWorkTaskStatus::tableName()],
            'dwt_status.id = wt.status_id'
        );
    }
}
