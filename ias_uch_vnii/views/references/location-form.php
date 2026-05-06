<?php
use yii\helpers\Html;
use yii\widgets\ActiveForm;
/** @var app\models\entities\Location $model */
$this->title = $model->isNewRecord ? 'Добавить локацию' : 'Редактировать локацию';
$this->params['breadcrumbs'][] = ['label' => 'Справочники', 'url' => ['index']];
$this->params['breadcrumbs'][] = ['label' => 'Локации', 'url' => ['locations']];
$this->params['breadcrumbs'][] = $model->isNewRecord ? 'Добавить' : 'Редактировать';
?>
<div class="references-location-form">
    <h1><?= Html::encode($this->title) ?></h1>
    <?php $form = ActiveForm::begin(); ?>
    <?= $form->field($model, 'name')->textInput(['maxlength' => true]) ?>
    <?= $form->field($model, 'location_code')->textInput(['maxlength' => true]) ?>
    <?= $form->field($model, 'location_type')->dropDownList([
        'кабинет' => 'Кабинет',
        'склад' => 'Склад',
        'серверная' => 'Серверная',
        'лаборатория' => 'Лаборатория',
        'другое' => 'Другое',
    ]) ?>
    <?= $form->field($model, 'floor')->textInput(['type' => 'number']) ?>
    <?= $form->field($model, 'description')->textarea() ?>
    <?= $form->field($model, 'is_archived')->checkbox() ?>
    <div class="form-group">
        <?= Html::submitButton('Сохранить', ['class' => 'btn btn-primary']) ?>
        <?= Html::a('Отмена', ['locations'], ['class' => 'btn btn-secondary']) ?>
    </div>
    <?php ActiveForm::end(); ?>
</div>
