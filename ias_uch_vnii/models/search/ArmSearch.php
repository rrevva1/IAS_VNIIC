<?php

namespace app\models\search;

use app\models\entities\Equipment;
use app\models\entities\EquipmentTypes;
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
    /** @var string|null Быстрый фильтр по группе статусов */
    public $status_group;
    /** @var string|null Фильтр по типу техники */
    public $equipment_type;
    /** @var string|null JSON filterModel AG Grid */
    public $ag_filter_model;
    /** @var string|null JSON sortModel AG Grid */
    public $ag_sort_model;

    public function rules()
    {
        return [
            [['id', 'responsible_user_id', 'location_id', 'status_id'], 'integer'],
            [['is_archived'], 'boolean'],
            [['name', 'description', 'inventory_number', 'equipment_type', 'status_group', 'ag_filter_model', 'ag_sort_model'], 'safe'],
        ];
    }

    public function scenarios()
    {
        return Model::scenarios();
    }

    public function search(array $params): ActiveDataProvider
    {
        // Eager-load relations to avoid N+1 queries when rendering the grid.
        $query = Equipment::find()->with(['responsibleUser', 'location', 'equipmentStatus']);

        $dataProvider = new ActiveDataProvider([
            'query' => $query,
            'pagination' => ['pageSize' => 20],
            'sort' => [
                'defaultOrder' => ['id' => SORT_ASC],
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
            'equipment.is_deleted' => false,
        ]);

        $eqType = $this->equipment_type !== null ? trim((string) $this->equipment_type) : '';
        if ($eqType !== '') {
            if (EquipmentTypes::usesDictionary()) {
                $typeId = EquipmentTypes::resolveIdByName($eqType);
                if ($typeId === null) {
                    $query->andWhere('1 = 0');
                } else {
                    $query->andWhere(['equipment.equipment_type_id' => $typeId]);
                }
            } else {
                $query->andFilterWhere(['equipment.equipment_type' => $eqType]);
            }
        }

        $query->andFilterWhere(['ilike', 'equipment.name', $this->name])
            ->andFilterWhere(['ilike', 'equipment.description', $this->description ?? ''])
            ->andFilterWhere(['ilike', 'equipment.inventory_number', $this->inventory_number]);

        $statusGroup = trim((string) $this->status_group);
        if ($statusGroup !== '') {
            if ($statusGroup === 'in_repair') {
                $query->innerJoin(['dstatus' => 'dic_equipment_status'], 'dstatus.id = equipment.status_id')
                    ->andWhere(['ilike', 'dstatus.status_name', 'ремонт']);
            } elseif ($statusGroup === 'writeoff') {
                $query->innerJoin(['dstatus' => 'dic_equipment_status'], 'dstatus.id = equipment.status_id')
                    ->andWhere(['or', ['ilike', 'dstatus.status_name', 'списан'], ['ilike', 'dstatus.status_name', 'списание']]);
            } elseif ($statusGroup === 'in_use') {
                $query->innerJoin(['dstatus' => 'dic_equipment_status'], 'dstatus.id = equipment.status_id')
                    ->andWhere(['ilike', 'dstatus.status_name', 'эксплуатац']);
            }
        }

        $this->applyAgGridFilterModel($query);
        $this->applyAgGridSortModel($dataProvider);

        return $dataProvider;
    }

    private function applyAgGridFilterModel($query): void
    {
        $raw = trim((string) $this->ag_filter_model);
        if ($raw === '') {
            return;
        }
        $model = json_decode($raw, true);
        if (!is_array($model) || empty($model)) {
            return;
        }

        $map = [
            'user_name' => ['column' => 'u.full_name', 'join' => ['responsibleUser u']],
            'location_name' => ['column' => 'l.name', 'join' => ['location l']],
            'status_name' => ['column' => 'dstatus.status_name', 'join' => ['equipmentStatus dstatus']],
            'cpu' => ['column' => 'equipment.description'],
            'ram' => ['column' => 'equipment.description'],
            'disk' => ['column' => 'equipment.description'],
            'system_block' => ['column' => 'equipment.name'],
            'inventory_number' => ['column' => 'equipment.inventory_number'],
            'monitor' => ['column' => 'equipment.description'],
            'hostname' => ['column' => 'equipment.description'],
            'ip' => ['column' => 'equipment.description'],
            'os' => ['column' => 'equipment.description'],
            'other_tech' => ['column' => 'equipment.description'],
        ];

        foreach ($model as $field => $cfg) {
            if (!isset($map[$field]) || !is_array($cfg)) {
                continue;
            }
            $column = $map[$field]['column'];
            if (!empty($map[$field]['join'])) {
                [$rel, $alias] = explode(' ', $map[$field]['join'][0], 2);
                $query->joinWith([$rel . ' ' . $alias]);
            }

            $type = (string) ($cfg['type'] ?? '');
            $value = trim((string) ($cfg['filter'] ?? ''));
            if ($value === '' && $type !== 'blank' && $type !== 'notBlank') {
                continue;
            }

            if ($type === 'equals') {
                $query->andWhere(['ilike', $column, $value]);
            } elseif ($type === 'startsWith') {
                $query->andWhere(['ilike', $column, $value . '%', false]);
            } elseif ($type === 'endsWith') {
                $query->andWhere(['ilike', $column, '%' . $value, false]);
            } elseif ($type === 'blank') {
                $query->andWhere(['or', [$column => null], [$column => '']]);
            } elseif ($type === 'notBlank') {
                $query->andWhere(['and', ['not', [$column => null]], ['<>', $column, '']]);
            } else {
                $query->andWhere(['ilike', $column, $value]);
            }
        }
    }

    private function applyAgGridSortModel(ActiveDataProvider $dataProvider): void
    {
        $raw = trim((string) $this->ag_sort_model);
        if ($raw === '') {
            return;
        }
        $sortModel = json_decode($raw, true);
        if (!is_array($sortModel) || empty($sortModel)) {
            return;
        }
        $map = [
            'user_name' => 'responsible_user_id',
            'location_name' => 'location_id',
            'status_name' => 'status_id',
            'system_block' => 'name',
            'inventory_number' => 'inventory_number',
            'other_tech' => 'description',
            'id' => 'id',
            'name' => 'name',
        ];
        $order = [];
        foreach ($sortModel as $sortEntry) {
            if (!is_array($sortEntry)) {
                continue;
            }
            $col = (string) ($sortEntry['colId'] ?? '');
            $dir = strtolower((string) ($sortEntry['sort'] ?? 'asc')) === 'desc' ? SORT_DESC : SORT_ASC;
            if (!isset($map[$col])) {
                continue;
            }
            $order[$map[$col]] = $dir;
        }
        if (!empty($order) && $dataProvider->sort) {
            $dataProvider->sort->defaultOrder = $order;
        }
    }
}
