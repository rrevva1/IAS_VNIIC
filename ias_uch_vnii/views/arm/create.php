<?php
/**
 * Страница создания техники (АРМ).
 * @var yii\web\View $this
 * @var app\models\entities\Equipment $model
 * @var array $users
 * @var array $locations
 * @var array $statuses
 * @var array $equipmentTypes
 * @var array $chars
 * @var string[] $cpuModels
 */

use yii\helpers\Html;

$this->title = 'Добавление техники';
$this->params['breadcrumbs'][] = $this->title;
?>

<div class="arm-create">
    <h1><?= Html::encode($this->title) ?></h1>

    <?= $this->render('_form', [
        'model' => $model,
        'users' => $users,
        'locations' => $locations,
        'statuses' => $statuses,
        'equipmentTypes' => $equipmentTypes ?? [],
        'chars' => $chars ?? [],
        'cpuModels' => $cpuModels ?? [],
        'ramModels' => $ramModels ?? [],
        'osModels' => $osModels ?? [],
        'diskModels' => $diskModels ?? [],
        'supplierNames' => $supplierNames ?? [],
        'ipAddresses' => $ipAddresses ?? [],
    ]) ?>
</div>





