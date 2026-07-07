<?php

use yii\helpers\Html;

/** @var string[] $cpuModels */
/** @var string[] $ramModels */
/** @var string[] $osModels */
/** @var string[] $diskModels */
/** @var string[] $ipAddresses */
/** @var string[] $supplierNames */
/** @var string $currentSupplier */
/** @var string[] $locationNames */
/** @var string $currentLocation */
/** @var string[] $upsBatteryModels */
/** @var string[] $inventoryNumbers */
/** @var string $currentInventoryNumber */
/** @var string[] $equipmentNames */
/** @var string $currentEquipmentName */
/** @var string[] $screenDiagonalValues */
/** @var string $currentScreenDiagonal */
?>
<datalist id="arm-name-datalist">
    <?php foreach ($equipmentNames ?? [] as $equipmentName): ?>
        <option value="<?= Html::encode($equipmentName) ?>"></option>
    <?php endforeach; ?>
    <?php
    $currentEquipmentName = trim((string) ($currentEquipmentName ?? ''));
    if ($currentEquipmentName !== '' && !in_array($currentEquipmentName, $equipmentNames ?? [], true)):
        ?>
        <option value="<?= Html::encode($currentEquipmentName) ?>"></option>
    <?php endif; ?>
</datalist>
<datalist id="arm-inventory-datalist">
    <?php foreach ($inventoryNumbers ?? [] as $inventoryNumber): ?>
        <option value="<?= Html::encode($inventoryNumber) ?>"></option>
    <?php endforeach; ?>
    <?php
    $currentInventoryNumber = trim((string) ($currentInventoryNumber ?? ''));
    if ($currentInventoryNumber !== '' && !in_array($currentInventoryNumber, $inventoryNumbers ?? [], true)):
        ?>
        <option value="<?= Html::encode($currentInventoryNumber) ?>"></option>
    <?php endif; ?>
</datalist>
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
<datalist id="arm-screen-diagonal-datalist">
    <?php foreach ($screenDiagonalValues ?? [] as $screenDiagonalValue): ?>
        <option value="<?= Html::encode($screenDiagonalValue) ?>"></option>
    <?php endforeach; ?>
    <?php
    $currentScreenDiagonal = trim((string) ($currentScreenDiagonal ?? ''));
    if ($currentScreenDiagonal !== '' && !in_array($currentScreenDiagonal, $screenDiagonalValues ?? [], true)):
        ?>
        <option value="<?= Html::encode($currentScreenDiagonal) ?>"></option>
    <?php endif; ?>
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
    <?php foreach ($ipAddresses ?? [] as $ipAddress): ?>
        <option value="<?= Html::encode($ipAddress) ?>"></option>
    <?php endforeach; ?>
</datalist>
<datalist id="arm-location-datalist">
    <?php foreach ($locationNames ?? [] as $locationName): ?>
        <option value="<?= Html::encode($locationName) ?>"></option>
    <?php endforeach; ?>
    <?php
    $currentLocation = trim((string) ($currentLocation ?? ''));
    if ($currentLocation !== '' && !in_array($currentLocation, $locationNames ?? [], true)):
        ?>
        <option value="<?= Html::encode($currentLocation) ?>"></option>
    <?php endif; ?>
</datalist>
<datalist id="arm-ups-battery-datalist">
    <?php foreach ($upsBatteryModels ?? [] as $upsBatteryModel): ?>
        <option value="<?= Html::encode($upsBatteryModel) ?>"></option>
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
