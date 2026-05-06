<?php

namespace app\components;

use Yii;

/**
 * Хелпер записи событий в журнал аудита (таблица audit_events).
 */
class AuditLog
{
    /**
     * Записать событие аудита.
     * @param string $actionType Тип операции (например: user.password_reset, task.delete, attachment.delete)
     * @param string $objectType Тип объекта (user, task, attachment, equipment)
     * @param string|int $objectId Идентификатор объекта
     * @param string $resultStatus success|error|denied
     * @param array|null $payload Дополнительные данные (JSONB)
     * @param string|null $errorMessage Сообщение об ошибке при result_status = error
     */
    public static function log(
        string $actionType,
        string $objectType,
        $objectId,
        string $resultStatus = 'success',
        ?array $payload = null,
        ?string $errorMessage = null
    ): void {
        $table = 'audit_events';
        try {
            $db = Yii::$app->db;
            $userId = Yii::$app->user->isGuest ? null : Yii::$app->user->id;
            $ip = Yii::$app->request->userIP ?? null;
            $userAgent = Yii::$app->request->userAgent ?? null;
            $db->createCommand()->insert($table, [
                'actor_id' => $userId,
                'action_type' => $actionType,
                'object_type' => $objectType,
                'object_id' => (string) $objectId,
                'result_status' => $resultStatus,
                'source_ip' => $ip,
                'user_agent' => $userAgent ? substr($userAgent, 0, 500) : null,
                'payload' => $payload !== null ? json_encode($payload) : null,
                'error_message' => $errorMessage,
            ])->execute();
        } catch (\Throwable $e) {
            Yii::error('AuditLog::log failed: ' . $e->getMessage(), __METHOD__);
        }
    }
}
