<?php

namespace app\components;

use app\models\entities\DeskAttachments;
use app\models\entities\License;
use app\models\entities\LicenseAttachment;
use Yii;
use yii\web\UploadedFile;

/**
 * Документы по закупке лицензий.
 */
class LicenseAttachmentService
{
    /**
     * @return array<int, array<string, mixed>>
     */
    public function getAttachmentRows(License $license): array
    {
        $attachments = DeskAttachments::find()
            ->alias('da')
            ->innerJoin(
                ['l' => 'license_attachments'],
                'l.attachment_id = da.id AND l.license_id = :lid',
                [':lid' => (int) $license->id]
            )
            ->orderBy(['da.uploaded_at' => SORT_DESC])
            ->all();

        $rows = [];
        foreach ($attachments as $attachment) {
            $rows[] = $this->formatAttachmentRow($attachment);
        }

        return $rows;
    }

    /**
     * @param UploadedFile[] $files
     * @return array{success: bool, message: string, attachments?: array, errors?: string[]}
     */
    public function uploadAttachments(License $license, array $files): array
    {
        $files = array_values(array_filter($files, static function ($file): bool {
            return $file instanceof UploadedFile;
        }));
        if ($files === []) {
            return ['success' => false, 'message' => 'Выберите файлы для загрузки.'];
        }

        $currentCount = (int) LicenseAttachment::find()
            ->where(['license_id' => $license->id])
            ->count();
        $maxFiles = License::getAttachmentMaxFiles();
        if ($currentCount >= $maxFiles) {
            return ['success' => false, 'message' => 'Достигнут лимит файлов (' . $maxFiles . ').'];
        }

        $allowed = License::getAttachmentExtensions();
        DeskAttachments::ensureUploadDirectory('licenses');
        $uploaded = 0;
        $errors = [];

        foreach ($files as $file) {
            if ($currentCount + $uploaded >= $maxFiles) {
                break;
            }
            $ext = strtolower((string) $file->extension);
            if (!in_array($ext, $allowed, true)) {
                $errors[] = $file->name . ': недопустимый тип файла';
                continue;
            }
            $fileName = time() . '_' . uniqid('', true) . '_' . $file->baseName . '.' . $file->extension;
            $relativePath = DeskAttachments::buildStoragePath('licenses', $fileName);
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
            $license->addAttachment((int) $att->id);
            $uploaded++;
        }

        if ($uploaded === 0) {
            return [
                'success' => false,
                'message' => 'Не удалось загрузить файлы.',
                'errors' => $errors,
            ];
        }

        $message = $uploaded === 1 ? 'Файл загружен.' : 'Загружено файлов: ' . $uploaded . '.';
        if ($errors !== []) {
            $message .= ' ' . implode('; ', array_slice($errors, 0, 3));
        }

        return [
            'success' => true,
            'message' => $message,
            'attachments' => $this->getAttachmentRows($license),
        ];
    }

    public function deleteAttachment(License $license, int $attachmentId): array
    {
        $linked = LicenseAttachment::find()
            ->where(['license_id' => $license->id, 'attachment_id' => $attachmentId])
            ->exists();
        if (!$linked) {
            return ['success' => false, 'message' => 'Вложение не найдено.'];
        }

        $attachment = DeskAttachments::findOne($attachmentId);
        $license->removeAttachment($attachmentId);
        if ($attachment) {
            $attachment->delete();
        }

        return [
            'success' => true,
            'message' => 'Файл удалён.',
            'attachments' => $this->getAttachmentRows($license),
        ];
    }

    public function licenseOwnsAttachment(int $licenseId, int $attachmentId): bool
    {
        return LicenseAttachment::find()
            ->where(['license_id' => $licenseId, 'attachment_id' => $attachmentId])
            ->exists();
    }

    /**
     * @return array<string, mixed>
     */
    private function formatAttachmentRow(DeskAttachments $attachment): array
    {
        return [
            'id' => (int) $attachment->id,
            'original_name' => $attachment->original_name,
            'file_extension' => $attachment->file_extension,
            'size_label' => $attachment->getFormattedFileSize(),
            'icon' => $attachment->getFileIcon(),
            'is_preview' => $attachment->isImageOrScan(),
            'uploaded_at' => $attachment->uploaded_at,
        ];
    }
}
