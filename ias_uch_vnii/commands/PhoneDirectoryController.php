<?php

namespace app\commands;

use app\models\entities\PhoneDirectory;
use app\models\entities\Users;
use Yii;
use yii\console\Controller;
use yii\console\ExitCode;

/**
 * Синхронизация телефонного справочника с пользователями.
 *
 * Пример: php yii phone-directory/sync
 */
class PhoneDirectoryController extends Controller
{
    /**
     * Импорт/обновление записей person из users + служебные заглушки.
     */
    public function actionSync(): int
    {
        $users = Users::find()
            ->andWhere(['is_deleted' => false])
            ->all();

        $synced = 0;
        $failed = 0;
        foreach ($users as $user) {
            $entry = PhoneDirectory::syncFromUser($user);
            if ($entry !== null) {
                $synced++;
            } else {
                $failed++;
            }
        }

        $services = [
            ['Приёмная', 'Администрация', 10],
            ['Охрана', 'Охрана', 20],
            ['АТС', 'ИТ', 30],
        ];
        $serviceAdded = 0;
        foreach ($services as [$name, $department, $sort]) {
            $exists = PhoneDirectory::find()
                ->where([
                    'entry_type' => PhoneDirectory::TYPE_SERVICE,
                    'full_name' => $name,
                ])
                ->exists();
            if ($exists) {
                continue;
            }
            $row = new PhoneDirectory();
            $row->entry_type = PhoneDirectory::TYPE_SERVICE;
            $row->full_name = $name;
            $row->department = $department;
            $row->is_published = true;
            $row->sort_order = $sort;
            if ($row->save()) {
                $serviceAdded++;
            }
        }

        $total = (int) PhoneDirectory::find()->count();
        $published = (int) PhoneDirectory::find()->where(['is_published' => true])->count();

        $this->stdout("Synced from users: {$synced}\n");
        if ($failed > 0) {
            $this->stdout("Failed: {$failed}\n");
        }
        $this->stdout("Service stubs added: {$serviceAdded}\n");
        $this->stdout("Directory total: {$total}, published: {$published}\n");

        return ExitCode::OK;
    }
}
