<?php

namespace app\assets;

use yii\web\AssetBundle;

/**
 * Статические разделы в едином каркасе с «Учёт ТС».
 */
class SectionPageAsset extends AssetBundle
{
    public $basePath = '@webroot';
    public $baseUrl = '@web';

    public $css = [
        'css/arm/index.css',
        'css/site/section-page.css',
    ];

    public $depends = [
        'yii\web\YiiAsset',
        'yii\bootstrap5\BootstrapAsset',
        'yii\bootstrap5\BootstrapPluginAsset',
    ];

    public $appendTimestamp = true;
}
