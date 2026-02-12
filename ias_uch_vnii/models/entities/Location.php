<?php
namespace app\models\entities;

use yii\db\ActiveRecord;

/**
 * Модель для таблицы "locations" (местоположения техники).
 *
 * @property int $id_location
 * @property string $name
 * @property string $location_type
 * @property int|null $floor
 * @property string|null $description
 */
class Location extends ActiveRecord
{
    /**
     * Возвращает имя таблицы
     */
    public static function tableName()
    {
        return 'locations';
    }

    /**
     * Правила валидации
     */
    public function rules()
    {
        return [
            [['name', 'location_type'], 'required'],
            [['name'], 'string', 'max' => 100],
            [['location_type'], 'string', 'max' => 50],
            [['description'], 'string'],
            [['floor'], 'integer'],
        ];
    }

    /**
     * Метки атрибутов
     */
    public function attributeLabels()
    {
        return [
            'id_location' => 'ID',
            'name' => 'Наименование',
            'location_type' => 'Тип локации',
            'floor' => 'Этаж',
            'description' => 'Описание',
        ];
    }
}





