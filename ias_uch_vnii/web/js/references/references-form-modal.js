/**
 * Модальное создание и редактирование записей справочников (по образцу заявок).
 */
(function() {
    'use strict';

    var currentMode = 'create';
    var currentRecordId = null;
    var loadRequestId = 0;
    var loadingHtml = (
        '<div class="tasks-create-modal__loading">' +
        '<i class="fas fa-spinner fa-spin" aria-hidden="true"></i>' +
        '<p>Загрузка формы…</p></div>'
    );

    function getGridHost() {
        return document.querySelector('.references-page .references-grid-host');
    }

    function getModalEl() {
        return document.getElementById('refFormModal');
    }

    function csrfParam() {
        var meta = document.querySelector('meta[name="csrf-param"]');
        return meta ? meta.getAttribute('content') : '_csrf';
    }

    function csrfToken() {
        var meta = document.querySelector('meta[name="csrf-token"]');
        return meta ? meta.getAttribute('content') : '';
    }

    function appendCsrf(body) {
        var token = csrfToken();
        if (token) {
            body.append(csrfParam(), token);
        }
    }

    function getCreateModalUrl() {
        var host = getGridHost();
        return (host && host.dataset.createModalUrl) || '';
    }

    function getUpdateModalUrl(id) {
        var host = getGridHost();
        var tpl = (host && host.dataset.updateModalUrlTemplate) || '';
        return tpl.replace('__ID__', String(id));
    }

    function getFormPrefix() {
        var host = getGridHost();
        return (host && host.dataset.formPrefix) || '';
    }

    function getGridId() {
        var host = getGridHost();
        return host ? host.id : '';
    }

    function showToast(type, message) {
        if (typeof window.showNotification === 'function') {
            window.showNotification(type, message);
            return;
        }
        if (typeof window.IASNotify === 'function') {
            window.IASNotify(message, type === 'error' ? 'danger' : type);
            return;
        }
        alert(message);
    }

    function setModalTitle(text) {
        var titleEl = document.getElementById('refFormModalLabel');
        if (titleEl) {
            titleEl.textContent = text || '';
        }
    }

    function getTitleForMode(mode) {
        var modal = getModalEl();
        if (!modal) {
            return mode === 'edit' ? 'Редактировать' : 'Добавить';
        }
        if (mode === 'edit') {
            return modal.getAttribute('data-update-title') || 'Редактировать';
        }
        return modal.getAttribute('data-create-title') || 'Добавить';
    }

    function resetModalBody() {
        var body = document.getElementById('refFormModalBody');
        if (body) {
            body.innerHTML = loadingHtml;
        }
    }

    function displayFormErrors(errors) {
        var $ = window.jQuery;
        var prefix = getFormPrefix();
        if (!$ || !errors || !prefix) {
            return;
        }
        $('#refFormModalBody .has-error').removeClass('has-error');
        $('#refFormModalBody .help-block.field-error').remove();
        $.each(errors, function(field, messages) {
            var $field = $('#' + prefix + '-' + field);
            if (!$field.length) {
                return;
            }
            var $group = $field.closest('.field-' + prefix + '-' + field + ', .form-group, .mb-0, .tasks-create-form__section');
            $group.addClass('has-error');
            $field.after('<div class="help-block field-error">' + messages.join('<br>') + '</div>');
        });
    }

    function refreshGrid() {
        var gridId = getGridId();
        if (gridId && window.SectionGridUtils && typeof window.SectionGridUtils.reload === 'function') {
            window.SectionGridUtils.reload(gridId);
        }
    }

    function openModal() {
        var modalEl = getModalEl();
        if (!modalEl || !window.bootstrap || !window.bootstrap.Modal) {
            return null;
        }
        return window.bootstrap.Modal.getOrCreateInstance(modalEl);
    }

    function loadForm(url, mode) {
        var $ = window.jQuery;
        if (!$ || !url) {
            return;
        }
        currentMode = mode;
        var requestId = ++loadRequestId;
        resetModalBody();
        setModalTitle(getTitleForMode(mode));

        $.ajax({
            url: url,
            type: 'GET',
            headers: { 'X-Requested-With': 'XMLHttpRequest' },
        }).done(function(html) {
            if (requestId !== loadRequestId) {
                return;
            }
            var body = document.getElementById('refFormModalBody');
            if (body) {
                body.innerHTML = html;
            }
            bindFormSubmit();
        }).fail(function() {
            if (requestId !== loadRequestId) {
                return;
            }
            showToast('error', 'Не удалось загрузить форму');
            resetModalBody();
        });
    }

    function bindFormSubmit() {
        var $ = window.jQuery;
        if (!$) {
            return;
        }
        $('#refFormModalBody form').off('submit.refModal').on('submit.refModal', function(e) {
            e.preventDefault();
            var $form = $(this);
            var $btn = $form.find('#submit-ref-form-btn');
            var originalHtml = $btn.html();
            $btn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> Сохранение…');

            $.ajax({
                url: $form.attr('action'),
                type: 'POST',
                data: $form.serialize(),
                dataType: 'json',
            }).done(function(res) {
                if (res && res.success) {
                    var inst = openModal();
                    if (inst) {
                        inst.hide();
                    }
                    showToast('success', res.message || 'Сохранено');
                    refreshGrid();
                    return;
                }
                displayFormErrors(res && res.errors);
                showToast('error', (res && res.message) || 'Ошибка сохранения');
            }).fail(function(xhr) {
                var res = xhr.responseJSON || null;
                if (res && res.errors) {
                    displayFormErrors(res.errors);
                }
                showToast('error', (res && res.message) || 'Ошибка сохранения');
            }).always(function() {
                $btn.prop('disabled', false).html(originalHtml);
            });
        });
    }

    function openCreate() {
        currentRecordId = null;
        var inst = openModal();
        if (inst) {
            inst.show();
        }
        loadForm(getCreateModalUrl(), 'create');
    }

    function openEdit(id) {
        if (id == null) {
            return;
        }
        currentRecordId = id;
        var inst = openModal();
        if (inst) {
            inst.show();
        }
        loadForm(getUpdateModalUrl(id), 'edit');
    }

    function archiveRecord(id, confirmText) {
        var host = getGridHost();
        if (!host || id == null) {
            return;
        }
        var base = host.dataset.archiveUrl || '';
        if (!base) {
            return;
        }
        if (confirmText && !window.confirm(confirmText)) {
            return;
        }
        var sep = base.indexOf('?') >= 0 ? '&' : '?';
        var url = base + sep + 'id=' + encodeURIComponent(id);
        var body = new URLSearchParams();
        appendCsrf(body);

        fetch(url, {
            method: 'POST',
            headers: {
                'X-Requested-With': 'XMLHttpRequest',
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: body.toString(),
        })
            .then(function(r) { return r.json(); })
            .then(function(res) {
                if (res && res.success) {
                    showToast('success', res.message || 'Запись архивирована');
                    refreshGrid();
                    return;
                }
                showToast('error', (res && res.message) || 'Не удалось архивировать');
            })
            .catch(function() {
                showToast('error', 'Не удалось архивировать');
            });
    }

    function initDelegates() {
        document.addEventListener('click', function(e) {
            var createBtn = e.target.closest('[data-ref-create-open]');
            if (createBtn) {
                e.preventDefault();
                openCreate();
                return;
            }
            var editLink = e.target.closest('.ref-link-edit');
            if (editLink) {
                e.preventDefault();
                var id = editLink.getAttribute('data-ref-id');
                openEdit(id);
                return;
            }
            var archiveBtn = e.target.closest('.ref-archive-btn');
            if (archiveBtn) {
                e.preventDefault();
                var archiveId = archiveBtn.getAttribute('data-ref-id');
                var confirmMsg = archiveBtn.getAttribute('data-confirm') || 'Архивировать запись?';
                archiveRecord(archiveId, confirmMsg);
            }
        });

        var modalEl = getModalEl();
        if (modalEl) {
            modalEl.addEventListener('hidden.bs.modal', function() {
                loadRequestId += 1;
                resetModalBody();
                currentRecordId = null;
            });
        }
    }

    window.openReferencesEditModal = openEdit;
    window.openReferencesCreateModal = openCreate;
    window.refreshReferencesGrid = refreshGrid;

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initDelegates);
    } else {
        initDelegates();
    }
})();
