<?php

use app\assets\SectionPageAsset;
use yii\helpers\Html;
use yii\widgets\ActiveForm;

/** @var yii\web\View $this */
/** @var string $message */
/** @var array $protocol */

SectionPageAsset::register($this);

$this->title = 'Импорт ОУ';
$this->params['breadcrumbs'] = [];
?>
<div class="arm-page import-page">
    <header class="arm-page__header">
        <div class="arm-page__heading">
            <h1 class="arm-page__title"><?= Html::encode($this->title) ?></h1>
        </div>
    </header>

    <div class="arm-grid-card arm-content-panel">
        <?php if ($message): ?>
            <div class="alert alert-info"><?= Html::encode($message) ?></div>
        <?php endif; ?>

        <?php $form = ActiveForm::begin(['options' => ['enctype' => 'multipart/form-data', 'class' => 'import-form']]); ?>
        <div class="mb-3">
            <label class="form-label" for="import-excel-file">Файл Excel</label>
            <input type="file" name="excel_file" id="import-excel-file" accept=".xlsx,.xls" class="form-control">
        </div>
        <?= Html::submitButton('<i class="fas fa-upload me-1" aria-hidden="true"></i> Загрузить', ['class' => 'btn btn-primary']) ?>
        <?php ActiveForm::end(); ?>

        <?php if (!empty($protocol['messages'])): ?>
            <div class="import-protocol">
                <h2 class="h5 mb-3">Протокол</h2>
                <ul class="import-protocol__list">
                    <?php foreach (array_slice($protocol['messages'], 0, 50) as $msg): ?>
                        <li class="import-protocol__item"><?= Html::encode($msg) ?></li>
                    <?php endforeach; ?>
                </ul>
                <?php if (count($protocol['messages']) > 50): ?>
                    <p class="text-muted small mb-0 mt-2">
                        … и ещё <?= (int) count($protocol['messages']) - 50 ?> записей.
                    </p>
                <?php endif; ?>
            </div>
        <?php endif; ?>
    </div>
</div>
