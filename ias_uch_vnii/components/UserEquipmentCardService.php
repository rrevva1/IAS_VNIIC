<?php

namespace app\components;

use app\models\entities\Equipment;
use app\models\entities\UserEquipmentCard;
use app\models\entities\Users;
use Yii;

class UserEquipmentCardService
{
    public static function isCardsTableReady(): bool
    {
        return Yii::$app->db->getTableSchema(UserEquipmentCard::tableName(), true) !== null;
    }

    public static function invalidateByUserId(?int $userId): void
    {
        if (!self::isCardsTableReady()) {
            return;
        }
        if (!$userId) {
            return;
        }

        $card = UserEquipmentCard::findOne(['user_id' => $userId]);
        if ($card === null) {
            return;
        }
        if (!$card->is_signed) {
            return;
        }

        $card->is_signed = false;
        $card->signed_at = null;
        $card->signed_by_admin_id = null;
        $card->version_no = (int) $card->version_no + 1;
        $card->save(false);
    }

    public static function ensureCardForUser(int $userId): ?UserEquipmentCard
    {
        if (!self::isCardsTableReady()) {
            return null;
        }
        $hasEquipment = Equipment::find()
            ->where(['responsible_user_id' => $userId, 'is_deleted' => false, 'is_archived' => false])
            ->exists();

        $card = UserEquipmentCard::findOne(['user_id' => $userId]);

        if (!$hasEquipment) {
            if ($card !== null) {
                $card->delete();
            }
            return null;
        }

        if ($card === null) {
            $card = new UserEquipmentCard();
            $card->user_id = $userId;
            $card->is_signed = false;
            $card->version_no = 1;
            $card->save(false);
        }

        $hash = self::buildSnapshotHash($userId);
        if ($card->last_snapshot_hash !== $hash) {
            $card->last_snapshot_hash = $hash;
            $card->is_signed = false;
            $card->signed_at = null;
            $card->signed_by_admin_id = null;
            $card->version_no = max(1, (int) $card->version_no + 1);
            $card->save(false);
        }

        return $card;
    }

    public static function buildSnapshotHash(int $userId): string
    {
        $rows = Equipment::find()
            ->select(['id', 'inventory_number', 'name', 'location_id', 'status_id'])
            ->where(['responsible_user_id' => $userId, 'is_deleted' => false, 'is_archived' => false])
            ->orderBy(['id' => SORT_ASC])
            ->asArray()
            ->all();

        return hash('sha256', json_encode($rows, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES));
    }

    public static function buildCardData(int $userId): array
    {
        $user = Users::findOne($userId);
        $equipment = Equipment::find()
            ->with(['location', 'equipmentStatus'])
            ->where(['responsible_user_id' => $userId, 'is_deleted' => false, 'is_archived' => false])
            ->orderBy(['name' => SORT_ASC, 'id' => SORT_ASC])
            ->all();

        return [
            'user' => $user,
            'equipment' => $equipment,
            'generated_at' => date('Y-m-d H:i:s'),
        ];
    }
}

