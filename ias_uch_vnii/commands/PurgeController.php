<?php

namespace app\commands;

use Yii;
use yii\console\Controller;
use yii\console\ExitCode;
use yii\helpers\Console;

/**
 * Очистка операционных данных БД с сохранением учётной записи администратора.
 */
class PurgeController extends Controller
{
    /** @var bool Подтверждение выполнения (без флага команда только предупреждает). */
    public $force = false;

    /** @var string|null Логин сохраняемого администратора */
    public $adminUsername = 'admin';

    public function options($actionID)
    {
        return array_merge(parent::options($actionID), ['force', 'adminUsername']);
    }

    public function optionAliases()
    {
        return ['f' => 'force'];
    }

    /**
     * Удаляет все данные, кроме учётной записи администратора и справочников/ролей для входа.
     *
     * php yii purge/keep-admin --force=1
     */
    public function actionKeepAdmin(): int
    {
        if (!$this->force) {
            $this->stdout("ВНИМАНИЕ: будут удалены все пользователи (кроме администратора),\n", Console::FG_YELLOW);
            $this->stdout("оборудование, заявки, аудит, карточки и прочие операционные данные.\n", Console::FG_YELLOW);
            $this->stdout("Справочники (роли, статусы, типы техники и т.п.) сохраняются.\n\n");
            $this->stdout("Для запуска:\n  php yii purge/keep-admin --force=1\n");
            return ExitCode::OK;
        }

        $db = Yii::$app->db;
        $adminId = $this->resolveAdminUserId();
        if ($adminId === null) {
            $this->stdout("Администратор не найден. Создаём учётную запись admin / admin123...\n", Console::FG_YELLOW);
            $adminId = $this->createInitialAdmin();
            if ($adminId === null) {
                $this->stderr("Не удалось создать администратора. Проверьте наличие роли admin в таблице roles.\n", Console::FG_RED);
                return ExitCode::DATAERR;
            }
        }

        $transaction = $db->beginTransaction();
        try {
            $this->disableAuditImmutableTrigger();
            $deleted = $this->purgeOperationalTables();
            $this->enableAuditImmutableTrigger();

            $usersRemoved = $db->createCommand(
                'DELETE FROM {{%user_roles}} WHERE user_id <> :id',
                [':id' => $adminId]
            )->execute();
            $usersRemoved += $db->createCommand(
                'DELETE FROM {{%users}} WHERE id <> :id',
                [':id' => $adminId]
            )->execute();

            $this->ensureAdminRole($adminId);
            $this->resetSequences();

            $transaction->commit();

            $this->stdout("Готово.\n", Console::FG_GREEN);
            $this->stdout("Сохранён пользователь id={$adminId} (логин: {$this->adminUsername}).\n");
            $this->stdout("Очищено таблиц: " . count($deleted) . ", удалено прочих пользователей/связей: {$usersRemoved}.\n");
            return ExitCode::OK;
        } catch (\Throwable $e) {
            $transaction->rollBack();
            try {
                $this->enableAuditImmutableTrigger();
            } catch (\Throwable $ignored) {
            }
            $this->stderr('Ошибка: ' . $e->getMessage() . "\n", Console::FG_RED);
            return ExitCode::UNSPECIFIED_ERROR;
        }
    }

    private function resolveAdminUserId(): ?int
    {
        $db = Yii::$app->db;
        $username = trim((string) $this->adminUsername);
        if ($username !== '') {
            $id = $db->createCommand(
                'SELECT id FROM {{%users}} WHERE username = :u AND COALESCE(is_deleted, false) = false LIMIT 1',
                [':u' => $username]
            )->queryScalar();
            if ($id) {
                return (int) $id;
            }
        }

        $id = $db->createCommand(
            "SELECT u.id
             FROM {{%users}} u
             INNER JOIN {{%user_roles}} ur ON ur.user_id = u.id AND ur.is_active = true AND ur.revoked_at IS NULL
             INNER JOIN {{%roles}} r ON r.id = ur.role_id AND r.role_code = 'admin'
             WHERE COALESCE(u.is_deleted, false) = false
             ORDER BY u.id
             LIMIT 1"
        )->queryScalar();
        if ($id) {
            return (int) $id;
        }

        $id = $db->createCommand(
            "SELECT id FROM {{%users}}
             WHERE lower(trim(full_name)) IN ('администратор', 'administrator')
               AND COALESCE(is_deleted, false) = false
             ORDER BY id
             LIMIT 1"
        )->queryScalar();

        return $id ? (int) $id : null;
    }

    private function createInitialAdmin(): ?int
    {
        $db = Yii::$app->db;
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

        $adminId = (int) $db->getLastInsertID('users_id_seq');
        $this->adminUsername = 'admin';
        $this->ensureAdminRole($adminId);

        return $adminId;
    }

