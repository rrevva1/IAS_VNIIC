/**
 * Боковое меню: сворачивание, подсказки, состояние в cookie.
 */
(function () {
    function normalizeType(type) {
        var t = String(type || 'info').toLowerCase();
        if (t === 'error') return 'danger';
        if (t !== 'success' && t !== 'danger' && t !== 'warning' && t !== 'info') return 'info';
        return t;
    }

    function ensureStack() {
        var existing = document.getElementById('iasToastStack');
        if (existing) return existing;
        var stack = document.createElement('div');
        stack.id = 'iasToastStack';
        stack.className = 'ias-toast-stack';
        document.body.appendChild(stack);
        return stack;
    }

    window.IASNotify = function (message, type, options) {
        if (!message) return;
        var stack = ensureStack();
        var level = normalizeType(type);
        var timeout = (options && options.timeoutMs) || 5000;

        var toast = document.createElement('div');
        toast.className = 'ias-toast ias-toast--' + level;
        toast.setAttribute('role', 'status');
        toast.setAttribute('aria-live', 'polite');
        toast.innerHTML = '<div class="ias-toast__message"></div>'
            + '<button type="button" class="ias-toast__close" aria-label="Закрыть">×</button>';
        toast.querySelector('.ias-toast__message').textContent = String(message);
        toast.querySelector('.ias-toast__close').addEventListener('click', function () {
            toast.remove();
        });
        stack.appendChild(toast);

        window.setTimeout(function () {
            if (toast && toast.parentNode) {
                toast.remove();
            }
        }, timeout);
    };
})();

document.addEventListener('DOMContentLoaded', function () {
    var sidebar = document.getElementById('sidebar');
    var toggleBtn = document.getElementById('toggleSidebar');
    if (!sidebar || !toggleBtn) {
        return;
    }

    var activeTooltip = null;

    function setSidebarCookie(expanded) {
        document.cookie = 'sidebarExpanded=' + (expanded ? '1' : '0') + ';path=/;max-age=31536000;SameSite=Lax';
    }

    function updateToggleAria() {
        var expanded = sidebar.classList.contains('expanded');
        toggleBtn.setAttribute('aria-expanded', expanded ? 'true' : 'false');
        toggleBtn.title = expanded ? 'Свернуть меню' : 'Развернуть меню';
    }

    function removeSidebarTooltip() {
        if (activeTooltip) {
            activeTooltip.remove();
            activeTooltip = null;
        }
    }

    if (!document.cookie.match(/\bsidebarExpanded=/)) {
        var stored = localStorage.getItem('sidebarExpanded');
        if (stored === 'false') {
            sidebar.classList.remove('expanded');
            setSidebarCookie(false);
        } else {
            sidebar.classList.add('expanded');
            setSidebarCookie(true);
        }
    }

    updateToggleAria();

    toggleBtn.addEventListener('click', function () {
        removeSidebarTooltip();
        sidebar.classList.toggle('expanded');
        var expanded = sidebar.classList.contains('expanded');
        localStorage.setItem('sidebarExpanded', expanded ? 'true' : 'false');
        setSidebarCookie(expanded);
        updateToggleAria();
    });

    sidebar.addEventListener('mouseover', function (e) {
        if (sidebar.classList.contains('expanded')) {
            return;
        }
        var link = e.target.closest('.sidebar-nav__link');
        if (!link) {
            return;
        }
        var textEl = link.querySelector('.sidebar-nav__text');
        var label = (textEl && textEl.textContent.trim()) || link.getAttribute('title') || '';
        if (!label) {
            return;
        }
        removeSidebarTooltip();
        var rect = link.getBoundingClientRect();
        activeTooltip = document.createElement('div');
        activeTooltip.className = 'sidebar-tooltip';
        activeTooltip.textContent = label;
        activeTooltip.style.top = rect.top + rect.height / 2 - 14 + 'px';
        document.body.appendChild(activeTooltip);
    });

    sidebar.addEventListener('mouseleave', removeSidebarTooltip);

    function isTextEntryTarget(el) {
        if (!el || el === document.body || el === document.documentElement) {
            return false;
        }
        return !!el.closest(
            'input:not([type="button"]):not([type="submit"]):not([type="reset"]):not([type="checkbox"]):not([type="radio"]):not([type="file"]),'
            + 'textarea, select, [contenteditable="true"], .select2-container, .select2-search__field,'
            + '.ag-root-wrapper, .ag-popup, .ag-menu, .ag-popup-editor'
        );
    }

    function clearAllGridCellFocus() {
        var list = window.__iasAgGridApis;
        if (!list || !list.length) {
            return;
        }
        for (var i = list.length - 1; i >= 0; i--) {
            var api = list[i];
            if (!api || (typeof api.isDestroyed === 'function' && api.isDestroyed())) {
                list.splice(i, 1);
                continue;
            }
            if (typeof api.clearFocusedCell === 'function') {
                api.clearFocusedCell();
            }
        }
    }

    document.addEventListener('mousedown', function (event) {
        if (isTextEntryTarget(event.target)) {
            return;
        }

        clearAllGridCellFocus();

        var active = document.activeElement;
        if (active && active !== document.body && !isTextEntryTarget(active)) {
            active.blur();
        }
    });
});
