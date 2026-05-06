<?php

namespace app\assets;

use yii\web\AssetBundle;

/**
 * Asset bundle для AG Grid с темой Quartz
 * Подключает библиотеку AG Grid Community с темой Quartz и пользовательскими стилями
 * 
 * @since 1.0
 */
class AgGridAsset extends AssetBundle
{
    public $basePath = '@webroot';
    public $baseUrl = '@web';
    
    public $css = [
        'ag-grid-community/styles/ag-theme-quartz.css',
        'css/tasks/ag-grid.css',
    ];
    
    public $js = [
        'ag-grid-community/dist/ag-grid-community.min.js',
        'js/tasks/ag-grid.js',
    ];
    
    public $depends = [
        'yii\web\YiiAsset',
        'yii\bootstrap5\BootstrapAsset',
        'yii\bootstrap5\BootstrapPluginAsset',  // JavaScript для Bootstrap 5
        'yii\web\JqueryAsset',
    ];
    
    public $jsOptions = [
        'position' => \yii\web\View::POS_END,
    ];
    
    /** Добавляем timestamp для сброса кэша браузера */
    public $appendTimestamp = true;
}

