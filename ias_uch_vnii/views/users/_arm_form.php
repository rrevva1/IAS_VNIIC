<?php
/**
 * Форма добавления техники (оборудование) для пользователя
 * @var yii\web\View $this
 * @var app\models\entities\Equipment $model
 * @var array $locations [id => name]
 * @var array $statuses [id => status_name]
 * @var int $userId
 */

use yii\helpers\Html;
use yii\widgets\ActiveForm;

?>

<div class="arm-create-form">
    <?php $form = ActiveForm::begin([
        'action' => ['users/arm-create', 'userId' => $userId],
        'options' => ['data-pjax' => 0],
    ]); ?>

    <?= $form->field($model, 'responsible_user_id')->hiddenInput(['value' => (int)$userId])->label(false) ?>

    <?= $form->field($model, 'inventory_number')->textInput(['maxlength' => true, 'placeholder' => 'Инв. номер']) ?>

    <?= $form->field($model, 'name')->textInput(['maxlength' => true, 'placeholder' => 'Например: ПК Dell OptiPlex 7080']) ?>

    <?= $form->field($model, 'location_id')->dropDownList($locations, ['prompt' => 'Выберите местоположение']) ?>

    <?= $form->field($model, 'status_id')->dropDownList($statuses, ['prompt' => '']) ?>

    <?= $form->field($model, 'description')->textarea(['rows' => 3, 'placeholder' => 'Комментарий, комплектация']) ?>

    <div class="form-group">
        <?= Html::submitButton('Сохранить', ['class' => 'btn btn-success']) ?>
        <?= Html::a('Отмена', ['users/view', 'id' => $userId], ['class' => 'btn btn-default']) ?>
    </div>

    <?php ActiveForm::end(); ?>
</div>
