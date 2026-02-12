<?php

use yii\helpers\Html;
use yii\helpers\Url;
use kartik\grid\GridView;
use app\models\search\TasksSearch;
use yii\bootstrap5\Modal as BootstrapModal;
use app\assets\TasksAsset;
use kartik\select2\Select2;
/* @var $this yii\web\View */
/* @var $searchModel TasksSearch */
/* @var $dataProvider yii\data\ActiveDataProvider */

// Подключаем assets для страницы задач
TasksAsset::register($this);

$this->title = 'Help Desk - Заявки';
$this->params['breadcrumbs'] = []; // Убираем хлебные крошки для полноэкранного режима

// Настройка колонок GridView
// Определяем, является ли пользователь администратором
$isAdmin = !Yii::$app->user->isGuest && Yii::$app->user->identity && Yii::$app->user->identity->isAdmin();

// Базовые колонки для всех пользователей
$gridColumns = [
    // 1. Чекбокс для выбора (только для админов)
];

if ($isAdmin) {
    $gridColumns[] = [
        'class' => 'kartik\grid\CheckboxColumn',
        'width' => '50px',
    ];
    // 2. ID заявки (только для админов)
    $gridColumns[] = [
        'attribute' => 'id',
        'width' => '10px',
        'format' => 'raw',
        'value' => function ($model) {
            return Html::a($model->id, ['view', 'id' => $model->id], [
                'title' => 'Просмотр заявки #' . $model->id
            ]);
        },
    ];
}

// 3. Описание заявки (для всех)
$gridColumns[] = [
    'attribute' => 'description',
    'format' => 'raw',
    'width' => '400px',
    'value' => function ($model) {
        return \yii\helpers\StringHelper::truncate($model->description, 50);
    },
];

// 4. Статус
if ($isAdmin) {
    // Для админов - редактируемый dropdown
    $gridColumns[] = [
        'attribute' => 'status_id',
        'label' => 'Статус',
        'format' => 'raw',
        'headerOptions' => ['style' => 'text-align: center;'],
        'contentOptions' => ['style' => 'text-align: center; vertical-align: middle;'],
        'value' => function ($model) use ($statusNames) {
            $color = $statusNames[$model->status_id]['color'] ?? '#6c757d';
            $colorScheme = ['bg' => $color . '20', 'text' => $color];
            return Html::dropDownList('status_' . $model->id, $model->status_id, 
                \app\models\dictionaries\DicTaskStatus::getStatusList(), [
                    'class' => 'form-control status-change',
                    'data-task-id' => $model->id,
                    'style' => "font-size: 14px; padding: 8px 5px; background-color: {$colorScheme['bg']}; color: {$colorScheme['text']}; width: 100%; text-align: center; text-align-last: center; border: 1px solid {$colorScheme['text']}40; border-radius: 4px; font-weight: 500;"
                ]);
        },
        'filter' => \app\models\dictionaries\DicTaskStatus::getStatusList(),
    ];
} else {
    // Для обычных пользователей - только просмотр
    $gridColumns[] = [
        'attribute' => 'status_id',
        'label' => 'Статус',
        'width' => '120px',
        'value' => 'status.status_name',
    ];
}

// 5. Автор заявки (для всех)
$gridColumns[] = [
    'attribute' => 'user_name',
    'label' => 'Автор',
    'width' => '120px',
    'value' => 'requester.full_name',
    'filter' => Select2::widget([
        'model' => $searchModel,
        'attribute' => 'user_name',
        'data' => \app\models\entities\Users::find()->select(['full_name', 'id'])->indexBy('id')->column(),
        'options' => ['placeholder' => 'Выберите автора'],
        'pluginOptions' => [
            'allowClear' => true,
            'theme' => 'bootstrap-5',
        ],
    ]),
    
];

// 6. Исполнитель
if ($isAdmin) {
    // Для админов - редактируемый dropdown
    $gridColumns[] = [
        'attribute' => 'executor_id',
        'label' => 'Исполнитель',
        'format' => 'raw',
        'headerOptions' => ['style' => 'text-align: center;'],
        'contentOptions' => ['style' => 'text-align: center; vertical-align: middle;'],
        'value' => function ($model) {
            return Html::dropDownList('executor_' . $model->id, $model->executor_id, 
                \app\models\entities\Users::find()->select(['full_name', 'id'])->indexBy('id')->column(), [
                    'class' => 'form-control executor-change',
                    'data-task-id' => $model->id,
                    'style' => 'font-size: 14px; padding: 8px 5px; width: 100%; text-align: center; text-align-last: center; border: none; border-radius: 4px; font-weight: 500;',
                    'prompt' => 'Не назначен'
                ]);
        },
    ];
} else {
    // Для обычных пользователей - только просмотр
    $gridColumns[] = [
        'attribute' => 'executor_id',
        'label' => 'Исполнитель',
        'width' => '150px',
        'format' => 'raw',
        'contentOptions' => ['style' => 'word-wrap: break-word; word-break: break-word; white-space: normal; line-height: 1.3;'],
        'value' => function ($model) {
            // Если executor_id пустой или связь отсутствует, возвращаем пустое значение
            if (empty($model->executor_id) || !$model->executor) {
                return '';
            }
            return Html::encode($model->executor->full_name);
        },
    ];
}

// 7. Дата создания (для всех)
$gridColumns[] = [
    'attribute' => 'created_at',
    'label' => 'Создана',
    'width' => '120px',
    'format' => ['date', 'php:d.m.Y H:i'],
];

// 8. Дата обновления (для всех)
$gridColumns[] = [
    'attribute' => 'updated_at',
    'label' => 'Обновлена',
    'width' => '120px',
    'format' => ['date', 'php:d.m.Y H:i'],
];

