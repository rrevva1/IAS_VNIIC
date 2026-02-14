<?php

namespace app\models\entities;

use yii\db\ActiveRecord;

/**
 * Справочник типов составных частей (spr_parts, схема tech_accounting).
 * Используется в учёте ТС: оборудование описывается через part_char_values (part_id → spr_parts, char_id → spr_chars).
 *
 * @property int $id
 * @property string $name
 * @property string|null $description
 * @property bool $is_archived
 * @property string $created_at
 * @property string $updated_at
 */
class SprParts extends ActiveRecord
{
    public static function tableName()
    {
        return 'spr_parts';
    }

    public function rules()
    {
        return [
            [['name'], 'required'],
            [['name'], 'string', 'max' => 100],
            [['description'], 'string'],
            [['is_archived'], 'boolean'],
        ];
    }

    public function attributeLabels()
    {
        return [
            'id' => 'ID',
            'name' => 'Наименование',
            'description' => 'Описание',
            'is_archived' => 'В архиве',
        ];
    }
}
