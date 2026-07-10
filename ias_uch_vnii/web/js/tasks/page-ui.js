/**
 * Оболочка страницы «Заявки»: быстрый поиск и фильтр по статусу (вкладки).
 */
(function() {
    'use strict';

    var quickFilterTimer = null;

    window.tasksStatusFilter = '';

    function getSearchText() {
        var input = document.getElementById('tasksQuickFilter');
        return input ? input.value.trim() : '';
    }

    function updateSearchClearButton() {
        var btn = document.getElementById('tasksQuickFilterClear');
        if (!btn) {
            return;
        }
        btn.hidden = !getSearchText();
    }

    function applyQuickFilter(text) {
        var api = window.tasksGridApi;
        if (api && typeof api.setGridOption === 'function') {
            api.setGridOption('quickFilterText', text);
        }
    }

    function buildTasksDataUrl() {
        var base = window.agGridDataUrl || '/index.php?r=tasks/get-grid-data';
        var parts = [];
        var code = window.tasksStatusFilter || '';
        if (code !== '') {
            parts.push('status_code=' + encodeURIComponent(code));
        }
        parts.push('_=' + String(Date.now()));
        var sep = base.indexOf('?') >= 0 ? '&' : '?';

        return base + sep + parts.join('&');
    }

    function reloadTasksGrid() {
        if (typeof window.loadGridData === 'function') {
            window.loadGridData();
            return;
        }
        if (typeof window.refreshGrid === 'function') {
            window.refreshGrid();
        }
    }

    window.buildTasksDataUrl = buildTasksDataUrl;

    function initQuickFilter() {
        var input = document.getElementById('tasksQuickFilter');
        if (!input) {
            return;
        }

        input.addEventListener('input', function() {
            clearTimeout(quickFilterTimer);
            quickFilterTimer = setTimeout(function() {
                applyQuickFilter(getSearchText());
                updateSearchClearButton();
            }, 200);
        });

        input.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                input.value = '';
                applyQuickFilter('');
                updateSearchClearButton();
            }
        });

        var clearBtn = document.getElementById('tasksQuickFilterClear');
        if (clearBtn) {
            clearBtn.addEventListener('click', function() {
                input.value = '';
                applyQuickFilter('');
                updateSearchClearButton();
                input.focus();
            });
        }

        updateSearchClearButton();
    }

    function initStatusTabs() {
        var tabList = document.querySelector('.tasks-status-tabs');
        if (!tabList) {
            return;
        }

        tabList.addEventListener('click', function(e) {
            var tab = e.target.closest('.tasks-status-tab');
            if (!tab || !tabList.contains(tab)) {
                return;
            }

            e.preventDefault();
            e.stopPropagation();

            var code = tab.getAttribute('data-status-code');
            if (code === null) {
                code = '';
            }

            window.tasksStatusFilter = code;

            if (window.tasksRealtimePoll && typeof window.tasksRealtimePoll.resetVersion === 'function') {
                window.tasksRealtimePoll.resetVersion();
            }

            tabList.querySelectorAll('.tasks-status-tab').forEach(function(t) {
                t.classList.remove('active');
                t.setAttribute('aria-selected', 'false');
            });
            tab.classList.add('active');
            tab.setAttribute('aria-selected', 'true');

            reloadTasksGrid();
        });
    }

    function initPageChrome() {
        initQuickFilter();
        initStatusTabs();
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initPageChrome);
    } else {
        initPageChrome();
    }
})();
