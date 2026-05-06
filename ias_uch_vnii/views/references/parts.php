<?php
use yii\helpers\Html;
use yii\helpers\Url;
use app\assets\ReferencesGridAsset;

ReferencesGridAsset::register($this);

$this->title = 'Типы частей (комплектующие)';
$this->params['breadcrumbs'][] = ['label' => 'Справочники', 'url' => ['index']];
$this->params['breadcrumbs'][] = $this->title;
?>
<div class="references-parts">
    <h1><?= Html::encode($this->title) ?></h1>
    <p>
        <?= Html::a('Добавить тип части', ['parts-create'], ['class' => 'btn btn-success']) ?>
        <?= Html::a('Обновить', ['parts'], ['class' => 'btn btn-outline-secondary']) ?>
    </p>
    <div
        id="agGridRefParts"
        class="ag-theme-quartz"
        style="width: 100%; height: 60vh; min-height: 300px;"
        data-url="<?= Html::encode(Url::to(['parts-get-grid-data'])) ?>"
        data-update-url="<?= Html::encode(Url::to(['parts-update'])) ?>"
        data-archive-url="<?= Html::encode(Url::to(['parts-archive'])) ?>"
    >
        <div class="text-center text-muted p-4">Загрузка таблицы...</div>
    </div>
</div>
