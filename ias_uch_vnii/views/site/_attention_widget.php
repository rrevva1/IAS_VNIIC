<?php

use yii\helpers\Html;
use yii\helpers\Url;

/** @var yii\web\View $this */
/** @var string $widgetId */
/** @var string $title */
/** @var string $icon */
/** @var string $severity */
/** @var int $count */
/** @var array<int, array<string, mixed>> $items */
/** @var array<int, string>|null $url */
/** @var string $urlLabel */
/** @var string $emptyText */
?>

<section class="dashboard-widget dashboard-widget--<?= Html::encode($severity) ?><?= $count > 0 ? ' dashboard-widget--active' : ' dashboard-widget--idle' ?>"
         aria-labelledby="<?= Html::encode($widgetId) ?>-title">
    <header class="dashboard-widget__header">
        <h2 id="<?= Html::encode($widgetId) ?>-title" class="dashboard-widget__title">
            <span class="dashboard-widget__icon" aria-hidden="true">
                <i class="<?= Html::encode($icon) ?>"></i>
            </span>
            <span class="dashboard-widget__title-text"><?= Html::encode($title) ?></span>
        </h2>
        <span class="dashboard-widget__count dashboard-widget__count--<?= $count > 0 ? Html::encode($severity) : 'zero' ?>">
            <?= (int) $count ?>
        </span>
    </header>

    <div class="dashboard-widget__body">
    <?php if ($items !== []): ?>
        <ul class="dashboard-widget__list">
            <?php foreach ($items as $item): ?>
                <li class="dashboard-widget__item">
                    <?php if (!empty($item['url'])): ?>
                        <a class="dashboard-widget__item-link" href="<?= Html::encode(Url::to($item['url'])) ?>">
                            <span class="dashboard-widget__item-main">
                                <span class="dashboard-widget__label"><?= Html::encode($item['label'] ?? '—') ?></span>
                                <?php if (!empty($item['meta'])): ?>
                                    <span class="dashboard-widget__meta"><?= Html::encode($item['meta']) ?></span>
                                <?php endif; ?>
                            </span>
                            <?php if (!empty($item['badge'])): ?>
                                <span class="badge dashboard-widget__badge <?= Html::encode($item['badge_class'] ?? 'bg-secondary') ?>">
                                    <?= Html::encode($item['badge']) ?>
                                </span>
                            <?php else: ?>
                                <span class="dashboard-widget__chevron" aria-hidden="true"><i class="fas fa-chevron-right"></i></span>
                            <?php endif; ?>
                        </a>
                    <?php else: ?>
                        <span class="dashboard-widget__label"><?= Html::encode($item['label'] ?? '—') ?></span>
                        <?php if (!empty($item['meta'])): ?>
                            <span class="dashboard-widget__meta"><?= Html::encode($item['meta']) ?></span>
                        <?php endif; ?>
                    <?php endif; ?>
                </li>
            <?php endforeach; ?>
        </ul>
    <?php else: ?>
        <p class="dashboard-widget__empty"><?= Html::encode($emptyText) ?></p>
    <?php endif; ?>
    </div>

    <?php if ($count > 0 && !empty($url)): ?>
        <footer class="dashboard-widget__footer">
            <a class="dashboard-widget__more" href="<?= Html::encode(Url::to($url)) ?>">
                <?= Html::encode($urlLabel) ?>
                <i class="fas fa-arrow-right" aria-hidden="true"></i>
            </a>
        </footer>
    <?php endif; ?>
</section>
