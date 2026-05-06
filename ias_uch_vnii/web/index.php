<?php

// По умолчанию работаем в режиме разработки; параметры можно переопределить через env.
$yiiEnv = getenv('YII_ENV') ?: 'dev';
$yiiDebugRaw = getenv('YII_DEBUG');
$yiiDebug = $yiiDebugRaw !== false
    ? in_array(strtolower((string) $yiiDebugRaw), ['1', 'true', 'yes', 'on'], true)
    : ($yiiEnv !== 'prod');

error_reporting($yiiDebug ? E_ALL : (E_ALL & ~E_NOTICE & ~E_DEPRECATED & ~E_STRICT));
ini_set('display_errors', $yiiDebug ? '1' : '0');

defined('YII_DEBUG') or define('YII_DEBUG', $yiiDebug);
defined('YII_ENV') or define('YII_ENV', $yiiEnv);

require __DIR__ . '/../vendor/autoload.php';
require __DIR__ . '/../vendor/yiisoft/yii2/Yii.php';

$config = require __DIR__ . '/../config/web.php';

(new yii\web\Application($config))->run();
