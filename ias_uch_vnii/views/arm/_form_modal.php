<?php

use yii\helpers\Html;
use yii\widgets\ActiveForm;

/** @var yii\web\View $this */
/** @var app\models\entities\Equipment $model */
/** @var array $users */
/** @var array $locations */
/** @var array $statuses */
/** @var array $equipmentTypes */
/** @var string[] $cpuModels */
/** @var string[] $ramModels */
/** @var string[] $osModels */
/** @var string[] $diskModels */
/** @var string[] $supplierNames */
/** @var string[] $ipAddresses */
/** @var string[] $upsBatteryModels */
/** @var string $currentSupplier */
/** @var string[] $locationNames */
/** @var string $currentLocation */
/** @var string[] $inventoryNumbers */
/** @var string $currentInventoryNumber */
/** @var string[] $equipmentNames */
/** @var string $currentEquipmentName */
/** @var string[] $screenDiagonalValues */
/** @var string $currentScreenDiagonal */

$formPlaceholders = require __DIR__ . '/_form_create_placeholders.php';

$fieldOptions = [
    'options' => ['class' => 'arm-form-create__field'],
    'labelOptions' => ['class' => 'form-label'],
    'inputOptions' => ['class' => 'form-control'],
];
$selectFieldOptions = $fieldOptions;
$selectFieldOptions['inputOptions'] = ['class' => 'form-select'];
?>

