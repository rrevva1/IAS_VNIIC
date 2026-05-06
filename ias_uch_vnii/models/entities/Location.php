<?php

namespace app\models\entities;

use yii\db\ActiveRecord;

/**
 * Модель для таблицы "locations" (схема tech_accounting).
 *
 * @property int $id
 * @property string|null $location_code
 * @property string $name
 * @property string $location_type
 * @property int|null $floor
 * @property string|null $description
 * @property bool $is_archived
 */
class Location extends ActiveRecord
{
    public static function tableName()
    {
        return 'locations';
    }

    public function rules()
    {
        return [
            [['name', 'location_type'], 'required'],
            [['name'], 'string', 'max' => 150],
            [['location_code'], 'string', 'max' => 50],
            [['location_type'], 'string', 'max' => 50],
            [['location_type'], 'in', 'range' => ['кабинет', 'склад', 'серверная', 'лаборатория', 'другое']],
            [['description'], 'string'],
            [['floor'], 'integer'],
            [['is_archived'], 'boolean'],
        ];
    }

    public function attributeLabels()
    {
        return [
            'id' => 'ID',
            'location_code' => 'Код',
            'name' => 'Наименование',
            'location_type' => 'Тип локации',
            'floor' => 'Этаж',
            'description' => 'Описание',
        ];
    }
}
