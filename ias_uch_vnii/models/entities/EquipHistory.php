<?php

namespace app\models\entities;

use app\models\dictionaries\DicEquipmentStatus;
use Yii;
use yii\db\ActiveRecord;
use yii\helpers\Json;

/**
 * Модель для таблицы equip_history (история изменений оборудования).
 *
 * @property int $id
 * @property int $equipment_id
 * @property string $event_type
 * @property array|string|null $old_value
 * @property array|string|null $new_value
 * @property int|null $changed_by
 * @property string $changed_at
 * @property string|null $comment
 *
 * @property Equipment $equipment
 * @property Users|null $changedByUser
 */
class EquipHistory extends ActiveRecord
{
    private const COMMENT_LABELS = [
        'dismissal_to_warehouse' => 'Увольнение: передача на склад',
        'dismissal_transfer' => 'Увольнение: передача другому сотруднику',
        'move_component_to_host' => 'Перемещение компонента к системному блоку',
        'move_component_detach' => 'Снятие привязки компонента к системному блоку',
        'move_component_attach' => 'Привязка компонента к системному блоку',
        'move_to_warehouse' => 'Перемещение на склад',
        'move_to_warehouse_detach_kit' => 'Перемещение на склад: разрыв связи комплекта',
    ];

    public static function tableName()
    {
        return 'equip_history';
    }

    public function rules()
    {
        return [
            [['equipment_id', 'event_type'], 'required'],
            [['equipment_id', 'changed_by'], 'integer'],
            [['event_type'], 'in', 'range' => ['create', 'update', 'move', 'assign', 'unassign', 'status_change', 'maintenance', 'writeoff', 'archive', 'restore']],
            [['old_value', 'new_value'], 'safe'],
            [['comment'], 'string'],
            [['changed_at'], 'safe'],
            [['equipment_id'], 'exist', 'targetClass' => Equipment::class, 'targetAttribute' => ['equipment_id' => 'id']],
        ];
    }

    public function afterFind()
    {
        parent::afterFind();
        $this->old_value = self::decodeValue($this->old_value);
        $this->new_value = self::decodeValue($this->new_value);
    }

    public function getEquipment()
    {
        return $this->hasOne(Equipment::class, ['id' => 'equipment_id']);
    }

    public function getChangedByUser()
    {
        return $this->hasOne(Users::class, ['id' => 'changed_by']);
    }

    /**
     * Записать событие в историю оборудования (с сохранением читаемых имён помещения, пользователя, статуса).
     */
    public static function log(int $equipmentId, string $eventType, $oldValue = null, $newValue = null, ?string $comment = null): void
    {
        try {
            $oldPayload = self::normalizePayload($oldValue);
            $newPayload = self::normalizePayload($newValue);
            if (!self::hasMeaningfulChange($eventType, $oldPayload, $newPayload)) {
                return;
            }

            $userId = Yii::$app->user->isGuest ? null : Yii::$app->user->id;
            $record = new self();
            $record->equipment_id = $equipmentId;
            $record->event_type = $eventType;
            $record->old_value = $oldPayload !== null ? Json::encode(self::enrichSnapshot($oldPayload)) : null;
            $record->new_value = $newPayload !== null ? Json::encode(self::enrichSnapshot($newPayload)) : null;
            $record->changed_by = $userId;
            $record->comment = $comment;
            $record->save(false);
        } catch (\Throwable $e) {
            Yii::error('EquipHistory::log failed: ' . $e->getMessage(), __METHOD__);
        }
    }

    /**
     * Текстовое описание изменения для карточки техники.
     */
    public function getFormattedDetails(): string
    {
        $old = self::decodeValue($this->old_value);
        $new = self::decodeValue($this->new_value);

        switch ($this->event_type) {
            case 'move':
                return 'Помещение: ' . self::formatLocationTransition($old, $new);
            case 'assign':
                return 'Ответственный: ' . self::formatUserTransition($old, $new, true);
            case 'unassign':
                return 'Ответственный: ' . self::formatUserTransition($old, $new, false);
            case 'status_change':
                return 'Статус: ' . self::formatStatusTransition($old, $new);
            case 'create':
                return self::formatCreateOrUpdate($new, true);
            case 'update':
                return self::formatCreateOrUpdate($new, false);
            case 'archive':
                return 'Техника переведена в архив';
            case 'restore':
                return 'Техника восстановлена из архива';
            case 'writeoff':
                return 'Техника списана';
            case 'maintenance':
                return 'Обслуживание';
            default:
                return self::formatGenericDiff($old, $new);
        }
    }

