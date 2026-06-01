<?php

use app\assets\WorkTasksAsset;
use app\models\dictionaries\DicWorkTaskStatus;
use app\models\entities\WorkTask;
use app\models\search\WorkTaskSearch;
use yii\helpers\Html;
use yii\helpers\Url;

/** @var yii\web\View $this */
/** @var app\models\search\WorkTaskSearch $searchModel */
/** @var array{tasks: WorkTask[], byStatus: array<string, WorkTask[]>} $board */
/** @var array $timelineSteps */
/** @var array<int, string[]> $allowedByTask */
/** @var bool $isManager */
/** @var bool $canCreateTask */
/** @var int $pendingReviewCount */
/** @var array $executors */
/** @var app\models\entities\WorkTask|null $createModel */

WorkTasksAsset::register($this);

$this->title = 'Задачи';
$this->params['breadcrumbs'] = [];

$filter = $searchModel->filter ?: 'active';
$isClosedTab = $filter === 'done';
$byStatus = $board['byStatus'] ?? [];
$closedTasks = $isClosedTab ? ($board['tasks'] ?? []) : [];
$totalCount = count($board['tasks'] ?? []);
$searchQ = trim((string) $searchModel->q);
$currentSort = $searchModel->sort ?: WorkTaskSearch::SORT_CLOSED_DESC;
$closedFrom = $searchModel->closed_from ?: '';
$closedTo = $searchModel->closed_to ?: '';
$pendingReviewCount = (int) ($pendingReviewCount ?? 0);

/** Колонки Kanban: активные — без «Закрыта»; закрытые — только финальные колонки. */
$boardColumns = $timelineSteps;
if ($filter === 'active') {
    $boardColumns = array_values(array_filter(
        $timelineSteps,
        static fn(array $step): bool => ($step['code'] ?? '') !== DicWorkTaskStatus::CODE_DONE
    ));
} elseif ($filter === 'done') {
    $boardColumns = array_values(array_filter(
        $timelineSteps,
        static fn(array $step): bool => ($step['code'] ?? '') === DicWorkTaskStatus::CODE_DONE
    ));
}
$showCancelledColumn = $filter === 'done';

$filterTab = static function (string $key, string $label) use ($filter, $searchModel, $currentSort) {
    $params = ['filter' => $key];
    if (trim((string) $searchModel->q) !== '') {
        $params['q'] = $searchModel->q;
    }
    if ($searchModel->executor_id !== null) {
        $params['executor_id'] = $searchModel->executor_id;
    }
    if ($key === 'done') {
        $params['sort'] = $currentSort;
        if (!empty($searchModel->closed_from)) {
            $params['closed_from'] = $searchModel->closed_from;
        }
        if (!empty($searchModel->closed_to)) {
            $params['closed_to'] = $searchModel->closed_to;
        }
    }

    return Html::a($label, ['index'] + $params, [
        'class' => 'nav-link arm-type-tab' . ($filter === $key ? ' active' : ''),
        'role' => 'tab',
        'aria-selected' => $filter === $key ? 'true' : 'false',
    ]);
};

$searchFormAction = Yii::$app->request->scriptUrl ?: Url::to(['/']);

$this->registerJs(
    'window.workTasksBoardConfig = ' . json_encode([
        'transitionUrlTemplate' => Url::to(['transition', 'id' => '__ID__']),
        'bulkConfirmUrl' => Url::to(['bulk-confirm']),
    ], JSON_UNESCAPED_UNICODE | JSON_HEX_TAG | JSON_HEX_APOS | JSON_HEX_QUOT) . ';'
    . 'window.workTasksViewConfig = ' . json_encode([
        'viewUrlTemplate' => Url::to(['view', 'id' => '__ID__']),
    ], JSON_UNESCAPED_UNICODE | JSON_HEX_TAG | JSON_HEX_APOS | JSON_HEX_QUOT) . ';',
    \yii\web\View::POS_HEAD
);
?>

