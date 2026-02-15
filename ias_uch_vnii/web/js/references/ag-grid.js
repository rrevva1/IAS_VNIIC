/**
 * AG Grid для справочников: статусы заявок, локации, статусы оборудования, типы частей, характеристики.
 * Контейнер задаётся на странице; data-url, data-update-url, data-archive-url передаются через data-атрибуты.
 */
(function() {
    'use strict';

    var localeTextRu = {
        page: 'Страница', to: 'до', of: 'из', next: 'След.', last: 'Последняя',
        first: 'Первая', previous: 'Пред.', loadingOoo: 'Загрузка...',
        noRowsToShow: 'Нет данных', filterOoo: 'Фильтр...', pageSizeSelectorLabel: 'Строк:',
        applyFilter: 'Применить', resetFilter: 'Сбросить', clearFilter: 'Очистить',
    };

    function escapeHtml(str) {
        if (str == null) return '';
        var div = document.createElement('div');
        div.textContent = str;
        return div.innerHTML;
    }

    function buildUrl(base, id) {
        if (!base) return '#';
        var sep = base.indexOf('?') >= 0 ? '&' : '?';
        return base + sep + 'id=' + encodeURIComponent(id);
    }

    function makeActionsCol(updateUrl, archiveUrl, archiveConfirm, canArchive) {
        return {
            headerName: 'Действия',
            width: 180,
            sortable: false,
            filter: false,
            cellRenderer: function(params) {
                if (!params.data || params.data.id == null) return '';
                var id = params.data.id;
                var html = '<a href="' + buildUrl(updateUrl, id) + '" class="btn btn-sm btn-default">Изменить</a>';
                if (canArchive && archiveUrl && !params.data.is_archived) {
                    html += ' <a href="' + buildUrl(archiveUrl, id) + '" class="btn btn-sm btn-warning ref-archive-link" data-method="post" data-confirm="' + escapeHtml(archiveConfirm || 'Архивировать?') + '">В архив</a>';
                }
                return html;
            },
        };
    }

    function makeArchivedBadgeCol() {
        return {
            headerName: 'Состояние',
            field: 'is_archived',
            width: 100,
            filter: 'agTextColumnFilter',
            cellRenderer: function(params) {
                if (params.value) return '<span class="badge bg-secondary">Архив</span>';
                return '<span class="badge bg-success">Активен</span>';
            },
        };
    }

    function initTaskStatus(container) {
        var dataUrl = container.dataset.url || '/index.php?r=references/task-status-get-grid-data';
        var updateUrl = container.dataset.updateUrl || '';
        var archiveUrl = container.dataset.archiveUrl || '';
        var columnDefs = [
            { headerName: 'ID', field: 'id', width: 80, filter: 'agNumberColumnFilter', cellRenderer: function(p) {
                if (!p.data || p.data.id == null) return p.value;
                return '<a href="' + buildUrl(updateUrl, p.data.id) + '">' + p.value + '</a>';
            }},
            { headerName: 'Код', field: 'status_code', width: 120, filter: 'agTextColumnFilter' },
            { headerName: 'Название', field: 'status_name', flex: 1, minWidth: 150, filter: 'agTextColumnFilter' },
            { headerName: 'Порядок', field: 'sort_order', width: 90, filter: 'agNumberColumnFilter' },
            makeArchivedBadgeCol(),
            makeActionsCol(updateUrl, archiveUrl, 'Архивировать этот статус?', true),
        ];
        createGrid(container, dataUrl, columnDefs);
    }

    function initLocations(container) {
        var dataUrl = container.dataset.url || '/index.php?r=references/locations-get-grid-data';
        var updateUrl = container.dataset.updateUrl || '';
        var archiveUrl = container.dataset.archiveUrl || '';
        var columnDefs = [
            { headerName: 'ID', field: 'id', width: 80, filter: 'agNumberColumnFilter', cellRenderer: function(p) {
                if (!p.data || p.data.id == null) return p.value;
                return '<a href="' + buildUrl(updateUrl, p.data.id) + '">' + p.value + '</a>';
            }},
            { headerName: 'Наименование', field: 'name', flex: 1, minWidth: 150, filter: 'agTextColumnFilter' },
            { headerName: 'Код', field: 'location_code', width: 110, filter: 'agTextColumnFilter' },
            { headerName: 'Тип', field: 'location_type', width: 120, filter: 'agTextColumnFilter' },
            makeArchivedBadgeCol(),
            makeActionsCol(updateUrl, archiveUrl, 'Архивировать эту локацию?', true),
        ];
        createGrid(container, dataUrl, columnDefs);
    }

    function initEquipmentStatus(container) {
        var dataUrl = container.dataset.url || '/index.php?r=references/equipment-status-get-grid-data';
        var updateUrl = container.dataset.updateUrl || '';
        var archiveUrl = container.dataset.archiveUrl || '';
        var columnDefs = [
            { headerName: 'ID', field: 'id', width: 80, filter: 'agNumberColumnFilter', cellRenderer: function(p) {
                if (!p.data || p.data.id == null) return p.value;
                return '<a href="' + buildUrl(updateUrl, p.data.id) + '">' + p.value + '</a>';
            }},
            { headerName: 'Код', field: 'status_code', width: 120, filter: 'agTextColumnFilter' },
            { headerName: 'Название', field: 'status_name', flex: 1, minWidth: 150, filter: 'agTextColumnFilter' },
            { headerName: 'Порядок', field: 'sort_order', width: 90, filter: 'agNumberColumnFilter' },
            makeArchivedBadgeCol(),
            makeActionsCol(updateUrl, archiveUrl, 'Архивировать этот статус?', true),
        ];
        createGrid(container, dataUrl, columnDefs);
    }

    function initParts(container) {
        var dataUrl = container.dataset.url || '/index.php?r=references/parts-get-grid-data';
        var updateUrl = container.dataset.updateUrl || '';
        var archiveUrl = container.dataset.archiveUrl || '';
        var columnDefs = [
            { headerName: 'ID', field: 'id', width: 80, filter: 'agNumberColumnFilter', cellRenderer: function(p) {
                if (!p.data || p.data.id == null) return p.value;
                return '<a href="' + buildUrl(updateUrl, p.data.id) + '">' + p.value + '</a>';
            }},
            { headerName: 'Наименование', field: 'name', flex: 1, minWidth: 150, filter: 'agTextColumnFilter' },
            { headerName: 'Описание', field: 'description', flex: 1, minWidth: 120, filter: 'agTextColumnFilter' },
            makeArchivedBadgeCol(),
            makeActionsCol(updateUrl, archiveUrl, 'Архивировать?', true),
        ];
        createGrid(container, dataUrl, columnDefs);
    }

    function initChars(container) {
        var dataUrl = container.dataset.url || '/index.php?r=references/chars-get-grid-data';
        var updateUrl = container.dataset.updateUrl || '';
        var archiveUrl = container.dataset.archiveUrl || '';
        var columnDefs = [
            { headerName: 'ID', field: 'id', width: 80, filter: 'agNumberColumnFilter', cellRenderer: function(p) {
                if (!p.data || p.data.id == null) return p.value;
                return '<a href="' + buildUrl(updateUrl, p.data.id) + '">' + p.value + '</a>';
            }},
            { headerName: 'Наименование', field: 'name', flex: 1, minWidth: 150, filter: 'agTextColumnFilter' },
            { headerName: 'Ед. изм.', field: 'measurement_unit', width: 100, filter: 'agTextColumnFilter' },
            { headerName: 'Описание', field: 'description', flex: 1, minWidth: 120, filter: 'agTextColumnFilter' },
            makeArchivedBadgeCol(),
            makeActionsCol(updateUrl, archiveUrl, 'Архивировать?', true),
        ];
        createGrid(container, dataUrl, columnDefs);
    }

    function createGrid(container, dataUrl, columnDefs) {
        container.innerHTML = '';
        if (typeof agGrid === 'undefined') {
            container.innerHTML = '<p class="text-muted">Загрузка таблицы...</p>';
            return;
        }
        var gridApi;
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
                    .catch(function(err) { console.error('AG Grid (справочник): ошибка загрузки', err); });
            },
        };
        agGrid.createGrid(container, gridOpts);
    }

    function init() {
        var ids = ['agGridRefTaskStatus', 'agGridRefLocations', 'agGridRefEquipmentStatus', 'agGridRefParts', 'agGridRefChars'];
        var inits = {
            agGridRefTaskStatus: initTaskStatus,
            agGridRefLocations: initLocations,
            agGridRefEquipmentStatus: initEquipmentStatus,
            agGridRefParts: initParts,
            agGridRefChars: initChars,
        };
        ids.forEach(function(id) {
            var el = document.getElementById(id);
            if (el && inits[id]) inits[id](el);
        });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() { setTimeout(init, 100); });
    } else {
        setTimeout(init, 100);
    }
})();
