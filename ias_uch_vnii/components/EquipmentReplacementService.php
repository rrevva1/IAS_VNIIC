<?php

namespace app\components;

use app\models\dictionaries\DicEquipmentStatus;
use app\models\entities\EquipHistory;
use app\models\entities\Equipment;
use app\models\entities\EquipmentLink;
use app\models\entities\Location;
use Yii;
use yii\db\Query;

/**
 * Замена полевой техники (СБ / монитор / ИБП) единицей со склада.
 *
 * Старая техника уходит на склад с указанным статусом.
 * Новая занимает место старой: ответственный, помещение и связи комплекта.
 */
class EquipmentReplacementService
{
    public const KIND_HOST = 'host';
    public const KIND_MONITOR = 'monitor';
    public const KIND_UPS = 'ups';

    /**
     * @return array{success: bool, message?: string, items?: array, warehouse_location_id?: ?int, kind?: string, match_equipment_type?: ?string}
     */
    public function getWarehouseOptions(
        string $kind,
        ?int $warehouseLocationId = null,
        ?int $matchEquipmentId = null
    ): array {
        $matchType = null;
        if ($matchEquipmentId !== null && $matchEquipmentId > 0) {
            $matchEquipment = Equipment::findOne($matchEquipmentId);
            if ($matchEquipment === null || $matchEquipment->is_deleted || $matchEquipment->is_archived) {
                return ['success' => false, 'message' => 'Заменяемая техника не найдена.'];
            }
            $detectedKind = $this->detectEquipmentKind($matchEquipment);
            if ($detectedKind === null) {
                return ['success' => false, 'message' => 'Замена доступна только для системного блока, монитора или ИБП.'];
            }
            if ($kind !== '' && $kind !== $detectedKind) {
                return ['success' => false, 'message' => 'Тип замены не соответствует выбранной технике.'];
            }
            $kind = $detectedKind;
            $matchType = trim((string) $matchEquipment->equipment_type);
        }

        if (!in_array($kind, [self::KIND_HOST, self::KIND_MONITOR, self::KIND_UPS], true)) {
            return ['success' => false, 'message' => 'Некорректный тип техники для замены.'];
        }

        $linkedChildExists = (new Query())
            ->from(['el' => EquipmentLink::tableName()])
            ->where('el.child_equipment_id = e.id');

        $baseQuery = Equipment::find()
            ->alias('e')
            ->innerJoin(['l' => Location::tableName()], 'l.id = e.location_id')
            ->with(['location', 'equipmentStatus'])
            ->where([
                'e.is_deleted' => false,
                'e.is_archived' => false,
                'l.location_type' => 'склад',
            ])
            ->andWhere(['e.responsible_user_id' => null]);

        if (Yii::$app->db->getTableSchema('equipment_links', true) !== null) {
            $baseQuery->andWhere(['not exists', $linkedChildExists]);
        }

        if ($warehouseLocationId !== null && $warehouseLocationId > 0) {
            $baseQuery->andWhere(['e.location_id' => $warehouseLocationId]);
        }

        if ($matchType !== null && $matchType !== '') {
            $baseQuery->andWhere(
                'LOWER(TRIM(e.equipment_type)) = :match_equipment_type',
                [':match_equipment_type' => mb_strtolower($matchType, 'UTF-8')]
            );
        }

        $rows = $baseQuery
            ->orderBy(['e.inventory_number' => SORT_ASC, 'e.name' => SORT_ASC])
            ->limit(500)
            ->all();

        $items = [];
        foreach ($rows as $equipment) {
            if (!$this->equipmentMatchesKind($equipment, $kind)) {
                continue;
            }
            if (!$this->equipmentTypeMatches($equipment, $matchType, $kind)) {
                continue;
            }
            $row = EquipmentKitHelper::equipmentToOptionRow($equipment);
            $label = EquipmentKitHelper::formatEquipmentOptionLabel($equipment, false);
            $statusName = trim((string) ($equipment->equipmentStatus->status_name ?? ''));
            if ($statusName !== '') {
                $label .= ' · ' . $statusName;
            }
            $row['label'] = $label;
            $row['status_id'] = $equipment->status_id !== null ? (int) $equipment->status_id : null;
            $row['status_name'] = $statusName !== '' ? $statusName : null;
            $items[] = $row;
        }

        return [
            'success' => true,
            'kind' => $kind,
            'items' => $items,
            'match_equipment_type' => $matchType !== '' ? $matchType : null,
            'warehouse_location_id' => $warehouseLocationId !== null && $warehouseLocationId > 0
                ? $warehouseLocationId
                : null,
        ];
    }

