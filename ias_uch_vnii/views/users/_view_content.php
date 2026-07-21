<?php
/**
 * Содержимое карточки пользователя (страница или модальное окно).
 *
 * @var yii\web\View $this
 * @var app\models\entities\Users $model
 * @var app\models\entities\Equipment[] $equipment
 * @var app\models\entities\AuditEvent[] $recentActions
 * @var bool $isOwnProfile
 * @var bool $isAdminViewer
 * @var array{total: int, open: int} $taskStats
 * @var bool $isModal
 */

use app\components\EquipmentCharCatalog;
use app\models\entities\Location;
use yii\helpers\Html;
use yii\helpers\Url;

$isModal = !empty($isModal);
$equipment = $equipment ?? [];
$recentActions = $recentActions ?? [];
$isOwnProfile = $isOwnProfile ?? (Yii::$app->user->identity && (int) Yii::$app->user->identity->id === (int) $model->id);
$isAdminViewer = $isAdminViewer ?? (Yii::$app->user->identity && Yii::$app->user->identity->isAdmin());
$taskStats = $taskStats ?? ['total' => 0, 'open' => 0];

$auditActionLabels = [
    'task.create' => 'Создана заявка',
    'task.update' => 'Изменена заявка',
    'task.delete' => 'Удалена заявка',
    'task.change_status' => 'Изменён статус заявки',
    'task.assign_executor' => 'Назначен исполнитель',
    'task.update_comment' => 'Изменён комментарий',
    'attachment.delete' => 'Удалено вложение',
    'work_task.create' => 'Создана задача',
    'work_task.delete' => 'Удалена задача',
    'work_task.assign' => 'Назначен исполнитель задачи',
    'work_task.comment' => 'Добавлен комментарий к задаче',
    'work_task.transition' => 'Изменён статус задачи',
    'equipment.create' => 'Добавлено оборудование',
    'equipment.update' => 'Изменено оборудование',
    'equipment.reassign' => 'Перезакреплено оборудование',
    'user.create' => 'Создан пользователь',
    'user.password_reset' => 'Сброшен пароль',
    'software.create' => 'Добавлено ПО',
    'software.update' => 'Изменено ПО',
    'software.delete' => 'Удалено ПО',
    'license.create' => 'Добавлена лицензия',
    'license.update' => 'Изменена лицензия',
    'license.delete' => 'Удалена лицензия',
];

$auditObjectLabels = [
    'task' => 'заявка',
    'work_task' => 'задача',
    'equipment' => 'оборудование',
    'user' => 'пользователь',
    'attachment' => 'вложение',
    'software' => 'ПО',
    'license' => 'лицензия',
];

$roleLabels = [
    'admin' => 'Администратор',
    'user' => 'Пользователь',
    'operator' => 'Сотрудник техподдержки',
];

$formatAuditLine = static function ($ev) use ($auditActionLabels, $auditObjectLabels): string {
    $action = $auditActionLabels[$ev->action_type] ?? 'Действие в системе';
    $object = $auditObjectLabels[$ev->object_type] ?? 'объект';
    $id = $ev->object_id !== '' && $ev->object_id !== null ? ' №' . $ev->object_id : '';

    return $action . ' (' . $object . $id . ')';
};

$role = $model->role;
$roleCode = $role ? $role->role_code : null;
$roleDisplay = $roleCode && isset($roleLabels[$roleCode])
    ? $roleLabels[$roleCode]
    : ($model->getRoleDisplayName() ?: 'Роль не назначена');

$canOpenArm = Yii::$app->user->identity && Yii::$app->user->identity->canAccessArm();
$equipmentCount = count($equipment);

