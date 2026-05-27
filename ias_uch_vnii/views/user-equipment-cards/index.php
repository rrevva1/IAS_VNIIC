<?php

use app\assets\UserEquipmentCardsGridAsset;
use yii\helpers\Html;
use yii\helpers\Url;

/** @var yii\web\View $this */
/** @var string $tab */
/** @var string|null $q */

UserEquipmentCardsGridAsset::register($this);

$tab = $tab ?? 'all';
$q = $q ?? '';

$this->title = 'Карточки пользователей';
$this->params['breadcrumbs'] = [];
?>
<div class="arm-page user-equipment-cards-page">
    <header class="arm-page__header">
        <div class="arm-page__heading">
            <h1 class="arm-page__title"><?= Html::encode($this->title) ?></h1>
        </div>
    </header>

    <div class="arm-command-bar" role="region" aria-label="Поиск и фильтры">
        <div class="arm-search">
            <label class="visually-hidden" for="uecQuickFilter">Поиск по таблице</label>
            <i class="fas fa-search arm-search__icon" aria-hidden="true"></i>
            <input type="search" id="uecQuickFilter" class="form-control arm-search__input"
                   placeholder="Поиск" autocomplete="off"
                   value="<?= Html::encode($q) ?>">
            <button type="button" class="arm-search__clear" id="uecQuickFilterClear"
                    aria-label="Очистить поиск" title="Очистить поиск"<?= $q === '' ? ' hidden' : '' ?>>×</button>
        </div>

        <div class="arm-command-bar__tabs" role="tablist" aria-label="Фильтр карточек">
            <ul class="nav nav-tabs arm-type-tabs">
                <li class="nav-item">
                    <a class="nav-link arm-type-tab uec-type-tab<?= $tab === 'all' ? ' active' : '' ?>"
                       href="#" role="tab" data-tab="all"
                       aria-selected="<?= $tab === 'all' ? 'true' : 'false' ?>">Все карточки</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link arm-type-tab uec-type-tab<?= $tab === 'unsigned' ? ' active' : '' ?>"
                       href="#" role="tab" data-tab="unsigned"
                       aria-selected="<?= $tab === 'unsigned' ? 'true' : 'false' ?>">Неподписанные</a>
                </li>
            </ul>
        </div>

        <div class="arm-command-bar__tools">
            <?= Html::button('<i class="fas fa-arrows-rotate" aria-hidden="true"></i><span class="arm-btn-label">Обновить</span>', [
                'class' => 'btn btn-outline-secondary arm-tool-btn',
                'type' => 'button',
                'id' => 'uecRefreshGrid',
                'title' => 'Перезагрузить данные',
            ]) ?>
        </div>
    </div>

    <div class="arm-grid-card">
        <div id="agGridUserEquipmentCardsContainer" class="ag-theme-quartz arm-grid-loading">
            <div class="arm-grid-loading__inner">
                <i class="fas fa-circle-notch fa-spin" aria-hidden="true"></i>
                <p>Загрузка таблицы…</p>
            </div>
        </div>
    </div>
</div>

<?php
$this->registerJs(
    'window.userEquipmentCardsDataUrl = ' . json_encode(Url::to(['user-equipment-cards/get-grid-data'])) . ';'
    . 'window.userEquipmentCardsTab = ' . json_encode((string) $tab) . ';'
    . 'window.userEquipmentCardsSearch = ' . json_encode((string) $q) . ';'
    . 'window.userEquipmentCardsDefaultLimit = 20;'
    . 'window.userEquipmentCardsCsrfParam = ' . json_encode(Yii::$app->request->csrfParam) . ';'
    . 'window.userEquipmentCardsCsrfToken = ' . json_encode(Yii::$app->request->csrfToken) . ';',
    \yii\web\View::POS_HEAD
);
?>
