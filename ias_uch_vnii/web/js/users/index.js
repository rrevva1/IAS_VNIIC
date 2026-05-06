// JavaScript для страниц пользователей
document.addEventListener('DOMContentLoaded', function() {
    // Инициализация таблицы пользователей
    initUsersTable();
    
    // Инициализация фильтров
    initFilters();
    
    // Инициализация модальных окон
    initModals();
    
    // Инициализация действий пользователей
    initUserActions();
});

function initUsersTable() {
    const table = document.querySelector('.users-table');
    if (!table) return;
    
    // Добавляем обработчики для сортировки
    const sortableHeaders = table.querySelectorAll('th[data-sort]');
    sortableHeaders.forEach(header => {
        header.style.cursor = 'pointer';
        header.addEventListener('click', function() {
            const sortField = this.dataset.sort;
            const currentSort = getUrlParameter('sort');
            const currentOrder = getUrlParameter('order');
            
            let newOrder = 'asc';
            if (currentSort === sortField && currentOrder === 'asc') {
                newOrder = 'desc';
            }
            
            // Обновляем URL с новыми параметрами сортировки
            const url = new URL(window.location);
            url.searchParams.set('sort', sortField);
            url.searchParams.set('order', newOrder);
            window.location.href = url.toString();
        });
    });
    
    // Добавляем индикаторы сортировки
    updateSortIndicators();
}

function initFilters() {
    const filterForm = document.getElementById('users-filter-form');
    if (!filterForm) return;
    
    // Автоматическая отправка формы при изменении фильтров
    const filterInputs = filterForm.querySelectorAll('input, select');
    filterInputs.forEach(input => {
        input.addEventListener('change', function() {
            clearTimeout(this.filterTimeout);
            this.filterTimeout = setTimeout(() => {
                filterForm.submit();
            }, 500);
        });
    });
    
    // Обработка кнопки сброса фильтров
    const resetBtn = document.getElementById('reset-users-filters');
    if (resetBtn) {
        resetBtn.addEventListener('click', function() {
            filterInputs.forEach(input => {
                if (input.type === 'text' || input.type === 'date') {
                    input.value = '';
                } else if (input.type === 'select-one') {
                    input.selectedIndex = 0;
                }
            });
            filterForm.submit();
        });
    }
}

function initModals() {
    // Обработка модальных окон
    const modalTriggers = document.querySelectorAll('[data-modal-target]');
    const modals = document.querySelectorAll('.modal');
    const modalCloses = document.querySelectorAll('.modal-close');
    
    // Открытие модальных окон
    modalTriggers.forEach(trigger => {
        trigger.addEventListener('click', function(e) {
            e.preventDefault();
            const targetId = this.dataset.modalTarget;
            const modal = document.getElementById(targetId);
            if (modal) {
                openModal(modal);
            }
        });
    });
    
    // Закрытие модальных окон
    modalCloses.forEach(close => {
        close.addEventListener('click', function() {
            const modal = this.closest('.modal');
            if (modal) {
                closeModal(modal);
            }
        });
    });
    
    // Закрытие по клику вне модального окна
    modals.forEach(modal => {
        modal.addEventListener('click', function(e) {
            if (e.target === this) {
                closeModal(this);
            }
        });
    });
    
    // Закрытие по клавише Escape
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            const openModal = document.querySelector('.modal.show');
            if (openModal) {
                closeModal(openModal);
            }
        }
    });
}

function initUserActions() {
    // Обработка действий с пользователями
    const actionButtons = document.querySelectorAll('.action-btn');
    actionButtons.forEach(button => {
        button.addEventListener('click', function(e) {
            const action = this.classList.contains('delete') ? 'delete' : 
                          this.classList.contains('activate') ? 'activate' :
                          this.classList.contains('deactivate') ? 'deactivate' : 'view';
            
            if (action === 'delete') {
                e.preventDefault();
                const userId = this.dataset.userId;
                const userName = this.dataset.userName;
                if (userId) {
                    confirmDeleteUser(userId, userName);
                }
            } else if (action === 'activate' || action === 'deactivate') {
                e.preventDefault();
                const userId = this.dataset.userId;
                const userName = this.dataset.userName;
                const newStatus = action === 'activate' ? 'active' : 'inactive';
                if (userId) {
                    confirmStatusChange(userId, userName, newStatus);
                }
            }
        });
    });
}

function updateSortIndicators() {
    const currentSort = getUrlParameter('sort');
    const currentOrder = getUrlParameter('order');
    
    if (currentSort) {
        const header = document.querySelector(`th[data-sort="${currentSort}"]`);
        if (header) {
            // Убираем все индикаторы
            document.querySelectorAll('.sort-indicator').forEach(indicator => {
                indicator.remove();
            });
            
            // Добавляем новый индикатор
            const indicator = document.createElement('span');
            indicator.className = 'sort-indicator';
            indicator.innerHTML = currentOrder === 'desc' ? ' ↓' : ' ↑';
            indicator.style.color = '#007bff';
            header.appendChild(indicator);
        }
    }
}

function confirmDeleteUser(userId, userName) {
    if (confirm(`Вы уверены, что хотите удалить пользователя "${userName}"?`)) {
        deleteUser(userId);
    }
}

