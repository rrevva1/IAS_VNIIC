<?php
/**
 * Asset bundle для страниц сайта
 */

namespace app\assets;

use yii\web\AssetBundle;

class SiteAsset extends AssetBundle
{
    public $basePath = '@webroot';
    public $baseUrl = '@web';
    
    public $css = [
        'css/site/pages.css',
    ];
    
    public $js = [
        'js/site/pages.js',
    ];
    
    public $depends = [
        'app\assets\LayoutAsset',
    ];
}
