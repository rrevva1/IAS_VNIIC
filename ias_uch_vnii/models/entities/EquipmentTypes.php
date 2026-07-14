<?php

namespace app\models\entities;

use Yii;
use yii\helpers\ArrayHelper;
use yii\db\Query;

/**
 * Список типов оборудования.
 * Поддерживает обе схемы:
 * - старая: equipment.equipment_type
 * - текущая: equipment.equipment_type_id -> equipment_types.name
 */
class EquipmentTypes
{
    /** Типы, не используемые при создании записи (АРМ — комплект СБ+монитор+ИБП, не отдельный актив). */
    private const EXCLUDED_TYPE_NAMES = [
        'АРМ',
    ];

    /** Типы без отдельной вкладки на странице «Учёт ТС» (видны на «Вся техника»). */
    private const EXCLUDED_TAB_TYPE_NAMES = [
        'Прочее',
    ];

    /**
     * Типы для формы создания/редактирования (всегда в списке, даже если в БД ещё нет строк).
     * @var string[]
     */
    private const CANONICAL_TYPE_NAMES = [
        'Системный блок',
        'Ноутбук',
        'Моноблок',
        'Монитор',
        'Принтер',
        'МФУ',
        'ИБП',
        'Сканер',
        'Сервер',
        'Прочее',
    ];

    /** Подписи вкладок «Учёт ТС» (множественное число); ключ — значение equipment_type в БД. */
    private const TAB_LABELS_PLURAL = [
        'ПК' => 'ПК',
        'МФУ' => 'МФУ',
        'ИБП' => 'ИБП',
        'Системный блок' => 'Системные блоки',
        'Моноблок' => 'Моноблоки',
        'Монитор' => 'Мониторы',
        'Ноутбук' => 'Ноутбуки',
        'Принтер' => 'Принтеры',
        'Сканер' => 'Сканеры',
        'Сервер' => 'Серверы',
        'Прочее' => 'Прочее',
    ];

    /** Порядок вкладок на странице «Учёт ТС». */
    private const PREFERRED_TAB_TYPES = [
        'Системный блок',
        'Ноутбук',
        'Моноблок',
        'Монитор',
        'ИБП',
        'Принтер',
        'МФУ',
        'Сканер',
        'Сервер',
        'Прочее',
    ];

    /** Вкладки, которые показываются всегда (отдельная таблица по типу). */
    private const ALWAYS_VISIBLE_TAB_TYPES = [
        'Ноутбук',
        'Моноблок',
    ];

    /** На складе «Прочее» всегда в вкладках (там нет «Вся техника»). */
    private const WAREHOUSE_ALWAYS_VISIBLE_TAB_TYPES = [
        'Прочее',
    ];

    /**
     * Кеш для ускорения resolveNameById() при afterFind().
     * Формат: [equipment_type_id => name]
     *
     * @var array<int, string|null>
     */
    private static array $nameCacheById = [];

    public static function usesDictionary(): bool
    {
        $schema = Yii::$app->db->getTableSchema('equipment', true);
        return $schema !== null && isset($schema->columns['equipment_type_id']);
    }

    /**
     * Список для выпадающего списка: [значение => подпись].
     * @return array<string, string>
     */
    public static function getList(): array
    {
        $merged = [];
        foreach (array_merge(self::CANONICAL_TYPE_NAMES, self::getNames()) as $name) {
            $name = trim((string) $name);
            if ($name === '' || self::isExcludedTypeName($name)) {
                continue;
            }
            if (!isset($merged[$name])) {
                $merged[$name] = $name;
            }
        }
        if ($merged === []) {
            foreach (self::defaultTypeNames() as $name) {
                $merged[$name] = $name;
            }
        }

        return $merged;
    }

    public static function isExcludedTypeName(string $name): bool
    {
        return in_array(trim($name), self::EXCLUDED_TYPE_NAMES, true);
    }

    public static function isExcludedTabTypeName(string $name): bool
    {
        return in_array(trim($name), self::EXCLUDED_TAB_TYPE_NAMES, true);
    }

    /**
     * Базовый набор типов, если справочник/данные ещё пусты.
     * @return string[]
     */
    public static function defaultTypeNames(): array
    {
        return [
            'Системный блок',
            'Моноблок',
            'Монитор',
            'Ноутбук',
            'Принтер',
            'МФУ',
            'ИБП',
        ];
    }

