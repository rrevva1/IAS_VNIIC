<?php

namespace app\assets;

use yii\web\AssetBundle;

/**
 * Asset bundle для страницы списка задач
 * Подключает стили и JavaScript для отображения списка задач
 * 
 * @since 1.0
 */
class TasksIndexAsset extends AssetBundle
{
    public $basePath = '@webroot';
    public $baseUrl = '@web';
    
    public $css = [
        'css/tasks/index.css',
    ];
    
    public $js = [
        'js/tasks/index.js',
    ];
    
    public $depends = [
        'yii\web\YiiAsset',
        'yii\bootstrap5\BootstrapAsset',
        'yii\web\JqueryAsset',
    ];
}
