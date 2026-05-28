/**
 * AG Grid для страницы «ПО и лицензии».
 */
(function() {
    'use strict';

    function escapeHtml(str) {
        var div = document.createElement('div');
        div.textContent = str;
        return div.innerHTML;
    }

    function buildUrl(base, paramName, id) {
        if (!base) {
            return '#';
        }
        var sep = base.indexOf('?') >= 0 ? '&' : '?';
        return base + sep + paramName + '=' + encodeURIComponent(id);
    }

    function getFilterDataUrl() {
        var container = document.getElementById('agGridSoftwareContainer');
        if (!container) {
            return '';
        }
        var base = container.dataset.baseUrl || '/index.php?r=software/get-grid-data';
        var params = [];
        var form = document.getElementById('software-filter-form');
        if (form) {
            var name = (form.querySelector('[name="name"]') || {}).value;
            var expiring = (form.querySelector('[name="expiring_days"]') || {}).value;
            if (name) {
                params.push('name=' + encodeURIComponent(name));
            }
            if (expiring) {
                params.push('expiring_days=' + encodeURIComponent(expiring));
            }
        }
        if (params.length) {
            base += (base.indexOf('?') >= 0 ? '&' : '?') + params.join('&');
        }
        return base;
    }

    function syncDataUrl() {
        var container = document.getElementById('agGridSoftwareContainer');
        if (!container) {
            return;
        }
        var url = getFilterDataUrl();
        container.dataset.url = url;
    }

    function init() {
        var container = document.getElementById('agGridSoftwareContainer');
        var utils = window.SectionGridUtils;
        if (!container || !utils) {
            return;
        }

        syncDataUrl();

        if (!utils.prepareContainer(container)) {
            return;
        }

        var viewUrl = container.dataset.viewUrl || '';
        var licenseCreateUrl = container.dataset.licenseCreateUrl || '';
        var updateUrl = container.dataset.updateUrl || '';
        var dataUrl = container.dataset.url;

        var columnDefs = [
            { headerName: 'ID', field: 'id', width: 80, filter: 'agNumberColumnFilter' },
            {
                headerName: 'Наименование',
                field: 'name',
                flex: 1,
                minWidth: 200,
                filter: 'agTextColumnFilter',
                cellRenderer: function(params) {
                    if (!params.data || params.data.id == null) {
                        return params.value || '';
                    }
                    var text = params.value || '—';
                    var url = buildUrl(viewUrl, 'id', params.data.id);
                    return '<a href="' + url + '">' + escapeHtml(String(text)) + '</a>';
                },
            },
            {
                headerName: 'Версия',
                field: 'version',
                width: 120,
                filter: 'agTextColumnFilter',
                valueFormatter: function(p) { return p.value || '—'; },
            },
            {
                headerName: 'Лицензии',
                width: 140,
                sortable: false,
                filter: false,
                cellRenderer: function(params) {
                    if (!params.data) {
                        return '';
                    }
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
                    if (!params.data || params.data.id == null) {
                        return '';
                    }
                    var id = params.data.id;
                    var html = '<a href="' + buildUrl(viewUrl, 'id', id) + '" class="btn btn-sm btn-outline-primary">Просмотр</a>';
                    if (updateUrl) {
                        html += ' <a href="' + buildUrl(updateUrl, 'id', id) + '" class="btn btn-sm btn-outline-secondary">Изменить</a>';
                    }
                    return html;
                },
            },
        ];

        var gridOpts = {
            columnDefs: columnDefs,
            theme: 'legacy',
            animateRows: true,
            defaultColDef: utils.mergeDefaultColDef(),
            pagination: true,
            paginationPageSize: 20,
            paginationPageSizeSelector: [10, 20, 50, 100, 500],
            domLayout: 'normal',
            getRowHeight: function() { return 36; },
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
                    .catch(function(err) { console.error('AG Grid (ПО): ошибка загрузки', err); });
            },
        };
        agGrid.createGrid(container, gridOpts);

        var form = document.getElementById('software-filter-form');
        var applyBtn = document.getElementById('softwareApplyFilters');
        if (form) {
            form.addEventListener('submit', function(e) {
                e.preventDefault();
                syncDataUrl();
                utils.reload(container.id);
            });
        }
        if (applyBtn) {
            applyBtn.addEventListener('click', function() {
                syncDataUrl();
                utils.reload(container.id);
            });
        }
    }

    window.refreshSoftwareGrid = function() {
        syncDataUrl();
        if (window.SectionGridUtils) {
            window.SectionGridUtils.reload('agGridSoftwareContainer');
        }
    };

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() { setTimeout(init, 100); });
    } else {
        setTimeout(init, 100);
    }
})();
