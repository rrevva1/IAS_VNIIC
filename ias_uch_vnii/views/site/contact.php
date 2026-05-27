<?php

/** @var yii\web\View $this */
/** @var yii\bootstrap5\ActiveForm $form */
/** @var app\models\ContactForm $model */

use app\assets\SectionPageAsset;
use yii\bootstrap5\ActiveForm;
use yii\bootstrap5\Html;
use yii\captcha\Captcha;

SectionPageAsset::register($this);

$this->title = 'Контакты';
$this->params['breadcrumbs'] = [];
?>
<div class="arm-page site-contact-page">
    <header class="arm-page__header">
        <div class="arm-page__heading">
            <h1 class="arm-page__title"><?= Html::encode($this->title) ?></h1>
        </div>
    </header>

    <div class="arm-grid-card arm-content-panel">
        <?php if (Yii::$app->session->hasFlash('contactFormSubmitted')): ?>

            <div class="alert alert-success">
                Спасибо за обращение. Ответ будет направлен в ближайшее время.
            </div>

            <p class="text-muted small mb-0">
                <?php if (Yii::$app->mailer->useFileTransport): ?>
                    Приложение в режиме разработки: письмо сохранено в каталоге
                    <code><?= Html::encode(Yii::getAlias(Yii::$app->mailer->fileTransportPath)) ?></code>.
                <?php endif; ?>
            </p>

        <?php else: ?>

            <div class="site-contact-form">
                <?php $form = ActiveForm::begin(['id' => 'contact-form']); ?>

                    <?= $form->field($model, 'name')->textInput(['autofocus' => true]) ?>

                    <?= $form->field($model, 'email') ?>

                    <?= $form->field($model, 'subject') ?>

                    <?= $form->field($model, 'body')->textarea(['rows' => 6]) ?>

                    <?= $form->field($model, 'verifyCode')->widget(Captcha::class, [
                        'template' => '<div class="row g-2"><div class="col-sm-4">{image}</div><div class="col-sm-8">{input}</div></div>',
                    ]) ?>

                    <div class="form-group mt-3">
                        <?= Html::submitButton('Отправить', ['class' => 'btn btn-primary', 'name' => 'contact-button']) ?>
                    </div>

                <?php ActiveForm::end(); ?>
            </div>

        <?php endif; ?>
    </div>
</div>
