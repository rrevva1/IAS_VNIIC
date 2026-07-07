<?php

use yii\helpers\Html;
use yii\helpers\Url;
use yii\widgets\ActiveForm;

/** @var app\models\entities\SprParts $model */
/** @var bool $isUpdate */

$isUpdate = !empty($isUpdate);
$formId = $isUpdate ? 'ref-parts-update-form' : 'ref-parts-create-form';
?>
<div class="tasks-create-form-wrap references-create-form-wrap">
    <?php $form = ActiveForm::begin([
        'id' => $formId,
        'action' => $isUpdate
            ? Url::to(['parts-update-modal', 'id' => $model->id])
            : Url::to(['parts-create-modal']),
        'method' => 'post',
        'enableClientValidation' => false,
        'enableAjaxValidation' => false,
        'options' => ['class' => 'tasks-create-form', 'novalidate' => true],
    ]); ?>

    <div class="tasks-create-form__section">
        <?= $form->field($model, 'name')->textInput(['maxlength' => true]) ?>
    </div>
    <div class="tasks-create-form__section">
        <?= $form->field($model, 'description')->textarea(['rows' => 3]) ?>
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
