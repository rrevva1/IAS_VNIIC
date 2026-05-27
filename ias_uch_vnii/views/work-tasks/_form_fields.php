<?php

use yii\helpers\Html;
use yii\widgets\ActiveForm;

/** @var yii\widgets\ActiveForm $form */
/** @var app\models\entities\WorkTask $model */
/** @var array $executors */

$fieldOpts = [
    'options' => ['class' => 'work-task-form-create__field'],
    'labelOptions' => ['class' => 'form-label'],
];
?>

<div class="work-task-form-create tasks-create-form-wrap">
    <section class="work-task-card work-task-create-section" aria-labelledby="work-task-form-main-title">
        <div class="work-task-card__body">
            <label id="work-task-form-main-title" class="work-task-create-section__label" for="worktask-title">
                <i class="fas fa-align-left" aria-hidden="true"></i>
                О чем задача? <span class="text-danger">*</span>
            </label>
            <?= $form->field($model, 'title', $fieldOpts)->textInput([
                'maxlength' => true,
                'id' => 'worktask-title',
                'class' => 'form-control form-control-lg',
                'placeholder' => 'Например: Подготовить отчёт по оборудованию',
            ]) ?>
            <?= $form->field($model, 'description', $fieldOpts)->textarea([
                'rows' => 4,
                'id' => 'worktask-description',
                'class' => 'form-control work-task-form-create__textarea',
                'placeholder' => 'Опишите, что нужно сделать и какой ожидается результат',
            ]) ?>
            <p class="work-task-form-create__hint">Чем понятнее описание, тем быстрее задача будет выполнена.</p>
        </div>
    </section>

    <div class="work-task-form-create__grid">
        <section class="work-task-card work-task-create-section" aria-labelledby="work-task-form-executor-title">
            <div class="work-task-card__body">
                <label id="work-task-form-executor-title" class="work-task-create-section__label" for="worktask-executor_id">
                    <i class="fas fa-user-check" aria-hidden="true"></i>
                    Исполнитель <span class="work-task-create-section__optional">(необязательно)</span>
                </label>
                <?= $form->field($model, 'executor_id', [
                    'options' => ['class' => 'work-task-form-create__field mb-0'],
                    'inputOptions' => ['class' => 'form-select'],
                ])->dropDownList($executors, [
                    'prompt' => 'Выбрать позже',
                    'id' => 'worktask-executor_id',
                ])->label(false) ?>
                <p class="work-task-form-create__hint">Можно назначить исполнителя сейчас или позже на доске.</p>
            </div>
        </section>

        <section class="work-task-card work-task-card--attachments work-task-create-section" aria-labelledby="work-task-form-files-title">
            <div class="work-task-card__body work-task-card__body--flush">
                <div id="work-task-form-files-title" class="work-task-create-section__label work-task-create-section__label--attachments">
                    <i class="fas fa-paperclip" aria-hidden="true"></i>
                    Вложения
                </div>
                <?= $this->render('/tasks/_form_attachments', [
                    'form' => $form,
                    'model' => $model,
                    'inputName' => 'WorkTask[uploadFiles][]',
                    'inputId' => 'file-input-work-tasks',
                    'compact' => true,
                ]) ?>
            </div>
        </section>
    </div>
</div>
