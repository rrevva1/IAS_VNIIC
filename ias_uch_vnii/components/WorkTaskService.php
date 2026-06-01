<?php

namespace app\components;

use app\models\dictionaries\DicTaskStatus;
use app\models\dictionaries\DicWorkTaskStatus;
use app\models\entities\TaskHistory;
use app\models\entities\Tasks;
use app\models\entities\Users;
use app\models\entities\WorkTask;
use app\models\entities\WorkTaskComment;
use app\models\entities\WorkTaskExecutor;
use app\models\entities\WorkTaskHistory;
use app\models\search\WorkTaskSearch;
use Yii;
use yii\web\ForbiddenHttpException;

/**
 * Бизнес-логика модуля «Задачи».
 */
class WorkTaskService
{
    /**
     * Создать задачу по заявке Help Desk (вызывается при создании заявки).
     */
    /**
     * Создаёт внутреннюю задачу по заявке, если её ещё нет.
     */
    public function ensureForRequest(Tasks $request): ?WorkTask
    {
        $existing = WorkTask::find()
            ->where(['request_task_id' => (int) $request->id, 'is_deleted' => false])
            ->one();
        if ($existing !== null) {
            $this->alignTaskCreatorWithRequest($existing, $request);

            return $existing;
        }

        return $this->createFromRequest($request);
    }

    public function createFromRequest(Tasks $request): ?WorkTask
    {
        if ((int) $request->id <= 0) {
            return null;
        }

        if (WorkTask::find()->where(['request_task_id' => $request->id, 'is_deleted' => false])->exists()) {
            return null;
        }

        $queueId = DicWorkTaskStatus::resolveIdByCode(DicWorkTaskStatus::CODE_QUEUE);
        if ($queueId === null) {
            Yii::error('Справочник статусов внутренних задач не содержит статус «Очередь».', 'work_tasks');

            return null;
        }

        $title = trim((string) $request->title);
        if ($title === '') {
            $title = 'Заявка #' . $request->id;
        }

        $task = new WorkTask();
        $task->title = $title;
        $task->description = (string) $request->description;
        $task->status_id = $queueId;
        $task->request_task_id = (int) $request->id;
        $task->creator_id = (int) $request->requester_id > 0
            ? (int) $request->requester_id
            : (int) (Yii::$app->user->id ?? 1);
        $task->executor_id = $request->executor_id ? (int) $request->executor_id : null;
        $task->priority = in_array($request->priority, ['low', 'medium', 'high', 'critical'], true)
            ? $request->priority
            : 'medium';
        $task->status_changed_at = date('Y-m-d H:i:s');

        if (!$task->save()) {
            Yii::error(
                'Не удалось сохранить внутреннюю задачу по заявке #' . $request->id . ': '
                . json_encode($task->getErrors(), JSON_UNESCAPED_UNICODE),
                'work_tasks'
            );

            return null;
        }

        if ($task->executor_id) {
            WorkTaskExecutor::syncForTask((int) $task->id, [(int) $task->executor_id]);
            $task->refresh();
        }

        WorkTaskHistory::log($task->id, 'created_from_request', null, $task->status_id, 'Создана по заявке #' . $request->id);

        if ($task->hasExecutor()) {
            $assignedId = DicWorkTaskStatus::resolveIdByCode(DicWorkTaskStatus::CODE_ASSIGNED);
            if ($assignedId !== null) {
                $this->applyStatus($task, $assignedId, 'Назначен исполнитель из заявки');
            }
        }

        return $task;
    }

    /**
     * В поле creator_id хранится автор связанной заявки (для отображения в карточке задачи).
     */
    private function alignTaskCreatorWithRequest(WorkTask $task, Tasks $request): void
    {
        if ((int) $request->requester_id <= 0 || (int) $task->creator_id === (int) $request->requester_id) {
            return;
        }

        $task->creator_id = (int) $request->requester_id;
        $task->save(false, ['creator_id']);
    }

