<?php

use yii\helpers\Html;
use yii\helpers\Url;
use yii\widgets\ActiveForm;

/** @var yii\web\View $this */
/** @var app\models\entities\Users $model */
?>

<div class="profile-edit-form-wrap">
    <?php $form = ActiveForm::begin([
        'id' => 'profile-edit-form',
        'action' => Url::to(['users/profile-modal']),
        'method' => 'post',
        'enableClientValidation' => false,
        'enableAjaxValidation' => false,
        'options' => [
            'class' => 'profile-edit-form',
            'novalidate' => true,
        ],
    ]); ?>

    <section class="profile-edit-form__block profile-edit-form__block--readonly" aria-label="Данные профиля">
        <div class="profile-edit-form__readonly-card">
            <dl class="profile-edit-form__readonly-list">
                <div class="profile-edit-form__readonly-row">
                    <dt class="profile-edit-form__readonly-label">
                        <i class="fas fa-user" aria-hidden="true"></i>
                        <span>ФИО</span>
                    </dt>
                    <dd class="profile-edit-form__readonly-value"><?= Html::encode($model->full_name ?: '—') ?></dd>
                </div>
                <div class="profile-edit-form__readonly-row">
                    <dt class="profile-edit-form__readonly-label">
                        <i class="fas fa-envelope" aria-hidden="true"></i>
                        <span>Электронная почта</span>
                    </dt>
                    <dd class="profile-edit-form__readonly-value"><?= Html::encode($model->email ?: '—') ?></dd>
                </div>
            </dl>
        </div>
        <p class="profile-edit-form__readonly-hint">
            ФИО и электронная почта изменяются администратором системы.
        </p>
    </section>

    <section class="profile-edit-form__block profile-edit-form__block--phone" aria-label="Контактные данные">
        <label class="profile-edit-form__label" for="profile-phone">
            <i class="fas fa-phone" aria-hidden="true"></i>
            <span>Внутренний телефон</span>
        </label>
        <div class="profile-edit-form__field">
            <?= $this->render('//partials/_internal_phone_field', [
                'form' => $form,
                'model' => $model,
                'attribute' => 'phone',
                'inputId' => 'profile-phone',
                'cssClass' => 'form-select profile-edit-form__input',
                'excludeUserId' => (int) $model->id,
                'excludeDirectoryId' => null,
                'showHint' => true,
            ]) ?>
        </div>

        <label class="profile-edit-form__label mt-3" for="profile-room">
            <i class="fas fa-door-open" aria-hidden="true"></i>
            <span>Кабинет</span>
        </label>
        <div class="profile-edit-form__field">
            <?= $form->field($model, 'room', ['options' => ['class' => 'mb-0']])->textInput([
                'id' => 'profile-room',
                'class' => 'form-control profile-edit-form__input',
                'maxlength' => true,
                'placeholder' => 'Например, 215',
                'autocomplete' => 'off',
            ])->label(false) ?>
        </div>
        <p class="profile-edit-form__readonly-hint mt-2 mb-0">
            Номер и кабинет отображаются в телефонном справочнике.
        </p>
    </section>

    <section class="profile-edit-form__block profile-edit-form__block--password" aria-label="Смена пароля">
        <h3 class="profile-edit-form__section-title">
            <i class="fas fa-key" aria-hidden="true"></i>
            <span>Смена пароля</span>
        </h3>
        <p class="profile-edit-form__section-lead">Заполните поля только если хотите установить новый пароль</p>

        <div class="profile-edit-form__password-grid">
            <div class="profile-edit-form__field">
                <label class="profile-edit-form__label profile-edit-form__label--sub" for="profile-password_plain">Новый пароль</label>
                <?= $form->field($model, 'password_plain', ['options' => ['class' => 'mb-0']])->passwordInput([
                    'id' => 'profile-password_plain',
                    'class' => 'form-control profile-edit-form__input',
                    'maxlength' => true,
                    'placeholder' => 'Не менее 8 символов',
                    'autocomplete' => 'new-password',
                    'data-profile-password' => '1',
                ])->label(false) ?>
            </div>
            <div class="profile-edit-form__field">
                <label class="profile-edit-form__label profile-edit-form__label--sub" for="profile-password_confirm">Подтверждение пароля</label>
                <?= $form->field($model, 'password_confirm', ['options' => ['class' => 'mb-0']])->passwordInput([
                    'id' => 'profile-password_confirm',
                    'class' => 'form-control profile-edit-form__input',
                    'maxlength' => true,
                    'placeholder' => 'Повторите пароль',
                    'autocomplete' => 'new-password',
                    'data-profile-password-confirm' => '1',
                ])->label(false) ?>
            </div>
        </div>

        <div class="profile-password-strength" id="profilePasswordStrength" hidden>
            <div class="profile-password-strength__bar" aria-hidden="true">
                <span class="profile-password-strength__fill" id="profilePasswordStrengthFill"></span>
            </div>
            <ul class="profile-password-strength__rules" id="profilePasswordRules">
                <li data-rule="length">Не менее 8 символов</li>
                <li data-rule="lower">Строчная буква</li>
                <li data-rule="upper">Прописная буква</li>
                <li data-rule="digit">Цифра</li>
                <li data-rule="match">Пароли совпадают</li>
            </ul>
        </div>
    </section>

    <div class="profile-edit-form__footer">
        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">
            Отмена
        </button>
        <?= Html::submitButton(
            '<i class="fas fa-check" aria-hidden="true"></i> Сохранить',
            [
                'class' => 'btn btn-primary',
                'id' => 'profile-edit-submit',
            ]
        ) ?>
    </div>

    <?php ActiveForm::end(); ?>
</div>
