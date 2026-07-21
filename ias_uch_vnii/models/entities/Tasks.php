<?php

namespace app\models\entities;

use app\models\dictionaries\DicTaskStatus;
use Yii;
use yii\behaviors\TimestampBehavior;
use yii\db\ActiveRecord;
use yii\web\UploadedFile;

/**
 * Модель для таблицы "tasks" (схема tech_accounting).
 *
 * @property int $id
 * @property string|null $task_number
 * @property string|null $title
 * @property string $description
 * @property int $status_id
 * @property int $requester_id
 * @property int|null $executor_id
 * @property string $priority
 * @property string|null $due_at
 * @property string|null $closed_at
 * @property string|null $comment
 * @property string|null $contact_phone
 * @property string|null $room_number
 * @property string|null $request_category
 * @property string|null $created_at
 * @property string|null $updated_at
 *
 * @property DicTaskStatus $status
 * @property Users $requester
 * @property Users $executor
 * @property WorkTask|null $linkedWorkTask связанная внутренняя задача
 * @property DeskAttachments[] $taskAttachments через task_attachments
 * @property Equipment[] $equipments через task_equipment
 */
class Tasks extends ActiveRecord
{
    public const CATEGORY_PHONE_DIRECTORY_UPDATE = 'phone_directory_update';
    public const CATEGORY_GENERAL = 'general';

    public $uploadFiles;
    /** @var array ID выбранных активов (для формы) */
    public $equipment_ids = [];

    public static function tableName()
    {
        return 'tasks';
    }

    /**
     * Поддержка contact_phone до применения миграции и после обновления схемы БД.
     *
     * @return string[]
     */
    public function attributes()
    {
        $parent = parent::attributes();
        if (!in_array('contact_phone', $parent, true)) {
            $parent[] = 'contact_phone';
        }
        if (!in_array('room_number', $parent, true)) {
            $parent[] = 'room_number';
        }
        if (!in_array('request_category', $parent, true)) {
            $parent[] = 'request_category';
        }

        return $parent;
    }

    /**
     * @return array<string, string>
     */
    public static function requestCategoryLabels(): array
    {
        return [
            self::CATEGORY_GENERAL => 'Общая заявка',
            self::CATEGORY_PHONE_DIRECTORY_UPDATE => 'Актуализация телефонного справочника',
        ];
    }

    public function behaviors()
    {
        return [
            [
                'class' => TimestampBehavior::class,
                'createdAtAttribute' => 'created_at',
                'updatedAtAttribute' => 'updated_at',
                'value' => new \yii\db\Expression('CURRENT_TIMESTAMP'),
            ],
        ];
    }

    public function rules()
    {
        return [
            [['status_id', 'description', 'requester_id'], 'required', 'message' => 'Заполните поле «{attribute}».'],
            [['status_id', 'requester_id', 'executor_id'], 'integer'],
            [['description', 'comment'], 'string'],
            [['title'], 'string', 'max' => 250],
            [['task_number'], 'string', 'max' => 50],
            [['contact_phone', 'room_number'], 'string', 'max' => 50],
            [['request_category'], 'string', 'max' => 50],
            [['contact_phone', 'room_number', 'request_category'], 'trim'],
            [['contact_phone', 'room_number', 'request_category'], 'default', 'value' => null],
            [['request_category'], 'in', 'range' => array_keys(self::requestCategoryLabels()), 'skipOnEmpty' => true],
            [['request_category'], 'filter', 'filter' => static function ($value) {
                $value = is_string($value) ? trim($value) : $value;
                return $value === '' ? null : $value;
            }],
            [['priority'], 'in', 'range' => ['low', 'medium', 'high', 'critical']],
            [['due_at', 'closed_at', 'created_at', 'updated_at'], 'safe'],
            [['status_id'], 'exist', 'targetClass' => DicTaskStatus::class, 'targetAttribute' => ['status_id' => 'id']],
            [['requester_id'], 'exist', 'targetClass' => Users::class, 'targetAttribute' => ['requester_id' => 'id']],
            [['executor_id'], 'exist', 'targetClass' => Users::class, 'targetAttribute' => ['executor_id' => 'id'], 'skipOnEmpty' => true],
            [['uploadFiles'], 'file', 'skipOnEmpty' => true, 'extensions' => 'png, jpg, jpeg, gif, pdf, doc, docx, xls, xlsx, txt', 'maxFiles' => 10],
            [['equipment_ids'], 'each', 'rule' => ['integer']],
        ];
    }

