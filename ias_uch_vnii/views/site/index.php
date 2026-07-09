<?php

use app\assets\DashboardAsset;
use yii\helpers\Html;

/** @var yii\web\View $this */
/** @var array $dashboard */

DashboardAsset::register($this);

$summary = $dashboard['summary'] ?? ['critical' => 0, 'warning' => 0, 'info' => 0];
$widgets = $dashboard['widgets'] ?? [];
$hasIssues = ((int) ($summary['critical'] ?? 0) + (int) ($summary['warning'] ?? 0) + (int) ($summary['info'] ?? 0)) > 0;
$idleWidgetCount = count(array_filter(
    $widgets,
    static fn(array $widget): bool => (int) ($widget['count'] ?? 0) === 0
));

$this->title = 'Главная';
$this->params['breadcrumbs'] = [];

$severityLabels = [
    'critical' => 'Критично',
    'warning' => 'Скоро',
    'info' => 'Информация',
];
?>
<div class="arm-page section-grid-page dashboard-page">
    <header class="arm-page__header">
        <div class="arm-page__heading">
            <h1 class="arm-page__title">Требует внимания</h1>
            <p class="arm-page__subtitle text-muted mb-0">
                Сводка проблем, сроков и нерешённых задач. Перейдите в раздел по ссылке для подробностей.
            </p>
        </div>
    </header>

    <div class="arm-grid-card arm-content-panel dashboard-panel">
        <div class="dashboard-summary" aria-label="Сводка по приоритетам">
            <?php foreach ($severityLabels as $severity => $label): ?>
                <div class="dashboard-summary__item dashboard-summary__item--<?= Html::encode($severity) ?>">
                    <span class="dashboard-summary__count"><?= (int) ($summary[$severity] ?? 0) ?></span>
                    <span class="dashboard-summary__label"><?= Html::encode($label) ?></span>
                </div>
            <?php endforeach; ?>
        </div>

        <?php if ($widgets === []): ?>
            <div class="dashboard-all-clear">
                <i class="fas fa-circle-check" aria-hidden="true"></i>
                <p class="mb-0">Для вашей роли нет доступных виджетов на главной странице.</p>
            </div>
        <?php else: ?>
            <?php if (!$hasIssues): ?>
                <div class="dashboard-all-clear">
                    <i class="fas fa-circle-check" aria-hidden="true"></i>
                    <p class="mb-0">На текущий момент проблем, требующих внимания, не обнаружено.</p>
                </div>
            <?php endif; ?>

            <?php if ($idleWidgetCount > 0): ?>
                <div class="dashboard-widgets-toolbar">
                    <button type="button"
                            class="btn btn-sm btn-outline-secondary arm-tool-btn dashboard-widgets-toggle"
                            id="dashboard-widgets-toggle"
                            data-idle-count="<?= (int) $idleWidgetCount ?>"
                            aria-expanded="false"
                            aria-controls="dashboard-widgets">
                        <i class="fas fa-th-large" aria-hidden="true"></i>
                        <span class="arm-btn-label dashboard-widgets-toggle__label">Показать все виджеты</span>
                        <span class="dashboard-widgets-toggle__count">(<?= (int) $idleWidgetCount ?>)</span>
                    </button>
                </div>
            <?php endif; ?>

            <div class="dashboard-widgets" id="dashboard-widgets">
                <?php foreach ($widgets as $widget): ?>
                    <?= $this->render('_attention_widget', [
                        'widgetId' => (string) ($widget['id'] ?? 'widget'),
                        'title' => (string) ($widget['title'] ?? ''),
                        'icon' => (string) ($widget['icon'] ?? 'fas fa-circle'),
                        'severity' => (string) ($widget['severity'] ?? 'info'),
                        'count' => (int) ($widget['count'] ?? 0),
                        'items' => $widget['items'] ?? [],
                        'url' => $widget['url'] ?? null,
                        'urlLabel' => (string) ($widget['url_label'] ?? 'Перейти →'),
                        'emptyText' => (string) ($widget['empty_text'] ?? 'Нет записей.'),
                    ]) ?>
                <?php endforeach; ?>
            </div>
        <?php endif; ?>
    </div>
</div>