// 9. Вложения (для всех)
$gridColumns[] = [
    'label' => 'Вложения',
    'width' => '120px',
    'format' => 'raw',
    'value' => function ($model) {
        $attachments = $model->getAllAttachments();
        if (empty($attachments)) {
            return '<span class="text-muted">-</span>';
        }
        
        $html = '<div class="attachments-container">';
        foreach ($attachments as $attachment) {
            $iconClass = $attachment->getFileIcon();
            $isPreviewable = $attachment->isImageOrScan();
            
            if ($isPreviewable) {
                // Для изображений и PDF - ссылка на предпросмотр
                $html .= Html::a(
                    '<i class="fa ' . $iconClass . '"></i>',
                    'javascript:void(0);',
                    [
                        'class' => 'attachment-link preview-link',
                        'title' => $attachment->original_name,
                        'data-filename' => $attachment->original_name,
                        'data-attachment-id' => $attachment->id,
                        'data-preview-url' => $attachment->getPreviewUrl(),
                    ]
                );
            } else {
                // Для остальных файлов - ссылка на скачивание
                $html .= Html::a(
                    '<i class="fa ' . $iconClass . '"></i>',
                    $attachment->getDownloadUrl(),
                    [
                        'class' => 'attachment-link download-link',
                        'title' => $attachment->original_name,
                        'data-filename' => $attachment->original_name,
                        'data-attachment-id' => $attachment->attach_id
                    ]
                );
            }
        }
        $html .= '</div>';
        
        return $html;
    },
];

// 10. Комментарий
if ($isAdmin) {
    // Для админов - редактируемое поле
    $gridColumns[] = [
        'attribute' => 'comment',
        'label' => 'Комментарий',
        'format' => 'raw',
        'value' => function ($model) {
            return Html::textarea('comment_' . $model->id, $model->comment, [
                'class' => 'form-control comment-edit',
                'data-task-id' => $model->id,
                'rows' => 2,
                'style' => 'font-size: 11px; resize: vertical; min-height: 40px;'
            ]);
        },
    ];
} else {
    // Для обычных пользователей - только просмотр
    $gridColumns[] = [
        'attribute' => 'comment',
        'label' => 'Комментарий',
        'format' => 'raw',
        'value' => function ($model) {
            return \yii\helpers\StringHelper::truncate($model->comment, 30);
        },
    ];
}



// Проверяем, является ли пользователь обычным пользователем (не администратором)
$isRegularUser = !Yii::$app->user->isGuest && Yii::$app->user->identity && Yii::$app->user->identity->isRegularUser();

// Получаем статистику по статусам заявок для пользователя
$statusStats = [];
if ($isRegularUser) {
    $statusStats = \app\models\entities\Tasks::find()
        ->where(['requester_id' => Yii::$app->user->id])
        ->select(['status_id', 'COUNT(*) as count'])
        ->groupBy('status_id')
        ->asArray()
        ->all();
} else {
    $statusStats = \app\models\entities\Tasks::find()
        ->select(['status_id', 'COUNT(*) as count'])
        ->groupBy('status_id')
        ->asArray()
        ->all();
}

// Преобразуем в более удобный формат
$statusData = [];
$totalTasks = 0;
foreach ($statusStats as $stat) {
    $statusData[$stat['status_id']] = $stat['count'];
    $totalTasks += $stat['count'];
}

$statusNames = [];
foreach (\app\models\dictionaries\DicTaskStatus::find()->orderBy(['sort_order' => SORT_ASC])->all() as $s) {
    $colors = ['new' => '#28a745', 'in_progress' => '#ffc107', 'on_hold' => '#6c757d', 'resolved' => '#17a2b8', 'closed' => '#17a2b8', 'cancelled' => '#dc3545'];
    $icons = ['new' => 'glyphicon-folder-open', 'in_progress' => 'glyphicon-cog', 'resolved' => 'glyphicon-ok', 'closed' => 'glyphicon-ok', 'cancelled' => 'glyphicon-remove'];
    $statusNames[$s->id] = ['name' => $s->status_name, 'color' => $colors[$s->status_code] ?? '#6c757d', 'icon' => $icons[$s->status_code] ?? 'glyphicon-tag'];
}
?>
<div class="create-task-wrapper">
    <?php if ($isRegularUser): ?>
    <div class="create-task-block">
        <div class="create-task-info">
            <div class="info-icon">
                <i class="glyphicon glyphicon-file"></i>
            </div>
            <div class="info-content">
                <h4>Создать новую заявку</h4>
                <p>Опишите проблему или задачу, и мы поможем вам её решить. К заявке можно прикрепить файлы для более подробного описания.</p>
            </div>
        </div>
        <div class="create-task-action">
            <?= Html::button('<i class="glyphicon glyphicon-plus"></i> Создать заявку', [
                'class' => 'btn btn-success btn-create-task',
                'id' => 'createTaskBtn'
            ]) ?>
        </div>
    </div>
    <?php endif; ?>
</div>

<?php if ($isRegularUser): ?>
<?php 
BootstrapModal::begin([
    'id' => 'createTaskModal',
    'title' => 'Создать заявку',
    'size' => BootstrapModal::SIZE_LARGE,
    'toggleButton' => false,
]);
?>

<div id="createTaskFormContent">
    <!-- Контент формы будет загружен через AJAX -->
    <div class="text-center">
        <i class="glyphicon glyphicon-refresh glyphicon-spin"></i> Загрузка...
    </div>
</div>

<?php BootstrapModal::end(); ?>
<?php endif; ?>

<!-- Модальное окно для предпросмотра файлов (HTML) -->
<div class="modal fade preview-modal" id="previewModal" tabindex="-1" aria-labelledby="previewModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="previewModalLabel">Предпросмотр файла</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" id="previewContent">
                <!-- Контент предпросмотра будет загружен через JavaScript -->
                <div class="text-center text-muted">
                    <i class="glyphicon glyphicon-picture"></i>
                    <p>Выберите вложение для предпросмотра</p>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Закрыть</button>
                <a href="#" class="btn btn-primary" id="downloadBtn" target="_blank">
                    <i class="glyphicon glyphicon-download"></i> Скачать
                </a>
            </div>
        </div>
    </div>
</div>

