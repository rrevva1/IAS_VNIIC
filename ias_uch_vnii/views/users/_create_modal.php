<?php

use yii\helpers\Html;

/** @var app\models\entities\Users $model */
/** @var array $roleItems */
?>
<div class="modal fade users-modal users-create-modal" id="userFormModal" tabindex="-1" aria-labelledby="userFormModalLabel">
    <div class="modal-dialog modal-lg modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header users-create-modal__header">
                <div>
                    <h5 class="modal-title" id="userFormModalLabel">Новый пользователь</h5>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Закрыть"></button>
            </div>
            <div class="modal-body users-create-modal__body" id="userFormModalBody">
                <div class="users-grid-loading">
                    <i class="fas fa-spinner fa-spin" aria-hidden="true"></i>
                    <p>Загрузка формы…</p>
                </div>
            </div>
        </div>
    </div>
</div>
