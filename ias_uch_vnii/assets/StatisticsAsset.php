<?php
/**
 * Asset bundle для страницы статистики задач
 */

namespace app\assets;

use yii\web\AssetBundle;

class StatisticsAsset extends AssetBundle
{
    public $basePath = '@webroot';
    public $baseUrl = '@web';
    
    public $css = [
        'css/tasks/statistics.css',
    ];
    
    public $js = [
        'js/tasks/statistics.js',
    ];
    
    public $depends = [
        'app\assets\LayoutAsset',
        
    ];
}
