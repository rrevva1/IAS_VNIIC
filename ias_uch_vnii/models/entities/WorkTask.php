<?php

namespace app\models\entities;

use app\models\dictionaries\DicWorkTaskStatus;
use Yii;
use yii\behaviors\TimestampBehavior;
use yii\db\ActiveRecord;
use yii\db\Expression;
use yii\web\UploadedFile;

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
 * @property Users[] $executors
 * @property WorkTaskExecutor[] $executorAssignments
 * @property string $priority
 * @property string|null $submitted_at
 * @property string|null $confirmed_at
 * @property int|null $confirmed_by
 * @property bool $is_deleted
 * @property string $created_at
 * @property string $updated_at
 * @property string $status_changed_at
 * @property DeskAttachments[] $taskAttachments через work_task_attachments
 */
class WorkTask extends ActiveRecord
{
    /** @var UploadedFile[]|null */
    public $uploadFiles;

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
            [['uploadFiles'], 'file', 'skipOnEmpty' => true, 'extensions' => 'png, jpg, jpeg, gif, pdf, doc, docx, xls, xlsx, txt', 'maxFiles' => 10],
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
            'executor_ids' => 'Исполнители',
            'priority' => 'Приоритет',
            'created_at' => 'Создана',
            'updated_at' => 'Обновлена',
            'status_changed_at' => 'В колонке с',
            'uploadFiles' => 'Файлы',
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

