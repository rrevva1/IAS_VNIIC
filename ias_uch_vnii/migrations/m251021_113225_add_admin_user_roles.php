<?php

use yii\db\Migration;
use app\models\dictionaries\Roles;

class m251021_113225_add_admin_user_roles extends Migration
{
    /**
     * {@inheritdoc}
     */
    public function safeUp()
    {
        echo "Создание ролей admin и user...\n";
        
        // Создаем роль администратора
        $adminRole = new Roles();
        $adminRole->role_name = 'admin';
        if ($adminRole->save()) {
            echo "Роль 'admin' создана с ID: {$adminRole->id}\n";
        } else {
            echo "Ошибка создания роли 'admin': " . implode(', ', $adminRole->getFirstErrors()) . "\n";
        }
        
        // Создаем роль пользователя
        $userRole = new Roles();
        $userRole->role_name = 'user';
        if ($userRole->save()) {
            echo "Роль 'user' создана с ID: {$userRole->id}\n";
        } else {
            echo "Ошибка создания роли 'user': " . implode(', ', $userRole->getFirstErrors()) . "\n";
        }
        
        // Назначаем роли пользователям
        echo "\nНазначение ролей пользователям:\n";
        
        // Revva Ruben Rubenovich - администратор
        $revva = \app\models\Users::findOne(['email' => 'rrevva@vniicentr.ru']);
        if ($revva) {
            $revva->role_id = $adminRole->id;
            if ($revva->save()) {
                echo "Revva Ruben Rubenovich назначен администратором\n";
            }
        }
        
        // Остальные пользователи - обычные пользователи
        $otherUsers = \app\models\Users::find()->where(['!=', 'email', 'rrevva@vniicentr.ru'])->all();
        foreach ($otherUsers as $user) {
            $user->role_id = $userRole->id;
            if ($user->save()) {
                echo "{$user->fio} назначен обычным пользователем\n";
            }
        }
        
        echo "\nРоли успешно созданы и назначены!\n";
    }

    /**
     * {@inheritdoc}
     */
    public function safeDown()
    {
        echo "m251021_113225_add_admin_user_roles cannot be reverted.\n";

        return false;
    }

    /*
    // Use up()/down() to run migration code without a transaction.
    public function up()
    {

    }

    public function down()
    {
        echo "m251021_113225_add_admin_user_roles cannot be reverted.\n";

        return false;
    }
    */
}
