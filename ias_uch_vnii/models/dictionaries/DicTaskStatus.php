<?php

namespace app\models\dictionaries;

use app\models\entities\Tasks;
use Yii;
use yii\helpers\Html;

/**
 * Модель для таблицы "dic_task_status" (схема tech_accounting).
 *
 * @property int $id
 * @property string $status_code
 * @property string $status_name
 * @property int $sort_order
 * @property bool $is_final
 * @property bool $is_archived
 *
 * @property Tasks[] $tasks
 */
class DicTaskStatus extends \yii\db\ActiveRecord
{
    public const CODE_NEW = 'new';
    public const CODE_EXECUTOR_ASSIGNED = 'executor_assigned';
    public const CODE_IN_PROGRESS = 'in_progress';
    public const CODE_ON_HOLD = 'on_hold';
    public const CODE_RESOLVED = 'resolved';
    public const CODE_CLOSED = 'closed';
    public const CODE_CANCELLED = 'cancelled';

    /** Статусы для вкладок фильтра на странице «Заявки» (без «На паузе», «Закрыта» и пр.). */
    public const INDEX_TAB_STATUS_CODES = [
        self::CODE_NEW,
        self::CODE_EXECUTOR_ASSIGNED,
        self::CODE_IN_PROGRESS,
        self::CODE_RESOLVED,
    ];

    public static function tableName()
    {
        return 'dic_task_status';
    }

    public function rules()
    {
        return [
            [['status_code', 'status_name'], 'required'],
            [['status_code'], 'string', 'max' => 50],
            [['status_name'], 'string', 'max' => 100],
            [['sort_order'], 'integer'],
            [['is_final', 'is_archived'], 'boolean'],
            [['status_code'], 'unique'],
        ];
    }

    public function attributeLabels()
    {
        return [
            'id' => 'ID',
            'status_code' => 'Код',
            'status_name' => 'Название статуса',
        ];
    }

    public function getTasks()
    {
        return $this->hasMany(Tasks::class, ['status_id' => 'id']);
    }

    /**
     * Список статусов для выпадающего списка [id => status_name].
     */
    public static function getStatusList()
    {
        return static::find()
            ->select(['status_name', 'id'])
            ->indexBy('id')
            ->column();
    }

    /**
     * Статусы для вкладок фильтра на index заявок.
     *
     * @return static[]
     */
    public static function getIndexTabStatuses(): array
    {
        if (self::INDEX_TAB_STATUS_CODES === []) {
            return [];
        }

        return static::find()
            ->where(['is_archived' => false, 'status_code' => self::INDEX_TAB_STATUS_CODES])
            ->orderBy(['sort_order' => SORT_ASC, 'id' => SORT_ASC])
            ->all();
    }

    /**
     * Коды статусов для SQL-фильтра по выбранной вкладке.
     *
     * @return string[]
     */
    public static function getCodesForIndexTabFilter(string $tabCode): array
    {
        $tabCode = trim($tabCode);
        if ($tabCode === '') {
            return [];
        }

        if ($tabCode === self::CODE_RESOLVED) {
            return [self::CODE_RESOLVED, self::CODE_CLOSED];
        }

        return [$tabCode];
    }

    /**
     * ID статусов для фильтра вкладки.
     *
     * @return int[]
     */
    public static function resolveIdsForIndexTabFilter(string $tabCode): array
    {
        $codes = self::getCodesForIndexTabFilter($tabCode);
        if ($codes === []) {
            return [];
        }

        return array_map('intval', static::find()
            ->select('id')
            ->where(['status_code' => $codes, 'is_archived' => false])
            ->column());
    }

    /**
     * ID статуса по умолчанию (например, «Новая»).
     */
    public static function getDefaultStatusId()
    {
        $status = static::find()->orderBy(['sort_order' => SORT_ASC])->one();
        return $status ? (int) $status->id : null;
    }

    public static function resolveIdByCode(string $code): ?int
    {
        $id = static::find()
            ->select('id')
            ->where(['status_code' => $code, 'is_archived' => false])
            ->scalar();

        return $id !== false ? (int) $id : null;
    }

