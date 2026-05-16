<?php

namespace app\assets;

use kartik\select2\Select2Asset;
use yii\web\AssetBundle;

/**
 * Поиск по списку пользователей (Select2) для выпадающих списков и комбобоксов.
 */
class UserSelectAsset extends AssetBundle
{
    public $basePath = '@webroot';
    public $baseUrl = '@web';

    public $css = [
        'css/common/user-select-search.css',
    ];

    public $js = [
        'js/common/user-select-search.js',
    ];

    public $depends = [
        Select2Asset::class,
        'yii\web\JqueryAsset',
    ];

    public $jsOptions = [
        'position' => \yii\web\View::POS_END,
    ];

    public $appendTimestamp = true;
}
