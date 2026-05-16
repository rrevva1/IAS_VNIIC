/**
 * AG Grid конфигурация для таблицы заявок
 */

// Глобальные переменные
let gridApi;
let gridOptions;
let isAdmin = false;
let allUsers = [];
let allStatuses = [];
let previewModalInstance = null;

/**
 * Глобальная функция для открытия модального окна предпросмотра
 */
window.openPreviewModalFromGrid = function(attachmentId, filename, previewUrl) {
    const downloadUrl = '/index.php?r=tasks/download&id=' + attachmentId;
    
    // Обновляем заголовок модального окна
    let modalTitle = document.querySelector('#previewModal .modal-title');
    if (!modalTitle) {
        modalTitle = document.querySelector('#previewModal h5');
    }
    if (!modalTitle) {
        modalTitle = document.querySelector('.modal-title');
    }
    
    if (modalTitle) {
        modalTitle.textContent = 'Предпросмотр: ' + filename;
    }
    
    // Обновляем ссылку на скачивание
    const downloadBtn = document.getElementById('downloadBtn');
    if (downloadBtn) {
        downloadBtn.setAttribute('href', downloadUrl);
    }
    
    // Определяем тип файла
    const extension = filename.split('.').pop().toLowerCase();
    let previewContent = '';
    
    if (extension === 'pdf') {
        previewContent = '<iframe src="' + previewUrl + '" style="width: 100%; height: 80vh; border: none;"></iframe>';
    } else if (['png', 'jpg', 'jpeg', 'gif', 'bmp', 'svg'].includes(extension)) {
        previewContent = '<img src="' + previewUrl + '" alt="' + filename + '" style="max-width: 100%; max-height: 80vh; object-fit: contain;">';
    } else {
        previewContent = '<div class="text-center" style="padding: 50px; color: #fff;"><i class="glyphicon glyphicon-file" style="font-size: 48px; margin-bottom: 20px;"></i><br><p>Предпросмотр недоступен для данного типа файла</p><p><a href="' + downloadUrl + '" class="btn btn-primary">Скачать файл</a></p></div>';
    }
    
    // Загружаем контент в модальное окно
    let previewContentDiv = document.getElementById('previewContent');
    if (!previewContentDiv) {
        previewContentDiv = document.querySelector('#previewModal .modal-body');
    }
    
    if (previewContentDiv) {
        previewContentDiv.innerHTML = previewContent;
    } else {
        return;
    }
    
    // Получаем или создаем экземпляр модального окна
    const modalElement = document.getElementById('previewModal');
    if (modalElement) {
        if (!previewModalInstance) {
            if (typeof bootstrap !== 'undefined' && bootstrap.Modal) {
                previewModalInstance = new bootstrap.Modal(modalElement, {
                    backdrop: true,
                    keyboard: true
                });
            } else {
                return;
            }
        }
        previewModalInstance.show();
    }
};

// Инициализация AG Grid при загрузке страницы
// Используем несколько способов для гарантии выполнения
(function() {
    'use strict';
    
    function initGrid() {
        // Проверяем наличие контейнера
        const container = document.getElementById('agGridTasksContainer');
        if (!container) {
            console.warn('AG Grid: Контейнер не найден, повторная попытка через 100ms...');
            setTimeout(initGrid, 100);
            return;
        }
        
        // Проверяем наличие AG Grid библиотеки
        if (typeof agGrid === 'undefined') {
            console.warn('AG Grid: Библиотека еще не загружена, повторная попытка через 200ms...');
            setTimeout(initGrid, 200);
            return;
        }
        
        console.log('AG Grid: Все готово, запуск инициализации...');
        initializeAgGrid();
    }
    
    // Пробуем сразу, если DOM уже готов
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initGrid);
    } else {
        // DOM уже загружен, но скрипты могут еще загружаться
        setTimeout(initGrid, 100);
    }
    
    // Дополнительная проверка через jQuery (если доступен)
    if (typeof jQuery !== 'undefined') {
        jQuery(document).ready(function($) {
            setTimeout(function() {
                if (!gridApi) {
                    console.log('AG Grid: jQuery ready, финальная проверка...');
                    initGrid();
                }
            }, 500);
        });
    }
    
    // Последняя попытка через 2 секунды
    setTimeout(function() {
        if (!gridApi) {
            console.warn('AG Grid: Финальная попытка инициализации...');
            initGrid();
        }
    }, 2000);
})();

// Обработчик изменения размера окна для динамической подстройки высоты таблицы
// Использует debounce для оптимизации производительности
let resizeTimeout;
window.addEventListener('resize', function() {
    clearTimeout(resizeTimeout);
    resizeTimeout = setTimeout(function() {
        // Перерасчитываем высоту контейнера при изменении размера окна
        if (gridApi) {
            adjustGridHeight();
        }
    }, 250); // задержка 250мс для оптимизации
});

// Флаг для предотвращения повторной инициализации
let gridInitialized = false;

/**
 * Инициализация AG Grid
 */
