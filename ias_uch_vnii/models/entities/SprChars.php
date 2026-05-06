<?php

namespace app\models\entities;

use yii\db\ActiveRecord;

/**
 * Справочник характеристик (spr_chars, схема tech_accounting).
 * Используется в учёте ТС: значения характеристик оборудования хранятся в part_char_values (char_id → spr_chars).
 *
 * @property int $id
 * @property string $name
 * @property string|null $description
 * @property string|null $measurement_unit
 * @property bool $is_archived
 * @property string $created_at
 * @property string $updated_at
 */
class SprChars extends ActiveRecord
{
    public static function tableName()
    {
        return 'spr_chars';
    }

    public function rules()
    {
        return [
            [['name'], 'required'],
            [['name'], 'string', 'max' => 100],
            [['description', 'measurement_unit'], 'string'],
            [['measurement_unit'], 'string', 'max' => 50],
            [['is_archived'], 'boolean'],
        ];
    }

    public function attributeLabels()
    {
        return [
            'id' => 'ID',
            'name' => 'Наименование',
            'description' => 'Описание',
            'measurement_unit' => 'Ед. измерения',
            'is_archived' => 'В архиве',
        ];
    }
}