<div class="arm-form arm-form--modal">
    <?php $form = ActiveForm::begin([
        'id' => 'arm-create-form',
        'options' => ['class' => 'arm-view arm-form-create'],
        'fieldConfig' => $fieldOptions,
        'scrollToError' => false,
    ]); ?>

    <?= $this->render('_form_datalists', [
        'cpuModels' => $cpuModels,
        'ramModels' => $ramModels,
        'osModels' => $osModels,
        'diskModels' => $diskModels,
        'ipAddresses' => $ipAddresses,
        'supplierNames' => $supplierNames,
        'currentSupplier' => $currentSupplier,
        'locationNames' => $locationNames,
        'currentLocation' => $currentLocation,
        'upsBatteryModels' => $upsBatteryModels,
        'inventoryNumbers' => $inventoryNumbers ?? [],
        'currentInventoryNumber' => $currentInventoryNumber ?? '',
        'equipmentNames' => $equipmentNames ?? [],
        'currentEquipmentName' => $currentEquipmentName ?? '',
        'screenDiagonalValues' => $screenDiagonalValues ?? [],
        'currentScreenDiagonal' => $currentScreenDiagonal ?? '',
    ]) ?>

    <div class="row g-3 arm-form-create__primary-row">
        <div class="col-md-6 arm-form-create__primary-col">
            <section class="arm-view-card arm-form-create__card" aria-labelledby="arm-create-section-main">
                <h2 id="arm-create-section-main" class="arm-view-card__title">Основные сведения</h2>
                <div class="arm-view-card__body arm-form-create__card-fields">
                    <?= $form->field($model, 'name', [
                        'options' => ['class' => 'arm-form-create__field arm-form-create__field--wide'],
                    ])->textInput([
                        'maxlength' => true,
                        'list' => 'arm-name-datalist',
                        'autocomplete' => 'off',
                        'placeholder' => $formPlaceholders['name'],
                        'class' => 'form-control js-equipment-name-datalist',
                        'id' => 'arm-create-name',
                    ]) ?>
                    <div class="row g-3 arm-form-create__identity-row">
                        <div class="col-sm-6">
                            <?= $form->field($model, 'inventory_number', ['options' => ['class' => 'arm-form-create__field mb-0']])
                                ->textInput([
                                    'maxlength' => true,
                                    'list' => 'arm-inventory-datalist',
                                    'autocomplete' => 'off',
                                    'class' => 'form-control js-inventory-datalist',
                                    'placeholder' => $formPlaceholders['inventory_number'],
                                ]) ?>
                        </div>
                        <div class="col-sm-6">
                            <?= $form->field($model, 'serial_number', ['options' => ['class' => 'arm-form-create__field mb-0']])
                                ->textInput([
                                    'maxlength' => true,
                                    'placeholder' => $formPlaceholders['serial_number'],
                                ]) ?>
                        </div>
                        <div class="col-12">
                            <?= $form->field($model, 'equipment_type', [
                                'options' => ['class' => 'arm-form-create__field mb-0'],
                                'inputOptions' => ['class' => 'form-select'],
                            ])->dropDownList($equipmentTypes, [
                                'prompt' => $formPlaceholders['equipment_type_prompt'],
                                'id' => 'equipment-type-select',
                                'required' => true,
                            ]) ?>
                        </div>
                    </div>
                </div>
            </section>
        </div>

        <div class="col-md-6 arm-form-create__primary-col">
            <section class="arm-view-card arm-form-create__card" aria-labelledby="arm-create-section-assignment">
                <h2 id="arm-create-section-assignment" class="arm-view-card__title">Закрепление</h2>
                <div class="arm-view-card__body arm-form-create__card-fields">
                    <?= $form->field($model, 'responsible_user_id', [
                        'options' => ['class' => 'arm-form-create__field'],
                        'inputOptions' => ['class' => 'form-select js-user-select-search'],
                    ])->dropDownList($users, [
                        'prompt' => $formPlaceholders['responsible_user'],
                        'data-placeholder' => $formPlaceholders['responsible_user'],
                    ]) ?>
                    <?= $form->field($model, 'location_name', [
                        'options' => ['class' => 'arm-form-create__field'],
                    ])->textInput([
                        'maxlength' => true,
                        'list' => 'arm-location-datalist',
                        'autocomplete' => 'off',
                        'id' => 'equipment-location-name',
                        'class' => 'form-control js-location-datalist',
                        'placeholder' => $formPlaceholders['location_name'],
                    ]) ?>
                    <?= $form->field($model, 'status_id', [
                        'options' => ['class' => 'arm-form-create__field mb-0'],
                        'inputOptions' => ['class' => 'form-select js-user-select-search'],
                    ])->dropDownList($statuses ?? [], [
                        'prompt' => $formPlaceholders['status'],
                        'data-placeholder' => $formPlaceholders['status'],
                    ]) ?>
                </div>
            </section>
        </div>
    </div>

    <section id="dynamic-fields-block" class="arm-view-card arm-form-create__card arm-form-create__config-section arm-form-section--chars d-none" aria-labelledby="arm-create-section-config">
        <h2 id="arm-create-section-config" class="arm-view-card__title">Конфигурация</h2>
        <div class="arm-view-card__body arm-form-create__card-fields">
            <div id="dynamic-fields-content" class="arm-form-create__config-fields"></div>
        </div>
    </section>

    <div class="row g-3 arm-form-create__cards-row">
        <div class="col-md-6">
        <section class="arm-view-card arm-form-create__card" aria-labelledby="arm-create-section-purchase">
            <h2 id="arm-create-section-purchase" class="arm-view-card__title">Закупка и гарантия</h2>
            <div class="arm-view-card__body arm-form-create__card-fields">
                <?= $form->field($model, 'supplier', ['options' => ['class' => 'arm-form-create__field arm-form-create__field--supplier']])
                    ->textInput([
                        'maxlength' => true,
                        'list' => 'arm-supplier-datalist',
                        'autocomplete' => 'off',
                        'placeholder' => $formPlaceholders['supplier'],
                    ]) ?>
                <div class="row g-3 arm-form-create__dates-row">
                    <div class="col-md-6">
                        <?= $form->field($model, 'purchase_date', ['options' => ['class' => 'arm-form-create__field mb-0']])
                            ->label('Дата закупки')
                            ->input('date', [
                                'id' => 'equipment-purchase-date',
                                'class' => 'form-control js-warranty-base-date',
                            ]) ?>
                    </div>
                    <div class="col-md-6">
                        <?= $form->field($model, 'warranty_years', ['options' => ['class' => 'arm-form-create__field mb-0']])
                            ->label('Гарантия, лет')
                            ->input('number', [
                                'id' => 'equipment-warranty-years',
                                'class' => 'form-control',
                                'min' => 0,
                                'max' => 50,
                                'step' => '0.5',
                                'placeholder' => $formPlaceholders['warranty_years'],
                            ]) ?>
                    </div>
                </div>
            </div>
        </section>
        </div>

        <div class="col-md-6">
        <section id="arm-form-description-section" class="arm-view-card arm-form-create__card" aria-labelledby="arm-create-section-note">
            <h2 id="arm-create-section-note" class="arm-view-card__title">Примечание</h2>
            <div class="arm-view-card__body arm-form-create__card-fields">
                <?= $form->field($model, 'description', ['options' => ['class' => 'arm-form-create__field mb-0']])
                    ->textarea([
                        'rows' => 4,
                        'placeholder' => $formPlaceholders['description'],
                        'class' => 'form-control',
                    ]) ?>
            </div>
        </section>
        </div>
    </div>

    <?php ActiveForm::end(); ?>
</div>
