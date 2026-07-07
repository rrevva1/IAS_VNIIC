/**
 * Фотографии техники: загрузка, удаление, просмотр в галерее.
 */
(function() {
    'use strict';

    var previewModalInstance = null;
    var boundGalleryElements = typeof WeakSet !== 'undefined' ? new WeakSet() : null;
    var boundGalleryElementIds = [];
    var boundDeleteContainers = typeof WeakSet !== 'undefined' ? new WeakSet() : null;
    var boundDeleteContainerIds = [];

    function csrfToken() {
        var meta = document.querySelector('meta[name="csrf-token"]');
        return meta ? meta.content : '';
    }

    function csrfParam() {
        var meta = document.querySelector('meta[name="csrf-param"]');
        return meta ? meta.getAttribute('content') : '_csrf';
    }

    function apiUrl(action, equipmentId) {
        return '/index.php?r=arm/' + action + '&id=' + encodeURIComponent(equipmentId);
    }

    function escapeHtml(str) {
        var div = document.createElement('div');
        div.textContent = str == null ? '' : String(str);
        return div.innerHTML;
    }

    function showToast(type, message) {
        if (!message) {
            return;
        }
        var alertClass = type === 'success' ? 'alert-success' : 'alert-danger';
        var alertEl = document.createElement('div');
        alertEl.className = 'alert ' + alertClass + ' alert-dismissible fade show';
        alertEl.setAttribute('role', 'alert');
        alertEl.style.cssText = 'position:fixed;top:20px;right:20px;z-index:10060;min-width:300px;max-width:420px;';
        alertEl.innerHTML = escapeHtml(message)
            + '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Закрыть"></button>';
        document.body.appendChild(alertEl);
        window.setTimeout(function() {
            if (alertEl.parentNode && typeof bootstrap !== 'undefined') {
                bootstrap.Alert.getOrCreateInstance(alertEl).close();
            }
        }, 5000);
    }

    function postFormData(url, formData) {
        var token = csrfToken();
        var param = csrfParam();
        if (token && param) {
            formData.append(param, token);
        }
        return fetch(url, {
            method: 'POST',
            body: formData,
            credentials: 'same-origin',
            headers: { 'X-Requested-With': 'XMLHttpRequest' },
        }).then(function(r) { return r.json(); });
    }

    function renderGallery(galleryEl, photos, canEdit) {
        if (!galleryEl) {
            return;
        }
        if (!photos || photos.length === 0) {
            galleryEl.innerHTML = '<p class="text-muted small mb-0 arm-photos-gallery__empty">Фотографии не прикреплены.</p>';
            return;
        }
        var html = '<div class="arm-photos-gallery__grid">';
        photos.forEach(function(photo) {
            var id = photo.id;
            var name = escapeHtml(photo.original_name || '');
            var previewUrl = escapeHtml(photo.preview_url || '');
            var downloadUrl = escapeHtml(photo.download_url || '');
            html += '<figure class="arm-photos-gallery__item" data-attachment-id="' + id + '">'
                + '<button type="button" class="arm-photos-gallery__thumb-btn"'
                + ' data-arm-photo-preview="' + previewUrl + '"'
                + ' data-arm-photo-download="' + downloadUrl + '"'
                + ' data-arm-photo-name="' + name + '"'
                + ' title="' + name + '">'
                + '<img src="' + previewUrl + '" alt="' + name + '" class="arm-photos-gallery__thumb" loading="lazy">'
                + '</button>';
            if (canEdit) {
                html += '<button type="button" class="btn btn-sm btn-outline-danger arm-photos-gallery__delete"'
                    + ' data-arm-photo-delete="' + id + '" title="Удалить фото">'
                    + '<i class="fas fa-trash" aria-hidden="true"></i>'
                    + '</button>';
            }
            html += '</figure>';
        });
        html += '</div>';
        galleryEl.innerHTML = html;
    }

    function openPhotoPreview(url, name, downloadUrl) {
        if (!url) {
            return;
        }
        var modalEl = document.getElementById('armPhotoPreviewModal');
        var imgEl = document.getElementById('armPhotoPreviewModalImage');
        var titleEl = document.getElementById('armPhotoPreviewModalTitle');
        var downloadEl = document.getElementById('armPhotoPreviewModalDownload');
        if (!modalEl || !imgEl) {
            window.open(downloadUrl || url, '_blank', 'noopener');
            return;
        }
        if (titleEl) {
            titleEl.textContent = name || 'Фотография';
        }
        imgEl.src = url;
        imgEl.alt = name || '';
        if (downloadEl) {
            downloadEl.setAttribute('href', downloadUrl || url);
        }
        if (typeof bootstrap === 'undefined' || !bootstrap.Modal) {
            window.open(url, '_blank', 'noopener');
            return;
        }
        if (!previewModalInstance) {
            previewModalInstance = bootstrap.Modal.getOrCreateInstance(modalEl, {
                backdrop: true,
                keyboard: true,
                focus: true,
            });
        }
        modalEl.addEventListener('hidden.bs.modal', function() {
            imgEl.removeAttribute('src');
        }, { once: true });
        previewModalInstance.show();
    }

    function isBound(set, list, item) {
        if (set) {
            return set.has(item);
        }
        return list.indexOf(item) !== -1;
    }

    function markBound(set, list, item) {
        if (set) {
            set.add(item);
            return;
        }
        if (list.indexOf(item) === -1) {
            list.push(item);
        }
    }

    function resolveEquipmentContext(container) {
        if (!container) {
            return null;
        }
        var equipmentRoot = container.querySelector('.arm-view[data-equipment-id]')
            || container.querySelector('.arm-form--modal[data-equipment-id]');
        if (!equipmentRoot) {
            return null;
        }
        var equipmentId = equipmentRoot.getAttribute('data-equipment-id');
        if (!equipmentId) {
            return null;
        }
        return {
            equipmentId: equipmentId,
            canEdit: equipmentRoot.getAttribute('data-can-edit-photos') === '1',
        };
    }

    function bindGalleryPreviews(container) {
        if (!container) {
            return;
        }
        container.querySelectorAll('[data-arm-photos-gallery]').forEach(function(gallery) {
            if (isBound(boundGalleryElements, boundGalleryElementIds, gallery)) {
                return;
            }
            markBound(boundGalleryElements, boundGalleryElementIds, gallery);
            gallery.addEventListener('click', function(e) {
                var thumbBtn = e.target.closest('.arm-photos-gallery__thumb-btn');
                if (!thumbBtn) {
                    return;
                }
                e.preventDefault();
                e.stopPropagation();
                openPhotoPreview(
                    thumbBtn.getAttribute('data-arm-photo-preview'),
                    thumbBtn.getAttribute('data-arm-photo-name'),
                    thumbBtn.getAttribute('data-arm-photo-download')
                );
            });
        });
    }

    function bindGalleryDelete(container) {
        if (!container || isBound(boundDeleteContainers, boundDeleteContainerIds, container)) {
            return;
        }
        markBound(boundDeleteContainers, boundDeleteContainerIds, container);

        container.addEventListener('click', function(e) {
            var context = resolveEquipmentContext(container);
            if (!context || !context.canEdit) {
                return;
            }
            var deleteBtn = e.target.closest('[data-arm-photo-delete]');
            if (!deleteBtn) {
                return;
            }
            e.preventDefault();
            e.stopPropagation();
            var attachmentId = deleteBtn.getAttribute('data-arm-photo-delete');
            if (!attachmentId || !window.confirm('Удалить фотографию?')) {
                return;
            }
            var data = new FormData();
            data.append('attachment_id', attachmentId);
            postFormData(apiUrl('delete-photo', context.equipmentId), data).then(function(res) {
                if (res && res.success && res.photos) {
                    var gallery = container.querySelector('[data-arm-photos-gallery]');
                    renderGallery(gallery, res.photos, context.canEdit);
                }
                showToast(res && res.success ? 'success' : 'error', (res && res.message) || '');
            });
        });
    }

    function bindUpload(container) {
        var context = resolveEquipmentContext(container);
        if (!context || !context.canEdit) {
            return;
        }
        var input = container.querySelector('[data-arm-photo-input]');
        var uploadBtn = container.querySelector('[data-arm-photo-upload]');
        var gallery = container.querySelector('[data-arm-photos-gallery]');
        if (!uploadBtn || !input) {
            return;
        }

        uploadBtn.onclick = function() {
            var uploadContext = resolveEquipmentContext(container);
            if (!uploadContext || !uploadContext.canEdit) {
                return;
            }
            if (!input.files || input.files.length === 0) {
                showToast('error', 'Выберите файлы для загрузки.');
                return;
            }
            var data = new FormData();
            Array.prototype.forEach.call(input.files, function(file) {
                data.append('uploadPhotos[]', file);
            });
            uploadBtn.disabled = true;
            postFormData(apiUrl('upload-photo', uploadContext.equipmentId), data)
                .then(function(res) {
                    if (res && res.success && res.photos) {
                        renderGallery(gallery, res.photos, true);
                        input.value = '';
                        if (window.ArmView && window.ArmView.isOpen && window.ArmView.isOpen()
                            && String(window.ArmView.getEquipmentId()) === String(uploadContext.equipmentId)) {
                            window.ArmView.reload();
                        }
                    }
                    showToast(res && res.success ? 'success' : 'error', (res && res.message) || '');
                })
                .finally(function() {
                    uploadBtn.disabled = false;
                });
        };
    }

    window.bindArmAttachments = function(container) {
        container = container || document;
        bindGalleryPreviews(container);
        bindGalleryDelete(container);
        bindUpload(container);
    };

    window.syncArmPhotosCardMinHeight = function(container) {
        container = container || document.getElementById('createArmModalBody');
        if (!container) {
            return;
        }
        var purchaseCard = container.querySelector('[aria-labelledby="arm-create-section-purchase"]');
        var photosCard = container.querySelector('.arm-equipment-photos-form');
        if (!purchaseCard || !photosCard) {
            return;
        }
        var purchaseHeight = purchaseCard.offsetHeight;
        if (purchaseHeight > 0) {
            photosCard.style.minHeight = purchaseHeight + 'px';
        }
    };

    window.openArmPhotoPreview = openPhotoPreview;
})();