    /**
     * Телефон для обратной связи из связанной заявки.
     */
    public function getRequestContactPhone(): ?string
    {
        if (!$this->isLinkedToRequest()) {
            return null;
        }

        if ($this->isRelationPopulated('requestTask') && $this->requestTask !== null) {
            $phone = trim((string) $this->requestTask->contact_phone);

            return $phone !== '' ? $phone : null;
        }

        $request = Tasks::findOne((int) $this->request_task_id);
        if ($request === null) {
            return null;
        }

        $phone = trim((string) $request->contact_phone);

        return $phone !== '' ? $phone : null;
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

    public function getExecutorAssignments()
    {
        return $this->hasMany(WorkTaskExecutor::class, ['work_task_id' => 'id'])
            ->orderBy(['id' => SORT_ASC]);
    }

    public function getExecutors()
    {
        return $this->hasMany(Users::class, ['id' => 'user_id'])
            ->via('executorAssignments');
    }

    public function getExecutor()
    {
        return $this->hasOne(Users::class, ['id' => 'executor_id']);
    }

    /**
     * @return int[]
     */
    public function getExecutorIds(): array
    {
        if ($this->isRelationPopulated('executors')) {
            $ids = [];
            foreach ($this->executors as $user) {
                $ids[] = (int) $user->id;
            }

            return $ids;
        }

        if ($this->isRelationPopulated('executorAssignments')) {
            $ids = [];
            foreach ($this->executorAssignments as $row) {
                $ids[] = (int) $row->user_id;
            }

            return $ids;
        }

        if (!$this->id) {
            return $this->executor_id ? [(int) $this->executor_id] : [];
        }

        $ids = array_map('intval', WorkTaskExecutor::find()
            ->select('user_id')
            ->where(['work_task_id' => (int) $this->id])
            ->orderBy(['id' => SORT_ASC])
            ->column());

        if ($ids === [] && $this->executor_id) {
            return [(int) $this->executor_id];
        }

        return $ids;
    }

    public function hasExecutor(): bool
    {
        return $this->getExecutorIds() !== [];
    }

    public function isExecutorUser(int $userId): bool
    {
        return in_array($userId, $this->getExecutorIds(), true);
    }

    /**
     * @return string[]
     */
    public function getExecutorNames(): array
    {
        if ($this->isRelationPopulated('executors')) {
            $names = [];
            foreach ($this->executors as $user) {
                $name = trim((string) $user->full_name);
                if ($name !== '') {
                    $names[] = $name;
                }
            }

            return $names;
        }

        $ids = $this->getExecutorIds();
        if ($ids === []) {
            return [];
        }

        $rows = Users::find()
            ->select(['id', 'full_name'])
            ->where(['id' => $ids])
            ->indexBy('id')
            ->all();

        $names = [];
        foreach ($ids as $id) {
            if (!isset($rows[$id])) {
                continue;
            }
            $name = trim((string) $rows[$id]->full_name);
            if ($name !== '') {
                $names[] = $name;
            }
        }

        return $names;
    }

    public function getExecutorName(): string
    {
        $names = $this->getExecutorNames();

        return $names !== [] ? implode(', ', $names) : '—';
    }

    public function getExecutorNamesString(): string
    {
        return $this->getExecutorName();
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

    /**
     * Вложения через таблицу work_task_attachments.
     */
    public function getTaskAttachments()
    {
        return $this->hasMany(DeskAttachments::class, ['id' => 'attachment_id'])
            ->viaTable('work_task_attachments', ['work_task_id' => 'id']);
    }

    public function getAllAttachments(): array
    {
        return $this->getTaskAttachments()->all();
    }

    public function addAttachment(int $attachmentId): void
    {
        if ($attachmentId <= 0 || !$this->id) {
            return;
        }
        $exists = WorkTaskAttachments::find()
            ->where(['work_task_id' => $this->id, 'attachment_id' => $attachmentId])
            ->exists();
        if ($exists) {
            return;
        }
        $link = new WorkTaskAttachments();
        $link->work_task_id = (int) $this->id;
        $link->attachment_id = $attachmentId;
        $link->linked_by = Yii::$app->user->isGuest ? null : (int) Yii::$app->user->id;
        $link->linked_at = date('Y-m-d H:i:s');
        $link->save(false);
    }

    /**
     * Сохраняет выбранные в форме файлы и привязывает к задаче.
     */
    public function persistUploadFiles(): bool
    {
        if (empty($this->uploadFiles) || !is_array($this->uploadFiles)) {
            return true;
        }

        DeskAttachments::ensureUploadDirectory('work_tasks');

        foreach ($this->uploadFiles as $file) {
            if (!$file instanceof UploadedFile) {
                continue;
            }
            $fileName = time() . '_' . uniqid() . '_' . $file->baseName . '.' . $file->extension;
            $relativePath = DeskAttachments::buildStoragePath('work_tasks', $fileName);
            $fullPath = DeskAttachments::resolveStoragePath($relativePath);
            if (!$file->saveAs($fullPath)) {
                continue;
            }
            $att = new DeskAttachments();
            $att->storage_path = $relativePath;
            $att->original_name = $file->baseName . '.' . $file->extension;
            $att->file_extension = $file->extension;
            $att->mime_type = $file->type;
            $att->size_bytes = (int) $file->size;
            $att->uploaded_by = Yii::$app->user->isGuest ? null : (int) Yii::$app->user->id;
            $att->uploaded_at = date('Y-m-d H:i:s');
            if ($att->save(false)) {
                $this->addAttachment((int) $att->id);
            }
        }

        return true;
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
        if (!$this->showsTimeInColumn()) {
            return '';
        }

        return self::formatDuration($this->getTimeInStatusSeconds());
    }

    public function getTimeInStatusTitle(): string
    {
        if (!$this->showsTimeInColumn()) {
            return '';
        }

        $statusName = $this->status ? $this->status->getDisplayName() : 'статусе';
        $since = Yii::$app->formatter->asDatetime(
            $this->status_changed_at ?: $this->created_at,
            'php:d.m.Y, H:i'
        );

        return 'В колонке «' . $statusName . '» с ' . $since;
    }

    /**
     * Для активных статусов показывается длительность в колонке; для выполненных/закрытых — дата события.
     */
    public function showsTimeInColumn(): bool
    {
        return $this->getCompletionEventMeta() === null;
    }

    /**
     * @return array{label: string, at: string|null}|null
     */
    public function getCompletionEventMeta(): ?array
    {
        $code = $this->getStatusCode();

        if ($code === DicWorkTaskStatus::CODE_PENDING_REVIEW) {
            return [
                'label' => 'Выполнена',
                'at' => $this->submitted_at ?: $this->status_changed_at ?: $this->updated_at,
            ];
        }
        if ($code === DicWorkTaskStatus::CODE_DONE) {
            return [
                'label' => 'Закрыта',
                'at' => $this->confirmed_at ?: $this->status_changed_at ?: $this->updated_at,
            ];
        }
        if ($code === DicWorkTaskStatus::CODE_CANCELLED) {
            return [
                'label' => 'Отменена',
                'at' => $this->status_changed_at ?: $this->updated_at,
            ];
        }

        return null;
    }

    /**
     * Подпись времени на карточке канбана: таймер в работе или дата завершения/закрытия.
     *
     * @return array{label: string, title: string, is_completion: bool}
     */
    public function getCardTimeMeta(): array
    {
        $event = $this->getCompletionEventMeta();
        if ($event !== null) {
            $at = $event['at'] ?? null;
            if ($at !== null && trim((string) $at) !== '') {
                return $this->buildCardCompletionMeta((string) $at, $event['label']);
            }

            return [
                'label' => '—',
                'title' => $event['label'],
                'is_completion' => true,
            ];
        }

        return [
            'label' => $this->getTimeInStatusLabel(),
            'title' => $this->getTimeInStatusTitle(),
            'is_completion' => false,
        ];
    }

    /**
     * @return array{label: string, title: string, is_completion: bool}
     */
    private function buildCardCompletionMeta(string $at, string $eventLabel): array
    {
        $formatted = Yii::$app->formatter->asDatetime($at, 'php:d.m.Y, H:i');

        return [
            'label' => $formatted,
            'title' => $eventLabel . ': ' . $formatted,
            'is_completion' => true,
        ];
    }

    /**
     * Хронология для списка закрытых задач (от старых событий к новым).
     *
     * @return array<int, array{at: string, time: string, title: string, note: string|null, user: string|null}>
     */
    public function getHistoryTimelineEntries(int $limit = 10): array
    {
        $eventLabels = [
            'created' => 'Создание',
            'created_from_request' => 'Создание по заявке',
            'assign_executor' => 'Назначение исполнителя',
            'status_change' => 'Смена статуса',
            'comment' => 'Комментарий',
            'deleted' => 'Удаление',
        ];

        if ($this->isRelationPopulated('history')) {
            $rows = array_values($this->history);
            usort($rows, static function (WorkTaskHistory $a, WorkTaskHistory $b): int {
                $cmp = strcmp((string) $a->changed_at, (string) $b->changed_at);
                if ($cmp !== 0) {
                    return $cmp;
                }

                return $a->id <=> $b->id;
            });
            if (count($rows) > $limit) {
                $rows = array_slice($rows, -$limit);
            }
        } else {
            $rows = $this->getHistory()
                ->with(['changedByUser', 'oldStatus', 'newStatus'])
                ->orderBy(['changed_at' => SORT_ASC, 'id' => SORT_ASC])
                ->limit($limit)
                ->all();
        }

        $entries = [];
        foreach ($rows as $row) {
            if (!$row instanceof WorkTaskHistory) {
                continue;
            }

            $note = null;
            if ($row->event_type === 'status_change') {
                if ($row->oldStatus && $row->newStatus) {
                    $note = $row->oldStatus->getDisplayName() . ' → ' . $row->newStatus->getDisplayName();
                } elseif ($row->newStatus) {
                    $note = $row->newStatus->getDisplayName();
                }
            } elseif ($row->event_type === 'comment' && trim((string) $row->comment) !== '') {
                $text = trim((string) $row->comment);
                $note = mb_strlen($text) > 100 ? mb_substr($text, 0, 100) . '…' : $text;
            }

            $userName = null;
            if ($row->changedByUser) {
                $name = trim((string) $row->changedByUser->full_name);
                $userName = $name !== '' ? $name : null;
            }

            $entries[] = [
                'at' => (string) $row->changed_at,
                'time' => Yii::$app->formatter->asDatetime($row->changed_at, 'php:d.m.Y, H:i'),
                'title' => $eventLabels[$row->event_type] ?? $row->event_type,
                'note' => $note,
                'user' => $userName,
            ];
        }

        return $entries;
    }
}
