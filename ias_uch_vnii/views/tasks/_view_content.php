<?php

use yii\helpers\Html;
use yii\helpers\Url;
use yii\widgets\DetailView;
use app\models\dictionaries\DicTaskStatus;
use app\models\entities\Users;

/**
 * Карточка заявки (просмотр).
 *
 * @var yii\web\View $this
 * @var app\models\entities\Tasks $model
 * @var app\models\entities\TaskHistory[] $taskHistory
 * @var array<int, array{changed_at: string, type: string, title: string, detail_html: string, note: string|null, user_name: string|null}> $taskHistoryItems
 * @var bool $isModal
 * @var bool $canEditExecutorComment
 */

$isModal = !empty($isModal);
$canEditExecutorComment = !empty($canEditExecutorComment);

$pageTitle = 'Заявка #' . $model->id;

if (!$isModal) {
    $this->title = $pageTitle;
    $this->params['breadcrumbs'][] = ['label' => 'Заявки', 'url' => ['index']];
    $this->params['breadcrumbs'][] = $this->title;
}

$canAssignExecutor = !Yii::$app->user->isGuest
    && Yii::$app->user->identity
    && Yii::$app->user->identity->isAdministrator()
    && !$model->hasAssignedExecutor();
$executorList = $canAssignExecutor ? Users::getSupportStaffList() : [];
$equipments = $model->getEquipments()->all();
$canOpenArm = Yii::$app->user->identity && Yii::$app->user->identity->canAccessArm();

$displayExecutorNames = $model->getDisplayExecutorNames();
$executorsLabel = count($displayExecutorNames) > 1 ? 'Исполнители' : 'Исполнитель';
$renderExecutorsValue = static function (array $names): string {
    if ($names === []) {
        return '<span class="text-muted">Не назначен</span>';
    }
    if (count($names) === 1) {
        return Html::encode($names[0]);
    }
    $items = '';
    foreach ($names as $name) {
        $items .= '<li>' . Html::encode($name) . '</li>';
    }

    return '<ul class="tasks-view-executors list-unstyled mb-0">' . $items . '</ul>';
};
$executorsValueHtml = $renderExecutorsValue($displayExecutorNames);
?>

<?php
$statusBadgeHtml = DicTaskStatus::renderStatusPill(
    $model->status ? $model->status->status_code : null,
    $model->status ? $model->status->status_name : null
);
$contactPhoneHtml = '<span class="text-muted">Не указан</span>';
if (!empty($model->contact_phone)) {
    $phone = Html::encode($model->contact_phone);
    $tel = preg_replace('/[^\d+]/', '', $model->contact_phone);
    $contactPhoneHtml = $tel !== ''
        ? Html::a($phone, 'tel:' . $tel, ['class' => 'tasks-contact-phone-link'])
        : $phone;
}
$roomDisplay = trim((string) ($model->room_number ?? ''));
$roomDisplay = $roomDisplay !== '' ? Html::encode($roomDisplay) : '—';

$formatTaskTextBlock = static function (?string $text, string $emptyLabel = 'Не указано'): string {
    if ($text === null || trim($text) === '') {
        return '<span class="text-muted">' . Html::encode($emptyLabel) . '</span>';
    }

    return nl2br(Html::encode(trim($text)), false);
};

$taskAttachments = $model->getAllAttachments();
$isAdmin = !Yii::$app->user->isGuest
    && Yii::$app->user->identity
    && Yii::$app->user->identity->isAdministrator();
?>

