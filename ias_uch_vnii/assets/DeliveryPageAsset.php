<?php

namespace app\assets;

use yii\web\AssetBundle;

/**
 * Страница «Поставки» — оформление как «Учёт ТС», AG Grid + модальные окна.
 */
class DeliveryPageAsset extends AssetBundle
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
        'css/delivery/page.css',
    ];

    public $js = [
        'ag-grid-community/dist/ag-grid-community.min.js',
        'js/ag-grid-wrap-utils.js',
        'js/ag-grid-filter-config.js',
        'js/ag-grid-theme-config.js',
        'js/section-grid-utils.js',
        'js/delivery/ag-grid.js',
        'js/delivery/page-ui.js',
        'js/delivery/delivery-card.js',
        'js/delivery/delivery-attachments.js',
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
