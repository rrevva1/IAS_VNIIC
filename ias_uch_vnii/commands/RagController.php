<?php

namespace app\commands;

use app\components\rag\DatabaseExporter;
use Yii;
use yii\console\Controller;
use yii\console\ExitCode;
use yii\helpers\Console;

/**
 * Построение векторного индекса RAG (ChromaDB) из данных БД.
 * Требуется: Python 3, chromadb, sentence-transformers (см. scripts/requirements.txt).
 */
class RagController extends Controller
{
    /**
     * Построение индекса: экспорт таблиц в JSON, вызов build_vector_db.py.
     *
     * @return int
     */
    public function actionBuildIndex()
    {
        $this->stdout("Начинаем экспорт данных из БД...\n");

        $exporter = new DatabaseExporter();
        $documents = $exporter->exportTablesToDocuments([]);

        $this->stdout("Экспортировано документов: " . count($documents) . "\n", Console::FG_GREEN);

        $runtimePath = Yii::getAlias('@runtime');
        $docsFile = $runtimePath . DIRECTORY_SEPARATOR . 'rag_docs.json';
        $written = file_put_contents($docsFile, json_encode($documents, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT));
        if ($written === false) {
            $this->stderr("Ошибка записи файла: {$docsFile}\n", Console::FG_RED);
            return ExitCode::UNSPECIFIED_ERROR;
        }

        $scriptsPath = Yii::getAlias(Yii::$app->params['rag_scripts_path'] ?? '@app/scripts');
        $chromaPath = Yii::getAlias(Yii::$app->params['rag_vector_db_path'] ?? '@runtime/chroma_db');
        $scriptPath = $scriptsPath . DIRECTORY_SEPARATOR . 'build_vector_db.py';

        if (!is_file($scriptPath)) {
            $this->stderr("Скрипт не найден: {$scriptPath}\n", Console::FG_RED);
            return ExitCode::UNSPECIFIED_ERROR;
        }

        $python = $this->getPythonBinary();
        $pythonArgs = $this->getPythonArgs();
        $cmd = escapeshellarg($python) . $pythonArgs . ' ' . escapeshellarg($scriptPath)
            . ' ' . escapeshellarg($docsFile)
            . ' ' . escapeshellarg($chromaPath);

        $modelPath = Yii::$app->params['rag_embedding_model_path'] ?? null;
        if ($modelPath !== null && $modelPath !== '') {
            $modelPath = Yii::getAlias($modelPath);
            if (is_dir($modelPath)) {
                $cmd .= ' ' . escapeshellarg($modelPath);
            }
        }

        $this->stdout("Запуск Python...\n");
        passthru($cmd, $exitCode);

        if ($exitCode !== 0) {
            $this->stderr("Ошибка при создании индекса (код {$exitCode}).\n", Console::FG_RED);
            return ExitCode::UNSPECIFIED_ERROR;
        }

        $this->stdout("Индекс успешно создан.\n", Console::FG_GREEN);
        return ExitCode::OK;
    }

    private function getPythonBinary(): string
    {
        $binary = Yii::$app->params['rag_python_binary'] ?? null;
        if ($binary !== null && $binary !== '') {
            return $binary;
        }
        return PHP_OS_FAMILY === 'Windows' ? 'py' : 'python3';
    }

    /** Аргументы после исполняемого файла (например " -3" для py -3). */
    private function getPythonArgs(): string
    {
        if (Yii::$app->params['rag_python_binary'] ?? null) {
            return '';
        }
        return PHP_OS_FAMILY === 'Windows' ? ' -3' : '';
    }
}
