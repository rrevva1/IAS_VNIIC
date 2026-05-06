<?php

namespace app\models\entities;

use yii\db\ActiveRecord;

class EquipmentLink extends ActiveRecord
{
    public const TYPE_MONITOR = 'monitor';
    public const TYPE_DISK = 'disk';
    public const TYPE_UPS = 'ups';

    public static function tableName()
    {
        return 'equipment_links';
    }

    public function rules()
    {
        return [
            [['parent_equipment_id', 'child_equipment_id', 'link_type'], 'required'],
            [['parent_equipment_id', 'child_equipment_id', 'created_by'], 'integer'],
            [['link_type'], 'string', 'max' => 32],
            [['link_type'], 'in', 'range' => [self::TYPE_MONITOR, self::TYPE_DISK, self::TYPE_UPS]],
            [['parent_equipment_id', 'child_equipment_id', 'link_type'], 'unique', 'targetAttribute' => ['parent_equipment_id', 'child_equipment_id', 'link_type']],
        ];
    }

    public function getParentEquipment()
    {
        return $this->hasOne(Equipment::class, ['id' => 'parent_equipment_id']);
    }

    public function getChildEquipment()
    {
        return $this->hasOne(Equipment::class, ['id' => 'child_equipment_id']);
    }
}

