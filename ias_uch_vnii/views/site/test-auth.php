<?php

use yii\helpers\Html;

/** @var yii\web\View $this */
/** @var app\models\Users $user */

$this->title = 'Тест авторизации';
$this->params['breadcrumbs'][] = $this->title;
?>
<div class="site-test-auth">
    <h1><?= Html::encode($this->title) ?></h1>

    <div class="alert alert-success">
        <h4>Авторизация успешна!</h4>
        <p>Вы успешно вошли в систему.</p>
    </div>

    <div class="card">
        <div class="card-header">
            <h5>Информация о пользователе</h5>
        </div>
        <div class="card-body">
            <table class="table table-striped">
                <tr>
                    <td><strong>ID:</strong></td>
                    <td><?= Html::encode($user->id) ?></td>
                </tr>
                <tr>
                    <td><strong>ФИО:</strong></td>
                    <td><?= Html::encode($user->fio) ?></td>
                </tr>
                <tr>
                    <td><strong>Email:</strong></td>
                    <td><?= Html::encode($user->email) ?></td>
                </tr>
                <tr>
                    <td><strong>Роль:</strong></td>
                    <td><?= Html::encode($user->role ? $user->role->role_name : 'Роль не назначена') ?></td>
                </tr>
                <tr>
                    <td><strong>Auth Key:</strong></td>
                    <td><?= Html::encode($user->auth_key) ?></td>
                </tr>
                <tr>
                    <td><strong>Является администратором:</strong></td>
                    <td><?= $user->isAdmin() ? 'Да' : 'Нет' ?></td>
                </tr>
            </table>
        </div>
    </div>

    <div class="mt-3">
        <?= Html::a('Управление пользователями', ['/users/index'], ['class' => 'btn btn-primary']) ?>
        <?= Html::a('Выйти', ['logout'], ['class' => 'btn btn-danger', 'data-method' => 'post']) ?>
    </div>
</div>
