<?php
/**
 * Модальное окно: закреплённая техника пользователя.
 */
?>
<div class="modal fade uec-user-equipment-modal" id="uecUserEquipmentModal" tabindex="-1"
     aria-labelledby="uecUserEquipmentModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable uec-user-equipment-modal__dialog">
        <div class="modal-content uec-user-equipment-modal__content">
            <div class="modal-header uec-user-equipment-modal__header">
                <div class="uec-user-equipment-modal__header-main">
                    <div class="uec-user-equipment-modal__header-icon" aria-hidden="true">
                        <i class="fas fa-desktop"></i>
                    </div>
                    <div class="uec-user-equipment-modal__header-text">
                        <h5 class="modal-title" id="uecUserEquipmentModalLabel">Закреплённая техника</h5>
                        <p class="uec-user-equipment-modal__subtitle" id="uecUserEquipmentModalSubtitle">—</p>
                    </div>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Закрыть"></button>
            </div>
            <div class="modal-body uec-user-equipment-modal__body" id="uecUserEquipmentModalBody">
                <div class="uec-user-equipment-modal__loading">
                    <i class="fas fa-circle-notch fa-spin" aria-hidden="true"></i>
                    <p>Загрузка списка техники…</p>
                </div>
            </div>
            <div class="modal-footer uec-user-equipment-modal__footer">
                <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Закрыть</button>
            </div>
        </div>
    </div>
</div>