    /**
     * Ручное создание задачи сотрудником техподдержки или руководителем.
     *
     * @param int[] $executorIds
     */
    public function createManual(
        string $title,
        string $description,
        array $executorIds = [],
        ?int $requestTaskId = null
    ): WorkTask {
        $this->assertSupportStaff();

        $executorIds = $this->normalizeExecutorIds($executorIds);

        $linkedRequest = null;
        if ($requestTaskId !== null) {
            $exists = WorkTask::find()
                ->where(['request_task_id' => $requestTaskId, 'is_deleted' => false])
                ->exists();
            if ($exists) {
                throw new \RuntimeException('Для выбранной заявки задача уже существует.');
            }
            $linkedRequest = Tasks::findOne((int) $requestTaskId);
        }

        $statusCode = $executorIds !== [] ? DicWorkTaskStatus::CODE_ASSIGNED : DicWorkTaskStatus::CODE_QUEUE;
        $statusId = DicWorkTaskStatus::resolveIdByCode($statusCode);
        if ($statusId === null) {
            throw new \RuntimeException('Справочник статусов задач не настроен.');
        }

        $task = new WorkTask();
        $task->title = $title;
        $task->description = $description;
        $task->status_id = $statusId;
        $task->creator_id = $linkedRequest && (int) $linkedRequest->requester_id > 0
            ? (int) $linkedRequest->requester_id
            : (int) Yii::$app->user->id;
        $task->executor_id = $executorIds[0] ?? null;
        $task->request_task_id = $requestTaskId;
        $task->priority = 'medium';
        $task->is_deleted = false;
        $task->status_changed_at = date('Y-m-d H:i:s');

        if (!$task->save()) {
            $errors = $task->getFirstErrors();
            $detail = $errors !== [] ? implode(' ', $errors) : 'Проверьте заполнение полей.';
            throw new \RuntimeException('Не удалось сохранить задачу: ' . $detail);
        }

        if ($executorIds !== []) {
            WorkTaskExecutor::syncForTask((int) $task->id, $executorIds);
            $task->refresh();
        }

        WorkTaskHistory::log($task->id, 'created', null, $task->status_id);

        return $task;
    }

    /**
     * Мягкое удаление задачи (только руководитель).
     */
    public function delete(WorkTask $task): void
    {
        $this->assertSupportStaff();
        $this->assertManager();

        if ($task->is_deleted) {
            throw new \InvalidArgumentException('Задача уже удалена.');
        }

        $oldStatus = (int) $task->status_id;
        $task->is_deleted = true;
        $task->save(false);
        WorkTaskHistory::log($task->id, 'deleted', $oldStatus, null, 'Задача удалена');
    }

    public function assignExecutor(WorkTask $task, ?int $executorId): WorkTask
    {
        return $this->assignExecutors($task, $executorId !== null ? [(int) $executorId] : []);
    }

    /**
     * @param int[] $executorIds
     */
    public function assignExecutors(WorkTask $task, array $executorIds): WorkTask
    {
        $this->assertSupportStaff();
        $this->assertManager();

        if ($task->isFinal()) {
            throw new ForbiddenHttpException('Задача уже завершена.');
        }

        $executorIds = $this->normalizeExecutorIds($executorIds);
        $this->assertValidExecutors($executorIds);

        $oldStatus = (int) $task->status_id;
        WorkTaskExecutor::syncForTask((int) $task->id, $executorIds);
        $task->refresh();

        if ($executorIds !== []) {
            $this->promoteToAssignedIfNeeded($task);
        }

        $task->save(false);
        $historyNote = $executorIds === []
            ? 'Исполнители сняты'
            : 'Исполнители: ' . implode(', ', $this->resolveExecutorNames($executorIds));
        WorkTaskHistory::log($task->id, 'assign_executor', $oldStatus, (int) $task->status_id, $historyNote);

        $this->syncLinkedRequestStatus($task);

        return $task;
    }

    public function addExecutor(WorkTask $task, int $executorId): WorkTask
    {
        $this->assertSupportStaff();
        $this->assertManager();

        if ($task->isFinal()) {
            throw new ForbiddenHttpException('Задача уже завершена.');
        }

        $executorId = (int) $executorId;
        if ($executorId <= 0) {
            throw new \InvalidArgumentException('Выберите исполнителя.');
        }
        if ($task->isExecutorUser($executorId)) {
            throw new \InvalidArgumentException('Этот сотрудник уже назначен исполнителем.');
        }

        $this->assertValidExecutors([$executorId]);

        $oldStatus = (int) $task->status_id;
        $executorIds = $task->getExecutorIds();
        $executorIds[] = $executorId;
        WorkTaskExecutor::syncForTask((int) $task->id, $executorIds);
        $task->refresh();

        $this->promoteToAssignedIfNeeded($task);
        $task->save(false);

        $addedName = $this->resolveExecutorNames([$executorId])[0] ?? '';
        WorkTaskHistory::log(
            $task->id,
            'assign_executor',
            $oldStatus,
            (int) $task->status_id,
            'Добавлен исполнитель: ' . $addedName
        );

        $this->syncLinkedRequestStatus($task);

        return $task;
    }

