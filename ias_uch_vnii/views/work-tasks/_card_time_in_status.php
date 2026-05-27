<?php

use yii\helpers\Html;

/** @var app\models\entities\WorkTask $task */

$meta = $task->getCardTimeMeta();
$iconClass = $meta['is_completion'] ? 'far fa-calendar-alt' : 'far fa-clock';
?>
<span class="work-task-card__time-in-status<?= $meta['is_completion'] ? ' work-task-card__time-in-status--completion' : '' ?>"
      title="<?= Html::encode($meta['title']) ?>">
    <i class="<?= $iconClass ?>" aria-hidden="true"></i>
    <?= Html::encode($meta['label']) ?>
</span>