function initializeAgGrid() {
    // Предотвращаем повторную инициализацию
    if (gridInitialized) {
        console.log('AG Grid: Уже инициализирован, пропускаем...');
        return;
    }
    
    console.log('AG Grid: Начало инициализации...');
    
    // Проверяем, доступен ли AG Grid
    if (typeof agGrid === 'undefined') {
        console.error('AG Grid: Библиотека agGrid не найдена!');
        const gridDiv = document.querySelector('#agGridTasksContainer');
        if (gridDiv) {
            gridDiv.innerHTML = '<div class="alert alert-danger" style="margin: 20px;"><h4>❌ AG Grid не загружен!</h4><p>Проверьте наличие файлов AG Grid в директории /web/ag-grid-community/</p><p>Откройте консоль браузера (F12) для подробностей</p><p>Попробуйте обновить страницу (Ctrl+F5 для очистки кэша)</p></div>';
        } else {
            console.error('AG Grid: Контейнер #agGridTasksContainer не найден!');
        }
        return;
    }
    
    console.log('AG Grid: Библиотека найдена, версия:', agGrid.VERSION || 'неизвестна');
    
    // Проверяем, является ли пользователь администратором
    isAdmin = window.isUserAdmin || false;
    allUsers = window.allUsersList || {};
    allStatuses = window.allStatusList || {};
    
    const gridDiv = document.querySelector('#agGridTasksContainer');
    if (!gridDiv) {
        console.error('AG Grid: Контейнер #agGridTasksContainer не найден в DOM!');
        return;
    }
    
    console.log('AG Grid: Контейнер найден, создание таблицы...');
    
    // Определение колонок
    const columnDefs = getColumnDefinitions();
    
    // Настройки AG Grid
    gridOptions = {
        columnDefs: columnDefs,
        defaultColDef: {
            sortable: true,
            filter: true,
            resizable: true,
            editable: false,
            floatingFilter: false, // только полное меню фильтра по клику на иконку (как на Учет ТС)
        },
        // Без чекбоксов: выбор строки по клику (как в Пользователях)
        rowSelection: { mode: 'singleRow' },
        pagination: true,
        paginationPageSize: 20,
        paginationPageSizeSelector: [10, 20, 50, 100],
        domLayout: 'normal',
        
        // Локализация
        localeText: {
            page: 'Страница',
            to: 'до',
            of: 'из',
            next: 'Следующая',
            last: 'Последняя',
            first: 'Первая',
            previous: 'Предыдущая',
            loadingOoo: 'Загрузка...',
            noRowsToShow: 'Нет данных для отображения',
            filterOoo: 'Фильтр...',
            pageSizeSelectorLabel: 'Размер страницы:',
        },
        
        // Обработчики событий
        onGridReady: onGridReady,
        onModelUpdated: initExecutorUserSelectsInGrid,
        onCellValueChanged: onCellValueChanged,
        // Добавляем обработчик изменения размера страницы для автоматической подстройки высоты
        onPaginationChanged: onPaginationChanged,
        
        // Full Width Row для выезжающей панели с техникой (работает в Community Edition)
        isFullWidthRow: function(params) {
            return params.rowNode.data && params.rowNode.data.isDetailRow;
        },
        fullWidthCellRenderer: EquipmentDetailRenderer,
        
        // Высота строки: для обычных — по длине описания (перенос), для детальной панели — по контенту
        getRowHeight: function(params) {
            if (!params.node.data) {
                return undefined;
            }
            // Детальная панель (техника)
            if (params.node.data.isDetailRow) {
                const equipmentData = params.node.data.equipmentData || [];
                if (equipmentData.length === 0) {
                    return 120;
                }
                const headerHeight = 60;
                const tableHeaderHeight = 45;
                const rowHeight = 45;
                const padding = 40;
                const totalHeight = headerHeight + tableHeaderHeight + (equipmentData.length * rowHeight) + padding;
                return Math.min(totalHeight, 600);
            }
            // Обычная строка: увеличить высоту при длинном описании (перенос текста)
            const desc = params.node.data.description;
            if (desc && typeof desc === 'string' && desc.length > 0) {
                const lineHeight = 20;
                const charsPerLine = 55; // приблизительно при типичной ширине колонки
                const lines = Math.min(Math.ceil(desc.length / charsPerLine), 6); // не более 6 строк
                if (lines > 1) {
                    return Math.max(40, 12 + lines * lineHeight);
                }
            }
            return undefined; // стандартная высота
        },
    };
    
    // Создание AG Grid
    try {
        console.log('AG Grid: Создание таблицы с опциями:', gridOptions);
        gridApi = agGrid.createGrid(gridDiv, gridOptions);
        console.log('AG Grid: Таблица создана успешно, gridApi:', gridApi);
        
        // Помечаем как инициализированную
        gridInitialized = true;
        
        // Очищаем сообщение о загрузке
        const loadingMsg = gridDiv.querySelector('.text-center');
        if (loadingMsg) {
            loadingMsg.remove();
        }
        
        // Загружаем данные
        console.log('AG Grid: Загрузка данных...');
        loadGridData();
    } catch (error) {
        console.error('AG Grid: Ошибка при создании таблицы:', error);
        gridDiv.innerHTML = `
            <div class="alert alert-danger" style="margin: 20px;">
                <h4>❌ Ошибка инициализации AG Grid</h4>
                <p><strong>Ошибка:</strong> ${error.message}</p>
                <p><strong>Стек:</strong> ${error.stack || 'недоступен'}</p>
                <p>Откройте консоль браузера (F12) для подробностей</p>
                <p><button onclick="location.reload()" class="btn btn-primary">Обновить страницу</button></p>
            </div>
        `;
    }
}