    public function removeExecutor(WorkTask $task, int $executorId): WorkTask
    {
        $this->assertSupportStaff();
        $this->assertManager();

        if ($task->isFinal()) {
            throw new ForbiddenHttpException('Задача уже завершена.');
        }

        $executorId = (int) $executorId;
        if (!$task->isExecutorUser($executorId)) {
            throw new \InvalidArgumentException('Исполнитель не назначен на эту задачу.');
        }

        $oldStatus = (int) $task->status_id;
        $removedName = $this->resolveExecutorNames([$executorId])[0] ?? '';
        $executorIds = array_values(array_filter(
            $task->getExecutorIds(),
            static fn(int $id): bool => $id !== $executorId
        ));

        WorkTaskExecutor::syncForTask((int) $task->id, $executorIds);
        $task->refresh();

        if ($executorIds === [] && $task->getStatusCode() === DicWorkTaskStatus::CODE_ASSIGNED) {
            $queueId = DicWorkTaskStatus::resolveIdByCode(DicWorkTaskStatus::CODE_QUEUE);
            if ($queueId !== null) {
                $task->status_id = $queueId;
                $this->touchStatusChangedAt($task);
            }
        }

        $task->save(false);
        WorkTaskHistory::log(
            $task->id,
            'assign_executor',
            $oldStatus,
            (int) $task->status_id,
            'Снят исполнитель: ' . $removedName
        );

        $this->syncLinkedRequestStatus($task);

        return $task;
    }

    private function promoteToAssignedIfNeeded(WorkTask $task): void
    {
        if (!$task->hasExecutor()) {
            return;
        }

        $assignedId = DicWorkTaskStatus::resolveIdByCode(DicWorkTaskStatus::CODE_ASSIGNED);
        if ($assignedId === null || $task->getStatusCode() !== DicWorkTaskStatus::CODE_QUEUE) {
            return;
        }

        $task->status_id = $assignedId;
        $assignedStatus = DicWorkTaskStatus::findOne($assignedId);
        if ($assignedStatus !== null) {
            $task->populateRelation('status', $assignedStatus);
        }
        $this->touchStatusChangedAt($task);
    }

    /**
     * При «Взять в работу» из очереди назначает текущего сотрудника исполнителем.
     * Для статуса «Назначена» исполнитель уже должен быть в списке — см. transition().
     */
    private function ensureExecutorForTakeInWork(WorkTask $task, Users $user): void
    {
        $userId = (int) $user->id;
        if ($task->isExecutorUser($userId)) {
            return;
        }

        if ($task->getStatusCode() !== DicWorkTaskStatus::CODE_QUEUE) {
            throw new ForbiddenHttpException('Взять в работу может только назначенный исполнитель.');
        }

        if (!Users::canBeTaskExecutor($userId)) {
            throw new ForbiddenHttpException('Взять задачу в работу могут только сотрудники технической поддержки.');
        }

        $oldStatusId = (int) $task->status_id;
        $executorIds = $task->getExecutorIds();
        $executorIds[] = $userId;
        WorkTaskExecutor::syncForTask((int) $task->id, $executorIds);
        $task->refresh();
        $this->promoteToAssignedIfNeeded($task);

        $name = trim((string) $user->full_name);
        WorkTaskHistory::log(
            $task->id,
            'assign_executor',
            $oldStatusId,
            (int) $task->status_id,
            'Взята в работу: ' . ($name !== '' ? $name : 'сотрудник #' . $userId)
        );

        $this->syncLinkedRequestStatus($task);
    }

