<?php

use yii\db\Migration;
use app\models\entities\Users;

class m251021_112748_fix_invalid_password_hashes extends Migration
{
    /**
     * {@inheritdoc}
     */
    public function safeUp()
    {
        echo "Исправление поврежденных хешей паролей...\n";
        
        // Получаем всех пользователей с паролями
        $users = Users::find()->where(['not', ['password' => null]])->all();
        
        $fixedCount = 0;
        $invalidCount = 0;
        
        foreach ($users as $user) {
            $isValidHash = false;
            
            // Проверяем, является ли это md5 хешем (32 символа, только hex)
            if (strlen($user->password) === 32 && ctype_xdigit($user->password)) {
                $isValidHash = true;
                echo "Пользователь ID: {$user->id} - MD5 хеш (корректный)\n";
            } else {
                // Проверяем, является ли это корректным хешем Yii2
                try {
                    // Пробуем валидировать с любым паролем, чтобы проверить формат хеша
                    Yii::$app->security->validatePassword('test', $user->password);
                    $isValidHash = true;
                    echo "Пользователь ID: {$user->id} - Yii2 хеш (корректный)\n";
                } catch (\Exception $e) {
                    $isValidHash = false;
                    $invalidCount++;
                    echo "Пользователь ID: {$user->id} - ПОВРЕЖДЕННЫЙ хеш: {$user->password}\n";
                    
                    // Устанавливаем временный пароль
                    $user->setPassword('temp_password_' . $user->id);
                    if ($user->save(false)) {
                        $fixedCount++;
                        echo "  -> Исправлен, новый пароль: temp_password_{$user->id}\n";
                    }
                }
            }
        }
        
        echo "\nРезультат:\n";
        echo "Исправлено поврежденных хешей: {$fixedCount}\n";
        echo "Найдено поврежденных хешей: {$invalidCount}\n";
        echo "Всего проверено пользователей: " . count($users) . "\n";
    }

    /**
     * {@inheritdoc}
     */
    public function safeDown()
    {
        echo "m251021_112748_fix_invalid_password_hashes cannot be reverted.\n";

        return false;
    }

    /*
    // Use up()/down() to run migration code without a transaction.
    public function up()
    {

    }

    public function down()
    {
        echo "m251021_112748_fix_invalid_password_hashes cannot be reverted.\n";

        return false;
    }
    */
}