$heroActions = '';
if ($isOwnProfile) {
    $heroActions = Html::tag('div', ''
        . Html::button('<i class="fas fa-pen" aria-hidden="true"></i> Редактировать профиль', [
            'class' => 'profile-hero__action profile-hero__action--primary',
            'type' => 'button',
            'data-profile-edit-open' => '1',
        ]),
        [
            'class' => 'profile-hero__actions',
            'role' => 'toolbar',
            'aria-label' => 'Действия профиля',
        ]
    );
} elseif ($isAdminViewer) {
    $heroActions = Html::tag('div', ''
        . Html::button('<i class="fas fa-pen" aria-hidden="true"></i> Редактировать', [
            'class' => 'profile-hero__action profile-hero__action--primary',
            'type' => 'button',
            'data-users-edit' => (int) $model->id,
        ])
        . Html::a('<i class="fas fa-key" aria-hidden="true"></i> Сбросить пароль', ['reset-password', 'id' => $model->id], [
            'class' => 'profile-hero__action profile-hero__action--warning',
            'data' => [
                'confirm' => 'Установить временный пароль для пользователя?',
                'method' => 'post',
            ],
        ])
        . Html::a('<i class="fas fa-trash" aria-hidden="true"></i> Удалить', ['delete', 'id' => $model->id], [
            'class' => 'profile-hero__action profile-hero__action--danger',
            'data' => ['confirm' => 'Удалить пользователя?', 'method' => 'post'],
        ]),
        [
            'class' => 'profile-hero__actions',
            'role' => 'toolbar',
            'aria-label' => 'Действия с пользователем',
        ]
    );
}

$renderEquipmentList = static function () use ($equipment, $canOpenArm): string {
    if ($equipment === []) {
        return '<p class="profile-empty profile-empty--center">'
            . '<i class="fas fa-desktop" aria-hidden="true"></i>'
            . 'За пользователем не закреплено оборудование</p>';
    }

    $html = '<ul class="profile-equipment-list">';
    foreach ($equipment as $eq) {
        $title = Html::encode($eq->name ?: 'Без названия');
        $inv = Html::encode($eq->inventory_number);
        $typeName = trim((string) ($eq->resolveEquipmentTypeName() ?? ''));
        $location = Html::encode(
            $eq->location ? $eq->location->getDisplayLabel() : Location::formatDisplayLabel(null)
        );
        $iconClass = EquipmentCharCatalog::resolveEquipmentTypeIconClass(
            $typeName !== '' ? $typeName : null,
            $eq->inventory_number
        );
        if ($canOpenArm) {
            $label = Html::a($title, ['/arm/index', 'equipment' => $eq->id], [
                'class' => 'profile-equipment-list__link',
            ]);
        } else {
            $label = $title;
        }

        $metaParts = [];
        if ($typeName !== '') {
            $metaParts[] = '<span class="profile-equipment-list__type">' . Html::encode($typeName) . '</span>';
        }
        $metaParts[] = 'Инв. № ' . $inv;
        $metaParts[] = $location;

        $html .= '<li class="profile-equipment-list__item">'
            . '<span class="profile-equipment-list__icon" aria-hidden="true"><i class="fas '
            . Html::encode($iconClass) . '"></i></span>'
            . '<div><div class="profile-equipment-list__name">' . $label . '</div>'
            . '<div class="profile-equipment-list__meta">' . implode(' · ', $metaParts) . '</div></div>'
            . '</li>';
    }
    $html .= '</ul>';

    return $html;
};
?>
<div class="profile-view<?= $isModal ? ' profile-view--modal' : '' ?>" data-user-id="<?= (int) $model->id ?>">
<?php if (!$isModal): ?>
<div class="profile-page">
    <header class="profile-page__header">
        <div class="profile-page__heading">
            <h1 class="profile-page__title">
                <?= Html::encode($isOwnProfile ? 'Мой профиль' : 'Пользователи') ?>
            </h1>
            <?php if (!$isOwnProfile && $isAdminViewer): ?>
                <p class="profile-page__subtitle"><?= Html::encode($model->full_name ?: 'Пользователь') ?></p>
            <?php endif; ?>
        </div>
    </header>
