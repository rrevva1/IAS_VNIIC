<?php

namespace app\assets;

use yii\web\AssetBundle;

/**
 * Модальное окно выдачи комплекта со склада.
 */
class IssueKitAsset extends AssetBundle
{
    public $basePath = '@webroot';
    public $baseUrl = '@web';

    public $css = [
        'css/warehouse/issue-kit.css',
    ];

    public $js = [
        'js/warehouse/issue-kit-modal.js',
    ];

    public $depends = [
        ArmGridAsset::class,
    ];

    public $jsOptions = [
        'position' => \yii\web\View::POS_END,
    ];

    public $appendTimestamp = true;
}
