<?php
/**
 * Список ПО.
 * @var yii\web\View $this
 * @var app\models\entities\Software[] $list
 */

use yii\helpers\Html;

$this->title = 'Учёт ПО и лицензий';
$this->params['breadcrumbs'][] = $this->title;
?>
<div class="software-index">
    <h1><?= Html::encode($this->title) ?></h1>
    <p><?= Html::a('Добавить ПО', ['create'], ['class' => 'btn btn-success']) ?></p>
    <div class="border rounded p-3 mb-3">
        <form method="get" class="row g-2 align-items-end">
            <div class="col-auto">
                <label class="form-label">Наименование</label>
                <input type="text" name="name" class="form-control" value="<?= Html::encode(Yii::$app->request->get('name')) ?>" placeholder="Поиск..." />
            </div>
            <div class="col-auto">
                <label class="form-label">Лицензии истекают в течение (дней)</label>
                <input type="number" name="expiring_days" class="form-control" value="<?= Html::encode(Yii::$app->request->get('expiring_days')) ?>" min="1" placeholder="30" style="width:90px" />
            </div>
            <div class="col-auto">
                <button type="submit" class="btn btn-primary">Фильтр</button>
            </div>
        </form>
    </div>
    <table class="table table-striped">
        <thead>
            <tr>
                <th>Наименование</th>
                <th>Версия</th>
                <th>Лицензии</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($list as $item): ?>
            <tr>
                <td><?= Html::a(Html::encode($item->name), ['view', 'id' => $item->id]) ?></td>
                <td><?= Html::encode($item->version ?: '—') ?></td>
                <td><?= count($item->licenses) ?> <?= Html::a('+', ['license-create', 'software_id' => $item->id], ['class' => 'btn btn-sm btn-outline-secondary']) ?></td>
            </tr>
            <?php endforeach; ?>
        </tbody>
    </table>
    <?php if (empty($list)): ?>
        <p class="text-muted">Нет записей. Добавьте ПО или восстановите БД из эталонного дампа.</p>
    <?php endif; ?>
</div>
