<?php

$params = require __DIR__ . '/params.php';
$db = require __DIR__ . '/db.php';

$config = [
    'id' => 'basic',
    'basePath' => dirname(__DIR__),
    'bootstrap' => ['log'],
    'aliases' => [
        '@bower' => '@vendor/bower-asset',
        '@npm'   => '@vendor/npm-asset',
    ],
    'components' => [
        'request' => [
            // !!! вставьте секретный ключ ниже (если он пустой) - это требуется для валидации cookie
            'cookieValidationKey' => '3657f4cb43c013948a1c51cb152714f88b2ead4726a47e4dfe7cf758e20723cd',
            // Явно задаём URL скрипта и базу — устраняет ошибку "Unable to determine the entry script URL"
            // когда DocumentRoot в Apache указывает не на папку web/ (должен быть путь к .../ias_uch_vnii/web)
            'baseUrl' => '',
            'scriptUrl' => '/index.php',
        ],
        'cache' => [
            'class' => 'yii\caching\FileCache',
        ],
        'user' => [
            'identityClass' => 'app\models\entities\Users',
            'enableAutoLogin' => true,
            'loginUrl' => ['site/login'],
        ],
        'errorHandler' => [
            'errorAction' => 'site/error',
        ],
        'mailer' => [
            'class' => \yii\symfonymailer\Mailer::class,
            'viewPath' => '@app/mail',
            // отправлять все письма в файл по умолчанию.
            'useFileTransport' => true,
        ],
        'log' => [
            'traceLevel' => YII_DEBUG ? 3 : 0,
            'targets' => [
                [
                    'class' => 'yii\log\FileTarget',
                    'levels' => ['error', 'warning'],
                ],
            ],
        ],
        'db' => $db,
        'urlManager' => [
            'enablePrettyUrl' => true,
            'showScriptName' => false,
            'rules' => [
                'api/<controller:[a-z-]+>/<id:\d+>/<action:[a-z-]+>' => 'api/<controller>/<action>',
                'api/<controller:[a-z-]+>/<id:\d+>' => 'api/<controller>/view',
                'api/<controller:[a-z-]+>/<action:[a-z-]+>' => 'api/<controller>/<action>',
                'api/<controller:[a-z-]+>' => 'api/<controller>/index',
                'spa/<path:.*>' => 'site/spa',
                'spa' => 'site/spa',
            ],
        ],
    ],
    'modules' => [
   'gridview' =>  [
        'class' => '\kartik\grid\Module',
        // другие настройки модуля grid
    ],
   'gridviewKrajee' =>  [
        'class' => '\kartik\grid\Module',
        // другие настройки модуля grid
    ]
   ],
 
    'params' => $params,
];

if (YII_ENV_DEV) {
    // настройки конфигурации для 'dev' окружения
    // Модуль debug отключён: в PHP 8.1+ yii2-debug падает с strncmp(null, …) при пустом REMOTE_ADDR.
    // Включите снова после обновления пакета yiisoft/yii2-debug или при доступе только из браузера.
    // $config['bootstrap'][] = 'debug';
    // $config['modules']['debug'] = [
    //     'class' => 'yii\debug\Module',
    //     'allowedIPs' => ['127.0.0.1', '::1', '192.168.*.*', '10.*.*.*'],
    // ];

    $config['bootstrap'][] = 'gii';
    $config['modules']['gii'] = [
        'class' => 'yii\gii\Module',
        // раскомментируйте следующую строку чтобы добавить свой IP, если вы не подключаетесь с localhost.
        //'allowedIPs' => ['127.0.0.1', '::1'],
    ];
}

return $config;
