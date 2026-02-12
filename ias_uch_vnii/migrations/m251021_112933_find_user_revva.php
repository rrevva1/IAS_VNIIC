<?php

use yii\db\Migration;
use app\models\entities\Users;

class m251021_112933_find_user_revva extends Migration
{
    /**
     * {@inheritdoc}
     */
    public function safeUp()
    {
        echo "Поиск пользователя Revva Ruben Rubenovich...\n";
        
        // Ищем пользователя по ФИО
        $users = Users::find()->all();
        
        echo "Все пользователи в системе:\n";
        foreach ($users as $user) {
            echo "ID: {$user->id} | ФИО: '{$user->fio}' | Email: {$user->email}\n";
            
            // Проверяем, содержит ли ФИО "Revva" или "Ruben"
            if (stripos($user->fio, 'Revva') !== false || 
                stripos($user->fio, 'Ruben') !== false) {
                echo "  *** НАЙДЕН ПОЛЬЗОВАТЕЛЬ! ***\n";
                
                // Сбрасываем пароль
                $newPassword = 'revva123';
                $user->setPassword($newPassword);
                
                if ($user->save(false)) {
                    echo "  Пароль сброшен! Новый пароль: {$newPassword}\n";
                } else {
                    echo "  Ошибка при сбросе пароля\n";
                }
            }
        }
        
        echo "\nЕсли пользователь не найден, проверьте точное написание ФИО.\n";
    }

    /**
     * {@inheritdoc}
     */
    public function safeDown()
    {
        echo "m251021_112933_find_user_revva cannot be reverted.\n";

        return false;
    }

    /*
    // Use up()/down() to run migration code without a transaction.
    public function up()
    {

    }

    public function down()
    {
        echo "m251021_112933_find_user_revva cannot be reverted.\n";

        return false;
    }
    */
}
