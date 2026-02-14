<?php
use yii\helpers\Html;
use yii\widgets\ActiveForm;
/** @var app\models\entities\EquipmentSoftware $model */
/** @var app\models\entities\Software $software */
/** @var array $equipmentItems */
$this->title = 'Добавить установку на оборудование';
$this->params['breadcrumbs'][] = ['label' => 'ПО и лицензии', 'url' => ['index']];
$this->params['breadcrumbs'][] = ['label' => $software->name, 'url' => ['view', 'id' => $software->id]];
$this->params['breadcrumbs'][] = $this->title;
?>
<div class="software-equipment-software-form">
    <h1><?= Html::encode($this->title) ?> — <?= Html::encode($software->name) ?></h1>
    <?php $form = ActiveForm::begin(); ?>
    <?= $form->field($model, 'equipment_id')->dropDownList($equipmentItems, ['prompt' => 'Выберите оборудование']) ?>
    <?= $form->field($model, 'installed_at')->input('date') ?>
    <div class="form-group">
        <?= Html::submitButton('Сохранить', ['class' => 'btn btn-primary']) ?>
        <?= Html::a('Отмена', ['view', 'id' => $software->id], ['class' => 'btn btn-secondary']) ?>
    </div>
    <?php ActiveForm::end(); ?>
</div>
