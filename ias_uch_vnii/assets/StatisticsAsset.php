<?php
/**
 * Asset bundle для страницы статистики задач (диаграммы Highcharts + таблицы AG Grid).
 */

namespace app\assets;

use yii\web\AssetBundle;

class StatisticsAsset extends AssetBundle
{
    public $basePath = '@webroot';
    public $baseUrl = '@web';

    public $css = [
        'css/tasks/page.css',
        'css/tasks/statistics.css',
        'ag-grid-community/styles/ag-theme-quartz.css',
        'css/tasks/ag-grid.css',
    ];

    public $js = [
        'ag-grid-community/dist/ag-grid-community.min.js',
        'js/ag-grid-theme-config.js',
        'js/tasks/statistics-ag-grid.js',
    ];

    public $depends = [
        'app\assets\LayoutAsset',
        'yii\web\YiiAsset',
        'yii\bootstrap5\BootstrapAsset',
    ];

    public $jsOptions = [
        'position' => \yii\web\View::POS_END,
    ];

    public $appendTimestamp = true;
}
