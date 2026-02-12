<?php
/**
 * Asset bundle для страниц пользователей
 */

namespace app\assets;

use yii\web\AssetBundle;

class UsersAsset extends AssetBundle
{
    public $basePath = '@webroot';
    public $baseUrl = '@web';
    
    public $css = [
        'css/users/index.css',
    ];
    
    public $js = [
        'js/users/index.js',
    ];
    
    public $depends = [
        'app\assets\LayoutAsset',
    ];
}
