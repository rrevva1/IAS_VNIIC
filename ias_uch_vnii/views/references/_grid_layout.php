<?php
/**
 * Каркас страницы справочника с AG Grid.
 *
 * @var yii\web\View $this
 * @var string $pageTitle
 * @var string $gridId
 * @var string $createLabel
 * @var array|string $createRoute
 * @var array $gridDataAttrs data-* атрибуты контейнера грида
 */

use yii\helpers\Html;

$this->params['breadcrumbs'] = [];

$gridAttrs = '';
foreach ($gridDataAttrs as $key => $value) {
    $gridAttrs .= ' ' . Html::encode($key) . '="' . Html::encode((string) $value) . '"';
}
?>
<div class="arm-page section-grid-page references-grid-page">
    <header class="arm-page__header">
        <div class="arm-page__heading">
            <h1 class="arm-page__title"><?= Html::encode($pageTitle) ?></h1>
        </div>
        <div class="arm-toolbar arm-toolbar--header">
            <?= Html::a('<i class="fas fa-book" aria-hidden="true"></i> Справочники', ['index'], [
                'class' => 'btn btn-outline-secondary btn-sm',
                'title' => 'К списку справочников',
            ]) ?>
        </div>
    </header>

    <div class="arm-command-bar section-command-bar section-command-bar--stacked" role="region" aria-label="Поиск и действия">
        <div class="section-command-bar__top">
            <div class="arm-search">
                <label class="visually-hidden" for="refQuickFilter">Поиск по таблице</label>
                <i class="fas fa-search arm-search__icon" aria-hidden="true"></i>
                <input type="search" id="refQuickFilter" class="form-control arm-search__input js-section-quick-filter"
                       placeholder="Поиск" autocomplete="off">
                <button type="button" class="arm-search__clear js-section-quick-filter-clear"
                        aria-label="Очистить поиск" title="Очистить поиск" hidden>×</button>
            </div>

            <div class="arm-command-bar__tools">
                <?= Html::a('<i class="fas fa-plus" aria-hidden="true"></i><span class="arm-btn-label">' . Html::encode($createLabel) . '</span>', $createRoute, [
                    'class' => 'btn btn-primary arm-tool-btn',
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
    </div>

    <div class="arm-grid-card">
        <div id="<?= Html::encode($gridId) ?>" class="ag-theme-quartz arm-grid-loading"<?= $gridAttrs ?>>
            <div class="arm-grid-loading__inner">
                <i class="fas fa-circle-notch fa-spin" aria-hidden="true"></i>
                <p>Загрузка таблицы…</p>
            </div>
        </div>
    </div>
</div>
