<?php

use app\assets\ReferencesGridAsset;
use yii\helpers\Url;

ReferencesGridAsset::register($this);

$this->title = 'Локации';

echo $this->render('_grid_layout', [
    'pageTitle' => $this->title,
    'gridId' => 'agGridRefLocations',
    'createLabel' => 'Добавить',
    'createRoute' => ['location-create'],
    'gridDataAttrs' => [
        'data-url' => Url::to(['locations-get-grid-data']),
        'data-update-url' => Url::to(['location-update']),
        'data-archive-url' => Url::to(['location-archive']),
    ],
]);
