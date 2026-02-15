<?php

$params = require __DIR__ . '/params.php';
$db = require __DIR__ . '/db.php';

$config = [
    'id' => 'basic',
    'name' => 'ИАС УТС ФГУП "ВНИИ "Центр"',
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
        ],
        // Разные имена cookie сессии по порту: на 8080 и 8081 — отдельные сессии (две учётки в браузере).
        'session' => [
            'name' => 'PHPSESSID_' . (isset($_SERVER['SERVER_PORT']) ? $_SERVER['SERVER_PORT'] : '80'),
        ],
        'cache' => [
            'class' => 'yii\caching\FileCache',
        ],
        'user' => [
            'identityClass' => 'app\models\entities\Users',
            'enableAutoLogin' => true,
            'loginUrl' => ['site/login'],
            // Разные cookie автологина по порту — выход на одном порту не сбрасывает вход на другом
            'identityCookie' => [
                'name' => '_identity_' . (isset($_SERVER['SERVER_PORT']) ? $_SERVER['SERVER_PORT'] : '80'),
                'httpOnly' => true,
            ],
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
        /*
        'urlManager' => [
            'enablePrettyUrl' => true,
            'showScriptName' => false,
            'rules' => [
            ],
        ],
        */
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
    // настройки конфигурации для 'dev' окружения (модули подключаются только если установлены)
    if (class_exists('yii\debug\Module')) {
        $config['bootstrap'][] = 'debug';
        $config['modules']['debug'] = [
            'class' => 'yii\debug\Module',
            'allowedIPs' => ['127.0.0.1', '::1', '192.168.*.*', '10.*.*.*'],
        ];
    }
    if (class_exists('yii\gii\Module')) {
        $config['bootstrap'][] = 'gii';
        $config['modules']['gii'] = [
            'class' => 'yii\gii\Module',
        ];
    }
}

return $config;
