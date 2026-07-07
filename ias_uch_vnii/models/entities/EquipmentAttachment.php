<?php

namespace app\models\entities;

use yii\db\ActiveRecord;

/**
 * Связь техники с файлом в desk_attachments.
 *
 * @property int $id
 * @property int $equipment_id
 * @property int $attachment_id
 * @property int|null $linked_by
 * @property string $linked_at
 *
 * @property Equipment $equipment
 * @property DeskAttachments $attachment
 */
class EquipmentAttachment extends ActiveRecord
{
    public static function tableName()
    {
        return 'equipment_attachments';
    }

    public function rules()
    {
        return [
            [['equipment_id', 'attachment_id'], 'required'],
            [['equipment_id', 'attachment_id', 'linked_by'], 'integer'],
            [['equipment_id'], 'exist', 'targetClass' => Equipment::class, 'targetAttribute' => ['equipment_id' => 'id']],
            [['attachment_id'], 'exist', 'targetClass' => DeskAttachments::class, 'targetAttribute' => ['attachment_id' => 'id']],
        ];
    }

    public function getEquipment()
    {
        return $this->hasOne(Equipment::class, ['id' => 'equipment_id']);
    }

    public function getAttachment()
    {
        return $this->hasOne(DeskAttachments::class, ['id' => 'attachment_id']);
    }
}
