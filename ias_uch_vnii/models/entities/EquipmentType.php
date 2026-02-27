<?php

namespace app\models\entities;

use yii\db\ActiveRecord;

/**
 * Модель справочника типов оборудования (equipment_types).
 *
 * @property int $id
 * @property string $name
 * @property int $sort_order
 * @property bool $is_archived
 */
class EquipmentType extends ActiveRecord
{
    public static function tableName()
    {
        return 'equipment_types';
    }
}