<div class="tasks-view<?= $isModal ? ' tasks-view--modal' : '' ?>"
     id="tasksViewRoot"
     data-task-id="<?= (int) $model->id ?>"
     data-executor-change-url="<?= Html::encode(Url::to(['assign-executor', 'id' => $model->id])) ?>">

    <?php if ($isModal): ?>
    <div id="tasksViewHeaderSlot" class="tasks-view-modal__hero">
        <div class="tasks-view-modal__hero-main">
            <span class="tasks-view-modal__number">#<?= (int) $model->id ?></span>
            <h2 class="tasks-view__title tasks-view-modal__title"><?= Html::encode($pageTitle) ?></h2>
            <p class="tasks-view-modal__meta">
                <span class="tasks-view-modal__meta-item">
                    <i class="far fa-calendar" aria-hidden="true"></i>
                    <?= Yii::$app->formatter->asDatetime($model->created_at, 'php:d.m.Y, H:i') ?>
                </span>
                <?php if ($model->status): ?>
                <span class="tasks-view-modal__meta-item"><?= $statusBadgeHtml ?></span>
                <?php endif; ?>
            </p>
        </div>
    </div>

    <div id="tasksViewActionsSlot" class="tasks-view-modal__actions-source">
        <?= Html::button('<i class="fas fa-pen" aria-hidden="true"></i> Редактировать', [
            'type' => 'button',
            'class' => 'btn btn-primary btn-sm',
            'data-task-edit' => (int) $model->id,
        ]) ?>
        <?= Html::a('<i class="fas fa-trash" aria-hidden="true"></i> Удалить', ['delete', 'id' => $model->id], [
            'class' => 'btn btn-outline-danger btn-sm',
            'data' => [
                'confirm' => 'Вы уверены, что хотите удалить эту заявку?',
                'method' => 'post',
            ],
        ]) ?>
        <?= Html::button('Закрыть', [
            'class' => 'btn btn-light btn-sm',
            'type' => 'button',
            'data-bs-dismiss' => 'modal',
        ]) ?>
    </div>

    <div class="tasks-view-modal__content">
        <section class="tasks-view-card">
            <h3 class="tasks-view-card__title"><i class="fas fa-align-left" aria-hidden="true"></i> Описание</h3>
            <div class="tasks-view-card__body">
                <div class="tasks-view-prose"><?= $formatTaskTextBlock($model->description) ?></div>
            </div>
        </section>

        <div class="tasks-view-modal__grid">
            <section class="tasks-view-card">
                <h3 class="tasks-view-card__title"><i class="fas fa-circle-info" aria-hidden="true"></i> Сведения</h3>
                <dl class="tasks-view-dl">
                    <div class="tasks-view-dl__row">
                        <dt>Помещение</dt>
                        <dd><?= $roomDisplay ?></dd>
                    </div>
                    <div class="tasks-view-dl__row">
                        <dt>Телефон</dt>
                        <dd><?= $contactPhoneHtml ?></dd>
                    </div>
                    <div class="tasks-view-dl__row">
                        <dt>Обновлено</dt>
                        <dd><?= Yii::$app->formatter->asDatetime($model->updated_at, 'php:d.m.Y, H:i') ?></dd>
                    </div>
                </dl>
            </section>

            <section class="tasks-view-card">
                <h3 class="tasks-view-card__title"><i class="fas fa-users" aria-hidden="true"></i> Участники</h3>
                <dl class="tasks-view-dl">
                    <div class="tasks-view-dl__row">
                        <dt>Автор</dt>
                        <dd><?= $model->requester ? Html::encode($model->requester->full_name) : '—' ?></dd>
                    </div>
                    <div class="tasks-view-dl__row">
                        <dt><?= Html::encode($executorsLabel) ?></dt>
                        <dd><?= $executorsValueHtml ?></dd>
                    </div>
                </dl>
            </section>
        </div>

        <?php if ($isModal && $canEditExecutorComment): ?>
        <section class="tasks-view-card tasks-view-executor-comment"
                 data-update-url="<?= Html::encode(Url::to(['update-comment', 'id' => $model->id])) ?>">
            <h3 class="tasks-view-card__title"><i class="fas fa-comment" aria-hidden="true"></i> Комментарий исполнителя</h3>
            <div class="tasks-view-card__body">
                <label class="visually-hidden" for="tasksExecutorCommentInput">Комментарий исполнителя</label>
                <textarea id="tasksExecutorCommentInput"
                          class="form-control tasks-view-executor-comment__input"
                          rows="4"
                          placeholder="Комментарий для заявителя и коллег техподдержки"><?= Html::encode((string) $model->comment) ?></textarea>
                <div class="tasks-view-executor-comment__actions">
                    <button type="button" class="btn btn-primary btn-sm" data-task-save-comment>
                        <i class="fas fa-check" aria-hidden="true"></i> Сохранить
                    </button>
                    <span class="tasks-view-executor-comment__hint text-muted small">Ctrl+Enter — сохранить</span>
                    <span class="tasks-view-executor-comment__status text-muted small" role="status" aria-live="polite"></span>
                </div>
            </div>
        </section>
        <?php elseif ($model->comment): ?>
        <section class="tasks-view-card">
            <h3 class="tasks-view-card__title"><i class="fas fa-comment" aria-hidden="true"></i> Комментарий исполнителя</h3>
            <div class="tasks-view-card__body">
                <div class="tasks-view-prose"><?= $formatTaskTextBlock($model->comment, 'Нет комментария') ?></div>
            </div>
        </section>
        <?php endif; ?>

        <?php if ($taskAttachments !== []): ?>
        <section class="tasks-view-card" aria-label="Вложения">
            <h3 class="tasks-view-card__title">
                <i class="fas fa-paperclip" aria-hidden="true"></i>
                Вложения (<?= count($taskAttachments) ?>)
            </h3>
            <ul class="tasks-view-attachments list-unstyled mb-0">
                <?php foreach ($taskAttachments as $attachment): ?>
                <li class="tasks-view-attachments__item">
                    <i class="fas <?= Html::encode($attachment->getFileIcon()) ?>" aria-hidden="true"></i>
                    <?php if ($attachment->isImageOrScan()): ?>
                        <?= Html::a(
                            Html::encode($attachment->original_name),
                            'javascript:void(0)',
                            [
                                'class' => 'tasks-view-attachments__link preview-link',
                                'title' => 'Предпросмотр',
                                'data-ag-attachment-id' => (int) $attachment->id,
                                'data-ag-filename' => $attachment->original_name,
                                'data-ag-preview-url' => Url::to(['preview', 'id' => $attachment->id]),
                            ]
                        ) ?>
                    <?php else: ?>
                        <?= Html::a(
                            Html::encode($attachment->original_name),
                            ['download', 'id' => $attachment->id],
                            ['class' => 'tasks-view-attachments__link']
                        ) ?>
                    <?php endif; ?>
                    <span class="tasks-view-attachments__size text-muted small">
                        <?= Html::encode($attachment->getFormattedFileSize()) ?>
                    </span>
                </li>
                <?php endforeach; ?>
            </ul>
        </section>
        <?php endif; ?>

    <?php else: ?>
    <div id="tasksViewHeaderSlot">
        <header class="tasks-page__header tasks-view__header">
            <div class="tasks-page__heading">
                <h1 class="tasks-page__title tasks-view__title"><?= Html::encode($pageTitle) ?></h1>
                <p class="tasks-page__subtitle tasks-view__subtitle">
                    Создана <?= Yii::$app->formatter->asDatetime($model->created_at, 'php:d.m.Y, H:i') ?>
                    <?php if ($model->status): ?>
                        · <?= $statusBadgeHtml ?>
                    <?php endif; ?>
                </p>
            </div>
        </header>
    </div>

    <div class="tasks-page__actions tasks-view__actions">
        <?= Html::button('<i class="fas fa-pen" aria-hidden="true"></i> Редактировать', [
            'type' => 'button',
            'class' => 'btn btn-primary tasks-tool-btn',
            'data-task-edit' => (int) $model->id,
        ]) ?>
        <?= Html::a('<i class="fas fa-trash" aria-hidden="true"></i> Удалить', ['delete', 'id' => $model->id], [
            'class' => 'btn btn-danger tasks-tool-btn',
            'data' => [
                'confirm' => 'Вы уверены, что хотите удалить эту заявку?',
                'method' => 'post',
            ],
        ]) ?>
        <?= Html::a('<i class="fas fa-list" aria-hidden="true"></i> К списку', ['index'], [
            'class' => 'btn btn-outline-secondary tasks-tool-btn',
        ]) ?>
    </div>

    <div class="tasks-detail-card">
    <?= DetailView::widget([
        'model' => $model,
        'attributes' => [
            [
                'attribute' => 'id',
                'label' => '№ заявки',
                'value' => static function ($model) {
                    return '#' . (int) $model->id;
                },
            ],
            [
                'attribute' => 'status_id',
                'label' => 'Статус',
                'format' => 'raw',
                'value' => static function ($model) {
                    if (!$model->status) {
                        return '<span class="text-muted">—</span>';
                    }

                    return DicTaskStatus::renderStatusPill(
                        $model->status->status_code,
                        $model->status->status_name
                    );
                },
            ],
            [
                'attribute' => 'description',
                'format' => 'raw',
                'value' => nl2br(Html::encode($model->description)),
            ],
            [
                'attribute' => 'contact_phone',
                'label' => 'Телефон для обратной связи',
                'format' => 'raw',
                'value' => static function ($model) {
                    if (empty($model->contact_phone)) {
                        return '<span class="text-muted">Не указан</span>';
                    }
                    $phone = Html::encode($model->contact_phone);
                    $tel = preg_replace('/[^\d+]/', '', $model->contact_phone);

                    return $tel !== ''
                        ? Html::a($phone, 'tel:' . $tel, ['class' => 'tasks-contact-phone-link'])
                        : $phone;
                },
            ],
            [
                'attribute' => 'room_number',
                'label' => 'Номер помещения',
                'value' => static function ($model) {
                    $room = trim((string) ($model->room_number ?? ''));

                    return $room !== '' ? $room : '—';
                },
            ],
            [
                'attribute' => 'requester_id',
                'label' => 'Автор',
                'value' => $model->requester ? $model->requester->full_name : '—',
            ],
            [
                'attribute' => 'executor_id',
                'label' => $executorsLabel,
                'format' => 'raw',
                'value' => $executorsValueHtml,
            ],
            [
                'attribute' => 'created_at',
                'label' => 'Дата создания',
                'format' => ['date', 'php:d.m.Y H:i:s'],
            ],
            [
                'attribute' => 'updated_at',
                'label' => 'Обновлено',
                'format' => ['date', 'php:d.m.Y H:i:s'],
            ],
            [
                'attribute' => 'comment',
                'format' => 'raw',
                'value' => $model->comment ? nl2br(Html::encode($model->comment)) : '<span class="text-muted">Нет комментариев</span>',
            ],
        ],
    ]) ?>
    </div>
    <?php endif; ?>

    <?php
    $sectionClass = $isModal ? 'tasks-view-card' : 'tasks-panel';
    $titleClass = $isModal ? 'tasks-view-card__title' : 'tasks-panel__title';
    ?>

    <?php
    $taskHistoryItems = $taskHistoryItems ?? [];
    if ($taskHistoryItems === [] && !empty($taskHistory)) {
        $taskHistoryItems = (new \app\components\TaskHistoryFormatter($taskHistory))->formatAll($taskHistory);
    }
    ?>
    <?php if (!empty($taskHistoryItems)): ?>
    <div class="<?= Html::encode($sectionClass) ?><?= $isModal ? ' tasks-view-card--collapsible' : '' ?>">
        <?php if ($isModal): ?>
        <button type="button"
                class="tasks-view-card__toggle"
                data-bs-toggle="collapse"
                data-bs-target="#tasksViewHistoryCollapse"
                aria-expanded="false"
                aria-controls="tasksViewHistoryCollapse">
            <span class="<?= Html::encode($titleClass) ?> mb-0">
                <i class="fas fa-clock-rotate-left" aria-hidden="true"></i> История изменений
                <span class="tasks-view-card__count"><?= count($taskHistoryItems) ?></span>
            </span>
            <i class="fas fa-chevron-down tasks-view-card__chevron" aria-hidden="true"></i>
        </button>
        <div class="collapse tasks-view-card__collapse" id="tasksViewHistoryCollapse">
        <?php else: ?>
        <h4 class="<?= Html::encode($titleClass) ?>"><i class="fas fa-clock-rotate-left" aria-hidden="true"></i> История изменений</h4>
        <?php endif; ?>
        <ul class="tasks-view-history list-unstyled mb-0">
            <?php foreach ($taskHistoryItems as $item): ?>
            <li class="tasks-view-history__item tasks-view-history__item--<?= Html::encode($item['type']) ?>">
                <time class="tasks-view-history__time" datetime="<?= Html::encode($item['changed_at']) ?>">
                    <?= Yii::$app->formatter->asDatetime($item['changed_at'], 'php:d.m.Y, H:i') ?>
                </time>
                <div class="tasks-view-history__main">
                    <span class="tasks-view-history__title"><?= Html::encode($item['title']) ?></span>
                    <div class="tasks-view-history__detail"><?= $item['detail_html'] ?></div>
                    <?php if (!empty($item['note'])): ?>
                    <p class="tasks-view-history__note"><?= Html::encode($item['note']) ?></p>
                    <?php endif; ?>
                </div>
                <?php if (!empty($item['user_name'])): ?>
                <span class="tasks-view-history__user"><?= Html::encode($item['user_name']) ?></span>
                <?php endif; ?>
            </li>
            <?php endforeach; ?>
        </ul>
        <?php if ($isModal): ?></div><?php endif; ?>
    </div>
    <?php endif; ?>

    <?php if (!empty($equipments)): ?>
    <div class="<?= Html::encode($sectionClass) ?>">
        <?php if ($isModal): ?>
        <h3 class="<?= Html::encode($titleClass) ?>"><i class="fas fa-desktop" aria-hidden="true"></i> Связанные активы</h3>
        <?php else: ?>
        <h4 class="<?= Html::encode($titleClass) ?>"><i class="fas fa-desktop" aria-hidden="true"></i> Связанные активы</h4>
        <?php endif; ?>
        <ul class="<?= $isModal ? 'tasks-view-list' : 'list-group' ?>">
            <?php foreach ($equipments as $eq): ?>
            <li class="<?= $isModal ? 'tasks-view-list__item' : 'list-group-item' ?>">
                <?php
                $eqLabel = Html::encode($eq->inventory_number . ' — ' . ($eq->name ?: ''));
                ?>
                <?= $canOpenArm
                    ? Html::a($eqLabel, ['/arm/index', 'equipment' => $eq->id], ['target' => '_blank', 'rel' => 'noopener'])
                    : $eqLabel ?>
            </li>
            <?php endforeach; ?>
        </ul>
    </div>
    <?php endif; ?>

    <?php if (!$isModal || $canAssignExecutor): ?>
    <div class="<?= Html::encode($sectionClass) ?>">
        <?php if ($isModal): ?>
        <h3 class="<?= Html::encode($titleClass) ?>"><i class="fas fa-user-check" aria-hidden="true"></i> Назначение исполнителя</h3>
        <?= Html::dropDownList('executor_change', null, $executorList, [
            'class' => 'form-control js-user-select-search',
            'id' => 'executor-change',
            'prompt' => 'Выберите исполнителя...',
            'data-placeholder' => 'Выберите исполнителя...',
        ]) ?>
        <p class="tasks-view-card__hint text-muted small mt-2 mb-0">
            Назначить исполнителя может только руководитель отдела. После назначения изменение — в разделе «Задачи».
        </p>
        <?php else: ?>
        <div class="row g-3">
            <div class="col-md-6">
                <h4 class="<?= Html::encode($titleClass) ?>"><i class="fas fa-user-check" aria-hidden="true"></i> Исполнитель</h4>
                <?php if ($canAssignExecutor): ?>
                    <?= Html::dropDownList('executor_change', null, $executorList, [
                        'class' => 'form-control js-user-select-search',
                        'id' => 'executor-change',
                        'prompt' => 'Выберите исполнителя...',
                        'data-placeholder' => 'Выберите исполнителя...',
                    ]) ?>
                    <p class="tasks-panel__hint text-muted small mt-2 mb-0">
                        Назначить исполнителя может только руководитель отдела. После назначения изменение — в разделе «Задачи».
                    </p>
                <?php elseif ($displayExecutorNames !== []): ?>
                    <div class="mb-1"><?= $executorsValueHtml ?></div>
                    <p class="tasks-panel__hint text-muted small mb-0">
                        <?= count($displayExecutorNames) > 1
                            ? 'Исполнителей несколько — полный состав и изменения в разделе «Задачи».'
                            : 'Исполнитель зафиксирован. Чтобы сменить его, откройте связанную задачу в разделе «Задачи».' ?>
                    </p>
                <?php else: ?>
                    <p class="text-muted mb-0">Не назначен</p>
                <?php endif; ?>
            </div>
        </div>
        <?php endif; ?>
    </div>
    <?php endif; ?>

    <?php if (!$isModal && $taskAttachments !== []): ?>
    <div class="<?= Html::encode($sectionClass) ?>">
        <h4 class="<?= Html::encode($titleClass) ?>">
            <i class="fas fa-paperclip" aria-hidden="true"></i>
            Вложения (<?= count($taskAttachments) ?>)
        </h4>
        <div class="row">
            <?php foreach ($taskAttachments as $attachment): ?>
            <div class="col-md-3 col-sm-4 col-xs-6 mb-3">
                <div class="card attachment-card">
                    <div class="card-body text-center">
                        <?php if (in_array(strtolower((string) $attachment->file_extension), ['jpg', 'jpeg', 'png', 'gif'], true)): ?>
                            <img src="<?= Url::to(['preview', 'id' => $attachment->id]) ?>"
                                 alt="<?= Html::encode($attachment->original_name) ?>"
                                 class="img-fluid mb-2"
                                 data-bs-toggle="modal"
                                 data-bs-target="#imageModal"
                                 data-image-src="<?= Html::encode(Url::to(['preview', 'id' => $attachment->id])) ?>"
                                 data-image-name="<?= Html::encode($attachment->original_name) ?>">
                        <?php else: ?>
                            <i class="fa <?= $attachment->getFileIcon() ?> fa-3x text-muted mb-2"></i>
                        <?php endif; ?>

                        <h6 class="card-title" title="<?= Html::encode($attachment->original_name) ?>">
                            <?= \yii\helpers\StringHelper::truncate($attachment->original_name, 20) ?>
                        </h6>
                        <p class="text-muted small">
                            <?= $attachment->getFormattedFileSize() ?>
                        </p>

                        <div class="btn-group btn-group-sm">
                            <?= Html::a('<i class="fas fa-download" aria-hidden="true"></i>',
                                ['download', 'id' => $attachment->id], [
                                'class' => 'btn btn-outline-primary',
                                'title' => 'Скачать',
                            ]) ?>
                            <?php if (in_array(strtolower((string) $attachment->file_extension), ['jpg', 'jpeg', 'png', 'gif'], true)): ?>
                                <button type="button"
                                        class="btn btn-outline-info"
                                        data-bs-toggle="modal"
                                        data-bs-target="#imageModal"
                                        data-image-src="<?= Html::encode(Url::to(['preview', 'id' => $attachment->id])) ?>"
                                        data-image-name="<?= Html::encode($attachment->original_name) ?>"
                                        title="Просмотр">
                                    <i class="fas fa-eye" aria-hidden="true"></i>
                                </button>
                            <?php endif; ?>
                            <?php if ($isAdmin): ?>
                            <?= Html::a('<i class="fas fa-trash" aria-hidden="true"></i>',
                                ['delete-attachment', 'taskId' => $model->id, 'attachmentId' => $attachment->id], [
                                'class' => 'btn btn-outline-danger',
                                'title' => 'Удалить',
                                'data' => [
                                    'confirm' => 'Вы уверены, что хотите удалить это вложение?',
                                    'method' => 'post',
                                ],
                            ]) ?>
                            <?php endif; ?>
                        </div>
                    </div>
                </div>
            </div>
            <?php endforeach; ?>
        </div>
    </div>
    <?php endif; ?>

    <?php if ($isModal): ?>
    </div>
    <?php endif; ?>

</div>
