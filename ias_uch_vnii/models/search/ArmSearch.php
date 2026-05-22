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
    /** Типы записей «рабочее место / ПК» (вкладка «АРМ» в UI). */
    private const KIT_HOST_EQUIPMENT_TYPES = [
        'АРМ',
        'ПК',
        'Системный блок',
        'Ноутбук',
        'Моноблок',
        'Сервер',
    ];

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
    /** @var string|null Быстрый поиск по основным полям таблицы */
    public $quick_search;

    /** @var string|null кэш имени FK equipment в part_char_values: equipment_id | id_arm | пусто */
    private static ?string $partCharEquipmentFkColumn = null;

    public function rules()
    {
        return [
            [['id', 'responsible_user_id', 'location_id', 'status_id'], 'integer'],
            [['is_archived'], 'boolean'],
            [['name', 'description', 'inventory_number', 'equipment_type', 'status_group', 'ag_filter_model', 'ag_sort_model', 'quick_search'], 'safe'],
        ];
    }

    public function scenarios()
    {
        return Model::scenarios();
    }

    public function search(array $params): ActiveDataProvider
    {
        $query = Equipment::find()->with(['responsibleUser', 'location', 'equipmentStatus']);

        $dataProvider = new ActiveDataProvider([
            'query' => $query,
            'pagination' => ['pageSize' => 20],
            'sort' => [
                'defaultOrder' => ['id' => SORT_ASC],
                'attributes' => [
                    'id',
                    'name',
                    'responsible_user_id',
                    'location_id',
                    'created_at',
                    'inventory_number',
                    'description',
                    'purchase_date',
                ],
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
            $this->applyEquipmentTypeFilter($query, $eqType);
        } else {
            // Вкладка «Вся техника»: комплект показывается строкой ПК; дочерние монитор/ИБП — в колонках связей.
            $this->excludeKitLinkedMonitorsAndUps($query);
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
        $this->applyQuickSearch($query);
        $this->applyAgGridSortModel($dataProvider);

        return $dataProvider;
    }

    /**
     * Быстрый поиск по отображаемым полям строки (для AG Grid infinite row model).
     */
    private function applyQuickSearch($query): void
    {
        $q = trim((string) $this->quick_search);
        if ($q === '') {
            return;
        }

        $query->joinWith(['responsibleUser u', 'location l', 'equipmentStatus dstatus'], false);

        $or = [
            'or',
            ['ilike', 'equipment.name', $q],
            ['ilike', 'equipment.inventory_number', $q],
            ['ilike', new Expression('CAST(equipment.purchase_date AS TEXT)'), $q],
            ['ilike', 'equipment.description', $q],
            ['ilike', 'u.full_name', $q],
            ['ilike', 'u.email', $q],
            ['ilike', 'u.username', $q],
            ['ilike', 'l.name', $q],
            ['ilike', 'dstatus.status_name', $q],
        ];

        $idCol = $this->getPartCharEquipmentFkColumn();
        if ($idCol !== null) {
            $valExpr = $this->getPartCharCoalescedValueExpression();
            $eqTable = Equipment::tableName();
            $charSub = (new Query())
                ->from(['pcv' => 'part_char_values'])
                ->where(['=', 'pcv.' . $idCol, new Expression($eqTable . '.id')])
                ->andWhere(['ilike', $valExpr, $q]);
            $or[] = ['exists', $charSub];
        }

        if (Yii::$app->db->getTableSchema('equipment_links', true) !== null) {
            $eqTable = Equipment::tableName();
            $linkSub = (new Query())
                ->from(['el' => 'equipment_links'])
                ->innerJoin(['child' => $eqTable], 'child.id = el.child_equipment_id')
                ->where(['el.parent_equipment_id' => new Expression($eqTable . '.id')])
                ->andWhere([
                    'or',
                    ['ilike', 'child.name', $q],
                    ['ilike', 'child.inventory_number', $q],
                ]);
            $or[] = ['exists', $linkSub];
        }

        $query->andWhere($or);
    }

    /**
     * Фильтр по вкладке типа техники. «АРМ» — все хосты (ПК), не только equipment_type = 'АРМ'.
     */
    private function applyEquipmentTypeFilter($query, string $eqType): void
    {
        if (mb_strtolower($eqType, 'UTF-8') === 'арм') {
            $this->applyKitHostTypesFilter($query);

            return;
        }

        if (EquipmentTypes::usesDictionary()) {
            $typeId = EquipmentTypes::resolveIdByName($eqType);
            if ($typeId === null) {
                $query->andWhere('1 = 0');
            } else {
                $query->andWhere(['equipment.equipment_type_id' => $typeId]);
            }

            return;
        }

        $query->andFilterWhere(['equipment.equipment_type' => $eqType]);
    }

    /**
     * Вкладка «АРМ»: системные блоки, ноутбуки, моноблоки и записи с типом «АРМ»/«ПК».
     */
    private function applyKitHostTypesFilter($query): void
    {
        if (EquipmentTypes::usesDictionary()) {
            $typeIds = [];
            foreach (self::KIT_HOST_EQUIPMENT_TYPES as $typeName) {
                $id = EquipmentTypes::resolveIdByName($typeName);
                if ($id !== null) {
                    $typeIds[] = $id;
                }
            }
            if ($typeIds === []) {
                $query->andWhere('1 = 0');

                return;
            }
            $query->andWhere(['equipment.equipment_type_id' => $typeIds]);

            return;
        }

        $query->andWhere([
            'or',
            ['equipment.equipment_type' => self::KIT_HOST_EQUIPMENT_TYPES],
            ['ilike', 'equipment.equipment_type', 'систем'],
            ['ilike', 'equipment.equipment_type', 'ноутбук'],
            ['ilike', 'equipment.equipment_type', 'моноблок'],
            ['ilike', 'equipment.equipment_type', 'пк'],
        ]);
    }

    /**
     * Исключить из выборки мониторы и ИБП, уже входящие в комплект (дочерние связи equipment_links).
     * Непривязанные мониторы/ИБП остаются в списке «Вся техника».
     */
    private function excludeKitLinkedMonitorsAndUps($query): void
    {
        if (Yii::$app->db->getTableSchema('equipment_links', true) === null) {
            return;
        }

        $sub = (new Query())
            ->from(['el' => 'equipment_links'])
            ->where('el.child_equipment_id = equipment.id')
            ->andWhere(['el.link_type' => [EquipmentLink::TYPE_MONITOR, EquipmentLink::TYPE_UPS]]);

        $query->andWhere(['not exists', $sub]);
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
            'purchase_date' => ['column' => new Expression('CAST(equipment.purchase_date AS TEXT)')],
            'other_tech' => ['column' => 'equipment.description'],
            'cartridge_procurement' => ['column' => 'equipment.description'],
        ];

        $partCharFields = ['cpu', 'ram', 'disk', 'monitor', 'hostname', 'ip', 'os'];

        foreach ($model as $field => $cfg) {
            if (!is_array($cfg)) {
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
        if ($gridField === 'monitor') {
            $this->applyMonitorGridFilter($query, $cfg);
            return;
        }

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

    /**
     * Фильтр колонки «Монитор»: характеристика part_char_values и привязанные мониторы (equipment_links).
     */
    private function applyMonitorGridFilter($query, array $cfg): void
    {
        $type = (string) ($cfg['type'] ?? '');
        $value = isset($cfg['filter']) ? trim((string) $cfg['filter']) : '';
        if ($value === '' && $type !== 'blank' && $type !== 'notBlank') {
            return;
        }

        $eqTable = Equipment::tableName();
        $hasLinksTable = Yii::$app->db->getTableSchema('equipment_links', true) !== null;

        $linkedMatch = function () use ($eqTable, $value, $type, $hasLinksTable) {
            if (!$hasLinksTable) {
                return null;
            }
            $q = (new Query())
                ->from(['el' => 'equipment_links'])
                ->innerJoin(['child' => $eqTable], 'child.id = el.child_equipment_id')
                ->where([
                    'el.parent_equipment_id' => new Expression($eqTable . '.id'),
                    'el.link_type' => EquipmentLink::TYPE_MONITOR,
                ]);
            if ($type === 'blank' || $type === 'notBlank') {
                return $q;
            }
            if ($value === '') {
                return null;
            }
            if ($type === 'equals' || $type === 'startsWith' || $type === 'endsWith') {
                $pattern = $type === 'startsWith' ? $value . '%' : ($type === 'endsWith' ? '%' . $value : $value);
                $q->andWhere(['or',
                    ['ilike', 'child.name', $pattern, $type !== 'equals'],
                    ['ilike', 'child.inventory_number', $pattern, $type !== 'equals'],
                ]);
            } else {
                $q->andWhere(['or',
                    ['ilike', 'child.name', $value],
                    ['ilike', 'child.inventory_number', $value],
                ]);
            }

            return $q;
        };

        $charMatch = function () use ($eqTable) {
            $idCol = $this->getPartCharEquipmentFkColumn();
            if ($idCol === null) {
                return null;
            }
            $valExpr = $this->getPartCharCoalescedValueExpression();
            $q = (new Query())
                ->from(['pcv' => 'part_char_values'])
                ->innerJoin(['sp' => 'spr_parts'], 'sp.id = pcv.part_id')
                ->innerJoin(['sc' => 'spr_chars'], 'sc.id = pcv.char_id')
                ->where(['=', 'pcv.' . $idCol, new Expression($eqTable . '.id')]);
            $this->addPartCharScopeForGridField($q, 'monitor');
            return ['q' => $q, 'valExpr' => $valExpr];
        };

        if ($type === 'blank') {
            $conditions = ['and'];
            $char = $charMatch();
            if ($char !== null) {
                $sub = $char['q'];
                $sub->andWhere(new Expression(
                    "(TRIM(COALESCE(pcv.value_text, '')) <> '' OR pcv.value_num IS NOT NULL)"
                ));
                $conditions[] = ['not exists', $sub];
            }
            $linked = $linkedMatch();
            if ($linked !== null) {
                $conditions[] = ['not exists', $linked];
            }
            if (count($conditions) > 1) {
                $query->andWhere($conditions);
            }
            return;
        }

        if ($type === 'notBlank') {
            $or = ['or'];
            $char = $charMatch();
            if ($char !== null) {
                $sub = $char['q'];
                $sub->andWhere(new Expression(
                    "(TRIM(COALESCE(pcv.value_text, '')) <> '' OR pcv.value_num IS NOT NULL)"
                ));
                $or[] = ['exists', $sub];
            }
            $linked = $linkedMatch();
            if ($linked !== null) {
                $or[] = ['exists', $linked];
            }
            if (count($or) > 1) {
                $query->andWhere($or);
            }
            return;
        }

        $or = ['or'];
        $char = $charMatch();
        if ($char !== null && $value !== '') {
            $sub = $char['q'];
            $valExpr = $char['valExpr'];
            if ($type === 'equals') {
                $sub->andWhere(['ilike', $valExpr, $value]);
            } elseif ($type === 'startsWith') {
                $sub->andWhere(['ilike', $valExpr, $value . '%', false]);
            } elseif ($type === 'endsWith') {
                $sub->andWhere(['ilike', $valExpr, '%' . $value, false]);
            } else {
                $sub->andWhere(['ilike', $valExpr, $value]);
            }
            $or[] = ['exists', $sub];
        }
        $linked = $linkedMatch();
        if ($linked !== null) {
            $or[] = ['exists', $linked];
        }
        if (count($or) > 1) {
            $query->andWhere($or);
        }
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

    /**
     * Суффикс направления сортировки (для PostgreSQL — пустые значения в конец/начало).
     */
    private function gridSortDirectionSuffix(int $dir): string
    {
        $name = $dir === SORT_DESC ? 'DESC' : 'ASC';
        if (Yii::$app->db->driverName === 'pgsql') {
            $name .= $dir === SORT_DESC ? ' NULLS LAST' : ' NULLS FIRST';
        }

        return $name;
    }

    /** Литерал для SQL (без плейсхолдеров — иначе Yii путает параметры ORDER BY с WHERE). */
    private function quoteSqlValue(string $value): string
    {
        return Yii::$app->db->quoteValue($value);
    }

    private function sqlEquals(string $column, string $value): string
    {
        return $column . ' = ' . $this->quoteSqlValue($value);
    }

    private function sqlIlikeContains(string $column, string $value): string
    {
        return $column . ' ILIKE ' . $this->quoteSqlValue('%' . $value . '%');
    }

    /**
     * Условие области part_char_values для сортировки (только литералы, без :param).
     */
    private function getPartCharScopeSql(string $gridField): string
    {
        switch ($gridField) {
            case 'cpu':
                return implode(' OR ', [
                    '(' . $this->sqlEquals('sp.name', 'ЦП') . ' AND ' . $this->sqlEquals('sc.name', 'Модель') . ')',
                    '(' . $this->sqlIlikeContains('sp.name', 'процессор') . ' AND (' . $this->sqlIlikeContains('sc.name', 'модель')
                        . ' OR ' . $this->sqlIlikeContains('sc.name', 'частот') . '))',
                    '(' . $this->sqlIlikeContains('sp.name', 'cpu') . ' AND ' . $this->sqlIlikeContains('sc.name', 'модель') . ')',
                    '(' . $this->sqlEquals('sp.name', 'ЦПУ') . ' AND (' . $this->sqlIlikeContains('sc.name', 'модель')
                        . ' OR ' . $this->sqlIlikeContains('sc.name', 'частот') . '))',
                ]);
            case 'ram':
                return implode(' OR ', [
                    '(' . $this->sqlEquals('sp.name', 'ОЗУ') . ' AND ' . $this->sqlEquals('sc.name', 'Объём') . ')',
                    '(' . $this->sqlIlikeContains('sp.name', 'оператив') . ' AND ' . $this->sqlIlikeContains('sc.name', 'объём') . ')',
                    '(' . $this->sqlIlikeContains('sp.name', 'оператив') . ' AND ' . $this->sqlIlikeContains('sc.name', 'объем') . ')',
                    '(' . $this->sqlIlikeContains('sp.name', 'память') . ' AND (' . $this->sqlIlikeContains('sc.name', 'объём')
                        . ' OR ' . $this->sqlIlikeContains('sc.name', 'объем') . '))',
                    '(' . $this->sqlIlikeContains('sp.name', 'ram') . ' AND (' . $this->sqlIlikeContains('sc.name', 'объём')
                        . ' OR ' . $this->sqlIlikeContains('sc.name', 'объем') . '))',
                ]);
            case 'disk':
                return implode(' OR ', [
                    $this->sqlEquals('sp.name', 'Накопитель'),
                    $this->sqlIlikeContains('sp.name', 'диск'),
                    $this->sqlIlikeContains('sp.name', 'накопител'),
                    $this->sqlIlikeContains('sp.name', 'жестк'),
                    $this->sqlIlikeContains('sp.name', 'hdd'),
                    $this->sqlIlikeContains('sp.name', 'ssd'),
                ]);
            case 'monitor':
                return implode(' OR ', [
                    $this->sqlEquals('sp.name', 'Монитор'),
                    $this->sqlIlikeContains('sp.name', 'монитор'),
                ]);
            case 'hostname':
                return implode(' OR ', [
                    '(' . $this->sqlEquals('sp.name', 'ПК') . ' AND ' . $this->sqlEquals('sc.name', 'Имя ПК') . ')',
                    $this->sqlIlikeContains('sc.name', 'имя пк'),
                ]);
            case 'ip':
                return implode(' OR ', [
                    '(' . $this->sqlEquals('sp.name', 'ПК') . ' AND ' . $this->sqlEquals('sc.name', 'IP адрес') . ')',
                    '(' . $this->sqlEquals('sp.name', 'ПК') . ' AND ' . $this->sqlIlikeContains('sc.name', 'ip') . ')',
                ]);
            case 'os':
                return implode(' OR ', [
                    '(' . $this->sqlEquals('sp.name', 'ПК') . ' AND ' . $this->sqlEquals('sc.name', 'ОС') . ')',
                    $this->sqlIlikeContains('sc.name', 'операционн'),
                ]);
            default:
                return '';
        }
    }

    /**
     * @return array{sql: string}|null MIN значения характеристики для ORDER BY (без bound-параметров)
     */
    private function buildPartCharMinSortSubquery(string $gridField): ?array
    {
        $idCol = $this->getPartCharEquipmentFkColumn();
        if ($idCol === null) {
            return null;
        }

        $scopeSql = $this->getPartCharScopeSql($gridField);
        if ($scopeSql === '') {
            return null;
        }

        $eqTable = Equipment::tableName();
        $valSql = Yii::$app->db->driverName === 'pgsql'
            ? 'COALESCE(pcv.value_text, pcv.value_num::text)'
            : 'COALESCE(pcv.value_text, CAST(pcv.value_num AS CHAR))';

        $sql = '(SELECT MIN(' . $valSql . ') FROM part_char_values pcv'
            . ' INNER JOIN spr_parts sp ON sp.id = pcv.part_id'
            . ' INNER JOIN spr_chars sc ON sc.id = pcv.char_id'
            . ' WHERE pcv.' . $idCol . ' = ' . $eqTable . '.id AND (' . $scopeSql . '))';

        return ['sql' => $sql];
    }

    /**
     * @return array{sql: string}|null MIN наименования связанного компонента для ORDER BY
     */
    private function buildLinkedChildMinSortSubquery(string $linkType): ?array
    {
        if (Yii::$app->db->getTableSchema('equipment_links', true) === null) {
            return null;
        }

        $eqTable = Equipment::tableName();
        $sql = '(SELECT MIN(COALESCE(child.name, child.inventory_number, ' . $this->quoteSqlValue('') . '))'
            . ' FROM equipment_links el'
            . ' INNER JOIN ' . $eqTable . ' child ON child.id = el.child_equipment_id'
            . ' WHERE el.parent_equipment_id = ' . $eqTable . '.id'
            . ' AND el.link_type = ' . $this->quoteSqlValue($linkType) . ')';

        return ['sql' => $sql];
    }

    /**
     * @param array{sql: string}[] $parts
     */
    private function buildCoalesceSortExpression(array $parts, int $dir): ?Expression
    {
        if ($parts === []) {
            return null;
        }

        $sqlParts = array_map(static fn(array $part) => $part['sql'], $parts);

        return new Expression(
            'COALESCE(' . implode(', ', $sqlParts) . ", '') " . $this->gridSortDirectionSuffix($dir)
        );
    }

    private function resolveGridSortExpression(string $col, int $dir, $query): ?Expression
    {
        $suffix = $this->gridSortDirectionSuffix($dir);

        $map = [
            'user_name' => ['column' => 'u.full_name', 'join' => ['responsibleUser u']],
            'location_name' => ['column' => 'l.name', 'join' => ['location l']],
            'status_name' => ['column' => 'dstatus.status_name', 'join' => ['equipmentStatus dstatus']],
            'system_block' => ['column' => 'equipment.name'],
            'inventory_number' => ['column' => 'equipment.inventory_number'],
            'purchase_date' => ['column' => 'equipment.purchase_date'],
            'other_tech' => ['column' => 'equipment.description'],
            'cartridge_procurement' => ['column' => 'equipment.description'],
            'id' => ['column' => 'equipment.id'],
            'name' => ['column' => 'equipment.name'],
        ];

        if (isset($map[$col])) {
            if (!empty($map[$col]['join'])) {
                foreach ($map[$col]['join'] as $joinRel) {
                    $query->joinWith([$joinRel]);
                }
            }

            return new Expression($map[$col]['column'] . ' ' . $suffix);
        }

        $partCharFields = ['cpu', 'ram', 'hostname', 'ip', 'os'];
        if (in_array($col, $partCharFields, true)) {
            $sub = $this->buildPartCharMinSortSubquery($col);

            return $sub !== null ? new Expression($sub['sql'] . ' ' . $suffix) : null;
        }

        if ($col === 'disk') {
            $parts = array_values(array_filter([
                $this->buildPartCharMinSortSubquery('disk'),
                $this->buildLinkedChildMinSortSubquery(EquipmentLink::TYPE_DISK),
            ]));

            return $this->buildCoalesceSortExpression($parts, $dir);
        }

        if ($col === 'monitor') {
            $parts = array_values(array_filter([
                $this->buildPartCharMinSortSubquery('monitor'),
                $this->buildLinkedChildMinSortSubquery(EquipmentLink::TYPE_MONITOR),
            ]));

            return $this->buildCoalesceSortExpression($parts, $dir);
        }

        return null;
    }

    private function applyDefaultGridSort($query): void
    {
        $query->joinWith(['responsibleUser u']);
        $query->orderBy([
            'u.full_name' => SORT_ASC,
            'equipment.id' => SORT_ASC,
        ]);
    }

    private function applyAgGridSortModel(ActiveDataProvider $dataProvider): void
    {
        $query = $dataProvider->query;
        $raw = trim((string) $this->ag_sort_model);
        if ($raw === '') {
            $this->applyDefaultGridSort($query);

            return;
        }
        $sortModel = json_decode($raw, true);
        if (!is_array($sortModel) || empty($sortModel)) {
            $this->applyDefaultGridSort($query);

            return;
        }

        $applied = false;
        foreach ($sortModel as $sortEntry) {
            if (!is_array($sortEntry)) {
                continue;
            }
            $col = (string) ($sortEntry['colId'] ?? $sortEntry['field'] ?? '');
            if ($col === '') {
                continue;
            }
            $dir = strtolower((string) ($sortEntry['sort'] ?? 'asc')) === 'desc' ? SORT_DESC : SORT_ASC;
            $expr = $this->resolveGridSortExpression($col, $dir, $query);
            if ($expr === null) {
                continue;
            }
            $query->addOrderBy($expr);
            $applied = true;
        }

        if ($applied) {
            $query->addOrderBy(['equipment.id' => SORT_ASC]);
        } else {
            $this->applyDefaultGridSort($query);
        }
    }
}
