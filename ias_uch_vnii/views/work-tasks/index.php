<?php

use app\assets\WorkTasksAsset;
use app\models\dictionaries\DicWorkTaskStatus;
use app\models\entities\WorkTask;
use yii\helpers\Html;
use yii\helpers\Url;

/** @var yii\web\View $this */
/** @var app\models\search\WorkTaskSearch $searchModel */
/** @var array{tasks: WorkTask[], byStatus: array<string, WorkTask[]>} $board */
/** @var array $timelineSteps */
/** @var array<int, string[]> $allowedByTask */
/** @var bool $isManager */
/** @var array $executors */
/** @var app\models\entities\WorkTask|null $createModel */
/** @var array $requests */

WorkTasksAsset::register($this);

$this->title = 'Задачи';
$this->params['breadcrumbs'] = [];

$filter = $searchModel->filter ?: 'active';
$byStatus = $board['byStatus'] ?? [];
$totalCount = count($board['tasks'] ?? []);

/** Колонки Kanban: на вкладке «Активные» без «Закрыта». */
$boardColumns = $timelineSteps;
if ($filter === 'active') {
    $boardColumns = array_values(array_filter(
        $timelineSteps,
        static fn(array $step): bool => ($step['code'] ?? '') !== DicWorkTaskStatus::CODE_DONE
    ));
}

$filterTab = static function (string $key, string $label) use ($filter, $searchModel) {
    $params = ['filter' => $key];
    if (trim((string) $searchModel->q) !== '') {
        $params['q'] = $searchModel->q;
    }
    if ($searchModel->executor_id !== null) {
        $params['executor_id'] = $searchModel->executor_id;
    }
    $class = 'nav-link work-tasks-filter-tab' . ($filter === $key ? ' active' : '');

    return Html::a($label, ['index'] + $params, [
        'class' => $class,
        'role' => 'tab',
        'aria-selected' => $filter === $key ? 'true' : 'false',
    ]);
};

$this->registerJs(
    'window.workTasksBoardConfig = ' . json_encode([
        'transitionUrlTemplate' => Url::to(['transition', 'id' => '__ID__']),
    ], JSON_UNESCAPED_UNICODE | JSON_HEX_TAG | JSON_HEX_APOS | JSON_HEX_QUOT) . ';'
    . 'window.workTasksViewConfig = ' . json_encode([
        'viewUrlTemplate' => Url::to(['view', 'id' => '__ID__']),
    ], JSON_UNESCAPED_UNICODE | JSON_HEX_TAG | JSON_HEX_APOS | JSON_HEX_QUOT) . ';',
    \yii\web\View::POS_HEAD
);
?>

<div class="work-tasks-page work-tasks-page--board">
    <header class="work-tasks-page__header">
        <div class="work-tasks-page__heading">
            <h1 class="work-tasks-page__title"><?= Html::encode($this->title) ?></h1>
            <p class="work-tasks-page__hint">Перетащите карточку в колонку для смены статуса</p>
        </div>
    </header>

    <div class="work-tasks-command-bar" role="region" aria-label="Поиск и фильтры">
        <?php
        // GET-форма заменяет query в action — маршрут передаём полем r (иначе открывается homeUrl → Учёт ТС).
        $searchFormAction = Yii::$app->request->scriptUrl ?: Url::to(['/']);
        ?>
        <form method="get" action="<?= Html::encode($searchFormAction) ?>" class="work-tasks-command-bar__search-form">
            <?= Html::hiddenInput('r', $this->context->route) ?>
            <input type="hidden" name="filter" value="<?= Html::encode($filter) ?>">
            <div class="work-tasks-search">
                <label class="visually-hidden" for="workTasksSearch">Поиск по задачам</label>
                <i class="fas fa-search work-tasks-search__icon" aria-hidden="true"></i>
                <input type="search" id="workTasksSearch" name="q" class="form-control work-tasks-search__input"
                       placeholder="Поиск" autocomplete="off"
                       value="<?= Html::encode($searchModel->q) ?>">
            </div>
            <div class="work-tasks-command-bar__tabs" role="tablist" aria-label="Фильтр задач">
                <ul class="nav work-tasks-filter-tabs">
                    <li class="nav-item"><?= $filterTab('active', 'Активные') ?></li>
                    <li class="nav-item"><?= $filterTab('review', 'Выполненные') ?></li>
                    <li class="nav-item"><?= $filterTab('done', 'Закрытые') ?></li>
                    <li class="nav-item"><?= $filterTab('all', 'Все') ?></li>
                </ul>
            </div>
            <div class="work-tasks-command-bar__tools">
                <?php if ($isManager && $executors): ?>
                <select name="executor_id" class="form-select work-tasks-command-bar__select" aria-label="Исполнитель">
                    <option value="">Все исполнители</option>
                    <?php foreach ($executors as $eid => $ename): ?>
                    <option value="<?= (int) $eid ?>"<?= $searchModel->executor_id !== null && (int) $searchModel->executor_id === (int) $eid ? ' selected' : '' ?>>
                        <?= Html::encode($ename) ?>
                    </option>
                    <?php endforeach; ?>
                </select>
                <?php endif; ?>
                <button type="submit" class="btn btn-outline-secondary work-tasks-tool-btn" title="Применить фильтры">
                    <i class="fas fa-filter" aria-hidden="true"></i><span class="work-tasks-btn-label">Применить</span>
                </button>
                <?php if ($isManager): ?>
                <button type="button" class="btn btn-primary work-tasks-tool-btn" data-work-task-create-open
                        title="Создать задачу">
                    <i class="fas fa-plus" aria-hidden="true"></i><span class="work-tasks-btn-label">Создать</span>
                </button>
                <?php endif; ?>
            </div>
        </form>
    </div>

    <?php
    $hasSearch = trim((string) $searchModel->q) !== '';
    $hasExecutorFilter = $searchModel->executor_id !== null && isset($executors[$searchModel->executor_id]);
    if ($hasSearch || $hasExecutorFilter):
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
        <?= Html::a('Сбросить', ['index', 'filter' => $filter], ['class' => 'work-tasks-active-filters__reset']) ?>
    </div>
    <?php endif; ?>

  <?php if ($totalCount === 0): ?>
    <p class="text-muted">
        Задач нет.
        <?php if ($isManager): ?>
            <button type="button" class="btn btn-link work-tasks-link-btn p-0 align-baseline" data-work-task-create-open>Создайте задачу</button>
            или дождитесь новой заявки.
        <?php endif; ?>
    </p>
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
        if ($cancelled !== []):
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
                         data-allowed=""
                         >
                    <?= $this->render('_card_header', ['task' => $task]) ?>
                    <?= $this->render('_card_description', ['task' => $task]) ?>
                    <?= $this->render('_card_meta', ['task' => $task]) ?>
                </article>
                <?php endforeach; ?>
            </div>
        </section>
        <?php endif; ?>
    </div>

    <?php if ($totalCount >= 200): ?>
    <p class="text-muted small mt-2">Показаны последние 200 задач. Уточните поиск или фильтр.</p>
    <?php endif; ?>

  <?php endif; ?>
</div>

<div id="workTaskBoardToast" class="work-task-board-toast" role="status" aria-live="polite" hidden></div>

<?= $this->render('_view_modal') ?>

<?php if ($isManager && $createModel): ?>
    <?= $this->render('_create_modal', [
        'model' => $createModel,
        'executors' => $executors,
        'requests' => $requests,
    ]) ?>
<?php endif; ?>
