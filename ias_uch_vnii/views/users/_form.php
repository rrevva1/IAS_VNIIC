<?php

use yii\helpers\Html;
use yii\widgets\ActiveForm;

/* @var $this yii\web\View */
/* @var $model app\models\entities\Users */
/* @var $form yii\widgets\ActiveForm */
?>

<div class="users-form">

    <?php $form = ActiveForm::begin(); ?>

    <?= $form->field($model, 'username')->textInput(['maxlength' => true]) ?>

    <?= $form->field($model, 'full_name')->textInput(['maxlength' => true]) ?>

    <?= $form->field($model, 'email')->textInput(['maxlength' => true]) ?>

    <label class="form-label" for="users-phone-legacy"><?= $model->getAttributeLabel('phone') ?></label>
    <?= $this->render('//partials/_internal_phone_field', [
        'form' => $form,
        'model' => $model,
        'attribute' => 'phone',
        'inputId' => 'users-phone-legacy',
        'cssClass' => 'form-select',
        'excludeUserId' => $model->isNewRecord ? null : (int) $model->id,
        'excludeDirectoryId' => null,
        'showHint' => true,
    ]) ?>

    <?= $form->field($model, 'password_plain')->passwordInput(['maxlength' => true]) ?>

    <div class="form-group">
        <?= Html::submitButton('Сохранить', ['class' => 'btn btn-success']) ?>
    </div>

    <?php ActiveForm::end(); ?>

</div>
