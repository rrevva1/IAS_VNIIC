<?php

use yii\helpers\Html;
use yii\widgets\ActiveForm;

/** @var app\models\entities\License $model */
/** @var app\models\entities\Software $software */
/** @var string[] $supplierNames */

$supplierNames = $supplierNames ?? [];
$this->title = $model->isNewRecord ? 'Добавить лицензию' : 'Редактировать лицензию';
$this->params['breadcrumbs'][] = ['label' => 'Лицензии ПО', 'url' => ['index']];
$this->params['breadcrumbs'][] = ['label' => $software->name, 'url' => ['view', 'id' => $software->id]];
$this->params['breadcrumbs'][] = $model->isNewRecord ? 'Добавить лицензию' : 'Редактировать';
?>
<div class="software-license-form">
    <h1><?= Html::encode($this->title) ?> — <?= Html::encode($software->name) ?></h1>
    <?php $form = ActiveForm::begin(); ?>
    <?= $form->field($model, 'supplier')->textInput([
        'maxlength' => true,
        'list' => 'software-license-supplier-datalist',
        'autocomplete' => 'off',
    ]) ?>
    <?= $form->field($model, 'purchase_date')->input('date') ?>
    <div class="row">
        <div class="col-md-6"><?= $form->field($model, 'valid_from')->input('date') ?></div>
        <div class="col-md-6"><?= $form->field($model, 'validity_years')->input('number', [
            'min' => 0.5,
            'max' => 100,
            'step' => 0.5,
            'disabled' => $model->isPerpetual(),
        ]) ?></div>
    </div>
    <?= $form->field($model, 'is_perpetual')->checkbox() ?>
    <?= $form->field($model, 'notes')->textarea() ?>
    <datalist id="software-license-supplier-datalist">
        <?php foreach ($supplierNames as $supplierName): ?>
            <option value="<?= Html::encode($supplierName) ?>"></option>
        <?php endforeach; ?>
    </datalist>
    <div class="form-group">
        <?= Html::submitButton('Сохранить', ['class' => 'btn btn-primary']) ?>
        <?= Html::a('Отмена', ['view', 'id' => $software->id], ['class' => 'btn btn-secondary']) ?>
    </div>
    <?php ActiveForm::end(); ?>
</div>
