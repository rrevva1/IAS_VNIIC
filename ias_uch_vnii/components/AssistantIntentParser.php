<?php

namespace app\components;

use app\models\dictionaries\DicTaskStatus;

/**
 * Парсер интентов для ИИ-помощника: по тексту запроса определяет тип (мои заявки, за период, по статусу, статистика, справка)
 * и формирует параметры для TasksSearch и подпись для ответа.
 */
class AssistantIntentParser
{
    /** Ключевые слова для интента «мои заявки» */
    private const MY_TASKS_KEYWORDS = ['мои заявки', 'мои обращения', 'заявки где я автор', 'где я автор', 'заявки которые я создал', 'созданные мной'];

    /** Ключевые слова для интента «заявки за период» */
    private const PERIOD_KEYWORDS = ['заявки за', 'заявки за последние', 'за последнюю', 'за последний', 'за месяц', 'за неделю', 'за квартал', 'за год'];

    /** Ключевые слова для интента «по статусу» */
    private const STATUS_KEYWORDS = ['по статусу', 'открытые заявки', 'закрытые заявки', 'новые заявки', 'в работе', 'выполненные', 'заявки в работе'];

    /** Ключевые слова для интента «статистика» */
    private const STATS_KEYWORDS = ['статистика', 'статистика заявок', 'сколько заявок', 'отчёт по заявкам', 'сводка заявок'];

    /** Ключевые слова для справки */
    private const HELP_KEYWORDS = ['справка', 'помощь', 'как создать заявку', 'как создать обращение', 'инструкция', 'подсказка'];

    /**
     * Разбирает сообщение пользователя и возвращает интент с параметрами.
     *
     * @param string $message Текст запроса
     * @param int|null $currentUserId ID текущего пользователя
     * @return array { intent: string|null, params: array, interpretation: string, link: array|null, hints: string[] }
     */
    public static function parse(string $message, ?int $currentUserId): array
    {
        $text = mb_strtolower(trim($message));
        if ($text === '') {
            return self::unknown('Уточните, пожалуйста, что вы ищете.', self::defaultHints());
        }

        // Справка — без доступа к данным
        if (self::matchesAny($text, self::HELP_KEYWORDS)) {
            return [
                'intent' => 'help',
                'params' => [],
                'interpretation' => 'Справка по системе.',
                'link' => null,
                'hints' => [],
                'helpText' => self::getHelpText(),
            ];
        }

        // Мои заявки
        if (self::matchesAny($text, self::MY_TASKS_KEYWORDS) && $currentUserId) {
            $params = ['TasksSearch' => ['requester_id' => (string) $currentUserId]];
            $linkParams = ['TasksSearch' => ['requester_id' => $currentUserId]];
            return [
                'intent' => 'my_tasks',
                'params' => $params,
                'interpretation' => 'Поиск заявок, где вы автор.',
                'link' => [
                    'label' => 'Открыть в разделе Заявки',
                    'url' => ['/tasks/index'] + $linkParams,
                ],
                'hints' => [],
            ];
        }

        // Заявки за период
        $period = self::detectPeriod($text);
        if ($period !== null) {
            $params = ['TasksSearch' => [
                'date_from' => $period['date_from'],
                'date_to' => $period['date_to'],
            ]];
            $linkParams = ['TasksSearch' => $params['TasksSearch']];
            return [
                'intent' => 'tasks_period',
                'params' => $params,
                'interpretation' => $period['interpretation'],
                'link' => [
                    'label' => 'Открыть в разделе Заявки',
                    'url' => ['/tasks/index'] + $linkParams,
                ],
                'hints' => [],
            ];
        }

        // По статусу
        $statusIntent = self::detectStatus($text);
        if ($statusIntent !== null) {
            $params = ['TasksSearch' => ['status_id' => $statusIntent['status_id']]];
            $linkParams = ['TasksSearch' => $params['TasksSearch']];
            return [
                'intent' => 'tasks_status',
                'params' => $params,
                'interpretation' => $statusIntent['interpretation'],
                'link' => [
                    'label' => 'Открыть в разделе Заявки',
                    'url' => ['/tasks/index'] + $linkParams,
                ],
                'hints' => [],
            ];
        }

        // Статистика
        if (self::matchesAny($text, self::STATS_KEYWORDS)) {
            return [
                'intent' => 'statistics',
                'params' => [],
                'interpretation' => 'Статистика заявок по пользователям и исполнителям.',
                'link' => [
                    'label' => 'Открыть раздел Статистика заявок',
                    'url' => ['/tasks/statistics'],
                ],
                'hints' => [],
            ];
        }

        // Общий запрос «заявки» без уточнения
        if (preg_match('/^(покажи\s+)?(все\s+)?заявки?$/u', $text) || preg_match('/^заявки?\s*$/u', $text)) {
            return [
                'intent' => 'tasks_all',
                'params' => [],
                'interpretation' => 'Список заявок (с учётом ваших прав доступа).',
                'link' => [
                    'label' => 'Открыть в разделе Заявки',
                    'url' => ['/tasks/index'],
                ],
                'hints' => [],
            ];
        }

        return self::unknown('Не удалось однозначно понять запрос.', self::defaultHints());
    }

