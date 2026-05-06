<?php

namespace app\models\entities;

use Yii;
use yii\db\ActiveRecord;

/**
 * Модель для чтения журнала аудита (таблица audit_events). Записи неизменяемы.
 *
 * @property int $id
 * @property string $event_time
 * @property int|null $actor_id
 * @property string $action_type
 * @property string $object_type
 * @property string $object_id
 * @property string $result_status
 * @property string|null $payload
 *
 * @property Users $actor
 */
class AuditEvent extends ActiveRecord
{
    public static function tableName()
    {
        return 'audit_events';
    }

    public function getActor()
    {
        return $this->hasOne(Users::class, ['id' => 'actor_id']);
    }
}
