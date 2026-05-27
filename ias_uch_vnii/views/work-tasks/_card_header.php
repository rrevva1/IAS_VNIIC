<?php

use yii\helpers\Html;

/** @var app\models\entities\WorkTask $task */
?>
<header class="work-task-card__head">
    <a href="#" class="work-task-card__link" data-work-task-view="<?= (int) $task->id ?>">
        <span class="work-task-card__id">#<?= (int) $task->id ?></span>
        <span class="work-task-card__name"><?= Html::encode($task->title) ?></span>
    </a>
    <div class="work-task-card__time-slot">
        <?= $this->render('_card_time_in_status', ['task' => $task]) ?>
    </div>
</header>
