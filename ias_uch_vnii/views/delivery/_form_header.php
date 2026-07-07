<?php
/**
 * Поля шапки поставки внутри arm-view-card (форма уже открыта снаружи).
 *
 * @var yii\web\View $this
 * @var app\models\entities\EquipmentDelivery $model
 * @var string[] $supplierNames
 * @var bool $readOnly
 * @var yii\widgets\ActiveForm $form
 * @var array<int, array<string, mixed>> $attachments
 * @var bool $canEditAttachments
 */

use yii\helpers\Html;

$readOnly = $readOnly ?? false;
$datalistId = 'delivery-supplier-datalist-' . (int) $model->id;

$fieldOptions = [
    'options' => ['class' => 'arm-form-create__field'],
    'labelOptions' => ['class' => 'form-label'],
    'inputOptions' => ['class' => 'form-control'],
];
?>
<section class="arm-view-card arm-form-create__card h-100" aria-labelledby="delivery-section-main">
    <h2 id="delivery-section-main" class="arm-view-card__title">Основные сведения</h2>
    <div class="arm-view-card__body arm-form-create__card-fields">
        <div class="row g-3">
            <div class="col-md-6">
                <?= $form->field($model, 'name', [
                    'options' => ['class' => 'arm-form-create__field arm-form-create__field--wide'],
                ])->textInput([
                    'maxlength' => true,
                    'readonly' => $readOnly,
                    'placeholder' => 'Название поставки',
                ]) ?>
            </div>
            <div class="col-md-6">
                <?= $form->field($model, 'delivery_date', $fieldOptions)
                    ->input('date', ['readonly' => $readOnly]) ?>
            </div>
            <div class="col-12">
                <?= $form->field($model, 'supplier', ['options' => ['class' => 'arm-form-create__field mb-0']])
                    ->textInput([
                        'maxlength' => true,
                        'list' => $datalistId,
                        'readonly' => $readOnly,
                        'placeholder' => 'Поставщик',
                    ]) ?>
                <datalist id="<?= Html::encode($datalistId) ?>">
                    <?php foreach ($supplierNames as $name): ?>
                        <option value="<?= Html::encode($name) ?>"></option>
                    <?php endforeach; ?>
                </datalist>
            </div>
        </div>

        <?= $this->render('_card_attachments', [
            'model' => $model,
            'attachments' => $attachments ?? [],
            'canEditAttachments' => $canEditAttachments ?? false,
            'embedded' => true,
        ]) ?>
    </div>
</section>
