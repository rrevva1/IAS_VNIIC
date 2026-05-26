<?php

namespace app\models\entities;

use app\models\dictionaries\DicWorkTaskStatus;
use Yii;
use yii\behaviors\TimestampBehavior;
use yii\db\ActiveRecord;
use yii\db\Expression;

/**
 * Внутренняя задача (назначение исполнителю).
 *
 * @property int $id
 * @property string $title
 * @property string $description
 * @property int $status_id
 * @property int|null $request_task_id
 * @property int $creator_id
 * @property int|null $executor_id
 * @property string $priority
 * @property string|null $submitted_at
 * @property string|null $confirmed_at
 * @property int|null $confirmed_by
 * @property bool $is_deleted
 * @property string $created_at
 * @property string $updated_at
 * @property string $status_changed_at
 */
class WorkTask extends ActiveRecord
{
    public static function tableName()
    {
        return 'work_tasks';
    }

    public function behaviors()
    {
        return [
            [
                'class' => TimestampBehavior::class,
                'createdAtAttribute' => 'created_at',
                'updatedAtAttribute' => 'updated_at',
                'value' => new Expression('CURRENT_TIMESTAMP'),
            ],
        ];
    }

    public function rules()
    {
        return [
            [['title', 'description', 'status_id', 'creator_id'], 'required'],
            [['description'], 'string'],
            [['status_id', 'request_task_id', 'creator_id', 'executor_id', 'confirmed_by'], 'integer'],
            [['title'], 'string', 'max' => 250],
            [['priority'], 'in', 'range' => ['low', 'medium', 'high', 'critical']],
            [['submitted_at', 'confirmed_at', 'status_changed_at', 'created_at', 'updated_at'], 'safe'],
            [['is_deleted'], 'boolean'],
            [['status_id'], 'exist', 'targetClass' => DicWorkTaskStatus::class, 'targetAttribute' => ['status_id' => 'id']],
            [['request_task_id'], 'exist', 'targetClass' => Tasks::class, 'targetAttribute' => ['request_task_id' => 'id'], 'skipOnEmpty' => true],
            [['creator_id'], 'exist', 'targetClass' => Users::class, 'targetAttribute' => ['creator_id' => 'id']],
            [['executor_id'], 'exist', 'targetClass' => Users::class, 'targetAttribute' => ['executor_id' => 'id'], 'skipOnEmpty' => true],
            [['confirmed_by'], 'exist', 'targetClass' => Users::class, 'targetAttribute' => ['confirmed_by' => 'id'], 'skipOnEmpty' => true],
        ];
    }

    public function attributeLabels()
    {
        return [
            'id' => '№',
            'title' => 'Название',
            'description' => 'Описание',
            'status_id' => 'Статус',
            'request_task_id' => 'Заявка',
            'creator_id' => 'Создал',
            'executor_id' => 'Исполнитель',
            'priority' => 'Приоритет',
            'created_at' => 'Создана',
            'updated_at' => 'Обновлена',
            'status_changed_at' => 'В колонке с',
        ];
    }

    public function getStatus()
    {
        return $this->hasOne(DicWorkTaskStatus::class, ['id' => 'status_id']);
    }

    public function getRequestTask()
    {
        return $this->hasOne(Tasks::class, ['id' => 'request_task_id']);
    }

    public function getCreator()
    {
        return $this->hasOne(Users::class, ['id' => 'creator_id']);
    }

    /**
     * Автор связанной заявки (для задач, созданных по заявке Help Desk).
     */
    public function getRequestAuthor(): ?Users
    {
        if (!$this->request_task_id) {
            return null;
        }

        if ($this->isRelationPopulated('requestTask') && $this->requestTask !== null) {
            if ($this->requestTask->isRelationPopulated('requester') && $this->requestTask->requester !== null) {
                return $this->requestTask->requester;
            }
            if ((int) $this->requestTask->requester_id > 0) {
                return Users::findOne((int) $this->requestTask->requester_id);
            }
        }

        if ($this->isRelationPopulated('creator') && $this->creator !== null) {
            return $this->creator;
        }

        return $this->creator_id ? Users::findOne((int) $this->creator_id) : null;
    }

    public function getRequestAuthorName(): string
    {
        $author = $this->getRequestAuthor();
        $name = $author ? trim((string) $author->full_name) : '';

        return $name !== '' ? $name : '—';
    }

