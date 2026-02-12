<?php

namespace app\models\entities;

use app\models\dictionaries\Roles;
use Yii;
use yii\web\IdentityInterface;

/**
 * Модель для таблицы "users" (схема tech_accounting).
 *
 * @property int $id
 * @property string|null $username
 * @property string $full_name
 * @property string|null $email
 * @property string|null $password_hash
 * @property bool $is_active
 * @property bool $is_locked
 *
 * @property Roles[] $roles через user_roles
 */
class Users extends \yii\db\ActiveRecord implements IdentityInterface
{
    /** @var string Виртуальное поле для ввода пароля */
    public $password_plain;

    /** @var int|null ID роли для формы (одна роль) */
    public $role_id;

    public static function tableName()
    {
        return 'users';
    }

    public function rules()
    {
        return [
            [['full_name'], 'required'],
            [['username', 'email', 'position', 'department', 'phone'], 'string', 'max' => 255],
            [['full_name'], 'string', 'max' => 200],
            [['email'], 'string', 'max' => 150],
            [['username'], 'unique'],
            [['email'], 'email'],
            [['is_active', 'is_locked', 'is_deleted'], 'boolean'],
            [['password_plain'], 'required', 'on' => 'create'],
            [['password_plain'], 'string', 'min' => 6, 'max' => 255],
            [['role_id'], 'integer'],
            [['role_id'], 'exist', 'skipOnEmpty' => true, 'targetClass' => Roles::class, 'targetAttribute' => ['role_id' => 'id']],
            [['full_name', 'email', 'password_plain'], 'filter', 'filter' => 'trim'],
        ];
    }

    public function attributeLabels()
    {
        return [
            'id' => 'ID',
            'username' => 'Логин',
            'full_name' => 'ФИО',
            'email' => 'Email',
            'password_hash' => 'Пароль (хэш)',
            'password_plain' => 'Пароль',
            'position' => 'Должность',
            'department' => 'Отдел',
            'phone' => 'Телефон',
        ];
    }

    public function getRole()
    {
        $roleIds = $this->getActiveRoleIds();
        if (empty($roleIds)) {
            return null;
        }
        return Roles::findOne($roleIds[0]);
    }

    /**
     * Роли пользователя (через user_roles, только активные).
     *
     * @return \yii\db\ActiveQuery
     */
    public function getRoles()
    {
        return $this->hasMany(Roles::class, ['id' => 'role_id'])
            ->viaTable('user_roles', ['user_id' => 'id'], function ($q) {
                $q->andWhere(['user_roles.is_active' => true])
                    ->andWhere(['user_roles.revoked_at' => null]);
            });
    }

    private function getActiveRoleIds(): array
    {
        return UserRoles::find()
            ->select('role_id')
            ->where(['user_id' => $this->id, 'is_active' => true])
            ->andWhere(['revoked_at' => null])
            ->column();
    }

    public function isAdmin()
    {
        return $this->hasRoleCode('admin');
    }

    public function isUser()
    {
        return $this->hasRoleCode('user');
    }

    public function isAdministrator()
    {
        return $this->hasRoleCode('admin');
    }

    public function isRegularUser()
    {
        return $this->hasRoleCode('user');
    }

    private function hasRoleCode(string $code): bool
    {
        $codes = Roles::find()
            ->select('role_code')
            ->innerJoin('user_roles', 'user_roles.role_id = roles.id')
            ->where(['user_roles.user_id' => $this->id, 'user_roles.is_active' => true])
            ->andWhere(['user_roles.revoked_at' => null])
            ->column();
        return in_array($code, $codes, true);
    }

    // ---------- IdentityInterface ----------

    public static function findIdentity($id)
    {
        return static::findOne(['id' => $id]);
    }

    public static function findIdentityByAccessToken($token, $type = null)
    {
        return null;
    }

    public function getId()
    {
        return $this->getAttribute('id');
    }

    public function getAuthKey()
    {
        return null;
    }

    public function validateAuthKey($authKey)
    {
        return false;
    }

