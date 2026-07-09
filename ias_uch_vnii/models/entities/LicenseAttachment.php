<?php

namespace app\models\entities;

use yii\db\ActiveRecord;

/**
 * Связь лицензии с файлом в desk_attachments.
 *
 * @property int $id
 * @property int $license_id
 * @property int $attachment_id
 * @property int|null $linked_by
 * @property string $linked_at
 */
class LicenseAttachment extends ActiveRecord
{
    public static function tableName()
    {
        return 'license_attachments';
    }

    public function rules()
    {
        return [
            [['license_id', 'attachment_id'], 'required'],
            [['license_id', 'attachment_id', 'linked_by'], 'integer'],
            [['license_id'], 'exist', 'targetClass' => License::class, 'targetAttribute' => ['license_id' => 'id']],
            [['attachment_id'], 'exist', 'targetClass' => DeskAttachments::class, 'targetAttribute' => ['attachment_id' => 'id']],
            [['linked_by'], 'exist', 'targetClass' => Users::class, 'targetAttribute' => ['linked_by' => 'id'], 'skipOnEmpty' => true],
        ];
    }

    public function getLicense()
    {
        return $this->hasOne(License::class, ['id' => 'license_id']);
    }

    public function getAttachment()
    {
        return $this->hasOne(DeskAttachments::class, ['id' => 'attachment_id']);
    }
}
