<?php

namespace app\assets;

use yii\web\AssetBundle;

/**
 * Asset для страницы «Учет ТС» (AG Grid).
 * Тема и библиотека — те же, что для заявок; свой скрипт инициализации грида ТС.
 */
class ArmGridAsset extends AssetBundle
{
    public $basePath = '@webroot';
    public $baseUrl = '@web';

    public $css = [
        'css/common/typography.css',
        'ag-grid-community/styles/ag-theme-quartz.css',
        'css/ag-grid-filter.css',
        'css/tasks/ag-grid.css',
        'css/arm/index.css',
        'css/arm/form.css',
        'css/arm/view.css',
    ];

    public $js = [
        'ag-grid-community/dist/ag-grid-community.min.js',
        'js/ag-grid-wrap-utils.js',
        'js/ag-grid-filter-config.js',
        'js/ag-grid-theme-config.js',
        'js/arm/ag-grid.js',
        'js/arm/page-ui.js',
        'js/arm/form-dynamic.js',
        'js/arm/warranty-preview.js',
        'js/arm/arm-create.js',
        'js/arm/arm-attachments.js',
        'js/arm/arm-view.js',
    ];

    public $depends = [
        'yii\web\YiiAsset',
        'yii\bootstrap5\BootstrapAsset',
        'yii\bootstrap5\BootstrapPluginAsset',
        'yii\web\JqueryAsset',
        UserSelectAsset::class,
    ];

    public $jsOptions = [
        'position' => \yii\web\View::POS_END,
    ];

    public $appendTimestamp = true;
}