    public function getCommentLabel(): ?string
    {
        $key = trim((string) $this->comment);
        if ($key === '') {
            return null;
        }

        return self::COMMENT_LABELS[$key] ?? $key;
    }

    /**
     * Сравнение идентификаторов (null и '' считаются «не задано»).
     */
    public static function idsEqual($left, $right): bool
    {
        return self::normalizeId($left) === self::normalizeId($right);
    }

    private static function normalizePayload($value): ?array
    {
        if ($value === null) {
            return null;
        }
        if (is_array($value)) {
            return $value;
        }

        return self::decodeValue($value);
    }

    private static function normalizeId($value): ?int
    {
        if ($value === null || $value === '' || $value === false) {
            return null;
        }
        $id = (int) $value;

        return $id > 0 ? $id : null;
    }

    /**
     * Есть ли фактическое изменение данных события (без ложных записей string/int).
     */
    private static function hasMeaningfulChange(string $eventType, ?array $old, ?array $new): bool
    {
        switch ($eventType) {
            case 'move':
                return !self::idsEqual(
                    is_array($old) ? ($old['location_id'] ?? null) : null,
                    is_array($new) ? ($new['location_id'] ?? null) : null
                );
            case 'assign':
            case 'unassign':
                return !self::idsEqual(
                    is_array($old) ? ($old['responsible_user_id'] ?? null) : null,
                    is_array($new) ? ($new['responsible_user_id'] ?? null) : null
                );
            case 'status_change':
                return !self::idsEqual(
                    is_array($old) ? ($old['status_id'] ?? null) : null,
                    is_array($new) ? ($new['status_id'] ?? null) : null
                );
            case 'archive':
            case 'restore':
            case 'writeoff':
            case 'maintenance':
            case 'create':
            case 'update':
                return true;
            default:
                return true;
        }
    }

    private static function decodeValue($raw): ?array
    {
        if ($raw === null || $raw === '') {
            return null;
        }
        if (is_array($raw)) {
            return $raw;
        }
        try {
            $decoded = Json::decode((string) $raw);
            return is_array($decoded) ? $decoded : null;
        } catch (\Throwable $e) {
            return null;
        }
    }

    /**
     * Дополняет снимок ID читаемыми наименованиями (для хранения в JSON).
     */
    private static function enrichSnapshot(?array $data): ?array
    {
        if ($data === null || $data === []) {
            return $data;
        }

        $out = $data;

        if (array_key_exists('location_id', $out) && !isset($out['location_name'])) {
            $out['location_name'] = self::resolveLocationName($out['location_id']);
        }
        if (array_key_exists('responsible_user_id', $out) && !isset($out['responsible_user_name'])) {
            $out['responsible_user_name'] = self::resolveUserName($out['responsible_user_id']);
        }
        if (array_key_exists('status_id', $out) && !isset($out['status_name'])) {
            $out['status_name'] = self::resolveStatusName($out['status_id']);
        }

        return $out;
    }

    private static function resolveLocationName($locationId): string
    {
        if ($locationId === null || $locationId === '') {
            return 'не указано';
        }
        $loc = Location::findOne((int) $locationId);
        return $loc ? (string) $loc->name : ('ID ' . (int) $locationId);
    }

    private static function resolveUserName($userId): string
    {
        if ($userId === null || $userId === '' || (int) $userId === 0) {
            return 'не назначен';
        }
        $user = Users::findOne((int) $userId);
        if (!$user) {
            return 'ID ' . (int) $userId;
        }
        $name = trim((string) ($user->full_name ?: $user->email ?: ''));
        return $name !== '' ? $name : ('ID ' . (int) $userId);
    }

    private static function resolveStatusName($statusId): string
    {
        if ($statusId === null || $statusId === '') {
            return 'не указан';
        }
        $status = DicEquipmentStatus::findOne((int) $statusId);
        return $status ? (string) $status->status_name : ('ID ' . (int) $statusId);
    }

