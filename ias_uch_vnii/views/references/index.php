<?php

use app\assets\SectionPageAsset;
use yii\helpers\Html;

SectionPageAsset::register($this);

$this->title = 'Справочники';
$this->params['breadcrumbs'] = [];

$items = [
    ['task-status', 'fas fa-list-check', 'Статусы заявок'],
    ['locations', 'fas fa-location-dot', 'Локации'],
    ['equipment-status', 'fas fa-circle-check', 'Статусы оборудования'],
    ['parts', 'fas fa-microchip', 'Типы частей (комплектующие)'],
    ['chars', 'fas fa-sliders', 'Характеристики'],
];
?>
<div class="arm-page references-hub-page">
    <header class="arm-page__header">
        <div class="arm-page__heading">
            <h1 class="arm-page__title"><?= Html::encode($this->title) ?></h1>
        </div>
    </header>

    <div class="arm-grid-card arm-content-panel">
        <ul class="ref-hub-list">
            <?php foreach ($items as [$route, $icon, $title]): ?>
            <li>
                <a class="ref-hub-card" href="<?= Html::encode(\yii\helpers\Url::to([$route])) ?>">
                    <span class="ref-hub-card__icon"><i class="<?= Html::encode($icon) ?>" aria-hidden="true"></i></span>
                    <span class="ref-hub-card__title"><?= Html::encode($title) ?></span>
                </a>
            </li>
            <?php endforeach; ?>
        </ul>
    </div>
</div>
