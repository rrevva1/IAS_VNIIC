<?php

namespace app\components;

use Yii;
use yii\db\Expression;
use yii\db\Query;

/**
 * Уникальные значения характеристик оборудования из part_char_values (для подсказок в формах).
 */
class EquipmentCharCatalog
{
    /**
     * Все известные модели процессоров (ЦП + «Модель» и синонимы частей/характеристик).
     *
     * @return string[]
     */
    public static function getDistinctCpuModels(): array
    {
        $db = Yii::$app->db;
        if (!$db->getTableSchema('part_char_values', true)) {
            return [];
        }

        try {
            $rows = (new Query())
                ->select(['value' => new Expression('TRIM(COALESCE(pcv.value_text, pcv.value_num::text))')])
                ->from(['pcv' => 'part_char_values'])
                ->innerJoin(['sp' => 'spr_parts'], 'sp.id = pcv.part_id')
                ->innerJoin(['sc' => 'spr_chars'], 'sc.id = pcv.char_id')
                ->andWhere(new Expression("TRIM(COALESCE(pcv.value_text, '')) <> ''"))
                ->andWhere(['or',
                    ['and', ['sp.name' => 'ЦП'], ['sc.name' => 'Модель']],
                    ['and', ['ilike', 'sp.name', 'процессор', false], ['or',
                        ['ilike', 'sc.name', 'модель', false],
                        ['ilike', 'sc.name', 'частот', false],
                    ]],
                    ['and', ['ilike', 'sp.name', 'cpu', false], ['ilike', 'sc.name', 'модель', false]],
                    ['and', ['sp.name' => 'ЦПУ'], ['or',
                        ['ilike', 'sc.name', 'модель', false],
                        ['ilike', 'sc.name', 'частот', false],
                    ]],
                ])
                ->groupBy([new Expression('TRIM(COALESCE(pcv.value_text, pcv.value_num::text))')])
                ->orderBy(['value' => SORT_ASC])
                ->column($db);
        } catch (\Throwable $e) {
            Yii::warning('EquipmentCharCatalog::getDistinctCpuModels: ' . $e->getMessage(), __METHOD__);
            return [];
        }

        $out = [];
        foreach ($rows as $row) {
            $v = trim((string) $row);
            if ($v !== '') {
                $out[] = $v;
            }
        }

        return $out;
    }

    /**
     * Текст для колонки «Монитор» в учёте ТС: привязанные мониторы + характеристика из part_char_values.
     *
     * @param array<int, array{id?: int, name?: string, inventory_number?: string}> $linkedMonitors
     */
    public static function formatMonitorColumnValue(string $charValue = '', array $linkedMonitors = []): string
    {
        $parts = [];
        foreach ($linkedMonitors as $item) {
            $label = self::formatLinkedEquipmentLabel($item);
            if ($label !== '' && !in_array($label, $parts, true)) {
                $parts[] = $label;
            }
        }

        $charValue = trim($charValue);
        if ($charValue !== '') {
            $covered = false;
            foreach ($parts as $part) {
                if ($part === $charValue
                    || mb_stripos($part, $charValue, 0, 'UTF-8') !== false
                    || mb_stripos($charValue, $part, 0, 'UTF-8') !== false
                ) {
                    $covered = true;
                    break;
                }
            }
            if (!$covered) {
                $parts[] = $charValue;
            }
        }

        return implode(', ', $parts);
    }

    /**
     * @param array{name?: string, inventory_number?: string} $item
     */
    public static function formatLinkedEquipmentLabel(array $item): string
    {
        $name = trim((string) ($item['name'] ?? ''));
        $inv = trim((string) ($item['inventory_number'] ?? ''));
        if ($name !== '' && $inv !== '') {
            return $name . ' (' . $inv . ')';
        }
        if ($name !== '') {
            return $name;
        }

        return $inv;
    }
}
