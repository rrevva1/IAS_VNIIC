<?php

namespace app\assets;

use yii\web\AssetBundle;

class UserEquipmentCardsGridAsset extends AssetBundle
{
    public $basePath = '@webroot';
    public $baseUrl = '@web';

    public $css = [
        'ag-grid-community/styles/ag-theme-quartz.css',
        'css/ag-grid-filter.css',
        'css/tasks/ag-grid.css',
        'css/arm/index.css',
        'css/arm/view.css',
        'css/user-equipment-cards/page.css',
    ];

    public $js = [
        'ag-grid-community/dist/ag-grid-community.min.js',
        'js/ag-grid-filter-config.js',
        'js/ag-grid-theme-config.js',
        'js/user-equipment-cards/user-equipment-modal.js',
        'js/arm/arm-view.js',
        'js/user-equipment-cards/ag-grid.js',
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
