<?php

namespace app\components;

use app\models\dictionaries\DicTaskStatus;
use app\models\dictionaries\DicWorkTaskStatus;
use app\models\entities\EquipHistory;
use app\models\entities\TaskHistory;
use app\models\entities\Tasks;
use app\models\entities\Users;
use app\models\entities\WorkTask;
use Yii;
use yii\db\Expression;

/**
 * KPI и аналитика по заявкам Help Desk.
 */
class TaskStatisticsService
{
    private ?string $dateFrom;
    private ?string $dateTo;

    /** @var int[] */
    private array $completedStatusIds;

    private ?int $cancelledStatusId;

    /** @var array<int, string> */
    private array $statusNames = [];

    /** @var array<int, int>|null */
    private ?array $completionTimestamps = null;

    public function __construct(?string $dateFrom = null, ?string $dateTo = null)
    {
        $this->dateFrom = $this->normalizeDate($dateFrom);
        $this->dateTo = $this->normalizeDate($dateTo);
        $this->completedStatusIds = DicTaskStatus::getCompletedStatusIds();
        $this->cancelledStatusId = DicTaskStatus::resolveIdByCode(DicTaskStatus::CODE_CANCELLED);

        foreach (DicTaskStatus::find()->orderBy(['sort_order' => SORT_ASC])->all() as $status) {
            $this->statusNames[(int) $status->id] = $status->status_name;
        }
    }

    /**
     * Отчёт по истории перемещений техники (без KPI заявок и задач).
     *
     * @return array<string, mixed>
     */
    public function buildMovementHistoryReport(): array
    {
        $movements = $this->buildEquipmentMovementStats();
        $movementSummary = $this->buildEquipmentMovementSummary($movements);

        return [
            'period' => [
                'from' => $this->dateFrom,
                'to' => $this->dateTo,
                'label' => $this->getPeriodLabel(),
            ],
            'movements' => $movements,
            'movement_summary' => $movementSummary,
        ];
    }

    public function buildReport(): array
    {
        $tasks = $this->loadTasksInPeriod();
        $this->preloadCompletionTimestamps($tasks);

        $summary = $this->buildSummary($tasks);
        $executors = $this->buildWorkExecutorKpi();
        $statusDistribution = $this->buildStatusDistribution($tasks);
        $workStatusDistribution = $this->buildWorkTaskStatusDistribution();
        $workSummary = $this->buildWorkTaskSummary();
        $closedWorkTasks = $this->loadClosedWorkTasksInPeriod();
        $monthlyCompleted = $this->buildMonthlyCompleted($closedWorkTasks);
        $dailyCompleted = $this->buildDailyCompleted($closedWorkTasks);
        $requesters = $this->buildRequesterStats($tasks);
        $movements = $this->buildEquipmentMovementStats();
        $movementSummary = $this->buildEquipmentMovementSummary($movements);

        return [
            'period' => [
                'from' => $this->dateFrom,
                'to' => $this->dateTo,
                'label' => $this->getPeriodLabel(),
            ],
            'summary' => $summary,
            'executors' => $executors,
            'status_distribution' => $statusDistribution,
            'work_status_distribution' => $workStatusDistribution,
            'work_summary' => $workSummary,
            'monthly_completed' => $monthlyCompleted,
            'daily_completed' => $dailyCompleted,
            'requesters' => $requesters,
            'movements' => $movements,
            'movement_summary' => $movementSummary,
        ];
    }

    public static function formatDuration(int $seconds): string
    {
        if ($seconds < 0) {
            $seconds = 0;
        }
        if ($seconds < 60) {
            return $seconds . ' сек';
        }
        if ($seconds < 3600) {
            $m = (int) floor($seconds / 60);

            return $m . ' мин';
        }
        if ($seconds < 86400) {
            $h = (int) floor($seconds / 3600);
            $m = (int) floor(($seconds % 3600) / 60);

            return $m > 0 ? $h . ' ч ' . $m . ' мин' : $h . ' ч';
        }

        $d = (int) floor($seconds / 86400);
        $h = (int) floor(($seconds % 86400) / 3600);

        return $h > 0 ? $d . ' дн ' . $h . ' ч' : $d . ' дн';
    }

    public static function formatDurationHours(int $seconds): string
    {
        if ($seconds <= 0) {
            return '0 ч';
        }

        return round($seconds / 3600, 1) . ' ч';
    }

