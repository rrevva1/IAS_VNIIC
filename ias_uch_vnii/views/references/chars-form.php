<?php
use yii\helpers\Html;
use yii\widgets\ActiveForm;
/** @var app\models\entities\SprChars $model */
$this->title = $model->isNewRecord ? 'Добавить характеристику' : 'Редактировать характеристику';
$this->params['breadcrumbs'][] = ['label' => 'Справочники', 'url' => ['index']];
$this->params['breadcrumbs'][] = ['label' => 'Характеристики', 'url' => ['chars']];
$this->params['breadcrumbs'][] = $model->isNewRecord ? 'Добавить' : 'Редактировать';
?>
<div class="references-chars-form">
    <h1><?= Html::encode($this->title) ?></h1>
    <?php $form = ActiveForm::begin(); ?>
    <?= $form->field($model, 'name')->textInput(['maxlength' => true]) ?>
    <?= $form->field($model, 'measurement_unit')->textInput(['maxlength' => true]) ?>
    <?= $form->field($model, 'description')->textarea() ?>
    <?= $form->field($model, 'is_archived')->checkbox() ?>
    <div class="form-group">
        <?= Html::submitButton('Сохранить', ['class' => 'btn btn-primary']) ?>
        <?= Html::a('Отмена', ['chars'], ['class' => 'btn btn-secondary']) ?>
    </div>
    <?php ActiveForm::end(); ?>
</div>
