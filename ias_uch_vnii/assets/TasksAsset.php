<?php

namespace app\assets;

use yii\web\AssetBundle;

/**
 * Asset bundle для страниц задач
 * Подключает стили и JavaScript для просмотра, создания и редактирования задач
 * 
 * @since 1.0
 */
class TasksAsset extends AssetBundle
{
    public $basePath = '@webroot';
    public $baseUrl = '@web';
    
    public $css = [
        'css/tasks/view.css',
        'css/tasks/form.css',
    ];
    
    public $js = [
        'js/tasks/view.js',
        'js/tasks/form.js',
    ];
    
    public $depends = [
        'yii\web\YiiAsset',
        'yii\bootstrap5\BootstrapAsset',
        'yii\web\JqueryAsset',
    ];
}
