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
 * @property DicEquipmentStatus $equipmentStatus
 * @property EquipmentLink[] $parentLinks
 * @property EquipmentLink[] $childLinks
 */
class Equipment extends ActiveRecord
{
    public ?string $equipment_type = null;

    public static function tableName()
    {
        return 'equipment';
    }

    public function rules()
    {
        $integerAttrs = ['status_id', 'responsible_user_id', 'location_id'];
        if (EquipmentTypes::usesDictionary()) {
            $integerAttrs[] = 'equipment_type_id';
        }

        return [
            [['inventory_number', 'name', 'status_id', 'location_id'], 'required'],
            [$integerAttrs, 'integer'],
            [['name'], 'string', 'max' => 200],
            [['inventory_number'], 'string', 'max' => 100],
            [['serial_number'], 'string', 'max' => 150],
            [['equipment_type'], 'string', 'max' => 100],
            [['description', 'supplier', 'archive_reason'], 'string'],
            [['purchase_date', 'commissioning_date', 'warranty_until', 'archived_at', 'created_at', 'updated_at'], 'safe'],
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
            'id' => 'Идентификатор',
            'inventory_number' => 'Инвентарный номер',
            'serial_number' => 'Серийный номер',
            'name' => 'Наименование',
            'equipment_type' => 'Тип техники',
            'equipment_type_id' => 'Тип техники',
            'status_id' => 'Статус эксплуатации',
            'responsible_user_id' => 'Ответственный пользователь',
            'location_id' => 'Местоположение',
            'description' => 'Примечание',
            'supplier' => 'Поставщик',
            'purchase_date' => 'Дата закупки',
            'commissioning_date' => 'Дата ввода в эксплуатацию',
            'warranty_until' => 'Гарантия до',
            'archived_at' => 'Дата архивации',
            'archive_reason' => 'Причина архивации',
            'is_archived' => 'В архиве',
            'is_deleted' => 'Удалено',
            'created_at' => 'Дата создания',
            'updated_at' => 'Дата изменения',
        ];
    }

    public function afterFind()
    {
        parent::afterFind();
        $this->equipment_type = $this->resolveEquipmentTypeName();
    }

    public function beforeValidate()
    {
        if (!parent::beforeValidate()) {
            return false;
        }

        $typeName = trim((string) $this->equipment_type);
        $schema = static::getTableSchema();

        if ($schema && isset($schema->columns['equipment_type'])) {
            $this->setAttribute('equipment_type', $typeName !== '' ? $typeName : null);
        } elseif (EquipmentTypes::usesDictionary()) {
            $typeId = $typeName !== '' ? EquipmentTypes::resolveIdByName($typeName) : null;
            $this->setAttribute('equipment_type_id', $typeId);
        }

        return true;
    }

    /**
     * Наименование типа техники для форм и отображения (varchar или справочник).
     */
    public function resolveEquipmentTypeName(): ?string
    {
        $schema = static::getTableSchema();
        if ($schema && isset($schema->columns['equipment_type'])) {
            $value = $this->getAttribute('equipment_type');
            return $value !== null && $value !== '' ? (string) $value : null;
        }
        if (EquipmentTypes::usesDictionary()) {
            $typeId = $this->getAttribute('equipment_type_id');
            return EquipmentTypes::resolveNameById($typeId !== null && $typeId !== '' ? (int) $typeId : null);
        }

        return null;
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

    public function getPartCharValues()
    {
        return $this->hasMany(PartCharValues::class, ['equipment_id' => 'id']);
    }

    public function getTaskEquipments()
    {
        return $this->hasMany(TaskEquipment::class, ['equipment_id' => 'id']);
    }

    public function getParentLinks()
    {
        return $this->hasMany(EquipmentLink::class, ['parent_equipment_id' => 'id']);
    }

    public function getChildLinks()
    {
        return $this->hasMany(EquipmentLink::class, ['child_equipment_id' => 'id']);
    }

    public function getMonitorLinks()
    {
        return $this->getParentLinks()->andWhere(['link_type' => EquipmentLink::TYPE_MONITOR]);
    }

    public function getDiskLinks()
    {
        return $this->getParentLinks()->andWhere(['link_type' => EquipmentLink::TYPE_DISK]);
    }

    public function getUpsLinks()
    {
        return $this->getParentLinks()->andWhere(['link_type' => EquipmentLink::TYPE_UPS]);
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
