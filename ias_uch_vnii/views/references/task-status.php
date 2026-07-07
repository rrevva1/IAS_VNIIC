<?php

use yii\helpers\Url;

$this->title = 'Статусы заявок';

echo $this->render('_grid_layout', [
    'pageTitle' => $this->title,
    'activeRoute' => 'task-status',
    'gridId' => 'agGridRefTaskStatus',
    'createLabel' => 'Добавить',
    'createTitle' => 'Добавить статус заявки',
    'updateTitle' => 'Редактировать статус заявки',
    'formPrefix' => 'dic-task-status',
    'gridDataAttrs' => [
        'data-url' => Url::to(['task-status-get-grid-data']),
        'data-create-modal-url' => Url::to(['task-status-create-modal']),
        'data-update-modal-url-template' => Url::to(['task-status-update-modal', 'id' => '__ID__']),
        'data-archive-url' => Url::to(['task-status-archive']),
        'data-edit-label-field' => 'status_name',
    ],
]);
