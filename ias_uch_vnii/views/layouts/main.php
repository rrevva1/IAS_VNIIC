<?php
/** @var yii\web\View $this */
/** @var string $content */

use app\assets\LayoutAsset;
use app\widgets\Alert;
use yii\bootstrap5\Breadcrumbs;
use yii\bootstrap5\Html;
use yii\bootstrap5\Nav;
use yii\bootstrap5\NavBar;

LayoutAsset::register($this);

// CSS стили теперь подключены через LayoutAsset

$this->registerCsrfMetaTags();
$this->registerMetaTag(['charset' => Yii::$app->charset], 'charset');
$this->registerMetaTag(['name' => 'viewport', 'content' => 'width=device-width, initial-scale=1, shrink-to-fit=no']);
$this->registerMetaTag(['name' => 'description', 'content' => $this->params['meta_description'] ?? '']);
$this->registerMetaTag(['name' => 'keywords', 'content' => $this->params['meta_keywords'] ?? '']);
$this->registerLinkTag(['rel' => 'icon', 'type' => 'image/x-icon', 'href' => Yii::getAlias('@web/favicon.ico')]);

$displayName = null;
if (!Yii::$app->user->isGuest && Yii::$app->user->identity) {
    $u = Yii::$app->user->identity;
    // подставляем что есть: ФИО -> email -> user#id
    $displayName = $u->full_name ?: $u->email ?: ('user#' . $u->id);
}
?>
<?php $this->beginPage() ?>
<!DOCTYPE html>
<html lang="<?= Yii::$app->language ?>" class="h-100">
<head>
    <title><?= Html::encode($this->title) ?></title>
    <!-- Font Awesome для иконок -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <?php $this->head() ?>
</head>
<body class="d-flex h-100">
<?php $this->beginBody() ?>

<!-- Боковая панель навигации -->
<nav class="sidebar bg-dark text-white d-flex flex-column" id="sidebar" style="width: 250px; min-height: 100vh;">
    <!-- Логотип/название с кнопкой сворачивания -->
    <div class="sidebar-header p-3 border-bottom d-flex justify-content-between align-items-center">
        <h4 class="sidebar-title mb-0"><?= Html::encode(Yii::$app->name) ?></h4>
        <button class="btn btn-outline-light btn-sm" id="toggleSidebar" title="Свернуть панель">
            <i class="fas fa-bars"></i>
        </button>
    </div>
    
    <!-- Элементы навигации -->
    <div class="sidebar-content flex-grow-1 p-0">
        <?php
        // Создаем массив элементов навигации динамически
        $navItems = [
            ['label' => '<i class="fas fa-home"></i><span class="nav-text">     Главная</span>', 'url' => ['/site/index']],
            ['label' => '<i class="fas fa-info-circle"></i><span class="nav-text">    О проекте</span>', 'url' => ['/site/about']],
            ['label' => '<i class="fas fa-envelope"></i><span class="nav-text">    Контакты</span>', 'url' => ['/site/contact']],
        ];
        
        // Добавляем кнопки для авторизованных пользователей
        if (!Yii::$app->user->isGuest) {
            // Добавляем "Мой профиль" для обычных пользователей
            
                $navItems[] = [
                    'label' => '<i class="fas fa-user"></i><span class="nav-text">Мой профиль</span>',
                    'url' => ['/users/view', 'id' => Yii::$app->user->id],
                ];
            
            

            
            
            // Добавляем разделы администрирования только для администраторов
            if(Yii::$app->user->identity->isAdministrator()) {
                $navItems[] = [
                    'label' => '<i class="fas fa-users"></i><span class="nav-text">    Пользователи</span>',
                    'url' => ['/users/index'],
                ];
                $navItems[] = [
                    'label' => '<i class="fas fa-desktop"></i><span class="nav-text">    Учет ТС</span>',
                    'url' => ['/arm/index'],
                ];
            }
                $navItems[] = [
                    'label' => '<i class="fas fa-file"></i><span class="nav-text">    Заявки</span>',
                    'url' => ['/tasks/index'],
                ];
                $navItems[] = [
                    'label' => '<i class="fas fa-bar-chart"></i><span class="nav-text">    Статистика заявок</span>',
                    'url' => ['/tasks/statistics'],
                ];
            
        }
        
        // Добавляем кнопку входа/выхода
        if (Yii::$app->user->isGuest) {
            $navItems[] = ['label' => '<i class="fas fa-sign-in-alt"></i><span class="nav-text">Войти</span>', 'url' => ['/site/login']];
        } else {
            $navItems[] = [
                'label' => '<i class="fas fa-sign-out-alt"></i><span class="nav-text">Выйти (' . Html::encode($displayName) . ')</span>',
                'url' => ['/site/logout'],
                'linkOptions' => [
                    'data-method' => 'post',
                    'class' => 'text-light'
                ]
            ];
        }

        echo Nav::widget([
            'options' => ['class' => 'nav flex-column'],
            'items' => $navItems,
            'encodeLabels' => false,
        ]);
        ?>
    </div>
</nav>

<!-- Основной контент -->
<main class="main-content flex-grow-1 d-flex flex-column">
    <div class="content-wrapper flex-grow-1 p-4">
        <?php if (!empty($this->params['breadcrumbs'])): ?>
            <?= Breadcrumbs::widget([
                'links'    => $this->params['breadcrumbs'],
                'homeLink' => ['label' => 'Главная', 'url' => ['/site/index']],
            ]) ?>
        <?php endif ?>
        <?= Alert::widget() ?>
        <?= $content ?>
    </div>
</main>

<!-- Footer скрыт, так как информация о компании теперь под таблицей tasks -->
<footer id="footer" class="mt-auto py-3 bg-light" style="display: none;">
    <div class="container">
        <div class="row text-muted">
            <div class="col-md-12 text-center">Работает на Yii2</div>
        </div>
    </div>
</footer>

<!-- JavaScript теперь подключен через LayoutAsset -->

<?php $this->endBody() ?>
</body>
</html>
<?php $this->endPage() ?>
