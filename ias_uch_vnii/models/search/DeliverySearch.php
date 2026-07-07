<?php

namespace app\models\search;

use app\models\entities\EquipmentDelivery;
use app\models\entities\EquipmentDeliveryLine;
use app\models\entities\EquipmentDeliveryUnit;
use yii\base\Model;
use yii\data\ActiveDataProvider;
use yii\db\Expression;

/**
 * Поиск поставок (список и фильтры).
 */
class DeliverySearch extends Model
{
    public ?string $q = null;
    public ?string $supplier = null;
    public ?string $status = null;

    public function rules()
    {
        return [
            [['q', 'supplier', 'status'], 'string'],
            [['status'], 'in', 'range' => array_keys(EquipmentDelivery::getStatusList()), 'skipOnEmpty' => true],
        ];
    }

    public function search(array $params): ActiveDataProvider
    {
        $this->load($params, '');

        $query = EquipmentDelivery::find()
            ->alias('d')
            ->with(['warehouseLocation', 'createdByUser']);

        if ($this->supplier !== null && trim($this->supplier) !== '') {
            $query->andWhere(['ilike', 'd.supplier', trim($this->supplier)]);
        }

        if ($this->status !== null && $this->status !== '') {
            $query->andWhere(['d.status' => $this->status]);
        }

        if ($this->q !== null && trim($this->q) !== '') {
            $term = '%' . str_replace(['%', '_'], ['\\%', '\\_'], trim($this->q)) . '%';
            $query->andWhere(['or',
                ['ilike', 'd.name', $term, false],
                ['ilike', 'd.supplier', $term, false],
                ['exists', EquipmentDeliveryLine::find()
                    ->alias('l')
                    ->where('l.delivery_id = d.id')
                    ->andWhere(['or',
                        ['ilike', 'l.name', $term, false],
                        ['ilike', 'l.equipment_type', $term, false],
                    ])],
                ['exists', EquipmentDeliveryUnit::find()
                    ->alias('u')
                    ->innerJoin(['l2' => EquipmentDeliveryLine::tableName()], 'l2.id = u.line_id')
                    ->where('l2.delivery_id = d.id')
                    ->andWhere(['or',
                        ['ilike', 'u.serial_number', $term, false],
                        ['ilike', 'u.inventory_number', $term, false],
                    ])],
            ]);
        }

        return new ActiveDataProvider([
            'query' => $query->orderBy(['d.delivery_date' => SORT_DESC, 'd.id' => SORT_DESC]),
            'pagination' => false,
        ]);
    }

    /**
     * Сводка по поставке для грида.
     *
     * @return array<string, int>
     */
    public static function getDeliveryStats(int $deliveryId): array
    {
        $row = EquipmentDeliveryUnit::find()
            ->alias('u')
            ->innerJoin(['l' => EquipmentDeliveryLine::tableName()], 'l.id = u.line_id')
            ->where(['l.delivery_id' => $deliveryId])
            ->select([
                'units_total' => new Expression('COUNT(*)'),
                'without_inventory' => new Expression("SUM(CASE WHEN COALESCE(TRIM(u.inventory_number), '') = '' THEN 1 ELSE 0 END)"),
                'without_serial' => new Expression("SUM(CASE WHEN COALESCE(TRIM(u.serial_number), '') = '' THEN 1 ELSE 0 END)"),
            ])
            ->asArray()
            ->one();

        return [
            'units_total' => (int) ($row['units_total'] ?? 0),
            'without_inventory' => (int) ($row['without_inventory'] ?? 0),
            'without_serial' => (int) ($row['without_serial'] ?? 0),
        ];
    }
}
