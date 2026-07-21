<?php
/**
 * Боковое меню навигации.
 *
 * Группы по смыслу:
 * — Техника: учёт, склад, поставки;
 * — Заявки: обращения, внутренние задачи, отчёты;
 * — Администрирование: пользователи, справочники, импорт, аудит;
 * — Справка.
 *
 * @var yii\web\View $this
 * @var bool $sidebarExpanded
 * @var string|null $displayName
 * @var string|null $displayNameFull полное ФИО для подсказки
 */

use yii\helpers\Html;
use yii\helpers\Url;

$currentRoute = Yii::$app->controller->route ?? '';

$isActive = static function (array $routes, array $excludePrefixes = []) use ($currentRoute): bool {
    foreach ($excludePrefixes as $exclude) {
        if ($currentRoute === $exclude || strncmp($currentRoute, $exclude . '/', strlen($exclude) + 1) === 0) {
            return false;
        }
    }
    foreach ($routes as $route) {
        if ($currentRoute === $route || strncmp($currentRoute, $route . '/', strlen($route) + 1) === 0) {
            return true;
        }
    }

    return false;
};

$linkClass = static function (array $routes, array $excludePrefixes = []) use ($isActive): string {
    return 'sidebar-nav__link' . ($isActive($routes, $excludePrefixes) ? ' is-active' : '');
};

$renderLink = static function (
    string $icon,
    string $label,
    array $url,
    array $routes,
    array $extraOptions = [],
    array $excludePrefixes = []
) use ($linkClass): string {
    $options = array_merge([
        'class' => $linkClass($routes, $excludePrefixes),
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

$isGuest = Yii::$app->user->isGuest;
$userId = !$isGuest ? (int) Yii::$app->user->id : null;
$isAdmin = !$isGuest
    && Yii::$app->user->identity
    && Yii::$app->user->identity->isAdministrator();
$isSupportStaff = !$isGuest
    && Yii::$app->user->identity
    && Yii::$app->user->identity->isSupportStaff();
$canAccessArm = !$isGuest
    && Yii::$app->user->identity
    && Yii::$app->user->identity->canAccessArm();
$homeUrl = !$isGuest && Yii::$app->user->identity
    ? Yii::$app->user->identity->getHomeUrl()
    : ['/site/login'];

$showEquipmentSection = $canAccessArm;
$showServiceSection = !$isGuest;
$showAdminSection = $isAdmin;
?>

<nav class="<?= $sidebarExpanded ? 'sidebar expanded' : 'sidebar' ?> bg-dark text-white d-flex flex-column" id="sidebar" aria-label="Основное меню">
    <div class="sidebar-header">
        <a href="<?= Url::to($homeUrl) ?>" class="sidebar-brand" title="<?= Html::encode(Yii::$app->name) ?>">
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
            <span class="sidebar-user__name"<?= !empty($displayNameFull) ? ' title="' . Html::encode($displayNameFull) . '"' : '' ?>><?= Html::encode($displayName) ?></span>
            <?= Html::a('Мой профиль', ['/users/view', 'id' => $userId], ['class' => 'sidebar-user__profile-link']) ?>
        </div>
    </div>
    <?php endif; ?>

    <div class="sidebar-content flex-grow-1" id="sidebar-nav">
        <ul class="sidebar-nav list-unstyled mb-0">
            <?php if (!$isGuest): ?>
                <li class="sidebar-nav__item">
                    <?= $renderLink('fas fa-house', 'Главная', ['/site/index'], ['site/index']) ?>
                </li>
                <div class="sidebar-nav__divider" role="separator" aria-hidden="true"></div>
            <?php endif; ?>
            <?php if ($showEquipmentSection): ?>
                <?= $renderSection('Техника') ?>
                <li class="sidebar-nav__item">
                    <?= $renderLink('fas fa-desktop', 'Учет ТС', ['/arm/index'], ['arm']) ?>
                </li>
                <li class="sidebar-nav__item">
                    <?= $renderLink('fas fa-warehouse', 'Склад', ['/warehouse/index'], ['warehouse']) ?>
                </li>
                <li class="sidebar-nav__item">
                    <?= $renderLink('fas fa-truck', 'Поставки', ['/delivery/index'], ['delivery']) ?>
                </li>
                <li class="sidebar-nav__item">
                    <?= $renderLink('fas fa-route', 'История перемещений', ['/tasks/movement-history'], ['tasks/movement-history']) ?>
                </li>
            <?php endif; ?>

            <?php if ($showServiceSection): ?>
                <?= $renderSection('Заявки') ?>
                <li class="sidebar-nav__item">
                    <?= $renderLink(
                        'fas fa-clipboard-list',
                        'Заявки',
                        ['/tasks/index'],
                        ['tasks'],
                        [],
                        ['tasks/statistics', 'tasks/movement-history']
                    ) ?>
                </li>
                <?php if ($isSupportStaff): ?>
                <li class="sidebar-nav__item">
                    <?= $renderLink(
                        'fas fa-list-check',
                        'Задачи',
                        ['/work-tasks/index'],
                        ['work-tasks']
                    ) ?>
                </li>
                <?php endif; ?>
                <?php if ($canAccessArm): ?>
                <li class="sidebar-nav__item">
                    <?= $renderLink('fas fa-chart-column', 'Статистика', ['/tasks/statistics'], ['tasks/statistics']) ?>
                </li>
                <?php endif; ?>
            <?php endif; ?>

            <?php if ($showAdminSection): ?>
                <?= $renderSection('Администрирование') ?>
                <li class="sidebar-nav__item">
                    <?= $renderLink('fas fa-users', 'Пользователи', ['/users/index'], ['users']) ?>
                </li>
                <li class="sidebar-nav__item">
                    <?= $renderLink('fas fa-id-card', 'Карточки ТС', ['/user-equipment-cards/index'], ['user-equipment-cards']) ?>
                </li>
                <li class="sidebar-nav__item">
                    <?= $renderLink('fas fa-book', 'Справочники', ['/references/index'], ['references']) ?>
                </li>
                <li class="sidebar-nav__item">
                    <?= $renderLink('fas fa-key', 'Лицензии ПО', ['/software/index'], ['software']) ?>
                </li>
                <li class="sidebar-nav__item">
                    <?= $renderLink('fas fa-clock-rotate-left', 'Журнал аудита', ['/audit/index'], ['audit']) ?>
                </li>
            <?php endif; ?>

            <?= $renderSection('Справка') ?>
            <li class="sidebar-nav__item">
                <?= $renderLink('fas fa-address-book', 'Телефонный справочник', ['/phone-directory/index'], ['phone-directory']) ?>
            </li>
            <li class="sidebar-nav__item">
                <?= $renderLink('fas fa-envelope', 'Служба поддержки', ['/site/contact'], ['site/contact']) ?>
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
