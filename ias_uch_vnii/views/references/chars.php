<?php

use yii\helpers\Url;

$this->title = 'Характеристики';

echo $this->render('_grid_layout', [
    'pageTitle' => $this->title,
    'activeRoute' => 'chars',
    'gridId' => 'agGridRefChars',
    'createLabel' => 'Добавить',
    'createTitle' => 'Добавить характеристику',
    'updateTitle' => 'Редактировать характеристику',
    'formPrefix' => 'spr-chars',
    'gridDataAttrs' => [
        'data-url' => Url::to(['chars-get-grid-data']),
        'data-create-modal-url' => Url::to(['chars-create-modal']),
        'data-update-modal-url-template' => Url::to(['chars-update-modal', 'id' => '__ID__']),
        'data-archive-url' => Url::to(['chars-archive']),
        'data-edit-label-field' => 'name',
    ],
]);
