<?php

use yii\helpers\Html;
use yii\widgets\DetailView;
use app\assets\UsersAsset;

/** @var yii\web\View $this */
/** @var app\models\Users $model */

// Подключаем assets для страниц пользователей
UsersAsset::register($this);

// Определяем заголовок в зависимости от роли пользователя
if (Yii::$app->user->identity && Yii::$app->user->identity->isAdministrator()) {
    $this->title = 'Пользователь: ' . $model->full_name;
    $this->params['breadcrumbs'][] = ['label' => 'Пользователи', 'url' => ['index']];
    $this->params['breadcrumbs'][] = $model->full_name;
} else {
    $this->title = 'Мой профиль';
    $this->params['breadcrumbs'][] = $this->title;
}
\yii\web\YiiAsset::register($this);
?>
<div class="users-view">

    <h1><?= Html::encode($this->title) ?></h1>

    <?php if (Yii::$app->user->identity && Yii::$app->user->identity->isAdministrator()): ?>
        <!-- Кнопки для администратора -->
        <p>
            <?= Html::a('Редактировать', ['update', 'id' => $model->id], ['class' => 'btn btn-primary']) ?>
            <?= Html::a('Сбросить пароль', ['reset-password', 'id' => $model->id], [
                'class' => 'btn btn-warning',
                'data' => [
                    'confirm' => 'Вы уверены, что хотите сбросить пароль этого пользователя?',
                    'method' => 'post',
                ],
            ]) ?>
            <?= Html::a('Удалить', ['delete', 'id' => $model->id], [
                'class' => 'btn btn-danger',
                'data' => [
                    'confirm' => 'Вы уверены, что хотите удалить этого пользователя?',
                    'method' => 'post',
                ],
            ]) ?>
        </p>
    <?php elseif (Yii::$app->user->identity && Yii::$app->user->identity->id == $model->id): ?>
        <!-- Кнопки для собственного профиля -->
        <p>
            <?= Html::a('Редактировать профиль', ['update', 'id' => $model->id], ['class' => 'btn btn-primary']) ?>
            <?= Html::a('Выйти', ['/site/logout'], ['class' => 'btn btn-secondary', 'data-method' => 'post']) ?>
        </p>
    <?php endif; ?>

    <?= DetailView::widget([
        'model' => $model,
        'attributes' => [
            'id',
            'full_name',
            'email:email',
            [
                'attribute' => 'role_id',
                'label' => 'Роль',
                'value' => $model->role ? $model->role->role_name : 'Роль не назначена',
            ],
            [
                'attribute' => 'password_hash',
                'label' => 'Пароль',
                'value' => '••••••••',
            ],
        ],
    ]) ?>

</div>
