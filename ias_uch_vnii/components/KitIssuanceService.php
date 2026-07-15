<?php

namespace app\components;

use app\models\dictionaries\DicEquipmentStatus;
use app\models\entities\EquipHistory;
use app\models\entities\Equipment;
use app\models\entities\EquipmentLink;
use app\models\entities\Location;
use app\models\entities\Users;
use Yii;
use yii\db\Query;

/**
 * Выдача комплекта техники со склада пользователю (хост + опционально несколько мониторов и ИБП).
 */
class KitIssuanceService
{
    /**
     * @return array{success: bool, hosts: array, monitors: array, ups: array, warehouse_location_id: ?int}
     */
    public function getOptions(?int $warehouseLocationId = null, ?int $hostId = null): array
    {
        // host_id используется только для проверки доступности выбранного СБ.
        // Не сужаем мониторы/ИБП до склада выбранного системного блока:
        // комплект может собираться с разных складских помещений
        // (помещение уже видно в подписи опции).
        if ($hostId !== null && $hostId > 0) {
            $host = Equipment::find()
                ->where(['id' => $hostId, 'is_deleted' => false, 'is_archived' => false])
                ->with('location')
                ->one();
            if ($host === null || !EquipmentKitHelper::isEquipmentOnWarehouse($host)) {
                return [
                    'success' => false,
                    'message' => 'Выбранный системный блок недоступен для выдачи со склада.',
                    'hosts' => [],
                    'monitors' => [],
                    'ups' => [],
                    'warehouse_location_id' => null,
                ];
            }
        }

        $linkedChildExists = (new Query())
            ->from(['el' => EquipmentLink::tableName()])
            ->where('el.child_equipment_id = e.id');

        $baseQuery = Equipment::find()
            ->alias('e')
            ->innerJoin(['l' => Location::tableName()], 'l.id = e.location_id')
            ->with('location')
            ->where([
                'e.is_deleted' => false,
                'e.is_archived' => false,
                'l.location_type' => 'склад',
            ])
            ->andWhere(['e.responsible_user_id' => null]);

        if (Yii::$app->db->getTableSchema('equipment_links', true) !== null) {
            $baseQuery->andWhere(['not exists', $linkedChildExists]);
        }

        // Фильтр по складу — только если явно передан warehouse_location_id.
        if ($warehouseLocationId !== null && $warehouseLocationId > 0) {
            $baseQuery->andWhere(['e.location_id' => $warehouseLocationId]);
        }

        $rows = (clone $baseQuery)
            ->orderBy(['e.inventory_number' => SORT_ASC, 'e.name' => SORT_ASC])
            ->limit(500)
            ->all();

        $hosts = [];
        $monitors = [];
        $ups = [];

        foreach ($rows as $equipment) {
            if (EquipmentKitHelper::isHostEquipment($equipment)) {
                $hosts[] = EquipmentKitHelper::equipmentToOptionRow($equipment);
            } elseif (EquipmentKitHelper::isMonitorEquipment($equipment)) {
                $monitors[] = EquipmentKitHelper::equipmentToOptionRow($equipment);
            } elseif (EquipmentKitHelper::isUpsEquipment($equipment)) {
                $ups[] = EquipmentKitHelper::equipmentToOptionRow($equipment);
            }
        }

        $hostIds = array_map(static function (array $row): int {
            return (int) ($row['id'] ?? 0);
        }, $hosts);
        $networkProfiles = $this->loadHostNetworkProfiles($hostIds);
        foreach ($hosts as $index => $hostRow) {
            $hostIdKey = (int) ($hostRow['id'] ?? 0);
            $profile = $networkProfiles[$hostIdKey] ?? ['hostname' => '', 'ip' => ''];
            $hosts[$index]['hostname'] = $profile['hostname'];
            $hosts[$index]['ip'] = $profile['ip'];
        }

        return [
            'success' => true,
            'hosts' => $hosts,
            'monitors' => $monitors,
            'ups' => $ups,
            'warehouse_location_id' => $warehouseLocationId > 0 ? $warehouseLocationId : null,
        ];
    }