    /**
     * Подпись вкладки по типу техники (множественное число для UI).
     */
    public static function getTabLabel(string $typeName): string
    {
        $typeName = trim($typeName);
        if ($typeName === '') {
            return '';
        }
        if (isset(self::TAB_LABELS_PLURAL[$typeName])) {
            return self::TAB_LABELS_PLURAL[$typeName];
        }

        $lower = mb_strtolower($typeName, 'UTF-8');
        if (mb_substr($lower, -2, 2, 'UTF-8') === 'ер') {
            return mb_substr($typeName, 0, -2, 'UTF-8') . 'еры';
        }
        if (mb_substr($lower, -1, 1, 'UTF-8') === 'к') {
            return $typeName . 'и';
        }
        if (mb_substr($lower, -1, 1, 'UTF-8') === 'р') {
            return $typeName . 'ы';
        }

        return $typeName;
    }

    /**
     * Список для вкладок: id — тип в БД, name — подпись во множественном числе.
     *
     * @param string|null $locationScope exclude_warehouse|warehouse_only|null
     * @return array<int, array{id: string, name: string}>
     */
    public static function getListForTabs(?string $locationScope = null): array
    {
        $fromDb = self::getNames();
        $seen = [];
        $ordered = [];
        $isWarehouse = $locationScope === 'warehouse_only';
        $alwaysVisible = self::ALWAYS_VISIBLE_TAB_TYPES;
        if ($isWarehouse) {
            $alwaysVisible = array_values(array_unique(array_merge(
                $alwaysVisible,
                self::WAREHOUSE_ALWAYS_VISIBLE_TAB_TYPES
            )));
        }

        foreach (self::PREFERRED_TAB_TYPES as $name) {
            if (self::isExcludedTypeName($name)) {
                continue;
            }
            if (self::isExcludedTabTypeName($name) && !($isWarehouse && $name === 'Прочее')) {
                continue;
            }
            $inDb = in_array($name, $fromDb, true);
            $forced = in_array($name, $alwaysVisible, true);
            if (!$inDb && !$forced) {
                continue;
            }
            if (!isset($seen[$name])) {
                $ordered[] = $name;
                $seen[$name] = true;
            }
        }

        foreach ($fromDb as $name) {
            if (self::isExcludedTypeName($name)) {
                continue;
            }
            if (self::isExcludedTabTypeName($name) && !($isWarehouse && $name === 'Прочее')) {
                continue;
            }
            if (!isset($seen[$name])) {
                $ordered[] = $name;
                $seen[$name] = true;
            }
        }

        $result = [];
        foreach ($ordered as $name) {
            $result[] = [
                'id' => $name,
                'name' => self::getTabLabel($name),
            ];
        }

        return $result;
    }

    public static function resolveIdByName(?string $name): ?int
    {
        $name = trim((string) $name);
        if ($name === '' || !self::usesDictionary()) {
            return null;
        }
        $id = (new Query())
            ->from('equipment_types')
            ->select('id')
            ->where(['name' => $name])
            ->scalar();
        return $id !== false ? (int) $id : null;
    }

    /**
     * Наименование типа оборудования по id справочника.
     * Используется в Equipment::afterFind().
     */
    public static function resolveNameById(?int $id): ?string
    {
        if ($id === null) {
            return null;
        }
        if (!self::usesDictionary()) {
            return null;
        }
        if (array_key_exists($id, self::$nameCacheById)) {
            return self::$nameCacheById[$id];
        }

        $name = (new Query())
            ->from('equipment_types')
            ->select('name')
            ->where(['id' => $id])
            ->scalar();

        $result = $name !== false ? (string) $name : null;
        self::$nameCacheById[$id] = $result;

        return $result;
    }

    private static function getNames(): array
    {
        if (self::usesDictionary()) {
            return (new Query())
                ->from('equipment_types')
                ->select('name')
                ->where(['not', ['name' => null]])
                ->andWhere(['<>', 'name', ''])
                ->orderBy(['sort_order' => SORT_ASC, 'name' => SORT_ASC])
                ->column();
        }

        return Equipment::find()
            ->select('equipment_type')
            ->distinct()
            ->where(['not', ['equipment_type' => null]])
            ->andWhere(['<>', 'equipment_type', ''])
            ->orderBy('equipment_type')
            ->column();
    }
}
