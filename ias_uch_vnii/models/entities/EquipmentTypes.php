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

        return ArrayHelper::map($types, function ($v) { return $v; }, function ($v) { return $v; });
    }

    /**
     * Список для вкладок: [['id' => тип, 'name' => тип], ...].
     * @return array<int, array{id: string, name: string}>
     */
    public static function getListForTabs(): array
    {
        $types = self::getNames();
        $result = [];
        foreach ($types as $name) {
            $result[] = ['id' => $name, 'name' => $name];
        }
        return $result;
    }

    public static function resolveIdByName(?string $name): ?int
    {
        $name = trim((string) $name);
        if ($name === '') {
            return null;
        }

        if (!self::usesDictionary()) {
            return null;
        }

        $id = (new Query())
            ->from('equipment_types')
            ->select('id')
            ->where(['name' => $name])
            ->scalar();

        return $id !== false ? (int) $id : null;
    }

    public static function resolveNameById(?int $id): ?string
    {
        if (!$id || !self::usesDictionary()) {
            return null;
        }

        $name = (new Query())
            ->from('equipment_types')
            ->select('name')
            ->where(['id' => $id])
            ->scalar();

        return $name !== false ? (string) $name : null;
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
