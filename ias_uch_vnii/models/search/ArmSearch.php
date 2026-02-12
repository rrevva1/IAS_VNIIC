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
    public $responsible_user_id;
    public $location_id;
    public $inventory_number;

    public function rules()
    {
        return [
            [['id', 'responsible_user_id', 'location_id'], 'integer'],
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
        ]);

        $query->andFilterWhere(['ilike', 'equipment.name', $this->name])
            ->andFilterWhere(['ilike', 'equipment.description', $this->description ?? ''])
            ->andFilterWhere(['ilike', 'equipment.inventory_number', $this->inventory_number]);

        return $dataProvider;
    }
}
