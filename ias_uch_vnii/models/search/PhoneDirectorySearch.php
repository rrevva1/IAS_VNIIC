<?php

namespace app\models\search;

use app\models\entities\PhoneDirectory;
use Yii;
use yii\base\Model;
use yii\data\ActiveDataProvider;

/**
 * Поиск по телефонному справочнику.
 */
class PhoneDirectorySearch extends PhoneDirectory
{
    /** @var string all|my_department|with_phone|service */
    public $filter = 'all';

    /** @var string|null Быстрый поиск по нескольким полям */
    public $q;

    public function rules()
    {
        return [
            [['id', 'user_id', 'sort_order'], 'integer'],
            [['full_name', 'position', 'department', 'room', 'internal_phone', 'external_phone', 'entry_type', 'filter', 'q'], 'safe'],
            [['is_published'], 'boolean'],
        ];
    }

    public function scenarios()
    {
        return Model::scenarios();
    }

    public function search($params, bool $publishedOnly = true): ActiveDataProvider
    {
        $query = PhoneDirectory::find();

        if ($publishedOnly) {
            $query->andWhere(['phone_directory.is_published' => true]);
        }

        $dataProvider = new ActiveDataProvider([
            'query' => $query,
            'pagination' => false,
            'sort' => [
                'defaultOrder' => [
                    'sort_order' => SORT_ASC,
                    'full_name' => SORT_ASC,
                ],
            ],
        ]);

        $this->load($params, '');

        if (!$this->validate()) {
            return $dataProvider;
        }

        $filter = (string) ($this->filter ?: 'all');
        if ($filter === 'my_department') {
            $identity = Yii::$app->user->identity;
            $department = $identity && !empty($identity->department) ? (string) $identity->department : null;
            if ($department !== null) {
                $query->andWhere(['ilike', 'phone_directory.department', $department]);
            } else {
                $query->andWhere('1=0');
            }
        } elseif ($filter === 'with_phone') {
            $query->andWhere(['and',
                ['not', ['phone_directory.internal_phone' => null]],
                ['<>', 'phone_directory.internal_phone', ''],
            ]);
        } elseif ($filter === 'service') {
            $query->andWhere(['phone_directory.entry_type' => PhoneDirectory::TYPE_SERVICE]);
        }

        if ($this->q !== null && trim((string) $this->q) !== '') {
            $q = trim((string) $this->q);
            $query->andWhere([
                'or',
                ['ilike', 'phone_directory.full_name', $q],
                ['ilike', 'phone_directory.department', $q],
                ['ilike', 'phone_directory.room', $q],
                ['ilike', 'phone_directory.internal_phone', $q],
                ['ilike', 'phone_directory.external_phone', $q],
                ['ilike', 'phone_directory.position', $q],
            ]);
        }

        $query->andFilterWhere(['phone_directory.id' => $this->id])
            ->andFilterWhere(['phone_directory.entry_type' => $this->entry_type])
            ->andFilterWhere(['ilike', 'phone_directory.full_name', $this->full_name])
            ->andFilterWhere(['ilike', 'phone_directory.department', $this->department])
            ->andFilterWhere(['ilike', 'phone_directory.room', $this->room])
            ->andFilterWhere(['ilike', 'phone_directory.internal_phone', $this->internal_phone]);

        $query->orderBy([
            'phone_directory.sort_order' => SORT_ASC,
            'phone_directory.full_name' => SORT_ASC,
        ]);

        return $dataProvider;
    }
}
