<?php

use yii\helpers\Html;
use yii\helpers\Url;

/** @var app\models\entities\WorkTask $task */

$authorName = $task->getAuthorName();
$executorName = $task->getExecutorName();
$hasExecutor = $task->hasExecutor();
?>
<div class="work-task-card__people" role="group" aria-label="Участники задачи">
    <div class="work-task-card__person work-task-card__person--author">
        <span class="work-task-card__person-badge" aria-hidden="true">
            <i class="fas fa-user"></i>
        </span>
        <span class="work-task-card__person-body">
            <span class="work-task-card__person-label"><?= Html::encode($task->getAuthorLabel()) ?></span>
            <span class="work-task-card__person-name"><?= Html::encode($authorName) ?></span>
        </span>
    </div>
    <div class="work-task-card__person work-task-card__person--executor<?= $hasExecutor ? '' : ' work-task-card__person--empty' ?>">
        <span class="work-task-card__person-badge" aria-hidden="true">
            <i class="fas fa-user-check"></i>
        </span>
        <span class="work-task-card__person-body">
            <span class="work-task-card__person-label">Исполнитель</span>
            <span class="work-task-card__person-name work-task-card__executor-name">
                <?php if ($hasExecutor): ?>
                    <?= Html::encode($executorName) ?>
                <?php else: ?>
                    <span class="work-task-card__person-missing">Не назначен</span>
                <?php endif; ?>
            </span>
        </span>
    </div>
</div>
<?php if ($task->request_task_id): ?>
<p class="work-task-card__request">
    <a href="<?= Url::to(['/tasks/view', 'id' => $task->request_task_id]) ?>" class="work-task-card__request-link">
        Заявка #<?= (int) $task->request_task_id ?>
    </a>
</p>
<?php endif; ?>
