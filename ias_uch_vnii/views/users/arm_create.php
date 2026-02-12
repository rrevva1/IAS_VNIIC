<?php
/**
 * Страница добавления техники (АРМ) для пользователя
 * @var yii\web\View $this
 * @var app\models\entities\Equipment $model
 * @var array $locations
 * @var array $statuses
 * @var int $userId
 */

use yii\helpers\Html;

$this->title = 'Добавление техники пользователю';
$this->params['breadcrumbs'][] = ['label' => 'Пользователи', 'url' => ['index']];
$this->params['breadcrumbs'][] = ['label' => 'Просмотр', 'url' => ['view', 'id' => $userId]];
$this->params['breadcrumbs'][] = $this->title;
?>

<div class="users-arm-create">
    <h1><?= Html::encode($this->title) ?></h1>
    <p class="text-muted">Заполните форму для добавления техники выбранному сотруднику.</p>

    <?= $this->render('_arm_form', [
        'model' => $model,
        'locations' => $locations,
        'statuses' => $statuses,
        'userId' => $userId,
    ]) ?>
</div>





