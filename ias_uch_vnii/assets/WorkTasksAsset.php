<?php

namespace app\assets;

use yii\web\AssetBundle;

class WorkTasksAsset extends AssetBundle
{
    public $basePath = '@webroot';
    public $baseUrl = '@web';
    public $css = ['css/work-tasks/work-tasks.css'];
    public $js = [
        'js/work-tasks/work-tasks.js',
        'js/work-tasks/work-tasks-board.js',
        'js/work-tasks/work-tasks-create.js',
        'js/work-tasks/work-tasks-view.js',
    ];
    public $depends = [
        'yii\web\YiiAsset',
        'yii\bootstrap5\BootstrapAsset',
        'yii\bootstrap5\BootstrapPluginAsset',
    ];
}
