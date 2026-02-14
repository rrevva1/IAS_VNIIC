// JavaScript для сворачивания панели
document.addEventListener('DOMContentLoaded', function() {
    const sidebar = document.getElementById('sidebar');
    const mainContent = document.querySelector('.main-content');
    const toggleBtn = document.getElementById('toggleSidebar');

    function removeSidebarTooltips() {
        sidebar.querySelectorAll('.sidebar-tooltip').forEach(function(t) { t.remove(); });
    }

    function setSidebarCookie(expanded) {
        var val = expanded ? '1' : '0';
        document.cookie = 'sidebarExpanded=' + val + ';path=/;max-age=31536000;SameSite=Lax';
    }

    // На первой загрузке без cookie подтягиваем состояние из localStorage и пишем cookie
    if (!document.cookie.match(/\bsidebarExpanded=/)) {
        var isExpanded = localStorage.getItem('sidebarExpanded') === 'true';
        if (isExpanded) {
            sidebar.classList.add('expanded');
            if (mainContent) mainContent.classList.add('expanded');
            setSidebarCookie(true);
        }
    }

    // Обработчик клика на кнопку сворачивания
    toggleBtn.addEventListener('click', function() {
        removeSidebarTooltips();
        sidebar.classList.toggle('expanded');
        if (mainContent) mainContent.classList.toggle('expanded');

        var expanded = sidebar.classList.contains('expanded');
        localStorage.setItem('sidebarExpanded', expanded);
        setSidebarCookie(expanded);
    });

    // Подсказки только для свернутой панели; при раскрытии — удаляем
    sidebar.addEventListener('mouseenter', function() {
        if (!sidebar.classList.contains('expanded')) {
            removeSidebarTooltips();
            const navLinks = sidebar.querySelectorAll('.nav-link');
            navLinks.forEach(link => {
                const text = link.querySelector('.nav-text');
                if (text) {
                    const tooltip = document.createElement('div');
                    tooltip.className = 'sidebar-tooltip';
                    tooltip.textContent = text.textContent.trim();
                    tooltip.style.cssText = `
                        position: absolute;
                        left: 60px;
                        background: #000;
                        color: #fff;
                        padding: 8px 12px;
                        border-radius: 4px;
                        font-size: 12px;
                        white-space: nowrap;
                        z-index: 1001;
                        pointer-events: none;
                    `;
                    link.style.position = 'relative';
                    link.appendChild(tooltip);
                }
            });
        }
    });

    sidebar.addEventListener('mouseleave', function() {
        removeSidebarTooltips();
    });
});
