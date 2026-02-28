<?php

namespace app\components\assistant;

use app\models\dictionaries\DicTaskStatus;
use app\models\entities\Location;
use app\models\entities\Users;

/**
 * Формирует RAG-контекст для передачи в LLM при неопределённом интенте:
 * списки сущностей (пользователи, локации, статусы заявок), чтобы модель могла ориентироваться в данных системы.
 */
class AssistantContextBuilder
{
    /** По умолчанию: макс. пользователей и локаций в контексте */
    private const DEFAULT_MAX_USERS = 30;
    private const DEFAULT_MAX_LOCATIONS = 20;

    /**
     * Собирает текстовый блок с актуальными сущностями из БД для вставки в системный промт LLM.
     *
     * @param array $options max_users, max_locations — лимиты выборки
     * @return string Текст вида «Контекст системы: Пользователи (ФИО): ...; Локации: ...; Статусы заявок: ...»
     */
    public static function buildRagContext(array $options = []): string
    {
        $maxUsers = (int) ($options['max_users'] ?? self::DEFAULT_MAX_USERS);
        $maxLocations = (int) ($options['max_locations'] ?? self::DEFAULT_MAX_LOCATIONS);

        $parts = [];

        $query = Users::find()
            ->select(['full_name'])
            ->orderBy(['full_name' => SORT_ASC])
            ->andWhere(['is_active' => true])
            ->limit($maxUsers);
        $schema = \Yii::$app->db->getTableSchema(Users::tableName());
        if ($schema && isset($schema->columns['is_deleted'])) {
            $query->andWhere(['is_deleted' => false]);
        }
        $users = $query->column();
        if (!empty($users)) {
            $parts[] = 'Пользователи (ФИО): ' . implode(', ', $users);
        }

        $locations = Location::find()
            ->select(['name', 'location_type'])
            ->where(['is_archived' => false])
            ->orderBy(['location_type' => SORT_ASC, 'name' => SORT_ASC])
            ->limit($maxLocations)
            ->asArray()
            ->all();
        if (!empty($locations)) {
            $locNames = array_map(function ($r) {
                return ($r['name'] ?? '') . ' (' . ($r['location_type'] ?? '') . ')';
            }, $locations);
            $parts[] = 'Локации: ' . implode(', ', $locNames);
        }

        $statuses = DicTaskStatus::find()
            ->select(['status_name'])
            ->orderBy(['sort_order' => SORT_ASC])
            ->asArray()
            ->all();
        if (!empty($statuses)) {
            $statusNames = array_column($statuses, 'status_name');
            $parts[] = 'Статусы заявок: ' . implode(', ', array_filter($statusNames));
        }

        if (empty($parts)) {
            return '';
        }

        return "Контекст системы (актуальные данные):\n" . implode(".\n", $parts) . '.';
    }
}
