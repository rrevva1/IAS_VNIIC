<?php

namespace app\models\forms;

use app\models\entities\Users;
use Yii;
use yii\base\Model;

/**
 * LoginForm модель для формы входа.
 *
 * @property-read Users|null $user
 *
 */
class LoginForm extends Model
{
    /** @var string Email пользователя */
    public $email;
    
    /** @var string Пароль */
    public $password;
    
    /** @var bool Запомнить меня */
    public $rememberMe = true;

    /** @var Users|false Кэш для пользователя */
    private $_user = false;


    /**
     * Правила валидации формы входа
     * 
     * @return array Правила валидации
     */
    public function rules()
    {
        return [
            /** email и password обязательны */
            [['email', 'password'], 'required'],
            /** email должен быть валидным email адресом */
            ['email', 'email'],
            /** rememberMe должно быть булевым значением */
            ['rememberMe', 'boolean'],
            /** пароль валидируется методом validatePassword() */
            ['password', 'validatePassword'],
        ];
    }

    /**
     * Валидация пароля
     * Проверяет существование пользователя и правильность пароля
     *
     * @param string $attribute Проверяемый атрибут
     * @param array $params Дополнительные параметры из правила
     */
    public function validatePassword($attribute, $params)
    {
    if (!$this->hasErrors()) {
        $user = $this->getUser();
        $password = md5($this->password);
        if (!$user) {
            $this->addError($attribute, 'Пользователь с таким email не найден.');
        } elseif ($password != $user->password) {
            $this->addError($attribute, 'Неверный пароль.');
        }
    }
    }

    /**
     * Выполняет вход пользователя
     * Проверяет валидацию и авторизует пользователя в системе
     * 
     * @return bool Успешно ли выполнен вход
     */
    public function login()
    {
        if ($this->validate()) {
            /** Отладочная информация для логирования процесса входа */
            $user = $this->getUser();
            Yii::debug('User found: ' . ($user ? 'YES, ID: ' . $user->id : 'NO'));
            Yii::debug('Input password: ' . $this->password);
            Yii::debug('Stored hash: ' . md5($user->password));
            Yii::debug('MD5 of input: ' . md5($this->password));
            Yii::debug('Password match: ' . ($user->validatePassword($this->password) ? 'YES' : 'NO'));
            
            return Yii::$app->user->login($user, $this->rememberMe ? 3600*24*30 : 0);
        } else {
            Yii::debug('Form validation errors: ' . print_r($this->errors, true));
        }
        return false;
    }
    /**
     * Находит пользователя по email
     * Использует кэширование для избежания повторных запросов к БД
     *
     * @return Users|null Найденный пользователь или null
     */
    public function getUser()
    {   
        if ($this->_user === false) {
            $this->_user = Users::findByEmail($this->email);
        }
        
        return $this->_user;
    }
    
}
