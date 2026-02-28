<?php

namespace app\controllers;

use app\components\AuditLog;
use app\components\assistant\AssistantContextBuilder;
use app\components\assistant\AssistantIntentParser;
use app\components\assistant\LlmClient;
use app\components\rag\VectorRagSearch;
use app\models\dictionaries\DicTaskStatus;
use app\models\entities\Equipment;
use app\models\entities\Location;
use app\models\entities\Tasks;
use app\models\entities\Users;
use app\models\search\TasksSearch;
use Yii;
use yii\filters\AccessControl;
use yii\filters\VerbFilter;
use yii\helpers\Url;
use yii\web\Controller;
use yii\web\Response;

/**
 * Контроллер ИИ-помощника: парсинг интентов, выборка данных из БД, опциональный вызов LM Studio.
 * Авторизация и аудит в PHP.
 */
class AssistantController extends Controller
{
    public function behaviors()
    {
        return [
            'access' => [
                'class' => AccessControl::class,
                'rules' => [
                    [
                        'allow' => true,
                        'actions' => ['rag-debug'],
                        'matchCallback' => function () {
                            if (YII_ENV_DEV) {
                                return true;
                            }
                            $identity = Yii::$app->user->identity;
                            return $identity && $identity->isAdministrator();
                        },
                    ],
                    [
                        'allow' => true,
                        'roles' => ['@'],
                    ],
                ],
                'denyCallback' => function () {
                    throw new \yii\web\ForbiddenHttpException('Доступ запрещён.');
                },
            ],
            'verbs' => [
                'class' => VerbFilter::class,
                'actions' => [
                    'query' => ['POST'],
                    'rag-debug' => ['GET'],
                ],
            ],
        ];
    }

