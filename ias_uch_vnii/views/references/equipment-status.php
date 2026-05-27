<?php

use app\assets\ReferencesGridAsset;
use yii\helpers\Url;

ReferencesGridAsset::register($this);

$this->title = 'Статусы оборудования';

echo $this->render('_grid_layout', [
    'pageTitle' => $this->title,
    'gridId' => 'agGridRefEquipmentStatus',
    'createLabel' => 'Добавить',
    'createRoute' => ['equipment-status-create'],
    'gridDataAttrs' => [
        'data-url' => Url::to(['equipment-status-get-grid-data']),
        'data-update-url' => Url::to(['equipment-status-update']),
        'data-archive-url' => Url::to(['equipment-status-archive']),
    ],
]);
