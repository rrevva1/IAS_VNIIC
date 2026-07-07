<?php
/**
 * Состав поставки (строки техники).
 *
 * @var app\models\entities\EquipmentDeliveryLine[] $lines
 * @var int $lineId
 * @var bool $isDraft
 */

use yii\helpers\Html;
use yii\helpers\Json;

$lines = $lines ?? [];
?>
<section class="arm-view-card arm-form-create__card h-100" aria-labelledby="delivery-section-lines">
    <div class="delivery-view-card__head">
        <h2 id="delivery-section-lines" class="arm-view-card__title">Состав поставки</h2>
        <?php if ($isDraft): ?>
            <?= Html::button('<i class="fas fa-plus" aria-hidden="true"></i><span class="arm-btn-label">Добавить технику</span>', [
                'class' => 'btn btn-sm btn-primary arm-tool-btn',
                'id' => 'deliveryAddLineBtn',
                'type' => 'button',
            ]) ?>
        <?php endif; ?>
    </div>
    <div class="arm-view-card__body delivery-lines-card__body">
        <?php if ($lines === []): ?>
            <p class="text-muted small mb-0 px-1">Добавьте строку: тип техники и количество. Нажмите строку — в таблице «Техника» отобразятся единицы этого типа.</p>
        <?php else: ?>
            <table class="table table-sm table-hover delivery-lines-table mb-0">
                <thead>
                <tr>
                    <th>Тип</th>
                    <th>Склад</th>
                    <th class="text-end">Кол-во</th>
                </tr>
                </thead>
                <tbody>
                <?php foreach ($lines as $line): ?>
                    <tr class="delivery-line-row<?= (int) $line->id === $lineId ? ' is-active' : '' ?>"
                        data-line-id="<?= (int) $line->id ?>"
                        data-line='<?= Json::htmlEncode([
                            'id' => (int) $line->id,
                            'equipment_type' => $line->equipment_type,
                            'name' => $line->name,
                            'quantity' => (int) $line->quantity,
                            'description' => $line->description ?? '',
                            'warehouse_location_id' => (int) ($line->warehouse_location_id ?? 0),
                            'warranty_years' => $line->warranty_years,
                            'char_template' => $line->getCharTemplateData(),
                        ]) ?>'>
                        <td>
                            <button type="button" class="btn btn-link btn-sm p-0 delivery-line-select text-start">
                                <?= Html::encode($line->equipment_type) ?>
                            </button>
                            <div class="small text-muted"><?= Html::encode($line->name) ?></div>
                            <?php if ($line->warranty_years !== null && $line->warranty_years !== ''): ?>
                                <div class="small text-muted">Гарантия: <?= Html::encode($line->warranty_years) ?> лет</div>
                            <?php endif; ?>
                        </td>
                        <td class="small align-middle">
                            <?= Html::encode($line->warehouseLocation ? $line->warehouseLocation->name : '—') ?>
                        </td>
                        <td class="text-end align-middle"><?= (int) $line->quantity ?></td>
                    </tr>
                <?php endforeach; ?>
                </tbody>
            </table>
        <?php endif; ?>
    </div>
</section>