    /**
     * Переход по workflow (с проверкой прав).
     */
    public function transition(WorkTask $task, string $targetCode, ?string $comment = null): WorkTask
    {
        $this->assertSupportStaff();
        $user = Yii::$app->user->identity;

        $current = $task->getStatusCode();
        $target = DicWorkTaskStatus::findByCode($targetCode);
        if (!$target) {
            throw new \InvalidArgumentException('Неизвестный статус.');
        }

        $allowed = $this->getAllowedTransitions($task, $user);
        if (!in_array($targetCode, $allowed, true)) {
            throw new ForbiddenHttpException('Недоступный переход статуса.');
        }

        if ($targetCode === DicWorkTaskStatus::CODE_ASSIGNED && !$task->hasExecutor()) {
            throw new \InvalidArgumentException('Сначала назначьте исполнителя.');
        }

        if ($targetCode === DicWorkTaskStatus::CODE_IN_PROGRESS) {
            if ($current === DicWorkTaskStatus::CODE_ASSIGNED && !$task->isExecutorUser((int) $user->id)) {
                throw new ForbiddenHttpException('Взять в работу может только назначенный исполнитель.');
            }
            if ($user->isSupportStaff()) {
                $this->ensureExecutorForTakeInWork($task, $user);
                $task->refresh();
            }
        }

        if (in_array($targetCode, [DicWorkTaskStatus::CODE_IN_PROGRESS, DicWorkTaskStatus::CODE_PENDING_REVIEW], true)
            && !$task->isExecutorUser((int) $user->id)
            && !$user->isAdministrator()
        ) {
            throw new ForbiddenHttpException('Действие доступно назначенному исполнителю.');
        }

        $oldStatusId = (int) $task->status_id;
        $task->status_id = (int) $target->id;

        if ($this->isActiveWorkStatus($targetCode)) {
            $this->resetCompletionTimestamps($task);
        }
        if ($targetCode === DicWorkTaskStatus::CODE_PENDING_REVIEW) {
            $task->submitted_at = date('Y-m-d H:i:s');
        }
        if ($targetCode === DicWorkTaskStatus::CODE_DONE) {
            $task->confirmed_at = date('Y-m-d H:i:s');
            $task->confirmed_by = (int) $user->id;
        }

        if ($oldStatusId !== (int) $task->status_id) {
            $this->touchStatusChangedAt($task);
        }

        $task->populateRelation('status', $target);
        $task->save(false);
        WorkTaskHistory::log($task->id, 'status_change', $oldStatusId, (int) $task->status_id, $comment);

        $this->syncLinkedRequestStatus($task);

        return $task;
    }

    /**
     * Массовое подтверждение задач в статусе «Выполнена» (только руководитель).
     *
     * @return array{confirmed: int, failed: int, errors: string[]}
     */
    public function confirmAllPendingReview(WorkTaskSearch $search, array $params): array
    {
        $this->assertManager();

        $tasks = $search->createPendingReviewQuery($params)->all();
        $confirmed = 0;
        $failed = 0;
        $errors = [];

        $transaction = Yii::$app->db->beginTransaction();
        try {
            foreach ($tasks as $task) {
                try {
                    $this->transition($task, DicWorkTaskStatus::CODE_DONE, 'Массовое подтверждение руководителем');
                    ++$confirmed;
                } catch (\Throwable $e) {
                    ++$failed;
                    if (count($errors) < 5) {
                        $errors[] = 'Задача #' . (int) $task->id . ': ' . $e->getMessage();
                    }
                }
            }
            $transaction->commit();
        } catch (\Throwable $e) {
            $transaction->rollBack();
            throw $e;
        }

        return [
            'confirmed' => $confirmed,
            'failed' => $failed,
            'errors' => $errors,
        ];
    }

    /**
     * Синхронизация связанной заявки: статус и исполнитель по внутренней задаче.
     */
    public function syncLinkedRequestStatus(WorkTask $workTask): void
    {
        DicTaskStatus::ensureRequestSyncStatuses();

        if (!$workTask->request_task_id) {
            return;
        }

        $request = Tasks::findOne((int) $workTask->request_task_id);
        if ($request === null) {
            return;
        }

        $executorChanged = $this->syncLinkedRequestExecutor($request, $workTask);

        $workCode = $workTask->getStatusCode();
        $targetStatusId = $this->resolveRequestStatusIdForWorkTask($workCode);

        $statusChanged = false;
        $oldStatusId = (int) $request->status_id;
        if ($targetStatusId !== null && $oldStatusId !== $targetStatusId) {
            $request->status_id = $targetStatusId;
            $statusChanged = true;
        }

        $this->applyRequestClosedAtForWorkTask($request, $workCode);

        if (!$statusChanged && $request->closed_at === null && $this->isWorkTaskCompletedCode($workCode)) {
            $request->closed_at = date('Y-m-d H:i:s');
            $statusChanged = true;
        }

        if ($statusChanged) {
            TaskHistory::log(
                (int) $request->id,
                'status_id',
                (string) $oldStatusId,
                (string) $request->status_id,
                $this->buildRequestSyncComment($workTask, $workCode)
            );
        }

        if ($executorChanged || $statusChanged || $request->isAttributeChanged('closed_at')) {
            $request->save(false);
        }
    }

