<?php

use yii\helpers\Html;
use yii\helpers\Url;

/** @var app\models\entities\WorkTask $task */

$statusCode = $task->getStatusCode();
$statusLabel = $task->status ? $task->status->getDisplayName() : '—';
$completion = $task->getCompletionEventMeta();
$createdAt = Yii::$app->formatter->asDatetime($task->created_at, 'php:d.m.Y, H:i');
?>

<article class="work-tasks-closed-item work-task-card work-task-card--closed"
         data-task-id="<?= (int) $task->id ?>">
    <header class="work-tasks-closed-item__head">
        <div class="work-tasks-closed-item__title-wrap">
            <a href="#" class="work-tasks-closed-item__link" data-work-task-view="<?= (int) $task->id ?>">
                <span class="work-tasks-closed-item__id">#<?= (int) $task->id ?></span>
                <span class="work-tasks-closed-item__name"><?= Html::encode($task->title) ?></span>
            </a>
            <?php if ($task->status): ?>
            <span class="work-task-status work-task-status--<?= Html::encode($statusCode) ?>">
                <?= Html::encode($statusLabel) ?>
            </span>
            <?php endif; ?>
        </div>
        <div class="work-tasks-closed-item__dates">
            <?php if ($completion !== null && !empty($completion['at'])): ?>
            <span class="work-tasks-closed-item__date work-tasks-closed-item__date--main"
                  title="<?= Html::encode($completion['label']) ?>">
                <?= Html::encode($completion['label']) ?>:
                <?= Html::encode(Yii::$app->formatter->asDatetime($completion['at'], 'php:d.m.Y, H:i')) ?>
            </span>
            <?php endif; ?>
            <span class="work-tasks-closed-item__date work-tasks-closed-item__date--muted">
                Создана: <?= Html::encode($createdAt) ?>
            </span>
        </div>
    </header>

    <div class="work-tasks-closed-item__meta">
        <span><strong>Автор:</strong> <?= Html::encode($task->getAuthorName()) ?></span>
        <span><strong>Исполнитель:</strong>
            <?= $task->hasExecutor()
                ? Html::encode($task->getExecutorName())
                : Html::tag('span', 'Не назначен', ['class' => 'work-task-card__person-missing']) ?>
        </span>
        <?php if ($task->request_task_id): ?>
        <a href="<?= Url::to(['/tasks/view', 'id' => $task->request_task_id]) ?>"
           class="work-tasks-closed-item__request-link"
           target="_blank" rel="noopener">
            Заявка #<?= (int) $task->request_task_id ?>
        </a>
        <?php endif; ?>
    </div>

    <?php if (trim((string) $task->description) !== ''): ?>
    <p class="work-tasks-closed-item__desc"><?= Html::encode($task->description) ?></p>
    <?php endif; ?>

    <footer class="work-tasks-closed-item__footer">
        <a href="#"
           class="work-tasks-closed-item__open"
           data-work-task-view="<?= (int) $task->id ?>">
            Открыть карточку
        </a>
    </footer>
</article>
