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
$currentSupplier = trim((string) ($model->supplier ?? ''));
$isModal = !empty($isModal);

$orgTech = [
    'cartridge_procurement' => '',
    'printer_comment' => '',
];
if (EquipmentCharCatalog::isPrinterOrMfuType($model->resolveEquipmentTypeName())) {
    $orgTech['cartridge_procurement'] = EquipmentCharCatalog::parseCartridgeProcurementCode($model->description);
    $orgTech['printer_comment'] = EquipmentCharCatalog::formatPrinterComment($model->description);
}

$orgTechFields = [
    ['name' => 'ip', 'label' => 'IP-адрес / подключение', 'part' => 'Принтер', 'char' => 'IP адрес', 'widget' => 'ip-datalist'],
    [
        'name' => 'cartridge_procurement',
        'label' => 'Учёт для закупки картриджей',
        'widget' => 'cartridge-select',
    ],
    ['name' => 'printer_comment', 'label' => 'Комментарий', 'widget' => 'printer-comment'],
];

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
                    'placeholder' => 'Например: ПК Lenovo ThinkCentre M720',
                ]) ?>
                <?= $form->field($model, 'inventory_number')->textInput(['maxlength' => true]) ?>
                <?= $form->field($model, 'serial_number')->textInput(['maxlength' => true]) ?>
                <?= $form->field($model, 'equipment_type')->dropDownList($equipmentTypes, [
                    'prompt' => '— выберите тип техники —',
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
                    'data-placeholder' => 'Не закреплять',
                ]) ?>
                <?= $form->field($model, 'location_id')->dropDownList($locations, [
                    'prompt' => 'Выберите местоположение',
                ]) ?>
                <?= $form->field($model, 'status_id')->dropDownList($statuses ?? [], [
                    'prompt' => '— выберите статус —',
                ]) ?>
            </section>

            <section class="arm-form-section">
                <h2 class="arm-form-section__title h6 text-uppercase text-muted">Закупка и гарантия</h2>
                <?= $form->field($model, 'supplier')->textInput([
                    'maxlength' => true,
                    'list' => 'arm-supplier-datalist',
                    'autocomplete' => 'off',
                    'placeholder' => 'Выберите из списка или введите поставщика вручную',
                ])->hint('Можно выбрать известного поставщика или указать нового — он сохранится в учёте.') ?>
                <div class="row g-3">
                    <div class="col-md-4">
                        <?= $form->field($model, 'purchase_date', ['options' => ['class' => 'mb-0']])->input('date', [
                            'id' => 'equipment-purchase-date',
                            'class' => 'form-control js-warranty-base-date',
                        ]) ?>
                    </div>
                    <div class="col-md-4">
                        <?= $form->field($model, 'commissioning_date', ['options' => ['class' => 'mb-0']])->input('date', [
                            'id' => 'equipment-commissioning-date',
                            'class' => 'form-control js-warranty-base-date',
                        ]) ?>
                    </div>
                    <div class="col-md-4">
                        <?= $form->field($model, 'warranty_years', ['options' => ['class' => 'mb-0']])->input('number', [
                            'id' => 'equipment-warranty-years',
                            'class' => 'form-control',
                            'min' => 0,
                            'max' => 50,
                            'step' => '0.5',
                            'placeholder' => 'Например: 3',
                        ]) ?>
                        <div id="equipment-warranty-until-preview" class="form-text text-muted mt-1"></div>
                    </div>
                </div>
            </section>

            <section id="arm-form-description-section" class="arm-form-section">
                <h2 class="arm-form-section__title h6 text-uppercase text-muted">Примечание</h2>
                <?= $form->field($model, 'description', ['options' => ['class' => 'mb-0']])->textarea([
                    'rows' => 4,
                    'placeholder' => 'Комментарий, комплектация',
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
