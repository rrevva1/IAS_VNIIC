<?php
/**
 * Модальное окно редактирования собственного профиля.
 */
?>
<div class="modal fade profile-edit-modal" id="profileEditModal" tabindex="-1"
     aria-labelledby="profileEditModalLabel" aria-hidden="true"
     data-bs-backdrop="true" data-bs-keyboard="true">
    <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable profile-edit-modal__dialog">
        <div class="modal-content profile-edit-modal__content">
            <div class="modal-header profile-edit-modal__header">
                <div>
                    <h5 class="modal-title" id="profileEditModalLabel">Редактирование профиля</h5>
                    <p class="profile-edit-modal__lead">Контактные данные и смена пароля</p>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Закрыть"></button>
            </div>
            <div class="modal-body profile-edit-modal__body" id="profileEditModalBody">
                <div class="profile-edit-modal__loading text-center text-muted py-4">
                    <i class="fas fa-circle-notch fa-spin fa-2x" aria-hidden="true"></i>
                    <p class="mt-3 mb-0">Загрузка формы…</p>
                </div>
            </div>
        </div>
    </div>
</div>
