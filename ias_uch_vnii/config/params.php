<?php

return [
    'adminEmail' => 'admin@example.com',
    'senderEmail' => 'noreply@example.com',
    'senderName' => 'Example.com mailer',
    'bsVersion' => '5.0',
    /** Версия приложения (отображается на странице «О проекте») */
    'appVersion' => '1.0',
    /** Базовый URL OpenAI-совместимого API (LM Studio по умолчанию) */
    'llm_base_url' => rtrim(trim((string) (getenv('LLM_BASE_URL') ?: 'http://localhost:1234/v1')), '/'),
    /** Локальная LLM: включена, если LLM_ENABLED=1/true/yes; если не задано — включено по умолчанию при базовом URL localhost:1234 (LM Studio) */
    'llm_enabled' => (function () {
        $env = strtolower(trim((string) (getenv('LLM_ENABLED') ?: '')));
        $base = rtrim(trim((string) (getenv('LLM_BASE_URL') ?: 'http://localhost:1234/v1')), '/');
        if (in_array($env, ['1', 'true', 'yes'], true)) {
            return true;
        }
        if (in_array($env, ['0', 'false', 'no'], true)) {
            return false;
        }
        return (strpos($base, 'localhost:1234') !== false || strpos($base, '127.0.0.1:1234') !== false);
    })(),
    /** Имя модели в LM Studio (например gemma-3). Пусто — модель по умолчанию сервера */
    'llm_model' => trim((string) (getenv('LLM_MODEL') ?: '')) ?: null,
    /** API-ключ (для LM Studio обычно не нужен) */
    'llm_api_key' => trim((string) (getenv('LLM_API_KEY') ?: '')) ?: null,
    /** Передавать в LLM при неопределённом интенте RAG-контекст (пользователи, локации, статусы). По умолчанию включено; выключить: LLM_USE_RAG=0. */
    'llm_use_rag' => (function () {
        $e = strtolower(trim((string) (getenv('LLM_USE_RAG') ?: '')));
        return !in_array($e, ['0', 'false', 'no'], true);
    })(),

    // --- Векторный RAG (ChromaDB + эмбеддинги), опционально ---
    /** Использовать поиск по векторной БД при неопределённом интенте. Включить: LLM_USE_VECTOR_RAG=1 или в конфиге true; выключить: LLM_USE_VECTOR_RAG=0 */
    'llm_use_vector_rag' => (function () {
        $e = strtolower(trim((string) (getenv('LLM_USE_VECTOR_RAG') ?: '')));
        if (in_array($e, ['0', 'false', 'no'], true)) {
            return false;
        }
        if (in_array($e, ['1', 'true', 'yes'], true)) {
            return true;
        }
        return true;
    })(),
    /** Путь к каталогу ChromaDB (алиас или абсолютный путь, резолвится через Yii::getAlias) */
    'rag_vector_db_path' => getenv('RAG_VECTOR_DB_PATH') ?: '@runtime/chroma_db',
    /** Каталог Python-скриптов для RAG (build_vector_db.py, search_context.py) */
    'rag_scripts_path' => getenv('RAG_SCRIPTS_PATH') ?: '@app/scripts',
    /** Таблицы для экспорта в векторный индекс */
    'rag_tables' => ['tasks', 'equipment', 'locations', 'users'],
    /** Число чанков в ответе векторного поиска (top_k) */
    'rag_top_k' => (int) (getenv('RAG_TOP_K') ?: 5),
    /** Лимит строк на таблицу при экспорте */
    'rag_limit_per_table' => (int) (getenv('RAG_LIMIT_PER_TABLE') ?: 1000),
    /** Путь к локальной папке с моделью эмбеддингов (sentence-transformers, напр. intfloat/multilingual-e5-base). Если задан и каталог существует — загрузка с Hugging Face не выполняется. Можно задать через RAG_EMBEDDING_MODEL_PATH. */
    'rag_embedding_model_path' => trim((string) (getenv('RAG_EMBEDDING_MODEL_PATH') ?: '')) ?: null,
    /** Исполняемый файл Python: из RAG_PYTHON_BINARY или автоопределение на Windows (раз и навсегда для окружения) */
    'rag_python_binary' => (function () {
        $explicit = trim((string) (getenv('RAG_PYTHON_BINARY') ?: ''));
        if ($explicit !== '') {
            return $explicit;
        }
        if (PHP_OS_FAMILY !== 'Windows') {
            return null;
        }
        $localAppData = getenv('LOCALAPPDATA');
        $programFiles = getenv('ProgramFiles');
        $candidates = [];
        if ($localAppData !== false && $localAppData !== '') {
            $pythonBase = $localAppData . DIRECTORY_SEPARATOR . 'Programs' . DIRECTORY_SEPARATOR . 'Python';
            if (is_dir($pythonBase)) {
                $versions = glob($pythonBase . DIRECTORY_SEPARATOR . 'Python*', GLOB_ONLYDIR);
                if ($versions !== false) {
                    rsort($versions);
                    foreach ($versions as $dir) {
                        $exe = $dir . DIRECTORY_SEPARATOR . 'python.exe';
                        if (is_file($exe)) {
                            $candidates[] = $exe;
                        }
                    }
                }
            }
            $windowsApps = $localAppData . DIRECTORY_SEPARATOR . 'Microsoft' . DIRECTORY_SEPARATOR . 'WindowsApps';
            if (is_dir($windowsApps)) {
                $exe = $windowsApps . DIRECTORY_SEPARATOR . 'python.exe';
                if (is_file($exe)) {
                    $candidates[] = $exe;
                }
                $exe3 = $windowsApps . DIRECTORY_SEPARATOR . 'python3.exe';
                if (is_file($exe3)) {
                    $candidates[] = $exe3;
                }
                $subdirs = glob($windowsApps . DIRECTORY_SEPARATOR . 'PythonSoftwareFoundation.Python.*', GLOB_ONLYDIR);
                if ($subdirs !== false) {
                    rsort($subdirs);
                    foreach ($subdirs as $dir) {
                        $exe = $dir . DIRECTORY_SEPARATOR . 'python.exe';
                        if (is_file($exe)) {
                            $candidates[] = $exe;
                        }
                    }
                }
            }
        }
        if ($programFiles !== false && $programFiles !== '' && is_dir($programFiles)) {
            $pythonBase = $programFiles . DIRECTORY_SEPARATOR . 'Python313';
            if (is_dir($pythonBase)) {
                $exe = $pythonBase . DIRECTORY_SEPARATOR . 'python.exe';
                if (is_file($exe)) {
                    $candidates[] = $exe;
                }
            }
            foreach (['Python312', 'Python311', 'Python310', 'Python39'] as $ver) {
                $pythonBase = $programFiles . DIRECTORY_SEPARATOR . $ver;
                if (is_dir($pythonBase)) {
                    $exe = $pythonBase . DIRECTORY_SEPARATOR . 'python.exe';
                    if (is_file($exe)) {
                        $candidates[] = $exe;
                    }
                    break;
                }
            }
        }
        return $candidates !== [] ? $candidates[0] : null;
    })(),
];