/**
 * Парсит строку даты формата dd.mm.yyyy HH:MM в объект Date
 * Возвращает null, если дата некорректна или пустая
 */
function parseRuDateTime(text) {
    if (!text || typeof text !== 'string') {
        return null;
    }
    const parts = text.trim().split(/\s+/);
    const datePart = parts[0];
    const timePart = parts[1] || '00:00';
    const dateMatch = datePart.match(/^(\d{2})\.(\d{2})\.(\d{4})$/);
    const timeMatch = timePart.match(/^(\d{2}):(\d{2})$/);
    if (!dateMatch) {
        return null;
    }
    const day = parseInt(dateMatch[1], 10);
    const month = parseInt(dateMatch[2], 10) - 1; // месяцы с нуля
    const year = parseInt(dateMatch[3], 10);
    const hours = timeMatch ? parseInt(timeMatch[1], 10) : 0;
    const minutes = timeMatch ? parseInt(timeMatch[2], 10) : 0;
    const d = new Date(year, month, day, hours, minutes, 0, 0);
    if (
        d.getFullYear() !== year ||
        d.getMonth() !== month ||
        d.getDate() !== day ||
        d.getHours() !== hours ||
        d.getMinutes() !== minutes
    ) {
        return null;
    }
    return d;
}

/**
 * Компаратор для agDateColumnFilter: сравнивает только календарные даты (дд.мм.гггг)
 * Возвращает -1 если cellDate < filterDate, 1 если >, 0 если один и тот же день
 */
function compareDatesByDay(filterDateAtMidnight, cellValue) {
    // cellValue приходит как Date из valueGetter
    if (!(cellValue instanceof Date) || isNaN(cellValue.getTime())) {
        return -1; // трактуем пустые/некорректные как меньше фильтра
    }
    const cellMidnight = new Date(
        cellValue.getFullYear(),
        cellValue.getMonth(),
        cellValue.getDate(),
        0, 0, 0, 0
    );
    const diff = cellMidnight.getTime() - filterDateAtMidnight.getTime();
    if (diff === 0) return 0;
    return diff < 0 ? -1 : 1;
}

/**
 * Переключение отображения техники работника
 * @param {number} taskId - ID заявки
 * @param {number} userId - ID пользователя
 */
function toggleEquipmentDetail(taskId, userId) {
    if (!gridApi) return;
    
    // Находим строку заявки
    let taskRowNode = null;
    gridApi.forEachNode(function(node) {
        if (node.data && node.data.id == taskId && !node.data.isDetailRow) {
            taskRowNode = node;
        }
    });
    
    if (!taskRowNode) {
        console.error('Строка заявки не найдена:', taskId);
        return;
    }
    
    const isExpanded = taskRowNode.data._equipmentExpanded || false;
    
    if (isExpanded) {
        // Скрыть панель
        hideEquipmentDetail(taskId);
    } else {
        // Показать панель
        showEquipmentDetail(taskId, userId, taskRowNode);
    }
}

/**
 * Показать технику работника (выезжающая панель)
 */
function showEquipmentDetail(taskId, userId, taskRowNode) {
    console.log('Загружаю технику для пользователя:', userId);
    
    // Загружаем данные о технике через AJAX
    fetch(`/index.php?r=tasks/get-user-equipment&userId=${userId}`)
        .then(response => response.json())
        .then(result => {
            if (result.success) {
                // Помечаем строку как раскрытую
                taskRowNode.data._equipmentExpanded = true;
                taskRowNode.data._equipmentData = result.data;
                
                // Обновляем кнопку (плюс → минус)
                gridApi.refreshCells({ rowNodes: [taskRowNode], force: true });
                
                // Создаем новый массив данных с detail row
                const rowData = [];
                gridApi.forEachNode(node => {
                    if (node.data && !node.data.isDetailRow) {
                        rowData.push(node.data);
                        
                        // После нужной строки добавляем detail row
                        if (node.data.id == taskId) {
                            rowData.push({
                                isDetailRow: true,
                                parentTaskId: taskId,
                                equipmentData: result.data,
                                totalCount: result.total || result.data.length
                            });
                        }
                    }
                });
                
                // Обновляем данные таблицы
                gridApi.setGridOption('rowData', rowData);
                
                // Запускаем пересчёт высоты строк для детальной панели
                setTimeout(() => {
                    gridApi.onRowHeightChanged();
                }, 100);
                
                console.log('✅ Техника загружена:', result.data.length, 'записей');
            } else {
                alert('Ошибка: ' + (result.message || 'Не удалось загрузить данные'));
            }
        })
        .catch(error => {
            console.error('Ошибка загрузки техники:', error);
            alert('Ошибка соединения с сервером');
        });
}

