<?php

namespace app\models\entities;

use Yii;
use yii\db\ActiveRecord;

/**
 * Исполнитель внутренней задачи (связь many-to-many).
 *
 * @property int $id
 * @property int $work_task_id
 * @property int $user_id
 * @property string $created_at
 *
 * @property WorkTask $workTask
 * @property Users $user
 */
class WorkTaskExecutor extends ActiveRecord
{
    public static function tableName()
    {
        return 'work_task_executors';
    }

    public function rules()
    {
        return [
            [['work_task_id', 'user_id'], 'required'],
            [['work_task_id', 'user_id'], 'integer'],
            [['work_task_id', 'user_id'], 'unique', 'targetAttribute' => ['work_task_id', 'user_id']],
        ];
    }

    public function getWorkTask()
    {
        return $this->hasOne(WorkTask::class, ['id' => 'work_task_id']);
    }

    public function getUser()
    {
        return $this->hasOne(Users::class, ['id' => 'user_id']);
    }

    /**
     * Синхронизирует список исполнителей задачи и поле work_tasks.executor_id (первый в списке).
     *
     * @param int[] $userIds
     */
    public static function syncForTask(int $workTaskId, array $userIds): void
    {
        if ($workTaskId <= 0) {
            return;
        }

        $userIds = array_values(array_unique(array_filter(array_map('intval', $userIds), static function ($id): bool {
            return (int) $id > 0;
        })));

        $existing = array_map('intval', static::find()
            ->select('user_id')
            ->where(['work_task_id' => $workTaskId])
            ->column());

        $toDelete = array_diff($existing, $userIds);
        if ($toDelete !== []) {
            static::deleteAll(['work_task_id' => $workTaskId, 'user_id' => $toDelete]);
        }

        $toAdd = array_diff($userIds, $existing);
        foreach ($toAdd as $userId) {
            $row = new static();
            $row->work_task_id = $workTaskId;
            $row->user_id = $userId;
            $row->save(false);
        }

        WorkTask::updateAll(
            ['executor_id' => $userIds[0] ?? null],
            ['id' => $workTaskId]
        );
    }
}
