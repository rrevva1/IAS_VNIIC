<?php

namespace app\models\entities;

use yii\db\ActiveRecord;

class EquipmentImportLog extends ActiveRecord
{
    public static function tableName()
    {
        return 'equipment_import_logs';
    }

    public function rules()
    {
        return [
            [['file_name'], 'required'],
            [['uploaded_by', 'total_rows', 'valid_rows', 'error_rows'], 'integer'],
            [['payload_json'], 'string'],
            [['created_at'], 'safe'],
            [['file_name'], 'string', 'max' => 255],
            [['status'], 'string', 'max' => 32],
        ];
    }

    public function getUploadedBy()
    {
        return $this->hasOne(Users::class, ['id' => 'uploaded_by']);
    }
}

