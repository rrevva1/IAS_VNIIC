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

    <?= $form->field($model, 'role_id')->dropDownList(
        $roleItems,
        ['prompt' => 'Выберите роль']
    ) ?>

    <?= $form->field($model, 'password_plain')->passwordInput(['maxlength' => true]) ?>

    <div class="form-group">
        <?= Html::submitButton(
            $model->isNewRecord ? 'Создать' : 'Сохранить',
            [
                'class' => 'btn btn-success',
                'title' => $model->isNewRecord ? 'Создать пользователя и сохранить в БД' : 'Сохранить изменения в БД',
            ]
        ) ?>
    </div>

    <?php ActiveForm::end(); ?>
</div>
