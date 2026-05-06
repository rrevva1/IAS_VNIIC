// JavaScript для страниц сайта
document.addEventListener('DOMContentLoaded', function() {
    // Инициализация форм
    initForms();
    
    // Инициализация анимаций
    initAnimations();
    
    // Инициализация модальных окон
    initModals();
    
    // Инициализация валидации
    initValidation();
});

function initForms() {
    const forms = document.querySelectorAll('.site-form');
    forms.forEach(form => {
        form.addEventListener('submit', function(e) {
            if (!validateForm(this)) {
                e.preventDefault();
                return false;
            }
            
            // Показываем индикатор загрузки
            const submitBtn = this.querySelector('button[type="submit"]');
            if (submitBtn) {
                const originalText = submitBtn.innerHTML;
                submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Отправка...';
                submitBtn.disabled = true;
                
                // Восстанавливаем кнопку через 5 секунд (на случай ошибки)
                setTimeout(() => {
                    submitBtn.innerHTML = originalText;
                    submitBtn.disabled = false;
                }, 5000);
            }
        });
    });
}

function initAnimations() {
    // Анимация появления элементов при скролле
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('animate-in');
            }
        });
    }, observerOptions);
    
    // Наблюдаем за элементами для анимации
    const animatedElements = document.querySelectorAll('.feature-card, .site-section, .site-content');
    animatedElements.forEach(el => {
        el.classList.add('animate-element');
        observer.observe(el);
    });
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

function initValidation() {
    const inputs = document.querySelectorAll('.form-control');
    inputs.forEach(input => {
        // Валидация в реальном времени
        input.addEventListener('blur', function() {
            validateField(this);
        });
        
        input.addEventListener('input', function() {
            // Убираем классы ошибок при вводе
            this.classList.remove('is-invalid');
            const feedback = this.parentNode.querySelector('.invalid-feedback');
            if (feedback) {
                feedback.style.display = 'none';
            }
        });
    });
}

function validateForm(form) {
    let isValid = true;
    const inputs = form.querySelectorAll('.form-control[required]');
    
    inputs.forEach(input => {
        if (!validateField(input)) {
            isValid = false;
        }
    });
    
    return isValid;
}

function validateField(field) {
    const value = field.value.trim();
    const type = field.type;
    const required = field.hasAttribute('required');
    let isValid = true;
    let errorMessage = '';
    
    // Проверка обязательных полей
    if (required && !value) {
        isValid = false;
        errorMessage = 'Это поле обязательно для заполнения';
    }
    
    // Проверка email
    if (type === 'email' && value) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(value)) {
            isValid = false;
            errorMessage = 'Введите корректный email адрес';
        }
    }
    
    // Проверка телефона
    if (field.name === 'phone' && value) {
        const phoneRegex = /^[\+]?[1-9][\d]{0,15}$/;
        if (!phoneRegex.test(value.replace(/\s/g, ''))) {
            isValid = false;
            errorMessage = 'Введите корректный номер телефона';
        }
    }
    
    // Проверка минимальной длины
    const minLength = field.getAttribute('minlength');
    if (minLength && value.length < parseInt(minLength)) {
        isValid = false;
        errorMessage = `Минимальная длина: ${minLength} символов`;
    }
    
    // Проверка максимальной длины
    const maxLength = field.getAttribute('maxlength');
    if (maxLength && value.length > parseInt(maxLength)) {
        isValid = false;
        errorMessage = `Максимальная длина: ${maxLength} символов`;
    }
    
    // Обновление UI
    if (isValid) {
        field.classList.remove('is-invalid');
        field.classList.add('is-valid');
        hideFieldError(field);
    } else {
        field.classList.remove('is-valid');
        field.classList.add('is-invalid');
        showFieldError(field, errorMessage);
    }
    
    return isValid;
}

function showFieldError(field, message) {
    let feedback = field.parentNode.querySelector('.invalid-feedback');
    if (!feedback) {
        feedback = document.createElement('div');
        feedback.className = 'invalid-feedback';
        field.parentNode.appendChild(feedback);
    }
    feedback.textContent = message;
    feedback.style.display = 'block';
}

function hideFieldError(field) {
    const feedback = field.parentNode.querySelector('.invalid-feedback');
    if (feedback) {
        feedback.style.display = 'none';
    }
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

// Функция для показа уведомлений
function showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.className = `alert-site ${type}`;
    notification.innerHTML = `
        <div style="display: flex; justify-content: space-between; align-items: center;">
            <span>${message}</span>
            <button type="button" class="btn-close" onclick="this.parentElement.parentElement.remove()">
                <i class="fas fa-times"></i>
            </button>
        </div>
    `;
    
    // Добавляем стили для кнопки закрытия
    const closeBtn = notification.querySelector('.btn-close');
    closeBtn.style.cssText = `
        background: none;
        border: none;
        font-size: 1rem;
        cursor: pointer;
        padding: 0;
        margin-left: 10px;
    `;
    
    // Вставляем уведомление в начало контейнера
    const container = document.querySelector('.site-container') || document.body;
    container.insertBefore(notification, container.firstChild);
    
    // Автоматически удаляем через 5 секунд
    setTimeout(() => {
        if (notification.parentNode) {
            notification.remove();
        }
    }, 5000);
}

// Функция для плавной прокрутки к элементу
function scrollToElement(elementId) {
    const element = document.getElementById(elementId);
    if (element) {
        element.scrollIntoView({
            behavior: 'smooth',
            block: 'start'
        });
    }
}

// Функция для копирования текста в буфер обмена
function copyToClipboard(text) {
    if (navigator.clipboard) {
        navigator.clipboard.writeText(text).then(() => {
            showNotification('Текст скопирован в буфер обмена', 'success');
        }).catch(() => {
            showNotification('Ошибка копирования', 'error');
        });
    } else {
        // Fallback для старых браузеров
        const textArea = document.createElement('textarea');
        textArea.value = text;
        document.body.appendChild(textArea);
        textArea.select();
        try {
            document.execCommand('copy');
            showNotification('Текст скопирован в буфер обмена', 'success');
        } catch (err) {
            showNotification('Ошибка копирования', 'error');
        }
        document.body.removeChild(textArea);
    }
}

// Экспорт функций для использования в других скриптах
window.SitePage = {
    showNotification: showNotification,
    scrollToElement: scrollToElement,
    copyToClipboard: copyToClipboard,
    validateForm: validateForm,
    openModal: openModal,
    closeModal: closeModal
};
