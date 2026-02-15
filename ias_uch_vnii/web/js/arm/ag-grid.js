/**
 * AG Grid для страницы «Учет ТС».
 * Колонки в порядке Основного учёта; данные из arm/get-grid-data.
 * Вкладки по типам техники, модальное «Переместить/Переназначить», пагинация «все», русская локаль.
 */
(function() {
    'use strict';

    let gridApi;

    function getColumnDefs() {
        return [
            { headerName: 'Пользователь', field: 'user_name', flex: 1, minWidth: 140, filter: 'agTextColumnFilter' },
            { headerName: 'Помещение', field: 'location_name', width: 110, filter: 'agTextColumnFilter' },
            { headerName: 'ЦП', field: 'cpu', width: 140, filter: 'agTextColumnFilter' },
            { headerName: 'ОЗУ', field: 'ram', width: 80, filter: 'agTextColumnFilter' },
            { headerName: 'Диск', field: 'disk', width: 120, filter: 'agTextColumnFilter' },
            { headerName: 'Тип/Название техники', field: 'system_block', flex: 1, minWidth: 140, filter: 'agTextColumnFilter' },
            { headerName: 'Инв. №', field: 'inventory_number', width: 110, filter: 'agTextColumnFilter' },
            { headerName: 'Монитор', field: 'monitor', width: 140, filter: 'agTextColumnFilter' },
            { headerName: 'Имя ПК', field: 'hostname', width: 120, filter: 'agTextColumnFilter' },
            { headerName: 'IP адрес', field: 'ip', width: 110, filter: 'agTextColumnFilter' },
            { headerName: 'ОС', field: 'os', width: 120, filter: 'agTextColumnFilter' },
            { headerName: 'ДР техника', field: 'other_tech', flex: 1, minWidth: 160, filter: 'agTextColumnFilter', tooltipField: 'other_tech' },
        ];
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

    function getDataUrl() {
        const base = window.agGridArmDataUrl || '/index.php?r=arm/get-grid-data';
        const typeId = (window.agGridArmCurrentTypeId || '').toString().trim();
        if (typeId) {
            return base + (base.indexOf('?') >= 0 ? '&' : '?') + 'equipment_type=' + encodeURIComponent(typeId);
        }
        return base;
    }

    function loadGridData() {
        if (!gridApi) return;
        fetch(getDataUrl())
            .then(function(r) { return r.ok ? r.json() : Promise.reject(new Error('HTTP ' + r.status)); })
            .then(function(result) {
                if (result.success && result.data) {
                    gridApi.setGridOption('rowData', result.data);
                }
            })
            .catch(function(err) { console.error('AG Grid (Учет ТС): ошибка загрузки', err); });
    }

    function updateReassignButton() {
        const btn = document.getElementById('btnReassignArm');
        if (!btn) return;
        const selected = gridApi ? gridApi.getSelectedRows() : [];
        btn.style.display = selected.length > 0 ? '' : 'none';
    }

    function initTabs() {
        document.querySelectorAll('.arm-type-tab').forEach(function(tab) {
            tab.addEventListener('click', function(e) {
                e.preventDefault();
                document.querySelectorAll('.arm-type-tab').forEach(function(t) { t.classList.remove('active'); });
                this.classList.add('active');
                window.agGridArmCurrentTypeId = this.getAttribute('data-type-id') || '';
                loadGridData();
            });
        });
    }

    function initReassign() {
        var btn = document.getElementById('btnReassignArm');
        if (btn) {
            btn.addEventListener('click', function() {
                var rows = gridApi ? gridApi.getSelectedRows() : [];
                if (rows.length === 0) return;
                var ids = rows.map(function(r) { return r.id; });
                if (typeof window.openReassignModal === 'function') {
                    window.openReassignModal(ids);
                }
            });
        }
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
            rowSelection: 'multiple',
            suppressRowClickSelection: true,
            pagination: true,
            paginationPageSize: 20,
            paginationPageSizeSelector: [10, 20, 50, 100, 9999],
            domLayout: 'normal',
            getRowHeight: function() { return 36; },
            localeText: localeTextRu,
            sideBar: 'columns',
            onGridReady: function(params) {
                gridApi = params.api;
                loadGridData();
                initTabs();
                initReassign();
            },
            onSelectionChanged: updateReassignButton,
        };
        agGrid.createGrid(container, gridOpts);
    }

    window.refreshArmGrid = function() {
        loadGridData();
    };

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() { setTimeout(init, 100); });
    } else {
        setTimeout(init, 100);
    }
})();