    /**
     * @param int[] $monitorIds
     * @return array{success: bool, message: string, updated?: int}
     */
    public function issueKit(
        int $hostId,
        array $monitorIds,
        ?int $upsId,
        int $responsibleUserId,
        int $locationId,
        ?int $statusId = null,
        ?string $hostname = null,
        ?string $ipAddress = null
    ): array {
        if ($responsibleUserId <= 0) {
            return ['success' => false, 'message' => 'Укажите получателя комплекта.'];
        }
        if ($locationId <= 0) {
            return ['success' => false, 'message' => 'Укажите помещение выдачи.'];
        }
        if (EquipmentKitHelper::isWarehouseLocationId($locationId)) {
            return ['success' => false, 'message' => 'Помещение выдачи не может быть складом.'];
        }
        if ($hostId <= 0) {
            return ['success' => false, 'message' => 'Укажите системный блок для выдачи.'];
        }

        $monitorIds = array_values(array_unique(array_filter(array_map('intval', $monitorIds), static function (int $id): bool {
            return $id > 0;
        })));
        foreach ($monitorIds as $monitorId) {
            if ($monitorId === $hostId) {
                return ['success' => false, 'message' => 'Монитор не может совпадать с системным блоком.'];
            }
            if ($upsId !== null && $upsId > 0 && $monitorId === $upsId) {
                return ['success' => false, 'message' => 'Монитор и ИБП должны быть разными единицами техники.'];
            }
        }
        if ($upsId !== null && $upsId > 0 && $upsId === $hostId) {
            return ['success' => false, 'message' => 'ИБП не может совпадать с системным блоком.'];
        }

        $user = Users::findOne($responsibleUserId);
        if ($user === null) {
            return ['success' => false, 'message' => 'Получатель не найден.'];
        }

        $host = $this->findWarehouseUnit($hostId);
        if ($host === null) {
            return ['success' => false, 'message' => 'Системный блок не найден на складе или уже выдан.'];
        }
        if (!EquipmentKitHelper::isHostEquipment($host)) {
            return ['success' => false, 'message' => 'Выбранная единица не является системным блоком или ПК.'];
        }

        /** @var Equipment[] $monitors */
        $monitors = [];
        foreach ($monitorIds as $monitorId) {
            $monitor = $this->findWarehouseUnit($monitorId);
            if ($monitor === null) {
                return ['success' => false, 'message' => 'Монитор #' . $monitorId . ' не найден на складе или уже привязан к комплекту.'];
            }
            if (!EquipmentKitHelper::isMonitorEquipment($monitor)) {
                return ['success' => false, 'message' => 'Единица #' . $monitorId . ' не является монитором.'];
            }
            $monitors[] = $monitor;
        }

        $ups = null;
        if ($upsId !== null && $upsId > 0) {
            $ups = $this->findWarehouseUnit($upsId);
            if ($ups === null) {
                return ['success' => false, 'message' => 'ИБП не найден на складе или уже привязан к комплекту.'];
            }
            if (!EquipmentKitHelper::isUpsEquipment($ups)) {
                return ['success' => false, 'message' => 'Выбранная единица не является ИБП.'];
            }
        }

        if ($statusId === null || $statusId <= 0) {
            $statusId = DicEquipmentStatus::getDefaultId();
        }

        if ($ups !== null && $this->hostHasLinkType($hostId, EquipmentLink::TYPE_UPS)) {
            return ['success' => false, 'message' => 'У выбранного системного блока уже есть привязанный ИБП.'];
        }

        $updated = 0;
        $transaction = Yii::$app->db->beginTransaction();
        try {
            if (!$this->assignFromWarehouse($host, $responsibleUserId, $locationId, $statusId)) {
                throw new \RuntimeException('Не удалось выдать системный блок.');
            }
            $host->refresh();
            $this->applyHostNetworkProfile($host, $hostname, $ipAddress);
            $updated++;

            foreach ($monitors as $monitor) {
                $this->attachChildLink($host, $monitor, EquipmentLink::TYPE_MONITOR, 'issue_kit');
                $monitor->refresh();
                if (!$this->syncChildToHost($monitor, $host, $statusId)) {
                    throw new \RuntimeException('Не удалось синхронизировать монитор #' . $monitor->id . ' с комплектом.');
                }
                $updated++;
            }

            if ($ups !== null) {
                $this->attachChildLink($host, $ups, EquipmentLink::TYPE_UPS, 'issue_kit');
                $ups->refresh();
                if (!$this->syncChildToHost($ups, $host, $statusId)) {
                    throw new \RuntimeException('Не удалось синхронизировать ИБП с комплектом.');
                }
                $updated++;
            }

            $transaction->commit();
        } catch (\Throwable $e) {
            $transaction->rollBack();
            Yii::error('KitIssuanceService::issueKit failed: ' . $e->getMessage(), __METHOD__);

            return ['success' => false, 'message' => 'Ошибка выдачи комплекта: ' . $e->getMessage()];
        }

        $monitorCount = count($monitors);
        AuditLog::log('equipment.issue_kit', 'equipment', $hostId, 'success', [
            'monitor_ids' => $monitorIds,
            'ups_id' => $ups !== null ? (int) $ups->id : null,
            'user_id' => $responsibleUserId,
            'location_id' => $locationId,
        ]);

        $parts = ['системный блок'];
        if ($monitorCount === 1) {
            $parts[] = 'монитор';
        } elseif ($monitorCount > 1) {
            $parts[] = 'мониторы (' . $monitorCount . ')';
        }
        if ($ups !== null) {
            $parts[] = 'ИБП';
        }

        return [
            'success' => true,
            'message' => 'Выдан комплект: ' . implode(', ', $parts) . '.',
            'updated' => $updated,
        ];
    }

