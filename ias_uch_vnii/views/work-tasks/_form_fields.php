<?php

use yii\helpers\Html;
use yii\widgets\ActiveForm;

/** @var yii\widgets\ActiveForm $form */
/** @var app\models\entities\WorkTask $model */
/** @var array $executors */
/** @var array $requests */
?>

<?= $form->field($model, 'title')->textInput(['maxlength' => true, 'placeholder' => 'Краткое название']) ?>

<?= $form->field($model, 'description')->textarea(['rows' => 4, 'placeholder' => 'Что нужно сделать']) ?>

<?= $form->field($model, 'executor_id')->dropDownList($executors, [
    'prompt' => '— назначить позже —',
]) ?>

<?= $form->field($model, 'request_task_id')->dropDownList($requests, [
    'prompt' => '— без привязки к заявке —',
])->hint('Необязательно. При создании заявки задача появляется автоматически.') ?>
