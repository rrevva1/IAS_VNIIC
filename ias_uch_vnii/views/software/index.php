<?php
/**
 * Список лицензий ПО (AG Grid).
 * @var yii\web\View $this
 */

use app\assets\SoftwareGridAsset;
use app\models\entities\License;
use yii\helpers\Html;
use yii\helpers\Url;

SoftwareGridAsset::register($this);

$defaultExpiringDays = License::EXPIRING_WARNING_DAYS;
$expiringDays = (string) Yii::$app->request->get('expiring_days', '');
$gridDataUrl = Url::to(array_merge(['software/get-grid-data'], array_filter([
    'expiring_days' => $expiringDays !== '' ? $expiringDays : null,
])));

$this->registerJs(
    'window.softwareExpiringDaysDefault = ' . (int) $defaultExpiringDays . ';',
    \yii\web\View::POS_HEAD
);

$this->title = 'Лицензии ПО';
$this->params['breadcrumbs'] = [];
?>
<div class="arm-page section-grid-page software-page">
    <header class="arm-page__header">
        <div class="arm-page__heading">
            <h1 class="arm-page__title"><?= Html::encode($this->title) ?></h1>
            <p class="arm-page__subtitle text-muted mb-0">Учёт закупленных лицензий на программное обеспечение</p>
        </div>
    </header>

    <div class="arm-command-bar software-command-bar" role="region" aria-label="Поиск и фильтры">
        <div class="arm-search software-command-bar__search">
            <label class="visually-hidden" for="softwareQuickFilter">Поиск по таблице</label>
            <i class="fas fa-search arm-search__icon" aria-hidden="true"></i>
            <input type="search"
                   id="softwareQuickFilter"
                   class="form-control arm-search__input js-section-quick-filter"
                   placeholder="Поиск по ПО, поставщику, технике…"
                   autocomplete="off">
            <button type="button"
                    class="arm-search__clear js-section-quick-filter-clear"
                    aria-label="Очистить поиск"
                    title="Очистить поиск"
                    hidden>×</button>
        </div>

        <div class="software-command-bar__filters" id="software-filter-form">
            <span class="software-command-bar__filters-label">Срок:</span>
            <div class="btn-group btn-group-sm software-command-bar__presets" role="group" aria-label="Фильтр по сроку действия">
                <button type="button"
                        class="btn btn-outline-secondary software-filter-preset<?= $expiringDays === '' ? ' active' : '' ?>"
                        data-expiring-days="">
                    Все
                </button>
                <button type="button"
                        class="btn btn-outline-secondary software-filter-preset<?= $expiringDays !== '' ? ' active' : '' ?>"
                        data-expiring-days="<?= (int) $defaultExpiringDays ?>">
                    Истекают
                </button>
            </div>
            <div class="software-command-bar__expiring">
                <label class="visually-hidden" for="software-filter-expiring">Истекают в течение (дней)</label>
                <span class="software-command-bar__expiring-text">в течение</span>
                <input type="number"
                       name="expiring_days"
                       id="software-filter-expiring"
                       class="form-control form-control-sm software-command-bar__expiring-input"
                       value="<?= Html::encode($expiringDays !== '' ? $expiringDays : (string) $defaultExpiringDays) ?>"
                       min="1"
                       max="3650"
                       inputmode="numeric"
                       <?= $expiringDays === '' ? 'disabled' : '' ?>>
                <span class="software-command-bar__expiring-text">дн.</span>
            </div>
        </div>

        <div class="arm-command-bar__tools">
            <?= Html::button('<i class="fas fa-plus" aria-hidden="true"></i><span class="arm-btn-label">Добавить</span>', [
                'class' => 'btn btn-primary arm-tool-btn',
                'type' => 'button',
                'data-software-license-create' => '',
                'title' => 'Добавить лицензию',
            ]) ?>
            <?= Html::button('<i class="fas fa-arrows-rotate" aria-hidden="true"></i><span class="arm-btn-label">Обновить</span>', [
                'class' => 'btn btn-outline-secondary arm-tool-btn js-section-grid-refresh',
                'type' => 'button',
                'data-grid-id' => 'agGridSoftwareContainer',
                'title' => 'Перезагрузить данные',
            ]) ?>
        </div>
    </div>

    <div class="arm-grid-card">
        <div
            id="agGridSoftwareContainer"
            class="ag-theme-quartz arm-grid-loading"
            data-base-url="<?= Html::encode(Url::to(['software/get-grid-data'])) ?>"
            data-url="<?= Html::encode($gridDataUrl) ?>"
            data-license-create-modal-url="<?= Html::encode(Url::to(['license-create-modal'])) ?>"
            data-license-update-modal-url-template="<?= Html::encode(Url::to(['license-update-modal', 'id' => '__ID__'])) ?>"
            data-license-delete-url-template="<?= Html::encode(Url::to(['license-delete', 'id' => '__ID__'])) ?>"
        >
            <div class="arm-grid-loading__inner">
                <i class="fas fa-circle-notch fa-spin" aria-hidden="true"></i>
                <p>Загрузка таблицы…</p>
            </div>
        </div>
    </div>
</div>

<?= $this->render('_license_modal', [
    'createTitle' => 'Добавить лицензию',
    'updateTitle' => 'Редактировать лицензию',
]) ?>
