/**
 * Оболочка страницы «Телефонный справочник»: поиск и фильтры.
 */
(function() {
    'use strict';

    var quickFilterTimer = null;
    window.phoneDirectoryFilter = 'all';

    function getContainer() {
        return document.getElementById('agGridPhoneDirectoryContainer');
    }

    function getSearchText() {
        var input = document.getElementById('phoneDirectoryQuickFilter');
        return input ? input.value.trim() : '';
    }

    function updateSearchClearButton() {
        var btn = document.getElementById('phoneDirectoryQuickFilterClear');
        if (btn) {
            btn.hidden = !getSearchText();
        }
    }

    window.buildPhoneDirectoryDataUrl = function() {
        var container = getContainer();
        var base = (container && container.dataset.url) || '/index.php?r=phone-directory/get-grid-data';
        var sep = base.indexOf('?') >= 0 ? '&' : '?';
        var parts = [];
        var filter = window.phoneDirectoryFilter || 'all';
        if (filter && filter !== 'all') {
            parts.push('filter=' + encodeURIComponent(filter));
        }
        var q = getSearchText();
        if (q) {
            parts.push('q=' + encodeURIComponent(q));
        }
        parts.push('_=' + String(Date.now()));
        return base + (parts.length ? sep + parts.join('&') : '');
    };

    function reloadGrid() {
        if (typeof window.refreshPhoneDirectoryGrid === 'function') {
            window.refreshPhoneDirectoryGrid();
        }
    }

    function initQuickFilter() {
        var input = document.getElementById('phoneDirectoryQuickFilter');
        if (!input) {
            return;
        }

        input.addEventListener('input', function() {
            clearTimeout(quickFilterTimer);
            quickFilterTimer = setTimeout(function() {
                updateSearchClearButton();
                reloadGrid();
            }, 250);
        });

        input.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                input.value = '';
                updateSearchClearButton();
                reloadGrid();
            }
        });

        var clearBtn = document.getElementById('phoneDirectoryQuickFilterClear');
        if (clearBtn) {
            clearBtn.addEventListener('click', function() {
                input.value = '';
                updateSearchClearButton();
                reloadGrid();
                input.focus();
            });
        }

        updateSearchClearButton();
    }

    function initFilterTabs() {
        var tabs = document.querySelectorAll('[data-pd-filter]');
        tabs.forEach(function(tab) {
            tab.addEventListener('click', function(e) {
                e.preventDefault();
                var filter = tab.getAttribute('data-pd-filter') || 'all';
                window.phoneDirectoryFilter = filter;
                tabs.forEach(function(t) {
                    var active = t === tab;
                    t.classList.toggle('active', active);
                    t.setAttribute('aria-selected', active ? 'true' : 'false');
                });
                reloadGrid();
            });
        });
    }

    function init() {
        initQuickFilter();
        initFilterTabs();
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
