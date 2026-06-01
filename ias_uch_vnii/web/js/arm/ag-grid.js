/**
 * AG Grid для страницы «Учет ТС».
 * Колонки в порядке Основного учёта; данные из arm/get-grid-data.
 * Вкладки по типам техники, модальное «Переместить/Переназначить», пагинация «все», русская локаль.
 */
(function() {
    'use strict';

    let gridApi;
    let armQuickSearchText = '';
    let armQuickFilterTimer = null;
    let currentPageSize = Number(window.agGridArmDefaultLimit || 20) || 20;
    const ARM_CLIENT_DATA_LIMIT = 5000;
    const ARM_COLUMNS_STORAGE_PREFIX = 'arm-columns:v4:';
    let armFitColumnsTimer = null;
    /** Не сбрасывать ширину после ручного изменения столбца мышью. */
    let armSuppressFitUntil = 0;

    function shouldSkipFitArmColumns() {
        return Date.now() < armSuppressFitUntil;
    }

    function markArmColumnUserResize() {
        armSuppressFitUntil = Date.now() + 2500;
    }

    function scheduleArmGridRowHeights() {
        if (window.AgGridWrap && gridApi) {
            window.AgGridWrap.scheduleResetRowHeights(gridApi);
        }
    }

    /** Высота строки: база и шаг — в CSS (#agGridArmContainer, --arm-grid-row-*). */
    function getArmGridRowHeight(lines) {
        var el = document.getElementById('agGridArmContainer');
        var style = el ? getComputedStyle(el) : null;
        var base = style ? parseFloat(style.getPropertyValue('--arm-grid-row-base')) : NaN;
        var step = style ? parseFloat(style.getPropertyValue('--arm-grid-row-step')) : NaN;
        var max = style ? parseFloat(style.getPropertyValue('--arm-grid-row-max')) : NaN;
        if (!Number.isFinite(base)) {
            base = 18;
        }
        if (!Number.isFinite(step)) {
            step = 12;
        }
        if (!Number.isFinite(max)) {
            max = 84;
        }
        var n = Math.max(1, Math.min(6, lines || 1));
        return Math.min(max, base + n * step);
    }

    /** Подгонка ширины видимых колонок под область таблицы. */
    function scheduleFitArmColumns(force) {
        clearTimeout(armFitColumnsTimer);
        armFitColumnsTimer = setTimeout(function() {
            if (!force && shouldSkipFitArmColumns()) {
                return;
            }
            if (!gridApi || typeof gridApi.sizeColumnsToFit !== 'function') {
                return;
            }
            var container = document.getElementById('agGridArmContainer');
            if (!container || container.clientWidth < 80) {
                return;
            }
            try {
                gridApi.sizeColumnsToFit();
            } catch (e) {
                console.warn('AG Grid (Учет ТС): sizeColumnsToFit', e);
            }
            scheduleArmGridRowHeights();
        }, 50);
    }

    const COLUMN_PRESETS = {
        /** Вся техника */
        all: ['user_name', 'location_name', 'cpu', 'ram', 'disk', 'system_block', 'inventory_number', 'purchase_date', 'monitor', 'ups', 'hostname', 'ip', 'os', 'other_tech'],
        /** Устаревшие типы «АРМ»/«ПК» — как системный блок */
        arm: ['user_name', 'location_name', 'cpu', 'ram', 'disk', 'system_block', 'inventory_number', 'purchase_date', 'monitor', 'ups', 'hostname', 'ip', 'os'],
        /** Вкладка «Системные блоки» */
        systemBlock: ['user_name', 'location_name', 'cpu', 'ram', 'disk', 'system_block', 'inventory_number', 'purchase_date', 'monitor', 'ups', 'hostname', 'ip', 'os'],
        /** Ноутбуки: конфигурация и сеть; без колонок «Монитор» и «ИБП» */
        laptop: ['user_name', 'location_name', 'cpu', 'ram', 'disk', 'system_block', 'inventory_number', 'purchase_date', 'screen_diagonal', 'hostname', 'ip', 'os'],
        /** Моноблоки: встроенный экран — без колонки «Монитор» и «ИБП» */
        monoblock: ['user_name', 'location_name', 'cpu', 'ram', 'disk', 'system_block', 'inventory_number', 'purchase_date', 'screen_diagonal', 'hostname', 'ip', 'os'],
        /** Прочие хосты (сервер и т.п.) */
        host: ['user_name', 'location_name', 'cpu', 'ram', 'disk', 'system_block', 'inventory_number', 'purchase_date', 'monitor', 'hostname', 'ip', 'os'],
        monitor: ['user_name', 'location_name', 'system_block', 'inventory_number', 'purchase_date', 'screen_diagonal'],
        upsType: ['user_name', 'location_name', 'system_block', 'inventory_number', 'purchase_date'],
        print: ['user_name', 'location_name', 'system_block', 'inventory_number', 'purchase_date', 'cartridge_procurement', 'ip', 'other_tech'],
        /** Сканеры — без «Закупка картриджей» */
        scanner: ['user_name', 'location_name', 'system_block', 'inventory_number', 'purchase_date', 'ip', 'other_tech'],
        /** Остальные вкладки — без колонки «ИБП» */
        generic: ['user_name', 'location_name', 'system_block', 'inventory_number', 'purchase_date'],
    };

    function buildCardViewLink(id, innerHtml, extraClass, title) {
        var cls = 'arm-link-to-card';
        if (extraClass) {
            cls += ' ' + extraClass;
        }
        var tit = title ? ' title="' + escapeHtml(title) + '"' : '';
        return '<a href="#" class="' + cls + '" data-arm-view="' + encodeURIComponent(id) + '"' + tit + '>'
            + innerHtml + '</a>';
    }

    function formatLinkedItemLabel(item) {
        if (!item) {
            return '';
        }
        var name = String(item.name || '').trim();
        var inv = String(item.inventory_number || '').trim();
        return name || inv;
    }

    function formatMonitorItemLabel(item) {
        return formatLinkedItemLabel(item);
    }

    function formatUpsItemLabel(item) {
        return formatLinkedItemLabel(item);
    }

    function monitorLinkTitle(item) {
        var label = formatMonitorItemLabel(item);
        if (!label) {
            return 'Открыть карточку монитора';
        }
        return 'Открыть карточку монитора: ' + label;
    }

    function renderMonitorCell(params) {
        var data = params.data;
        if (!data) {
            return '';
        }
        var lines = [];
        var list = data.monitor_list;
        if (Array.isArray(list)) {
            list.forEach(function(m) {
                var label = formatMonitorItemLabel(m);
                if (!label) {
                    return;
                }
                if (m && m.id) {
                    lines.push(
                        buildCardViewLink(m.id, escapeHtml(label), 'arm-monitor-link', monitorLinkTitle(m))
                    );
                } else {
                    lines.push(escapeHtml(label));
                }
            });
        }
        if (!lines.length) {
            var charText = String(data.monitor_char || '').trim();
            var fallback = charText || String(params.value || '').trim();
            return fallback ? '<span class="arm-monitor-fallback">' + escapeHtml(fallback) + '</span>' : '';
        }
        return '<div class="arm-monitor-cell arm-cell-wrap">' + lines.join('<br>') + '</div>';
    }

    function countMonitorDisplayLines(data, params) {
        if (!data) {
            return 1;
        }
        var list = data.monitor_list;
        var wrap = window.AgGridWrap;
        var col = params && params.api && typeof params.api.getColumn === 'function'
            ? params.api.getColumn('monitor')
            : null;
        var colWidth = wrap && col ? wrap.getColumnWidth(col) : 120;

        if (Array.isArray(list) && list.length) {
            if (wrap && typeof wrap.estimateLines === 'function') {
                var total = 0;
                list.forEach(function(m) {
                    var label = formatMonitorItemLabel(m);
                    if (label) {
                        total += wrap.estimateLines(label, colWidth);
                    }
                });
                return Math.max(1, total);
            }
            return Math.max(1, list.length);
        }

        var fallback = String(data.monitor || '').trim();
        if (!fallback) {
            return 1;
        }
        if (wrap && typeof wrap.estimateLines === 'function') {
            return wrap.estimateLines(fallback, colWidth);
        }
        return Math.max(1, fallback.split(/,\s*/).length);
    }

    function upsLinkTitle(item) {
        var label = formatUpsItemLabel(item);
        if (!label) {
            return 'Открыть карточку ИБП';
        }
        return 'Открыть карточку ИБП: ' + label;
    }

    function renderUpsCell(params) {
        var data = params.data;
        if (!data) {
            return '';
        }
        var lines = [];
        var list = data.ups_list;
        if (Array.isArray(list)) {
            list.forEach(function(u) {
                var label = formatUpsItemLabel(u);
                if (!label) {
                    return;
                }
                if (u && u.id) {
                    lines.push(
                        buildCardViewLink(u.id, escapeHtml(label), 'arm-ups-link', upsLinkTitle(u))
                    );
                } else {
                    lines.push(escapeHtml(label));
                }
            });
        }
        if (!lines.length) {
            var fallback = String(data.ups || params.value || '').trim();
            return fallback ? '<span class="arm-ups-fallback">' + escapeHtml(fallback) + '</span>' : '';
        }
        return '<div class="arm-ups-cell arm-cell-wrap">' + lines.join('<br>') + '</div>';
    }

    function countUpsDisplayLines(data, params) {
        if (!data) {
            return 1;
        }
        var list = data.ups_list;
        var wrap = window.AgGridWrap;
        var col = params && params.api && typeof params.api.getColumn === 'function'
            ? params.api.getColumn('ups')
            : null;
        var colWidth = wrap && col ? wrap.getColumnWidth(col) : 120;

        if (Array.isArray(list) && list.length) {
            if (wrap && typeof wrap.estimateLines === 'function') {
                var total = 0;
                list.forEach(function(u) {
                    var label = formatUpsItemLabel(u);
                    if (label) {
                        total += wrap.estimateLines(label, colWidth);
                    }
                });
                return Math.max(1, total);
            }
            return Math.max(1, list.length);
        }

        var fallback = String(data.ups || '').trim();
        if (!fallback) {
            return 1;
        }
        if (wrap && typeof wrap.estimateLines === 'function') {
            return wrap.estimateLines(fallback, colWidth);
        }
        return Math.max(1, fallback.split(/,\s*/).length);
    }

    function splitDiskFallback(text) {
        return String(text || '')
            .split(/\s*[,;]\s*/)
            .map(function(s) { return s.trim(); })
            .filter(function(s) { return s !== ''; });
    }

    function countDiskDisplayLines(data, params) {
        if (!data) {
            return 1;
        }
        var wrap = window.AgGridWrap;
        var col = params && params.api && typeof params.api.getColumn === 'function'
            ? params.api.getColumn('disk')
            : null;
        var colWidth = wrap && col ? wrap.getColumnWidth(col) : 100;
        var list = data.disk_lines;

        if (Array.isArray(list) && list.length) {
            if (wrap && typeof wrap.estimateLines === 'function') {
                var total = 0;
                list.forEach(function(d) {
                    var label = String(d || '').trim();
                    if (label) {
                        total += wrap.estimateLines(label, colWidth);
                    }
                });
                return Math.max(1, total);
            }
            return Math.max(1, list.length);
        }

        var fallback = String(data.disk || '').trim();
        if (!fallback) {
            return 1;
        }
        if (wrap && typeof wrap.estimateLines === 'function') {
            return wrap.estimateLines(fallback, colWidth);
        }
        return Math.max(1, splitDiskFallback(fallback).length);
    }

    function countUserDisplayLines(data, params) {
        if (!data) {
            return 1;
        }
        var text = String(data.user_name || '').trim();
        if (!text) {
            return 1;
        }
        var wrap = window.AgGridWrap;
        var col = params && params.api && typeof params.api.getColumn === 'function'
            ? params.api.getColumn('user_name')
            : null;
        var colWidth = wrap && col ? wrap.getColumnWidth(col) : 140;
        if (wrap && typeof wrap.estimateLines === 'function') {
            return Math.max(1, wrap.estimateLines(text, colWidth));
        }
        return Math.max(1, text.split(/\s+/).length);
    }

    function countGenericDisplayLines(data, params, colId) {
        if (!data || !colId) {
            return 1;
        }
        var value = data[colId];
        if (value == null) {
            return 1;
        }
        var text = String(value).trim();
        if (!text) {
            return 1;
        }
        var wrap = window.AgGridWrap;
        var col = params && params.api && typeof params.api.getColumn === 'function'
            ? params.api.getColumn(colId)
            : null;
        var colWidth = wrap && col ? wrap.getColumnWidth(col) : 120;
        if (wrap && typeof wrap.estimateLines === 'function') {
            return Math.max(1, wrap.estimateLines(text, colWidth));
        }
        return Math.max(1, Math.ceil(text.length / 22));
    }

    function countLinesForColumn(data, params, colId) {
        switch (colId) {
            case 'user_name':
                return countUserDisplayLines(data, params);
            case 'monitor':
                return countMonitorDisplayLines(data, params);
            case 'ups':
                return countUpsDisplayLines(data, params);
            case 'disk':
                return countDiskDisplayLines(data, params);
            default:
                return countGenericDisplayLines(data, params, colId);
        }
    }

    function getRowDisplayLines(data, params) {
        if (!params || !params.api || typeof params.api.getAllDisplayedColumns !== 'function') {
            return Math.max(
                countUserDisplayLines(data, params),
                countMonitorDisplayLines(data, params),
                countUpsDisplayLines(data, params),
                countDiskDisplayLines(data, params)
            );
        }
        var displayed = params.api.getAllDisplayedColumns() || [];
        var maxLines = 1;
        displayed.forEach(function(col) {
            if (!col || typeof col.getColId !== 'function') {
                return;
            }
            var colId = col.getColId();
            if (!colId || colId === 'ag-Grid-SelectionColumn') {
                return;
            }
            maxLines = Math.max(maxLines, countLinesForColumn(data, params, colId));
        });
        return maxLines;
    }

    function renderDiskCell(params) {
        var data = params.data;
        if (!data) {
            return '';
        }
        var lines = [];
        var list = data.disk_lines;
        if (Array.isArray(list)) {
            list.forEach(function(d) {
                var label = String(d || '').trim();
                if (label) {
                    lines.push(escapeHtml(label));
                }
            });
        }
        if (!lines.length) {
            splitDiskFallback(params.value || data.disk).forEach(function(label) {
                lines.push(escapeHtml(label));
            });
        }
        if (!lines.length) {
            return '';
        }
        return '<div class="arm-disk-cell arm-cell-wrap">' + lines.join('<br>') + '</div>';
    }

    function getColumnDefs() {
        var defs = [
            {
                headerName: 'Пользователь',
                field: 'user_name',
                minWidth: 120,
                filter: 'agTextColumnFilter',
                wrapText: true,
                autoHeight: false,
                cellClass: 'ag-cell-wrap-text',
            },
            {
                headerName: 'Помещение',
                field: 'location_name',
                minWidth: 100,
                wrapHeaderText: false,
                filter: 'agTextColumnFilter',
            },
            {
                headerName: 'Статус',
                field: 'status_name',
                minWidth: 120,
                filter: 'agTextColumnFilter',
                cellRenderer: renderStatusCell,
            },
            { headerName: 'ЦП', field: 'cpu', minWidth: 90, filter: 'agTextColumnFilter' },
            { headerName: 'ОЗУ', field: 'ram', minWidth: 64, filter: 'agTextColumnFilter' },
            {
                headerName: 'Диск',
                field: 'disk',
                minWidth: 100,
                filter: 'agTextColumnFilter',
                cellRenderer: renderDiskCell,
                tooltipValueGetter: function(params) {
                    if (!params.data) {
                        return '';
                    }
                    var list = params.data.disk_lines;
                    if (Array.isArray(list) && list.length) {
                        return list.map(function(d) { return String(d || '').trim(); }).filter(Boolean).join('\n');
                    }
                    return splitDiskFallback(params.value || '').join('\n');
                },
            },
            {
                headerName: 'Тип/Название техники',
                field: 'system_block',
                minWidth: 140,
                filter: 'agTextColumnFilter',
                cellRenderer: function(params) {
                    if (!params.data || params.data.id == null) return params.value || '';
                    var text = params.value || '—';
                    return buildCardViewLink(params.data.id, escapeHtml(String(text)));
                },
                tooltipField: 'system_block',
            },
            {
                headerName: 'Инв. №',
                field: 'inventory_number',
                minWidth: 90,
                filter: 'agTextColumnFilter',
                cellRenderer: function(params) {
                    if (!params.data || params.data.id == null) return params.value || '';
                    var text = params.value || '—';
                    return buildCardViewLink(params.data.id, escapeHtml(String(text)), '', 'Открыть карточку актива');
                },
            },
            {
                headerName: 'Дата закупки',
                field: 'purchase_date',
                minWidth: 110,
                filter: 'agTextColumnFilter',
            },
            {
                headerName: 'Диагональ экрана',
                field: 'screen_diagonal',
                minWidth: 110,
                filter: 'agTextColumnFilter',
                tooltipField: 'screen_diagonal',
            },
            {
                headerName: 'Монитор',
                field: 'monitor',
                minWidth: 120,
                filter: 'agTextColumnFilter',
                cellRenderer: renderMonitorCell,
                tooltipValueGetter: function(params) {
                    if (!params.data) {
                        return '';
                    }
                    var list = params.data.monitor_list;
                    if (Array.isArray(list) && list.length) {
                        return list.map(function(m) { return formatMonitorItemLabel(m); }).filter(Boolean).join('\n');
                    }
                    return params.value || '';
                },
            },
            {
                headerName: 'ИБП',
                field: 'ups',
                minWidth: 120,
                filter: 'agTextColumnFilter',
                cellRenderer: renderUpsCell,
                tooltipValueGetter: function(params) {
                    if (!params.data) {
                        return '';
                    }
                    var list = params.data.ups_list;
                    if (Array.isArray(list) && list.length) {
                        return list.map(function(u) { return formatUpsItemLabel(u); }).filter(Boolean).join('\n');
                    }
                    return params.value || '';
                },
            },
            { headerName: 'Имя ПК', field: 'hostname', minWidth: 100, filter: 'agTextColumnFilter' },
            { headerName: 'IP адрес', field: 'ip', minWidth: 100, filter: 'agTextColumnFilter' },
            { headerName: 'ОС', field: 'os', minWidth: 90, filter: 'agTextColumnFilter' },
            {
                headerName: 'Закупка картриджей',
                field: 'cartridge_procurement',
                minWidth: 140,
                filter: 'agTextColumnFilter',
                tooltipField: 'cartridge_procurement',
            },
            { headerName: 'Комментарий', field: 'other_tech', minWidth: 140, filter: 'agTextColumnFilter', tooltipField: 'other_tech' },
        ];
        return defs;
    }

    function escapeHtml(str) {
        var div = document.createElement('div');
        div.textContent = str;
        return div.innerHTML;
    }

    function getStatusTone(data) {
        return (data && data.status_color) ? data.status_color : 'gray';
    }

    function renderStatusCell(params) {
        var text = params.value != null ? String(params.value).trim() : '';
        if (!text) {
            return '';
        }
        var tone = getStatusTone(params.data);
        return '<span class="arm-status-badge arm-status-badge--' + tone + '">' + escapeHtml(text) + '</span>';
    }

    var localeTextRu = {
        page: 'Страница', to: 'до', of: 'из', next: 'След.', last: 'Последняя',
        first: 'Первая', previous: 'Пред.', loadingOoo: 'Загрузка...',
        noRowsToShow: 'Нет данных', filterOoo: 'Фильтр...', pageSizeSelectorLabel: 'Строк:',
        applyFilter: 'Применить', resetFilter: 'Сбросить', clearFilter: 'Очистить',
        equals: 'Равно', notEqual: 'Не равно', contains: 'Содержит', notContains: 'Не содержит',
        startsWith: 'Начинается с', endsWith: 'Заканчивается на', blank: 'Пусто', notBlank: 'Не пусто',
        filterPlaceholder: 'Введите значение...', searchOoo: 'Поиск...',
        selectAll: 'Выбрать все', unselectAll: 'Снять выбор',
        pinned: 'Закреплено', pinLeft: 'Закрепить слева', pinRight: 'Закрепить справа', noPin: 'Снять закрепление',
        autosizeThisColumn: 'Автоширина этой колонки', autosizeAllColumns: 'Автоширина всех колонок',
        resetColumns: 'Сбросить колонки', expandAll: 'Развернуть все', collapseAll: 'Свернуть все',
        copy: 'Копировать', copyWithHeaders: 'Копировать с заголовками',
        paste: 'Вставить', export: 'Экспорт',
        columns: 'Колонки', pivotMode: 'Режим сводной таблицы',
    };

    var DEFAULT_GRID_SORT = [
        { colId: 'location_name', sort: 'asc' },
        { colId: 'user_name', sort: 'asc' },
    ];

    /** Сортировка по умолчанию только на сервере — без стрелок и цифр в заголовках до ручного клика. */
    function buildSortModelFromColumnState(api) {
        if (!api || typeof api.getColumnState !== 'function') {
            return DEFAULT_GRID_SORT.slice();
        }
        var state = (api.getColumnState() || []).filter(function(c) { return c && c.sort; });
        if (!state.length) {
            return DEFAULT_GRID_SORT.slice();
        }
        state.sort(function(a, b) {
            var ai = a.sortIndex != null ? a.sortIndex : 0;
            var bi = b.sortIndex != null ? b.sortIndex : 0;
            return ai - bi;
        });
        return state.map(function(c) {
            return { colId: c.colId, sort: c.sort };
        });
    }

    function getDataUrl(limit, offset, filterModel, sortModel) {
        const base = window.agGridArmDataUrl || '/index.php?r=arm/get-grid-data';
        const sep = base.indexOf('?') >= 0 ? '&' : '?';
        const query = ['limit=' + encodeURIComponent(limit), 'offset=' + encodeURIComponent(offset)];
        const typeId = (window.agGridArmCurrentTypeId || '').toString().trim();
        if (typeId) {
            query.push('equipment_type=' + encodeURIComponent(typeId));
        }
        if (filterModel && Object.keys(filterModel).length > 0) {
            query.push('filterModel=' + encodeURIComponent(JSON.stringify(filterModel)));
        }
        if (sortModel && Array.isArray(sortModel) && sortModel.length > 0) {
            query.push('sortModel=' + encodeURIComponent(JSON.stringify(sortModel)));
        }
        if (armQuickSearchText) {
            query.push('quickSearch=' + encodeURIComponent(armQuickSearchText));
        }
        if (window.agGridArmLocationScope) {
            query.push('location_scope=' + encodeURIComponent(window.agGridArmLocationScope));
        }
        return base + sep + query.join('&');
    }

    function initQuickFilter() {
        var input = document.getElementById('armQuickFilter');
        if (!input) {
            return;
        }
        input.addEventListener('input', function() {
            clearTimeout(armQuickFilterTimer);
            armQuickFilterTimer = setTimeout(function() {
                var next = input.value.trim();
                if (next === armQuickSearchText) {
                    return;
                }
                armQuickSearchText = next;
                loadGridData(true);
                if (typeof window.armUpdatePageChrome === 'function') {
                    window.armUpdatePageChrome();
                }
            }, 300);
        });
        input.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                input.value = '';
                if (armQuickSearchText !== '') {
                    armQuickSearchText = '';
                    loadGridData(true);
                }
                if (typeof window.armUpdatePageChrome === 'function') {
                    window.armUpdatePageChrome();
                }
            }
        });
    }

    function createDataSource() {
        return {
            getRows: function(params) {
                var startRow = params.startRow || 0;
                var endRow = params.endRow || (startRow + currentPageSize);
                var limit = Math.max(1, endRow - startRow);
                var offset = Math.max(0, startRow);

                var sortModel = buildSortModelFromColumnState(gridApi);
                fetch(getDataUrl(limit, offset, params.filterModel || {}, sortModel))
                    .then(function(r) { return r.ok ? r.json() : Promise.reject(new Error('HTTP ' + r.status)); })
                    .then(function(result) {
                        if (!result || !result.success || !Array.isArray(result.data)) {
                            return Promise.reject(new Error((result && result.message) || 'Invalid response'));
                        }
                        params.successCallback(result.data, Number(result.total || 0));
                        setTimeout(function() {
                            scheduleFitArmColumns();
                            scheduleArmGridRowHeights();
                            syncSelectionChrome();
                        }, 0);
                    })
                    .catch(function(err) {
                        console.error('AG Grid (Учет ТС): ошибка загрузки', err);
                        params.failCallback();
                        setTimeout(syncSelectionChrome, 0);
                    });
            }
        };
    }

    function loadGridData(resetToFirstPage) {
        if (!gridApi) {
            console.warn('loadGridData: gridApi не инициализирован');
            return;
        }
        try {
            gridApi.deselectAll();
        } catch (e) {}
        if (resetToFirstPage) {
            try {
                gridApi.paginationGoToFirstPage();
            } catch (e) {}
        }
        fetch(getDataUrl(ARM_CLIENT_DATA_LIMIT, 0, {}, []))
            .then(function(r) { return r.ok ? r.json() : Promise.reject(new Error('HTTP ' + r.status)); })
            .then(function(result) {
                if (!result || !result.success || !Array.isArray(result.data)) {
                    return Promise.reject(new Error((result && result.message) || 'Invalid response'));
                }
                gridApi.setGridOption('rowData', result.data);
                setTimeout(function() {
                    scheduleFitArmColumns();
                    scheduleArmGridRowHeights();
                    syncSelectionChrome();
                }, 0);
            })
            .catch(function(err) {
                console.error('AG Grid (Учет ТС): ошибка загрузки', err);
                gridApi.setGridOption('rowData', []);
                setTimeout(syncSelectionChrome, 0);
            });
        syncSelectionChrome();
    }

    function syncSelectionChrome() {
        if (typeof window.armUpdatePageChrome === 'function') {
            window.armUpdatePageChrome();
        }
    }

    function initTabs() {
        document.querySelectorAll('.arm-type-tab').forEach(function(tab) {
            tab.addEventListener('click', function(e) {
                e.preventDefault();
                document.querySelectorAll('.arm-type-tab').forEach(function(t) {
                    t.classList.remove('active');
                    t.setAttribute('aria-selected', 'false');
                });
                this.classList.add('active');
                this.setAttribute('aria-selected', 'true');
                window.agGridArmCurrentTypeId = this.getAttribute('data-type-id') || '';
                applyColumnsForCurrentType();
                loadGridData(true);
                if (typeof window.armUpdatePageChrome === 'function') {
                    window.armUpdatePageChrome();
                }
            });
        });
    }

    function getColumnsStorageKey(typeId) {
        var normalized = (typeId || 'all').toString().trim();
        if (!normalized) normalized = 'all';
        return ARM_COLUMNS_STORAGE_PREFIX + normalized;
    }

    function typeAllowsUpsColumn(typeId) {
        return getPresetColumns(typeId).indexOf('ups') >= 0;
    }

    function typeAllowsCartridgeColumn(typeId) {
        return getPresetColumns(typeId).indexOf('cartridge_procurement') >= 0;
    }

    function getPresetColumns(typeId) {
        var raw = (typeId || '').toString().trim().toLowerCase();
        if (!raw) {
            return COLUMN_PRESETS.all;
        }
        if (raw.indexOf('монитор') >= 0) {
            return COLUMN_PRESETS.monitor;
        }
        if (raw === 'арм' || raw === 'пк' || (raw.indexOf('систем') >= 0 && raw.indexOf('блок') >= 0)) {
            return COLUMN_PRESETS.systemBlock;
        }
        if (raw.indexOf('ноут') >= 0) {
            return COLUMN_PRESETS.laptop;
        }
        if (raw.indexOf('моноблок') >= 0) {
            return COLUMN_PRESETS.monoblock;
        }
        if (raw.indexOf('сервер') >= 0) {
            return COLUMN_PRESETS.host;
        }
        if (raw.indexOf('ибп') >= 0 || raw === 'ups') {
            return COLUMN_PRESETS.upsType;
        }
        if (raw.indexOf('скан') >= 0) {
            return COLUMN_PRESETS.scanner;
        }
        if (raw.indexOf('мфу') >= 0 || raw.indexOf('принтер') >= 0) {
            return COLUMN_PRESETS.print;
        }
        return COLUMN_PRESETS.generic;
    }

    function loadSavedColumnsByColId(typeId) {
        if (typeof window.localStorage === 'undefined') {
            return null;
        }
        try {
            var raw = window.localStorage.getItem(getColumnsStorageKey(typeId));
            if (!raw) {
                return null;
            }
            var parsed = JSON.parse(raw);
            if (!Array.isArray(parsed) || parsed.length === 0) {
                return null;
            }
            var map = {};
            parsed.forEach(function(item) {
                if (item && item.colId) {
                    map[item.colId] = !!item.hide;
                }
            });
            return Object.keys(map).length > 0 ? map : null;
        } catch (e) {
            return null;
        }
    }

    function buildColumnVisibilityState(typeId, forcePreset) {
        var allowed = getPresetColumns(typeId);
        var upsAllowed = typeAllowsUpsColumn(typeId);
        var cartridgeAllowed = typeAllowsCartridgeColumn(typeId);
        var savedByColId = forcePreset ? null : loadSavedColumnsByColId(typeId);
        var columns = gridApi.getColumns ? gridApi.getColumns() : [];
        var state = [];
        columns.forEach(function(col) {
            if (!col || !col.getColId || !col.getColDef) {
                return;
            }
            var def = col.getColDef() || {};
            var colId = col.getColId();
            if (!colId || !def.field) {
                return;
            }
            var hide;
            if (colId === 'ups' && !upsAllowed) {
                hide = true;
            } else if (colId === 'cartridge_procurement' && !cartridgeAllowed) {
                hide = true;
            } else if (savedByColId && Object.prototype.hasOwnProperty.call(savedByColId, colId)) {
                hide = savedByColId[colId];
            } else {
                hide = allowed.indexOf(colId) === -1;
            }
            state.push({ colId: colId, hide: hide });
        });
        return state;
    }

    function saveCurrentColumnsStateForType(typeId) {
        if (!gridApi || typeof window.localStorage === 'undefined') return;
        var upsAllowed = typeAllowsUpsColumn(typeId);
        var cartridgeAllowed = typeAllowsCartridgeColumn(typeId);
        var columns = gridApi.getColumns ? gridApi.getColumns() : [];
        var state = [];
        columns.forEach(function(col) {
            if (!col || !col.getColId || !col.getColDef) return;
            var def = col.getColDef() || {};
            var colId = col.getColId();
            if (!colId || !def.field) return;
            var visible = col.isVisible ? col.isVisible() : true;
            if (colId === 'ups' && !upsAllowed) {
                visible = false;
            }
            if (colId === 'cartridge_procurement' && !cartridgeAllowed) {
                visible = false;
            }
            state.push({ colId: colId, hide: !visible });
        });
        window.localStorage.setItem(getColumnsStorageKey(typeId), JSON.stringify(state));
    }

    function applyColumnsForCurrentType(forcePreset) {
        if (!gridApi || !gridApi.applyColumnState) return;
        var typeId = (window.agGridArmCurrentTypeId || '').toString().trim();
        var state = buildColumnVisibilityState(typeId, !!forcePreset);
        if (state.length === 0) {
            return;
        }
        gridApi.applyColumnState({ state: state, applyOrder: false });
        armSuppressFitUntil = 0;
        scheduleFitArmColumns(true);
        scheduleArmGridRowHeights();
    }

    function initActions() {
        var exportBtn = document.getElementById('btnArmExportXlsx');
        if (exportBtn) {
            exportBtn.addEventListener('click', function() {
                var url = window.agGridArmExportUrl || '/index.php?r=arm/export-xlsx';
                var query = [];
                query.push('export_scope=' + encodeURIComponent('visible'));
                if (window.agGridArmLocationScope) {
                    query.push('location_scope=' + encodeURIComponent(window.agGridArmLocationScope));
                }
                var selectedRows = gridApi ? gridApi.getSelectedRows() : [];
                if (selectedRows.length > 0) {
                    var ids = selectedRows
                        .map(function(r) { return r && r.id != null ? String(r.id) : ''; })
                        .filter(function(v) { return v !== ''; });
                    if (ids.length > 0) {
                        query.push('ids=' + encodeURIComponent(ids.join(',')));
                    }
                }
                var typeId = (window.agGridArmCurrentTypeId || '').toString().trim();
                if (typeId) {
                    query.push('equipment_type=' + encodeURIComponent(typeId));
                }
                if (gridApi && typeof gridApi.getAllDisplayedColumns === 'function') {
                    var cols = gridApi.getAllDisplayedColumns()
                        .map(function(col) { return col && typeof col.getColId === 'function' ? col.getColId() : ''; })
                        .filter(function(v) { return v !== ''; });
                    if (cols.length > 0) {
                        query.push('cols=' + encodeURIComponent(cols.join(',')));
                    }
                }
                if (gridApi && typeof gridApi.getFilterModel === 'function') {
                    var fm = gridApi.getFilterModel();
                    if (fm && Object.keys(fm).length > 0) {
                        query.push('filterModel=' + encodeURIComponent(JSON.stringify(fm)));
                    }
                }
                var sm = buildSortModelFromColumnState(gridApi);
                if (sm.length > 0) {
                    query.push('sortModel=' + encodeURIComponent(JSON.stringify(sm)));
                }
                if (armQuickSearchText) {
                    query.push('quickSearch=' + encodeURIComponent(armQuickSearchText));
                }
                if (query.length > 0) {
                    url += '&' + query.join('&');
                }
                window.location.href = url;
            });
        }
        var templateBtn = document.getElementById('btnArmTemplateXlsx');
        if (templateBtn) {
            templateBtn.addEventListener('click', function() {
                window.location.href = '/index.php?r=arm/import-template-xlsx';
            });
        }
        var importBtn = document.getElementById('btnArmImportXlsx');
        var importInput = document.getElementById('armImportFileInput');
        if (importBtn && importInput) {
            importBtn.addEventListener('click', function() {
                importInput.click();
            });
            importInput.addEventListener('change', function() {
                if (!importInput.files || !importInput.files.length) return;
                var fd = new FormData();
                fd.append(window.armReassignCsrf.param, window.armReassignCsrf.token);
                fd.append('import_file', importInput.files[0]);
                fetch(window.agGridArmImportPreviewUrl, { method: 'POST', body: fd })
                    .then(function(r){ return r.ok ? r.json() : Promise.reject(new Error('HTTP ' + r.status)); })
                    .then(function(res){
                        if (!res.success) throw new Error(res.message || 'Preview failed');
                        var valid = (res.rows || []).length;
                        var errors = (res.errors || []).length;
                        var ok = window.confirm('Предпросмотр импорта:\\nВалидных строк: ' + valid + '\\nОшибок: ' + errors + '\\nВыполнить импорт валидных строк?');
                        if (!ok || !valid) return;
                        var fdApply = new FormData();
                        fdApply.append(window.armReassignCsrf.param, window.armReassignCsrf.token);
                        fdApply.append('rows', JSON.stringify(res.rows));
                        return fetch(window.agGridArmImportApplyUrl, { method: 'POST', body: fdApply });
                    })
                    .then(function(r){
                        if (!r) return;
                        return r.ok ? r.json() : Promise.reject(new Error('HTTP ' + r.status));
                    })
                    .then(function(res){
                        if (!res) return;
                        if (res.success) {
                            alert('Импорт завершен. Загружено: ' + (res.imported || 0));
                            if (typeof window.refreshArmGrid === 'function') window.refreshArmGrid();
                        } else {
                            alert('Ошибка импорта: ' + (res.message || 'unknown'));
                        }
                    })
                    .catch(function(err){
                        alert('Ошибка импорта: ' + err.message);
                    })
                    .finally(function(){
                        importInput.value = '';
                    });
            });
        }
    }

    function initColumnSettings() {
        var btn = document.getElementById('btnArmColumns');
        var modalEl = document.getElementById('armColumnsModal');
        var listEl = document.getElementById('armColumnsList');
        var applyBtn = document.getElementById('armColumnsApply');
        var resetBtn = document.getElementById('armColumnsReset');
        if (!btn || !modalEl || !listEl || !applyBtn || !resetBtn) return;

        var modal = new bootstrap.Modal(modalEl);

        function renderColumnsList() {
            if (!gridApi) return;
            var typeId = (window.agGridArmCurrentTypeId || '').toString().trim();
            var upsAllowed = typeAllowsUpsColumn(typeId);
            var cartridgeAllowed = typeAllowsCartridgeColumn(typeId);
            var cols = gridApi.getColumns ? gridApi.getColumns() : [];
            var html = '';
            cols.forEach(function(col) {
                var def = col.getColDef ? col.getColDef() : {};
                var colId = col.getColId ? col.getColId() : def.field;
                var label = (def && def.headerName != null ? String(def.headerName) : '').trim();
                if (!colId || !def.field) return; // без поля — служебная колонка выбора
                var checked = col.isVisible ? col.isVisible() : true;
                var disabled = (colId === 'ups' && !upsAllowed)
                    || (colId === 'cartridge_procurement' && !cartridgeAllowed);
                if (disabled) {
                    checked = false;
                }
                html += '<div class="form-check mb-1">';
                html += '<input class="form-check-input arm-col-check" type="checkbox" id="arm-col-' + escapeHtml(colId) + '" data-col-id="' + escapeHtml(colId) + '"' +
                    (checked ? ' checked' : '') + (disabled ? ' disabled' : '') + '>';
                html += '<label class="form-check-label' + (disabled ? ' text-muted' : '') + '" for="arm-col-' + escapeHtml(colId) + '">' + escapeHtml(label) + '</label>';
                html += '</div>';
            });
            listEl.innerHTML = html || '<div class="text-muted">Нет настраиваемых колонок</div>';
        }

        btn.addEventListener('click', function() {
            renderColumnsList();
            modal.show();
        });

        applyBtn.addEventListener('click', function() {
            if (!gridApi) return;
            var typeId = (window.agGridArmCurrentTypeId || '').toString().trim();
            var saved = loadSavedColumnsByColId(typeId) || {};
            var checks = listEl.querySelectorAll('.arm-col-check');
            checks.forEach(function(ch) {
                var colId = ch.getAttribute('data-col-id');
                if (!colId) return;
                saved[colId] = !ch.checked;
            });
            if (!typeAllowsUpsColumn(typeId)) {
                saved.ups = true;
            }
            if (!typeAllowsCartridgeColumn(typeId)) {
                saved.cartridge_procurement = true;
            }
            if (typeof window.localStorage !== 'undefined') {
                var toStore = Object.keys(saved).map(function(colId) {
                    return { colId: colId, hide: saved[colId] };
                });
                window.localStorage.setItem(getColumnsStorageKey(typeId), JSON.stringify(toStore));
            }
            applyColumnsForCurrentType(false);
            modal.hide();
        });

        resetBtn.addEventListener('click', function() {
            if (typeof window.localStorage !== 'undefined') {
                window.localStorage.removeItem(getColumnsStorageKey(window.agGridArmCurrentTypeId));
            }
            applyColumnsForCurrentType(true);
            renderColumnsList();
        });
    }

    function init() {
        var container = document.getElementById('agGridArmContainer');
        if (container) {
            container.classList.remove('arm-grid-loading');
        }
        if (!container || typeof agGrid === 'undefined') {
            if (container) container.innerHTML = '<p class="text-muted">Загрузка таблицы...</p>';
            return;
        }
        container.innerHTML = '';
        var gridOpts = {
            columnDefs: getColumnDefs(),
            theme: 'legacy',
            animateRows: true,
            defaultColDef: (window.AgGridWrap && window.AgGridWrap.mergeDefaultColDef)
                ? window.AgGridWrap.mergeDefaultColDef({
                    sortable: true,
                    filter: true,
                    resizable: true,
                    wrapText: true,
                    autoHeight: false,
                    cellClass: 'ag-cell-wrap-text',
                }, true)
                : {
                    sortable: true,
                    filter: true,
                    resizable: true,
                    wrapText: true,
                    autoHeight: false,
                    cellClass: 'ag-cell-wrap-text',
                },
            suppressHorizontalScroll: false,
            alwaysShowHorizontalScroll: true,
            alwaysShowVerticalScroll: true,
            scrollbarWidth: 12,
            rowData: [],
            rowSelection: {
                mode: 'multiRow',
                checkboxes: true,
                headerCheckbox: false,
                enableClickSelection: false,
            },
            selectionColumnDef: {
                pinned: 'left',
                width: 48,
                minWidth: 48,
                maxWidth: 48,
                resizable: false,
                sortable: false,
                filter: false,
                suppressHeaderMenuButton: true,
                headerTooltip: 'Выбор строк для перемещения и переназначения',
            },
            suppressCellFocus: true,
            pagination: true,
            paginationPageSize: currentPageSize,
            paginationPageSizeSelector: [10, 20, 50, 100, 200],
            domLayout: 'normal',
            getRowId: function(params) {
                if (!params || !params.data || params.data.id == null) {
                    return undefined;
                }
                return String(params.data.id);
            },
            getRowHeight: function(params) {
                return getArmGridRowHeight(getRowDisplayLines(params.data, params));
            },
            localeText: localeTextRu,
            sideBar: false,
            onFirstDataRendered: function() {
                scheduleFitArmColumns();
                scheduleArmGridRowHeights();
            },
            onGridReady: function(params) {
                gridApi = params.api;
                window.armGridApi = params.api;
                applyColumnsForCurrentType();
                loadGridData(true);
                initTabs();
                initActions();
                initColumnSettings();
                initQuickFilter();
                syncSelectionChrome();
            },
            onPaginationChanged: function() {
                if (!gridApi) return;
                var pageSize = gridApi.paginationGetPageSize ? gridApi.paginationGetPageSize() : currentPageSize;
                if (pageSize !== currentPageSize) {
                    currentPageSize = pageSize;
                    gridApi.setGridOption('paginationPageSize', currentPageSize);
                }
            },
            onSelectionChanged: function() {
                syncSelectionChrome();
            },
            onDisplayedColumnsChanged: scheduleArmGridRowHeights,
            onColumnResized: function(event) {
                markArmColumnUserResize();
                if (event && event.finished) {
                    scheduleArmGridRowHeights();
                }
            },
            onGridSizeChanged: function() {
                scheduleArmGridRowHeights();
                if (shouldSkipFitArmColumns()) {
                    return;
                }
                var el = document.getElementById('agGridArmContainer');
                if (el && el.clientWidth >= 80) {
                    scheduleFitArmColumns();
                }
            },
        };
        var createGrid = window.iasCreateGrid || (window.AgGridFilter && window.AgGridFilter.iasCreateGrid);
        (typeof createGrid === 'function' ? createGrid : agGrid.createGrid.bind(agGrid))(container, gridOpts);
        window.addEventListener('resize', function() {
            armSuppressFitUntil = 0;
            scheduleFitArmColumns(true);
        });
        requestAnimationFrame(function() {
            requestAnimationFrame(scheduleFitArmColumns);
        });
    }

    window.refreshArmGrid = function() {
        console.log('refreshArmGrid вызван');
        loadGridData(true);
    };

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() { setTimeout(init, 100); });
    } else {
        setTimeout(init, 100);
    }
})();
