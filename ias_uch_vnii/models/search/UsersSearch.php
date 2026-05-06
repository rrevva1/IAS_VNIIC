<?php

namespace app\models\search;

use app\models\entities\Users;
use yii\base\Model;
use yii\data\ActiveDataProvider;
use Yii;

/**
 * Поиск пользователей (схема tech_accounting: id, role через user_roles).
 */
class UsersSearch extends Users
{
    public function rules()
    {
        return [
            [['id', 'role_id'], 'integer'],
            [['full_name', 'email', 'username'], 'safe'],
        ];
    }

    public function scenarios()
    {
        return Model::scenarios();
    }

    public function search($params, $formName = null)
    {
        $query = Users::find();
        if (!Yii::$app->user->identity->isAdministrator()) {
            $query->where(['users.id' => Yii::$app->user->id]);
        }

        $dataProvider = new ActiveDataProvider([
            'query' => $query,
        ]);

        $this->load($params, $formName);

        if (!$this->validate()) {
            return $dataProvider;
        }

        $query->andFilterWhere(['users.id' => $this->id]);

        if ($this->role_id !== null && $this->role_id !== '') {
            $query->innerJoin('user_roles', 'user_roles.user_id = users.id')
                ->andWhere(['user_roles.role_id' => $this->role_id])
                ->andWhere(['user_roles.is_active' => true])
                ->andWhere(['user_roles.revoked_at' => null]);
        }

        $query->andFilterWhere(['ilike', 'users.full_name', $this->full_name])
            ->andFilterWhere(['ilike', 'users.email', $this->email])
            ->andFilterWhere(['ilike', 'users.username', $this->username]);

        return $dataProvider;
    }
}
