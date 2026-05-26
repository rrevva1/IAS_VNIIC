<?php

use yii\helpers\Html;
use yii\helpers\Url;
use yii\widgets\ActiveForm;

/** @var app\models\entities\WorkTask $model */
/** @var array $executors */
/** @var array $requests */
?>

<div class="modal fade" id="workTaskCreateModal" tabindex="-1" aria-labelledby="workTaskCreateModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-scrollable modal-fullscreen-sm-down">
        <div class="modal-content work-task-create-modal">
            <div class="modal-header">
                <h5 class="modal-title" id="workTaskCreateModalLabel">Новая задача</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Закрыть"></button>
            </div>
            <?php $form = ActiveForm::begin([
                'id' => 'workTaskCreateForm',
                'action' => Url::to(['create']),
                'enableClientValidation' => false,
                'enableAjaxValidation' => false,
                'options' => [
                    'class' => 'work-tasks-form work-tasks-form--modal',
                ],
                'fieldConfig' => [
                    'options' => ['class' => 'mb-3'],
                ],
            ]); ?>
            <div class="modal-body">
                <div id="workTaskCreateFormError" class="alert alert-danger d-none" role="alert"></div>
                <?= $this->render('_form_fields', [
                    'form' => $form,
                    'model' => $model,
                    'executors' => $executors,
                    'requests' => $requests,
                ]) ?>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline-secondary work-tasks-tool-btn" data-bs-dismiss="modal">Отмена</button>
                <?= Html::submitButton('Создать', [
                    'class' => 'btn btn-primary work-tasks-tool-btn',
                    'id' => 'workTaskCreateSubmit',
                ]) ?>
            </div>
            <?php ActiveForm::end(); ?>
        </div>
    </div>
</div>
