<?php

namespace app\components;

use app\models\dictionaries\DicTaskStatus;
use app\models\entities\TaskHistory;
use app\models\entities\Tasks;
use app\models\entities\Users;
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

    public function buildReport(): array
    {
        $tasks = $this->loadTasksInPeriod();
        $this->preloadCompletionTimestamps($tasks);

        $summary = $this->buildSummary($tasks);
        $executors = $this->buildExecutorKpi($tasks);
        $statusDistribution = $this->buildStatusDistribution($tasks);
        $monthlyCompleted = $this->buildMonthlyCompleted($tasks);
        $requesters = $this->buildRequesterStats($tasks);

        return [
            'period' => [
                'from' => $this->dateFrom,
                'to' => $this->dateTo,
                'label' => $this->getPeriodLabel(),
            ],
            'summary' => $summary,
            'executors' => $executors,
            'status_distribution' => $statusDistribution,
            'monthly_completed' => $monthlyCompleted,
            'requesters' => $requesters,
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

        if ($this->dateFrom) {
            $query->andWhere(['>=', 't.created_at', $this->dateFrom . ' 00:00:00']);
        }
        if ($this->dateTo) {
            $query->andWhere(['<=', 't.created_at', $this->dateTo . ' 23:59:59']);
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
     * @param Tasks[] $tasks
     */
    private function buildMonthlyCompleted(array $tasks): array
    {
        $months = [];
        foreach ($tasks as $task) {
            if (!$this->isCompleted($task)) {
                continue;
            }
            $ts = $this->getCompletionTimestamp($task);
            if ($ts === null) {
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
}
