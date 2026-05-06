<?php

namespace app\models\entities;

use app\models\dictionaries\Roles;
use yii\db\ActiveRecord;

/**
 * Связь пользователь — роль (таблица user_roles, схема tech_accounting).
 *
 * @property int $id
 * @property int $user_id
 * @property int $role_id
 * @property int|null $assigned_by
 * @property string $assigned_at
 * @property string|null $revoked_at
 * @property bool $is_active
 *
 * @property Users $user
 * @property Roles $role
 */
class UserRoles extends ActiveRecord
{
    public static function tableName()
    {
        return 'user_roles';
    }

    public function rules()
    {
        return [
            [['user_id', 'role_id'], 'required'],
            [['user_id', 'role_id', 'assigned_by'], 'integer'],
            [['assigned_at', 'revoked_at'], 'safe'],
            [['is_active'], 'boolean'],
            [['user_id'], 'exist', 'targetClass' => Users::class, 'targetAttribute' => ['user_id' => 'id']],
            [['role_id'], 'exist', 'targetClass' => Roles::class, 'targetAttribute' => ['role_id' => 'id']],
        ];
    }

    public function getUser()
    {
        return $this->hasOne(Users::class, ['id' => 'user_id']);
    }

    public function getRole()
    {
        return $this->hasOne(Roles::class, ['id' => 'role_id']);
    }
}
