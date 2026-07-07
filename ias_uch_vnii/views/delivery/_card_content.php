<?php
/**
 * Карточка поставки (модальное окно, стиль как «Учёт ТС»).
 *
 * @var yii\web\View $this
 * @var app\models\entities\EquipmentDelivery $model
 * @var app\models\entities\EquipmentDeliveryLine[] $lines
 * @var array $equipmentTypes
 * @var string[] $supplierNames
 * @var int $lineId
 * @var array $stats
 * @var bool $isDraft
 * @var bool $canEditHeader
 * @var array<int, array<string, mixed>> $attachments
 * @var bool $canEditAttachments
 */

use app\models\entities\EquipmentDelivery;
use yii\helpers\Html;
use yii\helpers\Url;
use yii\widgets\ActiveForm;

$isDraft = $model->isDraft();
$canEditHeader = $isDraft || $model->status === EquipmentDelivery::STATUS_POSTED;

$statusBadgeMap = [
    EquipmentDelivery::STATUS_POSTED => 'arm-view-status--in-use',
    EquipmentDelivery::STATUS_CLOSED => 'arm-view-status--archived',
    EquipmentDelivery::STATUS_DRAFT => 'arm-view-status--stock',
];
$statusBadgeClass = $statusBadgeMap[$model->status] ?? 'arm-view-status--stock';

?>
<div class="arm-form arm-form--modal">
    <div class="delivery-card-content arm-view arm-form-create"
         data-delivery-id="<?= (int) $model->id ?>"
         data-delivery-name="<?= Html::encode($model->name) ?>"
         data-status-label="<?= Html::encode($model->getStatusLabel()) ?>"
         data-is-draft="<?= $isDraft ? '1' : '0' ?>"
         data-can-edit-attachments="<?= ($canEditAttachments ?? $model->canEditAttachments()) ? '1' : '0' ?>"
         data-delivery-date="<?= Html::encode($model->delivery_date) ?>"
         data-line-id="<?= (int) $lineId ?>">

        <div id="deliveryCardHeaderSlot">
            <header class="arm-view__header">
                <div class="arm-view__header-layout">
                    <div class="arm-view__header-icon" aria-hidden="true">
                        <i class="fas fa-truck"></i>
                    </div>
                    <div class="arm-view__header-content">
                        <div class="arm-view__header-top">
                            <span class="arm-view__type">Поставка техники</span>
                            <div class="arm-view__badges">
                                <span class="arm-view-badge-status <?= Html::encode($statusBadgeClass) ?>">
                                    <?= Html::encode($model->getStatusLabel()) ?>
                                </span>
                            </div>
                        </div>
                        <h1 class="arm-view__title"><?= Html::encode($model->name) ?></h1>
                    </div>
                </div>
            </header>
        </div>

        <div class="arm-view__actions" id="deliveryCardActions">
            <?= Html::button('<i class="fas fa-xmark" aria-hidden="true"></i> Закрыть', [
                'class' => 'btn arm-tool-btn arm-view-btn arm-view-btn--close',
                'type' => 'button',
                'data-bs-dismiss' => 'modal',
            ]) ?>
            <?= Html::a('<i class="fas fa-file-export" aria-hidden="true"></i> Экспорт CSV', ['export-units', 'id' => $model->id], [
                'class' => 'btn arm-tool-btn arm-view-btn arm-view-btn--close',
                'id' => 'deliveryCardExportBtn',
                'target' => '_blank',
                'rel' => 'noopener',
            ]) ?>
            <?php if ($isDraft): ?>
                <?= Html::button('<i class="fas fa-trash" aria-hidden="true"></i> Удалить', [
                    'class' => 'btn arm-tool-btn arm-view-btn arm-view-btn--archive',
                    'type' => 'button',
                    'id' => 'deliveryCardDeleteBtn',
                ]) ?>
                <?= Html::button('<i class="fas fa-check-double" aria-hidden="true"></i> Провести', [
                    'class' => 'btn arm-tool-btn arm-view-btn arm-view-btn--edit',
                    'type' => 'button',
                    'id' => 'deliveryCardPostBtn',
                ]) ?>
            <?php endif; ?>
            <?= Html::button('<i class="fas fa-save" aria-hidden="true"></i> Сохранить', [
                'class' => 'btn arm-tool-btn arm-view-btn arm-view-btn--edit',
                'type' => 'submit',
                'form' => 'delivery-header-form',
                'id' => 'deliveryCardSaveHeaderBtn',
            ]) ?>
        </div>

        <?php $form = ActiveForm::begin([
            'id' => 'delivery-header-form',
            'action' => Url::to(['save-header', 'id' => $model->id]),
            'options' => ['class' => 'delivery-header-form'],
            'fieldConfig' => [
                'options' => ['class' => 'arm-form-create__field'],
                'labelOptions' => ['class' => 'form-label'],
            ],
            'scrollToError' => false,
        ]); ?>

        <div class="row g-3 arm-form-create__cards-row delivery-card-top-row">
            <div class="col-lg-7">
                <?= $this->render('_form_header', [
                    'model' => $model,
                    'supplierNames' => $supplierNames,
                    'readOnly' => !$canEditHeader,
                    'form' => $form,
                    'attachments' => $attachments ?? [],
                    'canEditAttachments' => $canEditAttachments ?? $model->canEditAttachments(),
                ]) ?>
            </div>
            <div class="col-lg-5">
                <?= $this->render('_card_lines', [
                    'lines' => $lines,
                    'lineId' => $lineId,
                    'isDraft' => $isDraft,
                ]) ?>
            </div>
        </div>

        <section class="arm-view-card arm-form-create__card delivery-section-units-wrap" aria-labelledby="delivery-section-units">
            <div class="delivery-view-card__head delivery-units-card__toolbar">
                <div class="delivery-units-card__heading">
                    <h2 id="delivery-section-units" class="arm-view-card__title">Техника</h2>
                    <p id="deliveryUnitsFilterHint" class="delivery-units-filter-hint small text-muted mb-0" hidden></p>
                </div>
                <div class="delivery-units-card__tools">
                    <input type="search" class="form-control form-control-sm" id="deliveryUnitsSearch"
                           placeholder="Поиск" autocomplete="off">
                    <?= Html::button('Серийные', [
                        'class' => 'btn btn-outline-primary btn-sm arm-tool-btn',
                        'id' => 'deliveryBulkSerialBtn',
                        'type' => 'button',
                    ]) ?>
                    <?= Html::button('Инв. №', [
                        'class' => 'btn btn-outline-primary btn-sm arm-tool-btn',
                        'id' => 'deliveryBulkInventoryBtn',
                        'type' => 'button',
                    ]) ?>
                    <?= Html::button('Пары', [
                        'class' => 'btn btn-outline-secondary btn-sm arm-tool-btn',
                        'id' => 'deliveryBulkPairsBtn',
                        'type' => 'button',
                        'title' => 'Серийный и инв. № в строке через табуляцию (вставка из Excel)',
                    ]) ?>
                </div>
            </div>
            <div class="arm-view-card__body delivery-units-card__body p-0">
                <div class="arm-grid-card delivery-units-grid-wrap">
                    <div id="agGridDeliveryUnits" class="ag-theme-quartz delivery-units-grid"></div>
                </div>
            </div>
        </section>

        <?= $this->render('_form_note', [
            'model' => $model,
            'readOnly' => !$canEditHeader,
            'form' => $form,
        ]) ?>

        <?php ActiveForm::end(); ?>
    </div>
</div>
