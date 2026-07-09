<?php

namespace app\assets;

use yii\web\AssetBundle;

/**
 * Asset для страницы «ПО и лицензии» (AG Grid).
 */
class SoftwareGridAsset extends AssetBundle
{
    public $basePath = '@webroot';
    public $baseUrl = '@web';

    public $css = [
        'ag-grid-community/styles/ag-theme-quartz.css',
        'css/ag-grid-filter.css',
        'css/tasks/ag-grid.css',
        'css/arm/index.css',
        'css/arm/form.css',
        'css/arm/view.css',
        'css/section-grid-page.css',
        'css/software/page.css',
    ];

    public $js = [
        'ag-grid-community/dist/ag-grid-community.min.js',
        'js/ag-grid-wrap-utils.js',
        'js/ag-grid-filter-config.js',
        'js/ag-grid-theme-config.js',
        'js/section-grid-utils.js',
        'js/software/ag-grid.js',
        'js/software/license-attachments.js',
        'js/software/license-form-modal.js',
    ];

    public $depends = [
        'yii\web\YiiAsset',
        'yii\bootstrap5\BootstrapAsset',
        'yii\bootstrap5\BootstrapPluginAsset',
        'yii\web\JqueryAsset',
    ];

    public $jsOptions = [
        'position' => \yii\web\View::POS_END,
    ];

    public $appendTimestamp = true;
}