    /**
     * Первичное назначение исполнителя в заявке → внутренняя задача.
     */
    public function syncExecutorFromRequestToWorkTask(Tasks $request): void
    {
        if (!$request->hasAssignedExecutor() || (int) $request->id <= 0) {
            return;
        }

        $workTask = WorkTask::find()
            ->where(['request_task_id' => (int) $request->id, 'is_deleted' => false])
            ->one();
        if ($workTask === null) {
            return;
        }

        $requestExecutorId = (int) $request->executor_id;
        if ($workTask->isExecutorUser($requestExecutorId)) {
            return;
        }

        $oldStatusId = (int) $workTask->status_id;
        $executorIds = $workTask->getExecutorIds();
        $executorIds[] = $requestExecutorId;
        WorkTaskExecutor::syncForTask((int) $workTask->id, $executorIds);
        $workTask->refresh();

        $assignedId = DicWorkTaskStatus::resolveIdByCode(DicWorkTaskStatus::CODE_ASSIGNED);
        if ($assignedId !== null && $workTask->getStatusCode() === DicWorkTaskStatus::CODE_QUEUE) {
            $workTask->status_id = $assignedId;
            $assignedStatus = DicWorkTaskStatus::findOne($assignedId);
            if ($assignedStatus !== null) {
                $workTask->populateRelation('status', $assignedStatus);
            }
            $this->touchStatusChangedAt($workTask);
        }

        $workTask->save(false);
        WorkTaskHistory::log(
            $workTask->id,
            'assign_executor',
            $oldStatusId,
            (int) $workTask->status_id,
            'Назначен исполнитель из заявки #' . $request->id
        );
    }

    /**
     * @return bool true, если исполнитель заявки изменён
     */
    private function syncLinkedRequestExecutor(Tasks $request, WorkTask $workTask): bool
    {
        $executorIds = $workTask->getExecutorIds();
        if ($executorIds === []) {
            return false;
        }

        $newId = (int) $executorIds[0];
        $oldId = $request->executor_id ? (int) $request->executor_id : null;
        if ($oldId === $newId) {
            return false;
        }

        $request->executor_id = $newId;
        TaskHistory::log(
            (int) $request->id,
            'executor_id',
            $oldId !== null ? (string) $oldId : '',
            (string) $newId,
            'Синхронизация исполнителя из задачи #' . $workTask->id
        );

        $assignedStatusId = DicTaskStatus::getExecutorAssignedStatusId();
        if ($assignedStatusId !== null && (int) $request->status_id !== $assignedStatusId) {
            $oldStatusId = (int) $request->status_id;
            $request->status_id = $assignedStatusId;
            TaskHistory::log(
                (int) $request->id,
                'status_id',
                (string) $oldStatusId,
                (string) $assignedStatusId,
                'Статус заявки при назначении исполнителя из задачи #' . $workTask->id
            );
        }

        return true;
    }

    private function resolveRequestStatusIdForWorkTask(string $workCode): ?int
    {
        switch ($workCode) {
            case DicWorkTaskStatus::CODE_ASSIGNED:
                return DicTaskStatus::getExecutorAssignedStatusId();

            case DicWorkTaskStatus::CODE_IN_PROGRESS:
                return DicTaskStatus::resolveIdByCode(DicTaskStatus::CODE_IN_PROGRESS);

            case DicWorkTaskStatus::CODE_PENDING_REVIEW:
            case DicWorkTaskStatus::CODE_DONE:
                return DicTaskStatus::getCompletedStatusId();

            case DicWorkTaskStatus::CODE_CANCELLED:
                return DicTaskStatus::resolveIdByCode(DicTaskStatus::CODE_CANCELLED);

            case DicWorkTaskStatus::CODE_QUEUE:
            default:
                return null;
        }
    }

