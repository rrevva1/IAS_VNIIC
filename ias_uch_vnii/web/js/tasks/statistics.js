// JavaScript для страницы статистики
document.addEventListener('DOMContentLoaded', function() {
    // Инициализация графиков
    initCharts();
    
    // Инициализация фильтров
    initFilters();
    
    // Инициализация экспорта
    initExport();
    
    // Обновление статистики в реальном времени
    initRealTimeUpdates();
});

function initCharts() {
    // Инициализация графиков Highcharts
    if (typeof Highcharts !== 'undefined') {
        initTasksChart();
        initStatusChart();
        initTimelineChart();
    }
}

function initTasksChart() {
    const chartData = getChartData('tasks-chart');
    if (!chartData) return;
    
    Highcharts.chart('tasks-chart', {
        chart: {
            type: 'line',
            height: 400
        },
        title: {
            text: 'Динамика заявок по времени'
        },
        xAxis: {
            categories: chartData.categories,
            title: {
                text: 'Период'
            }
        },
        yAxis: {
            title: {
                text: 'Количество заявок'
            }
        },
        series: chartData.series,
        legend: {
            enabled: true
        },
        tooltip: {
            shared: true,
            crosshairs: true
        },
        credits: {
            enabled: false
        }
    });
}

function initStatusChart() {
    const chartData = getChartData('status-chart');
    if (!chartData) return;
    
    Highcharts.chart('status-chart', {
        chart: {
            type: 'pie',
            height: 400
        },
        title: {
            text: 'Распределение заявок по статусам'
        },
        series: [{
            name: 'Заявки',
            data: chartData.data,
            size: '60%',
            innerSize: '40%',
            dataLabels: {
                enabled: true,
                format: '{point.name}: {point.y} ({point.percentage:.1f}%)'
            }
        }],
        tooltip: {
            pointFormat: '{series.name}: <b>{point.y}</b> ({point.percentage:.1f}%)'
        },
        credits: {
            enabled: false
        }
    });
}

function initTimelineChart() {
    const chartData = getChartData('timeline-chart');
    if (!chartData) return;
    
    Highcharts.chart('timeline-chart', {
        chart: {
            type: 'column',
            height: 400
        },
        title: {
            text: 'Статистика по месяцам'
        },
        xAxis: {
            categories: chartData.categories,
            title: {
                text: 'Месяц'
            }
        },
        yAxis: {
            title: {
                text: 'Количество заявок'
            }
        },
        series: chartData.series,
        legend: {
            enabled: true
        },
        tooltip: {
            shared: true
        },
        credits: {
            enabled: false
        }
    });
}

function initFilters() {
    const filterForm = document.getElementById('stats-filter-form');
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
    const resetBtn = document.getElementById('reset-stats-filters');
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

function initExport() {
    const exportButtons = document.querySelectorAll('.export-btn');
    exportButtons.forEach(button => {
        button.addEventListener('click', function(e) {
            e.preventDefault();
            const format = this.dataset.format;
            const url = this.href;
            
            if (format) {
                exportData(format, url);
            }
        });
    });
}

function initRealTimeUpdates() {
    // Обновление статистики каждые 5 минут
    setInterval(() => {
        updateStatsCards();
    }, 300000); // 5 минут
}

function getChartData(chartId) {
    const chartElement = document.getElementById(chartId);
    if (!chartElement) return null;
    
    try {
        return JSON.parse(chartElement.dataset.chartData);
    } catch (e) {
        console.error('Ошибка парсинга данных графика:', e);
        return null;
    }
}

function updateStatsCards() {
    // Загружаем обновленные данные статистики
    fetch('/tasks/statistics-data')
        .then(response => response.json())
        .then(data => {
            updateStatCard('total-tasks', data.total);
            updateStatCard('new-tasks', data.new);
            updateStatCard('in-progress-tasks', data.inProgress);
            updateStatCard('completed-tasks', data.completed);
        })
        .catch(error => {
            console.error('Ошибка обновления статистики:', error);
        });
}

function updateStatCard(cardId, value) {
    const card = document.getElementById(cardId);
    if (card) {
        const valueElement = card.querySelector('.stat-value');
        if (valueElement) {
            // Анимация изменения значения
            const currentValue = parseInt(valueElement.textContent);
            animateValue(valueElement, currentValue, value, 1000);
        }
    }
}

function animateValue(element, start, end, duration) {
    const startTime = performance.now();
    
    function updateValue(currentTime) {
        const elapsed = currentTime - startTime;
        const progress = Math.min(elapsed / duration, 1);
        
        const current = Math.round(start + (end - start) * progress);
        element.textContent = current;
        
        if (progress < 1) {
            requestAnimationFrame(updateValue);
        }
    }
    
    requestAnimationFrame(updateValue);
}

function exportData(format, url) {
    // Показываем индикатор загрузки
    const button = event.target.closest('.export-btn');
    const originalText = button.innerHTML;
    button.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Экспорт...';
    button.disabled = true;
    
    // Создаем скрытую форму для экспорта
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = url;
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
    
    // Восстанавливаем кнопку через 3 секунды
    setTimeout(() => {
        button.innerHTML = originalText;
        button.disabled = false;
        document.body.removeChild(form);
    }, 3000);
}

// Функция для обновления графиков при изменении фильтров
function refreshCharts() {
    if (typeof Highcharts !== 'undefined') {
        // Перезагружаем страницу для обновления данных графиков
        window.location.reload();
    }
}

// Экспорт функций для использования в других скриптах
window.StatisticsPage = {
    refreshCharts: refreshCharts,
    updateStatsCards: updateStatsCards,
    exportData: exportData
};
