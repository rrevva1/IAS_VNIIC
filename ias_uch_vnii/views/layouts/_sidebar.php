<?php
/**
 * Боковое меню навигации.
 *
 * @var yii\web\View $this
 * @var bool $sidebarExpanded
 * @var string|null $displayName
 */

use yii\helpers\Html;
use yii\helpers\Url;

$currentRoute = Yii::$app->controller->route ?? '';

$isActive = static function (array $routes) use ($currentRoute): bool {
    foreach ($routes as $route) {
        if ($currentRoute === $route || strncmp($currentRoute, $route . '/', strlen($route) + 1) === 0) {
            return true;
        }
    }

    return false;
};

$linkClass = static function (array $routes) use ($isActive): string {
    return 'sidebar-nav__link' . ($isActive($routes) ? ' is-active' : '');
};

$renderLink = static function (
    string $icon,
    string $label,
    array $url,
    array $routes,
    array $extraOptions = []
) use ($linkClass): string {
    $options = array_merge([
        'class' => $linkClass($routes),
        'title' => $label,
    ], $extraOptions);

    return Html::a(
        '<span class="sidebar-nav__icon" aria-hidden="true"><i class="' . $icon . '"></i></span>'
        . '<span class="sidebar-nav__text">' . Html::encode($label) . '</span>',
        $url,
        $options
    );
};

$renderSection = static function (string $title): string {
    return '<div class="sidebar-nav__section">' . Html::encode($title) . '</div>'
        . '<div class="sidebar-nav__divider" role="separator" aria-hidden="true"></div>';
};

$isAdmin = !Yii::$app->user->isGuest
    && Yii::$app->user->identity
    && Yii::$app->user->identity->isAdministrator();
$isGuest = Yii::$app->user->isGuest;
$userId = !$isGuest ? (int) Yii::$app->user->id : null;
?>

<nav class="<?= $sidebarExpanded ? 'sidebar expanded' : 'sidebar' ?> bg-dark text-white d-flex flex-column" id="sidebar" aria-label="Основное меню">
    <div class="sidebar-header">
        <a href="<?= Url::to(['/arm/index']) ?>" class="sidebar-brand" title="<?= Html::encode(Yii::$app->name) ?>">
            <span class="sidebar-brand__icon" aria-hidden="true"><i class="fas fa-desktop"></i></span>
            <span class="sidebar-brand__text">
                <span class="sidebar-brand__title">ИАС УТС</span>
                <span class="sidebar-brand__subtitle">Учёт техники</span>
            </span>
        </a>
        <button type="button" class="btn btn-sidebar-toggle" id="toggleSidebar"
                title="<?= $sidebarExpanded ? 'Свернуть меню' : 'Развернуть меню' ?>"
                aria-expanded="<?= $sidebarExpanded ? 'true' : 'false' ?>"
                aria-controls="sidebar-nav">
            <i class="fas fa-angles-left sidebar-toggle-icon"></i>
        </button>
    </div>

    <?php if (!$isGuest && $displayName): ?>
    <div class="sidebar-user">
        <div class="sidebar-user__avatar" aria-hidden="true">
            <i class="fas fa-user"></i>
        </div>
        <div class="sidebar-user__info">
            <span class="sidebar-user__name"><?= Html::encode($displayName) ?></span>
            <?= Html::a('Мой профиль', ['/users/view', 'id' => $userId], ['class' => 'sidebar-user__profile-link']) ?>
        </div>
    </div>
    <?php endif; ?>

    <div class="sidebar-content flex-grow-1" id="sidebar-nav">
        <ul class="sidebar-nav list-unstyled mb-0">
            <?php if (!$isGuest): ?>
                <?= $renderSection('Учёт') ?>
                <li class="sidebar-nav__item">
                    <?= $renderLink('fas fa-desktop', 'Учет ТС', ['/arm/index'], ['arm/index', 'arm/view', 'arm/create', 'arm/update']) ?>
                </li>
                <li class="sidebar-nav__item">
                    <?= $renderLink('fas fa-clipboard-list', 'Заявки', ['/tasks/index'], ['tasks/index', 'tasks/view', 'tasks/create', 'tasks/update']) ?>
                </li>
                <li class="sidebar-nav__item">
                    <?= $renderLink('fas fa-chart-column', 'Статистика', ['/tasks/statistics'], ['tasks/statistics']) ?>
                </li>

                <?php if ($isAdmin): ?>
                    <?= $renderSection('Администрирование') ?>
                    <li class="sidebar-nav__item">
                        <?= $renderLink('fas fa-users', 'Пользователи', ['/users/index'], ['users/index', 'users/view', 'users/create', 'users/update']) ?>
                    </li>
                    <li class="sidebar-nav__item">
                        <?= $renderLink('fas fa-id-card', 'Карточки ТС', ['/user-equipment-cards/index'], ['user-equipment-cards/index', 'user-equipment-cards/view']) ?>
                    </li>
                    <li class="sidebar-nav__item">
                        <?= $renderLink('fas fa-clock-rotate-left', 'Журнал аудита', ['/audit/index'], ['audit/index']) ?>
                    </li>
                    <li class="sidebar-nav__item">
                        <?= $renderLink('fas fa-file-import', 'Импорт ОУ', ['/import/index'], ['import/index']) ?>
                    </li>
                    <li class="sidebar-nav__item">
                        <?= $renderLink('fas fa-key', 'ПО и лицензии', ['/software/index'], ['software/index', 'software/view']) ?>
                    </li>
                    <li class="sidebar-nav__item">
                        <?= $renderLink('fas fa-book', 'Справочники', ['/references/index'], ['references/index']) ?>
                    </li>
                <?php endif; ?>
            <?php endif; ?>

            <?= $renderSection('Справка') ?>
            <li class="sidebar-nav__item">
                <?= $renderLink('fas fa-envelope', 'Контакты', ['/site/contact'], ['site/contact']) ?>
            </li>
            <li class="sidebar-nav__item">
                <?= $renderLink('fas fa-circle-info', 'О проекте', ['/site/about'], ['site/about']) ?>
            </li>
        </ul>
    </div>

    <div class="sidebar-footer">
        <?php if ($isGuest): ?>
            <?= Html::a(
                '<i class="fas fa-right-to-bracket"></i><span class="sidebar-footer__text">Войти</span>',
                ['/site/login'],
                ['class' => 'btn btn-sidebar-login w-100', 'encode' => false]
            ) ?>
        <?php else: ?>
            <?= Html::a(
                '<i class="fas fa-right-from-bracket"></i><span class="sidebar-footer__text">Выйти</span>',
                ['/site/logout'],
                [
                    'class' => 'btn btn-sidebar-logout w-100',
                    'data-method' => 'post',
                    'encode' => false,
                ]
            ) ?>
        <?php endif; ?>
    </div>
</nav>