    /**
     * Выдача монитора или ИБП со склада и привязка к уже выданному системному блоку.
     *
     * @return array{success: bool, message: string, updated?: int}
     */
    public function issueComponentToHost(int $hostId, int $componentId, string $kind): array
    {
        $kind = trim($kind);
        if (!in_array($kind, ['monitor', 'ups'], true)) {
            return ['success' => false, 'message' => 'Укажите тип выдаваемой техники: монитор или ИБП.'];
        }
        if ($hostId <= 0 || $componentId <= 0) {
            return ['success' => false, 'message' => 'Укажите системный блок и технику со склада.'];
        }
        if ($hostId === $componentId) {
            return ['success' => false, 'message' => 'Системный блок и выдаваемая техника должны быть разными единицами.'];
        }

        $host = Equipment::find()
            ->where(['id' => $hostId, 'is_deleted' => false, 'is_archived' => false])
            ->with('location')
            ->one();
        if ($host === null) {
            return ['success' => false, 'message' => 'Системный блок не найден.'];
        }
        if (!EquipmentKitHelper::isHostEquipment($host)) {
            return ['success' => false, 'message' => 'Выдача со склада доступна для системного блока, ПК, ноутбука или моноблока.'];
        }
        if (EquipmentKitHelper::isEquipmentOnWarehouse($host)) {
            return ['success' => false, 'message' => 'Системный блок находится на складе. Для выдачи комплекта используйте операцию со склада.'];
        }
        if ($host->location_id === null || (int) $host->location_id <= 0) {
            return ['success' => false, 'message' => 'У системного блока не указано помещение — сначала назначьте помещение.'];
        }

        $component = $this->findWarehouseUnit($componentId);
        if ($component === null) {
            return ['success' => false, 'message' => 'Техника не найдена на складе или уже привязана к комплекту.'];
        }

        $linkType = $kind === 'ups' ? EquipmentLink::TYPE_UPS : EquipmentLink::TYPE_MONITOR;
        if ($kind === 'monitor' && !EquipmentKitHelper::isMonitorEquipment($component)) {
            return ['success' => false, 'message' => 'Выбранная единица не является монитором.'];
        }
        if ($kind === 'ups' && !EquipmentKitHelper::isUpsEquipment($component)) {
            return ['success' => false, 'message' => 'Выбранная единица не является ИБП.'];
        }
        if ($kind === 'ups' && $this->hostHasLinkType($hostId, EquipmentLink::TYPE_UPS)) {
            return ['success' => false, 'message' => 'У выбранного системного блока уже есть привязанный ИБП.'];
        }

        $statusId = DicEquipmentStatus::getDefaultId();
        $updated = 0;
        $transaction = Yii::$app->db->beginTransaction();
        try {
            $this->attachChildLink($host, $component, $linkType, 'issue_from_warehouse');
            $component->refresh();
            if (!$this->syncIssuedChildToHost($component, $host, $statusId)) {
                throw new \RuntimeException('Не удалось синхронизировать технику с системным блоком.');
            }
            $updated++;
            $transaction->commit();
        } catch (\Throwable $e) {
            $transaction->rollBack();
            Yii::error('KitIssuanceService::issueComponentToHost failed: ' . $e->getMessage(), __METHOD__);

            return ['success' => false, 'message' => 'Ошибка выдачи со склада: ' . $e->getMessage()];
        }

        AuditLog::log('equipment.issue_from_warehouse', 'equipment', $hostId, 'success', [
            'component_id' => $componentId,
            'kind' => $kind,
        ]);
        AuditLog::log('equipment.issue_from_warehouse', 'equipment', $componentId, 'success', [
            'host_id' => $hostId,
            'kind' => $kind,
        ]);

        $kindLabel = $kind === 'ups' ? 'ИБП' : 'монитор';

        return [
            'success' => true,
            'message' => 'Со склада выдан ' . $kindLabel . ' и привязан к системному блоку.',
            'updated' => $updated,
        ];
    }

