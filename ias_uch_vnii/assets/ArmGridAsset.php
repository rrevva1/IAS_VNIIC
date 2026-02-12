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
        'ag-grid-community/styles/ag-theme-quartz.css',
        'css/tasks/ag-grid.css',
    ];

    public $js = [
        'ag-grid-community/dist/ag-grid-community.min.js',
        'js/arm/ag-grid.js',
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
