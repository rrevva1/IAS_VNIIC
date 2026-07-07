<?php
?>
<div class="modal fade delivery-bulk-modal" id="deliveryBulkModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered arm-view-modal__dialog">
        <div class="modal-content arm-view-modal">
            <div class="modal-header arm-view-modal__header">
                <h5 class="modal-title mb-0" id="deliveryBulkModalTitle">Массовый ввод</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Закрыть"></button>
            </div>
            <div class="modal-body arm-view-modal__body">
                <p class="text-muted small mb-2" id="deliveryBulkModalHint"></p>
                <textarea class="form-control" id="deliveryBulkText" rows="12" placeholder="По одному значению на строку"></textarea>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline-secondary arm-tool-btn" data-bs-dismiss="modal">Отмена</button>
                <button type="button" class="btn btn-primary arm-tool-btn" id="deliveryBulkApplyBtn">
                    <i class="fas fa-check" aria-hidden="true"></i>
                    Применить
                </button>
            </div>
        </div>
    </div>
</div>
