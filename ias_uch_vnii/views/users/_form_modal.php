<?php

use app\models\dictionaries\Roles;
use yii\helpers\Html;
use yii\helpers\Url;
use yii\widgets\ActiveForm;

/** @var yii\web\View $this */
/** @var app\models\entities\Users $model */
/** @var array $roleItems */
/** @var bool $isUpdate */

$roleItems = $roleItems ?? Roles::getList();
$isUpdate = !empty($isUpdate);
$formId = $isUpdate ? 'user-update-form' : 'user-create-form';
$passwordRequired = !$isUpdate;
?>

<div class="users-create-form-wrap">
    <?php $form = ActiveForm::begin([
        'id' => $formId,
        'action' => $isUpdate
            ? Url::to(['users/update-modal', 'id' => $model->id])
            : Url::to(['users/create-modal']),
        'method' => 'post',
        'enableClientValidation' => false,
        'enableAjaxValidation' => false,
        'options' => [
            'class' => 'users-create-form',
            'novalidate' => true,
        ],
    ]); ?>

    <?php if ($isUpdate): ?>
        <?= Html::activeHiddenInput($model, 'id') ?>
    <?php endif; ?>

    <div class="users-create-form__section">
        <label class="users-create-form__label" for="users-full_name">
            <i class="fas fa-user" aria-hidden="true"></i>
            ФИО <span class="text-danger">*</span>
        </label>
        <?= $form->field($model, 'full_name', ['options' => ['class' => 'mb-0']])->textInput([
            'id' => 'users-full_name',
            'class' => 'form-control',
            'maxlength' => true,
            'placeholder' => 'Иванов Иван Иванович',
            'autocomplete' => 'name',
        ])->label(false) ?>
    </div>

    <div class="row g-3">
        <div class="col-md-6">
            <div class="users-create-form__section mb-0">
                <label class="users-create-form__label" for="users-email">
                    <i class="fas fa-envelope" aria-hidden="true"></i>
                    Email
                </label>
                <?= $form->field($model, 'email', ['options' => ['class' => 'mb-0']])->textInput([
                    'id' => 'users-email',
                    'class' => 'form-control',
                    'maxlength' => true,
                    'placeholder' => 'user@example.com',
                    'autocomplete' => 'email',
                ])->label(false) ?>
                <p class="users-create-form__hint">Используется для входа, если не указан логин</p>
            </div>
        </div>
        <div class="col-md-6">
            <div class="users-create-form__section mb-0">
                <label class="users-create-form__label" for="users-phone">
                    <i class="fas fa-phone" aria-hidden="true"></i>
                    Внутренний телефон
                </label>
                <?= $this->render('//partials/_internal_phone_field', [
                    'form' => $form,
                    'model' => $model,
                    'attribute' => 'phone',
                    'inputId' => 'users-phone',
                    'cssClass' => 'form-select',
                    'excludeUserId' => $model->isNewRecord ? null : (int) $model->id,
                    'excludeDirectoryId' => null,
                    'showHint' => true,
                ]) ?>
            </div>
        </div>
        <div class="col-md-6">
            <div class="users-create-form__section mb-0">
                <label class="users-create-form__label" for="users-room">
                    <i class="fas fa-door-open" aria-hidden="true"></i>
                    Кабинет
                </label>
                <?= $form->field($model, 'room', ['options' => ['class' => 'mb-0']])->textInput([
                    'id' => 'users-room',
                    'class' => 'form-control',
                    'maxlength' => true,
                    'placeholder' => 'Например: 215',
                    'autocomplete' => 'off',
                ])->label(false) ?>
                <p class="users-create-form__hint">Отображается в телефонном справочнике</p>
            </div>
        </div>
    </div>

    <div class="row g-3">
        <div class="col-md-6">
            <div class="users-create-form__section mb-0">
                <label class="users-create-form__label" for="users-username">
                    <i class="fas fa-at" aria-hidden="true"></i>
                    Логин
                </label>
                <?= $form->field($model, 'username', ['options' => ['class' => 'mb-0']])->textInput([
                    'id' => 'users-username',
                    'class' => 'form-control',
                    'maxlength' => true,
                    'placeholder' => 'Необязательно',
                    'autocomplete' => 'username',
                ])->label(false) ?>
            </div>
        </div>
        <div class="col-md-6">
            <div class="users-create-form__section mb-0">
                <label class="users-create-form__label" for="users-role_id">
                    <i class="fas fa-user-shield" aria-hidden="true"></i>
                    Роль
                </label>
                <?= $form->field($model, 'role_id', ['options' => ['class' => 'mb-0']])->dropDownList(
                    $roleItems,
                    ['prompt' => 'Выберите роль', 'id' => 'users-role_id', 'class' => 'form-select']
                )->label(false) ?>
            </div>
        </div>
    </div>

    <div class="users-create-form__section users-create-form__section--password mb-0">
        <label class="users-create-form__label" for="users-password_plain">
            <i class="fas fa-key" aria-hidden="true"></i>
            <?= $isUpdate ? 'Новый пароль' : 'Пароль' ?>
            <?php if ($passwordRequired): ?>
                <span class="text-danger">*</span>
            <?php else: ?>
                <span class="users-create-form__optional">(необязательно)</span>
            <?php endif; ?>
        </label>
        <?= $form->field($model, 'password_plain', ['options' => ['class' => 'mb-0']])->passwordInput([
            'id' => 'users-password_plain',
            'class' => 'form-control',
            'maxlength' => true,
            'placeholder' => $isUpdate ? 'Оставьте пустым, если не меняете' : 'Не менее 6 символов',
            'autocomplete' => 'new-password',
        ])->label(false) ?>
        <?php if ($isUpdate): ?>
            <p class="users-create-form__hint">Заполните только при смене пароля</p>
        <?php endif; ?>
    </div>

    <div class="users-create-form__footer">
        <button type="button" class="btn btn-outline-secondary users-tool-btn" data-bs-dismiss="modal">
            Отмена
        </button>
        <?= Html::submitButton(
            $isUpdate
                ? '<i class="fas fa-check" aria-hidden="true"></i> Сохранить'
                : '<i class="fas fa-check" aria-hidden="true"></i> Создать',
            [
                'class' => 'btn btn-primary users-tool-btn',
                'id' => 'submit-user-btn',
            ]
        ) ?>
    </div>

    <?php ActiveForm::end(); ?>
</div>