/**
 * Скрыть технику работника (свернуть панель)
 */
function hideEquipmentDetail(taskId) {
    // Помечаем строку как свернутую
    let taskRowNode = null;
    gridApi.forEachNode(function(node) {
        if (node.data && node.data.id == taskId && !node.data.isDetailRow) {
            taskRowNode = node;
        }
    });
    
    if (taskRowNode) {
        taskRowNode.data._equipmentExpanded = false;
        delete taskRowNode.data._equipmentData;
    }
    
    // Удаляем detail row из таблицы
    const rowData = [];
    gridApi.forEachNode(node => {
        if (node.data) {
            // Пропускаем detail row для этой заявки
            if (node.data.isDetailRow && node.data.parentTaskId == taskId) {
                return; // skip
            }
            rowData.push(node.data);
        }
    });
    
    // Обновляем таблицу
    gridApi.setGridOption('rowData', rowData);
    
    // Запускаем пересчёт высоты строк
    setTimeout(() => {
        gridApi.onRowHeightChanged();
    }, 100);
    
    console.log('✅ Панель техники скрыта');
}

/**
 * Рендерер для Full Width Row (выезжающая панель с техникой)
 */
function EquipmentDetailRenderer(params) {
    if (!params.data || !params.data.isDetailRow) {
        return document.createElement('div');
    }
    
    const equipmentData = params.data.equipmentData || [];
    const totalCount = params.data.totalCount || 0;
    
    const container = document.createElement('div');
    container.className = 'equipment-detail-container';
    container.style.cssText = 'background-color: #f8f9fa; padding: 20px; border-left: 4px solid #667eea; animation: slideDown 0.3s ease-out;';
    
    if (equipmentData.length === 0) {
        // Нет техники
        container.innerHTML = `
            <div style="text-align: center; padding: 30px; color: #6c757d;">
                <i class="glyphicon glyphicon-info-sign" style="font-size: 32px; margin-bottom: 15px; color: #adb5bd;"></i>
                <p style="font-size: 16px; margin: 0;">У работника нет закрепленной техники</p>
            </div>
        `;
    } else {
        // Есть техника - строим таблицу
        let html = `
            <div style="margin-bottom: 15px;">
                <span style="font-size: 16px; font-weight: 600; color: #495057;">
                    🖥️ Техника работника
                </span>
                <span style="margin-left: 10px; padding: 3px 10px; background: #667eea; color: white; border-radius: 12px; font-size: 13px;">
                    ${totalCount} ${totalCount === 1 ? 'единица' : totalCount < 5 ? 'единицы' : 'единиц'}
                </span>
            </div>
            <table class="table table-bordered table-hover" style="margin: 0; background: white; border-radius: 6px; overflow: hidden;">
                <thead style="background-color: #667eea; color: white;">
                    <tr>
                        <th style="padding: 12px;">ID</th>
                        <th style="padding: 12px;">Название техники</th>
                        <th style="padding: 12px;">Местоположение</th>
                        <th style="padding: 12px;">Описание</th>
                        <th style="padding: 12px;">Дата добавления</th>
                    </tr>
                </thead>
                <tbody>
        `;
        
        equipmentData.forEach((item, index) => {
            const rowStyle = index % 2 === 0 ? 'background-color: #ffffff;' : 'background-color: #f8f9fa;';
            html += `
                <tr style="${rowStyle}">
                    <td style="padding: 10px; text-align: center;"><strong>${item.id}</strong></td>
                    <td style="padding: 10px;"><strong style="color: #495057;">${item.name}</strong></td>
                    <td style="padding: 10px;">${item.location}</td>
                    <td style="padding: 10px; color: #6c757d;">${item.description}</td>
                    <td style="padding: 10px; font-size: 13px;">${item.created_at}</td>
                </tr>
            `;
        });
        
        html += `
                </tbody>
            </table>
        `;
        
        container.innerHTML = html;
    }
    
    return container;
}

/**
 * Определение колонок таблицы
 */
