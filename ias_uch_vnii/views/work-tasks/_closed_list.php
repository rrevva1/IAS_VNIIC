<?php

/** @var app\models\entities\WorkTask[] $closedTasks */
?>

<div class="work-tasks-closed-list" id="workTasksClosedList" role="list" aria-label="Закрытые задачи">
    <?php foreach ($closedTasks as $task): ?>
    <div role="listitem">
        <?= $this->render('_closed_item', ['task' => $task]) ?>
    </div>
    <?php endforeach; ?>
</div>
