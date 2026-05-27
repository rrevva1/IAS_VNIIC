<?php

namespace app\models\entities;

use yii\db\ActiveRecord;

/**
 * Связь внутренней задачи и вложения.
 *
 * @property int $id
 * @property int $work_task_id
 * @property int $attachment_id
 * @property int|null $linked_by
 * @property string $linked_at
 *
 * @property WorkTask $workTask
 * @property DeskAttachments $attachment
 */
class WorkTaskAttachments extends ActiveRecord
{
    public static function tableName()
    {
        return 'work_task_attachments';
    }

    public function rules()
    {
        return [
            [['work_task_id', 'attachment_id'], 'required'],
            [['work_task_id', 'attachment_id', 'linked_by'], 'integer'],
            [['linked_at'], 'safe'],
            [['work_task_id'], 'exist', 'targetClass' => WorkTask::class, 'targetAttribute' => ['work_task_id' => 'id']],
            [['attachment_id'], 'exist', 'targetClass' => DeskAttachments::class, 'targetAttribute' => ['attachment_id' => 'id']],
        ];
    }

    public function getWorkTask()
    {
        return $this->hasOne(WorkTask::class, ['id' => 'work_task_id']);
    }

    public function getAttachment()
    {
        return $this->hasOne(DeskAttachments::class, ['id' => 'attachment_id']);
    }
}
