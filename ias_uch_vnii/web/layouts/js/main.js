/**
 * Боковое меню: сворачивание, подсказки, состояние в cookie.
 */
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
});
