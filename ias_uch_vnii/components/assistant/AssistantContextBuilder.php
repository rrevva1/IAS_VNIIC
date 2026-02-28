<?php

namespace app\components\assistant;

use app\models\dictionaries\DicTaskStatus;
use app\models\entities\Equipment;
use app\models\entities\EquipmentType;
use app\models\entities\Location;
use app\models\entities\Users;
use Yii;
use yii\db\Expression;
use yii\db\Query;

/**
 * Формирует RAG-контекст для передачи в LLM при неопределённом интенте:
 * списки сущностей (пользователи, локации, статусы заявок), сводка по технике с характеристиками (ЦП, ОЗУ, дата),
 * чтобы модель могла ориентироваться в данных системы и отвечать на аналитические запросы («самый мощный процессор», «самый новый»).
 */
class AssistantContextBuilder
{
    /** По умолчанию: макс. пользователей и локаций в контексте */
    private const DEFAULT_MAX_USERS = 30;
    private const DEFAULT_MAX_LOCATIONS = 20;
    /** Макс. единиц техники в сводке и макс. длина блока (символов) */
    private const DEFAULT_MAX_EQUIPMENT_SUMMARY = 15;
    private const DEFAULT_MAX_EQUIPMENT_SUMMARY_LENGTH = 2500;

    /**
     * Собирает текстовый блок с актуальными сущностями из БД для вставки в системный промт LLM.
     *
     * @param array $options max_users, max_locations — лимиты выборки; include_equipment_summary — добавить сводку по технике с характеристиками (ЦП, ОЗУ, дата), по умолчанию true
     * @return string Текст вида «Контекст системы: Пользователи (ФИО): ...; Локации: ...; Статусы заявок: ...; Примеры техники с характеристиками: ...»
     */
    public static function buildRagContext(array $options = []): string
    {
        $maxUsers = (int) ($options['max_users'] ?? self::DEFAULT_MAX_USERS);
        $maxLocations = (int) ($options['max_locations'] ?? self::DEFAULT_MAX_LOCATIONS);
        $includeEquipmentSummary = ($options['include_equipment_summary'] ?? true) !== false;

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

        $locations = Location::find()
            ->select(['name', 'location_type'])
            ->where(['is_archived' => false])
            ->orderBy(['location_type' => SORT_ASC, 'name' => SORT_ASC])
            ->limit($maxLocations)
            ->asArray()
            ->all();

        $statuses = DicTaskStatus::find()
            ->select(['status_name'])
            ->orderBy(['sort_order' => SORT_ASC])
            ->asArray()
            ->all();

        $blocks = [];
        if (!empty($users)) {
            $blocks[] = "Сущность: Пользователи (ФИО)\n" . implode(', ', $users);
        }
        if (!empty($locations)) {
            $locNames = array_map(function ($r) {
                return ($r['name'] ?? '') . ' (' . ($r['location_type'] ?? '') . ')';
            }, $locations);
            $blocks[] = "Сущность: Локации\n" . implode(', ', $locNames);
        }
        if (!empty($statuses)) {
            $statusNames = array_column($statuses, 'status_name');
            $blocks[] = "Сущность: Статусы заявок\n" . implode(', ', array_filter($statusNames));
        }
        if ($includeEquipmentSummary) {
            $equipmentBlock = self::buildEquipmentSummary($options);
            if ($equipmentBlock !== '') {
                $blocks[] = "Сущность: Технические средства (примеры с характеристиками)\n" . $equipmentBlock;
            }
        }

        if (empty($blocks)) {
            return '';
        }

        $header = "Контекст системы (актуальные данные). Используй для ответа только эти данные.\n\n";
        $orientationBlock = self::buildSystemOrientationBlock($options);
        $entitiesBlock = implode("\n\n", $blocks);
        return $header . ($orientationBlock !== '' ? $orientationBlock . "\n\n" : '') . $entitiesBlock;
    }

    /**
     * Блок «Описание системы» для ориентации модели: назначение ИАС, разделы, сводные цифры.
     *
     * @param array $options include_orientation_stats — добавлять сводку (по умолчанию из params)
     * @return string
     */
    public static function buildSystemOrientationBlock(array $options = []): string
    {
        $params = Yii::$app->params;
        $customDesc = $params['assistant_system_description'] ?? '';
        if (is_string($customDesc) && trim($customDesc) !== '') {
            $description = trim($customDesc);
        } else {
            $description = "Информационно-аналитическая система (ИАС) учёта технических средств предприятия. "
                . "Назначение: учёт технических средств, заявок на обслуживание и ремонт, привязка техники к ответственным сотрудникам и к местам размещения (локациям). "
                . "Разделы интерфейса: Заявки (обращения пользователей), Технические средства (АРМ — единицы учёта с характеристиками), Локации (кабинеты, склады, серверные), Пользователи (ответственные), Справка.";
        }

        $includeStats = ($options['include_orientation_stats'] ?? null) !== false
            && !empty($params['assistant_orientation_include_stats'] ?? true);

        $lines = ["Сущность: Описание системы (для ориентации)\n" . $description];

        if ($includeStats) {
            $stats = self::getSystemStats();
            if ($stats !== '') {
                $lines[] = "Сводка по системе:\n" . $stats;
            }
        }

        return implode("\n\n", $lines);
    }

