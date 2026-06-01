<?php

use yii\helpers\Html;
use yii\helpers\Url;

/**
 * Управление исполнителями задачи (руководитель).
 *
 * @var app\models\entities\WorkTask $model
 * @var array<int, string> $executors
 */

$assignedIds = $model->getExecutorIds();
$executorUsers = $model->isRelationPopulated('executors')
    ? $model->executors
    : [];
if ($executorUsers === [] && $assignedIds !== []) {
    $executorUsers = \app\models\entities\Users::find()
        ->where(['id' => $assignedIds])
        ->orderBy(['full_name' => SORT_ASC])
        ->all();
}

$availableExecutors = array_diff_key($executors, array_flip($assignedIds));
$addUrl = Url::to(['add-executor', 'id' => $model->id]);
$removeUrlTemplate = Url::to(['remove-executor', 'id' => $model->id, 'userId' => '__UID__']);
?>

<div class="work-task-view__executors-manage"
     id="workTaskExecutorsManage"
     data-add-url="<?= Html::encode($addUrl) ?>"
     data-remove-url-template="<?= Html::encode($removeUrlTemplate) ?>">
    <p class="work-task-view__executors-title">Исполнители</p>

    <ul class="work-task-view__executors-list list-unstyled mb-0" id="workTaskExecutorsList">
        <?php if ($executorUsers === []): ?>
        <li class="work-task-view__executors-empty text-muted" id="workTaskExecutorsEmpty">
            Исполнители не назначены
        </li>
        <?php else: ?>
            <?php foreach ($executorUsers as $user): ?>
            <li class="work-task-view__executor-item" data-user-id="<?= (int) $user->id ?>">
                <span class="work-task-view__executor-name"><?= Html::encode($user->full_name) ?></span>
                <button type="button"
                        class="btn btn-sm btn-outline-danger work-task-view__executor-remove"
                        data-work-task-remove-executor="<?= (int) $user->id ?>"
                        title="Снять исполнителя"
                        aria-label="Снять исполнителя <?= Html::encode($user->full_name) ?>">
                    <i class="fas fa-times" aria-hidden="true"></i>
                </button>
            </li>
            <?php endforeach; ?>
        <?php endif; ?>
    </ul>

    <div class="work-task-view__executors-add d-none" id="workTaskExecutorAddPanel">
        <?php if ($availableExecutors === []): ?>
        <p class="text-muted small mb-2">Все доступные сотрудники уже назначены.</p>
        <?php else: ?>
        <label class="visually-hidden" for="workTaskExecutorAddSelect">Новый исполнитель</label>
        <?= Html::dropDownList(
            'executor_id',
            null,
            $availableExecutors,
            [
                'id' => 'workTaskExecutorAddSelect',
                'class' => 'form-select js-user-select-search',
                'prompt' => 'Выберите сотрудника…',
                'data-placeholder' => 'Выберите сотрудника…',
            ]
        ) ?>
        <?php endif; ?>
        <div class="work-task-view__executors-add-actions">
            <?php if ($availableExecutors !== []): ?>
            <button type="button"
                    class="btn btn-primary btn-sm work-tasks-tool-btn"
                    id="workTaskExecutorAddConfirm">
                Добавить
            </button>
            <?php endif; ?>
            <button type="button"
                    class="btn btn-light btn-sm"
                    id="workTaskExecutorAddCancel">
                Отмена
            </button>
        </div>
    </div>

    <button type="button"
            class="btn btn-outline-primary btn-sm work-task-view__executors-add-btn"
            id="workTaskShowAddExecutor">
        <i class="fas fa-plus" aria-hidden="true"></i> Добавить исполнителя
    </button>
</div>
