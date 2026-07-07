/**
 * Документы поставки: загрузка и удаление вложений.
 */
(function() {
    'use strict';

    function csrfToken() {
        var meta = document.querySelector('meta[name="csrf-token"]');
        return meta ? meta.content : '';
    }

    function csrfParam() {
        var meta = document.querySelector('meta[name="csrf-param"]');
        return meta ? meta.getAttribute('content') : '_csrf';
    }

    function apiUrl(action, deliveryId) {
        return '/index.php?r=delivery/' + action + '&id=' + encodeURIComponent(deliveryId);
    }

    function escapeHtml(str) {
        var div = document.createElement('div');
        div.textContent = str;
        return div.innerHTML;
    }

    function renderList(listEl, items, deliveryId, canEdit) {
        if (!listEl) {
            return;
        }
        if (!items || items.length === 0) {
            listEl.innerHTML = '<li class="text-muted small delivery-attachments-list__empty">Документы не прикреплены.</li>';
            return;
        }
        var html = '';
        items.forEach(function(item) {
            var id = item.id;
            var name = escapeHtml(item.original_name || '');
            var size = escapeHtml(item.size_label || '');
            var icon = escapeHtml(item.icon || 'fa-file');
            var href = item.is_preview
                ? apiUrl('preview-attachment', deliveryId) + '&attachmentId=' + encodeURIComponent(id)
                : apiUrl('download-attachment', deliveryId) + '&attachmentId=' + encodeURIComponent(id);
            var target = item.is_preview ? ' target="_blank" rel="noopener"' : '';
            html += '<li class="delivery-attachments-list__item" data-attachment-id="' + id + '">'
                + '<i class="fas ' + icon + '" aria-hidden="true"></i> '
                + '<a href="' + href + '" class="delivery-attachments-list__link"' + target + '>' + name + '</a> '
                + '<span class="text-muted small">' + size + '</span>';
            if (canEdit) {
                html += ' <button type="button" class="btn btn-link btn-sm text-danger p-0 delivery-attachments-list__delete"'
                    + ' data-delivery-attachment-delete="' + id + '" title="Удалить файл">'
                    + '<i class="fas fa-trash" aria-hidden="true"></i></button>';
            }
            html += '</li>';
        });
        listEl.innerHTML = html;
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

    window.bindDeliveryAttachments = function() {
        var root = document.querySelector('#deliveryCardModalBody .delivery-card-content');
        if (!root) {
            return;
        }
        var deliveryId = root.getAttribute('data-delivery-id');
        var canEditAttachments = root.getAttribute('data-can-edit-attachments') === '1';
        if (!deliveryId) {
            return;
        }

        var listEl = document.getElementById('deliveryAttachmentsList');
        var input = document.getElementById('deliveryAttachmentInput');
        var uploadBtn = document.getElementById('deliveryAttachmentUploadBtn');

        if (uploadBtn && input && canEditAttachments) {
            uploadBtn.onclick = function() {
                if (!input.files || input.files.length === 0) {
                    return;
                }
                var data = new FormData();
                Array.prototype.forEach.call(input.files, function(file) {
                    data.append('uploadFiles[]', file);
                });
                uploadBtn.disabled = true;
                postFormData(apiUrl('upload-attachment', deliveryId), data)
                    .then(function(res) {
                        if (res && res.success && res.attachments) {
                            renderList(listEl, res.attachments, deliveryId, true);
                            input.value = '';
                        }
                        if (typeof window.deliveryShowToast === 'function') {
                            window.deliveryShowToast(res && res.success ? 'success' : 'error', (res && res.message) || '');
                        }
                    })
                    .finally(function() {
                        uploadBtn.disabled = false;
                    });
            };
        }

        if (listEl && canEditAttachments) {
            listEl.onclick = function(e) {
                var btn = e.target.closest('[data-delivery-attachment-delete]');
                if (!btn) {
                    return;
                }
                var attachmentId = btn.getAttribute('data-delivery-attachment-delete');
                if (!attachmentId || !confirm('Удалить файл?')) {
                    return;
                }
                var data = new FormData();
                data.append('attachment_id', attachmentId);
                postFormData(apiUrl('delete-attachment', deliveryId), data).then(function(res) {
                    if (res && res.success && res.attachments) {
                        renderList(listEl, res.attachments, deliveryId, true);
                    }
                    if (typeof window.deliveryShowToast === 'function') {
                        window.deliveryShowToast(res && res.success ? 'success' : 'error', (res && res.message) || '');
                    }
                });
            };
        }
    };
})();
