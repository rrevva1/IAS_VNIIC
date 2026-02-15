<?php

namespace app\models\entities;

use yii\helpers\ArrayHelper;

/**
 * Список типов оборудования по данным из equipment.equipment_type (схема как в дампе, без таблицы equipment_types).
 */
class EquipmentTypes
{
    /**
     * Список для выпадающего списка: [значение => подпись].
     * @return array<string, string>
     */
    public static function getList(): array
    {
        $types = Equipment::find()
            ->select('equipment_type')
            ->distinct()
            ->where(['not', ['equipment_type' => null]])
            ->andWhere(['<>', 'equipment_type', ''])
            ->orderBy('equipment_type')
            ->column();
        return ArrayHelper::map($types, function ($v) { return $v; }, function ($v) { return $v; });
    }

    /**
     * Список для вкладок: [['id' => тип, 'name' => тип], ...].
     * @return array<int, array{id: string, name: string}>
     */
    public static function getListForTabs(): array
    {
        $types = Equipment::find()
            ->select('equipment_type')
            ->distinct()
            ->where(['not', ['equipment_type' => null]])
            ->andWhere(['<>', 'equipment_type', ''])
            ->orderBy('equipment_type')
            ->column();
        $result = [];
        foreach ($types as $name) {
            $result[] = ['id' => $name, 'name' => $name];
        }
        return $result;
    }
}
