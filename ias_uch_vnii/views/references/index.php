<?php

use app\assets\ReferencesPageAsset;
use yii\helpers\Html;

ReferencesPageAsset::register($this);

$this->title = 'Справочники';
$this->params['breadcrumbs'] = [];
?>
<div class="arm-page references-page references-hub-page">
    <header class="arm-page__header">
        <div class="arm-page__heading">
            <h1 class="arm-page__title"><?= Html::encode($this->title) ?></h1>
        </div>
    </header>

    <div class="arm-command-bar references-hub-command-bar" role="region" aria-label="Разделы справочников">
        <?= $this->render('_hub_tabs', ['activeRoute' => 'index']) ?>
    </div>

    <div class="arm-grid-card arm-content-panel">
        <p class="arm-content-panel__lead">
            Выберите справочник во вкладках выше. Создание и изменение записей выполняется в модальных окнах на странице списка.
        </p>
        <ul class="ref-hub-list">
            <?php
            $items = [
                ['task-status', 'fas fa-list-check', 'Статусы заявок'],
                ['locations', 'fas fa-location-dot', 'Локации'],
                ['equipment-status', 'fas fa-circle-check', 'Статусы оборудования'],
                ['parts', 'fas fa-microchip', 'Типы частей (комплектующие)'],
                ['chars', 'fas fa-sliders', 'Характеристики'],
            ];
            foreach ($items as [$route, $icon, $title]):
            ?>
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
