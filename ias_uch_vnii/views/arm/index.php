<?php
/**
 * Страница учета техники (оборудование): список с фильтрами.
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
    'id',
    function (Users $u) { return $u->getDisplayName(); }
);

$locationFilter = ArrayHelper::map(
    Location::find()->orderBy(['name' => SORT_ASC])->all(),
    'id',
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
                'attribute' => 'inventory_number',
                'label' => 'Инв. номер',
            ],
            [
                'attribute' => 'name',
                'label' => 'Наименование',
            ],
            [
                'attribute' => 'responsible_user_id',
                'label' => 'Ответственный',
                'value' => function ($model) {
                    return $model->responsibleUser ? $model->responsibleUser->getDisplayName() : '—';
                },
                'filter' => Html::activeDropDownList(
                    $searchModel,
                    'responsible_user_id',
                    $userFilter,
                    ['class' => 'form-control', 'prompt' => 'Все']
                ),
            ],
            [
                'attribute' => 'location_id',
                'label' => 'Местоположение',
                'value' => function ($model) {
                    return $model->location ? $model->location->name : '—';
                },
                'filter' => Html::activeDropDownList(
                    $searchModel,
                    'location_id',
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
