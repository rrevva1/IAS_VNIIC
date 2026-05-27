<?php

use app\assets\ReferencesGridAsset;
use yii\helpers\Url;

ReferencesGridAsset::register($this);

$this->title = 'Характеристики';

echo $this->render('_grid_layout', [
    'pageTitle' => $this->title,
    'gridId' => 'agGridRefChars',
    'createLabel' => 'Добавить',
    'createRoute' => ['chars-create'],
    'gridDataAttrs' => [
        'data-url' => Url::to(['chars-get-grid-data']),
        'data-update-url' => Url::to(['chars-update']),
        'data-archive-url' => Url::to(['chars-archive']),
    ],
]);
