<?php
/**
 * Редактирование карточки актива.
 * @var yii\web\View $this
 * @var app\models\entities\Equipment $model
 * @var array $users
 * @var array $locations
 * @var array $statuses
 */

use yii\helpers\Html;

$this->title = 'Редактирование: ' . Html::encode($model->name ?: $model->inventory_number);
$this->params['breadcrumbs'][] = ['label' => 'Учет ТС', 'url' => ['index']];
$this->params['breadcrumbs'][] = ['label' => $model->inventory_number, 'url' => ['view', 'id' => $model->id]];
$this->params['breadcrumbs'][] = 'Редактирование';
?>

<div class="arm-update">
    <h1><?= Html::encode($this->title) ?></h1>
    <?= $this->render('_form', [
        'model' => $model,
        'users' => $users,
        'locations' => $locations,
        'statuses' => $statuses,
    ]) ?>
</div>