function getColumnDefinitions() {
    const columns = [];
    
    // Порядок как в Пользователях: первый столбец — кнопка «+» (техника), затем ID
    if (isAdmin) {
        // 1) Плюсик в первом столбце (как в Пользователях)
        columns.push({
            colId: 'equipment_toggle',
            headerName: '',
            field: 'equipment_toggle',
            width: 56,
            minWidth: 48,
            pinned: 'left',
            filter: false,
            floatingFilter: false,
            sortable: false,
            cellRenderer: function(params) {
                if (params.data && params.data.isDetailRow) {
                    return '';
                }
                const taskId = params.data.id;
                const userId = params.data.user_id;
                const isExpanded = params.node.data._equipmentExpanded || false;
                const title = isExpanded ? 'Скрыть технику' : 'Показать технику работника';
                const btnClass = isExpanded ? 'equipment-toggle-btn equipment-toggle-btn--expanded' : 'equipment-toggle-btn';
                const symbol = isExpanded ? '−' : '+';
                return '<button class="' + btnClass + '" data-task-id="' + taskId + '" data-user-id="' + userId + '" aria-label="' + title + '" title="' + title + '"><span class="toggle-icon">' + symbol + '</span></button>';
            }
        });

        // 2) ID заявки (с фильтром)
        columns.push({
            headerName: 'ID',
            field: 'id',
            width: 80,
            pinned: 'left',
            filter: 'agNumberColumnFilter',
            cellRenderer: function(params) {
                return '<a href="/index.php?r=tasks/view&id=' + params.value + '">' + params.value + '</a>';
            }
        });
    }
    
    // Описание — перенос по словам для объёмного текста
    columns.push({
        headerName: 'Описание',
        field: 'description',
        flex: 2,
        minWidth: 250,
        filter: 'agTextColumnFilter',
        wrapText: true,
        cellClass: 'ag-cell-description-wrap',
        cellRenderer: function(params) {
            return params.value != null ? String(params.value) : '';
        },
        tooltipField: 'description',
    });
    
    // Статус
    if (isAdmin) {
        columns.push({
            headerName: 'Статус',
            field: 'status_name',
            width: 150,
            filter: 'agTextColumnFilter',
            cellRenderer: function(params) {
                const statusId = params.data.status_id;
                const statusColors = {
                    1: { bg: '#28a74520', text: '#28a745' },
                    2: { bg: '#ffc10720', text: '#856404' },
                    3: { bg: '#dc354520', text: '#721c24' },
                    4: { bg: '#17a2b820', text: '#0c5460' },
                };
                const colorScheme = statusColors[statusId] || { bg: '#f8f9fa', text: '#495057' };
                
                return `<select class="form-control status-change-ag" 
                    data-task-id="${params.data.id}" 
                    style="font-size: 13px; padding: 4px; background-color: ${colorScheme.bg}; 
                    color: ${colorScheme.text}; border: 1px solid ${colorScheme.text}40; 
                    border-radius: 4px; font-weight: 500; width: 100%;">
                    ${Object.entries(allStatuses).map(([id, name]) => 
                        `<option value="${id}" ${id == statusId ? 'selected' : ''}>${name}</option>`
                    ).join('')}
                </select>`;
            }
        });
    } else {
        columns.push({
            headerName: 'Статус',
            field: 'status_name',
            width: 150,
            filter: 'agTextColumnFilter',
        });
    }
    
    // Автор
    columns.push({
        headerName: 'Автор',
        field: 'user_name',
        width: 150,
        filter: 'agTextColumnFilter',
    });
    
    // Исполнитель
    if (isAdmin) {
        columns.push({
            headerName: 'Исполнитель',
            field: 'executor_name',
            width: 180,
            filter: 'agTextColumnFilter',
            cellRenderer: function(params) {
                const executorId = params.data.executor_id || '';
                return `<select class="form-control executor-change-ag js-user-select-search" 
                    data-task-id="${params.data.id}" 
                    data-placeholder="Не назначен"
                    style="font-size: 13px; padding: 4px; width: 100%; border-radius: 4px;">
                    <option value="">Не назначен</option>
                    ${Object.entries(allUsers).map(([id, name]) => 
                        `<option value="${id}" ${id == executorId ? 'selected' : ''}>${name}</option>`
                    ).join('')}
                </select>`;
            }
        });
    } else {
        columns.push({
            headerName: 'Исполнитель',
            field: 'executor_name',
            width: 180,
            filter: 'agTextColumnFilter',
        });
    }
    
    // Дата создания
    columns.push({
        headerName: 'Создана',
        field: 'date',
        width: 150,
        valueGetter: function(params) {
            return parseRuDateTime(params.data && params.data.date);
        },
        valueFormatter: function(params) {
            return params.data && params.data.date ? params.data.date : '';
        },
        filter: 'agDateColumnFilter',
        filterParams: {
            inRangeInclusive: true,
            comparator: compareDatesByDay,
        },
    });
    
    // Дата обновления
    columns.push({
        headerName: 'Обновлена',
        field: 'last_time_update',
        width: 150,
        valueGetter: function(params) {
            return parseRuDateTime(params.data && params.data.last_time_update);
        },
        valueFormatter: function(params) {
            return params.data && params.data.last_time_update ? params.data.last_time_update : '';
        },
        filter: 'agDateColumnFilter',
        filterParams: {
            inRangeInclusive: true,
            comparator: compareDatesByDay,
        },
    });
    
    // Вложения
    columns.push({
        headerName: 'Вложения',
        field: 'attachments',
        width: 120,
        filter: false,
        valueFormatter: function(params) {
            const attachments = params.value || [];
            return attachments.length > 0 ? `${attachments.length}` : '-';
        },
        cellRenderer: function(params) {
            const attachments = params.value || [];
            if (attachments.length === 0) {
                return '<span class="text-muted">-</span>';
            }
            
            let html = '<div class="attachments-container-ag">';
            attachments.forEach(attachment => {
                const iconClass = attachment.icon;
                if (attachment.is_previewable) {
                    html += `<a href="javascript:void(0);" 
                        class="attachment-link-ag preview-link" 
                        title="${attachment.name}" 
                        data-ag-attachment-id="${attachment.id}"
                        data-ag-filename="${attachment.name}"
                        data-ag-preview-url="${attachment.preview_url}">
                        <i class="fa ${iconClass}"></i>
                    </a>`;
                } else {
                    html += `<a href="${attachment.download_url}" 
                        class="attachment-link-ag download-link" 
                        title="${attachment.name}">
                        <i class="fa ${iconClass}"></i>
                    </a>`;
                }
            });
            html += '</div>';
            return html;
        }
    });
    
    // Комментарий
    if (isAdmin) {
        columns.push({
            headerName: 'Комментарий',
            field: 'comment',
            flex: 1,
            minWidth: 200,
            filter: 'agTextColumnFilter',
            editable: true,
            cellEditor: 'agLargeTextCellEditor',
            cellEditorPopup: true,
            cellRenderer: function(params) {
                const text = params.value || '';
                return text.length > 50 ? text.substring(0, 50) + '...' : text;
            },
            tooltipField: 'comment',
        });
    } else {
        columns.push({
            headerName: 'Комментарий',
            field: 'comment',
            flex: 1,
            minWidth: 200,
            filter: 'agTextColumnFilter',
            cellRenderer: function(params) {
                const text = params.value || '';
                return text.length > 50 ? text.substring(0, 50) + '...' : text;
            },
            tooltipField: 'comment',
        });
    }
    
    return columns;
}

