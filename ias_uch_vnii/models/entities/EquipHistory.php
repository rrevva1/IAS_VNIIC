<?php

namespace app\models\entities;

use Yii;
use yii\db\ActiveRecord;
use yii\helpers\Json;

/**
 * Модель для таблицы equip_history (история изменений оборудования).
 *
 * @property int $id
 * @property int $equipment_id
 * @property string $event_type
 * @property array|null $old_value
 * @property array|null $new_value
 * @property int|null $changed_by
 * @property string $changed_at
 * @property string|null $comment
 *
 * @property Equipment $equipment
 */
class EquipHistory extends ActiveRecord
{
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

    public function getEquipment()
    {
        return $this->hasOne(Equipment::class, ['id' => 'equipment_id']);
    }

    /**
     * Записать событие в историю оборудования.
     */
    public static function log(int $equipmentId, string $eventType, $oldValue = null, $newValue = null, ?string $comment = null): void
    {
        try {
            $userId = Yii::$app->user->isGuest ? null : Yii::$app->user->id;
            $record = new self();
            $record->equipment_id = $equipmentId;
            $record->event_type = $eventType;
            $record->old_value = $oldValue !== null ? Json::encode($oldValue) : null;
            $record->new_value = $newValue !== null ? Json::encode($newValue) : null;
            $record->changed_by = $userId;
            $record->comment = $comment;
            $record->save(false);
        } catch (\Throwable $e) {
            Yii::error('EquipHistory::log failed: ' . $e->getMessage(), __METHOD__);
        }
    }
}