    private function findWarehouseUnit(int $id): ?Equipment
    {
        $query = Equipment::find()
            ->alias('e')
            ->innerJoin(['l' => Location::tableName()], 'l.id = e.location_id')
            ->where([
                'e.id' => $id,
                'e.is_deleted' => false,
                'e.is_archived' => false,
                'l.location_type' => 'склад',
                'e.responsible_user_id' => null,
            ]);

        if (Yii::$app->db->getTableSchema('equipment_links', true) !== null) {
            $query->andWhere(['not exists', (new Query())
                ->from(['el' => EquipmentLink::tableName()])
                ->where('el.child_equipment_id = e.id')]);
        }

        /** @var Equipment|null $equipment */
        $equipment = $query->one();

        return $equipment;
    }

    private function hostHasLinkType(int $hostId, string $linkType): bool
    {
        if (Yii::$app->db->getTableSchema('equipment_links', true) === null) {
            return false;
        }

        return EquipmentLink::find()
            ->where(['parent_equipment_id' => $hostId, 'link_type' => $linkType])
            ->exists();
    }

    private function assignFromWarehouse(
        Equipment $equipment,
        int $userId,
        int $locationId,
        ?int $statusId
    ): bool {
        $oldResponsible = $equipment->responsible_user_id;
        $oldLocation = $equipment->location_id;
        $oldStatus = $equipment->status_id;

        $equipment->responsible_user_id = $userId;
        $equipment->location_id = $locationId;
        if ($statusId !== null && $statusId > 0) {
            $equipment->status_id = $statusId;
        }

        if (!EquipHistory::idsEqual($oldResponsible, $equipment->responsible_user_id)) {
            EquipHistory::log(
                $equipment->id,
                'assign',
                ['responsible_user_id' => $oldResponsible],
                ['responsible_user_id' => $equipment->responsible_user_id],
                'issue_kit'
            );
        }
        if (!EquipHistory::idsEqual($oldLocation, $equipment->location_id)) {
            EquipHistory::log(
                $equipment->id,
                'move',
                ['location_id' => $oldLocation],
                ['location_id' => $equipment->location_id],
                'issue_kit'
            );
        }
        if ($statusId !== null && $statusId > 0 && !EquipHistory::idsEqual($oldStatus, $equipment->status_id)) {
            EquipHistory::log(
                $equipment->id,
                'status_change',
                ['status_id' => $oldStatus],
                ['status_id' => $equipment->status_id],
                'issue_kit'
            );
        }

        if (!$equipment->save(false)) {
            Yii::error(
                'KitIssuanceService save failed for equipment #' . $equipment->id . ': ' . json_encode($equipment->errors, JSON_UNESCAPED_UNICODE),
                __METHOD__
            );

            return false;
        }

        UserEquipmentCardService::invalidateByUserId((int) $oldResponsible);
        UserEquipmentCardService::ensureCardForUser((int) $oldResponsible);
        UserEquipmentCardService::invalidateByUserId($userId);
        UserEquipmentCardService::ensureCardForUser($userId);

        return true;
    }

    private function attachChildLink(Equipment $host, Equipment $child, string $linkType, string $historyComment = 'issue_kit'): void
    {
        if (Yii::$app->db->getTableSchema('equipment_links', true) === null) {
            throw new \RuntimeException('Таблица связей оборудования недоступна.');
        }

        EquipmentLink::deleteAll([
            'child_equipment_id' => (int) $child->id,
            'link_type' => $linkType,
        ]);

        $link = new EquipmentLink();
        $link->parent_equipment_id = (int) $host->id;
        $link->child_equipment_id = (int) $child->id;
        $link->link_type = $linkType;
        $link->created_by = Yii::$app->user->id;
        if (!$link->save(false)) {
            throw new \RuntimeException('Не удалось создать связь комплекта: ' . json_encode($link->errors, JSON_UNESCAPED_UNICODE));
        }

        EquipHistory::log(
            (int) $child->id,
            'update',
            null,
            ['parent_equipment_id' => (int) $host->id, 'link_type' => $linkType],
            $historyComment
        );
    }

    private function syncChildToHost(Equipment $child, Equipment $host, ?int $statusId): bool
    {
        return $this->assignFromWarehouse(
            $child,
            (int) $host->responsible_user_id,
            (int) $host->location_id,
            $statusId
        );
    }

