<?php

use app\models\entities\PhoneDirectory;
use yii\helpers\Html;
use yii\helpers\Url;
use yii\widgets\ActiveForm;

/** @var yii\web\View $this */
/** @var app\models\entities\PhoneDirectory $model */
/** @var bool $isUpdate */

$action = $isUpdate
    ? Url::to(['phone-directory/update-modal', 'id' => $model->id])
    : Url::to(['phone-directory/create-modal']);
?>

<div class="phone-directory-form-wrap">
    <?php $form = ActiveForm::begin([
        'id' => 'phone-directory-form',
        'action' => $action,
        'method' => 'post',
        'enableClientValidation' => false,
        'options' => [
            'class' => 'phone-directory-form',
            'novalidate' => true,
        ],
    ]); ?>

    <div class="row g-3">
        <div class="col-md-6">
            <?= $form->field($model, 'entry_type')->dropDownList(PhoneDirectory::entryTypeLabels(), [
                'class' => 'form-select',
            ]) ?>
        </div>
        <div class="col-md-6">
            <?= $form->field($model, 'is_published')->checkbox(['uncheck' => '0', 'value' => '1']) ?>
        </div>
        <div class="col-12">
            <?= $form->field($model, 'full_name')->textInput([
                'class' => 'form-control',
                'maxlength' => true,
                'placeholder' => 'ФИО сотрудника или название службы',
            ]) ?>
        </div>
        <div class="col-md-6">
            <?= $form->field($model, 'position')->textInput(['class' => 'form-control', 'maxlength' => true]) ?>
        </div>
        <div class="col-md-6">
            <?= $form->field($model, 'department')->textInput(['class' => 'form-control', 'maxlength' => true]) ?>
        </div>
        <div class="col-md-4">
            <?= $form->field($model, 'room')->textInput(['class' => 'form-control', 'maxlength' => true]) ?>
        </div>
        <div class="col-md-4">
            <label class="form-label" for="pd-internal-phone"><?= $model->getAttributeLabel('internal_phone') ?></label>
            <?= $this->render('//partials/_internal_phone_field', [
                'form' => $form,
                'model' => $model,
                'attribute' => 'internal_phone',
                'inputId' => 'pd-internal-phone',
                'cssClass' => 'form-select',
                'excludeUserId' => $model->user_id ? (int) $model->user_id : null,
                'excludeDirectoryId' => $model->isNewRecord ? null : (int) $model->id,
                'showHint' => true,
            ]) ?>
        </div>
        <div class="col-md-4">
            <?= $form->field($model, 'external_phone')->textInput([
                'class' => 'form-control',
                'maxlength' => true,
                'type' => 'tel',
                'placeholder' => 'Городской (формат уточняется)',
            ])->hint('Городские номера пока вводятся свободно; диапазон будет согласован отдельно.') ?>
        </div>
        <div class="col-md-6">
            <?= $form->field($model, 'user_id')->textInput([
                'class' => 'form-control',
                'type' => 'number',
                'min' => 1,
                'placeholder' => 'Необязательно',
            ])->hint('Оставьте пустым, если у сотрудника ещё нет учётной записи в системе.') ?>
        </div>
        <div class="col-md-6">
            <?= $form->field($model, 'sort_order')->textInput([
                'class' => 'form-control',
                'type' => 'number',
            ]) ?>
        </div>
    </div>

    <div class="d-flex justify-content-end gap-2 mt-4">
        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Отмена</button>
        <?= Html::submitButton(
            '<i class="fas fa-check" aria-hidden="true"></i> Сохранить',
            ['class' => 'btn btn-primary', 'id' => 'phone-directory-form-submit']
        ) ?>
    </div>

    <?php ActiveForm::end(); ?>
</div>
