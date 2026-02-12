<?php

use yii\db\Migration;

/**
 * Создаёт первого пользователя-администратора, если в БД ещё нет пользователей.
 * Для БД IAS_VNIIC, схема tech_accounting.
 *
 * Логин: admin
 * Пароль: admin123
 *
 * После первого входа рекомендуется сменить пароль.
 */
class m260212_100000_insert_initial_admin_user extends Migration
{
    public function safeUp()
    {
        $exists = $this->db->createCommand(
            'SELECT 1 FROM {{%users}} LIMIT 1'
        )->queryScalar();

        if ($exists) {
            echo "Пользователи уже есть, первого админа не создаём.\n";
            return true;
        }

        $passwordHash = \Yii::$app->security->generatePasswordHash('admin123');

        $this->insert('{{%users}}', [
            'username' => 'admin',
            'full_name' => 'Администратор',
            'email' => 'admin@local',
            'password_hash' => $passwordHash,
            'is_active' => true,
            'is_locked' => false,
            'is_deleted' => false,
        ]);

        $userId = $this->db->getLastInsertId();
        $roleId = $this->db->createCommand(
            "SELECT id FROM {{%roles}} WHERE role_code = 'admin' LIMIT 1"
        )->queryScalar();

        if (!$roleId) {
            echo "Роль admin не найдена. Назначите роль пользователю вручную.\n";
            return true;
        }

        $this->insert('{{%user_roles}}', [
            'user_id' => $userId,
            'role_id' => $roleId,
            'is_active' => true,
            'assigned_at' => date('Y-m-d H:i:s'),
        ]);

        echo "Создан пользователь admin (пароль: admin123). Смените пароль после входа.\n";
        return true;
    }

    public function safeDown()
    {
        $userId = $this->db->createCommand(
            "SELECT id FROM {{%users}} WHERE username = 'admin' LIMIT 1"
        )->queryScalar();

        if ($userId) {
            $this->delete('{{%user_roles}}', ['user_id' => $userId]);
            $this->delete('{{%users}}', ['id' => $userId]);
        }

        return true;
    }
}
