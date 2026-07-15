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
     * Известные модели аккумуляторов ИБП (часть «ИБП», характеристика «Модель аккумулятора»).
     *
     * @return string[]
     */
    public static function getDistinctUpsBatteryModels(): array
    {
        return self::fetchDistinctCharValues([
            ['and', ['sp.name' => 'ИБП'], ['sc.name' => 'Модель аккумулятора']],
            ['and', ['ilike', 'sp.name', 'ибп', false], ['ilike', 'sc.name', 'аккумулятор', false]],
            ['and', ['ilike', 'sp.name', 'ups', false], ['ilike', 'sc.name', 'battery', false]],
        ], 'EquipmentCharCatalog::getDistinctUpsBatteryModels');
    }

    public static function formatPartCharDateDisplay(string $value): string
    {
        $value = trim($value);
        if ($value === '') {
            return '';
        }
        if (preg_match('/^\d{4}-\d{2}-\d{2}$/', $value)) {
            $dt = \DateTime::createFromFormat('Y-m-d', $value);

            return $dt ? $dt->format('d.m.Y') : $value;
        }

        return $value;
    }

    public static function formatUpsBatteryServiceLifeDisplay(string $value): string
    {
        $value = trim($value);
        if ($value === '') {
            return '';
        }
        $normalized = str_replace(',', '.', $value);
        if (is_numeric($normalized) && !str_contains(mb_strtolower($value, 'UTF-8'), 'лет')) {
            $formatted = rtrim(rtrim(number_format((float) $normalized, 1, '.', ''), '0'), '.');

            return $formatted . ' лет';
        }

        return $value;
    }

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
     * Известные наименования техники (поле equipment.name).
     *
     * @return string[]
     */
    public static function getDistinctEquipmentNames(): array
    {
        $db = Yii::$app->db;
        if (!$db->getTableSchema('equipment', true)) {
            return [];
        }

        try {
            $rows = (new Query())
                ->select(['value' => new Expression('TRIM(name)')])
                ->from('equipment')
                ->where(['is_deleted' => false])
                ->andWhere(['not', ['name' => null]])
                ->andWhere(['<>', 'name', ''])
                ->groupBy([new Expression('TRIM(name)')])
                ->orderBy(['value' => SORT_ASC])
                ->column($db);
        } catch (\Throwable $e) {
            Yii::warning('EquipmentCharCatalog::getDistinctEquipmentNames: ' . $e->getMessage(), __METHOD__);

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
     * Известные инвентарные номера (для подсказок при создании и редактировании).
     *
     * @return string[]
     */
    public static function getDistinctInventoryNumbers(): array
    {
        $db = Yii::$app->db;
        if (!$db->getTableSchema('equipment', true)) {
            return [];
        }

        try {
            $rows = (new Query())
                ->select(['value' => new Expression('TRIM(inventory_number)')])
                ->from('equipment')
                ->where(['is_deleted' => false])
                ->andWhere(['not', ['inventory_number' => null]])
                ->andWhere(['<>', 'inventory_number', ''])
                ->groupBy([new Expression('TRIM(inventory_number)')])
                ->orderBy(['value' => SORT_ASC])
                ->column($db);
        } catch (\Throwable $e) {
            Yii::warning('EquipmentCharCatalog::getDistinctInventoryNumbers: ' . $e->getMessage(), __METHOD__);

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
     * Известные значения диагонали экрана (часть «Монитор», характеристика «Диагональ экрана»).
     *
     * @return string[]
     */
    public static function getDistinctScreenDiagonalValues(): array
    {
        return self::fetchDistinctCharValues([
            ['and', ['sp.name' => 'Монитор'], ['sc.name' => 'Диагональ экрана']],
            ['and', ['ilike', 'sp.name', 'монитор', false], ['ilike', 'sc.name', 'диагональ', false]],
        ], 'EquipmentCharCatalog::getDistinctScreenDiagonalValues');
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
     * Нормализация многострочного комментария: только края и переводы строк.
     */
    public static function normalizeEquipmentComment(?string $value): string
    {
        $value = str_replace(["\r\n", "\r"], "\n", (string) $value);

        return trim($value);
    }

    /**
     * Учёт для закупки картриджей (принтер / МФУ) из equipment.description.
     */
    public static function formatCartridgeProcurementStatus(?string $description): string
    {
        $code = self::parseCartridgeProcurementCode($description);
        if ($code === 'no') {
            return self::CARTRIDGE_NOT_ACCOUNTED_LABEL;
        }
        if ($code === 'yes') {
            return self::CARTRIDGE_ACCOUNTED_LABEL;
        }

        return '';
    }

    /**
     * Код для формы: yes | no | ''.
     */
    public static function parseCartridgeProcurementCode(?string $description): string
    {
        $description = self::normalizeEquipmentComment($description);
        if ($description === '') {
            return '';
        }

        if (self::isCartridgeNotAccountedPart($description)) {
            return 'no';
        }
        if (self::isCartridgeAccountedPart($description)) {
            return 'yes';
        }

        $firstLine = strtok($description, "\n");
        $firstLine = is_string($firstLine) ? trim($firstLine) : '';
        if ($firstLine !== '' && self::isCartridgeNotAccountedPart($firstLine)) {
            return 'no';
        }
        if ($firstLine !== '' && self::isCartridgeAccountedPart($firstLine)) {
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

        $comment = self::stripCartridgeProcurementFromDescription($comment);
        if ($comment !== '') {
            $parts[] = $comment;
        }

        if ($parts === []) {
            return null;
        }

        if (count($parts) === 1) {
            return $parts[0];
        }

        return $parts[0] . '; ' . $parts[1];
    }

    /**
     * Примечание принтера/МФУ без строки про учёт картриджей.
     */
    public static function formatPrinterComment(?string $description): string
    {
        return self::stripCartridgeProcurementFromDescription($description);
    }

    /**
     * Удаляет служебную метку учёта картриджей, не изменяя текст комментария.
     */
    public static function stripCartridgeProcurementFromDescription(?string $description): string
    {
        $description = self::normalizeEquipmentComment($description);
        if ($description === '') {
            return '';
        }

        if (self::isCartridgeAccountedPart($description) || self::isCartridgeNotAccountedPart($description)) {
            return '';
        }

        $prefixes = [
            self::CARTRIDGE_ACCOUNTED_STORAGE,
            self::CARTRIDGE_NOT_ACCOUNTED_STORAGE,
        ];
        foreach ($prefixes as $prefix) {
            $quoted = preg_quote($prefix, '/');
            $next = preg_replace('/^' . $quoted . '\s*;\s*/u', '', $description, 1);
            if (is_string($next) && $next !== $description) {
                return $next;
            }
        }

        return $description;
    }

    /**
     * Ключи PartChar с многострочным текстом (без обрезки переносов внутри значения).
     *
     * @return string[]
     */
    public static function getMultilinePartCharFieldNames(): array
    {
        return ['misc_description'];
    }

    public static function isPrinterOrMfuType(?string $equipmentType): bool
    {
        $type = trim((string) $equipmentType);

        return $type === 'Принтер' || $type === 'МФУ';
    }

    public static function isScannerType(?string $equipmentType): bool
    {
        return trim((string) $equipmentType) === 'Сканер';
    }

    public static function isServerType(?string $equipmentType): bool
    {
        return trim((string) $equipmentType) === 'Сервер';
    }

    /**
     * Дополнительные поля конфигурации сервера (после «Процессор»).
     *
     * @return array<int, array<string, mixed>>
     */
    public static function getServerExtraFormFieldDefinitions(): array
    {
        return [
            [
                'name' => 'cpu_count',
                'label' => 'Количество процессоров',
                'part' => 'ЦП',
                'char' => 'Количество процессоров',
                'widget' => 'choice-select',
                'options' => [
                    ['value' => '', 'label' => '— не указано —'],
                    ['value' => 'Один', 'label' => 'Один'],
                    ['value' => 'Два', 'label' => 'Два'],
                ],
            ],
        ];
    }

    /**
     * Вставляет поля сервера сразу после «Процессор (ЦП)».
     *
     * @param array<int, array<string, mixed>> $fields
     * @return array<int, array<string, mixed>>
     */
    public static function insertServerFieldsAfterCpu(array $fields): array
    {
        $extras = self::getServerExtraFormFieldDefinitions();
        if ($extras === []) {
            return $fields;
        }

        $out = [];
        foreach ($fields as $field) {
            $out[] = $field;
            if (($field['name'] ?? '') === 'cpu') {
                foreach ($extras as $extra) {
                    $out[] = $extra;
                }
            }
        }

        return $out;
    }

    /**
     * @return array<string, array{0: string, 1: string}>
     */
    public static function getServerPartCharSaveMap(): array
    {
        $map = [];
        foreach (self::getServerExtraFormFieldDefinitions() as $field) {
            $name = (string) ($field['name'] ?? '');
            $part = (string) ($field['part'] ?? '');
            $char = (string) ($field['char'] ?? '');
            if ($name === '' || $part === '' || $char === '') {
                continue;
            }
            $map[$name] = [$part, $char];
        }

        return $map;
    }

    /**
     * @return array<string, string>
     */
    public static function getServerCharDisplayLabels(): array
    {
        $labels = [];
        foreach (self::getServerExtraFormFieldDefinitions() as $field) {
            $name = (string) ($field['name'] ?? '');
            if ($name === '') {
                continue;
            }
            $labels[$name] = (string) ($field['label'] ?? $name);
        }

        return $labels;
    }

    public static function isMiscType(?string $equipmentType): bool
    {
        return trim((string) $equipmentType) === 'Прочее';
    }

    /**
     * Поля конфигурации типа «Прочее».
     *
     * @return array<int, array<string, mixed>>
     */
    public static function getMiscFormFieldDefinitions(): array
    {
        return [
            [
                'name' => 'misc_description',
                'label' => 'Комментарий к технике',
                'part' => 'Прочее',
                'char' => 'Описание',
                'widget' => 'textarea',
            ],
            [
                'name' => 'misc_ip',
                'label' => 'IP-адрес',
                'part' => 'Прочее',
                'char' => 'IP адрес',
                'widget' => 'ip-datalist',
            ],
        ];
    }

    /**
     * @return array<string, array{0: string, 1: string}>
     */
    public static function getMiscPartCharSaveMap(): array
    {
        $map = [];
        foreach (self::getMiscFormFieldDefinitions() as $field) {
            $name = (string) ($field['name'] ?? '');
            $part = (string) ($field['part'] ?? '');
            $char = (string) ($field['char'] ?? '');
            if ($name === '' || $part === '' || $char === '') {
                continue;
            }
            $map[$name] = [$part, $char];
        }

        return $map;
    }

    /**
     * @return array<string, string>
     */
    public static function getMiscPartCharKeyByCharName(): array
    {
        $out = [];
        foreach (self::getMiscFormFieldDefinitions() as $field) {
            $name = (string) ($field['name'] ?? '');
            $char = (string) ($field['char'] ?? '');
            if ($name !== '' && $char !== '') {
                $out[$char] = $name;
            }
        }

        return $out;
    }

    /**
     * @return array<string, string>
     */
    public static function getMiscCharDisplayLabels(): array
    {
        $labels = [];
        foreach (self::getMiscFormFieldDefinitions() as $field) {
            $name = (string) ($field['name'] ?? '');
            if ($name === '') {
                continue;
            }
            $labels[$name] = (string) ($field['label'] ?? $name);
        }

        return $labels;
    }

    /**
     * Шаблоны полей «Конфигурация» (учёт ТС и строки поставки).
     *
     * @param array<int, array<string, mixed>> $orgTechFields поля принтера/МФУ (с блоком OrgTech при необходимости)
     * @param bool $forDelivery без имени ПК и IP (строка поставки)
     * @return array{templates: array<string, array<int, array<string, mixed>>>, placeholders: array<string, string>}
     */
    public static function buildFormFieldTemplates(array $orgTechFields, bool $forDelivery = false): array
    {
        static $builder = null;
        if ($builder === null) {
            $builder = require Yii::getAlias('@app/views/arm/_form_field_templates_builder.php');
        }

        return $builder($orgTechFields, $forDelivery);
    }

    /**
     * Варианты «Максимальный размер бумаги» (принтер, МФУ, сканер).
     *
     * @return array<int, array{value: string, label: string}>
     */
    public static function getPaperSizeMaxChoiceOptions(): array
    {
        return [
            ['value' => '', 'label' => '— не указано —'],
            ['value' => 'A4', 'label' => 'A4'],
            ['value' => 'A3', 'label' => 'A3'],
            ['value' => 'A2', 'label' => 'A2'],
            ['value' => 'A1', 'label' => 'A1'],
            ['value' => 'A0', 'label' => 'A0'],
        ];
    }

    /**
     * Поля конфигурации принтера / МФУ (форма создания и редактирования).
     *
     * @return array<int, array<string, mixed>>
     */
    public static function getPrinterMfuFormFieldDefinitions(): array
    {
        $choice = static function (string $name, string $label, string $charName, array $options): array {
            return [
                'name' => $name,
                'label' => $label,
                'part' => 'Принтер',
                'char' => $charName,
                'widget' => 'choice-select',
                'options' => $options,
            ];
        };

        $notSpecified = ['value' => '', 'label' => '— не указано —'];

        return [
            [
                'name' => 'ip',
                'label' => 'IP-адрес / подключение',
                'part' => 'Принтер',
                'char' => 'IP адрес',
                'widget' => 'ip-datalist',
            ],
            $choice('paper_size_max', 'Максимальный размер бумаги', 'Максимальный размер бумаги', self::getPaperSizeMaxChoiceOptions()),
            $choice('print_technology', 'Технология печати', 'Технология печати', [
                $notSpecified,
                ['value' => 'Лазерный', 'label' => 'Лазерный'],
                ['value' => 'Струйный', 'label' => 'Струйный'],
            ]),
            $choice('print_color', 'Цветность', 'Цветность печати', [
                $notSpecified,
                ['value' => 'Чёрно-белый', 'label' => 'Чёрно-белый'],
                ['value' => 'Цветной', 'label' => 'Цветной'],
            ]),
            $choice('connection_type', 'Тип подключения', 'Подключение', [
                $notSpecified,
                ['value' => 'Сетевой', 'label' => 'Сетевой'],
                ['value' => 'USB', 'label' => 'USB'],
            ]),
            $choice('printer_wifi', 'Модуль Wi‑Fi', 'Модуль WiFi', [
                $notSpecified,
                ['value' => 'Да', 'label' => 'Есть'],
                ['value' => 'Нет', 'label' => 'Нет'],
                ['value' => 'Отключен', 'label' => 'Отключен'],
            ]),
            [
                'name' => 'printer_login',
                'label' => 'Логин',
                'part' => 'Принтер',
                'char' => 'Логин',
            ],
            [
                'name' => 'printer_password',
                'label' => 'Пароль',
                'part' => 'Принтер',
                'char' => 'Пароль',
            ],
        ];
    }

    /**
     * Поля конфигурации сканера (форма создания и редактирования).
     *
     * @return array<int, array<string, mixed>>
     */
    public static function getScannerFormFieldDefinitions(): array
    {
        $choice = static function (string $name, string $label, string $charName, array $options): array {
            return [
                'name' => $name,
                'label' => $label,
                'part' => 'Сканер',
                'char' => $charName,
                'widget' => 'choice-select',
                'options' => $options,
            ];
        };

        $notSpecified = ['value' => '', 'label' => '— не указано —'];

        return [
            $choice('scanner_type', 'Тип сканера', 'Тип сканера', [
                $notSpecified,
                ['value' => 'Многопоточный', 'label' => 'Многопоточный'],
                ['value' => 'Планшетный', 'label' => 'Планшетный'],
                ['value' => 'Комбинированный', 'label' => 'Комбинированный'],
            ]),
            $choice(
                'paper_size_max',
                'Максимальный размер бумаги',
                'Максимальный размер бумаги',
                self::getPaperSizeMaxChoiceOptions()
            ),
        ];
    }

    /**
     * Ключ поля формы PartChar[*] => [часть, характеристика] в spr_*.
     *
     * @return array<string, array{0: string, 1: string}>
     */
    public static function getPrinterMfuPartCharSaveMap(): array
    {
        $map = [];
        foreach (self::getPrinterMfuFormFieldDefinitions() as $field) {
            $name = (string) ($field['name'] ?? '');
            $part = (string) ($field['part'] ?? '');
            $char = (string) ($field['char'] ?? '');
            if ($name === '' || $part === '' || $char === '') {
                continue;
            }
            $map[$name] = [$part, $char];
        }

        return $map;
    }

    /**
     * Имя характеристики в БД => ключ поля формы.
     *
     * @return array<string, string>
     */
    public static function getPrinterMfuPartCharKeyByCharName(): array
    {
        $out = [];
        foreach (self::getPrinterMfuFormFieldDefinitions() as $field) {
            $name = (string) ($field['name'] ?? '');
            $char = (string) ($field['char'] ?? '');
            if ($name !== '' && $char !== '') {
                $out[$char] = $name;
            }
        }

        return $out;
    }

    /**
     * Подписи характеристик принтера / МФУ в карточке просмотра.
     *
     * @return array<string, string>
     */
    public static function getPrinterMfuCharDisplayLabels(): array
    {
        $labels = [];
        foreach (self::getPrinterMfuFormFieldDefinitions() as $field) {
            $name = (string) ($field['name'] ?? '');
            if ($name === '') {
                continue;
            }
            $labels[$name] = (string) ($field['label'] ?? $name);
        }

        return $labels;
    }

    /**
     * @return array<string, array{0: string, 1: string}>
     */
    public static function getScannerPartCharSaveMap(): array
    {
        $map = [];
        foreach (self::getScannerFormFieldDefinitions() as $field) {
            $name = (string) ($field['name'] ?? '');
            $part = (string) ($field['part'] ?? '');
            $char = (string) ($field['char'] ?? '');
            if ($name === '' || $part === '' || $char === '') {
                continue;
            }
            $map[$name] = [$part, $char];
        }

        return $map;
    }

    /**
     * @return array<string, string>
     */
    public static function getScannerPartCharKeyByCharName(): array
    {
        $out = [];
        foreach (self::getScannerFormFieldDefinitions() as $field) {
            $name = (string) ($field['name'] ?? '');
            $char = (string) ($field['char'] ?? '');
            if ($name !== '' && $char !== '') {
                $out[$char] = $name;
            }
        }

        return $out;
    }

    /**
     * Подписи характеристик сканера в карточке просмотра.
     *
     * @return array<string, string>
     */
    public static function getScannerCharDisplayLabels(): array
    {
        $labels = [];
        foreach (self::getScannerFormFieldDefinitions() as $field) {
            $name = (string) ($field['name'] ?? '');
            if ($name === '') {
                continue;
            }
            $labels[$name] = (string) ($field['label'] ?? $name);
        }

        return $labels;
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
        if ($name !== '') {
            return $name;
        }

        return trim((string) ($item['inventory_number'] ?? ''));
    }

    /**
     * Строки блока «Привязанная техника» на карточке хоста (ПК, системный блок и т.п.).
     *
     * @param array{monitor?: array<int, array<string, mixed>>, disk?: array<int, array<string, mixed>>, ups?: array<int, array<string, mixed>>} $linked
     * @param array<string, string> $chars
     * @return list<array{type_label: string, icon_class: string, id: ?int, label: string, inventory_number: string}>
     */
    public static function buildHostLinkedComponentsViewRows(
        array $linked,
        array $chars = [],
        bool $includeLegacyCharBindings = true
    ): array {
        $rows = [];
        $order = [
            'monitor' => 'Монитор',
            'ups' => 'ИБП',
            'disk' => 'Накопитель',
        ];

        foreach ($order as $key => $typeLabel) {
            foreach ($linked[$key] ?? [] as $item) {
                if (!is_array($item)) {
                    continue;
                }
                $label = self::formatLinkedEquipmentLabel($item);
                if ($label === '') {
                    continue;
                }
                $rows[] = [
                    'type_label' => $typeLabel,
                    'icon_class' => self::getLinkedComponentTypeIconClass($typeLabel),
                    'id' => isset($item['id']) ? (int) $item['id'] : null,
                    'label' => $label,
                    'inventory_number' => trim((string) ($item['inventory_number'] ?? '')),
                ];
            }
        }

        if ($includeLegacyCharBindings) {
            $hasMonitorLink = !empty($linked['monitor']);
            $legacyMonitor = trim((string) ($chars['monitor'] ?? ''));
            if (!$hasMonitorLink && $legacyMonitor !== '') {
                $legacyInv = trim((string) ($chars['monitor_inv'] ?? ''));
                $rows[] = [
                    'type_label' => 'Монитор',
                    'icon_class' => self::getLinkedComponentTypeIconClass('Монитор'),
                    'id' => null,
                    'label' => $legacyMonitor,
                    'inventory_number' => $legacyInv,
                ];
            }
        }

        return $rows;
    }

    public static function getLinkedComponentTypeIconClass(string $typeLabel): string
    {
        return match ($typeLabel) {
            'Монитор' => 'fa-tv',
            'ИБП' => 'fa-battery-full',
            'Накопитель' => 'fa-hard-drive',
            default => 'fa-link',
        };
    }

    /**
     * Класс иконки Font Awesome Solid по типу техники (для карточек и списков).
     * Используются только иконки из free-набора FA 6.0.
     */
    public static function getEquipmentTypeIconClass(?string $typeName): string
    {
        $t = mb_strtolower(trim((string) $typeName));
        if ($t === '') {
            return 'fa-desktop';
        }
        if (str_contains($t, 'монитор')) {
            return 'fa-tv';
        }
        if (str_contains($t, 'принтер') || str_contains($t, 'мфу')) {
            return 'fa-print';
        }
        if (str_contains($t, 'сканер')) {
            return 'fa-file-lines';
        }
        if ($t === 'прочее') {
            return 'fa-box';
        }
        if (str_contains($t, 'ибп') || str_contains($t, 'ups')) {
            return 'fa-battery-full';
        }
        if (str_contains($t, 'ноутбук')) {
            return 'fa-laptop';
        }
        if (str_contains($t, 'сервер')) {
            return 'fa-server';
        }
        if (str_contains($t, 'планшет')) {
            return 'fa-tablet';
        }
        if (str_contains($t, 'моноблок') || str_contains($t, 'системный') || str_contains($t, 'компьютер')) {
            return 'fa-desktop';
        }

        return 'fa-desktop';
    }

    /**
     * Иконка по типу; при пустом типе — эвристика по инвентарному номеру (mon, ups).
     */
    public static function resolveEquipmentTypeIconClass(?string $typeName, ?string $inventoryNumber = null): string
    {
        $type = trim((string) $typeName);
        if ($type !== '') {
            return self::getEquipmentTypeIconClass($type);
        }

        $inv = mb_strtolower(trim((string) $inventoryNumber));
        if ($inv !== '') {
            if (preg_match('/(?:^|[^a-z])mon(?:[^a-z]|$)|-mon-/u', $inv)) {
                return 'fa-tv';
            }
            if (preg_match('/(?:^|[^a-z])ups(?:[^a-z]|$)|-ups-/u', $inv)) {
                return 'fa-battery-full';
            }
        }

        return 'fa-desktop';
    }

    /**
     * Маппинг поля грида → [часть, характеристика] для фильтрации и сортировки.
     *
     * @return array<string, array{0: string, 1: string}>
     */
    public static function getArmGridPartCharFilterMap(): array
    {
        $map = [
            'cpu' => ['ЦП', 'Модель'],
            'ram' => ['ОЗУ', 'Объём'],
            'disk' => ['Накопитель', 'Объём'],
            'monitor' => ['Монитор', 'Модель'],
            'screen_diagonal' => ['Монитор', 'Диагональ экрана'],
            'hostname' => ['ПК', 'Имя ПК'],
            'ip' => ['ПК', 'IP адрес'],
            'os' => ['ПК', 'ОС'],
            'monitor_inv' => ['Монитор', '№ монитора'],
            'ups_battery' => ['ИБП', 'Модель аккумулятора'],
            'ups_battery_replaced_at' => ['ИБП', 'Дата замены аккумулятора'],
            'ups_battery_service_life' => ['ИБП', 'Срок службы аккумулятора'],
        ];

        foreach (self::getServerPartCharSaveMap() as $name => $pair) {
            $map[$name] = $pair;
        }
        foreach (self::getPrinterMfuPartCharSaveMap() as $name => $pair) {
            $map[$name] = $pair;
        }
        foreach (self::getScannerPartCharSaveMap() as $name => $pair) {
            $map[$name] = $pair;
        }

        return $map;
    }

    /**
     * Дополнительные поля part_char в строке грида (кроме базовых cpu/ram/…).
     *
     * @return string[]
     */
    public static function getArmGridExtraPartCharFields(): array
    {
        $skip = [
            'cpu', 'ram', 'disk', 'monitor', 'hostname', 'ip', 'os', 'screen_diagonal',
            'misc_description', 'misc_ip',
        ];
        $fields = [];

        $append = static function (array $definitions) use (&$fields, $skip): void {
            foreach ($definitions as $field) {
                $name = (string) ($field['name'] ?? '');
                if ($name === '' || in_array($name, $skip, true)) {
                    continue;
                }
                if (!in_array($name, $fields, true)) {
                    $fields[] = $name;
                }
            }
        };

        $append(self::getServerExtraFormFieldDefinitions());
        $append(self::getPrinterMfuFormFieldDefinitions());
        $append(self::getScannerFormFieldDefinitions());

        foreach (['monitor_inv', 'ups_battery', 'ups_battery_replaced_at', 'ups_battery_service_life'] as $name) {
            if (!in_array($name, $fields, true)) {
                $fields[] = $name;
            }
        }

        return $fields;
    }

    /**
     * Каталог настраиваемых столбцов грида «Учёт ТС» (группы и подписи).
     *
     * @return array{groups: array<int, array{id: string, title: string, icon: string, columns: string[]}>, labels: array<string, string>}
     */
    public static function getArmGridColumnCatalog(): array
    {
        $labels = [
            'user_name' => 'Пользователь',
            'previous_user_name' => 'Предыдущий пользователь',
            'location_name' => 'Помещение',
            'status_name' => 'Статус',
            'system_block' => 'Тип/Название техники',
            'inventory_number' => 'Инв. №',
            'purchase_date' => 'Дата закупки',
            'cpu' => 'ЦП',
            'ram' => 'ОЗУ',
            'disk' => 'Диск',
            'screen_diagonal' => 'Диагональ экрана',
            'monitor' => 'Монитор',
            'monitor_inv' => '№ монитора',
            'ups' => 'ИБП',
            'ups_battery' => 'Модель аккумулятора ИБП',
            'ups_battery_replaced_at' => 'Дата замены аккумулятора',
            'ups_battery_service_life' => 'Срок службы аккумулятора',
            'hostname' => 'Имя ПК',
            'ip' => 'IP адрес',
            'os' => 'ОС',
            'cartridge_procurement' => 'Закупка картриджей',
            'other_tech' => 'Комментарий',
        ];

        foreach (self::getServerCharDisplayLabels() as $name => $label) {
            $labels[$name] = $label;
        }
        foreach (self::getPrinterMfuCharDisplayLabels() as $name => $label) {
            $labels[$name] = $label;
        }
        foreach (self::getScannerCharDisplayLabels() as $name => $label) {
            $labels[$name] = $label;
        }

        $printerCols = [];
        foreach (self::getPrinterMfuFormFieldDefinitions() as $field) {
            $name = (string) ($field['name'] ?? '');
            if ($name === '' || $name === 'ip') {
                continue;
            }
            $printerCols[] = $name;
        }

        $scannerCols = [];
        foreach (self::getScannerFormFieldDefinitions() as $field) {
            $name = (string) ($field['name'] ?? '');
            if ($name === '' || $name === 'paper_size_max') {
                continue;
            }
            $scannerCols[] = $name;
        }

        $groups = [
            [
                'id' => 'base',
                'title' => 'Основное',
                'icon' => 'fa-id-card',
                'columns' => ['user_name', 'previous_user_name', 'location_name', 'status_name', 'system_block', 'inventory_number', 'purchase_date'],
            ],
            [
                'id' => 'config',
                'title' => 'Конфигурация',
                'icon' => 'fa-microchip',
                'columns' => ['cpu', 'cpu_count', 'ram', 'disk', 'screen_diagonal'],
            ],
            [
                'id' => 'periphery',
                'title' => 'Периферия',
                'icon' => 'fa-plug',
                'columns' => ['monitor', 'monitor_inv', 'ups', 'ups_battery', 'ups_battery_replaced_at', 'ups_battery_service_life'],
            ],
            [
                'id' => 'network',
                'title' => 'Сеть и ПО',
                'icon' => 'fa-network-wired',
                'columns' => ['hostname', 'ip', 'os'],
            ],
            [
                'id' => 'printer',
                'title' => 'Принтер / МФУ',
                'icon' => 'fa-print',
                'columns' => $printerCols,
            ],
            [
                'id' => 'scanner',
                'title' => 'Сканер',
                'icon' => 'fa-barcode',
                'columns' => $scannerCols,
            ],
            [
                'id' => 'extra',
                'title' => 'Дополнительно',
                'icon' => 'fa-comment-dots',
                'columns' => ['cartridge_procurement', 'other_tech'],
            ],
        ];

        return ['groups' => $groups, 'labels' => $labels];
    }
}
