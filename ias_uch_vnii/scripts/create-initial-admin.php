<?php
/**
 * Создаёт первого пользователя-администратора (admin / admin123), если в БД ещё нет пользователей.
 * Запуск из каталога ias_uch_vnii:
 *   php scripts/create-initial-admin.php
 * или с полным путём к PHP:
 *   C:\xampp\php\php.exe scripts/create-initial-admin.php
 */

$root = dirname(__DIR__);
require $root . '/vendor/autoload.php';
require $root . '/vendor/yiisoft/yii2/Yii.php';

$config = require $root . '/config/console.php';
new yii\console\Application($config);

$db = Yii::$app->db;

$exists = $db->createCommand('SELECT 1 FROM {{%users}} LIMIT 1')->queryScalar();
if ($exists) {
    echo "Пользователи уже есть. Первого админа не создаём.\n";
    exit(0);
}

$passwordHash = Yii::$app->security->generatePasswordHash('admin123');

$db->createCommand()->insert('{{%users}}', [
    'username' => 'admin',
    'full_name' => 'Администратор',
    'email' => 'admin@local',
    'password_hash' => $passwordHash,
    'is_active' => true,
    'is_locked' => false,
    'is_deleted' => false,
])->execute();

$userId = $db->getLastInsertId();
$roleId = $db->createCommand("SELECT id FROM {{%roles}} WHERE role_code = 'admin' LIMIT 1")->queryScalar();

if (!$roleId) {
    echo "Пользователь создан (id=$userId). Роль 'admin' не найдена — назначьте роль вручную в user_roles.\n";
    exit(0);
}

$db->createCommand()->insert('{{%user_roles}}', [
    'user_id' => $userId,
    'role_id' => $roleId,
    'is_active' => true,
    'assigned_at' => date('Y-m-d H:i:s'),
])->execute();

echo "Готово. Создан пользователь:\n  Логин: admin\n  Пароль: admin123\nСмените пароль после первого входа.\n";
