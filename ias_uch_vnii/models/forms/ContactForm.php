<?php

namespace app\models\forms;

use Yii;
use yii\base\Model;

/**
 * ContactForm модель для формы обратной связи.
 */
class ContactForm extends Model
{
    public $name;
    public $email;
    public $subject;
    public $body;
    public $verifyCode;


    /**
     * @return array правила валидации.
     */
    public function rules()
    {
        return [
            // имя, email, тема и сообщение обязательны
            [['name', 'email', 'subject', 'body'], 'required'],
            // email должен быть валидным email адресом
            ['email', 'email'],
            // verifyCode должен быть введен правильно
            ['verifyCode', 'captcha'],
        ];
    }

    /**
     * @return array пользовательские метки атрибутов
     */
    public function attributeLabels()
    {
        return [
            'verifyCode' => 'Код подтверждения',
        ];
    }

    /**
     * Отправляет email на указанный адрес используя информацию собранную этой моделью.
     * @param string $email целевой email адрес
     * @return bool прошла ли модель валидацию
     */
    public function contact($email)
    {
        if ($this->validate()) {
            Yii::$app->mailer->compose()
                ->setTo($email)
                ->setFrom([Yii::$app->params['senderEmail'] => Yii::$app->params['senderName']])
                ->setReplyTo([$this->email => $this->name])
                ->setSubject($this->subject)
                ->setTextBody($this->body)
                ->send();

            return true;
        }
        return false;
    }
}
