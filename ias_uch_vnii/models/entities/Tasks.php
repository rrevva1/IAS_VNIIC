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
 * @property string|null $created_at
 * @property string|null $updated_at
 *
 * @property DicTaskStatus $status
 * @property Users $requester
 * @property Users $executor
 * @property DeskAttachments[] $taskAttachments через task_attachments
 */
class Tasks extends ActiveRecord
{
    public $uploadFiles;

    public static function tableName()
    {
        return 'tasks';
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
            [['status_id', 'description', 'requester_id'], 'required'],
            [['status_id', 'requester_id', 'executor_id'], 'integer'],
            [['description', 'comment'], 'string'],
            [['title'], 'string', 'max' => 250],
            [['task_number'], 'string', 'max' => 50],
            [['priority'], 'in', 'range' => ['low', 'medium', 'high', 'critical']],
            [['due_at', 'closed_at', 'created_at', 'updated_at'], 'safe'],
            [['status_id'], 'exist', 'targetClass' => DicTaskStatus::class, 'targetAttribute' => ['status_id' => 'id']],
            [['requester_id'], 'exist', 'targetClass' => Users::class, 'targetAttribute' => ['requester_id' => 'id']],
            [['executor_id'], 'exist', 'targetClass' => Users::class, 'targetAttribute' => ['executor_id' => 'id'], 'skipOnEmpty' => true],
            [['uploadFiles'], 'file', 'skipOnEmpty' => true, 'extensions' => 'png, jpg, jpeg, gif, pdf, doc, docx, xls, xlsx, txt', 'maxFiles' => 10],
        ];
    }

    public function attributeLabels()
    {
        return [
            'id' => 'ID',
            'task_number' => 'Номер',
            'title' => 'Тема',
            'status_id' => 'Статус',
            'description' => 'Описание',
            'requester_id' => 'Автор',
            'executor_id' => 'Исполнитель',
            'priority' => 'Приоритет',
            'due_at' => 'Срок',
            'closed_at' => 'Закрыта',
            'comment' => 'Комментарий',
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
        if ((int) $attachmentId <= 0) {
            return;
        }
        $exists = TaskAttachments::find()
            ->where(['task_id' => $this->id, 'attachment_id' => $attachmentId])
            ->exists();
        if (!$exists) {
            $ta = new TaskAttachments();
            $ta->task_id = $this->id;
            $ta->attachment_id = (int) $attachmentId;
            $ta->linked_at = date('Y-m-d H:i:s');
            $ta->save(false);
        }
    }

    public function removeAttachment($attachmentId)
    {
        TaskAttachments::deleteAll(['task_id' => $this->id, 'attachment_id' => $attachmentId]);
    }

    public function getAllAttachments()
    {
        return $this->getTaskAttachments()->all();
    }

    public function uploadFiles()
    {
        if (empty($this->uploadFiles) || !is_array($this->uploadFiles)) {
            return true;
        }
        $uploadDir = Yii::getAlias('@webroot/uploads/tasks/');
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0755, true);
        }
        foreach ($this->uploadFiles as $file) {
            if (!$file instanceof UploadedFile) {
                continue;
            }
            $fileName = time() . '_' . uniqid() . '_' . $file->baseName . '.' . $file->extension;
            $relativePath = '/uploads/tasks/' . $fileName;
            $fullPath = Yii::getAlias('@webroot') . $relativePath;
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

    public static function AllTasks()
    {
        return self::find()
            ->with(['requester', 'executor', 'status'])
            ->orderBy(['id' => SORT_DESC])
            ->all();
    }
}
