<?php

namespace app\models\entities;

use yii\db\ActiveRecord;

/**
 * Связь заявка — вложение (task_attachments, схема tech_accounting).
 *
 * @property int $id
 * @property int $task_id
 * @property int $attachment_id
 * @property int|null $linked_by
 * @property string $linked_at
 *
 * @property Tasks $task
 * @property DeskAttachments $attachment
 */
class TaskAttachments extends ActiveRecord
{
    public static function tableName()
    {
        return 'task_attachments';
    }

    public function rules()
    {
        return [
            [['task_id', 'attachment_id'], 'required'],
            [['task_id', 'attachment_id', 'linked_by'], 'integer'],
            [['task_id'], 'exist', 'targetClass' => Tasks::class, 'targetAttribute' => ['task_id' => 'id']],
            [['attachment_id'], 'exist', 'targetClass' => DeskAttachments::class, 'targetAttribute' => ['attachment_id' => 'id']],
        ];
    }

    public function getTask()
    {
        return $this->hasOne(Tasks::class, ['id' => 'task_id']);
    }

    public function getAttachment()
    {
        return $this->hasOne(DeskAttachments::class, ['id' => 'attachment_id']);
    }
}
