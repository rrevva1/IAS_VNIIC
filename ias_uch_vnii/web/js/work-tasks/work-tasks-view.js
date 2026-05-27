(function() {
    'use strict';

    var modalEl = document.getElementById('workTaskViewModal');
    var bodyEl = document.getElementById('workTaskViewModalBody');
    var headerEl = document.getElementById('workTaskViewModalHeader');
    var titleEl = document.getElementById('workTaskViewModalLabel');
    var subtitleEl = document.getElementById('workTaskViewModalSubtitle');
    var footerSlot = document.getElementById('workTaskViewModalFooter');
    if (!modalEl || !bodyEl) {
        return;
    }

    var config = window.workTasksViewConfig || {};
    var modalInstance = null;
    var currentTaskId = null;
    var loadingHtml = bodyEl.innerHTML;
    var defaultHeaderHtml = headerEl ? headerEl.innerHTML : '';

    function getModal() {
        if (!modalInstance && typeof bootstrap !== 'undefined') {
            modalInstance = bootstrap.Modal.getOrCreateInstance(modalEl);
        }
        return modalInstance;
    }

    function viewUrl(taskId) {
        var tpl = config.viewUrlTemplate || '';
        return tpl.replace('__ID__', String(taskId));
    }

    function clearFooter() {
        if (!footerSlot) {
            return;
        }
        footerSlot.innerHTML = '';
        footerSlot.classList.add('d-none');
    }

    function setLoading() {
        bodyEl.innerHTML = loadingHtml;
        if (headerEl) {
            headerEl.innerHTML = defaultHeaderHtml;
        }
        clearFooter();
    }

    function setTitle(text) {
        if (titleEl) {
            titleEl.textContent = text || 'Задача';
        }
    }

    function setSubtitle(text) {
        if (!subtitleEl) {
            return;
        }
        if (text) {
            subtitleEl.textContent = text;
            subtitleEl.classList.remove('d-none');
        } else {
            subtitleEl.textContent = '';
            subtitleEl.classList.add('d-none');
        }
    }

    function mountHeader(root) {
        if (!headerEl || !root) {
            return;
        }
        var slot = root.querySelector('#workTaskViewHeaderSlot');
        if (!slot) {
            return;
        }
        headerEl.innerHTML = '';
        headerEl.appendChild(slot);
        slot.classList.add('work-task-view__header-slot--in-modal');
        var titleNode = slot.querySelector('.work-task-view__title');
        if (titleNode) {
            setTitle(titleNode.textContent.trim());
        }
        var subtitleNode = slot.querySelector('.work-task-view__subtitle');
        if (subtitleNode) {
            setSubtitle(subtitleNode.textContent.trim());
        } else {
            setSubtitle('');
        }
    }

    function mountFooter(root) {
        if (!footerSlot || !root) {
            return;
        }
        var footer = root.querySelector('.work-task-view__footer');
        clearFooter();
        if (!footer) {
            return;
        }
        footer.classList.add('work-task-view__footer--in-modal');
        footerSlot.appendChild(footer);
        footerSlot.classList.remove('d-none');
    }

    function loadTask(taskId) {
        currentTaskId = taskId;
        setLoading();
        setTitle('Задача #' + taskId);

        return fetch(viewUrl(taskId), {
            headers: { 'X-Requested-With': 'XMLHttpRequest', Accept: 'text/html' },
            credentials: 'same-origin',
        })
            .then(function(r) {
                if (!r.ok) {
                    return r.text().then(function(text) {
                        var err = new Error('load failed');
                        err.status = r.status;
                        err.body = text;
                        throw err;
                    });
                }
                return r.text();
            })
            .then(function(html) {
                if (!html || html.indexOf('work-task-view') === -1) {
                    throw new Error('invalid response');
                }
                bodyEl.innerHTML = html;
                var root = bodyEl.querySelector('.work-task-view');
                mountHeader(root);
                mountFooter(root);
                var commentList = bodyEl.querySelector('.work-task-comment-list');
                if (commentList) {
                    commentList.scrollTop = commentList.scrollHeight;
                }
            })
            .catch(function(err) {
                var msg = 'Не удалось загрузить задачу.';
                if (err && err.status === 403) {
                    msg = 'Нет доступа к этой задаче.';
                } else if (err && err.status === 404) {
                    msg = 'Задача не найдена.';
                }
                bodyEl.innerHTML = '<p class="text-danger mb-0">' + msg + '</p>';
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

    function reload(transitionRes) {
        if (!currentTaskId) {
            return Promise.resolve();
        }
        return loadTask(currentTaskId).then(function() {
            if (transitionRes && typeof window.workTasksBoardUpdateCard === 'function') {
                window.workTasksBoardUpdateCard(currentTaskId, transitionRes);
            }
        });
    }

    function isOpen() {
        return modalEl.classList.contains('show');
    }

    function getTaskId() {
        return currentTaskId;
    }

    window.WorkTasksView = {
        open: open,
        reload: reload,
        isOpen: isOpen,
        getTaskId: getTaskId,
        load: loadTask,
    };

    document.addEventListener('click', function(e) {
        if (e.target.closest('.work-task-card__request-link')) {
            return;
        }

        var link = e.target.closest('a[data-work-task-view]');
        if (link) {
            e.preventDefault();
            open(link.getAttribute('data-work-task-view'));
            return;
        }

        var card = e.target.closest('.work-task-card--kanban, .work-task-card--closed');
        if (!card) {
            return;
        }
        if (e.target.closest('a')) {
            return;
        }
        e.preventDefault();
        open(card.getAttribute('data-task-id'));
    });

    modalEl.addEventListener('hidden.bs.modal', function() {
        currentTaskId = null;
        setTitle('Задача');
        setSubtitle('');
        setLoading();
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
