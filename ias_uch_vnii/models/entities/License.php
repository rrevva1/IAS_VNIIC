<?php

namespace app\models\entities;

use Yii;
use yii\db\ActiveRecord;

/**
 * Лицензия (licenses).
 *
 * @property int $id
 * @property int $software_id
 * @property string|null $supplier
 * @property string|null $purchase_date
 * @property string|null $valid_from
 * @property string|null $valid_until
 * @property float|null $validity_years
 * @property bool $is_perpetual
 * @property int $seats
 * @property string|null $notes
 * @property string $created_at
 */
class License extends ActiveRecord
{
    /** Порог предупреждения «истекает скоро», дней до окончания срока. */
    public const EXPIRING_WARNING_DAYS = 60;

    private const ATTACHMENT_MAX_FILES = 20;

    /** @var string[] */
    private const ATTACHMENT_EXTENSIONS = [
        'pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'png', 'jpg', 'jpeg', 'gif', 'webp',
    ];

    public static function tableName()
    {
        return 'licenses';
    }

    public function rules()
    {
        return [
            [['software_id'], 'required'],
            [['software_id', 'seats'], 'integer'],
            [['seats'], 'default', 'value' => 1],
            [['seats'], 'integer', 'min' => 1, 'max' => 100000],
            [['is_perpetual'], 'boolean'],
            [['is_perpetual'], 'default', 'value' => false],
            [['supplier'], 'string', 'max' => 255],
            [['purchase_date', 'valid_from', 'valid_until'], 'safe'],
            [['validity_years'], 'number', 'min' => 0.5, 'max' => 100],
            [['notes'], 'string'],
            [['software_id'], 'exist', 'targetClass' => Software::class, 'targetAttribute' => ['software_id' => 'id']],
            ['validity_years', 'validateValidityPeriod'],
        ];
    }

    public function validateValidityPeriod(): void
    {
        if ($this->isPerpetual()) {
            return;
        }
        $years = $this->validity_years;
        if ($years === null || $years === '' || (float) $years <= 0) {
            $this->addError('validity_years', 'Укажите срок действия в годах или отметьте «Бессрочная».');
        }
    }

    public function beforeSave($insert)
    {
        if (!parent::beforeSave($insert)) {
            return false;
        }

        if ($this->isPerpetual()) {
            $this->valid_until = null;
            $this->validity_years = null;
        } else {
            $this->valid_until = $this->computeValidUntil();
        }

        return true;
    }

    public function isPerpetual(): bool
    {
        return (bool) $this->is_perpetual;
    }

    public function computeValidUntil(): ?string
    {
        $from = trim((string) ($this->valid_from ?? ''));
        $years = $this->validity_years;
        if ($from === '' || $years === null || $years === '' || (float) $years <= 0) {
            return $this->valid_until ? (string) $this->valid_until : null;
        }

        try {
            $date = new \DateTimeImmutable($from);
            $wholeYears = (int) floor((float) $years);
            $months = (int) round(((float) $years - $wholeYears) * 12);
            if ($wholeYears > 0) {
                $date = $date->modify('+' . $wholeYears . ' years');
            }
            if ($months > 0) {
                $date = $date->modify('+' . $months . ' months');
            }

            return $date->format('Y-m-d');
        } catch (\Exception $e) {
            return null;
        }
    }

    /**
     * Текст срока для таблицы и карточек.
     */
    public function getValidityDisplay(): string
    {
        if ($this->isPerpetual()) {
            return 'Бессрочная';
        }

        $from = trim((string) ($this->valid_from ?? ''));
        $years = $this->validity_years;
        if ($from === '' && ($years === null || $years === '')) {
            return '—';
        }

        $parts = [];
        if ($from !== '') {
            $parts[] = 'с ' . Yii::$app->formatter->asDate($from);
        }
        if ($years !== null && $years !== '') {
            $parts[] = $this->formatYearsLabel((float) $years);
        }
        $until = trim((string) ($this->valid_until ?? ''));
        if ($until !== '') {
            $parts[] = 'до ' . Yii::$app->formatter->asDate($until);
        }

        return $parts !== [] ? implode(', ', $parts) : '—';
    }

    public function getExpiryStatus(): string
    {
        if ($this->isPerpetual()) {
            return 'perpetual';
        }
        $until = trim((string) ($this->valid_until ?? ''));
        if ($until === '') {
            return '';
        }
        $today = strtotime(date('Y-m-d'));
        $untilTs = strtotime($until);
        if ($untilTs === false) {
            return '';
        }
        $days = (int) floor(($untilTs - $today) / 86400);
        if ($days < 0) {
            return 'expired';
        }
        if ($days <= self::EXPIRING_WARNING_DAYS) {
            return 'expiring';
        }

        return 'active';
    }

    private function formatYearsLabel(float $years): string
    {
        $rounded = round($years, 1);
        $intPart = (int) $rounded;
        $label = rtrim(rtrim(number_format($rounded, 1, '.', ''), '0'), '.');
        if ($intPart === 1 && abs($rounded - 1.0) < 0.05) {
            return $label . ' год';
        }
        if ($intPart >= 2 && $intPart <= 4 && abs($rounded - $intPart) < 0.05) {
            return $label . ' года';
        }

        return $label . ' лет';
    }

    public function attributeLabels()
    {
        return [
            'software_id' => 'Программное обеспечение',
            'supplier' => 'Поставщик',
            'purchase_date' => 'Дата закупки',
            'valid_from' => 'Действует с',
            'validity_years' => 'Срок действия, лет',
            'is_perpetual' => 'Бессрочная',
            'seats' => 'Количество лицензий',
            'notes' => 'Примечание',
        ];
    }

    public function getSoftware()
    {
        return $this->hasOne(Software::class, ['id' => 'software_id']);
    }

    public function getEquipmentSoftware()
    {
        return $this->hasMany(EquipmentSoftware::class, ['license_id' => 'id']);
    }

    public function addAttachment(int $attachmentId): void
    {
        if (LicenseAttachment::find()->where([
            'license_id' => $this->id,
            'attachment_id' => $attachmentId,
        ])->exists()) {
            return;
        }
        $link = new LicenseAttachment();
        $link->license_id = (int) $this->id;
        $link->attachment_id = $attachmentId;
        $link->linked_by = Yii::$app->user->isGuest ? null : (int) Yii::$app->user->id;
        $link->save(false);
    }

    public function removeAttachment(int $attachmentId): void
    {
        LicenseAttachment::deleteAll([
            'license_id' => $this->id,
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
}
