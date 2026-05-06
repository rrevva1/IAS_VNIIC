<?php

use yii\helpers\Html;

/* @var $this yii\web\View */
/* @var string $message */
/* @var array $protocol */

$this->title = 'Импорт из Excel (лист АРМ)';
$this->params['breadcrumbs'][] = $this->title;
?>

<div class="import-index">
    <h1><?= Html::encode($this->title) ?></h1>
    <p class="text-muted">Загрузите файл Excel с листом «АРМ». Колонки: A=Пользователь, B=Отдел, C=Помещение, D=ЦП, E=ОЗУ, F=Диск, G=Системный блок, H=—, I=№ системн. блока (см. регламент парсинга).</p>

    <?php if ($message): ?>
        <div class="alert alert-info"><?= Html::encode($message) ?></div>
    <?php endif; ?>

    <?php $form = \yii\widgets\ActiveForm::begin(['options' => ['enctype' => 'multipart/form-data']]); ?>
    <div class="form-group">
        <label>Файл Excel</label>
        <input type="file" name="excel_file" accept=".xlsx,.xls" class="form-control">
    </div>
    <?= Html::submitButton('Загрузить', ['class' => 'btn btn-primary']) ?>
    <?php \yii\widgets\ActiveForm::end(); ?>

    <?php if (!empty($protocol['messages'])): ?>
        <h3>Протокол</h3>
        <ul class="list-group">
            <?php foreach (array_slice($protocol['messages'], 0, 50) as $msg): ?>
                <li class="list-group-item"><?= Html::encode($msg) ?></li>
            <?php endforeach; ?>
        </ul>
        <?php if (count($protocol['messages']) > 50): ?>
            <p>… и ещё <?= count($protocol['messages']) - 50 ?> записей.</p>
        <?php endif; ?>
    <?php endif; ?>
</div>