    private static function formatLocationTransition(?array $old, ?array $new): string
    {
        return '«' . self::pickLabel($old, 'location_name', 'location_id', 'не указано') . '»'
            . ' → «' . self::pickLabel($new, 'location_name', 'location_id', 'не указано') . '»';
    }

    private static function formatUserTransition(?array $old, ?array $new, bool $isAssignEvent): string
    {
        if ($isAssignEvent && self::isEmptyUser($new)) {
            return 'снят с «' . self::pickLabel($old, 'responsible_user_name', 'responsible_user_id', 'не назначен') . '»';
        }

        return '«' . self::pickLabel($old, 'responsible_user_name', 'responsible_user_id', 'не назначен') . '»'
            . ' → «' . self::pickLabel($new, 'responsible_user_name', 'responsible_user_id', 'не назначен') . '»';
    }

    private static function formatStatusTransition(?array $old, ?array $new): string
    {
        return '«' . self::pickLabel($old, 'status_name', 'status_id', 'не указан') . '»'
            . ' → «' . self::pickLabel($new, 'status_name', 'status_id', 'не указан') . '»';
    }

    private static function formatCreateOrUpdate(?array $new, bool $isCreate): string
    {
        if ($new === null) {
            return $isCreate ? 'Создана запись' : 'Изменены данные';
        }
        $parts = [];
        if (!empty($new['inventory_number'])) {
            $parts[] = 'инв. № ' . $new['inventory_number'];
        }
        if (!empty($new['name'])) {
            $parts[] = '«' . $new['name'] . '»';
        }
        if ($parts === []) {
            return $isCreate ? 'Создана запись' : 'Изменены данные';
        }

        return ($isCreate ? 'Создана запись: ' : 'Изменены данные: ') . implode(', ', $parts);
    }

    private static function formatGenericDiff(?array $old, ?array $new): string
    {
        if ($old === null && $new === null) {
            return '';
        }
        if ($old === null) {
            return self::formatPayloadSummary($new);
        }
        if ($new === null) {
            return self::formatPayloadSummary($old);
        }

        return self::formatPayloadSummary($old) . ' → ' . self::formatPayloadSummary($new);
    }

    private static function formatPayloadSummary(?array $data): string
    {
        if ($data === null || $data === []) {
            return '—';
        }
        $chunks = [];
        if (array_key_exists('location_id', $data) || isset($data['location_name'])) {
            $chunks[] = 'помещение «' . self::pickLabel($data, 'location_name', 'location_id', '—') . '»';
        }
        if (array_key_exists('responsible_user_id', $data) || isset($data['responsible_user_name'])) {
            $chunks[] = 'ответственный «' . self::pickLabel($data, 'responsible_user_name', 'responsible_user_id', '—') . '»';
        }
        if (array_key_exists('status_id', $data) || isset($data['status_name'])) {
            $chunks[] = 'статус «' . self::pickLabel($data, 'status_name', 'status_id', '—') . '»';
        }
        if ($chunks === [] && !empty($data['inventory_number'])) {
            $chunks[] = 'инв. № ' . $data['inventory_number'];
        }
        if ($chunks === [] && !empty($data['name'])) {
            $chunks[] = '«' . $data['name'] . '»';
        }

        return $chunks !== [] ? implode('; ', $chunks) : '—';
    }

    private static function pickLabel(?array $data, string $nameKey, string $idKey, string $emptyLabel): string
    {
        if ($data === null) {
            return $emptyLabel;
        }
        if (!empty($data[$nameKey])) {
            return (string) $data[$nameKey];
        }
        if (array_key_exists($idKey, $data)) {
            if ($idKey === 'responsible_user_id') {
                return self::resolveUserName($data[$idKey]);
            }
            if ($idKey === 'location_id') {
                return self::resolveLocationName($data[$idKey]);
            }
            if ($idKey === 'status_id') {
                return self::resolveStatusName($data[$idKey]);
            }
        }

        return $emptyLabel;
    }

    private static function isEmptyUser(?array $data): bool
    {
        if ($data === null || !array_key_exists('responsible_user_id', $data)) {
            return true;
        }
        $id = $data['responsible_user_id'];
        return $id === null || $id === '' || (int) $id === 0;
    }
}