    private function ensureAdminRole(int $adminId): void
    {
        $db = Yii::$app->db;
        $roleId = $db->createCommand(
            "SELECT id FROM {{%roles}} WHERE role_code = 'admin' LIMIT 1"
        )->queryScalar();
        if (!$roleId) {
            return;
        }

        $hasRole = $db->createCommand(
            'SELECT 1 FROM {{%user_roles}}
             WHERE user_id = :uid AND role_id = :rid AND is_active = true AND revoked_at IS NULL
             LIMIT 1',
            [':uid' => $adminId, ':rid' => $roleId]
        )->queryScalar();
        if ($hasRole) {
            return;
        }

        $db->createCommand()->insert('{{%user_roles}}', [
            'user_id' => $adminId,
            'role_id' => (int) $roleId,
            'is_active' => true,
            'assigned_at' => date('Y-m-d H:i:s'),
        ])->execute();
    }

    /**
     * @return array<string, int> table => rows before purge
     */
    private function purgeOperationalTables(): array
    {
        $db = Yii::$app->db;
        $tables = [
            'import_errors',
            'import_runs',
            'equipment_import_logs',
            'task_attachments',
            'task_equipment',
            'task_history',
            'equip_history',
            'part_char_values',
            'equipment_links',
            'equipment_software',
            'licenses',
            'user_equipment_cards',
            'tasks',
            'desk_attachments',
            'nsi_change_log',
            'equipment',
            'locations',
            'software',
        ];

        $result = [];
        $existing = [];
        foreach ($tables as $table) {
            if ($db->getTableSchema($table, true) === null) {
                continue;
            }
            $count = (int) $db->createCommand("SELECT COUNT(*) FROM {{%{$table}}}")->queryScalar();
            if ($count > 0) {
                $result[$table] = $count;
                $existing[] = '{{%' . $table . '}}';
            }
        }

        if ($existing !== []) {
            $sql = 'TRUNCATE TABLE ' . implode(', ', $existing) . ' RESTART IDENTITY CASCADE';
            $db->createCommand($sql)->execute();
        }

        if ($db->getTableSchema('audit_events', true) !== null) {
            $count = (int) $db->createCommand('SELECT COUNT(*) FROM {{%audit_events}}')->queryScalar();
            if ($count > 0) {
                $result['audit_events'] = $count;
                $db->createCommand('TRUNCATE TABLE {{%audit_events}} RESTART IDENTITY')->execute();
            }
        }

        return $result;
    }

    private function disableAuditImmutableTrigger(): void
    {
        if (Yii::$app->db->getTableSchema('audit_events', true) === null) {
            return;
        }
        Yii::$app->db->createCommand(
            'DROP TRIGGER IF EXISTS trg_audit_events_immutable ON audit_events'
        )->execute();
    }

    private function enableAuditImmutableTrigger(): void
    {
        if (Yii::$app->db->getTableSchema('audit_events', true) === null) {
            return;
        }
        $exists = Yii::$app->db->createCommand(
            "SELECT 1 FROM pg_trigger WHERE tgname = 'trg_audit_events_immutable' LIMIT 1"
        )->queryScalar();
        if ($exists) {
            return;
        }
        Yii::$app->db->createCommand(
            'CREATE TRIGGER trg_audit_events_immutable
             BEFORE UPDATE OR DELETE ON audit_events
             FOR EACH ROW EXECUTE FUNCTION prevent_update_delete()'
        )->execute();
    }

    private function resetSequences(): void
    {
        $db = Yii::$app->db;
        $tables = [
            'users',
            'equipment',
            'tasks',
            'locations',
            'audit_events',
            'desk_attachments',
            'part_char_values',
            'equip_history',
            'task_history',
            'task_equipment',
            'task_attachments',
            'import_runs',
            'import_errors',
            'software',
            'licenses',
            'user_equipment_cards',
            'equipment_links',
            'equipment_import_logs',
        ];

        foreach ($tables as $table) {
            if ($db->getTableSchema($table, true) === null) {
                continue;
            }
            $seq = $db->createCommand("SELECT pg_get_serial_sequence(:t, 'id')", [':t' => 'tech_accounting.' . $table])->queryScalar();
            if (!$seq) {
                continue;
            }
            $maxId = (int) $db->createCommand("SELECT COALESCE(MAX(id), 0) FROM {{%{$table}}}")->queryScalar();
            $next = $maxId > 0 ? $maxId : 1;
            $db->createCommand("SELECT setval(:seq, :next, :isCalled)", [
                ':seq' => $seq,
                ':next' => $next,
                ':isCalled' => $maxId > 0,
            ])->execute();
        }
    }
}
