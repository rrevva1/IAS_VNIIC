<?php

use yii\helpers\Html;
use yii\helpers\Url;
use yii\widgets\ActiveForm;

/** @var app\models\entities\License $model */
/** @var string $modalTitle */
/** @var string $softwareName */
/** @var string[] $softwareNames */
/** @var array<int, array<string, mixed>> $equipmentRows */
/** @var int[] $selectedEquipmentIds */
/** @var string[] $supplierNames */
/** @var array<int, array<string, mixed>> $attachments */

$softwareName = $softwareName ?? '';
$softwareNames = $softwareNames ?? [];
$equipmentRows = $equipmentRows ?? [];
$selectedEquipmentIds = $selectedEquipmentIds ?? [];
$supplierNames = $supplierNames ?? [];
$attachments = $attachments ?? [];
$isUpdate = !$model->isNewRecord;
$isPerpetual = $model->isPerpetual();
$formAction = $isUpdate
    ? Url::to(['license-update-modal', 'id' => $model->id])
    : Url::to(['license-create-modal']);

$fieldOptions = [
    'options' => ['class' => 'arm-form-create__field'],
    'labelOptions' => ['class' => 'form-label'],
    'inputOptions' => ['class' => 'form-control'],
];
?>

<div class="arm-form arm-form--modal"
     <?php if ($isUpdate): ?>data-license-id="<?= (int) $model->id ?>"<?php endif; ?>>
    <?php $form = ActiveForm::begin([
        'id' => 'software-license-form',
        'action' => $formAction,
        'options' => [
            'class' => 'arm-view arm-form-create software-license-form',
            'enctype' => 'multipart/form-data',
            'data-license-id' => $isUpdate ? (int) $model->id : '',
        ],
        'fieldConfig' => $fieldOptions,
        'scrollToError' => false,
    ]); ?>

    <datalist id="software-license-name-datalist">
        <?php foreach ($softwareNames as $name): ?>
            <option value="<?= Html::encode($name) ?>"></option>
        <?php endforeach; ?>
    </datalist>

    <datalist id="software-license-supplier-datalist">
        <?php foreach ($supplierNames as $supplierName): ?>
            <option value="<?= Html::encode($supplierName) ?>"></option>
        <?php endforeach; ?>
    </datalist>

    <section class="arm-view-card arm-form-create__card software-license-primary-card">
        <div class="arm-view-card__body software-license-primary-grid">
            <h2 id="license-create-section-software" class="software-license-primary-grid__title">Программное обеспечение</h2>
            <h2 id="license-create-section-validity" class="software-license-primary-grid__title">Срок действия</h2>

            <div class="arm-form-create__field software-license-primary-grid__cell">
                <label class="form-label" for="license-software-name">Наименование ПО</label>
                <input type="text"
                       class="form-control"
                       id="license-software-name"
                       name="software_name"
                       value="<?= Html::encode($softwareName) ?>"
                       list="software-license-name-datalist"
                       autocomplete="off"
                       maxlength="200"
                       required
                       placeholder="Например: Microsoft Office">
            </div>
            <div class="software-license-primary-grid__cell">
                <?= $form->field($model, 'valid_from', [
                    'options' => ['class' => 'arm-form-create__field mb-0'],
                ])->input('date') ?>
            </div>

            <div class="software-license-primary-grid__cell">
                <?= $form->field($model, 'seats', [
                    'options' => ['class' => 'arm-form-create__field mb-0'],
                ])->input('number', [
                    'min' => 1,
                    'max' => 100000,
                    'step' => 1,
                    'placeholder' => '1',
                ])->label('Количество лицензий') ?>
            </div>
            <div class="software-license-primary-grid__cell">
                <?= $form->field($model, 'validity_years', [
                    'options' => [
                        'class' => 'arm-form-create__field mb-0 software-license-form__validity-years'
                            . ($isPerpetual ? ' software-license-form__validity-years--disabled text-muted' : ''),
                    ],
                ])->input('number', [
                    'min' => 0.5,
                    'max' => 100,
                    'step' => 0.5,
                    'placeholder' => 'Например: 1',
                    'disabled' => $isPerpetual,
                    'value' => $model->validity_years === null
                        ? ''
                        : rtrim(rtrim(number_format((float) $model->validity_years, 1, '.', ''), '0'), '.'),
                ]) ?>
            </div>

            <div class="software-license-primary-grid__spacer" aria-hidden="true"></div>
            <div class="software-license-primary-grid__cell">
                <?= $form->field($model, 'is_perpetual', [
                    'options' => ['class' => 'mb-0 form-check software-license-form__perpetual'],
                    'template' => "{input}\n{label}\n{hint}\n{error}",
                ])->checkbox([
                    'class' => 'form-check-input',
                    'label' => false,
                ], false)->label('Бессрочная', ['class' => 'form-check-label']) ?>
            </div>
        </div>
    </section>

    <div class="row g-3 arm-form-create__cards-row">
        <div class="col-md-6 arm-form-create__cards-row-col d-flex flex-column">
            <section class="arm-view-card arm-form-create__card h-100" aria-labelledby="license-create-section-purchase">
                <h2 id="license-create-section-purchase" class="arm-view-card__title">Закупка</h2>
                <div class="arm-view-card__body arm-form-create__card-fields">
                    <?= $form->field($model, 'supplier', [
                        'options' => ['class' => 'arm-form-create__field arm-form-create__field--supplier'],
                    ])->textInput([
                        'maxlength' => true,
                        'list' => 'software-license-supplier-datalist',
                        'autocomplete' => 'off',
                        'placeholder' => 'Наименование поставщика',
                    ]) ?>
                    <?= $form->field($model, 'purchase_date', [
                        'options' => ['class' => 'arm-form-create__field'],
                    ])->input('date') ?>
                </div>
            </section>
        </div>

        <div class="col-md-6 arm-form-create__cards-row-col d-flex flex-column">
            <?= $this->render('_license_attachments', [
                'model' => $model,
                'attachments' => $attachments,
                'canEditAttachments' => true,
                'wrapInCard' => true,
            ]) ?>
        </div>
    </div>

    <div class="row g-3 arm-form-create__note-row">
        <div class="col-md-6 arm-form-create__cards-row-col d-flex flex-column">
            <section class="arm-view-card arm-form-create__card h-100" aria-labelledby="license-create-section-equipment">
                <h2 id="license-create-section-equipment" class="arm-view-card__title">
                    Привязка к технике
                    <span class="text-muted fw-normal">(необязательно)</span>
                </h2>
                <div class="arm-view-card__body arm-form-create__card-fields">
                    <?= $this->render('_license_equipment_picker', [
                        'equipmentRows' => $equipmentRows,
                        'selectedEquipmentIds' => $selectedEquipmentIds,
                    ]) ?>
                </div>
            </section>
        </div>
        <div class="col-md-6 arm-form-create__cards-row-col d-flex flex-column">
            <section class="arm-view-card arm-form-create__card h-100" aria-labelledby="license-create-section-note">
                <h2 id="license-create-section-note" class="arm-view-card__title">Примечание</h2>
                <div class="arm-view-card__body arm-form-create__card-fields">
                    <?= $form->field($model, 'notes', [
                        'options' => ['class' => 'arm-form-create__field mb-0'],
                    ])->textarea([
                        'rows' => 4,
                        'placeholder' => 'Дополнительная информация',
                    ]) ?>
                </div>
            </section>
        </div>
    </div>

    <?php ActiveForm::end(); ?>
</div>
