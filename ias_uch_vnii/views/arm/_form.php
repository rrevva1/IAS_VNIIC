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
 */

use app\assets\UserSelectAsset;
use yii\helpers\Html;
use yii\widgets\ActiveForm;

UserSelectAsset::register($this);

$chars = $chars ?? [];
$equipmentTypes = $equipmentTypes ?? [];
$cpuModels = $cpuModels ?? [];
?>

<div class="arm-form">
    <?php $form = ActiveForm::begin(); ?>

    <?= $form->field($model, 'inventory_number')->textInput(['maxlength' => true]) ?>
    <?= $form->field($model, 'serial_number')->textInput(['maxlength' => true]) ?>

    <?= $form->field($model, 'name')->textInput([
        'maxlength' => true,
        'placeholder' => 'Например: ПК Lenovo ThinkCentre M720',
    ]) ?>

    <?= $form->field($model, 'equipment_type')->dropDownList($equipmentTypes, [
        'prompt' => '— выберите тип техники —',
        'id' => 'equipment-type-select',
        'required' => true,
    ]) ?>

    <datalist id="arm-cpu-datalist">
        <?php foreach ($cpuModels as $cpuModel): ?>
            <option value="<?= Html::encode($cpuModel) ?>"></option>
        <?php endforeach; ?>
    </datalist>

    <div id="dynamic-fields-block" style="display:none;" class="border rounded p-3 mb-3 bg-light">
        <h5 class="mb-3">Характеристики</h5>
        <div id="dynamic-fields-content"></div>
    </div>

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

    <?= $form->field($model, 'supplier')->textInput(['maxlength' => true]) ?>
    <?= $form->field($model, 'purchase_date')->input('date') ?>
    <?= $form->field($model, 'commissioning_date')->input('date') ?>
    <?= $form->field($model, 'warranty_until')->input('date') ?>

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

<?php
$pcFields = [
    ['name' => 'cpu', 'label' => 'Процессор (ЦП)', 'part' => 'ЦП', 'char' => 'Модель', 'widget' => 'cpu-datalist'],
    ['name' => 'ram', 'label' => 'Оперативная память (ОЗУ)', 'part' => 'ОЗУ', 'char' => 'Объём'],
    ['name' => 'disk', 'label' => 'Накопитель (тип, объём)', 'part' => 'Накопитель', 'char' => 'Объём'],
    ['name' => 'hostname', 'label' => 'Имя компьютера', 'part' => 'ПК', 'char' => 'Имя ПК'],
    ['name' => 'ip', 'label' => 'IP-адрес', 'part' => 'ПК', 'char' => 'IP адрес'],
    ['name' => 'os', 'label' => 'Операционная система', 'part' => 'ПК', 'char' => 'ОС'],
];
$fieldTemplates = [
    'Системный блок' => $pcFields,
    'Ноутбук' => array_merge($pcFields, [
        ['name' => 'monitor', 'label' => 'Встроенный монитор (модель)', 'part' => 'Монитор', 'char' => 'Модель'],
    ]),
    'Моноблок' => array_merge($pcFields, [
        ['name' => 'monitor', 'label' => 'Встроенный монитор (модель)', 'part' => 'Монитор', 'char' => 'Модель'],
    ]),
    'Монитор' => [
        ['name' => 'monitor', 'label' => 'Модель монитора', 'part' => 'Монитор', 'char' => 'Модель'],
        ['name' => 'diagonal', 'label' => 'Диагональ / инв. № монитора', 'part' => 'Монитор', 'char' => '№ монитора'],
    ],
    'Принтер' => [
        ['name' => 'model', 'label' => 'Модель принтера', 'part' => 'Монитор', 'char' => 'Модель'],
    ],
    'МФУ' => [
        ['name' => 'model', 'label' => 'Модель МФУ', 'part' => 'Монитор', 'char' => 'Модель'],
    ],
    'ИБП' => [
        ['name' => 'model', 'label' => 'Марка и модель ИБП', 'part' => 'Монитор', 'char' => 'Модель'],
    ],
];
$this->registerJs('
window.armFormFieldTemplates = ' . json_encode($fieldTemplates) . ';
window.armFormChars = ' . json_encode($chars) . ';
window.armFormCpuModels = ' . json_encode(array_values($cpuModels)) . ';
', \yii\web\View::POS_HEAD);
$this->registerJsFile(\yii\helpers\Url::to('@web/js/arm/form-dynamic.js'), ['depends' => ['yii\web\JqueryAsset'], 'position' => \yii\web\View::POS_END]);