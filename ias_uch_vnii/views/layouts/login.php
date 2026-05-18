<?php
/** @var yii\web\View $this */
/** @var string $content */

use app\assets\LoginAsset;
use app\widgets\Alert;
use yii\bootstrap5\Html;
LoginAsset::register($this);

$this->registerCsrfMetaTags();
$this->registerMetaTag(['charset' => Yii::$app->charset], 'charset');
$this->registerMetaTag(['name' => 'viewport', 'content' => 'width=device-width, initial-scale=1, shrink-to-fit=no']);
$this->registerLinkTag(['rel' => 'icon', 'type' => 'image/x-icon', 'href' => Yii::getAlias('@web/favicon.ico')]);
$this->registerLinkTag([
    'rel' => 'stylesheet',
    'href' => 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css',
]);
?>
<?php $this->beginPage() ?>
<!DOCTYPE html>
<html lang="ru" class="h-100">
<head>
    <title><?= Html::encode($this->title) ?></title>
    <?php $this->head() ?>
</head>
<body class="login-layout">
<?php $this->beginBody() ?>

<main class="login-layout__main" role="main">
    <?= Alert::widget() ?>
    <?= $content ?>
</main>

<footer class="login-layout__footer text-center">
    <small class="text-muted">
        <?= Html::encode(Yii::$app->name) ?>
        <?php if (!empty(Yii::$app->params['appVersion'])): ?>
            · версия <?= Html::encode(Yii::$app->params['appVersion']) ?>
        <?php endif; ?>
    </small>
</footer>

<?php $this->endBody() ?>
</body>
</html>
<?php $this->endPage() ?>
