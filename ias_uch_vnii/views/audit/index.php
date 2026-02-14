<?php

use yii\helpers\Html;
use yii\widgets\ActiveForm;
use yii\widgets\Pjax;
use yii\grid\GridView;

/* @var $this yii\web\View */
/* @var $dataProvider yii\data\ActiveDataProvider */
/* @var $users array [id => full_name] */

$this->title = 'Журнал аудита';
$this->params['breadcrumbs'][] = $this->title;
?>

<div class="audit-index">
    <h1><?= Html::encode($this->title) ?></h1>

    <?php Pjax::begin(['id' => 'audit-grid-pjax']); ?>
    <?php $form = ActiveForm::begin(['method' => 'get', 'action' => ['index'], 'options' => ['data-pjax' => 1]]); ?>
    <div class="row">
        <div class="col-md-2">
            <label>С</label>
            <input type="date" name="from" class="form-control" value="<?= Html::encode(Yii::$app->request->get('from')) ?>">
        </div>
        <div class="col-md-2">
            <label>По</label>
            <input type="date" name="to" class="form-control" value="<?= Html::encode(Yii::$app->request->get('to')) ?>">
        </div>
        <div class="col-md-2">
            <label>Пользователь</label>
            <?= Html::dropDownList('actor_id', Yii::$app->request->get('actor_id'), ['' => '—'] + $users, ['class' => 'form-control']) ?>
        </div>
        <div class="col-md-2">
            <label>Тип операции</label>
            <input type="text" name="action_type" class="form-control" value="<?= Html::encode(Yii::$app->request->get('action_type')) ?>" placeholder="task.create">
        </div>
        <div class="col-md-2">
            <label>Тип объекта</label>
            <?= Html::dropDownList('object_type', Yii::$app->request->get('object_type'), [
                '' => '—',
                'task' => 'Заявка',
                'user' => 'Пользователь',
                'attachment' => 'Вложение',
                'equipment' => 'Актив',
            ], ['class' => 'form-control']) ?>
        </div>
        <div class="col-md-2">
            <label>&nbsp;</label>
            <?= Html::submitButton('Фильтр', ['class' => 'btn btn-primary btn-block']) ?>
        </div>
        <div class="col-md-2">
            <label>&nbsp;</label>
            <?= Html::a('Сбросить фильтры', ['index'], ['class' => 'btn btn-outline-secondary btn-block']) ?>
        </div>
    </div>
    <?php ActiveForm::end(); ?>

    <?php
    $totalCount = $dataProvider->getTotalCount();
    $hasFilters = (Yii::$app->request->get('from') !== null && Yii::$app->request->get('from') !== '')
        || (Yii::$app->request->get('to') !== null && Yii::$app->request->get('to') !== '')
        || (Yii::$app->request->get('actor_id') !== null && Yii::$app->request->get('actor_id') !== '')
        || (Yii::$app->request->get('action_type') !== null && Yii::$app->request->get('action_type') !== '')
        || (Yii::$app->request->get('object_type') !== null && Yii::$app->request->get('object_type') !== '');
    if ($totalCount === 0): ?>
    <p class="text-muted mt-2">
        Записей не найдено.
        <?php if ($hasFilters): ?>
            Попробуйте <strong>Сбросить фильтры</strong>.
        <?php endif; ?>
        Если тестовые записи аудита должны быть в БД, загрузите их: <code>psql -U postgres -d ias_vniic -f tests/seed_audit_only.sql</code> (см. <code>tests/LOAD_TEST_DATA_FROM_DUMP.md</code>).
    </p>
    <?php endif; ?>

    <?= GridView::widget([
        'dataProvider' => $dataProvider,
        'columns' => [
            ['class' => 'yii\grid\SerialColumn'],
            'event_time:datetime',
            [
                'attribute' => 'actor_id',
                'value' => function ($model) {
                    return $model->actor ? $model->actor->full_name : '—';
                },
            ],
            'action_type',
            'object_type',
            'object_id',
            'result_status',
        ],
    ]) ?>
    <?php Pjax::end(); ?>
</div>
