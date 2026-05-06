<?php

namespace app\models\entities;

use yii\db\ActiveRecord;

/**
 * Лицензия (licenses).
 * @property int $id
 * @property int $software_id
 * @property string|null $valid_until
 * @property string|null $notes
 */
class License extends ActiveRecord
{
    public static function tableName()
    {
        return 'licenses';
    }

    public function rules()
    {
        return [
            [['software_id'], 'required'],
            [['software_id'], 'integer'],
            [['valid_until'], 'safe'],
            [['notes'], 'string'],
            [['software_id'], 'exist', 'targetClass' => Software::class, 'targetAttribute' => ['software_id' => 'id']],
        ];
    }

    public function attributeLabels()
    {
        return [
            'software_id' => 'ПО',
            'valid_until' => 'Срок действия по',
            'notes' => 'Примечание',
        ];
    }

    public function getSoftware()
    {
        return $this->hasOne(Software::class, ['id' => 'software_id']);
    }
}
