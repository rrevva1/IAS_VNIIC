/**
 * Модальное окно редактирования заявки.
 */
(function() {
    'use strict';

    var modalEl = document.getElementById('editTaskModal');
    var bodyEl = document.getElementById('editTaskModalBody');
    var titleEl = document.getElementById('editTaskModalLabel');
    if (!modalEl || !bodyEl) {
        return;
    }

    var modalInstance = null;
    var currentTaskId = null;
    var loadingHtml = bodyEl.innerHTML;

    function getUpdateModalUrl(id) {
        var container = document.getElementById('agGridTasksContainer');
        var tpl = (container && container.dataset.updateModalUrlTemplate)
            || window.agGridTasksUpdateModalUrlTemplate
            || '/index.php?r=tasks/update-modal&id=__ID__';
        return tpl.replace('__ID__', String(id));
    }

    function getModal() {
        if (!modalInstance && typeof bootstrap !== 'undefined') {
            modalInstance = bootstrap.Modal.getOrCreateInstance(modalEl);
        }
        return modalInstance;
    }

    function setLoading() {
        bodyEl.innerHTML = loadingHtml;
        if (titleEl) {
            titleEl.textContent = 'Редактирование заявки';
        }
    }

    function notify(type, message) {
        if (typeof window.showNotification === 'function') {
            window.showNotification(type, message);
            return;
        }
        if (typeof window.IASNotify === 'function') {
            window.IASNotify(message, type === 'error' ? 'danger' : type);
        }
    }

    function displayFormErrors(errors) {
        if (!errors || typeof window.jQuery === 'undefined') {
            return;
        }
        var $ = window.jQuery;
        $('.has-error').removeClass('has-error');
        $('.help-block').remove();
        $.each(errors, function(field, messages) {
            var $field = $('#tasks-' + field);
            var $formGroup = $field.closest('.form-group');
            $formGroup.addClass('has-error');
            $field.after('<div class="help-block">' + messages.join('<br>') + '</div>');
        });
    }

    function initFormSubmit(taskId) {
        if (typeof window.jQuery === 'undefined') {
            return;
        }
        var $ = window.jQuery;
        var $form = $(bodyEl).find('form');
        var url = getUpdateModalUrl(taskId);

        $form.off('submit.tasksEdit').on('submit.tasksEdit', function(e) {
            e.preventDefault();
            if (typeof window.tasksFormPrepareSubmit === 'function') {
                window.tasksFormPrepareSubmit(this);
            }
            var formData = new FormData(this);
            var $submitBtn = $form.find('#submit-task-btn');
            var originalBtnText = $submitBtn.html();
            $submitBtn.html('<i class="fas fa-spinner fa-spin" aria-hidden="true"></i> Сохранение…');
            $submitBtn.prop('disabled', true);

            $.ajax({
                url: url,
                type: 'POST',
                data: formData,
                processData: false,
                contentType: false,
            })
                .done(function(response) {
                    if (response && response.success) {
                        var modal = getModal();
                        if (modal) {
                            modal.hide();
                        }
                        notify('success', response.message || 'Заявка сохранена.');
                        if (typeof window.refreshGrid === 'function') {
                            window.refreshGrid();
                        }
                        if (window.TasksView && window.TasksView.isOpen()
                            && window.TasksView.getTaskId() === taskId
                            && typeof window.TasksView.reload === 'function') {
                            window.TasksView.reload();
                        }
                        return;
                    }
                    notify('error', (response && response.message) || 'Не удалось сохранить заявку.');
                    if (response && response.errors) {
                        displayFormErrors(response.errors);
                    }
                })
                .fail(function(xhr) {
                    var msg = 'Ошибка сервера при сохранении заявки.';
                    if (xhr && xhr.status === 403) {
                        msg = 'Нет доступа к редактированию этой заявки.';
                    }
                    notify('error', msg);
                })
                .always(function() {
                    $submitBtn.html(originalBtnText);
                    $submitBtn.prop('disabled', false);
                });
        });

        $form.find('.btn-cancel').off('click.tasksEdit').on('click.tasksEdit', function() {
            var modal = getModal();
            if (modal) {
                modal.hide();
            }
        });
    }

    function loadForm(taskId) {
        currentTaskId = taskId;
        setLoading();
        if (titleEl) {
            titleEl.textContent = 'Заявка №' + taskId;
        }

        if (typeof window.jQuery === 'undefined') {
            bodyEl.innerHTML = '<p class="text-danger mb-0">Не удалось загрузить форму.</p>';
            return;
        }

        window.jQuery.ajax({
            url: getUpdateModalUrl(taskId),
            type: 'GET',
        })
            .done(function(response) {
                bodyEl.innerHTML = response;
                if (typeof window.tasksCreateFormInit === 'function') {
                    window.tasksCreateFormInit(bodyEl.querySelector('form'));
                }
                initFormSubmit(taskId);
            })
            .fail(function(xhr) {
                var msg = 'Не удалось загрузить форму редактирования.';
                if (xhr && xhr.status === 403) {
                    msg = 'Нет доступа к редактированию этой заявки.';
                } else if (xhr && xhr.status === 404) {
                    msg = 'Заявка не найдена.';
                }
                bodyEl.innerHTML = '<div class="alert alert-danger mb-0"><i class="fas fa-circle-exclamation"></i> ' + msg + '</div>';
            });
    }

    function open(taskId) {
        var id = parseInt(taskId, 10);
        if (!id) {
            return;
        }
        var viewModal = document.getElementById('tasksViewModal');
        if (viewModal && viewModal.classList.contains('show') && typeof bootstrap !== 'undefined') {
            var viewInstance = bootstrap.Modal.getInstance(viewModal);
            if (viewInstance) {
                viewModal.addEventListener('hidden.bs.modal', function onViewHidden() {
                    viewModal.removeEventListener('hidden.bs.modal', onViewHidden);
                    var modal = getModal();
                    if (modal) {
                        modal.show();
                    }
                    loadForm(id);
                }, { once: true });
                viewInstance.hide();
                return;
            }
        }
        var modal = getModal();
        if (modal) {
            modal.show();
        }
        loadForm(id);
    }

    window.openTasksEditModal = open;

    document.addEventListener('click', function(e) {
        var trigger = e.target.closest('[data-task-edit]');
        if (!trigger) {
            return;
        }
        e.preventDefault();
        open(trigger.getAttribute('data-task-edit'));
    });

    modalEl.addEventListener('hidden.bs.modal', function() {
        currentTaskId = null;
        setLoading();
        if (window.IasUserSelect && typeof window.IasUserSelect.destroy === 'function') {
            window.IasUserSelect.destroy(modalEl);
        }
    });
})();
