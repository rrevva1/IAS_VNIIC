<?php

namespace app\models\search;

use app\models\entities\Users;
use yii\base\Model;
use yii\data\ActiveDataProvider;
use Yii;
/**
 * UsersSearch представляет модель для формы поиска `app\models\Users`.
 */
class UsersSearch extends Users
{
    /**
     * Правила валидации
     */
    public function rules()
    {
        return [
            [['id_user', 'id_role'], 'integer'],
            [['full_name', 'email', 'password'], 'safe'],
        ];
    }

    /**
     * Сценарии модели
     */
    public function scenarios()
    {
        // обходим реализацию scenarios() в родительском классе
        return Model::scenarios();
    }

    /**
     * Создает экземпляр провайдера данных с примененным поисковым запросом
     *
     * @param array $params
     * @param string|null $formName Имя формы для использования в методе `->load()`.
     *
     * @return ActiveDataProvider
     */
    public function search($params, $formName = null)
    {
        if (Yii::$app->user->identity->isAdministrator()) {
        $query = Users::find();
        } else {
            $query = Users::find()->where(['id_user' => Yii::$app->user->id_user]);
        }
        // добавьте условия, которые должны применяться всегда

        $dataProvider = new ActiveDataProvider([
            'query' => $query,
        ]);

        $this->load($params, $formName);

        if (!$this->validate()) {
            // раскомментируйте следующую строку, если не хотите возвращать записи при неудачной валидации
            // $query->where('0=1');
            return $dataProvider;
        }

        // условия фильтрации grid
        $query->andFilterWhere([
            'id' => $this->id,
            'id_role' => $this->id_role,
        ]);

        $query->andFilterWhere(['ilike', 'full_name', $this->full_name])
            ->andFilterWhere(['ilike', 'email', $this->email])
            ->andFilterWhere(['ilike', 'password', $this->password]);

        return $dataProvider;
    }
}