    public function attributeLabels()
    {
        return [
            'id' => '№ заявки',
            'task_number' => 'Номер',
            'title' => 'Тема',
            'status_id' => 'Статус',
            'description' => 'Описание',
            'requester_id' => 'Автор',
            'executor_id' => 'Исполнитель',
            'priority' => 'Приоритет',
            'due_at' => 'Срок',
            'closed_at' => 'Закрыта',
            'comment' => 'Комментарий исполнителя',
            'contact_phone' => 'Телефон для обратной связи',
            'room_number' => 'Номер помещения',
            'request_category' => 'Категория заявки',
            'created_at' => 'Дата создания',
            'updated_at' => 'Обновлено',
            'uploadFiles' => 'Файлы',
        ];
    }

    public function getStatus()
    {
        return $this->hasOne(DicTaskStatus::class, ['id' => 'status_id']);
    }

    public function getRequester()
    {
        return $this->hasOne(Users::class, ['id' => 'requester_id']);
    }

    public function getExecutor()
    {
        return $this->hasOne(Users::class, ['id' => 'executor_id']);
    }

    /**
     * Внутренняя задача, созданная по этой заявке.
     */
    public function getLinkedWorkTask()
    {
        return $this->hasOne(WorkTask::class, ['request_task_id' => 'id'])
            ->andWhere(['work_tasks.is_deleted' => false]);
    }

    /**
     * Исполнители для отображения: полный список из связанной задачи, иначе один из заявки.
     *
     * @return string[]
     */
    public function getDisplayExecutorNames(): array
    {
        $workTask = $this->linkedWorkTask;
        if ($workTask !== null) {
            $names = $workTask->getExecutorNames();
            if ($names !== []) {
                return $names;
            }
        }

        if ($this->executor_id && $this->executor) {
            $name = trim((string) $this->executor->full_name);
            if ($name !== '') {
                return [$name];
            }
        }

        return [];
    }

    public function getDisplayExecutorNamesString(): string
    {
        $names = $this->getDisplayExecutorNames();

        return $names !== [] ? implode(', ', $names) : '';
    }

    /**
     * Исполнитель зафиксирован — в заявке его менять нельзя (только через «Задачи»).
     */
    public function hasAssignedExecutor(): bool
    {
        return $this->executor_id !== null && (int) $this->executor_id > 0;
    }

    /** Для совместимости с представлениями: автор заявки */
    public function getUser()
    {
        return $this->getRequester();
    }

    /**
     * Вложения через таблицу task_attachments.
     *
     * @return \yii\db\ActiveQuery
     */
    public function getTaskAttachments()
    {
        return $this->hasMany(DeskAttachments::class, ['id' => 'attachment_id'])
            ->viaTable('task_attachments', ['task_id' => 'id']);
    }

    public function getEquipments()
    {
        return $this->hasMany(Equipment::class, ['id' => 'equipment_id'])
            ->viaTable('task_equipment', ['task_id' => 'id']);
    }

    public function getTaskEquipments()
    {
        return $this->hasMany(TaskEquipment::class, ['task_id' => 'id']);
    }

    public function getAttachmentsArray()
    {
        return $this->getTaskAttachments()->select('id')->column();
    }

    public function setAttachmentsArray(array $ids)
    {
        TaskAttachments::deleteAll(['task_id' => $this->id]);
        foreach ($ids as $attachmentId) {
            if ((int) $attachmentId > 0) {
                $ta = new TaskAttachments();
                $ta->task_id = $this->id;
                $ta->attachment_id = (int) $attachmentId;
                $ta->linked_at = date('Y-m-d H:i:s');
                $ta->save(false);
            }
        }
    }

