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
 * @property string|null $location_name Наименование помещения (ввод в форме)
 * @property string|null $description
 * @property string|null $supplier
 * @property string|null $purchase_date
 * @property string|null $commissioning_date
 * @property string|null $warranty_until
 * @property float|string|null $warranty_years Срок гарантии в годах (виртуальное поле формы)
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

    /** @var float|string|null */
    public $warranty_years = null;

    /** @var string|null */
    public $location_name = null;

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
            [['inventory_number', 'name', 'status_id', 'location_name'], 'required'],
            [$integerAttrs, 'integer'],
            [['location_name'], 'string', 'max' => 150],
            [['name'], 'string', 'max' => 200],
            [['inventory_number'], 'string', 'max' => 100],
            [['serial_number'], 'filter', 'filter' => [static::class, 'normalizeSerialNumberValue']],
            [['serial_number'], 'string', 'max' => 150],
            [['serial_number'], 'unique', 'skipOnEmpty' => true],
            [['equipment_type'], 'string', 'max' => 100],
            [['description', 'supplier', 'archive_reason'], 'string'],
            [['purchase_date', 'commissioning_date', 'warranty_until', 'archived_at', 'created_at', 'updated_at'], 'safe'],
            [['warranty_years'], 'number', 'min' => 0, 'max' => 50],
            [['is_archived', 'is_deleted'], 'boolean'],
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
            'location_name' => 'Местоположение',
            'description' => 'Примечание',
            'supplier' => 'Поставщик',
            'purchase_date' => 'Дата закупки',
            'commissioning_date' => 'Дата ввода в эксплуатацию',
            'warranty_years' => 'Срок гарантии (лет)',
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
        $this->warranty_years = static::deriveWarrantyYears(
            static::resolveWarrantyBaseDate($this->commissioning_date, $this->purchase_date),
            $this->warranty_until
        );
        if ($this->location_id && $this->location) {
            $this->location_name = $this->location->name;
        }
    }

    public function beforeValidate()
    {
        if (!parent::beforeValidate()) {
            return false;
        }

        $this->normalizeSerialNumberAttribute();

        $typeName = trim((string) $this->equipment_type);
        $schema = static::getTableSchema();

        if ($schema && isset($schema->columns['equipment_type'])) {
            $this->setAttribute('equipment_type', $typeName !== '' ? $typeName : null);
        } elseif (EquipmentTypes::usesDictionary()) {
            $typeId = $typeName !== '' ? EquipmentTypes::resolveIdByName($typeName) : null;
            $this->setAttribute('equipment_type_id', $typeId);
        }

        $this->applyWarrantyUntilFromYears();
        $this->applyLocationFromName();

        return true;
    }

    /**
     * Привязка location_id по введённому наименованию помещения (создание в справочнике при отсутствии).
     */
    private function applyLocationFromName(): void
    {
        $name = trim((string) ($this->location_name ?? ''));
        if ($name === '') {
            return;
        }

        $locationId = Location::resolveOrCreateByName($name);
        if ($locationId === null) {
            $this->addError(
                'location_name',
                'Не удалось сохранить местоположение в справочнике.'
            );

            return;
        }

        $this->location_id = $locationId;
    }

    public function afterValidate()
    {
        parent::afterValidate();
        $this->normalizeSerialNumberAttribute();
    }

    public function beforeSave($insert)
    {
        if (!parent::beforeSave($insert)) {
            return false;
        }
        $this->normalizeSerialNumberAttribute();
        $this->applyWarrantyUntilFromYears();

        return true;
    }

    /**
     * Базовая дата для расчёта гарантии: ввод в эксплуатацию, иначе закупка.
     */
    public static function resolveWarrantyBaseDate(?string $commissioningDate, ?string $purchaseDate): ?string
    {
        $commissioningDate = trim((string) $commissioningDate);
        if ($commissioningDate !== '') {
            return $commissioningDate;
        }
        $purchaseDate = trim((string) $purchaseDate);

        return $purchaseDate !== '' ? $purchaseDate : null;
    }

    /**
     * Дата окончания гарантии по сроку в годах от базовой даты.
     */
    public static function calculateWarrantyUntil(?string $baseDate, $years): ?string
    {
        if ($baseDate === null || trim($baseDate) === '') {
            return null;
        }
        $years = str_replace(',', '.', trim((string) $years));
        if ($years === '' || !is_numeric($years) || (float) $years <= 0) {
            return null;
        }

        try {
            $dt = new \DateTimeImmutable(trim($baseDate));
            $months = (int) round((float) $years * 12);

            return $dt->modify('+' . $months . ' months')->format('Y-m-d');
        } catch (\Exception $e) {
            return null;
        }
    }

    /**
     * Срок гарантии в годах по сохранённой дате окончания (для формы редактирования).
     *
     * @return float|null
     */
    public static function deriveWarrantyYears(?string $baseDate, ?string $warrantyUntil)
    {
        if ($baseDate === null || trim($baseDate) === '' || $warrantyUntil === null || trim($warrantyUntil) === '') {
            return null;
        }

        try {
            $start = new \DateTimeImmutable(trim($baseDate));
            $end = new \DateTimeImmutable(trim($warrantyUntil));
            if ($end < $start) {
                return null;
            }
            $days = (int) $start->diff($end)->days;
            $years = round($days / 365.25, 1);

            return $years > 0 ? $years : null;
        } catch (\Exception $e) {
            return null;
        }
    }

    public function getWarrantyUntilDisplay(): string
    {
        $until = trim((string) $this->warranty_until);
        if ($until === '') {
            return '';
        }

        try {
            return (new \DateTimeImmutable($until))->format('d.m.Y');
        } catch (\Exception $e) {
            return $until;
        }
    }

    private function applyWarrantyUntilFromYears(): void
    {
        $years = $this->warranty_years;
        $baseDate = static::resolveWarrantyBaseDate($this->commissioning_date, $this->purchase_date);

        if ($years === null || $years === '') {
            $existingUntil = trim((string) $this->warranty_until);
            if ($existingUntil !== '' && $baseDate === null) {
                return;
            }
            $this->setAttribute('warranty_until', null);

            return;
        }

        $years = str_replace(',', '.', trim((string) $years));
        if ($years === '' || !is_numeric($years) || (float) $years <= 0) {
            $this->setAttribute('warranty_until', null);

            return;
        }

        $this->setAttribute('warranty_until', static::calculateWarrantyUntil($baseDate, $years));
    }

    /**
     * Пустой серийный номер → NULL (иначе '' нарушает uq_equipment_serial_number_not_null).
     *
     * @param mixed $value
     */
    public static function normalizeSerialNumberValue($value): ?string
    {
        if ($value === null || $value === '') {
            return null;
        }
        $value = trim((string) $value);

        return $value === '' ? null : $value;
    }

    private function normalizeSerialNumberAttribute(): void
    {
        $this->setAttribute('serial_number', static::normalizeSerialNumberValue($this->serial_number));
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
     * Значения по умолчанию при создании (статус эксплуатации).
     */
    public function loadDefaultValues($skipIfSet = true)
    {
        parent::loadDefaultValues($skipIfSet);
        if ($this->status_id === null || $this->status_id === '') {
            $this->status_id = DicEquipmentStatus::getDefaultId();
        }

        return $this;
    }
}