    private function normalizeDate(?string $date): ?string
    {
        if ($date === null || trim($date) === '') {
            return null;
        }
        $ts = strtotime($date);
        if ($ts === false) {
            return null;
        }

        return date('Y-m-d', $ts);
    }

    private function getPeriodLabel(): string
    {
        if ($this->dateFrom && $this->dateTo) {
            return Yii::$app->formatter->asDate($this->dateFrom, 'php:d.m.Y')
                . ' — '
                . Yii::$app->formatter->asDate($this->dateTo, 'php:d.m.Y');
        }
        if ($this->dateFrom) {
            return 'с ' . Yii::$app->formatter->asDate($this->dateFrom, 'php:d.m.Y');
        }
        if ($this->dateTo) {
            return 'по ' . Yii::$app->formatter->asDate($this->dateTo, 'php:d.m.Y');
        }

        return 'за всё время';
    }

    /**
     * @return Tasks[]
     */
    private function loadTasksInPeriod(): array
    {
        $query = Tasks::find()
            ->alias('t')
            ->with(['status', 'executor', 'requester']);

        $fromDateTime = $this->dateFrom ? ($this->dateFrom . ' 00:00:00') : null;
        $toDateTime = $this->dateTo ? ($this->dateTo . ' 23:59:59') : null;

        if ($fromDateTime !== null) {
            $query->andWhere(['>=', 't.created_at', $fromDateTime]);
        }
        if ($toDateTime !== null) {
            $query->andWhere(['<=', 't.created_at', $toDateTime]);
        }

        return $query->orderBy(['t.id' => SORT_DESC])->all();
    }

    /**
     * @param Tasks[] $tasks
     */
    private function preloadCompletionTimestamps(array $tasks): void
    {
        $taskIds = [];
        foreach ($tasks as $task) {
            if ($this->isCompleted($task) && !$task->closed_at) {
                $taskIds[] = (int) $task->id;
            }
        }

        $this->completionTimestamps = [];
        if ($taskIds === [] || $this->completedStatusIds === []) {
            return;
        }

        $completedIdStrings = array_map('strval', $this->completedStatusIds);
        $rows = TaskHistory::find()
            ->select(['task_id', new Expression('MIN(changed_at) AS completed_at')])
            ->where(['field_name' => 'status_id', 'task_id' => $taskIds])
            ->andWhere(['new_value' => $completedIdStrings])
            ->groupBy(['task_id'])
            ->asArray()
            ->all();

        foreach ($rows as $row) {
            $ts = strtotime((string) $row['completed_at']);
            if ($ts !== false) {
                $this->completionTimestamps[(int) $row['task_id']] = $ts;
            }
        }
    }

    private function isCompleted(Tasks $task): bool
    {
        return in_array((int) $task->status_id, $this->completedStatusIds, true);
    }

    private function isCancelled(Tasks $task): bool
    {
        return $this->cancelledStatusId !== null && (int) $task->status_id === $this->cancelledStatusId;
    }

    private function getCompletionTimestamp(Tasks $task): ?int
    {
        if (!$this->isCompleted($task)) {
            return null;
        }

        if ($task->closed_at) {
            $ts = strtotime((string) $task->closed_at);

            return $ts !== false ? $ts : null;
        }

        $fromHistory = $this->completionTimestamps[(int) $task->id] ?? null;
        if ($fromHistory !== null) {
            return $fromHistory;
        }

        if ($task->updated_at) {
            $ts = strtotime((string) $task->updated_at);

            return $ts !== false ? $ts : null;
        }

        return null;
    }

    private function getResolutionSeconds(Tasks $task): ?int
    {
        $completedAt = $this->getCompletionTimestamp($task);
        if ($completedAt === null || !$task->created_at) {
            return null;
        }

        $createdAt = strtotime((string) $task->created_at);
        if ($createdAt === false) {
            return null;
        }

        return max(0, $completedAt - $createdAt);
    }

