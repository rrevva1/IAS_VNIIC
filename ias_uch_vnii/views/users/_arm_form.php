<?php
/**
 * Форма добавления техники (АРМ) для пользователя
 * @var yii\web\View $this
 * @var app\models\entities\Arm $model
 * @var array $locations
 * @var int $userId
 */

use yii\helpers\Html;
use yii\widgets\ActiveForm;

?>

<div class="arm-create-form">
    <?php $form = ActiveForm::begin([
        'action' => ['users/arm-create', 'userId' => $userId],
        'options' => [
            'data-pjax' => 0, // при необходимости можно заменить на 1 для PJAX
        ],
    ]); ?>

    <?php // Скрытое поле для назначения техники выбранному пользователю ?>
    <?= $form->field($model, 'id_user')->hiddenInput([ 'value' => (int)$userId ])->label(false) ?>

    <?php // Наименование техники ?>
    <?= $form->field($model, 'name')->textInput([ 'maxlength' => true, 'placeholder' => 'Например: ПК Dell OptiPlex 7080' ]) ?>

    <?php // Местоположение (кабинет/склад/и т.д.) ?>
    <?= $form->field($model, 'id_location')->dropDownList($locations, [ 'prompt' => 'Выберите местоположение' ]) ?>

    <?php // Описание/комментарий ?>
    <?= $form->field($model, 'description')->textarea([ 'rows' => 3, 'placeholder' => 'Комментарий, комплектация, серийные номера и т.п.' ]) ?>

    <div class="form-group">
        <?= Html::submitButton('Сохранить', ['class' => 'btn btn-success']) ?>
        <?= Html::a('Отмена', ['users/view', 'id' => $userId], ['class' => 'btn btn-default']) ?>
    </div>

    <?php ActiveForm::end(); ?>
</div>





