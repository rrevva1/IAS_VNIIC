<?php
/**
 * Страница создания техники (АРМ).
 * @var yii\web\View $this
 * @var app\models\entities\Equipment $model
 * @var array $users
 * @var array $locations
 * @var array $statuses
 */

use yii\helpers\Html;

$this->title = 'Добавление техники';
$this->params['breadcrumbs'][] = ['label' => 'Учет ТС', 'url' => ['index']];
$this->params['breadcrumbs'][] = $this->title;
?>

<div class="arm-create">
    <h1><?= Html::encode($this->title) ?></h1>
    <p class="text-muted">Заполните форму для добавления техники. Можно сразу закрепить за пользователем.</p>

    <?= $this->render('_form', [
        'model' => $model,
        'users' => $users,
        'locations' => $locations,
        'statuses' => $statuses,
    ]) ?>
</div>





