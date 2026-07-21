/**
 * Модальное окно создания и редактирования пользователя (по образцу заявок).
 */
(function() {
    'use strict';

    var currentMode = 'create';
    var currentUserId = null;
    var loadingHtml = (
        '<div class="users-grid-loading">' +
        '<i class="fas fa-spinner fa-spin" aria-hidden="true"></i>' +
        '<p>Загрузка формы…</p></div>'
    );

    function getContainer() {
        return document.getElementById('agGridUsersContainer');
    }

    function getModalEl() {
        return document.getElementById('userFormModal');
    }

    function getCreateModalUrl() {
        var container = getContainer();
        return (container && container.dataset.createModalUrl) || '/index.php?r=users/create-modal';
    }

    function getUpdateModalUrl(userId) {
        var container = getContainer();
        var tpl = (container && container.dataset.updateModalUrlTemplate)
            || window.agGridUsersUpdateModalUrlTemplate
            || '/index.php?r=users/update-modal&id=__ID__';
        return tpl.replace('__ID__', String(userId));
    }

    function resolveSubmitUrl($form) {
        var action = $form && $form.attr('action');
        if (action) {
            return action;
        }
        if ($form && $form.attr('id') === 'user-update-form' && currentUserId) {
            return getUpdateModalUrl(currentUserId);
        }
        if (currentMode === 'edit' && currentUserId) {
            return getUpdateModalUrl(currentUserId);
        }
        return getCreateModalUrl();
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

    function displayFormErrors(errors) {
        var $ = window.jQuery;
        if (!$ || !errors) {
            return;
        }
        $('#userFormModalBody .has-error').removeClass('has-error');
        $('#userFormModalBody .help-block.field-error').remove();
        $.each(errors, function(field, messages) {
            var $field = $('#users-' + field);
            if (!$field.length) {
                return;
            }
            var $group = $field.closest('.field-users-' + field + ', .form-group, .mb-0, .users-create-form__section');
            $group.addClass('has-error');
            $field.after('<div class="help-block field-error">' + messages.join('<br>') + '</div>');
        });
    }

    function parseJsonResponse(xhr) {
        if (xhr.responseJSON) {
            return xhr.responseJSON;
        }
        if (!xhr.responseText) {
            return null;
        }
        try {
            return JSON.parse(xhr.responseText);
        } catch (e) {
            return null;
        }
    }

    function setModalTitle(text) {
        var titleEl = document.getElementById('userFormModalLabel');
        if (titleEl) {
            titleEl.textContent = text || 'Пользователь';
        }
    }

    function resetModalBody() {
        var body = document.getElementById('userFormModalBody');
        if (body) {
            body.innerHTML = loadingHtml;
        }
    }

    function raiseFormModalAboveView() {
        var viewModal = document.getElementById('usersViewModal');
        var formModal = getModalEl();
        if (!viewModal || !formModal || !viewModal.classList.contains('show')) {
            return;
        }
        var viewZ = parseInt(viewModal.style.zIndex, 10) || 1055;
        formModal.style.zIndex = String(viewZ + 10);
    }

    function clearStuckModalBackdrop() {
        if (document.querySelector('.modal.show')) {
            return;
        }
        document.querySelectorAll('.modal-backdrop').forEach(function(el) {
            el.remove();
        });
        document.body.classList.remove('modal-open');
        document.body.style.removeProperty('overflow');
        document.body.style.removeProperty('padding-right');
    }

    function handleFormSubmit(e) {
        e.preventDefault();

        var $ = window.jQuery;
        var $form = $(e.currentTarget);
        if (!$form.length || !$form.closest('#userFormModalBody').length) {
            return;
        }

        var $btn = $form.find('#submit-user-btn');
        var originalHtml = $btn.html();
        $btn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> Сохранение…');

        var url = resolveSubmitUrl($form);
        var isUpdate = $form.attr('id') === 'user-update-form';

        $.ajax({
            url: url,
            type: 'POST',
            data: $form.serialize(),
            dataType: 'json',
            headers: {
                'X-Requested-With': 'XMLHttpRequest',
                Accept: 'application/json',
            },
        })
            .done(function(response) {
                if (response && response.success) {
                    var modalEl = getModalEl();
                    var inst = modalEl && bootstrap.Modal.getInstance(modalEl);
                    if (inst) {
                        inst.hide();
                    }
                    showToast('success', response.message || 'Сохранено.');
                    if (typeof window.refreshUsersGrid === 'function') {
                        window.refreshUsersGrid();
                    }
                    if (isUpdate && window.UsersView && window.UsersView.reload) {
                        var viewUserId = window.UsersView.getUserId();
                        var savedId = response.user_id || currentUserId;
                        if (window.UsersView.isOpen() && parseInt(viewUserId, 10) === parseInt(savedId, 10)) {
                            window.UsersView.reload();
                        }
                    }
                } else {
                    showToast('error', (response && response.message) || 'Не удалось сохранить.');
                    displayFormErrors(response && response.errors);
                }
            })
            .fail(function(xhr) {
                var parsed = parseJsonResponse(xhr);
                var msg = (parsed && parsed.message)
                    || 'Ошибка сервера'
                    + (xhr.status ? ' (' + xhr.status + ')' : '');
                showToast('error', msg);
                if (parsed && parsed.errors) {
                    displayFormErrors(parsed.errors);
                }
            })
            .always(function() {
                $btn.prop('disabled', false).html(originalHtml);
            });
    }

    function bindFormSubmitDelegation() {
        var $ = window.jQuery;
        var $body = $('#userFormModalBody');
        if (!$body.length) {
            return;
        }
        $body.off('submit.usersForm', 'form').on('submit.usersForm', 'form', handleFormSubmit);
        $body.off('click.usersForm', '#submit-user-btn').on('click.usersForm', '#submit-user-btn', function(e) {
            var $form = $(this).closest('form');
            if ($form.length) {
                e.preventDefault();
                $form.trigger('submit');
            }
        });
    }

    function openFormModal(url, title, mode, userId) {
        var modalEl = getModalEl();
        if (!modalEl) {
            showToast('error', 'Модальное окно не найдено на странице.');
            return;
        }
        if (!window.bootstrap || !window.bootstrap.Modal) {
            showToast('error', 'Не загружен Bootstrap. Обновите страницу.');
            return;
        }
        if (!window.jQuery) {
            showToast('error', 'Не загружен jQuery. Обновите страницу.');
            return;
        }

        currentMode = mode;
        currentUserId = userId;

        setModalTitle(title);
        resetModalBody();
        moveUsersModalsToBody();

        var modal = bootstrap.Modal.getOrCreateInstance(modalEl, {
            backdrop: true,
            keyboard: true,
            focus: true,
        });
        modal.show();

        window.jQuery.get(url)
            .done(function(html) {
                var $body = window.jQuery('#userFormModalBody');
                $body.html(html);
                $body.find('script').remove();
                bindFormSubmitDelegation();
                if (typeof window.initInternalPhoneSelects === 'function') {
                    window.initInternalPhoneSelects($body[0]);
                }
            })
            .fail(function() {
                window.jQuery('#userFormModalBody').html(
                    '<div class="alert alert-danger mb-0">Не удалось загрузить форму. Попробуйте позже.</div>'
                );
            });
    }

    window.openCreateUserModal = function() {
        openFormModal(getCreateModalUrl(), 'Новый пользователь', 'create', null);
    };

    window.openEditUserModal = function(userId) {
        var id = parseInt(userId, 10);
        if (!id) {
            return;
        }
        openFormModal(getUpdateModalUrl(id), 'Редактирование пользователя', 'edit', id);
    };

    function bindModalEvents() {
        var modalEl = getModalEl();
        if (!modalEl) {
            return;
        }
        modalEl.addEventListener('shown.bs.modal', raiseFormModalAboveView);
        modalEl.addEventListener('hidden.bs.modal', function() {
            modalEl.style.zIndex = '';
            currentMode = 'create';
            currentUserId = null;
            resetModalBody();
            setModalTitle('Новый пользователь');
        });
    }

    /** Обе модалки в body — иначе backdrop из body перекрывает форму в content-wrapper. */
    function moveUsersModalsToBody() {
        ['usersViewModal', 'userFormModal'].forEach(function(id) {
            var el = document.getElementById(id);
            if (el && el.parentNode !== document.body) {
                document.body.appendChild(el);
            }
        });
    }

    function bindDocumentClicks() {
        document.addEventListener('click', function(e) {
            if (e.target.closest('[data-user-create-open]')) {
                e.preventDefault();
                window.openCreateUserModal();
                return;
            }
            var editBtn = e.target.closest('[data-users-edit]');
            if (editBtn) {
                e.preventDefault();
                window.openEditUserModal(editBtn.getAttribute('data-users-edit'));
            }
        });
    }

    function init() {
        moveUsersModalsToBody();
        bindModalEvents();
        bindDocumentClicks();
        bindFormSubmitDelegation();

        var params = new URLSearchParams(window.location.search);
        var editParam = params.get('edit');
        if (editParam) {
            window.openEditUserModal(editParam);
            params.delete('edit');
            var qs = params.toString();
            var next = window.location.pathname + (qs ? '?' + qs : '') + window.location.hash;
            if (window.history && window.history.replaceState) {
                window.history.replaceState({}, '', next);
            }
        }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
