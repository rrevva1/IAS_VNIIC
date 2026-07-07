<?php

use yii\helpers\Html;
use yii\helpers\Url;
use yii\widgets\ActiveForm;

/** @var app\models\dictionaries\DicEquipmentStatus $model */
/** @var bool $isUpdate */

$isUpdate = !empty($isUpdate);
$formId = $isUpdate ? 'ref-equipment-status-update-form' : 'ref-equipment-status-create-form';
?>
<div class="tasks-create-form-wrap references-create-form-wrap">
    <?php $form = ActiveForm::begin([
        'id' => $formId,
        'action' => $isUpdate
            ? Url::to(['equipment-status-update-modal', 'id' => $model->id])
            : Url::to(['equipment-status-create-modal']),
        'method' => 'post',
        'enableClientValidation' => false,
        'enableAjaxValidation' => false,
        'options' => ['class' => 'tasks-create-form', 'novalidate' => true],
    ]); ?>

    <div class="tasks-create-form__section">
        <?= $form->field($model, 'status_code')->textInput(['maxlength' => true]) ?>
    </div>
    <div class="tasks-create-form__section">
        <?= $form->field($model, 'status_name')->textInput(['maxlength' => true]) ?>
    </div>
    <div class="tasks-create-form__section">
        <?= $form->field($model, 'sort_order')->textInput(['type' => 'number']) ?>
    </div>
    <div class="tasks-create-form__section">
        <?= $form->field($model, 'is_final')->checkbox() ?>
    </div>
    <div class="tasks-create-form__section">
        <?= $form->field($model, 'is_archived')->checkbox() ?>
    </div>

    <div class="tasks-create-form__footer">
        <?= Html::button('Отмена', ['class' => 'btn btn-outline-secondary', 'type' => 'button', 'data-bs-dismiss' => 'modal']) ?>
        <?= Html::submitButton('Сохранить', ['class' => 'btn btn-primary', 'id' => 'submit-ref-form-btn']) ?>
    </div>

    <?php ActiveForm::end(); ?>
</div>
