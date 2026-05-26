/**
 * Оболочка страницы «Пользователи»: поиск и фильтр по роли.
 */
(function() {
    'use strict';

    var quickFilterTimer = null;
    window.usersRoleFilter = '';

    function getContainer() {
        return document.getElementById('agGridUsersContainer');
    }

    function getSearchText() {
        var input = document.getElementById('usersQuickFilter');
        return input ? input.value.trim() : '';
    }

    function updateSearchClearButton() {
        var btn = document.getElementById('usersQuickFilterClear');
        if (btn) {
            btn.hidden = !getSearchText();
        }
    }

    function applyQuickFilter(text) {
        var api = window.usersGridApi;
        if (api && typeof api.setGridOption === 'function') {
            api.setGridOption('quickFilterText', text);
        }
    }

    window.buildUsersDataUrl = function() {
        var container = getContainer();
        var base = (container && container.dataset.url) || '/index.php?r=users/get-grid-data';
        var sep = base.indexOf('?') >= 0 ? '&' : '?';
        var parts = [];
        var roleId = window.usersRoleFilter || '';
        if (roleId !== '') {
            parts.push('role_id=' + encodeURIComponent(roleId));
        }
        parts.push('_=' + String(Date.now()));
        return base + (parts.length ? sep + parts.join('&') : '');
    };

    function initQuickFilter() {
        var input = document.getElementById('usersQuickFilter');
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

        var clearBtn = document.getElementById('usersQuickFilterClear');
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

    function initRoleTabs() {
        var tabList = document.querySelector('.users-role-tabs');
        if (!tabList) {
            return;
        }

        tabList.addEventListener('click', function(e) {
            var tab = e.target.closest('.users-role-tab');
            if (!tab || !tabList.contains(tab)) {
                return;
            }
            e.preventDefault();
            e.stopPropagation();

            var roleId = tab.getAttribute('data-role-id') || '';
            if (roleId === window.usersRoleFilter) {
                return;
            }

            window.usersRoleFilter = roleId;

            tabList.querySelectorAll('.users-role-tab').forEach(function(t) {
                t.classList.remove('active');
                t.setAttribute('aria-selected', 'false');
            });
            tab.classList.add('active');
            tab.setAttribute('aria-selected', 'true');

            if (typeof window.refreshUsersGrid === 'function') {
                window.refreshUsersGrid();
            }
        });
    }

    function initPageChrome() {
        var active = document.querySelector('.users-role-tab.active');
        window.usersRoleFilter = active ? (active.getAttribute('data-role-id') || '') : '';
        initQuickFilter();
        initRoleTabs();
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initPageChrome);
    } else {
        initPageChrome();
    }
})();