    public static function findByUsername($username)
    {
        return static::find()
            ->andWhere(['or', ['username' => $username], ['email' => $username]])
            ->andWhere(['is_active' => true])
            ->andWhere(['is_deleted' => false])
            ->one();
    }

    public static function findByEmail($email)
    {
        return static::findOne(['email' => $email, 'is_active' => true, 'is_deleted' => false]);
    }

    public function validatePassword($password)
    {
        if (empty($this->password_hash) || empty($password)) {
            return false;
        }
        try {
            return Yii::$app->security->validatePassword($password, $this->password_hash);
        } catch (\Throwable $e) {
            return false;
        }
    }

    public function setPassword($password)
    {
        $this->password_hash = Yii::$app->security->generatePasswordHash($password);
    }

    public function generateAuthKey()
    {
        // В новой схеме нет поля auth_key
    }

    public function scenarios()
    {
        $s = parent::scenarios();
        $s['create'] = ['full_name', 'username', 'email', 'password_plain', 'role_id', 'position', 'department', 'phone'];
        $s['update'] = ['full_name', 'username', 'email', 'password_plain', 'role_id', 'position', 'department', 'phone'];
        return $s;
    }

    public function beforeSave($insert)
    {
        if (!parent::beforeSave($insert)) {
            return false;
        }
        if (!empty($this->password_plain)) {
            $this->setPassword($this->password_plain);
            $this->password_plain = null;
        }
        return true;
    }

    public function afterSave($insert, $changedAttributes)
    {
        parent::afterSave($insert, $changedAttributes);
        if ($this->role_id !== null && $this->role_id !== '') {
            $this->assignRole((int) $this->role_id);
        }
    }

    public function afterFind()
    {
        parent::afterFind();
        $this->role_id = $this->getRoleIdForForm();
    }

    public function getUsername()
    {
        return $this->username ?: $this->email;
    }

    public function getRoleName(): ?string
    {
        $role = $this->role;
        return $role ? $role->role_name : null;
    }

    public static function getUsersWithRoles()
    {
        return self::find()->joinWith(['roles'])->all();
    }

    public static function getUsersWithRussianRoles()
    {
        return self::find()
            ->innerJoin('user_roles', 'user_roles.user_id = users.id')
            ->innerJoin('roles', 'roles.id = user_roles.role_id')
            ->where(['user_roles.is_active' => true])
            ->andWhere(['user_roles.revoked_at' => null])
            ->andWhere(['in', 'roles.role_name', ['Администратор', 'Пользователь', 'администратор', 'пользователь']])
            ->all();
    }

    public static function getRolesList()
    {
        return \yii\helpers\ArrayHelper::map(Roles::find()->all(), 'id', 'role_name');
    }

    public function getRoleDisplayName()
    {
        $role = $this->role;
        if (!$role) {
            return 'Не назначена';
        }
        $map = ['admin' => 'Администратор', 'user' => 'Пользователь', 'operator' => 'Оператор'];
        return $map[$role->role_code] ?? $role->role_name;
    }

    public function getDisplayName()
    {
        return $this->full_name ?: $this->email ?: $this->username ?: (string) $this->id;
    }

    /**
     * Назначить одну роль пользователю (для формы: одна роль в выпадающем списке).
     * Создаёт или обновляет запись в user_roles.
     */
    public function assignRole(int $roleId): bool
    {
        $existing = UserRoles::find()
            ->where(['user_id' => $this->id, 'role_id' => $roleId, 'is_active' => true])
            ->andWhere(['revoked_at' => null])
            ->one();
        if ($existing) {
            return true;
        }
        UserRoles::updateAll(['revoked_at' => date('Y-m-d H:i:s'), 'is_active' => false], ['user_id' => $this->id]);
        $ur = new UserRoles();
        $ur->user_id = $this->id;
        $ur->role_id = $roleId;
        $ur->assigned_at = date('Y-m-d H:i:s');
        return $ur->save(false);
    }

    /**
     * Получить ID текущей (первой активной) роли для формы.
     */
    public function getRoleIdForForm(): ?int
    {
        $ids = $this->getActiveRoleIds();
        return $ids ? (int) $ids[0] : null;
    }
}
