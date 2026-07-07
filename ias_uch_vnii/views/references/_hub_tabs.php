<?php
/**
 * Вкладки навигации по справочникам (как типы техники в «Учёт ТС»).
 *
 * @var string $activeRoute ключ активного раздела: index|task-status|locations|...
 */

use yii\helpers\Html;
use yii\helpers\Url;

$activeRoute = $activeRoute ?? 'index';

$tabs = [
    'index' => ['index', 'Обзор'],
    'task-status' => ['task-status', 'Статусы заявок'],
    'locations' => ['locations', 'Локации'],
    'equipment-status' => ['equipment-status', 'Статусы оборудования'],
    'parts' => ['parts', 'Типы частей'],
    'chars' => ['chars', 'Характеристики'],
];
?>
<div class="arm-command-bar__tabs" role="tablist" aria-label="Разделы справочников">
    <ul class="nav nav-tabs arm-type-tabs references-hub-tabs">
        <?php foreach ($tabs as $key => [$route, $label]): ?>
        <li class="nav-item">
            <a class="nav-link arm-type-tab references-hub-tab<?= $activeRoute === $key ? ' active' : '' ?>"
               href="<?= Html::encode(Url::to([$route])) ?>"
               role="tab"
               aria-selected="<?= $activeRoute === $key ? 'true' : 'false' ?>"><?= Html::encode($label) ?></a>
        </li>
        <?php endforeach; ?>
    </ul>
</div>
