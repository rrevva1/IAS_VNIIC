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
 */

use yii\helpers\Html;
use yii\widgets\ActiveForm;

$chars = $chars ?? [];
$equipmentTypes = $equipmentTypes ?? [];
?>

<div class="arm-form">
    <?php $form = ActiveForm::begin(); ?>

    <?= $form->field($model, 'inventory_number')->textInput(['maxlength' => true]) ?>
    <?= $form->field($model, 'serial_number')->textInput(['maxlength' => true]) ?>

    <?= $form->field($model, 'name')->textInput([
        'maxlength' => true,
        'placeholder' => 'Например: ПК Lenovo ThinkCentre M720',
    ]) ?>

    <?= $form->field($model, 'equipment_type_id')->dropDownList($equipmentTypes, [
        'prompt' => 'Выберите тип техники',
        'id' => 'equipment-type-select',
    ]) ?>

    <div id="dynamic-fields-block" style="display:none;" class="border rounded p-3 mb-3 bg-light">
        <h5 class="mb-3">Характеристики</h5>
        <div id="dynamic-fields-content"></div>
    </div>

    <?= $form->field($model, 'responsible_user_id')->dropDownList($users, [
        'prompt' => 'Не закреплять',
    ]) ?>

    <?= $form->field($model, 'location_id')->dropDownList($locations, [
        'prompt' => 'Выберите местоположение',
    ]) ?>

    <?= $form->field($model, 'status_id')->dropDownList($statuses ?? [], ['prompt' => '']) ?>

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
$fieldTemplates = [
    'Системный блок' => [
        ['name' => 'cpu', 'label' => 'Процессор (ЦП)', 'part' => 'ЦП', 'char' => 'Модель'],
        ['name' => 'ram', 'label' => 'Оперативная память (ОЗУ)', 'part' => 'ОЗУ', 'char' => 'Объём'],
        ['name' => 'disk', 'label' => 'Накопитель (тип, объём)', 'part' => 'Накопитель', 'char' => 'Объём'],
        ['name' => 'hostname', 'label' => 'Имя ПК', 'part' => 'ПК', 'char' => 'Имя ПК'],
        ['name' => 'ip', 'label' => 'IP адрес', 'part' => 'ПК', 'char' => 'IP адрес'],
        ['name' => 'os', 'label' => 'ОС', 'part' => 'ПК', 'char' => 'ОС'],
    ],
    'Монитор' => [
        ['name' => 'monitor', 'label' => 'Модель / № монитора', 'part' => 'Монитор', 'char' => 'Модель'],
        ['name' => 'diagonal', 'label' => 'Диагональ', 'part' => 'Монитор', 'char' => 'Объём'],
    ],
    'Ноутбук' => [
        ['name' => 'cpu', 'label' => 'Процессор', 'part' => 'ЦП', 'char' => 'Модель'],
        ['name' => 'ram', 'label' => 'ОЗУ', 'part' => 'ОЗУ', 'char' => 'Объём'],
        ['name' => 'disk', 'label' => 'Накопитель', 'part' => 'Накопитель', 'char' => 'Объём'],
        ['name' => 'monitor', 'label' => 'Монитор (встроенный)', 'part' => 'Монитор', 'char' => 'Модель'],
        ['name' => 'hostname', 'label' => 'Имя ПК', 'part' => 'ПК', 'char' => 'Имя ПК'],
        ['name' => 'ip', 'label' => 'IP адрес', 'part' => 'ПК', 'char' => 'IP адрес'],
        ['name' => 'os', 'label' => 'ОС', 'part' => 'ПК', 'char' => 'ОС'],
    ],
    'Моноблок' => [
        ['name' => 'cpu', 'label' => 'Процессор', 'part' => 'ЦП', 'char' => 'Модель'],
        ['name' => 'ram', 'label' => 'ОЗУ', 'part' => 'ОЗУ', 'char' => 'Объём'],
        ['name' => 'disk', 'label' => 'Накопитель', 'part' => 'Накопитель', 'char' => 'Объём'],
        ['name' => 'monitor', 'label' => 'Монитор (встроенный)', 'part' => 'Монитор', 'char' => 'Модель'],
        ['name' => 'hostname', 'label' => 'Имя ПК', 'part' => 'ПК', 'char' => 'Имя ПК'],
        ['name' => 'ip', 'label' => 'IP адрес', 'part' => 'ПК', 'char' => 'IP адрес'],
        ['name' => 'os', 'label' => 'ОС', 'part' => 'ПК', 'char' => 'ОС'],
    ],
    'Принтер' => [
        ['name' => 'model', 'label' => 'Модель', 'part' => 'Монитор', 'char' => 'Модель'],
    ],
    'МФУ' => [
        ['name' => 'model', 'label' => 'Модель', 'part' => 'Монитор', 'char' => 'Модель'],
    ],
];
$this->registerJs('
window.armFormFieldTemplates = ' . json_encode($fieldTemplates) . ';
window.armFormChars = ' . json_encode($chars) . ';
', \yii\web\View::POS_HEAD);
$this->registerJsFile(\yii\helpers\Url::to('@web/js/arm/form-dynamic.js'), ['depends' => ['yii\web\JqueryAsset'], 'position' => \yii\web\View::POS_END]);