    /**
     * @param Tasks[] $tasks
     */
    private function buildSummary(array $tasks): array
    {
        $total = count($tasks);
        $completed = 0;
        $cancelled = 0;
        $open = 0;
        $resolutionSeconds = [];
        $completedInPeriod = 0;

        foreach ($tasks as $task) {
            if ($this->isCancelled($task)) {
                $cancelled++;
                continue;
            }
            if ($this->isCompleted($task)) {
                $completed++;
                $sec = $this->getResolutionSeconds($task);
                if ($sec !== null) {
                    $resolutionSeconds[] = $sec;
                }
                if ($this->isCompletedInPeriod($task)) {
                    $completedInPeriod++;
                }
                continue;
            }
            $open++;
        }

        $totalResolution = array_sum($resolutionSeconds);
        $avgResolution = $completed > 0 && $resolutionSeconds !== []
            ? (int) round($totalResolution / count($resolutionSeconds))
            : 0;
        $medianResolution = $this->median($resolutionSeconds);

        $denominator = max(1, $total - $cancelled);
        $completionRate = $total > 0 ? round(($completed / $denominator) * 100, 1) : 0.0;

        $executorIds = [];
        foreach ($tasks as $task) {
            if ($this->isCompleted($task) && (int) $task->executor_id > 0) {
                $executorIds[(int) $task->executor_id] = true;
            }
        }
        $activeExecutors = count($executorIds);
        $avgPerExecutor = $activeExecutors > 0 ? round($completed / $activeExecutors, 1) : 0.0;

        return [
            'total' => $total,
            'completed' => $completed,
            'completed_in_period' => $completedInPeriod,
            'cancelled' => $cancelled,
            'open' => $open,
            'completion_rate' => $completionRate,
            'total_resolution_seconds' => $totalResolution,
            'total_resolution_label' => self::formatDuration($totalResolution),
            'total_resolution_hours' => self::formatDurationHours($totalResolution),
            'avg_resolution_seconds' => $avgResolution,
            'avg_resolution_label' => $avgResolution > 0 ? self::formatDuration($avgResolution) : '—',
            'median_resolution_seconds' => $medianResolution,
            'median_resolution_label' => $medianResolution > 0 ? self::formatDuration($medianResolution) : '—',
            'avg_per_executor' => $avgPerExecutor,
            'active_executors' => $activeExecutors,
        ];
    }

    private function isCompletedInPeriod(Tasks $task): bool
    {
        $completedAt = $this->getCompletionTimestamp($task);
        if ($completedAt === null) {
            return false;
        }

        $day = date('Y-m-d', $completedAt);
        if ($this->dateFrom && $day < $this->dateFrom) {
            return false;
        }
        if ($this->dateTo && $day > $this->dateTo) {
            return false;
        }

        return true;
    }

    /**
     * @param Tasks[] $tasks
     */
    private function buildExecutorKpi(array $tasks): array
    {
        $buckets = [];

        foreach ($tasks as $task) {
            if (!$this->isCompleted($task)) {
                continue;
            }

            $executorId = (int) ($task->executor_id ?? 0);
            if (!isset($buckets[$executorId])) {
                $name = 'Не назначен';
                if ($executorId > 0 && $task->executor) {
                    $name = $task->executor->full_name;
                } elseif ($executorId > 0) {
                    $user = Users::findOne($executorId);
                    $name = $user ? $user->full_name : 'Исполнитель #' . $executorId;
                }

                $buckets[$executorId] = [
                    'executor_id' => $executorId,
                    'name' => $name,
                    'completed_count' => 0,
                    'total_resolution_seconds' => 0,
                    'resolution_samples' => 0,
                ];
            }

            $buckets[$executorId]['completed_count']++;
            $sec = $this->getResolutionSeconds($task);
            if ($sec !== null) {
                $buckets[$executorId]['total_resolution_seconds'] += $sec;
                $buckets[$executorId]['resolution_samples']++;
            }
        }

        $rows = array_values($buckets);
        usort($rows, static function (array $a, array $b): int {
            return $b['completed_count'] <=> $a['completed_count']
                ?: $b['total_resolution_seconds'] <=> $a['total_resolution_seconds'];
        });

        $totalCompleted = array_sum(array_column($rows, 'completed_count'));
        $result = [];
        $rowNum = 1;

        foreach ($rows as $row) {
            $samples = (int) $row['resolution_samples'];
            $avgSec = $samples > 0 ? (int) round($row['total_resolution_seconds'] / $samples) : 0;
            $share = $totalCompleted > 0
                ? round(($row['completed_count'] / $totalCompleted) * 100, 1)
                : 0.0;

            $result[] = [
                'row_num' => $rowNum++,
                'executor_id' => (int) $row['executor_id'],
                'name' => $row['name'],
                'completed_count' => (int) $row['completed_count'],
                'share_percent' => $share,
                'total_resolution_seconds' => (int) $row['total_resolution_seconds'],
                'total_resolution_label' => self::formatDuration((int) $row['total_resolution_seconds']),
                'avg_resolution_seconds' => $avgSec,
                'avg_resolution_label' => $avgSec > 0 ? self::formatDuration($avgSec) : '—',
            ];
        }

        return $result;
    }

