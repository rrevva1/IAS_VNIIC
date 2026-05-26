<?php

use yii\helpers\Html;

/** @var app\models\entities\WorkTask $task */

$text = trim((string) $task->description);
if ($text === '') {
    return;
}
?>
<div class="work-task-card__desc-wrap">
    <p class="work-task-card__desc" title="<?= Html::encode($text) ?>"><?= Html::encode($text) ?></p>
</div>
