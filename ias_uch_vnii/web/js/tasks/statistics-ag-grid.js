/**
 * AG Grid для таблиц на странице «Статистика заявок»: по пользователям и по исполнителям.
 */
(function() {
    'use strict';

    var localeTextRu = {
        page: 'Страница', to: 'до', of: 'из', next: 'След.', last: 'Последняя',
        first: 'Первая', previous: 'Пред.', loadingOoo: 'Загрузка...',
        noRowsToShow: 'Нет данных', filterOoo: 'Фильтр...', pageSizeSelectorLabel: 'Строк:',
    };

    function createStatsGrid(container, dataUrl, nameColHeader) {
        if (!container || typeof agGrid === 'undefined') return;
        container.innerHTML = '';
        var columnDefs = [
            { headerName: '№', field: 'row_num', width: 70, filter: 'agNumberColumnFilter' },
            { headerName: nameColHeader, field: 'name', flex: 1, minWidth: 180, filter: 'agTextColumnFilter' },
            {
                headerName: 'Количество',
                field: 'count',
                width: 130,
                filter: 'agNumberColumnFilter',
                cellRenderer: function(params) {
                    if (params.value == null) return '';
                    var badgeClass = container.id.indexOf('Executor') >= 0 ? 'badge bg-success' : 'badge bg-primary';
                    return '<span class="' + badgeClass + '" style="padding: 6px 10px;">' + params.value + '</span>';
                },
            },
            {
                headerName: 'Процент',
                field: 'percentage',
                width: 180,
                filter: 'agNumberColumnFilter',
                cellRenderer: function(params) {
                    if (params.value == null) return '';
                    var pct = Number(params.value);
                    var color = container.id.indexOf('Executor') >= 0 ? '#28a745' : '#007bff';
                    return '<div class="progress" style="height: 22px; margin: 0; min-width: 80px;">' +
                        '<div class="progress-bar" role="progressbar" style="width: ' + Math.min(pct, 100) + '%; background-color: ' + color + ';">' + pct + '%</div></div>';
                },
            },
        ];
        var gridOpts = {
            columnDefs: columnDefs,
            defaultColDef: { sortable: true, filter: true, resizable: true },
            pagination: true,
            paginationPageSize: 15,
            paginationPageSizeSelector: [10, 15, 25, 50],
            domLayout: 'normal',
            getRowHeight: function() { return 40; },
            localeText: localeTextRu,
            onGridReady: function(params) {
                fetch(dataUrl)
                    .then(function(r) { return r.json(); })
                    .then(function(result) {
                        if (result && result.success && result.data) {
                            params.api.setGridOption('rowData', result.data);
                        } else {
                            params.api.setGridOption('rowData', []);
                        }
                    })
                    .catch(function(err) { console.error('AG Grid (статистика): ошибка загрузки', err); });
            },
        };
        agGrid.createGrid(container, gridOpts);
    }

    function init() {
        var userEl = document.getElementById('agGridStatisticsUserContainer');
        var executorEl = document.getElementById('agGridStatisticsExecutorContainer');
        if (userEl && userEl.dataset.url) {
            createStatsGrid(userEl, userEl.dataset.url, 'Пользователь');
        }
        if (executorEl && executorEl.dataset.url) {
            createStatsGrid(executorEl, executorEl.dataset.url, 'Исполнитель');
        }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() { setTimeout(init, 150); });
    } else {
        setTimeout(init, 150);
    }
})();
