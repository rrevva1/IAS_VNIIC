<?php

use app\components\EquipmentCharCatalog;
use app\models\entities\Location;
use yii\helpers\Html;

/** @var yii\web\View $this */
/** @var app\models\entities\Users|null $user */
/** @var app\models\entities\Equipment[] $equipment */
/** @var bool $isModal */

$equipment = $equipment ?? [];
$count = count($equipment);

$resolveStatusTone = static function (?string $statusCode, string $statusName): string {
    $code = mb_strtolower(trim((string) $statusCode), 'UTF-8');
    $byCode = [
        'in_use' => 'green',
        'in_repair' => 'yellow',
        'writeoff' => 'red',
        'in_stock' => 'gray',
        'archived' => 'gray',
    ];
    if ($code !== '' && isset($byCode[$code])) {
        return $byCode[$code];
    }

    $name = mb_strtolower(trim($statusName), 'UTF-8');
    if (str_contains($name, 'эксплуатац')) {
        return 'green';
    }
    if (str_contains($name, 'ремонт')) {
        return 'yellow';
    }
    if (str_contains($name, 'списан')) {
        return 'red';
    }
    if (str_contains($name, 'склад') || str_contains($name, 'резерв')) {
        return 'gray';
    }

    return 'gray';
};
?>
<div class="uec-user-equipment" data-user-id="<?= $user ? (int) $user->id : 0 ?>">
    <?php if ($user): ?>
        <div class="uec-user-equipment__hero">
            <div class="uec-user-equipment__hero-text">
                <span class="uec-user-equipment__hero-label">Ответственный</span>
                <strong class="uec-user-equipment__hero-name"><?= Html::encode($user->getDisplayName()) ?></strong>
                <?php if (trim((string) ($user->department ?? '')) !== ''): ?>
                    <span class="uec-user-equipment__hero-meta"><?= Html::encode($user->department) ?></span>
                <?php endif; ?>
            </div>
            <div class="uec-user-equipment__hero-stat" aria-label="Количество единиц техники">
                <span class="uec-user-equipment__hero-stat-value"><?= (int) $count ?></span>
                <span class="uec-user-equipment__hero-stat-label"><?= $count === 1 ? 'единица' : ($count >= 2 && $count <= 4 ? 'единицы' : 'единиц') ?></span>
            </div>
        </div>
    <?php endif; ?>

    <?php if ($equipment === []): ?>
        <div class="uec-user-equipment__empty" role="status">
            <div class="uec-user-equipment__empty-icon" aria-hidden="true">
                <i class="fas fa-box-open"></i>
            </div>
            <p class="uec-user-equipment__empty-title">Техника не закреплена</p>
            <p class="uec-user-equipment__empty-text">За выбранным пользователем нет активных записей в учёте ТС.</p>
        </div>
    <?php else: ?>
        <ul class="uec-equipment-list">
            <?php foreach ($equipment as $eq): ?>
                <?php
                $typeName = trim((string) ($eq->resolveEquipmentTypeName() ?? ''));
                $locationLabel = $eq->location
                    ? $eq->location->getDisplayLabel()
                    : Location::formatDisplayLabel(null);
                $status = $eq->equipmentStatus;
                $statusName = $status ? (string) $status->status_name : '—';
                $statusCode = $status ? (string) $status->status_code : '';
                $statusTone = $resolveStatusTone($statusCode, $statusName);
                $title = trim((string) ($eq->name ?? ''));
                if ($title === '') {
                    $title = 'Без названия';
                }
                $iconClass = EquipmentCharCatalog::resolveEquipmentTypeIconClass(
                    $typeName !== '' ? $typeName : null,
                    $eq->inventory_number
                );
                $inventory = trim((string) ($eq->inventory_number ?? ''));
                $serial = trim((string) ($eq->serial_number ?? ''));
                ?>
                <li class="uec-equipment-card">
                    <div class="uec-equipment-card__icon" aria-hidden="true">
                        <i class="fas <?= Html::encode($iconClass) ?>"></i>
                    </div>
                    <div class="uec-equipment-card__main">
                        <a href="#" class="uec-equipment-card__title arm-link-to-card"
                           data-arm-view="<?= (int) $eq->id ?>"
                           title="Открыть карточку техники">
                            <?= Html::encode($title) ?>
                        </a>
                        <div class="uec-equipment-card__meta">
                            <?php if ($typeName !== ''): ?>
                                <span class="uec-equipment-card__chip"><?= Html::encode($typeName) ?></span>
                            <?php endif; ?>
                            <?php if ($inventory !== ''): ?>
                                <span class="uec-equipment-card__meta-item">
                                    <i class="fas fa-barcode" aria-hidden="true"></i>
                                    <?= Html::encode($inventory) ?>
                                </span>
                            <?php endif; ?>
                            <?php if ($serial !== ''): ?>
                                <span class="uec-equipment-card__meta-item">
                                    <i class="fas fa-fingerprint" aria-hidden="true"></i>
                                    <?= Html::encode($serial) ?>
                                </span>
                            <?php endif; ?>
                        </div>
                    </div>
                    <div class="uec-equipment-card__aside">
                        <?php if ($statusName !== '' && $statusName !== '—'): ?>
                            <span class="arm-status-badge arm-status-badge--<?= Html::encode($statusTone) ?>">
                                <?= Html::encode($statusName) ?>
                            </span>
                        <?php endif; ?>
                        <?php if ($locationLabel !== '' && $locationLabel !== '—'): ?>
                            <span class="uec-equipment-card__location" title="Местоположение">
                                <i class="fas fa-location-dot" aria-hidden="true"></i>
                                <?= Html::encode($locationLabel) ?>
                            </span>
                        <?php endif; ?>
                    </div>
                </li>
            <?php endforeach; ?>
        </ul>
    <?php endif; ?>
</div>