    public static function getExecutorAssignedStatusId(): ?int
    {
        $id = static::resolveIdByCode(self::CODE_EXECUTOR_ASSIGNED);
        if ($id !== null) {
            return $id;
        }

        $id = static::find()
            ->select('id')
            ->where(['status_name' => 'Назначен исполнитель', 'is_archived' => false])
            ->scalar();

        return $id !== false ? (int) $id : null;
    }

    /**
     * Гарантирует наличие статусов заявок для синхронизации с колонками внутренних задач.
     */
    public static function ensureRequestSyncStatuses(): void
    {
        static $ensured = false;
        if ($ensured) {
            return;
        }
        $ensured = true;

        $model = static::findOne(['status_code' => self::CODE_EXECUTOR_ASSIGNED]);
        if ($model === null) {
            $model = new static();
            $model->status_code = self::CODE_EXECUTOR_ASSIGNED;
            $model->status_name = 'Назначен исполнитель';
            $model->sort_order = 15;
            $model->is_final = false;
            $model->is_archived = false;
            $model->save(false);
        } elseif ($model->status_name !== 'Назначен исполнитель') {
            $model->status_name = 'Назначен исполнитель';
            $model->save(false);
        }

        static::updateAll(
            ['status_name' => 'Выполнена'],
            ['and', ['status_code' => self::CODE_RESOLVED], ['<>', 'status_name', 'Выполнена']]
        );
    }

    /** Статус заявки «Выполнена» (колонки «Выполнена» / «Закрыта» внутренней задачи). */
    /**
     * ID статусов «выполнена» (resolved, closed).
     *
     * @return int[]
     */
    public static function getCompletedStatusIds(): array
    {
        return array_map('intval', static::find()
            ->select('id')
            ->where([
                'status_code' => [self::CODE_RESOLVED, self::CODE_CLOSED],
                'is_archived' => false,
            ])
            ->column());
    }

    public static function isCompletedStatusId(int $statusId): bool
    {
        return in_array($statusId, self::getCompletedStatusIds(), true);
    }

    public static function getCompletedStatusId(): ?int
    {
        $id = static::find()
            ->select('id')
            ->where(['status_name' => 'Выполнена', 'is_archived' => false])
            ->scalar();
        if ($id !== false) {
            return (int) $id;
        }

        return static::getResolvedStatusId();
    }

    /** @deprecated Используйте getCompletedStatusId() */
    public static function getResolvedStatusId(): ?int
    {
        return static::resolveIdByCode(self::CODE_RESOLVED)
            ?? static::resolveIdByCode(self::CODE_CLOSED);
    }

    /**
     * CSS-модификатор бейджа статуса (согласован с AG Grid и tasks-status-pill).
     */
    public static function getPillClassForCode(?string $statusCode): string
    {
        $map = [
            self::CODE_NEW => 'tasks-status-pill--new',
            self::CODE_EXECUTOR_ASSIGNED => 'tasks-status-pill--assigned',
            self::CODE_IN_PROGRESS => 'tasks-status-pill--progress',
            self::CODE_ON_HOLD => 'tasks-status-pill--hold',
            self::CODE_RESOLVED => 'tasks-status-pill--done',
            self::CODE_CLOSED => 'tasks-status-pill--done',
            self::CODE_CANCELLED => 'tasks-status-pill--cancelled',
        ];

        return $map[$statusCode] ?? 'tasks-status-pill--default';
    }

    /**
     * HTML бейджа статуса для карточки заявки.
     */
    public static function renderStatusPill(?string $statusCode, ?string $statusName): string
    {
        if ($statusName === null || trim($statusName) === '') {
            return '<span class="text-muted">—</span>';
        }

        return Html::tag('span', Html::encode($statusName), [
            'class' => 'tasks-status-pill ' . static::getPillClassForCode($statusCode),
            'data-status-code' => $statusCode !== null && $statusCode !== '' ? $statusCode : null,
        ]);
    }
}
