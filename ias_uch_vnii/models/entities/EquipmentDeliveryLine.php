<?php

namespace app\models\entities;

use yii\db\ActiveRecord;

/**
 * Строка поставки (тип техники × количество).
 *
 * @property int $id
 * @property int $delivery_id
 * @property string $equipment_type
 * @property int|null $equipment_type_id
 * @property string $name
 * @property int $quantity
 * @property string|null $description
 * @property int|null $warehouse_location_id
 * @property string|null $char_template
 * @property float|string|null $warranty_years
 * @property int $sort_order
 * @property string $created_at
 * @property string|null $updated_at
 *
 * @property EquipmentDelivery $delivery
 * @property Location|null $warehouseLocation
 * @property EquipmentDeliveryUnit[] $units
 */
class EquipmentDeliveryLine extends ActiveRecord
{
    public static function tableName()
    {
        return 'equipment_delivery_lines';
    }

    public function rules()
    {
        return [
            [['delivery_id', 'equipment_type', 'name', 'quantity', 'warehouse_location_id'], 'required'],
            [['delivery_id', 'equipment_type_id', 'quantity', 'sort_order', 'warehouse_location_id'], 'integer'],
            [['char_template'], 'string'],
            [['warranty_years'], 'number', 'min' => 0, 'max' => 50],
            [['quantity'], 'integer', 'min' => 1, 'max' => 500],
            [['equipment_type'], 'string', 'max' => 100],
            [['name'], 'string', 'max' => 200],
            [['description'], 'string'],
            [['delivery_id'], 'exist', 'targetClass' => EquipmentDelivery::class, 'targetAttribute' => ['delivery_id' => 'id']],
            [['warehouse_location_id'], 'exist', 'targetClass' => Location::class, 'targetAttribute' => ['warehouse_location_id' => 'id']],
        ];
    }

    public function attributeLabels()
    {
        return [
            'id' => 'ID',
            'delivery_id' => 'Поставка',
            'equipment_type' => 'Тип техники',
            'equipment_type_id' => 'Тип техники',
            'name' => 'Наименование',
            'quantity' => 'Количество',
            'description' => 'Примечание',
            'warehouse_location_id' => 'Склад',
            'char_template' => 'Характеристики',
            'warranty_years' => 'Гарантия (лет)',
            'sort_order' => 'Порядок',
        ];
    }

    public function beforeValidate()
    {
        if (!parent::beforeValidate()) {
            return false;
        }

        $typeName = trim((string) $this->equipment_type);
        if ($typeName !== '' && EquipmentTypes::usesDictionary()) {
            $this->equipment_type_id = EquipmentTypes::resolveIdByName($typeName);
        }

        return true;
    }

    public function beforeSave($insert)
    {
        if (!parent::beforeSave($insert)) {
            return false;
        }
        $this->updated_at = date('Y-m-d H:i:s');

        return true;
    }

    public function getDelivery()
    {
        return $this->hasOne(EquipmentDelivery::class, ['id' => 'delivery_id']);
    }

    public function getWarehouseLocation()
    {
        return $this->hasOne(Location::class, ['id' => 'warehouse_location_id']);
    }

    /**
     * @return array<string, mixed>
     */
    public function getCharTemplateData(): array
    {
        $raw = trim((string) ($this->char_template ?? ''));
        if ($raw === '') {
            return [];
        }
        $decoded = json_decode($raw, true);

        return is_array($decoded) ? $decoded : [];
    }

    public function setCharTemplateData(array $data): void
    {
        if ($data === []) {
            $this->char_template = null;

            return;
        }
        $this->char_template = json_encode($data, JSON_UNESCAPED_UNICODE);
    }

    public function getUnits()
    {
        return $this->hasMany(EquipmentDeliveryUnit::class, ['line_id' => 'id'])
            ->orderBy(['seq_no' => SORT_ASC]);
    }
}
