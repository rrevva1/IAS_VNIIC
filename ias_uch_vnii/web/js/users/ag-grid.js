/**
 * AG Grid для страницы «Пользователи».
 */
(function() {
    'use strict';

    var gridApi;

    function buildUrl(baseUrl, id) {
        if (!baseUrl) {
            return '';
        }
        var sep = baseUrl.indexOf('?') === -1 ? '?' : '&';
        return baseUrl + sep + 'id=' + encodeURIComponent(id);
    }

    function emailRenderer(params) {
        var value = params.value;
        if (!value) {
            return '';
        }
        return '<a href="mailto:' + value + '">' + value + '</a>';
    }

    function actionsRenderer(params) {
        if (!params.data || !params.data.id) {
            return '';
        }
        var id = params.data.id;
        var viewHref = buildUrl(params.context.viewUrl, id);
        var updateHref = buildUrl(params.context.updateUrl, id);
        var deleteHref = buildUrl(params.context.deleteUrl, id);

        return ''
            + '<div class="ag-actions">'
            + '<a class="btn btn-sm btn-outline-secondary" href="' + viewHref + '"'
            + ' title="Просмотр" aria-label="Просмотр"><i class="fas fa-eye" aria-hidden="true"></i></a>'
            + '<a class="btn btn-sm btn-outline-primary" href="' + updateHref + '"'
            + ' title="Изменить" aria-label="Изменить"><i class="fas fa-pen" aria-hidden="true"></i></a>'
            + '<a class="btn btn-sm btn-outline-danger" href="' + deleteHref + '"'
            + ' title="Удалить" aria-label="Удалить" data-method="post"'
            + ' data-confirm="Удалить пользователя?"><i class="fas fa-trash" aria-hidden="true"></i></a>'
            + '</div>';
    }

    function getColumnDefs() {
        return [
            { headerName: 'ID', field: 'id', width: 90, filter: 'agNumberColumnFilter' },
            { headerName: 'ФИО', field: 'full_name', flex: 1, minWidth: 180, filter: 'agTextColumnFilter' },
            { headerName: 'Email', field: 'email', flex: 1, minWidth: 200, filter: 'agTextColumnFilter', cellRenderer: emailRenderer },
            { headerName: 'Роль', field: 'role_name', width: 180, filter: 'agTextColumnFilter' },
            { headerName: 'Пароль', field: 'password_mask', width: 120, sortable: false, filter: false, valueGetter: function() { return '••••••••'; } },
            { headerName: 'Действия', field: 'actions', width: 118, minWidth: 110, sortable: false, filter: false, cellRenderer: actionsRenderer },
        ];
    }

    function loadGridData(url) {
        if (!gridApi || !url) {
            return;
        }
        fetch(url)
            .then(function(r) { return r.ok ? r.json() : Promise.reject(new Error('HTTP ' + r.status)); })
            .then(function(result) {
                if (result && result.success && result.data) {
                    gridApi.setGridOption('rowData', result.data);
                } else {
                    gridApi.setGridOption('rowData', []);
                }
            })
            .catch(function(err) { console.error('AG Grid (Пользователи): ошибка загрузки', err); });
    }

    function init() {
        var container = document.getElementById('agGridUsersContainer');
        if (!container || typeof agGrid === 'undefined') {
            if (container) {
                container.innerHTML = '<p class="text-muted">Загрузка таблицы...</p>';
            }
            return;
        }

        var viewUrl = container.dataset.viewUrl || '/index.php?r=users/view';
        var updateUrl = container.dataset.updateUrl || '/index.php?r=users/update';
        var deleteUrl = container.dataset.deleteUrl || '/index.php?r=users/delete';

        var gridOptions = {
            columnDefs: getColumnDefs(),
            defaultColDef: { sortable: true, filter: true, resizable: true },
            initialState: {
                sort: {
                    sortModel: [{ colId: 'full_name', sort: 'asc' }],
                },
            },
            getQuickFilterText: function(params) {
                if (!params.data) {
                    return '';
                }
                var d = params.data;
                return [d.id, d.full_name, d.email, d.role_name].filter(function(v) {
                    return v != null && v !== '';
                }).join(' ');
            },
            pagination: true,
            paginationPageSize: 20,
            paginationPageSizeSelector: [10, 20, 50, 100],
            domLayout: 'normal',
            rowHeight: 36,
            localeText: {
                page: 'Страница', to: 'до', of: 'из', next: 'След.', last: 'Последняя',
                first: 'Первая', previous: 'Пред.', loadingOoo: 'Загрузка...',
                noRowsToShow: 'Нет данных', filterOoo: 'Фильтр...', pageSizeSelectorLabel: 'Строк:',
            },
            context: {
                viewUrl: viewUrl,
                updateUrl: updateUrl,
                deleteUrl: deleteUrl,
            },
            onGridReady: function(params) {
                gridApi = params.api;
                window.usersGridApi = gridApi;
                var dataUrl = typeof window.buildUsersDataUrl === 'function'
                    ? window.buildUsersDataUrl()
                    : (container.dataset.url || '/index.php?r=users/get-grid-data');
                loadGridData(dataUrl);
            },
        };

        container.innerHTML = '';
        agGrid.createGrid(container, gridOptions);
    }

    window.refreshUsersGrid = function() {
        if (!gridApi) {
            return;
        }
        var dataUrl = typeof window.buildUsersDataUrl === 'function'
            ? window.buildUsersDataUrl()
            : '/index.php?r=users/get-grid-data';
        loadGridData(dataUrl);
    };

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() { setTimeout(init, 100); });
    } else {
        setTimeout(init, 100);
    }
})();
