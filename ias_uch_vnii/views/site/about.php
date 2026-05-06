<?php

/** @var yii\web\View $this */

use yii\helpers\Html;
use app\assets\SiteAsset;

SiteAsset::register($this);

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
    // БД недоступна или запрос не поддерживается — оставляем прочерк
}

$this->title = 'О проекте';
$this->params['breadcrumbs'][] = $this->title;
?>
<div class="site-about">
    <h1><?= Html::encode($this->title) ?></h1>

    <p class="lead text-muted">
        <?= Html::encode($appName) ?> — информационно-аналитическая система учёта технических средств предприятия
        (учёт активов, Help Desk, справочники, отчётность).
    </p>

    <div class="row mt-4">
        <div class="col-md-6 col-lg-4 mb-3">
            <div class="card h-100">
                <div class="card-header bg-light">
                    <strong>Версия и окружение</strong>
                </div>
                <div class="card-body">
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
        </div>
        <div class="col-md-6 col-lg-4 mb-3">
            <div class="card h-100">
                <div class="card-header bg-light">
                    <strong>Технологии</strong>
                </div>
                <div class="card-body">
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
        </div>
        <div class="col-md-6 col-lg-4 mb-3">
            <div class="card h-100">
                <div class="card-header bg-light">
                    <strong>Развёртывание</strong>
                </div>
                <div class="card-body">
                    <p class="small mb-0">
                        Приложение может работать в среде Docker (контейнеры PHP + PostgreSQL + веб-сервер)
                        или на выделенном хостинге с PHP и PostgreSQL. Инструкции по запуску — в разделе
                        <code>docker/</code> репозитория.
                    </p>
                </div>
            </div>
        </div>
    </div>

    <p class="mt-3 text-muted small">
        Документация по системе, техническое задание и описание требований размещены в репозитории проекта
        (каталог <code>docs/</code>).
    </p>
</div>
