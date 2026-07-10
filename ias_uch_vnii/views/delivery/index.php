<?php
/**
 * Поставки — список (AG Grid), как «Учёт ТС»; карточка и создание в модальных окнах.
 *
 * @var yii\web\View $this
 * @var string $openDeliveryId
 * @var array<string, string> $equipmentTypes
 * @var array<int, string> $warehouses
 */

use app\assets\DeliveryPageAsset;
use app\models\entities\EquipmentDelivery;
use yii\helpers\Html;
use yii\helpers\Url;

DeliveryPageAsset::register($this);

$this->title = 'Поставки';
$this->params['breadcrumbs'] = [];

$statusTabs = [
    '' => 'Все',
    EquipmentDelivery::STATUS_DRAFT => 'Черновики',
    EquipmentDelivery::STATUS_POSTED => 'Проведённые',
];
?>
<div class="arm-page delivery-page">
    <header class="arm-page__header">
        <div class="arm-page__heading">
            <h1 class="arm-page__title"><?= Html::encode($this->title) ?></h1>
        </div>
    </header>

    <div class="arm-command-bar" role="region" aria-label="Фильтры и действия с таблицей">
        <div class="arm-search">
            <label class="visually-hidden" for="deliveryQuickFilter">Поиск по таблице</label>
            <i class="fas fa-search arm-search__icon" aria-hidden="true"></i>
            <input type="search" id="deliveryQuickFilter" class="form-control arm-search__input"
                   placeholder="Поиск" autocomplete="off">
            <button type="button" class="arm-search__clear" id="deliveryQuickFilterClear"
                    aria-label="Очистить поиск" title="Очистить поиск" hidden>×</button>
        </div>

        <div class="arm-command-bar__tabs" role="tablist" aria-label="Статус поставки">
            <ul class="nav nav-tabs arm-type-tabs" id="deliveryStatusTabs">
                <?php $first = true; foreach ($statusTabs as $statusKey => $label): ?>
                <li class="nav-item">
                    <a class="nav-link delivery-status-tab<?= $first ? ' active' : '' ?>" href="#" role="tab"
                       data-status="<?= Html::encode($statusKey) ?>"
                       aria-selected="<?= $first ? 'true' : 'false' ?>"><?= Html::encode($label) ?></a>
                </li>
                <?php $first = false; endforeach; ?>
            </ul>
        </div>

        <div class="arm-command-bar__tools">
            <?= Html::button('<i class="fas fa-plus" aria-hidden="true"></i><span class="arm-btn-label">Добавить</span>', [
                'class' => 'btn btn-primary arm-tool-btn',
                'type' => 'button',
                'data-delivery-create-open' => '1',
                'title' => 'Новая поставка',
            ]) ?>
            <?= Html::button('<i class="fas fa-arrows-rotate" aria-hidden="true"></i><span class="arm-btn-label">Обновить</span>', [
                'class' => 'btn btn-outline-secondary arm-tool-btn',
                'type' => 'button',
                'onclick' => 'refreshDeliveryGrid()',
                'title' => 'Перезагрузить данные',
            ]) ?>
        </div>
    </div>

    <div class="arm-grid-card">
        <div id="agGridDeliveryContainer" class="ag-theme-quartz arm-grid-loading"
             data-base-url="<?= Html::encode(Url::to(['delivery/get-grid-data'])) ?>"
             data-create-draft-url="<?= Html::encode(Url::to(['delivery/create-draft'])) ?>"
             data-card-modal-url-template="<?= Html::encode(Url::to(['delivery/card-modal', 'id' => '__ID__'])) ?>"
             data-open-delivery-id="<?= Html::encode($openDeliveryId) ?>">
            <div class="arm-grid-loading__inner">
                <i class="fas fa-circle-notch fa-spin" aria-hidden="true"></i>
                <p>Загрузка таблицы…</p>
            </div>
        </div>
    </div>
</div>

<?= $this->render('//arm/_form_datalists', [
    'cpuModels' => $cpuModels ?? [],
    'ramModels' => $ramModels ?? [],
    'osModels' => $osModels ?? [],
    'diskModels' => $diskModels ?? [],
    'ipAddresses' => $ipAddresses ?? [],
    'supplierNames' => $supplierNames ?? [],
    'currentSupplier' => $currentSupplier ?? '',
    'locationNames' => $locationNames ?? [],
    'currentLocation' => $currentLocation ?? '',
    'upsBatteryModels' => $upsBatteryModels ?? [],
    'inventoryNumbers' => $inventoryNumbers ?? [],
    'currentInventoryNumber' => $currentInventoryNumber ?? '',
    'equipmentNames' => $equipmentNames ?? [],
    'currentEquipmentName' => $currentEquipmentName ?? '',
    'screenDiagonalValues' => $screenDiagonalValues ?? [],
    'currentScreenDiagonal' => $currentScreenDiagonal ?? '',
]) ?>
<?= $this->render('_form_scripts', [
    'chars' => $chars ?? [],
    'orgTech' => $orgTech ?? [],
    'armFormFieldTemplates' => $armFormFieldTemplates ?? [],
    'cpuModels' => $cpuModels ?? [],
    'ramModels' => $ramModels ?? [],
    'osModels' => $osModels ?? [],
    'diskModels' => $diskModels ?? [],
]) ?>
<?= $this->render('_card_modal') ?>
<?= $this->render('_line_modal', [
    'equipmentTypes' => $equipmentTypes ?? [],
    'warehouses' => $warehouses ?? [],
]) ?>
<?= $this->render('_bulk_modal') ?>
