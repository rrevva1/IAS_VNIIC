/**
 * AG Grid: KPI-таблицы на странице статистики заявок.
 */
(function() {
    'use strict';

    var localeTextRu = {
        page: 'Страница',
        to: 'до',
        of: 'из',
        next: 'След.',
        last: 'Последняя',
        first: 'Первая',
        previous: 'Пред.',
        loadingOoo: 'Загрузка...',
        noRowsToShow: 'Нет данных',
        filterOoo: 'Фильтр...',
        pageSizeSelectorLabel: 'Строк:',
    };

    function createExecutorGrid(container, dataUrl) {
        var columnDefs = [
            { headerName: '№', field: 'row_num', width: 64, filter: 'agNumberColumnFilter' },
            { headerName: 'Исполнитель', field: 'name', flex: 1, minWidth: 180, filter: 'agTextColumnFilter' },
            {
                headerName: 'Выполнено',
                field: 'completed_count',
                width: 120,
                filter: 'agNumberColumnFilter',
            },
            {
                headerName: 'Доля',
                field: 'share_percent',
                width: 90,
                valueFormatter: function(p) {
                    return p.value != null ? p.value + '%' : '';
                },
            },
            {
                headerName: 'Суммарное время',
                field: 'total_resolution_label',
                width: 150,
                filter: 'agTextColumnFilter',
            },
            {
                headerName: 'Среднее время',
                field: 'avg_resolution_label',
                width: 140,
                filter: 'agTextColumnFilter',
            },
        ];
        createGrid(container, dataUrl, columnDefs);
    }

    function createRequesterGrid(container, dataUrl) {
        var columnDefs = [
            { headerName: '№', field: 'row_num', width: 64, filter: 'agNumberColumnFilter' },
            { headerName: 'Автор заявки', field: 'name', flex: 1, minWidth: 180, filter: 'agTextColumnFilter' },
            { headerName: 'Заявок', field: 'count', width: 110, filter: 'agNumberColumnFilter' },
            {
                headerName: 'Доля',
                field: 'percentage',
                width: 100,
                valueFormatter: function(p) {
                    return p.value != null ? p.value + '%' : '';
                },
            },
        ];
        createGrid(container, dataUrl, columnDefs);
    }

    function createGrid(container, dataUrl, columnDefs) {
        if (!container || typeof agGrid === 'undefined') {
            return;
        }
        container.innerHTML = '';

        var gridOpts = {
            columnDefs: columnDefs,
            defaultColDef: { sortable: true, filter: true, resizable: true },
            pagination: true,
            paginationPageSize: 15,
            paginationPageSizeSelector: [10, 15, 25, 50],
            domLayout: 'normal',
            getRowHeight: function() {
                return 40;
            },
            localeText: localeTextRu,
            onGridReady: function(params) {
                fetch(dataUrl)
                    .then(function(r) {
                        return r.json();
                    })
                    .then(function(result) {
                        if (result && result.success && result.data) {
                            params.api.setGridOption('rowData', result.data);
                        } else {
                            params.api.setGridOption('rowData', []);
                        }
                    })
                    .catch(function(err) {
                        console.error('AG Grid (статистика KPI):', err);
                    });
            },
        };

        agGrid.createGrid(container, gridOpts);
    }

    function init() {
        var executorEl = document.getElementById('agGridStatisticsExecutorContainer');
        var requesterEl = document.getElementById('agGridStatisticsRequesterContainer');

        if (executorEl && executorEl.dataset.url) {
            createExecutorGrid(executorEl, executorEl.dataset.url);
        }
        if (requesterEl && requesterEl.dataset.url) {
            createRequesterGrid(requesterEl, requesterEl.dataset.url);
        }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() {
            setTimeout(init, 150);
        });
    } else {
        setTimeout(init, 150);
    }
})();
