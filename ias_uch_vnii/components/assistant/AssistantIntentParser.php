<?php

namespace app\components\assistant;

use app\models\dictionaries\DicTaskStatus;

/**
 * Парсер интентов для ИИ-помощника: по тексту запроса определяет тип (мои заявки, за период, по статусу, статистика, справка)
 * и формирует параметры для TasksSearch и подпись для ответа.
 */
class AssistantIntentParser
{
    /** Ключевые слова для интента «мои заявки» */
    private const MY_TASKS_KEYWORDS = [
        'мои заявки', 'мои обращения', 'заявки где я автор', 'где я автор',
        'заявки которые я создал', 'созданные мной', 'мои задачи',
    ];

    /** Ключевые слова для интента «заявки за период» */
    private const PERIOD_KEYWORDS = [
        'заявки за', 'заявки за последние', 'за последнюю', 'за последний',
        'за месяц', 'за неделю', 'за квартал', 'за год', 'заявки за последнюю неделю',
        'заявки за последний месяц', 'заявки за последний год',
    ];

    /** Ключевые слова для интента «по статусу» */
    private const STATUS_KEYWORDS = [
        'по статусу', 'открытые заявки', 'закрытые заявки', 'новые заявки',
        'в работе', 'выполненные', 'заявки в работе', 'открытые', 'закрытые',
        'новые заявки', 'заявки новые', 'заявки открытые', 'заявки закрытые',
    ];

    /** Ключевые слова для интента «статистика» */
    private const STATS_KEYWORDS = [
        'статистика', 'статистика заявок', 'сколько заявок', 'отчёт по заявкам',
        'сводка заявок', 'сводка', 'отчёт заявок',
    ];

    /** Ключевые слова для справки */
    private const HELP_KEYWORDS = [
        'справка', 'помощь', 'как создать заявку', 'как создать обращение',
        'инструкция', 'подсказка', 'что умеешь', 'что можешь',
    ];

    /** Ключевые слова для списка локаций */
    private const LIST_LOCATIONS_KEYWORDS = [
        'список кабинетов', 'все локации', 'какие кабинеты', 'локации',
        'все кабинеты', 'какие локации есть', 'список локаций', 'кабинеты',
        'где что стоит', 'перечень кабинетов',
    ];

    /** Ключевые слова для списка пользователей */
    private const LIST_USERS_KEYWORDS = [
        'кто в системе', 'список пользователей', 'все ответственные',
        'пользователи', 'список сотрудников', 'все пользователи',
        'кто есть в системе', 'перечень пользователей',
    ];

