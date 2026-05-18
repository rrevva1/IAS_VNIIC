<?php

/** @var yii\web\View $this */
/** @var yii\bootstrap5\ActiveForm $form */
/** @var app\models\forms\LoginForm $model */

use yii\bootstrap5\ActiveForm;
use yii\bootstrap5\Html;

$this->title = 'Вход в систему';
?>

<div class="login-page">
    <div class="login-card">
        <div class="login-card__brand">
            <div class="login-card__logo" aria-hidden="true">
                <i class="fas fa-desktop"></i>
            </div>
            <p class="login-card__app-name"><?= Html::encode(Yii::$app->name) ?></p>
            <p class="login-card__subtitle">Информационно-аналитическая система учёта технических средств</p>
        </div>

        <div class="login-card__body">
            <h1 class="login-card__heading">Вход в систему</h1>
            <p class="login-card__hint">Введите email или логин и пароль, выданные администратором</p>

            <?php $form = ActiveForm::begin([
                'id' => 'login-form',
                'options' => ['class' => 'login-form'],
                'fieldConfig' => [
                    'template' => "{label}\n{input}\n{error}",
                    'labelOptions' => ['class' => 'form-label'],
                    'inputOptions' => ['class' => 'form-control'],
                    'errorOptions' => ['class' => 'invalid-feedback d-block'],
                ],
            ]); ?>

            <?= $form->field($model, 'email', [
                'template' => "{label}\n<div class=\"input-group\"><span class=\"input-group-text\"><i class=\"fas fa-user\" aria-hidden=\"true\"></i></span>{input}</div>\n{error}",
            ])->textInput([
                'autofocus' => true,
                'autocomplete' => 'username',
                'placeholder' => 'Например: ivanov или user@vnii.ru',
            ]) ?>

            <?= $form->field($model, 'password', [
                'template' => "{label}\n<div class=\"input-group\"><span class=\"input-group-text\"><i class=\"fas fa-lock\" aria-hidden=\"true\"></i></span>{input}</div>\n{error}",
            ])->passwordInput([
                'autocomplete' => 'current-password',
                'placeholder' => 'Введите пароль',
            ]) ?>

            <?= $form->field($model, 'rememberMe')->checkbox([
                'template' => "<div class=\"form-check mt-2\">{input} {label}</div>\n{error}",
                'labelOptions' => ['class' => 'form-check-label'],
            ]) ?>

            <div class="d-grid">
                <?= Html::submitButton('<i class="fas fa-sign-in-alt me-2"></i>Войти', [
                    'class' => 'btn btn-primary login-form__submit',
                    'name' => 'login-button',
                    'encode' => false,
                ]) ?>
            </div>

            <?php ActiveForm::end(); ?>

            <div class="login-card__footer">
                <p class="mb-1 text-muted">Нет учётной записи?</p>
                <?= Html::a('Обратиться к администратору', ['/site/contact'], ['title' => 'Контакты администратора']) ?>
            </div>
        </div>
    </div>
</div>
