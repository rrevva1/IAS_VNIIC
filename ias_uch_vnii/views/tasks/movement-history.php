<?php

use app\assets\MovementHistoryAsset;
use yii\helpers\Html;
use yii\helpers\Url;

/** @var yii\web\View $this */
/** @var array $report */
/** @var string|null $dateFrom */
/** @var string|null $dateTo */

MovementHistoryAsset::register($this);

$movements = $report['movements'] ?? [];
$movementSummary = $report['movement_summary'] ?? ['routes' => 0, 'units' => 0, 'moves' => 0];
$periodLabel = $report['period']['label'] ?? '';

$this->title = 'История перемещений';
$this->params['breadcrumbs'][] = $this->title;

$gridQuery = [];
if ($dateFrom) {
    $gridQuery['date_from'] = $dateFrom;
}
if ($dateTo) {
    $gridQuery['date_to'] = $dateTo;
}
$movementGridUrl = Url::to(array_merge(['tasks/movement-history-get-grid-data'], $gridQuery));
$formAction = Yii::$app->request->scriptUrl ?: Url::to(['/']);
?>

<div class="tasks-page tasks-page--movement-history tasks-kpi arm-page section-grid-page">
    <header class="tasks-page__header arm-page__header">
        <div class="tasks-page__heading arm-page__heading">
            <h1 class="tasks-page__title arm-page__title"><?= Html::encode($this->title) ?></h1>
        </div>
    </header>

    <form method="get" action="<?= Html::encode($formAction) ?>" class="tasks-kpi-filter tasks-kpi-filter--movements">
        <?= Html::hiddenInput('r', $this->context->route) ?>
        <div class="tasks-kpi-filter__fields">
            <div class="tasks-kpi-filter__field">
                <label for="movementHistoryDateFrom">Период с</label>
                <input type="date" id="movementHistoryDateFrom" name="date_from" class="form-control"
                       value="<?= Html::encode($dateFrom ?? '') ?>">
            </div>
            <div class="tasks-kpi-filter__field">
                <label for="movementHistoryDateTo">по</label>
                <input type="date" id="movementHistoryDateTo" name="date_to" class="form-control"
                       value="<?= Html::encode($dateTo ?? '') ?>">
            </div>
            <div class="tasks-kpi-filter__field tasks-kpi-filter__field--search">
                <label class="visually-hidden" for="movementHistoryQuickFilter">Поиск по таблице</label>
                <div class="arm-search tasks-kpi-filter__search">
                    <i class="fas fa-search arm-search__icon" aria-hidden="true"></i>
                    <input type="search" id="movementHistoryQuickFilter" class="form-control arm-search__input"
                           placeholder="Поиск" autocomplete="off"
                           <?= $movements === [] ? ' disabled' : '' ?>>
                    <button type="button" class="arm-search__clear" id="movementHistoryQuickFilterClear"
                            aria-label="Очистить поиск" title="Очистить поиск" hidden>×</button>
                </div>
            </div>
            <button type="submit" class="btn btn-primary tasks-tool-btn">Применить</button>
            <?= Html::a('Сбросить', ['/tasks/movement-history'], ['class' => 'btn btn-outline-secondary tasks-tool-btn']) ?>
        </div>
    </form>

    <section class="tasks-kpi-table-section tasks-kpi-table-section--movement" aria-labelledby="movementHistoryTableTitle">
        <header class="tasks-kpi-panel__header">
            <h2 id="movementHistoryTableTitle" class="tasks-kpi-panel__title">
                <i class="fas fa-exchange-alt" aria-hidden="true"></i> Перемещения техники
            </h2>
            <p class="tasks-kpi-filter__hint mb-0">
                Маршруты перемещений за период: <?= Html::encode($periodLabel ?: 'за всё время') ?>.
                Маршрутов: <strong><?= (int) ($movementSummary['routes'] ?? 0) ?></strong>,
                единиц техники: <strong><?= (int) ($movementSummary['units'] ?? 0) ?></strong>.
            </p>
        </header>
        <?php if ($movements === []): ?>
            <p class="tasks-kpi-panel__empty">За выбранный период перемещений техники не найдено.</p>
        <?php else: ?>
            <div class="arm-grid-card tasks-stats-grid-card">
                <div class="arm-grid-card__body">
                    <div id="agGridMovementHistoryContainer"
                         class="ag-theme-quartz tasks-kpi-grid tasks-kpi-grid--movement"
                         data-url="<?= Html::encode($movementGridUrl) ?>"></div>
                </div>
            </div>
        <?php endif; ?>
    </section>
</div>