    public function isLinkedToRequest(): bool
    {
        return $this->request_task_id !== null && (int) $this->request_task_id > 0;
    }

    public function getAuthorLabel(): string
    {
        return $this->isLinkedToRequest() ? 'Автор заявки' : 'Автор';
    }

    public function getAuthorName(): string
    {
        if ($this->isLinkedToRequest()) {
            return $this->getRequestAuthorName();
        }

        if ($this->isRelationPopulated('creator') && $this->creator !== null) {
            $name = trim((string) $this->creator->full_name);

            return $name !== '' ? $name : '—';
        }

        if ($this->creator_id) {
            $creator = Users::findOne((int) $this->creator_id);
            if ($creator !== null) {
                $name = trim((string) $creator->full_name);

                return $name !== '' ? $name : '—';
            }
        }

        return '—';
    }

    public function getExecutorName(): string
    {
        if ($this->isRelationPopulated('executor') && $this->executor !== null) {
            $name = trim((string) $this->executor->full_name);

            return $name !== '' ? $name : '—';
        }

        if ($this->executor_id) {
            $executor = Users::findOne((int) $this->executor_id);
            if ($executor !== null) {
                $name = trim((string) $executor->full_name);

                return $name !== '' ? $name : '—';
            }
        }

        return '—';
    }

    public function hasExecutor(): bool
    {
        return $this->executor_id !== null && (int) $this->executor_id > 0;
    }

    public function getExecutor()
    {
        return $this->hasOne(Users::class, ['id' => 'executor_id']);
    }

    public function getConfirmedByUser()
    {
        return $this->hasOne(Users::class, ['id' => 'confirmed_by']);
    }

    public function getHistory()
    {
        return $this->hasMany(WorkTaskHistory::class, ['work_task_id' => 'id'])
            ->orderBy(['changed_at' => SORT_DESC, 'id' => SORT_DESC]);
    }

    public function getComments()
    {
        return $this->hasMany(WorkTaskComment::class, ['work_task_id' => 'id'])
            ->orderBy(['created_at' => SORT_ASC, 'id' => SORT_ASC]);
    }

    public function getStatusCode(): string
    {
        if (!$this->status_id) {
            return '';
        }

        if ($this->isRelationPopulated('status')
            && $this->status !== null
            && (int) $this->status->id === (int) $this->status_id
        ) {
            return (string) $this->status->status_code;
        }

        $code = DicWorkTaskStatus::find()
            ->select('status_code')
            ->where(['id' => (int) $this->status_id])
            ->scalar();

        return $code !== false ? (string) $code : '';
    }

    public function isFinal(): bool
    {
        return $this->status && (bool) $this->status->is_final;
    }

    public function getStatusChangedAtTimestamp(): int
    {
        $raw = $this->status_changed_at ?: $this->created_at;

        return $raw ? (int) strtotime((string) $raw) : time();
    }

    public function getTimeInStatusSeconds(): int
    {
        return max(0, time() - $this->getStatusChangedAtTimestamp());
    }

    public static function formatDuration(int $seconds): string
    {
        if ($seconds < 60) {
            return $seconds . ' сек';
        }
        if ($seconds < 3600) {
            $minutes = (int) floor($seconds / 60);

            return $minutes . ' мин';
        }
        if ($seconds < 86400) {
            $hours = (int) floor($seconds / 3600);
            $minutes = (int) floor(($seconds % 3600) / 60);

            return $minutes > 0 ? $hours . ' ч ' . $minutes . ' мин' : $hours . ' ч';
        }

        $days = (int) floor($seconds / 86400);
        $hours = (int) floor(($seconds % 86400) / 3600);

        return $hours > 0 ? $days . ' дн ' . $hours . ' ч' : $days . ' дн';
    }

    public function getTimeInStatusLabel(): string
    {
        return self::formatDuration($this->getTimeInStatusSeconds());
    }

    public function getTimeInStatusTitle(): string
    {
        $statusName = $this->status ? $this->status->getDisplayName() : 'статусе';
        $since = Yii::$app->formatter->asDatetime(
            $this->status_changed_at ?: $this->created_at,
            'php:d.m.Y, H:i'
        );

        return 'В колонке «' . $statusName . '» с ' . $since;
    }
}
