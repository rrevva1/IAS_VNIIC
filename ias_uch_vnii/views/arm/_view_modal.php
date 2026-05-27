<?php
/**
 * Модальное окно просмотра карточки техники.
 */
?>
<div class="modal fade" id="armViewModal" tabindex="-1" aria-labelledby="armViewModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-fullscreen arm-view-modal__dialog arm-reassign-modal__dialog">
        <div class="modal-content arm-view-modal arm-reassign-modal">
            <div class="modal-header arm-reassign-modal__header arm-view-modal__header">
                <div id="armViewModalHeader" class="arm-view-modal__header-body">
                    <h5 class="modal-title mb-0" id="armViewModalLabel">Карточка техники</h5>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Закрыть"></button>
            </div>
            <div class="modal-body arm-reassign-modal__body arm-view-modal__body" id="armViewModalBody">
                <div class="arm-view-modal__loading text-center text-muted py-5">
                    <i class="fas fa-circle-notch fa-spin fa-2x" aria-hidden="true"></i>
                    <p class="mt-3 mb-0">Загрузка карточки…</p>
                </div>
            </div>
        </div>
    </div>
</div>
