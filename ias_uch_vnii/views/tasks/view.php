<?php

use app\assets\TasksAsset;

/**
 * @var yii\web\View $this
 * @var app\models\entities\Tasks $model
 * @var app\models\entities\TaskHistory[] $taskHistory
 */

TasksAsset::register($this);
$this->registerJs(
    "window.executorChangeUrl = " . json_encode(\yii\helpers\Url::to(['assign-executor', 'id' => $model->id])) . ';',
    \yii\web\View::POS_HEAD
);
?>

<div class="tasks-page tasks-page--detail">
    <?= $this->render('_view_content', [
        'model' => $model,
        'taskHistory' => $taskHistory,
        'isModal' => false,
    ]) ?>
</div>

<?= $this->render('_view_image_modal') ?>