    /**
     * Сводные цифры по системе для ориентации модели.
     *
     * @return string
     */
    private static function getSystemStats(): string
    {
        try {
            $eqCount = (int) Equipment::find()
                ->where(['is_archived' => false, 'is_deleted' => false])
                ->count();
            $locCount = (int) Location::find()->where(['is_archived' => false])->count();
            $userQuery = Users::find()->andWhere(['is_active' => true]);
            $userSchema = Yii::$app->db->getTableSchema(Users::tableName(), true);
            if ($userSchema && isset($userSchema->columns['is_deleted'])) {
                $userQuery->andWhere(['is_deleted' => false]);
            }
            $userCount = (int) $userQuery->count();

            $parts = ["всего единиц техники: {$eqCount}", "локаций: {$locCount}", "пользователей: {$userCount}"];

            $typeRows = (new Query())
                ->select(['type_name' => 'et.name', 'cnt' => 'COUNT(e.id)'])
                ->from(['e' => Equipment::tableName()])
                ->leftJoin(['et' => EquipmentType::tableName()], 'et.id = e.equipment_type_id')
                ->where(['e.is_archived' => false, 'e.is_deleted' => false])
                ->groupBy(['e.equipment_type_id', 'et.name'])
                ->orderBy(['cnt' => SORT_DESC])
                ->limit(10)
                ->all(Yii::$app->db);
            if (!empty($typeRows)) {
                $typeParts = [];
                foreach ($typeRows as $r) {
                    $name = trim((string) ($r['type_name'] ?? ''));
                    if ($name === '') {
                        $name = 'Без типа';
                    }
                    $typeParts[] = $name . ' — ' . (int) $r['cnt'];
                }
                $parts[] = 'по типам техники: ' . implode(', ', $typeParts);
            }

            return implode('; ', $parts);
        } catch (\Throwable $e) {
            return '';
        }
    }

    /**
     * Сводка по технике с характеристиками (ЦП, ОЗУ, дата) для аналитических запросов («самый мощный процессор», «самый новый»).
     *
     * @param array $options max_units — макс. единиц (по умолчанию 15), max_length — макс. длина блока в символах (2500)
     * @return string Текст вида «Примеры техники с характеристиками: ПК-1 (инв. X): ЦП ...; ОЗУ ...; дата ...»
     */
    public static function buildEquipmentSummary(array $options = []): string
    {
        $maxUnits = (int) ($options['max_equipment_units'] ?? $options['max_units'] ?? self::DEFAULT_MAX_EQUIPMENT_SUMMARY);
        $maxLength = (int) ($options['max_equipment_summary_length'] ?? $options['max_length'] ?? self::DEFAULT_MAX_EQUIPMENT_SUMMARY_LENGTH);
        if ($maxUnits < 1 || $maxLength < 50) {
            return '';
        }

        $query = Equipment::find()
            ->select(['id', 'name', 'inventory_number', 'created_at', 'commissioning_date'])
            ->where(['is_archived' => false, 'is_deleted' => false])
            ->orderBy(['id' => SORT_DESC])
            ->limit($maxUnits)
            ->asArray();
        $schema = \Yii::$app->db->getTableSchema(Equipment::tableName());
        if ($schema && isset($schema->columns['is_deleted'])) {
            $query->andWhere(['is_deleted' => false]);
        }
        $equipment = $query->all();
        if (empty($equipment)) {
            return '';
        }

        $ids = array_column($equipment, 'id');
        $charsByEq = self::loadPartCharValuesByEquipmentIds($ids);
        $lines = [];
        foreach ($equipment as $row) {
            $id = (int) $row['id'];
            $name = trim((string) ($row['name'] ?? ''));
            $inv = trim((string) ($row['inventory_number'] ?? ''));
            $date = !empty($row['commissioning_date']) ? $row['commissioning_date'] : ($row['created_at'] ?? '');
            $ch = $charsByEq[$id] ?? [];
            $cpu = isset($ch['cpu']) ? trim((string) $ch['cpu']) : '';
            $ram = isset($ch['ram']) ? trim((string) $ch['ram']) : '';
            $disk = isset($ch['disk']) ? trim((string) $ch['disk']) : '';
            $parts = [];
            if ($name !== '') {
                $parts[] = $name;
            }
            if ($inv !== '') {
                $parts[] = '(инв. ' . $inv . ')';
            }
            $line = implode(' ', $parts);
            if ($cpu !== '') {
                $line .= ': ЦП ' . $cpu;
            }
            if ($ram !== '') {
                $line .= ($line !== '' ? '; ' : ': ') . 'ОЗУ ' . $ram;
            }
            if ($disk !== '') {
                $line .= ($line !== '' ? '; ' : ': ') . 'Диск ' . $disk;
            }
            if ($date !== '') {
                $line .= ($line !== '' ? '; ' : ': ') . 'дата ' . $date;
            }
            if ($line !== '') {
                $lines[] = '- ' . $line;
            }
        }
        if (empty($lines)) {
            return '';
        }
        $block = "Примеры техники с характеристиками (для запросов вроде «самый мощный процессор», «самый новый»):\n" . implode("\n", $lines);
        if (mb_strlen($block) > $maxLength) {
            $block = mb_substr($block, 0, $maxLength - 3) . '…';
        }
        return $block;
    }