    /**
     * @return array{success: bool, message: string, updated?: int, details?: array}
     */
    public function replace(
        int $oldEquipmentId,
        int $newEquipmentId,
        int $replacedStatusId = 0,
        ?int $oldWarehouseLocationId = null,
        bool $changeDescription = false,
        ?string $replacedDescription = null,
        bool $applyNetworkProfile = false,
        ?string $hostname = null,
        ?string $ipAddress = null
    ): array {
        if ($oldEquipmentId <= 0 || $newEquipmentId <= 0) {
            return ['success' => false, 'message' => 'Укажите заменяемую технику и замену со склада.'];
        }
        if ($oldEquipmentId === $newEquipmentId) {
            return ['success' => false, 'message' => 'Заменяемая техника и замена должны быть разными единицами.'];
        }

        $changeStatus = $replacedStatusId > 0;
        if ($changeStatus) {
            $status = DicEquipmentStatus::findOne($replacedStatusId);
            if ($status === null || (string) $status->status_code === 'archived') {
                return ['success' => false, 'message' => 'Указан недопустимый статус для заменяемой техники.'];
            }
        }

        $normalizedDescription = null;
        if ($changeDescription) {
            $normalizedDescription = trim((string) $replacedDescription);
            if ($normalizedDescription === '') {
                $normalizedDescription = null;
            }
        }

        $old = Equipment::findOne($oldEquipmentId);
        $new = Equipment::findOne($newEquipmentId);
        if ($old === null || $old->is_deleted || $old->is_archived) {
            return ['success' => false, 'message' => 'Заменяемая техника не найдена.'];
        }
        if ($new === null || $new->is_deleted || $new->is_archived) {
            return ['success' => false, 'message' => 'Техника со склада не найдена.'];
        }
        if (EquipmentKitHelper::isEquipmentOnWarehouse($old)) {
            return ['success' => false, 'message' => 'Заменяемая техника уже находится на складе.'];
        }
        if (!EquipmentKitHelper::isEquipmentOnWarehouse($new)) {
            return ['success' => false, 'message' => 'Замена должна быть выбрана со склада.'];
        }

        $kind = $this->detectEquipmentKind($old);
        if ($kind === null) {
            return ['success' => false, 'message' => 'Замена доступна только для системного блока, монитора или ИБП.'];
        }
        if (!$this->equipmentMatchesKind($new, $kind)) {
            return ['success' => false, 'message' => 'Тип замены со склада должен совпадать с заменяемой техникой.'];
        }
        if (!$this->equipmentTypeMatches($new, trim((string) $old->equipment_type), $kind)) {
            return ['success' => false, 'message' => 'Тип техники со склада должен совпадать с типом заменяемой единицы.'];
        }

        $warehouseLocationId = $oldWarehouseLocationId !== null && $oldWarehouseLocationId > 0
            ? $oldWarehouseLocationId
            : (int) $new->location_id;
        if ($warehouseLocationId <= 0 || !EquipmentKitHelper::isWarehouseLocationId($warehouseLocationId)) {
            return ['success' => false, 'message' => 'Не удалось определить склад для старой техники.'];
        }

        $inUseStatusId = DicEquipmentStatus::getDefaultId();
        $updated = 0;
        $statusChanged = 0;
        $linksMoved = 0;

        $transaction = Yii::$app->db->beginTransaction();
        try {
            $oldUserId = $old->responsible_user_id !== null ? (int) $old->responsible_user_id : null;
            $oldLocationId = $old->location_id !== null ? (int) $old->location_id : null;
            $oldStatusId = $old->status_id !== null ? (int) $old->status_id : null;

            $parentLink = null;
            $childLinkRows = [];
            if (Yii::$app->db->getTableSchema('equipment_links', true) !== null) {
                if ($kind === self::KIND_HOST) {
                    $childLinks = EquipmentLink::find()
                        ->where(['parent_equipment_id' => $old->id])
                        ->all();
                    foreach ($childLinks as $link) {
                        $childLinkRows[] = [
                            'child_id' => (int) $link->child_equipment_id,
                            'link_type' => (string) $link->link_type,
                        ];
                        $childId = (int) $link->child_equipment_id;
                        $linkType = (string) $link->link_type;
                        $link->delete();
                        EquipHistory::log(
                            $childId,
                            'update',
                            ['parent_equipment_id' => $old->id, 'link_type' => $linkType],
                            ['parent_equipment_id' => null],
                            'replace_from_warehouse_detach'
                        );
                    }
                } else {
                    $parentLink = EquipmentLink::find()
                        ->where(['child_equipment_id' => $old->id])
                        ->one();
                    if ($parentLink !== null) {
                        $parentId = (int) $parentLink->parent_equipment_id;
                        $linkType = (string) $parentLink->link_type;
                        $parentLink->delete();
                        EquipHistory::log(
                            $old->id,
                            'update',
                            ['parent_equipment_id' => $parentId, 'link_type' => $linkType],
                            ['parent_equipment_id' => null],
                            'replace_from_warehouse_detach'
                        );
                    }
                }
            }

            // 2) Новая техника занимает место старой
            $newChanged = false;
            $newOldUser = $new->responsible_user_id;
            $newOldLocation = $new->location_id;
            $newOldStatus = $new->status_id;

            if (!EquipHistory::idsEqual($new->responsible_user_id, $oldUserId)) {
                $new->responsible_user_id = $oldUserId;
                EquipHistory::log(
                    $new->id,
                    $oldUserId ? 'assign' : 'unassign',
                    ['responsible_user_id' => $newOldUser],
                    ['responsible_user_id' => $oldUserId],
                    'replace_from_warehouse'
                );
                $newChanged = true;
            }
            if ($oldLocationId !== null && !EquipHistory::idsEqual($new->location_id, $oldLocationId)) {
                $new->location_id = $oldLocationId;
                EquipHistory::log(
                    $new->id,
                    'move',
                    ['location_id' => $newOldLocation],
                    ['location_id' => $oldLocationId],
                    'replace_from_warehouse'
                );
                $newChanged = true;
            }
            if ($inUseStatusId !== null && !EquipHistory::idsEqual($new->status_id, $inUseStatusId)) {
                $new->status_id = $inUseStatusId;
                EquipHistory::log(
                    $new->id,
                    'status_change',
                    ['status_id' => $newOldStatus],
                    ['status_id' => $inUseStatusId],
                    'replace_from_warehouse'
                );
                $newChanged = true;
            }

            if ($newChanged && !$new->save(false)) {
                throw new \RuntimeException('Не удалось сохранить новую технику.');
            }
            if ($newChanged) {
                $updated++;
            }

            // 3) Перенос связей на новую технику
            if ($kind === self::KIND_HOST) {
                foreach ($childLinkRows as $row) {
                    $childId = (int) ($row['child_id'] ?? 0);
                    $linkType = (string) ($row['link_type'] ?? '');
                    if ($childId <= 0 || $linkType === '') {
                        continue;
                    }
                    EquipmentLink::deleteAll([
                        'child_equipment_id' => $childId,
                        'link_type' => $linkType,
                    ]);
                    $equipmentLink = new EquipmentLink();
                    $equipmentLink->parent_equipment_id = $new->id;
                    $equipmentLink->child_equipment_id = $childId;
                    $equipmentLink->link_type = $linkType;
                    $equipmentLink->created_by = Yii::$app->user->id;
                    $equipmentLink->save(false);
                    EquipHistory::log(
                        $childId,
                        'update',
                        null,
                        ['parent_equipment_id' => $new->id, 'link_type' => $linkType],
                        'replace_from_warehouse_attach'
                    );
                    $linksMoved++;
                }
            } elseif ($parentLink !== null) {
                $parentId = (int) $parentLink->parent_equipment_id;
                $linkType = (string) $parentLink->link_type;
                if ($parentId > 0 && $linkType !== '') {
                    EquipmentLink::deleteAll([
                        'child_equipment_id' => $new->id,
                        'link_type' => $linkType,
                    ]);
                    $equipmentLink = new EquipmentLink();
                    $equipmentLink->parent_equipment_id = $parentId;
                    $equipmentLink->child_equipment_id = $new->id;
                    $equipmentLink->link_type = $linkType;
                    $equipmentLink->created_by = Yii::$app->user->id;
                    $equipmentLink->save(false);
                    EquipHistory::log(
                        $new->id,
                        'update',
                        null,
                        ['parent_equipment_id' => $parentId, 'link_type' => $linkType],
                        'replace_from_warehouse_attach'
                    );
                    $linksMoved++;
                }
            }

            // 3.5) Сетевой профиль: на новую СБ, со старой снимаем
            if ($kind === self::KIND_HOST && $applyNetworkProfile) {
                $this->transferHostNetworkProfile(
                    $old,
                    $new,
                    trim((string) $hostname),
                    trim((string) $ipAddress)
                );
            }

            // 4) Старую — на склад со сменой статуса
            $oldChanged = false;
            if (!EquipHistory::idsEqual($old->location_id, $warehouseLocationId)) {
                $prevLoc = $old->location_id;
                $old->location_id = $warehouseLocationId;
                EquipHistory::log(
                    $old->id,
                    'move',
                    ['location_id' => $prevLoc],
                    ['location_id' => $warehouseLocationId],
                    'replace_from_warehouse'
                );
                $oldChanged = true;
            }
            if ($old->responsible_user_id !== null) {
                $prevUser = $old->responsible_user_id;
                $old->responsible_user_id = null;
                EquipHistory::log(
                    $old->id,
                    'unassign',
                    ['responsible_user_id' => $prevUser],
                    ['responsible_user_id' => null],
                    'replace_from_warehouse'
                );
                $oldChanged = true;
            }
            if ($changeStatus && !EquipHistory::idsEqual($old->status_id, $replacedStatusId)) {
                $old->status_id = $replacedStatusId;
                EquipHistory::log(
                    $old->id,
                    'status_change',
                    ['status_id' => $oldStatusId],
                    ['status_id' => $replacedStatusId],
                    'replace_from_warehouse'
                );
                $statusChanged++;
                $oldChanged = true;
            }
            if ($changeDescription) {
                $prevDescription = $old->description !== null ? (string) $old->description : null;
                $nextDescription = $normalizedDescription;
                if ((string) ($prevDescription ?? '') !== (string) ($nextDescription ?? '')) {
                    $old->description = $nextDescription;
                    EquipHistory::log(
                        $old->id,
                        'update',
                        ['description' => $prevDescription],
                        ['description' => $nextDescription],
                        'replace_from_warehouse'
                    );
                    $oldChanged = true;
                }
            }

            if ($oldChanged && !$old->save(false)) {
                throw new \RuntimeException('Не удалось сохранить заменяемую технику.');
            }
            if ($oldChanged) {
                $updated++;
            }

            AuditLog::log('equipment.replace_from_warehouse', 'equipment', $old->id, 'success', [
                'old_id' => $old->id,
                'new_id' => $new->id,
                'kind' => $kind,
                'replaced_status_id' => $replacedStatusId,
            ]);
            AuditLog::log('equipment.replace_from_warehouse', 'equipment', $new->id, 'success', [
                'old_id' => $old->id,
                'new_id' => $new->id,
                'kind' => $kind,
            ]);

            if ($oldUserId) {
                UserEquipmentCardService::invalidateByUserId($oldUserId);
                UserEquipmentCardService::ensureCardForUser($oldUserId);
            }

            $transaction->commit();
        } catch (\Throwable $e) {
            $transaction->rollBack();

            return ['success' => false, 'message' => 'Ошибка замены со склада: ' . $e->getMessage()];
        }

        return [
            'success' => true,
            'message' => 'Замена со склада выполнена.',
            'updated' => $updated,
            'details' => [
                'status_changed' => $statusChanged,
                'links_moved' => $linksMoved,
                'old_equipment_id' => $oldEquipmentId,
                'new_equipment_id' => $newEquipmentId,
            ],
        ];
    }

