<?php

namespace app\models\entities;

use app\models\dictionaries\Roles;
use Yii;
use yii\web\IdentityInterface;

/**
 * Модель для таблицы "users".
 *
 * @property int $id_user
 * @property string $full_name
 * @property string $email
 * @property int $id_role
 * @property string|null $password
 * @property string|null $auth_key
 * @property string|null $access_token
 * @property string|null $password_reset_token
 *
 * @property Roles $role
 */
class Users extends \yii\db\ActiveRecord implements IdentityInterface
{
    /** @var string Виртуальное поле для ввода пароля в открытом виде */
    public $password_plain;

    /**
     * Возвращает имя таблицы
     */
    public static function tableName()
    {
        return 'users';
    }

    /**
     * Правила валидации
     */
    public function rules()
    {
        return [
            /** Базовые поля */
            [['password'], 'default', 'value' => null],
            [['id_role'], 'default', 'value' => null],
            [['id_role' , 'id_user'], 'integer'],

            /** Строковые поля с ограничением длины */
            [['email', 'password', 'position', 'department',], 'string', 'max' => 100],
            [['full_name'], 'string', 'max' => 200],
            ['phone', 'string', 'max' => 50],
            
            /** Обязательные поля */
            [['full_name', 'email', 'id_user'], 'required'],
            [['email'], 'unique'],
            [['id_role'], 'exist', 'skipOnError' => true,
                'targetClass' => Roles::class, 'targetAttribute' => ['id_role' => 'id_role']],

            /** Правила для пароля - вводим через виртуальное поле */
            [['password_plain'], 'required', 'on' => 'create', 'message' => 'Введите пароль'],
            [['password_plain'], 'string', 'min' => 6, 'max' => 255],

            /** Фильтрация данных - удаление пробелов */
            [['full_name', 'email', 'password_plain'], 'filter', 'filter' => 'trim'],
        ];
    }

    /**
     * Метки атрибутов
     */
    public function attributeLabels()
    {
        return [
            'id' => 'ID',
            'full_name' => 'ФИО',
            'email' => 'Email',
            'id_role' => 'Роль',
            'password' => 'Пароль(хэш)',
            'password_plain' => 'Пароль',
            'position' => 'Должность',
            'department' => 'Отдел',
            'phone' => 'Телефон',
        ];
    }

    // ========== СВЯЗИ ==========

    /**
     * Получить связь с моделью роли пользователя
     * 
     * @return \yii\db\ActiveQuery
     */
    public function getRole()
    {
        return $this->hasOne(Roles::class, ['id_role' => 'id_role']);
    }
    /**
     * Проверяет, является ли пользователь администратором (по ID роли)
     *
     * @return bool
     */
    public function isAdmin()
    {
        return $this->id_role == 5; /** ID роли администратора в БД */
    }

    /**
     * Проверяет, является ли пользователь обычным пользователем (по ID роли)
     *
     * @return bool
     */
    public function isUser()
    {
        return $this->id_role == 4; /** ID роли пользователя в БД */
    }

    // ========== ОБЯЗАТЕЛЬНЫЕ МЕТОДЫ IdentityInterface ==========

    /**
     * Найти пользователя по ID
     */
    public static function findIdentity($id)
    {
        return static::findOne(['id_user' => $id]);
    }

    /**
     * Найти пользователя по токену доступа
     */
    public static function findIdentityByAccessToken($token, $type = null)
    {
        return static::findOne(['access_token' => $token]);
    }

    /**
     * Получить ID пользователя
     */
    public function getId()
    {
        return $this->getPrimaryKey();
    }

    /**
     * Получить ключ аутентификации
     */
    public function getAuthKey()
    {
        return $this->auth_key;
    }

    /**
     * Проверить ключ аутентификации
     */
    public function validateAuthKey($authKey)
    {
        return $this->getAuthKey() === $authKey;
    }

    // ========== ДОПОЛНИТЕЛЬНЫЕ МЕТОДЫ АВТОРИЗАЦИИ ==========

    /**
     * Найти пользователя по имени пользователя (для совместимости с IdentityInterface)
     * В нашем случае username = email
     */
    public static function findByUsername($username)
    {
        return static::findOne(['email' => $username]);
    }

    /**
     * Найти пользователя по email
     */
    public static function findByEmail($email)
    {
        return static::findOne(['email' => $email]);
    }

