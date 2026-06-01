<?php

use app\assets\TasksAsset;
use yii\helpers\Html;

TasksAsset::register($this);

/* @var $this yii\web\View */
/* @var $model app\models\Tasks */

$this->title = 'Редактировать заявку #' . $model->id;
$this->params['breadcrumbs'][] = ['label' => 'Заявки', 'url' => ['index']];
$this->params['breadcrumbs'][] = ['label' => 'Заявка #' . $model->id, 'url' => ['view', 'id' => $model->id]];
$this->params['breadcrumbs'][] = 'Редактировать';

?>
<div class="tasks-page tasks-page--form tasks-update">

    <header class="tasks-page__header">
        <div class="tasks-page__heading">
            <h1 class="tasks-page__title"><?= Html::encode($this->title) ?></h1>
        </div>
    </header>

    <div class="tasks-page__actions">
        <?= Html::a('<i class="fas fa-eye" aria-hidden="true"></i> Просмотр', ['view', 'id' => $model->id], [
            'class' => 'btn btn-outline-primary tasks-tool-btn',
        ]) ?>
        <?= Html::a('<i class="fas fa-list" aria-hidden="true"></i> К списку', ['index'], [
            'class' => 'btn btn-outline-secondary tasks-tool-btn',
        ]) ?>
    </div>

    <div class="tasks-form-card">
        <?= $this->render('_form', [
            'model' => $model,
            'equipmentList' => $equipmentList ?? [],
            'isUpdate' => true,
            'canEditExecutorComment' => $canEditExecutorComment ?? false,
        ]) ?>
    </div>

</div>
