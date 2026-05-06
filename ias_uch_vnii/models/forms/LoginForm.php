<?php

namespace app\models\forms;

use app\models\entities\Users;
use Yii;
use yii\base\Model;

/**
 * Форма входа (логин по email или username, пароль — password_hash).
 */
class LoginForm extends Model
{
    /** Логин: email или username */
    public $email;

    public $password;
    public $rememberMe = true;

    private $_user = false;

    public function rules()
    {
        return [
            [['email', 'password'], 'required'],
            ['email', 'trim'],
            ['rememberMe', 'boolean'],
            ['password', 'validatePassword'],
        ];
    }

    public function validatePassword($attribute, $params)
    {
        if ($this->hasErrors()) {
            return;
        }
        $user = $this->getUser();
        if (!$user) {
            $this->addError($attribute, 'Пользователь с таким email или логином не найден.');
            return;
        }
        if (!$user->validatePassword($this->password)) {
            $this->addError($attribute, 'Неверный пароль.');
        }
    }

    public function login()
    {
        if ($this->validate()) {
            return Yii::$app->user->login($this->getUser(), $this->rememberMe ? 3600 * 24 * 30 : 0);
        }
        return false;
    }

    public function getUser()
    {
        if ($this->_user === false) {
            $this->_user = Users::findByUsername($this->email);
        }
        return $this->_user;
    }
}
