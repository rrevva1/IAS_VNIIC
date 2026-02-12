<?php

namespace app\widgets;

use Yii;

/**
 * Виджет Alert отображает сообщение из сессии flash. Все flash сообщения отображаются
 * в последовательности их назначения через setFlash. Вы можете установить сообщение следующим образом:
 *
 * ```php
 * Yii::$app->session->setFlash('error', 'Это сообщение');
 * Yii::$app->session->setFlash('success', 'Это сообщение');
 * Yii::$app->session->setFlash('info', 'Это сообщение');
 * ```
 *
 * Множественные сообщения могут быть установлены следующим образом:
 *
 * ```php
 * Yii::$app->session->setFlash('error', ['Ошибка 1', 'Ошибка 2']);
 * ```
 *
 * @author Kartik Visweswaran <kartikv2@gmail.com>
 * @author Alexander Makarov <sam@rmcreative.ru>
 */
class Alert extends \yii\bootstrap5\Widget
{
    /**
     * @var array конфигурация типов alert для flash сообщений.
     * Этот массив настраивается как $key => $value, где:
     * - key: имя переменной flash сессии
     * - value: тип bootstrap alert (например danger, success, info, warning)
     */
    public $alertTypes = [
        'error'   => 'alert-danger',
        'danger'  => 'alert-danger',
        'success' => 'alert-success',
        'info'    => 'alert-info',
        'warning' => 'alert-warning'
    ];
    /**
     * @var array опции для рендеринга тега кнопки закрытия.
     * Массив будет передан в [[\yii\bootstrap\Alert::closeButton]].
     */
    public $closeButton = [];


    /**
     * Запуск виджета
     */
    public function run()
    {
        $session = Yii::$app->session;
        $appendClass = isset($this->options['class']) ? ' ' . $this->options['class'] : '';

        foreach (array_keys($this->alertTypes) as $type) {
            $flash = $session->getFlash($type);

            foreach ((array) $flash as $i => $message) {
                echo \yii\bootstrap5\Alert::widget([
                    'body' => $message,
                    'closeButton' => $this->closeButton,
                    'options' => array_merge($this->options, [
                        'id' => $this->getId() . '-' . $type . '-' . $i,
                        'class' => $this->alertTypes[$type] . $appendClass,
                    ]),
                ]);
            }

            $session->removeFlash($type);
        }
    }
}
