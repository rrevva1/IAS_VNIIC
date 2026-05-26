<?php

use yii\helpers\Html;

/** @var app\models\entities\WorkTask $task */
?>
<span class="work-task-card__time-in-status"
      title="<?= Html::encode($task->getTimeInStatusTitle()) ?>">
    <i class="far fa-clock" aria-hidden="true"></i>
    <?= Html::encode($task->getTimeInStatusLabel()) ?>
</span>
