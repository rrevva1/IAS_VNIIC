<?php
/**
 * Модальное окно просмотра карточки пользователя.
 */
?>
<div class="modal fade" id="usersViewModal" tabindex="-1" aria-labelledby="usersViewModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-fullscreen users-view-modal__dialog">
        <div class="modal-content users-view-modal">
            <div class="modal-header users-view-modal__header">
                <div id="usersViewModalHeader" class="users-view-modal__header-body">
                    <h5 class="modal-title mb-0 visually-hidden" id="usersViewModalLabel">Карточка пользователя</h5>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Закрыть"></button>
            </div>
            <div class="modal-body users-view-modal__body" id="usersViewModalBody">
                <div class="users-view-modal__loading text-center text-muted py-5">
                    <i class="fas fa-circle-notch fa-spin fa-2x" aria-hidden="true"></i>
                    <p class="mt-3 mb-0">Загрузка карточки…</p>
                </div>
            </div>
        </div>
    </div>
</div>
