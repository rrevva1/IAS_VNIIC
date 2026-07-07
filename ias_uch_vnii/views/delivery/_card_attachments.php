<?php
/**
 * Документы поставки (накладные, акты, счета).
 *
 * @var app\models\entities\EquipmentDelivery $model
 * @var array<int, array<string, mixed>> $attachments
 * @var bool $canEditAttachments
 * @var bool $embedded внутри блока «Основные сведения»
 */

use yii\helpers\Html;
use yii\helpers\Url;

$attachments = $attachments ?? [];
$canEditAttachments = $canEditAttachments ?? false;
$embedded = !empty($embedded);
$maxFiles = \app\models\entities\EquipmentDelivery::getAttachmentMaxFiles();
?>
<?php if ($embedded): ?>
<div class="delivery-section-attachments delivery-section-attachments--embedded" aria-labelledby="delivery-section-attachments">
    <h3 id="delivery-section-attachments" class="delivery-section-attachments__title">Документы</h3>
    <div class="delivery-section-attachments__body">
<?php else: ?>
<section class="arm-view-card arm-form-create__card delivery-section-attachments" aria-labelledby="delivery-section-attachments">
    <h2 id="delivery-section-attachments" class="arm-view-card__title">Документы</h2>
    <div class="arm-view-card__body">
<?php endif; ?>
        <?php if ($canEditAttachments): ?>
            <div class="delivery-attachments-upload mb-3">
                <label class="form-label" for="deliveryAttachmentInput">Добавить файлы</label>
                <div class="delivery-attachments-upload__row">
                    <input type="file"
                           class="form-control form-control-sm"
                           id="deliveryAttachmentInput"
                           name="uploadFiles[]"
                           multiple
                           accept="image/*,application/pdf,.doc,.docx,.xls,.xlsx,.txt"
                           data-delivery-attachment-input="1">
                    <button type="button" class="btn btn-sm btn-primary arm-tool-btn" id="deliveryAttachmentUploadBtn" data-delivery-attachment-upload="1">
                        <i class="fas fa-upload" aria-hidden="true"></i>
                        Загрузить
                    </button>
                </div>
                <p class="form-text mb-0">PDF, Word, Excel, изображения — до <?= (int) $maxFiles ?> файлов.</p>
            </div>
        <?php endif; ?>

        <ul class="delivery-attachments-list list-unstyled mb-0" id="deliveryAttachmentsList" data-delivery-attachments-list="1">
            <?php if ($attachments === []): ?>
                <li class="text-muted small delivery-attachments-list__empty">Документы не прикреплены.</li>
            <?php else: ?>
                <?php foreach ($attachments as $item): ?>
                    <li class="delivery-attachments-list__item" data-attachment-id="<?= (int) $item['id'] ?>">
                        <i class="fas <?= Html::encode($item['icon']) ?>" aria-hidden="true"></i>
                        <?php if (!empty($item['is_preview'])): ?>
                            <a href="<?= Url::to(['preview-attachment', 'id' => $model->id, 'attachmentId' => $item['id']]) ?>"
                               class="delivery-attachments-list__link"
                               target="_blank" rel="noopener">
                                <?= Html::encode($item['original_name']) ?>
                            </a>
                        <?php else: ?>
                            <a href="<?= Url::to(['download-attachment', 'id' => $model->id, 'attachmentId' => $item['id']]) ?>"
                               class="delivery-attachments-list__link">
                                <?= Html::encode($item['original_name']) ?>
                            </a>
                        <?php endif; ?>
                        <span class="text-muted small"><?= Html::encode($item['size_label']) ?></span>
                        <?php if ($canEditAttachments): ?>
                            <button type="button"
                                    class="btn btn-link btn-sm text-danger p-0 delivery-attachments-list__delete"
                                    data-delivery-attachment-delete="<?= (int) $item['id'] ?>"
                                    title="Удалить файл">
                                <i class="fas fa-trash" aria-hidden="true"></i>
                            </button>
                        <?php endif; ?>
                    </li>
                <?php endforeach; ?>
            <?php endif; ?>
        </ul>
<?php if ($embedded): ?>
    </div>
</div>
<?php else: ?>
    </div>
</section>
<?php endif; ?>
