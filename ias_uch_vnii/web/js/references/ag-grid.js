/**
 * AG Grid — справочники (каркас как «Учёт ТС», редактирование в модальном окне).
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
        if (str == null) {
            return '';
        }
        var div = document.createElement('div');
        div.textContent = str;
        return div.innerHTML;
    }

    function editLink(id, text) {
        return '<a href="#" class="ref-link-edit" data-ref-id="' + encodeURIComponent(id) + '">'
            + escapeHtml(String(text || '—')) + '</a>';
    }

    function makeActionsCol(archiveConfirm) {
        return {
            headerName: 'Действия',
            width: 200,
            sortable: false,
            filter: false,
            cellRenderer: function(params) {
                if (!params.data || params.data.id == null) {
                    return '';
                }
                var id = params.data.id;
                var html = '<div class="ref-actions">';
                html += '<a href="#" class="ref-link-edit btn btn-sm btn-outline-secondary" data-ref-id="'
                    + encodeURIComponent(id) + '">Изменить</a>';
                if (!params.data.is_archived) {
                    html += '<button type="button" class="btn btn-sm btn-outline-warning ref-archive-btn" data-ref-id="'
                        + encodeURIComponent(id) + '" data-confirm="' + escapeHtml(archiveConfirm || 'Архивировать?')
                        + '">В архив</button>';
                }
                html += '</div>';
                return html;
            },
        };
    }

    function makeArchivedBadgeCol() {
        return {
            headerName: 'Состояние',
            field: 'is_archived',
            width: 110,
            filter: 'agTextColumnFilter',
            cellRenderer: function(params) {
                if (params.value) {
                    return '<span class="badge bg-secondary">Архив</span>';
                }
                return '<span class="badge bg-success">Активен</span>';
            },
        };
    }

    function nameCol(field, headerName) {
        return {
            headerName: headerName || 'Наименование',
            field: field,
            flex: 1,
            minWidth: 160,
            filter: 'agTextColumnFilter',
            cellRenderer: function(params) {
                if (!params.data || params.data.id == null) {
                    return escapeHtml(params.value || '');
                }
                return editLink(params.data.id, params.value);
            },
        };
    }

    function initTaskStatus(container) {
        var dataUrl = container.dataset.url || '';
        var columnDefs = [
            { headerName: 'Код', field: 'status_code', width: 120, filter: 'agTextColumnFilter' },
            nameCol('status_name', 'Название'),
            { headerName: 'Порядок', field: 'sort_order', width: 90, filter: 'agNumberColumnFilter' },
            makeArchivedBadgeCol(),
            makeActionsCol('Архивировать этот статус?'),
        ];
        createGrid(container, dataUrl, columnDefs);
    }

    function initLocations(container) {
        var dataUrl = container.dataset.url || '';
        var columnDefs = [
            nameCol('name', 'Наименование'),
            { headerName: 'Код', field: 'location_code', width: 110, filter: 'agTextColumnFilter' },
            { headerName: 'Тип', field: 'location_type', width: 120, filter: 'agTextColumnFilter' },
            makeArchivedBadgeCol(),
            makeActionsCol('Архивировать эту локацию?'),
        ];
        createGrid(container, dataUrl, columnDefs);
    }

    function initEquipmentStatus(container) {
        var dataUrl = container.dataset.url || '';
        var columnDefs = [
            { headerName: 'Код', field: 'status_code', width: 120, filter: 'agTextColumnFilter' },
            nameCol('status_name', 'Название'),
            { headerName: 'Порядок', field: 'sort_order', width: 90, filter: 'agNumberColumnFilter' },
            makeArchivedBadgeCol(),
            makeActionsCol('Архивировать этот статус?'),
        ];
        createGrid(container, dataUrl, columnDefs);
    }

    function initParts(container) {
        var dataUrl = container.dataset.url || '';
        var columnDefs = [
            nameCol('name', 'Наименование'),
            { headerName: 'Описание', field: 'description', flex: 1, minWidth: 120, filter: 'agTextColumnFilter' },
            makeArchivedBadgeCol(),
            makeActionsCol('Архивировать?'),
        ];
        createGrid(container, dataUrl, columnDefs);
    }

    function initChars(container) {
        var dataUrl = container.dataset.url || '';
        var columnDefs = [
            nameCol('name', 'Наименование'),
            { headerName: 'Ед. изм.', field: 'measurement_unit', width: 100, filter: 'agTextColumnFilter' },
            { headerName: 'Описание', field: 'description', flex: 1, minWidth: 120, filter: 'agTextColumnFilter' },
            makeArchivedBadgeCol(),
            makeActionsCol('Архивировать?'),
        ];
        createGrid(container, dataUrl, columnDefs);
    }

    function createGrid(container, dataUrl, columnDefs) {
        var utils = window.SectionGridUtils;
        if (!utils || !utils.prepareContainer(container)) {
            return;
        }
        var gridOpts = {
            columnDefs: columnDefs,
            theme: 'legacy',
            animateRows: true,
            defaultColDef: utils.mergeDefaultColDef(),
            pagination: false,
            domLayout: 'normal',
            getRowHeight: function() { return 36; },
            localeText: localeTextRu,
            sideBar: 'columns',
            onGridReady: function(params) {
                utils.registerApi(container.id, params.api);
                fetch(dataUrl)
                    .then(function(r) { return r.json(); })
                    .then(function(result) {
                        if (result && result.success && result.data) {
                            params.api.setGridOption('rowData', result.data);
                        } else {
                            params.api.setGridOption('rowData', []);
                        }
                    })
                    .catch(function(err) { console.error('AG Grid (справочник): ошибка загрузки', err); });
            },
        };
        var createGridFn = window.iasCreateGrid || (window.AgGridFilter && window.AgGridFilter.iasCreateGrid);
        (typeof createGridFn === 'function' ? createGridFn : agGrid.createGrid.bind(agGrid))(container, gridOpts);
    }

    function init() {
        var inits = {
            agGridRefTaskStatus: initTaskStatus,
            agGridRefLocations: initLocations,
            agGridRefEquipmentStatus: initEquipmentStatus,
            agGridRefParts: initParts,
            agGridRefChars: initChars,
        };
        Object.keys(inits).forEach(function(id) {
            var el = document.getElementById(id);
            if (el && inits[id]) {
                inits[id](el);
            }
        });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() { setTimeout(init, 100); });
    } else {
        setTimeout(init, 100);
    }
})();
