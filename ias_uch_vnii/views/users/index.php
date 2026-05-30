<?php

use app\assets\UsersGridAsset;
use yii\helpers\Html;
use yii\helpers\Url;

/** @var yii\web\View $this */
/** @var app\models\dictionaries\Roles[] $roles */

UsersGridAsset::register($this);

$this->title = 'Пользователи';
$this->params['breadcrumbs'] = [];

$roles = $roles ?? [];
$roleFilter = Yii::$app->request->get('role_id', '');
?>

<div class="users-page users-page--grid">
    <header class="users-page__header">
        <div class="users-page__heading">
            <h1 class="users-page__title"><?= Html::encode($this->title) ?></h1>
        </div>
    </header>

    <div class="users-command-bar" role="region" aria-label="Поиск и действия">
        <div class="users-search">
            <label class="visually-hidden" for="usersQuickFilter">Поиск по таблице</label>
            <i class="fas fa-search users-search__icon" aria-hidden="true"></i>
            <input type="search" id="usersQuickFilter" class="form-control users-search__input"
                   placeholder="Поиск" autocomplete="off">
            <button type="button" class="users-search__clear" id="usersQuickFilterClear"
                    aria-label="Очистить поиск" title="Очистить" hidden>×</button>
        </div>

        <div class="users-command-bar__tabs" role="tablist" aria-label="Фильтр по роли">
            <ul class="nav users-role-tabs">
                <li class="nav-item">
                    <a class="nav-link users-role-tab<?= $roleFilter === '' ? ' active' : '' ?>"
                       href="#" data-role-id="" role="tab"
                       aria-selected="<?= $roleFilter === '' ? 'true' : 'false' ?>">Все</a>
                </li>
                <?php foreach ($roles as $role): ?>
                <li class="nav-item">
                    <a class="nav-link users-role-tab<?= (string) $roleFilter === (string) $role->id ? ' active' : '' ?>"
                       href="#" data-role-id="<?= (int) $role->id ?>" role="tab"
                       aria-selected="<?= (string) $roleFilter === (string) $role->id ? 'true' : 'false' ?>">
                        <?= Html::encode($role->role_name) ?>
                    </a>
                </li>
                <?php endforeach; ?>
            </ul>
        </div>

        <div class="users-command-bar__tools">
            <button type="button" class="btn btn-primary users-tool-btn" data-user-create-open="1"
                    title="Добавить пользователя"
                    onclick="if (window.openCreateUserModal) { window.openCreateUserModal(); } return false;">
                <i class="fas fa-plus" aria-hidden="true"></i><span>Добавить</span>
            </button>
            <button type="button" class="btn btn-outline-secondary users-tool-btn"
                    onclick="refreshUsersGrid()" title="Обновить таблицу">
                <i class="fas fa-arrows-rotate" aria-hidden="true"></i><span>Обновить</span>
            </button>
        </div>
    </div>

    <div class="users-grid-card">
        <div id="agGridUsersContainer"
             class="ag-theme-quartz users-grid-loading"
             data-url="<?= Html::encode(Url::to(['users/get-grid-data'])) ?>"
             data-create-modal-url="<?= Html::encode(Url::to(['users/create-modal'])) ?>"
             data-view-url="<?= Html::encode(Url::to(['users/view'])) ?>"
             data-view-modal-url-template="<?= Html::encode(Url::to(['users/view-modal', 'id' => '__ID__'])) ?>"
             data-update-url="<?= Html::encode(Url::to(['users/update'])) ?>"
             data-update-modal-url-template="<?= Html::encode(Url::to(['users/update-modal', 'id' => '__ID__'])) ?>"
             data-delete-url="<?= Html::encode(Url::to(['users/delete'])) ?>">
            <div class="users-grid-loading__inner">
                <i class="fas fa-circle-notch fa-spin" aria-hidden="true"></i>
                <p>Загрузка таблицы…</p>
            </div>
        </div>
    </div>
</div>

<?= $this->render('_view_modal') ?>

<div class="modal fade users-modal users-create-modal" id="userFormModal" tabindex="-1"
     aria-labelledby="userFormModalLabel" aria-hidden="true"
     data-bs-backdrop="true" data-bs-keyboard="true">
    <div class="modal-dialog modal-lg modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header users-create-modal__header">
                <div>
                    <h5 class="modal-title" id="userFormModalLabel">Новый пользователь</h5>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Закрыть"></button>
            </div>
            <div class="modal-body users-create-modal__body" id="userFormModalBody">
                <div class="users-grid-loading">
                    <i class="fas fa-spinner fa-spin" aria-hidden="true"></i>
                    <p>Загрузка формы…</p>
                </div>
            </div>
        </div>
    </div>
</div>

<?php
$this->registerJs(
    'window.agGridUsersViewModalUrlTemplate = ' . json_encode(Url::to(['users/view-modal', 'id' => '__ID__'])) . ';' .
    'window.agGridUsersUpdateModalUrlTemplate = ' . json_encode(Url::to(['users/update-modal', 'id' => '__ID__'])) . ';',
    \yii\web\View::POS_HEAD
);

$this->registerJs(<<<'JS'
document.addEventListener('DOMContentLoaded', function() {
    if (!document.querySelector('.modal.show')) {
        document.querySelectorAll('.modal-backdrop').forEach(function(el) { el.remove(); });
        document.body.classList.remove('modal-open');
    }
    document.querySelectorAll('[data-user-create-open]').forEach(function(btn) {
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            if (typeof window.openCreateUserModal === 'function') {
                window.openCreateUserModal();
            }
        });
    });
});
JS
, \yii\web\View::POS_END);
?>
