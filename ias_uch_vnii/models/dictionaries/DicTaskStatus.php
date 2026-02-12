<?php

namespace app\models\dictionaries;

use app\models\entities\Tasks;
use Yii;

/**
 * Модель для таблицы "dic_task_status" (схема tech_accounting).
 *
 * @property int $id
 * @property string $status_code
 * @property string $status_name
 * @property int $sort_order
 * @property bool $is_final
 * @property bool $is_archived
 *
 * @property Tasks[] $tasks
 */
class DicTaskStatus extends \yii\db\ActiveRecord
{
    public static function tableName()
    {
        return 'dic_task_status';
    }

    public function rules()
    {
        return [
            [['status_code', 'status_name'], 'required'],
            [['status_code'], 'string', 'max' => 50],
            [['status_name'], 'string', 'max' => 100],
            [['sort_order'], 'integer'],
            [['is_final', 'is_archived'], 'boolean'],
            [['status_code'], 'unique'],
        ];
    }

    public function attributeLabels()
    {
        return [
            'id' => 'ID',
            'status_code' => 'Код',
            'status_name' => 'Название статуса',
        ];
    }

    public function getTasks()
    {
        return $this->hasMany(Tasks::class, ['status_id' => 'id']);
    }

    /**
     * Список статусов для выпадающего списка [id => status_name].
     */
    public static function getStatusList()
    {
        return static::find()
            ->select(['status_name', 'id'])
            ->indexBy('id')
            ->column();
    }

    /**
     * ID статуса по умолчанию (например, «Новая»).
     */
    public static function getDefaultStatusId()
    {
        $status = static::find()->orderBy(['sort_order' => SORT_ASC])->one();
        return $status ? (int) $status->id : null;
    }
}
