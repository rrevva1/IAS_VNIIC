<?php

namespace app\models\entities;

use Yii;
use yii\db\ActiveRecord;

/**
 * Модель для таблицы "desk_attachments" (схема tech_accounting).
 *
 * @property int $id
 * @property string $storage_path
 * @property string $original_name
 * @property string|null $file_extension
 * @property string|null $mime_type
 * @property int $size_bytes
 * @property int|null $uploaded_by
 * @property string $uploaded_at
 */
class DeskAttachments extends ActiveRecord
{
    /**
     * Совместимость: старые поля path/name/extension маппятся на storage_path/original_name/file_extension.
     */
    public function getPath()
    {
        return $this->storage_path;
    }

    public function getName()
    {
        return $this->original_name;
    }

    public function getExtension()
    {
        return $this->file_extension;
    }

    public static function tableName()
    {
        return 'desk_attachments';
    }

    public function rules()
    {
        return [
            [['storage_path', 'original_name', 'size_bytes'], 'required'],
            [['storage_path'], 'string', 'max' => 1000],
            [['original_name'], 'string', 'max' => 255],
            [['file_extension'], 'string', 'max' => 20],
            [['mime_type'], 'string', 'max' => 150],
            [['size_bytes'], 'integer', 'min' => 0],
            [['uploaded_by'], 'integer'],
        ];
    }

    public function attributeLabels()
    {
        return [
            'id' => 'ID',
            'storage_path' => 'Путь',
            'original_name' => 'Имя файла',
            'file_extension' => 'Расширение',
            'size_bytes' => 'Размер',
            'uploaded_at' => 'Дата загрузки',
        ];
    }

    public function getFullPath()
    {
        $path = $this->storage_path;
        if (strpos($path, '/') !== 0 && strpos($path, ':') === false) {
            $path = '/' . $path;
        }
        return Yii::getAlias('@webroot') . $path;
    }

    public function fileExists()
    {
        return file_exists($this->getFullPath());
    }

    public function getFileSize()
    {
        return $this->fileExists() ? filesize($this->getFullPath()) : $this->size_bytes;
    }

    public function getFormattedFileSize()
    {
        $size = $this->getFileSize();
        if ($size === false) {
            return 'Неизвестно';
        }
        $units = ['B', 'KB', 'MB', 'GB'];
        $i = 0;
        while ($size >= 1024 && $i < count($units) - 1) {
            $size /= 1024;
            $i++;
        }
        return round($size, 2) . ' ' . $units[$i];
    }

    public function getFileIcon()
    {
        $ext = strtolower((string) $this->file_extension);
        $icons = [
            'pdf' => 'fa-file-pdf', 'doc' => 'fa-file-word', 'docx' => 'fa-file-word',
            'xls' => 'fa-file-excel', 'xlsx' => 'fa-file-excel', 'txt' => 'fa-file-alt',
            'jpg' => 'fa-file-image', 'jpeg' => 'fa-file-image', 'png' => 'fa-file-image',
            'gif' => 'fa-file-image', 'bmp' => 'fa-file-image', 'svg' => 'fa-file-image',
        ];
        return $icons[$ext] ?? 'fa-file';
    }

    public function isImageOrScan()
    {
        return in_array(strtolower((string) $this->file_extension), ['pdf', 'png', 'jpeg', 'jpg', 'bmp', 'gif', 'svg'], true);
    }

    public function getPreviewUrl()
    {
        if ($this->isImageOrScan()) {
            return \yii\helpers\Url::to(['tasks/preview', 'id' => $this->id]);
        }
        return \yii\helpers\Url::to(['tasks/download', 'id' => $this->id]);
    }

    public function getDownloadUrl()
    {
        return \yii\helpers\Url::to(['tasks/download', 'id' => $this->id]);
    }

    public function deleteFile()
    {
        return $this->fileExists() ? unlink($this->getFullPath()) : true;
    }

    public function delete()
    {
        $this->deleteFile();
        return parent::delete();
    }
}
