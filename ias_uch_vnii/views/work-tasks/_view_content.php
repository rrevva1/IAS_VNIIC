<?php

use app\models\dictionaries\DicWorkTaskStatus;
use app\models\entities\WorkTaskComment;
use yii\helpers\Html;
use yii\helpers\StringHelper;
use yii\helpers\Url;

/** @var app\models\entities\WorkTask $model */
/** @var array $timelineSteps */
/** @var string[] $allowedTransitions */
/** @var bool $isManager */
/** @var bool $canComment */
/** @var WorkTaskComment[] $comments */
/** @var array $executors */

$currentCode = $model->getStatusCode();
$statusLabel = $model->status ? $model->status->getDisplayName() : '—';
$description = trim((string) $model->description);
$showTimeInColumn = $model->showsTimeInColumn();
$submittedAtDisplay = $model->submitted_at
    ?: ($currentCode === DicWorkTaskStatus::CODE_PENDING_REVIEW
        ? ($model->status_changed_at ?: $model->updated_at)
        : null);
$showSubmittedAt = $submittedAtDisplay !== null
    && in_array($currentCode, [DicWorkTaskStatus::CODE_PENDING_REVIEW, DicWorkTaskStatus::CODE_DONE], true);
$showConfirmedAt = $model->confirmed_at && $currentCode === DicWorkTaskStatus::CODE_DONE;
$showCancelledAt = $currentCode === DicWorkTaskStatus::CODE_CANCELLED;

$transitionLabels = [
    DicWorkTaskStatus::CODE_ASSIGNED => 'Назначить',
    DicWorkTaskStatus::CODE_IN_PROGRESS => $currentCode === DicWorkTaskStatus::CODE_DONE
        ? 'Вернуть в работу'
        : 'Взять в работу',
    DicWorkTaskStatus::CODE_PENDING_REVIEW => 'Отметить выполненной',
    DicWorkTaskStatus::CODE_DONE => 'Подтвердить выполнение',
    DicWorkTaskStatus::CODE_CANCELLED => 'Отменить',
    DicWorkTaskStatus::CODE_QUEUE => 'В очередь',
];

$transitionUrl = Url::to(['transition', 'id' => $model->id]);

$modalTransitions = array_values(array_filter($allowedTransitions, static function (string $code): bool {
    return !in_array($code, [
        DicWorkTaskStatus::CODE_ASSIGNED,
        DicWorkTaskStatus::CODE_CANCELLED,
    ], true);
}));

$history = $model->getHistory()->with(['changedByUser', 'oldStatus', 'newStatus'])->limit(12)->all();
$historyLabels = [
    'created' => 'Создание',
    'created_from_request' => 'Создание по заявке',
    'assign_executor' => 'Назначение исполнителя',
    'status_change' => 'Смена статуса',
    'comment' => 'Комментарий',
    'deleted' => 'Удаление',
];

$comments = $comments ?? [];
$requestContactPhone = $model->getRequestContactPhone();
$attachments = $model->getAllAttachments();

$fmtDate = static function ($value): string {
    return $value ? Yii::$app->formatter->asDatetime($value, 'php:d.m.Y, H:i') : '';
};
?>

