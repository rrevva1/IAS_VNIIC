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

    /**
     * Находит помещение по наименованию или создаёт запись в справочнике (тип «кабинет»).
     */
    public static function resolveOrCreateByName(string $name): ?int
    {
        $name = trim($name);
        if ($name === '') {
            return null;
        }

        $location = static::find()->where(['name' => $name])->one();
        if ($location !== null) {
            return (int) $location->id;
        }

        $location = new static();
        $location->name = $name;
        $location->location_type = 'кабинет';
        if (!$location->save()) {
            return null;
        }

        return (int) $location->id;
    }

    /**
     * Подпись помещения для интерфейса (списки, карточки, таблица).
     */
    public function getDisplayLabel(): string
    {
        return static::formatDisplayLabel($this->name);
    }

    /**
     * @param string $emptyLabel Текст, если помещение не задано
     */
    public static function formatDisplayLabel(?string $name, string $emptyLabel = 'Помещение не указано'): string
    {
        $name = trim((string) $name);
        if ($name === '') {
            return $emptyLabel;
        }
        if (preg_match('/^помещение\s*(№|#|n)?\s*/ui', $name)) {
            return $name;
        }

        return 'Помещение № ' . $name;
    }
}
