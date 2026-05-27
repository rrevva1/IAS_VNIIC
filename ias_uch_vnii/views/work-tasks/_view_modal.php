<?php
/**
 * Модальное окно просмотра задачи.
 */
?>
<div class="modal fade" id="workTaskViewModal" tabindex="-1" aria-labelledby="workTaskViewModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-scrollable modal-fullscreen-lg-down work-task-modal__dialog">
        <div class="modal-content work-task-modal work-task-view-modal">
            <div class="modal-header work-task-modal__header">
                <div id="workTaskViewModalHeader" class="work-task-modal__header-text">
                    <h5 class="modal-title mb-0" id="workTaskViewModalLabel">Задача</h5>
                    <p class="work-task-modal__subtitle mb-0" id="workTaskViewModalSubtitle"></p>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Закрыть"></button>
            </div>
            <div class="modal-body work-task-modal__body" id="workTaskViewModalBody">
                <div class="work-task-modal__loading text-center text-muted py-5">
                    <i class="fas fa-circle-notch fa-spin fa-2x" aria-hidden="true"></i>
                    <p class="mt-3 mb-0">Загрузка…</p>
                </div>
            </div>
            <div class="modal-footer work-task-modal__footer work-task-modal__footer--actions d-none" id="workTaskViewModalFooter"></div>
        </div>
    </div>
</div>
