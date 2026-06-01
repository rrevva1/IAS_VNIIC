<?php
/**
 * Модальное окно просмотра карточки заявки.
 */
?>
<div class="modal fade" id="tasksViewModal" tabindex="-1" aria-labelledby="tasksViewModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable tasks-view-modal__dialog">
        <div class="modal-content tasks-view-modal">
            <div class="modal-header tasks-view-modal__header">
                <div id="tasksViewModalHeader" class="tasks-view-modal__header-body">
                    <div class="tasks-view-modal__header-icon" aria-hidden="true">
                        <i class="fas fa-clipboard-list"></i>
                    </div>
                    <div class="tasks-view-modal__header-text">
                        <p class="tasks-view-modal__eyebrow mb-0">Просмотр заявки</p>
                        <h5 class="modal-title mb-0" id="tasksViewModalLabel">Заявка</h5>
                    </div>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Закрыть"></button>
            </div>
            <div class="modal-body tasks-view-modal__body" id="tasksViewModalBody">
                <div class="tasks-view-modal__loading text-center text-muted py-5">
                    <i class="fas fa-circle-notch fa-spin fa-2x text-primary" aria-hidden="true"></i>
                    <p class="mt-3 mb-0">Загрузка карточки…</p>
                </div>
            </div>
            <div class="modal-footer tasks-view-modal__footer d-none" id="tasksViewModalFooter"></div>
        </div>
    </div>
</div>
