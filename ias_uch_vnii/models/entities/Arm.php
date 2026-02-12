<?php
namespace app\models\entities;

use Yii;
use yii\db\ActiveRecord;

/**
 * Модель для таблицы "arm" (техника/АРМ).
 * 
 * @property int $id_arm
 * @property string $name
 * @property int $id_user
 * @property int $id_location
 * @property string $description
 * @property string $created_at
 */
class Arm extends ActiveRecord
{
    /**
     * Правила валидации
     */
    public function rules()
    {
        return [
            [['name', 'id_location'], 'required'],
            [['id_user', 'id_location'], 'integer'],
            [['description'], 'string'],
            [['created_at'], 'safe'],
            [['name'], 'string', 'max' => 200],
        ];
    }

    /**
     * Метки атрибутов
     */
    public function attributeLabels()
    {
        return [
            'id_arm' => 'ID',
            'name' => 'Наименование техники',
            'id_user' => 'Пользователь',
            'id_location' => 'Местоположение',
            'description' => 'Описание',
            'created_at' => 'Дата создания',
        ];
    }

    /**
     * Возвращает имя таблицы
     */
    public static function tableName()
    {
        return 'arm';
    }
    
    /**
     * Получить связь с пользователем (владельцем техники)
     * @return \yii\db\ActiveQuery
     */
    public function getUser()
    {
        return $this->hasOne(Users::class, ['id_user' => 'id_user']);
    }

    /**
     * Получить связь с местоположением
     * @return \yii\db\ActiveQuery
     */
    public function getLocation()
    {
        return $this->hasOne(Location::class, ['id_location' => 'id_location']);
    }
    
    /**
     * Получить комплектующие АРМ (характеристики)
     * @return \yii\db\ActiveQuery
     */
    public function getPartCharValues()
    {
        return $this->hasMany(PartCharValues::class, ['id_arm' => 'id_arm']);
    }
}