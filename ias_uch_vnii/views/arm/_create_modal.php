<?php
/**
 * Модальное окно добавления техники (оформление как карточка просмотра).
 */
?>
<div class="modal fade" id="createArmModal" tabindex="-1" aria-labelledby="createArmModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-fullscreen arm-create-modal__dialog arm-view-modal__dialog arm-reassign-modal__dialog">
        <div class="modal-content arm-create-modal arm-view-modal arm-reassign-modal">
            <div class="modal-header arm-reassign-modal__header arm-view-modal__header arm-create-modal__header">
                <div id="createArmModalHeader" class="arm-view-modal__header-body">
                    <h5 class="modal-title mb-0" id="createArmModalLabel">
                        <i class="fas fa-plus" aria-hidden="true"></i>
                        Добавление техники
                    </h5>
                    <p class="text-muted small mb-0 mt-1" id="createArmModalSubtitle">Новая запись в учёте технических средств</p>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Закрыть"></button>
            </div>
            <div class="modal-body arm-reassign-modal__body arm-view-modal__body arm-create-modal__body" id="createArmModalBody">
                <div class="arm-view-modal__loading text-center text-muted py-5">
                    <i class="fas fa-circle-notch fa-spin fa-2x" aria-hidden="true"></i>
                    <p class="mt-3 mb-0">Загрузка формы…</p>
                </div>
            </div>
            <div class="modal-footer arm-reassign-modal__footer arm-create-modal__footer">
                <button type="button" class="btn btn-outline-secondary arm-tool-btn" data-bs-dismiss="modal">
                    <i class="fas fa-xmark" aria-hidden="true"></i>
                    Отмена
                </button>
                <button type="button" class="btn btn-primary arm-tool-btn" id="submit-arm-create-btn">
                    <i class="fas fa-check" aria-hidden="true"></i>
                    Сохранить
                </button>
            </div>
        </div>
    </div>
</div>
