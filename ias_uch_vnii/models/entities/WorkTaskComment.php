<?php

namespace app\models\entities;

use yii\db\ActiveRecord;

/**
 * Комментарий к внутренней задаче.
 *
 * @property int $id
 * @property int $work_task_id
 * @property int $author_id
 * @property string $body
 * @property string $created_at
 */
class WorkTaskComment extends ActiveRecord
{
    public static function tableName()
    {
        return 'work_task_comments';
    }

    public function rules()
    {
        return [
            [['work_task_id', 'author_id', 'body'], 'required'],
            [['work_task_id', 'author_id'], 'integer'],
            [['body'], 'string', 'min' => 1, 'max' => 4000],
            [['created_at'], 'safe'],
            [['work_task_id'], 'exist', 'targetClass' => WorkTask::class, 'targetAttribute' => ['work_task_id' => 'id']],
            [['author_id'], 'exist', 'targetClass' => Users::class, 'targetAttribute' => ['author_id' => 'id']],
        ];
    }

    public function attributeLabels()
    {
        return [
            'body' => 'Комментарий',
            'created_at' => 'Дата',
        ];
    }

    public function getWorkTask()
    {
        return $this->hasOne(WorkTask::class, ['id' => 'work_task_id']);
    }

    public function getAuthor()
    {
        return $this->hasOne(Users::class, ['id' => 'author_id']);
    }
}
