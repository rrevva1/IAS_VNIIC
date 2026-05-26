<?php

use yii\helpers\Html;
use yii\widgets\ActiveForm;
use app\models\dictionaries\Roles;

/** @var yii\web\View $this */
/** @var app\models\entities\Users $model */

$roleItems = Roles::getList();
$isOwnProfile = Yii::$app->user->identity
    && (int) Yii::$app->user->identity->id === (int) $model->id
    && !Yii::$app->user->identity->isAdmin();
?>

<div class="users-form">
    <?php $form = ActiveForm::begin(); ?>

    <?= $form->field($model, 'full_name')->textInput(['maxlength' => true]) ?>

    <?= $form->field($model, 'email')->textInput(['maxlength' => true, 'type' => 'email']) ?>

    <?= $form->field($model, 'phone')->textInput(['maxlength' => true]) ?>

    <?php if (!$isOwnProfile): ?>
        <?= $form->field($model, 'role_id')->dropDownList(
            $roleItems,
            ['prompt' => 'Выберите роль']
        ) ?>
    <?php endif; ?>

    <?= $form->field($model, 'password_plain')->passwordInput([
        'maxlength' => true,
        'placeholder' => $isOwnProfile ? 'Оставьте пустым, если не меняете' : '',
    ])->hint($isOwnProfile ? 'Заполните только при смене пароля' : 'Заполните для установки нового пароля') ?>

    <div class="form-group mt-3">
        <?= Html::submitButton(
            $model->isNewRecord ? 'Создать' : 'Сохранить изменения',
            ['class' => 'btn btn-primary']
        ) ?>
        <?= Html::a('Отмена', ['view', 'id' => $model->id], ['class' => 'btn btn-outline-secondary ms-2']) ?>
    </div>

    <?php ActiveForm::end(); ?>
</div>
