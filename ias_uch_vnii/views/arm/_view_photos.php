<?php
/**
 * Галерея фотографий в карточке техники (просмотр).
 *
 * @var array<int, array<string, mixed>> $photos
 */

use yii\helpers\Html;

$photos = $photos ?? [];
?>
<section class="arm-view-section arm-equipment-photos-view" aria-labelledby="arm-view-photos-title">
    <h2 id="arm-view-photos-title" class="arm-view-section__title">Фотографии</h2>
    <div class="arm-view-card">
        <div class="arm-view-card__body arm-view-card__body--content">
            <div class="arm-photos-gallery" id="armPhotosGalleryView" data-arm-photos-gallery="1">
                <?php if ($photos === []): ?>
                    <p class="text-muted small mb-0 arm-photos-gallery__empty">Фотографии не прикреплены.</p>
                <?php else: ?>
                    <div class="arm-photos-gallery__grid">
                        <?php foreach ($photos as $photo): ?>
                            <figure class="arm-photos-gallery__item" data-attachment-id="<?= (int) $photo['id'] ?>">
                                <button type="button"
                                        class="arm-photos-gallery__thumb-btn"
                                        data-arm-photo-preview="<?= Html::encode($photo['preview_url']) ?>"
                                        data-arm-photo-download="<?= Html::encode($photo['download_url']) ?>"
                                        data-arm-photo-name="<?= Html::encode($photo['original_name']) ?>"
                                        title="<?= Html::encode($photo['original_name']) ?>">
                                    <img src="<?= Html::encode($photo['preview_url']) ?>"
                                         alt="<?= Html::encode($photo['original_name']) ?>"
                                         class="arm-photos-gallery__thumb"
                                         loading="lazy">
                                </button>
                            </figure>
                        <?php endforeach; ?>
                    </div>
                <?php endif; ?>
            </div>
        </div>
    </div>
</section>
