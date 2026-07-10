(function() {
    'use strict';

    var boardHost = document.querySelector('.work-tasks-board-card__body');
    if (!boardHost) {
        return;
    }

    function getBoard() {
        return document.getElementById('workKanbanBoard');
    }

    var dragState = null;

    function postForm(url, data) {
        var body = new FormData();
        Object.keys(data).forEach(function(key) {
            if (data[key] !== undefined && data[key] !== null) {
                body.append(key, data[key]);
            }
        });
        if (window.yii && typeof yii.getCsrfParam === 'function') {
            body.append(yii.getCsrfParam(), yii.getCsrfToken());
        }
        return fetch(url, {
            method: 'POST',
            body: body,
            headers: { 'X-Requested-With': 'XMLHttpRequest' },
            credentials: 'same-origin',
        }).then(function(response) {
            return response.text().then(function(text) {
                var payload = null;
                if (text) {
                    try {
                        payload = JSON.parse(text);
                    } catch (parseError) {
                        var error = new Error('Сервер вернул некорректный ответ');
                        error.isParseError = true;
                        error.status = response.status;
                        throw error;
                    }
                }
                if (!response.ok) {
                    var httpError = new Error(
                        (payload && payload.message) ? payload.message : ('HTTP ' + response.status)
                    );
                    httpError.payload = payload;
                    throw httpError;
                }
                return payload || { success: false, message: 'Пустой ответ сервера' };
            });
        });
    }

    function showToast(message, isError) {
        var el = document.getElementById('workTaskBoardToast');
        if (!el) {
            return;
        }
        el.textContent = message;
        el.hidden = false;
        el.classList.toggle('is-error', !!isError);
        clearTimeout(showToast._timer);
        showToast._timer = setTimeout(function() {
            el.hidden = true;
        }, 5000);
    }

    function parseAllowed(card) {
        var raw = card.getAttribute('data-allowed') || '';
        if (!raw) {
            return [];
        }
        return raw.split(',').map(function(s) {
            return s.trim();
        }).filter(Boolean);
    }

    function normalizeAllowedList(list) {
        if (Array.isArray(list)) {
            return list;
        }
        if (list && typeof list === 'object') {
            return Object.keys(list).map(function(k) {
                return list[k];
            });
        }
        return [];
    }

    function setCardAllowed(card, list) {
        var allowed = normalizeAllowedList(list);
        card.setAttribute('data-allowed', allowed.join(','));
        if (allowed.length > 0) {
            card.setAttribute('draggable', 'true');
            card.classList.remove('work-task-card--locked');
        } else {
            card.removeAttribute('draggable');
            card.classList.add('work-task-card--locked');
        }
    }

    function getColumnZone(statusCode) {
        if (!statusCode) {
            return null;
        }
        var board = getBoard();
        if (!board) {
            return null;
        }
        var column = board.querySelector('.work-kanban__column[data-status-code="' + statusCode + '"]');
        return column ? column.querySelector('[data-drop-zone]') : null;
    }

    function placeCardInColumn(card, statusCode) {
        var zone = getColumnZone(statusCode);
        if (!zone) {
            return null;
        }
        zone.appendChild(card);
        return zone.closest('.work-kanban__column');
    }

    function isActiveBoardFilter() {
        var board = getBoard();
        return board && board.getAttribute('data-board-filter') === 'active';
    }

    /** На вкладке «Активные» закрытые задачи с доски убираются. */
    function finalizeCardOnActiveBoard(card, statusCode) {
        if (!isActiveBoardFilter() || !isFinalStatus(statusCode)) {
            return false;
        }
        card.remove();
        updateColumnCounts();
        return true;
    }

    function normalizeExecutorNames(executorNames) {
        if (Array.isArray(executorNames)) {
            return executorNames.map(function(name) {
                return String(name || '').trim();
            }).filter(Boolean);
        }
        if (!executorNames) {
            return [];
        }
        return String(executorNames).split(',').map(function(name) {
            return name.trim();
        }).filter(Boolean);
    }

    function setCardExecutors(card, executorNames) {
        var people = card.querySelector('.work-task-card__people');
        if (!people) {
            return;
        }
        var names = normalizeExecutorNames(executorNames);
        var row = card.querySelector('.work-task-card__person--executor');
        if (names.length === 0) {
            if (row) {
                row.remove();
            }
            return;
        }
        if (!row) {
            row = document.createElement('div');
            people.appendChild(row);
        }
        row.className = 'work-task-card__person work-task-card__person--executor'
            + (names.length > 1 ? ' work-task-card__person--executors-multi' : '');
        while (row.firstChild) {
            row.removeChild(row.firstChild);
        }

        var label = document.createElement('span');
        label.className = 'work-task-card__person-label';
        label.textContent = names.length > 1 ? 'Исполнители' : 'Исполнитель';
        row.appendChild(label);

        if (names.length === 1) {
            var single = document.createElement('span');
            single.className = 'work-task-card__person-name work-task-card__executor-name';
            single.textContent = names[0];
            row.appendChild(single);
            return;
        }

        var list = document.createElement('ul');
        list.className = 'work-task-card__executor-names list-unstyled mb-0';
        names.forEach(function(name) {
            var item = document.createElement('li');
            item.className = 'work-task-card__person-name work-task-card__executor-name';
            item.textContent = name;
            list.appendChild(item);
        });
        row.appendChild(list);
    }

    function updateCardTimeInStatus(card, res) {
        if (!card || !res) {
            return;
        }
        var label = res.time_in_status;
        var title = res.time_in_status_title;
        var isCompletion = res.time_is_completion === true;
        if (!label) {
            return;
        }
        var iconClass = isCompletion ? 'far fa-calendar-alt' : 'far fa-clock';
        var slot = card.querySelector('.work-task-card__time-slot');
        if (!slot) {
            var head = card.querySelector('.work-task-card__head');
            if (!head) {
                return;
            }
            slot = document.createElement('div');
            slot.className = 'work-task-card__time-slot';
            head.appendChild(slot);
        }
        slot.innerHTML = '<span class="work-task-card__time-in-status" title="">'
            + '<i class="' + iconClass + '" aria-hidden="true"></i> '
            + '</span>';
        var span = slot.querySelector('.work-task-card__time-in-status');
        if (span) {
            span.classList.toggle('work-task-card__time-in-status--completion', isCompletion);
            if (title) {
                span.setAttribute('title', title);
            }
            var icon = span.querySelector('i');
            span.textContent = '';
            if (icon) {
                icon.className = iconClass;
                span.appendChild(icon);
            } else {
                var iEl = document.createElement('i');
                iEl.className = iconClass;
                iEl.setAttribute('aria-hidden', 'true');
                span.appendChild(iEl);
            }
            span.appendChild(document.createTextNode(' ' + label));
        }
    }

    var PENDING_REVIEW_STATUS = 'pending_review';

    function countPendingReviewOnBoard() {
        var board = getBoard();
        if (!board) {
            return 0;
        }
        var column = board.querySelector(
            '.work-kanban__column[data-status-code="' + PENDING_REVIEW_STATUS + '"]'
        );
        if (!column) {
            return 0;
        }
        var zone = column.querySelector('[data-drop-zone]');
        if (!zone) {
            return 0;
        }
        return zone.querySelectorAll('.work-task-card--kanban').length;
    }

    function updateBulkConfirmButton() {
        var btn = document.querySelector('[data-work-tasks-bulk-confirm]');
        if (!btn) {
            return;
        }
        var count = countPendingReviewOnBoard();
        btn.setAttribute('data-count', String(count));
        btn.disabled = count <= 0;
        var label = btn.querySelector('.arm-btn-label');
        if (label) {
            label.textContent = count > 0
                ? 'Подтвердить все (' + count + ')'
                : 'Подтвердить все';
        }
    }

    function updateColumnCounts() {
        var board = getBoard();
        if (!board) {
            return;
        }
        board.querySelectorAll('.work-kanban__column').forEach(function(col) {
            var zone = col.querySelector('[data-drop-zone]');
            var countEl = col.querySelector('.work-kanban__column-count');
            if (zone && countEl) {
                countEl.textContent = String(zone.querySelectorAll('.work-task-card--kanban').length);
            }
        });
        updateBulkConfirmButton();
    }

    function highlightDropTargets(allowed) {
        var board = getBoard();
        if (!board) {
            return;
        }
        board.querySelectorAll('.work-kanban__column').forEach(function(col) {
            var code = col.getAttribute('data-status-code');
            var canDrop = allowed.indexOf(code) >= 0;
            col.classList.toggle('is-drop-target', canDrop);
            col.classList.toggle('is-drop-disabled', !canDrop && !!dragState);
        });
    }

    function clearDropHighlights() {
        var board = getBoard();
        if (!board) {
            return;
        }
        board.querySelectorAll('.work-kanban__column').forEach(function(col) {
            col.classList.remove('is-drop-target', 'is-drop-disabled', 'is-drag-over');
        });
    }

    function resetCardDragStyles(card) {
        if (!card) {
            return;
        }
        card.classList.remove('is-dragging', 'is-saving');
    }

    function clearDragState() {
        if (dragState && dragState.card) {
            resetCardDragStyles(dragState.card);
        }
        dragState = null;
        clearDropHighlights();
    }

    function isFinalStatus(code) {
        return code === 'done' || code === 'cancelled';
    }

    boardHost.addEventListener('dragstart', function(e) {
        var board = getBoard();
        if (!board || !board.contains(e.target)) {
            return;
        }
        var card = e.target.closest('.work-task-card--kanban');
        if (!card || !card.getAttribute('draggable')) {
            e.preventDefault();
            return;
        }
        dragState = {
            card: card,
            sourceColumn: card.closest('.work-kanban__column'),
        };
        card.classList.add('is-dragging');
        e.dataTransfer.effectAllowed = 'move';
        e.dataTransfer.setData('text/plain', card.getAttribute('data-task-id') || '');
        highlightDropTargets(parseAllowed(card));
    });

    boardHost.addEventListener('dragend', function() {
        var board = getBoard();
        if (!board) {
            return;
        }
        board.querySelectorAll('.work-task-card--kanban.is-dragging').forEach(function(card) {
            card.classList.remove('is-dragging');
        });
        clearDropHighlights();
        dragState = null;
    });

    boardHost.addEventListener('dragover', function(e) {
        if (!dragState) {
            return;
        }
        var board = getBoard();
        if (!board) {
            return;
        }
        var column = e.target.closest('.work-kanban__column');
        if (!column || !board.contains(column)) {
            return;
        }
        e.preventDefault();
        var code = column.getAttribute('data-status-code');
        var allowed = parseAllowed(dragState.card);
        if (allowed.indexOf(code) >= 0) {
            e.dataTransfer.dropEffect = 'move';
            column.classList.add('is-drag-over');
        } else {
            e.dataTransfer.dropEffect = 'none';
        }
    });

    boardHost.addEventListener('dragleave', function(e) {
        var board = getBoard();
        if (!board) {
            return;
        }
        var column = e.target.closest('.work-kanban__column');
        if (column && board.contains(column)) {
            column.classList.remove('is-drag-over');
        }
    });

    boardHost.addEventListener('drop', function(e) {
        e.preventDefault();
        e.stopPropagation();

        var state = dragState;
        if (!state || !state.card) {
            return;
        }

        var board = getBoard();
        if (!board) {
            clearDragState();
            return;
        }

        var column = e.target.closest('.work-kanban__column');
        if (!column || !board.contains(column)) {
            clearDragState();
            return;
        }

        var zone = column.querySelector('[data-drop-zone]');
        column.classList.remove('is-drag-over');

        var targetCode = column.getAttribute('data-status-code');
        var cardRef = state.card;
        var sourceCol = state.sourceColumn;
        var currentCode = cardRef.getAttribute('data-status-code');

        if (!zone || !targetCode || targetCode === currentCode) {
            clearDragState();
            return;
        }

        var allowed = parseAllowed(cardRef);
        if (allowed.indexOf(targetCode) < 0) {
            showToast('Нельзя перевести задачу в этот статус', true);
            clearDragState();
            return;
        }

        var url = cardRef.getAttribute('data-transition-url');
        resetCardDragStyles(cardRef);
        cardRef.classList.add('is-saving');
        dragState = null;
        clearDropHighlights();

        if (!url) {
            showToast('Не найден адрес для смены статуса', true);
            clearDragState();
            return;
        }

        window.workTasksRealtimePollPaused = true;
        postForm(url, { status_code: targetCode })
            .then(function(res) {
                if (!res.success) {
                    if (sourceCol) {
                        var srcZone = sourceCol.querySelector('[data-drop-zone]');
                        if (srcZone) {
                            srcZone.appendChild(cardRef);
                        }
                    }
                    showToast(res.message || 'Ошибка', true);
                    return;
                }

                var newCode = res.status_code || targetCode;
                cardRef.setAttribute('data-status-code', newCode);
                setCardAllowed(cardRef, res.allowed_transitions || []);

                if (finalizeCardOnActiveBoard(cardRef, newCode)) {
                    showToast((res.message || 'Статус обновлён') + '. Задача закрыта — см. вкладку «Закрытые».', false);
                    if (window.IasRealtimeSync && typeof window.IasRealtimeSync.refreshWorkTasksPoll === 'function') {
                        window.IasRealtimeSync.refreshWorkTasksPoll();
                    }
                    return;
                }

                var targetColumn = placeCardInColumn(cardRef, newCode);
                updateCardTimeInStatus(cardRef, res);
                try {
                    updateColumnCounts();
                } catch (countError) {
                    console.error('work-tasks-board: updateColumnCounts failed', countError);
                }

                if (targetColumn) {
                    targetColumn.classList.add('is-drop-flash');
                    setTimeout(function() {
                        targetColumn.classList.remove('is-drop-flash');
                    }, 1200);
                    targetColumn.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'center' });
                }

                showToast(res.message || 'Статус обновлён', false);

                if (window.IasRealtimeSync && typeof window.IasRealtimeSync.refreshWorkTasksPoll === 'function') {
                    window.IasRealtimeSync.refreshWorkTasksPoll();
                }
            })
            .catch(function(err) {
                if (sourceCol) {
                    var revertZone = sourceCol.querySelector('[data-drop-zone]');
                    if (revertZone) {
                        revertZone.appendChild(cardRef);
                    }
                }
                showToast((err && err.message) ? err.message : 'Ошибка сети', true);
            })
            .finally(function() {
                window.workTasksRealtimePollPaused = false;
                resetCardDragStyles(cardRef);
            });
    });

    window.workTasksBoardRemoveCard = function(taskId) {
        var board = getBoard();
        if (!board) {
            return;
        }
        var card = board.querySelector('.work-task-card--kanban[data-task-id="' + taskId + '"]');
        if (!card) {
            return;
        }
        card.remove();
        updateColumnCounts();
    };

    window.workTasksBoardUpdateBulkConfirm = updateBulkConfirmButton;

    window.workTasksBoardUpdateCard = function(taskId, res) {
        var board = getBoard();
        if (!board) {
            return;
        }
        var card = board.querySelector('.work-task-card--kanban[data-task-id="' + taskId + '"]');
        if (!card || !res) {
            return;
        }
        var newCode = res.status_code;
        if (!newCode) {
            return;
        }
        card.setAttribute('data-status-code', newCode);
        var allowed = normalizeAllowedList(res.allowed_transitions || []);
        card.setAttribute('data-allowed', allowed.join(','));
        if (allowed.length > 0) {
            card.setAttribute('draggable', 'true');
            card.classList.remove('work-task-card--locked');
        } else {
            card.removeAttribute('draggable');
            card.classList.add('work-task-card--locked');
        }
        if (finalizeCardOnActiveBoard(card, newCode)) {
            return;
        }
        placeCardInColumn(card, newCode);
        updateCardTimeInStatus(card, res);
        updateColumnCounts();

        if (res.executor_names !== undefined) {
            setCardExecutors(card, res.executor_names);
        } else if (res.executor_name !== undefined) {
            setCardExecutors(card, res.executor_name);
        }

        var targetColumn = getColumnZone(newCode);
        if (targetColumn) {
            var col = targetColumn.closest('.work-kanban__column');
            if (col) {
                col.classList.add('is-drop-flash');
                setTimeout(function() {
                    col.classList.remove('is-drop-flash');
                }, 1200);
            }
        }
    };

    window.workTasksBoardGetTaskIds = function() {
        var board = getBoard();
        if (board) {
            return Array.prototype.map.call(
                board.querySelectorAll('.work-task-card--kanban[data-task-id]'),
                function(card) {
                    return parseInt(card.getAttribute('data-task-id'), 10);
                }
            ).filter(function(id) {
                return id > 0;
            });
        }

        var closedList = document.getElementById('workTasksClosedList');
        if (!closedList) {
            return [];
        }

        return Array.prototype.map.call(
            closedList.querySelectorAll('[data-task-id]'),
            function(card) {
                return parseInt(card.getAttribute('data-task-id'), 10);
            }
        ).filter(function(id) {
            return id > 0;
        });
    };

    window.workTasksBoardUpdateColumnCounts = updateColumnCounts;
})();
