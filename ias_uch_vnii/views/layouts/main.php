<?php
/** @var yii\web\View $this */
/** @var string $content */

use app\assets\LayoutAsset;
use app\widgets\Alert;
use yii\bootstrap5\Breadcrumbs;
use yii\bootstrap5\Html;

LayoutAsset::register($this);

$this->registerCsrfMetaTags();
$this->registerMetaTag(['charset' => Yii::$app->charset], 'charset');
$this->registerMetaTag(['name' => 'viewport', 'content' => 'width=device-width, initial-scale=1, shrink-to-fit=no']);
$this->registerMetaTag(['name' => 'description', 'content' => $this->params['meta_description'] ?? '']);
$this->registerMetaTag(['name' => 'keywords', 'content' => $this->params['meta_keywords'] ?? '']);
$this->registerLinkTag(['rel' => 'icon', 'type' => 'image/x-icon', 'href' => Yii::getAlias('@web/favicon.ico')]);

$displayName = null;
if (!Yii::$app->user->isGuest && Yii::$app->user->identity) {
    $u = Yii::$app->user->identity;
    $displayName = $u->full_name ?: $u->email ?: ('user#' . $u->id);
}

$sidebarExpanded = !isset($_COOKIE['sidebarExpanded']) || $_COOKIE['sidebarExpanded'] === '1';
$mainClass = 'main-content d-flex flex-column';
?>
<?php $this->beginPage() ?>
<!DOCTYPE html>
<html lang="ru" class="h-100">
<head>
    <title><?= Html::encode($this->title) ?></title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <?php $this->head() ?>
</head>
<body class="app-body">
<?php $this->beginBody() ?>

<?= $this->render('_sidebar', [
    'sidebarExpanded' => $sidebarExpanded,
    'displayName' => $displayName,
]) ?>

<main class="<?= $mainClass ?>">
    <div class="content-wrapper flex-grow-1 p-4">
        <?php if (!empty($this->params['breadcrumbs'])): ?>
            <?php
            $breadcrumbHome = false;
            if (!Yii::$app->user->isGuest) {
                $breadcrumbHome = ['label' => 'Учет ТС', 'url' => ['/arm/index']];
            }
            ?>
            <?= Breadcrumbs::widget([
                'links' => $this->params['breadcrumbs'],
                'homeLink' => $breadcrumbHome,
            ]) ?>
        <?php endif ?>
        <?= Alert::widget() ?>
        <?= $content ?>
    </div>
</main>

<?php $this->endBody() ?>
</body>
</html>
<?php $this->endPage() ?>
