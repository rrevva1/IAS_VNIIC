<?php

use yii\helpers\Url;

$this->title = 'Статусы оборудования';

echo $this->render('_grid_layout', [
    'pageTitle' => $this->title,
    'activeRoute' => 'equipment-status',
    'gridId' => 'agGridRefEquipmentStatus',
    'createLabel' => 'Добавить',
    'createTitle' => 'Добавить статус оборудования',
    'updateTitle' => 'Редактировать статус оборудования',
    'formPrefix' => 'dic-equipment-status',
    'gridDataAttrs' => [
        'data-url' => Url::to(['equipment-status-get-grid-data']),
        'data-create-modal-url' => Url::to(['equipment-status-create-modal']),
        'data-update-modal-url-template' => Url::to(['equipment-status-update-modal', 'id' => '__ID__']),
        'data-archive-url' => Url::to(['equipment-status-archive']),
        'data-edit-label-field' => 'status_name',
    ],
]);
