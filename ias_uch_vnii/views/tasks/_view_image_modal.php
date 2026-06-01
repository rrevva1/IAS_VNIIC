<?php
/**
 * Модальное окно предпросмотра изображения вложения заявки.
 */
?>
<div class="modal fade tasks-modal" id="imageModal" tabindex="-1" aria-labelledby="imageModalLabel">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="imageModalLabel"><i class="fas fa-image" aria-hidden="true"></i> Просмотр изображения</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Закрыть"></button>
            </div>
            <div class="modal-body text-center">
                <img id="modalImage" src="" alt="" class="img-fluid">
                <p id="modalImageName" class="text-muted mt-2 mb-0"></p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Закрыть</button>
                <a id="modalDownloadBtn" href="#" class="btn btn-primary">
                    <i class="fas fa-download" aria-hidden="true"></i> Скачать
                </a>
            </div>
        </div>
    </div>
</div>
