<?php
/**
 * Карточка актива (просмотр).
 * @var yii\web\View $this
 * @var app\models\entities\Equipment $model
 * @var array $chars Характеристики из part_char_values (cpu, ram, disk, ...)
 * @var app\models\entities\EquipHistory[] $history
 */

use yii\helpers\Html;
use yii\widgets\DetailView;

$this->title = 'Карточка актива: ' . Html::encode($model->name ?: $model->inventory_number);
$this->params['breadcrumbs'][] = ['label' => 'Учет ТС', 'url' => ['index']];
$this->params['breadcrumbs'][] = $this->title;
?>

<div class="arm-view">
    <h1><?= Html::encode($model->name ?: $model->inventory_number) ?></h1>
    <p>
        <?php if (Yii::$app->user->identity && (Yii::$app->user->identity->isAdministrator() || (int) $model->responsible_user_id === (int) Yii::$app->user->id)): ?>
            <?= Html::a('Редактировать', ['update', 'id' => $model->id], ['class' => 'btn btn-primary']) ?>
            <?php if (!$model->is_archived && Yii::$app->user->identity->isAdministrator()): ?>
                <?= Html::a('Архивировать', ['archive', 'id' => $model->id], [
                    'class' => 'btn btn-warning',
                    'data' => ['method' => 'post', 'confirm' => 'Архивировать этот актив?'],
                ]) ?>
            <?php endif; ?>
        <?php endif; ?>
        <?= Html::a('К списку', ['index'], ['class' => 'btn btn-default']) ?>
    </p>

    <?= DetailView::widget([
        'model' => $model,
        'attributes' => [
            'id',
            'inventory_number',
            'serial_number',
            'name',
            [
                'attribute' => 'equipment_type',
                'label' => 'Тип',
                'value' => $model->equipment_type ?: '—',
            ],
            [
                'attribute' => 'status_id',
                'value' => $model->equipmentStatus ? $model->equipmentStatus->status_name : '',
            ],
            [
                'attribute' => 'responsible_user_id',
                'value' => $model->responsibleUser ? $model->responsibleUser->getDisplayName() : '—',
            ],
            [
                'attribute' => 'location_id',
                'value' => $model->location ? $model->location->name : '—',
            ],
            'supplier',
            'purchase_date',
            'commissioning_date',
            'warranty_until',
            'description:ntext',
            [
                'attribute' => 'is_archived',
                'value' => $model->is_archived ? 'Да' : 'Нет',
            ],
            'archived_at',
            'archive_reason:ntext',
            'created_at',
            'updated_at',
        ],
    ]) ?>

    <?php if (!empty($chars)): ?>
    <h3>Конфигурация</h3>
    <table class="table table-bordered table-striped">
        <thead>
            <tr><th>Параметр</th><th>Значение</th></tr>
        </thead>
        <tbody>
            <?php foreach (['cpu' => 'ЦП', 'ram' => 'ОЗУ', 'disk' => 'Диск', 'monitor' => 'Монитор', 'hostname' => 'Имя ПК', 'ip' => 'IP', 'os' => 'ОС'] as $key => $label): ?>
                <?php if (!empty($chars[$key])): ?>
                <tr><td><?= Html::encode($label) ?></td><td><?= Html::encode($chars[$key]) ?></td></tr>
                <?php endif; ?>
            <?php endforeach; ?>
        </tbody>
    </table>
    <?php endif; ?>

    <?php
    $relatedTasks = $model->getTasks()->with('status')->orderBy(['created_at' => SORT_DESC])->limit(20)->all();
    if (!empty($relatedTasks)):
    ?>
    <h3>Связанные заявки</h3>
    <table class="table table-bordered table-striped">
        <thead>
            <tr><th>№</th><th>Тема / Описание</th><th>Статус</th><th>Дата</th><th></th></tr>
        </thead>
        <tbody>
            <?php foreach ($relatedTasks as $t): ?>
            <tr>
                <td><?= (int) $t->id ?></td>
                <td><?= Html::encode($t->title ?: mb_substr($t->description, 0, 50)) ?></td>
                <td><?= $t->status ? Html::encode($t->status->status_name) : '—' ?></td>
                <td><?= Yii::$app->formatter->asDate($t->created_at) ?></td>
                <td><?= Html::a('Открыть', ['/tasks/view', 'id' => $t->id], ['class' => 'btn btn-xs btn-default']) ?></td>
            </tr>
            <?php endforeach; ?>
        </tbody>
    </table>
    <?php endif; ?>

    <?php if (!empty($history)): ?>
    <h3>История изменений</h3>
    <table class="table table-bordered table-striped">
        <thead>
            <tr>
                <th>Дата</th>
                <th>Событие</th>
                <th>Комментарий</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($history as $h): ?>
            <tr>
                <td><?= Yii::$app->formatter->asDatetime($h->changed_at) ?></td>
                <td><?= Html::encode($h->event_type) ?></td>
                <td><?= Html::encode($h->comment) ?></td>
            </tr>
            <?php endforeach; ?>
        </tbody>
    </table>
    <?php endif; ?>
</div>
