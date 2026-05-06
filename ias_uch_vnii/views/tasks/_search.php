<?php

use yii\helpers\Html;
use yii\widgets\ActiveForm;

/* @var $this yii\web\View */
/* @var $model app\models\TasksSearch */
/* @var $form yii\widgets\ActiveForm */

?>

<div class="tasks-search">

    <?php $form = ActiveForm::begin([
        'action' => ['index'],
        'method' => 'get',
        'options' => [
            'data-pjax' => 1
        ],
    ]); ?>

    <div class="row">
        <div class="col-md-3">
            <?= $form->field($model, 'id') ?>
        </div>
        
        <div class="col-md-3">
            <?= $form->field($model, 'status_id')->dropDownList(
                \app\models\dictionaries\DicTaskStatus::getStatusList(),
                ['prompt' => 'Все статусы...']
            ) ?>
        </div>
        
        <div class="col-md-3">
            <?= $form->field($model, 'user_name') ?>
        </div>
        
        <div class="col-md-3">
            <?= $form->field($model, 'executor_name') ?>
        </div>
    </div>

    <div class="row">
        <div class="col-md-6">
            <?= $form->field($model, 'description') ?>
        </div>
        
        <div class="col-md-3">
            <?= $form->field($model, 'date_from')->input('date') ?>
        </div>
        
        <div class="col-md-3">
            <?= $form->field($model, 'date_to')->input('date') ?>
        </div>
    </div>

    <div class="form-group">
        <div class="row">
            <div class="col-md-12 text-center">
                <?= Html::submitButton('<i class="glyphicon glyphicon-search"></i> Поиск', [
                    'class' => 'btn btn-primary'
                ]) ?>
                
                <?= Html::a('<i class="glyphicon glyphicon-refresh"></i> Сбросить', ['index'], [
                    'class' => 'btn btn-default'
                ]) ?>
            </div>
        </div>
    </div>

    <?php ActiveForm::end(); ?>

</div>
