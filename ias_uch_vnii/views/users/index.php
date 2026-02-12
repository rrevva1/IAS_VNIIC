<?php

use yii\helpers\Html;
use yii\helpers\Url;
use app\assets\UsersAsset;
use app\assets\UsersGridAsset;

/** @var yii\web\View $this */
// Подключаем assets для страниц пользователей
UsersAsset::register($this);
UsersGridAsset::register($this);

$this->title = 'Управление пользователями';
$this->params['breadcrumbs'][] = $this->title;
?>
<div class="users-index users-index-ag">

    <h1><?= Html::encode($this->title) ?></h1>

    <?php if (!Yii::$app->user->isGuest && Yii::$app->user->identity): ?>
        <div class="alert alert-info">
            <strong>Добро пожаловать, <?= Html::encode(Yii::$app->user->identity->full_name ?: Yii::$app->user->identity->email) ?>!</strong>
            <br>Вы вошли как администратор системы.
        </div>
    <?php endif; ?>

    <div class="ag-grid-toolbar">
        <div class="btn-group">
            <?= Html::a('<i class="glyphicon glyphicon-plus"></i> Добавить пользователя', ['create'], ['class' => 'btn btn-success']) ?>
            <?= Html::button('<i class="glyphicon glyphicon-refresh"></i> Обновить', [
                'class' => 'btn btn-outline-secondary',
                'onclick' => 'refreshUsersGrid()'
            ]) ?>
        </div>
        <div class="btn-group">
            <?= Html::a('Выйти', ['/site/logout'], ['class' => 'btn btn-secondary', 'data-method' => 'post']) ?>
        </div>
    </div>

    <div
        id="agGridUsersContainer"
        class="ag-theme-quartz"
        data-url="<?= Url::to(['users/get-grid-data']) ?>"
        data-view-url="<?= Url::to(['users/view']) ?>"
        data-update-url="<?= Url::to(['users/update']) ?>"
        data-delete-url="<?= Url::to(['users/delete']) ?>"
    >
        <div class="text-center">
            <i class="glyphicon glyphicon-refresh glyphicon-spin"></i>
            <p>Загрузка таблицы пользователей...</p>
        </div>
    </div>
</div>
