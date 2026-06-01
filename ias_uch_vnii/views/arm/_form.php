<?php
/**
 * Форма создания/редактирования техники (оборудование).
 * Умная форма: при выборе типа техники подгружаются специфичные поля.
 *
 * @var yii\web\View $this
 * @var app\models\entities\Equipment $model
 * @var array $users [id => name]
 * @var array $locations [id => name]
 * @var array $statuses [id => status_name]
 * @var array $chars [key => value] — текущие значения характеристик для редактирования
 * @var string[] $cpuModels — известные модели процессоров для подсказок
 * @var string[] $ramModels — известные значения ОЗУ для подсказок
 * @var string[] $osModels — известные ОС для подсказок
 * @var string[] $diskModels — известные накопители для подсказок
 * @var string[] $supplierNames — известные поставщики для подсказок
 * @var string[] $ipAddresses — известные IP-адреса для подсказок
 * @var bool $isModal форма в модальном окне
 */

use app\assets\UserSelectAsset;
use app\components\EquipmentCharCatalog;
use yii\helpers\Html;
use yii\helpers\Url;
use yii\widgets\ActiveForm;

UserSelectAsset::register($this);
$this->registerCssFile(Url::to('@web/css/arm/form.css'), ['depends' => [\yii\bootstrap5\BootstrapAsset::class]]);

$chars = $chars ?? [];
$equipmentTypes = $equipmentTypes ?? [];
$cpuModels = $cpuModels ?? [];
$ramModels = $ramModels ?? [];
$osModels = $osModels ?? [];
$diskModels = $diskModels ?? [];
$supplierNames = $supplierNames ?? [];
$ipAddresses = $ipAddresses ?? [];
$upsBatteryModels = $upsBatteryModels ?? [];
$inventoryNumbers = $inventoryNumbers ?? [];
$equipmentNames = $equipmentNames ?? [];
$screenDiagonalValues = $screenDiagonalValues ?? [];
$currentScreenDiagonal = trim((string) ($chars['screen_diagonal'] ?? ''));
$formPlaceholders = require __DIR__ . '/_form_create_placeholders.php';
$currentSupplier = trim((string) ($model->supplier ?? ''));
$currentInventoryNumber = trim((string) ($model->inventory_number ?? ''));
$currentEquipmentName = trim((string) ($model->name ?? ''));
$descriptionPlaceholder = $formPlaceholders['description'];
if (EquipmentCharCatalog::isPrinterOrMfuType($model->resolveEquipmentTypeName())) {
    $descriptionPlaceholder = $formPlaceholders['description_printer'];
}
$locationNames = array_values($locations ?? []);
$currentLocation = trim((string) ($model->location_name ?? ''));
if ($currentLocation === '' && $model->location) {
    $currentLocation = trim((string) $model->location->name);
}
$isModal = !empty($isModal);

$orgTech = [
    'cartridge_procurement' => '',
];
if (EquipmentCharCatalog::isPrinterOrMfuType($model->resolveEquipmentTypeName())) {
    $orgTech['cartridge_procurement'] = EquipmentCharCatalog::parseCartridgeProcurementCode($model->description);
    $model->description = EquipmentCharCatalog::formatPrinterComment($model->description);
}

$orgTechFields = array_merge(EquipmentCharCatalog::getPrinterMfuFormFieldDefinitions(), [
    [
        'name' => 'cartridge_procurement',
        'label' => 'Учёт для закупки картриджей',
        'widget' => 'cartridge-select',
    ],
]);

if ($isModal) {
    echo $this->render('_form_modal', [
        'model' => $model,
        'users' => $users,
        'locations' => $locations,
        'statuses' => $statuses ?? [],
        'equipmentTypes' => $equipmentTypes,
        'cpuModels' => $cpuModels,
        'ramModels' => $ramModels,
        'osModels' => $osModels,
        'diskModels' => $diskModels,
        'supplierNames' => $supplierNames,
        'ipAddresses' => $ipAddresses,
        'currentSupplier' => $currentSupplier,
        'locationNames' => $locationNames,
        'currentLocation' => $currentLocation,
        'upsBatteryModels' => $upsBatteryModels,
        'inventoryNumbers' => $inventoryNumbers,
        'currentInventoryNumber' => $currentInventoryNumber,
        'equipmentNames' => $equipmentNames,
        'currentEquipmentName' => $currentEquipmentName,
        'screenDiagonalValues' => $screenDiagonalValues,
        'currentScreenDiagonal' => $currentScreenDiagonal,
    ]);
    echo $this->render('_form_scripts', [
        'model' => $model,
        'chars' => $chars,
        'orgTech' => $orgTech,
        'orgTechFields' => $orgTechFields,
        'cpuModels' => $cpuModels,
        'ramModels' => $ramModels,
        'osModels' => $osModels,
        'diskModels' => $diskModels,
        'ipAddresses' => $ipAddresses,
        'isModal' => true,
    ]);

    return;
}

$formId = 'arm-equipment-form';
?>

