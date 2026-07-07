<?php

use yii\helpers\Html;

/** @var string $createTitle заголовок при создании */
/** @var string $updateTitle заголовок при редактировании */

$createTitle = $createTitle ?? 'Добавить';
$updateTitle = $updateTitle ?? 'Редактировать';
?>
<div class="modal fade references-modal tasks-modal tasks-create-modal" id="refFormModal" tabindex="-1"
     aria-labelledby="refFormModalLabel" aria-hidden="true"
     data-bs-backdrop="true" data-bs-keyboard="true"
     data-create-title="<?= Html::encode($createTitle) ?>"
     data-update-title="<?= Html::encode($updateTitle) ?>">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable tasks-create-modal__dialog">
        <div class="modal-content">
            <div class="modal-header tasks-create-modal__header">
                <div class="tasks-create-modal__header-text">
                    <h5 class="modal-title" id="refFormModalLabel"><?= Html::encode($createTitle) ?></h5>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Закрыть"></button>
            </div>
            <div class="modal-body tasks-create-modal__body" id="refFormModalBody">
                <div class="tasks-create-modal__loading">
                    <i class="fas fa-spinner fa-spin" aria-hidden="true"></i>
                    <p>Загрузка формы…</p>
                </div>
            </div>
        </div>
    </div>
</div>
