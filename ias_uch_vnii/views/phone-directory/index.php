<?php

use app\assets\PhoneDirectoryAsset;
use yii\helpers\Html;
use yii\helpers\Url;

/** @var yii\web\View $this */
/** @var string|null $lastUpdated */
/** @var bool $isAdmin */
/** @var string $reportIssueUrl */

PhoneDirectoryAsset::register($this);

$this->title = 'Телефонный справочник';
$this->params['breadcrumbs'] = [];

$lastUpdatedLabel = '—';
if (!empty($lastUpdated)) {
    try {
        $lastUpdatedLabel = Yii::$app->formatter->asDatetime($lastUpdated, 'php:d.m.Y H:i');
    } catch (\Throwable $e) {
        $lastUpdatedLabel = (string) $lastUpdated;
    }
}
?>

<div class="users-page users-page--grid phone-directory-page">
    <header class="users-page__header">
        <div class="users-page__heading">
            <h1 class="users-page__title"><?= Html::encode($this->title) ?></h1>
            <p class="phone-directory-page__meta" id="phoneDirectoryLastUpdated">
                Актуальность данных:
                <time datetime="<?= Html::encode((string) $lastUpdated) ?>"><?= Html::encode($lastUpdatedLabel) ?></time>
            </p>
        </div>
    </header>

    <div class="users-command-bar" role="region" aria-label="Поиск и фильтры">
        <div class="users-search">
            <label class="visually-hidden" for="phoneDirectoryQuickFilter">Поиск по справочнику</label>
            <i class="fas fa-search users-search__icon" aria-hidden="true"></i>
            <input type="search" id="phoneDirectoryQuickFilter" class="form-control users-search__input"
                   placeholder="ФИО, отдел, кабинет, номер" autocomplete="off">
            <button type="button" class="users-search__clear" id="phoneDirectoryQuickFilterClear"
                    aria-label="Очистить поиск" title="Очистить" hidden>×</button>
        </div>

        <div class="users-command-bar__tabs" role="tablist" aria-label="Фильтр справочника">
            <ul class="nav users-role-tabs">
                <li class="nav-item">
                    <a class="nav-link users-role-tab active" href="#" data-pd-filter="all" role="tab" aria-selected="true">Все</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link users-role-tab" href="#" data-pd-filter="my_department" role="tab" aria-selected="false">Мой отдел</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link users-role-tab" href="#" data-pd-filter="with_phone" role="tab" aria-selected="false">Только с номером</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link users-role-tab" href="#" data-pd-filter="service" role="tab" aria-selected="false">Служебные</a>
                </li>
            </ul>
        </div>

        <div class="users-command-bar__tools">
            <?= Html::a(
                '<i class="fas fa-triangle-exclamation" aria-hidden="true"></i><span>Сообщить об ошибке</span>',
                $reportIssueUrl,
                [
                    'class' => 'btn btn-outline-secondary users-tool-btn',
                    'title' => 'Создать заявку на актуализацию справочника',
                    'encode' => false,
                ]
            ) ?>
            <?php if ($isAdmin): ?>
                <button type="button" class="btn btn-primary users-tool-btn" id="phoneDirectoryCreateBtn"
                        title="Добавить запись">
                    <i class="fas fa-plus" aria-hidden="true"></i><span>Добавить</span>
                </button>
                <button type="button" class="btn btn-outline-secondary users-tool-btn" id="phoneDirectorySyncBtn"
                        title="Синхронизировать из пользователей">
                    <i class="fas fa-users" aria-hidden="true"></i><span>Из users</span>
                </button>
            <?php endif; ?>
            <button type="button" class="btn btn-outline-secondary users-tool-btn"
                    onclick="if (window.refreshPhoneDirectoryGrid) { window.refreshPhoneDirectoryGrid(); }"
                    title="Обновить таблицу">
                <i class="fas fa-arrows-rotate" aria-hidden="true"></i><span>Обновить</span>
            </button>
        </div>
    </div>

    <div class="users-grid-card">
        <div id="agGridPhoneDirectoryContainer"
             class="ag-theme-quartz users-grid-loading"
             data-url="<?= Html::encode(Url::to(['phone-directory/get-grid-data'])) ?>"
             data-create-modal-url="<?= Html::encode(Url::to(['phone-directory/create-modal'])) ?>"
             data-update-modal-url-template="<?= Html::encode(Url::to(['phone-directory/update-modal', 'id' => '__ID__'])) ?>"
             data-delete-url="<?= Html::encode(Url::to(['phone-directory/delete'])) ?>"
             data-sync-url="<?= Html::encode(Url::to(['phone-directory/sync-from-users'])) ?>"
             data-is-admin="<?= $isAdmin ? '1' : '0' ?>">
            <div class="users-grid-loading__inner">
                <i class="fas fa-circle-notch fa-spin" aria-hidden="true"></i>
                <p>Загрузка таблицы…</p>
            </div>
        </div>
    </div>
</div>

<?php if ($isAdmin): ?>
<div class="modal fade" id="phoneDirectoryFormModal" tabindex="-1" aria-labelledby="phoneDirectoryFormModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header">
                <h2 class="modal-title fs-5" id="phoneDirectoryFormModalLabel">Запись справочника</h2>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Закрыть"></button>
            </div>
            <div class="modal-body" id="phoneDirectoryFormModalBody">
                <p class="text-muted mb-0">Загрузка…</p>
            </div>
        </div>
    </div>
</div>
<?php endif; ?>
