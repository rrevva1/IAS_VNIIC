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
        . "Модель сущностей системы (онтология):\n"
        . "- Пользователь — сотрудник (ФИО); может быть автором заявки, исполнителем заявки, ответственным за технику.\n"
        . "- Заявка — обращение с описанием, статусом, автором (requester), исполнителем (executor); статусы из справочника (Новая, В работе, Выполнена и т.д.).\n"
        . "- Техника (оборудование) — единица учёта с наименованием, инв. номером, типом, статусом; привязана к ответственному (Пользователь) и к локации.\n"
        . "- Локация — кабинет, склад, серверная, лаборатория и т.д.; в локации может находиться техника.\n\n"
        . "Направления запросов (отвечай только в их рамках, не придумывай данные):\n"
        . "1) Заявки — примеры: «Мои заявки», «Заявки за месяц», «Открытые заявки», «Заявки где я исполнитель», «Статистика заявок», «Покажи заявки».\n"
        . "2) Техника по ответственному — примеры: «Техника [ФИО]», «Покажи технику Печерского», «Что закреплено за Ивановым», «Инвентарь Петрова».\n"
        . "3) Техника по локации — примеры: «Техника в кабинете 203», «Оборудование в серверной», «Техника по кабинетам», «Что в кабинете 205».\n"
        . "4) Справочно — примеры: «Список кабинетов», «Список пользователей», «Справка», «Помощь».\n\n"
        . "Отвечай кратко и по делу. Используй контекст системы (если передан) для ориентации в реальных ФИО, локациях и статусах. Если запрос неоднозначен или не по теме системы — вежливо предложи примеры из перечисленных направлений. Не придумывай фактические данные (числа, списки) — только подсказки или ссылку на переданный контекст.";

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
            Yii::info('LlmClient: LLM disabled by config (llm_enabled=false or not set).', __METHOD__);
            return null;
        }

        $baseUrl = $params['llm_base_url'] ?? 'http://localhost:1234/v1';
        $model = $params['llm_model'] ?? null;
        $apiKey = $params['llm_api_key'] ?? null;

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
                'timeout' => 30,
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
            Yii::warning('LlmClient: request failed for ' . $url . ' — ' . $msg, __METHOD__);
            return null;
        }

        $data = json_decode($response, true);
        if (!is_array($data) || !isset($data['choices'][0]['message']['content'])) {
            return null;
        }

        $text = trim((string) $data['choices'][0]['message']['content']);
        return $text !== '' ? $text : null;
    }
}