function confirmStatusChange(userId, userName, newStatus) {
    const statusText = newStatus === 'active' ? 'активировать' : 'деактивировать';
    if (confirm(`Вы уверены, что хотите ${statusText} пользователя "${userName}"?`)) {
        changeUserStatus(userId, newStatus);
    }
}

function deleteUser(userId) {
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = `/users/delete?id=${userId}`;
    
    // Добавляем CSRF токен
    const csrfToken = document.querySelector('meta[name="csrf-token"]');
    if (csrfToken) {
        const csrfInput = document.createElement('input');
        csrfInput.type = 'hidden';
        csrfInput.name = '_token';
        csrfInput.value = csrfToken.getAttribute('content');
        form.appendChild(csrfInput);
    }
    
    document.body.appendChild(form);
    form.submit();
}

function changeUserStatus(userId, newStatus) {
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = `/users/change-status`;
    
    // Добавляем поля формы
    const userIdInput = document.createElement('input');
    userIdInput.type = 'hidden';
    userIdInput.name = 'userId';
    userIdInput.value = userId;
    form.appendChild(userIdInput);
    
    const statusInput = document.createElement('input');
    statusInput.type = 'hidden';
    statusInput.name = 'status';
    statusInput.value = newStatus;
    form.appendChild(statusInput);
    
    // Добавляем CSRF токен
    const csrfToken = document.querySelector('meta[name="csrf-token"]');
    if (csrfToken) {
        const csrfInput = document.createElement('input');
        csrfInput.type = 'hidden';
        csrfInput.name = '_token';
        csrfInput.value = csrfToken.getAttribute('content');
        form.appendChild(csrfInput);
    }
    
    document.body.appendChild(form);
    form.submit();
}

function openModal(modal) {
    modal.classList.add('show');
    document.body.classList.add('modal-open');
    
    // Фокус на первом инпуте
    const firstInput = modal.querySelector('input, textarea, select');
    if (firstInput) {
        setTimeout(() => firstInput.focus(), 100);
    }
}

function closeModal(modal) {
    modal.classList.remove('show');
    document.body.classList.remove('modal-open');
}

function getUrlParameter(name) {
    const urlParams = new URLSearchParams(window.location.search);
    return urlParams.get(name);
}

// Функция для показа уведомлений
function showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.className = `alert alert-${type} alert-dismissible fade show`;
    notification.innerHTML = `
        ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `;
    
    // Вставляем уведомление в начало контейнера
    const container = document.querySelector('.users-container') || document.body;
    container.insertBefore(notification, container.firstChild);
    
    // Автоматически удаляем через 5 секунд
    setTimeout(() => {
        if (notification.parentNode) {
            notification.remove();
        }
    }, 5000);
}

// Функция для экспорта списка пользователей
function exportUsers(format) {
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = '/users/export';
    form.target = '_blank';
    
    // Добавляем параметры
    const formatInput = document.createElement('input');
    formatInput.type = 'hidden';
    formatInput.name = 'format';
    formatInput.value = format;
    form.appendChild(formatInput);
    
    // Добавляем CSRF токен
    const csrfToken = document.querySelector('meta[name="csrf-token"]');
    if (csrfToken) {
        const csrfInput = document.createElement('input');
        csrfInput.type = 'hidden';
        csrfInput.name = '_token';
        csrfInput.value = csrfToken.getAttribute('content');
        form.appendChild(csrfInput);
    }
    
    document.body.appendChild(form);
    form.submit();
    document.body.removeChild(form);
}

// Функция для массовых действий
function performBulkAction(action) {
    const selectedUsers = document.querySelectorAll('input[name="userIds[]"]:checked');
    if (selectedUsers.length === 0) {
        showNotification('Выберите пользователей для выполнения действия', 'warning');
        return;
    }
    
    const userIds = Array.from(selectedUsers).map(input => input.value);
    const actionText = action === 'delete' ? 'удалить' : 
                     action === 'activate' ? 'активировать' : 
                     action === 'deactivate' ? 'деактивировать' : 'обработать';
    
    if (confirm(`Вы уверены, что хотите ${actionText} выбранных пользователей?`)) {
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = '/users/bulk-action';
        
        // Добавляем поля формы
        userIds.forEach(userId => {
            const input = document.createElement('input');
            input.type = 'hidden';
            input.name = 'userIds[]';
            input.value = userId;
            form.appendChild(input);
        });
        
        const actionInput = document.createElement('input');
        actionInput.type = 'hidden';
        actionInput.name = 'action';
        actionInput.value = action;
        form.appendChild(actionInput);
        
        // Добавляем CSRF токен
        const csrfToken = document.querySelector('meta[name="csrf-token"]');
        if (csrfToken) {
            const csrfInput = document.createElement('input');
            csrfInput.type = 'hidden';
            csrfInput.name = '_token';
            csrfInput.value = csrfToken.getAttribute('content');
            form.appendChild(csrfInput);
        }
        
        document.body.appendChild(form);
        form.submit();
    }
}

// Экспорт функций для использования в других скриптах
window.UsersPage = {
    showNotification: showNotification,
    exportUsers: exportUsers,
    performBulkAction: performBulkAction,
    openModal: openModal,
    closeModal: closeModal
};
