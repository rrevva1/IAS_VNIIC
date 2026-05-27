/**
 * AG Grid для страницы «Пользователи» (оформление как «Учёт ТС» / «Заявки»).
 */
(function() {
    'use strict';

    var gridApi;
    var usersFitColumnsTimer = null;
    /** Не пересчитывать ширину сразу после ручного изменения столбца. */
    var usersSuppressFitUntil = 0;

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
            { headerName: 'ID', field: 'id', minWidth: 64, maxWidth: 120, filter: 'agNumberColumnFilter' },
            { headerName: 'ФИО', field: 'full_name', minWidth: 120, filter: 'agTextColumnFilter' },
            {
                headerName: 'Электронная почта',
                field: 'email',
                minWidth: 140,
                filter: 'agTextColumnFilter',
                cellRenderer: emailRenderer,
            },
            {
                headerName: 'Роль',
                field: 'role_name',
                minWidth: 120,
                filter: 'agTextColumnFilter',
                cellRenderer: function(params) {
                    var roleName = (params && params.value != null) ? String(params.value) : '';
                    var roleCode = params && params.data && params.data.role_code ? String(params.data.role_code) : '';
                    var cls = 'users-role-badge';
                    if (roleCode === 'admin') {
                        cls += ' users-role-badge--admin';
                    } else if (roleCode === 'operator' || roleCode === 'support') {
                        cls += ' users-role-badge--operator';
                    } else if (roleCode === 'user') {
                        cls += ' users-role-badge--user';
                    } else {
                        cls += ' users-role-badge--other';
                    }
                    var text = roleName || '—';
                    return '<span class="' + cls + '">' + text + '</span>';
                },
            },
            {
                headerName: 'Действия',
                field: 'actions',
                minWidth: 110,
                maxWidth: 140,
                pinned: 'right',
                sortable: false,
                filter: false,
                suppressHeaderMenuButton: true,
                cellRenderer: actionsRenderer,
            },
        ];
    }

    function shouldSkipFitUsersColumns() {
        return Date.now() < usersSuppressFitUntil;
    }

    function markUsersColumnUserResize() {
        usersSuppressFitUntil = Date.now() + 3000;
    }

    function hideGridLoading(container) {
        if (container) {
            container.classList.remove('users-grid-loading');
        }
    }

    /**
     * 1) autoSize — ширина по содержимому (заголовок + ячейки);
     * 2) sizeColumnsToFit — растянуть на всю ширину таблицы с сохранением пропорций.
     */
    function fitUsersGridColumns(force) {
        clearTimeout(usersFitColumnsTimer);
        usersFitColumnsTimer = setTimeout(function() {
            if (!force && shouldSkipFitUsersColumns()) {
                return;
            }
            if (!gridApi) {
                return;
            }
            var container = document.getElementById('agGridUsersContainer');
            if (!container || container.clientWidth < 80) {
                return;
            }

            var colIds = [];
            if (typeof gridApi.getColumns === 'function') {
                gridApi.getColumns().forEach(function(col) {
                    colIds.push(col.getColId());
                });
            }

            if (colIds.length && typeof gridApi.autoSizeColumns === 'function') {
                gridApi.autoSizeColumns(colIds, false);
            } else if (typeof gridApi.autoSizeAllColumns === 'function') {
                gridApi.autoSizeAllColumns(false);
            }

            if (typeof gridApi.sizeColumnsToFit === 'function') {
                try {
                    gridApi.sizeColumnsToFit();
                } catch (e) {
                    console.warn('AG Grid (Пользователи): sizeColumnsToFit', e);
                }
            }
        }, 50);
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
                fitUsersGridColumns(true);
            })
            .catch(function(err) {
                console.error('AG Grid (Пользователи): ошибка загрузки', err);
                gridApi.setGridOption('rowData', []);
            });
    }

    function init() {
        var container = document.getElementById('agGridUsersContainer');
        if (!container || typeof agGrid === 'undefined') {
            if (container) {
                container.innerHTML = '<p class="text-muted p-4">Не удалось загрузить таблицу. Обновите страницу.</p>';
            }
            return;
        }

        var viewUrl = container.dataset.viewUrl || '/index.php?r=users/view';
        var updateUrl = container.dataset.updateUrl || '/index.php?r=users/update';
        var deleteUrl = container.dataset.deleteUrl || '/index.php?r=users/delete';

        var gridOptions = {
            columnDefs: getColumnDefs(),
            defaultColDef: {
                sortable: true,
                filter: true,
                resizable: true,
                wrapText: false,
                autoHeight: false,
            },
            suppressHorizontalScroll: false,
            alwaysShowHorizontalScroll: true,
            alwaysShowVerticalScroll: true,
            scrollbarWidth: 12,
            suppressCellFocus: true,
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
            localeText: {
                page: 'Страница',
                to: 'до',
                of: 'из',
                next: 'След.',
                last: 'Последняя',
                first: 'Первая',
                previous: 'Пред.',
                loadingOoo: 'Загрузка…',
                noRowsToShow: 'Нет пользователей',
                filterOoo: 'Фильтр…',
                pageSizeSelectorLabel: 'Строк на странице:',
            },
            context: {
                viewUrl: viewUrl,
                updateUrl: updateUrl,
                deleteUrl: deleteUrl,
            },
            onGridReady: function(params) {
                gridApi = params.api;
                window.usersGridApi = gridApi;
                hideGridLoading(container);
                var dataUrl = typeof window.buildUsersDataUrl === 'function'
                    ? window.buildUsersDataUrl()
                    : (container.dataset.url || '/index.php?r=users/get-grid-data');
                loadGridData(dataUrl);
            },
            onFirstDataRendered: function() {
                fitUsersGridColumns(true);
            },
            onGridSizeChanged: function() {
                fitUsersGridColumns();
            },
            onColumnResized: function(event) {
                if (event && event.finished) {
                    markUsersColumnUserResize();
                }
            },
        };

        agGrid.createGrid(container, gridOptions);

        window.addEventListener('resize', function() {
            usersSuppressFitUntil = 0;
            fitUsersGridColumns(true);
        });
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
