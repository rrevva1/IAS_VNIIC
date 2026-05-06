<?php
use yii\helpers\Html;
$this->title = 'Требуется миграция';
$this->params['breadcrumbs'][] = $this->title;
?>
<div class="software-migrate-required">
    <h1><?= Html::encode($this->title) ?></h1>
    <p class="alert alert-warning">Таблицы <code>software</code>, <code>licenses</code>, <code>equipment_software</code> не найдены в БД. Выполните миграции или восстановите БД из эталонного дампа <code>ias_vniic_14_02_26.sql</code>.</p>
    <p><?= Html::a('К списку', ['index'], ['class' => 'btn btn-secondary']) ?></p>
</div>
