<?php
/**
 * Документы лицензии.
 *
 * @var app\models\entities\License $model
 * @var array<int, array<string, mixed>> $attachments
 * @var bool $canEditAttachments
 */

use yii\helpers\Html;
use yii\helpers\Url;

$attachments = $attachments ?? [];
$canEditAttachments = $canEditAttachments ?? false;
$wrapInCard = $wrapInCard ?? false;
$maxFiles = \app\models\entities\License::getAttachmentMaxFiles();
$licenseId = (int) $model->id;

$attachmentsBody = function () use (
    $canEditAttachments,
    $licenseId,
    $maxFiles,
    $attachments,
    $model
): void {
    ?>
    <div class="software-license-attachments"
         data-license-attachments-root="1"
         data-license-id="<?= $licenseId ?>"
         data-can-edit="<?= $canEditAttachments ? '1' : '0' ?>">
        <?php if ($canEditAttachments): ?>
            <div class="software-license-attachments__upload mb-3">
                <label class="form-label" for="licenseAttachmentInput">Добавить файлы</label>
                <div class="software-license-attachments__upload-row">
                    <input type="file"
                           class="form-control form-control-sm"
                           id="licenseAttachmentInput"
                           name="uploadFiles[]"
                           multiple
                           accept="image/*,application/pdf,.doc,.docx,.xls,.xlsx,.txt"
                           data-license-attachment-input="1">
                    <?php if ($licenseId > 0): ?>
                        <button type="button"
                                class="btn btn-sm btn-primary arm-tool-btn"
                                id="licenseAttachmentUploadBtn"
                                data-license-attachment-upload="1">
                            <i class="fas fa-upload" aria-hidden="true"></i>
                            Загрузить
                        </button>
                    <?php endif; ?>
                </div>
                <p class="form-text mb-0">
                    PDF, Word, Excel, изображения — до <?= (int) $maxFiles ?> файлов.
                    <?php if ($licenseId <= 0): ?>
                        Файлы из поля выше будут сохранены вместе с лицензией.
                    <?php endif; ?>
                </p>
            </div>
        <?php endif; ?>

        <ul class="software-license-attachments__list list-unstyled mb-0"
            id="licenseAttachmentsList"
            data-license-attachments-list="1">
            <?php if ($attachments === []): ?>
                <li class="text-muted small software-license-attachments__empty">Документы не прикреплены.</li>
            <?php else: ?>
                <?php foreach ($attachments as $item): ?>
                    <li class="software-license-attachments__item" data-attachment-id="<?= (int) $item['id'] ?>">
                        <i class="fas <?= Html::encode($item['icon']) ?>" aria-hidden="true"></i>
                        <?php if (!empty($item['is_preview'])): ?>
                            <a href="<?= Url::to(['download-license-attachment', 'id' => $licenseId, 'attachmentId' => $item['id']]) ?>"
                               class="software-license-attachments__link"
                               target="_blank" rel="noopener">
                                <?= Html::encode($item['original_name']) ?>
                            </a>
                        <?php else: ?>
                            <a href="<?= Url::to(['download-license-attachment', 'id' => $licenseId, 'attachmentId' => $item['id']]) ?>"
                               class="software-license-attachments__link">
                                <?= Html::encode($item['original_name']) ?>
                            </a>
                        <?php endif; ?>
                        <span class="text-muted small"><?= Html::encode($item['size_label']) ?></span>
                        <?php if ($canEditAttachments): ?>
                            <button type="button"
                                    class="btn btn-link btn-sm text-danger p-0 software-license-attachments__delete"
                                    data-license-attachment-delete="<?= (int) $item['id'] ?>"
                                    title="Удалить файл">
                                <i class="fas fa-trash" aria-hidden="true"></i>
                            </button>
                        <?php endif; ?>
                    </li>
                <?php endforeach; ?>
            <?php endif; ?>
        </ul>
    </div>
    <?php
};

if ($wrapInCard): ?>
    <section class="arm-view-card arm-form-create__card software-license-attachments-card h-100" aria-labelledby="license-create-section-attachments">
        <h2 id="license-create-section-attachments" class="arm-view-card__title">Документы по закупке</h2>
        <div class="arm-view-card__body">
            <?php $attachmentsBody(); ?>
        </div>
    </section>
<?php else:
    $attachmentsBody();
endif;
