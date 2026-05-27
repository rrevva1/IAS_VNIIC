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
        'css/ag-grid-filter.css',
        'css/tasks/ag-grid.css',
        'css/tasks/page.css',
        'css/tasks/form-modal.css',
    ];
    
    public $js = [
        'ag-grid-community/dist/ag-grid-community.min.js',
        'js/ag-grid-wrap-utils.js',
        'js/ag-grid-filter-config.js',
        'js/ag-grid-theme-config.js',
        'js/tasks/page-ui.js',
        'js/tasks/form-modal.js',
        'js/tasks/ag-grid.js',
    ];
    
    public $depends = [
        'yii\web\YiiAsset',
        'yii\bootstrap5\BootstrapAsset',
        'yii\bootstrap5\BootstrapPluginAsset',  // JavaScript для Bootstrap 5
        'yii\web\JqueryAsset',
        UserSelectAsset::class,
    ];
    
    public $jsOptions = [
        'position' => \yii\web\View::POS_END,
    ];
    
    /** Добавляем timestamp для сброса кэша браузера */
    public $appendTimestamp = true;
}

