(function() {
    'use strict';

    var board = document.getElementById('workKanbanBoard');
    if (!board) {
        return;
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
        }).then(function(r) {
            return r.json();
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
        return board.getAttribute('data-board-filter') === 'active';
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

    function updateCardTimeInStatus(card, res) {
        if (!card || !res) {
            return;
        }
        var label = res.time_in_status;
        var title = res.time_in_status_title;
        if (!label) {
            return;
        }
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
            + '<i class="far fa-clock" aria-hidden="true"></i> '
            + '</span>';
        var span = slot.querySelector('.work-task-card__time-in-status');
        if (span) {
            if (title) {
                span.setAttribute('title', title);
            }
            var icon = span.querySelector('i');
            span.textContent = '';
            if (icon) {
                span.appendChild(icon);
            } else {
                var iEl = document.createElement('i');
                iEl.className = 'far fa-clock';
                iEl.setAttribute('aria-hidden', 'true');
                span.appendChild(iEl);
            }
            span.appendChild(document.createTextNode(' ' + label));
        }
    }

    function updateColumnCounts() {
        board.querySelectorAll('.work-kanban__column').forEach(function(col) {
            var zone = col.querySelector('[data-drop-zone]');
            var countEl = col.querySelector('.work-kanban__column-count');
            if (zone && countEl) {
                countEl.textContent = String(zone.querySelectorAll('.work-task-card--kanban').length);
            }
        });
    }

    function highlightDropTargets(allowed) {
        board.querySelectorAll('.work-kanban__column').forEach(function(col) {
            var code = col.getAttribute('data-status-code');
            var canDrop = allowed.indexOf(code) >= 0;
            col.classList.toggle('is-drop-target', canDrop);
            col.classList.toggle('is-drop-disabled', !canDrop && !!dragState);
        });
    }

    function clearDropHighlights() {
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

    board.addEventListener('dragstart', function(e) {
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

    board.addEventListener('dragend', function() {
        board.querySelectorAll('.work-task-card--kanban.is-dragging').forEach(function(card) {
            card.classList.remove('is-dragging');
        });
        clearDropHighlights();
        dragState = null;
    });

    board.addEventListener('dragover', function(e) {
        if (!dragState) {
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

    board.addEventListener('dragleave', function(e) {
        var column = e.target.closest('.work-kanban__column');
        if (column && board.contains(column)) {
            column.classList.remove('is-drag-over');
        }
    });

    board.addEventListener('drop', function(e) {
        e.preventDefault();
        e.stopPropagation();

        var state = dragState;
        if (!state || !state.card) {
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
                    return;
                }

                var targetColumn = placeCardInColumn(cardRef, newCode);
                updateCardTimeInStatus(cardRef, res);
                updateColumnCounts();

                if (targetColumn) {
                    targetColumn.classList.add('is-drop-flash');
                    setTimeout(function() {
                        targetColumn.classList.remove('is-drop-flash');
                    }, 1200);
                    targetColumn.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'center' });
                }

                showToast(res.message || 'Статус обновлён', false);
            })
            .catch(function() {
                if (sourceCol) {
                    var revertZone = sourceCol.querySelector('[data-drop-zone]');
                    if (revertZone) {
                        revertZone.appendChild(cardRef);
                    }
                }
                showToast('Ошибка сети', true);
            })
            .finally(function() {
                resetCardDragStyles(cardRef);
            });
    });

    window.workTasksBoardRemoveCard = function(taskId) {
        var card = board.querySelector('.work-task-card--kanban[data-task-id="' + taskId + '"]');
        if (!card) {
            return;
        }
        card.remove();
        updateColumnCounts();
    };

    window.workTasksBoardUpdateCard = function(taskId, res) {
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

        if (res.executor_name !== undefined) {
            var executorEl = card.querySelector('.work-task-card__executor-name');
            var executorRow = card.querySelector('.work-task-card__person--executor');
            if (executorEl) {
                if (res.executor_name) {
                    executorEl.textContent = res.executor_name;
                    if (executorRow) {
                        executorRow.classList.remove('work-task-card__person--empty');
                    }
                } else {
                    executorEl.innerHTML = '<span class="work-task-card__person-missing">Не назначен</span>';
                    if (executorRow) {
                        executorRow.classList.add('work-task-card__person--empty');
                    }
                }
            }
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
})();
