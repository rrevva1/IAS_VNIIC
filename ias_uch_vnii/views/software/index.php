<?php
/**
 * Список ПО (AG Grid).
 * @var yii\web\View $this
 */

use app\assets\SoftwareGridAsset;
use yii\helpers\Html;
use yii\helpers\Url;

SoftwareGridAsset::register($this);

$name = (string) Yii::$app->request->get('name', '');
$expiringDays = (string) Yii::$app->request->get('expiring_days', '');
$gridDataUrl = Url::to(array_merge(['software/get-grid-data'], array_filter([
    'name' => $name !== '' ? $name : null,
    'expiring_days' => $expiringDays !== '' ? $expiringDays : null,
])));

$this->title = 'ПО и лицензии';
$this->params['breadcrumbs'] = [];
?>
<div class="arm-page section-grid-page software-page">
    <header class="arm-page__header">
        <div class="arm-page__heading">
            <h1 class="arm-page__title"><?= Html::encode($this->title) ?></h1>
        </div>
    </header>

    <div class="arm-command-bar section-command-bar section-command-bar--stacked" role="region" aria-label="Поиск и фильтры">
        <div class="section-command-bar__top">
            <div class="arm-search">
                <label class="visually-hidden" for="softwareQuickFilter">Поиск по таблице</label>
                <i class="fas fa-search arm-search__icon" aria-hidden="true"></i>
                <input type="search" id="softwareQuickFilter" class="form-control arm-search__input js-section-quick-filter"
                       placeholder="Поиск" autocomplete="off">
                <button type="button" class="arm-search__clear js-section-quick-filter-clear"
                        aria-label="Очистить поиск" title="Очистить поиск" hidden>×</button>
            </div>

            <div class="arm-command-bar__tools">
                <?= Html::a('<i class="fas fa-plus" aria-hidden="true"></i><span class="arm-btn-label">Добавить</span>', ['create'], [
                    'class' => 'btn btn-primary arm-tool-btn',
                    'title' => 'Добавить ПО',
                ]) ?>
                <?= Html::button('<i class="fas fa-arrows-rotate" aria-hidden="true"></i><span class="arm-btn-label">Обновить</span>', [
                    'class' => 'btn btn-outline-secondary arm-tool-btn js-section-grid-refresh',
                    'type' => 'button',
                    'data-grid-id' => 'agGridSoftwareContainer',
                    'title' => 'Перезагрузить данные',
                ]) ?>
            </div>
        </div>

        <form id="software-filter-form" class="section-filters" method="get" action="<?= Html::encode(Url::to(['index'])) ?>">
            <div>
                <label class="section-filters__label" for="software-filter-name">Наименование</label>
                <input type="text" name="name" id="software-filter-name" class="form-control form-control-sm"
                       value="<?= Html::encode($name) ?>" placeholder="Поиск…">
            </div>
            <div>
                <label class="section-filters__label" for="software-filter-expiring">Лицензии истекают (дней)</label>
                <input type="number" name="expiring_days" id="software-filter-expiring" class="form-control form-control-sm"
                       value="<?= Html::encode($expiringDays) ?>" min="1" placeholder="30">
            </div>
            <div class="d-flex align-items-end gap-2">
                <?= Html::button('<i class="fas fa-filter" aria-hidden="true"></i> Применить', [
                    'class' => 'btn btn-primary btn-sm',
                    'type' => 'button',
                    'id' => 'softwareApplyFilters',
                ]) ?>
                <?= Html::a('Сбросить', ['index'], ['class' => 'btn btn-outline-secondary btn-sm']) ?>
            </div>
        </form>
    </div>

    <div class="arm-grid-card">
        <div
            id="agGridSoftwareContainer"
            class="ag-theme-quartz arm-grid-loading"
            data-base-url="<?= Html::encode(Url::to(['software/get-grid-data'])) ?>"
            data-url="<?= Html::encode($gridDataUrl) ?>"
            data-view-url="<?= Html::encode(Url::to(['view'])) ?>"
            data-update-url="<?= Html::encode(Url::to(['update'])) ?>"
            data-license-create-url="<?= Html::encode(Url::to(['license-create'])) ?>"
        >
            <div class="arm-grid-loading__inner">
                <i class="fas fa-circle-notch fa-spin" aria-hidden="true"></i>
                <p>Загрузка таблицы…</p>
            </div>
        </div>
    </div>
</div>
