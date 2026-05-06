<?php

/** @var yii\web\View $this */
/** @var yii\bootstrap5\ActiveForm $form */
/** @var app\models\LoginForm $model */

use yii\bootstrap5\ActiveForm;
use yii\bootstrap5\Html;
use app\assets\SiteAsset;

// Подключаем assets для страниц сайта
SiteAsset::register($this);

$this->title = 'Авторизация';
$this->params['breadcrumbs'][] = $this->title;
?>
<div class="site-login">
    <div class="row justify-content-center">
        <div class="col-lg-5">
            <div class="card">
                <div class="card-header">
                    <h1 class="card-title text-center"><?= Html::encode($this->title) ?></h1>
                </div>
                <div class="card-body">
                    <p class="text-center">Пожалуйста, заполните поля для входа в систему:</p>

                    <?php $form = ActiveForm::begin([
                        'id' => 'login-form',
                        'fieldConfig' => [
                            'template' => "{label}\n{input}\n{error}",
                            'labelOptions' => ['class' => 'form-label'],
                            'inputOptions' => ['class' => 'form-control'],
                            'errorOptions' => ['class' => 'invalid-feedback'],
                        ],
                    ]); ?>

                    <?= $form->field($model, 'email')->textInput([
                        'autofocus' => true,
                        'placeholder' => 'Введите ваш email',
                        'type' => 'email'
                    ]) ?>

                    <?= $form->field($model, 'password')->passwordInput([
                        'placeholder' => 'Введите пароль'
                    ]) ?>

                    <?= $form->field($model, 'rememberMe')->checkbox([
                        'template' => "<div class=\"form-check\">{input} {label}</div>\n<div class=\"col-lg-8\">{error}</div>",
                    ]) ?>

                    <div class="form-group text-center">
                        <?= Html::submitButton('Войти', [
                            'class' => 'btn btn-primary btn-lg w-100', 
                            'name' => 'login-button'
                        ]) ?>
                    </div>

                    <?php ActiveForm::end(); ?>

                    <div class="text-center mt-3">
                        <p class="text-muted">
                            Нет аккаунта? 
                            <?= Html::a('Зарегистрироваться', ['/users/create'], ['class' => 'text-decoration-none']) ?>
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