    public function detectEquipmentKind(Equipment $equipment): ?string
    {
        if (EquipmentKitHelper::isHostEquipment($equipment)) {
            return self::KIND_HOST;
        }
        if (EquipmentKitHelper::isMonitorEquipment($equipment)) {
            return self::KIND_MONITOR;
        }
        if (EquipmentKitHelper::isUpsEquipment($equipment)) {
            return self::KIND_UPS;
        }

        return null;
    }

    private function equipmentMatchesKind(Equipment $equipment, string $kind): bool
    {
        if ($kind === self::KIND_HOST) {
            return EquipmentKitHelper::isHostEquipment($equipment);
        }
        if ($kind === self::KIND_MONITOR) {
            return EquipmentKitHelper::isMonitorEquipment($equipment);
        }
        if ($kind === self::KIND_UPS) {
            return EquipmentKitHelper::isUpsEquipment($equipment);
        }

        return false;
    }

    /**
     * Записывает имя ПК / IP на новую СБ и очищает их у старой (уходит на склад).
     */
    private function transferHostNetworkProfile(
        Equipment $old,
        Equipment $new,
        string $hostname,
        string $ipAddress
    ): void {
        $partChar = [];
        if ($hostname !== '') {
            $partChar['hostname'] = $hostname;
        }
        if ($ipAddress !== '') {
            $partChar['ip'] = $ipAddress;
        }
        if ($partChar !== []) {
            (new EquipmentPartCharService())->savePartCharValues(
                (int) $new->id,
                $partChar,
                $new->resolveEquipmentTypeName()
            );
            EquipHistory::log(
                $new->id,
                'update',
                null,
                [
                    'hostname' => $hostname !== '' ? $hostname : null,
                    'ip' => $ipAddress !== '' ? $ipAddress : null,
                ],
                'replace_from_warehouse'
            );
        }

        $this->clearHostNetworkChars((int) $old->id);
        EquipHistory::log(
            $old->id,
            'update',
            null,
            ['hostname' => null, 'ip' => null],
            'replace_from_warehouse'
        );
    }

