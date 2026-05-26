<?php

use yii\helpers\Html;
use yii\helpers\Url;
use yii\widgets\DetailView;
use app\assets\TasksAsset;
use app\models\entities\Users;

/* @var $this yii\web\View */
/* @var $model app\models\Tasks */

$this->title = 'Заявка #' . $model->id;
$this->params['breadcrumbs'][] = ['label' => 'Заявки', 'url' => ['index']];
$this->params['breadcrumbs'][] = $this->title;

// Подключение Asset bundle для задач
TasksAsset::register($this);

// Передача URL для AJAX запросов в JavaScript
$this->registerJs("var statusChangeUrl = '" . Url::to(['change-status', 'id' => $model->id]) . "'; var executorChangeUrl = '" . Url::to(['assign-executor', 'id' => $model->id]) . "';", \yii\web\View::POS_HEAD);

$statusBadgeMap = [
    'new' => 'bg-success',
    'executor_assigned' => 'bg-primary',
    'in_progress' => 'bg-warning text-dark',
    'on_hold' => 'bg-secondary',
    'resolved' => 'bg-info text-dark',
    'closed' => 'bg-info text-dark',
    'cancelled' => 'bg-danger',
];
?>
<div class="tasks-page tasks-page--detail tasks-view">

    <header class="tasks-page__header">
        <div class="tasks-page__heading">
            <h1 class="tasks-page__title"><?= Html::encode($this->title) ?></h1>
            <p class="tasks-page__subtitle">
                Создана <?= Yii::$app->formatter->asDatetime($model->created_at, 'php:d.m.Y, H:i') ?>
                <?php if ($model->status): ?>
                    · <span class="tasks-status-badge <?= $statusBadgeMap[$model->status->status_code] ?? 'bg-secondary' ?>">
                        <?= Html::encode($model->status->status_name) ?>
                    </span>
                <?php endif; ?>
            </p>
        </div>
    </header>

    <div class="tasks-page__actions">
        <?= Html::a('<i class="fas fa-pen" aria-hidden="true"></i> Редактировать', ['update', 'id' => $model->id], [
            'class' => 'btn btn-primary tasks-tool-btn',
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
            'id',
            [
                'attribute' => 'status_id',
                'label' => 'Статус',
                'format' => 'raw',
                'value' => function ($model) {
                    if (!$model->status) {
                        return '—';
                    }
                    $badge = $statusBadgeMap[$model->status->status_code] ?? 'bg-secondary';

                    return Html::tag('span', $model->status->status_name, [
                        'class' => 'tasks-status-badge ' . $badge,
                    ]);
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
                'value' => function ($model) {
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
                'attribute' => 'requester_id',
                'label' => 'Автор',
                'value' => $model->requester ? $model->requester->full_name : '—',
            ],
            [
                'attribute' => 'executor_id',
                'label' => 'Исполнитель',
                'format' => 'raw',
                'value' => $model->executor ? $model->executor->full_name : '<span class="text-muted">Не назначен</span>',
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

    <?php
    $taskHistory = \app\models\entities\TaskHistory::find()
        ->where(['task_id' => $model->id])
        ->with('changedByUser')
        ->orderBy(['changed_at' => SORT_DESC])
        ->limit(30)
        ->all();
    if (!empty($taskHistory)):
    ?>
    <div class="tasks-panel">
    <h4 class="tasks-panel__title"><i class="fas fa-clock-rotate-left" aria-hidden="true"></i> История изменений</h4>
    <table class="table table-bordered table-striped mb-0">
        <thead><tr><th>Дата</th><th>Поле</th><th>Было</th><th>Стало</th><th>Кто</th></tr></thead>
        <tbody>
            <?php foreach ($taskHistory as $h): ?>
            <tr>
                <td><?= Yii::$app->formatter->asDatetime($h->changed_at) ?></td>
                <td><?= Html::encode($h->field_name) ?></td>
                <td><?= Html::encode(mb_substr((string)$h->old_value, 0, 80)) ?></td>
                <td><?= Html::encode(mb_substr((string)$h->new_value, 0, 80)) ?></td>
                <td><?= $h->changedByUser ? Html::encode($h->changedByUser->full_name) : '—' ?></td>
            </tr>
            <?php endforeach; ?>
        </tbody>
    </table>
    </div>
    <?php endif; ?>

    <?php
    $equipments = $model->getEquipments()->all();
    if (!empty($equipments)):
    ?>
    <div class="tasks-panel">
    <h4 class="tasks-panel__title"><i class="fas fa-desktop" aria-hidden="true"></i> Связанные активы</h4>
    <ul class="list-group">
        <?php foreach ($equipments as $eq): ?>
        <li class="list-group-item">
            <?php
            $eqLabel = Html::encode($eq->inventory_number . ' — ' . ($eq->name ?: ''));
            $canOpenArm = Yii::$app->user->identity && Yii::$app->user->identity->canAccessArm();
            ?>
            <?= $canOpenArm
                ? Html::a($eqLabel, ['/arm/view', 'id' => $eq->id], ['target' => '_blank'])
                : $eqLabel ?>
        </li>
        <?php endforeach; ?>
    </ul>
    </div>
    <?php endif; ?>

    <div class="tasks-panel">
    <div class="row g-3">
        <div class="col-md-6">
            <h4 class="tasks-panel__title"><i class="fas fa-flag" aria-hidden="true"></i> Изменить статус</h4>
            <?= Html::dropDownList('status_change', $model->status_id, 
                \app\models\dictionaries\DicTaskStatus::getStatusList(), [
                'class' => 'form-control',
                'id' => 'status-change',
                'prompt' => 'Выберите статус...'
            ]) ?>
        </div>
        <div class="col-md-6">
            <h4 class="tasks-panel__title"><i class="fas fa-user-check" aria-hidden="true"></i> Исполнитель</h4>
            <?php
            $canAssignExecutor = !Yii::$app->user->isGuest
                && Yii::$app->user->identity
                && Yii::$app->user->identity->isAdministrator()
                && !$model->hasAssignedExecutor();
            if ($canAssignExecutor):
                $executorList = Users::getSupportStaffList();
            ?>
                <?= Html::dropDownList('executor_change', null, $executorList, [
                    'class' => 'form-control js-user-select-search',
                    'id' => 'executor-change',
                    'prompt' => 'Выберите исполнителя...',
                    'data-placeholder' => 'Выберите исполнителя...',
                ]) ?>
                <p class="tasks-panel__hint text-muted small mt-2 mb-0">
                    Назначить исполнителя может только руководитель отдела. После назначения изменение — в разделе «Задачи».
                </p>
            <?php elseif ($model->hasAssignedExecutor() && $model->executor): ?>
                <p class="mb-1"><?= Html::encode($model->executor->full_name) ?></p>
                <p class="tasks-panel__hint text-muted small mb-0">
                    Исполнитель зафиксирован. Чтобы сменить его, откройте связанную задачу в разделе «Задачи».
                </p>
            <?php else: ?>
                <p class="text-muted mb-0">Не назначен</p>
            <?php endif; ?>
        </div>
    </div>
    </div>

    <?php if (!empty($model->getAllAttachments())): ?>
    <div class="tasks-panel">
        <h4 class="tasks-panel__title"><i class="fas fa-paperclip" aria-hidden="true"></i> Вложения (<?= count($model->getAllAttachments()) ?>)</h4>
        <div class="row">
            <?php foreach ($model->getAllAttachments() as $attachment): ?>
            <div class="col-md-3 col-sm-4 col-xs-6 mb-3">
                <div class="card attachment-card">
                    <div class="card-body text-center">
                        <?php if (in_array(strtolower($attachment->file_extension), ['jpg', 'jpeg', 'png', 'gif'])): ?>
                            <!-- Предварительный просмотр изображений -->
                            <img src="<?= \yii\helpers\Url::to(['view-attachment', 'attachmentId' => $attachment->id]) ?>" 
                                 alt="<?= Html::encode($attachment->original_name) ?>"
                                 class="img-fluid mb-2"
                                 data-bs-toggle="modal" 
                                 data-bs-target="#imageModal"
                                 data-image-src="<?= \yii\helpers\Url::to(['view-attachment', 'attachmentId' => $attachment->id]) ?>"
                                 data-image-name="<?= Html::encode($attachment->original_name) ?>">
                        <?php else: ?>
                            <!-- Иконка для не-изображений -->
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
                                ['download-attachment', 'attachmentId' => $attachment->id], [
                                'class' => 'btn btn-outline-primary',
                                'title' => 'Скачать'
                            ]) ?>
                            <?php if (in_array(strtolower($attachment->file_extension), ['jpg', 'jpeg', 'png', 'gif'])): ?>
                                <button type="button" 
                                        class="btn btn-outline-info"
                                        data-bs-toggle="modal" 
                                        data-bs-target="#imageModal"
                                        data-image-src="<?= \yii\helpers\Url::to(['view-attachment', 'attachmentId' => $attachment->id]) ?>"
                                        data-image-name="<?= Html::encode($attachment->original_name) ?>"
                                        title="Просмотр">
                                    <i class="fas fa-eye" aria-hidden="true"></i>
                                </button>
                            <?php endif; ?>
                            <?= Html::a('<i class="fas fa-trash" aria-hidden="true"></i>', 
                                ['delete-attachment', 'taskId' => $model->id, 'attachmentId' => $attachment->id], [
                                'class' => 'btn btn-outline-danger',
                                'title' => 'Удалить',
                                'data' => [
                                    'confirm' => 'Вы уверены, что хотите удалить это вложение?',
                                    'method' => 'post',
                                ],
                            ]) ?>
                        </div>
                    </div>
                </div>
            </div>
            <?php endforeach; ?>
        </div>
    </div>
    <?php endif; ?>

</div>


<!-- Модальное окно для просмотра изображений -->
<div class="modal fade tasks-modal" id="imageModal" tabindex="-1" aria-labelledby="imageModalLabel">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="imageModalLabel"><i class="fas fa-image" aria-hidden="true"></i> Просмотр изображения</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Закрыть"></button>
            </div>
            <div class="modal-body text-center">
                <img id="modalImage" src="" alt="" class="img-fluid">
                <p id="modalImageName" class="text-muted mt-2 mb-0"></p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Закрыть</button>
                <a id="modalDownloadBtn" href="#" class="btn btn-primary">
                    <i class="fas fa-download" aria-hidden="true"></i> Скачать
                </a>
            </div>
        </div>
    </div>
</div>