    /**
     * Разбирает сообщение пользователя и возвращает интент с параметрами.
     *
     * @param string $message Текст запроса
     * @param int|null $currentUserId ID текущего пользователя
     * @return array { intent: string|null, params: array, interpretation: string, link: array|null, hints: string[] }
     */
    public static function parse(string $message, ?int $currentUserId): array
    {
        $text = preg_replace('/\s+/u', ' ', trim($message));
        $text = mb_strtolower($text);
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

        // Мои заявки (где я автор)
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

        // Заявки, где я исполнитель
        if (self::matchesAny($text, ['заявки где я исполнитель', 'что на мне висит', 'заявки мне на исполнение', 'где я исполнитель']) && $currentUserId) {
            $params = ['TasksSearch' => ['executor_id' => (string) $currentUserId]];
            $linkParams = ['TasksSearch' => ['executor_id' => $currentUserId]];
            return [
                'intent' => 'tasks_executor',
                'params' => $params,
                'interpretation' => 'Заявки, где вы назначены исполнителем.',
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
        if (preg_match('/^(покажи\s+)?(все\s+)?заявки?$/u', $text) || preg_match('/^заявки?\s*$/u', $text) || preg_match('/^покажи\s+заявки/u', $text)) {
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

        // Список локаций / кабинетов
        if (self::matchesAny($text, self::LIST_LOCATIONS_KEYWORDS)) {
            return [
                'intent' => 'list_locations',
                'params' => [],
                'interpretation' => 'Список локаций (кабинеты, склады и т.д.).',
                'link' => [
                    'label' => 'Открыть в разделе Технические средства',
                    'url' => ['/arm/index'],
                ],
                'hints' => [],
            ];
        }

        // Список пользователей
        if (self::matchesAny($text, self::LIST_USERS_KEYWORDS)) {
            return [
                'intent' => 'list_users',
                'params' => [],
                'interpretation' => 'Список пользователей системы.',
                'link' => [
                    'label' => 'Открыть раздел Пользователи',
                    'url' => ['/users/index'],
                ],
                'hints' => [],
            ];
        }

        // Топ техники по объёму ОЗУ (свободные формулировки)
        $ramTopKeywords = [
            'самый большой объем озу', 'самый большой объём озу', 'компьютеры с самым большим объемом озу',
            'компьютеры с самым большим объёмом оперативной памяти', 'с самым большим объемом оперативной памяти',
            'топ по озу', 'по объему озу', 'по объёму оперативной памяти', 'где больше всего памяти',
            'с максимальной озу', 'с наибольшим объемом памяти', 'больше всего озу', 'с большим объемом озу',
        ];
        if (self::matchesAny($text, $ramTopKeywords)) {
            return [
                'intent' => 'equipment_top_by_ram',
                'params' => ['order' => 'desc', 'limit' => 15],
                'interpretation' => 'Техника с наибольшим объёмом ОЗУ (по убыванию).',
                'link' => null,
                'hints' => [],
            ];
        }

        // Техника по локации/кабинету: «техника в кабинете 203», «оборудование в серверной», «покажи технику по кабинетам»
        $locationIntent = self::detectEquipmentByLocation($text);
        if ($locationIntent !== null) {
            return $locationIntent;
        }

        // Техника по ответственному лицу: «покажи технику Печерского», «техника Иванова», «оборудование [ФИО]», «что закреплено за [ФИО]», «инвентарь [ФИО]»
        if (preg_match('/^(?:покажи\s+)?(?:техник[уа]|оборудование)\s+(.+)$/u', $text, $m)) {
            $namePart = trim($m[1]);
            if (mb_strlen($namePart) >= 2) {
                return [
                    'intent' => 'equipment_by_person',
                    'params' => ['responsible_name' => $namePart],
                    'interpretation' => 'Техника, закреплённая за ответственным: ' . $namePart . '.',
                    'link' => null,
                    'hints' => [],
                ];
            }
        }
        if (preg_match('/^(?:что\s+закреплено\s+за|техника\s+сотрудника|инвентарь)\s+(.+)$/u', $text, $m)) {
            $namePart = trim($m[1]);
            if (mb_strlen($namePart) >= 2) {
                return [
                    'intent' => 'equipment_by_person',
                    'params' => ['responsible_name' => $namePart],
                    'interpretation' => 'Техника, закреплённая за ответственным: ' . $namePart . '.',
                    'link' => null,
                    'hints' => [],
                ];
            }
        }

        // Одно или два слова (фамилия/имя) — трактуем как запрос техники по ответственному (например: «Протопопов», «Иванов Иван»)
        $words = preg_split('/\s+/u', $text, -1, PREG_SPLIT_NO_EMPTY);
        if (count($words) >= 1 && count($words) <= 2 && mb_strlen($text) >= 3) {
            $allLongEnough = true;
            foreach ($words as $w) {
                if (mb_strlen($w) < 2) {
                    $allLongEnough = false;
                    break;
                }
            }
            $excludeWords = [
                'кабинет', 'склад', 'серверная', 'лаборатория', 'заявки', 'заявка', 'справка', 'помощь',
                'статистика', 'пользователи', 'локации', 'кабинеты', 'оборудование', 'техника',
                'привет', 'пока', 'здравствуй', 'здравствуйте', 'ок', 'да', 'нет', 'спасибо', 'хорошо', 'отлично', 'алло', 'ага', 'угу',
                'помещение',
            ];
            $wordNormalized = count($words) === 1 ? self::trimPunctuation($words[0]) : null;
            $isExcluded = (count($words) === 1 && $wordNormalized !== null && in_array($wordNormalized, $excludeWords, true))
                || (count($words) === 1 && preg_match('/^\d+$/u', $words[0]))
                || (count($words) === 2 && in_array($words[0], ['заявки', 'заявка'], true));
            if ($allLongEnough && !$isExcluded) {
                $namePart = trim($text);
                return [
                    'intent' => 'equipment_by_person',
                    'params' => ['responsible_name' => $namePart],
                    'interpretation' => 'Техника, закреплённая за ответственным: ' . $namePart . '.',
                    'link' => null,
                    'hints' => [],
                ];
            }
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
        return self::getDefaultHintsList();
    }

    /** Публичный список подсказок по умолчанию (для контроллера при ответах без данных). */
    public static function getDefaultHintsList(): array
    {
        return [
            'Заявки: «Мои заявки», «Заявки за месяц», «Открытые заявки», «Заявки где я исполнитель», «Статистика заявок»',
            'Техника по ответственному: «Техника [ФИО]», «Покажи технику Печерского», «Что закреплено за Ивановым»',
            'Техника по локации: «Техника в кабинете 203», «Оборудование в серверной», «Техника по кабинетам»',
            'Справочно: «Список кабинетов», «Список пользователей», «Справка»',
        ];
    }

    /**
     * Подсказки при ненайденном пользователе (техника по ответственному): только уточнение ФИО и список пользователей.
     */
    public static function getEquipmentByPersonNotFoundHints(): array
    {
        return [
            'Уточните фамилию или имя ответственного (например: «Техника Иванова», «Техника Печерского»).',
            'Посмотреть всех ответственных: «Список пользователей».',
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
     * Определяет интент «техника по локации/кабинету».
     * Распознаёт: «техника в кабинете 203», «оборудование в серверной», «покажи технику по кабинетам», «что в кабинете 203».
     *
     * @return array|null Массив интента или null
     */
    private static function detectEquipmentByLocation(string $text): ?array
    {
        $text = trim($text);
        if ($text === '') {
            return null;
        }

        // Одно слово — только цифры (номер кабинета): «306», «307»
        if (preg_match('/^\d+$/u', $text)) {
            return [
                'intent' => 'equipment_by_location',
                'params' => ['location_name' => 'кабинет ' . $text],
                'interpretation' => 'Техника в локации: кабинет ' . $text . '.',
                'link' => null,
                'hints' => [],
            ];
        }

        // «помещение 307», «помещение 306» — синоним кабинета
        if (preg_match('/^помещение\s+(.+)$/u', $text, $m)) {
            $locationPart = trim($m[1]);
            if (mb_strlen($locationPart) >= 1) {
                return [
                    'intent' => 'equipment_by_location',
                    'params' => ['location_name' => 'кабинет ' . $locationPart],
                    'interpretation' => 'Техника в локации: кабинет ' . $locationPart . '.',
                    'link' => null,
                    'hints' => [],
                ];
            }
        }

        // Короткая форма: «кабинет 306», «кабинет 203», «серверная», «склад» — без «техника в»
        if (preg_match('/^кабинет\s+(.+)$/u', $text, $m)) {
            $locationPart = trim($m[1]);
            if (mb_strlen($locationPart) >= 1) {
                return [
                    'intent' => 'equipment_by_location',
                    'params' => ['location_name' => 'кабинет ' . $locationPart],
                    'interpretation' => 'Техника в локации: кабинет ' . $locationPart . '.',
                    'link' => null,
                    'hints' => [],
                ];
            }
        }
        $shortLocations = ['серверная', 'склад', 'лаборатория'];
        foreach ($shortLocations as $loc) {
            if (mb_strtolower($text) === $loc) {
                return [
                    'intent' => 'equipment_by_location',
                    'params' => ['location_name' => $loc],
                    'interpretation' => 'Техника в локации: ' . $loc . '.',
                    'link' => null,
                    'hints' => [],
                ];
            }
        }

        // «покажи технику по кабинетам» / «техника по локациям» / «оборудование по кабинетам»
        if (preg_match('/^(?:покажи\s+)?(?:техник[уа]|оборудование)\s+по\s+(?:кабинетам|локациям)\s*$/u', $text)
            || preg_match('/^техник[ау]\s+по\s+кабинетам/u', $text)) {
            return [
                'intent' => 'equipment_by_location',
                'params' => ['location_query' => 'all'],
                'interpretation' => 'Техника по кабинетам и локациям.',
                'link' => null,
                'hints' => [],
            ];
        }

        // «техника в кабинете 203», «оборудование в серверной», «что в кабинете 203», «какая техника в кабинете X», «оборудование в комнате X»
        if (preg_match('/(?:техник[уа]|оборудование|что|какая\s+техник[ау])\s+в\s+(.+)$/u', $text, $m)) {
            $locationPart = trim($m[1]);
            if (mb_strlen($locationPart) >= 2) {
                return [
                    'intent' => 'equipment_by_location',
                    'params' => ['location_name' => $locationPart],
                    'interpretation' => 'Техника в локации: ' . $locationPart . '.',
                    'link' => null,
                    'hints' => [],
                ];
            }
        }
        if (preg_match('/оборудование\s+в\s+комнате\s+(.+)$/u', $text, $m)) {
            $locationPart = trim($m[1]);
            if (mb_strlen($locationPart) >= 1) {
                return [
                    'intent' => 'equipment_by_location',
                    'params' => ['location_name' => 'кабинет ' . $locationPart],
                    'interpretation' => 'Техника в локации: комната ' . $locationPart . '.',
                    'link' => null,
                    'hints' => [],
                ];
            }
        }

        return null;
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
            . "• Заявки: «Мои заявки», «Заявки за месяц», «Открытые заявки», «Заявки где я исполнитель», «Статистика заявок». Результат можно открыть в разделе «Заявки» по ссылке.\n"
            . "• Техника по ответственному: «Покажи технику [ФИО]», «Техника Печерского», «Что закреплено за Ивановым» — список техники, закреплённой за сотрудником.\n"
            . "• Техника по локации: «Техника в кабинете 203», «Оборудование в серверной», «Покажи технику по кабинетам» — техника в указанной локации или сводка по кабинетам.\n"
            . "• Справочно: «Список кабинетов», «Список пользователей» — перечень локаций и пользователей системы.\n"
            . "• Создать заявку: раздел «Заявки» → кнопка создания заявки; укажите описание и при необходимости прикрепите файлы.";
    }

    /**
     * Убирает знаки препинания в начале и конце строки (чтобы «привет!» и «привет» считались одинаково при проверке исключений).
     */
    private static function trimPunctuation(string $word): string
    {
        return trim($word, " \t\n\r\0\x0B.!?,;:\"'()");
    }
}
