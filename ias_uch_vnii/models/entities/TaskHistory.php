<?php

namespace app\models\entities;

use Yii;
use yii\db\ActiveRecord;

/**
 * История изменений заявки (task_history).
 *
 * @property int $id
 * @property int $task_id
 * @property string $field_name
 * @property string|null $old_value
 * @property string|null $new_value
 * @property int|null $changed_by
 * @property string $changed_at
 * @property string|null $comment
 */
class TaskHistory extends ActiveRecord
{
    public static function tableName()
    {
        return 'task_history';
    }

    public function getTask()
    {
        return $this->hasOne(Tasks::class, ['id' => 'task_id']);
    }

    public function getChangedByUser()
    {
        return $this->hasOne(Users::class, ['id' => 'changed_by']);
    }

    public static function log(int $taskId, string $fieldName, $oldValue, $newValue, ?string $comment = null): void
    {
        $userId = Yii::$app->user->isGuest ? null : Yii::$app->user->id;
        $record = new self();
        $record->task_id = $taskId;
        $record->field_name = $fieldName;
        $record->old_value = $oldValue === null ? null : (string) $oldValue;
        $record->new_value = $newValue === null ? null : (string) $newValue;
        $record->changed_by = $userId;
        $record->comment = $comment;
        $record->save(false);
    }
}
