<?php

namespace app\commands;

use Yii;
use yii\console\Controller;
use yii\console\ExitCode;
use yii\helpers\Console;

/**
 * Импорт из «Основной Учет.xlsx» (листы АРМ и Принтеры).
 * Вызывает скрипт scripts/load_ou_main.py с указанным путём к файлу.
 * Требуется: Python 3, openpyxl, psycopg2-binary; переменные окружения PGHOST, PGPORT, PGDATABASE, PGUSER, PGPASSWORD (или значения по умолчанию из скрипта).
 */
class ImportOuController extends Controller
{
    /**
     * Запуск импорта из файла «Основной Учет.xlsx».
     * @param string $file Путь к файлу Excel (по умолчанию — Основной Учет.xlsx в корне проекта).
     * @return int
     */
    public function actionIndex($file = '')
    {
        $projectRoot = dirname(Yii::getAlias('@app'));
        $scriptPath = $projectRoot . DIRECTORY_SEPARATOR . 'scripts' . DIRECTORY_SEPARATOR . 'load_ou_main.py';
        if (!is_file($scriptPath)) {
            $this->stderr("Скрипт не найден: {$scriptPath}\n", Console::FG_RED);
            return ExitCode::UNSPECIFIED_ERROR;
        }
        if ($file !== '') {
            if (!is_file($file)) {
                $this->stderr("Файл не найден: {$file}\n", Console::FG_RED);
                return ExitCode::UNSPECIFIED_ERROR;
            }
            putenv('OU_MAIN_EXCEL=' . $file);
        } else {
            $defaultFile = $projectRoot . DIRECTORY_SEPARATOR . 'Основной Учет.xlsx';
            if (!is_file($defaultFile)) {
                $this->stderr("Файл по умолчанию не найден: {$defaultFile}\n", Console::FG_RED);
                $this->stdout("Укажите путь: php yii import-ou <путь к файлу>\n");
                return ExitCode::UNSPECIFIED_ERROR;
            }
        }
        $cmd = escapeshellarg(PHP_OS_FAMILY === 'Windows' ? 'python' : 'python3') . ' ' . escapeshellarg($scriptPath);
        $this->stdout("Запуск: {$cmd}\n");
        passthru($cmd, $exitCode);
        return $exitCode === 0 ? ExitCode::OK : ExitCode::UNSPECIFIED_ERROR;
    }
}