    /**
     * Проверить пароль пользователя
     * Поддерживает старый формат MD5 и новый формат Yii2 Security
     * 
     * @param string $password Пароль для проверки
     * @return bool
     */
    public function validatePassword($password)
    {
        /** Если пароль пустой или null, возвращаем false */
        if (empty($this->password) || empty($password)) {
            return false;
        }
        
        /** Проверяем старый формат md5 для совместимости (32 символа, только hex) */
        if (strlen($this->password) === 32 && ctype_xdigit($this->password)) {
            if (md5($password) === $this->password) {
                /** Если пароль совпадает в старом формате, обновляем хеш на новый */
                $this->setPassword($password);
                $this->save(false);
                return true;
            }
            return false;
        }
        
        /** Проверяем новый формат хеша (Yii2 security) */
        try {
            if (Yii::$app->security->validatePassword($password, $this->password)) {
                return true;
            }
        } catch (\Exception $e) {
            /** Если хеш поврежден, считаем пароль неверным */
            Yii::error('Неверный хэш пароля для пользователя ID: ' . $this->id . ', Ошибка: ' . $e->getMessage());
            return false;
        }
        
        return false;
    }

    /**
     * Генерирует хэш пароля и устанавливает его в модель
     * Использует MD5 для совместимости со старой системой
     * 
     * @param string $password Пароль в открытом виде
     */
    public function setPassword($password)
    {
        $this->password = md5($password);
    }

    /**
     * Генерирует ключ аутентификации "запомнить меня"
     */
    public function generateAuthKey()
    {
        $this->auth_key = Yii::$app->security->generateRandomString();
    }

    // ========== СЦЕНАРИИ И СОБЫТИЯ ==========

    /**
     * Сценарии валидации
     */
    public function scenarios()
    {
        $scenarios = parent::scenarios();
        $scenarios['create'] = ['full_name', 'email', 'id_role', 'password_plain'];
        $scenarios['update'] = ['full_name', 'email', 'id_role', 'password_plain'];
        return $scenarios;
    }

    /**
     * Событие перед сохранением модели
     * Генерирует auth_key и хэширует пароль при необходимости
     * 
     * @param bool $insert Флаг создания новой записи
     * @return bool
     */
    public function beforeSave($insert)
    {
        if (!parent::beforeSave($insert)) {
            return false;
        }
        
        /** Генерируем auth_key при создании нового пользователя */
        if ($insert && empty($this->auth_key)) {
            $this->generateAuthKey();
        }
        
        /** Хэшируем пароль если он был изменен */
        if (!empty($this->password_plain)) {
            $this->setPassword($this->password_plain);
            $this->password_plain = null;
        }
        
        return true;
    }

    /**
     * Событие после валидации
     */
    public function afterValidate()
    {
        parent::afterValidate();
        
        if (!empty($this->password_plain) && !$this->hasErrors()) {
            $this->setPassword($this->password_plain);
        }
    }

    // ========== ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ==========

    /**
     * Виртуальное свойство username для совместимости
     */
    public function getUsername()
    {
        return $this->email;
    }

    /**
     * Удобный аксессор: имя роли
     */
    public function getRoleName(): ?string
    {
        return $this->role ? $this->role->role_name : null;
    }

    /**
     * Получить всех пользователей с загруженными ролями
     * 
     * @return Users[]
     */
    public static function getUsersWithRoles()
    {
        return self::find()
            ->joinWith(['role'])
            ->all();
    }

    /**
     * Получить пользователей с русскими названиями ролей
     * Фильтрует только пользователей с ролями "администратор" и "пользователь"
     * 
     * @return Users[]
     */
    public static function getUsersWithRussianRoles()
    {
        return self::find()
            ->joinWith(['role'])
            ->where(['IN', 'roles.role_name', ['администратор', 'пользователь']])
            ->all();
    }

    /**
     * Получить список ролей для выпадающего списка
     * Возвращает массив [id => название роли]
     * 
     * @return array
     */
    public static function getRolesList()
    {
        return \yii\helpers\ArrayHelper::map(
            Roles::find()->all(), 
            'id', 
            'role_name'
        );
    }

    /**
     * Проверить, является ли пользователь администратором (по названию роли)
     * Проверяет название роли на русском языке
     * 
     * @return bool
     */
    public function isAdministrator()
    {
        return $this->role && $this->role->role_name === 'администратор';
    }

    /**
     * Проверить, является ли пользователь обычным пользователем (по названию роли)
     * Проверяет название роли на русском языке
     * 
     * @return bool
     */
    public function isRegularUser()
    {
        return $this->role && $this->role->role_name === 'пользователь';
    }

    /**
     * Получить отображаемое имя роли на русском языке
     * Преобразует английские названия ролей в русские
     * 
     * @return string
     */
    public function getRoleDisplayName()
    {
        if (!$this->role) {
            return 'Не назначена';
        }

        $roleMap = [
            'admin' => 'администратор',
            'user' => 'пользователь',
            'администратор' => 'администратор',
            'пользователь' => 'пользователь'
        ];

        return $roleMap[$this->role->role_name] ?? $this->role->role_name;
    }

    /**
     * Получить имя пользователя для отображения
     * Возвращает ФИО, если заполнено, иначе email
     * 
     * @return string
     */
    public function getDisplayName()
    {
        return $this->full_name ?: $this->email;
    }
}