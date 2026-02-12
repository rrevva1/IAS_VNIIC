<?php

use yii\db\Migration;
use app\models\entities\Users;

class m251021_112508_update_passwords_to_secure_hash extends Migration
{
    /**
     * {@inheritdoc}
     */
    public function safeUp()
    {
        echo "Обновление паролей пользователей с md5 на безопасное хеширование...\n";
        
        // Получаем всех пользователей с паролями в формате md5
        $users = Users::find()->where(['not', ['password' => null]])->all();
        
        $updatedCount = 0;
        foreach ($users as $user) {
            // Проверяем, является ли пароль md5 хешем (32 символа, только hex)
            if (strlen($user->password) === 32 && ctype_xdigit($user->password)) {
                // Это md5 хеш, нужно обновить
                // Создаем временный пароль для обновления
                $tempPassword = 'temp_password_' . $user->id . '_' . time();
                $user->setPassword($tempPassword);
                
                // Сохраняем с новым хешем
                if ($user->save(false)) {
                    $updatedCount++;
                    echo "Обновлен пользователь ID: {$user->id}, Email: {$user->email}\n";
                }
            }
        }
        
        echo "Обновлено {$updatedCount} пользователей.\n";
        echo "ВНИМАНИЕ: Все пользователи должны будут сбросить пароли через форму восстановления!\n";
    }

    /**
     * {@inheritdoc}
     */
    public function safeDown()
    {
        echo "Эта миграция не может быть отменена, так как пароли были обновлены на безопасное хеширование.\n";
        return false;
    }

    /*
    // Use up()/down() to run migration code without a transaction.
    public function up()
    {

    }

    public function down()
    {
        echo "m251021_112508_update_passwords_to_secure_hash cannot be reverted.\n";

        return false;
    }
    */
}
