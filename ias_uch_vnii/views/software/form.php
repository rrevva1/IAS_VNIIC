<?php
use yii\helpers\Html;
use yii\widgets\ActiveForm;
/** @var app\models\entities\Software $model */
$this->title = $model->isNewRecord ? 'Добавить ПО' : 'Редактировать ПО';
$this->params['breadcrumbs'][] = ['label' => 'ПО и лицензии', 'url' => ['index']];
$this->params['breadcrumbs'][] = $model->isNewRecord ? 'Добавить' : 'Редактировать';
?>
<div class="software-form">
    <h1><?= Html::encode($this->title) ?></h1>
    <?php $form = ActiveForm::begin(); ?>
    <?= $form->field($model, 'name')->textInput(['maxlength' => true]) ?>
    <?= $form->field($model, 'version')->textInput(['maxlength' => true]) ?>
    <div class="form-group">
        <?= Html::submitButton('Сохранить', ['class' => 'btn btn-primary']) ?>
        <?= Html::a('Отмена', $model->isNewRecord ? ['index'] : ['view', 'id' => $model->id], ['class' => 'btn btn-secondary']) ?>
    </div>
    <?php ActiveForm::end(); ?>
</div>
