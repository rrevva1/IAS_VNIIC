<?php

namespace app\models\entities;

use yii\helpers\ArrayHelper;

/**
 * Список типов оборудования из справочника equipment_types.
 */
class EquipmentTypes
{
    /**
     * Список для выпадающего списка: [id => name].
     * @return array<int|string, string>
     */
    public static function getList(): array
    {
        $rows = EquipmentType::find()
            ->where(['is_archived' => false])
            ->orderBy(['sort_order' => SORT_ASC, 'name' => SORT_ASC])
            ->all();
        return ArrayHelper::map($rows, 'id', 'name');
    }

    /**
     * Список для вкладок: [['id' => id, 'name' => name], ...].
     * @return array<int, array{id: int, name: string}>
     */
    public static function getListForTabs(): array
    {
        $rows = EquipmentType::find()
            ->where(['is_archived' => false])
            ->orderBy(['sort_order' => SORT_ASC, 'name' => SORT_ASC])
            ->all();
        $result = [];
        foreach ($rows as $t) {
            $result[] = ['id' => (int) $t->id, 'name' => $t->name];
        }
        return $result;
    }
}
