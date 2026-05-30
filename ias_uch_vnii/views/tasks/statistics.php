<?php

use app\assets\StatisticsAsset;
use yii\helpers\Html;
use yii\helpers\Url;

/** @var yii\web\View $this */
/** @var array $report */
/** @var string|null $dateFrom */
/** @var string|null $dateTo */

StatisticsAsset::register($this);

$executors = $report['executors'] ?? [];
$statusDistribution = $report['status_distribution'] ?? [];
$workStatusDistribution = $report['work_status_distribution'] ?? [];
$monthlyCompleted = $report['monthly_completed'] ?? [];
$dailyCompleted = $report['daily_completed'] ?? [];
$movements = $report['movements'] ?? [];
$movementSummary = $report['movement_summary'] ?? ['routes' => 0, 'units' => 0, 'moves' => 0];
$periodLabel = $report['period']['label'] ?? '';
$statsTab = Yii::$app->request->get('tab', 'tasks');
$allowedTabs = ['tasks', 'requests', 'movements'];
if (!in_array($statsTab, $allowedTabs, true)) {
    $statsTab = 'tasks';
}
$trendMode = Yii::$app->request->get('trend', 'day');
if (!in_array($trendMode, ['month', 'day'], true)) {
    $trendMode = 'day';
}

$maxExecutorCount = $executors !== [] ? max(array_column($executors, 'completed_count')) : 1;
$maxStatusCount = $statusDistribution !== [] ? max(array_column($statusDistribution, 'count')) : 1;
$maxWorkStatusCount = $workStatusDistribution !== [] ? max(array_column($workStatusDistribution, 'count')) : 1;
$maxMonthly = $monthlyCompleted !== [] ? max(array_column($monthlyCompleted, 'count')) : 1;
$maxDaily = $dailyCompleted !== [] ? max(array_column($dailyCompleted, 'count')) : 1;

$this->title = 'Статистика';
$this->params['breadcrumbs'][] = $this->title;

$gridQuery = [];
if ($dateFrom) {
    $gridQuery['date_from'] = $dateFrom;
}
if ($dateTo) {
    $gridQuery['date_to'] = $dateTo;
}
$executorGridUrl = Url::to(array_merge(['tasks/statistics-get-grid-data', 'type' => 'executor'], $gridQuery));
$requesterGridUrl = Url::to(array_merge(['tasks/statistics-get-grid-data', 'type' => 'requester'], $gridQuery));
$movementGridUrl = Url::to(array_merge(['tasks/statistics-get-grid-data', 'type' => 'movement'], $gridQuery));

$buildTabLink = static function (string $key, string $label) use ($statsTab, $dateFrom, $dateTo): string {
    $params = ['/tasks/statistics', 'tab' => $key];
    if ($dateFrom) {
        $params['date_from'] = $dateFrom;
    }
    if ($dateTo) {
        $params['date_to'] = $dateTo;
    }

    return Html::a($label, $params, [
        'class' => 'nav-link arm-type-tab' . ($statsTab === $key ? ' active' : ''),
        'role' => 'tab',
        'aria-selected' => $statsTab === $key ? 'true' : 'false',
    ]);
};

$buildTrendLink = static function (string $mode, string $label) use ($trendMode): string {
    return Html::a($label, '#', [
        'class' => 'nav-link tasks-kpi-trend-tab' . ($trendMode === $mode ? ' active' : ''),
        'data-trend-mode' => $mode,
    ]);
};

$statsRootClasses = 'tasks-page tasks-page--stats tasks-kpi arm-page section-grid-page';
if ($statsTab === 'movements') {
    $statsRootClasses .= ' tasks-page--stats-movements';
}

$statsFilterClass = 'tasks-kpi-filter';
if ($statsTab === 'movements') {
    $statsFilterClass .= ' tasks-kpi-filter--movements';
}
?>