<?php if ($isAdmin): ?>
<div class="status-diagram-wrapper">
    <div class="status-diagram">
        <h5 class="diagram-title">
            <i class="glyphicon glyphicon-stats"></i> Статистика всех заявок
        </h5>
        <div class="status-cards">
            <?php foreach ($statusNames as $statusId => $statusInfo): ?>
                <?php 
                $count = isset($statusData[$statusId]) ? $statusData[$statusId] : 0;
                $percentage = $totalTasks > 0 ? round(($count / $totalTasks) * 100) : 0;
                ?>
                <div class="status-card">
                    <div class="status-icon" style="background-color: <?= $statusInfo['color'] ?>20; color: <?= $statusInfo['color'] ?>;">
                        <i class="glyphicon <?= $statusInfo['icon'] ?>"></i>
                    </div>
                    <div class="status-info">
                        <div class="status-name"><?= $statusInfo['name'] ?></div>
                        <div class="status-count">
                            <span class="count-number"><?= $count ?></span>
                            <span class="count-percentage">(<?= $percentage ?>%)</span>
                        </div>
                    </div>
                    <div class="status-bar">
                        <div class="status-bar-fill" style="width: <?= $percentage ?>%; background-color: <?= $statusInfo['color'] ?>;"></div>
                    </div>
                </div>
            <?php endforeach; ?>
        </div>
    </div>
</div>
<?php endif; ?>

<!-- Основной контейнер для страницы заявок -->
<div class="tasks-index">
    <!-- Контейнер таблицы -->
    <div class="table-container">
        <?= GridView::widget([
            'id' => 'kv-grid-tasks',
            'dataProvider' => $dataProvider,
            'filterModel' => $isAdmin ? $searchModel : null, // Фильтры только для админов
            'columns' => $gridColumns,
            //'filterLayout' => $isAdmin ? '' : '{items}', // Убираем фильтры для пользователей
            'headerContainer' => ['style' => 'top:50px', 'class' => 'kv-table-header'],
            'floatHeader' => true,
            'floatPageSummary' => true,
            'floatFooter' => false,
            'pjax' => true,
            'responsive' => false,
            'bordered' => false,
            'striped' => false,
            'condensed' => true,
            'hover' => true,
            'showPageSummary' => true,
            'panel' => [
                
                'heading' => false,
                'type' => 'default',
                
            ],
            'export' => [
                'fontAwesome' => true
            ],
            'exportConfig' => [
                'html' => [],
                'csv' => [],
                'txt' => [],
                'xls' => [],
                'json' => [],
            ],
            'toolbar' => [
                [
                    'content' =>
                        ($isRegularUser ? 
                            Html::button('<i class="glyphicon glyphicon-plus"></i>', [
                                'class' => 'btn btn-success',
                                'title' => 'Создать заявку',
                                'onclick' => 'openCreateTaskModal()'
                            ]) : ''
                        ) . ' '.
                        ($isAdmin ? 
                            Html::button('<i class="glyphicon glyphicon-hdd"></i>', [
                                'class' => 'btn btn-primary',
                                'title' => 'Учет ТС',
                                'onclick' => 'openEquipmentManagementModal()'
                            ]) : ''
                        ) . ' '.
                        Html::button('<i class="glyphicon glyphicon-refresh"></i>', [
                            'class' => 'btn btn-outline-secondary',
                            'title' => 'Обновить',
                            'onclick' => 'location.reload()'
                        ]) . ' '.
                        Html::button('<i class="glyphicon glyphicon-check"></i>', [
                            'class' => 'btn btn-outline-secondary',
                            'title' => 'Выбрать все',
                            'onclick' => 'selectAll()'
                        ]) . ' ' .
                        Html::a('<i class="fas fa-table"></i> AG Grid', ['/tasks/ag-grid'], [
                            'class' => 'btn btn-info',
                            'title' => 'Открыть в AG Grid',
                            'style' => 'color: white;'
                        ]), 
                    'options' => ['class' => 'btn-group mr-2 me-2']
                ],
                '{export}',
                '{toggleData}',
            ],
            'toggleDataContainer' => ['class' => 'btn-group mr-2 me-2'],
            'persistResize' => false,
            'toggleDataOptions' => ['minCount' => 10],
            'itemLabelSingle' => 'заявка',
            'itemLabelPlural' => 'заявки',
            'layout' => '{toolbar} {items} {pager}',
            'pager' => [
                'options' => ['class' => 'pagination'],
                'firstPageLabel' => '«',
                'lastPageLabel' => '»',
                'prevPageLabel' => '‹',
                'nextPageLabel' => '›',
                'maxButtonCount' => 5,
            ],
            'tableOptions' => [
                'class' => 'table table-striped table-condensed',
                'style' => 'margin-bottom: 0; border: none;'
            ],
            'containerOptions' => [
                'style' => 'overflow-x: auto;'
            ],
            'pageSummaryPosition' => GridView::POS_TOP,
        ]) ?>
    </div>
    <!-- Конец контейнера таблицы -->
    
    <!-- Информация о компании под таблицей -->
    <div class="company-info">
        <div class="row">
            <div class="col-md-6">
                <small class="text-muted">&copy; ФГУП "ВНИИ "Центр" <?= date('Y') ?></small>
            </div>
            <div class="col-md-6 text-end">
                <small class="text-muted">Работает на Yii2</small>
            </div>
        </div>
    </div>
</div>
<!-- Конец основного контейнера -->

