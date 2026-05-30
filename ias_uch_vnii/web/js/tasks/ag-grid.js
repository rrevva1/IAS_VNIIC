/**
 * AG Grid: таблица заявок (список, выбор, массовое удаление).
 */

// Глобальные переменные
let gridApi;
let gridOptions;
let isAdmin = false;
let allUsers = [];
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
    allUsers = window.taskExecutorsList || window.allUsersList || {};
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
        animateRows: true,
        defaultColDef: {
            sortable: true,
            filter: true,
            resizable: true,
            wrapText: true,
            autoHeight: false,
            cellClass: 'ag-cell-wrap-text',
            editable: false,
            floatingFilter: false, // только полное меню фильтра по клику на иконку (как на Учет ТС)
        },
        rowSelection: isAdmin ? {
            mode: 'multiRow',
            checkboxes: true,
            headerCheckbox: true,
            enableClickSelection: false,
        } : {
            mode: 'singleRow',
            enableClickSelection: false,
        },
        selectionColumnDef: isAdmin ? {
            pinned: 'left',
            width: 48,
            minWidth: 48,
            maxWidth: 48,
            resizable: false,
            sortable: false,
            filter: false,
            suppressHeaderMenuButton: true,
            headerTooltip: 'Выбор заявок для удаления',
        } : undefined,
        pagination: true,
        paginationPageSize: 20,
        paginationPageSizeSelector: [10, 20, 50, 100],
        domLayout: 'normal',
        suppressCellFocus: true,
        enableCellTextSelection: false,

        // Локализация
        localeText: {
            page: 'Страница',
            to: 'до',
            of: 'из',
            next: 'Следующая',
            last: 'Последняя',
            first: 'Первая',
            previous: 'Предыдущая',
            loadingOoo: 'Загрузка…',
            noRowsToShow: 'Заявок пока нет. Нажмите «Создать заявку», чтобы добавить первую.',
            filterOoo: 'Фильтр…',
            pageSizeSelectorLabel: 'Строк на странице:',
        },
        
        // Обработчики событий
        onGridReady: onGridReady,
        onFirstDataRendered: function() {
            fitTasksGridColumns();
            if (gridApi && typeof gridApi.resetRowHeights === 'function') {
                gridApi.resetRowHeights();
            }
            cleanupExecutorSelect2InGrid();
        },
        onModelUpdated: cleanupExecutorSelect2InGrid,
        onCellValueChanged: onCellValueChanged,
        // Добавляем обработчик изменения размера страницы для автоматической подстройки высоты
        onPaginationChanged: onPaginationChanged,
        onDisplayedColumnsChanged: function() {
            if (gridApi && typeof gridApi.resetRowHeights === 'function') {
                gridApi.resetRowHeights();
            }
        },
        onColumnResized: function(event) {
            if (event && event.finished && gridApi && typeof gridApi.resetRowHeights === 'function') {
                gridApi.resetRowHeights();
            }
        },
        onGridSizeChanged: function() {
            if (gridApi && typeof gridApi.resetRowHeights === 'function') {
                gridApi.resetRowHeights();
            }
        },
        onSelectionChanged: isAdmin ? function() {
            syncTasksDeleteButton();
        } : undefined,

        // Высота строки: по максимальному контенту видимых столбцов
        getRowHeight: function(params) {
            const lines = Math.max(1, Math.min(8, getTasksRowDisplayLines(params)));
            const base = Math.min(132, 24 + lines * 14);
            return Math.max(base, getTasksExecutorRowMinHeight(params));
        },
    };
    
    // Создание AG Grid
    try {
        console.log('AG Grid: Создание таблицы с опциями:', gridOptions);
        var createGrid = window.iasCreateGrid || (window.AgGridFilter && window.AgGridFilter.iasCreateGrid);
        gridApi = (typeof createGrid === 'function' ? createGrid : agGrid.createGrid.bind(agGrid))(gridDiv, gridOptions);
        window.tasksGridApi = gridApi;
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

/** Бейдж статуса заявки в таблице */
function renderTaskStatusBadge(statusCode, statusName) {
    const code = statusCode || '';
    const name = statusName || '—';
    const map = {
        new: 'tasks-status-pill--new',
        executor_assigned: 'tasks-status-pill--assigned',
        in_progress: 'tasks-status-pill--progress',
        on_hold: 'tasks-status-pill--hold',
        resolved: 'tasks-status-pill--done',
        closed: 'tasks-status-pill--done',
        cancelled: 'tasks-status-pill--cancelled',
    };
    const cls = map[code] || 'tasks-status-pill--default';
    return '<span class="tasks-status-pill ' + cls + '">' + escapeHtml(name) + '</span>';
}

function escapeHtml(text) {
    if (text == null) {
        return '';
    }
    return String(text)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;');
}

function getTaskViewUrl(id) {
    return '/index.php?r=tasks/view&id=' + encodeURIComponent(id);
}

function renderTaskIdLink(id) {
    return '<a class="tasks-grid-link" href="' + getTaskViewUrl(id) + '">#' + id + '</a>';
}

function renderTaskDescriptionLink(id, text) {
    const value = text != null ? String(text) : '';
    if (!id) {
        return escapeHtml(value);
    }
    return '<a class="tasks-grid-link tasks-grid-link--description" href="' + getTaskViewUrl(id) + '"'
        + ' title="Открыть заявку">' + escapeHtml(value) + '</a>';
}

/** Ячейка «Исполнитель»: выбор только руководителем, пока исполнитель не назначен. */
function renderExecutorCell(params) {
    if (!params.data) {
        return '';
    }

    const executorId = params.data.executor_id;
    const executorName = params.data.executor_name || '';
    const canAssign = (window.canAssignTaskExecutor === true || window.canAssignTaskExecutor === 'true')
        && !executorId;

    if (!canAssign) {
        if (executorName) {
            return '<span class="tasks-executor-readonly" title="Изменение — в разделе «Задачи»">'
                + escapeHtml(executorName) + '</span>';
        }

        return '<span class="tasks-grid-empty">Не назначен</span>';
    }

    return '<div class="tasks-executor-select-wrap">'
        + '<select class="form-select form-select-sm executor-change-ag executor-change-ag--grid"'
        + ' data-task-id="' + params.data.id + '"'
        + ' aria-label="Назначить исполнителя">'
        + buildExecutorOptionsHtml('', '')
        + '</select></div>';
}

/** HTML опций исполнителя (только техподдержка + текущий, если уже назначен). */
function buildExecutorOptionsHtml(selectedId, currentName) {
    let html = '<option value="">Не назначен</option>';
    const selected = selectedId ? String(selectedId) : '';

    if (selected && !allUsers[selected] && currentName) {
        html += '<option value="' + escapeHtml(selected) + '" selected>'
            + escapeHtml(currentName) + '</option>';
    }

    Object.entries(allUsers).forEach(function(entry) {
        const id = entry[0];
        const name = entry[1];
        const isSelected = selected && id === selected;
        html += '<option value="' + escapeHtml(id) + '"' + (isSelected ? ' selected' : '') + '>'
            + escapeHtml(name) + '</option>';
    });

    return html;
}

/** Подбор ширины столбцов по содержимому (кроме flex-колонок). */
function fitTasksGridColumns() {
    if (!gridApi || typeof gridApi.getColumns !== 'function') {
        return;
    }

    const flexFields = ['description', 'comment'];
    const colIds = [];

    gridApi.getColumns().forEach(function(col) {
        const def = col.getColDef();
        const field = def.field || col.getColId();
        if (def.flex || flexFields.indexOf(field) >= 0) {
            return;
        }
        colIds.push(col.getColId());
    });

    if (!colIds.length) {
        return;
    }

    if (typeof gridApi.autoSizeColumns === 'function') {
        gridApi.autoSizeColumns(colIds, false);
    } else if (typeof gridApi.autoSizeAllColumns === 'function') {
        gridApi.autoSizeAllColumns(false);
    }
}

function estimateTasksCellLines(text, colWidth) {
    const value = text == null ? '' : String(text).trim();
    if (!value) return 1;
    const width = Math.max(56, Number(colWidth || 120) - 20);
    if (window.AgGridWrap && typeof window.AgGridWrap.estimateLines === 'function') {
        return Math.max(1, window.AgGridWrap.estimateLines(value, width));
    }
    return Math.max(1, Math.ceil(value.length / 22));
}

function getTasksCellText(data, colId, colDef) {
    if (!data || !colId) return '';
    if (colId === 'ag-Grid-SelectionColumn' || colId === 'attachments') return '';
    if (colId === 'id') return data.id != null ? String(data.id) : '';
    const field = (colDef && colDef.field) ? colDef.field : colId;
    const value = data[field];
    if (value == null) return '';
    if (Array.isArray(value)) {
        return value.map(function(v) { return v == null ? '' : String(v); }).join(' ');
    }
    return String(value);
}

function getTasksRowDisplayLines(params) {
    if (!params || !params.data || !params.api || typeof params.api.getAllDisplayedColumns !== 'function') {
        return 1;
    }
    const cols = params.api.getAllDisplayedColumns() || [];
    let maxLines = 1;
    cols.forEach(function(col) {
        if (!col || typeof col.getColId !== 'function') return;
        const colId = col.getColId();
        if (!colId || colId === 'ag-Grid-SelectionColumn') return;
        const colDef = typeof col.getColDef === 'function' ? (col.getColDef() || {}) : {};
        if (colDef.field === 'executor_name') {
            return;
        }
        const text = getTasksCellText(params.data, colId, colDef);
        const width = typeof col.getActualWidth === 'function' ? col.getActualWidth() : 120;
        maxLines = Math.max(maxLines, estimateTasksCellLines(text, width));
    });
    return maxLines;
}

/** Минимальная высота строки под селект исполнителя (Select2). */
function getTasksExecutorRowMinHeight(params) {
    if (!isAdmin || !params || !params.data) {
        return 0;
    }
    const canAssign = (window.canAssignTaskExecutor === true || window.canAssignTaskExecutor === 'true')
        && !params.data.executor_id;
    return canAssign ? 40 : 0;
}

/**
 * Определение колонок таблицы
 */
function getColumnDefinitions() {
    const columns = [];

    if (isAdmin) {
        columns.push({
            headerName: 'ID',
            field: 'id',
            minWidth: 64,
            maxWidth: 96,
            pinned: 'left',
            filter: 'agNumberColumnFilter',
            cellRenderer: function(params) {
                if (!params.data || !params.data.id) {
                    return '';
                }
                return renderTaskIdLink(params.data.id);
            },
        });
    }

    columns.push({
        headerName: 'Описание',
        field: 'description',
        flex: 1,
        minWidth: 200,
        filter: 'agTextColumnFilter',
        wrapText: true,
        cellClass: 'ag-cell-description-wrap',
        cellRenderer: function(params) {
            if (!params.data || !params.data.id) {
                return params.value != null ? escapeHtml(String(params.value)) : '';
            }
            return renderTaskDescriptionLink(params.data.id, params.value);
        },
        tooltipField: 'description',
    });
    
    columns.push({
        headerName: 'Статус',
        field: 'status_name',
        minWidth: 120,
        maxWidth: 200,
        filter: 'agTextColumnFilter',
        wrapText: false,
        cellRenderer: function(params) {
            if (!params.data) {
                return '';
            }
            return renderTaskStatusBadge(params.data.status_code, params.value);
        },
    });
    
    // Автор
    columns.push({
        headerName: 'Автор',
        field: 'user_name',
        minWidth: 100,
        maxWidth: 220,
        filter: 'agTextColumnFilter',
    });
    
    // Исполнитель
    if (isAdmin) {
        columns.push({
            headerName: 'Исполнитель',
            field: 'executor_name',
            flex: 1,
            minWidth: 200,
            maxWidth: 420,
            filter: 'agTextColumnFilter',
            wrapText: false,
            cellRenderer: renderExecutorCell,
            cellClass: 'tasks-executor-cell',
        });
    } else {
        columns.push({
            headerName: 'Исполнитель',
            field: 'executor_name',
            minWidth: 100,
            maxWidth: 220,
            filter: 'agTextColumnFilter',
            wrapText: false,
            cellRenderer: renderExecutorCell,
            cellClass: 'tasks-executor-cell',
        });
    }
    
    // Дата создания
    columns.push({
        headerName: 'Создана',
        field: 'date',
        minWidth: 128,
        maxWidth: 150,
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
        minWidth: 128,
        maxWidth: 150,
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
        minWidth: 88,
        maxWidth: 110,
        filter: false,
        wrapText: false,
        valueFormatter: function(params) {
            const attachments = params.value || [];
            return attachments.length > 0 ? `${attachments.length}` : '-';
        },
        cellRenderer: function(params) {
            const attachments = params.value || [];
            if (attachments.length === 0) {
                return '<span class="tasks-grid-empty">—</span>';
            }
            
            let html = '<div class="tasks-attachments-cell">';
            attachments.forEach(attachment => {
                const iconClass = attachment.icon;
                if (attachment.is_previewable) {
                    html += `<a href="javascript:void(0);" 
                        class="tasks-attachment-chip tasks-attachment-chip--preview" 
                        title="${escapeHtml(attachment.name)}" 
                        data-ag-attachment-id="${attachment.id}"
                        data-ag-filename="${escapeHtml(attachment.name)}"
                        data-ag-preview-url="${attachment.preview_url}">
                        <i class="fa ${iconClass}" aria-hidden="true"></i>
                    </a>`;
                } else {
                    html += `<a href="${attachment.download_url}" 
                        class="tasks-attachment-chip tasks-attachment-chip--file" 
                        title="${escapeHtml(attachment.name)}">
                        <i class="fa ${iconClass}" aria-hidden="true"></i>
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
            minWidth: 140,
            maxWidth: 320,
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
            minWidth: 120,
            maxWidth: 280,
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
/** В гриде — только нативный select; снять Select2, если остался от прошлой инициализации. */
function cleanupExecutorSelect2InGrid() {
    var container = document.getElementById('agGridTasksContainer');
    if (!container || !window.jQuery) {
        return;
    }
    window.jQuery(container).find('select.executor-change-ag--grid.select2-hidden-accessible').each(function() {
        window.jQuery(this).select2('destroy');
    });
}

/**
 * Обработчик готовности сетки
 */
function onGridReady(params) {
    loadGridData();
    setupEventHandlers();
    adjustGridHeight();
    syncTasksDeleteButton();
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
    
    const dataUrl = typeof window.buildTasksDataUrl === 'function'
        ? window.buildTasksDataUrl()
        : (window.agGridDataUrl || '/index.php?r=tasks/get-grid-data');
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
                syncTasksDeleteButton();
                setTimeout(function() {
                    fitTasksGridColumns();
                    if (typeof gridApi.sizeColumnsToFit === 'function') {
                        gridApi.sizeColumnsToFit();
                    }
                    if (gridApi && typeof gridApi.resetRowHeights === 'function') {
                        gridApi.resetRowHeights();
                    }
                    cleanupExecutorSelect2InGrid();
                }, 0);
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
    
    document.addEventListener('change', function(e) {
        if (e.target.classList.contains('executor-change-ag')) {
            const taskId = e.target.dataset.taskId;
            const executorId = e.target.value;
            if (!executorId) {
                return;
            }
            assignExecutor(taskId, executorId);
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
 * Назначение исполнителя
 */
function assignExecutor(taskId, executorId) {
    const formData = new FormData();
    formData.append('executor_id', executorId);
    formData.append('_csrf', getCsrfToken());

    const url = `/index.php?r=tasks/assign-executor&id=${taskId}`;
    fetch(url, {
        method: 'POST',
        body: formData,
    })
        .then(function(response) { return response.json(); })
        .then(function(data) {
            if (data && data.success) {
                if (typeof window.showNotification === 'function') {
                    window.showNotification('success', data.message || 'Исполнитель назначен.');
                }
                loadGridData();
            } else {
                const msg = (data && data.message) || 'Не удалось назначить исполнителя.';
                if (typeof window.showNotification === 'function') {
                    window.showNotification('error', msg);
                } else {
                    alert(msg);
                }
                loadGridData();
            }
        })
        .catch(function(error) {
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

window.loadGridData = loadGridData;

const TASKS_MIN_SELECTED_FOR_DELETE = window.tasksMinSelectedForDelete || 1;

function getSelectedTaskRows() {
    if (!gridApi || typeof gridApi.getSelectedRows !== 'function') {
        return [];
    }
    return gridApi.getSelectedRows().filter(function(row) {
        return row && row.id;
    });
}

function syncTasksDeleteButton() {
    const btn = document.getElementById('btnTasksBulkDelete');
    if (!btn) {
        return;
    }
    const count = getSelectedTaskRows().length;
    const enabled = count >= TASKS_MIN_SELECTED_FOR_DELETE;
    btn.disabled = !enabled;
    const label = btn.querySelector('span');
    if (label) {
        label.textContent = enabled ? ('Удалить (' + count + ')') : 'Удалить';
    }
    btn.title = enabled
        ? 'Удалить выбранные заявки (' + count + ')'
        : 'Отметьте заявки чекбоксами';
}

function bulkDeleteSelectedTasks() {
    const rows = getSelectedTaskRows();
    if (rows.length < TASKS_MIN_SELECTED_FOR_DELETE) {
        return;
    }

    const countLabel = rows.length === 1 ? '1 заявку' : rows.length + ' заявок';
    if (!confirm('Удалить ' + countLabel + '? Это действие нельзя отменить.')) {
        return;
    }

    const btn = document.getElementById('btnTasksBulkDelete');
    if (btn) {
        btn.disabled = true;
    }

    const formData = new FormData();
    rows.forEach(function(row) {
        formData.append('ids[]', row.id);
    });
    formData.append('_csrf', getCsrfToken());

    const url = window.tasksBulkDeleteUrl || '/index.php?r=tasks/bulk-delete';
    fetch(url, { method: 'POST', body: formData })
        .then(function(response) { return response.json(); })
        .then(function(data) {
            if (data && data.success) {
                if (typeof window.showNotification === 'function') {
                    window.showNotification('success', data.message || 'Заявки удалены.');
                } else {
                    alert(data.message || 'Заявки удалены.');
                }
                if (gridApi && typeof gridApi.deselectAll === 'function') {
                    gridApi.deselectAll();
                }
                loadGridData();
            } else {
                const msg = (data && data.message) || 'Не удалось удалить заявки.';
                if (typeof window.showNotification === 'function') {
                    window.showNotification('error', msg);
                } else {
                    alert(msg);
                }
            }
        })
        .catch(function(error) {
            console.error('Ошибка массового удаления:', error);
            alert('Ошибка соединения с сервером');
        })
        .finally(function() {
            syncTasksDeleteButton();
        });
}

window.bulkDeleteSelectedTasks = bulkDeleteSelectedTasks;
window.syncTasksDeleteButton = syncTasksDeleteButton;

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
            if (typeof window.tasksCreateFormInit === 'function') {
                window.tasksCreateFormInit();
            }
            initTaskFormSubmit();
        },
        error: function(xhr, status, error) {
            $('#createTaskModalBody').html(
                '<div class="alert alert-danger">' +
                '<i class="fas fa-circle-exclamation"></i> ' +
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
        $submitBtn.html('<i class="fas fa-spinner fa-spin" aria-hidden="true"></i> Отправка…');
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
    if (typeof window.IASNotify === 'function') {
        window.IASNotify(message, type === 'error' ? 'danger' : type);
        return;
    }
    console.log((type || 'info') + ': ' + message);
}

/**
 * Очищает форму и модальное окно при закрытии
 */
const modalElement = document.getElementById('createTaskModal');
if (modalElement) {
    modalElement.addEventListener('hidden.bs.modal', function () {
        $('#createTaskModalBody').html(
            '<div class="tasks-create-modal__loading">' +
            '<i class="fas fa-spinner fa-spin" aria-hidden="true"></i>' +
            '<p>Загрузка формы…</p>' +
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
