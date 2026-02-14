<?php
use yii\helpers\Html;
use yii\grid\GridView;
use yii\widgets\Pjax;

$this->title = 'Локации';
$this->params['breadcrumbs'][] = ['label' => 'Справочники', 'url' => ['index']];
$this->params['breadcrumbs'][] = $this->title;
?>
<div class="references-locations">
    <h1><?= Html::encode($this->title) ?></h1>
    <p><?= Html::a('Добавить локацию', ['location-create'], ['class' => 'btn btn-success']) ?></p>
    <?php Pjax::begin(['id' => 'ref-locations-pjax']); ?>
    <?= GridView::widget([
        'dataProvider' => $dataProvider,
        'columns' => [
            'id',
            'name',
            'location_code',
            'location_type',
            [
                'attribute' => 'is_archived',
                'format' => 'raw',
                'value' => function ($model) {
                    return $model->is_archived ? '<span class="badge bg-secondary">Архив</span>' : '<span class="badge bg-success">Активна</span>';
                },
            ],
            [
                'class' => 'yii\grid\ActionColumn',
                'template' => '{update} {archive}',
                'buttons' => [
                    'archive' => function ($url, $model, $key) {
                        if ($model->is_archived) {
                            return '';
                        }
                        return Html::a('В архив', ['location-archive', 'id' => $model->id], [
                            'class' => 'btn btn-sm btn-warning',
                            'data' => ['confirm' => 'Архивировать эту локацию?', 'method' => 'post'],
                        ]);
                    },
                ],
                'urlCreator' => function ($action, $model, $key, $index) {
                    if ($action === 'update') {
                        return ['location-update', 'id' => $model->id];
                    }
                    return null;
                },
            ],
        ],
    ]) ?>
    <?php Pjax::end(); ?>
</div>
