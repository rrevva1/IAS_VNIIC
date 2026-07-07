<?php

namespace app\components;

use app\models\entities\DeskAttachments;
use app\models\entities\Equipment;
use app\models\entities\EquipmentAttachment;
use Yii;
use yii\web\UploadedFile;

/**
 * Загрузка и удаление фотографий техники.
 */
class EquipmentAttachmentService
{
    /**
     * @return array<int, array<string, mixed>>
     */
    public function getPhotoRows(Equipment $equipment): array
    {
        $attachments = DeskAttachments::find()
            ->alias('da')
            ->innerJoin(
                ['l' => 'equipment_attachments'],
                'l.attachment_id = da.id AND l.equipment_id = :eid',
                [':eid' => (int) $equipment->id]
            )
            ->orderBy(['da.uploaded_at' => SORT_DESC])
            ->all();

        $rows = [];
        foreach ($attachments as $attachment) {
            $rows[] = $this->formatPhotoRow($attachment, (int) $equipment->id);
        }

        return $rows;
    }

    /**
     * @param UploadedFile[] $files
     * @return array{success: bool, message: string, photos?: array, errors?: string[]}
     */
    public function uploadPhotos(Equipment $equipment, array $files): array
    {
        if (!$equipment->canEditPhotos()) {
            return ['success' => false, 'message' => 'Нет прав на изменение фотографий.'];
        }

        $files = array_values(array_filter($files, static function ($file): bool {
            return $file instanceof UploadedFile;
        }));
        if ($files === []) {
            return ['success' => false, 'message' => 'Выберите файлы для загрузки.'];
        }

        $currentCount = (int) EquipmentAttachment::find()
            ->where(['equipment_id' => $equipment->id])
            ->count();
        $maxFiles = Equipment::getPhotoMaxFiles();
        if ($currentCount >= $maxFiles) {
            return ['success' => false, 'message' => 'Достигнут лимит фотографий (' . $maxFiles . ').'];
        }

        $allowed = Equipment::getPhotoExtensions();
        DeskAttachments::ensureUploadDirectory('equipment');
        $uploaded = 0;
        $errors = [];

        foreach ($files as $file) {
            if ($currentCount + $uploaded >= $maxFiles) {
                break;
            }
            $ext = strtolower((string) $file->extension);
            if (!in_array($ext, $allowed, true)) {
                $errors[] = $file->name . ': допустимы только изображения (PNG, JPG, GIF, WebP)';
                continue;
            }
            $fileName = time() . '_' . uniqid('', true) . '_' . $file->baseName . '.' . $file->extension;
            $relativePath = DeskAttachments::buildStoragePath('equipment', $fileName);
            $fullPath = DeskAttachments::resolveStoragePath($relativePath);
            if (!$file->saveAs($fullPath)) {
                $errors[] = $file->name . ': не удалось сохранить';
                continue;
            }
            $att = new DeskAttachments();
            $att->storage_path = $relativePath;
            $att->original_name = $file->baseName . '.' . $file->extension;
            $att->file_extension = $file->extension;
            $att->mime_type = $file->type;
            $att->size_bytes = (int) $file->size;
            $att->uploaded_by = Yii::$app->user->isGuest ? null : (int) Yii::$app->user->id;
            $att->uploaded_at = date('Y-m-d H:i:s');
            if (!$att->save(false)) {
                @unlink($fullPath);
                $errors[] = $file->name . ': ошибка записи в БД';
                continue;
            }
            $equipment->addPhoto((int) $att->id);
            $uploaded++;
        }

        if ($uploaded === 0) {
            return [
                'success' => false,
                'message' => 'Не удалось загрузить фотографии.',
                'errors' => $errors,
            ];
        }

        $message = $uploaded === 1 ? 'Фотография загружена.' : 'Загружено фотографий: ' . $uploaded . '.';
        if ($errors !== []) {
            $message .= ' ' . implode('; ', array_slice($errors, 0, 3));
        }

        return [
            'success' => true,
            'message' => $message,
            'photos' => $this->getPhotoRows($equipment),
        ];
    }

    /**
     * @return array{success: bool, message: string, photos?: array}
     */
    public function deletePhoto(Equipment $equipment, int $attachmentId): array
    {
        if (!$equipment->canEditPhotos()) {
            return ['success' => false, 'message' => 'Нет прав на изменение фотографий.'];
        }

        $linked = EquipmentAttachment::find()
            ->where(['equipment_id' => $equipment->id, 'attachment_id' => $attachmentId])
            ->exists();
        if (!$linked) {
            return ['success' => false, 'message' => 'Фотография не найдена.'];
        }

        $attachment = DeskAttachments::findOne($attachmentId);
        $equipment->removePhoto($attachmentId);
        if ($attachment) {
            $attachment->delete();
        }

        return [
            'success' => true,
            'message' => 'Фотография удалена.',
            'photos' => $this->getPhotoRows($equipment),
        ];
    }

    public function equipmentOwnsPhoto(int $equipmentId, int $attachmentId): bool
    {
        return EquipmentAttachment::find()
            ->where(['equipment_id' => $equipmentId, 'attachment_id' => $attachmentId])
            ->exists();
    }

    /**
     * @return array<string, mixed>
     */
    private function formatPhotoRow(DeskAttachments $attachment, int $equipmentId): array
    {
        return [
            'id' => (int) $attachment->id,
            'original_name' => $attachment->original_name,
            'file_extension' => $attachment->file_extension,
            'size_label' => $attachment->getFormattedFileSize(),
            'preview_url' => '/index.php?r=arm/preview-photo&id=' . $equipmentId . '&attachmentId=' . (int) $attachment->id,
            'download_url' => '/index.php?r=arm/download-photo&id=' . $equipmentId . '&attachmentId=' . (int) $attachment->id,
            'uploaded_at' => $attachment->uploaded_at,
        ];
    }
}