    /**
     * Синхронизация выданного со склада компонента с полевым хостом (ответственный может отсутствовать).
     */
    private function syncIssuedChildToHost(Equipment $child, Equipment $host, ?int $statusId): bool
    {
        $oldResponsible = $child->responsible_user_id;
        $oldLocation = $child->location_id;
        $oldStatus = $child->status_id;
        $hostUserId = $host->responsible_user_id !== null ? (int) $host->responsible_user_id : null;
        $hostLocationId = (int) $host->location_id;

        $child->responsible_user_id = $hostUserId;
        $child->location_id = $hostLocationId;
        if ($statusId !== null && $statusId > 0) {
            $child->status_id = $statusId;
        }

        if (!EquipHistory::idsEqual($oldResponsible, $child->responsible_user_id)) {
            EquipHistory::log(
                $child->id,
                $hostUserId ? 'assign' : 'unassign',
                ['responsible_user_id' => $oldResponsible],
                ['responsible_user_id' => $child->responsible_user_id],
                'issue_from_warehouse'
            );
        }
        if (!EquipHistory::idsEqual($oldLocation, $child->location_id)) {
            EquipHistory::log(
                $child->id,
                'move',
                ['location_id' => $oldLocation],
                ['location_id' => $child->location_id],
                'issue_from_warehouse'
            );
        }
        if ($statusId !== null && $statusId > 0 && !EquipHistory::idsEqual($oldStatus, $child->status_id)) {
            EquipHistory::log(
                $child->id,
                'status_change',
                ['status_id' => $oldStatus],
                ['status_id' => $child->status_id],
                'issue_from_warehouse'
            );
        }

        if (!$child->save(false)) {
            return false;
        }

        UserEquipmentCardService::invalidateByUserId((int) $oldResponsible);
        UserEquipmentCardService::ensureCardForUser((int) $oldResponsible);
        if ($hostUserId) {
            UserEquipmentCardService::invalidateByUserId($hostUserId);
            UserEquipmentCardService::ensureCardForUser($hostUserId);
        }

        return true;
    }

    /**
     * @param int[] $equipmentIds
     * @return array<int, array{hostname: string, ip: string}>
     */
    private function loadHostNetworkProfiles(array $equipmentIds): array
    {
        $equipmentIds = array_values(array_unique(array_filter(array_map('intval', $equipmentIds), static function (int $id): bool {
            return $id > 0;
        })));
        if ($equipmentIds === []) {
            return [];
        }

        $schema = Yii::$app->db->getTableSchema('part_char_values', true);
        if ($schema === null) {
            return array_fill_keys($equipmentIds, ['hostname' => '', 'ip' => '']);
        }

        $idCol = isset($schema->columns['equipment_id']) ? 'equipment_id' : 'id_arm';
        $out = array_fill_keys($equipmentIds, ['hostname' => '', 'ip' => '']);

        $rows = (new Query())
            ->select([
                'eq_id' => 'pcv.' . $idCol,
                'char_name' => 'sc.name',
                'value_text' => new \yii\db\Expression('COALESCE(pcv.value_text, pcv.value_num::text)'),
            ])
            ->from(['pcv' => 'part_char_values'])
            ->innerJoin(['sp' => 'spr_parts'], 'sp.id = pcv.part_id')
            ->innerJoin(['sc' => 'spr_chars'], 'sc.id = pcv.char_id')
            ->where(['pcv.' . $idCol => $equipmentIds, 'sp.name' => 'ПК'])
            ->andWhere(['sc.name' => ['Имя ПК', 'IP адрес']])
            ->all();

        foreach ($rows as $row) {
            $id = (int) ($row['eq_id'] ?? 0);
            if (!isset($out[$id])) {
                continue;
            }
            $charName = trim((string) ($row['char_name'] ?? ''));
            $value = trim((string) ($row['value_text'] ?? ''));
            if ($charName === 'Имя ПК') {
                $out[$id]['hostname'] = $value;
            } elseif ($charName === 'IP адрес') {
                $out[$id]['ip'] = $value;
            }
        }

        return $out;
    }

    private function applyHostNetworkProfile(Equipment $host, ?string $hostname, ?string $ipAddress): void
    {
        $partChar = [];
        $hostname = $hostname !== null ? trim($hostname) : '';
        $ipAddress = $ipAddress !== null ? trim($ipAddress) : '';
        if ($hostname !== '') {
            $partChar['hostname'] = $hostname;
        }
        if ($ipAddress !== '') {
            $partChar['ip'] = $ipAddress;
        }
        if ($partChar === []) {
            return;
        }

        (new EquipmentPartCharService())->savePartCharValues(
            (int) $host->id,
            $partChar,
            $host->resolveEquipmentTypeName()
        );
    }
}
