<?php

namespace app\models\search;

use app\models\entities\Equipment;
use yii\base\Model;
use yii\data\ActiveDataProvider;

/**
 * Поиск по оборудованию (таблица equipment, схема tech_accounting).
 */
class ArmSearch extends Model
{
    public $id;
    public $name;
    /** @var string|null Описание оборудования для фильтрации */
    public $description;
    public $responsible_user_id;
    public $location_id;
    public $inventory_number;
    /** @var int|null Статус оборудования */
    public $status_id;
    /** @var int|bool Показать архивные (0 = нет по умолчанию) */
    public $is_archived = 0;
    /** @var int|null Фильтр по типу техники (equipment_type_id) */
    public $equipment_type_id;

    public function rules()
    {
        return [
            [['id', 'responsible_user_id', 'location_id', 'status_id', 'equipment_type_id'], 'integer'],
            [['is_archived'], 'boolean'],
            [['name', 'description', 'inventory_number'], 'safe'],
        ];
    }

    public function scenarios()
    {
        return Model::scenarios();
    }

    public function search(array $params): ActiveDataProvider
    {
        $query = Equipment::find()->with(['responsibleUser', 'location']);

        $dataProvider = new ActiveDataProvider([
            'query' => $query,
            'pagination' => ['pageSize' => 20],
            'sort' => [
                'defaultOrder' => ['id' => SORT_DESC],
                'attributes' => ['id', 'name', 'responsible_user_id', 'location_id', 'created_at', 'inventory_number'],
            ],
        ]);

        $this->load($params);

        if (!$this->validate()) {
            return $dataProvider;
        }

        $query->andFilterWhere([
            'equipment.id' => $this->id,
            'responsible_user_id' => $this->responsible_user_id,
            'location_id' => $this->location_id,
            'status_id' => $this->status_id,
            'equipment.is_archived' => $this->is_archived,
        ]);

        if ($this->equipment_type_id !== null && $this->equipment_type_id !== '') {
            $query->andFilterWhere(['equipment.equipment_type_id' => $this->equipment_type_id]);
        }

        $query->andFilterWhere(['ilike', 'equipment.name', $this->name])
            ->andFilterWhere(['ilike', 'equipment.description', $this->description ?? ''])
            ->andFilterWhere(['ilike', 'equipment.inventory_number', $this->inventory_number]);

        return $dataProvider;
    }
}
