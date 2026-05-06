<?php

namespace app\models\entities;

use yii\db\ActiveRecord;

class UserEquipmentCard extends ActiveRecord
{
    public static function tableName()
    {
        return 'user_equipment_cards';
    }

    public function rules()
    {
        return [
            [['user_id'], 'required'],
            [['user_id', 'signed_by_admin_id', 'version_no'], 'integer'],
            [['is_signed'], 'boolean'],
            [['signed_at', 'created_at', 'updated_at'], 'safe'],
            [['last_snapshot_hash'], 'string', 'max' => 64],
            [['user_id'], 'unique'],
        ];
    }

    public function getUser()
    {
        return $this->hasOne(Users::class, ['id' => 'user_id']);
    }

    public function getSignedByAdmin()
    {
        return $this->hasOne(Users::class, ['id' => 'signed_by_admin_id']);
    }
}

