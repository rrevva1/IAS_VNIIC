<?php

use yii\helpers\Html;
use yii\widgets\ActiveForm;

/* @var $this yii\web\View */
/* @var $model app\models\entities\Tasks */
/* @var $form yii\widgets\ActiveForm */
/* @var bool $isUpdate */
/* @var bool $canEditExecutorComment */

$isUpdate = !empty($isUpdate);
$canEditExecutorComment = !empty($canEditExecutorComment);
?>

<div class="tasks-create-form-wrap">
    <?php $form = ActiveForm::begin([
        'options' => [
            'enctype' => 'multipart/form-data',
            'id' => 'task-form',
            'class' => 'task-create-form tasks-create-form',
        ],
    ]); ?>

    <div class="tasks-create-form__section">
        <label class="tasks-create-form__label" for="tasks-description">
            <i class="fas fa-align-left" aria-hidden="true"></i>
            Описание <span class="text-danger">*</span>
        </label>
        <?= $form->field($model, 'description', ['options' => ['class' => 'mb-0']])->textarea([
            'rows' => 5,
            'id' => 'tasks-description',
            'class' => 'form-control tasks-create-form__textarea',
            'placeholder' => 'Например: не включается монитор на рабочем месте, нужна диагностика…',
        ])->label(false) ?>
        <p class="tasks-create-form__hint">Чем подробнее описание, тем быстрее смогут помочь</p>
    </div>

    <div class="tasks-create-form__section">
        <label class="tasks-create-form__label" for="tasks-contact_phone">
            <i class="fas fa-phone" aria-hidden="true"></i>
            Телефон для обратной связи <span class="tasks-create-form__optional">(необязательно)</span>
        </label>
        <?= $form->field($model, 'contact_phone', ['options' => ['class' => 'mb-0']])->textInput([
            'id' => 'tasks-contact_phone',
            'class' => 'form-control',
            'type' => 'tel',
            'maxlength' => true,
            'placeholder' => '+7 (999) 123-45-67',
            'autocomplete' => 'tel',
        ])->label(false) ?>
        <p class="tasks-create-form__hint">Укажите номер, если удобнее связаться по телефону</p>
    </div>

    <div class="tasks-create-form__section">
        <label class="tasks-create-form__label" for="tasks-room_number">
            <i class="fas fa-door-open" aria-hidden="true"></i>
            Номер помещения <span class="tasks-create-form__optional">(необязательно)</span>
        </label>
        <?= $form->field($model, 'room_number', ['options' => ['class' => 'mb-0']])->textInput([
            'id' => 'tasks-room_number',
            'class' => 'form-control',
            'maxlength' => true,
            'placeholder' => 'Например: 303',
            'autocomplete' => 'off',
        ])->label(false) ?>
        <p class="tasks-create-form__hint">Кабинет или помещение, где находится техника</p>
    </div>

    <?= $this->render('_form_attachments', [
        'form' => $form,
        'model' => $model,
        'inputName' => 'Tasks[uploadFiles][]',
        'inputId' => 'file-input-tasks',
    ]) ?>

    <?php if ($isUpdate && $canEditExecutorComment): ?>
    <div class="tasks-create-form__section">
        <label class="tasks-create-form__label" for="tasks-comment">
            <i class="fas fa-comment-dots" aria-hidden="true"></i>
            Комментарий исполнителя <span class="tasks-create-form__optional">(необязательно)</span>
        </label>
        <?= $form->field($model, 'comment', ['options' => ['class' => 'mb-0']])->textarea([
            'rows' => 4,
            'id' => 'tasks-comment',
            'class' => 'form-control tasks-create-form__textarea',
            'placeholder' => 'Результат работ, что сделано, рекомендации для автора заявки…',
        ])->label(false) ?>
        <p class="tasks-create-form__hint">Доступно сотрудникам технической поддержки. Виден автору заявки в карточке.</p>
    </div>
    <?php endif; ?>

    <div class="tasks-create-form__footer">
        <button type="button" class="btn btn-outline-secondary tasks-tool-btn btn-cancel" data-bs-dismiss="modal">
            Отмена
        </button>
        <?= Html::submitButton(
            $isUpdate
                ? '<i class="fas fa-check" aria-hidden="true"></i> Сохранить'
                : '<i class="fas fa-paper-plane" aria-hidden="true"></i> Отправить заявку',
            [
                'class' => 'btn btn-primary tasks-tool-btn',
                'id' => 'submit-task-btn',
            ]
        ) ?>
    </div>

    <?php ActiveForm::end(); ?>
</div>
