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
     * @var bool Использовать Bootstrap Toast (всплывающие уведомления) вместо inline Alert.
     * Тосты показываются в правом верхнем углу, зелёные для success, красные для error/danger.
     */
    public $useToast = true;

    /**
     * Запуск виджета
     */
    public function run()
    {
        $session = Yii::$app->session;
        $messages = [];

        foreach (array_keys($this->alertTypes) as $type) {
            $flash = $session->getFlash($type);
            foreach ((array) $flash as $message) {
                $messages[] = ['type' => $type, 'body' => $message];
            }
            $session->removeFlash($type);
        }

        if (empty($messages)) {
            return;
        }

        if ($this->useToast) {
            $this->renderToasts($messages);
        } else {
            $appendClass = isset($this->options['class']) ? ' ' . $this->options['class'] : '';
            foreach ($messages as $i => $m) {
                echo \yii\bootstrap5\Alert::widget([
                    'body' => $m['body'],
                    'closeButton' => $this->closeButton,
                    'options' => array_merge($this->options, [
                        'id' => $this->getId() . '-' . $m['type'] . '-' . $i,
                        'class' => ($this->alertTypes[$m['type']] ?? 'alert-info') . $appendClass,
                    ]),
                ]);
            }
        }
    }

    private function renderToasts(array $messages): void
    {
        $toastTypeMap = [
            'error' => 'danger', 'danger' => 'danger', 'success' => 'success',
            'info' => 'info', 'warning' => 'warning',
        ];
        $id = $this->getId();
        echo '<div class="toast-container position-fixed top-0 end-0 p-3" id="' . $id . '-toast-container" style="z-index: 9999;">';
        foreach ($messages as $i => $m) {
            $bsType = $toastTypeMap[$m['type']] ?? 'info';
            $bgClass = $bsType === 'success' ? 'bg-success' : ($bsType === 'danger' ? 'bg-danger' : 'bg-' . $bsType);
            echo '<div class="toast align-items-center text-white ' . $bgClass . ' border-0" role="alert" data-bs-autohide="true" data-bs-delay="5000">';
            echo '<div class="d-flex"><div class="toast-body">' . \yii\helpers\Html::encode($m['body']) . '</div>';
            echo '<button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button></div></div>';
        }
        echo '</div>';
        $json = \yii\helpers\Json::htmlEncode($messages);
        \Yii::$app->view->registerJs(
            "(function(){ var c=document.getElementById('{$id}-toast-container'); if(c&&typeof bootstrap!=='undefined'){ var toasts=c.querySelectorAll('.toast'); toasts.forEach(function(t){ (new bootstrap.Toast(t)).show(); }); } })();",
            \yii\web\View::POS_READY
        );
    }
}