/**
 * Select2 для выпадающего списка исполнителя в ячейках грида.
 */
function initExecutorUserSelectsInGrid() {
    var container = document.getElementById('agGridTasksContainer');
    if (container && window.IasUserSelect) {
        window.IasUserSelect.init(container);
    }
}

/**
 * Обработчик готовности сетки
 */
function onGridReady(params) {
    loadGridData();
    setupEventHandlers();
    // Устанавливаем начальную высоту контейнера под текущий размер страницы
    adjustGridHeight();
}

/**
 * Обработчик изменения пагинации (смена количества строк на странице)
 * Автоматически подстраивает высоту таблицы под выбранное количество строк
 */
function onPaginationChanged(params) {
    // Проверяем, что изменился именно размер страницы
    const pageSize = gridApi.paginationGetPageSize();
    adjustGridHeight(pageSize);
}

/**
 * Динамически изменяет высоту контейнера AG Grid в зависимости от размера страницы
 * @param {number} pageSize - количество строк на странице (если не указано, берется из API)
 */
function adjustGridHeight(pageSize) {
    if (!gridApi) return;
    
    // Получаем текущий размер страницы, если не передан
    if (!pageSize) {
        pageSize = gridApi.paginationGetPageSize();
    }
    
    // Константы для расчета высоты
    const ROW_HEIGHT = 55; // высота одной строки (определена в CSS переменных)
    const HEADER_HEIGHT = 55; // высота заголовка таблицы
    const PAGINATION_HEIGHT = 60; // высота панели пагинации
    const EXTRA_PADDING = 20; // дополнительные отступы и границы
    const FLOATING_FILTER_HEIGHT = isAdmin ? 40 : 0; // высота floating фильтров (только для админов)
    
    // Рассчитываем оптимальную высоту контейнера
    const calculatedHeight = 
        (ROW_HEIGHT * pageSize) + 
        HEADER_HEIGHT + 
        PAGINATION_HEIGHT + 
        EXTRA_PADDING + 
        FLOATING_FILTER_HEIGHT;
    
    // Получаем высоту окна для ограничения максимальной высоты
    const windowHeight = window.innerHeight;
    const maxHeight = windowHeight - 250; // оставляем место для заголовка страницы и панели инструментов
    
    // Применяем высоту с ограничением по максимуму
    const finalHeight = Math.min(calculatedHeight, maxHeight);
    
    // Устанавливаем минимальную высоту
    const minHeight = 500;
    const resultHeight = Math.max(finalHeight, minHeight);
    
    // Применяем высоту к контейнеру
    const gridDiv = document.querySelector('#agGridTasksContainer');
    if (gridDiv) {
        gridDiv.style.height = resultHeight + 'px';
        
        // Логируем для отладки (можно удалить в продакшене)
        console.log('AG Grid: Автоподстройка высоты', {
            pageSize: pageSize,
            calculatedHeight: calculatedHeight,
            maxHeight: maxHeight,
            resultHeight: resultHeight
        });
    }
}

/**
 * Загрузка данных в таблицу
 */