    private function isWorkTaskCompletedCode(string $workCode): bool
    {
        return in_array($workCode, [
            DicWorkTaskStatus::CODE_PENDING_REVIEW,
            DicWorkTaskStatus::CODE_DONE,
        ], true);
    }

    private function applyRequestClosedAtForWorkTask(Tasks $request, string $workCode): void
    {
        if ($this->isWorkTaskCompletedCode($workCode)) {
            if (!$request->closed_at) {
                $request->closed_at = date('Y-m-d H:i:s');
            }

            return;
        }

        $request->closed_at = null;
    }

    private function buildRequestSyncComment(WorkTask $workTask, string $workCode): string
    {
        $labels = [
            DicWorkTaskStatus::CODE_ASSIGNED => 'Назначен исполнитель',
            DicWorkTaskStatus::CODE_IN_PROGRESS => 'В работе',
            DicWorkTaskStatus::CODE_PENDING_REVIEW => 'Выполнена',
            DicWorkTaskStatus::CODE_DONE => 'Выполнена',
            DicWorkTaskStatus::CODE_CANCELLED => 'Отменена',
        ];
        $label = $labels[$workCode] ?? $workCode;

        return 'Статус заявки по задаче #' . $workTask->id . ': «' . $label . '»';
    }

    /**
     * @return string[]
     */
    public function getAllowedTransitions(WorkTask $task, Users $user): array
    {
        $code = $task->getStatusCode();
        if ($code === DicWorkTaskStatus::CODE_CANCELLED) {
            return [];
        }

        $isManager = $user->isAdministrator();
        $isExecutor = $task->isExecutorUser((int) $user->id);

        switch ($code) {
            case DicWorkTaskStatus::CODE_QUEUE:
                $out = [];
                if ($user->isSupportStaff()) {
                    $out[] = DicWorkTaskStatus::CODE_IN_PROGRESS;
                }
                if ($isManager) {
                    $out[] = DicWorkTaskStatus::CODE_ASSIGNED;
                    $out[] = DicWorkTaskStatus::CODE_CANCELLED;
                }

                return $out;

            case DicWorkTaskStatus::CODE_ASSIGNED:
                $out = [];
                if ($isExecutor) {
                    $out[] = DicWorkTaskStatus::CODE_IN_PROGRESS;
                }
                if ($isManager) {
                    $out[] = DicWorkTaskStatus::CODE_CANCELLED;
                }

                return $out;

            case DicWorkTaskStatus::CODE_IN_PROGRESS:
                $out = [];
                if ($isExecutor || $isManager) {
                    $out[] = DicWorkTaskStatus::CODE_PENDING_REVIEW;
                }
                if ($isManager) {
                    $out[] = DicWorkTaskStatus::CODE_ASSIGNED;
                    $out[] = DicWorkTaskStatus::CODE_CANCELLED;
                }
                return $out;

            case DicWorkTaskStatus::CODE_PENDING_REVIEW:
                if ($isManager) {
                    return [DicWorkTaskStatus::CODE_DONE, DicWorkTaskStatus::CODE_IN_PROGRESS, DicWorkTaskStatus::CODE_CANCELLED];
                }
                return [];

            case DicWorkTaskStatus::CODE_DONE:
                return $isManager ? [DicWorkTaskStatus::CODE_IN_PROGRESS] : [];

            default:
                return [];
        }
    }

    public function assertManager(): void
    {
        $user = Yii::$app->user->identity;
        if (!$user || !$user->isSupportStaff()) {
            throw new ForbiddenHttpException('Раздел «Задачи» доступен только сотрудникам технической поддержки и руководителю.');
        }
        if (!$user->isAdministrator()) {
            throw new ForbiddenHttpException('Действие доступно руководителю (администратору).');
        }
    }

    public function assertSupportStaff(): void
    {
        $user = Yii::$app->user->identity;
        if (!$user || !$user->isSupportStaff()) {
            throw new ForbiddenHttpException('Раздел «Задачи» доступен только сотрудникам технической поддержки и руководителю.');
        }
    }

    public function canAccess(WorkTask $task, ?Users $user = null): bool
    {
        $user = $user ?? Yii::$app->user->identity;

        return $user !== null && $user->isSupportStaff();
    }

    /**
     * @param int[] $executorIds
     * @return int[]
     */
    public function normalizeExecutorIds(array $executorIds): array
    {
        $normalized = [];
        foreach ($executorIds as $id) {
            $id = (int) $id;
            if ($id > 0) {
                $normalized[$id] = $id;
            }
        }

        return array_values($normalized);
    }

