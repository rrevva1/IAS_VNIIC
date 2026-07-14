/**
 * AG Grid для страницы «Карточки пользователей».
 */
(function() {
    'use strict';

    var gridApi;

    function escapeHtml(str) {
        var div = document.createElement('div');
        div.textContent = str == null ? '' : String(str);
        return div.innerHTML;
    }

    function buildDataUrl(limit, offset, sortModel) {
        var base = window.userEquipmentCardsDataUrl || '/index.php?r=user-equipment-cards/get-grid-data';
        var sep = base.indexOf('?') >= 0 ? '&' : '?';
        var query = [
            'limit=' + encodeURIComponent(limit),
            'offset=' + encodeURIComponent(offset),
            'tab=' + encodeURIComponent(window.userEquipmentCardsTab || 'all'),
            'q=' + encodeURIComponent(window.userEquipmentCardsSearch || ''),
        ];
        if (Array.isArray(sortModel) && sortModel.length > 0) {
            query.push('sortModel=' + encodeURIComponent(JSON.stringify(sortModel)));
        }
        return base + sep + query.join('&');
    }

    function statusRenderer(params) {
        var isSigned = !!params.value;
        var tone = isSigned ? 'green' : 'yellow';
        var text = isSigned ? 'Подписана' : 'Не подписана';
        return '<span class="uec-status-badge uec-status-badge--' + tone + '">' + text + '</span>';
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
            + '<div class="ag-actions">'
            + '<a class="btn btn-sm btn-outline-secondary" href="' + downloadUrl + '"'
            + ' title="Скачать DOCX" aria-label="Скачать DOCX">'
            + '<i class="fas fa-file-word" aria-hidden="true"></i></a>';
        if (!row.is_signed) {
            html += '<button class="btn btn-sm btn-outline-primary js-card-sign" data-card-id="' + cardId + '"'
                + ' title="Подписать" aria-label="Подписать">'
                + '<i class="fas fa-check" aria-hidden="true"></i></button>';
        }
        html += '</div>';
        return html;
    }

    function userNameRenderer(params) {
        if (!params.data || !params.data.user_id) {
            return escapeHtml(params.value || '');
        }
        var name = params.value || '—';
        return '<button type="button" class="uec-grid-user-link" data-uec-user-id="'
            + encodeURIComponent(params.data.user_id) + '" data-uec-user-name="'
            + encodeURIComponent(name) + '" title="Закреплённая техника">'
            + escapeHtml(name) + '</button>';
    }

    function getColumnDefs() {
        return [
            { headerName: '#', field: 'id', width: 90, filter: 'agNumberColumnFilter' },
            { headerName: 'Пользователь', field: 'user_name', flex: 1, minWidth: 250, filter: 'agTextColumnFilter', cellRenderer: userNameRenderer },
            { headerName: 'Статус подписи', field: 'is_signed', width: 150, filter: false, sortable: false, cellRenderer: statusRenderer },
            { headerName: 'Кто подтвердил', field: 'signed_by_admin', width: 180, filter: 'agTextColumnFilter' },
            { headerName: 'Обновлено', field: 'updated_at', width: 180, filter: 'agTextColumnFilter' },
            { headerName: 'Действия', field: 'actions', width: 120, minWidth: 110, maxWidth: 140, filter: false, sortable: false, cellRenderer: actionsRenderer },
        ];
    }

    function loadGridData() {
        if (!gridApi) {
            return;
        }
        fetch(buildDataUrl(50000, 0, []))
            .then(function(r) { return r.ok ? r.json() : Promise.reject(new Error('HTTP ' + r.status)); })
            .then(function(result) {
                if (!result || !result.success || !Array.isArray(result.data)) {
                    return Promise.reject(new Error((result && result.message) || 'Invalid response'));
                }
                gridApi.setGridOption('rowData', result.data);
            })
            .catch(function(err) {
                console.error('AG Grid (Карточки): ошибка загрузки', err);
                gridApi.setGridOption('rowData', []);
            });
    }

    function reloadGrid(resetPage) {
        loadGridData(resetPage);
    }

    window.refreshUserEquipmentCardsGrid = function() {
        reloadGrid(true);
    };

    function setActiveTab(tab) {
        document.querySelectorAll('.uec-type-tab').forEach(function(link) {
            var isActive = link.getAttribute('data-tab') === tab;
            link.classList.toggle('active', isActive);
            link.setAttribute('aria-selected', isActive ? 'true' : 'false');
        });
    }

    function bindCommandBar() {
        var searchInput = document.getElementById('uecQuickFilter');
        var searchClear = document.getElementById('uecQuickFilterClear');
        var refreshBtn = document.getElementById('uecRefreshGrid');
        var debounceTimer;

        if (searchInput) {
            searchInput.addEventListener('input', function() {
                var value = searchInput.value.trim();
                if (searchClear) {
                    searchClear.hidden = value === '';
                }
                clearTimeout(debounceTimer);
                debounceTimer = setTimeout(function() {
                    window.userEquipmentCardsSearch = value;
                    reloadGrid(true);
                }, 300);
            });
        }

        if (searchClear && searchInput) {
            searchClear.addEventListener('click', function() {
                searchInput.value = '';
                searchClear.hidden = true;
                window.userEquipmentCardsSearch = '';
                reloadGrid(true);
                searchInput.focus();
            });
        }

        document.querySelectorAll('.uec-type-tab').forEach(function(link) {
            link.addEventListener('click', function(e) {
                e.preventDefault();
                var tab = link.getAttribute('data-tab') || 'all';
                window.userEquipmentCardsTab = tab;
                setActiveTab(tab);
                reloadGrid(true);
            });
        });

        if (refreshBtn) {
            refreshBtn.addEventListener('click', function() {
                reloadGrid(true);
            });
        }
    }

    function bindActions(container) {
        container.addEventListener('click', function(e) {
            var userBtn = e.target.closest && e.target.closest('.uec-grid-user-link');
            if (userBtn) {
                e.preventDefault();
                var userId = userBtn.getAttribute('data-uec-user-id');
                var userName = userBtn.getAttribute('data-uec-user-name') || '';
                try {
                    userName = decodeURIComponent(userName);
                } catch (err) {
                    userName = userBtn.textContent || '';
                }
                if (typeof window.openUserEquipmentModal === 'function') {
                    window.openUserEquipmentModal(userId, userName);
                }
                return;
            }

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

        var gridOptions = {
            columnDefs: getColumnDefs(),
            defaultColDef: { sortable: true, filter: true, resizable: true },
            animateRows: true,
            rowData: [],
            pagination: false,
            getRowHeight: function() { return 42; },
            getRowId: function(params) {
                if (!params || !params.data || params.data.id == null) {
                    return undefined;
                }
                return String(params.data.id);
            },
            localeText: {
                page: 'Страница', to: 'до', of: 'из', next: 'След.', last: 'Последняя',
                first: 'Первая', previous: 'Пред.', loadingOoo: 'Загрузка...',
                noRowsToShow: 'Нет данных', filterOoo: 'Фильтр...', pageSizeSelectorLabel: 'Строк:',
            },
            onGridReady: function(params) {
                gridApi = params.api;
                container.classList.remove('arm-grid-loading');
                loadGridData(true);
                bindActions(container);
                bindCommandBar();
            },
        };

        var createGrid = window.iasCreateGrid || (window.AgGridFilter && window.AgGridFilter.iasCreateGrid);
        (typeof createGrid === 'function' ? createGrid : agGrid.createGrid.bind(agGrid))(container, gridOptions);
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() { setTimeout(init, 100); });
    } else {
        setTimeout(init, 100);
    }
})();
