/**
 * AG Grid — список поставок (как «Учёт ТС»).
 */
(function() {
    'use strict';

    var quickFilterTimer = null;
    var listApi = null;
    var currentStatus = '';

    function escapeHtml(str) {
        var div = document.createElement('div');
        div.textContent = str;
        return div.innerHTML;
    }

    function getContainer() {
        return document.getElementById('agGridDeliveryContainer');
    }

    function buildDeliveryCardLink(id, innerHtml) {
        return '<a href="#" class="delivery-link-to-card" data-delivery-id="'
            + encodeURIComponent(id) + '">' + innerHtml + '</a>';
    }

    function getListDataUrl() {
        var container = getContainer();
        if (!container) {
            return '';
        }
        var base = container.dataset.baseUrl || '';
        if (currentStatus) {
            base += (base.indexOf('?') >= 0 ? '&' : '?') + 'status=' + encodeURIComponent(currentStatus);
        }
        return base;
    }

    function syncDataUrl() {
        var container = getContainer();
        if (container) {
            container.dataset.url = getListDataUrl();
        }
    }

    function initQuickFilter() {
        var input = document.getElementById('deliveryQuickFilter');
        if (!input || !listApi) {
            return;
        }
        input.addEventListener('input', function() {
            clearTimeout(quickFilterTimer);
            quickFilterTimer = setTimeout(function() {
                listApi.setGridOption('quickFilterText', input.value);
                if (window.deliveryUpdatePageChrome) {
                    window.deliveryUpdatePageChrome();
                }
            }, 200);
        });
    }

    function initStatusTabs() {
        document.querySelectorAll('.delivery-status-tab').forEach(function(tab) {
            tab.addEventListener('click', function(e) {
                e.preventDefault();
                document.querySelectorAll('.delivery-status-tab').forEach(function(t) {
                    t.classList.remove('active');
                    t.setAttribute('aria-selected', 'false');
                });
                tab.classList.add('active');
                tab.setAttribute('aria-selected', 'true');
                currentStatus = tab.getAttribute('data-status') || '';
                syncDataUrl();
                reloadListGrid();
            });
        });
    }

    function reloadListGrid() {
        var container = getContainer();
        if (!container || !listApi) {
            return;
        }
        var url = getListDataUrl();
        fetch(url)
            .then(function(r) { return r.json(); })
            .then(function(result) {
                listApi.setGridOption('rowData', (result && result.success && result.data) ? result.data : []);
            })
            .catch(function(err) { console.error('Delivery list', err); });
    }

    function init() {
        var container = getContainer();
        var utils = window.SectionGridUtils;
        if (!container || !utils) {
            return;
        }

        syncDataUrl();
        if (!utils.prepareContainer(container)) {
            return;
        }

        var cardTpl = container.dataset.cardModalUrlTemplate || '';
        var dataUrl = container.dataset.url || getListDataUrl();

        var columnDefs = [
            {
                headerName: 'Название',
                field: 'name',
                flex: 1,
                minWidth: 200,
                filter: 'agTextColumnFilter',
                cellRenderer: function(params) {
                    if (!params.data || params.data.id == null) {
                        return escapeHtml(params.value || '');
                    }
                    var text = params.value || '—';
                    return buildDeliveryCardLink(params.data.id, escapeHtml(String(text)));
                },
                tooltipField: 'name',
            },
            { headerName: 'Поставщик', field: 'supplier', width: 150, filter: 'agTextColumnFilter' },
            {
                headerName: 'Дата',
                field: 'delivery_date',
                width: 110,
                filter: 'agTextColumnFilter',
            },
            { headerName: 'Статус', field: 'status_label', width: 110 },
            { headerName: 'Единиц', field: 'units_total', width: 85 },
        ];

        var gridOpts = {
            columnDefs: columnDefs,
            theme: 'legacy',
            animateRows: true,
            defaultColDef: utils.mergeDefaultColDef(),
            pagination: true,
            paginationPageSize: 20,
            paginationPageSizeSelector: [10, 20, 50, 100],
            domLayout: 'normal',
            getRowHeight: function() { return 36; },
            onGridReady: function(params) {
                listApi = params.api;
                window.deliveryListGridApi = listApi;
                utils.registerApi(container.id, params.api);
                fetch(dataUrl)
                    .then(function(r) { return r.json(); })
                    .then(function(result) {
                        params.api.setGridOption('rowData', (result && result.success && result.data) ? result.data : []);
                    })
                    .catch(function(err) { console.error('Delivery grid', err); });
                initQuickFilter();
                initStatusTabs();

                container.addEventListener('click', function(e) {
                    var link = e.target.closest('.delivery-link-to-card');
                    if (!link || !link.dataset.deliveryId) {
                        return;
                    }
                    if (typeof window.openDeliveryCardModal === 'function') {
                        e.preventDefault();
                        window.openDeliveryCardModal(link.dataset.deliveryId);
                    }
                });

                var openId = container.dataset.openDeliveryId;
                if (openId && typeof window.openDeliveryCardModal === 'function') {
                    window.openDeliveryCardModal(openId);
                }
            },
        };

        var createGrid = window.iasCreateGrid || (window.AgGridFilter && window.AgGridFilter.iasCreateGrid);
        (typeof createGrid === 'function' ? createGrid : agGrid.createGrid.bind(agGrid))(container, gridOpts);
    }

    window.refreshDeliveryGrid = function() {
        syncDataUrl();
        reloadListGrid();
    };

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() { setTimeout(init, 100); });
    } else {
        setTimeout(init, 100);
    }
})();