    public function addAttachment($attachmentId)
    {
        if ((int) $attachmentId <= 0 || (int) $this->id <= 0) {
            return;
        }
        $exists = TaskAttachments::find()
            ->where(['task_id' => $this->id, 'attachment_id' => $attachmentId])
            ->exists();
        if (!$exists) {
            $ta = new TaskAttachments();
            $ta->task_id = (int) $this->id;
            $ta->attachment_id = (int) $attachmentId;
            $ta->linked_by = Yii::$app->user->isGuest ? null : (int) Yii::$app->user->id;
            $ta->linked_at = date('Y-m-d H:i:s');
            $ta->save(false);
        }
    }

    public function removeAttachment($attachmentId)
    {
        TaskAttachments::deleteAll(['task_id' => $this->id, 'attachment_id' => $attachmentId]);
    }

    public function getAllAttachments(): array
    {
        if ((int) $this->id <= 0) {
            return [];
        }

        if ($this->isRelationPopulated('taskAttachments')) {
            return $this->taskAttachments;
        }

        return DeskAttachments::find()
            ->alias('da')
            ->innerJoin(
                ['ta' => TaskAttachments::tableName()],
                'ta.attachment_id = da.id'
            )
            ->where(['ta.task_id' => (int) $this->id])
            ->orderBy(['ta.id' => SORT_ASC])
            ->all();
    }

    public function uploadFiles()
    {
        if (empty($this->uploadFiles) || !is_array($this->uploadFiles)) {
            return true;
        }
        DeskAttachments::ensureUploadDirectory('tasks');
        foreach ($this->uploadFiles as $file) {
            if (!$file instanceof UploadedFile) {
                continue;
            }
            $fileName = time() . '_' . uniqid() . '_' . $file->baseName . '.' . $file->extension;
            $relativePath = DeskAttachments::buildStoragePath('tasks', $fileName);
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
            $att->uploaded_by = Yii::$app->user->isGuest ? null : Yii::$app->user->id;
            $att->uploaded_at = date('Y-m-d H:i:s');
            if ($att->save(false)) {
                $this->addAttachment($att->id);
            }
        }
        return true;
    }

    public function beforeSave($insert)
    {
        if (!parent::beforeSave($insert)) {
            return false;
        }
        if ($this->contact_phone !== null && $this->contact_phone !== '') {
            $this->contact_phone = trim($this->contact_phone);
        }
        if ($this->contact_phone === '') {
            $this->contact_phone = null;
        }
        if ($this->room_number !== null && $this->room_number !== '') {
            $this->room_number = trim($this->room_number);
        }
        if ($this->room_number === '') {
            $this->room_number = null;
        }

        return true;
    }

    public function beforeDelete()
    {
        if (!parent::beforeDelete()) {
            return false;
        }

        TaskEquipment::deleteAll(['task_id' => $this->id]);
        TaskAttachments::deleteAll(['task_id' => $this->id]);
        TaskHistory::deleteAll(['task_id' => $this->id]);

        return true;
    }

    public function afterFind()
    {
        parent::afterFind();
        $this->equipment_ids = $this->getTaskEquipments()->select('equipment_id')->column();
    }

    public function afterSave($insert, $changedAttributes)
    {
        parent::afterSave($insert, $changedAttributes);
        if ($this->id && is_array($this->equipment_ids)) {
            TaskEquipment::deleteAll(['task_id' => $this->id]);
            $userId = Yii::$app->user->isGuest ? null : Yii::$app->user->id;
            foreach (array_filter(array_map('intval', $this->equipment_ids)) as $equipmentId) {
                if ($equipmentId <= 0) {
                    continue;
                }
                $te = new TaskEquipment();
                $te->task_id = $this->id;
                $te->equipment_id = $equipmentId;
                $te->relation_type = 'related';
                $te->linked_by = $userId;
                $te->save(false);
            }
        }
    }

    public static function AllTasks()
    {
        return self::find()
            ->with(['requester', 'executor', 'status'])
            ->orderBy(['id' => SORT_DESC])
            ->all();
    }
}
