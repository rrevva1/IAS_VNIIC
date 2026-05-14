<?php

namespace app\models\search;

use app\models\entities\Equipment;
use app\models\entities\EquipmentLink;
use app\models\entities\EquipmentTypes;
use Yii;
use yii\base\Model;
use yii\data\ActiveDataProvider;
use yii\db\Expression;
use yii\db\Query;

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

    /** @var string|null кэш имени FK equipment в part_char_values: equipment_id | id_arm | пусто */
    private static ?string $partCharEquipmentFkColumn = null;

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
        $query = Equipment::find()->with(['responsibleUser', 'location', 'equipmentStatus']);

        $eqTable = Equipment::tableName();
        $dataProvider = new ActiveDataProvider([
            'query' => $query,
            'pagination' => ['pageSize' => 20],
            'sort' => [
                'defaultOrder' => ['id' => SORT_ASC],
                'attributes' => array_merge(
                    [
                        'id',
                        'name',
                        'responsible_user_id',
                        'location_id',
                        'created_at',
                        'inventory_number',
                        'description',
                    ],
                    $this->buildLinkCountSortAttributes($eqTable)
                ),
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

    /**
     * Атрибуты сортировки по количеству связей equipment_links (для AG Grid).
     *
     * @return array<string, array{asc: array<Expression, int>, desc: array<Expression, int>}>
     */
    private function buildLinkCountSortAttributes(string $eqTable): array
    {
        $countExpr = static function (string $linkType) use ($eqTable): string {
            return "(SELECT COUNT(*) FROM equipment_links el WHERE el.parent_equipment_id = {$eqTable}.id AND el.link_type = '{$linkType}')";
        };

        return [
            'monitor_count' => [
                'asc' => [$countExpr(EquipmentLink::TYPE_MONITOR) => SORT_ASC],
                'desc' => [$countExpr(EquipmentLink::TYPE_MONITOR) => SORT_DESC],
            ],
            'disk_count' => [
                'asc' => [$countExpr(EquipmentLink::TYPE_DISK) => SORT_ASC],
                'desc' => [$countExpr(EquipmentLink::TYPE_DISK) => SORT_DESC],
            ],
            'ups_count' => [
                'asc' => [$countExpr(EquipmentLink::TYPE_UPS) => SORT_ASC],
                'desc' => [$countExpr(EquipmentLink::TYPE_UPS) => SORT_DESC],
            ],
        ];
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

        $simpleMap = [
            'user_name' => ['column' => 'u.full_name', 'join' => ['responsibleUser u']],
            'location_name' => ['column' => 'l.name', 'join' => ['location l']],
            'status_name' => ['column' => 'dstatus.status_name', 'join' => ['equipmentStatus dstatus']],
            'system_block' => ['column' => 'equipment.name'],
            'inventory_number' => ['column' => 'equipment.inventory_number'],
            'other_tech' => ['column' => 'equipment.description'],
        ];

        $partCharFields = ['cpu', 'ram', 'disk', 'monitor', 'hostname', 'ip', 'os'];
        $linkCountMap = [
            'monitor_count' => EquipmentLink::TYPE_MONITOR,
            'disk_count' => EquipmentLink::TYPE_DISK,
            'ups_count' => EquipmentLink::TYPE_UPS,
        ];

        foreach ($model as $field => $cfg) {
            if (!is_array($cfg)) {
                continue;
            }
            if (isset($linkCountMap[$field])) {
                $this->applyEquipmentLinkCountFilter($query, $linkCountMap[$field], $cfg);
                continue;
            }
            if (in_array($field, $partCharFields, true)) {
                $this->applyPartCharGridFilter($query, $field, $cfg);
                continue;
            }
            if (!isset($simpleMap[$field])) {
                continue;
            }
            $column = $simpleMap[$field]['column'];
            if (!empty($simpleMap[$field]['join'])) {
                [$rel, $alias] = explode(' ', $simpleMap[$field]['join'][0], 2);
                $query->joinWith([$rel . ' ' . $alias]);
            }
            $this->applyTextFilterOnColumn($query, $column, $cfg);
        }
    }

    private function applyTextFilterOnColumn($query, string $column, array $cfg): void
    {
        $type = (string) ($cfg['type'] ?? '');
        $value = isset($cfg['filter']) ? trim((string) $cfg['filter']) : '';
        if ($value === '' && $type !== 'blank' && $type !== 'notBlank') {
            return;
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

    /**
     * Фильтр по числу дочерних связей (AG Grid number filter).
     */
    private function applyEquipmentLinkCountFilter($query, string $linkType, array $cfg): void
    {
        $countExpr = new Expression(
            '(SELECT COUNT(*) FROM equipment_links el WHERE el.parent_equipment_id = equipment.id AND el.link_type = :lt)',
            [':lt' => $linkType]
        );
        $type = (string) ($cfg['type'] ?? 'equals');
        $filter = $cfg['filter'] ?? null;
        $filterTo = $cfg['filterTo'] ?? null;

        if ($type === 'blank') {
            $query->andWhere(['=', $countExpr, 0]);
            return;
        }
        if ($type === 'notBlank') {
            $query->andWhere(['>', $countExpr, 0]);
            return;
        }

        if ($filter === null || $filter === '') {
            return;
        }
        $n = is_numeric($filter) ? 0 + $filter : null;
        if ($n === null) {
            return;
        }

        switch ($type) {
            case 'equals':
                $query->andWhere(['=', $countExpr, $n]);
                break;
            case 'notEqual':
                $query->andWhere(['!=', $countExpr, $n]);
                break;
            case 'greaterThan':
                $query->andWhere(['>', $countExpr, $n]);
                break;
            case 'greaterThanOrEqual':
                $query->andWhere(['>=', $countExpr, $n]);
                break;
            case 'lessThan':
                $query->andWhere(['<', $countExpr, $n]);
                break;
            case 'lessThanOrEqual':
                $query->andWhere(['<=', $countExpr, $n]);
                break;
            case 'inRange':
                if ($filterTo !== null && $filterTo !== '' && is_numeric($filterTo)) {
                    $n2 = 0 + $filterTo;
                    $query->andWhere(['and', ['>=', $countExpr, min($n, $n2)], ['<=', $countExpr, max($n, $n2)]]);
                }
                break;
            default:
                $query->andWhere(['=', $countExpr, $n]);
        }
    }

    private function getPartCharEquipmentFkColumn(): ?string
    {
        if (self::$partCharEquipmentFkColumn !== null) {
            return self::$partCharEquipmentFkColumn === '' ? null : self::$partCharEquipmentFkColumn;
        }
        self::$partCharEquipmentFkColumn = '';
        try {
            $schema = Yii::$app->db->getTableSchema('part_char_values', true);
            if ($schema) {
                self::$partCharEquipmentFkColumn = isset($schema->columns['equipment_id'])
                    ? 'equipment_id'
                    : 'id_arm';
            }
        } catch (\Throwable $e) {
        }
        return self::$partCharEquipmentFkColumn === '' ? null : self::$partCharEquipmentFkColumn;
    }

    /** SQL-выражение значения характеристики (как в ArmController::loadPartCharValuesByEquipment). */
    private function getPartCharCoalescedValueExpression(): Expression
    {
        $driver = Yii::$app->db->driverName;
        if ($driver === 'pgsql') {
            return new Expression('COALESCE(pcv.value_text, pcv.value_num::text)');
        }
        return new Expression('COALESCE(pcv.value_text, CAST(pcv.value_num AS CHAR))');
    }

    private function applyPartCharGridFilter($query, string $gridField, array $cfg): void
    {
        $idCol = $this->getPartCharEquipmentFkColumn();
        if ($idCol === null) {
            $this->applyTextFilterOnColumn($query, 'equipment.description', $cfg);
            return;
        }

        $type = (string) ($cfg['type'] ?? '');
        $value = isset($cfg['filter']) ? trim((string) $cfg['filter']) : '';
        if ($value === '' && $type !== 'blank' && $type !== 'notBlank') {
            return;
        }

        $valExpr = $this->getPartCharCoalescedValueExpression();
        $eqTable = Equipment::tableName();

        $scopeQuery = function () use ($idCol, $gridField, $eqTable) {
            $q = (new Query())
                ->from(['pcv' => 'part_char_values'])
                ->innerJoin(['sp' => 'spr_parts'], 'sp.id = pcv.part_id')
                ->innerJoin(['sc' => 'spr_chars'], 'sc.id = pcv.char_id')
                ->where(['=', 'pcv.' . $idCol, new Expression($eqTable . '.id')]);
            $this->addPartCharScopeForGridField($q, $gridField);
            return $q;
        };

        $nonEmptyExpr = new Expression('(TRIM(COALESCE(pcv.value_text, \'\')) <> \'\' OR pcv.value_num IS NOT NULL)');

        if ($type === 'blank') {
            $sub = $scopeQuery();
            $sub->andWhere($nonEmptyExpr);
            $query->andWhere(['not exists', $sub]);
            return;
        }
        if ($type === 'notBlank') {
            $sub = $scopeQuery();
            $sub->andWhere($nonEmptyExpr);
            $query->andWhere(['exists', $sub]);
            return;
        }

        $sub = $scopeQuery();
        if ($type === 'equals') {
            $sub->andWhere(['ilike', $valExpr, $value]);
        } elseif ($type === 'startsWith') {
            $sub->andWhere(['ilike', $valExpr, $value . '%', false]);
        } elseif ($type === 'endsWith') {
            $sub->andWhere(['ilike', $valExpr, '%' . $value, false]);
        } else {
            $sub->andWhere(['ilike', $valExpr, $value]);
        }
        $query->andWhere(['exists', $sub]);
    }

    private function addPartCharScopeForGridField(Query $q, string $gridField): void
    {
        switch ($gridField) {
            case 'cpu':
                $q->andWhere(['or',
                    ['and', ['sp.name' => 'ЦП'], ['sc.name' => 'Модель']],
                    ['and', ['ilike', 'sp.name', 'процессор', false], ['or',
                        ['ilike', 'sc.name', 'модель', false],
                        ['ilike', 'sc.name', 'частот', false],
                    ]],
                    ['and', ['ilike', 'sp.name', 'cpu', false], ['ilike', 'sc.name', 'модель', false]],
                    ['and', ['sp.name' => 'ЦПУ'], ['or',
                        ['ilike', 'sc.name', 'модель', false],
                        ['ilike', 'sc.name', 'частот', false],
                    ]],
                ]);
                break;
            case 'ram':
                $q->andWhere(['or',
                    ['and', ['sp.name' => 'ОЗУ'], ['sc.name' => 'Объём']],
                    ['and', ['ilike', 'sp.name', 'оператив', false], ['ilike', 'sc.name', 'объём', false]],
                    ['and', ['ilike', 'sp.name', 'оператив', false], ['ilike', 'sc.name', 'объем', false]],
                    ['and', ['ilike', 'sp.name', 'память', false], ['or',
                        ['ilike', 'sc.name', 'объём', false],
                        ['ilike', 'sc.name', 'объем', false],
                    ]],
                    ['and', ['ilike', 'sp.name', 'ram', false], ['or',
                        ['ilike', 'sc.name', 'объём', false],
                        ['ilike', 'sc.name', 'объем', false],
                    ]],
                ]);
                break;
            case 'disk':
                $q->andWhere(['or',
                    ['sp.name' => 'Накопитель'],
                    ['ilike', 'sp.name', 'диск', false],
                    ['ilike', 'sp.name', 'накопител', false],
                    ['ilike', 'sp.name', 'жестк', false],
                    ['ilike', 'sp.name', 'hdd', false],
                    ['ilike', 'sp.name', 'ssd', false],
                ]);
                break;
            case 'monitor':
                $q->andWhere(['or',
                    ['sp.name' => 'Монитор'],
                    ['ilike', 'sp.name', 'монитор', false],
                ]);
                break;
            case 'hostname':
                $q->andWhere(['or',
                    ['and', ['sp.name' => 'ПК'], ['sc.name' => 'Имя ПК']],
                    ['ilike', 'sc.name', 'имя пк', false],
                ]);
                break;
            case 'ip':
                $q->andWhere(['or',
                    ['and', ['sp.name' => 'ПК'], ['sc.name' => 'IP адрес']],
                    ['and', ['sp.name' => 'ПК'], ['ilike', 'sc.name', 'ip', false]],
                ]);
                break;
            case 'os':
                $q->andWhere(['or',
                    ['and', ['sp.name' => 'ПК'], ['sc.name' => 'ОС']],
                    ['ilike', 'sc.name', 'операционн', false],
                ]);
                break;
        }
    }

    private function applyAgGridSortModel(ActiveDataProvider $dataProvider): void
    {
        $query = $dataProvider->query;
        $raw = trim((string) $this->ag_sort_model);
        if ($raw === '') {
            $query->joinWith(['responsibleUser u']);
            $query->orderBy([
                'u.full_name' => SORT_ASC,
                'equipment.id' => SORT_ASC,
            ]);
            return;
        }
        $sortModel = json_decode($raw, true);
        if (!is_array($sortModel) || empty($sortModel)) {
            $query->joinWith(['responsibleUser u']);
            $query->orderBy([
                'u.full_name' => SORT_ASC,
                'equipment.id' => SORT_ASC,
            ]);
            return;
        }

        $map = [
            'user_name' => ['column' => 'u.full_name', 'join' => ['responsibleUser u']],
            'location_name' => ['column' => 'l.name', 'join' => ['location l']],
            'status_name' => ['column' => 'dstatus.status_name', 'join' => ['equipmentStatus dstatus']],
            'system_block' => ['column' => 'equipment.name'],
            'inventory_number' => ['column' => 'equipment.inventory_number'],
            'other_tech' => ['column' => 'equipment.description'],
            'monitor_count' => ['column' => "(SELECT COUNT(*) FROM equipment_links el WHERE el.parent_equipment_id = equipment.id AND el.link_type = '" . EquipmentLink::TYPE_MONITOR . "')"],
            'disk_count' => ['column' => "(SELECT COUNT(*) FROM equipment_links el WHERE el.parent_equipment_id = equipment.id AND el.link_type = '" . EquipmentLink::TYPE_DISK . "')"],
            'ups_count' => ['column' => "(SELECT COUNT(*) FROM equipment_links el WHERE el.parent_equipment_id = equipment.id AND el.link_type = '" . EquipmentLink::TYPE_UPS . "')"],
            'id' => ['column' => 'equipment.id'],
            'name' => ['column' => 'equipment.name'],
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
            if (!empty($map[$col]['join'])) {
                foreach ($map[$col]['join'] as $joinRel) {
                    $query->joinWith([$joinRel]);
                }
            }
            $order[$map[$col]['column']] = $dir;
        }
        if (!empty($order)) {
            $query->orderBy($order);
        } else {
            $query->joinWith(['responsibleUser u']);
            $query->orderBy([
                'u.full_name' => SORT_ASC,
                'equipment.id' => SORT_ASC,
            ]);
        }
    }
}
