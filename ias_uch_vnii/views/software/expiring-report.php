<?php
/**
 * Отчёт: лицензии с истекающим сроком и просроченные.
 * @var yii\web\View $this
 * @var app\models\entities\License[] $expired
 * @var app\models\entities\License[] $expiring
 * @var int $days
 */

use yii\helpers\Html;
use yii\helpers\Url;

$this->title = 'Лицензии: истекающие и просроченные';
$this->params['breadcrumbs'][] = ['label' => 'ПО и лицензии', 'url' => ['software/index']];
$this->params['breadcrumbs'][] = $this->title;
?>
<div class="software-expiring-report">
    <h1><?= Html::encode($this->title) ?></h1>
    <p class="text-muted">
        Просроченные лицензии и лицензии, срок которых истекает в течение указанного числа дней.
        <?= Html::a('К списку ПО', ['software/index'], ['class' => 'btn btn-default']) ?>
        <button type="button" class="btn btn-default" onclick="window.print();">Печать / Сохранить как PDF</button>
    </p>

    <form method="get" action="<?= Html::encode(Url::to(['software/expiring-report'])) ?>" class="form-inline mb-4">
        <label class="mr-2">Показывать истекающие в течение</label>
        <input type="number" name="days" value="<?= (int) $days ?>" min="1" max="365" class="form-control mr-2" style="width:80px">
        <label class="mr-2">дней</label>
        <button type="submit" class="btn btn-primary">Обновить</button>
    </form>

    <?php if (!empty($expired)): ?>
    <h2>Просроченные лицензии</h2>
    <table class="table table-bordered table-striped">
        <thead>
            <tr>
                <th>ПО</th>
                <th>Срок действия по</th>
                <th>Примечание</th>
                <th></th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($expired as $l): ?>
            <tr>
                <td><?= Html::encode($l->software ? $l->software->name : '—') ?></td>
                <td><?= Yii::$app->formatter->asDate($l->valid_until) ?></td>
                <td><?= Html::encode($l->notes ?: '') ?></td>
                <td><?= Html::a('Карточка ПО', ['software/view', 'id' => $l->software_id], ['class' => 'btn btn-xs btn-default']) ?></td>
            </tr>
            <?php endforeach; ?>
        </tbody>
    </table>
    <?php else: ?>
    <p>Просроченных лицензий нет.</p>
    <?php endif; ?>

    <?php if (!empty($expiring)): ?>
    <h2>Истекают в течение <?= (int) $days ?> дней</h2>
    <table class="table table-bordered table-striped">
        <thead>
            <tr>
                <th>ПО</th>
                <th>Срок действия по</th>
                <th>Примечание</th>
                <th></th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($expiring as $l): ?>
            <tr>
                <td><?= Html::encode($l->software ? $l->software->name : '—') ?></td>
                <td><?= Yii::$app->formatter->asDate($l->valid_until) ?></td>
                <td><?= Html::encode($l->notes ?: '') ?></td>
                <td><?= Html::a('Карточка ПО', ['software/view', 'id' => $l->software_id], ['class' => 'btn btn-xs btn-default']) ?></td>
            </tr>
            <?php endforeach; ?>
        </tbody>
    </table>
    <?php else: ?>
    <p>Лицензий, истекающих в указанный период, нет.</p>
    <?php endif; ?>
</div>