    /**
     * @param Tasks[] $tasks
     */
    private function buildRequesterStats(array $tasks): array
    {
        $buckets = [];
        foreach ($tasks as $task) {
            $requesterId = (int) $task->requester_id;
            if (!isset($buckets[$requesterId])) {
                $name = $task->requester ? $task->requester->full_name : 'Неизвестный';
                $buckets[$requesterId] = ['name' => $name, 'count' => 0];
            }
            $buckets[$requesterId]['count']++;
        }

        $rows = array_values($buckets);
        usort($rows, static fn(array $a, array $b): int => $b['count'] <=> $a['count']);

        $total = count($tasks);
        $result = [];
        $rowNum = 1;
        foreach ($rows as $row) {
            $count = (int) $row['count'];
            $result[] = [
                'row_num' => $rowNum++,
                'name' => $row['name'],
                'count' => $count,
                'percentage' => $total > 0 ? round(($count / $total) * 100, 1) : 0.0,
            ];
        }

        return $result;
    }

    /**
     * @param Tasks[] $tasks
     */
    private function buildStatusDistribution(array $tasks): array
    {
        $counts = [];
        foreach ($tasks as $task) {
            $statusId = (int) $task->status_id;
            $label = $this->statusNames[$statusId] ?? ($task->status ? $task->status->status_name : '—');
            if (!isset($counts[$label])) {
                $counts[$label] = 0;
            }
            $counts[$label]++;
        }

        arsort($counts);
        $result = [];
        foreach ($counts as $name => $count) {
            $result[] = ['name' => $name, 'count' => $count];
        }

        return $result;
    }

    /**
     * Распределение внутренних задач по статусам (вкладка "Статистика по задачам").
     * @return array<int, array{name:string,count:int}>
     */
    private function buildWorkTaskStatusDistribution(): array
    {
        $query = WorkTask::find()
            ->alias('wt')
            ->where(['wt.is_deleted' => false])
            ->with(['status']);

        $fromDateTime = $this->dateFrom ? ($this->dateFrom . ' 00:00:00') : null;
        $toDateTime = $this->dateTo ? ($this->dateTo . ' 23:59:59') : null;
        if ($fromDateTime !== null) {
            $query->andWhere(['>=', 'wt.created_at', $fromDateTime]);
        }
        if ($toDateTime !== null) {
            $query->andWhere(['<=', 'wt.created_at', $toDateTime]);
        }

        $rows = $query->all();
        if ($rows === []) {
            return [];
        }

        $counts = [];
        foreach ($rows as $row) {
            $statusName = $row->status ? $row->status->getDisplayName() : '—';
            if (!isset($counts[$statusName])) {
                $counts[$statusName] = 0;
            }
            $counts[$statusName]++;
        }

        arsort($counts);
        $result = [];
        foreach ($counts as $name => $count) {
            $result[] = ['name' => $name, 'count' => $count];
        }

        return $result;
    }