function loadGridData() {
    if (!gridApi) {
        console.error('AG Grid: gridApi не доступен для загрузки данных');
        return;
    }
    
    const dataUrl = window.agGridDataUrl || '/index.php?r=tasks/get-grid-data';
    console.log('AG Grid: Загрузка данных из:', dataUrl);
    
    fetch(dataUrl)
        .then(response => {
            console.log('AG Grid: Ответ получен, статус:', response.status);
            if (!response.ok) {
                throw new Error('HTTP error! status: ' + response.status);
            }
            return response.json();
        })
        .then(result => {
            console.log('AG Grid: Данные получены, результат:', result);
            if (result.success) {
                console.log('AG Grid: Загрузка', result.data.length, 'записей в таблицу');
                gridApi.setGridOption('rowData', result.data);
            } else {
                console.error('AG Grid: Ошибка в ответе сервера:', result.error || 'Неизвестная ошибка');
            }
        })
        .catch(error => {
            console.error('AG Grid: Ошибка загрузки данных:', error);
            const gridDiv = document.querySelector('#agGridTasksContainer');
            if (gridDiv && gridApi) {
                // Показываем сообщение об ошибке, но не заменяем всю таблицу
                console.error('AG Grid: Не удалось загрузить данные');
            }
        });
}

/**
 * Настройка обработчиков событий для редактируемых элементов
 */
let eventHandlersInitialized = false;

function setupEventHandlers() {
    if (eventHandlersInitialized) {
        return;
    }
    
    // Обработчик изменений (статус, исполнитель)
    document.addEventListener('change', function(e) {
        if (e.target.classList.contains('status-change-ag')) {
            const taskId = e.target.dataset.taskId;
            const statusId = e.target.value;
            changeTaskStatus(taskId, statusId);
        }
        
        if (e.target.classList.contains('executor-change-ag')) {
            const taskId = e.target.dataset.taskId;
            const executorId = e.target.value;
            assignExecutor(taskId, executorId);
        }
    });
    
    // Обработчик кликов на кнопку техники
    document.addEventListener('click', function(e) {
        const toggleBtn = e.target.closest('.equipment-toggle-btn');
        if (toggleBtn) {
            e.preventDefault();
            e.stopPropagation();
            
            const userId = toggleBtn.dataset.userId;
            const taskId = toggleBtn.dataset.taskId;
            
            console.log('Клик на кнопку техники. TaskID:', taskId, 'UserID:', userId);
            toggleEquipmentDetail(taskId, userId);
        }
    });
    
    // Обработчик кликов по вложениям
    document.addEventListener('click', function(e) {
        const previewLink = e.target.closest('.preview-link');
        
        if (previewLink) {
            e.preventDefault();
            e.stopPropagation();
            e.stopImmediatePropagation();
            
            const attachmentId = previewLink.getAttribute('data-ag-attachment-id');
            const filename = previewLink.getAttribute('data-ag-filename');
            const previewUrl = previewLink.getAttribute('data-ag-preview-url');
            
            if (attachmentId && filename && previewUrl) {
                window.openPreviewModalFromGrid(attachmentId, filename, previewUrl);
            }
            
            return false;
        }
    }, true);
    
    eventHandlersInitialized = true;
}

/**
 * Получить CSRF токен
 */
function getCsrfToken() {
    if (window.yii && typeof window.yii.getCsrfToken === 'function') {
        return window.yii.getCsrfToken();
    }
    const metaTag = document.querySelector('meta[name="csrf-token"]');
    if (metaTag) {
        return metaTag.getAttribute('content');
    }
    return '';
}

/**
 * Изменение статуса задачи
 */
function changeTaskStatus(taskId, statusId) {
    const formData = new FormData();
    formData.append('status_id', statusId);
    formData.append('_csrf', getCsrfToken());
    
    const url = `/index.php?r=tasks/change-status&id=${taskId}`;
    fetch(url, {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        loadGridData();
    })
    .catch(error => {
        console.error('Error:', error);
        loadGridData();
    });
}

/**
 * Назначение исполнителя
 */
function assignExecutor(taskId, executorId) {
    const formData = new FormData();
    formData.append('executor_id', executorId);
    formData.append('_csrf', getCsrfToken());
    
    const url = `/index.php?r=tasks/assign-executor&id=${taskId}`;
    fetch(url, {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        loadGridData();
    })
    .catch(error => {
        console.error('Error:', error);
        loadGridData();
    });
}

/**
 * Обработчик изменения значения ячейки
 */
function onCellValueChanged(params) {
    if (params.colDef.field === 'comment') {
        const taskId = params.data.id;
        const comment = params.newValue;
        updateComment(taskId, comment);
    }
}

/**
 * Обновление комментария
 */
function updateComment(taskId, comment) {
    const formData = new FormData();
    formData.append('comment', comment);
    formData.append('_csrf', getCsrfToken());
    
    const url = `/index.php?r=tasks/update-comment&id=${taskId}`;
    fetch(url, {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        if (!data.success) {
            loadGridData();
        }
    })
    .catch(error => {
        console.error('Error:', error);
        loadGridData();
    });
}

/**
 * Функции для кнопок панели инструментов
 */
function refreshGrid() {
    loadGridData();
}

function selectAllRows() {
    if (gridApi) {
        gridApi.selectAll();
    }
}

