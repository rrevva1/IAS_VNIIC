<?php

use yii\helpers\Html;
use yii\widgets\ActiveForm;

/* @var $this yii\web\View */
/* @var $model app\models\Tasks */
/* @var $form yii\widgets\ActiveForm */

// Подключаем CSS и JS для модальной формы
$this->registerCssFile('@web/css/tasks/form-modal.css', ['depends' => [\yii\web\YiiAsset::class]]);
$this->registerJsFile('@web/js/tasks/form-modal.js', ['depends' => [\yii\web\JqueryAsset::class]]);

?>

<div class="tasks-form modal-form">
    
    <?php $form = ActiveForm::begin([
        'options' => [
            'enctype' => 'multipart/form-data',
            'id' => 'task-form',
            'class' => 'task-create-form'
        ]
    ]); ?>

    <div class="form-section">
        <div class="section-header">
            <i class="glyphicon glyphicon-info-sign"></i>
            <h5>Описание заявки</h5>
        </div>
        <?= $form->field($model, 'description')->textarea([
            'rows' => 4, 
            'placeholder' => 'Опишите проблему или запрос подробно...'
        ])->label(false) ?>
    </div>

    
    <div class="form-section">
        <div class="section-header">
            <i class="glyphicon glyphicon-paperclip"></i>
            <h5>Вложения</h5>
        </div>
        <div class="file-upload-wrapper">
            <?= $form->field($model, 'uploadFiles')->fileInput([
                'multiple' => true,
                'accept' => 'image/*,application/pdf,.doc,.docx,.xls,.xlsx,.txt',
                'class' => 'file-input-custom',
                'id' => 'file-input-tasks',
                'name' => 'Tasks[uploadFiles][]'  // ИСПРАВЛЕНИЕ: явно указываем, что это массив
            ])->label('Выберите файлы для загрузки', ['class' => 'file-label']) ?>
            
            <!-- Список выбранных файлов -->
            <div id="selected-files-list" class="selected-files-list" style="display: none;">
                <div class="selected-files-header">
                    <strong>Выбранные файлы:</strong>
                    <button type="button" class="btn btn-xs btn-danger clear-files-btn">
                        <i class="glyphicon glyphicon-trash"></i> Очистить все
                    </button>
                </div>
                <ul id="files-list-container" class="files-list-container"></ul>
            </div>
            
            <small class="text-muted">
                <i class="glyphicon glyphicon-info-sign"></i> 
                Поддерживаемые форматы: изображения, PDF, документы Word/Excel, текстовые файлы
            </small>
        </div>
    </div>

    <div class="form-actions">
        <?= Html::submitButton('<i class="glyphicon glyphicon-plus"></i> Создать заявку', [
            'class' => 'btn btn-success btn-submit',
            'id' => 'submit-task-btn'
        ]) ?>
        <button type="button" class="btn btn-default btn-cancel" data-bs-dismiss="modal">
            <i class="glyphicon glyphicon-remove"></i> Отмена
        </button>
    </div>

    <?php ActiveForm::end(); ?>

</div>
