<?php
/**
 * Фотографии техники (форма редактирования).
 *
 * @var app\models\entities\Equipment $model
 * @var array<int, array<string, mixed>> $photos
 * @var bool $canEditPhotos
 */

use yii\helpers\Html;

$photos = $photos ?? [];
$canEditPhotos = $canEditPhotos ?? false;
$maxFiles = \app\models\entities\Equipment::getPhotoMaxFiles();
$isNew = $model->isNewRecord;
?>
<section class="arm-view-card arm-form-create__card arm-equipment-photos-form" aria-labelledby="arm-create-section-photos">
    <h2 id="arm-create-section-photos" class="arm-view-card__title">Фотографии</h2>
    <div class="arm-view-card__body">
        <?php if ($isNew): ?>
            <p class="text-muted small mb-0">Сохраните карточку, затем добавьте фотографии при редактировании.</p>
        <?php else: ?>
            <?php if ($canEditPhotos): ?>
                <div class="arm-photos-upload mb-3">
                    <label class="form-label" for="armPhotoInput">Добавить фото</label>
                    <div class="arm-photos-upload__row">
                        <input type="file"
                               class="form-control form-control-sm"
                               id="armPhotoInput"
                               name="uploadPhotos[]"
                               multiple
                               accept="image/png,image/jpeg,image/gif,image/webp,.png,.jpg,.jpeg,.gif,.webp"
                               data-arm-photo-input="1">
                        <button type="button" class="btn btn-sm btn-primary arm-tool-btn" id="armPhotoUploadBtn" data-arm-photo-upload="1">
                            <i class="fas fa-upload" aria-hidden="true"></i>
                            Загрузить
                        </button>
                    </div>
                    <p class="form-text mb-0">PNG, JPG, GIF, WebP — до <?= (int) $maxFiles ?> файлов.</p>
                </div>
            <?php endif; ?>

            <div class="arm-photos-gallery" id="armPhotosGallery" data-arm-photos-gallery="1">
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
                                <?php if ($canEditPhotos): ?>
                                    <button type="button"
                                            class="btn btn-sm btn-outline-danger arm-photos-gallery__delete"
                                            data-arm-photo-delete="<?= (int) $photo['id'] ?>"
                                            title="Удалить фото">
                                        <i class="fas fa-trash" aria-hidden="true"></i>
                                    </button>
                                <?php endif; ?>
                            </figure>
                        <?php endforeach; ?>
                    </div>
                <?php endif; ?>
            </div>
        <?php endif; ?>
    </div>
</section>
