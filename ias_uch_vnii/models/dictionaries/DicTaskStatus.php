<?php

namespace app\models\dictionaries;

use app\models\entities\Tasks;
use Yii;

/**
 * Модель для таблицы "dic_task_status".
 *
 * @property int $id_status
 * @property string $status_name
 *
 * @property Tasks[] $tasks
 */
class DicTaskStatus extends \yii\db\ActiveRecord
{
    /**
     * Возвращает имя таблицы
     */
    public static function tableName()
    {
        return 'dic_task_status';
    }

    /**
     * Правила валидации
     */
    public function rules()
    {
        return [
            [['status_name'], 'required'],
            [['status_name'], 'string', 'max' => 50],
            [['status_name'], 'unique'],
        ];
    }

    /**
     * Метки атрибутов
     */
    public function attributeLabels()
    {
        return [
            'id_status' => 'ID Статуса',
            'status_name' => 'Название статуса',
        ];
    }

    /**
     * Получить запрос для [[Tasks]].
     *
     * @return \yii\db\ActiveQuery
     */
    public function getTasks()
    {
        return $this->hasMany(Tasks::class, ['id_status' => 'id_status']);
    }

    /**
     * Получить список статусов для выпадающего списка
     *
     * @return array
     */
    public static function getStatusList()
    {
        return static::find()
            ->select(['status_name', 'id_status'])
            ->indexBy('id_status')
            ->column();
    }

    /**
     * Получить статус по умолчанию (первый в списке)
     *
     * @return int|null
     */
    public static function getDefaultStatusId()
    {
        $status = static::find()->orderBy(['id_status' => SORT_ASC])->one();
        return $status ? $status->id_status : null;
    }
}
