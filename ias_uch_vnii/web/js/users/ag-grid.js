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
        var container = document.createElement('div');
        container.className = 'ag-actions';
        container.style.display = 'flex';
        container.style.gap = '8px';
        container.style.alignItems = 'center';

        var viewLink = document.createElement('a');
        viewLink.href = buildUrl(params.context.viewUrl, id);
        viewLink.textContent = '🔍';
        viewLink.title = 'Показать';
        viewLink.setAttribute('aria-label', 'Показать');

        var updateLink = document.createElement('a');
        updateLink.href = buildUrl(params.context.updateUrl, id);
        updateLink.textContent = '✏️';
        updateLink.title = 'Изменить';
        updateLink.setAttribute('aria-label', 'Изменить');

        var deleteLink = document.createElement('a');
        deleteLink.href = buildUrl(params.context.deleteUrl, id);
        deleteLink.textContent = '🗑️';
        deleteLink.title = 'Удалить';
        deleteLink.setAttribute('aria-label', 'Удалить');
        deleteLink.setAttribute('data-confirm', 'Удалить пользователя?');
        deleteLink.setAttribute('data-method', 'post');

        container.appendChild(viewLink);
        container.appendChild(updateLink);
        container.appendChild(deleteLink);

        return container;
    }

    function getColumnDefs() {
        return [
            { headerName: 'ID', field: 'id', width: 90, filter: 'agNumberColumnFilter' },
            { headerName: 'ФИО', field: 'full_name', flex: 1, minWidth: 180, filter: 'agTextColumnFilter' },
            { headerName: 'Email', field: 'email', flex: 1, minWidth: 200, filter: 'agTextColumnFilter', cellRenderer: emailRenderer },
            { headerName: 'Роль', field: 'role_name', width: 180, filter: 'agTextColumnFilter' },
            { headerName: 'Пароль', field: 'password_mask', width: 120, sortable: false, filter: false, valueGetter: function() { return '••••••••'; } },
            { headerName: 'Действия', field: 'actions', width: 140, sortable: false, filter: false, cellRenderer: actionsRenderer },
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

        var dataUrl = container.dataset.url || '/index.php?r=users/get-grid-data';
        var viewUrl = container.dataset.viewUrl || '/index.php?r=users/view';
        var updateUrl = container.dataset.updateUrl || '/index.php?r=users/update';
        var deleteUrl = container.dataset.deleteUrl || '/index.php?r=users/delete';

        var gridOptions = {
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
            context: {
                viewUrl: viewUrl,
                updateUrl: updateUrl,
                deleteUrl: deleteUrl,
            },
            onGridReady: function(params) {
                gridApi = params.api;
                loadGridData(dataUrl);
            },
        };

        container.innerHTML = '';
        agGrid.createGrid(container, gridOptions);
    }

    window.refreshUsersGrid = function() {
        var container = document.getElementById('agGridUsersContainer');
        if (!container || !gridApi) {
            return;
        }
        var dataUrl = container.dataset.url || '/index.php?r=users/get-grid-data';
        loadGridData(dataUrl);
    };

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() { setTimeout(init, 100); });
    } else {
        setTimeout(init, 100);
    }
})();
