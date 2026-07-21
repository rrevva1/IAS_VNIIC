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
        'css/users/profile.css',
    ];
    
    public $js = [
        'js/users/index.js',
        'js/users/profile-edit-modal.js',
        'js/internal-phone-select.js',
    ];
    
    public $depends = [
        'app\assets\LayoutAsset',
    ];
}
