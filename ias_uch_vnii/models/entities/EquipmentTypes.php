<?php

namespace app\models\entities;

use yii\db\ActiveRecord;

/**
 * Справочник типов оборудования (equipment_types, схема tech_accounting).
 *
 * @property int $id
 * @property string $name
 * @property int $sort_order
 * @property bool $is_archived
 */
class EquipmentTypes extends ActiveRecord
{
    public static function tableName()
    {
        return 'equipment_types';
    }

    public function rules()
    {
        return [
            [['name'], 'required'],
            [['name'], 'string', 'max' => 100],
            [['sort_order'], 'integer'],
            [['is_archived'], 'boolean'],
        ];
    }

    public static function getList(): array
    {
        return \yii\helpers\ArrayHelper::map(
            self::find()->where(['is_archived' => false])->orderBy(['sort_order' => SORT_ASC])->all(),
            'id',
            'name'
        );
    }
}