    /**
     * @param int[] $executorIds
     */
    private function assertValidExecutors(array $executorIds): void
    {
        foreach ($executorIds as $executorId) {
            if (!Users::findOne(['id' => $executorId])) {
                throw new \InvalidArgumentException('Исполнитель не найден.');
            }
            if (!Users::canBeTaskExecutor($executorId)) {
                throw new \InvalidArgumentException('Исполнителем может быть только сотрудник технической поддержки.');
            }
        }
    }

    /**
     * @param int[] $executorIds
     * @return string[]
     */
    private function resolveExecutorNames(array $executorIds): array
    {
        if ($executorIds === []) {
            return [];
        }

        $rows = Users::find()
            ->select(['id', 'full_name'])
            ->where(['id' => $executorIds])
            ->indexBy('id')
            ->all();

        $names = [];
        foreach ($executorIds as $id) {
            if (!isset($rows[$id])) {
                continue;
            }
            $name = trim((string) $rows[$id]->full_name);
            if ($name !== '') {
                $names[] = $name;
            }
        }

        return $names;
    }

    public function canComment(WorkTask $task, ?Users $user = null): bool
    {
        if ($task->is_deleted || $task->getStatusCode() === DicWorkTaskStatus::CODE_CANCELLED) {
            return false;
        }

        return $this->canAccess($task, $user);
    }

    public function addComment(WorkTask $task, string $body): WorkTaskComment
    {
        $this->assertSupportStaff();
        $user = Yii::$app->user->identity;
        if (!$user || !$this->canComment($task, $user)) {
            throw new ForbiddenHttpException('Нельзя добавить комментарий к этой задаче.');
        }

        $body = trim($body);
        if ($body === '') {
            throw new \InvalidArgumentException('Введите текст комментария.');
        }
        if (mb_strlen($body) > 4000) {
            throw new \InvalidArgumentException('Комментарий не должен превышать 4000 символов.');
        }

        $comment = new WorkTaskComment();
        $comment->work_task_id = (int) $task->id;
        $comment->author_id = (int) $user->id;
        $comment->body = $body;

        if (!$comment->save()) {
            $errors = $comment->getFirstErrors();
            $detail = $errors !== [] ? implode(' ', $errors) : 'Не удалось сохранить комментарий.';

            throw new \RuntimeException($detail);
        }

        WorkTaskHistory::log($task->id, 'comment', null, null, $body);

        return $comment;
    }

    /**
     * @return array<int, string> id => full_name
     */
    public static function getExecutorList(): array
    {
        return Users::getSupportStaffList();
    }

    private function applyStatus(WorkTask $task, int $statusId, ?string $comment = null): void
    {
        $old = (int) $task->status_id;
        $task->status_id = $statusId;
        $status = DicWorkTaskStatus::findOne($statusId);
        if ($status !== null) {
            $task->populateRelation('status', $status);
        }
        if ($old !== $statusId) {
            $this->touchStatusChangedAt($task);
        }
        $task->save(false);
        WorkTaskHistory::log($task->id, 'status_change', $old, $statusId, $comment);

        if ($old !== $statusId) {
            $this->syncLinkedRequestStatus($task);
        }
    }

    private function touchStatusChangedAt(WorkTask $task): void
    {
        $task->status_changed_at = date('Y-m-d H:i:s');
    }

    /**
     * @return array{time_in_status: string, time_in_status_title: string, time_is_completion: bool}
     */
    public static function boardTimeMeta(WorkTask $task): array
    {
        $meta = $task->getCardTimeMeta();

        return [
            'time_in_status' => $meta['label'],
            'time_in_status_title' => $meta['title'],
            'time_is_completion' => $meta['is_completion'],
        ];
    }

    /** Статусы, в которых задача снова в работе (не на проверке и не закрыта). */
    private function isActiveWorkStatus(string $code): bool
    {
        return in_array($code, [
            DicWorkTaskStatus::CODE_QUEUE,
            DicWorkTaskStatus::CODE_ASSIGNED,
            DicWorkTaskStatus::CODE_IN_PROGRESS,
        ], true);
    }

    private function resetCompletionTimestamps(WorkTask $task): void
    {
        $task->submitted_at = null;
        $task->confirmed_at = null;
        $task->confirmed_by = null;
    }
}
