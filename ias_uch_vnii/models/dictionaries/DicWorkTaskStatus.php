<?php

namespace app\models\dictionaries;

use app\models\entities\WorkTask;
use yii\db\ActiveRecord;

/**
 * Статусы внутренних задач (модуль «Задачи»).
 *
 * @property int $id
 * @property string $status_code
 * @property string $status_name
 * @property int $sort_order
 * @property int $timeline_step
 * @property bool $is_final
 * @property bool $is_archived
 */
class DicWorkTaskStatus extends ActiveRecord
{
    public const CODE_QUEUE = 'queue';
    public const CODE_ASSIGNED = 'assigned';
    public const CODE_IN_PROGRESS = 'in_progress';
    public const CODE_PENDING_REVIEW = 'pending_review';
    public const CODE_DONE = 'done';
    public const CODE_CANCELLED = 'cancelled';

    /** Шаги таймлайна (без «Отменена»). */
    public const TIMELINE_CODES = [
        self::CODE_QUEUE,
        self::CODE_ASSIGNED,
        self::CODE_IN_PROGRESS,
        self::CODE_PENDING_REVIEW,
        self::CODE_DONE,
    ];

    /** Актуальные подписи статусов (источник для UI и синхронизации с БД). */
    public const CANONICAL_NAMES = [
        self::CODE_QUEUE => 'Очередь',
        self::CODE_ASSIGNED => 'Назначена',
        self::CODE_IN_PROGRESS => 'В работе',
        self::CODE_PENDING_REVIEW => 'Выполнена',
        self::CODE_DONE => 'Закрыта',
        self::CODE_CANCELLED => 'Отменена',
    ];

    public static function tableName()
    {
        return 'dic_work_task_status';
    }

    public function getDisplayName(): string
    {
        return self::CANONICAL_NAMES[$this->status_code] ?? $this->status_name;
    }

    /**
     * Приводит status_name в справочнике к каноническим значениям (если миграция не выполнялась).
     */
    public static function syncCanonicalLabels(): void
    {
        static $synced = false;
        if ($synced) {
            return;
        }
        $synced = true;

        foreach (self::CANONICAL_NAMES as $code => $name) {
            static::updateAll(
                ['status_name' => $name],
                ['and', ['status_code' => $code], ['<>', 'status_name', $name]]
            );
        }
    }

    public static function getStatusList(): array
    {
        $list = [];
        foreach (static::find()
            ->where(['is_archived' => false])
            ->orderBy(['sort_order' => SORT_ASC])
            ->all() as $row) {
            $list[(int) $row->id] = $row->getDisplayName();
        }

        return $list;
    }

    public static function resolveIdByCode(string $code): ?int
    {
        $id = static::find()
            ->select('id')
            ->where(['status_code' => $code, 'is_archived' => false])
            ->scalar();

        return $id !== false ? (int) $id : null;
    }

    public static function findByCode(string $code): ?self
    {
        return static::findOne(['status_code' => $code, 'is_archived' => false]);
    }

    /**
     * @return array<int, array{code: string, name: string, step: int}>
     */
    public static function getTimelineSteps(): array
    {
        static::syncCanonicalLabels();

        $rows = static::find()
            ->where(['status_code' => self::TIMELINE_CODES, 'is_archived' => false])
            ->orderBy(['timeline_step' => SORT_ASC])
            ->all();

        $out = [];
        foreach ($rows as $row) {
            $out[] = [
                'code' => $row->status_code,
                'name' => $row->getDisplayName(),
                'step' => (int) $row->timeline_step,
                'id' => (int) $row->id,
            ];
        }

        return $out;
    }
}
