<?php
use yii\helpers\Html;
use yii\helpers\Url;
use app\assets\ReferencesGridAsset;

ReferencesGridAsset::register($this);

$this->title = 'Локации';
$this->params['breadcrumbs'][] = ['label' => 'Справочники', 'url' => ['index']];
$this->params['breadcrumbs'][] = $this->title;
?>
<div class="references-locations">
    <h1><?= Html::encode($this->title) ?></h1>
    <p>
        <?= Html::a('Добавить локацию', ['location-create'], ['class' => 'btn btn-success']) ?>
        <?= Html::a('Обновить', ['locations'], ['class' => 'btn btn-outline-secondary']) ?>
    </p>
    <div
        id="agGridRefLocations"
        class="ag-theme-quartz"
        style="width: 100%; height: 60vh; min-height: 300px;"
        data-url="<?= Html::encode(Url::to(['locations-get-grid-data'])) ?>"
        data-update-url="<?= Html::encode(Url::to(['location-update'])) ?>"
        data-archive-url="<?= Html::encode(Url::to(['location-archive'])) ?>"
    >
        <div class="text-center text-muted p-4">Загрузка таблицы...</div>
    </div>
</div>
