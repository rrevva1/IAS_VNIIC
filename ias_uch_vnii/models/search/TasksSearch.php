<?php

namespace app\models\search;

use app\models\entities\Tasks;

use Yii;
use yii\base\Model;
use yii\data\ActiveDataProvider;

/**
 * TasksSearch представляет модель для формы поиска `app\models\Tasks`.
 */
class TasksSearch extends Tasks
{
    /**
     * @var string дата создания от
     */
    public $date_from;
    
    /**
     * @var string дата создания до
     */
    public $date_to;
    
    /**
     * @var string имя автора
     */
    public $user_name;
    
    /**
     * @var string имя исполнителя
     */
    public $executor_name;

    /**
     * Правила валидации
     */
    public function rules()
    {
        return [
            [['id', 'id_status', 'id_user', 'executor_id'], 'integer'],
            [['description', 'comment', 'date', 'last_time_update'], 'safe'],
            [['date_from', 'date_to'], 'date', 'format' => 'yyyy-MM-dd'],
            [['user_name', 'executor_name'], 'string'],
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
     *
     * @return ActiveDataProvider
     */
    public function search($params)
    {   IF(Yii::$app->user->identity->isAdministrator()) {
        $query = Tasks::find()
            ->joinWith(['user', 'executor', 'status']);
    } else {
        $query = Tasks::find()
            ->joinWith(['user', 'executor', 'status'])
            ->where(['tasks.id_user' => Yii::$app->user->id]);
           
    }
        // добавьте условия, которые должны применяться всегда

        $dataProvider = new ActiveDataProvider([
            'query' => $query,
            'sort' => [
                'defaultOrder' => ['id' => SORT_DESC],
                'attributes' => [
                    'id',
                    'description',
                    'date',
                    'last_time_update',
                    'user_name' => [
                        'asc' => ['users.full_name' => SORT_ASC],
                        'desc' => ['users.full_name' => SORT_DESC],
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
            'pagination' => [
                'pageSize' => 10, // Пагинация по 10 записей
            ],
        ]);

        $this->load($params);

        if (!$this->validate()) {
            // раскомментируйте следующую строку, если не хотите возвращать записи при неудачной валидации
            // $query->where('0=1');
            return $dataProvider;
        }

        // условия фильтрации grid
        $query->andFilterWhere([
            'tasks.id' => $this->id,
            'tasks.id_status' => $this->id_status,
            'tasks.id_user' => $this->id_user,
            'tasks.executor_id' => $this->executor_id,
        ]);

        $query->andFilterWhere(['like', 'tasks.description', $this->description])
            ->andFilterWhere(['like', 'tasks.comment', $this->comment]);

        // Фильтр по дате создания
        if ($this->date_from) {
            $query->andWhere(['>=', 'tasks.date', $this->date_from . ' 00:00:00']);
        }
        if ($this->date_to) {
            $query->andWhere(['<=', 'tasks.date', $this->date_to . ' 23:59:59']);
        }

        // Фильтр по имени автора
        if ($this->user_name) {
            $query->andWhere(['like', 'users.full_name', $this->user_name]);
        }

        // Фильтр по имени исполнителя
        if ($this->executor_name) {
            $query->andWhere(['like', 'executor.full_name', $this->executor_name]);
        }

        return $dataProvider;
    }

    /**
     * Метки атрибутов
     */
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
