<?php
/**
 * @link https://www.yiiframework.com/
 * @copyright Copyright (c) 2008 Yii Software LLC
 * @license https://www.yiiframework.com/license/
 */

namespace app\commands;

use yii\console\Controller;
use yii\console\ExitCode;

/**
 * Консольная команда Hello
 * Пример консольной команды для демонстрации работы с консолью в Yii2
 *
 * @author Qiang Xue <qiang.xue@gmail.com>
 * @since 2.0
 */
class HelloController extends Controller
{
    /**
     * Выводит переданное сообщение в консоль
     * Пример использования: php yii hello "Привет мир"
     * 
     * @param string $message Сообщение для вывода
     * @return int Код завершения
     */
    public function actionIndex($message = 'hello world')
    {
        echo $message . "\n";

        return ExitCode::OK;
    }
}
