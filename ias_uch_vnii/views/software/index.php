<?php
/**
 * Список ПО (AG Grid).
 * @var yii\web\View $this
 */

use yii\helpers\Html;
use yii\helpers\Url;
use app\assets\SoftwareGridAsset;

SoftwareGridAsset::register($this);

$name = Yii::$app->request->get('name', '');
$expiringDays = Yii::$app->request->get('expiring_days', '');
$gridDataUrl = Url::to(array_merge(['software/get-grid-data'], array_filter([
    'name' => $name !== '' ? $name : null,
    'expiring_days' => $expiringDays !== '' ? $expiringDays : null,
])));

$this->title = 'Учёт ПО и лицензий';
$this->params['breadcrumbs'][] = $this->title;
?>
<div class="software-index">
    <h1><?= Html::encode($this->title) ?></h1>
    <p>
        <?= Html::a('Добавить ПО', ['create'], ['class' => 'btn btn-success']) ?>
        <?= Html::button('Обновить', ['class' => 'btn btn-outline-secondary', 'onclick' => 'refreshSoftwareGrid()']) ?>
    </p>
    <div class="border rounded p-3 mb-3">
        <form method="get" action="<?= Html::encode(Url::to(['index'])) ?>" class="row g-2 align-items-end">
            <div class="col-auto">
                <label class="form-label">Наименование</label>
                <input type="text" name="name" class="form-control" value="<?= Html::encode($name) ?>" placeholder="Поиск..." />
            </div>
            <div class="col-auto">
                <label class="form-label">Лицензии истекают в течение (дней)</label>
                <input type="number" name="expiring_days" class="form-control" value="<?= Html::encode($expiringDays) ?>" min="1" placeholder="30" style="width:90px" />
            </div>
            <div class="col-auto">
                <button type="submit" class="btn btn-primary">Фильтр</button>
            </div>
        </form>
    </div>
    <div
        id="agGridSoftwareContainer"
        class="ag-theme-quartz"
        style="width: 100%; height: 60vh; min-height: 300px;"
        data-url="<?= Html::encode($gridDataUrl) ?>"
        data-view-url="<?= Html::encode(Url::to(['view'])) ?>"
        data-update-url="<?= Html::encode(Url::to(['update'])) ?>"
        data-license-create-url="<?= Html::encode(Url::to(['license-create'])) ?>"
    >
        <div class="text-center text-muted p-4">Загрузка таблицы...</div>
    </div>
</div>
