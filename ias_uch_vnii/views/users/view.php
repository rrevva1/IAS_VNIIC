<?php
/**
 * Просмотр пользователя / «Мой профиль».
 *
 * @var yii\web\View $this
 * @var app\models\entities\Users $model
 * @var app\models\entities\Equipment[] $equipment
 * @var app\models\entities\AuditEvent[] $recentActions
 * @var bool $isOwnProfile
 * @var bool $isAdminViewer
 * @var array{total: int, open: int} $taskStats
 */

use yii\helpers\Html;
use yii\helpers\Url;
use app\assets\UsersAsset;

UsersAsset::register($this);

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
    'equipment.archive' => 'Оборудование в архиве',
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

$profileInitials = static function (?string $fullName): string {
    $parts = array_values(array_filter(preg_split('/\s+/u', trim((string) $fullName))));
    if (count($parts) >= 2) {
        return mb_strtoupper(mb_substr($parts[0], 0, 1) . mb_substr($parts[1], 0, 1));
    }
    if (count($parts) === 1) {
        return mb_strtoupper(mb_substr($parts[0], 0, 2));
    }

    return '?';
};

/** Имя и отчество из ФИО (Фамилия Имя Отчество). */
$profileNamePatronymic = static function (?string $fullName): string {
    $parts = array_values(array_filter(preg_split('/\s+/u', trim((string) $fullName))));
    if (count($parts) >= 3) {
        return $parts[1] . ' ' . $parts[2];
    }
    if (count($parts) === 2) {
        return $parts[1];
    }

    return $parts[0] ?? '';
};

$profileGreeting = static function (string $namePart): string {
    $hour = (int) date('G');
    if ($hour >= 5 && $hour < 12) {
        $phrase = 'Доброе утро';
    } elseif ($hour >= 12 && $hour < 18) {
        $phrase = 'Добрый день';
    } elseif ($hour >= 18 && $hour < 23) {
        $phrase = 'Добрый вечер';
    } else {
        $phrase = 'Доброй ночи';
    }

    return $namePart !== '' ? $phrase . ', ' . $namePart . '!' : $phrase . '!';
};

$role = $model->role;
$roleCode = $role ? $role->role_code : null;
$roleDisplay = $roleCode && isset($roleLabels[$roleCode])
    ? $roleLabels[$roleCode]
    : ($model->getRoleDisplayName() ?: 'Роль не назначена');

$canOpenArm = Yii::$app->user->identity && Yii::$app->user->identity->canAccessArm();
$equipmentCount = count($equipment);
$initials = $profileInitials($model->full_name);
$greetingName = $profileNamePatronymic($model->full_name);
$greetingLine = $profileGreeting($greetingName);

$editProfileLink = $isOwnProfile
    ? Html::a('Редактировать профиль', ['update', 'id' => $model->id], ['class' => 'profile-hero__edit'])
    : '';

if ($isAdminViewer && !$isOwnProfile) {
    $this->title = $model->full_name;
    $this->params['breadcrumbs'][] = ['label' => 'Пользователи', 'url' => ['index']];
    $this->params['breadcrumbs'][] = $model->full_name;
} else {
    $this->title = 'Мой профиль';
    $this->params['breadcrumbs'] = [];
}

