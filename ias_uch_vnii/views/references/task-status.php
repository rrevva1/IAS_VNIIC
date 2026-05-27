<?php

use app\assets\ReferencesGridAsset;
use yii\helpers\Url;

ReferencesGridAsset::register($this);

$this->title = 'Статусы заявок';

echo $this->render('_grid_layout', [
    'pageTitle' => $this->title,
    'gridId' => 'agGridRefTaskStatus',
    'createLabel' => 'Добавить',
    'createRoute' => ['task-status-create'],
    'gridDataAttrs' => [
        'data-url' => Url::to(['task-status-get-grid-data']),
        'data-update-url' => Url::to(['task-status-update']),
        'data-archive-url' => Url::to(['task-status-archive']),
    ],
]);
