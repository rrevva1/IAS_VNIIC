<?php
use yii\helpers\Html;
use yii\grid\GridView;
use yii\widgets\Pjax;

$this->title = 'Статусы оборудования';
$this->params['breadcrumbs'][] = ['label' => 'Справочники', 'url' => ['index']];
$this->params['breadcrumbs'][] = $this->title;
?>
<div class="references-equipment-status">
    <h1><?= Html::encode($this->title) ?></h1>
    <p><?= Html::a('Добавить статус', ['equipment-status-create'], ['class' => 'btn btn-success']) ?></p>
    <?php Pjax::begin(['id' => 'ref-equipment-status-pjax']); ?>
    <?= GridView::widget([
        'dataProvider' => $dataProvider,
        'columns' => [
            'id',
            'status_code',
            'status_name',
            'sort_order',
            [
                'attribute' => 'is_archived',
                'format' => 'raw',
                'value' => function ($model) {
                    return $model->is_archived ? '<span class="badge bg-secondary">Архив</span>' : '<span class="badge bg-success">Активен</span>';
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
                        return Html::a('В архив', ['equipment-status-archive', 'id' => $model->id], [
                            'class' => 'btn btn-sm btn-warning',
                            'data' => ['confirm' => 'Архивировать этот статус?', 'method' => 'post'],
                        ]);
                    },
                ],
                'urlCreator' => function ($action, $model, $key, $index) {
                    if ($action === 'update') {
                        return ['equipment-status-update', 'id' => $model->id];
                    }
                    return null;
                },
            ],
        ],
    ]) ?>
    <?php Pjax::end(); ?>
</div>
