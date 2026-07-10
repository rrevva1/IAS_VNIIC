<?php

use yii\helpers\Html;
use yii\helpers\Url;
use app\assets\AgGridAsset;
use app\assets\TasksAsset;
use app\models\entities\Users;
use app\models\dictionaries\DicTaskStatus;

/** @var \app\models\dictionaries\DicTaskStatus[] $taskStatuses */

AgGridAsset::register($this);
TasksAsset::register($this);

$taskStatuses = $taskStatuses ?? [];

$this->title = 'Заявки';
$this->params['breadcrumbs'] = [];

$isAdmin = !Yii::$app->user->isGuest && Yii::$app->user->identity && Yii::$app->user->identity->isAdministrator();
$canCreateTask = !empty($canCreateTask);

$usersList = [];

if ($isAdmin) {
    $usersList = Users::getSupportStaffList();
}

$this->registerJs("
    window.isUserAdmin = " . ($isAdmin ? 'true' : 'false') . ";
    window.canAssignTaskExecutor = " . ($isAdmin ? 'true' : 'false') . ";
    window.taskExecutorsList = " . json_encode($usersList) . ";
    window.allUsersList = window.taskExecutorsList;
    window.agGridDataUrl = '" . Url::to(['tasks/get-grid-data']) . "';
    window.tasksRealtimePollUrl = '" . Url::to(['tasks/poll-changes']) . "';
    window.tasksBulkDeleteUrl = '" . Url::to(['tasks/bulk-delete']) . "';
    window.tasksMinSelectedForDelete = 1;
    window.agGridTasksViewModalUrlTemplate = " . json_encode(Url::to(['view-modal', 'id' => '__ID__'])) . ";
    window.agGridTasksUpdateModalUrlTemplate = " . json_encode(Url::to(['update-modal', 'id' => '__ID__'])) . ";
", \yii\web\View::POS_HEAD);
?>

<div class="tasks-page tasks-page--grid">
    <header class="tasks-page__header">
        <div class="tasks-page__heading">
            <h1 class="tasks-page__title"><?= Html::encode($this->title) ?></h1>
        </div>
    </header>

    <div class="tasks-command-bar" role="region" aria-label="Поиск и действия">
        <div class="tasks-search">
            <label class="visually-hidden" for="tasksQuickFilter">Поиск по таблице</label>
            <i class="fas fa-search tasks-search__icon" aria-hidden="true"></i>
            <input type="search" id="tasksQuickFilter" class="form-control tasks-search__input"
                   placeholder="Поиск по заявкам" autocomplete="off">
            <button type="button" class="tasks-search__clear" id="tasksQuickFilterClear"
                    aria-label="Очистить поиск" title="Очистить поиск" hidden>×</button>
        </div>

        <div class="tasks-command-bar__tabs" role="tablist" aria-label="Статус заявки">
            <ul class="nav nav-tabs tasks-status-tabs">
                <li class="nav-item">
                    <a class="nav-link active tasks-status-tab" href="#" data-status-code="" role="tab" aria-selected="true">Все</a>
                </li>
                <?php foreach ($taskStatuses as $status): ?>
                <li class="nav-item">
                    <a class="nav-link tasks-status-tab" href="#" role="tab" aria-selected="false"
                       data-status-code="<?= Html::encode($status->status_code) ?>">
                        <?= Html::encode($status->status_name) ?>
                    </a>
                </li>
                <?php endforeach; ?>
            </ul>
        </div>

        <div class="tasks-command-bar__tools">
            <?php if ($canCreateTask): ?>
                <?= Html::button('<i class="fas fa-plus" aria-hidden="true"></i><span>Создать заявку</span>', [
                    'class' => 'btn btn-primary tasks-tool-btn',
                    'onclick' => 'openCreateTaskModal()',
                    'title' => 'Новая заявка',
                ]) ?>
            <?php endif; ?>
            <?php if ($isAdmin): ?>
                <?= Html::button('<i class="fas fa-trash" aria-hidden="true"></i><span>Удалить</span>', [
                    'class' => 'btn btn-outline-danger tasks-tool-btn',
                    'id' => 'btnTasksBulkDelete',
                    'onclick' => 'bulkDeleteSelectedTasks()',
                    'disabled' => true,
                    'title' => 'Удалить выбранные заявки',
                ]) ?>
            <?php endif; ?>
            <?= Html::button('<i class="fas fa-arrows-rotate" aria-hidden="true"></i><span>Обновить</span>', [
                'class' => 'btn btn-outline-secondary tasks-tool-btn',
                'onclick' => 'refreshGrid()',
                'title' => 'Перезагрузить данные',
            ]) ?>
        </div>
    </div>

    <div class="tasks-grid-card">
        <div id="agGridTasksContainer" class="ag-theme-quartz"
             data-view-modal-url-template="<?= Html::encode(Url::to(['view-modal', 'id' => '__ID__'])) ?>"
             data-update-modal-url-template="<?= Html::encode(Url::to(['update-modal', 'id' => '__ID__'])) ?>">
            <div class="text-center tasks-grid-loading">
                <i class="fas fa-spinner fa-spin" aria-hidden="true"></i>
                <p>Загрузка таблицы заявок…</p>
            </div>
        </div>
    </div>
</div>

<div class="modal fade tasks-modal tasks-edit-modal" id="editTaskModal" tabindex="-1" aria-labelledby="editTaskModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable tasks-edit-modal__dialog">
        <div class="modal-content">
            <div class="modal-header tasks-create-modal__header">
                <div class="tasks-create-modal__header-text">
                    <h5 class="modal-title" id="editTaskModalLabel">Редактирование заявки</h5>
                    <p class="tasks-create-modal__lead mb-0">Измените описание, контакты или добавьте вложения</p>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Закрыть"></button>
            </div>
            <div class="modal-body tasks-create-modal__body" id="editTaskModalBody">
                <div class="tasks-create-modal__loading">
                    <i class="fas fa-spinner fa-spin" aria-hidden="true"></i>
                    <p>Загрузка формы…</p>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal fade tasks-modal tasks-create-modal" id="createTaskModal" tabindex="-1" aria-labelledby="createTaskModalLabel">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable tasks-create-modal__dialog">
        <div class="modal-content">
            <div class="modal-header tasks-create-modal__header">
                <div class="tasks-create-modal__header-text">
                    <h5 class="modal-title" id="createTaskModalLabel">Новая заявка</h5>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Закрыть"></button>
            </div>
            <div class="modal-body tasks-create-modal__body" id="createTaskModalBody">
                <div class="tasks-create-modal__loading">
                    <i class="fas fa-spinner fa-spin" aria-hidden="true"></i>
                    <p>Загрузка формы…</p>
                </div>
            </div>
        </div>
    </div>
</div>

<?= $this->render('_view_modal') ?>

<?= $this->render('_view_image_modal') ?>

<div class="modal fade tasks-modal preview-modal" id="previewModal" tabindex="-1" aria-labelledby="previewModalLabel">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="previewModalLabel">Предпросмотр файла</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Закрыть"></button>
            </div>
            <div class="modal-body" id="previewContent">
                <div class="text-center text-muted py-4">
                    <i class="fas fa-image fa-2x mb-2" aria-hidden="true"></i>
                    <p class="mb-0">Выберите вложение для предпросмотра</p>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Закрыть</button>
                <a href="#" class="btn btn-primary" id="downloadBtn" target="_blank" rel="noopener">
                    <i class="fas fa-download" aria-hidden="true"></i> Скачать
                </a>
            </div>
        </div>
    </div>
</div>
