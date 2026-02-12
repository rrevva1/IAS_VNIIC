<?php
use yii\helpers\Html;
use yii\widgets\ActiveForm;
use app\models\dictionaries\Roles;

// ВАЖНО: получаем пары [id => role_name] для дропдауна
$roleItems = Roles::getList();
?>

<div class="users-form">
    <?php $form = ActiveForm::begin(); ?>

    <?= $form->field($model, 'full_name')->textInput(['maxlength' => true]) ?>

    <?= $form->field($model, 'email')->textInput(['maxlength' => true]) ?>

    <?= $form->field($model, 'id_role')->dropDownList(
        $roleItems,
        ['prompt' => 'Выберите роль']
    ) ?>

    <?= $form->field($model, 'password_plain')->passwordInput(['maxlength' => true]) ?>

    <div class="form-group">
        <?= Html::submitButton('Save', ['class' => 'btn btn-success']) ?>
    </div>

    <?php ActiveForm::end(); ?>
</div>
