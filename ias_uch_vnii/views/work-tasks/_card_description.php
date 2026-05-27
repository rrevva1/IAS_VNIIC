<?php

use yii\helpers\Html;

/** @var app\models\entities\WorkTask $task */

$text = trim((string) $task->description);
?>
<div class="work-task-card__desc-wrap">
    <?php if ($text !== ''): ?>
    <p class="work-task-card__desc" title="<?= Html::encode($text) ?>"><?= Html::encode($text) ?></p>
    <?php else: ?>
    <p class="work-task-card__desc work-task-card__desc--empty">Описание не указано</p>
    <?php endif; ?>
</div>
