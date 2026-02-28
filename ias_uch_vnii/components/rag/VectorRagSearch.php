<?php

namespace app\components\rag;

use Yii;
use yii\base\Component;

/**
 * Поиск релевантных чанков в векторной БД ChromaDB через вызов Python-скрипта.
 * Используется при неопределённом интенте для дополнения RAG-контекста перед вызовом LLM.
 */
class VectorRagSearch extends Component
{
    /** Таймаут запуска Python (секунды) */
    public $timeout = 15;

    /**
     * Поиск релевантных документов по запросу.
     *
     * @param string $query Текст запроса пользователя
     * @param int|null $topK Количество чанков (null — из params['rag_top_k'])
     * @return array<int, array{content: string, metadata: array, relevance_score: float}>
     */
    public function search(string $query, ?int $topK = null): array
    {
        $params = Yii::$app->params;
        if (empty($params['llm_use_vector_rag'])) {
            return [];
        }

        $chromaPath = $params['rag_vector_db_path'] ?? null;
        $scriptsPath = $params['rag_scripts_path'] ?? null;
        if ($chromaPath === null || $chromaPath === '' || $scriptsPath === null || $scriptsPath === '') {
            return [];
        }

        $chromaPath = Yii::getAlias($chromaPath);
        $scriptsPath = Yii::getAlias($scriptsPath);
        if (!is_dir($chromaPath) || !is_dir($scriptsPath)) {
            return [];
        }

        $scriptPath = $scriptsPath . DIRECTORY_SEPARATOR . 'search_context.py';
        if (!is_file($scriptPath)) {
            Yii::warning('RAG: search_context.py not found at ' . $scriptPath, __METHOD__);
            return [];
        }

        $topK = $topK ?? (int) ($params['rag_top_k'] ?? 5);
        if ($topK < 1) {
            return [];
        }

        $runtimePath = Yii::getAlias('@runtime');
        $queryFile = $runtimePath . DIRECTORY_SEPARATOR . 'rag_query_' . md5(uniqid((string) mt_rand(), true)) . '.json';
        $queryData = [
            'query' => $query,
            'top_k' => $topK,
        ];
        if (file_put_contents($queryFile, json_encode($queryData, JSON_UNESCAPED_UNICODE)) === false) {
            return [];
        }

        try {
            $python = $this->getPythonBinary();
            $pythonArgs = $this->getPythonArgs();
            $cmd = sprintf(
                '%s%s %s %s %s',
                escapeshellarg($python),
                $pythonArgs,
                escapeshellarg($scriptPath),
                escapeshellarg($queryFile),
                escapeshellarg($chromaPath)
            );

            $modelPath = Yii::$app->params['rag_embedding_model_path'] ?? null;
            if ($modelPath !== null && $modelPath !== '') {
                $modelPath = Yii::getAlias($modelPath);
                if (is_dir($modelPath)) {
                    $cmd .= ' ' . escapeshellarg($modelPath);
                }
            }

            $output = $this->runProcess($cmd, $this->timeout);
            @unlink($queryFile);

            if ($output === null || $output === '') {
                return [];
            }

            $decoded = json_decode($output, true);
            if (!is_array($decoded)) {
                Yii::warning('RAG: invalid JSON from search_context.py', __METHOD__);
                return [];
            }

            $result = [];
            foreach ($decoded as $item) {
                if (!is_array($item)) {
                    continue;
                }
                $result[] = [
                    'content' => (string) ($item['content'] ?? ''),
                    'metadata' => is_array($item['metadata'] ?? null) ? $item['metadata'] : [],
                    'relevance_score' => (float) ($item['relevance_score'] ?? 0.0),
                ];
            }
            return $result;
        } catch (\Throwable $e) {
            Yii::warning('RAG VectorRagSearch: ' . $e->getMessage(), __METHOD__);
            @unlink($queryFile);
            return [];
        }
    }

    /**
     * Запуск процесса с таймаутом и захватом stdout.
     */
    private function runProcess(string $command, int $timeoutSeconds): ?string
    {
        $descriptorSpec = [
            0 => ['pipe', 'r'],
            1 => ['pipe', 'w'],
            2 => ['pipe', 'w'],
        ];
        $pipes = [];
        $proc = @proc_open(
            $command,
            $descriptorSpec,
            $pipes,
            null,
            null,
            ['bypass_shell' => true]
        );

        if (!is_resource($proc)) {
            return null;
        }

        fclose($pipes[0]);
        $stdout = stream_get_contents($pipes[1]);
        fclose($pipes[1]);
        $stderr = stream_get_contents($pipes[2]);
        fclose($pipes[2]);

        $end = time() + $timeoutSeconds;
        while (time() < $end) {
            $status = proc_get_status($proc);
            if ($status === false || !$status['running']) {
                break;
            }
            usleep(100000);
        }
        if (proc_get_status($proc)['running'] ?? false) {
            proc_terminate($proc);
            proc_close($proc);
            return null;
        }
        proc_close($proc);

        if ($stderr !== '' && $stderr !== false) {
            Yii::info('RAG search stderr: ' . $stderr, __METHOD__);
        }

        return $stdout !== false ? $stdout : null;
    }

    private function getPythonBinary(): string
    {
        $binary = Yii::$app->params['rag_python_binary'] ?? null;
        if ($binary !== null && $binary !== '') {
            return $binary;
        }
        return PHP_OS_FAMILY === 'Windows' ? 'py' : 'python3';
    }

    private function getPythonArgs(): string
    {
        if (Yii::$app->params['rag_python_binary'] ?? null) {
            return '';
        }
        return PHP_OS_FAMILY === 'Windows' ? ' -3' : '';
    }
}
