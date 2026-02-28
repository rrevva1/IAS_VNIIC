<?php

namespace app\components\assistant;

use Yii;

/**
 * Клиент к локальной LLM (LM Studio и др.) по OpenAI-совместимому API.
 * Используется помощником при неопределённом интенте для генерации ответа.
 */
class LlmClient
{
    /** Базовое описание системы для системного промта */
    private const SYSTEM_CONTEXT = "Ты — помощник в системе учёта технических средств предприятия (ИАС). "
        . "ИАС предназначена для учёта технических средств и заявок.\n\n"
        . "Ключевые сущности системы (ориентируйся только на них):\n"
        . "• Пользователь — сотрудник (ФИО); автор/исполнитель заявки, ответственный за технику. Атрибуты: ФИО, активность.\n"
        . "• Заявка — обращение с описанием, статусом, автором, исполнителем. Атрибуты: описание, статус (из справочника), даты, автор, исполнитель.\n"
        . "• Техническое средство (техника, оборудование) — единица учёта. Атрибуты: наименование, инв. номер, тип, статус, ответственный (Пользователь), локация; характеристики: ЦП/процессор (модель, частота), ОЗУ (объём), диск, дата ввода/постановки на учёт.\n"
        . "• Локация — место размещения: кабинет, склад, серверная, лаборатория. Атрибуты: название, тип, код. В локации может находиться техника.\n"
        . "• Статусы заявок — справочник (Новая, В работе, Выполнена и т.д.).\n\n"
        . "Правило ответов: Отвечай только в рамках перечисленных сущностей и данных из блока «Контекст системы» ниже. Не придумывай записи, числа, списки техники, ФИО или кабинеты — только то, что явно передано в контексте. Если данных для ответа нет — скажи об этом и предложи уточнить запрос или открыть соответствующий раздел системы.\n\n"
        . "В контексте передаётся блок «Описание системы» — используй его для ответов на вопросы о системе (что это за система, что умеет, какие разделы, сколько техники/локаций/пользователей).\n\n"
        . "Направления запросов (примеры): Заявки (мои, за период, открытые, статистика); техника по ответственному (ФИО); техника по локации (кабинет, серверная); аналитика по технике (самый мощный процессор, самый новый, больше всего ОЗУ — только по данным из контекста); справочно (список кабинетов, пользователей, помощь). Отвечай кратко и по делу.";

    /**
     * Формирует системный контекст с опциональным именем текущего пользователя и RAG-контекстом сущностей.
     *
     * @param string|null $currentUserName ФИО текущего пользователя (опционально)
     * @param string|null $ragContext Текст с актуальными сущностями из БД (пользователи, локации, статусы)
     * @return string Готовый системный промт
     */
    public static function buildSystemContext(?string $currentUserName = null, ?string $ragContext = null): string
    {
        $context = self::SYSTEM_CONTEXT;
        if ($currentUserName !== null && $currentUserName !== '') {
            $context .= "\n\nТекущий пользователь: " . $currentUserName . ".";
        }
        if ($ragContext !== null && $ragContext !== '') {
            $context .= "\n\n" . $ragContext;
        }
        return $context;
    }

    /**
     * Отправляет запрос в локальную LLM и возвращает сгенерированный ответ.
     *
     * @param string $userMessage Текст запроса пользователя
     * @param string|null $systemMessage Переопределение системного контекста (опционально)
     * @return string|null Текст ответа или null при отключённой LLM, ошибке или пустом ответе
     */
    public static function completion(string $userMessage, ?string $systemMessage = null): ?string
    {
        $params = Yii::$app->params;
        $enabled = $params['llm_enabled'] ?? false;
        if (!$enabled) {
            Yii::info('LlmClient: LLM отключён (llm_enabled=false или не задан). Задайте LLM_ENABLED=1 или используйте llm_base_url с localhost:1234 для включения.', __METHOD__);
            return null;
        }

        $baseUrl = $params['llm_base_url'] ?? 'http://localhost:1234/v1';
        $model = $params['llm_model'] ?? null;
        $apiKey = $params['llm_api_key'] ?? null;
        $timeout = (int) ($params['llm_timeout_seconds'] ?? 120);
        if ($timeout < 15) {
            $timeout = 120;
        }

        $messages = [
            ['role' => 'system', 'content' => $systemMessage ?? self::buildSystemContext()],
            ['role' => 'user', 'content' => $userMessage],
        ];

        $body = [
            'messages' => $messages,
            'max_tokens' => 512,
            'temperature' => 0.3,
        ];
        if ($model !== null && $model !== '') {
            $body['model'] = $model;
        } else {
            $body['model'] = 'local';
        }

        $url = $baseUrl . '/chat/completions';
        $headers = [
            'Content-Type: application/json',
            'Accept: application/json',
        ];
        if ($apiKey !== null && $apiKey !== '') {
            $headers[] = 'Authorization: Bearer ' . $apiKey;
        }

        $opts = [
            'http' => [
                'method' => 'POST',
                'header' => implode("\r\n", $headers),
                'content' => json_encode($body, JSON_UNESCAPED_UNICODE),
                'timeout' => $timeout,
            ],
        ];
        $ctx = stream_context_create($opts);

        $response = @file_get_contents($url, false, $ctx);
        if ($response === false && strpos($baseUrl, 'localhost') !== false) {
            $urlFallback = str_replace('localhost', '127.0.0.1', $url);
            $response = @file_get_contents($urlFallback, false, $ctx);
        }
        if ($response === false) {
            $err = error_get_last();
            $msg = $err && isset($err['message']) ? $err['message'] : 'connection failed';
            $statusLine = isset($http_response_header[0]) ? $http_response_header[0] : '';
            Yii::warning(
                'LlmClient: запрос к LLM не удался. URL: ' . $url . '. Ошибка: ' . $msg
                . ($statusLine !== '' ? '. Ответ сервера: ' . $statusLine : '')
                . ' Проверьте: LM Studio запущен, Local Server включён, адрес llm_base_url совпадает с сервером (например http://localhost:1234/v1).',
                __METHOD__
            );
            return null;
        }

        $data = json_decode($response, true);
        if (!is_array($data) || !isset($data['choices'][0]['message']['content'])) {
            $preview = is_string($response) ? mb_substr($response, 0, 500) : '';
            Yii::warning(
                'LlmClient: неверная структура ответа от LLM (ожидается choices[0].message.content). '
                . 'Возможно модель не загружена в LM Studio или другой формат API. Тело ответа (начало): ' . $preview,
                __METHOD__
            );
            return null;
        }

        $text = trim((string) $data['choices'][0]['message']['content']);
        return $text !== '' ? $text : null;
    }

