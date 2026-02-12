/**
 * Инициализация данных для AG Grid
 * Этот файл устанавливает глобальные переменные для ag-grid.js
 */

// Данные пользователей, статусов и URL устанавливаются в PHP и передаются через data-атрибуты
document.addEventListener('DOMContentLoaded', function() {
    // Проверяем, что данные установлены из PHP
    if (typeof window.isUserAdmin === 'undefined') {
        console.warn('AG Grid initialization data not set from PHP');
    }
});