    private static function matchesAny(string $text, array $keywords): bool
    {
        foreach ($keywords as $kw) {
            if (mb_strpos($text, $kw) !== false) {
                return true;
            }
        }
        return false;
    }

    private static function defaultHints(): array
    {
        return [
            '«Мои заявки» — заявки, где вы автор',
            '«Заявки за месяц» — заявки за последние 30 дней',
            '«Открытые заявки» — заявки в статусе «В работе» или «Новая»',
            '«Статистика заявок» — сводка по пользователям и исполнителям',
            '«Справка» — подсказка по работе с системой',
        ];
    }

    private static function unknown(string $interpretation, array $hints): array
    {
        return [
            'intent' => null,
            'params' => [],
            'interpretation' => $interpretation,
            'link' => null,
            'hints' => $hints,
        ];
    }

    /**
     * Определяет период из текста (неделя, месяц, квартал, год).
     */
    private static function detectPeriod(string $text): ?array
    {
        if (!self::matchesAny($text, self::PERIOD_KEYWORDS)) {
            return null;
        }
        $now = time();
        $dateTo = date('Y-m-d', $now);
        $dateFrom = null;
        $label = '';

        if (preg_match('/недел[ию]/u', $text) || preg_match('/последнюю\s+недел/u', $text)) {
            $dateFrom = date('Y-m-d', strtotime('-7 days', $now));
            $label = 'Заявки за последнюю неделю.';
        } elseif (preg_match('/месяц/u', $text) || preg_match('/последний\s+месяц/u', $text)) {
            $dateFrom = date('Y-m-d', strtotime('-1 month', $now));
            $label = 'Заявки за последний месяц.';
        } elseif (preg_match('/квартал/u', $text)) {
            $dateFrom = date('Y-m-d', strtotime('-3 months', $now));
            $label = 'Заявки за последний квартал.';
        } elseif (preg_match('/год/u', $text)) {
            $dateFrom = date('Y-m-d', strtotime('-1 year', $now));
            $label = 'Заявки за последний год.';
        } else {
            $dateFrom = date('Y-m-d', strtotime('-1 month', $now));
            $label = 'Заявки за последний месяц.';
        }

        return [
            'date_from' => $dateFrom,
            'date_to' => $dateTo,
            'interpretation' => $label,
        ];
    }

    /**
     * Определяет статус по ключевым словам.
     */
    private static function detectStatus(string $text): ?array
    {
        $statusRows = DicTaskStatus::find()->select(['id', 'status_code', 'status_name'])->asArray()->all();
        $statusByCode = [];
        foreach ($statusRows as $r) {
            $statusByCode[$r['status_code']] = $r;
        }

        $map = [
            'open' => ['открытые', 'новые', 'новая', 'открытая'],
            'in_progress' => ['в работе'],
            'resolved' => ['закрытые', 'выполненные', 'закрыта', 'выполнена', 'решен'],
            'closed' => ['закрытые', 'выполненные'],
        ];

        foreach ($map as $code => $words) {
            foreach ($words as $w) {
                if (mb_strpos($text, $w) !== false) {
                    $row = $statusByCode[$code] ?? null;
                    if ($row === null && $code === 'resolved') {
                        $row = $statusByCode['closed'] ?? null;
                    }
                    if ($row !== null) {
                        return [
                            'status_id' => (int) $row['id'],
                            'interpretation' => 'Заявки со статусом «' . $row['status_name'] . '».',
                        ];
                    }
                }
            }
        }

        foreach ($statusRows as $row) {
            if (mb_strpos($text, mb_strtolower($row['status_name'])) !== false) {
                return [
                    'status_id' => (int) $row['id'],
                    'interpretation' => 'Заявки со статусом «' . $row['status_name'] . '».',
                ];
            }
        }

        return null;
    }

    private static function getHelpText(): string
    {
        return "В системе учёта технических средств вы можете:\n\n"
            . "• Создать заявку — раздел «Заявки» → кнопка создания заявки; укажите описание и при необходимости прикрепите файлы.\n"
            . "• Просматривать свои заявки и заявки, где вы назначены исполнителем (в разделе «Заявки»).\n"
            . "• Запросить у помощника: «Мои заявки», «Заявки за месяц», «Открытые заявки», «Статистика заявок». Результат можно открыть в соответствующем разделе по ссылке.";
    }
}
