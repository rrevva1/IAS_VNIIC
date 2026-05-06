<?php
use yii\helpers\Html;
use yii\widgets\ActiveForm;
/** @var app\models\dictionaries\DicEquipmentStatus $model */
$this->title = $model->isNewRecord ? 'Добавить статус оборудования' : 'Редактировать статус оборудования';
$this->params['breadcrumbs'][] = ['label' => 'Справочники', 'url' => ['index']];
$this->params['breadcrumbs'][] = ['label' => 'Статусы оборудования', 'url' => ['equipment-status']];
$this->params['breadcrumbs'][] = $model->isNewRecord ? 'Добавить' : 'Редактировать';
?>
<div class="references-equipment-status-form">
    <h1><?= Html::encode($this->title) ?></h1>
    <?php $form = ActiveForm::begin(); ?>
    <?= $form->field($model, 'status_code')->textInput(['maxlength' => true]) ?>
    <?= $form->field($model, 'status_name')->textInput(['maxlength' => true]) ?>
    <?= $form->field($model, 'sort_order')->textInput(['type' => 'number']) ?>
    <?= $form->field($model, 'is_final')->checkbox() ?>
    <?= $form->field($model, 'is_archived')->checkbox() ?>
    <div class="form-group">
        <?= Html::submitButton('Сохранить', ['class' => 'btn btn-primary']) ?>
        <?= Html::a('Отмена', ['equipment-status'], ['class' => 'btn btn-secondary']) ?>
    </div>
    <?php ActiveForm::end(); ?>
</div>
