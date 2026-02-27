<?php

use yii\helpers\Html;

/* @var $this yii\web\View */
/* @var string $message */
/* @var array $protocol */

$this->title = 'Универсальный импорт';
$this->params['breadcrumbs'][] = ['label' => 'Импорт', 'url' => ['import/index']];
$this->params['breadcrumbs'][] = $this->title;
?>

<div class="import-universal">
    <h1><?= Html::encode($this->title) ?></h1>
    <p class="text-muted">
        Поддерживаемые форматы: CSV (разделитель «;» или «,»), JSON, XML, XLSX. Кодировка UTF-8.
        Сущность: оборудование (equipment). Ожидаемые поля: <code>inventory_number</code> (или <code>inv</code>), <code>name</code>, <code>location</code> (название помещения), опционально <code>description</code>, <code>status_id</code>.
        При совпадении инв. номера запись обновляется.
    </p>

    <?php if ($message !== ''): ?>
        <div class="alert alert-info"><?= Html::encode($message) ?></div>
    <?php endif; ?>

    <?php $form = \yii\widgets\ActiveForm::begin([
        'id' => 'universal-import-form',
        'options' => ['enctype' => 'multipart/form-data'],
        'action' => ['import/universal'],
        'method' => 'post',
    ]); ?>
    <div class="row">
        <div class="col-md-4">
            <div class="form-group">
                <label>Формат</label>
                <select name="format" class="form-control" required>
                    <option value="csv">CSV</option>
                    <option value="json">JSON</option>
                    <option value="xml">XML</option>
                    <option value="xlsx">XLSX</option>
                </select>
            </div>
        </div>
        <div class="col-md-4">
            <div class="form-group">
                <label>Сущность</label>
                <select name="entity" class="form-control">
                    <option value="equipment">Оборудование</option>
                </select>
            </div>
        </div>
        <div class="col-md-4">
            <div class="form-group">
                <label>Файл</label>
                <input type="file" name="import_file" accept=".csv,.json,.xml,.xlsx" class="form-control" required>
            </div>
        </div>
    </div>
    <?= Html::submitButton('Импортировать', ['class' => 'btn btn-primary']) ?>
    <?= Html::a('Импорт из Excel (лист АРМ)', ['import/index'], ['class' => 'btn btn-default']) ?>
    <?php \yii\widgets\ActiveForm::end(); ?>

    <?php if (!empty($protocol['messages'])): ?>
        <h3>Протокол</h3>
        <ul class="list-group">
            <?php foreach (array_slice($protocol['messages'], 0, 100) as $msg): ?>
                <li class="list-group-item"><?= Html::encode($msg) ?></li>
            <?php endforeach; ?>
        </ul>
        <?php if (count($protocol['messages']) > 100): ?>
            <p>… и ещё <?= count($protocol['messages']) - 100 ?> записей.</p>
        <?php endif; ?>
    <?php endif; ?>
</div>
