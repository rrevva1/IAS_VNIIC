<?php

namespace app\controllers;

use Yii;
use yii\filters\AccessControl;
use yii\web\Controller;
use yii\web\Response;
use yii\filters\VerbFilter;
use app\models\forms\LoginForm;
use app\models\forms\ContactForm;

/**
 * SiteController обрабатывает основные действия сайта
 * Включает авторизацию, главную страницу, контакты и другие общие страницы
 */
class SiteController extends Controller
{
    /**
     * Определяет поведения контроллера
     */
    public function behaviors()
    {
        return [
            'access' => [
                'class' => AccessControl::class,
                'only' => ['logout'],
                'rules' => [
                    [
                        'actions' => ['logout'],
                        'allow' => true,
                        'roles' => ['@'],
                    ],
                ],
            ],
            'verbs' => [
                'class' => VerbFilter::class,
                'actions' => [
                    'logout' => ['post'],
                ],
            ],
        ];
    }

    /**
     * Определяет действия контроллера
     */
    public function actions()
    {
        return [
            'error' => [
                'class' => 'yii\web\ErrorAction',
            ],
            'captcha' => [
                'class' => 'yii\captcha\CaptchaAction',
                'fixedVerifyCode' => YII_ENV_TEST ? 'testme' : null,
            ],
        ];
    }

    /**
     * Отображает главную страницу.
     *
     * @return string
     */
    public function actionIndex()
    {
        if (Yii::$app->user->isGuest) {
            return $this->redirect(['login']);
        }
        
        $user = Yii::$app->user->identity;
        
        if ($user->isAdministrator()) {
            /** Администратор видит список всех пользователей */
            return $this->redirect(['/users/index']);
        } else {
            /** Обычный пользователь видит только свои данные */
            return $this->redirect(['/users/view', 'id' => $user->id]);
        }
    }

    /**
     * Действие для авторизации.
     *
     * @return Response|string
     */
    public function actionLogin()
    {
        if (!Yii::$app->user->isGuest) {
            return $this->goHome();
        }
    
        $model = new LoginForm();
        
        /** Отладка: логируем данные POST запроса */
        Yii::debug('POST data: ' . print_r(Yii::$app->request->post(), true));
        
        if ($model->load(Yii::$app->request->post())) {
            Yii::debug('Model loaded. Email: ' . $model->email . ', RememberMe: ' . $model->rememberMe);
            Yii::debug('Model attributes: ' . print_r($model->attributes, true));
            
            if ($model->login()) {
                Yii::debug('Login successful');
                return $this->goHome();
            } else {
                Yii::debug('Login failed. Errors: ' . print_r($model->errors, true));
            }
        } else {
            Yii::debug('Model load failed');
        }
    
        $model->password = '';

        return $this->render('login', [
            'model' => $model,
        ]);
    }

    /**
     * Действие для выхода из системы.
     *
     * @return Response
     */
    public function actionLogout()
    {
        Yii::$app->user->logout();

        return $this->goHome();
    }

    /**
     * Отображает страницу контактов.
     *
     * @return Response|string
     */
    public function actionContact()
    {
        $model = new ContactForm();
        if ($model->load(Yii::$app->request->post()) && $model->contact(Yii::$app->params['adminEmail'])) {
            Yii::$app->session->setFlash('contactFormSubmitted');

            return $this->refresh();
        }
        return $this->render('contact', [
            'model' => $model,
        ]);
    }

    /**
     * Отображает страницу "О нас".
     *
     * @return string
     */
    public function actionAbout()
    {
        return $this->render('about');
    }
    
    /**
     * Тестовое действие для демонстрации передачи параметров
     * 
     * @param string $message Сообщение для отображения
     * @return string
     */
    public function actionSay($message = 'Привет')
    {
	return $this->render('say', ['message' => $message]);
    }
    
    /**
     * Тестовая страница Rebbe
     * 
     * @return string
     */
    public function actionRebbe()
    {
	return $this->render('rebbe');
    }

    /**
     * Тестирование авторизации
     * Страница для проверки текущего авторизованного пользователя
     * 
     * @return string|\yii\web\Response
     */
    public function actionTestAuth()
    {
        if (Yii::$app->user->isGuest) {
            return $this->redirect(['login']);
        }
        
        $user = Yii::$app->user->identity;
        return $this->render('test-auth', [
            'user' => $user,
        ]);
    }
}
