<?php
/**
 * Карточка ПО.
 * @var yii\web\View $this
 * @var app\models\entities\Software $model
 */

use yii\helpers\Html;

$this->title = Html::encode($model->name);
$this->params['breadcrumbs'][] = ['label' => 'Учёт ПО и лицензий', 'url' => ['index']];
$this->params['breadcrumbs'][] = $this->title;
$daysWarning = 30;
?>
<div class="software-view">
    <h1><?= Html::encode($model->name) ?></h1>
    <p>
        <?= Html::a('Изменить', ['update', 'id' => $model->id], ['class' => 'btn btn-primary']) ?>
        <?= Html::a('Удалить', ['delete', 'id' => $model->id], ['class' => 'btn btn-danger', 'data' => ['confirm' => 'Удалить это ПО и все связанные лицензии и установки?', 'method' => 'post']]) ?>
    </p>
    <table class="table table-bordered">
        <tr><th>Версия</th><td><?= Html::encode($model->version ?: '—') ?></td></tr>
    </table>
    <h3>Лицензии <?= Html::a('Добавить', ['license-create', 'software_id' => $model->id], ['class' => 'btn btn-sm btn-success']) ?></h3>
    <?php
    $licenses = $model->licenses;
    if (empty($licenses)):
        echo '<p class="text-muted">Нет лицензий.</p>';
    else:
        echo '<table class="table table-striped"><thead><tr><th>Срок по</th><th>Примечание</th><th></th></tr></thead><tbody>';
        foreach ($licenses as $l) {
            $expiring = $l->valid_until && (strtotime($l->valid_until) - time()) / 86400 <= $daysWarning && (strtotime($l->valid_until) - time()) >= 0;
            $expired = $l->valid_until && strtotime($l->valid_until) < time();
            $row = '<tr>';
            $row .= '<td>' . Yii::$app->formatter->asDate($l->valid_until);
            if ($expired) $row .= ' <span class="badge bg-danger">Истекла</span>';
            elseif ($expiring) $row .= ' <span class="badge bg-warning">Скоро истекает</span>';
            $row .= '</td><td>' . Html::encode($l->notes ?: '—') . '</td>';
            $row .= '<td>' . Html::a('Изменить', ['license-update', 'id' => $l->id]) . ' ' . Html::a('Удалить', ['license-delete', 'id' => $l->id], ['data' => ['confirm' => 'Удалить лицензию?', 'method' => 'post']]) . '</td></tr>';
            echo $row;
        }
        echo '</tbody></table>';
    endif;
    ?>
    <h3>Установлено на оборудовании <?= Html::a('Добавить', ['equipment-software-create', 'software_id' => $model->id], ['class' => 'btn btn-sm btn-success']) ?></h3>
    <?php
    $installs = $model->equipmentSoftware;
    if (empty($installs)):
        echo '<p class="text-muted">Нет записей об установке.</p>';
    else:
        echo '<ul class="list-group">';
        foreach ($installs as $inst) {
            $eq = $inst->equipment;
            $line = $eq ? Html::a(Html::encode($eq->inventory_number . ' — ' . $eq->name), ['/arm/view', 'id' => $eq->id], ['target' => '_blank']) : '—';
            if ($inst->installed_at) {
                $line .= ' <span class="text-muted">(' . Yii::$app->formatter->asDate($inst->installed_at) . ')</span>';
            }
            $line .= ' ' . Html::a('Удалить', ['equipment-software-delete', 'id' => $inst->id], ['class' => 'btn btn-sm btn-outline-danger', 'data' => ['confirm' => 'Удалить связь?', 'method' => 'post']]);
            echo '<li class="list-group-item">' . $line . '</li>';
        }
        echo '</ul>';
    endif;
    ?>
</div>
