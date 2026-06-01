<?php

use yii\helpers\Html;
use yii\helpers\Url;

/** @var app\models\entities\WorkTask $task */

$authorName = $task->getAuthorName();
$hasExecutor = $task->hasExecutor();
?>
<div class="work-task-card__people" role="group" aria-label="Участники задачи">
    <div class="work-task-card__person work-task-card__person--author">
        <span class="work-task-card__person-label">Автор</span>
        <span class="work-task-card__person-name"><?= Html::encode($authorName) ?></span>
    </div>
    <?php if ($hasExecutor):
        $executorNames = $task->getExecutorNames();
        $executorLabel = count($executorNames) > 1 ? 'Исполнители' : 'Исполнитель';
    ?>
    <div class="work-task-card__person work-task-card__person--executor<?= count($executorNames) > 1 ? ' work-task-card__person--executors-multi' : '' ?>">
        <span class="work-task-card__person-label"><?= Html::encode($executorLabel) ?></span>
        <?php if (count($executorNames) === 1): ?>
        <span class="work-task-card__person-name work-task-card__executor-name"><?= Html::encode($executorNames[0]) ?></span>
        <?php else: ?>
        <ul class="work-task-card__executor-names list-unstyled mb-0">
            <?php foreach ($executorNames as $name): ?>
            <li class="work-task-card__person-name work-task-card__executor-name"><?= Html::encode($name) ?></li>
            <?php endforeach; ?>
        </ul>
        <?php endif; ?>
    </div>
    <?php endif; ?>
</div>
<?php if ($task->request_task_id): ?>
<footer class="work-task-card__footer">
    <a href="<?= Url::to(['/tasks/view', 'id' => $task->request_task_id]) ?>" class="work-task-card__request-link"
       title="Заявка №<?= (int) $task->request_task_id ?>">
        Перейти к заявке
    </a>
</footer>
<?php endif; ?>