$renderEquipmentList = static function () use ($equipment, $canOpenArm): string {
    if ($equipment === []) {
        return '<p class="profile-empty profile-empty--center">'
            . '<i class="fas fa-desktop" aria-hidden="true"></i>'
            . 'За вами не закреплено оборудование</p>';
    }

    $html = '<ul class="profile-equipment-list">';
    foreach ($equipment as $eq) {
        $title = Html::encode($eq->name ?: 'Без названия');
        $inv = Html::encode($eq->inventory_number);
        $location = Html::encode($eq->location ? $eq->location->name : 'Помещение не указано');
        $label = $canOpenArm
            ? Html::a($title, ['/arm/view', 'id' => $eq->id])
            : $title;

        $html .= '<li class="profile-equipment-list__item">'
            . '<span class="profile-equipment-list__icon" aria-hidden="true"><i class="fas fa-desktop"></i></span>'
            . '<div><div class="profile-equipment-list__name">' . $label . '</div>'
            . '<div class="profile-equipment-list__meta">Инв. № ' . $inv . ' · ' . $location . '</div></div>'
            . '</li>';
    }
    $html .= '</ul>';

    return $html;
};
?>
<div class="profile-page">
    <?php if ($isOwnProfile && !$isAdminViewer): ?>
        <?php /* ——— Профиль обычного пользователя ——— */ ?>
        <section class="profile-hero" aria-label="Профиль">
            <div class="profile-hero__inner profile-hero__inner--compact">
                <div class="profile-hero__head">
                    <div class="profile-hero__body">
                    <h1 class="profile-hero__greeting profile-hero__greeting--title"><?= Html::encode($greetingLine) ?></h1>
                    <p class="profile-hero__name profile-hero__name--sub"><?= Html::encode($model->full_name ?: 'Пользователь') ?></p>
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
                    <?= $editProfileLink ?>
                </div>
            </div>
        </section>

        <div class="profile-stats" role="group" aria-label="Сводка">
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
            <div class="profile-stat" style="cursor: default;">
                <span class="profile-stat__value"><?= (int) $equipmentCount ?></span>
                <span class="profile-stat__label">Единиц техники</span>
            </div>
        </div>

        <div class="profile-grid">
            <section class="profile-card" aria-labelledby="profile-contacts-title">
                <div class="profile-card__header">
                    <h2 class="profile-card__title" id="profile-contacts-title">
                        <i class="fas fa-address-book" aria-hidden="true"></i>Контактные данные
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
                                    <span class="text-muted">Не указана</span>
                                <?php endif; ?>
                            </dd>
                        </div>
                        <div class="profile-dl__row">
                            <dt class="profile-dl__label">Телефон</dt>
                            <dd class="profile-dl__value"><?= Html::encode($model->phone ?: 'Не указан') ?></dd>
                        </div>
                        <div class="profile-dl__row">
                            <dt class="profile-dl__label">Логин в системе</dt>
                            <dd class="profile-dl__value"><?= Html::encode($model->username ?: 'Не указан') ?></dd>
                        </div>
                    </dl>
                </div>
            </section>

            <section class="profile-card" aria-labelledby="profile-equipment-title">
                <div class="profile-card__header">
                    <h2 class="profile-card__title" id="profile-equipment-title">
                        <i class="fas fa-desktop" aria-hidden="true"></i>Моя техника
                    </h2>
                </div>
                <div class="profile-card__body">
                    <?= $renderEquipmentList() ?>
                </div>
            </section>

            <section class="profile-card profile-card--full">
                <div class="profile-card__body d-flex flex-wrap align-items-center justify-content-between gap-3">
                    <div>
                        <strong>Нужна помощь?</strong>
                        <p class="profile-empty mb-0">Создайте заявку — её увидит служба технической поддержки.</p>
                    </div>
                    <?= Html::a(
                        '<i class="fas fa-plus" aria-hidden="true"></i> Создать заявку',
                        ['/tasks/index'],
                        ['class' => 'btn btn-primary']
                    ) ?>
                </div>
            </section>
        </div>

    <?php else: ?>
        <?php /* ——— Просмотр администратором или свой профиль админа ——— */ ?>
        <?php if (!$isOwnProfile): ?>
        <div class="profile-page__toolbar">
            <div class="profile-admin-header">
                <h1><?= Html::encode($model->full_name) ?></h1>
                <p class="profile-admin-header__sub">Карточка пользователя системы</p>
            </div>
            <div class="profile-page__toolbar-actions">
                <?php if ($isAdminViewer): ?>
                    <?= Html::a('<i class="fas fa-pen"></i> Редактировать', ['update', 'id' => $model->id], ['class' => 'btn btn-primary btn-sm']) ?>
                    <?= Html::a('<i class="fas fa-key"></i> Сбросить пароль', ['reset-password', 'id' => $model->id], [
                        'class' => 'btn btn-warning btn-sm',
                        'data' => [
                            'confirm' => 'Установить временный пароль для пользователя?',
                            'method' => 'post',
                        ],
                    ]) ?>
                    <?= Html::a('<i class="fas fa-trash"></i> Удалить', ['delete', 'id' => $model->id], [
                        'class' => 'btn btn-danger btn-sm',
                        'data' => ['confirm' => 'Удалить пользователя?', 'method' => 'post'],
                    ]) ?>
                <?php endif; ?>
            </div>
        </div>
        <?php endif; ?>

        <section class="profile-hero" aria-label="Профиль">
            <div class="profile-hero__inner<?= $isOwnProfile ? ' profile-hero__inner--compact' : '' ?>">
                <?php if ($isOwnProfile): ?>
                <div class="profile-hero__head">
                    <div class="profile-hero__body">
                        <h1 class="profile-hero__greeting profile-hero__greeting--title"><?= Html::encode($greetingLine) ?></h1>
                        <p class="profile-hero__name profile-hero__name--sub"><?= Html::encode($model->full_name ?: 'Без имени') ?></p>
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
                    <?= $editProfileLink ?>
                </div>
                <?php else: ?>
                <div class="profile-hero__avatar" aria-hidden="true"><?= Html::encode($initials) ?></div>
                <div class="profile-hero__body">
                    <h2 class="profile-hero__name"><?= Html::encode($model->full_name ?: 'Без имени') ?></h2>
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
                <?php endif; ?>
            </div>
        </section>

        <?php if ($isOwnProfile || $isAdminViewer): ?>
        <div class="profile-stats" role="group" aria-label="Заявки пользователя">
            <div class="profile-stat" style="cursor: default;">
                <span class="profile-stat__value"><?= (int) $taskStats['total'] ?></span>
                <span class="profile-stat__label">Всего заявок</span>
            </div>
            <div class="profile-stat" style="cursor: default;">
                <span class="profile-stat__value"><?= (int) $taskStats['open'] ?></span>
                <span class="profile-stat__label">В работе</span>
            </div>
            <div class="profile-stat" style="cursor: default;">
                <span class="profile-stat__value"><?= (int) $equipmentCount ?></span>
                <span class="profile-stat__label">Единиц техники</span>
            </div>
        </div>
        <?php endif; ?>

        <div class="profile-grid">
            <section class="profile-card" aria-labelledby="profile-admin-contacts">
                <div class="profile-card__header">
                    <h2 class="profile-card__title" id="profile-admin-contacts">
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
                            <dt class="profile-dl__label">Телефон</dt>
                            <dd class="profile-dl__value"><?= Html::encode($model->phone ?: 'Не указан') ?></dd>
                        </div>
                        <div class="profile-dl__row">
                            <dt class="profile-dl__label">Логин</dt>
                            <dd class="profile-dl__value"><?= Html::encode($model->username ?: 'Не указан') ?></dd>
                        </div>
                    </dl>
                </div>
            </section>

            <section class="profile-card" aria-labelledby="profile-admin-equipment">
                <div class="profile-card__header">
                    <h2 class="profile-card__title" id="profile-admin-equipment">
                        <i class="fas fa-desktop" aria-hidden="true"></i>Закреплённая техника
                    </h2>
                    <?php if ($canOpenArm): ?>
                        <?= Html::a('Открыть учёт', ['/arm/index'], ['class' => 'btn btn-sm btn-outline-primary']) ?>
                    <?php endif; ?>
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
    <?php endif; ?>
</div>
