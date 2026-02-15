/**
 * AG Grid для страницы «ПО и лицензии».
 */
(function() {
    'use strict';

    var gridApi;
    var localeTextRu = {
        page: 'Страница', to: 'до', of: 'из', next: 'След.', last: 'Последняя',
        first: 'Первая', previous: 'Пред.', loadingOoo: 'Загрузка...',
        noRowsToShow: 'Нет данных', filterOoo: 'Фильтр...', pageSizeSelectorLabel: 'Строк:',
        applyFilter: 'Применить', resetFilter: 'Сбросить', clearFilter: 'Очистить',
    };

    function buildUrl(base, paramName, id) {
        if (!base) return '#';
        var sep = base.indexOf('?') >= 0 ? '&' : '?';
        return base + sep + paramName + '=' + encodeURIComponent(id);
    }

    function init() {
        var container = document.getElementById('agGridSoftwareContainer');
        if (!container || typeof agGrid === 'undefined') {
            if (container) container.innerHTML = '<p class="text-muted">Загрузка таблицы...</p>';
            return;
        }

        var dataUrl = container.dataset.url || '/index.php?r=software/get-grid-data';
        var viewUrl = container.dataset.viewUrl || '';
        var licenseCreateUrl = container.dataset.licenseCreateUrl || '';
        var updateUrl = container.dataset.updateUrl || '';

        var columnDefs = [
            { headerName: 'ID', field: 'id', width: 80, filter: 'agNumberColumnFilter' },
            {
                headerName: 'Наименование',
                field: 'name',
                flex: 1,
                minWidth: 200,
                filter: 'agTextColumnFilter',
                cellRenderer: function(params) {
                    if (!params.data || params.data.id == null) return params.value || '';
                    var text = params.value || '—';
                    var url = buildUrl(viewUrl, 'id', params.data.id);
                    return '<a href="' + url + '">' + escapeHtml(String(text)) + '</a>';
                },
            },
            { headerName: 'Версия', field: 'version', width: 120, filter: 'agTextColumnFilter', valueFormatter: function(p) { return p.value || '—'; } },
            {
                headerName: 'Лицензии',
                width: 140,
                sortable: false,
                filter: false,
                cellRenderer: function(params) {
                    if (!params.data) return '';
                    var id = params.data.id;
                    var count = params.data.licenses_count != null ? params.data.licenses_count : 0;
                    var addUrl = buildUrl(licenseCreateUrl, 'software_id', id);
                    return count + ' <a href="' + addUrl + '" class="btn btn-sm btn-outline-secondary" title="Добавить лицензию">+</a>';
                },
            },
            {
                headerName: 'Действия',
                width: 160,
                sortable: false,
                filter: false,
                cellRenderer: function(params) {
                    if (!params.data || params.data.id == null) return '';
                    var id = params.data.id;
                    var html = '<a href="' + buildUrl(viewUrl, 'id', id) + '" class="btn btn-sm btn-default">Просмотр</a>';
                    if (updateUrl) html += ' <a href="' + buildUrl(updateUrl, 'id', id) + '" class="btn btn-sm btn-default">Изменить</a>';
                    return html;
                },
            },
        ];

        function escapeHtml(str) {
            var div = document.createElement('div');
            div.textContent = str;
            return div.innerHTML;
        }

        container.innerHTML = '';
        var gridOpts = {
            columnDefs: columnDefs,
            defaultColDef: { sortable: true, filter: true, resizable: true },
            pagination: true,
            paginationPageSize: 20,
            paginationPageSizeSelector: [10, 20, 50, 100],
            domLayout: 'normal',
            getRowHeight: function() { return 36; },
            localeText: localeTextRu,
            onGridReady: function(params) {
                gridApi = params.api;
                fetch(dataUrl)
                    .then(function(r) { return r.json(); })
                    .then(function(result) {
                        if (result && result.success && result.data) {
                            gridApi.setGridOption('rowData', result.data);
                        } else {
                            gridApi.setGridOption('rowData', []);
                        }
                    })
                    .catch(function(err) { console.error('AG Grid (ПО): ошибка загрузки', err); });
            },
        };
        agGrid.createGrid(container, gridOpts);
    }

    window.refreshSoftwareGrid = function() {
        var container = document.getElementById('agGridSoftwareContainer');
        if (!container || !gridApi) return;
        var dataUrl = container.dataset.url || '/index.php?r=software/get-grid-data';
        fetch(dataUrl)
            .then(function(r) { return r.json(); })
            .then(function(result) {
                if (result && result.success && result.data) {
                    gridApi.setGridOption('rowData', result.data);
                }
            });
    };

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() { setTimeout(init, 100); });
    } else {
        setTimeout(init, 100);
    }
})();