    /**
     * Отправляет запрос в LLM с историей диалога (массив сообщений user/assistant).
     * Используется для свободного диалога с учётом контекста предыдущих реплик.
     *
     * @param array<int, array{role: string, content: string}> $conversationHistory Пары [user, assistant], только role и content
     * @param string $currentUserMessage Текущее сообщение пользователя
     * @param string|null $systemPrompt Системный промт (онтология + RAG). Если null — buildSystemContext() без параметров
     * @return string|null Текст ответа или null при отключённой LLM, ошибке или пустом ответе
     */
    public static function completionWithHistory(array $conversationHistory, string $currentUserMessage, ?string $systemPrompt = null): ?string
    {
        $params = Yii::$app->params;
        $enabled = $params['llm_enabled'] ?? false;
        if (!$enabled) {
            Yii::info('LlmClient: LLM отключён (llm_enabled=false или не задан). Задайте LLM_ENABLED=1 или используйте llm_base_url с localhost:1234 для включения.', __METHOD__);
            return null;
        }

        $baseUrl = $params['llm_base_url'] ?? 'http://localhost:1234/v1';
        $model = $params['llm_model'] ?? null;
        $apiKey = $params['llm_api_key'] ?? null;
        $timeout = (int) ($params['llm_timeout_seconds'] ?? 120);
        if ($timeout < 15) {
            $timeout = 120;
        }

        $messages = [
            ['role' => 'system', 'content' => $systemPrompt ?? self::buildSystemContext()],
        ];
        foreach ($conversationHistory as $item) {
            $role = isset($item['role']) ? (string) $item['role'] : 'user';
            $content = isset($item['content']) ? (string) $item['content'] : '';
            if ($content === '' || !in_array($role, ['user', 'assistant'], true)) {
                continue;
            }
            $messages[] = ['role' => $role, 'content' => $content];
        }
        $messages[] = ['role' => 'user', 'content' => $currentUserMessage];

        $body = [
            'messages' => $messages,
            'max_tokens' => 512,
            'temperature' => 0.3,
        ];
        if ($model !== null && $model !== '') {
            $body['model'] = $model;
        } else {
            $body['model'] = 'local';
        }

        $url = $baseUrl . '/chat/completions';
        $headers = [
            'Content-Type: application/json',
            'Accept: application/json',
        ];
        if ($apiKey !== null && $apiKey !== '') {
            $headers[] = 'Authorization: Bearer ' . $apiKey;
        }

        $opts = [
            'http' => [
                'method' => 'POST',
                'header' => implode("\r\n", $headers),
                'content' => json_encode($body, JSON_UNESCAPED_UNICODE),
                'timeout' => $timeout,
            ],
        ];
        $ctx = stream_context_create($opts);

        $response = @file_get_contents($url, false, $ctx);
        if ($response === false && strpos($baseUrl, 'localhost') !== false) {
            $urlFallback = str_replace('localhost', '127.0.0.1', $url);
            $response = @file_get_contents($urlFallback, false, $ctx);
        }
        if ($response === false) {
            $err = error_get_last();
            $msg = $err && isset($err['message']) ? $err['message'] : 'connection failed';
            $statusLine = isset($http_response_header[0]) ? $http_response_header[0] : '';
            Yii::warning(
                'LlmClient: запрос к LLM не удался. URL: ' . $url . '. Ошибка: ' . $msg
                . ($statusLine !== '' ? '. Ответ сервера: ' . $statusLine : '')
                . ' Проверьте: LM Studio запущен, Local Server включён, llm_base_url совпадает (например http://localhost:1234/v1).',
                __METHOD__
            );
            return null;
        }

        $data = json_decode($response, true);
        if (!is_array($data) || !isset($data['choices'][0]['message']['content'])) {
            $preview = is_string($response) ? mb_substr($response, 0, 500) : '';
            Yii::warning(
                'LlmClient: неверная структура ответа от LLM (ожидается choices[0].message.content). '
                . 'Возможно модель не загружена в LM Studio. Тело ответа (начало): ' . $preview,
                __METHOD__
            );
            return null;
        }

        $text = trim((string) $data['choices'][0]['message']['content']);
        return $text !== '' ? $text : null;
    }
}
