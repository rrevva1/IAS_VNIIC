<?php
use yii\helpers\Html;
use yii\widgets\ActiveForm;
/** @var app\models\entities\License $model */
/** @var app\models\entities\Software $software */
$this->title = $model->isNewRecord ? 'Добавить лицензию' : 'Редактировать лицензию';
$this->params['breadcrumbs'][] = ['label' => 'ПО и лицензии', 'url' => ['index']];
$this->params['breadcrumbs'][] = ['label' => $software->name, 'url' => ['view', 'id' => $software->id]];
$this->params['breadcrumbs'][] = $model->isNewRecord ? 'Добавить лицензию' : 'Редактировать';
?>
<div class="software-license-form">
    <h1><?= Html::encode($this->title) ?> — <?= Html::encode($software->name) ?></h1>
    <?php $form = ActiveForm::begin(); ?>
    <?= $form->field($model, 'valid_until')->input('date') ?>
    <?= $form->field($model, 'notes')->textarea() ?>
    <div class="form-group">
        <?= Html::submitButton('Сохранить', ['class' => 'btn btn-primary']) ?>
        <?= Html::a('Отмена', ['view', 'id' => $software->id], ['class' => 'btn btn-secondary']) ?>
    </div>
    <?php ActiveForm::end(); ?>
</div>
