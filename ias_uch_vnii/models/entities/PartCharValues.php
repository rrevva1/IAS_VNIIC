<?php

namespace app\models\entities;

use Yii;
use yii\db\ActiveRecord;

/**
 * Модель для таблицы part_char_values (характеристики оборудования, схема tech_accounting).
 *
 * @property int $id
 * @property int $equipment_id
 * @property int $part_id
 * @property int $char_id
 * @property string|null $value_text
 * @property float|null $value_num
 * @property string|null $source
 * @property int|null $updated_by
 * @property string $updated_at
 *
 * @property Equipment $equipment
 */
class PartCharValues extends ActiveRecord
{
    public static function tableName()
    {
        return 'part_char_values';
    }

    public function rules()
    {
        return [
            [['equipment_id', 'part_id', 'char_id'], 'required'],
            [['equipment_id', 'part_id', 'char_id', 'updated_by'], 'integer'],
            [['value_num'], 'number'],
            [['value_text', 'source'], 'string'],
            [['updated_at'], 'safe'],
            [['equipment_id'], 'exist', 'targetClass' => Equipment::class, 'targetAttribute' => ['equipment_id' => 'id']],
        ];
    }

    public function getEquipment()
    {
        return $this->hasOne(Equipment::class, ['id' => 'equipment_id']);
    }
}
