<?php

namespace app\models\entities;

use yii\db\ActiveRecord;

/**
 * Связь оборудование — ПО (equipment_software).
 * @property int $id
 * @property int $equipment_id
 * @property int $software_id
 * @property string|null $installed_at
 */
class EquipmentSoftware extends ActiveRecord
{
    public static function tableName()
    {
        return 'equipment_software';
    }

    public function getEquipment()
    {
        return $this->hasOne(Equipment::class, ['id' => 'equipment_id']);
    }

    public function getSoftware()
    {
        return $this->hasOne(Software::class, ['id' => 'software_id']);
    }

    public function rules()
    {
        return [
            [['equipment_id', 'software_id'], 'required'],
            [['equipment_id', 'software_id'], 'integer'],
            [['installed_at'], 'safe'],
            [['equipment_id'], 'exist', 'targetClass' => Equipment::class, 'targetAttribute' => ['equipment_id' => 'id']],
            [['software_id'], 'exist', 'targetClass' => Software::class, 'targetAttribute' => ['software_id' => 'id']],
        ];
    }

    public function attributeLabels()
    {
        return [
            'equipment_id' => 'Оборудование',
            'software_id' => 'ПО',
            'installed_at' => 'Дата установки',
        ];
    }
}