    /**
     * Обработка запроса: парсер интентов, при неопределённом интенте — опционально LLM, формирование ответа.
     */
    public function actionQuery()
    {
        Yii::$app->response->format = Response::FORMAT_JSON;

        $message = (string) (Yii::$app->request->post('message') ?? '');
        $message = trim($message);
        $userId = Yii::$app->user->isGuest ? null : (int) Yii::$app->user->id;
        $identity = Yii::$app->user->identity;
        $isAdmin = $identity && $identity->isAdministrator();
        $isOperator = $identity && $identity->isOperator();

        try {
            $result = AssistantIntentParser::parse($message, $userId);

            if ($result['intent'] === null && ($result['interpretation'] ?? '') !== '') {
                $userName = ($identity && isset($identity->full_name)) ? $identity->full_name : null;
                $ragContext = (Yii::$app->params['llm_use_rag'] ?? true)
                    ? AssistantContextBuilder::buildRagContext([])
                    : null;
                if (!empty(Yii::$app->params['llm_use_vector_rag'])) {
                    $vectorChunks = Yii::createObject(VectorRagSearch::class)->search($message, null);
                    $vectorBlock = $this->formatVectorRagContext($vectorChunks, 2800);
                    if ($vectorBlock !== '') {
                        $ragContext = ($ragContext !== null ? $ragContext . "\n\n" : '') . $vectorBlock;
                    }
                }
                $llmReply = LlmClient::completion($message, LlmClient::buildSystemContext($userName, $ragContext));
                if ($llmReply !== null) {
                    $result['interpretation'] = $llmReply;
                }
            }

            $response = [
                'success' => true,
                'interpretation' => $result['interpretation'] ?? '',
            ];
            if (!empty($result['hints'])) {
                $response['hints'] = $result['hints'];
            }

            if (isset($result['helpText'])) {
                $response['helpText'] = $result['helpText'];
                $response['data'] = [];
                $response['total'] = 0;
                $this->normalizeResponse($response);
                AuditLog::log('assistant.query', 'assistant', 0, 'success', ['query' => mb_substr($message, 0, 200)]);
                return $response;
            }

            if (isset($result['link'])) {
                $response['link'] = $result['link'];
            }

            $intent = $result['intent'] ?? null;
            $params = $result['params'] ?? [];

            if ($intent === 'statistics') {
                $this->buildStatisticsResponse($response);
                $this->normalizeResponse($response);
                AuditLog::log('assistant.query', 'assistant', 0, 'success', ['query' => mb_substr($message, 0, 200)]);
                return $response;
            }

            if (in_array($intent, ['my_tasks', 'tasks_period', 'tasks_status', 'tasks_all', 'tasks_executor'], true)) {
                $searchParams = $params['TasksSearch'] ?? $params;
                $this->buildTasksResponse($response, $searchParams);
                $this->normalizeResponse($response);
                AuditLog::log('assistant.query', 'assistant', 0, 'success', ['query' => mb_substr($message, 0, 200)]);
                return $response;
            }

            if ($intent === 'equipment_by_person') {
                $namePart = trim((string) ($params['responsible_name'] ?? ''));
                $this->buildEquipmentByPersonResponse($response, $namePart, $userId, $isAdmin, $isOperator, $result['hints'] ?? []);
                $this->normalizeResponse($response);
                AuditLog::log('assistant.query', 'assistant', 0, 'success', ['query' => mb_substr($message, 0, 200)]);
                return $response;
            }

            if ($intent === 'equipment_by_location') {
                $locationQuery = $params['location_query'] ?? null;
                $locationName = trim((string) ($params['location_name'] ?? ''));
                $this->buildEquipmentByLocationResponse($response, $locationQuery, $locationName);
                $this->normalizeResponse($response);
                AuditLog::log('assistant.query', 'assistant', 0, 'success', ['query' => mb_substr($message, 0, 200)]);
                return $response;
            }

            if ($intent === 'list_locations') {
                $this->buildListLocationsResponse($response);
                $this->normalizeResponse($response);
                AuditLog::log('assistant.query', 'assistant', 0, 'success', ['query' => mb_substr($message, 0, 200)]);
                return $response;
            }

            if ($intent === 'list_users') {
                $this->buildListUsersResponse($response, $isAdmin, $isOperator);
                $this->normalizeResponse($response);
                AuditLog::log('assistant.query', 'assistant', 0, 'success', ['query' => mb_substr($message, 0, 200)]);
                return $response;
            }

            $response['data'] = [];
            $response['total'] = 0;
            $this->normalizeResponse($response);
            AuditLog::log('assistant.query', 'assistant', 0, 'success', ['query' => mb_substr($message, 0, 200)]);
            return $response;
        } catch (\Throwable $e) {
            Yii::error('AssistantController::actionQuery: ' . $e->getMessage(), __METHOD__);
            AuditLog::log('assistant.query', 'assistant', 0, 'error', null, $e->getMessage());
            return [
                'success' => false,
                'interpretation' => 'Произошла ошибка при обработке запроса.',
                'data' => [],
                'total' => 0,
            ];
        }
    }

