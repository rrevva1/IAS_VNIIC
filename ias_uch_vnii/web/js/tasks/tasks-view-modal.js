/**
 * Модальное окно просмотра карточки заявки.
 */
(function() {
    'use strict';

    var modalEl = document.getElementById('tasksViewModal');
    var bodyEl = document.getElementById('tasksViewModalBody');
    var headerEl = document.getElementById('tasksViewModalHeader');
    var footerEl = document.getElementById('tasksViewModalFooter');
    var titleEl = document.getElementById('tasksViewModalLabel');
    if (!modalEl || !bodyEl) {
        return;
    }

    var modalInstance = null;
    var currentTaskId = null;
    var loadingHtml = bodyEl.innerHTML;
    var defaultHeaderHtml = headerEl ? headerEl.innerHTML : '';

    function getViewModalUrl(id) {
        var container = document.getElementById('agGridTasksContainer');
        var tpl = (container && container.dataset.viewModalUrlTemplate)
            || window.agGridTasksViewModalUrlTemplate
            || '/index.php?r=tasks/view-modal&id=__ID__';
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
        resetChrome();
    }

    function resetChrome() {
        if (headerEl) {
            headerEl.innerHTML = defaultHeaderHtml;
            titleEl = document.getElementById('tasksViewModalLabel');
        }
        if (footerEl) {
            footerEl.innerHTML = '';
            footerEl.classList.add('d-none');
        }
    }

    function setTitle(text) {
        if (titleEl) {
            titleEl.textContent = text || 'Заявка';
        }
    }

    function mountHeader(root) {
        if (!headerEl || !root) {
            return;
        }
        var slot = root.querySelector('#tasksViewHeaderSlot');
        if (!slot) {
            return;
        }
        var iconWrap = headerEl.querySelector('.tasks-view-modal__header-icon');
        var textWrap = headerEl.querySelector('.tasks-view-modal__header-text');
        if (!textWrap) {
            headerEl.innerHTML = '';
            headerEl.appendChild(slot);
        } else {
            textWrap.innerHTML = '';
            textWrap.appendChild(slot);
            if (iconWrap) {
                iconWrap.style.display = 'none';
            }
        }
        var titleNode = slot.querySelector('.tasks-view__title, .tasks-view-modal__title');
        if (titleNode) {
            setTitle(titleNode.textContent.trim());
        }
    }

    function mountFooter(root) {
        if (!footerEl || !root) {
            return;
        }
        var slot = root.querySelector('#tasksViewActionsSlot');
        if (!slot) {
            footerEl.classList.add('d-none');
            return;
        }
        footerEl.innerHTML = '';
        while (slot.firstChild) {
            footerEl.appendChild(slot.firstChild);
        }
        footerEl.classList.remove('d-none');
    }

    function initLoadedContent() {
        var root = bodyEl.querySelector('#tasksViewRoot');
        if (!root) {
            return;
        }
        if (root.dataset.executorChangeUrl) {
            window.executorChangeUrl = root.dataset.executorChangeUrl;
        }
        if (typeof window.initTasksViewPage === 'function') {
            window.initTasksViewPage(bodyEl);
        }
        if (window.IasUserSelect && typeof window.IasUserSelect.init === 'function') {
            window.IasUserSelect.init(bodyEl, { force: true });
        }
    }

    function loadTask(taskId) {
        currentTaskId = taskId;
        setLoading();
        setTitle('Заявка #' + taskId);

        return fetch(getViewModalUrl(taskId), {
            headers: { 'X-Requested-With': 'XMLHttpRequest', Accept: 'text/html' },
            credentials: 'same-origin',
        })
            .then(function(r) {
                if (!r.ok) {
                    return r.text().then(function() {
                        var err = new Error('load failed');
                        err.status = r.status;
                        throw err;
                    });
                }
                return r.text();
            })
            .then(function(html) {
                if (!html || html.indexOf('tasks-view') === -1) {
                    throw new Error('invalid response');
                }
                bodyEl.innerHTML = html;
                var root = bodyEl.querySelector('.tasks-view');
                mountHeader(root);
                mountFooter(root);
                initLoadedContent();
            })
            .catch(function(err) {
                var msg = 'Не удалось загрузить карточку заявки.';
                if (err && err.status === 403) {
                    msg = 'Нет доступа к этой заявке.';
                } else if (err && err.status === 404) {
                    msg = 'Заявка не найдена.';
                }
                bodyEl.innerHTML = '<p class="text-danger mb-0">' + msg + '</p>';
                if (footerEl) {
                    footerEl.innerHTML = '';
                    footerEl.classList.add('d-none');
                }
            });
    }

    function open(taskId) {
        var id = parseInt(taskId, 10);
        if (!id) {
            return;
        }
        var m = getModal();
        if (m) {
            m.show();
        }
        loadTask(id);
    }

    window.openTasksViewModal = open;

    window.TasksView = {
        open: open,
        reload: function() {
            if (currentTaskId) {
                return loadTask(currentTaskId);
            }
            return Promise.resolve();
        },
        isOpen: function() {
            return modalEl.classList.contains('show');
        },
        getTaskId: function() {
            return currentTaskId;
        },
    };

    document.addEventListener('click', function(e) {
        var link = e.target.closest('[data-task-view]');
        if (!link) {
            return;
        }
        e.preventDefault();
        open(link.getAttribute('data-task-view'));
    });

    modalEl.addEventListener('hidden.bs.modal', function() {
        currentTaskId = null;
        setLoading();
        if (window.IasUserSelect && typeof window.IasUserSelect.destroy === 'function') {
            window.IasUserSelect.destroy(modalEl);
        }
        var params = new URLSearchParams(window.location.search);
        if (params.has('task')) {
            params.delete('task');
            var qs = params.toString();
            var next = window.location.pathname + (qs ? '?' + qs : '') + window.location.hash;
            if (window.history && window.history.replaceState) {
                window.history.replaceState({}, '', next);
            }
        }
    });

    var params = new URLSearchParams(window.location.search);
    var taskParam = params.get('task');
    if (taskParam) {
        open(taskParam);
        params.delete('task');
        var qs = params.toString();
        var next = window.location.pathname + (qs ? '?' + qs : '') + window.location.hash;
        if (window.history && window.history.replaceState) {
            window.history.replaceState({}, '', next);
        }
    }
})();
