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
     * @var bool Использовать глобальные toast-уведомления вместо inline Alert.
     * Уведомления показываются снизу справа и не влияют на вёрстку страницы.
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
        $json = \yii\helpers\Json::htmlEncode($messages);
        \Yii::$app->view->registerJs(
            "(function(){"
            . "var items={$json};"
            . "function emit(){"
            . "if(typeof window.IASNotify!=='function'){"
            . "window.IASNotify=function(msg,type){"
            . "var stack=document.getElementById('iasToastStackFallback');"
            . "if(!stack){stack=document.createElement('div');stack.id='iasToastStackFallback';stack.style.cssText='position:fixed;right:16px;bottom:16px;z-index:1600;display:flex;flex-direction:column;gap:8px;max-width:min(420px,calc(100vw - 32px));';document.body.appendChild(stack);}"
            . "var t=document.createElement('div');t.style.cssText='background:#fff;border:1px solid #cbd5e1;border-left:4px solid #2563eb;border-radius:10px;padding:10px 12px;box-shadow:0 8px 24px rgba(15,23,42,.14);font-size:13px;line-height:1.35;color:#1f2937;';"
            . "if(type==='success'){t.style.borderLeftColor='#16a34a';}else if(type==='danger'||type==='error'){t.style.borderLeftColor='#dc2626';}else if(type==='warning'){t.style.borderLeftColor='#d97706';}"
            . "t.textContent=String(msg||'');stack.appendChild(t);setTimeout(function(){if(t&&t.parentNode){t.parentNode.removeChild(t);}},5000);"
            . "};"
            . "}"
            . "items.forEach(function(m){window.IASNotify(m.body,m.type||'info');});"
            . "}"
            . "if(document.readyState==='loading'){document.addEventListener('DOMContentLoaded',emit,{once:true});}else{emit();}"
            . "})();",
            \yii\web\View::POS_END
        );
    }
}
