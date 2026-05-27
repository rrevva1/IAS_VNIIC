<?php

use app\assets\ReferencesGridAsset;
use yii\helpers\Url;

ReferencesGridAsset::register($this);

$this->title = 'Типы частей (комплектующие)';

echo $this->render('_grid_layout', [
    'pageTitle' => $this->title,
    'gridId' => 'agGridRefParts',
    'createLabel' => 'Добавить',
    'createRoute' => ['parts-create'],
    'gridDataAttrs' => [
        'data-url' => Url::to(['parts-get-grid-data']),
        'data-update-url' => Url::to(['parts-update']),
        'data-archive-url' => Url::to(['parts-archive']),
    ],
]);
