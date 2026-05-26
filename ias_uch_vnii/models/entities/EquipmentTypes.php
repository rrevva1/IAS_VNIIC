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
    /** Подписи вкладок «Учёт ТС» (множественное число); ключ — значение equipment_type в БД. */
    private const TAB_LABELS_PLURAL = [
        'АРМ' => 'АРМ',
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
    ];

    /** Порядок вкладок на странице «Учёт ТС». */
    private const PREFERRED_TAB_TYPES = [
        'АРМ',
        'Системный блок',
        'Ноутбук',
        'Моноблок',
        'Монитор',
        'ИБП',
        'Принтер',
        'МФУ',
        'Сканер',
        'Сервер',
    ];

    /** Вкладки, которые показываются всегда (отдельная таблица по типу). */
    private const ALWAYS_VISIBLE_TAB_TYPES = [
        'Ноутбук',
        'Моноблок',
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
        $types = self::getNames();
        if ($types === []) {
            $types = self::defaultTypeNames();
        }
        return ArrayHelper::map($types, static fn($v) => $v, static fn($v) => $v);
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
     * @return array<int, array{id: string, name: string}>
     */
    public static function getListForTabs(): array
    {
        $fromDb = self::getNames();
        $seen = [];
        $ordered = [];

        foreach (self::PREFERRED_TAB_TYPES as $name) {
            $inDb = in_array($name, $fromDb, true);
            $forced = in_array($name, self::ALWAYS_VISIBLE_TAB_TYPES, true);
            if (!$inDb && !$forced) {
                continue;
            }
            if (!isset($seen[$name])) {
                $ordered[] = $name;
                $seen[$name] = true;
            }
        }

        foreach ($fromDb as $name) {
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
