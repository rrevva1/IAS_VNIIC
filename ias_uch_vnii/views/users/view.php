<?php
/**
 * Просмотр пользователя / Мой профиль.
 * Редизайн: карточки (аватар, контакты, активы, последние действия).
 *
 * @var yii\web\View $this
 * @var app\models\Users $model
 * @var app\models\entities\Equipment[] $equipment
 * @var app\models\entities\AuditEvent[] $recentActions
 */

use yii\helpers\Html;
use yii\helpers\Url;
use app\assets\UsersAsset;

UsersAsset::register($this);

$equipment = $equipment ?? [];
$recentActions = $recentActions ?? [];

$isOwnProfile = Yii::$app->user->identity && (int)Yii::$app->user->identity->id === (int)$model->id;

if (Yii::$app->user->identity && Yii::$app->user->identity->isAdministrator()) {
    $this->title = 'Пользователь: ' . $model->full_name;
    $this->params['breadcrumbs'][] = ['label' => 'Пользователи', 'url' => ['index']];
    $this->params['breadcrumbs'][] = $model->full_name;
} else {
    $this->title = 'Мой профиль';
    $this->params['breadcrumbs'][] = $this->title;
}
?>
<div class="users-view profile-redesign">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="mb-0"><?= Html::encode($this->title) ?></h1>
        <div>
            <?php if (Yii::$app->user->identity && Yii::$app->user->identity->isAdministrator()): ?>
                <?= Html::a('<i class="fas fa-edit"></i> Редактировать', ['update', 'id' => $model->id], ['class' => 'btn btn-primary']) ?>
                <?= Html::a('<i class="fas fa-key"></i> Сбросить пароль', ['reset-password', 'id' => $model->id], [
                    'class' => 'btn btn-warning',
                    'data' => ['confirm' => 'Вы уверены? Будет установлен временный пароль.', 'method' => 'post'],
                ]) ?>
                <?= Html::a('<i class="fas fa-trash"></i> Удалить', ['delete', 'id' => $model->id], [
                    'class' => 'btn btn-danger',
                    'data' => ['confirm' => 'Удалить пользователя?', 'method' => 'post'],
                ]) ?>
            <?php elseif ($isOwnProfile): ?>
                <?= Html::a('<i class="fas fa-edit"></i> Редактировать профиль', ['update', 'id' => $model->id], ['class' => 'btn btn-primary']) ?>
                <?= Html::a('<i class="fas fa-sign-out-alt"></i> Выйти', ['/site/logout'], ['class' => 'btn btn-secondary', 'data-method' => 'post']) ?>
            <?php endif; ?>
        </div>
    </div>

    <div class="row g-4">
        <!-- Блок 1: Аватар и основное -->
        <div class="col-lg-4">
            <div class="card shadow-sm h-100">
                <div class="card-body text-center p-4">
                    <div class="profile-avatar mb-3">
                        <div class="rounded-circle bg-primary bg-opacity-25 d-inline-flex align-items-center justify-content-center" style="width: 100px; height: 100px;">
                            <i class="fas fa-user fa-3x text-primary"></i>
                        </div>
                    </div>
                    <h4 class="card-title mb-1"><?= Html::encode($model->full_name ?: 'Без имени') ?></h4>
                    <p class="text-muted mb-0"><?= Html::encode($model->position ?: '—') ?></p>
                    <p class="text-muted small"><?= Html::encode($model->department ?: '—') ?></p>
                    <span class="badge bg-secondary"><?= Html::encode($model->role ? $model->getRoleDisplayName() : 'Роль не назначена') ?></span>
                </div>
            </div>
        </div>

        <!-- Блок 2: Контакты -->
        <div class="col-lg-4">
            <div class="card shadow-sm h-100">
                <div class="card-header bg-light">
                    <h5 class="mb-0"><i class="fas fa-address-card me-2"></i>Контакты</h5>
                </div>
                <div class="card-body">
                    <div class="mb-3">
                        <label class="text-muted small">Email</label>
                        <p class="mb-0">
                            <?php if ($model->email): ?>
                                <a href="mailto:<?= Html::encode($model->email) ?>"><?= Html::encode($model->email) ?></a>
                            <?php else: ?>—<?php endif; ?>
                        </p>
                    </div>
                    <div class="mb-3">
                        <label class="text-muted small">Телефон</label>
                        <p class="mb-0"><?= Html::encode($model->phone ?: '—') ?></p>
                    </div>
                    <div>
                        <label class="text-muted small">Внутренний номер</label>
                        <p class="mb-0"><?= Html::encode($model->username ?: '—') ?></p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Блок 3: Активы -->
        <div class="col-lg-4">
            <div class="card shadow-sm h-100">
                <div class="card-header bg-light d-flex justify-content-between align-items-center">
                    <h5 class="mb-0"><i class="fas fa-desktop me-2"></i>Закреплённая техника</h5>
                    <?php if (Yii::$app->user->identity && Yii::$app->user->identity->isAdministrator()): ?>
                        <?= Html::a('Все', ['/arm/index'], ['class' => 'btn btn-sm btn-outline-primary']) ?>
                    <?php endif; ?>
                </div>
                <div class="card-body">
                    <?php if (empty($equipment)): ?>
                        <p class="text-muted mb-0">Нет закреплённой техники</p>
                    <?php else: ?>
                        <ul class="list-group list-group-flush">
                            <?php foreach ($equipment as $eq): ?>
                                <li class="list-group-item px-0 border-0">
                                    <?= Html::a(Html::encode($eq->inventory_number . ' — ' . ($eq->name ?: 'Без названия')), ['/arm/view', 'id' => $eq->id]) ?>
                                    <small class="text-muted d-block"><?= Html::encode($eq->location ? $eq->location->name : '') ?></small>
                                </li>
                            <?php endforeach; ?>
                        </ul>
                    <?php endif; ?>
                </div>
            </div>
        </div>

        <!-- Блок 4: Последние действия -->
        <div class="col-12">
            <div class="card shadow-sm">
                <div class="card-header bg-light">
                    <h5 class="mb-0"><i class="fas fa-history me-2"></i>Последние действия</h5>
                </div>
                <div class="card-body">
                    <?php if (empty($recentActions)): ?>
                        <p class="text-muted mb-0">Нет записей</p>
                    <?php else: ?>
                        <ul class="list-group list-group-flush">
                            <?php foreach ($recentActions as $ev): ?>
                                <li class="list-group-item px-0 border-0 d-flex justify-content-between">
                                    <span>
                                        <?= Html::encode($ev->action_type) ?> — <?= Html::encode($ev->object_type) ?> #<?= Html::encode($ev->object_id) ?>
                                    </span>
                                    <small class="text-muted"><?= Yii::$app->formatter->asDatetime($ev->event_time, 'php:d.m.Y H:i') ?></small>
                                </li>
                            <?php endforeach; ?>
                        </ul>
                    <?php endif; ?>
                </div>
            </div>
        </div>
    </div>
</div>
