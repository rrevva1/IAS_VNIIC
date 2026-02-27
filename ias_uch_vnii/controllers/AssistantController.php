<?php

namespace app\controllers;

use app\components\AuditLog;
use Yii;
use yii\filters\AccessControl;
use yii\filters\VerbFilter;
use yii\helpers\Url;
use yii\web\Controller;
use yii\web\Response;

/**
 * Контроллер ИИ-помощника: проксирует запросы в Python-микросервис assistant_api.
 * Авторизация и аудит остаются в PHP.
 */
class AssistantController extends Controller
{
    /** HTTP-код последнего ответа от Python API (для диагностики). */
    private $lastAssistantHttpCode = 0;

    public function behaviors()
    {
        return [
            'access' => [
                'class' => AccessControl::class,
                'rules' => [
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
                ],
            ],
        ];
    }

    /**
     * Обработка запроса: проксирование в Python-сервис + приведение ссылок и view_url к абсолютным URL.
     */
    public function actionQuery()
    {
        Yii::$app->response->format = Response::FORMAT_JSON;

        $message = (string) (Yii::$app->request->post('message') ?? '');
        $userId = Yii::$app->user->isGuest ? null : (int) Yii::$app->user->id;
        $identity = Yii::$app->user->identity;
        $isAdmin = $identity && $identity->isAdministrator();
        $isOperator = $identity && $identity->isOperator();

        $apiUrl = rtrim((string) (Yii::$app->params['assistantApiUrl'] ?? ''), '/');
        if ($apiUrl === '') {
            AuditLog::log('assistant.query', 'assistant', 0, 'error', null, 'assistantApiUrl not configured');
            return [
                'success' => false,
                'interpretation' => 'Сервис помощника не настроен.',
                'data' => [],
                'total' => 0,
            ];
        }

        try {
            $payload = json_encode([
                'message' => $message,
                'user_id' => $userId ?: 0,
                'is_admin' => $isAdmin,
                'is_operator' => $isOperator,
            ]);
            $requestUrl = $apiUrl . '/query';
            $response = $this->httpPost($requestUrl, $payload);
            if ($response === false) {
                throw new \RuntimeException('Не удалось связаться с сервисом помощника. Проверьте, что запущен Assistant API (порт 8000).');
            }
            $httpCode = $this->getLastHttpCode();
            if ($httpCode !== 200) {
                Yii::warning("Assistant API вернул HTTP {$httpCode} для {$requestUrl}", __METHOD__);
                throw new \RuntimeException('Сервис помощника вернул ошибку (HTTP ' . $httpCode . '). Убедитесь, что Assistant API запущен: http://127.0.0.1:8000/health');
            }
            $data = json_decode($response, true);
            if (!is_array($data)) {
                throw new \RuntimeException('Некорректный ответ сервиса.');
            }

            AuditLog::log(
                'assistant.query',
                'assistant',
                0,
                'success',
                ['query' => mb_substr($message, 0, 200)]
            );

            $this->normalizeResponse($data);
            return $data;
        } catch (\Throwable $e) {
            Yii::error('AssistantController::actionQuery: ' . $e->getMessage(), __METHOD__);
            AuditLog::log('assistant.query', 'assistant', 0, 'error', null, $e->getMessage());
            return [
                'success' => false,
                'interpretation' => 'Произошла ошибка при обработке запроса. Убедитесь, что запущен Python-сервис помощника (assistant_api).',
                'data' => [],
                'total' => 0,
            ];
        }
    }

    /**
     * Преобразует link.path + link.params в link.url; добавляет view_url в элементах data (заявки).
     */
    private function normalizeResponse(array &$data): void
    {
        if (isset($data['link']) && is_array($data['link'])) {
            $path = $data['link']['path'] ?? '';
            $params = $data['link']['params'] ?? [];
            if ($path !== '') {
                $route = '/' . ltrim($path, '/');
                $data['link']['url'] = Url::to(array_merge([$route], $params), true);
            }
            unset($data['link']['path'], $data['link']['params']);
        }
        if (isset($data['data']) && is_array($data['data'])) {
            foreach ($data['data'] as &$row) {
                if (isset($row['id']) && !isset($row['view_url'])) {
                    $row['view_url'] = Url::to(['/tasks/view', 'id' => $row['id']], true);
                }
            }
            unset($row);
        }
    }

    /** @return string|false */
    private function httpPost(string $url, string $body)
    {
        $this->lastAssistantHttpCode = 0;
        $opts = [
            'http' => [
                'method' => 'POST',
                'header' => "Content-Type: application/json\r\nAccept: application/json\r\n",
                'content' => $body,
                'timeout' => 15,
            ],
        ];
        $ctx = stream_context_create($opts);
        $result = @file_get_contents($url, false, $ctx);
        if (isset($http_response_header) && is_array($http_response_header)) {
            $first = $http_response_header[0] ?? '';
            if (preg_match('/HTTP\/\d\.\d\s+(\d+)/', $first, $m)) {
                $this->lastAssistantHttpCode = (int) $m[1];
            }
        }
        return $result;
    }

    private function getLastHttpCode(): int
    {
        return $this->lastAssistantHttpCode;
    }
}
