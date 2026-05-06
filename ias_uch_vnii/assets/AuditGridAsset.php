<?php

namespace app\assets;

use yii\web\AssetBundle;

/**
 * Asset для страницы «Журнал аудита» (AG Grid).
 * Тема и библиотека — те же, что для заявок и учёта ТС.
 */
class AuditGridAsset extends AssetBundle
{
    public $basePath = '@webroot';
    public $baseUrl = '@web';

    public $css = [
        'ag-grid-community/styles/ag-theme-quartz.css',
        'css/tasks/ag-grid.css',
    ];

    public $js = [
        'ag-grid-community/dist/ag-grid-community.min.js',
        'js/audit/ag-grid.js',
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
