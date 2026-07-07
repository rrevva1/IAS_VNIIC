<?php

namespace app\models\dictionaries;

use yii\db\ActiveRecord;

/**
 * Справочник статусов оборудования (dic_equipment_status, схема tech_accounting).
 *
 * @property int $id
 * @property string $status_code
 * @property string $status_name
 * @property int $sort_order
 * @property bool $is_final
 * @property bool $is_archived
 */
class DicEquipmentStatus extends ActiveRecord
{
    public static function tableName()
    {
        return 'dic_equipment_status';
    }

    public function rules()
    {
        return [
            [['status_code', 'status_name'], 'required'],
            [['status_code'], 'string', 'max' => 50],
            [['status_name'], 'string', 'max' => 100],
            [['sort_order'], 'integer'],
            [['is_final', 'is_archived'], 'boolean'],
            [['status_code'], 'unique'],
        ];
    }

    public function attributeLabels()
    {
        return [
            'id' => 'ID',
            'status_code' => 'Код',
            'status_name' => 'Название',
        ];
    }

    /**
     * Список для выпадающего списка [id => status_name].
     */
    public static function getList(): array
    {
        return \yii\helpers\ArrayHelper::map(
            self::find()->orderBy(['sort_order' => SORT_ASC])->all(),
            'id',
            'status_name'
        );
    }

    /**
     * ID статуса по умолчанию (например, «В эксплуатации»).
     */
    public static function getDefaultId(): ?int
    {
        $row = self::find()->where(['status_code' => 'in_use'])->one();
        return $row ? (int) $row->id : null;
    }
}