    /**
     * Сводка по внутренним задачам для блока "Статистика по задачам".
     * @return array<string, mixed>
     */
    private function buildWorkTaskSummary(): array
    {
        $query = WorkTask::find()
            ->alias('wt')
            ->where(['wt.is_deleted' => false]);

        $fromDateTime = $this->dateFrom ? ($this->dateFrom . ' 00:00:00') : null;
        $toDateTime = $this->dateTo ? ($this->dateTo . ' 23:59:59') : null;
        if ($fromDateTime !== null) {
            $query->andWhere(['>=', 'wt.created_at', $fromDateTime]);
        }
        if ($toDateTime !== null) {
            $query->andWhere(['<=', 'wt.created_at', $toDateTime]);
        }

        $rows = $query->all();
        if ($rows === []) {
            return [
                'completed' => 0,
                'total_resolution_seconds' => 0,
                'total_resolution_label' => self::formatDuration(0),
                'total_resolution_hours' => self::formatDurationHours(0),
                'avg_resolution_seconds' => 0,
                'avg_resolution_label' => '—',
                'median_resolution_seconds' => 0,
                'median_resolution_label' => '—',
            ];
        }

        $doneCodeIds = array_values(array_filter([
            DicWorkTaskStatus::resolveIdByCode(DicWorkTaskStatus::CODE_PENDING_REVIEW),
            DicWorkTaskStatus::resolveIdByCode(DicWorkTaskStatus::CODE_DONE),
        ], static fn($id) => $id !== null));

        $completed = 0;
        $durations = [];
        $executorIds = [];
        foreach ($rows as $row) {
            if (!in_array((int) $row->status_id, $doneCodeIds, true)) {
                continue;
            }
            $completed++;
            if ((int) $row->executor_id > 0) {
                $executorIds[(int) $row->executor_id] = true;
            }

            $createdTs = strtotime((string) $row->created_at);
            if ($createdTs === false) {
                continue;
            }

            $finishedRaw = $row->confirmed_at ?: $row->submitted_at ?: $row->status_changed_at ?: $row->updated_at;
            $finishedTs = $finishedRaw ? strtotime((string) $finishedRaw) : false;
            if ($finishedTs === false) {
                continue;
            }
            $durations[] = max(0, $finishedTs - $createdTs);
        }

        $totalResolution = array_sum($durations);
        $avgResolution = $durations !== [] ? (int) round($totalResolution / count($durations)) : 0;
        $medianResolution = $this->median($durations);
        $activeExecutors = count($executorIds);
        $avgPerExecutor = $activeExecutors > 0 ? round($completed / $activeExecutors, 1) : 0.0;

        return [
            'completed' => $completed,
            'total_resolution_seconds' => $totalResolution,
            'total_resolution_label' => self::formatDuration($totalResolution),
            'total_resolution_hours' => self::formatDurationHours($totalResolution),
            'avg_resolution_seconds' => $avgResolution,
            'avg_resolution_label' => $avgResolution > 0 ? self::formatDuration($avgResolution) : '—',
            'median_resolution_seconds' => $medianResolution,
            'median_resolution_label' => $medianResolution > 0 ? self::formatDuration($medianResolution) : '—',
            'avg_per_executor' => $avgPerExecutor,
            'active_executors' => $activeExecutors,
        ];
    }

