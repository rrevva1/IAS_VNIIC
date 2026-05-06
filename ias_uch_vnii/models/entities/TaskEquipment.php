<?php

namespace app\models\entities;

use Yii;
use yii\db\ActiveRecord;

/**
 * Связь заявка — актив (task_equipment, схема tech_accounting).
 *
 * @property int $id
 * @property int $task_id
 * @property int $equipment_id
 * @property string $relation_type
 * @property bool $is_primary
 * @property int|null $linked_by
 * @property string $linked_at
 *
 * @property Tasks $task
 * @property Equipment $equipment
 */
class TaskEquipment extends ActiveRecord
{
    public static function tableName()
    {
        return 'task_equipment';
    }

    public function rules()
    {
        return [
            [['task_id', 'equipment_id'], 'required'],
            [['task_id', 'equipment_id', 'linked_by'], 'integer'],
            [['relation_type'], 'in', 'range' => ['related', 'affected', 'requested_for']],
            [['is_primary'], 'boolean'],
            [['linked_at'], 'safe'],
            [['task_id'], 'exist', 'targetClass' => Tasks::class, 'targetAttribute' => ['task_id' => 'id']],
            [['equipment_id'], 'exist', 'targetClass' => Equipment::class, 'targetAttribute' => ['equipment_id' => 'id']],
        ];
    }

    public function getTask()
    {
        return $this->hasOne(Tasks::class, ['id' => 'task_id']);
    }

    public function getEquipment()
    {
        return $this->hasOne(Equipment::class, ['id' => 'equipment_id']);
    }
}
