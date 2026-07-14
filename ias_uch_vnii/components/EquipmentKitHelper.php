<?php

namespace app\components;

use app\models\entities\Equipment;
use app\models\entities\EquipmentTypes;
use app\models\entities\Location;

/**
 * Классификация техники для комплектов (хост, монитор, ИБП) и проверка склада.
 */
class EquipmentKitHelper
{
    /** @return string[] */
    public static function getKitHostEquipmentTypes(): array
    {
        return ['ПК', 'Моноблок', 'Системный блок', 'Ноутбук', 'Сервер'];
    }

    /** @return string[] */
    public static function getPeripheralEquipmentTypes(): array
    {
        return ['Монитор', 'ИБП', 'Принтер', 'МФУ', 'Сканер'];
    }

    /** @return string[] */
    public static function getHostEquipmentLabelPatterns(): array
    {
        return ['систем', 'system', 'моноблок', 'monoblock', 'ноутбук', 'ноут', 'laptop', 'пк', 'computer'];
    }

    public static function isWarehouseLocationId(int $locationId): bool
    {
        $location = Location::findOne($locationId);
        if ($location === null) {
            return false;
        }

        return (string) $location->location_type === 'склад';
    }

    public static function isEquipmentOnWarehouse(Equipment $model): bool
    {
        $locationId = $model->location_id;
        if ($locationId === null || (int) $locationId <= 0) {
            return false;
        }

        return self::isWarehouseLocationId((int) $locationId);
    }

    public static function isHostEquipment(Equipment $equipment): bool
    {
        $type = trim((string) $equipment->equipment_type);
        if (in_array($type, self::getPeripheralEquipmentTypes(), true)) {
            return false;
        }
        if (in_array($type, self::getKitHostEquipmentTypes(), true)) {
            return true;
        }

        $name = mb_strtolower(trim((string) $equipment->name), 'UTF-8');
        $typeLower = mb_strtolower($type, 'UTF-8');
        foreach (self::getHostEquipmentLabelPatterns() as $pattern) {
            if ($typeLower !== '' && mb_strpos($typeLower, $pattern, 0, 'UTF-8') !== false) {
                return true;
            }
            if ($name !== '' && mb_strpos($name, $pattern, 0, 'UTF-8') !== false) {
                return true;
            }
        }

        return false;
    }

    public static function isMonitorEquipment(Equipment $equipment): bool
    {
        if (self::isHostEquipment($equipment)) {
            return false;
        }

        return self::matchesEquipmentPatterns($equipment, ['монитор', 'monitor']);
    }

    public static function isUpsEquipment(Equipment $equipment): bool
    {
        if (self::isHostEquipment($equipment)) {
            return false;
        }

        return self::matchesEquipmentPatterns($equipment, ['ибп', 'ups']);
    }

    /**
     * @param string[] $patterns
     */
    private static function matchesEquipmentPatterns(Equipment $equipment, array $patterns): bool
    {
        $name = mb_strtolower(trim((string) $equipment->name), 'UTF-8');
        $typeLower = mb_strtolower(trim((string) $equipment->equipment_type), 'UTF-8');
        foreach ($patterns as $pattern) {
            if ($typeLower !== '' && mb_strpos($typeLower, $pattern, 0, 'UTF-8') !== false) {
                return true;
            }
            if ($name !== '' && mb_strpos($name, $pattern, 0, 'UTF-8') !== false) {
                return true;
            }
        }

        return false;
    }

    /**
     * Условие SQL для выборки хостов.
     *
     * @return array<int|string, mixed>
     */
    public static function buildHostEquipmentSqlCondition(string $equipmentAlias, ?string $typeTableAlias = null): array
    {
        $or = ['or'];
        foreach (self::getHostEquipmentLabelPatterns() as $pattern) {
            $or[] = ['ilike', $equipmentAlias . '.name', $pattern];
            $or[] = ['ilike', $equipmentAlias . '.equipment_type', $pattern];
            if ($typeTableAlias !== null) {
                $or[] = ['ilike', $typeTableAlias . '.name', $pattern];
            }
        }

        return $or;
    }

    public static function formatEquipmentOptionLabel(Equipment $equipment, bool $withWarehouseLocation = false): string
    {
        $inv = trim((string) $equipment->inventory_number);
        $name = trim((string) $equipment->name);
        $parts = [];
        if ($name !== '') {
            $parts[] = $name;
        }
        if ($inv !== '') {
            $parts[] = $inv;
        }
        if ($parts === []) {
            $base = 'Техника #' . (int) $equipment->id;
        } else {
            $base = implode(' · ', $parts);
        }

        if (!$withWarehouseLocation) {
            return $base;
        }

        $locationName = trim((string) ($equipment->location->name ?? ''));
        if ($locationName !== '') {
            return $base . ' · ' . $locationName;
        }

        return $base;
    }

    /**
     * @return array<string, mixed>
     */
    public static function equipmentToOptionRow(Equipment $equipment): array
    {
        $location = $equipment->location;

        return [
            'id' => (int) $equipment->id,
            'inventory_number' => $equipment->inventory_number,
            'name' => $equipment->name,
            'serial_number' => $equipment->serial_number,
            'equipment_type' => $equipment->equipment_type,
            'location_id' => $equipment->location_id !== null ? (int) $equipment->location_id : null,
            'location_name' => $location ? $location->name : null,
            'label' => self::formatEquipmentOptionLabel($equipment, true),
        ];
    }
}
