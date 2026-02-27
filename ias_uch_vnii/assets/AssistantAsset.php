<?php
/**
 * Asset bundle для панели ИИ-помощника (диалоговое окно)
 */

namespace app\assets;

use yii\web\AssetBundle;

class AssistantAsset extends AssetBundle
{
    public $basePath = '@webroot';
    public $baseUrl = '@web';

    public $css = [
        'css/assistant.css',
    ];

    public $js = [
        'js/assistant.js',
    ];

    public $depends = [
        'yii\web\YiiAsset',
        'yii\bootstrap5\BootstrapAsset',
    ];
}
