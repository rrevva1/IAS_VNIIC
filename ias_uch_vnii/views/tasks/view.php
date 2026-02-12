<?php

use yii\helpers\Html;
use yii\helpers\Url;
use yii\widgets\DetailView;
use app\assets\TasksAsset;

/* @var $this yii\web\View */
/* @var $model app\models\Tasks */

$this->title = 'Заявка #' . $model->id;
$this->params['breadcrumbs'][] = ['label' => 'Заявки', 'url' => ['index']];
$this->params['breadcrumbs'][] = $this->title;

// Подключение Asset bundle для задач
TasksAsset::register($this);

// Передача URL для AJAX запросов в JavaScript
$this->registerJs("var statusChangeUrl = '" . Url::to(['change-status', 'id' => $model->id]) . "'; var executorChangeUrl = '" . Url::to(['assign-executor', 'id' => $model->id]) . "';", \yii\web\View::POS_HEAD);

?>
<div class="tasks-view">

    <h1><?= Html::encode($this->title) ?></h1>

    <!-- Кнопки действий -->
    <p>
        <?= Html::a('Редактировать', ['update', 'id' => $model->id], ['class' => 'btn btn-primary']) ?>
        <?= Html::a('Удалить', ['delete', 'id' => $model->id], [
            'class' => 'btn btn-danger',
            'data' => [
                'confirm' => 'Вы уверены, что хотите удалить эту заявку?',
                'method' => 'post',
            ],
        ]) ?>
        <?= Html::a('К списку заявок', ['index'], ['class' => 'btn btn-secondary']) ?>
    </p>

    <!-- Основная информация -->
    <?= DetailView::widget([
        'model' => $model,
        'attributes' => [
            'id',
            [
                'attribute' => 'status_id',
                'label' => 'Статус',
                'format' => 'raw',
                'value' => function ($model) {
                    $statusClass = 'default';
                    if ($model->status && $model->status->status_code) {
                        $map = ['new' => 'success', 'in_progress' => 'warning', 'resolved' => 'info', 'closed' => 'info', 'cancelled' => 'danger'];
                        $statusClass = $map[$model->status->status_code] ?? 'default';
                    }
                    return Html::tag('span', $model->status ? $model->status->status_name : '—', [
                        'class' => 'label label-' . $statusClass
                    ]);
                },
            ],
            [
                'attribute' => 'description',
                'format' => 'raw',
                'value' => nl2br(Html::encode($model->description)),
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

    <!-- Быстрое управление -->
    <div class="row mt-4">
        <div class="col-md-6">
            <h4>Изменить статус</h4>
            <?= Html::dropDownList('status_change', $model->status_id, 
                \app\models\dictionaries\DicTaskStatus::getStatusList(), [
                'class' => 'form-control',
                'id' => 'status-change',
                'prompt' => 'Выберите статус...'
            ]) ?>
        </div>
        <div class="col-md-6">
            <h4>Назначить исполнителя</h4>
            <?= Html::dropDownList('executor_change', $model->executor_id, 
                \app\models\entities\Users::find()->select(['full_name', 'id'])->indexBy('id')->column(), [
                'class' => 'form-control',
                'id' => 'executor-change',
                'prompt' => 'Выберите исполнителя...'
            ]) ?>
        </div>
    </div>
    <!-- Вложения -->
    <?php if (!empty($model->getAllAttachments())): ?>
    <div class="mt-4">
        <h4>Вложения (<?= count($model->getAllAttachments()) ?>)</h4>
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
                            <?= Html::a('<i class="glyphicon glyphicon-download-alt"></i>', 
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
                                    <i class="glyphicon glyphicon-eye-open"></i>
                                </button>
                            <?php endif; ?>
                            <?= Html::a('<i class="glyphicon glyphicon-trash"></i>', 
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
<div class="modal fade" id="imageModal" tabindex="-1" role="dialog" aria-labelledby="imageModalLabel">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="imageModalLabel">Просмотр изображения</h4>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body text-center">
                <img id="modalImage" src="" alt="" class="img-responsive">
                <p id="modalImageName" class="text-muted"></p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Закрыть</button>
                <a id="modalDownloadBtn" href="#" class="btn btn-primary">
                    <i class="glyphicon glyphicon-download-alt"></i> Скачать
                </a>
            </div>
        </div>
    </div>
</div>