    private function clearHostNetworkChars(int $equipmentId): void
    {
        if ($equipmentId <= 0 || Yii::$app->db->getTableSchema('part_char_values', true) === null) {
            return;
        }

        $pairs = [
            ['ПК', 'Имя ПК'],
            ['ПК', 'IP адрес'],
        ];
        foreach ($pairs as [$partName, $charName]) {
            $part = \app\models\entities\SprParts::find()->where(['name' => $partName])->one();
            $char = \app\models\entities\SprChars::find()->where(['name' => $charName])->one();
            if ($part === null || $char === null) {
                continue;
            }
            $eqCol = 'equipment_id';
            $schema = Yii::$app->db->getTableSchema('part_char_values', true);
            if ($schema === null || !isset($schema->columns['equipment_id'])) {
                $eqCol = 'id_arm';
            }
            \app\models\entities\PartCharValues::deleteAll([
                $eqCol => $equipmentId,
                'part_id' => $part->id,
                'char_id' => $char->id,
            ]);
        }
    }

    /**
     * Для хостов — строгое совпадение equipment_type (ноутбук ≠ системный блок).
     * Для монитора/ИБП достаточно kind, если тип у одной из сторон пустой.
     */
    private function equipmentTypeMatches(Equipment $equipment, ?string $expectedType, string $kind): bool
    {
        $expected = trim((string) $expectedType);
        if ($expected === '') {
            return true;
        }
        $actual = trim((string) $equipment->equipment_type);
        if ($actual === '') {
            return $kind !== self::KIND_HOST;
        }

        return mb_strtolower($actual, 'UTF-8') === mb_strtolower($expected, 'UTF-8');
    }
}
