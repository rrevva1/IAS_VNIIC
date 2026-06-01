(function() {
    'use strict';

    function appendFormValue(body, key, value) {
        if (value === undefined || value === null) {
            return;
        }
        if (Array.isArray(value)) {
            value.forEach(function(item) {
                if (item !== undefined && item !== null && item !== '') {
                    body.append(key.endsWith('[]') ? key : key + '[]', item);
                }
            });
            return;
        }
        body.append(key, value);
    }

    function postForm(url, data) {
        var body = new FormData();
        Object.keys(data).forEach(function(key) {
            appendFormValue(body, key, data[key]);
        });
        if (window.yii && typeof yii.getCsrfParam === 'function') {
            body.append(yii.getCsrfParam(), yii.getCsrfToken());
        }
        return fetch(url, { method: 'POST', body: body, headers: { 'X-Requested-With': 'XMLHttpRequest' } })
            .then(function(r) { return r.json(); });
    }

    function showToast(message, isError) {
        var el = document.getElementById('workTaskBoardToast');
        if (!el) {
            if (isError) {
                alert(message);
            }
            return;
        }
        el.textContent = message;
        el.hidden = false;
        el.classList.toggle('is-error', !!isError);
        clearTimeout(showToast._timer);
        showToast._timer = setTimeout(function() {
            el.hidden = true;
        }, 4000);
    }

    function updateBoardCard(res, taskId) {
        if (!document.getElementById('workKanbanBoard') || !res || !res.status_code) {
            return;
        }
        var id = taskId || (window.WorkTasksView && window.WorkTasksView.getTaskId());
        if (id && typeof window.workTasksBoardUpdateCard === 'function') {
            window.workTasksBoardUpdateCard(id, res);
        }
    }

    function closeViewModal() {
        var modalEl = document.getElementById('workTaskViewModal');
        if (modalEl && typeof bootstrap !== 'undefined') {
            var inst = bootstrap.Modal.getInstance(modalEl);
            if (inst) {
                inst.hide();
            }
        }
    }

    function handleTaskChangeSuccess(res, taskId) {
        var id = taskId || (window.WorkTasksView && window.WorkTasksView.getTaskId());
        updateBoardCard(res, id);
        if (window.WorkTasksView && window.WorkTasksView.isOpen()) {
            closeViewModal();
            showToast(res.message || 'Готово', false);
            return;
        }
        if (document.getElementById('workKanbanBoard')) {
            showToast(res.message || 'Готово', false);
            return;
        }
        window.location.href = res.redirect || window.location.href;
    }

    document.addEventListener('click', function(e) {
        var btn = e.target.closest('[data-work-task-transition]');
        if (!btn || btn.disabled) {
            return;
        }
        e.preventDefault();
        var url = btn.getAttribute('data-url');
        var code = btn.getAttribute('data-status-code');
        if (!url || !code) {
            return;
        }
        btn.disabled = true;
        postForm(url, { status_code: code })
            .then(function(res) {
                if (res.success) {
                    handleTaskChangeSuccess(res);
                } else {
                    showToast(res.message || 'Ошибка', true);
                    btn.disabled = false;
                }
            })
            .catch(function() {
                showToast('Ошибка сети', true);
                btn.disabled = false;
            });
    });

    document.addEventListener('click', function(e) {
        var bulkBtn = e.target.closest('[data-work-tasks-bulk-confirm]');
        if (bulkBtn && !bulkBtn.disabled) {
            e.preventDefault();
            var count = parseInt(bulkBtn.getAttribute('data-count'), 10) || 0;
            if (count <= 0) {
                return;
            }
            var config = window.workTasksBoardConfig || {};
            var bulkUrl = config.bulkConfirmUrl || '/index.php?r=work-tasks/bulk-confirm';
            var confirmText = 'Подтвердить выполнение всех задач (' + count
                + ') в статусе «Выполнена»? Они будут переведены в статус «Закрыта».';
            if (!window.confirm(confirmText)) {
                return;
            }

            var form = document.querySelector('.work-tasks-command-form');
            var payload = { filter: 'active' };
            if (form) {
                var qInput = form.querySelector('[name="q"]');
                if (qInput && qInput.value.trim() !== '') {
                    payload.q = qInput.value.trim();
                }
                var executorSelect = form.querySelector('[name="executor_id"]');
                if (executorSelect && executorSelect.value !== '') {
                    payload.executor_id = executorSelect.value;
                }
            }

            bulkBtn.disabled = true;
            postForm(bulkUrl, payload)
                .then(function(res) {
                    if (res.success || (res.confirmed && res.confirmed > 0)) {
                        showToast(res.message || 'Готово', false);
                        window.setTimeout(function() {
                            window.location.reload();
                        }, 600);
                    } else {
                        showToast(res.message || 'Не удалось подтвердить задачи', true);
                        bulkBtn.disabled = false;
                    }
                })
                .catch(function() {
                    showToast('Ошибка сети', true);
                    bulkBtn.disabled = false;
                });
            return;
        }

        var deleteBtn = e.target.closest('[data-work-task-delete]');
        if (!deleteBtn || deleteBtn.disabled) {
            return;
        }
        e.preventDefault();
        var url = deleteBtn.getAttribute('data-url');
        var taskId = deleteBtn.getAttribute('data-task-id');
        if (!url || !taskId) {
            return;
        }
        if (!window.confirm('Удалить задачу №' + taskId + '?')) {
            return;
        }
        deleteBtn.disabled = true;
        postForm(url, {})
            .then(function(res) {
                if (res.success) {
                    if (typeof window.workTasksBoardRemoveCard === 'function') {
                        window.workTasksBoardRemoveCard(taskId);
                    }
                    closeViewModal();
                    showToast(res.message || 'Задача удалена', false);
                } else {
                    showToast(res.message || 'Ошибка', true);
                    deleteBtn.disabled = false;
                }
            })
            .catch(function() {
                showToast('Ошибка сети', true);
                deleteBtn.disabled = false;
            });
    });

    document.addEventListener('submit', function(e) {
        var commentForm = e.target.closest('#workTaskCommentForm');
        if (commentForm) {
            e.preventDefault();
            var commentUrl = commentForm.getAttribute('action');
            var commentBody = commentForm.querySelector('[name="body"]');
            var commentText = commentBody ? commentBody.value.trim() : '';
            if (!commentText) {
                showToast('Введите текст комментария', true);
                return;
            }
            var submitBtn = commentForm.querySelector('[type="submit"]');
            if (submitBtn) {
                submitBtn.disabled = true;
            }
            postForm(commentUrl, { body: commentText })
                .then(function(res) {
                    if (res.success) {
                        showToast(res.message || 'Комментарий добавлен', false);
                        if (window.WorkTasksView && typeof window.WorkTasksView.reload === 'function') {
                            return window.WorkTasksView.reload();
                        }
                    } else {
                        showToast(res.message || 'Ошибка', true);
                    }
                })
                .catch(function() {
                    showToast('Ошибка сети', true);
                })
                .finally(function() {
                    if (submitBtn) {
                        submitBtn.disabled = false;
                    }
                });
            return;
        }

    });
})();
