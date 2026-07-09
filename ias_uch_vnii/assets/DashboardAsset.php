<?php

namespace app\assets;

use yii\web\AssetBundle;

/**
 * Главная страница «Требует внимания».
 */
class DashboardAsset extends AssetBundle
{
    public $basePath = '@webroot';
    public $baseUrl = '@web';

    public $css = [
        'css/site/dashboard.css',
    ];

    public $js = [
        'js/site/dashboard.js',
    ];

    public $depends = [
        'app\assets\LayoutAsset',
        'app\assets\SectionPageAsset',
    ];

    public $appendTimestamp = true;
}
