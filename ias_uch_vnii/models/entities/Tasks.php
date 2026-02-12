<?php

namespace app\models\entities;

use app\models\dictionaries\DicTaskStatus;
use Yii;
use yii\behaviors\TimestampBehavior;
use yii\db\ActiveRecord;
use yii\web\UploadedFile;

/**
 * Модель для таблицы "tasks".
 *
 * @property int $id
 * @property int $id_status
 * @property string $description
 * @property int $id_user
 * @property string|null $date
 * @property string|null $last_time_update
 * @property string|null $comment
 * @property int|null $executor_id
 * @property int[]|null $attachments
 *
 * @property DicTaskStatus $status
 * @property Users $user
 * @property Users $executor
 * @property DeskAttachments[] $taskAttachments
 */
class Tasks extends ActiveRecord
{
    /**
     * @var UploadedFile[] массив загружаемых файлов
     */
    public $uploadFiles;

    /**
     * Возвращает имя таблицы
     */
    public static function tableName()
    {
        return 'tasks';
    }

    /**
     * Определяет поведения модели
     */
    public function behaviors()
    {
        return [
            [
                'class' => TimestampBehavior::class,
                'createdAtAttribute' => 'date',
                'updatedAtAttribute' => 'last_time_update',
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
            [['id_status', 'description', 'id_user'], 'required'],
            [['id_status', 'id_user', 'executor_id'], 'integer'],
            [['description', 'comment'], 'string'],
            [['attachments'], 'each', 'rule' => ['integer']],
            [['attachments'], 'safe'],
            [['date', 'last_time_update'], 'safe'],
            [['id_status'], 'exist', 'skipOnError' => true, 'targetClass' => DicTaskStatus::class, 'targetAttribute' => ['id_status' => 'id_status']],
            [['id_user'], 'exist', 'skipOnError' => true, 'targetClass' => Users::class, 'targetAttribute' => ['id_user' => 'id_user']],
            [['executor_id'], 'exist', 'skipOnError' => true, 'targetClass' => Users::class, 'targetAttribute' => ['executor_id' => 'id']],
            [['uploadFiles'], 'file', 'skipOnEmpty' => true, 'extensions' => 'png, jpg, jpeg, gif, pdf, doc, docx, xls, xlsx, txt', 'maxFiles' => 10],
        ];
    }

    /**
     * Метки атрибутов
     */
    public function attributeLabels()
    {
        return [
            'id' => 'ID',
            'id_status' => 'Статус',
            'description' => 'Описание',
            'id_user' => 'Автор',
            'date' => 'Дата создания',
            'last_time_update' => 'Последнее обновление',
            'comment' => 'Комментарий',
            'executor_id' => 'Исполнитель',
            'attachments' => 'Вложения',
            'uploadFiles' => 'Файлы для загрузки',
        ];
    }

    /**
     * Получить запрос для [[Status]].
     *
     * @return \yii\db\ActiveQuery
     */
    public function getStatus()
    {
        return $this->hasOne(DicTaskStatus::class, ['id_status' => 'id_status']);
    }

    /**
     * Получить запрос для [[User]].
     *
     * @return \yii\db\ActiveQuery
     */
    public function getUser()
    {
        return $this->hasOne(Users::class, ['id_user' => 'id_user']);
    }

    /**
     * Получить запрос для [[Executor]].
     *
     * @return \yii\db\ActiveQuery
     */
    public function getExecutor()
    {
        return $this->hasOne(Users::class, ['id_user' => 'executor_id']);
    }

    /**
     * Получить запрос для [[TaskAttachments]].
     *
     * @return \yii\db\ActiveQuery
     */
    public function getTaskAttachments()
    {
        return $this->hasMany(DeskAttachments::class, ['attach_id' => 'attach_id'])
            ->viaTable('task_attachments', ['task_id' => 'id']);
    }

    /**
     * Получить массив ID вложений
     *
     * @return array
     */
    public function getAttachmentsArray()
    {
        return is_array($this->attachments) ? $this->attachments : [];
    }

    /**
     * Установить массив ID вложений
     *
     * @param array $attachments
     */
    public function setAttachmentsArray($attachments)
    {
        $this->attachments = $attachments;
    }

    /**
     * Добавить вложение к задаче
     *
     * @param int $attachmentId
     */
    public function addAttachment($attachmentId)
    {
        $attachments = $this->getAttachmentsArray();
        if (!in_array($attachmentId, $attachments)) {
            $attachments[] = $attachmentId;
            $this->setAttachmentsArray($attachments);
        }
    }

    /**
     * Удалить вложение из задачи
     *
     * @param int $attachmentId
     */
    public function removeAttachment($attachmentId)
    {
        $attachments = $this->getAttachmentsArray();
        $key = array_search($attachmentId, $attachments);
        if ($key !== false) {
            unset($attachments[$key]);
            $this->setAttachmentsArray(array_values($attachments));
        }
    }

    /**
     * Получить все вложения задачи
     *
     * @return DeskAttachments[]
     */
    public function getAllAttachments()
    {
        $attachmentIds = $this->getAttachmentsArray(); 
        if (!is_array($attachmentIds)) {
            return [];
        }
        
        return DeskAttachments::find()
            ->where(['in', 'attach_id', $attachmentIds])
            ->all();
    }

    /**
     * Загрузить файлы и создать вложения
     *
     * @return bool
     */
    public function uploadFiles()
    {
        Yii::info("=== НАЧАЛО uploadFiles() ===", 'tasks');
        Yii::info("Task ID: {$this->id}", 'tasks');
        Yii::info("uploadFiles тип: " . gettype($this->uploadFiles), 'tasks');
        Yii::info("uploadFiles пустой?: " . (empty($this->uploadFiles) ? 'ДА' : 'НЕТ'), 'tasks');
        Yii::info("uploadFiles массив?: " . (is_array($this->uploadFiles) ? 'ДА' : 'НЕТ'), 'tasks');
        
        if (is_array($this->uploadFiles)) {
            Yii::info("Количество файлов в uploadFiles: " . count($this->uploadFiles), 'tasks');
            foreach ($this->uploadFiles as $i => $file) {
                if ($file instanceof \yii\web\UploadedFile) {
                    Yii::info("  Файл #{$i}: {$file->name} ({$file->size} байт)", 'tasks');
                } else {
                    Yii::info("  Файл #{$i}: НЕ UploadedFile!", 'tasks');
                }
            }
        }
        
        /** Проверяем, что uploadFiles не пустой и является массивом */
        if (empty($this->uploadFiles) || !is_array($this->uploadFiles)) {
            Yii::info("uploadFiles пустой или не массив - выход", 'tasks');
            return true; /** Не ошибка, просто нет файлов для загрузки */
        }

        if ($this->validate()) {
            $uploadedAttachments = [];
            
            Yii::info("Начинаем загрузку файлов...", 'tasks');
            foreach ($this->uploadFiles as $index => $file) {
                Yii::info("--- Обработка файла #{$index}: {$file->name} ---", 'tasks');
                $fileName = time() . '_' . uniqid() . '_' . $file->baseName . '.' . $file->extension;
                $uploadPath = Yii::getAlias('@webroot/uploads/tasks/') . $fileName;
                
                /** Создаем директорию для загрузок, если её нет */
                $uploadDir = Yii::getAlias('@webroot/uploads/tasks/');
                if (!is_dir($uploadDir)) {
                    mkdir($uploadDir, 0755, true);
                }
                
                if ($file->saveAs($uploadPath)) {
                    Yii::info("Файл сохранен на диск: {$uploadPath}", 'tasks');
                    $attachment = new DeskAttachments();
                    $attachment->name = $file->baseName . '.' . $file->extension;
                    $attachment->path = '/uploads/tasks/' . $fileName;
                    $attachment->extension = $file->extension;
                    
                    if ($attachment->save()) {
                        $uploadedAttachments[] = $attachment->attach_id;
                        Yii::info("Attachment сохранен в БД с ID: {$attachment->attach_id}", 'tasks');
                    } else {
                        Yii::error("Ошибка сохранения attachment для файла {$file->name}: " . json_encode($attachment->errors), 'tasks');
                    }
                } else {
                    Yii::error("Ошибка сохранения файла {$file->name} в {$uploadPath}", 'tasks');
                }
            }
            
            Yii::info("Загружено attachments (ID): " . json_encode($uploadedAttachments), 'tasks');
            
            if (!empty($uploadedAttachments)) {
                $currentAttachments = $this->getAttachmentsArray();
                Yii::info("Текущие attachments в задаче: " . json_encode($currentAttachments), 'tasks');
                
                $merged = array_merge($currentAttachments, $uploadedAttachments);
                Yii::info("После merge: " . json_encode($merged), 'tasks');
                
                $this->setAttachmentsArray($merged);
                Yii::info("После setAttachmentsArray, attachments = " . json_encode($this->attachments), 'tasks');
                
                $saveResult = $this->save(false);
                Yii::info("Результат save(false): " . ($saveResult ? 'УСПЕХ' : 'ОШИБКА'), 'tasks');
                
                if ($saveResult) {
                    Yii::info("После save, attachments = " . json_encode($this->attachments), 'tasks');
                }
                
                Yii::info("=== КОНЕЦ uploadFiles() ===", 'tasks');
                return $saveResult;
            }
            
            Yii::info("Нет загруженных attachments", 'tasks');
            return true;
        } else {
            Yii::error("Ошибка валидации при загрузке файлов: " . json_encode($this->errors), 'tasks');
        }
        return false;
    }
    
    /**
     * Обработка массива attachments перед сохранением в БД
     * Конвертирует PHP массив в JSON строку
     */
    public function beforeSave($insert)
    {
        if (parent::beforeSave($insert)) {
            /** Убеждаемся, что attachments является массивом */
            if (!is_array($this->attachments)) {
                /** Если это строка JSON - декодируем */
                if (is_string($this->attachments) && !empty($this->attachments)) {
                    $decoded = json_decode($this->attachments, true);
                    $this->attachments = is_array($decoded) ? $decoded : [];
                } else {
                    $this->attachments = [];
                }
            }
            
            /** Удаляем пустые и невалидные значения из массива */
            $cleanAttachments = array_values(array_filter($this->attachments, function($val) {
                return is_numeric($val) && $val > 0;
            }));
            
            /** Конвертируем в JSON строку для хранения в БД */
            $this->attachments = json_encode($cleanAttachments);
            
            return true;
        }
        return false;
    }
    
    /**
     * После сохранения восстанавливаем массив из JSON
     */
    public function afterSave($insert, $changedAttributes)
    {
        parent::afterSave($insert, $changedAttributes);
        
        /** Восстанавливаем массив из JSON для дальнейшей работы */
        if (is_string($this->attachments)) {
            $decoded = json_decode($this->attachments, true);
            $this->attachments = is_array($decoded) ? $decoded : [];
        }
    }
    
    /**
     * Обработка attachments после загрузки из БД
     * Конвертирует JSON строку в PHP массив
     */
    public function afterFind()
    {
        parent::afterFind();
        
        /** Если это уже массив - ничего не делаем */
        if (is_array($this->attachments)) {
            return;
        }
        
        /** Если это строка - декодируем JSON или парсим PostgreSQL массив */
        if (is_string($this->attachments)) {
            $trimmed = trim($this->attachments);
            
            /** Пустая строка или NULL */
            if (empty($trimmed)) {
                $this->attachments = [];
                return;
            }
            
            /** Проверяем, является ли это JSON массивом */
            if ($trimmed[0] === '[') {
                /** Это JSON формат: [1,2,3] */
                $decoded = json_decode($trimmed, true);
                $this->attachments = is_array($decoded) ? $decoded : [];
            } 
            /** Проверяем, является ли это PostgreSQL массивом */
            elseif ($trimmed[0] === '{') {
                /** Это PostgreSQL формат: {1,2,3} */
                $value = trim($trimmed, '{}');
                if (empty($value)) {
                    $this->attachments = [];
                } else {
                    $this->attachments = array_values(array_filter(
                        array_map('intval', explode(',', $value)),
                        function($val) { return $val > 0; }
                    ));
                }
            }
            else {
                /** Неизвестный формат - устанавливаем пустой массив */
                $this->attachments = [];
            }
        } else {
            /** На всякий случай устанавливаем пустой массив */
            $this->attachments = [];
        }
    }
    
    /**
     * Получить все задачи с связями
     * Возвращает все задачи с подгруженными связями пользователя, исполнителя и статуса
     * 
     * @return Tasks[] Массив задач
     */
    public static function AllTasks()
    {
        $tasks = Tasks::find()
        ->with(['user', 'executor', 'status'])
        ->orderBy(['id' => SORT_DESC])
        ->all();
        return $tasks;
    }
}
