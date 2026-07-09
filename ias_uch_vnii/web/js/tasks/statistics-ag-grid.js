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

    function buildDataUrlWithPeriod(dataUrl) {
        try {
            var target = new URL(dataUrl, window.location.origin);
            var current = new URL(window.location.href);
            var from = current.searchParams.get('date_from');
            var to = current.searchParams.get('date_to');

            if (from) {
                target.searchParams.set('date_from', from);
            }
            if (to) {
                target.searchParams.set('date_to', to);
            }

            return target.toString();
        } catch (e) {
            return dataUrl;
        }
    }

    function createExecutorGrid(container, dataUrl) {
        var columnDefs = [
            { headerName: '№', field: 'row_num', width: 56, minWidth: 50, maxWidth: 70, filter: 'agNumberColumnFilter' },
            { headerName: 'Исполнитель', field: 'name', flex: 1.6, minWidth: 160, filter: 'agTextColumnFilter' },
            {
                headerName: 'Выполнено',
                field: 'completed_count',
                flex: 0.7,
                minWidth: 96,
                maxWidth: 120,
                filter: 'agNumberColumnFilter',
            },
            {
                headerName: 'Доля',
                field: 'share_percent',
                flex: 0.55,
                minWidth: 80,
                maxWidth: 100,
                valueFormatter: function(p) {
                    return p.value != null ? p.value + '%' : '';
                },
            },
            {
                headerName: 'Суммарное время',
                field: 'total_resolution_label',
                flex: 0.9,
                minWidth: 120,
                filter: 'agTextColumnFilter',
            },
            {
                headerName: 'Среднее время',
                field: 'avg_resolution_label',
                flex: 0.85,
                minWidth: 115,
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

        function fitColumns(api) {
            if (!api || typeof api.sizeColumnsToFit !== 'function') {
                return;
            }
            if (!container || container.clientWidth < 80) {
                return;
            }
            try {
                api.sizeColumnsToFit();
            } catch (e) {
                console.warn('AG Grid (статистика KPI): sizeColumnsToFit', e);
            }
        }

        var gridOpts = {
            columnDefs: columnDefs,
            theme: 'legacy',
            animateRows: true,
            defaultColDef: { sortable: true, filter: true, resizable: true },
            suppressHorizontalScroll: false,
            pagination: true,
            paginationPageSize: 20,
            paginationPageSizeSelector: [10, 20, 50, 100, 200],
            domLayout: 'normal',
            alwaysShowHorizontalScroll: true,
            alwaysShowVerticalScroll: true,
            scrollbarWidth: 12,
            getRowHeight: function() {
                return 40;
            },
            localeText: localeTextRu,
            onFirstDataRendered: function(params) {
                fitColumns(params.api);
            },
            onGridSizeChanged: function(params) {
                fitColumns(params.api);
            },
            onGridReady: function(params) {
                fetch(buildDataUrlWithPeriod(dataUrl), { cache: 'no-store' })
                    .then(function(r) {
                        return r.json();
                    })
                    .then(function(result) {
                        if (result && result.success && result.data) {
                            params.api.setGridOption('rowData', result.data);
                        } else {
                            params.api.setGridOption('rowData', []);
                        }
                        setTimeout(function() {
                            fitColumns(params.api);
                        }, 0);
                    })
                    .catch(function(err) {
                        console.error('AG Grid (статистика KPI):', err);
                    });
            },
        };

        var createGridFn = window.iasCreateGrid || (window.AgGridFilter && window.AgGridFilter.iasCreateGrid);
        (typeof createGridFn === 'function' ? createGridFn : agGrid.createGrid.bind(agGrid))(container, gridOpts);
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
