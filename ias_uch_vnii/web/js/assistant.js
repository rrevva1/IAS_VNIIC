/**
 * ИИ-помощник: диалоговое окно, запрос к assistant/query и отображение ответа
 */
(function() {
    'use strict';

    function getConfig() {
        return window.assistantConfig || {};
    }

    function getEl(id) {
        return document.getElementById(id);
    }

    function togglePanel(open) {
        var panel = getEl('assistant-panel');
        var toggle = getEl('assistant-toggle');
        if (!panel || !toggle) return;
        if (open === undefined) {
            open = panel.getAttribute('aria-hidden') === 'true';
        }
        panel.setAttribute('aria-hidden', !open);
        panel.classList.toggle('assistant-panel-open', open);
    }

    function addMessage(role, contentHtml) {
        var container = getEl('assistant-messages');
        if (!container) return null;
        var wrap = document.createElement('div');
        wrap.className = 'assistant-msg assistant-msg-' + role;
        var body = document.createElement('div');
        body.className = 'assistant-msg-body';
        body.innerHTML = contentHtml;
        wrap.appendChild(body);
        container.appendChild(wrap);
        container.scrollTop = container.scrollHeight;
        return wrap;
    }

    function renderTasksTable(data) {
        if (!data || data.length === 0) return '<p class="assistant-no-data">Нет заявок.</p>';
        var html = '<table class="assistant-table table table-sm table-bordered">';
        html += '<thead><tr><th>№</th><th>Описание</th><th>Статус</th><th>Автор</th><th>Исполнитель</th><th>Дата</th><th></th></tr></thead><tbody>';
        data.forEach(function(row) {
            html += '<tr>';
            html += '<td>' + (row.id || '') + '</td>';
            html += '<td>' + escapeHtml((row.description || '').substring(0, 80)) + (row.description && row.description.length > 80 ? '…' : '') + '</td>';
            html += '<td>' + escapeHtml(row.status_name || '') + '</td>';
            html += '<td>' + escapeHtml(row.user_name || '') + '</td>';
            html += '<td>' + escapeHtml(row.executor_name || '') + '</td>';
            html += '<td>' + escapeHtml(row.date || '') + '</td>';
            html += '<td>' + (row.view_url ? '<a href="' + escapeAttr(row.view_url) + '" target="_blank" rel="noopener">Открыть</a>' : '') + '</td>';
            html += '</tr>';
        });
        html += '</tbody></table>';
        return html;
    }

    function renderStatisticsRows(rows, summary) {
        var html = '';
        if (summary) {
            html += '<p class="assistant-summary">Всего заявок: <strong>' + (summary.total_tasks || 0) + '</strong>. Завершённых: <strong>' + (summary.total_resolved || 0) + '</strong>.</p>';
        }
        if (!rows || rows.length === 0) return html || '<p class="assistant-no-data">Нет данных.</p>';
        html += '<table class="assistant-table table table-sm table-bordered">';
        html += '<thead><tr><th>Показатель</th><th>Кол-во</th><th>%</th></tr></thead><tbody>';
        rows.forEach(function(r) {
            if (r.type === 'header') {
                html += '<tr class="assistant-table-header-row"><td colspan="3"><strong>' + escapeHtml(r.title || '') + '</strong></td></tr>';
            } else if (r.type === 'row') {
                html += '<tr><td>' + escapeHtml(r.name || '') + '</td><td>' + (r.count ?? '') + '</td><td>' + escapeHtml(r.percentage || '') + '</td></tr>';
            }
        });
        html += '</tbody></table>';
        return html;
    }

    function escapeHtml(s) {
        if (s == null) return '';
        var div = document.createElement('div');
        div.textContent = s;
        return div.innerHTML;
    }

    function escapeAttr(s) {
        if (s == null) return '';
        return String(s)
            .replace(/&/g, '&amp;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;');
    }

    function renderResponse(resp) {
        var parts = [];
        parts.push('<div class="assistant-interpretation">' + escapeHtml(resp.interpretation || '') + '</div>');

        if (resp.helpText) {
            parts.push('<div class="assistant-help-text">' + escapeHtml(resp.helpText).replace(/\n/g, '<br>') + '</div>');
        }

        if (resp.link && resp.link.url) {
            parts.push('<p class="assistant-link-wrap"><a href="' + escapeAttr(resp.link.url) + '" class="assistant-link btn btn-outline-primary btn-sm" target="_blank" rel="noopener">' + escapeHtml(resp.link.label || 'Открыть') + '</a></p>');
        }

        if (resp.data && resp.data.length > 0) {
            var first = resp.data[0];
            if (first.type === 'header' || first.type === 'row') {
                parts.push(renderStatisticsRows(resp.data, resp.summary));
            } else {
                parts.push(renderTasksTable(resp.data));
                if (resp.total != null) {
                    parts.push('<p class="assistant-total">Найдено: ' + resp.total + '</p>');
                }
            }
        } else if (resp.total === 0 && !resp.helpText && resp.data && Array.isArray(resp.data)) {
            parts.push('<p class="assistant-no-data">Нет данных по запросу.</p>');
        }

        if (resp.hints && resp.hints.length > 0) {
            parts.push('<div class="assistant-hints"><strong>Примеры запросов:</strong><ul>');
            resp.hints.forEach(function(h) {
                parts.push('<li>' + escapeHtml(h) + '</li>');
            });
            parts.push('</ul></div>');
        }

        return parts.join('');
    }

    function sendQuery(message) {
        var config = getConfig();
        var url = config.queryUrl;
        var csrfParam = config.csrfParam;
        var csrfToken = config.csrfToken;
        if (!url) {
            addMessage('assistant', '<div class="assistant-error">Не настроен URL запроса.</div>');
            return;
        }
        var payload = { message: message };
        if (csrfParam && csrfToken) {
            payload[csrfParam] = csrfToken;
        }
        var xhr = new XMLHttpRequest();
        xhr.open('POST', url, true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== 4) return;
            var container = getEl('assistant-messages');
            var loadingWrap = container ? container.querySelector('.assistant-msg-loading') : null;
            if (loadingWrap) loadingWrap.remove();
            var errMsg = '';
            try {
                var json = JSON.parse(xhr.responseText || '{}');
                if (json.success !== false) {
                    addMessage('assistant', renderResponse(json));
                    return;
                }
                errMsg = json.interpretation || json.message || 'Ошибка сервера';
            } catch (e) {
                errMsg = xhr.status === 0 ? 'Сетевая ошибка' : (xhr.responseText ? 'Ошибка ответа' : 'HTTP ' + xhr.status);
            }
            addMessage('assistant', '<div class="assistant-error">' + escapeHtml(errMsg) + '</div>');
        };
        var body = Object.keys(payload).map(function(k) {
            return encodeURIComponent(k) + '=' + encodeURIComponent(payload[k]);
        }).join('&');
        xhr.send(body);
    }

    function onSend() {
        var input = getEl('assistant-input');
        var container = getEl('assistant-messages');
        if (!input) return;
        var msg = (input.value || '').trim();
        if (!msg) return;
        addMessage('user', escapeHtml(msg));
        input.value = '';
        var loadingWrap = addMessage('assistant', '<div class="assistant-loading">Обработка запроса…</div>');
        if (loadingWrap) loadingWrap.classList.add('assistant-msg-loading');
        sendQuery(msg);
    }

    function init() {
        var toggle = getEl('assistant-toggle');
        var closeBtn = getEl('assistant-close');
        var panel = getEl('assistant-panel');
        var sendBtn = getEl('assistant-send');
        var input = getEl('assistant-input');

        if (!panel) return;

        if (toggle) {
            toggle.addEventListener('click', function() {
                togglePanel(true);
            });
        }
        if (closeBtn) {
            closeBtn.addEventListener('click', function() {
                togglePanel(false);
            });
        }
        if (sendBtn) {
            sendBtn.addEventListener('click', onSend);
        }
        if (input) {
            input.addEventListener('keydown', function(e) {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    onSend();
                }
            });
        }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
