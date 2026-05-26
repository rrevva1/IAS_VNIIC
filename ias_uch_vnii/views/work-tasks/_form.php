<?php

use yii\helpers\Html;
use yii\widgets\ActiveForm;

/** @var app\models\entities\WorkTask $model */
/** @var array $executors */
/** @var array $requests */
?>

<?php $form = ActiveForm::begin(['options' => ['class' => 'work-tasks-form']]); ?>

<?= $this->render('_form_fields', [
    'form' => $form,
    'model' => $model,
    'executors' => $executors,
    'requests' => $requests,
]) ?>

<div class="d-flex gap-2">
    <?= Html::submitButton('Создать', ['class' => 'btn btn-primary']) ?>
    <?= Html::a('Отмена', ['index'], ['class' => 'btn btn-outline-secondary']) ?>
</div>

<?php ActiveForm::end(); ?>
