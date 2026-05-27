/**
 * Общие утилиты для AG Grid-страниц в каркасе arm-page.
 */
(function() {
    'use strict';

    var apis = {};
    var quickFilterTimer;

    function setQuickFilter(api, value) {
        if (!api) {
            return;
        }
        if (typeof api.setGridOption === 'function') {
            api.setGridOption('quickFilterText', value);
        } else if (typeof api.setQuickFilter === 'function') {
            api.setQuickFilter(value);
        }
    }

    function bindQuickFilter(pageRoot, gridId) {
        if (!pageRoot) {
            return;
        }
        var searchInput = pageRoot.querySelector('.js-section-quick-filter');
        var searchClear = pageRoot.querySelector('.js-section-quick-filter-clear');
        if (!searchInput) {
            return;
        }
        searchInput.addEventListener('input', function() {
            var value = searchInput.value.trim();
            if (searchClear) {
                searchClear.hidden = value === '';
            }
            clearTimeout(quickFilterTimer);
            quickFilterTimer = setTimeout(function() {
                setQuickFilter(apis[gridId], value);
            }, 200);
        });
        if (searchClear) {
            searchClear.addEventListener('click', function() {
                searchInput.value = '';
                searchClear.hidden = true;
                setQuickFilter(apis[gridId], '');
                searchInput.focus();
            });
        }
    }

    function bindRefreshButtons() {
        document.querySelectorAll('.js-section-grid-refresh').forEach(function(btn) {
            btn.addEventListener('click', function() {
                var gridId = btn.getAttribute('data-grid-id');
                if (gridId) {
                    window.SectionGridUtils.reload(gridId);
                }
            });
        });
    }

    window.SectionGridUtils = {
        registerApi: function(gridId, api) {
            apis[gridId] = api;
            var container = document.getElementById(gridId);
            var pageRoot = container ? container.closest('.section-grid-page') : null;
            if (pageRoot) {
                bindQuickFilter(pageRoot, gridId);
            }
        },
        reload: function(gridId) {
            var api = apis[gridId];
            var container = document.getElementById(gridId);
            if (!container || !api) {
                return Promise.resolve();
            }
            var dataUrl = container.dataset.url;
            if (!dataUrl) {
                return Promise.resolve();
            }
            return fetch(dataUrl)
                .then(function(r) { return r.json(); })
                .then(function(result) {
                    if (result && result.success && result.data) {
                        api.setGridOption('rowData', result.data);
                    } else {
                        api.setGridOption('rowData', []);
                    }
                })
                .catch(function(err) {
                    console.error('Section grid reload error:', err);
                });
        },
        prepareContainer: function(container) {
            if (!container) {
                return false;
            }
            container.classList.remove('arm-grid-loading');
            if (typeof agGrid === 'undefined') {
                container.innerHTML = '<p class="text-muted p-4">Загрузка таблицы…</p>';
                return false;
            }
            container.innerHTML = '';
            return true;
        },
        mergeDefaultColDef: function() {
            return (window.AgGridWrap && window.AgGridWrap.mergeDefaultColDef)
                ? window.AgGridWrap.mergeDefaultColDef({ sortable: true, filter: true, resizable: true }, true)
                : { sortable: true, filter: true, resizable: true };
        },
    };

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', bindRefreshButtons);
    } else {
        bindRefreshButtons();
    }
})();
