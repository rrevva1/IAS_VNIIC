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
/** @var string[] $ipAddresses */
/** @var bool $isModal */

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
    'ПК' => $pcFields,
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
window.armFormDiskModels = ' . json_encode(array_values($diskModels), JSON_UNESCAPED_UNICODE) . ';
window.armFormIpAddresses = ' . json_encode(array_values($ipAddresses), JSON_UNESCAPED_UNICODE) . ';';

// jQuery .html() вырезает <script> — конфиг передаём в textarea (остаётся в DOM).
echo '<textarea id="arm-form-config-json" class="d-none" aria-hidden="true" tabindex="-1" readonly>'
    . htmlspecialchars($armFormConfigPayload, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8')
    . '</textarea>';

if ($isModal) {
    echo '<script>', $armFormVarsJs, '</script>';
} else {
    $this->registerJs($armFormVarsJs, \yii\web\View::POS_HEAD);
    $this->registerJsFile(Url::to('@web/js/arm/form-dynamic.js'), ['depends' => ['yii\web\JqueryAsset'], 'position' => \yii\web\View::POS_END]);
    $this->registerJsFile(Url::to('@web/js/arm/warranty-preview.js'), ['depends' => ['yii\web\JqueryAsset'], 'position' => \yii\web\View::POS_END]);
}
