/**
 * Модальное окно создания пользователя.
 */
(function($) {
    'use strict';

    function getCsrfToken() {
        if (window.yii && typeof window.yii.getCsrfToken === 'function') {
            return window.yii.getCsrfToken();
        }
        var meta = document.querySelector('meta[name="csrf-token"]');
        return meta ? meta.getAttribute('content') : '';
    }

    function showToast(type, message) {
        if (typeof window.showNotification === 'function') {
            window.showNotification(type, message);
            return;
        }
        alert(message);
    }

    function displayFormErrors(errors) {
        $('.has-error').removeClass('has-error');
        $('.help-block').remove();
        if (!errors) {
            return;
        }
        $.each(errors, function(field, messages) {
            var $field = $('#users-' + field);
            var $group = $field.closest('.form-group');
            $group.addClass('has-error');
            $field.after('<div class="help-block">' + messages.join('<br>') + '</div>');
        });
    }

    function initUserFormSubmit() {
        var $form = $('#createUserModalBody').find('#user-create-form');
        if (!$form.length) {
            return;
        }

        $form.off('submit.usersCreate').on('submit.usersCreate', function(e) {
            e.preventDefault();

            var $btn = $('#submit-user-btn');
            var originalHtml = $btn.html();
            $btn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> Сохранение…');

            var container = document.getElementById('agGridUsersContainer');
            var url = (container && container.dataset.createModalUrl) || '/index.php?r=users/create-modal';

            $.ajax({
                url: url,
                type: 'POST',
                data: $form.serialize(),
                dataType: 'json',
            })
                .done(function(response) {
                    if (response && response.success) {
                        var modalEl = document.getElementById('createUserModal');
                        var modal = modalEl ? bootstrap.Modal.getInstance(modalEl) : null;
                        if (modal) {
                            modal.hide();
                        }
                        showToast('success', response.message || 'Пользователь создан.');
                        if (typeof window.refreshUsersGrid === 'function') {
                            window.refreshUsersGrid();
                        }
                    } else {
                        showToast('error', (response && response.message) || 'Не удалось создать пользователя.');
                        displayFormErrors(response && response.errors);
                    }
                })
                .fail(function(xhr) {
                    var msg = 'Ошибка сервера';
                    if (xhr.responseJSON && xhr.responseJSON.message) {
                        msg = xhr.responseJSON.message;
                    }
                    showToast('error', msg);
                })
                .always(function() {
                    $btn.prop('disabled', false).html(originalHtml);
                });
        });
    }

    window.openCreateUserModal = function() {
        var modalEl = document.getElementById('createUserModal');
        if (!modalEl) {
            return;
        }

        var modal = bootstrap.Modal.getOrCreateInstance(modalEl);
        modal.show();

        var container = document.getElementById('agGridUsersContainer');
        var url = (container && container.dataset.createModalUrl) || '/index.php?r=users/create-modal';

        $('#createUserModalBody').html(
            '<div class="users-grid-loading">' +
            '<i class="fas fa-spinner fa-spin" aria-hidden="true"></i>' +
            '<p>Загрузка формы…</p></div>'
        );

        $.get(url)
            .done(function(html) {
                $('#createUserModalBody').html(html);
                initUserFormSubmit();
            })
            .fail(function() {
                $('#createUserModalBody').html(
                    '<div class="alert alert-danger mb-0">Не удалось загрузить форму. Попробуйте позже.</div>'
                );
            });
    };

    $(document).on('click', '[data-user-create-open]', function(e) {
        e.preventDefault();
        window.openCreateUserModal();
    });

    var modalEl = document.getElementById('createUserModal');
    if (modalEl) {
        modalEl.addEventListener('hidden.bs.modal', function() {
            $('#createUserModalBody').html(
                '<div class="users-grid-loading">' +
                '<i class="fas fa-spinner fa-spin" aria-hidden="true"></i>' +
                '<p>Загрузка формы…</p></div>'
            );
        });
    }
})(jQuery);
