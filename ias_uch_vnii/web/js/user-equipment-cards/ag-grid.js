/**
 * AG Grid для страницы «Карточки пользователей».
 */
(function() {
    'use strict';

    var gridApi;
    var currentPageSize = Number(window.userEquipmentCardsDefaultLimit || 20) || 20;

    function escapeHtml(str) {
        var div = document.createElement('div');
        div.textContent = str == null ? '' : String(str);
        return div.innerHTML;
    }

    function buildDataUrl(limit, offset) {
        var base = window.userEquipmentCardsDataUrl || '/index.php?r=user-equipment-cards/get-grid-data';
        var sep = base.indexOf('?') >= 0 ? '&' : '?';
        var query = [
            'limit=' + encodeURIComponent(limit),
            'offset=' + encodeURIComponent(offset),
            'tab=' + encodeURIComponent(window.userEquipmentCardsTab || 'all'),
            'q=' + encodeURIComponent(window.userEquipmentCardsSearch || ''),
        ];
        return base + sep + query.join('&');
    }

    function statusRenderer(params) {
        return params.value
            ? '<span class="badge bg-success">Подписана</span>'
            : '<span class="badge bg-warning text-dark">Не подписана</span>';
    }

    function actionsRenderer(params) {
        if (!params.data || !params.data.id) {
            return '';
        }
        var row = params.data;
        var cardId = Number(row.id);
        var userId = Number(row.user_id);
        var downloadUrl = '/index.php?r=user-equipment-cards/download&userId=' + encodeURIComponent(userId);

        var html = ''
            + '<div style="display:flex;align-items:center;gap:6px;min-width:190px;white-space:nowrap;">'
            + '<a class="btn btn-sm btn-outline-primary" style="line-height:1.1;padding:4px 8px;" href="' + downloadUrl + '">DOCX</a>';
        if (!row.is_signed) {
            html += '<button class="btn btn-sm btn-success js-card-sign" style="line-height:1.1;padding:4px 8px;" data-card-id="' + cardId + '">Подписать</button>';
        }
        html += '</div>';
        return html;
    }

    function getColumnDefs() {
        return [
            { headerName: '#', field: 'id', width: 90, filter: 'agNumberColumnFilter' },
            { headerName: 'Пользователь', field: 'user_name', flex: 1, minWidth: 250, filter: 'agTextColumnFilter' },
            { headerName: 'Версия', field: 'version_no', width: 100, filter: 'agNumberColumnFilter' },
            { headerName: 'Статус подписи', field: 'is_signed', width: 150, filter: false, sortable: false, cellRenderer: statusRenderer },
            { headerName: 'Подписано админом', field: 'signed_by_admin', width: 180, filter: 'agTextColumnFilter' },
            { headerName: 'Обновлено', field: 'updated_at', width: 180, filter: 'agTextColumnFilter' },
            { headerName: 'Действия', field: 'actions', width: 230, minWidth: 210, filter: false, sortable: false, cellRenderer: actionsRenderer },
        ];
    }

    function createDataSource() {
        return {
            getRows: function(params) {
                var startRow = params.startRow || 0;
                var endRow = params.endRow || (startRow + currentPageSize);
                var limit = Math.max(1, endRow - startRow);
                var offset = Math.max(0, startRow);

                fetch(buildDataUrl(limit, offset))
                    .then(function(r) { return r.ok ? r.json() : Promise.reject(new Error('HTTP ' + r.status)); })
                    .then(function(result) {
                        if (!result || !result.success || !Array.isArray(result.data)) {
                            return Promise.reject(new Error((result && result.message) || 'Invalid response'));
                        }
                        params.successCallback(result.data, Number(result.total || 0));
                    })
                    .catch(function(err) {
                        console.error('AG Grid (Карточки): ошибка загрузки', err);
                        params.failCallback();
                    });
            }
        };
    }

    function reloadGrid(resetPage) {
        if (!gridApi) {
            return;
        }
        if (resetPage && typeof gridApi.paginationGoToFirstPage === 'function') {
            gridApi.paginationGoToFirstPage();
        }
        if (typeof gridApi.setGridOption === 'function') {
            gridApi.setGridOption('datasource', createDataSource());
        } else if (typeof gridApi.setDatasource === 'function') {
            gridApi.setDatasource(createDataSource());
        }
    }

    function bindActions(container) {
        container.addEventListener('click', function(e) {
            var btn = e.target.closest && e.target.closest('.js-card-sign');
            if (!btn) {
                return;
            }
            e.preventDefault();

            var cardId = btn.getAttribute('data-card-id');
            if (!cardId) {
                return;
            }
            btn.disabled = true;
            fetch('/index.php?r=user-equipment-cards/mark-signed&id=' + encodeURIComponent(cardId), {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
                body: encodeURIComponent(window.userEquipmentCardsCsrfParam || '_csrf') + '=' + encodeURIComponent(window.userEquipmentCardsCsrfToken || ''),
            })
                .then(function(r) {
                    if (!r.ok) {
                        return Promise.reject(new Error('HTTP ' + r.status));
                    }
                    reloadGrid(false);
                })
                .catch(function(err) {
                    console.error('Подписание карточки: ошибка', err);
                    alert('Не удалось подтвердить подпись. Обновите страницу и попробуйте снова.');
                    btn.disabled = false;
                });
        });
    }

    function init() {
        var container = document.getElementById('agGridUserEquipmentCardsContainer');
        if (!container || typeof agGrid === 'undefined') {
            return;
        }

        container.innerHTML = '';
        var gridOptions = {
            columnDefs: getColumnDefs(),
            defaultColDef: { sortable: true, filter: true, resizable: true },
            rowModelType: 'infinite',
            cacheBlockSize: currentPageSize,
            maxBlocksInCache: 5,
            pagination: true,
            paginationPageSize: currentPageSize,
            paginationPageSizeSelector: [10, 20, 50, 100, 200],
            getRowHeight: function() { return 42; },
            localeText: {
                page: 'Страница', to: 'до', of: 'из', next: 'След.', last: 'Последняя',
                first: 'Первая', previous: 'Пред.', loadingOoo: 'Загрузка...',
                noRowsToShow: 'Нет данных', filterOoo: 'Фильтр...', pageSizeSelectorLabel: 'Строк:',
            },
            onGridReady: function(params) {
                gridApi = params.api;
                reloadGrid(true);
                bindActions(container);
            },
            onPaginationChanged: function() {
                if (!gridApi) {
                    return;
                }
                var pageSize = gridApi.paginationGetPageSize ? gridApi.paginationGetPageSize() : currentPageSize;
                if (pageSize !== currentPageSize) {
                    currentPageSize = pageSize;
                    gridApi.setGridOption('cacheBlockSize', currentPageSize);
                    reloadGrid(true);
                }
            },
        };

        agGrid.createGrid(container, gridOptions);
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() { setTimeout(init, 100); });
    } else {
        setTimeout(init, 100);
    }
})();
