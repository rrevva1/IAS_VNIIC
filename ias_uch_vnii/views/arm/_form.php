<?php
/**
 * Форма создания/редактирования техники (оборудование).
 * @var yii\web\View $this
 * @var app\models\entities\Equipment $model
 * @var array $users [id => name]
 * @var array $locations [id => name]
 * @var array $statuses [id => status_name]
 */

use yii\helpers\Html;
use yii\widgets\ActiveForm;

?>

<div class="arm-form">
    <?php $form = ActiveForm::begin(); ?>

    <?= $form->field($model, 'inventory_number')->textInput(['maxlength' => true]) ?>

    <?= $form->field($model, 'name')->textInput([
        'maxlength' => true,
        'placeholder' => 'Например: ПК Lenovo ThinkCentre M720',
    ]) ?>

    <?= $form->field($model, 'responsible_user_id')->dropDownList($users, [
        'prompt' => 'Не закреплять',
    ]) ?>

    <?= $form->field($model, 'location_id')->dropDownList($locations, [
        'prompt' => 'Выберите местоположение',
    ]) ?>

    <?= $form->field($model, 'status_id')->dropDownList($statuses ?? [], ['prompt' => '']) ?>

    <?= $form->field($model, 'description')->textarea([
        'rows' => 4,
        'placeholder' => 'Комментарий, комплектация',
    ]) ?>

    <div class="form-group">
        <?= Html::submitButton('Сохранить', ['class' => 'btn btn-success']) ?>
        <?= Html::a('Отмена', ['index'], ['class' => 'btn btn-default']) ?>
    </div>

    <?php ActiveForm::end(); ?>
</div>
