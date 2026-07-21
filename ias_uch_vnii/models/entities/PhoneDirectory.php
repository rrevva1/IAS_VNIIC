<?php

namespace app\models\entities;

use Yii;
use yii\behaviors\TimestampBehavior;
use yii\db\ActiveRecord;
use yii\db\Expression;

/**
 * Запись телефонного справочника.
 *
 * @property int $id
 * @property string $entry_type person|service
 * @property string $full_name
 * @property string|null $position
 * @property string|null $department
 * @property string|null $room
 * @property string|null $internal_phone
 * @property string|null $external_phone
 * @property int|null $user_id
 * @property bool $is_published
 * @property int $sort_order
 * @property string|null $created_at
 * @property string|null $updated_at
 *
 * @property Users|null $user
 */
class PhoneDirectory extends ActiveRecord
{
    public const TYPE_PERSON = 'person';
    public const TYPE_SERVICE = 'service';

    public static function tableName()
    {
        return 'phone_directory';
    }

    public function behaviors()
    {
        return [
            [
                'class' => TimestampBehavior::class,
                'createdAtAttribute' => 'created_at',
                'updatedAtAttribute' => 'updated_at',
                'value' => new Expression('CURRENT_TIMESTAMP'),
            ],
        ];
    }

    public function rules()
    {
        return [
            [['full_name', 'entry_type'], 'required'],
            [['full_name'], 'string', 'max' => 200],
            [['position', 'department'], 'string', 'max' => 100],
            [['room', 'internal_phone', 'external_phone'], 'string', 'max' => 50],
            [['internal_phone'], 'validateInternalPhone'],
            [['entry_type'], 'in', 'range' => [self::TYPE_PERSON, self::TYPE_SERVICE]],
            [['user_id', 'sort_order'], 'integer'],
            [['is_published'], 'boolean'],
            [['is_published'], 'default', 'value' => true],
            [['sort_order'], 'default', 'value' => 0],
            [['entry_type'], 'default', 'value' => self::TYPE_PERSON],
            [
                ['user_id'],
                'exist',
                'skipOnEmpty' => true,
                'targetClass' => Users::class,
                'targetAttribute' => ['user_id' => 'id'],
            ],
            [['full_name', 'position', 'department', 'room', 'internal_phone', 'external_phone'], 'trim'],
            [['position', 'department', 'room', 'internal_phone', 'external_phone', 'user_id'], 'default', 'value' => null],
        ];
    }

    public function attributeLabels()
    {
        return [
            'id' => 'ID',
            'entry_type' => 'Тип записи',
            'full_name' => 'ФИО / название',
            'position' => 'Должность',
            'department' => 'Подразделение',
            'room' => 'Кабинет',
            'internal_phone' => 'Внутренний номер',
            'external_phone' => 'Городской / мобильный',
            'user_id' => 'Пользователь системы',
            'is_published' => 'Опубликовано',
            'sort_order' => 'Порядок',
            'created_at' => 'Создано',
            'updated_at' => 'Обновлено',
        ];
    }

    public function getUser()
    {
        return $this->hasOne(Users::class, ['id' => 'user_id']);
    }

    /**
     * Внутренний номер: формат X-XX, серии 4–8 (или пусто).
     */
    public function validateInternalPhone(string $attribute): void
    {
        \app\components\InternalPhoneHelper::validateAttribute($this, $attribute);
    }

    /**
     * Подписи типов записей.
     *
     * @return array<string, string>
     */
    public static function entryTypeLabels(): array
    {
        return [
            self::TYPE_PERSON => 'Сотрудник',
            self::TYPE_SERVICE => 'Служебный номер',
        ];
    }

    /**
     * Дата последнего обновления опубликованных записей.
     */
    public static function getLastUpdatedAt(): ?string
    {
        $value = static::find()
            ->where(['is_published' => true])
            ->max('updated_at');

        return $value ? (string) $value : null;
    }

    /**
     * Создаёт или обновляет запись справочника по данным пользователя.
     */
    public static function syncFromUser(Users $user): ?self
    {
        if (!$user->id) {
            return null;
        }

        if (!empty($user->is_deleted)) {
            $existing = static::findOne(['user_id' => $user->id]);
            if ($existing !== null) {
                $existing->is_published = false;
                $existing->save(false);

                return $existing;
            }

            return null;
        }

        // Неактивные учётные записи остаются в справочнике (опубликованы),
        // т.к. сотрудник может ещё числиться без входа в систему.
        $entry = static::findOne(['user_id' => $user->id]);
        if ($entry === null) {
            $entry = new static();
            $entry->entry_type = self::TYPE_PERSON;
            $entry->user_id = (int) $user->id;
            $entry->sort_order = 100;
        }

        $entry->full_name = (string) $user->full_name;
        $entry->position = $user->position ?: null;
        $entry->department = $user->department ?: null;
        $entry->room = $user->hasAttribute('room') ? ($user->room ?: null) : $entry->room;
        $entry->internal_phone = \app\components\InternalPhoneHelper::normalize($user->phone ?: null);
        $entry->is_published = true;

        if (!$entry->save()) {
            Yii::warning('PhoneDirectory::syncFromUser failed: ' . json_encode($entry->errors), __METHOD__);

            return null;
        }

        return $entry;
    }

    public function afterSave($insert, $changedAttributes)
    {
        parent::afterSave($insert, $changedAttributes);

        $needPush = $insert
            || array_key_exists('internal_phone', $changedAttributes)
            || array_key_exists('room', $changedAttributes)
            || array_key_exists('user_id', $changedAttributes);

        if ($needPush) {
            try {
                $this->syncPhoneRoomToUser();
            } catch (\Throwable $e) {
                Yii::warning('PhoneDirectory::afterSave sync to user: ' . $e->getMessage(), __METHOD__);
            }
        }
    }

    /**
     * Обратная синхронизация: только внутренний телефон и кабинет → users.
     * Пароль, роли, email и прочие поля пользователя не изменяются.
     * Используется updateAttributes (без afterSave), чтобы не зациклить syncFromUser.
     */
    public function syncPhoneRoomToUser(): bool
    {
        if (empty($this->user_id)) {
            return false;
        }

        $user = Users::findOne(['id' => (int) $this->user_id]);
        if ($user === null || !empty($user->is_deleted)) {
            return false;
        }

        $phone = \app\components\InternalPhoneHelper::normalize($this->internal_phone ?: null);
        $room = $this->room !== null && trim((string) $this->room) !== ''
            ? trim((string) $this->room)
            : null;

        $attrs = [];
        if ((string) ($user->phone ?? '') !== (string) ($phone ?? '')) {
            $attrs['phone'] = $phone;
        }
        if ($user->hasAttribute('room') && (string) ($user->room ?? '') !== (string) ($room ?? '')) {
            $attrs['room'] = $room;
        }

        if ($attrs === []) {
            return true;
        }

        // Без событий модели — иначе Users::afterSave снова вызовет syncFromUser.
        return $user->updateAttributes($attrs) !== false;
    }
}
