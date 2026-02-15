<?php

use yii\helpers\Html;
use yii\helpers\Url;
use miloschuman\highcharts\Highcharts;
use app\assets\StatisticsAsset;

/* @var $this yii\web\View */
/* @var $userChartData array */
/* @var $executorChartData array */

// Подключаем assets для страницы статистики
StatisticsAsset::register($this);

$this->title = 'Статистика заявок';
$this->params['breadcrumbs'][] = $this->title;

// Статистика по статусам заявок
$statusStats = \app\models\entities\Tasks::find()
    ->select(['status_id', 'COUNT(*) as count'])
    ->groupBy('status_id')
    ->asArray()
    ->all();

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

// Для подзаголовка диаграммы «Завершенные заявки по исполнителям»
$totalCompletedTasks = array_sum(array_column($executorChartData, 'y'));

?>

<div class="tasks-statistics">
    <div class="row">
        <div class="col-md-12">
            <div class="page-header">
                <h1><?= Html::encode($this->title) ?></h1>
                <p class="lead">Аналитика и статистика по заявкам системы Help Desk</p>
            </div>
        </div>
    </div>

    <!-- Диаграммы Highcharts -->
    <div class="row">
        <!-- Диаграмма количества заявок по пользователям -->
        <div class="col-md-12">
            <div class="chart-panel">
                <div class="chart-header">
                    <h3 class="chart-title">
                        <i class="glyphicon glyphicon-user"></i> Количество заявок по пользователям
                    </h3>
                    <div class="chart-actions">
                        <?= Html::a('<i class="glyphicon glyphicon-download"></i> Excel', ['tasks/export-user-stats'], [
                            'class' => 'btn btn-success btn-sm',
                            'target' => '_blank'
                        ]) ?>
                        <?= Html::a('<i class="glyphicon glyphicon-file"></i> PDF', ['tasks/export-user-stats-pdf'], [
                            'class' => 'btn btn-danger btn-sm',
                            'target' => '_blank'
                        ]) ?>
                        <?= Html::a('<i class="glyphicon glyphicon-list-alt"></i> HTML', ['tasks/export-user-stats-html'], [
                            'class' => 'btn btn-info btn-sm',
                            'target' => '_blank'
                        ]) ?>
                    </div>
                </div>
                <div class="chart-body">
                    <?php
                    echo Highcharts::widget([
                        'options' => [
                            'chart' => [
                                'type' => 'bar',
                                'backgroundColor' => '#ffffff',
                                'borderRadius' => 8,
                                'height' => 500,
                                'style' => [
                                    'fontFamily' => 'Arial, sans-serif'
                                ]
                            ],
                            'title' => [
                                'text' => 'Распределение заявок по авторам',
                                'style' => [
                                    'fontSize' => '20px',
                                    'fontWeight' => 'bold',
                                    'color' => '#333333'
                                ]
                            ],
                            'subtitle' => [
                                'text' => 'Общее количество заявок: ' . $totalTasks,
                                'style' => [
                                    'fontSize' => '14px',
                                    'color' => '#666666'
                                ]
                            ],
                            'xAxis' => [
                                'categories' => array_column($userChartData, 'name'),
                                'title' => [
                                    'text' => 'Пользователи',
                                    'style' => [
                                        'fontSize' => '14px',
                                        'fontWeight' => 'bold'
                                    ]
                                ],
                                'labels' => [
                                    'rotation' => -45,
                                    'style' => [
                                        'fontSize' => '12px'
                                    ]
                                ]
                            ],
                            'yAxis' => [
                                'title' => [
                                    'text' => 'Количество заявок',
                                    'style' => [
                                        'fontSize' => '14px',
                                        'fontWeight' => 'bold'
                                    ]
                                ],
                                'min' => 0,
                                'allowDecimals' => false,
                                'gridLineColor' => '#e0e0e0'
                            ],
                            'series' => [
                                [
                                    'name' => 'Количество заявок',
                                    'data' => array_column($userChartData, 'y'),
                                    'color' => [
                                        'linearGradient' => [
                                            'x1' => 0,
                                            'y1' => 0,
                                            'x2' => 0,
                                            'y2' => 1
                                        ],
                                        'stops' => [
                                            [0, '#007bff'],
                                            [1, '#0056b3']
                                        ]
                                    ],
                                    'dataLabels' => [
                                        'enabled' => true,
                                        'style' => [
                                            'fontWeight' => 'bold',
                                            'color' => '#333333',
                                            'fontSize' => '12px'
                                        ],
                                        'formatter' => new \yii\web\JsExpression("function() { return this.y; }")
                                    ],
                                    'tooltip' => [
                                        'pointFormat' => '<b>{point.y}</b> заявок ({point.percentage:.1f}%)'
                                    ]
                                ]
                            ],
                            'plotOptions' => [
                                'bar' => [
                                    'pointPadding' => 0.1,
                                    'borderWidth' => 0,
                                    'animation' => [
                                        'duration' => 1500
                                    ],
                                    'dataLabels' => [
                                        'enabled' => true
                                    ]
                                ]
                            ],
                            'credits' => [
                                'enabled' => false
                            ],
                            'legend' => [
                                'enabled' => false
                            ]
                        ]
                    ]);
                    ?>
                </div>
                
                <!-- Таблица данных под диаграммой (AG Grid) -->
                <div class="chart-table">
                    <h4><i class="glyphicon glyphicon-list"></i> Детальные данные</h4>
                    <div
                        id="agGridStatisticsUserContainer"
                        class="ag-theme-quartz"
                        style="width: 100%; height: 320px; min-height: 200px;"
                        data-url="<?= Html::encode(Url::to(['tasks/statistics-get-grid-data', 'type' => 'user'])) ?>"
                    ></div>
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <!-- Диаграмма завершенных заявок по исполнителям -->
        <div class="col-md-12">
            <div class="chart-panel">
                <div class="chart-header">
                    <h3 class="chart-title">
                        <i class="glyphicon glyphicon-wrench"></i> Завершенные заявки по исполнителям
                    </h3>
                    <div class="chart-actions">
                        <?= Html::a('<i class="glyphicon glyphicon-download"></i> Excel', ['tasks/export-executor-stats'], [
                            'class' => 'btn btn-success btn-sm',
                            'target' => '_blank'
                        ]) ?>
                        <?= Html::a('<i class="glyphicon glyphicon-file"></i> PDF', ['tasks/export-executor-stats-pdf'], [
                            'class' => 'btn btn-danger btn-sm',
                            'target' => '_blank'
                        ]) ?>
                        <?= Html::a('<i class="glyphicon glyphicon-list-alt"></i> HTML', ['tasks/export-executor-stats-html'], [
                            'class' => 'btn btn-info btn-sm',
                            'target' => '_blank'
                        ]) ?>
                    </div>
                </div>
                <div class="chart-body">
                    <?php
                    echo Highcharts::widget([
                        'options' => [
                            'chart' => [
                                'type' => 'bar',
                                'backgroundColor' => '#ffffff',
                                'borderRadius' => 8,
                                'height' => 500,
                                'style' => [
                                    'fontFamily' => 'Arial, sans-serif'
                                ]
                            ],
                            'title' => [
                                'text' => 'Распределение завершенных заявок по исполнителям',
                                'style' => [
                                    'fontSize' => '20px',
                                    'fontWeight' => 'bold',
                                    'color' => '#333333'
                                ]
                            ],
                            'subtitle' => [
                                'text' => 'Общее количество завершенных заявок: ' . $totalCompletedTasks,
                                'style' => [
                                    'fontSize' => '14px',
                                    'color' => '#666666'
                                ]
                            ],
                            'xAxis' => [
                                'categories' => array_column($executorChartData, 'name'),
                                'title' => [
                                    'text' => 'Исполнители',
                                    'style' => [
                                        'fontSize' => '14px',
                                        'fontWeight' => 'bold'
                                    ]
                                ],
                                'labels' => [
                                    'rotation' => -45,
                                    'style' => [
                                        'fontSize' => '12px'
                                    ]
                                ]
                            ],
                            'yAxis' => [
                                'title' => [
                                    'text' => 'Количество завершенных заявок',
                                    'style' => [
                                        'fontSize' => '14px',
                                        'fontWeight' => 'bold'
                                    ]
                                ],
                                'min' => 0,
                                'allowDecimals' => false,
                                'gridLineColor' => '#e0e0e0'
                            ],
                            'series' => [
                                [
                                    'name' => 'Завершенные заявки',
                                    'data' => array_column($executorChartData, 'y'),
                                    'color' => [
                                        'linearGradient' => [
                                            'x1' => 0,
                                            'y1' => 0,
                                            'x2' => 0,
                                            'y2' => 1
                                        ],
                                        'stops' => [
                                            [0, '#28a745'],
                                            [1, '#1e7e34']
                                        ]
                                    ],
                                    'dataLabels' => [
                                        'enabled' => true,
                                        'style' => [
                                            'fontWeight' => 'bold',
                                            'color' => '#333333',
                                            'fontSize' => '12px'
                                        ],
                                        'formatter' => new \yii\web\JsExpression("function() { return this.y; }")
                                    ],
                                    'tooltip' => [
                                        'pointFormat' => '<b>{point.y}</b> завершенных заявок ({point.percentage:.1f}%)'
                                    ]
                                ]
                            ],
                            'plotOptions' => [
                                'bar' => [
                                    'pointPadding' => 0.1,
                                    'borderWidth' => 0,
                                    'animation' => [
                                        'duration' => 1500
                                    ],
                                    'dataLabels' => [
                                        'enabled' => true
                                    ]
                                ]
                            ],
                            'credits' => [
                                'enabled' => false
                            ],
                            'legend' => [
                                'enabled' => false
                            ]
                        ]
                    ]);
                    ?>
                </div>
                
                <!-- Таблица данных под диаграммой (AG Grid) -->
                <div class="chart-table">
                    <h4><i class="glyphicon glyphicon-list"></i> Детальные данные</h4>
                    <div
                        id="agGridStatisticsExecutorContainer"
                        class="ag-theme-quartz"
                        style="width: 100%; height: 320px; min-height: 200px;"
                        data-url="<?= Html::encode(Url::to(['tasks/statistics-get-grid-data', 'type' => 'executor'])) ?>"
                    ></div>
                </div>
            </div>
        </div>
    </div>

    <!-- Кнопки действий -->
    <div class="row">
        <div class="col-md-12">
            <div class="text-center">
                <?= Html::a('<i class="glyphicon glyphicon-arrow-left"></i> Назад к заявкам', ['tasks/index'], [
                    'class' => 'btn btn-primary btn-lg'
                ]) ?>
                <?= Html::a('<i class="glyphicon glyphicon-refresh"></i> Обновить', ['tasks/statistics'], [
                    'class' => 'btn btn-default btn-lg'
                ]) ?>
            </div>
        </div>
    </div>
