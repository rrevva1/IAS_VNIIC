<?php

use app\assets\UserEquipmentCardsGridAsset;
use yii\helpers\Html;
use yii\helpers\Url;

UserEquipmentCardsGridAsset::register($this);

$this->title = 'Карточки пользователей';
$this->params['breadcrumbs'][] = $this->title;
?>
<div class="user-equipment-cards-index">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h1 class="mb-0"><?= Html::encode($this->title) ?></h1>
    </div>

    <form method="get" action="<?= Url::to(['user-equipment-cards/index']) ?>" class="card card-body mb-3">
        <input type="hidden" name="r" value="user-equipment-cards/index">
        <input type="hidden" name="tab" value="<?= Html::encode($tab) ?>">
        <div class="row g-2 align-items-end">
            <div class="col-md-6">
                <label class="form-label">Поиск пользователя</label>
                <input
                    type="text"
                    class="form-control"
                    name="q"
                    value="<?= Html::encode($q ?? '') ?>"
                    placeholder="ФИО, логин или email"
                >
            </div>
            <div class="col-md-3">
                <label class="form-label">Статус подписи</label>
                <select name="is_signed" class="form-select">
                    <option value="" <?= ($isSigned ?? '') === '' ? 'selected' : '' ?>>Все</option>
                    <option value="1" <?= ($isSigned ?? '') === '1' ? 'selected' : '' ?>>Подписана</option>
                    <option value="0" <?= ($isSigned ?? '') === '0' ? 'selected' : '' ?>>Не подписана</option>
                </select>
            </div>
            <div class="col-md-3 d-flex gap-2">
                <button type="submit" class="btn btn-primary">Найти</button>
                <a href="<?= Url::to(['user-equipment-cards/index', 'tab' => $tab]) ?>" class="btn btn-outline-secondary">Сброс</a>
            </div>
        </div>
    </form>

    <ul class="nav nav-tabs mb-3">
        <li class="nav-item">
            <a class="nav-link <?= $tab === 'all' ? 'active' : '' ?>" href="<?= Url::to(['user-equipment-cards/index', 'tab' => 'all', 'q' => ($q ?? ''), 'is_signed' => ($isSigned ?? '')]) ?>">Все карточки</a>
        </li>
        <li class="nav-item">
            <a class="nav-link <?= $tab === 'unsigned' ? 'active' : '' ?>" href="<?= Url::to(['user-equipment-cards/index', 'tab' => 'unsigned', 'q' => ($q ?? ''), 'is_signed' => ($isSigned ?? '')]) ?>">Неподписанные</a>
        </li>
    </ul>

    <div
        id="agGridUserEquipmentCardsContainer"
        class="ag-theme-quartz"
        style="width: 100%; height: calc(100vh - 320px); min-height: 480px;"
    >
        <div class="text-center p-4 text-muted">
            <span class="glyphicon glyphicon-refresh glyphicon-spin"></span>
            <p>Загрузка карточек...</p>
        </div>
    </div>
</div>

<?php
$this->registerJs(
    "window.userEquipmentCardsDataUrl = " . json_encode(Url::to(['user-equipment-cards/get-grid-data'])) . ";"
    . "window.userEquipmentCardsTab = " . json_encode((string) ($tab ?? 'all')) . ";"
    . "window.userEquipmentCardsSearch = " . json_encode((string) ($q ?? '')) . ";"
    . "window.userEquipmentCardsIsSigned = " . json_encode((string) ($isSigned ?? '')) . ";"
    . "window.userEquipmentCardsDefaultLimit = 20;"
    . "window.userEquipmentCardsCsrfParam = " . json_encode(Yii::$app->request->csrfParam) . ";"
    . "window.userEquipmentCardsCsrfToken = " . json_encode(Yii::$app->request->csrfToken) . ";",
    \yii\web\View::POS_HEAD
);
?>