<div class="arm-form">
    <?php $form = ActiveForm::begin([
        'id' => $formId,
        'options' => ['class' => 'arm-form__body'],
        'scrollToError' => false,
        'fieldConfig' => [
            'options' => ['class' => 'mb-3'],
            'labelOptions' => ['class' => 'form-label'],
            'inputOptions' => ['class' => 'form-control'],
        ],
    ]); ?>

    <div class="card shadow-sm border-0">
        <div class="card-body">
            <section class="arm-form-section">
                <h2 class="arm-form-section__title h6 text-uppercase text-muted">Основные сведения</h2>
                <?= $form->field($model, 'name')->textInput([
                    'maxlength' => true,
                    'list' => 'arm-name-datalist',
                    'autocomplete' => 'off',
                    'class' => 'form-control js-equipment-name-datalist',
                    'placeholder' => $formPlaceholders['name'],
                ]) ?>
                <?= $form->field($model, 'inventory_number')->textInput([
                    'maxlength' => true,
                    'list' => 'arm-inventory-datalist',
                    'autocomplete' => 'off',
                    'class' => 'form-control js-inventory-datalist',
                    'placeholder' => $formPlaceholders['inventory_number'],
                ]) ?>
                <?= $form->field($model, 'serial_number')->textInput([
                    'maxlength' => true,
                    'placeholder' => $formPlaceholders['serial_number'],
                ]) ?>
                <?= $form->field($model, 'equipment_type')->dropDownList($equipmentTypes, [
                    'prompt' => $formPlaceholders['equipment_type_prompt'],
                    'id' => 'equipment-type-select',
                    'required' => true,
                ]) ?>
            </section>

            <?= $this->render('_form_datalists', [
                'cpuModels' => $cpuModels,
                'ramModels' => $ramModels,
                'osModels' => $osModels,
                'diskModels' => $diskModels,
                'ipAddresses' => $ipAddresses,
                'supplierNames' => $supplierNames,
                'currentSupplier' => $currentSupplier,
                'locationNames' => $locationNames,
                'currentLocation' => $currentLocation,
                'upsBatteryModels' => $upsBatteryModels,
                'inventoryNumbers' => $inventoryNumbers,
                'currentInventoryNumber' => $currentInventoryNumber,
                'equipmentNames' => $equipmentNames,
                'currentEquipmentName' => $currentEquipmentName,
                'screenDiagonalValues' => $screenDiagonalValues,
                'currentScreenDiagonal' => $currentScreenDiagonal,
            ]) ?>

            <section id="dynamic-fields-block" class="arm-form-section arm-form-section--chars d-none">
                <h2 class="arm-form-section__title h6 text-uppercase text-muted">Характеристики</h2>
                <div id="dynamic-fields-content" class="arm-form-dynamic-fields"></div>
            </section>

            <section class="arm-form-section">
                <h2 class="arm-form-section__title h6 text-uppercase text-muted">Закрепление и статус</h2>
                <?= $form->field($model, 'responsible_user_id')->dropDownList($users, [
                    'prompt' => 'Не закреплять',
                    'class' => 'form-select js-user-select-search',
                    'data-placeholder' => $formPlaceholders['responsible_user'],
                ]) ?>
                <?= $form->field($model, 'location_name')->textInput([
                    'maxlength' => true,
                    'list' => 'arm-location-datalist',
                    'autocomplete' => 'off',
                    'id' => 'equipment-location-name',
                    'class' => 'form-control js-location-datalist',
                    'placeholder' => $formPlaceholders['location_name'],
                ]) ?>
                <?= $form->field($model, 'status_id')->dropDownList($statuses ?? [], [
                    'prompt' => $formPlaceholders['status'],
                    'class' => 'form-select js-user-select-search',
                    'data-placeholder' => $formPlaceholders['status'],
                ]) ?>
            </section>

            <section class="arm-form-section">
                <h2 class="arm-form-section__title h6 text-uppercase text-muted">Закупка и гарантия</h2>
                <?= $form->field($model, 'supplier')->textInput([
                    'maxlength' => true,
                    'list' => 'arm-supplier-datalist',
                    'autocomplete' => 'off',
                    'placeholder' => $formPlaceholders['supplier'],
                ]) ?>
                <div class="row g-3">
                    <div class="col-md-6">
                        <?= $form->field($model, 'purchase_date', ['options' => ['class' => 'mb-0']])->input('date', [
                            'id' => 'equipment-purchase-date',
                            'class' => 'form-control js-warranty-base-date',
                        ]) ?>
                    </div>
                    <div class="col-md-6">
                        <?= $form->field($model, 'warranty_years', ['options' => ['class' => 'mb-0']])->input('number', [
                            'id' => 'equipment-warranty-years',
                            'class' => 'form-control',
                            'min' => 0,
                            'max' => 50,
                            'step' => '0.5',
                            'placeholder' => $formPlaceholders['warranty_years'],
                        ]) ?>
                    </div>
                </div>
            </section>

            <section id="arm-form-description-section" class="arm-form-section">
                <h2 class="arm-form-section__title h6 text-uppercase text-muted">Примечание</h2>
                <?= $form->field($model, 'description', ['options' => ['class' => 'mb-0']])
                    ->label('Комментарий к технике')
                    ->textarea([
                    'rows' => 4,
                    'placeholder' => $descriptionPlaceholder,
                ]) ?>
            </section>

            <div class="arm-form-actions">
                <?= Html::submitButton('Сохранить', ['class' => 'btn btn-primary btn-success']) ?>
                <?= Html::a('Отмена', ['index'], ['class' => 'btn btn-outline-secondary']) ?>
            </div>
        </div>
    </div>

    <?php ActiveForm::end(); ?>
</div>

<?php
echo $this->render('_form_scripts', [
    'model' => $model,
    'chars' => $chars,
    'orgTech' => $orgTech,
    'orgTechFields' => $orgTechFields,
    'cpuModels' => $cpuModels,
    'ramModels' => $ramModels,
    'osModels' => $osModels,
    'diskModels' => $diskModels,
    'ipAddresses' => $ipAddresses,
    'isModal' => false,
]);
