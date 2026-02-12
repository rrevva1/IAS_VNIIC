<?php
namespace app\models\dictionaries;
use Yii;
use yii\helpers\ArrayHelper; // добавил 
/**
 * Модель для таблицы "roles".
 *
 * @property int $id
 * @property string $role_name
 *
 * @property Users[] $users
 */
class Roles extends \yii\db\ActiveRecord
{
    /**
     * Возвращает имя таблицы
     */
    public static function tableName()
    {
        return 'roles';
    }
    /**
     * Правила валидации
     */
    public function rules()
    {
        return [
            [['role_name'], 'required'],
            [['role_name'], 'string', 'max' => 50],
            [['role_name'], 'unique'],
        ];
    }
    /**
     * Метки атрибутов
     */
    public function attributeLabels()
    {
        return [
            'id' => 'ID',
            'role_name' => 'Роль',
        ];
    }
    /**
     * Получить запрос для [[Users]].
     *
     * @return \yii\db\ActiveQuery
     */
    public function getUsers()
    {
        return $this->hasMany(Users::class, ['id_role' => 'id_role']);
    }
 /**
     * Вернёт массив [id => role_name] для дропдауна
     */
    public static function getList(): array
    {
        return ArrayHelper::map(
            self::find()->orderBy(['role_name' => SORT_ASC])->all(),
            'id_role',
            'role_name'
        );
    }
}