<?php
// CSS для корректного отображения таблицы заявок
$this->registerCss("
    /* Основные стили для страницы заявок */
    .tasks-index {
        width: 100%;
        margin: 0;
        padding: 20px;
        background: #fff;
        min-height: calc(100vh - 200px); /* Учитываем footer */
        max-width: 100%;
        overflow-x: hidden;
    }
    
    /* Убираем все отступы справа */
    .content-wrapper {
        margin-right: 0 !important;
        padding-right: 0 !important;
    }
    
    /* Убираем лишние float элементы */
    .float-right,
    .float-end {
        float: none !important;
    }
    
    /* Скрываем все элементы справа от основного контента */
    body > div:not(.main-content):not(.sidebar):not(#footer) {
        display: none !important;
    }
    
    /* Убираем лишние элементы, которые могут отображаться справа */
    .container-fluid > div:last-child:not(.tasks-index) {
        display: none !important;
    }
    
    /* Скрываем все элементы справа */
    .main-content > div:not(.content-wrapper) {
        display: none !important;
    }
    
    /* Убираем все элементы с float right */
    .float-right,
    .float-end,
    .pull-right {
        float: none !important;
        display: none !important;
    }
    
    /* Скрываем все элементы с position absolute/fixed справа */
    [style*=\"position: absolute\"][style*=\"right:\"],
    [style*=\"position: fixed\"][style*=\"right:\"] {
        display: none !important;
    }
    
    .table-container {
        background: #fff;
        border-radius: 0;
        box-shadow: none;
        overflow: hidden;
    }
    
    /* Убираем обводку у контейнера GridView */
    .kv-panel {
        border: none !important;
        box-shadow: none !important;
    }
    
    /* Убираем обводку у таблицы */
    .kv-grid-container {
        border: none !important;
    }
    
    /* Стили для информации о компании */
    .company-info {
        margin-top: 0;
        padding: 15px 20px;
        border-top: 1px solid #dee2e6;
        background: #f8f9fa;
        border-radius: 0 0 8px 8px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }
    
    /* Стили для контейнера кнопки создания заявки */
    #tasks-btn {
        margin-bottom: 15px;
        padding: 0;
    }
    
    #tasks-btn .btn {
        font-size: 0.85rem;
        padding: 6px 12px;
    }
    
    .company-info .text-muted {
        color: #6c757d !important;
        font-size: 12px;
    }
    
    /* Убираем лишние отступы у body */
    body {
        margin: 0;
        padding: 0;
        background: #f8f9fa;
    }
    
    .container-fluid {
        padding: 0;
        margin: 0;
        width: 100%;
    }
    
    /* Стили для таблицы GridView */
    .kv-grid-table {
        border: none !important;
        margin: 0 !important;
        width: 100%;
        border-collapse: collapse;
    }
    
    .kv-grid-table th,
    .kv-grid-table td {
        border: none !important;
        border-bottom: 1px solid #e9ecef !important;
        padding: 12px 8px !important;
        vertical-align: middle;
        text-align: left;
        word-wrap: break-word;
        word-break: break-word;
        white-space: normal;
    }
    
    .kv-grid-table th {
        background: #f8f9fa !important;
        font-weight: 600;
        font-size: 13px;
        color: #495057;
        border-bottom: 2px solid #dee2e6 !important;
    }
    
    .kv-grid-table tr:last-child td {
        border-bottom: none !important;
    }
    
    .kv-grid-table tbody tr:nth-child(even) {
        background: #f8f9fa;
    }
    
    .kv-grid-table tbody tr:hover {
        background: #e3f2fd !important;
        transition: background-color 0.2s ease;
    }
    
    /* Стили для панели GridView */
    .kv-panel {
        border: none !important;
        box-shadow: none !important;
        margin: 0 !important;
        background: transparent !important;
    }
    
    .kv-panel-heading {
        display: none !important;
    }
    
    .kv-panel-body {
        padding: 0 !important;
    }
    
    /* Скрываем заголовок панели если он есть */
    .panel-heading {
        display: none !important;
    }
    
    /* Стили для диаграммы статусов */
    .status-diagram-wrapper {
        margin-bottom: 20px;
    }
    
    .status-diagram {
        background: #fff;
        border-radius: 12px;
        padding: 20px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.08);
    }
    
    .diagram-title {
        margin: 0 0 20px 0;
        font-size: 16px;
        font-weight: 600;
        color: #343a40;
        padding-bottom: 15px;
        border-bottom: 2px solid #e9ecef;
    }
    
    .diagram-title i {
        margin-right: 8px;
        color: #667eea;
    }
    
    .status-cards {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 15px;
    }
    
    .status-card {
        background: #f8f9fa;
        border-radius: 8px;
        padding: 15px;
        transition: transform 0.2s ease, box-shadow 0.2s ease;
        border: 2px solid transparent;
    }
    
    .status-card:hover {
        transform: translateY(-3px);
        box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        border-color: #e9ecef;
    }
    
    .status-icon {
        width: 48px;
        height: 48px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 12px;
        font-size: 22px;
        transition: transform 0.2s ease;
    }
    
    .status-card:hover .status-icon {
        transform: scale(1.1);
    }
    
    .status-info {
        text-align: center;
        margin-bottom: 12px;
    }
    
    .status-name {
        font-size: 14px;
        font-weight: 600;
        color: #495057;
        margin-bottom: 5px;
    }
    
    .status-count {
        font-size: 20px;
        font-weight: 700;
        color: #212529;
    }
    
    .count-number {
        margin-right: 5px;
    }
    
    .count-percentage {
        font-size: 14px;
        font-weight: 500;
        color: #6c757d;
    }
    
    .status-bar {
        height: 6px;
        background: #e9ecef;
        border-radius: 3px;
        overflow: hidden;
    }
    
    .status-bar-fill {
        height: 100%;
        transition: width 0.5s ease;
        border-radius: 3px;
    }
    
    /* Адаптивность для диаграммы */
    @media (max-width: 768px) {
        .status-cards {
            grid-template-columns: 1fr;
        }
    }
    
    /* Стили для блока создания заявки */
    .create-task-wrapper {
        margin-bottom: 25px;
    }
    
    .create-task-block {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        border-radius: 12px;
        padding: 25px 30px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
        transition: transform 0.3s ease, box-shadow 0.3s ease;
    }
    
    .create-task-block:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
    }
    
    .create-task-info {
        display: flex;
        align-items: center;
        flex: 1;
        color: #fff;
    }
    
    .info-icon {
        font-size: 48px;
        margin-right: 20px;
        opacity: 0.9;
    }
    
    .info-content h4 {
        margin: 0 0 8px 0;
        font-size: 20px;
        font-weight: 600;
        color: #fff;
    }
    
    .info-content p {
        margin: 0;
        font-size: 14px;
        line-height: 1.5;
        opacity: 0.95;
        color: #fff;
    }
    
    .create-task-action {
        margin-left: 30px;
    }
    
    .btn-create-task {
        background: #fff;
        color: #667eea;
        border: none;
        padding: 12px 28px;
        font-size: 15px;
        font-weight: 600;
        border-radius: 8px;
        transition: all 0.3s ease;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
    }
    
    .btn-create-task:hover {
        background: #f8f9fa;
        color: #764ba2;
        transform: scale(1.05);
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
    }
    
    .btn-create-task i {
        margin-right: 8px;
    }
    
    /* Адаптивность для блока создания заявки */
    @media (max-width: 768px) {
        .create-task-block {
            flex-direction: column;
            text-align: center;
            padding: 20px;
        }
        
        .info-icon {
            margin-right: 0;
            margin-bottom: 15px;
            font-size: 36px;
        }
        
        .info-content {
            margin-bottom: 20px;
        }
        
        .create-task-action {
            margin-left: 0;
            width: 100%;
        }
        
        .btn-create-task {
            width: 100%;
        }
    }
    
    /* Стили для элементов формы */
    .form-control {
        border: 1px solid #ced4da;
        border-radius: 4px;
        font-size: 12px;
        padding: 6px 10px;
        transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
    }
    
    .form-control:focus {
        border-color: #80bdff;
        box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
        outline: 0;
    }
    
    /* Стили для кнопок */
    .btn-xs {
        padding: 4px 8px;
        font-size: 11px;
        margin: 1px;
        border-radius: 3px;
    }
    
    .btn-primary {
        background-color: #007bff;
        border-color: #007bff;
    }
    
    .btn-primary:hover {
        background-color: #0056b3;
        border-color: #004085;
    }
    
    /* Стили для бейджей */
    .badge {
        font-size: 11px;
        padding: 4px 8px;
        border-radius: 12px;
    }
    
    .badge-info {
        background-color: #17a2b8;
        color: #fff;
    }
    
    /* Стили для пагинации */
    .pagination {
        margin: 20px 0;
        justify-content: center;
    }
    
    .pagination > li > a {
        padding: 8px 12px;
        font-size: 13px;
        color: #007bff;
        border: 1px solid #dee2e6;
        margin: 0 2px;
        border-radius: 4px;
    }
    
    .pagination > li.active > a {
        background-color: #007bff;
        border-color: #007bff;
        color: #fff;
    }
    
    .pagination > li > a:hover {
        background-color: #e9ecef;
        border-color: #adb5bd;
    }
    
    /* Стили для сводки таблицы */
    .kv-grid-summary {
        background: #f8f9fa;
        font-weight: 600;
        border-top: 2px solid #007bff;
        padding: 15px 20px;
        color: #495057;
    }
    
    /* Стили для футера панели */
    .kv-panel-footer {
        background: #f8f9fa;
        border-top: 1px solid #dee2e6;
        padding: 15px 20px;
        text-align: center;
    }
    
    .kv-panel-footer em {
        color: #6c757d;
        font-size: 13px;
    }
    
    /* Индикаторы состояния для редактируемых полей */
    .status-change.loading,
    .executor-change.loading {
        opacity: 0.7;
        background-color: #f8f9fa;
        border-color: #adb5bd;
    }
    
    .comment-edit.editing {
        border-color: #ffc107;
        box-shadow: 0 0 0 0.2rem rgba(255, 193, 7, 0.25);
        background-color: #fffbf0;
    }
    
    .comment-edit.saving {
        border-color: #28a745;
        box-shadow: 0 0 0 0.2rem rgba(40, 167, 69, 0.25);
        background-color: #f8fff9;
    }
    
    /* Анимация для индикаторов */
    .status-change.loading::after,
    .executor-change.loading::after {
        content: '...';
        animation: dots 1.5s infinite;
    }
    
    @keyframes dots {
        0%, 20% { content: '.'; }
        40% { content: '..'; }
        60%, 100% { content: '...'; }
    }
    
    /* Стили для уведомлений */
    .alert {
        border-radius: 6px;
        font-size: 14px;
        border: none;
        box-shadow: 0 2px 8px rgba(0,0,0,0.15);
    }
    
    .alert-success {
        background-color: #d4edda;
        color: #155724;
    }
    
    .alert-danger {
        background-color: #f8d7da;
        color: #721c24;
    }
    
    .alert-dismissible .close {
        padding: 0.75rem 1.25rem;
        color: inherit;
    }
    
    /* Стили для вложений */
    .attachments-container {
        display: flex;
        flex-wrap: wrap;
        gap: 5px;
        align-items: center;
    }
    
    .attachment-link {
        display: inline-block;
        padding: 4px 6px;
        border-radius: 4px;
        text-decoration: none;
        transition: all 0.2s ease;
        font-size: 14px;
        color: #495057;
        border: 1px solid #dee2e6;
        background: #f8f9fa;
    }
    
    .attachment-link:hover {
        background: #e9ecef;
        border-color: #adb5bd;
        color: #212529;
        text-decoration: none;
        transform: translateY(-1px);
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    
    .preview-link {
        color: #007bff;
        border-color: #007bff;
        background: #e7f3ff;
    }
    
    .preview-link:hover {
        background: #cce7ff;
        border-color: #0056b3;
        color: #0056b3;
    }
    
    .download-link {
        color: #28a745;
        border-color: #28a745;
        background: #e8f5e8;
    }
    
    .download-link:hover {
        background: #d4edda;
        border-color: #1e7e34;
        color: #1e7e34;
    }
    
    /* Модальное окно для предпросмотра */
    .preview-modal .modal-dialog {
        max-width: 90vw;
        max-height: 90vh;
    }
    
    .preview-modal .modal-content {
        background: #000;
        border: none;
        border-radius: 8px;
    }
    
    .preview-modal .modal-header {
        background: #333;
        border-bottom: 1px solid #555;
        color: #fff;
    }
    
    .preview-modal .modal-header .close {
        color: #fff;
        opacity: 0.8;
    }
    
    .preview-modal .modal-header .close:hover {
        opacity: 1;
    }
    
    .preview-modal .modal-body {
        padding: 0;
        text-align: center;
        background: #000;
        max-height: 80vh;
        overflow: auto;
    }
    
    .preview-modal .modal-body img,
    .preview-modal .modal-body iframe {
        max-width: 100%;
        max-height: 80vh;
        object-fit: contain;
    }
    
    .preview-modal .modal-footer {
        background: #333;
        border-top: 1px solid #555;
        padding: 10px 15px;
    }
    
    .preview-modal .btn-download {
        background: #28a745;
        border-color: #28a745;
        color: #fff;
    }
    
    .preview-modal .btn-download:hover {
        background: #218838;
        border-color: #1e7e34;
    }
    
    /* Специальные стили для колонки исполнителя */
    .kv-grid-table td[data-col-seq=\"6\"] {
        max-width: 150px;
        word-wrap: break-word;
        word-break: break-word;
        white-space: normal;
        line-height: 1.4;
        padding: 8px 6px !important;
    }
    
    /* Стили для dropdown исполнителя */
    .executor-change {
        word-wrap: break-word;
        word-break: break-word;
        white-space: normal;
        line-height: 1.3;
    }
    
    /* Стили для Select2 с темой Bootstrap 5 */
    .select2-container--bootstrap-5 .select2-selection {
        border: 1px solid #ced4da;
        border-radius: 4px;
        min-height: 38px;
    }
    
    .select2-container--bootstrap-5 .select2-selection--single {
        padding: 6px 12px;
    }
    
    .select2-container--bootstrap-5 .select2-selection--single .select2-selection__rendered {
        line-height: 24px;
        padding-left: 0;
        color: #495057;
    }
    
    .select2-container--bootstrap-5 .select2-selection--single .select2-selection__arrow {
        height: 36px;
        right: 3px;
    }
    
    .select2-container--bootstrap-5.select2-container--focus .select2-selection,
    .select2-container--bootstrap-5.select2-container--open .select2-selection {
        border-color: #80bdff;
        box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
    }
    
    .select2-container--bootstrap-5 .select2-dropdown {
        border: 1px solid #ced4da;
        border-radius: 4px;
    }
    
    .select2-container--bootstrap-5 .select2-search--dropdown .select2-search__field {
        border: 1px solid #ced4da;
        border-radius: 4px;
        padding: 6px 12px;
    }
    
    .select2-container--bootstrap-5 .select2-results__option {
        padding: 6px 12px;
    }
    
    .select2-container--bootstrap-5 .select2-results__option--highlighted {
        background-color: #007bff;
        color: #fff;
    }
    
    .select2-container--bootstrap-5 .select2-selection__clear {
        margin-right: 10px;
        font-size: 18px;
        line-height: 1;
    }
    
    /* Адаптивность */
    @media (max-width: 768px) {
        .tasks-index {
            padding: 10px;
        }
        
        .kv-grid-table th,
        .kv-grid-table td {
            padding: 8px 4px !important;
            font-size: 11px;
        }
        
        .kv-grid-table td[data-col-seq=\"6\"] {
            max-width: 120px;
            font-size: 10px;
            padding: 6px 4px !important;
        }
        
        .form-control {
            font-size: 11px;
            padding: 4px 6px;
        }
        
        .attachments-container {
            gap: 3px;
        }
        
        .attachment-link {
            padding: 3px 5px;
            font-size: 12px;
        }
        
        .preview-modal .modal-dialog {
            max-width: 95vw;
            max-height: 95vh;
        }
    }
");

// JavaScript для инлайн-редактирования
$this->registerJs("
    // Изменение статуса с индикацией сохранения
    $(document).on('change', '.status-change', function() {
        var element = $(this);
        var taskId = element.data('task-id');
        var statusId = element.val();
        var originalValue = element.data('original-value');
        
        // Показываем индикатор загрузки
        element.prop('disabled', true).addClass('loading');
        
        $.post('" . Url::to(['tasks/change-status', 'id' => '']) . "' + taskId, {
            status_id: statusId,
            _csrf: '" . Yii::$app->request->csrfToken . "'
        }, function(data) {
            element.prop('disabled', false).removeClass('loading');
            
            if (data.success) {
                // Показываем уведомление об успешном сохранении
                showNotification('Статус заявки #' + taskId + ' обновлен', 'success');
                element.data('original-value', statusId);
            } else {
                // Возвращаем предыдущее значение при ошибке
                element.val(originalValue);
                showNotification('Ошибка: ' + (data.message || 'Не удалось сохранить статус'), 'error');
            }
        }).fail(function(xhr, status, error) {
            element.prop('disabled', false).removeClass('loading');
            element.val(originalValue);
            console.log('AJAX Error:', status, error);
            console.log('Response:', xhr.responseText);
            showNotification('Ошибка соединения с сервером: ' + error, 'error');
        });
    });
    
    // Назначение исполнителя с индикацией сохранения
    $(document).on('change', '.executor-change', function() {
        var element = $(this);
        var taskId = element.data('task-id');
        var executorId = element.val();
        var originalValue = element.data('original-value');
        
        // Показываем индикатор загрузки
        element.prop('disabled', true).addClass('loading');
        
        $.post('" . Url::to(['tasks/assign-executor', 'id' => '']) . "' + taskId, {
            executor_id: executorId,
            _csrf: '" . Yii::$app->request->csrfToken . "'
        }, function(data) {
            element.prop('disabled', false).removeClass('loading');
            
            if (data.success) {
                // Показываем уведомление об успешном сохранении
                var executorName = executorId ? element.find('option:selected').text() : 'Не назначен';
                showNotification('Исполнитель заявки #' + taskId + ' изменен на: ' + executorName, 'success');
                element.data('original-value', executorId);
            } else {
                // Возвращаем предыдущее значение при ошибке
                element.val(originalValue);
                showNotification('Ошибка: ' + (data.message || 'Не удалось назначить исполнителя'), 'error');
            }
        }).fail(function(xhr, status, error) {
            element.prop('disabled', false).removeClass('loading');
            element.val(originalValue);
            console.log('AJAX Error:', status, error);
            console.log('Response:', xhr.responseText);
            showNotification('Ошибка соединения с сервером: ' + error, 'error');
        });
    });
    
    // Редактирование комментария с автосохранением
    var commentTimeout = {};
    $(document).on('input', '.comment-edit', function() {
        var element = $(this);
        var taskId = element.data('task-id');
        var comment = element.val();
        var originalValue = element.data('original-value');
        
        // Показываем индикатор редактирования
        element.addClass('editing');
        
        // Очищаем предыдущий таймер для этого поля
        clearTimeout(commentTimeout[taskId]);
        
        // Устанавливаем новый таймер
        commentTimeout[taskId] = setTimeout(function() {
            // Показываем индикатор сохранения
            element.addClass('saving');
            
            $.post('" . Url::to(['tasks/update-comment', 'id' => '']) . "' + taskId, {
                comment: comment,
                _csrf: '" . Yii::$app->request->csrfToken . "'
            }, function(data) {
                element.removeClass('saving editing');
                
                if (data.success) {
                    // Показываем уведомление об успешном сохранении
                    showNotification('Комментарий к заявке #' + taskId + ' сохранен', 'success');
                    element.data('original-value', comment);
                } else {
                    // Возвращаем предыдущее значение при ошибке
                    element.val(originalValue);
                    showNotification('Ошибка: ' + (data.message || 'Не удалось сохранить комментарий'), 'error');
                }
            }).fail(function(xhr, status, error) {
                element.removeClass('saving editing');
                element.val(originalValue);
                console.log('AJAX Error:', status, error);
                console.log('Response:', xhr.responseText);
                showNotification('Ошибка соединения с сервером: ' + error, 'error');
            });
        }, 2000); // Увеличиваем время до 2 секунд
    });
    
    // Сохранение при потере фокуса
    $(document).on('blur', '.comment-edit', function() {
        var element = $(this);
        var taskId = element.data('task-id');
        
        // Если есть активный таймер, сохраняем немедленно
        if (commentTimeout[taskId]) {
            clearTimeout(commentTimeout[taskId]);
            commentTimeout[taskId] = setTimeout(function() {
                element.trigger('input');
            }, 100);
        }
    });
    
    // Функция выбора всех элементов
    function selectAll() {
        $('.kv-grid-checkbox').prop('checked', true);
    }
    
    // Функция скачивания выбранных
    function downloadSelected() {
        var selected = [];
        $('.kv-grid-checkbox:checked').each(function() {
            selected.push($(this).val());
        });
        
        if (selected.length === 0) {
            alert('Выберите заявки для скачивания');
            return;
        }
        
        // Здесь можно добавить логику скачивания
        alert('Скачивание ' + selected.length + ' заявок');
    }
    
    // Инициализация оригинальных значений при загрузке страницы
    $(document).ready(function() {
        // Предотвращаем автоматическую инициализацию Bootstrap для модальных окон
        // которые будут управляться программно
        var modalEl = document.getElementById('createTaskModal');
        if (modalEl && modalEl.hasAttribute('data-bs-toggle')) {
            modalEl.removeAttribute('data-bs-toggle');
        }
        
        // Сохраняем оригинальные значения для всех редактируемых полей
        $('.status-change').each(function() {
            $(this).data('original-value', $(this).val());
        });
        
        $('.executor-change').each(function() {
            $(this).data('original-value', $(this).val());
        });
        
        $('.comment-edit').each(function() {
            $(this).data('original-value', $(this).val());
        });
    });
    
    // Функция показа уведомлений
    function showNotification(message, type) {
        var alertClass = type === 'success' ? 'alert-success' : 'alert-danger';
        var icon = type === 'success' ? 'glyphicon-ok' : 'glyphicon-warning-sign';
        var notification = $('<div class=\"alert ' + alertClass + ' alert-dismissible\" style=\"position: fixed; top: 20px; right: 20px; z-index: 9999; min-width: 300px; box-shadow: 0 4px 8px rgba(0,0,0,0.2);\">' +
            '<button type=\"button\" class=\"close\" data-dismiss=\"alert\">&times;</button>' +
            '<i class=\"glyphicon ' + icon + '\"></i> ' + message +
            '</div>');
        
        $('body').append(notification);
        
        setTimeout(function() {
            notification.fadeOut(500, function() {
                $(this).remove();
            });
        }, 4000);
    }
    
    // Переменная для хранения экземпляра модального окна
    var createTaskModalInstance = null;
    
    // Функция загрузки формы создания заявки через AJAX
    function loadCreateTaskForm() {
        $.ajax({
            url: '" . Url::to(['tasks/create']) . "',
            type: 'GET',
            success: function(data) {
                // Извлекаем только содержимое формы из ответа
                var formContent = $(data).find('.tasks-form').html();
                if (!formContent) {
                    formContent = $(data).find('form').html();
                }
                if (formContent) {
                    $('#createTaskFormContent').html(formContent);
                } else {
                    $('#createTaskFormContent').html('<div class=\"alert alert-danger\">Не удалось загрузить форму</div>');
                }
            },
            error: function() {
                $('#createTaskFormContent').html('<div class=\"alert alert-danger\">Ошибка загрузки формы</div>');
            }
        });
    }
    
    // Функция программного открытия модального окна
    function openCreateTaskModal() {
        // Загружаем форму
        loadCreateTaskForm();
        
        // Получаем или создаем экземпляр модального окна
        var modalElement = document.getElementById('createTaskModal');
        if (modalElement) {
            if (!createTaskModalInstance) {
                // Создаем экземпляр только если его еще нет
                createTaskModalInstance = new bootstrap.Modal(modalElement, {
                    backdrop: true,
                    keyboard: true
                });
            }
            // Показываем модальное окно
            createTaskModalInstance.show();
        }
    }
    
    // Обработчик для большой кнопки создания задачи
    $(document).on('click', '#createTaskBtn', function(e) {
        e.preventDefault();
        openCreateTaskModal();
    });
    
    // Обработка отправки формы в модальном окне
    $(document).on('submit', '#createTaskFormContent form', function(e) {
        e.preventDefault();
        
        var form = $(this);
        var formData = new FormData(form[0]);
        
        $.ajax({
            url: form.attr('action') || '" . Url::to(['tasks/create']) . "',
            type: 'POST',
            data: formData,
            processData: false,
            contentType: false,
            success: function(data, textStatus, xhr) {
                // Проверяем, есть ли ошибки валидации
                var hasErrors = $(data).find('.has-error').length > 0 || 
                                $(data).find('.field-task-description .help-block').length > 0;
                
                if (hasErrors) {
                    // Есть ошибки валидации, обновляем только форму
                    var formContent = $(data).find('.tasks-form').html();
                    if (!formContent) {
                        formContent = $(data).find('form').html();
                    }
                    if (formContent) {
                        $('#createTaskFormContent').html(formContent);
                    }
                } else {
                    // Успешно - показываем уведомление и перенаправляем
                    if (createTaskModalInstance) {
                        createTaskModalInstance.hide();
                    }
                    showNotification('Заявка успешно создана', 'success');
                    
                    // Перенаправляем на tasks/index
                    setTimeout(function() {
                        window.location.href = '" . Url::to(['tasks/index']) . "';
                    }, 800);
                }
            },
            error: function(xhr, status, error) {
                console.log('Error:', error);
                showNotification('Ошибка при создании заявки: ' + error, 'error');
            }
        });
    });
    
    // Обработка закрытия модального окна
    $('#createTaskModal').on('hidden.bs.modal', function() {
        $('#createTaskFormContent').html('<div class=\"text-center\"><i class=\"glyphicon glyphicon-refresh glyphicon-spin\"></i> Загрузка...</div>');
    });
    
    // Переменная для хранения экземпляра модального окна предпросмотра
    var previewModalInstance = null;
    
    // Обработка кликов по вложениям
    $(document).on('click', '.preview-link', function(e) {
        e.preventDefault();
        e.stopPropagation();
        
        var attachmentId = $(this).data('attachment-id');
        var filename = $(this).data('filename');
        var previewUrl = $(this).data('preview-url');
        var downloadUrl = '" . Url::to(['tasks/download', 'id' => '']) . "' + attachmentId;
        
        // Обновляем заголовок модального окна
        $('#previewModal .modal-title').text('Предпросмотр: ' + filename);
        
        // Обновляем ссылку на скачивание
        $('#downloadBtn').attr('href', downloadUrl);
        
        // Определяем тип файла
        var extension = filename.split('.').pop().toLowerCase();
        var previewContent = '';
        
        if (extension === 'pdf') {
            // Для PDF используем iframe
            previewContent = '<iframe src=\"' + previewUrl + '\" style=\"width: 100%; height: 80vh; border: none;\"></iframe>';
        } else if (['png', 'jpg', 'jpeg', 'gif', 'bmp', 'svg'].includes(extension)) {
            // Для изображений используем img
            previewContent = '<img src=\"' + previewUrl + '\" alt=\"' + filename + '\" style=\"max-width: 100%; max-height: 80vh; object-fit: contain;\">';
        } else {
            // Для остальных файлов показываем сообщение
            previewContent = '<div class=\"text-center\" style=\"padding: 50px; color: #fff;\"><i class=\"glyphicon glyphicon-file\" style=\"font-size: 48px; margin-bottom: 20px;\"></i><br><p>Предпросмотр недоступен для данного типа файла</p><p><a href=\"' + downloadUrl + '\" class=\"btn btn-primary\">Скачать файл</a></p></div>';
        }
        
        // Загружаем контент в модальное окно
        $('#previewContent').html(previewContent);
        
        // Получаем или создаем экземпляр модального окна
        var modalElement = document.getElementById('previewModal');
        if (modalElement) {
            if (!previewModalInstance) {
                // Создаем экземпляр только если его еще нет
                previewModalInstance = new bootstrap.Modal(modalElement, {
                    backdrop: true,
                    keyboard: true
                });
            }
            // Показываем модальное окно
            previewModalInstance.show();
        }
        
        return false;
    });
    
    // Обработка кликов по ссылкам скачивания
    $(document).on('click', '.download-link', function(e) {
        // Позволяем браузеру обработать скачивание
        // Никаких дополнительных действий не требуется
    });
    
    // Экземпляр модального окна для управления ТС
    var equipmentManagementModalInstance = null;
    
    // Функция открытия модального окна управления ТС
    function openEquipmentManagementModal() {
        var modalElement = document.getElementById('equipmentManagementModal');
        if (!modalElement) {
            // Создаем модальное окно динамически, если его нет
            var modalHtml = '<div class=\"modal fade\" id=\"equipmentManagementModal\" tabindex=\"-1\" role=\"dialog\">' +
                '<div class=\"modal-dialog modal-lg\" role=\"document\">' +
                '<div class=\"modal-content\">' +
                '<div class=\"modal-header\">' +
                '<h4 class=\"modal-title\"><i class=\"glyphicon glyphicon-hdd\"></i> Управление техническими средствами</h4>' +
                '<button type=\"button\" class=\"btn-close\" data-bs-dismiss=\"modal\" aria-label=\"Close\"></button>' +
                '</div>' +
                '<div class=\"modal-body\" id=\"equipmentManagementModalBody\">' +
                '<div class=\"text-center\"><i class=\"glyphicon glyphicon-refresh glyphicon-spin\"></i><p>Загрузка...</p></div>' +
                '</div>' +
                '</div>' +
                '</div>' +
                '</div>';
            $('body').append(modalHtml);
            modalElement = document.getElementById('equipmentManagementModal');
        }
        
        // Создаем или получаем экземпляр модального окна
        if (!equipmentManagementModalInstance) {
            equipmentManagementModalInstance = new bootstrap.Modal(modalElement, {
                backdrop: true,
                keyboard: true
            });
        }
        
        // Показываем модальное окно
        equipmentManagementModalInstance.show();
        
        // Загружаем список пользователей для выбора
        $.ajax({
            url: '" . Url::to(['users/index']) . "',
            type: 'GET',
            success: function(data) {
                // Извлекаем только содержимое контейнера с пользователями
                var content = $(data).find('.users-index').html();
                if (!content) {
                    content = '<div class=\"alert alert-info\">Перейдите в раздел <a href=\"" . Url::to(['users/index']) . "\" target=\"_blank\">Пользователи</a> для управления техническими средствами.</div>';
                }
                $('#equipmentManagementModalBody').html(content);
            },
            error: function() {
                $('#equipmentManagementModalBody').html('<div class=\"alert alert-danger\">Ошибка загрузки данных. <a href=\"" . Url::to(['users/index']) . "\" target=\"_blank\">Открыть в новой вкладке</a></div>');
            }
        });
    }
    
    // Очистка при закрытии модального окна
    $(document).on('hidden.bs.modal', '#equipmentManagementModal', function() {
        $('#equipmentManagementModalBody').html('<div class=\"text-center\"><i class=\"glyphicon glyphicon-refresh glyphicon-spin\"></i><p>Загрузка...</p></div>');
    });
    
    // Экспортируем функцию глобально
    window.openEquipmentManagementModal = openEquipmentManagementModal;
");
?>