    /**
     * Отладка векторного RAG: возвращает найденные чанки для запроса (GET message или query).
     * Доступ: только в YII_ENV_DEV или для администратора.
     */
    public function actionRagDebug()
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $message = (string) (Yii::$app->request->get('message') ?? Yii::$app->request->get('query') ?? '');
        $message = trim($message);
        $context = [];
        if ($message !== '') {
            $context = Yii::createObject(VectorRagSearch::class)->search($message, null);
        }
        return [
            'query' => $message,
            'context_used' => $context,
        ];
    }

    /**
     * Форматирует результат векторного поиска RAG в текст для системного промта.
     *
     * @param array<int, array{content: string, metadata: array, relevance_score: float}> $chunks
     * @param int $maxLength Максимальная суммарная длина блока (символов)
     */
    private function formatVectorRagContext(array $chunks, int $maxLength = 2800): string
    {
        if (empty($chunks)) {
            return '';
        }
        $parts = [];
        $total = 0;
        foreach ($chunks as $chunk) {
            $content = (string) ($chunk['content'] ?? '');
            if ($content === '') {
                continue;
            }
            $table = (string) ($chunk['metadata']['table'] ?? '');
            $line = $table !== '' ? "[Таблица {$table}]: {$content}" : $content;
            if ($total + mb_strlen($line) + 2 > $maxLength) {
                $line = mb_substr($line, 0, $maxLength - $total - 4) . '…';
                $parts[] = $line;
                break;
            }
            $parts[] = $line;
            $total += mb_strlen($line) + 2;
        }
        if (empty($parts)) {
            return '';
        }
        return 'Релевантные фрагменты из БД:' . "\n" . implode("\n\n", $parts);
    }

    /**
     * Заполняет response данными статистики заявок.
     */
    private function buildStatisticsResponse(array &$response): void
    {
        $resolvedStatusId = (int) (DicTaskStatus::find()->where(['status_code' => 'resolved'])->select('id')->scalar()
            ?: DicTaskStatus::find()->where(['status_code' => 'closed'])->select('id')->scalar());

        $userStats = Tasks::find()
            ->select(['requester_id', 'COUNT(*) as count'])
            ->groupBy('requester_id')
            ->asArray()
            ->all();
        $totalTasks = (int) array_sum(array_column($userStats, 'count'));

        $executorStats = [];
        if ($resolvedStatusId > 0) {
            $executorStats = Tasks::find()
                ->select(['executor_id', 'COUNT(*) as count'])
                ->where(['status_id' => $resolvedStatusId])
                ->andWhere(['not', ['executor_id' => null]])
                ->groupBy('executor_id')
                ->asArray()
                ->all();
        }
        $totalResolved = (int) array_sum(array_column($executorStats, 'count'));

        $rows = [];
        $rows[] = ['type' => 'header', 'title' => 'По авторам заявок'];
        foreach ($userStats as $s) {
            $user = Users::findOne($s['requester_id']);
            $name = $user ? $user->full_name : 'Неизвестный пользователь';
            $count = (int) $s['count'];
            $pct = $totalTasks > 0 ? round(($count / $totalTasks) * 100, 1) : 0;
            $rows[] = ['type' => 'row', 'name' => $name, 'count' => $count, 'percentage' => $pct . '%'];
        }
        $rows[] = ['type' => 'header', 'title' => 'По исполнителям (завершённые заявки)'];
        foreach ($executorStats as $s) {
            $user = Users::findOne($s['executor_id']);
            $name = $user ? $user->full_name : 'Неизвестный исполнитель';
            $count = (int) $s['count'];
            $pct = $totalResolved > 0 ? round(($count / $totalResolved) * 100, 1) : 0;
            $rows[] = ['type' => 'row', 'name' => $name, 'count' => $count, 'percentage' => $pct . '%'];
        }

        $response['data'] = $rows;
        $response['total'] = count($rows);
        $response['summary'] = ['total_tasks' => $totalTasks, 'total_resolved' => $totalResolved];
    }

    /**
     * Заполняет response списком заявок по параметрам поиска.
     *
     * @param array $searchParams Массив для TasksSearch (ключ TasksSearch или плоский)
     */
    private function buildTasksResponse(array &$response, array $searchParams): void
    {
        $params = isset($searchParams['requester_id']) || isset($searchParams['date_from']) || isset($searchParams['status_id'])
            ? ['TasksSearch' => $searchParams]
            : $searchParams;
        if (!isset($params['TasksSearch'])) {
            $params = ['TasksSearch' => $searchParams];
        }

        $searchModel = new TasksSearch();
        $dataProvider = $searchModel->search($params);
        $dataProvider->pagination = false;
        $models = $dataProvider->getModels();

        $data = [];
        foreach ($models as $model) {
            $data[] = [
                'id' => $model->id,
                'description' => $model->description ?? '',
                'status_name' => $model->status ? $model->status->status_name : '',
                'user_name' => $model->requester ? $model->requester->full_name : '',
                'executor_name' => $model->executor ? $model->executor->full_name : '',
                'date' => $model->created_at ? Yii::$app->formatter->asDatetime($model->created_at, 'php:d.m.Y H:i') : '',
            ];
        }
        $response['data'] = $data;
        $response['total'] = count($data);
    }

    /**
     * Заполняет response списком техники по ответственному (поиск по ФИО).
     */
    private function buildEquipmentByPersonResponse(
        array &$response,
        string $namePart,
        ?int $currentUserId,
        bool $isAdmin,
        bool $isOperator,
        array $defaultHints
    ): void {
        $defaultHints = $defaultHints ?: AssistantIntentParser::getDefaultHintsList();

        if ($namePart === '') {
            $response['interpretation'] = 'Уточните ФИО ответственного.';
            $response['data'] = [];
            $response['total'] = 0;
            $response['hints'] = AssistantIntentParser::getEquipmentByPersonNotFoundHints();
            return;
        }

        $searchPatterns = self::getSearchPatternsForResponsibleName($namePart);
        if (empty($searchPatterns)) {
            $response['interpretation'] = 'Уточните ФИО ответственного.';
            $response['data'] = [];
            $response['total'] = 0;
            $response['hints'] = AssistantIntentParser::getEquipmentByPersonNotFoundHints();
            return;
        }

        $query = Users::find()
            ->select(['id', 'full_name'])
            ->orderBy('full_name')
            ->limit(20)
            ->asArray();
        if (count($searchPatterns) === 1) {
            $query->andWhere(['ilike', 'full_name', $searchPatterns[0]]);
        } else {
            $orConditions = [];
            foreach (array_slice($searchPatterns, 0, 8) as $p) {
                $orConditions[] = ['ilike', 'full_name', $p];
            }
            $query->andWhere(array_merge(['or'], $orConditions));
        }
        $users = $query->all();

        if (empty($users)) {
            $response['interpretation'] = 'Пользователь по запросу «' . $namePart . '» не найден. Уточните ФИО ответственного.';
            $response['data'] = [];
            $response['total'] = 0;
            $response['hints'] = AssistantIntentParser::getEquipmentByPersonNotFoundHints();
            return;
        }

        $responsibleUserId = (int) $users[0]['id'];
        $responsibleLabel = $users[0]['full_name'] ?? $namePart;

        if (!$isAdmin && !$isOperator && $currentUserId !== null && $responsibleUserId !== $currentUserId) {
            $response['data'] = [];
            $response['total'] = 0;
            $response['interpretation'] = 'Доступ к технике другого ответственного ограничен.';
            $response['hints'] = $defaultHints;
            return;
        }

        $equipment = Equipment::find()
            ->where(['responsible_user_id' => $responsibleUserId])
            ->andWhere(['is_archived' => false, 'is_deleted' => false])
            ->with(['responsibleUser', 'equipmentStatus', 'equipmentType'])
            ->orderBy(['name' => SORT_ASC, 'inventory_number' => SORT_ASC])
            ->all();

        $data = [];
        foreach ($equipment as $e) {
            $data[] = [
                'id' => $e->id,
                'name' => $e->name ?? '',
                'inventory_number' => $e->inventory_number ?? '',
                'equipment_type' => $e->equipmentType ? $e->equipmentType->name : '',
                'status_name' => $e->equipmentStatus ? $e->equipmentStatus->status_name : '',
                'responsible_name' => $e->responsibleUser ? $e->responsibleUser->full_name : '',
            ];
        }

        $response['data'] = $data;
        $response['total'] = count($data);
        $response['link'] = [
            'label' => 'Открыть в разделе Технические средства',
            'url' => Url::to(['/arm/index', 'ArmSearch' => ['responsible_user_id' => $responsibleUserId]], true),
        ];
        $response['dataType'] = 'equipment';
        if (count($users) > 1) {
            $response['interpretation'] = 'Техника ответственного «' . $responsibleLabel . '» (найдено несколько совпадений по ФИО — показан первый).';
        }
    }

    /**
     * Заполняет response списком техники по локации (кабинет/склад/серверная и т.д.)
     *
     * @param string|null $locationQuery 'all' для «техника по кабинетам», иначе null
     * @param string $locationName Название/часть локации: «кабинете 203», «серверной», «склад»
     */
    private function buildEquipmentByLocationResponse(array &$response, ?string $locationQuery, string $locationName): void
    {
        $defaultHints = AssistantIntentParser::getDefaultHintsList();

        if ($locationQuery === 'all') {
            $locations = Location::find()
                ->where(['is_archived' => false])
                ->orderBy(['location_type' => SORT_ASC, 'name' => SORT_ASC])
                ->all();
            $rows = [];
            $rows[] = ['type' => 'header', 'title' => 'Техника по локациям'];
            $totalUnits = 0;
            foreach ($locations as $loc) {
                $count = (int) Equipment::find()
                    ->where(['location_id' => $loc->id])
                    ->andWhere(['is_archived' => false, 'is_deleted' => false])
                    ->count();
                $totalUnits += $count;
                $rows[] = [
                    'type' => 'row',
                    'name' => $loc->name . ' (' . $loc->location_type . ')',
                    'count' => $count,
                    'percentage' => '',
                ];
            }
            $response['data'] = $rows;
            $response['total'] = count($rows);
            $response['summary'] = ['total_tasks' => $totalUnits, 'total_resolved' => 0, 'total_units' => $totalUnits, 'total_locations' => count($locations)];
            $response['interpretation'] = 'Техника по кабинетам и локациям. Всего единиц техники: ' . $totalUnits . ', локаций: ' . count($locations) . '.';
            $response['link'] = [
                'label' => 'Открыть в разделе Технические средства',
                'url' => Url::to(['/arm/index'], true),
            ];
            return;
        }

        if ($locationName === '') {
            $response['interpretation'] = 'Уточните кабинет или локацию (например: техника в кабинете 203, оборудование в серверной).';
            $response['data'] = [];
            $response['total'] = 0;
            $response['hints'] = $defaultHints;
            return;
        }

        $normalized = self::normalizeLocationSearchString($locationName);
        $query = Location::find()
            ->where(['is_archived' => false])
            ->orderBy('name')
            ->limit(20);
        $typeValues = ['кабинет', 'склад', 'серверная', 'лаборатория', 'другое'];
        $typeAndRest = self::parseLocationTypeAndRest($normalized, $typeValues);
        if ($typeAndRest !== null) {
            [$type, $rest] = $typeAndRest;
            $query->andWhere([
                'and',
                ['location_type' => $type],
                [
                    'or',
                    ['ilike', 'name', '%' . $rest . '%'],
                    ['ilike', 'location_code', '%' . $rest . '%'],
                ],
            ]);
        } elseif (in_array(mb_strtolower($normalized), $typeValues, true)) {
            $query->andWhere(['location_type' => mb_strtolower($normalized)]);
        } else {
            $query->andWhere([
                'or',
                ['ilike', 'name', $normalized],
                ['ilike', 'location_code', $normalized],
            ]);
        }
        $locations = $query->all();

        if (empty($locations)) {
            $response['interpretation'] = 'Локация по запросу «' . $locationName . '» не найдена. Уточните кабинет или название (например: кабинет 203, серверная).';
            $response['data'] = [];
            $response['total'] = 0;
            $response['hints'] = $defaultHints;
            return;
        }

        $location = $locations[0];
        $locationLabel = $location->name . ' (' . $location->location_type . ')';
        if (count($locations) > 1) {
            $response['interpretation'] = 'Техника в локации «' . $locationLabel . '» (найдено несколько подходящих — показана первая).';
        }

        $equipment = Equipment::find()
            ->where(['location_id' => $location->id])
            ->andWhere(['is_archived' => false, 'is_deleted' => false])
            ->with(['responsibleUser', 'equipmentStatus', 'equipmentType'])
            ->orderBy(['name' => SORT_ASC, 'inventory_number' => SORT_ASC])
            ->all();

        $data = [];
        foreach ($equipment as $e) {
            $data[] = [
                'id' => $e->id,
                'name' => $e->name ?? '',
                'inventory_number' => $e->inventory_number ?? '',
                'equipment_type' => $e->equipmentType ? $e->equipmentType->name : '',
                'status_name' => $e->equipmentStatus ? $e->equipmentStatus->status_name : '',
                'responsible_name' => $e->responsibleUser ? $e->responsibleUser->full_name : '',
            ];
        }

        $response['data'] = $data;
        $response['total'] = count($data);
        $response['link'] = [
            'label' => 'Открыть в разделе Технические средства',
            'url' => Url::to(['/arm/index', 'ArmSearch' => ['location_id' => $location->id]], true),
        ];
        $response['dataType'] = 'equipment';
    }

    /**
     * Заполняет response списком локаций (кабинеты, склады и т.д.) с количеством техники.
     */
    private function buildListLocationsResponse(array &$response): void
    {
        $locations = Location::find()
            ->where(['is_archived' => false])
            ->orderBy(['location_type' => SORT_ASC, 'name' => SORT_ASC])
            ->all();
        $rows = [];
        $rows[] = ['type' => 'header', 'title' => 'Локации'];
        $totalUnits = 0;
        foreach ($locations as $loc) {
            $count = (int) Equipment::find()
                ->where(['location_id' => $loc->id])
                ->andWhere(['is_archived' => false, 'is_deleted' => false])
                ->count();
            $totalUnits += $count;
            $rows[] = [
                'type' => 'row',
                'name' => $loc->name . ' (' . $loc->location_type . ')',
                'count' => $count,
                'percentage' => '',
            ];
        }
        $response['data'] = $rows;
        $response['total'] = count($rows);
        $response['summary'] = ['total_units' => $totalUnits, 'total_locations' => count($locations)];
        $response['interpretation'] = 'Список локаций. Всего локаций: ' . count($locations) . ', единиц техники: ' . $totalUnits . '.';
        $response['link'] = [
            'label' => 'Открыть в разделе Технические средства',
            'url' => Url::to(['/arm/index'], true),
        ];
    }

    /**
     * Заполняет response списком пользователей (ФИО и количество техники).
     */
    private function buildListUsersResponse(array &$response, bool $isAdmin, bool $isOperator): void
    {
        $query = Users::find()
            ->alias('u')
            ->select(['u.id', 'u.full_name'])
            ->orderBy(['u.full_name' => SORT_ASC])
            ->andWhere(['u.is_active' => true]);
        $schema = \Yii::$app->db->getTableSchema(Users::tableName());
        if ($schema && isset($schema->columns['is_deleted'])) {
            $query->andWhere(['u.is_deleted' => false]);
        }
        $users = $query->asArray()->all();

        $rows = [];
        $rows[] = ['type' => 'header', 'title' => 'Пользователи'];
        $totalEquipment = 0;
        foreach ($users as $u) {
            $count = (int) Equipment::find()
                ->where(['responsible_user_id' => (int) $u['id']])
                ->andWhere(['is_archived' => false, 'is_deleted' => false])
                ->count();
            $totalEquipment += $count;
            $rows[] = [
                'type' => 'row',
                'name' => $u['full_name'] ?? '',
                'count' => $count,
                'percentage' => '',
            ];
        }
        $response['data'] = $rows;
        $response['total'] = count($rows);
        $response['summary'] = ['total_users' => count($users), 'total_equipment' => $totalEquipment];
        $response['interpretation'] = 'Список пользователей системы. Всего: ' . count($users) . ' пользователей.';
        $response['link'] = [
            'label' => 'Открыть раздел Пользователи',
            'url' => Url::to(['/users/index'], true),
        ];
    }

    /**
     * Формирует варианты ФИО для поиска по БД с учётом падежей: подставляет формы именительного падежа.
     * Например: «Яшкиной» → [«яшкиной», «яшкина»], «Печерского» → [«печерского», «печерский»].
     */
    private static function getSearchPatternsForResponsibleName(string $namePart): array
    {
        $namePart = trim($namePart);
        if ($namePart === '') {
            return [];
        }
        $patterns = [$namePart];
        $s = mb_strtolower($namePart);

        // Женские фамилии/имена: -ой, -ей → именительный -а, -я (Яшкиной → Яшкина, Ковалёвой → Ковалёва)
        if (preg_match('/^(.*)(ой|ей)$/u', $s, $m) && mb_strlen($m[1]) >= 2) {
            $stem = $m[1];
            $patterns[] = $stem . 'а';
            $patterns[] = $stem . 'я';
        }
        // -ую (вин. падеж ж.р.): Петрову → Петрова
        if (preg_match('/^(.*)ую$/u', $s, $m) && mb_strlen($m[1]) >= 2) {
            $patterns[] = $m[1] . 'а';
        }
        // Мужские -ого, -его (род. падеж): Печерского → Печерский, Сидорова (род.) → Сидоров
        if (preg_match('/^(.*)(ого|его)$/u', $s, $m) && mb_strlen($m[1]) >= 2) {
            $stem = $m[1];
            $patterns[] = $stem . 'ий';
            $patterns[] = $stem . 'ый';
            $patterns[] = $stem . 'ов';
            $patterns[] = $stem . 'ев';
        }
        // -ову, -еву (дат. падеж): Иванову → Иванов/Иванова
        if (preg_match('/^(.*)(ову|еву)$/u', $s, $m) && mb_strlen($m[1]) >= 2) {
            $patterns[] = $m[1] . 'ов';
            $patterns[] = $m[1] . 'ев';
            $patterns[] = $m[1] . 'ова';
            $patterns[] = $m[1] . 'ева';
        }

        return array_values(array_unique($patterns));
    }

    /**
     * Нормализует строку поиска локации: падежи «кабинете» → «кабинет», тип по ключевым словам.
     */
    private static function normalizeLocationSearchString(string $s): string
    {
        $s = trim($s);
        $map = [
            'кбинете' => 'кабинет',
            'кабинете' => 'кабинет',
            'кабинет' => 'кабинет',
            'складе' => 'склад',
            'склад' => 'склад',
            'серверной' => 'серверная',
            'серверная' => 'серверная',
            'лаборатории' => 'лаборатория',
            'лаборатория' => 'лаборатория',
            'помещении' => 'кабинет',
            'помещение' => 'кабинет',
        ];
        foreach ($map as $from => $to) {
            if (mb_strtolower($s) === $from || mb_strpos(mb_strtolower($s), $from) === 0) {
                if (preg_match('/^' . preg_quote($from, '/') . '\s*(.*)$/u', $s, $m)) {
                    $rest = trim($m[1]);
                    return $rest !== '' ? ($to . ' ' . $rest) : $to;
                }
                return $to;
            }
        }
        return $s;
    }

    /**
     * Если строка имеет вид «тип номер» (например «кабинет 306»), возвращает [тип, номер/остаток]; иначе null.
     */
    private static function parseLocationTypeAndRest(string $normalized, array $typeValues): ?array
    {
        $n = mb_strtolower(trim($normalized));
        foreach ($typeValues as $type) {
            if (mb_strpos($n, $type) === 0) {
                $rest = trim(mb_substr($n, mb_strlen($type)));
                if ($rest !== '') {
                    return [$type, $rest];
                }
                break;
            }
        }
        return null;
    }

    /**
     * Преобразует link.url (массив маршрута) в абсолютный URL; добавляет view_url в элементах data (заявки).
     */
    private function normalizeResponse(array &$data): void
    {
        if (isset($data['link']) && is_array($data['link'])) {
            if (isset($data['link']['path'], $data['link']['params'])) {
                $route = '/' . ltrim($data['link']['path'], '/');
                $data['link']['url'] = Url::to(array_merge([$route], $data['link']['params']), true);
                unset($data['link']['path'], $data['link']['params']);
            } elseif (isset($data['link']['url']) && is_array($data['link']['url'])) {
                $data['link']['url'] = Url::to($data['link']['url'], true);
            }
        }
        if (isset($data['data']) && is_array($data['data'])) {
            foreach ($data['data'] as &$row) {
                if (is_array($row) && isset($row['id']) && !isset($row['view_url'])) {
                    $row['view_url'] = Url::to(['/tasks/view', 'id' => $row['id']], true);
                }
            }
            unset($row);
        }
    }
}
