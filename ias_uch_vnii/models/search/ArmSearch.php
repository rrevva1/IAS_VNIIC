<?php

namespace app\models\search;

use app\models\entities\Arm;
use yii\base\Model;
use yii\data\ActiveDataProvider;

/**
 * ArmSearch — модель поиска для техники (АРМ).
 */
class ArmSearch extends Arm
{
    /**
     * Правила валидации полей поиска
     */
    public function rules()
    {
        return [
            [['id_arm', 'id_user', 'id_location'], 'integer'],
            [['name', 'description', 'created_at'], 'safe'],
        ];
    }

    /**
     * Сценарии
     */
    public function scenarios()
    {
        return Model::scenarios();
    }

    /**
     * Поиск по технике
     * @param array $params
     * @return ActiveDataProvider
     */
    public function search(array $params): ActiveDataProvider
    {
        $query = Arm::find()->with(['user', 'location']);

        $dataProvider = new ActiveDataProvider([
            'query' => $query,
            'pagination' => [
                'pageSize' => 20,
            ],
            'sort' => [
                'defaultOrder' => ['id_arm' => SORT_DESC],
                'attributes' => ['id_arm', 'name', 'id_user', 'id_location', 'created_at'],
            ],
        ]);

        $this->load($params);

        if (!$this->validate()) {
            return $dataProvider;
        }

        $query->andFilterWhere([
            'id_arm' => $this->id_arm,
            'id_user' => $this->id_user,
            'id_location' => $this->id_location,
        ]);

        $query->andFilterWhere(['ilike', 'name', $this->name]);
        $query->andFilterWhere(['ilike', 'description', $this->description]);

        return $dataProvider;
    }
}





