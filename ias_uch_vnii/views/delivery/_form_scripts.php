<?php

use yii\helpers\Url;

/** @var yii\web\View $this */
/** @var array $chars */
/** @var array $orgTech */
/** @var array $orgTechFields */
/** @var string[] $cpuModels */
/** @var string[] $ramModels */
/** @var string[] $osModels */
/** @var string[] $diskModels */

$configPlaceholders = require Yii::getAlias('@app/views/arm/_form_config_field_placeholders.php');

$withPlaceholder = static function (array $field) use ($configPlaceholders): array {
    $name = (string) ($field['name'] ?? '');
    if ($name !== '' && isset($configPlaceholders[$name]) && !isset($field['placeholder'])) {
        $field['placeholder'] = $configPlaceholders[$name];
    }

    return $field;
};

$pcFields = array_map($withPlaceholder, [
    ['name' => 'cpu', 'label' => 'Процессор (ЦП)', 'part' => 'ЦП', 'char' => 'Модель', 'widget' => 'cpu-datalist'],
    ['name' => 'ram', 'label' => 'Оперативная память (ОЗУ)', 'part' => 'ОЗУ', 'char' => 'Объём', 'widget' => 'ram-datalist'],
    ['name' => 'disk', 'label' => 'Накопители (диски)', 'part' => 'Накопитель', 'char' => 'Модель', 'widget' => 'disk-datalist-multi'],
    ['name' => 'os', 'label' => 'Операционная система', 'part' => 'ПК', 'char' => 'ОС', 'widget' => 'os-datalist'],
]);
$portablePcFields = array_merge($pcFields, [
    $withPlaceholder([
        'name' => 'screen_diagonal',
        'label' => 'Диагональ экрана',
        'part' => 'Монитор',
        'char' => 'Диагональ экрана',
        'widget' => 'screen-diagonal-datalist',
    ]),
]);

$orgTechFields = array_map($withPlaceholder, $orgTechFields ?? []);

$fieldTemplates = [
    'ПК' => $pcFields,
    'Системный блок' => $pcFields,
    'Ноутбук' => $portablePcFields,
    'Моноблок' => $portablePcFields,
    'Монитор' => [
        $withPlaceholder([
            'name' => 'screen_diagonal',
            'label' => 'Диагональ экрана',
            'part' => 'Монитор',
            'char' => 'Диагональ экрана',
            'widget' => 'screen-diagonal-datalist',
        ]),
    ],
    'Принтер' => $orgTechFields,
    'МФУ' => $orgTechFields,
    'ИБП' => [
        $withPlaceholder([
            'name' => 'ups_battery',
            'label' => 'Модель аккумулятора',
            'part' => 'ИБП',
            'char' => 'Модель аккумулятора',
            'widget' => 'ups-battery-datalist',
        ]),
        $withPlaceholder([
            'name' => 'ups_battery_replaced_at',
            'label' => 'Дата замены аккумулятора',
            'part' => 'ИБП',
            'char' => 'Дата замены аккумулятора',
            'widget' => 'date',
        ]),
        $withPlaceholder([
            'name' => 'ups_battery_service_life',
            'label' => 'Срок службы аккумулятора, лет',
            'part' => 'ИБП',
            'char' => 'Срок службы аккумулятора',
            'widget' => 'number',
        ]),
    ],
];

$armFormConfigPayload = json_encode([
    'templates' => $fieldTemplates,
    'chars' => $chars,
    'orgTech' => $orgTech,
], JSON_UNESCAPED_UNICODE | JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT);

$armFormVarsJs = 'window.armFormFieldTemplates = ' . json_encode($fieldTemplates, JSON_UNESCAPED_UNICODE) . ';
window.armFormChars = ' . json_encode($chars, JSON_UNESCAPED_UNICODE) . ';
window.armFormOrgTech = ' . json_encode($orgTech, JSON_UNESCAPED_UNICODE) . ';
window.armFormCpuModels = ' . json_encode(array_values($cpuModels), JSON_UNESCAPED_UNICODE) . ';
window.armFormRamModels = ' . json_encode(array_values($ramModels), JSON_UNESCAPED_UNICODE) . ';
window.armFormOsModels = ' . json_encode(array_values($osModels), JSON_UNESCAPED_UNICODE) . ';
window.armFormDiskModels = ' . json_encode(array_values($diskModels), JSON_UNESCAPED_UNICODE) . ';';

echo '<textarea id="arm-form-config-json" class="d-none" aria-hidden="true" tabindex="-1" readonly>'
    . htmlspecialchars($armFormConfigPayload, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8')
    . '</textarea>';

$this->registerJs($armFormVarsJs, \yii\web\View::POS_HEAD);
$this->registerJsFile(Url::to('@web/js/arm/form-dynamic.js'), ['depends' => ['yii\web\JqueryAsset'], 'position' => \yii\web\View::POS_END]);
$this->registerJsFile(Url::to('@web/js/arm/warranty-preview.js'), ['depends' => ['yii\web\JqueryAsset'], 'position' => \yii\web\View::POS_END]);
