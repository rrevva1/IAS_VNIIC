<?php

use app\models\entities\Users;
use app\models\dictionaries\Roles;
use yii\helpers\Html;
use yii\helpers\Url;
use yii\grid\ActionColumn;
use yii\grid\GridView;
use app\assets\UsersAsset;

/** @var yii\web\View $this */
/** @var app\models\UsersSearch $searchModel */
/** @var yii\data\ActiveDataProvider $dataProvider */

// Подключаем assets для страниц пользователей
UsersAsset::register($this);

$this->title = 'Управление пользователями';
$this->params['breadcrumbs'][] = $this->title;
?>
<div class="users-index">

    <h1><?= Html::encode($this->title) ?></h1>

    <?php if (!Yii::$app->user->isGuest && Yii::$app->user->identity): ?>
        <div class="alert alert-info">
            <strong>Добро пожаловать, <?= Html::encode(Yii::$app->user->identity->full_name ?: Yii::$app->user->identity->email) ?>!</strong>
            <br>Вы вошли как администратор системы.
        </div>
    <?php endif; ?>

    <div class="row mb-3">
        <div class="col-md-6">
            <?= Html::a('Добавить пользователя', ['create'], ['class' => 'btn btn-success']) ?>
        </div>
        <div class="col-md-6 text-end">
            <?= Html::a('Выйти', ['/site/logout'], ['class' => 'btn btn-secondary', 'data-method' => 'post']) ?>
        </div>
    </div>

    <?= GridView::widget([
        'dataProvider' => $dataProvider,
        'filterModel'  => $searchModel,

        // Русские подписи в шапке и подвале таблицы:
        'summary'   => 'Показаны {begin}–{end} из {totalCount}',
        'emptyText' => 'Записей не найдено',

        'columns' => [
            ['class' => 'yii\grid\SerialColumn'],

            'id',
            [
                'attribute' => 'full_name',
                'label'     => 'ФИО',
            ],
            [
                'attribute' => 'email',
                'format'    => 'email',
                'label'     => 'Email',
            ],

            // Роль: показываем название роли (а не id) и фильтруем по БД
            [
                'attribute' => 'role_id',
                'label'     => 'Роль',
                'value'     => static fn($m) => $m->role ? $m->role->role_name : null,
                'filter'    => Roles::getList(),
            ],

            [
                'attribute' => 'password_hash',
                'label'     => 'Пароль',
                'value'     => static fn() => '••••••••',
                'filter'    => false,
            ],

            [
                'class'  => ActionColumn::class,
                'header' => 'Действия',
                'buttons' => [
                    'view' => function ($url, $model) {
                        return Html::a('🔍', $url, ['title' => 'Показать', 'aria-label' => 'Показать']);
                    },
                    'update' => function ($url, $model) {
                        return Html::a('✏️', $url, ['title' => 'Изменить', 'aria-label' => 'Изменить']);
                    },
                    'delete' => function ($url, $model) {
                        return Html::a('🗑️', $url, [
                            'title' => 'Удалить',
                            'aria-label' => 'Удалить',
                            'data-confirm' => 'Удалить пользователя?',
                            'data-method'  => 'post',
                        ]);
                    },
                ],
                'urlCreator' => function ($action, Users $model) {
                    return Url::toRoute([$action, 'id' => $model->id]);
                },
            ],
        ],
    ]); ?>
</div>
