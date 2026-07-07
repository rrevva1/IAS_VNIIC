<?php
/**
 * Модальное окно просмотра фотографии техники.
 */
?>
<div class="modal fade arm-photo-preview-modal" id="armPhotoPreviewModal" tabindex="-1" aria-labelledby="armPhotoPreviewModalTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-xl">
        <div class="modal-content">
            <div class="modal-header py-2">
                <h5 class="modal-title" id="armPhotoPreviewModalTitle">Фотография</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Закрыть"></button>
            </div>
            <div class="modal-body arm-photo-preview-modal__body">
                <img id="armPhotoPreviewModalImage" class="arm-photo-preview-modal__image" src="" alt="">
            </div>
            <div class="modal-footer py-2">
                <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Закрыть</button>
                <a href="#" class="btn btn-primary" id="armPhotoPreviewModalDownload" target="_blank" rel="noopener">
                    <i class="fas fa-download" aria-hidden="true"></i>
                    Скачать изображение
                </a>
            </div>
        </div>
    </div>
</div>
