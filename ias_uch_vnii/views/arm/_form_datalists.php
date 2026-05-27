<?php

use yii\helpers\Html;

/** @var string[] $cpuModels */
/** @var string[] $ramModels */
/** @var string[] $osModels */
/** @var string[] $diskModels */
/** @var string[] $ipAddresses */
/** @var string[] $supplierNames */
/** @var string $currentSupplier */
?>
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
