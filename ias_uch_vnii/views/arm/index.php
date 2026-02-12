<?php
/**
 * Страница учета техники (АРМ): список с фильтрами.
 * @var yii\web\View $this
 * @var app\models\search\ArmSearch $searchModel
 * @var yii\data\ActiveDataProvider $dataProvider
 */

use app\models\entities\Location;
use app\models\entities\Users;
use yii\grid\GridView;
use yii\helpers\ArrayHelper;
use yii\helpers\Html;

$this->title = 'Учет ТС';
$this->params['breadcrumbs'][] = $this->title;

$userFilter = ArrayHelper::map(
    Users::find()->orderBy(['full_name' => SORT_ASC])->all(),
    'id_user',
    function (Users $u) { return $u->full_name ?: $u->email; }
);

$locationFilter = ArrayHelper::map(
    Location::find()->orderBy(['name' => SORT_ASC])->all(),
    'id_location',
    'name'
);
?>

<div class="arm-index">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h1 class="mb-0"><?= Html::encode($this->title) ?></h1>
        <?= Html::a('Добавить технику', ['create'], ['class' => 'btn btn-success']) ?>
    </div>

    <?= GridView::widget([
        'dataProvider' => $dataProvider,
        'filterModel' => $searchModel,
        'columns' => [
            ['class' => 'yii\grid\SerialColumn'],
            [
                'attribute' => 'name',
                'label' => 'Наименование',
                'format' => 'text',
            ],
            [
                'attribute' => 'id_user',
                'label' => 'Пользователь',
                'value' => function ($model) {
                    return $model->user ? ($model->user->full_name ?: $model->user->email) : '—';
                },
                'filter' => Html::activeDropDownList(
                    $searchModel,
                    'id_user',
                    $userFilter,
                    ['class' => 'form-control', 'prompt' => 'Все']
                ),
            ],
            [
                'attribute' => 'id_location',
                'label' => 'Местоположение',
                'value' => function ($model) {
                    return $model->location ? $model->location->name : '—';
                },
                'filter' => Html::activeDropDownList(
                    $searchModel,
                    'id_location',
                    $locationFilter,
                    ['class' => 'form-control', 'prompt' => 'Все']
                ),
            ],
            [
                'attribute' => 'description',
                'label' => 'Описание',
                'contentOptions' => ['style' => 'max-width: 400px; white-space: normal;'],
                'format' => 'ntext',
            ],
            [
                'attribute' => 'created_at',
                'label' => 'Создано',
                'format' => ['datetime', 'php:d.m.Y H:i'],
                'filter' => false,
            ],
        ],
        'tableOptions' => ['class' => 'table table-striped table-bordered'],
        'summary' => 'Показано {count} из {totalCount}',
    ]) ?>
</div>





