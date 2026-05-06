/**
 * AG Grid для страницы «Учет ТС».
 * Колонки в порядке Основного учёта; данные из arm/get-grid-data.
 * Вкладки по типам техники, модальное «Переместить/Переназначить», пагинация «все», русская локаль.
 */
(function() {
    'use strict';

    let gridApi;
    let currentPageSize = Number(window.agGridArmDefaultLimit || 20) || 20;
    const ARM_COLUMNS_STORAGE_PREFIX = 'arm-columns:';

    const COLUMN_PRESETS = {
        default: ['user_name', 'location_name', 'status_name', 'cpu', 'ram', 'disk', 'system_block', 'inventory_number', 'monitor', 'hostname', 'ip', 'os', 'other_tech'],
        monitor: ['user_name', 'location_name', 'status_name', 'system_block', 'inventory_number'],
        system: ['user_name', 'location_name', 'status_name', 'cpu', 'ram', 'disk', 'system_block', 'inventory_number', 'monitor_count', 'disk_count', 'ups_count', 'hostname', 'ip', 'os'],
        ups: ['user_name', 'location_name', 'status_name', 'system_block', 'inventory_number', 'other_tech'],
        print: ['user_name', 'location_name', 'status_name', 'system_block', 'inventory_number', 'other_tech']
    };

    function getViewUrl(id) {
        var base = window.agGridArmViewUrl || (window.location.pathname.indexOf('index.php') >= 0
            ? window.location.pathname.substring(0, window.location.pathname.lastIndexOf('/') + 1) + 'index.php'
            : '/index.php');
        var sep = base.indexOf('?') >= 0 ? '&' : '?';
        return base + sep + 'r=arm/view&id=' + encodeURIComponent(id);
    }

    function getColumnDefs() {
        return [
            {
                headerName: '',
                width: 48,
                minWidth: 48,
                maxWidth: 48,
                sortable: false,
                filter: false,
                resizable: false,
                pinned: 'left',
            },
            { headerName: 'Пользователь', field: 'user_name', flex: 1, minWidth: 140, filter: 'agTextColumnFilter' },
            { headerName: 'Помещение', field: 'location_name', width: 110, filter: 'agTextColumnFilter' },
            {
                headerName: 'Статус',
                field: 'status_name',
                width: 150,
                filter: 'agTextColumnFilter',
                cellRenderer: function(params) {
                    var color = params.data && params.data.status_color ? params.data.status_color : 'gray';
                    var icon = color === 'green' ? '●' : (color === 'yellow' ? '▲' : (color === 'red' ? '▲' : '○'));
                    return '<span class="status-dot status-' + color + '">' + icon + '</span> ' + escapeHtml(params.value || '');
                }
            },
            { headerName: 'ЦП', field: 'cpu', width: 140, filter: 'agTextColumnFilter' },
            { headerName: 'ОЗУ', field: 'ram', width: 80, filter: 'agTextColumnFilter' },
            { headerName: 'Диск', field: 'disk', width: 120, filter: 'agTextColumnFilter' },
            {
                headerName: 'Тип/Название техники',
                field: 'system_block',
                flex: 1,
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
                width: 110,
                filter: 'agTextColumnFilter',
                cellRenderer: function(params) {
                    if (!params.data || params.data.id == null) return params.value || '';
                    var text = params.value || '—';
                    var url = getViewUrl(params.data.id);
                    return '<a href="' + url + '" class="arm-link-to-card" title="Открыть карточку актива">' + escapeHtml(String(text)) + '</a>';
                },
            },
            { headerName: 'Монитор', field: 'monitor', width: 140, filter: 'agTextColumnFilter' },
            { headerName: 'Мониторы (шт)', field: 'monitor_count', width: 120, filter: 'agNumberColumnFilter' },
            { headerName: 'Диски (шт)', field: 'disk_count', width: 100, filter: 'agNumberColumnFilter' },
            { headerName: 'ИБП (шт)', field: 'ups_count', width: 90, filter: 'agNumberColumnFilter' },
            { headerName: 'Имя ПК', field: 'hostname', width: 120, filter: 'agTextColumnFilter' },
            { headerName: 'IP адрес', field: 'ip', width: 110, filter: 'agTextColumnFilter' },
            { headerName: 'ОС', field: 'os', width: 120, filter: 'agTextColumnFilter' },
            { headerName: 'ДР техника', field: 'other_tech', flex: 1, minWidth: 160, filter: 'agTextColumnFilter', tooltipField: 'other_tech' },
        ];
    }

    function escapeHtml(str) {
        var div = document.createElement('div');
        div.textContent = str;
        return div.innerHTML;
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
        return base + sep + query.join('&');
    }

    function createDataSource() {
        return {
            getRows: function(params) {
                var startRow = params.startRow || 0;
                var endRow = params.endRow || (startRow + currentPageSize);
                var limit = Math.max(1, endRow - startRow);
                var offset = Math.max(0, startRow);

                fetch(getDataUrl(limit, offset, params.filterModel || {}, params.sortModel || []))
                    .then(function(r) { return r.ok ? r.json() : Promise.reject(new Error('HTTP ' + r.status)); })
                    .then(function(result) {
                        if (!result || !result.success || !Array.isArray(result.data)) {
                            return Promise.reject(new Error((result && result.message) || 'Invalid response'));
                        }
                        params.successCallback(result.data, Number(result.total || 0));
                        setTimeout(updateReassignButton, 0);
                    })
                    .catch(function(err) {
                        console.error('AG Grid (Учет ТС): ошибка загрузки', err);
                        params.failCallback();
                        setTimeout(updateReassignButton, 0);
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
        updateReassignButton();
    }

    function updateReassignButton() {
        const btn = document.getElementById('btnReassignArm');
        if (!btn) return;
        const selected = gridApi ? gridApi.getSelectedRows() : [];
        btn.disabled = selected.length === 0;
        btn.title = selected.length > 0
            ? 'Переместить или переназначить выбранную технику (' + selected.length + ')'
            : 'Выберите одну или несколько строк в таблице (чекбокс слева), затем нажмите';
    }

    function initTabs() {
        document.querySelectorAll('.arm-type-tab').forEach(function(tab) {
            tab.addEventListener('click', function(e) {
                e.preventDefault();
                document.querySelectorAll('.arm-type-tab').forEach(function(t) { t.classList.remove('active'); });
                this.classList.add('active');
                window.agGridArmCurrentTypeId = this.getAttribute('data-type-id') || '';
                applyColumnsForCurrentType();
                loadGridData(true);
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
        if (raw.indexOf('систем') >= 0 || raw.indexOf('моноблок') >= 0 || raw.indexOf('ноут') >= 0) return COLUMN_PRESETS.system;
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
            gridApi.applyColumnState({ state: savedState, applyOrder: false });
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
    }

    function initReassign() {
        var btn = document.getElementById('btnReassignArm');
        if (btn) {
            btn.disabled = true;
            btn.addEventListener('click', function() {
                var rows = gridApi ? gridApi.getSelectedRows() : [];
                if (rows.length === 0) {
                    alert('Выберите одну или несколько единиц техники в таблице (отметьте чекбоксы слева от строк), затем нажмите кнопку снова.');
                    return;
                }
                var ids = rows.map(function(r) { return r.id; });
                if (typeof window.openReassignModal === 'function') {
                    window.openReassignModal(ids);
                } else {
                    console.error('Функция openReassignModal не найдена');
                    alert('Ошибка: функция открытия модального окна не найдена.');
                }
            });
        } else {
            console.error('Кнопка btnReassignArm не найдена при инициализации');
        }
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
                if (!colId || label === '') return; // skip checkbox tech column
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
        if (!container || typeof agGrid === 'undefined') {
            if (container) container.innerHTML = '<p class="text-muted">Загрузка таблицы...</p>';
            return;
        }
        container.innerHTML = '';
        var gridOpts = {
            columnDefs: getColumnDefs(),
            defaultColDef: { sortable: true, filter: true, resizable: true },
            rowModelType: 'infinite',
            cacheBlockSize: currentPageSize,
            maxBlocksInCache: 5,
            rowSelection: {
                mode: 'multiRow',
                checkboxes: true,
                headerCheckbox: false,
                enableClickSelection: false
            },
            suppressCellFocus: true,
            pagination: true,
            paginationPageSize: currentPageSize,
            paginationPageSizeSelector: [10, 20, 50, 100, 200],
            domLayout: 'normal',
            getRowHeight: function() { return 36; },
            localeText: localeTextRu,
            sideBar: false,
            onGridReady: function(params) {
                gridApi = params.api;
                applyColumnsForCurrentType();
                loadGridData(true);
                initTabs();
                initReassign();
                initActions();
                initColumnSettings();
                updateReassignButton();
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
                updateReassignButton();
            },
        };
        agGrid.createGrid(container, gridOpts);
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
