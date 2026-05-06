<?php
use yii\helpers\Html;
$this->title = 'Справочники';
$this->params['breadcrumbs'][] = $this->title;
?>
<div class="references-index">
    <h1><?= Html::encode($this->title) ?></h1>
    <p class="lead">Выберите справочник для просмотра и редактирования.</p>
    <ul class="list-group">
        <li class="list-group-item">
            <?= Html::a('Статусы заявок', ['task-status'], ['class' => '']) ?>
            <span class="text-muted"> — статусы жизненного цикла заявки Help Desk</span>
        </li>
        <li class="list-group-item">
            <?= Html::a('Локации', ['locations'], ['class' => '']) ?>
            <span class="text-muted"> — помещения, кабинеты, склады</span>
        </li>
        <li class="list-group-item">
            <?= Html::a('Статусы оборудования', ['equipment-status'], ['class' => '']) ?>
            <span class="text-muted"> — эксплуатационный статус актива</span>
        </li>
        <li class="list-group-item">
            <?= Html::a('Типы частей (комплектующие)', ['parts'], ['class' => '']) ?>
            <span class="text-muted"> — справочник составных частей техники (ЦП, ОЗУ, Монитор и т.д.)</span>
        </li>
        <li class="list-group-item">
            <?= Html::a('Характеристики', ['chars'], ['class' => '']) ?>
            <span class="text-muted"> — наименования характеристик для учёта ТС (модель, объём, Имя ПК, ОС и т.д.)</span>
        </li>
    </ul>
</div>
