<?php

use yii\helpers\Html;
use yii\widgets\ActiveForm;

/* @var $this yii\web\View */
/* @var $model app\models\entities\Tasks */
/* @var $form yii\widgets\ActiveForm */
?>

<div class="tasks-create-form-wrap">
    <?php $form = ActiveForm::begin([
        'options' => [
            'enctype' => 'multipart/form-data',
            'id' => 'task-form',
            'class' => 'task-create-form',
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
        <span class="tasks-create-form__label">
            <i class="fas fa-paperclip" aria-hidden="true"></i>
            Вложения <span class="tasks-create-form__optional">(необязательно)</span>
        </span>

        <div class="tasks-file-drop" id="tasks-file-drop" role="button" tabindex="0" aria-label="Выбрать файлы">
            <div class="tasks-file-drop__icon" aria-hidden="true">
                <i class="fas fa-cloud-arrow-up"></i>
            </div>
            <p class="tasks-file-drop__title">Перетащите файлы сюда или нажмите для выбора</p>
            <p class="tasks-file-drop__formats">Изображения, PDF, Word, Excel, текст — до 10 файлов</p>
            <?= $form->field($model, 'uploadFiles', ['options' => ['class' => 'mb-0 tasks-file-drop__field']])->fileInput([
                'multiple' => true,
                'accept' => 'image/*,application/pdf,.doc,.docx,.xls,.xlsx,.txt',
                'class' => 'tasks-file-drop__input',
                'id' => 'file-input-tasks',
                'name' => 'Tasks[uploadFiles][]',
            ])->label(false) ?>
        </div>

        <div id="selected-files-list" class="tasks-files-list" hidden>
            <div class="tasks-files-list__head">
                <strong>Выбранные файлы</strong>
                <button type="button" class="btn btn-sm btn-link text-danger clear-files-btn p-0">Очистить все</button>
            </div>
            <ul id="files-list-container" class="tasks-files-list__items"></ul>
        </div>
    </div>

    <div class="tasks-create-form__footer">
        <button type="button" class="btn btn-outline-secondary tasks-tool-btn btn-cancel" data-bs-dismiss="modal">
            Отмена
        </button>
        <?= Html::submitButton('<i class="fas fa-paper-plane" aria-hidden="true"></i> Отправить заявку', [
            'class' => 'btn btn-primary tasks-tool-btn',
            'id' => 'submit-task-btn',
        ]) ?>
    </div>

    <?php ActiveForm::end(); ?>
</div>