<div class="<?= Html::encode($statsRootClasses) ?>">
    <header class="tasks-page__header arm-page__header">
        <div class="tasks-page__heading arm-page__heading">
            <h1 class="tasks-page__title arm-page__title"><?= Html::encode($this->title) ?></h1>
        </div>
    </header>

    <div class="tasks-stats-tabs" role="tablist" aria-label="Разделы статистики">
        <ul class="nav arm-type-tabs">
            <li class="nav-item"><?= $buildTabLink('tasks', 'Статистика по задачам') ?></li>
            <li class="nav-item"><?= $buildTabLink('requests', 'Статистика по заявкам') ?></li>
            <li class="nav-item"><?= $buildTabLink('movements', 'История перемещения техники') ?></li>
        </ul>
    </div>

    <form method="get" action="<?= Html::encode(Url::to(['/tasks/statistics'])) ?>" class="<?= Html::encode($statsFilterClass) ?>">
        <input type="hidden" name="tab" value="<?= Html::encode($statsTab) ?>">
        <input type="hidden" name="trend" value="<?= Html::encode($trendMode) ?>">
        <div class="tasks-kpi-filter__fields">
            <div class="tasks-kpi-filter__field">
                <label for="statsDateFrom">Период с</label>
                <input type="date" id="statsDateFrom" name="date_from" class="form-control"
                       value="<?= Html::encode($dateFrom ?? '') ?>">
            </div>
            <div class="tasks-kpi-filter__field">
                <label for="statsDateTo">по</label>
                <input type="date" id="statsDateTo" name="date_to" class="form-control"
                       value="<?= Html::encode($dateTo ?? '') ?>">
            </div>
            <?php if ($statsTab === 'movements'): ?>
            <div class="tasks-kpi-filter__field tasks-kpi-filter__field--search">
                <label for="statsMovementQuickFilter">Поиск по таблице</label>
                <div class="arm-search tasks-kpi-filter__search">
                    <i class="fas fa-search arm-search__icon" aria-hidden="true"></i>
                    <input type="search" id="statsMovementQuickFilter" class="form-control arm-search__input"
                           placeholder="Поиск" autocomplete="off"
                           <?= $movements === [] ? ' disabled' : '' ?>>
                    <button type="button" class="arm-search__clear" id="statsMovementQuickFilterClear"
                            aria-label="Очистить поиск" title="Очистить поиск" hidden>×</button>
                </div>
            </div>
            <?php endif; ?>
            <button type="submit" class="btn btn-primary tasks-tool-btn">Применить</button>
            <?= Html::a('Сбросить', ['/tasks/statistics', 'tab' => $statsTab, 'trend' => $trendMode], ['class' => 'btn btn-outline-secondary tasks-tool-btn']) ?>
        </div>
    </form>

    <?php if ($statsTab === 'tasks'): ?>
    <div class="tasks-stats-tab-pane tasks-stats-tab-pane--tasks">
    <div class="tasks-kpi-panels">
        <section class="tasks-kpi-panel" aria-labelledby="kpiExecutorsTitle">
            <header class="tasks-kpi-panel__header">
                <h2 id="kpiExecutorsTitle" class="tasks-kpi-panel__title">
                    <i class="fas fa-user-check" aria-hidden="true"></i> Выполнено по исполнителям
                </h2>
            </header>
            <?php if ($executors === []): ?>
                <p class="tasks-kpi-panel__empty">Нет выполненных заявок за выбранный период.</p>
            <?php else: ?>
                <ul class="tasks-kpi-bars">
                    <?php foreach (array_slice($executors, 0, 8) as $row):
                        $pct = $maxExecutorCount > 0 ? round(($row['completed_count'] / $maxExecutorCount) * 100) : 0;
                    ?>
                    <li class="tasks-kpi-bars__row">
                        <span class="tasks-kpi-bars__label" title="<?= Html::encode($row['name']) ?>">
                            <?= Html::encode($row['name']) ?>
                        </span>
                        <span class="tasks-kpi-bars__track">
                            <span class="tasks-kpi-bars__fill" style="width: <?= (int) $pct ?>%"></span>
                        </span>
                        <span class="tasks-kpi-bars__value"><?= (int) $row['completed_count'] ?></span>
                    </li>
                    <?php endforeach; ?>
                </ul>
            <?php endif; ?>
        </section>

        <section class="tasks-kpi-panel" aria-labelledby="kpiStatusTitle">
            <header class="tasks-kpi-panel__header">
                <h2 id="kpiStatusTitle" class="tasks-kpi-panel__title">
                    <i class="fas fa-chart-pie" aria-hidden="true"></i> По статусам
                </h2>
            </header>
            <?php if ($workStatusDistribution === []): ?>
                <p class="tasks-kpi-panel__empty">Нет данных.</p>
            <?php else: ?>
                <ul class="tasks-kpi-bars tasks-kpi-bars--muted">
                    <?php foreach ($workStatusDistribution as $row):
                        $pct = $maxWorkStatusCount > 0 ? round(($row['count'] / $maxWorkStatusCount) * 100) : 0;
                    ?>
                    <li class="tasks-kpi-bars__row">
                        <span class="tasks-kpi-bars__label"><?= Html::encode($row['name']) ?></span>
                        <span class="tasks-kpi-bars__track">
                            <span class="tasks-kpi-bars__fill tasks-kpi-bars__fill--status" style="width: <?= (int) $pct ?>%"></span>
                        </span>
                        <span class="tasks-kpi-bars__value"><?= (int) $row['count'] ?></span>
                    </li>
                    <?php endforeach; ?>
                </ul>
            <?php endif; ?>
        </section>

        <?php if ($monthlyCompleted !== [] || $dailyCompleted !== []): ?>
        <section class="tasks-kpi-panel tasks-kpi-panel--wide" aria-labelledby="kpiMonthlyTitle">
            <header class="tasks-kpi-panel__header">
                <h2 id="kpiMonthlyTitle" class="tasks-kpi-panel__title">
                    <i class="fas fa-calendar-check" aria-hidden="true"></i> Динамика выполнения
                </h2>
            </header>
            <ul class="nav nav-tabs tasks-kpi-trend-tabs">
                <li class="nav-item"><?= $buildTrendLink('day', 'По дням') ?></li>
                <li class="nav-item"><?= $buildTrendLink('month', 'По месяцам') ?></li>
            </ul>
            <div class="tasks-kpi-trend-chart" data-trend-panel="month"<?= $trendMode === 'month' ? '' : ' hidden' ?>>
                <?php foreach ($monthlyCompleted as $row):
                    $h = $maxMonthly > 0 ? max(8, round(($row['count'] / $maxMonthly) * 100)) : 8;
                ?>
                <div class="tasks-kpi-trend-chart__col" title="<?= (int) $row['count'] ?> заявок">
                    <div class="tasks-kpi-trend-chart__bar" style="height: <?= (int) $h ?>%"></div>
                    <span class="tasks-kpi-trend-chart__count"><?= (int) $row['count'] ?></span>
                    <span class="tasks-kpi-trend-chart__label"><?= Html::encode($row['label']) ?></span>
                </div>
                <?php endforeach; ?>
            </div>
            <div class="tasks-kpi-trend-chart" data-trend-panel="day"<?= $trendMode === 'day' ? '' : ' hidden' ?>>
                    <?php foreach ($dailyCompleted as $row):
                        $h = $maxDaily > 0 ? max(8, round(($row['count'] / $maxDaily) * 100)) : 8;
                    ?>
                    <div class="tasks-kpi-trend-chart__col" title="<?= (int) $row['count'] ?> заявок">
                        <div class="tasks-kpi-trend-chart__bar" style="height: <?= (int) $h ?>%"></div>
                        <span class="tasks-kpi-trend-chart__count"><?= (int) $row['count'] ?></span>
                        <span class="tasks-kpi-trend-chart__label"><?= Html::encode($row['label']) ?></span>
                    </div>
                    <?php endforeach; ?>
            </div>
            <?php if ($monthlyCompleted === [] && $dailyCompleted === []): ?>
                <p class="tasks-kpi-panel__empty">Нет данных для выбранного режима.</p>
            <?php endif; ?>
        </section>
        <?php endif; ?>
    </div>

    <section class="tasks-kpi-table-section" aria-labelledby="kpiExecutorTableTitle">
        <header class="tasks-kpi-panel__header">
            <h2 id="kpiExecutorTableTitle" class="tasks-kpi-panel__title">
                <i class="fas fa-table" aria-hidden="true"></i> Детализация по исполнителям
            </h2>
        </header>
        <div class="arm-grid-card tasks-stats-grid-card">
            <div class="arm-grid-card__body">
                <div id="agGridStatisticsExecutorContainer"
                     class="ag-theme-quartz tasks-kpi-grid"
                     data-url="<?= Html::encode($executorGridUrl) ?>"
                     data-grid-type="executor"></div>
            </div>
        </div>
    </section>
    </div>
    <?php endif; ?>

    <?php if ($statsTab === 'requests'): ?>
        <div class="tasks-stats-tab-pane tasks-stats-tab-pane--requests">
        <section class="tasks-kpi-panel" aria-labelledby="kpiStatusTitleRequests">
            <header class="tasks-kpi-panel__header">
                <h2 id="kpiStatusTitleRequests" class="tasks-kpi-panel__title">
                    <i class="fas fa-chart-pie" aria-hidden="true"></i> Распределение по статусам
                </h2>
            </header>
            <?php if ($statusDistribution === []): ?>
                <p class="tasks-kpi-panel__empty">Нет данных за выбранный период.</p>
            <?php else: ?>
                <ul class="tasks-kpi-bars tasks-kpi-bars--muted">
                    <?php foreach ($statusDistribution as $row):
                        $pct = $maxStatusCount > 0 ? round(($row['count'] / $maxStatusCount) * 100) : 0;
                    ?>
                    <li class="tasks-kpi-bars__row">
                        <span class="tasks-kpi-bars__label"><?= Html::encode($row['name']) ?></span>
                        <span class="tasks-kpi-bars__track">
                            <span class="tasks-kpi-bars__fill tasks-kpi-bars__fill--status" style="width: <?= (int) $pct ?>%"></span>
                        </span>
                        <span class="tasks-kpi-bars__value"><?= (int) $row['count'] ?></span>
                    </li>
                    <?php endforeach; ?>
                </ul>
            <?php endif; ?>
        </section>

        <section class="tasks-kpi-table-section" aria-labelledby="kpiRequesterTableTitle">
            <header class="tasks-kpi-panel__header">
                <h2 id="kpiRequesterTableTitle" class="tasks-kpi-panel__title">
                    <i class="fas fa-users" aria-hidden="true"></i> Заявки по авторам
                </h2>
            </header>
            <div class="arm-grid-card tasks-stats-grid-card">
                <div class="arm-grid-card__body">
                    <div id="agGridStatisticsRequesterContainer"
                         class="ag-theme-quartz tasks-kpi-grid"
                         data-url="<?= Html::encode($requesterGridUrl) ?>"
                         data-grid-type="requester"></div>
                </div>
            </div>
        </section>
        </div>
    <?php endif; ?>

    <?php if ($statsTab === 'movements'): ?>
    <div class="tasks-stats-tab-pane tasks-stats-tab-pane--movements">
    <section class="tasks-kpi-table-section tasks-kpi-table-section--movement" aria-labelledby="kpiMovementTableTitle">
        <header class="tasks-kpi-panel__header">
            <h2 id="kpiMovementTableTitle" class="tasks-kpi-panel__title">
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
                    <div id="agGridStatisticsMovementContainer"
                         class="ag-theme-quartz tasks-kpi-grid tasks-kpi-grid--movement"
                         data-url="<?= Html::encode($movementGridUrl) ?>"
                         data-grid-type="movement"></div>
                </div>
            </div>
        <?php endif; ?>
    </section>
    </div>
    <?php endif; ?>
</div>
<?php
$this->registerJs(<<<JS
(function () {
    var tabs = document.querySelectorAll('.tasks-kpi-trend-tab[data-trend-mode]');
    if (!tabs.length) return;
    var trendInput = document.querySelector('input[name="trend"]');
    var panels = document.querySelectorAll('[data-trend-panel]');

    function setMode(mode) {
        tabs.forEach(function (tab) {
            tab.classList.toggle('active', tab.getAttribute('data-trend-mode') === mode);
        });
        panels.forEach(function (panel) {
            panel.hidden = panel.getAttribute('data-trend-panel') !== mode;
        });
        if (trendInput) {
            trendInput.value = mode;
        }
    }

    tabs.forEach(function (tab) {
        tab.addEventListener('click', function (e) {
            e.preventDefault();
            setMode(tab.getAttribute('data-trend-mode'));
        });
    });
})();
JS);
?>
