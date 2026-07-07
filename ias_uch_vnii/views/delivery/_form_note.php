<?php
/**
 * Примечание к поставке (внутри формы шапки).
 *
 * @var app\models\entities\EquipmentDelivery $model
 * @var bool $readOnly
 * @var yii\widgets\ActiveForm $form
 */

$readOnly = $readOnly ?? false;
?>
<section class="arm-view-card arm-form-create__card delivery-section-note" aria-labelledby="delivery-section-note">
    <h2 id="delivery-section-note" class="arm-view-card__title">Примечание</h2>
    <div class="arm-view-card__body arm-form-create__card-fields">
        <?= $form->field($model, 'notes', ['options' => ['class' => 'arm-form-create__field mb-0']])
            ->textarea(['rows' => 3, 'readonly' => $readOnly, 'placeholder' => 'Комментарий к поставке'])
            ->label(false) ?>
    </div>
</section>
