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
    /** Текст в equipment.description (как в импорте Excel). */
    public const CARTRIDGE_ACCOUNTED_STORAGE = 'Учтен';

    public const CARTRIDGE_NOT_ACCOUNTED_STORAGE = 'Не учтен';

    /** Подпись в форме, таблице и карточке. */
    public const CARTRIDGE_ACCOUNTED_LABEL = 'Учтен';

    public const CARTRIDGE_NOT_ACCOUNTED_LABEL = 'Не учтен';

    /**
     * Все известные модели процессоров (ЦП + «Модель» и синонимы частей/характеристик).
     *
     * @return string[]
     */
    public static function getDistinctCpuModels(): array
    {
        return self::fetchDistinctCharValues([
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
        ], 'EquipmentCharCatalog::getDistinctCpuModels');
    }

    /**
     * Известные поставщики из карточек оборудования (поле equipment.supplier).
     *
     * @return string[]
     */
    public static function getDistinctSuppliers(): array
    {
        $db = Yii::$app->db;
        if (!$db->getTableSchema('equipment', true)) {
            return [];
        }

        try {
            $rows = (new Query())
                ->select(['value' => new Expression('TRIM(supplier)')])
                ->from('equipment')
                ->where(['is_deleted' => false])
                ->andWhere(['not', ['supplier' => null]])
                ->andWhere(['<>', 'supplier', ''])
                ->groupBy([new Expression('TRIM(supplier)')])
                ->orderBy(['value' => SORT_ASC])
                ->column($db);
        } catch (\Throwable $e) {
            Yii::warning(__METHOD__ . ': ' . $e->getMessage(), __METHOD__);

            return [];
        }

        $out = [];
        foreach ($rows as $row) {
            $v = trim((string) $row);
            if ($v !== '' && !in_array($v, $out, true)) {
                $out[] = $v;
            }
        }

        sort($out, SORT_NATURAL | SORT_FLAG_CASE);

        return $out;
    }

    /**
     * Известные значения ОЗУ (часть «ОЗУ», характеристика «Объём» и синонимы).
     *
     * @return string[]
     */
    public static function getDistinctRamValues(): array
    {
        return self::fetchDistinctCharValues([
            ['and', ['sp.name' => 'ОЗУ'], ['sc.name' => 'Объём']],
            ['and', ['ilike', 'sp.name', 'оператив', false], ['or',
                ['ilike', 'sc.name', 'объем', false],
                ['ilike', 'sc.name', 'объём', false],
            ]],
            ['and', ['ilike', 'sp.name', 'память', false], ['or',
                ['ilike', 'sc.name', 'объем', false],
                ['ilike', 'sc.name', 'объём', false],
            ]],
            ['and', ['ilike', 'sp.name', 'ram', false], ['or',
                ['ilike', 'sc.name', 'объем', false],
                ['ilike', 'sc.name', 'объём', false],
            ]],
        ], __METHOD__);
    }

    /**
     * Известные операционные системы (часть «ПК», характеристика «ОС» и синонимы).
     *
     * @return string[]
     */
    public static function getDistinctOsValues(): array
    {
        return self::fetchDistinctCharValues([
            ['and', ['sp.name' => 'ПК'], ['sc.name' => 'ОС']],
            ['and', ['ilike', 'sp.name', 'пк', false], ['or',
                ['sc.name' => 'ОС'],
                ['ilike', 'sc.name', 'операционн', false],
            ]],
            ['ilike', 'sc.name', 'операционн', false],
        ], __METHOD__);
    }

    /**
     * Известные IP-адреса (ПК и принтеры/МФУ: «IP адрес» и синонимы).
     *
     * @return string[]
     */
    public static function getDistinctIpAddresses(): array
    {
        return self::fetchDistinctCharValues([
            ['and', ['sp.name' => 'ПК'], ['sc.name' => 'IP адрес']],
            ['and', ['sp.name' => 'ПК'], ['ilike', 'sc.name', 'ip', false]],
            ['and', ['sp.name' => 'Принтер'], ['sc.name' => 'IP адрес']],
            ['ilike', 'sc.name', 'ip адрес', false],
        ], __METHOD__);
    }

    /**
     * @param array<int, array|string> $partCharConditions
     * @return string[]
     */
    private static function fetchDistinctCharValues(array $partCharConditions, string $logContext): array
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
                ->andWhere(array_merge(['or'], $partCharConditions))
                ->groupBy([new Expression('TRIM(COALESCE(pcv.value_text, pcv.value_num::text))')])
                ->orderBy(['value' => SORT_ASC])
                ->column($db);
        } catch (\Throwable $e) {
            Yii::warning($logContext . ': ' . $e->getMessage(), __METHOD__);
            return [];
        }

        $out = [];
        foreach ($rows as $row) {
            $v = trim((string) $row);
            if ($v !== '' && !in_array($v, $out, true)) {
                $out[] = $v;
            }
        }

        sort($out, SORT_NATURAL | SORT_FLAG_CASE);

        return $out;
    }

    /**
     * Известные описания накопителей (тип «Накопитель», все характеристики).
     *
     * @return string[]
     */
    public static function getDistinctDiskModels(): array
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
                ->andWhere(new Expression("TRIM(COALESCE(pcv.value_text, '')) <> ''"))
                ->andWhere(['or',
                    ['sp.name' => 'Накопитель'],
                    ['ilike', 'sp.name', 'накопител', false],
                    ['ilike', 'sp.name', 'диск', false],
                    ['ilike', 'sp.name', 'hdd', false],
                    ['ilike', 'sp.name', 'ssd', false],
                ])
                ->groupBy([new Expression('TRIM(COALESCE(pcv.value_text, pcv.value_num::text))')])
                ->orderBy(['value' => SORT_ASC])
                ->column($db);
        } catch (\Throwable $e) {
            Yii::warning('EquipmentCharCatalog::getDistinctDiskModels: ' . $e->getMessage(), __METHOD__);
            return [];
        }

        $unique = [];
        foreach ($rows as $row) {
            foreach (self::parseDiskList((string) $row) as $item) {
                $unique[$item] = true;
            }
        }

        $out = array_keys($unique);
        sort($out, SORT_NATURAL | SORT_FLAG_CASE);

        return $out;
    }

    /**
     * Разбор списка дисков из ячейки Excel / part_char_values.
     *
     * @return string[]
     */
    public static function parseDiskList(?string $value): array
    {
        $value = trim((string) $value);
        if ($value === '') {
            return [];
        }
        $parts = preg_split('/\s*[,;]\s*/u', $value) ?: [];
        $out = [];
        foreach ($parts as $part) {
            $part = trim((string) $part);
            if ($part !== '' && !in_array($part, $out, true)) {
                $out[] = $part;
            }
        }

        return $out;
    }

    /**
     * Объединение списка дисков для сохранения в part_char_values.
     */
    public static function joinDiskList(array $disks): string
    {
        $out = [];
        foreach ($disks as $disk) {
            $disk = trim((string) $disk);
            if ($disk !== '' && !in_array($disk, $out, true)) {
                $out[] = $disk;
            }
        }

        return implode('; ', $out);
    }

    /**
     * Строки для колонки «Диск» в учёте ТС (характеристика + привязанные накопители).
     *
     * @param array<int, array{name?: string, inventory_number?: string}> $linkedDisks
     * @return string[]
     */
    public static function formatDiskGridLines(string $charValue = '', array $linkedDisks = []): array
    {
        $parts = [];
        foreach ($linkedDisks as $item) {
            $label = self::formatLinkedEquipmentLabel($item);
            if ($label !== '' && !in_array($label, $parts, true)) {
                $parts[] = $label;
            }
        }

        foreach (self::parseDiskList($charValue) as $disk) {
            $covered = false;
            foreach ($parts as $part) {
                if ($part === $disk
                    || mb_stripos($part, $disk, 0, 'UTF-8') !== false
                    || mb_stripos($disk, $part, 0, 'UTF-8') !== false
                ) {
                    $covered = true;
                    break;
                }
            }
            if (!$covered) {
                $parts[] = $disk;
            }
        }

        return $parts;
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
     * Учёт для закупки картриджей (принтер / МФУ) из equipment.description.
     */
    public static function formatCartridgeProcurementStatus(?string $description): string
    {
        foreach (self::splitDescriptionParts($description) as $part) {
            if (self::isCartridgeNotAccountedPart($part)) {
                return self::CARTRIDGE_NOT_ACCOUNTED_LABEL;
            }
            if (self::isCartridgeAccountedPart($part)) {
                return self::CARTRIDGE_ACCOUNTED_LABEL;
            }
        }

        $description = trim((string) $description);
        if ($description === '') {
            return '';
        }
        if (self::isCartridgeNotAccountedPart($description)) {
            return self::CARTRIDGE_NOT_ACCOUNTED_LABEL;
        }
        if (self::isCartridgeAccountedPart($description)) {
            return self::CARTRIDGE_ACCOUNTED_LABEL;
        }

        return '';
    }

    /**
     * Код для формы: yes | no | ''.
     */
    public static function parseCartridgeProcurementCode(?string $description): string
    {
        foreach (self::splitDescriptionParts($description) as $part) {
            if (self::isCartridgeNotAccountedPart($part)) {
                return 'no';
            }
            if (self::isCartridgeAccountedPart($part)) {
                return 'yes';
            }
        }

        $description = trim((string) $description);
        if ($description === '') {
            return '';
        }
        if (self::isCartridgeNotAccountedPart($description)) {
            return 'no';
        }
        if (self::isCartridgeAccountedPart($description)) {
            return 'yes';
        }

        return '';
    }

    /**
     * Сборка equipment.description для принтера/МФУ из формы.
     */
    public static function buildPrinterDescription(?string $code, ?string $comment): ?string
    {
        $parts = [];
        $code = trim((string) $code);
        if ($code === 'yes') {
            $parts[] = self::CARTRIDGE_ACCOUNTED_STORAGE;
        } elseif ($code === 'no') {
            $parts[] = self::CARTRIDGE_NOT_ACCOUNTED_STORAGE;
        }

        $comment = trim((string) $comment);
        if ($comment !== '') {
            $parts[] = $comment;
        }

        if ($parts === []) {
            return null;
        }

        return implode('; ', $parts);
    }

    /**
     * Примечание принтера/МФУ без строки про учёт картриджей.
     */
    public static function formatPrinterComment(?string $description): string
    {
        $parts = [];
        foreach (self::splitDescriptionParts($description) as $part) {
            if ($part === '') {
                continue;
            }
            if (self::isCartridgeAccountedPart($part) || self::isCartridgeNotAccountedPart($part)) {
                continue;
            }
            if (!in_array($part, $parts, true)) {
                $parts[] = $part;
            }
        }

        return implode('; ', $parts);
    }

    public static function isPrinterOrMfuType(?string $equipmentType): bool
    {
        $type = trim((string) $equipmentType);

        return $type === 'Принтер' || $type === 'МФУ';
    }

    /**
     * @return string[]
     */
    private static function splitDescriptionParts(?string $description): array
    {
        $description = trim((string) $description);
        if ($description === '') {
            return [];
        }
        $parts = preg_split('/\s*[;\n]\s*/u', $description) ?: [];
        $out = [];
        foreach ($parts as $part) {
            $part = trim((string) $part);
            if ($part !== '' && !in_array($part, $out, true)) {
                $out[] = $part;
            }
        }

        return $out;
    }

    private static function isCartridgeAccountedPart(string $part): bool
    {
        $part = trim($part);
        if (preg_match('/^учт[её]н$/ui', $part)) {
            return true;
        }

        return (bool) preg_match('/учт[её]н/ui', $part)
            && (bool) preg_match('/картридж/ui', $part)
            && !preg_match('/не\s+учт/ui', $part);
    }

    private static function isCartridgeNotAccountedPart(string $part): bool
    {
        $part = trim($part);
        if (preg_match('/^не\s+учт[её]н$/ui', $part)) {
            return true;
        }

        return (bool) preg_match('/не\s+учт/ui', $part) && (bool) preg_match('/картридж/ui', $part);
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
