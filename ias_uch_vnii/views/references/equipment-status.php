<?php
use yii\helpers\Html;
use yii\helpers\Url;
use app\assets\ReferencesGridAsset;

ReferencesGridAsset::register($this);

$this->title = 'Статусы оборудования';
$this->params['breadcrumbs'][] = ['label' => 'Справочники', 'url' => ['index']];
$this->params['breadcrumbs'][] = $this->title;
?>
<div class="references-equipment-status">
    <h1><?= Html::encode($this->title) ?></h1>
    <p>
        <?= Html::a('Добавить статус', ['equipment-status-create'], ['class' => 'btn btn-success']) ?>
        <?= Html::a('Обновить', ['equipment-status'], ['class' => 'btn btn-outline-secondary']) ?>
    </p>
    <div
        id="agGridRefEquipmentStatus"
        class="ag-theme-quartz"
        style="width: 100%; height: 60vh; min-height: 300px;"
        data-url="<?= Html::encode(Url::to(['equipment-status-get-grid-data'])) ?>"
        data-update-url="<?= Html::encode(Url::to(['equipment-status-update'])) ?>"
        data-archive-url="<?= Html::encode(Url::to(['equipment-status-archive'])) ?>"
    >
        <div class="text-center text-muted p-4">Загрузка таблицы...</div>
    </div>
</div>
