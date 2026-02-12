<?php

namespace app\models\entities;

use Yii;
use yii\behaviors\TimestampBehavior;
use yii\db\ActiveRecord;

/**
 * Модель для таблицы "desk_attachments".
 *
 * @property int $attach_id
 * @property string $path
 * @property string $name
 * @property string $extension
 * @property string|null $created_at
 */
class DeskAttachments extends ActiveRecord
{
    /**
     * Возвращает имя таблицы
     */
    public static function tableName()
    {
        return 'desk_attachments';
    }

    /**
     * Определяет поведения модели
     */
    public function behaviors()
    {
        return [
            [
                'class' => TimestampBehavior::class,
                'createdAtAttribute' => 'created_at',
                'updatedAtAttribute' => false,
                'value' => new \yii\db\Expression('CURRENT_TIMESTAMP'),
            ],
        ];
    }

    /**
     * Правила валидации
     */
    public function rules()
    {
        return [
            [['path', 'name', 'extension'], 'required'],
            [['created_at'], 'safe'],
            [['path'], 'string', 'max' => 500],
            [['name'], 'string', 'max' => 255],
            [['extension'], 'string', 'max' => 10],
        ];
    }

    /**
     * Метки атрибутов
     */
    public function attributeLabels()
    {
        return [
            'attach_id' => 'ID Вложения',
            'path' => 'Путь к файлу',
            'name' => 'Имя файла',
            'extension' => 'Расширение',
            'created_at' => 'Дата создания',
        ];
    }

    /**
     * Получить полный путь к файлу
     *
     * @return string
     */
    public function getFullPath()
    {
        return Yii::getAlias('@webroot') . $this->path;
    }

    /**
     * Проверить существование файла
     *
     * @return bool
     */
    public function fileExists()
    {
        return file_exists($this->getFullPath());
    }

    /**
     * Получить размер файла
     *
     * @return int|false
     */
    public function getFileSize()
    {
        if ($this->fileExists()) {
            return filesize($this->getFullPath());
        }
        return false;
    }

    /**
     * Получить размер файла в читаемом формате
     *
     * @return string
     */
    public function getFormattedFileSize()
    {
        $size = $this->getFileSize();
        if ($size === false) {
            return 'Неизвестно';
        }

        $units = ['B', 'KB', 'MB', 'GB'];
        $unitIndex = 0;
        
        while ($size >= 1024 && $unitIndex < count($units) - 1) {
            $size /= 1024;
            $unitIndex++;
        }
        
        return round($size, 2) . ' ' . $units[$unitIndex];
    }

    /**
     * Получить иконку для типа файла
     *
     * @return string
     */
    public function getFileIcon()
    {
        $extension = strtolower($this->extension);
        
        $icons = [
            'pdf' => 'fa-file-pdf',
            'doc' => 'fa-file-word',
            'docx' => 'fa-file-word',
            'xls' => 'fa-file-excel',
            'xlsx' => 'fa-file-excel',
            'txt' => 'fa-file-alt',
            'jpg' => 'fa-file-image',
            'jpeg' => 'fa-file-image',
            'png' => 'fa-file-image',
            'gif' => 'fa-file-image',
            'bmp' => 'fa-file-image',
            'svg' => 'fa-file-image',
        ];
        
        return isset($icons[$extension]) ? $icons[$extension] : 'fa-file';
    }

    /**
     * Проверить, является ли файл изображением или сканом
     *
     * @return bool
     */
    public function isImageOrScan()
    {
        $extension = strtolower($this->extension);
        $imageExtensions = ['pdf', 'png', 'jpeg', 'jpg', 'bmp', 'gif', 'svg'];
        
        return in_array($extension, $imageExtensions);
    }

    /**
     * Получить URL для предпросмотра файла
     *
     * @return string
     */
    public function getPreviewUrl()
    {
        if ($this->isImageOrScan()) {
            return \yii\helpers\Url::to(['tasks/preview', 'id' => $this->attach_id]);
        }
        return \yii\helpers\Url::to(['tasks/download', 'id' => $this->attach_id]);
    }

    /**
     * Получить URL для скачивания файла
     *
     * @return string
     */
    public function getDownloadUrl()
    {
        return \yii\helpers\Url::to(['tasks/download', 'id' => $this->attach_id]);
    }

    /**
     * Удалить файл с диска
     *
     * @return bool
     */
    public function deleteFile()
    {
        if ($this->fileExists()) {
            return unlink($this->getFullPath());
        }
        return true;
    }

    /**
     * Переопределяем метод delete для удаления файла
     *
     * @return bool
     */
    public function delete()
    {
        $this->deleteFile();
        return parent::delete();
    }
}
