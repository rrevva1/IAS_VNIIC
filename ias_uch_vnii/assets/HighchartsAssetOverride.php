<?php

namespace app\assets;

use yii\web\AssetBundle;

/**
 * Переопределение HighchartsAsset: скрипты лежат в подпапке package (npm-asset/highcharts/package/).
 * Подключается через assetManager.bundles в config.
 */
class HighchartsAssetOverride extends AssetBundle
{
    /** Путь к папке, где лежит highcharts.js (в npm пакете это package/) */
    public $sourcePath = '@vendor/npm-asset/highcharts/package';

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