    /**
     * Загружает характеристики (ЦП, ОЗУ, диск и т.д.) по списку ID оборудования.
     *
     * @param int[] $equipmentIds
     * @return array<int, array{cpu?: string, ram?: string, disk?: string}>
     */
    private static function loadPartCharValuesByEquipmentIds(array $equipmentIds): array
    {
        if (empty($equipmentIds)) {
            return [];
        }
        $db = Yii::$app->db;
        $idCol = 'equipment_id';
        try {
            $schema = $db->getTableSchema('part_char_values', true);
            if ($schema && !isset($schema->columns['equipment_id']) && isset($schema->columns['id_arm'])) {
                $idCol = 'id_arm';
            }
        } catch (\Throwable $e) {
            return array_fill_keys($equipmentIds, []);
        }
        try {
            $rows = (new Query())
                ->select([
                    'eq_id' => 'pcv.' . $idCol,
                    'part_name' => 'sp.name',
                    'char_name' => 'sc.name',
                    'value_text' => new Expression('COALESCE(pcv.value_text, pcv.value_num::text)'),
                ])
                ->from(['pcv' => 'part_char_values'])
                ->innerJoin(['sp' => 'spr_parts'], 'sp.id = pcv.part_id')
                ->innerJoin(['sc' => 'spr_chars'], 'sc.id = pcv.char_id')
                ->where(['pcv.' . $idCol => $equipmentIds])
                ->all($db);
        } catch (\Throwable $e) {
            return array_fill_keys($equipmentIds, []);
        }
        $out = array_fill_keys($equipmentIds, []);
        foreach ($rows as $row) {
            $id = (int) $row['eq_id'];
            if (!isset($out[$id])) {
                continue;
            }
            $part = trim((string) ($row['part_name'] ?? ''));
            $char = trim((string) ($row['char_name'] ?? ''));
            $val = trim((string) ($row['value_text'] ?? ''));
            if ($val === '') {
                continue;
            }
            $p = mb_strtolower($part, 'UTF-8');
            $c = mb_strtolower($char, 'UTF-8');
            if ($part === 'ЦП' && $char === 'Модель') {
                $out[$id]['cpu'] = $val;
                continue;
            }
            if ($part === 'ОЗУ' && $char === 'Объём') {
                $out[$id]['ram'] = $val;
                continue;
            }
            if ($part === 'Накопитель') {
                $out[$id]['disk'] = isset($out[$id]['disk']) ? $out[$id]['disk'] . ', ' . $val : $val;
                continue;
            }
            if (($p === 'цп' || $p === 'цпу' || strpos($p, 'процессор') !== false || $p === 'cpu') && (strpos($c, 'модель') !== false || strpos($c, 'частота') !== false)) {
                $out[$id]['cpu'] = isset($out[$id]['cpu']) ? $out[$id]['cpu'] . ' ' . $val : $val;
            } elseif (($p === 'озу' || strpos($p, 'оператив') !== false || $p === 'ram') && (strpos($c, 'объем') !== false || strpos($c, 'объём') !== false)) {
                $out[$id]['ram'] = $val;
            } elseif (strpos($p, 'диск') !== false || strpos($p, 'накопитель') !== false) {
                $out[$id]['disk'] = isset($out[$id]['disk']) ? $out[$id]['disk'] . ', ' . $val : $val;
            }
        }
        return $out;
    }
}
