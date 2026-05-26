<?php

namespace app\models\entities;

use Yii;
use yii\db\ActiveRecord;

/**
 * @property int $id
 * @property int $work_task_id
 * @property string $event_type
 * @property int|null $old_status_id
 * @property int|null $new_status_id
 * @property string|null $comment
 * @property int|null $changed_by
 * @property string $changed_at
 */
class WorkTaskHistory extends ActiveRecord
{
    public static function tableName()
    {
        return 'work_task_history';
    }

    public function getChangedByUser()
    {
        return $this->hasOne(Users::class, ['id' => 'changed_by']);
    }

    public function getOldStatus()
    {
        return $this->hasOne(\app\models\dictionaries\DicWorkTaskStatus::class, ['id' => 'old_status_id']);
    }

    public function getNewStatus()
    {
        return $this->hasOne(\app\models\dictionaries\DicWorkTaskStatus::class, ['id' => 'new_status_id']);
    }

    public static function log(
        int $workTaskId,
        string $eventType,
        ?int $oldStatusId,
        ?int $newStatusId,
        ?string $comment = null
    ): void {
        $record = new self();
        $record->work_task_id = $workTaskId;
        $record->event_type = $eventType;
        $record->old_status_id = $oldStatusId;
        $record->new_status_id = $newStatusId;
        $record->comment = $comment;
        $record->changed_by = Yii::$app->user->isGuest ? null : (int) Yii::$app->user->id;
        $record->save(false);
    }
}
