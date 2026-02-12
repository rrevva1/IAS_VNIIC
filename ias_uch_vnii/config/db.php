<?php

return [
    'class' => 'yii\db\Connection',
    'dsn' => 'pgsql:host=localhost;dbname=IAS_VNIIC',
    'username' => 'postgres',
    'password' => '12345',
    'charset' => 'utf8',

    // Целевая БД: IAS_VNIIC, схема tech_accounting (см. scripts/create_ias_uch_db_test.sql, setup_ias_vniic_db.cmd)
    'on afterOpen' => function ($event) {
        $event->sender->createCommand('SET search_path TO tech_accounting')->execute();
    },

    // Schema cache options (for production environment)
    //'enableSchemaCache' => true,
    //'schemaCacheDuration' => 60,
    //'schemaCache' => 'cache',
];


