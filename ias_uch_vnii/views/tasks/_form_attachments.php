<?php

use yii\helpers\Html;
use yii\widgets\ActiveForm;

/** @var ActiveForm $form */
/** @var yii\base\Model $model */
/** @var string $inputName */
/** @var string $inputId */
/** @var bool $compact */

$compact = !empty($compact);
$sectionClass = 'tasks-create-form__section' . ($compact ? ' tasks-create-form__section--compact' : '');
?>
<div class="<?= Html::encode($sectionClass) ?>">
    <?php if (!$compact): ?>
    <span class="tasks-create-form__label">
        <i class="fas fa-paperclip" aria-hidden="true"></i>
        Вложения <span class="tasks-create-form__optional">(необязательно)</span>
    </span>
    <?php endif; ?>

    <div class="tasks-file-drop" data-tasks-file-drop role="button" tabindex="0" aria-label="Выбрать файлы">
        <div class="tasks-file-drop__icon" aria-hidden="true">
            <i class="fas fa-cloud-arrow-up"></i>
        </div>
        <p class="tasks-file-drop__title"><?= $compact ? 'Нажмите или перетащите файлы' : 'Перетащите файлы сюда или нажмите для выбора' ?></p>
        <p class="tasks-file-drop__formats"><?= $compact ? 'До 10 файлов' : 'Изображения, PDF, Word, Excel, текст — до 10 файлов' ?></p>
        <?= $form->field($model, 'uploadFiles', ['options' => ['class' => 'mb-0 tasks-file-drop__field']])->fileInput([
            'multiple' => true,
            'accept' => 'image/*,application/pdf,.doc,.docx,.xls,.xlsx,.txt',
            'class' => 'tasks-file-drop__input',
            'id' => $inputId,
            'name' => $inputName,
            'data-tasks-file-input' => '1',
        ])->label(false) ?>
    </div>

    <div class="tasks-files-list" data-tasks-files-list hidden>
        <div class="tasks-files-list__head">
            <strong>Выбранные файлы</strong>
            <button type="button" class="btn btn-sm btn-link text-danger clear-files-btn p-0">Очистить</button>
        </div>
        <ul class="tasks-files-list__items" data-tasks-files-container></ul>
    </div>
</div>
