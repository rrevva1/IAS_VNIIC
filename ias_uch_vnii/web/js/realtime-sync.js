/**
 * Фоновое обновление разделов «Заявки» и «Задачи» без перезагрузки страницы.
 */
(function() {
    'use strict';

    var DEFAULT_INTERVAL_MS = 5000;
    var polls = [];

    function isPageVisible() {
        return typeof document.hidden === 'undefined' || !document.hidden;
    }

    function appendQuery(url, params) {
        var parts = [];
        Object.keys(params).forEach(function(key) {
            if (key === 'r') {
                return;
            }
            var value = params[key];
            if (value === undefined || value === null || value === '') {
                return;
            }
            parts.push(encodeURIComponent(key) + '=' + encodeURIComponent(String(value)));
        });
        if (!parts.length) {
            return url;
        }
        var sep = url.indexOf('?') >= 0 ? '&' : '?';
        return url + sep + parts.join('&');
    }

    function fetchJson(url) {
        return fetch(url, {
            headers: {
                'X-Requested-With': 'XMLHttpRequest',
                Accept: 'application/json',
            },
            credentials: 'same-origin',
        }).then(function(response) {
            return response.text().then(function(text) {
                if (!response.ok) {
                    throw new Error('HTTP ' + response.status);
                }
                if (!text) {
                    return null;
                }
                try {
                    return JSON.parse(text);
                } catch (parseError) {
                    var preview = text.replace(/\s+/g, ' ').slice(0, 120);
                    var error = new Error('Некорректный JSON: ' + preview);
                    error.isParseError = true;
                    throw error;
                }
            });
        });
    }

    function startPoll(config) {
        if (!config || !config.url || typeof config.onResult !== 'function') {
            return null;
        }

        var state = {
            timer: null,
            version: config.initialVersion || '',
            paused: false,
            intervalMs: config.intervalMs || DEFAULT_INTERVAL_MS,
            url: config.url,
            getParams: config.getParams || function() { return {}; },
            onResult: config.onResult,
            shouldPoll: config.shouldPoll || function() { return true; },
        };

        function clearTimer() {
            if (state.timer) {
                clearTimeout(state.timer);
                state.timer = null;
            }
        }

        function scheduleNext(delay) {
            clearTimer();
            state.timer = setTimeout(runPoll, delay == null ? state.intervalMs : delay);
        }

        function runPoll() {
            if (!isPageVisible() || state.paused || !state.shouldPoll()) {
                scheduleNext();
                return;
            }

            var params = Object.assign({}, state.getParams(), {
                version: state.version,
            });

            fetchJson(appendQuery(state.url, params))
                .then(function(result) {
                    if (!result || !result.success) {
                        if (result && result.message && typeof console !== 'undefined' && console.warn) {
                            console.warn('IasRealtimeSync: poll rejected', result.message);
                        }
                        return;
                    }
                    if (result.version) {
                        state.version = result.version;
                    }
                    state.onResult(result, state);
                })
                .catch(function(err) {
                    if (typeof console !== 'undefined' && console.warn) {
                        console.warn('IasRealtimeSync: poll failed', err);
                    }
                })
                .finally(function() {
                    scheduleNext();
                });
        }

        state.pause = function() {
            state.paused = true;
        };

        state.resume = function() {
            state.paused = false;
        };

        state.refreshNow = function() {
            clearTimer();
            runPoll();
        };

        state.resetVersion = function() {
            state.version = '';
        };

        state.stop = function() {
            clearTimer();
            var index = polls.indexOf(state);
            if (index >= 0) {
                polls.splice(index, 1);
            }
        };

        polls.push(state);
        scheduleNext(config.initialDelayMs || state.intervalMs);

        return state;
    }

    function applyTasksGridData(gridApi, rows) {
        if (!gridApi || !Array.isArray(rows)) {
            return;
        }

        var existing = {};
        if (typeof gridApi.forEachNode === 'function') {
            gridApi.forEachNode(function(node) {
                if (node && node.data && node.data.id != null) {
                    existing[String(node.data.id)] = node.data;
                }
            });
        }

        var nextIds = {};
        rows.forEach(function(row) {
            if (!row || row.id == null) {
                return;
            }
            nextIds[String(row.id)] = true;
        });

        var toRemove = [];
        Object.keys(existing).forEach(function(id) {
            if (!nextIds[id]) {
                toRemove.push(existing[id]);
            }
        });

        var toAdd = [];
        var toUpdate = [];
        rows.forEach(function(row) {
            if (!row || row.id == null) {
                return;
            }
            var key = String(row.id);
            if (existing[key]) {
                toUpdate.push(row);
            } else {
                toAdd.push(row);
            }
        });

        if (typeof gridApi.applyTransaction === 'function') {
            gridApi.applyTransaction({
                add: toAdd,
                update: toUpdate,
                remove: toRemove,
            });
        } else {
            gridApi.setGridOption('rowData', rows);
        }

        if (typeof gridApi.refreshCells === 'function') {
            gridApi.refreshCells({ force: true });
        }

        if (typeof window.syncTasksDeleteButton === 'function') {
            window.syncTasksDeleteButton();
        }

        if (typeof window.cleanupExecutorSelect2InGrid === 'function') {
            window.cleanupExecutorSelect2InGrid();
        }
    }

    function replaceHtmlTarget(targetId, html) {
        if (!targetId || !html) {
            return;
        }
        var current = document.getElementById(targetId);
        if (!current) {
            return;
        }
        var wrapper = document.createElement('div');
        wrapper.innerHTML = html.trim();
        var next = wrapper.firstElementChild;
        if (!next) {
            return;
        }
        current.replaceWith(next);
    }

    function updateBulkConfirmButton(count) {
        var btn = document.querySelector('[data-work-tasks-bulk-confirm]');
        if (!btn) {
            return;
        }
        var safeCount = parseInt(count, 10) || 0;
        btn.setAttribute('data-count', String(safeCount));
        btn.disabled = safeCount <= 0;
        var label = btn.querySelector('.arm-btn-label');
        if (label) {
            label.textContent = safeCount > 0
                ? 'Подтвердить все (' + safeCount + ')'
                : 'Подтвердить все';
        }
    }

    function applyWorkTasksBoardSync(result) {
        if (!result || !result.changed) {
            if (result && result.pending_review_count !== undefined) {
                updateBulkConfirmButton(result.pending_review_count);
            }
            return;
        }

        if (result.pending_review_count !== undefined) {
            updateBulkConfirmButton(result.pending_review_count);
        }

        if (result.structure_changed && result.html && result.html_target) {
            replaceHtmlTarget(result.html_target, result.html);
            if (typeof window.workTasksBoardUpdateColumnCounts === 'function') {
                window.workTasksBoardUpdateColumnCounts();
            }
            return;
        }

        if (!Array.isArray(result.tasks)) {
            return;
        }

        var board = document.getElementById('workKanbanBoard');
        if (!board) {
            if (result.mode === 'closed' && result.html) {
                replaceHtmlTarget('workTasksClosedList', result.html);
            }
            return;
        }

        var serverIds = {};
        result.tasks.forEach(function(task) {
            if (task && task.id) {
                serverIds[String(task.id)] = true;
            }
        });

        board.querySelectorAll('.work-task-card--kanban[data-task-id]').forEach(function(card) {
            var id = card.getAttribute('data-task-id');
            if (id && !serverIds[id] && typeof window.workTasksBoardRemoveCard === 'function') {
                window.workTasksBoardRemoveCard(parseInt(id, 10));
            }
        });

        result.tasks.forEach(function(task) {
            if (!task || !task.id) {
                return;
            }
            if (typeof window.workTasksBoardUpdateCard === 'function') {
                window.workTasksBoardUpdateCard(task.id, task);
            }
        });
    }

    function buildWorkTasksPollParams() {
        var params = {};
        var form = document.querySelector('.work-tasks-command-form');
        if (!form) {
            return params;
        }

        var elements = form.querySelectorAll('input[name], select[name]');
        elements.forEach(function(el) {
            if (!el.name || el.type === 'submit' || el.name === 'r') {
                return;
            }
            if ((el.type === 'checkbox' || el.type === 'radio') && !el.checked) {
                return;
            }
            params[el.name] = el.value;
        });

        if (typeof window.workTasksBoardGetTaskIds === 'function') {
            var ids = window.workTasksBoardGetTaskIds();
            if (ids.length) {
                params.ids = ids.join(',');
            }
        } else {
            var board = document.getElementById('workKanbanBoard');
            if (board) {
                var fallbackIds = Array.prototype.map.call(
                    board.querySelectorAll('.work-task-card--kanban[data-task-id]'),
                    function(card) {
                        return parseInt(card.getAttribute('data-task-id'), 10);
                    }
                ).filter(function(id) {
                    return id > 0;
                });
                if (fallbackIds.length) {
                    params.ids = fallbackIds.join(',');
                }
            } else {
                var closedList = document.getElementById('workTasksClosedList');
                if (closedList) {
                    var closedIds = Array.prototype.map.call(
                        closedList.querySelectorAll('[data-task-id]'),
                        function(card) {
                            return parseInt(card.getAttribute('data-task-id'), 10);
                        }
                    ).filter(function(id) {
                        return id > 0;
                    });
                    if (closedIds.length) {
                        params.ids = closedIds.join(',');
                    }
                }
            }
        }

        return params;
    }

    function initTasksPolling() {
        if (!window.tasksRealtimePollUrl || !document.getElementById('agGridTasksContainer')) {
            return null;
        }
        if (window.tasksRealtimePoll) {
            return window.tasksRealtimePoll;
        }

        var poll = startPoll({
            url: window.tasksRealtimePollUrl,
            intervalMs: window.tasksRealtimePollIntervalMs || DEFAULT_INTERVAL_MS,
            initialDelayMs: 2000,
            getParams: function() {
                var params = {};
                var code = window.tasksStatusFilter || '';
                if (code !== '') {
                    params.status_code = code;
                }
                return params;
            },
            shouldPoll: function() {
                return !window.tasksRealtimePollPaused && !!window.tasksGridApi;
            },
            onResult: function(result) {
                if (!result.changed || !Array.isArray(result.data)) {
                    return;
                }
                var api = window.tasksGridApi;
                if (!api) {
                    return;
                }

                applyTasksGridData(api, result.data);

                if (window.TasksView && typeof window.TasksView.getTaskId === 'function') {
                    var openId = window.TasksView.getTaskId();
                    if (openId && window.TasksView.isOpen && window.TasksView.isOpen()
                        && result.data.some(function(row) { return row && String(row.id) === String(openId); })
                        && typeof window.TasksView.reload === 'function') {
                        window.TasksView.reload();
                    }
                }
            },
        });

        window.tasksRealtimePoll = poll;
        return poll;
    }

    function ensureTasksPolling() {
        if (!window.tasksGridApi) {
            return null;
        }
        var poll = initTasksPolling();
        if (poll && typeof poll.refreshNow === 'function') {
            poll.refreshNow();
        }
        return poll;
    }

    function initWorkTasksPolling() {
        if (!window.workTasksRealtimePollUrl || !document.querySelector('.work-tasks-page')) {
            return null;
        }
        if (window.workTasksRealtimePoll) {
            return window.workTasksRealtimePoll;
        }

        var poll = startPoll({
            url: window.workTasksRealtimePollUrl,
            intervalMs: window.workTasksRealtimePollIntervalMs || DEFAULT_INTERVAL_MS,
            initialDelayMs: 2000,
            getParams: buildWorkTasksPollParams,
            shouldPoll: function() {
                return !window.workTasksRealtimePollPaused && !dragStateActive();
            },
            onResult: function(result) {
                if (!result.changed) {
                    if (result.pending_review_count !== undefined) {
                        updateBulkConfirmButton(result.pending_review_count);
                    }
                    return;
                }

                applyWorkTasksBoardSync(result);

                if (!window.WorkTasksView || typeof window.WorkTasksView.getTaskId !== 'function') {
                    return;
                }
                var openId = window.WorkTasksView.getTaskId();
                if (!openId || !window.WorkTasksView.isOpen || !window.WorkTasksView.isOpen()) {
                    return;
                }
                if (!result.changed) {
                    return;
                }
                var touched = false;
                if (Array.isArray(result.tasks)) {
                    touched = result.tasks.some(function(task) {
                        return task && String(task.id) === String(openId);
                    });
                }
                if (!touched && result.structure_changed) {
                    touched = true;
                }
                if (touched && typeof window.WorkTasksView.reload === 'function') {
                    window.WorkTasksView.reload();
                }
            },
        });

        window.workTasksRealtimePoll = poll;
        return poll;
    }

    function dragStateActive() {
        return !!document.querySelector('.work-task-card--kanban.is-dragging, .work-task-card--kanban.is-saving');
    }

    document.addEventListener('visibilitychange', function() {
        if (!isPageVisible()) {
            return;
        }
        polls.forEach(function(poll) {
            poll.refreshNow();
        });
    });

    window.IasRealtimeSync = {
        startPoll: startPoll,
        applyTasksGridData: applyTasksGridData,
        applyWorkTasksBoardSync: applyWorkTasksBoardSync,
        initTasksPolling: initTasksPolling,
        ensureTasksPolling: ensureTasksPolling,
        initWorkTasksPolling: initWorkTasksPolling,
        refreshWorkTasksPoll: function() {
            if (!window.workTasksRealtimePoll) {
                initWorkTasksPolling();
            }
            if (window.workTasksRealtimePoll && typeof window.workTasksRealtimePoll.resetVersion === 'function') {
                window.workTasksRealtimePoll.resetVersion();
            }
            if (window.workTasksRealtimePoll && typeof window.workTasksRealtimePoll.refreshNow === 'function') {
                window.workTasksRealtimePoll.refreshNow();
            }
        },
    };

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initWorkTasksPolling);
    } else {
        initWorkTasksPolling();
    }
})();
