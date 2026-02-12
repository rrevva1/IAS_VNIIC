<?php
/**
 * Учет ТС: список оборудования в AG Grid.
 * Колонки — по Основному учёту (см. docs/МАППИНГ_КОЛОНОК_УЧЕТ_ТС.md).
 */

use app\assets\ArmGridAsset;
use yii\helpers\Html;
use yii\helpers\Url;

ArmGridAsset::register($this);

$this->title = 'Учет ТС';
$this->params['breadcrumbs'][] = $this->title;
?>
<div class="arm-index">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h1 class="mb-0"><?= Html::encode($this->title) ?></h1>
        <div class="btn-group">
            <?= Html::a('<i class="glyphicon glyphicon-plus"></i> Добавить технику', ['create'], ['class' => 'btn btn-success']) ?>
            <?= Html::button('<i class="glyphicon glyphicon-refresh"></i> Обновить', [
                'class' => 'btn btn-outline-secondary',
                'onclick' => 'refreshArmGrid()',
            ]) ?>
        </div>
    </div>

    <div id="agGridArmContainer" class="ag-theme-quartz" style="width: 100%; height: 65vh; min-height: 400px;">
        <div class="text-center p-4 text-muted">
            <span class="glyphicon glyphicon-refresh glyphicon-spin"></span>
            <p>Загрузка таблицы...</p>
        </div>
    </div>
</div>
<?php
$this->registerJs(
    "window.agGridArmDataUrl = " . json_encode(Url::to(['arm/get-grid-data'])) . ";",
    \yii\web\View::POS_HEAD
);
