<?php

namespace app\assets;

use yii\web\AssetBundle;

/**
 * Переопределение HighchartsAsset: скрипты в npm-asset/highcharts (highcharts.js, highcharts.src.js).
 * Подключается через assetManager.bundles в config.
 */
class HighchartsAssetOverride extends AssetBundle
{
    public $sourcePath = '@vendor/npm-asset/highcharts';

    public $depends = ['yii\web\JqueryAsset'];

    /**
     * Регистрация скриптов (как в miloschuman\highcharts\HighchartsAsset).
     * @param array $scripts
     * @return $this
     */
    public function withScripts($scripts = ['highcharts'])
    {
        $ext = YII_DEBUG ? 'src.js' : 'js';
        foreach ($scripts as $script) {
            $this->js[] = "$script.$ext";
        }
        array_unshift($this->js, "highcharts.$ext");
        return $this;
    }
}
