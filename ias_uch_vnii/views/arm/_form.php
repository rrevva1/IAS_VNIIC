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
?>

<div class="arm-form">
    <?php $form = ActiveForm::begin([
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

            <datalist id="arm-cpu-datalist">
                <?php foreach ($cpuModels as $cpuModel): ?>
                    <option value="<?= Html::encode($cpuModel) ?>"></option>
                <?php endforeach; ?>
            </datalist>

            <datalist id="arm-ram-datalist">
                <?php foreach ($ramModels as $ramModel): ?>
                    <option value="<?= Html::encode($ramModel) ?>"></option>
                <?php endforeach; ?>
            </datalist>

            <datalist id="arm-os-datalist">
                <?php foreach ($osModels as $osModel): ?>
                    <option value="<?= Html::encode($osModel) ?>"></option>
                <?php endforeach; ?>
            </datalist>

            <datalist id="arm-disk-datalist">
                <?php foreach ($diskModels as $diskModel): ?>
                    <option value="<?= Html::encode($diskModel) ?>"></option>
                <?php endforeach; ?>
            </datalist>

            <datalist id="arm-ip-datalist">
                <?php foreach ($ipAddresses as $ipAddress): ?>
                    <option value="<?= Html::encode($ipAddress) ?>"></option>
                <?php endforeach; ?>
            </datalist>

            <datalist id="arm-supplier-datalist">
                <?php foreach ($supplierNames as $supplierName): ?>
                    <option value="<?= Html::encode($supplierName) ?>"></option>
                <?php endforeach; ?>
                <?php if ($currentSupplier !== '' && !in_array($currentSupplier, $supplierNames, true)): ?>
                    <option value="<?= Html::encode($currentSupplier) ?>"></option>
                <?php endif; ?>
            </datalist>

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
                <?= Html::submitButton('Сохранить', ['class' => 'btn btn-success']) ?>
                <?= Html::a('Отмена', ['index'], ['class' => 'btn btn-outline-secondary']) ?>
            </div>
        </div>
    </div>

    <?php ActiveForm::end(); ?>
</div>

<?php
$pcFields = [
    ['name' => 'cpu', 'label' => 'Процессор (ЦП)', 'part' => 'ЦП', 'char' => 'Модель', 'widget' => 'cpu-datalist'],
    ['name' => 'ram', 'label' => 'Оперативная память (ОЗУ)', 'part' => 'ОЗУ', 'char' => 'Объём', 'widget' => 'ram-datalist'],
    ['name' => 'disk', 'label' => 'Накопители (диски)', 'part' => 'Накопитель', 'char' => 'Модель', 'widget' => 'disk-datalist-multi'],
    ['name' => 'hostname', 'label' => 'Имя компьютера', 'part' => 'ПК', 'char' => 'Имя ПК'],
    ['name' => 'ip', 'label' => 'IP-адрес', 'part' => 'ПК', 'char' => 'IP адрес', 'widget' => 'ip-datalist'],
    ['name' => 'os', 'label' => 'Операционная система', 'part' => 'ПК', 'char' => 'ОС', 'widget' => 'os-datalist'],
];
$fieldTemplates = [
    'АРМ' => $pcFields,
    'Системный блок' => $pcFields,
    'Ноутбук' => array_merge($pcFields, [
        ['name' => 'monitor', 'label' => 'Встроенный монитор (модель)', 'part' => 'Монитор', 'char' => 'Модель'],
        ['name' => 'screen_diagonal', 'label' => 'Диагональ экрана', 'part' => 'Монитор', 'char' => 'Диагональ экрана'],
    ]),
    'Моноблок' => array_merge($pcFields, [
        ['name' => 'monitor', 'label' => 'Встроенный монитор (модель)', 'part' => 'Монитор', 'char' => 'Модель'],
        ['name' => 'screen_diagonal', 'label' => 'Диагональ экрана', 'part' => 'Монитор', 'char' => 'Диагональ экрана'],
    ]),
    'Монитор' => [
        ['name' => 'monitor', 'label' => 'Модель монитора', 'part' => 'Монитор', 'char' => 'Модель'],
        ['name' => 'screen_diagonal', 'label' => 'Диагональ экрана', 'part' => 'Монитор', 'char' => 'Диагональ экрана'],
        ['name' => 'monitor_inv', 'label' => '№ монитора (инв.)', 'part' => 'Монитор', 'char' => '№ монитора'],
    ],
    'Принтер' => $orgTechFields,
    'МФУ' => $orgTechFields,
    'ИБП' => [
        ['name' => 'model', 'label' => 'Марка и модель ИБП', 'part' => 'Монитор', 'char' => 'Модель'],
    ],
];
$this->registerJs('
window.armFormFieldTemplates = ' . json_encode($fieldTemplates) . ';
window.armFormChars = ' . json_encode($chars) . ';
window.armFormOrgTech = ' . json_encode($orgTech) . ';
window.armFormCpuModels = ' . json_encode(array_values($cpuModels)) . ';
window.armFormRamModels = ' . json_encode(array_values($ramModels)) . ';
window.armFormOsModels = ' . json_encode(array_values($osModels)) . ';
window.armFormDiskModels = ' . json_encode(array_values($diskModels)) . ';
window.armFormIpAddresses = ' . json_encode(array_values($ipAddresses)) . ';
', \yii\web\View::POS_HEAD);
$this->registerJsFile(Url::to('@web/js/arm/form-dynamic.js'), ['depends' => ['yii\web\JqueryAsset'], 'position' => \yii\web\View::POS_END]);
$this->registerJsFile(Url::to('@web/js/arm/warranty-preview.js'), ['depends' => ['yii\web\JqueryAsset'], 'position' => \yii\web\View::POS_END]);
