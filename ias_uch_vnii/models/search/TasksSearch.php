<?php

namespace app\models\search;

use app\models\entities\Tasks;
use Yii;
use yii\base\Model;
use yii\data\ActiveDataProvider;

/**
 * Поиск заявок (схема tech_accounting: status_id, requester_id, executor_id, created_at).
 */
class TasksSearch extends Tasks
{
    public $date_from;
    public $date_to;
    public $user_name;
    public $executor_name;

    public function rules()
    {
        return [
            [['id', 'status_id', 'requester_id', 'executor_id'], 'integer'],
            [['description', 'comment', 'created_at', 'updated_at'], 'safe'],
            [['date_from', 'date_to'], 'date', 'format' => 'yyyy-MM-dd'],
            [['user_name', 'executor_name'], 'string'],
        ];
    }

    public function scenarios()
    {
        return Model::scenarios();
    }

    public function search($params)
    {
        $query = Tasks::find()->joinWith(['requester', 'executor', 'status']);
        if (!Yii::$app->user->identity->isAdministrator()) {
            $query->where(['tasks.requester_id' => Yii::$app->user->id]);
        }

        $dataProvider = new ActiveDataProvider([
            'query' => $query,
            'sort' => [
                'defaultOrder' => ['id' => SORT_DESC],
                'attributes' => [
                    'id',
                    'description',
                    'created_at',
                    'updated_at',
                    'user_name' => [
                        'asc' => ['requester.full_name' => SORT_ASC],
                        'desc' => ['requester.full_name' => SORT_DESC],
                    ],
                    'executor_name' => [
                        'asc' => ['executor.full_name' => SORT_ASC],
                        'desc' => ['executor.full_name' => SORT_DESC],
                    ],
                    'status_name' => [
                        'asc' => ['dic_task_status.status_name' => SORT_ASC],
                        'desc' => ['dic_task_status.status_name' => SORT_DESC],
                    ],
                ],
            ],
            'pagination' => ['pageSize' => 10],
        ]);

        $this->load($params);

        if (!$this->validate()) {
            return $dataProvider;
        }

        $query->andFilterWhere([
            'tasks.id' => $this->id,
            'tasks.status_id' => $this->status_id,
            'tasks.requester_id' => $this->requester_id,
            'tasks.executor_id' => $this->executor_id,
        ]);

        $query->andFilterWhere(['like', 'tasks.description', $this->description])
            ->andFilterWhere(['like', 'tasks.comment', $this->comment]);

        if ($this->date_from) {
            $query->andWhere(['>=', 'tasks.created_at', $this->date_from . ' 00:00:00']);
        }
        if ($this->date_to) {
            $query->andWhere(['<=', 'tasks.created_at', $this->date_to . ' 23:59:59']);
        }
        if ($this->user_name) {
            $query->andWhere(['like', 'requester.full_name', $this->user_name]);
        }
        if ($this->executor_name) {
            $query->andWhere(['like', 'executor.full_name', $this->executor_name]);
        }

        return $dataProvider;
    }

    public function attributeLabels()
    {
        return array_merge(parent::attributeLabels(), [
            'date_from' => 'Дата создания от',
            'date_to' => 'Дата создания до',
            'user_name' => 'Автор',
            'executor_name' => 'Исполнитель',
        ]);
    }
}