function deselectAllRows() {
    if (gridApi) {
        gridApi.deselectAll();
    }
}

function exportToExcel() {
    if (gridApi) {
        alert('Экспорт в Excel доступен только в AG Grid Enterprise Edition. Используйте экспорт в CSV.');
        exportToCsv();
    }
}

function exportToCsv() {
    if (gridApi) {
        gridApi.exportDataAsCsv({
            fileName: 'Заявки_' + new Date().toISOString().split('T')[0] + '.csv'
        });
    }
}

/**
 * Открывает модальное окно для создания новой заявки
 */
function openCreateTaskModal() {
    const modalElement = document.getElementById('createTaskModal');
    if (!modalElement) {
        return;
    }
    
    const modal = new bootstrap.Modal(modalElement);
    modal.show();
    
    $.ajax({
        url: '/index.php?r=tasks/create-modal',
        type: 'GET',
        success: function(response) {
            $('#createTaskModalBody').html(response);
            initTaskFormSubmit();
        },
        error: function(xhr, status, error) {
            $('#createTaskModalBody').html(
                '<div class="alert alert-danger">' +
                '<i class="glyphicon glyphicon-exclamation-sign"></i> ' +
                'Ошибка загрузки формы: ' + error +
                '</div>'
            );
        }
    });
}

/**
 * Инициализирует обработчик отправки формы через AJAX
 */
function initTaskFormSubmit() {
    var $form = $('#createTaskModalBody').find('form');
    
    $form.off('submit').on('submit', function(e) {
        e.preventDefault();
        
        var formData = new FormData(this);
        
        var $submitBtn = $form.find('#submit-task-btn');
        var originalBtnText = $submitBtn.html();
        $submitBtn.html('<i class="glyphicon glyphicon-refresh glyphicon-spin"></i> Создание...');
        $submitBtn.prop('disabled', true);
        
        $.ajax({
            url: '/index.php?r=tasks/create-modal',
            type: 'POST',
            data: formData,
            processData: false,
            contentType: false,
            success: function(response) {
                if (response.success) {
                    const modalElement = document.getElementById('createTaskModal');
                    const modal = bootstrap.Modal.getInstance(modalElement);
                    if (modal) {
                        modal.hide();
                    }
                    
                    showNotification('success', response.message);
                    refreshGrid();
                    
                } else {
                    showNotification('error', response.message);
                    displayFormErrors(response.errors);
                }
            },
            error: function(xhr, status, error) {
                showNotification('error', 'Ошибка сервера: ' + error);
            },
            complete: function() {
                $submitBtn.html(originalBtnText);
                $submitBtn.prop('disabled', false);
            }
        });
    });
    
    $form.find('.btn-cancel').off('click').on('click', function() {
        const modalElement = document.getElementById('createTaskModal');
        const modal = bootstrap.Modal.getInstance(modalElement);
        if (modal) {
            modal.hide();
        }
    });
}

/**
 * Отображает ошибки валидации в форме
 */
function displayFormErrors(errors) {
    $('.has-error').removeClass('has-error');
    $('.help-block').remove();
    
    $.each(errors, function(field, messages) {
        var $field = $('#tasks-' + field);
        var $formGroup = $field.closest('.form-group');
        
        $formGroup.addClass('has-error');
        
        var errorHtml = '<div class="help-block">' + messages.join('<br>') + '</div>';
        $field.after(errorHtml);
    });
}

/**
 * Показывает уведомление пользователю
 */
function showNotification(type, message) {
    var alertClass = type === 'success' ? 'alert-success' : 'alert-danger';
    var iconClass = type === 'success' ? 'glyphicon-ok-sign' : 'glyphicon-exclamation-sign';
    
    var notification = $('<div class="alert ' + alertClass + ' alert-dismissible" role="alert">' +
        '<button type="button" class="close" data-dismiss="alert" aria-label="Close">' +
        '<span aria-hidden="true">&times;</span>' +
        '</button>' +
        '<i class="glyphicon ' + iconClass + '"></i> ' + message +
        '</div>');
    
    $('.tasks-index-ag').prepend(notification);
    
    setTimeout(function() {
        notification.fadeOut(function() {
            $(this).remove();
        });
    }, 5000);
}

/**
 * Очищает форму и модальное окно при закрытии
 */
const modalElement = document.getElementById('createTaskModal');
if (modalElement) {
    modalElement.addEventListener('hidden.bs.modal', function () {
        $('#createTaskModalBody').html(
            '<div class="text-center" style="padding: 50px;">' +
            '<i class="glyphicon glyphicon-refresh glyphicon-spin" style="font-size: 32px; color: #667eea;"></i>' +
            '<p style="margin-top: 15px;">Загрузка формы...</p>' +
            '</div>'
        );
    });
}

// Экспорт функций
window.refreshGrid = refreshGrid;
window.selectAllRows = selectAllRows;
window.deselectAllRows = deselectAllRows;
window.exportToExcel = exportToExcel;
window.exportToCsv = exportToCsv;
window.openCreateTaskModal = openCreateTaskModal;
