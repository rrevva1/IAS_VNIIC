<?php

namespace app\controllers;

use Yii;
use yii\web\Controller;

/**
 * HelpDeskController - универсальный контроллер для перенаправления пользователей
 */
class HelpDeskController extends Controller
{
    /**
     * Перенаправляет пользователя на соответствующую страницу в зависимости от роли
     *
     * @return \yii\web\Response
     */
    public function actionIndex()
    {
        if (Yii::$app->user->isGuest) {
            return $this->redirect(['/site/login']);
        }

        $user = Yii::$app->user->identity;
        
        if ($user->isAdmin()) {
            return $this->redirect(['/tasks/index']);
        } elseif ($user->isUser()) {
            return $this->redirect(['/user-tasks/index']);
        } else {
            Yii::$app->session->setFlash('error', 'У вас не определена роль в системе.');
            return $this->redirect(['/site/index']);
        }
    }
}
