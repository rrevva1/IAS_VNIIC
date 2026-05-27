<?php

/** @var yii\web\View $this */

use app\assets\SectionPageAsset;
use yii\helpers\Html;

SectionPageAsset::register($this);

$appName = Yii::$app->name;
$appVersion = Yii::$app->params['appVersion'] ?? '1.0';
$phpVersion = PHP_VERSION;
$yiiVersion = Yii::getVersion();
$dbDriver = Yii::$app->db->driverName ?? '—';
$dbName = '—';
try {
    if (Yii::$app->db->driverName === 'pgsql') {
        $dbName = Yii::$app->db->createCommand('SELECT current_database()')->queryScalar();
    }
} catch (Throwable $e) {
    // БД недоступна
}

$this->title = 'О проекте';
$this->params['breadcrumbs'] = [];
?>
<div class="arm-page site-about-page">
    <header class="arm-page__header">
        <div class="arm-page__heading">
            <h1 class="arm-page__title"><?= Html::encode($this->title) ?></h1>
        </div>
    </header>

    <div class="arm-grid-card arm-content-panel">
        <div class="about-cards">
            <div class="about-card">
                <div class="about-card__header">Версия и окружение</div>
                <div class="about-card__body">
                    <table class="table table-sm table-borderless mb-0">
                        <tr>
                            <td class="text-muted">Версия приложения</td>
                            <td><?= Html::encode($appVersion) ?></td>
                        </tr>
                        <tr>
                            <td class="text-muted">PHP</td>
                            <td><?= Html::encode($phpVersion) ?></td>
                        </tr>
                        <tr>
                            <td class="text-muted">Yii</td>
                            <td><?= Html::encode($yiiVersion) ?></td>
                        </tr>
                        <tr>
                            <td class="text-muted">СУБД</td>
                            <td><?= Html::encode($dbDriver) ?></td>
                        </tr>
                        <tr>
                            <td class="text-muted">База данных</td>
                            <td><?= Html::encode($dbName) ?></td>
                        </tr>
                        <?php if (defined('YII_DEBUG') && YII_DEBUG): ?>
                        <tr>
                            <td class="text-muted">Режим</td>
                            <td><span class="badge bg-warning text-dark">Отладка</span></td>
                        </tr>
                        <?php endif; ?>
                    </table>
                </div>
            </div>
            <div class="about-card">
                <div class="about-card__header">Технологии</div>
                <div class="about-card__body">
                    <ul class="list-unstyled mb-0 small">
                        <li>PHP &ge; 7.4, Yii2</li>
                        <li>PostgreSQL</li>
                        <li>Bootstrap 5</li>
                        <li>AG Grid (таблицы)</li>
                        <li>Highcharts (графики)</li>
                        <li>PhpSpreadsheet, DomPDF</li>
                    </ul>
                </div>
            </div>
            <div class="about-card">
                <div class="about-card__header">Развёртывание</div>
                <div class="about-card__body">
                    <p class="small mb-0">
                        Приложение может работать в среде Docker (контейнеры PHP, PostgreSQL и веб-сервер)
                        или на выделенном хостинге с PHP и PostgreSQL. Инструкции — в каталоге
                        <code>docker/</code> репозитория.
                    </p>
                </div>
            </div>
        </div>
    </div>
</div>
