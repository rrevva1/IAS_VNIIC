<?php

use yii\helpers\Html;
use yii\helpers\Url;
use yii\widgets\ActiveForm;

/** @var app\models\entities\WorkTask $model */
/** @var array $executors */
?>

<div class="modal fade" id="workTaskCreateModal" tabindex="-1" aria-labelledby="workTaskCreateModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-scrollable modal-fullscreen-lg-down work-task-modal__dialog">
        <div class="modal-content work-task-modal work-task-create-modal">
            <?php $form = ActiveForm::begin([
                'id' => 'workTaskCreateForm',
                'action' => Url::to(['create']),
                'enableClientValidation' => false,
                'enableAjaxValidation' => false,
                'options' => [
                    'class' => 'work-task-modal__form tasks-create-form',
                    'enctype' => 'multipart/form-data',
                ],
                'fieldConfig' => [
                    'options' => ['class' => 'mb-0'],
                ],
            ]); ?>
            <div class="modal-header work-task-modal__header work-task-create-modal__header">
                <div class="work-task-modal__header-text">
                    <h5 class="modal-title mb-0" id="workTaskCreateModalLabel">
                        Создание задачи
                    </h5>
                    <p class="work-task-modal__subtitle mb-0" id="workTaskCreateModalSubtitle">Заполните главное, остальное можно добавить позже.</p>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Закрыть"></button>
            </div>
            <div class="modal-body work-task-modal__body">
                <div id="workTaskCreateFormError" class="alert alert-danger d-none mb-3" role="alert"></div>
                <?= $this->render('_form_fields', [
                    'form' => $form,
                    'model' => $model,
                    'executors' => $executors,
                ]) ?>
            </div>
            <div class="modal-footer work-task-modal__footer">
                <button type="button" class="btn btn-outline-secondary work-tasks-tool-btn" data-bs-dismiss="modal">
                    <i class="fas fa-xmark" aria-hidden="true"></i>
                    Закрыть
                </button>
                <?= Html::submitButton('<i class="fas fa-check" aria-hidden="true"></i> Создать задачу', [
                    'class' => 'btn btn-primary work-tasks-tool-btn',
                    'id' => 'workTaskCreateSubmit',
                    'encode' => false,
                ]) ?>
            </div>
            <?php ActiveForm::end(); ?>
        </div>
    </div>
</div>
