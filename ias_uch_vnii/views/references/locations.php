<?php

use yii\helpers\Url;

$this->title = 'Локации';

echo $this->render('_grid_layout', [
    'pageTitle' => $this->title,
    'activeRoute' => 'locations',
    'gridId' => 'agGridRefLocations',
    'createLabel' => 'Добавить',
    'createTitle' => 'Добавить локацию',
    'updateTitle' => 'Редактировать локацию',
    'formPrefix' => 'location',
    'gridDataAttrs' => [
        'data-url' => Url::to(['locations-get-grid-data']),
        'data-create-modal-url' => Url::to(['location-create-modal']),
        'data-update-modal-url-template' => Url::to(['location-update-modal', 'id' => '__ID__']),
        'data-archive-url' => Url::to(['location-archive']),
        'data-edit-label-field' => 'name',
    ],
]);
