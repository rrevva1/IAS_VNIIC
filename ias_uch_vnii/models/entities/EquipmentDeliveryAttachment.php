<?php

namespace app\models\entities;

use yii\db\ActiveRecord;

/**
 * Связь поставки с файлом в desk_attachments.
 *
 * @property int $id
 * @property int $delivery_id
 * @property int $attachment_id
 * @property int|null $linked_by
 * @property string $linked_at
 *
 * @property EquipmentDelivery $delivery
 * @property DeskAttachments $attachment
 */
class EquipmentDeliveryAttachment extends ActiveRecord
{
    public static function tableName()
    {
        return 'equipment_delivery_attachments';
    }

    public function rules()
    {
        return [
            [['delivery_id', 'attachment_id'], 'required'],
            [['delivery_id', 'attachment_id', 'linked_by'], 'integer'],
            [['delivery_id'], 'exist', 'targetClass' => EquipmentDelivery::class, 'targetAttribute' => ['delivery_id' => 'id']],
            [['attachment_id'], 'exist', 'targetClass' => DeskAttachments::class, 'targetAttribute' => ['attachment_id' => 'id']],
            [['linked_by'], 'exist', 'targetClass' => Users::class, 'targetAttribute' => ['linked_by' => 'id'], 'skipOnEmpty' => true],
        ];
    }

    public function getDelivery()
    {
        return $this->hasOne(EquipmentDelivery::class, ['id' => 'delivery_id']);
    }

    public function getAttachment()
    {
        return $this->hasOne(DeskAttachments::class, ['id' => 'attachment_id']);
    }
}
