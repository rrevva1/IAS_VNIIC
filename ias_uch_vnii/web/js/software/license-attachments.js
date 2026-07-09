/**
 * Документы лицензии: загрузка и удаление вложений.
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

    function apiUrl(action, licenseId) {
        return '/index.php?r=software/' + action + '&id=' + encodeURIComponent(licenseId);
    }

    function escapeHtml(str) {
        var div = document.createElement('div');
        div.textContent = str;
        return div.innerHTML;
    }

    function renderList(listEl, items, licenseId, canEdit) {
        if (!listEl) {
            return;
        }
        if (!items || items.length === 0) {
            listEl.innerHTML = '<li class="text-muted small software-license-attachments__empty">Документы не прикреплены.</li>';
            return;
        }
        var html = '';
        items.forEach(function(item) {
            var id = item.id;
            var name = escapeHtml(item.original_name || '');
            var size = escapeHtml(item.size_label || '');
            var icon = escapeHtml(item.icon || 'fa-file');
            var href = apiUrl('download-license-attachment', licenseId) + '&attachmentId=' + encodeURIComponent(id);
            var target = item.is_preview ? ' target="_blank" rel="noopener"' : '';
            html += '<li class="software-license-attachments__item" data-attachment-id="' + id + '">'
                + '<i class="fas ' + icon + '" aria-hidden="true"></i> '
                + '<a href="' + href + '" class="software-license-attachments__link"' + target + '>' + name + '</a> '
                + '<span class="text-muted small">' + size + '</span>';
            if (canEdit) {
                html += ' <button type="button" class="btn btn-link btn-sm text-danger p-0 software-license-attachments__delete"'
                    + ' data-license-attachment-delete="' + id + '" title="Удалить файл">'
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

    window.bindLicenseAttachments = function(root) {
        root = root || document;
        var block = root.querySelector('[data-license-attachments-root]');
        if (!block || block.dataset.licenseAttachmentsBound === '1') {
            return;
        }
        block.dataset.licenseAttachmentsBound = '1';

        var licenseId = block.getAttribute('data-license-id');
        var canEdit = block.getAttribute('data-can-edit') === '1';
        var listEl = block.querySelector('[data-license-attachments-list]');
        var inputEl = block.querySelector('[data-license-attachment-input]');
        var uploadBtn = block.querySelector('[data-license-attachment-upload]');

        if (uploadBtn && inputEl && licenseId) {
            uploadBtn.addEventListener('click', function() {
                if (!inputEl.files || inputEl.files.length === 0) {
                    return;
                }
                var formData = new FormData();
                Array.prototype.forEach.call(inputEl.files, function(file) {
                    formData.append('uploadFiles[]', file);
                });
                uploadBtn.disabled = true;
                postFormData(apiUrl('upload-license-attachment', licenseId), formData)
                    .then(function(res) {
                        if (res && res.success) {
                            renderList(listEl, res.attachments || [], licenseId, canEdit);
                            inputEl.value = '';
                        } else {
                            alert((res && res.message) || 'Не удалось загрузить файлы');
                        }
                    })
                    .catch(function() {
                        alert('Ошибка загрузки файлов');
                    })
                    .finally(function() {
                        uploadBtn.disabled = false;
                    });
            });
        }

        block.addEventListener('click', function(e) {
            var deleteBtn = e.target.closest('[data-license-attachment-delete]');
            if (!deleteBtn || !licenseId) {
                return;
            }
            e.preventDefault();
            var attachmentId = deleteBtn.getAttribute('data-license-attachment-delete');
            if (!attachmentId || !window.confirm('Удалить файл?')) {
                return;
            }
            var formData = new FormData();
            formData.append('attachment_id', attachmentId);
            postFormData(apiUrl('delete-license-attachment', licenseId), formData)
                .then(function(res) {
                    if (res && res.success) {
                        renderList(listEl, res.attachments || [], licenseId, canEdit);
                    } else {
                        alert((res && res.message) || 'Не удалось удалить файл');
                    }
                })
                .catch(function() {
                    alert('Ошибка удаления файла');
                });
        });
    };
})();