</div>

<?php
// CSS стили для страницы статистики
$this->registerCss("
    .tasks-statistics {
        padding: 20px;
        background: #f8f9fa;
        min-height: 100vh;
    }
    
    .page-header {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        padding: 30px;
        border-radius: 12px;
        margin-bottom: 30px;
        box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
    }
    
    .page-header h1 {
        margin: 0 0 10px 0;
        font-size: 2.5rem;
        font-weight: 300;
    }
    
    .page-header .lead {
        margin: 0;
        font-size: 1.1rem;
        opacity: 0.9;
    }
    
    .chart-panel {
        background: #fff;
        border-radius: 12px;
        box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        margin-bottom: 30px;
        overflow: hidden;
    }
    
    .chart-header {
        background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
        padding: 20px 30px;
        border-bottom: 2px solid #dee2e6;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    
    .chart-title {
        margin: 0;
        font-size: 1.4rem;
        font-weight: 600;
        color: #495057;
    }
    
    .chart-title i {
        margin-right: 10px;
        color: #007bff;
    }
    
    .chart-actions {
        display: flex;
        gap: 10px;
    }
    
    .chart-body {
        padding: 30px;
    }
    
    .chart-table {
        background: #f8f9fa;
        padding: 20px 30px;
        border-top: 1px solid #dee2e6;
    }
    
    .chart-table h4 {
        margin: 0 0 20px 0;
        font-size: 1.2rem;
        font-weight: 600;
        color: #495057;
    }
    
    .chart-table h4 i {
        margin-right: 8px;
        color: #28a745;
    }
    
    .table {
        margin-bottom: 0;
        background: #fff;
        border-radius: 8px;
        overflow: hidden;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }
    
    .table thead th {
        background: #495057;
        color: #fff;
        border: none;
        font-weight: 600;
        padding: 15px;
        text-align: center;
    }
    
    .table tbody td {
        padding: 15px;
        text-align: center;
        vertical-align: middle;
        border-color: #e9ecef;
    }
    
    .table tbody tr:hover {
        background-color: #f8f9fa;
    }
    
    .badge {
        font-size: 14px;
        padding: 8px 12px;
        border-radius: 20px;
    }
    
    .badge-primary {
        background-color: #007bff;
    }
    
    .badge-success {
        background-color: #28a745;
    }
    
    .progress {
        background-color: #e9ecef;
        border-radius: 10px;
        overflow: hidden;
    }
    
    .progress-bar {
        transition: width 0.6s ease;
        font-weight: 600;
        font-size: 12px;
        line-height: 20px;
    }
    
    /* Стили для Highcharts */
    .highcharts-container {
        border-radius: 8px;
        overflow: hidden;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }
    
    /* Адаптивность */
    @media (max-width: 768px) {
        .tasks-statistics {
            padding: 10px;
        }
        
        .page-header {
            padding: 20px;
        }
        
        .page-header h1 {
            font-size: 2rem;
        }
        
        .chart-header {
            flex-direction: column;
            gap: 15px;
            text-align: center;
        }
        
        .chart-body {
            padding: 15px;
        }
        
        .chart-table {
            padding: 15px;
        }
        
        .table thead th,
        .table tbody td {
            padding: 10px 8px;
            font-size: 12px;
        }
        
        .chart-title {
            font-size: 1.2rem;
        }
    }
    
    @media (max-width: 576px) {
        .page-header h1 {
            font-size: 1.5rem;
        }
        
        .chart-title {
            font-size: 1rem;
        }
        
        .table thead th,
        .table tbody td {
            padding: 8px 5px;
            font-size: 11px;
        }
    }
");
?>