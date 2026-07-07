<?php

use yii\helpers\Url;

/** @var yii\web\View $this */
/** @var array $chars */
/** @var array $orgTech */
/** @var array<string, array<int, array<string, mixed>>> $armFormFieldTemplates */
/** @var string $armFormConfigPayload */
/** @var string[] $cpuModels */
/** @var string[] $ramModels */
/** @var string[] $osModels */
/** @var string[] $diskModels */
/** @var string[] $ipAddresses */
/** @var bool $isModal */

$armFormFieldTemplates = $armFormFieldTemplates ?? [];
$armFormConfigPayload = $armFormConfigPayload ?? '{"templates":{},"chars":{},"orgTech":{}}';

$jsonFlags = JSON_UNESCAPED_UNICODE | JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT | JSON_INVALID_UTF8_SUBSTITUTE;

$armFormVarsJs = 'window.armFormFieldTemplates = ' . json_encode($armFormFieldTemplates, $jsonFlags) . ';
window.armFormChars = ' . json_encode($chars, $jsonFlags) . ';
window.armFormOrgTech = ' . json_encode($orgTech, $jsonFlags) . ';
window.armFormCpuModels = ' . json_encode(array_values($cpuModels), JSON_UNESCAPED_UNICODE) . ';
window.armFormRamModels = ' . json_encode(array_values($ramModels), JSON_UNESCAPED_UNICODE) . ';
window.armFormOsModels = ' . json_encode(array_values($osModels), JSON_UNESCAPED_UNICODE) . ';
window.armFormDiskModels = ' . json_encode(array_values($diskModels), JSON_UNESCAPED_UNICODE) . ';
window.armFormIpAddresses = ' . json_encode(array_values($ipAddresses), JSON_UNESCAPED_UNICODE) . ';';

echo '<textarea id="arm-form-config-json" class="d-none" aria-hidden="true" tabindex="-1" readonly>'
    . htmlspecialchars($armFormConfigPayload, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8')
    . '</textarea>';

if (!$isModal) {
    $this->registerJs($armFormVarsJs, \yii\web\View::POS_HEAD);
    $this->registerJsFile(Url::to('@web/js/arm/form-dynamic.js'), ['depends' => ['yii\web\JqueryAsset'], 'position' => \yii\web\View::POS_END]);
    $this->registerJsFile(Url::to('@web/js/arm/warranty-preview.js'), ['depends' => ['yii\web\JqueryAsset'], 'position' => \yii\web\View::POS_END]);
}