    /**
     * KPI исполнителей по внутренним задачам (учитывает задачи, завершенные в выбранный период).
     * @return array<int, array<string, mixed>>
     */
    private function buildWorkExecutorKpi(): array
    {
        $doneCodeIds = array_values(array_filter([
            DicWorkTaskStatus::resolveIdByCode(DicWorkTaskStatus::CODE_PENDING_REVIEW),
            DicWorkTaskStatus::resolveIdByCode(DicWorkTaskStatus::CODE_DONE),
        ], static fn($id) => $id !== null));
        if ($doneCodeIds === []) {
            return [];
        }

        $rows = WorkTask::find()
            ->alias('wt')
            ->where(['wt.is_deleted' => false])
            ->andWhere(['wt.status_id' => $doneCodeIds])
            ->with(['executor'])
            ->all();

        $buckets = [];
        foreach ($rows as $row) {
            $finishedRaw = $row->confirmed_at ?: $row->submitted_at ?: $row->status_changed_at ?: $row->updated_at;
            $finishedTs = $finishedRaw ? strtotime((string) $finishedRaw) : false;
            if ($finishedTs === false) {
                continue;
            }

            $finishedDay = date('Y-m-d', $finishedTs);
            if ($this->dateFrom && $finishedDay < $this->dateFrom) {
                continue;
            }
            if ($this->dateTo && $finishedDay > $this->dateTo) {
                continue;
            }

            $executorId = (int) ($row->executor_id ?? 0);
            if (!isset($buckets[$executorId])) {
                $name = 'Не назначен';
                if ($executorId > 0 && $row->executor) {
                    $name = $row->executor->full_name;
                } elseif ($executorId > 0) {
                    $user = Users::findOne($executorId);
                    $name = $user ? $user->full_name : 'Исполнитель #' . $executorId;
                }

                $buckets[$executorId] = [
                    'executor_id' => $executorId,
                    'name' => $name,
                    'completed_count' => 0,
                    'total_resolution_seconds' => 0,
                    'resolution_samples' => 0,
                ];
            }

            $buckets[$executorId]['completed_count']++;

            $createdTs = strtotime((string) $row->created_at);
            if ($createdTs !== false) {
                $seconds = max(0, $finishedTs - $createdTs);
                $buckets[$executorId]['total_resolution_seconds'] += $seconds;
                $buckets[$executorId]['resolution_samples']++;
            }
        }

        $data = array_values($buckets);
        usort($data, static function (array $a, array $b): int {
            return $b['completed_count'] <=> $a['completed_count']
                ?: $b['total_resolution_seconds'] <=> $a['total_resolution_seconds'];
        });

        $totalCompleted = array_sum(array_column($data, 'completed_count'));
        $result = [];
        $rowNum = 1;
        foreach ($data as $row) {
            $samples = (int) $row['resolution_samples'];
            $avgSec = $samples > 0 ? (int) round($row['total_resolution_seconds'] / $samples) : 0;
            $share = $totalCompleted > 0
                ? round(($row['completed_count'] / $totalCompleted) * 100, 1)
                : 0.0;

            $result[] = [
                'row_num' => $rowNum++,
                'executor_id' => (int) $row['executor_id'],
                'name' => $row['name'],
                'completed_count' => (int) $row['completed_count'],
                'share_percent' => $share,
                'total_resolution_seconds' => (int) $row['total_resolution_seconds'],
                'total_resolution_label' => self::formatDuration((int) $row['total_resolution_seconds']),
                'avg_resolution_seconds' => $avgSec,
                'avg_resolution_label' => $avgSec > 0 ? self::formatDuration($avgSec) : '—',
            ];
        }

        return $result;
    }

    /**
     * @return WorkTask[]
     */
    private function loadClosedWorkTasksInPeriod(): array
    {
        $closedStatusId = DicWorkTaskStatus::resolveIdByCode(DicWorkTaskStatus::CODE_DONE);
        if ($closedStatusId === null) {
            return [];
        }

        $query = WorkTask::find()
            ->alias('wt')
            ->where([
                'wt.is_deleted' => false,
                'wt.status_id' => $closedStatusId,
            ]);

        $fromDateTime = $this->dateFrom ? ($this->dateFrom . ' 00:00:00') : null;
        $toDateTime = $this->dateTo ? ($this->dateTo . ' 23:59:59') : null;
        if ($fromDateTime !== null) {
            $query->andWhere(['>=', 'COALESCE(wt.confirmed_at, wt.status_changed_at, wt.updated_at)', $fromDateTime]);
        }
        if ($toDateTime !== null) {
            $query->andWhere(['<=', 'COALESCE(wt.confirmed_at, wt.status_changed_at, wt.updated_at)', $toDateTime]);
        }

        return $query->all();
    }

    /**
     * @param WorkTask[] $tasks
     */
    private function buildMonthlyCompleted(array $tasks): array
    {
        $months = [];
        foreach ($tasks as $task) {
            $finishedRaw = $task->confirmed_at ?: $task->status_changed_at ?: $task->updated_at;
            $ts = $finishedRaw ? strtotime((string) $finishedRaw) : false;
            if ($ts === null) {
                continue;
            }
            if ($ts === false) {
                continue;
            }
            $key = date('Y-m', $ts);
            if (!isset($months[$key])) {
                $months[$key] = [
                    'key' => $key,
                    'label' => self::formatMonthLabel($key),
                    'count' => 0,
                ];
            }
            $months[$key]['count']++;
        }

        ksort($months);

        return array_values($months);
    }

    /**
     * @param WorkTask[] $tasks
     * @return array<int, array{key:string,label:string,count:int}>
     */
    private function buildDailyCompleted(array $tasks): array
    {
        $days = [];
        foreach ($tasks as $task) {
            $finishedRaw = $task->confirmed_at ?: $task->status_changed_at ?: $task->updated_at;
            $ts = $finishedRaw ? strtotime((string) $finishedRaw) : false;
            if ($ts === false) {
                continue;
            }
            $key = date('Y-m-d', $ts);
            if (!isset($days[$key])) {
                $days[$key] = [
                    'key' => $key,
                    'label' => self::formatDayLabel($key),
                    'count' => 0,
                ];
            }
            $days[$key]['count']++;
        }

        ksort($days);

        return array_values($days);
    }

