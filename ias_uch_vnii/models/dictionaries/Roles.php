<?php

namespace app\models\dictionaries;

use app\models\entities\Users;
use Yii;
use yii\helpers\ArrayHelper;

/**
 * Модель для таблицы "roles" (схема tech_accounting).
 *
 * @property int $id
 * @property string $role_code
 * @property string $role_name
 * @property string|null $description
 * @property bool $is_system
 * @property bool $is_archived
 *
 * @property Users[] $users через user_roles
 */
class Roles extends \yii\db\ActiveRecord
{
    public static function tableName()
    {
        return 'roles';
    }

    public function rules()
    {
        return [
            [['role_code', 'role_name'], 'required'],
            [['role_code'], 'string', 'max' => 50],
            [['role_name'], 'string', 'max' => 150],
            [['description'], 'string'],
            [['is_system', 'is_archived'], 'boolean'],
            [['role_code'], 'unique'],
        ];
    }

    public function attributeLabels()
    {
        return [
            'id' => 'ID',
            'role_code' => 'Код роли',
            'role_name' => 'Роль',
            'description' => 'Описание',
        ];
    }

    /**
     * Пользователи с этой ролью (через user_roles).
     *
     * @return \yii\db\ActiveQuery
     */
    public function getUsers()
    {
        return $this->hasMany(Users::class, ['id' => 'user_id'])
            ->viaTable('user_roles', ['role_id' => 'id'], function ($q) {
                $q->andWhere(['user_roles.is_active' => true])->andWhere(['user_roles.revoked_at' => null]);
            });
    }

    /**
     * Список ролей для выпадающего списка [id => role_name].
     */
    public static function getList(): array
    {
        return ArrayHelper::map(
            self::find()->orderBy(['role_name' => SORT_ASC])->all(),
            'id',
            'role_name'
        );
    }
}
