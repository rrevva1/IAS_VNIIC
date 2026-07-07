<?php

use yii\helpers\Url;

$this->title = 'Типы частей';

echo $this->render('_grid_layout', [
    'pageTitle' => $this->title,
    'activeRoute' => 'parts',
    'gridId' => 'agGridRefParts',
    'createLabel' => 'Добавить',
    'createTitle' => 'Добавить тип части',
    'updateTitle' => 'Редактировать тип части',
    'formPrefix' => 'spr-parts',
    'gridDataAttrs' => [
        'data-url' => Url::to(['parts-get-grid-data']),
        'data-create-modal-url' => Url::to(['parts-create-modal']),
        'data-update-modal-url-template' => Url::to(['parts-update-modal', 'id' => '__ID__']),
        'data-archive-url' => Url::to(['parts-archive']),
        'data-edit-label-field' => 'name',
    ],
]);