<div class="arm-page work-tasks-page<?= $isClosedTab ? ' work-tasks-page--closed' : '' ?>">
    <header class="arm-page__header">
        <div class="arm-page__heading">
            <h1 class="arm-page__title"><?= Html::encode($this->title) ?></h1>
        </div>
    </header>

    <form method="get" action="<?= Html::encode($searchFormAction) ?>"
          class="arm-command-bar work-tasks-command-form" role="region" aria-label="Поиск и фильтры">
        <?= Html::hiddenInput('r', $this->context->route) ?>
        <input type="hidden" name="filter" value="<?= Html::encode($filter) ?>">

        <div class="arm-search">
            <label class="visually-hidden" for="workTasksSearch">Поиск по задачам</label>
            <i class="fas fa-search arm-search__icon" aria-hidden="true"></i>
            <input type="search" id="workTasksSearch" name="q" class="form-control arm-search__input"
                   placeholder="Поиск" autocomplete="off"
                   value="<?= Html::encode($searchModel->q) ?>">
        </div>

        <div class="arm-command-bar__tabs" role="tablist" aria-label="Фильтр задач">
            <ul class="nav arm-type-tabs">
                <li class="nav-item"><?= $filterTab('active', 'Активные') ?></li>
                <li class="nav-item"><?= $filterTab('done', 'Закрытые') ?></li>
            </ul>
        </div>

        <div class="arm-command-bar__tools">
            <?php if ($isClosedTab): ?>
            <select name="sort" class="form-select form-select-sm work-tasks-sort-select"
                    aria-label="Сортировка закрытых задач">
                <?php foreach (WorkTaskSearch::sortLabels() as $sortKey => $sortLabel): ?>
                <option value="<?= Html::encode($sortKey) ?>"<?= $currentSort === $sortKey ? ' selected' : '' ?>>
                    <?= Html::encode($sortLabel) ?>
                </option>
                <?php endforeach; ?>
            </select>
            <label class="visually-hidden" for="closedFromDate">Период закрытия от</label>
            <input type="date" id="closedFromDate" name="closed_from"
                   class="form-control form-control-sm work-tasks-period-date"
                   value="<?= Html::encode($closedFrom) ?>">
            <label class="visually-hidden" for="closedToDate">Период закрытия до</label>
            <input type="date" id="closedToDate" name="closed_to"
                   class="form-control form-control-sm work-tasks-period-date"
                   value="<?= Html::encode($closedTo) ?>">
            <?php endif; ?>
            <?php if (!empty($canCreateTask) && $executors): ?>
            <select name="executor_id" class="form-select form-select-sm work-tasks-executor-select"
                    aria-label="Исполнитель">
                <option value="">Все исполнители</option>
                <?php foreach ($executors as $eid => $ename): ?>
                <option value="<?= (int) $eid ?>"<?= $searchModel->executor_id !== null && (int) $searchModel->executor_id === (int) $eid ? ' selected' : '' ?>>
                    <?= Html::encode($ename) ?>
                </option>
                <?php endforeach; ?>
            </select>
            <?php endif; ?>
            <button type="submit" class="btn btn-outline-secondary arm-tool-btn" title="Применить фильтры">
                <i class="fas fa-filter" aria-hidden="true"></i><span class="arm-btn-label">Применить</span>
            </button>
            <?php if ($isManager && !$isClosedTab): ?>
            <button type="button"
                    class="btn btn-success arm-tool-btn"
                    data-work-tasks-bulk-confirm
                    data-count="<?= $pendingReviewCount ?>"
                    title="Подтвердить выполнение всех задач в статусе «Выполнена»"
                    <?= $pendingReviewCount <= 0 ? ' disabled' : '' ?>>
                <i class="fas fa-check-double" aria-hidden="true"></i>
                <span class="arm-btn-label">Подтвердить все<?= $pendingReviewCount > 0 ? ' (' . $pendingReviewCount . ')' : '' ?></span>
            </button>
            <?php endif; ?>
            <?php if (!empty($canCreateTask)): ?>
            <button type="button" class="btn btn-primary arm-tool-btn" data-work-task-create-open
                    title="Создать задачу">
                <i class="fas fa-plus" aria-hidden="true"></i><span class="arm-btn-label">Создать</span>
            </button>
            <?php endif; ?>
        </div>
    </form>

    <?php
    $hasSearch = $searchQ !== '';
    $hasExecutorFilter = $searchModel->executor_id !== null && isset($executors[$searchModel->executor_id]);
    $hasSortFilter = $isClosedTab && $currentSort !== WorkTaskSearch::SORT_CLOSED_DESC;
    $hasPeriodFilter = $isClosedTab && ($closedFrom !== '' || $closedTo !== '');
    if ($hasSearch || $hasExecutorFilter || $hasSortFilter || $hasPeriodFilter):
    ?>
    <div class="work-tasks-active-filters" role="status">
        <span class="work-tasks-active-filters__label">Фильтр:</span>
        <?php if ($hasExecutorFilter): ?>
        <span class="work-tasks-active-filters__chip">
            Исполнитель: <?= Html::encode($executors[$searchModel->executor_id]) ?>
        </span>
        <?php endif; ?>
        <?php if ($hasSearch): ?>
        <span class="work-tasks-active-filters__chip">
            Поиск: «<?= Html::encode($searchModel->q) ?>»
        </span>
        <?php endif; ?>
        <?php if ($hasSortFilter): ?>
        <span class="work-tasks-active-filters__chip">
            Сортировка: <?= Html::encode(WorkTaskSearch::sortLabels()[$currentSort] ?? $currentSort) ?>
        </span>
        <?php endif; ?>
        <?php if ($hasPeriodFilter): ?>
        <span class="work-tasks-active-filters__chip">
            Период:
            <?= Html::encode($closedFrom !== '' ? $closedFrom : '...') ?>
            —
            <?= Html::encode($closedTo !== '' ? $closedTo : '...') ?>
        </span>
        <?php endif; ?>
        <?= Html::a('Сбросить', ['index', 'filter' => $filter], ['class' => 'work-tasks-active-filters__reset']) ?>
    </div>
    <?php endif; ?>

    <div class="arm-grid-card work-tasks-board-card<?= $isClosedTab ? ' work-tasks-board-card--closed' : '' ?>">
        <div class="work-tasks-board-card__body">
            <?php if ($totalCount === 0): ?>
                <div class="work-tasks-board-empty text-muted">
                    <p class="mb-0">
                        <?= $isClosedTab ? 'Закрытых задач нет.' : 'Задач нет.' ?>
                        <?php if (!empty($canCreateTask) && !$isClosedTab): ?>
                            <button type="button" class="btn btn-link work-tasks-link-btn p-0 align-baseline"
                                    data-work-task-create-open>Создайте задачу</button>
                            или дождитесь новой заявки.
                        <?php endif; ?>
                    </p>
                </div>
            <?php elseif ($isClosedTab): ?>
                <?= $this->render('_closed_list', ['closedTasks' => $closedTasks]) ?>
            <?php else: ?>
                <div class="work-kanban" id="workKanbanBoard" data-board-filter="<?= Html::encode($filter) ?>">
                    <?php foreach ($boardColumns as $step):
                        $code = $step['code'];
                        $columnTasks = $byStatus[$code] ?? [];
                    ?>
                    <section class="work-kanban__column work-kanban__column--<?= Html::encode($code) ?>"
                             data-status-code="<?= Html::encode($code) ?>"
                             aria-label="<?= Html::encode($step['name']) ?>">
                        <header class="work-kanban__column-header">
                            <span class="work-kanban__column-title"><?= Html::encode($step['name']) ?></span>
                            <span class="work-kanban__column-count"><?= count($columnTasks) ?></span>
                        </header>
                        <div class="work-kanban__cards" data-drop-zone>
                            <?php foreach ($columnTasks as $task):
                                $allowed = $allowedByTask[$task->id] ?? [];
                                $draggable = $allowed !== [];
                            ?>
                            <article class="work-task-card work-task-card--kanban<?= $draggable ? '' : ' work-task-card--locked' ?>"
                                     data-task-id="<?= (int) $task->id ?>"
                                     data-status-code="<?= Html::encode($task->getStatusCode()) ?>"
                                     data-allowed="<?= Html::encode(implode(',', $allowed)) ?>"
                                     data-transition-url="<?= Html::encode(Url::to(['transition', 'id' => $task->id])) ?>"
                                     <?= $draggable ? 'draggable="true"' : '' ?>>
                                <?= $this->render('_card_header', ['task' => $task]) ?>
                                <?= $this->render('_card_description', ['task' => $task]) ?>
                                <?= $this->render('_card_meta', ['task' => $task]) ?>
                            </article>
                            <?php endforeach; ?>
                        </div>
                    </section>
                    <?php endforeach; ?>

                    <?php
                    $cancelled = $byStatus[DicWorkTaskStatus::CODE_CANCELLED] ?? [];
                    if ($showCancelledColumn && $cancelled !== []):
                    ?>
                    <section class="work-kanban__column work-kanban__column--cancelled"
                             data-status-code="<?= Html::encode(DicWorkTaskStatus::CODE_CANCELLED) ?>"
                             aria-label="Отменена">
                        <header class="work-kanban__column-header">
                            <span class="work-kanban__column-title">Отменена</span>
                            <span class="work-kanban__column-count"><?= count($cancelled) ?></span>
                        </header>
                        <div class="work-kanban__cards" data-drop-zone>
                            <?php foreach ($cancelled as $task): ?>
                            <article class="work-task-card work-task-card--kanban work-task-card--locked"
                                     data-task-id="<?= (int) $task->id ?>"
                                     data-status-code="cancelled"
                                     data-allowed="">
                                <?= $this->render('_card_header', ['task' => $task]) ?>
                                <?= $this->render('_card_description', ['task' => $task]) ?>
                                <?= $this->render('_card_meta', ['task' => $task]) ?>
                            </article>
                            <?php endforeach; ?>
                        </div>
                    </section>
                    <?php endif; ?>
                </div>

                <?php endif; ?>
            <?php if ($totalCount >= 200): ?>
            <p class="text-muted small work-tasks-board-limit mb-0 mt-2">
                Показаны последние 200 задач. Уточните поиск или фильтр.
            </p>
            <?php endif; ?>
        </div>
    </div>
</div>

<div id="workTaskBoardToast" class="work-task-board-toast" role="status" aria-live="polite" hidden></div>

<?= $this->render('_view_modal') ?>

<?php if (!empty($canCreateTask) && $createModel): ?>
    <?= $this->render('_create_modal', [
        'model' => $createModel,
        'executors' => $executors,
    ]) ?>
<?php endif; ?>
