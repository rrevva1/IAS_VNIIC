<?php

// В Docker задаются переменные окружения (DB_HOST, DB_NAME, DB_USER, DB_PASSWORD).
// Локально можно не задавать — используются значения по умолчанию.
$host = getenv('DB_HOST') ?: 'localhost';
$port = getenv('DB_PORT') ?: '5432';
$dbname = getenv('DB_NAME') ?: 'ias_vniic';
$username = getenv('DB_USER') ?: 'postgres';
$password = getenv('DB_PASSWORD') ?: '12345';
$yiiEnv = getenv('YII_ENV') ?: 'prod';

return [
    'class' => 'yii\db\Connection',
    'dsn' => "pgsql:host={$host};port={$port};dbname={$dbname}",
    'username' => $username,
    'password' => $password,
    'charset' => 'utf8',
    // Целевая схема в БД — tech_accounting.
    // По умолчанию Yii2 для PostgreSQL считает defaultSchema = public,
    // поэтому явно переназначаем схему, чтобы таблицы без префикса
    // (users, roles, tasks и т.п.) искались в tech_accounting.
    'schemaMap' => [
        'pgsql' => [
            'class' => \yii\db\pgsql\Schema::class,
            'defaultSchema' => 'tech_accounting',
        ],
    ],
    // Дополнительно фиксируем search_path для совместимости с SQL‑скриптами.
    'on afterOpen' => function ($event) {
        $event->sender->createCommand('SET search_path TO tech_accounting')->execute();
    },

    // Schema cache options (for production environment)
    'enableSchemaCache' => $yiiEnv === 'prod',
    'schemaCacheDuration' => 3600,
    'schemaCache' => 'cache',
];


