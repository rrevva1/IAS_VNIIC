<?php

use app\assets\TasksAsset;
use yii\helpers\Html;

TasksAsset::register($this);

/* @var $this yii\web\View */
/* @var $model app\models\Tasks */

$this->title = 'Создать заявку';
$this->params['breadcrumbs'][] = ['label' => 'Заявки', 'url' => ['index']];
$this->params['breadcrumbs'][] = $this->title;

?>
<div class="tasks-page tasks-page--form tasks-create">

    <header class="tasks-page__header">
        <div class="tasks-page__heading">
            <h1 class="tasks-page__title"><?= Html::encode($this->title) ?></h1>
            <p class="tasks-page__subtitle">Опишите проблему или запрос — заявка будет передана в службу поддержки</p>
        </div>
    </header>

    <div class="tasks-page__actions">
        <?= Html::a('<i class="fas fa-arrow-left" aria-hidden="true"></i> К списку', ['index'], [
            'class' => 'btn btn-outline-secondary tasks-tool-btn',
        ]) ?>
    </div>

    <div class="tasks-form-card">
        <?= $this->render('_form', [
            'model' => $model,
            'equipmentList' => $equipmentList ?? [],
        ]) ?>
    </div>

</div>
