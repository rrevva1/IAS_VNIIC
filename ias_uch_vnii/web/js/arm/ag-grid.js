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
    let armFitColumnsTimer = null;
    const ARM_COLUMNS_STORAGE_PREFIX = 'arm-columns:';

    function scheduleFitArmColumns() {
        clearTimeout(armFitColumnsTimer);
        armFitColumnsTimer = setTimeout(function() {
            if (!gridApi || typeof gridApi.sizeColumnsToFit !== 'function') {
                return;
            }
            try {
                gridApi.sizeColumnsToFit();
            } catch (e) {
                console.warn('AG Grid (Учет ТС): sizeColumnsToFit', e);
            }
        }, 50);
    }

    /** Firefox: flex + height:100% даёт нулевую высоту области строк — задаём явно. */
    function applyArmGridContainerHeight() {
        var container = document.getElementById('agGridArmContainer');
        var card = container && container.closest('.arm-grid-card');
        if (!container || !card) {
            return;
        }
        var cardHeight = card.clientHeight;
        if (cardHeight < 120) {
            return;
        }
        container.style.height = cardHeight + 'px';
        container.style.minHeight = '300px';
        if (gridApi && typeof gridApi.sizeColumnsToFit === 'function') {
            scheduleFitArmColumns();
        }
    }

    function scheduleArmGridContainerHeight() {
        setTimeout(applyArmGridContainerHeight, 0);
        setTimeout(applyArmGridContainerHeight, 100);
    }

    const COLUMN_PRESETS = {
        default: ['user_name', 'location_name', 'status_name', 'cpu', 'ram', 'disk', 'system_block', 'inventory_number', 'purchase_date', 'monitor', 'hostname', 'ip', 'os', 'other_tech'],
        monitor: ['user_name', 'location_name', 'status_name', 'system_block', 'inventory_number', 'purchase_date'],
        system: ['user_name', 'location_name', 'status_name', 'cpu', 'ram', 'disk', 'system_block', 'inventory_number', 'purchase_date', 'hostname', 'ip', 'os'],
        ups: ['user_name', 'location_name', 'status_name', 'system_block', 'inventory_number', 'purchase_date'],
        print: ['user_name', 'location_name', 'status_name', 'system_block', 'inventory_number', 'purchase_date', 'cartridge_procurement', 'ip', 'other_tech']
    };

    function getViewUrl(id) {
        var base = window.agGridArmViewUrl || (window.location.pathname.indexOf('index.php') >= 0
            ? window.location.pathname.substring(0, window.location.pathname.lastIndexOf('/') + 1) + 'index.php'
            : '/index.php');
        if (base.indexOf('id=') === -1 && base.indexOf('arm/view') !== -1) {
            var sep = base.indexOf('?') >= 0 ? '&' : '?';
            return base + sep + 'id=' + encodeURIComponent(id);
        }
        var sep = base.indexOf('?') >= 0 ? '&' : '?';
        return base + sep + 'r=arm/view&id=' + encodeURIComponent(id);
    }

    function isAllEquipmentTab() {
        return !(window.agGridArmCurrentTypeId || '').toString().trim();
    }

    function formatMonitorItemLabel(item, options) {
        if (!item) {
            return '';
        }
        options = options || {};
        var name = String(item.name || '').trim();
        var inv = String(item.inventory_number || '').trim();
        var showInv = options.showInv !== false && !isAllEquipmentTab();
        if (name && inv && showInv) {
            return name + ' (' + inv + ')';
        }
        return name || inv;
    }

    function monitorLinkTitle(item) {
        var name = String(item && item.name || '').trim();
        var inv = String(item && item.inventory_number || '').trim();
        if (name && inv) {
            return 'Открыть карточку монитора: ' + name + ' (' + inv + ')';
        }
        if (name) {
            return 'Открыть карточку монитора: ' + name;
        }
        return 'Открыть карточку монитора';
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
                        '<a href="' + getViewUrl(m.id) + '" class="arm-link-to-card arm-monitor-link" title="' +
                        escapeHtml(monitorLinkTitle(m)) + '">' +
                        escapeHtml(label) + '</a>'
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
        return [
            {
                headerName: 'Пользователь',
                field: 'user_name',
                minWidth: 120,
                filter: 'agTextColumnFilter',
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
                    var url = getViewUrl(params.data.id);
                    return '<a href="' + url + '" class="arm-link-to-card">' + escapeHtml(String(text)) + '</a>';
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
                    var url = getViewUrl(params.data.id);
                    return '<a href="' + url + '" class="arm-link-to-card" title="Открыть карточку актива">' + escapeHtml(String(text)) + '</a>';
                },
            },
            {
                headerName: 'Дата закупки',
                field: 'purchase_date',
                minWidth: 110,
                filter: 'agTextColumnFilter',
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

    function buildSortModelFromColumnState(api) {
        if (!api || typeof api.getColumnState !== 'function') {
            return [];
        }
        var state = (api.getColumnState() || []).filter(function(c) { return c && c.sort; });
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

                var sortModel = (params.sortModel && params.sortModel.length)
                    ? params.sortModel
                    : buildSortModelFromColumnState(gridApi);
                fetch(getDataUrl(limit, offset, params.filterModel || {}, sortModel))
                    .then(function(r) { return r.ok ? r.json() : Promise.reject(new Error('HTTP ' + r.status)); })
                    .then(function(result) {
                        if (!result || !result.success || !Array.isArray(result.data)) {
                            return Promise.reject(new Error((result && result.message) || 'Invalid response'));
                        }
                        params.successCallback(result.data, Number(result.total || 0));
                        setTimeout(function() {
                            scheduleFitArmColumns();
                            if (window.AgGridWrap && gridApi) {
                                window.AgGridWrap.scheduleResetRowHeights(gridApi);
                            }
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
        if (typeof gridApi.setGridOption === 'function') {
            gridApi.setGridOption('datasource', createDataSource());
        } else if (typeof gridApi.setDatasource === 'function') {
            gridApi.setDatasource(createDataSource());
        } else {
            console.error('AG Grid API: datasource method is unavailable');
        }
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

    function getPresetColumns(typeId) {
        var raw = (typeId || '').toString().toLowerCase();
        if (!raw) return COLUMN_PRESETS.default;
        if (raw.indexOf('монитор') >= 0) return COLUMN_PRESETS.monitor;
        if (raw === 'арм' || raw.indexOf('систем') >= 0 || raw.indexOf('моноблок') >= 0 || raw.indexOf('ноут') >= 0 || raw === 'пк') {
            return COLUMN_PRESETS.system;
        }
        if (raw.indexOf('ибп') >= 0 || raw.indexOf('ups') >= 0) return COLUMN_PRESETS.ups;
        if (raw.indexOf('мфу') >= 0 || raw.indexOf('принтер') >= 0) return COLUMN_PRESETS.print;
        return COLUMN_PRESETS.default;
    }

    function saveCurrentColumnsStateForType(typeId) {
        if (!gridApi || typeof window.localStorage === 'undefined') return;
        var columns = gridApi.getColumns ? gridApi.getColumns() : [];
        var state = [];
        columns.forEach(function(col) {
            if (!col || !col.getColId || !col.getColDef) return;
            var def = col.getColDef() || {};
            var colId = col.getColId();
            if (!colId || !def.field) return;
            state.push({ colId: colId, hide: !(col.isVisible ? col.isVisible() : true) });
        });
        window.localStorage.setItem(getColumnsStorageKey(typeId), JSON.stringify(state));
    }

    function applyColumnsForCurrentType(forcePreset) {
        if (!gridApi || !gridApi.applyColumnState) return;
        var typeId = (window.agGridArmCurrentTypeId || '').toString().trim();
        var savedState = null;
        if (!forcePreset && typeof window.localStorage !== 'undefined') {
            try {
                var raw = window.localStorage.getItem(getColumnsStorageKey(typeId));
                if (raw) {
                    savedState = JSON.parse(raw);
                }
            } catch (e) {
                savedState = null;
            }
        }
        if (savedState && Array.isArray(savedState) && savedState.length > 0) {
            var visibilityState = savedState.map(function(item) {
                return {
                    colId: item.colId,
                    hide: !!item.hide,
                };
            });
            gridApi.applyColumnState({ state: visibilityState, applyOrder: false });
            scheduleFitArmColumns();
            return;
        }
        var allowed = getPresetColumns(typeId);
        var columns = gridApi.getColumns ? gridApi.getColumns() : [];
        var state = [];
        columns.forEach(function(col) {
            if (!col || !col.getColId || !col.getColDef) return;
            var def = col.getColDef() || {};
            var colId = col.getColId();
            if (!colId || !def.field) return;
            state.push({ colId: colId, hide: allowed.indexOf(colId) === -1 });
        });
        gridApi.applyColumnState({ state: state, applyOrder: false });
        scheduleFitArmColumns();
    }

    function initActions() {
        var exportBtn = document.getElementById('btnArmExportXlsx');
        if (exportBtn) {
            exportBtn.addEventListener('click', function() {
                var url = '/index.php?r=arm/export-xlsx';
                var query = [];
                query.push('export_scope=' + encodeURIComponent('visible'));
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
            var cols = gridApi.getColumns ? gridApi.getColumns() : [];
            var html = '';
            cols.forEach(function(col) {
                var def = col.getColDef ? col.getColDef() : {};
                var colId = col.getColId ? col.getColId() : def.field;
                var label = (def && def.headerName != null ? String(def.headerName) : '').trim();
                if (!colId || !def.field) return; // без поля — служебная колонка выбора
                var checked = col.isVisible ? col.isVisible() : true;
                html += '<div class="form-check mb-1">';
                html += '<input class="form-check-input arm-col-check" type="checkbox" id="arm-col-' + escapeHtml(colId) + '" data-col-id="' + escapeHtml(colId) + '"' + (checked ? ' checked' : '') + '>';
                html += '<label class="form-check-label" for="arm-col-' + escapeHtml(colId) + '">' + escapeHtml(label) + '</label>';
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
            var checks = listEl.querySelectorAll('.arm-col-check');
            var state = [];
            checks.forEach(function(ch) {
                state.push({
                    colId: ch.getAttribute('data-col-id'),
                    hide: !ch.checked
                });
            });
            if (gridApi.applyColumnState) {
                gridApi.applyColumnState({ state: state, applyOrder: false });
            }
            saveCurrentColumnsStateForType(window.agGridArmCurrentTypeId);
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
            defaultColDef: (window.AgGridWrap && window.AgGridWrap.mergeDefaultColDef)
                ? window.AgGridWrap.mergeDefaultColDef({
                    sortable: true,
                    filter: true,
                    resizable: true,
                    autoHeight: false,
                }, true)
                : { sortable: true, filter: true, resizable: true, wrapText: true, autoHeight: false, cellClass: 'ag-cell-wrap-text' },
            rowModelType: 'infinite',
            cacheBlockSize: currentPageSize,
            maxBlocksInCache: 5,
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
            getRowHeight: function(params) {
                var extraLines = Math.max(
                    countMonitorDisplayLines(params.data, params),
                    countDiskDisplayLines(params.data, params)
                );
                if (window.AgGridWrap && typeof window.AgGridWrap.estimateRowHeight === 'function') {
                    return window.AgGridWrap.estimateRowHeight(params, extraLines);
                }
                return Math.min(160, Math.max(62, extraLines * 24 + 28));
            },
            localeText: localeTextRu,
            sideBar: false,
            onGridReady: function(params) {
                gridApi = params.api;
                window.armGridApi = params.api;
                scheduleArmGridContainerHeight();
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
                    gridApi.setGridOption('cacheBlockSize', currentPageSize);
                    loadGridData(true);
                }
            },
            onSelectionChanged: function() {
                syncSelectionChrome();
            },
            onSortChanged: function() {
                loadGridData(true);
            },
            onDisplayedColumnsChanged: function() {
                scheduleFitArmColumns();
                if (window.AgGridWrap && gridApi) {
                    window.AgGridWrap.scheduleResetRowHeights(gridApi);
                }
            },
            onGridSizeChanged: function() {
                scheduleArmGridContainerHeight();
                scheduleFitArmColumns();
                if (window.AgGridWrap && gridApi) {
                    window.AgGridWrap.scheduleResetRowHeights(gridApi);
                }
            },
            onColumnResized: function() {
                if (window.AgGridWrap && gridApi) {
                    window.AgGridWrap.scheduleResetRowHeights(gridApi);
                }
            },
        };
        agGrid.createGrid(container, gridOpts);
        scheduleArmGridContainerHeight();
        if (typeof ResizeObserver !== 'undefined' && container) {
            var armGridResizeObserver = new ResizeObserver(function() {
                applyArmGridContainerHeight();
                scheduleFitArmColumns();
            });
            armGridResizeObserver.observe(container);
            var card = container.closest('.arm-grid-card');
            if (card) {
                armGridResizeObserver.observe(card);
            }
        }
        window.addEventListener('resize', scheduleArmGridContainerHeight);
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