<?php endif; ?>

    <div id="usersViewHeaderSlot">
        <section class="profile-hero" aria-label="Профиль">
            <div class="profile-hero__inner profile-hero__inner--compact">
                <div class="profile-hero__head">
                    <div class="profile-hero__body">
                        <h2 class="profile-hero__name">
                            <?= Html::encode($model->full_name ?: 'Пользователь') ?>
                        </h2>
                        <div class="profile-hero__meta">
                            <span class="profile-hero__badge"><?= Html::encode($roleDisplay) ?></span>
                            <?php if ($model->department): ?>
                                <span><?= Html::encode($model->department) ?></span>
                            <?php endif; ?>
                            <?php if ($model->position): ?>
                                <span><?= Html::encode($model->position) ?></span>
                            <?php endif; ?>
                        </div>
                    </div>
                    <?= $heroActions ?>
                </div>
            </div>
        </section>
    </div>

    <div class="profile-view__body">
        <div class="profile-stats" role="group" aria-label="<?= $isOwnProfile ? 'Сводка' : 'Заявки пользователя' ?>">
            <?php if ($isOwnProfile): ?>
                <?= Html::a(
                    '<span class="profile-stat__value">' . (int) $taskStats['total'] . '</span>'
                    . '<span class="profile-stat__label">Всего заявок</span>',
                    ['/tasks/index'],
                    ['class' => 'profile-stat']
                ) ?>
                <?= Html::a(
                    '<span class="profile-stat__value">' . (int) $taskStats['open'] . '</span>'
                    . '<span class="profile-stat__label">В работе</span>',
                    ['/tasks/index'],
                    ['class' => 'profile-stat']
                ) ?>
            <?php else: ?>
                <div class="profile-stat profile-stat--static">
                    <span class="profile-stat__value"><?= (int) $taskStats['total'] ?></span>
                    <span class="profile-stat__label">Всего заявок</span>
                </div>
                <div class="profile-stat profile-stat--static">
                    <span class="profile-stat__value"><?= (int) $taskStats['open'] ?></span>
                    <span class="profile-stat__label">В работе</span>
                </div>
            <?php endif; ?>
            <div class="profile-stat profile-stat--static">
                <span class="profile-stat__value"><?= (int) $equipmentCount ?></span>
                <span class="profile-stat__label">Единиц техники</span>
            </div>
        </div>

        <div class="profile-grid">
            <section class="profile-card" aria-labelledby="profile-contacts-title">
                <div class="profile-card__header">
                    <h2 class="profile-card__title" id="profile-contacts-title">
                        <i class="fas fa-address-book" aria-hidden="true"></i>Контакты
                    </h2>
                </div>
                <div class="profile-card__body">
                    <dl class="profile-dl">
                        <div class="profile-dl__row">
                            <dt class="profile-dl__label">Электронная почта</dt>
                            <dd class="profile-dl__value">
                                <?php if ($model->email): ?>
                                    <a href="mailto:<?= Html::encode($model->email) ?>"><?= Html::encode($model->email) ?></a>
                                <?php else: ?>
                                    Не указана
                                <?php endif; ?>
                            </dd>
                        </div>
                        <div class="profile-dl__row">
                            <dt class="profile-dl__label">Внутренний телефон</dt>
                            <dd class="profile-dl__value" data-profile-phone-value><?= Html::encode($model->phone ?: 'Не указан') ?></dd>
                        </div>
                        <div class="profile-dl__row">
                            <dt class="profile-dl__label">Кабинет</dt>
                            <dd class="profile-dl__value"><?= Html::encode(($model->hasAttribute('room') && $model->room) ? $model->room : 'Не указан') ?></dd>
                        </div>
                        <div class="profile-dl__row">
                            <dt class="profile-dl__label">Логин</dt>
                            <dd class="profile-dl__value"><?= Html::encode($model->username ?: 'Не указан') ?></dd>
                        </div>
                    </dl>
                </div>
            </section>

            <section class="profile-card" aria-labelledby="profile-equipment-title">
                <div class="profile-card__header">
                    <h2 class="profile-card__title" id="profile-equipment-title">
                        <i class="fas fa-desktop" aria-hidden="true"></i>Закреплённая техника
                    </h2>
                </div>
                <div class="profile-card__body">
                    <?= $renderEquipmentList() ?>
                </div>
            </section>

            <?php if ($isAdminViewer && !$isOwnProfile && $recentActions !== []): ?>
            <section class="profile-card profile-card--full" aria-labelledby="profile-audit-title">
                <div class="profile-card__header">
                    <h2 class="profile-card__title" id="profile-audit-title">
                        <i class="fas fa-clock-rotate-left" aria-hidden="true"></i>Последние действия в системе
                    </h2>
                </div>
                <div class="profile-card__body">
                    <ul class="profile-audit-list">
                        <?php foreach ($recentActions as $ev): ?>
                        <li class="profile-audit-list__item">
                            <span><?= Html::encode($formatAuditLine($ev)) ?></span>
                            <time class="profile-audit-list__time" datetime="<?= Html::encode(date('c', strtotime($ev->event_time))) ?>">
                                <?= Yii::$app->formatter->asDatetime($ev->event_time, 'php:d.m.Y, H:i') ?>
                            </time>
                        </li>
                        <?php endforeach; ?>
                    </ul>
                </div>
            </section>
            <?php endif; ?>
        </div>
    </div>

<?php if (!$isModal): ?>
</div>
<?php endif; ?>
</div>
