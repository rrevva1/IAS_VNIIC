<?php

namespace app\models\entities;

use Yii;
use yii\db\ActiveRecord;

/**
 * Документ поставки техники.
 *
 * @property int $id
 * @property string $name
 * @property string|null $supplier
 * @property string $delivery_date
 * @property int|null $warehouse_location_id
 * @property string $status draft|posted|closed
 * @property string|null $notes
 * @property int|null $created_by
 * @property string $created_at
 * @property string|null $updated_at
 *
 * @property Location $warehouseLocation
 * @property Users|null $createdByUser
 * @property EquipmentDeliveryLine[] $lines
 * @property EquipmentDeliveryUnit[] $units
 * @property Equipment[] $equipmentItems
 * @property DeskAttachments[] $attachments
 */
class EquipmentDelivery extends ActiveRecord
{
    private const ATTACHMENT_MAX_FILES = 10;

    private const ATTACHMENT_EXTENSIONS = [
        'png', 'jpg', 'jpeg', 'gif', 'pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt',
    ];

    public const STATUS_DRAFT = 'draft';
    public const STATUS_POSTED = 'posted';
    public const STATUS_CLOSED = 'closed';

    public static function tableName()
    {
        return 'equipment_deliveries';
    }

    public function rules()
    {
        return [
            [['name', 'delivery_date'], 'required'],
            [['name'], 'string', 'max' => 200],
            [['supplier'], 'string', 'max' => 255],
            [['notes'], 'string'],
            [['delivery_date'], 'date', 'format' => 'php:Y-m-d'],
            [['warehouse_location_id', 'created_by'], 'integer'],
            [['status'], 'in', 'range' => [self::STATUS_DRAFT, self::STATUS_POSTED, self::STATUS_CLOSED]],
            [['warehouse_location_id'], 'exist', 'targetClass' => Location::class, 'targetAttribute' => ['warehouse_location_id' => 'id']],
            [['created_by'], 'exist', 'targetClass' => Users::class, 'targetAttribute' => ['created_by' => 'id']],
        ];
    }

    public function attributeLabels()
    {
        return [
            'id' => 'ID',
            'name' => 'Название поставки',
            'supplier' => 'Поставщик',
            'delivery_date' => 'Дата поставки',
            'warehouse_location_id' => 'Склад',
            'status' => 'Статус',
            'notes' => 'Примечание',
            'created_by' => 'Автор',
            'created_at' => 'Создано',
            'updated_at' => 'Изменено',
        ];
    }

    public function beforeSave($insert)
    {
        if (!parent::beforeSave($insert)) {
            return false;
        }
        $this->updated_at = date('Y-m-d H:i:s');
        if ($insert && empty($this->created_by) && !Yii::$app->user->isGuest) {
            $this->created_by = (int) Yii::$app->user->id;
        }

        return true;
    }

    public function getWarehouseLocation()
    {
        return $this->hasOne(Location::class, ['id' => 'warehouse_location_id']);
    }

    public function getCreatedByUser()
    {
        return $this->hasOne(Users::class, ['id' => 'created_by']);
    }

    public function getLines()
    {
        return $this->hasMany(EquipmentDeliveryLine::class, ['delivery_id' => 'id'])
            ->orderBy(['sort_order' => SORT_ASC, 'id' => SORT_ASC]);
    }

    public function getUnits()
    {
        return $this->hasMany(EquipmentDeliveryUnit::class, ['line_id' => 'id'])
            ->viaTable('equipment_delivery_lines', ['delivery_id' => 'id']);
    }

    public function getEquipmentItems()
    {
        return $this->hasMany(Equipment::class, ['delivery_id' => 'id']);
    }

    public function getDeliveryAttachmentLinks()
    {
        return $this->hasMany(EquipmentDeliveryAttachment::class, ['delivery_id' => 'id']);
    }

    public function getAttachments()
    {
        return $this->hasMany(DeskAttachments::class, ['id' => 'attachment_id'])
            ->via('deliveryAttachmentLinks');
    }

    public function addAttachment(int $attachmentId): void
    {
        if ($attachmentId <= 0 || !$this->id) {
            return;
        }
        $exists = EquipmentDeliveryAttachment::find()
            ->where(['delivery_id' => $this->id, 'attachment_id' => $attachmentId])
            ->exists();
        if ($exists) {
            return;
        }
        $link = new EquipmentDeliveryAttachment();
        $link->delivery_id = (int) $this->id;
        $link->attachment_id = $attachmentId;
        $link->linked_by = Yii::$app->user->isGuest ? null : (int) Yii::$app->user->id;
        $link->save(false);
    }

    public function removeAttachment(int $attachmentId): void
    {
        EquipmentDeliveryAttachment::deleteAll([
            'delivery_id' => $this->id,
            'attachment_id' => $attachmentId,
        ]);
    }

    public static function getAttachmentMaxFiles(): int
    {
        return self::ATTACHMENT_MAX_FILES;
    }

    /**
     * @return string[]
     */
    public static function getAttachmentExtensions(): array
    {
        return self::ATTACHMENT_EXTENSIONS;
    }

    public function isDraft(): bool
    {
        return $this->status === self::STATUS_DRAFT;
    }

    public function isPosted(): bool
    {
        return $this->status === self::STATUS_POSTED || $this->status === self::STATUS_CLOSED;
    }

    /** Документы можно добавлять и удалять в черновике и после проведения. */
    public function canEditAttachments(): bool
    {
        return $this->status === self::STATUS_DRAFT || $this->status === self::STATUS_POSTED;
    }

    public function getStatusLabel(): string
    {
        $labels = self::getStatusList();

        return $labels[$this->status] ?? 'Черновик';
    }

    public static function getStatusList(): array
    {
        return [
            self::STATUS_DRAFT => 'Черновик',
            self::STATUS_POSTED => 'Проведена',
            self::STATUS_CLOSED => 'Закрыта',
        ];
    }
}