    private static function formatMonthLabel(string $yearMonth): string
    {
        $parts = explode('-', $yearMonth);
        if (count($parts) !== 2) {
            return $yearMonth;
        }

        $labels = [
            '01' => 'янв', '02' => 'фев', '03' => 'мар', '04' => 'апр',
            '05' => 'май', '06' => 'июн', '07' => 'июл', '08' => 'авг',
            '09' => 'сен', '10' => 'окт', '11' => 'ноя', '12' => 'дек',
        ];

        return ($labels[$parts[1]] ?? $parts[1]) . ' ' . $parts[0];
    }

    private static function formatDayLabel(string $isoDate): string
    {
        $ts = strtotime($isoDate);
        if ($ts === false) {
            return $isoDate;
        }

        return date('d.m', $ts);
    }

    /**
     * @param int[] $values
     */
    private function median(array $values): int
    {
        if ($values === []) {
            return 0;
        }
        sort($values);
        $n = count($values);
        $mid = (int) floor($n / 2);

        if ($n % 2 === 1) {
            return $values[$mid];
        }

        return (int) round(($values[$mid - 1] + $values[$mid]) / 2);
    }

    /**
     * Статистика перемещений техники по датам и маршрутам «откуда -> куда».
     * @return array<int, array<string, mixed>>
     */
    private function buildEquipmentMovementStats(): array
    {
        $query = EquipHistory::find()
            ->alias('h')
            ->with(['equipment'])
            ->where([
                'or',
                ['h.event_type' => 'move'],
                ['h.event_type' => ['assign', 'unassign']],
            ])
            ->orderBy(['h.changed_at' => SORT_DESC, 'h.id' => SORT_DESC]);

        if ($this->dateFrom) {
            $query->andWhere(['>=', 'h.changed_at', $this->dateFrom . ' 00:00:00']);
        }
        if ($this->dateTo) {
            $query->andWhere(['<=', 'h.changed_at', $this->dateTo . ' 23:59:59']);
        }

        $rows = $query->all();
        if ($rows === []) {
            return [];
        }

        $mergedByUnitAndTime = [];
        foreach ($rows as $row) {
            $old = is_array($row->old_value) ? $row->old_value : [];
            $new = is_array($row->new_value) ? $row->new_value : [];

            $fromLocation = $this->extractLocationName($old, '');
            $toLocation = $this->extractLocationName($new, '');
            $fromResponsible = $this->extractResponsibleName($old, '');
            $toResponsible = $this->extractResponsibleName($new, '');

            $locationChanged = $fromLocation !== $toLocation;
            $responsibleChanged = $fromResponsible !== $toResponsible;
            if (!$locationChanged && !$responsibleChanged) {
                continue;
            }

            $ts = strtotime((string) $row->changed_at);
            $dateTimeKey = $ts !== false ? date('Y-m-d H:i:s', $ts) : '';
            if ($dateTimeKey === '') {
                continue;
            }

            $equipmentId = (int) $row->equipment_id;
            $unitKey = $dateTimeKey . '|' . $equipmentId;
            if (!isset($mergedByUnitAndTime[$unitKey])) {
                $mergedByUnitAndTime[$unitKey] = [
                    'date_key' => $dateTimeKey,
                    'moved_at' => date('d.m.Y H:i:s', $ts),
                    'equipment_id' => $equipmentId,
                    'from_location' => '',
                    'to_location' => '',
                    'from_responsible' => '',
                    'to_responsible' => '',
                    'example' => '',
                ];
            }

            if ($locationChanged) {
                $mergedByUnitAndTime[$unitKey]['from_location'] = $fromLocation;
                $mergedByUnitAndTime[$unitKey]['to_location'] = $toLocation;
            }
            if ($responsibleChanged) {
                $mergedByUnitAndTime[$unitKey]['from_responsible'] = $fromResponsible;
                $mergedByUnitAndTime[$unitKey]['to_responsible'] = $toResponsible;
            }

            if ($equipmentId > 0) {
                $mergedByUnitAndTime[$unitKey]['equipment_id'] = $equipmentId;
            }
            if ($row->equipment) {
                $equipmentName = trim((string) ($row->equipment->name ?? ''));
                $inventoryNumber = trim((string) ($row->equipment->inventory_number ?? ''));
                $example = trim($equipmentName . ' ' . $inventoryNumber);
                if ($example !== '') {
                    $mergedByUnitAndTime[$unitKey]['example'] = $example;
                }
            }
        }

        $buckets = [];
        foreach ($mergedByUnitAndTime as $unit) {
            $bucketKey = $unit['date_key']
                . '|' . $unit['from_location'] . '|' . $unit['to_location']
                . '|' . $unit['from_responsible'] . '|' . $unit['to_responsible'];
            if (!isset($buckets[$bucketKey])) {
                $buckets[$bucketKey] = [
                    'date_key' => $unit['date_key'],
                    'moved_at' => $unit['moved_at'],
                    'from_location' => $unit['from_location'],
                    'to_location' => $unit['to_location'],
                    'from_responsible' => $unit['from_responsible'],
                    'to_responsible' => $unit['to_responsible'],
                    'moves_count' => 0,
                    'equipment_ids' => [],
                    'examples' => [],
                    'example_links' => [],
                ];
            }

            $buckets[$bucketKey]['moves_count']++;
            $equipmentId = (int) ($unit['equipment_id'] ?? 0);
            if ($equipmentId > 0) {
                $buckets[$bucketKey]['equipment_ids'][$equipmentId] = true;
            }
            $example = trim((string) ($unit['example'] ?? ''));
            if ($example !== '' && count($buckets[$bucketKey]['examples']) < 5) {
                $buckets[$bucketKey]['examples'][] = $example;
                if ($equipmentId > 0) {
                    $buckets[$bucketKey]['example_links'][] = [
                        'id' => $equipmentId,
                        'label' => $example,
                    ];
                }
            }
        }

        $result = [];
        foreach ($buckets as $bucket) {
            $units = count($bucket['equipment_ids']);
            $result[] = [
                'date_key' => $bucket['date_key'],
                'moved_at' => $bucket['moved_at'],
                'from_location' => $bucket['from_location'],
                'to_location' => $bucket['to_location'],
                'from_responsible' => $bucket['from_responsible'],
                'to_responsible' => $bucket['to_responsible'],
                'moves_count' => (int) $bucket['moves_count'],
                'moved_units' => $units,
                'examples' => implode("\n", array_filter($bucket['examples'])),
                'example_links' => $bucket['example_links'],
            ];
        }

        usort($result, static function (array $a, array $b): int {
            return strcmp($b['date_key'], $a['date_key'])
                ?: ($b['moved_units'] <=> $a['moved_units'])
                ?: ($b['moves_count'] <=> $a['moves_count']);
        });

        $rowNum = 1;
        foreach ($result as &$row) {
            $row['row_num'] = $rowNum++;
        }
        unset($row);

        return $result;
    }