<div class="work-task-view" data-work-task-id="<?= (int) $model->id ?>">
    <div id="workTaskViewHeaderSlot" class="work-task-view__header-slot">
        <div class="work-task-view__header-row">
            <h2 class="work-task-view__title"><?= Html::encode($model->title) ?></h2>
            <?php if ($model->status): ?>
            <span class="work-task-status work-task-status--<?= Html::encode($currentCode) ?>">
                <?= Html::encode($statusLabel) ?>
            </span>
            <?php endif; ?>
        </div>
        <p class="work-task-view__subtitle">
            № <?= (int) $model->id ?>
            <?php if ($model->request_task_id): ?>
                · <?= Html::a(
                    'Заявка #' . (int) $model->request_task_id,
                    ['/tasks/view', 'id' => $model->request_task_id],
                    ['target' => '_blank', 'rel' => 'noopener', 'class' => 'work-task-view__request-link']
                ) ?>
            <?php endif; ?>
        </p>
    </div>

    <?php if ($currentCode === DicWorkTaskStatus::CODE_CANCELLED): ?>
    <div class="work-task-view__alert" role="status">Задача отменена и не выполняется.</div>
    <?php endif; ?>

    <div class="work-task-view__layout">
        <section class="work-task-view__main work-task-view__main-stack" aria-label="Содержание задачи">
            <?php if ($description !== ''): ?>
            <div class="work-task-view__description-text"><?= nl2br(Html::encode($description)) ?></div>
            <?php else: ?>
            <p class="work-task-view__no-description">Описание не указано.</p>
            <?php endif; ?>

            <?php if ($attachments !== []): ?>
            <div class="work-task-view__attachments" aria-label="Вложения">
                <h3 class="work-task-view__attachments-title">Вложения</h3>
                <ul class="work-task-view__attachments-list">
                    <?php foreach ($attachments as $attachment): ?>
                    <li class="work-task-view__attachments-item">
                        <i class="fas <?= Html::encode($attachment->getFileIcon()) ?>" aria-hidden="true"></i>
                        <?php if ($attachment->isImageOrScan()): ?>
                            <?= Html::a(
                                Html::encode($attachment->original_name),
                                ['tasks/preview', 'id' => $attachment->id],
                                ['target' => '_blank', 'rel' => 'noopener', 'class' => 'work-task-view__attachment-link']
                            ) ?>
                        <?php else: ?>
                            <?= Html::a(
                                Html::encode($attachment->original_name),
                                ['tasks/download', 'id' => $attachment->id],
                                ['class' => 'work-task-view__attachment-link']
                            ) ?>
                        <?php endif; ?>
                        <span class="work-task-view__attachment-size"><?= Html::encode($attachment->getFormattedFileSize()) ?></span>
                    </li>
                    <?php endforeach; ?>
                </ul>
            </div>
            <?php endif; ?>

            <section class="work-task-view__comments work-task-view__comments--minimal work-task-card" aria-label="Комментарии">
                <div class="work-task-view__comments-head">
                    <h3 class="work-task-view__comments-title">Комментарии</h3>
                </div>

                <?php if ($comments !== []): ?>
                <ul class="work-task-comment-list work-task-comment-list--minimal list-unstyled mb-0">
                    <?php foreach ($comments as $comment): ?>
                    <li class="work-task-comment work-task-comment--minimal">
                        <div class="work-task-comment__meta work-task-comment__meta--minimal">
                            <span class="work-task-comment__author work-task-comment__author--minimal">
                                <?= $comment->author ? Html::encode($comment->author->full_name) : 'Сотрудник' ?>
                            </span>
                            <time class="work-task-comment__time work-task-comment__time--minimal" datetime="<?= Html::encode($comment->created_at) ?>">
                                <?= Html::encode($fmtDate($comment->created_at)) ?>
                            </time>
                        </div>
                        <div class="work-task-comment__body work-task-comment__body--minimal"><?= nl2br(Html::encode($comment->body)) ?></div>
                    </li>
                    <?php endforeach; ?>
                </ul>
                <?php else: ?>
                <p class="work-task-view__comments-empty work-task-view__comments-empty--minimal">Пока нет комментариев.</p>
                <?php endif; ?>

                <?php if ($canComment): ?>
                <form id="workTaskCommentForm"
                      class="work-task-view__comment-form work-task-view__comment-form--minimal"
                      method="post"
                      action="<?= Html::encode(Url::to(['add-comment', 'id' => $model->id])) ?>">
                    <?= Html::hiddenInput(Yii::$app->request->csrfParam, Yii::$app->request->csrfToken) ?>
                    <label class="visually-hidden" for="workTaskCommentBody">Новый комментарий</label>
                    <textarea id="workTaskCommentBody"
                              name="body"
                              class="form-control work-task-view__comment-input work-task-view__comment-input--minimal"
                              rows="3"
                              maxlength="4000"
                              placeholder="Напишите комментарий..."
                              required></textarea>
                    <div class="work-task-view__comment-form-actions work-task-view__comment-form-actions--minimal">
                        <button type="submit" class="btn btn-primary work-tasks-tool-btn">Отправить</button>
                    </div>
                </form>
                <?php endif; ?>
            </section>
        </section>

        <aside class="work-task-view__aside work-task-view__aside-card" aria-label="Сведения о задаче">
            <div class="work-task-view__people" role="group" aria-label="Участники задачи">
                <div class="work-task-view__person work-task-view__person--author">
                    <span class="work-task-view__person-badge" aria-hidden="true">
                        <i class="fas fa-user"></i>
                    </span>
                    <div class="work-task-view__person-text">
                        <span class="work-task-view__person-label"><?= Html::encode($model->getAuthorLabel()) ?></span>
                        <span class="work-task-view__person-name"><?= Html::encode($model->getAuthorName()) ?></span>
                    </div>
                </div>
                <div class="work-task-view__person work-task-view__person--executor<?= $model->hasExecutor() ? '' : ' work-task-view__person--empty' ?>">
                    <span class="work-task-view__person-badge" aria-hidden="true">
                        <i class="fas fa-user-check"></i>
                    </span>
                    <div class="work-task-view__person-text">
                        <span class="work-task-view__person-label">Исполнитель</span>
                        <span class="work-task-view__person-name">
                            <?= $model->hasExecutor()
                                ? Html::encode($model->getExecutorName())
                                : '<span class="work-task-view__person-missing">Не назначен</span>' ?>
                        </span>
                    </div>
                </div>
            </div>

            <dl class="work-task-view__facts">
                <?php if ($requestContactPhone !== null): ?>
                <div class="work-task-view__fact">
                    <dt>Телефон для связи</dt>
                    <dd>
                        <?php
                        $tel = preg_replace('/[^\d+]/', '', $requestContactPhone);
                        echo $tel !== ''
                            ? Html::a(Html::encode($requestContactPhone), 'tel:' . $tel, [
                                'class' => 'work-task-view__phone-link',
                            ])
                            : Html::encode($requestContactPhone);
                        ?>
                    </dd>
                </div>
                <?php endif; ?>
                <div class="work-task-view__fact">
                    <dt>Создана</dt>
                    <dd><?= Html::encode($fmtDate($model->created_at)) ?></dd>
                </div>
                <?php if ($showTimeInColumn): ?>
                <div class="work-task-view__fact">
                    <dt>В колонке</dt>
                    <dd title="<?= Html::encode($model->getTimeInStatusTitle()) ?>">
                        <?= Html::encode($model->getTimeInStatusLabel()) ?>
                    </dd>
                </div>
                <?php endif; ?>
                <?php if ($showSubmittedAt): ?>
                <div class="work-task-view__fact">
                    <dt>Выполнена</dt>
                    <dd><?= Html::encode($fmtDate($submittedAtDisplay)) ?></dd>
                </div>
                <?php endif; ?>
                <?php if ($showConfirmedAt): ?>
                <div class="work-task-view__fact">
                    <dt>Закрыта</dt>
                    <dd><?= Html::encode($fmtDate($model->confirmed_at)) ?></dd>
                </div>
                <?php endif; ?>
                <?php if ($showCancelledAt): ?>
                <div class="work-task-view__fact">
                    <dt>Отменена</dt>
                    <dd><?= Html::encode($fmtDate($model->status_changed_at ?: $model->updated_at)) ?></dd>
                </div>
                <?php endif; ?>
            </dl>

            <?php if ($isManager && !$model->isFinal()): ?>
            <form id="workTaskAssignForm"
                  method="post"
                  action="<?= Html::encode(Url::to(['assign', 'id' => $model->id])) ?>"
                  class="work-task-view__assign">
                <?= Html::hiddenInput(Yii::$app->request->csrfParam, Yii::$app->request->csrfToken) ?>
                <label class="work-task-view__assign-label" for="workTaskAssignExecutor">Исполнитель</label>
                <div class="work-task-view__assign-row">
                    <select id="workTaskAssignExecutor" name="executor_id" class="form-select">
                        <option value="">Не назначен</option>
                        <?php foreach ($executors as $eid => $ename): ?>
                        <option value="<?= (int) $eid ?>"<?= (int) $model->executor_id === (int) $eid ? ' selected' : '' ?>>
                            <?= Html::encode($ename) ?>
                        </option>
                        <?php endforeach; ?>
                    </select>
                    <button type="submit" class="btn btn-primary work-tasks-tool-btn">Сохранить</button>
                </div>
            </form>
            <?php endif; ?>
            <?php if ($history !== []): ?>
            <details class="work-task-view__history">
                <summary>История <span class="work-task-view__history-count"><?= count($history) ?></span></summary>
                <ul class="work-tasks-history list-unstyled mb-0">
                    <?php foreach ($history as $h):
                        $eventLabel = $historyLabels[$h->event_type] ?? $h->event_type;
                    ?>
                    <li class="work-task-view__history-item">
                        <time datetime="<?= Html::encode($h->changed_at) ?>">
                            <?= Html::encode($fmtDate($h->changed_at)) ?>
                        </time>
                        <span class="work-task-view__history-event"><?= Html::encode($eventLabel) ?></span>
                        <?php if ($h->event_type === 'comment' && trim((string) $h->comment) !== ''): ?>
                        <span class="work-task-view__history-note">«<?= Html::encode(StringHelper::truncate((string) $h->comment, 120)) ?>»</span>
                        <?php elseif ($h->newStatus): ?>
                        <span class="work-task-view__history-status">→ <?= Html::encode($h->newStatus->getDisplayName()) ?></span>
                        <?php endif; ?>
                        <?php if ($h->changedByUser): ?>
                        <span class="work-task-view__history-user"><?= Html::encode($h->changedByUser->full_name) ?></span>
                        <?php endif; ?>
                    </li>
                    <?php endforeach; ?>
                </ul>
            </details>
            <?php endif; ?>
        </aside>
    </div>

    <?php if ($modalTransitions !== [] || ($isManager && !$model->is_deleted)): ?>
    <footer class="work-task-view__footer">
        <?php if ($modalTransitions !== []): ?>
        <div class="work-task-view__actions" role="group" aria-label="Действия с задачей">
            <?php foreach ($modalTransitions as $code):
                $label = $transitionLabels[$code] ?? $code;
                $btnClass = 'btn work-tasks-tool-btn ';
                if ($code === DicWorkTaskStatus::CODE_DONE) {
                    $btnClass .= 'btn-success';
                } elseif ($code === DicWorkTaskStatus::CODE_PENDING_REVIEW) {
                    $btnClass .= 'btn-primary';
                } else {
                    $btnClass .= 'btn-outline-primary';
                }
            ?>
            <button type="button"
                    class="<?= $btnClass ?>"
                    data-work-task-transition
                    data-url="<?= Html::encode($transitionUrl) ?>"
                    data-status-code="<?= Html::encode($code) ?>">
                <?= Html::encode($label) ?>
            </button>
            <?php endforeach; ?>
        </div>
        <?php endif; ?>

        <?php if ($isManager): ?>
        <button type="button"
                class="btn btn-link work-task-view__delete"
                data-work-task-delete
                data-task-id="<?= (int) $model->id ?>"
                data-url="<?= Html::encode(Url::to(['delete', 'id' => $model->id])) ?>">
            Удалить
        </button>
        <?php endif; ?>
    </footer>
    <?php endif; ?>
</div>
