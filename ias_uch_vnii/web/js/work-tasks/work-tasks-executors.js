(function() {
    'use strict';

    function postForm(url, data) {
        var body = new FormData();
        Object.keys(data).forEach(function(key) {
            if (data[key] !== undefined && data[key] !== null && data[key] !== '') {
                body.append(key, data[key]);
            }
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

    function handleSuccess(res) {
        if (!res || !res.success) {
            showToast((res && res.message) || 'Ошибка', true);
            return;
        }
        var taskId = window.WorkTasksView && window.WorkTasksView.getTaskId();
        updateBoardCard(res, taskId);
        if (window.WorkTasksView && window.WorkTasksView.isOpen() && typeof window.WorkTasksView.reload === 'function') {
            window.WorkTasksView.reload({ transitionRes: res });
        }
        showToast(res.message || 'Готово', false);
    }

    function getManageRoot() {
        return document.getElementById('workTaskExecutorsManage');
    }

    function hideAddPanel() {
        var panel = document.getElementById('workTaskExecutorAddPanel');
        var showBtn = document.getElementById('workTaskShowAddExecutor');
        if (!panel) {
            return;
        }
        panel.classList.add('d-none');
        if (showBtn) {
            showBtn.classList.remove('d-none');
        }
        if (window.IasUserSelect && typeof window.IasUserSelect.destroy === 'function') {
            window.IasUserSelect.destroy(panel);
        }
    }

    function showAddPanel() {
        var panel = document.getElementById('workTaskExecutorAddPanel');
        var showBtn = document.getElementById('workTaskShowAddExecutor');
        if (!panel) {
            return;
        }
        panel.classList.remove('d-none');
        if (showBtn) {
            showBtn.classList.add('d-none');
        }
        if (window.IasUserSelect && typeof window.IasUserSelect.init === 'function') {
            window.IasUserSelect.init(panel, { force: true });
        }
        var select = document.getElementById('workTaskExecutorAddSelect');
        if (select) {
            select.focus();
        }
    }

    document.addEventListener('click', function(e) {
        var root = getManageRoot();
        if (!root || !root.contains(e.target)) {
            return;
        }

        if (e.target.closest('#workTaskShowAddExecutor')) {
            e.preventDefault();
            showAddPanel();
            return;
        }

        if (e.target.closest('#workTaskExecutorAddCancel')) {
            e.preventDefault();
            hideAddPanel();
            return;
        }

        var removeBtn = e.target.closest('[data-work-task-remove-executor]');
        if (removeBtn) {
            e.preventDefault();
            var userId = removeBtn.getAttribute('data-work-task-remove-executor');
            var tpl = root.getAttribute('data-remove-url-template') || '';
            var url = tpl.replace('__UID__', String(userId));
            removeBtn.disabled = true;
            postForm(url, {})
                .then(handleSuccess)
                .catch(function() { showToast('Ошибка сети', true); })
                .finally(function() { removeBtn.disabled = false; });
            return;
        }

        if (e.target.closest('#workTaskExecutorAddConfirm')) {
            e.preventDefault();
            var addUrl = root.getAttribute('data-add-url');
            var select = document.getElementById('workTaskExecutorAddSelect');
            if (!addUrl || !select || !select.value) {
                showToast('Выберите сотрудника', true);
                return;
            }
            var confirmBtn = document.getElementById('workTaskExecutorAddConfirm');
            if (confirmBtn) {
                confirmBtn.disabled = true;
            }
            postForm(addUrl, { executor_id: select.value })
                .then(function(res) {
                    handleSuccess(res);
                    hideAddPanel();
                })
                .catch(function() { showToast('Ошибка сети', true); })
                .finally(function() {
                    if (confirmBtn) {
                        confirmBtn.disabled = false;
                    }
                });
        }
    });

    window.workTasksExecutorsInit = function(container) {
        hideAddPanel();
        if (container && window.IasUserSelect && typeof window.IasUserSelect.destroy === 'function') {
            window.IasUserSelect.destroy(container);
        }
    };
})();