    /**
     * @param array<int, array<string, mixed>> $movements
     * @return array<string, mixed>
     */
    private function buildEquipmentMovementSummary(array $movements): array
    {
        if ($movements === []) {
            return [
                'routes' => 0,
                'units' => 0,
                'moves' => 0,
            ];
        }

        $units = 0;
        $moves = 0;
        foreach ($movements as $row) {
            $units += (int) ($row['moved_units'] ?? 0);
            $moves += (int) ($row['moves_count'] ?? 0);
        }

        return [
            'routes' => count($movements),
            'units' => $units,
            'moves' => $moves,
        ];
    }

    private function extractLocationName(array $payload, string $default): string
    {
        $name = trim((string) ($payload['location_name'] ?? ''));
        if ($name !== '') {
            return $name;
        }

        $id = isset($payload['location_id']) ? (int) $payload['location_id'] : 0;
        if ($id > 0) {
            return 'ID ' . $id;
        }

        return $default;
    }

    private function extractResponsibleName(array $payload, string $default): string
    {
        $name = trim((string) ($payload['responsible_user_name'] ?? ''));
        if ($name !== '') {
            return $name;
        }

        $id = isset($payload['responsible_user_id']) ? (int) $payload['responsible_user_id'] : 0;
        if ($id > 0) {
            return 'ID ' . $id;
        }

        return $default;
    }
}
