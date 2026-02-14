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
 * @property int|null $equipment_type_id
 * @property int $status_id
 * @property int|null $responsible_user_id
 * @property int $location_id
 * @property string|null $description
 * @property string|null $supplier
 * @property string|null $purchase_date
 * @property string|null $commissioning_date
 * @property string|null $warranty_until
 * @property string|null $archived_at
 * @property string|null $archive_reason
 * @property bool $is_archived
 * @property bool $is_deleted
 * @property string $created_at
 * @property string $updated_at
 *
 * @property Users $responsibleUser
 * @property PartCharValues[] $partCharValues
 * @property Location $location
 * @property EquipmentTypes|null $equipmentType
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
            [['status_id', 'responsible_user_id', 'location_id', 'equipment_type_id'], 'integer'],
            [['name'], 'string', 'max' => 200],
            [['inventory_number'], 'string', 'max' => 100],
            [['serial_number'], 'string', 'max' => 150],
            [['description', 'supplier', 'archive_reason'], 'string'],
            [['purchase_date', 'commissioning_date', 'warranty_until', 'archived_at', 'created_at', 'updated_at'], 'safe'],
            [['is_archived', 'is_deleted'], 'boolean'],
            [['inventory_number'], 'unique'],
            [['status_id'], 'exist', 'targetClass' => DicEquipmentStatus::class, 'targetAttribute' => ['status_id' => 'id']],
            [['responsible_user_id'], 'exist', 'targetClass' => Users::class, 'targetAttribute' => ['responsible_user_id' => 'id']],
            [['location_id'], 'exist', 'targetClass' => Location::class, 'targetAttribute' => ['location_id' => 'id']],
            [['equipment_type_id'], 'exist', 'skipOnEmpty' => true, 'targetClass' => EquipmentTypes::class, 'targetAttribute' => ['equipment_type_id' => 'id']],
        ];
    }

    public function attributeLabels()
    {
        return [
            'id' => 'ID',
            'inventory_number' => 'Инв. номер',
            'serial_number' => 'Серийный номер',
            'name' => 'Наименование',
            'equipment_type_id' => 'Тип',
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

    public function getEquipmentType()
    {
        return $this->hasOne(EquipmentTypes::class, ['id' => 'equipment_type_id']);
    }

    public function getEquipmentStatus()
    {
        return $this->hasOne(DicEquipmentStatus::class, ['id' => 'status_id']);
    }

    public function getPartCharValues()
    {
        return $this->hasMany(PartCharValues::class, ['equipment_id' => 'id']);
    }

    public function getTaskEquipments()
    {
        return $this->hasMany(TaskEquipment::class, ['equipment_id' => 'id']);
    }

    /** Заявки, в которых указан этот актив */
    public function getTasks()
    {
        return $this->hasMany(Tasks::class, ['id' => 'task_id'])
            ->viaTable('task_equipment', ['equipment_id' => 'id']);
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
