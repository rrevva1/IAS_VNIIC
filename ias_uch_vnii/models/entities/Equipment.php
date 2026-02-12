<?php

namespace app\models\entities;

use app\models\dictionaries\DicEquipmentStatus;
use Yii;
use yii\db\ActiveRecord;

/**
 * Модель для таблицы "equipment" (оборудование/АРМ, схема tech_accounting).
 *
 * @property int $id
 * @property string $inventory_number
 * @property string|null $serial_number
 * @property string $name
 * @property string|null $equipment_type
 * @property int $status_id
 * @property int|null $responsible_user_id
 * @property int $location_id
 * @property string|null $description
 * @property bool $is_archived
 * @property bool $is_deleted
 *
 * @property Users $responsibleUser
 * @property Location $location
 * @property DicEquipmentStatus $equipmentStatus
 */
class Equipment extends ActiveRecord
{
    public static function tableName()
    {
        return 'equipment';
    }

    public function rules()
    {
        return [
            [['inventory_number', 'name', 'status_id', 'location_id'], 'required'],
            [['status_id', 'responsible_user_id', 'location_id'], 'integer'],
            [['name'], 'string', 'max' => 200],
            [['inventory_number'], 'string', 'max' => 100],
            [['serial_number'], 'string', 'max' => 150],
            [['equipment_type'], 'string', 'max' => 100],
            [['description'], 'string'],
            [['is_archived', 'is_deleted'], 'boolean'],
            [['inventory_number'], 'unique'],
            [['status_id'], 'exist', 'targetClass' => DicEquipmentStatus::class, 'targetAttribute' => ['status_id' => 'id']],
            [['responsible_user_id'], 'exist', 'targetClass' => Users::class, 'targetAttribute' => ['responsible_user_id' => 'id']],
            [['location_id'], 'exist', 'targetClass' => Location::class, 'targetAttribute' => ['location_id' => 'id']],
        ];
    }

    public function attributeLabels()
    {
        return [
            'id' => 'ID',
            'inventory_number' => 'Инв. номер',
            'serial_number' => 'Серийный номер',
            'name' => 'Наименование',
            'equipment_type' => 'Тип',
            'status_id' => 'Статус',
            'responsible_user_id' => 'Ответственный',
            'location_id' => 'Местоположение',
            'description' => 'Описание',
        ];
    }

    public function getResponsibleUser()
    {
        return $this->hasOne(Users::class, ['id' => 'responsible_user_id']);
    }

    public function getLocation()
    {
        return $this->hasOne(Location::class, ['id' => 'location_id']);
    }

    public function getEquipmentStatus()
    {
        return $this->hasOne(DicEquipmentStatus::class, ['id' => 'status_id']);
    }

    /**
     * Значения по умолчанию при создании (инв. номер и статус).
     */
    public function loadDefaultValues($skipIfSet = true)
    {
        parent::loadDefaultValues($skipIfSet);
        if ($this->status_id === null || $this->status_id === '') {
            $this->status_id = DicEquipmentStatus::getDefaultId();
        }
        if (empty($this->inventory_number)) {
            $this->inventory_number = 'EQ-' . date('Ymd') . '-' . substr(uniqid(), -4);
        }
        return $this;
    }
}
