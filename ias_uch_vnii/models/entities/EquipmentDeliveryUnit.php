<?php

namespace app\models\entities;

use yii\db\ActiveRecord;

/**
 * Единица техники в поставке (одна физическая позиция).
 *
 * @property int $id
 * @property int $line_id
 * @property int $seq_no
 * @property string|null $serial_number
 * @property string|null $inventory_number
 * @property string $number_status empty|serial_only|complete
 * @property int|null $equipment_id
 * @property string $created_at
 * @property string|null $updated_at
 *
 * @property EquipmentDeliveryLine $line
 * @property Equipment|null $equipment
 */
class EquipmentDeliveryUnit extends ActiveRecord
{
    public const NUMBER_EMPTY = 'empty';
    public const NUMBER_SERIAL_ONLY = 'serial_only';
    public const NUMBER_COMPLETE = 'complete';

    public static function tableName()
    {
        return 'equipment_delivery_units';
    }

    public function rules()
    {
        return [
            [['line_id', 'seq_no'], 'required'],
            [['line_id', 'seq_no', 'equipment_id'], 'integer'],
            [['seq_no'], 'integer', 'min' => 1],
            [['serial_number'], 'filter', 'filter' => [Equipment::class, 'normalizeSerialNumberValue']],
            [['serial_number'], 'string', 'max' => 150],
            [['inventory_number'], 'string', 'max' => 100],
            [['number_status'], 'in', 'range' => [self::NUMBER_EMPTY, self::NUMBER_SERIAL_ONLY, self::NUMBER_COMPLETE]],
            [['line_id'], 'exist', 'targetClass' => EquipmentDeliveryLine::class, 'targetAttribute' => ['line_id' => 'id']],
            [['equipment_id'], 'exist', 'targetClass' => Equipment::class, 'targetAttribute' => ['equipment_id' => 'id']],
        ];
    }

    public function attributeLabels()
    {
        return [
            'id' => 'ID',
            'line_id' => 'Строка',
            'seq_no' => '№',
            'serial_number' => 'Серийный номер',
            'inventory_number' => 'Инвентарный номер',
            'number_status' => 'Статус номеров',
            'equipment_id' => 'Техника',
        ];
    }

    public function beforeSave($insert)
    {
        if (!parent::beforeSave($insert)) {
            return false;
        }
        $this->refreshNumberStatus();
        $this->updated_at = date('Y-m-d H:i:s');

        return true;
    }

    public function refreshNumberStatus(): void
    {
        $serial = trim((string) $this->serial_number);
        $inventory = trim((string) $this->inventory_number);
        if ($serial !== '' && $inventory !== '') {
            $this->number_status = self::NUMBER_COMPLETE;
        } elseif ($serial !== '') {
            $this->number_status = self::NUMBER_SERIAL_ONLY;
        } else {
            $this->number_status = self::NUMBER_EMPTY;
        }
    }

    public function getDeliveryLine()
    {
        return $this->hasOne(EquipmentDeliveryLine::class, ['id' => 'line_id']);
    }

    public function getEquipment()
    {
        return $this->hasOne(Equipment::class, ['id' => 'equipment_id']);
    }
}
