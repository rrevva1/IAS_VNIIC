<?php

namespace app\assets;

use yii\web\AssetBundle;

/**
 * Справочники: обзор и общие стили раздела (как «Учёт ТС»).
 */
class ReferencesPageAsset extends AssetBundle
{
    public $basePath = '@webroot';
    public $baseUrl = '@web';

    public $css = [
        'css/common/typography.css',
        'css/arm/index.css',
        'css/site/section-page.css',
        'css/references/page.css',
    ];

    public $depends = [
        'yii\web\YiiAsset',
        'yii\bootstrap5\BootstrapAsset',
        'yii\bootstrap5\BootstrapPluginAsset',
    ];

    public $appendTimestamp = true;
}
