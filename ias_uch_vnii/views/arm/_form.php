<?php
/**
 * Форма создания/редактирования техники (АРМ).
 * @var yii\web\View $this
 * @var app\models\entities\Arm $model
 * @var array $users [id_user => name]
 * @var array $locations [id_location => name]
 */

use yii\helpers\Html;
use yii\widgets\ActiveForm;

?>

<div class="arm-form">
    <?php $form = ActiveForm::begin(); ?>

    <?= $form->field($model, 'name')->textInput([
        'maxlength' => true,
        'placeholder' => 'Например: ПК Lenovo ThinkCentre M720',
    ]) ?>

    <?= $form->field($model, 'id_user')->dropDownList($users, [
        'prompt' => 'Не закреплять',
    ]) ?>

    <?= $form->field($model, 'id_location')->dropDownList($locations, [
        'prompt' => 'Выберите местоположение',
    ]) ?>

    <?= $form->field($model, 'description')->textarea([
        'rows' => 4,
        'placeholder' => 'Комментарий, комплектация, серийные номера и т.п.',
    ]) ?>

    <div class="form-group">
        <?= Html::submitButton('Сохранить', ['class' => 'btn btn-success']) ?>
        <?= Html::a('Отмена', ['index'], ['class' => 'btn btn-default']) ?>
    </div>

    <?php ActiveForm::end(); ?>
</div>





