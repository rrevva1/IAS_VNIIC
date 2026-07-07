<?php

namespace app\assets;

use yii\web\AssetBundle;

/**
 * Справочники: AG Grid + модальные формы.
 */
class ReferencesGridAsset extends AssetBundle
{
    public $basePath = '@webroot';
    public $baseUrl = '@web';

    public $css = [
        'ag-grid-community/styles/ag-theme-quartz.css',
        'css/ag-grid-filter.css',
        'css/tasks/ag-grid.css',
        'css/tasks/form-modal.css',
    ];

    public $js = [
        'ag-grid-community/dist/ag-grid-community.min.js',
        'js/ag-grid-wrap-utils.js',
        'js/ag-grid-filter-config.js',
        'js/ag-grid-theme-config.js',
        'js/section-grid-utils.js',
        'js/references/ag-grid.js',
        'js/references/references-form-modal.js',
    ];

    public $depends = [
        'app\assets\ReferencesPageAsset',
        'yii\web\JqueryAsset',
    ];

    public $jsOptions = [
        'position' => \yii\web\View::POS_END,
    ];

    public $appendTimestamp = true;
}
