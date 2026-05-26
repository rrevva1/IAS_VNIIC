<?php

use yii\helpers\Html;
use app\assets\UsersAsset;

/** @var yii\web\View $this */
/** @var app\models\entities\Users $model */

UsersAsset::register($this);

$isOwnProfile = Yii::$app->user->identity
    && (int) Yii::$app->user->identity->id === (int) $model->id
    && !Yii::$app->user->identity->isAdmin();

if ($isOwnProfile) {
    $this->title = 'Редактирование профиля';
    $this->params['breadcrumbs'] = [];
} else {
    $this->title = 'Редактирование: ' . $model->full_name;
    $this->params['breadcrumbs'][] = ['label' => 'Пользователи', 'url' => ['index']];
    $this->params['breadcrumbs'][] = ['label' => $model->full_name, 'url' => ['view', 'id' => $model->id]];
    $this->params['breadcrumbs'][] = 'Редактирование';
}
?>
<div class="profile-page">
    <div class="profile-page__toolbar">
        <div class="profile-admin-header">
            <h1><?= Html::encode($this->title) ?></h1>
            <?php if ($isOwnProfile): ?>
                <p class="profile-admin-header__sub">Измените контактные данные и пароль при необходимости</p>
            <?php endif; ?>
        </div>
        <?= Html::a(
            '<i class="fas fa-arrow-left" aria-hidden="true"></i> Назад',
            ['view', 'id' => $model->id],
            ['class' => 'btn btn-outline-secondary btn-sm']
        ) ?>
    </div>

    <div class="profile-card">
        <div class="profile-card__body">
            <?= $this->render('_form', [
                'model' => $model,
            ]) ?>
        </div>
    </div>
</div>
