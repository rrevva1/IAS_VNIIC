(function () {
    'use strict';

    var STORAGE_KEY = 'ias.dashboard.showAllWidgets';

    function initDashboardWidgetsToggle() {
        var toggle = document.getElementById('dashboard-widgets-toggle');
        var widgets = document.getElementById('dashboard-widgets');
        if (!toggle || !widgets) {
            return;
        }

        var idleCount = parseInt(toggle.getAttribute('data-idle-count') || '0', 10);
        var labelEl = toggle.querySelector('.dashboard-widgets-toggle__label');
        var countEl = toggle.querySelector('.dashboard-widgets-toggle__count');

        function setExpanded(expanded, persist) {
            widgets.classList.toggle('dashboard-widgets--show-idle', expanded);
            toggle.setAttribute('aria-expanded', expanded ? 'true' : 'false');
            if (labelEl) {
                labelEl.textContent = expanded ? 'Скрыть неактивные' : 'Показать все виджеты';
            }
            if (countEl) {
                countEl.hidden = expanded;
            }
            if (persist) {
                try {
                    localStorage.setItem(STORAGE_KEY, expanded ? '1' : '0');
                } catch (e) {
                    /* ignore */
                }
            }
        }

        var saved = null;
        try {
            saved = localStorage.getItem(STORAGE_KEY);
        } catch (e) {
            /* ignore */
        }
        if (saved === '1') {
            setExpanded(true, false);
        }

        toggle.addEventListener('click', function () {
            var expanded = widgets.classList.contains('dashboard-widgets--show-idle');
            setExpanded(!expanded, true);
        });

        if (idleCount <= 0) {
            toggle.hidden = true;
        }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initDashboardWidgetsToggle);
    } else {
        initDashboardWidgetsToggle();
    }
})();
