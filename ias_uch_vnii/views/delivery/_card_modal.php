<?php
/**
 * Модальное окно карточки поставки (оформление как карточка техники).
 */
?>
<div class="modal fade" id="deliveryCardModal" tabindex="-1" aria-labelledby="deliveryCardModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-fullscreen arm-create-modal__dialog arm-view-modal__dialog arm-reassign-modal__dialog">
        <div class="modal-content arm-create-modal arm-view-modal arm-reassign-modal delivery-card-modal">
            <div class="modal-header arm-reassign-modal__header arm-view-modal__header arm-create-modal__header">
                <div id="deliveryCardModalHeader" class="arm-view-modal__header-body">
                    <h5 class="modal-title mb-0" id="deliveryCardModalLabel">Поставка</h5>
                    <p class="text-muted small mb-0 mt-1" id="deliveryCardModalSubtitle">Загрузка…</p>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Закрыть"></button>
            </div>
            <div class="modal-body arm-reassign-modal__body arm-view-modal__body arm-create-modal__body" id="deliveryCardModalBody">
                <div class="arm-view-modal__loading text-center text-muted py-5">
                    <i class="fas fa-circle-notch fa-spin fa-2x" aria-hidden="true"></i>
                    <p class="mt-3 mb-0">Загрузка карточки…</p>
                </div>
            </div>
        </div>
    </div>
</div>
