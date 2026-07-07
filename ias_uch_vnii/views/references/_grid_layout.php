<?php
/**
 * Список справочника: каркас как «Учёт ТС» + модальное создание/редактирование.
 *
 * @var yii\web\View $this
 * @var string $pageTitle
 * @var string $activeRoute
 * @var string $gridId
 * @var string $createLabel
 * @var string $createTitle
 * @var string $updateTitle
 * @var string $formPrefix префикс id полей ActiveForm (dic-task-status, location, …)
 * @var array $gridDataAttrs data-* атрибуты контейнера грида
 */

use app\assets\ReferencesGridAsset;
use yii\helpers\Html;

ReferencesGridAsset::register($this);

$this->params['breadcrumbs'] = [];

$gridAttrs = '';
foreach ($gridDataAttrs as $key => $value) {
    $gridAttrs .= ' ' . Html::encode($key) . '="' . Html::encode((string) $value) . '"';
}
?>
<div class="arm-page references-page">
    <header class="arm-page__header">
        <div class="arm-page__heading">
            <h1 class="arm-page__title"><?= Html::encode($pageTitle) ?></h1>
        </div>
    </header>

    <div class="arm-command-bar" role="region" aria-label="Разделы и действия">
        <div class="arm-search">
            <label class="visually-hidden" for="refQuickFilter">Поиск по таблице</label>
            <i class="fas fa-search arm-search__icon" aria-hidden="true"></i>
            <input type="search" id="refQuickFilter" class="form-control arm-search__input js-section-quick-filter"
                   placeholder="Поиск" autocomplete="off">
            <button type="button" class="arm-search__clear js-section-quick-filter-clear" id="refQuickFilterClear"
                    aria-label="Очистить поиск" title="Очистить поиск" hidden>×</button>
        </div>

        <?= $this->render('_hub_tabs', ['activeRoute' => $activeRoute ?? '']) ?>

        <div class="arm-command-bar__tools">
            <?= Html::button('<i class="fas fa-plus" aria-hidden="true"></i><span class="arm-btn-label">' . Html::encode($createLabel) . '</span>', [
                'class' => 'btn btn-primary arm-tool-btn',
                'type' => 'button',
                'data-ref-create-open' => '1',
                'title' => $createLabel,
            ]) ?>
            <?= Html::button('<i class="fas fa-arrows-rotate" aria-hidden="true"></i><span class="arm-btn-label">Обновить</span>', [
                'class' => 'btn btn-outline-secondary arm-tool-btn js-section-grid-refresh',
                'type' => 'button',
                'data-grid-id' => $gridId,
                'title' => 'Перезагрузить данные',
            ]) ?>
        </div>
    </div>

    <div class="arm-grid-card">
        <div id="<?= Html::encode($gridId) ?>" class="ag-theme-quartz arm-grid-loading references-grid-host"
             data-form-prefix="<?= Html::encode($formPrefix) ?>"<?= $gridAttrs ?>>
            <div class="arm-grid-loading__inner">
                <i class="fas fa-circle-notch fa-spin" aria-hidden="true"></i>
                <p>Загрузка таблицы…</p>
            </div>
        </div>
    </div>
</div>

<?= $this->render('_form_modal', [
    'createTitle' => $createTitle ?? 'Добавить',
    'updateTitle' => $updateTitle ?? 'Редактировать',
]) ?>
