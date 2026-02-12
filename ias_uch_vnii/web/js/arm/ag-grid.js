/**
 * AG Grid для страницы «Учет ТС».
 * Колонки в порядке Основного учёта; данные из arm/get-grid-data.
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
            { headerName: 'Системный блок', field: 'system_block', flex: 1, minWidth: 140, filter: 'agTextColumnFilter' },
            { headerName: 'Инв. №', field: 'inventory_number', width: 110, filter: 'agTextColumnFilter' },
            { headerName: 'Монитор', field: 'monitor', width: 140, filter: 'agTextColumnFilter' },
            { headerName: 'Имя ПК', field: 'hostname', width: 120, filter: 'agTextColumnFilter' },
            { headerName: 'IP адрес', field: 'ip', width: 110, filter: 'agTextColumnFilter' },
            { headerName: 'ОС', field: 'os', width: 120, filter: 'agTextColumnFilter' },
            { headerName: 'ДР техника', field: 'other_tech', flex: 1, minWidth: 160, filter: 'agTextColumnFilter', tooltipField: 'other_tech' },
        ];
    }

    function loadGridData() {
        if (!gridApi) return;
        const url = window.agGridArmDataUrl || '/index.php?r=arm/get-grid-data';
        fetch(url)
            .then(function(r) { return r.ok ? r.json() : Promise.reject(new Error('HTTP ' + r.status)); })
            .then(function(result) {
                if (result.success && result.data) {
                    gridApi.setGridOption('rowData', result.data);
                }
            })
            .catch(function(err) { console.error('AG Grid (Учет ТС): ошибка загрузки', err); });
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
            pagination: true,
            paginationPageSize: 20,
            paginationPageSizeSelector: [10, 20, 50, 100],
            domLayout: 'normal',
            getRowHeight: function() { return 36; },
            localeText: {
                page: 'Страница', to: 'до', of: 'из', next: 'След.', last: 'Последняя',
                first: 'Первая', previous: 'Пред.', loadingOoo: 'Загрузка...',
                noRowsToShow: 'Нет данных', filterOoo: 'Фильтр...', pageSizeSelectorLabel: 'Строк:',
            },
            onGridReady: function(params) {
                gridApi = params.api;
                loadGridData();
            },
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
