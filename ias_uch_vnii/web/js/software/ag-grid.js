/**
 * AG Grid для страницы «Лицензии ПО».
 */
(function() {
    'use strict';

    function escapeHtml(str) {
        var div = document.createElement('div');
        div.textContent = str;
        return div.innerHTML;
    }

    function formatDate(value) {
        if (!value) {
            return '—';
        }
        var parts = String(value).split('-');
        if (parts.length !== 3) {
            return value;
        }
        return parts[2] + '.' + parts[1] + '.' + parts[0];
    }

    function formatPeriod(from, until) {
        if (!from && !until) {
            return '—';
        }
        return (from ? formatDate(from) : '…') + ' — ' + (until ? formatDate(until) : '…');
    }

    function formatYearsShort(value) {
        if (value == null || value === '') {
            return '';
        }
        var num = Number(value);
        if (!isFinite(num) || num <= 0) {
            return '';
        }
        var rounded = Math.round(num * 10) / 10;
        var label = String(rounded).replace(/\.0$/, '').replace('.', ',');
        return label + ' г.';
    }

    function buildValidityCell(data) {
        if (!data) {
            return '—';
        }
        var status = data.expiry_status || '';
        if (status === 'perpetual') {
            return '<span class="badge bg-secondary">Бессрочная</span>';
        }

        var period = formatPeriod(data.valid_from, data.valid_until);
        var years = formatYearsShort(data.validity_years);
        var yearsHtml = years
            ? ' <span class="software-grid-validity__years text-muted">' + escapeHtml(years) + '</span>'
            : '';
        var badge = '';
        if (status === 'expired') {
            badge = ' <span class="badge bg-danger">Истекла</span>';
        } else if (status === 'expiring') {
            badge = ' <span class="badge bg-warning text-dark">Скоро</span>';
        }

        return '<div class="software-grid-validity">'
            + '<span class="software-grid-validity__period">' + escapeHtml(period) + '</span>'
            + yearsHtml
            + badge
            + '</div>';
    }

    function getDefaultExpiringDays() {
        var value = window.softwareExpiringDaysDefault;
        var days = parseInt(value, 10);
        return isFinite(days) && days > 0 ? days : 60;
    }

    function getFilterDataUrl() {
        var container = document.getElementById('agGridSoftwareContainer');
        if (!container) {
            return '';
        }
        var base = container.dataset.baseUrl || '/index.php?r=software/get-grid-data';
        var params = [];
        var filterRoot = document.getElementById('software-filter-form');
        if (filterRoot) {
            var activePreset = filterRoot.querySelector('.software-filter-preset.active');
            var expiringInput = filterRoot.querySelector('[name="expiring_days"]');
            var expiring = '';
            if (activePreset && activePreset.getAttribute('data-expiring-days') !== '') {
                expiring = expiringInput ? String(expiringInput.value || '').trim() : '';
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

    function applyExpiringFilter(expiringDays) {
        var filterRoot = document.getElementById('software-filter-form');
        if (!filterRoot) {
            return;
        }
        var expiringInput = filterRoot.querySelector('[name="expiring_days"]');
        var presets = filterRoot.querySelectorAll('.software-filter-preset');
        var days = expiringDays == null ? '' : String(expiringDays);
        presets.forEach(function(btn) {
            var presetDays = btn.getAttribute('data-expiring-days') || '';
            btn.classList.toggle('active', presetDays === days);
        });
        if (expiringInput) {
            if (days === '') {
                expiringInput.disabled = true;
            } else {
                expiringInput.disabled = false;
                if (!expiringInput.value) {
                    expiringInput.value = String(getDefaultExpiringDays());
                }
            }
        }
        syncDataUrl();
        if (window.SectionGridUtils) {
            window.SectionGridUtils.reload('agGridSoftwareContainer');
        }
    }

    function bindFilterControls() {
        var filterRoot = document.getElementById('software-filter-form');
        if (!filterRoot) {
            return;
        }
        filterRoot.addEventListener('click', function(e) {
            var presetBtn = e.target.closest('.software-filter-preset');
            if (!presetBtn) {
                return;
            }
            e.preventDefault();
            applyExpiringFilter(presetBtn.getAttribute('data-expiring-days') || '');
        });

        var expiringInput = filterRoot.querySelector('[name="expiring_days"]');
        if (expiringInput) {
            expiringInput.addEventListener('change', function() {
                var activePreset = filterRoot.querySelector('.software-filter-preset.active');
                if (!activePreset || activePreset.getAttribute('data-expiring-days') === '') {
                    return;
                }
                syncDataUrl();
                if (window.SectionGridUtils) {
                    window.SectionGridUtils.reload('agGridSoftwareContainer');
                }
            });
            expiringInput.addEventListener('keydown', function(e) {
                if (e.key !== 'Enter') {
                    return;
                }
                e.preventDefault();
                var activePreset = filterRoot.querySelector('.software-filter-preset.active');
                if (!activePreset || activePreset.getAttribute('data-expiring-days') === '') {
                    applyExpiringFilter(String(getDefaultExpiringDays()));
                    return;
                }
                syncDataUrl();
                if (window.SectionGridUtils) {
                    window.SectionGridUtils.reload('agGridSoftwareContainer');
                }
            });
        }
    }

    function syncDataUrl() {
        var container = document.getElementById('agGridSoftwareContainer');
        if (!container) {
            return;
        }
        container.dataset.url = getFilterDataUrl();
    }

    function csrfToken() {
        var meta = document.querySelector('meta[name="csrf-token"]');
        return meta ? meta.content : '';
    }

    function csrfParam() {
        var meta = document.querySelector('meta[name="csrf-param"]');
        return meta ? meta.getAttribute('content') : '_csrf';
    }

    function deleteLicense(licenseId) {
        var container = document.getElementById('agGridSoftwareContainer');
        var tpl = (container && container.dataset.licenseDeleteUrlTemplate)
            || '/index.php?r=software/license-delete&id=__ID__';
        var url = tpl.replace('__ID__', String(licenseId));
        var body = new URLSearchParams();
        var token = csrfToken();
        var param = csrfParam();
        if (token && param) {
            body.append(param, token);
        }
        return fetch(url, {
            method: 'POST',
            body: body,
            credentials: 'same-origin',
            headers: {
                'X-Requested-With': 'XMLHttpRequest',
                Accept: 'application/json',
            },
        }).then(function(r) { return r.json(); });
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

        var dataUrl = container.dataset.url;

        var columnDefs = [
            {
                headerName: 'Программное обеспечение',
                field: 'software_name',
                flex: 1,
                minWidth: 180,
                filter: 'agTextColumnFilter',
            },
            {
                headerName: 'Поставщик',
                field: 'supplier',
                width: 160,
                filter: 'agTextColumnFilter',
                valueFormatter: function(p) { return p.value || '—'; },
            },
            {
                headerName: 'Дата закупки',
                field: 'purchase_date',
                width: 130,
                valueFormatter: function(p) { return formatDate(p.value); },
            },
            {
                headerName: 'Срок действия',
                field: 'validity_display',
                width: 280,
                minWidth: 220,
                filter: 'agTextColumnFilter',
                cellRenderer: function(params) {
                    return buildValidityCell(params.data);
                },
            },
            {
                headerName: 'Кол-во',
                field: 'seats',
                width: 90,
                filter: 'agNumberColumnFilter',
            },
            {
                headerName: 'Техника',
                field: 'equipment_summary',
                flex: 1,
                minWidth: 160,
                filter: 'agTextColumnFilter',
                valueFormatter: function(p) { return p.value || '—'; },
            },
            {
                headerName: 'Действия',
                width: 170,
                sortable: false,
                filter: false,
                cellRenderer: function(params) {
                    if (!params.data || params.data.id == null) {
                        return '';
                    }
                    var id = params.data.id;
                    return '<button type="button" class="btn btn-sm btn-outline-primary"'
                        + ' data-software-license-edit="' + id + '">Изменить</button>'
                        + ' <button type="button" class="btn btn-sm btn-outline-danger"'
                        + ' data-software-license-delete="' + id + '">Удалить</button>';
                },
            },
        ];

        var gridOpts = {
            columnDefs: columnDefs,
            theme: 'legacy',
            animateRows: true,
            defaultColDef: utils.mergeDefaultColDef(),
            pagination: false,
            domLayout: 'normal',
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
                    .catch(function(err) { console.error('AG Grid (лицензии): ошибка загрузки', err); });
            },
        };
        var createGrid = window.iasCreateGrid || (window.AgGridFilter && window.AgGridFilter.iasCreateGrid);
        (typeof createGrid === 'function' ? createGrid : agGrid.createGrid.bind(agGrid))(container, gridOpts);

        bindFilterControls();

        var form = document.getElementById('software-filter-form');
        if (form) {
            form.addEventListener('submit', function(e) {
                e.preventDefault();
            });
        }

        container.addEventListener('click', function(e) {
            var deleteBtn = e.target.closest('[data-software-license-delete]');
            if (!deleteBtn) {
                return;
            }
            e.preventDefault();
            var licenseId = deleteBtn.getAttribute('data-software-license-delete');
            if (!licenseId || !window.confirm('Удалить эту лицензию?')) {
                return;
            }
            deleteLicense(licenseId).then(function(res) {
                if (res && res.success) {
                    window.refreshSoftwareGrid();
                    return;
                }
                alert((res && res.message) || 'Не удалось удалить лицензию');
            }).catch(function() {
                alert('Ошибка удаления лицензии');
            });
        });
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
