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
            $choice('paper_size_max', 'Максимальный размер бумаги', 'Максимальный размер бумаги', [
                $notSpecified,
                ['value' => 'A6', 'label' => 'A6'],
                ['value' => 'A5', 'label' => 'A5'],
                ['value' => 'A4', 'label' => 'A4'],
                ['value' => 'A3', 'label' => 'A3'],
                ['value' => 'A2', 'label' => 'A2'],
                ['value' => 'A1', 'label' => 'A1'],
                ['value' => 'A0', 'label' => 'A0'],
            ]),
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
            ]),
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
        if ($name !== '') {
            return $name;
        }

        return trim((string) ($item['inventory_number'] ?? ''));
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
}
