/**
 * AG Grid для телефонного справочника.
 */
(function() {
    'use strict';

    var gridApi;
    var fitTimer = null;
    var suppressFitUntil = 0;

    function escapeHtml(text) {
        if (text == null) {
            return '';
        }
        var div = document.createElement('div');
        div.textContent = String(text);
        return div.innerHTML;
    }

    function emptyDash(value) {
        if (value == null || String(value).trim() === '') {
            return '<span class="users-grid-empty">—</span>';
        }
        return escapeHtml(value);
    }

    function phoneRenderer(params) {
        var value = params.value;
        if (!value) {
            return '<span class="users-grid-empty">—</span>';
        }
        var display = String(value);
        var tel = display.replace(/[^\d+]/g, '');
        var html = tel
            ? '<a class="phone-directory-tel" href="tel:' + escapeHtml(tel) + '">' + escapeHtml(display) + '</a>'
            : escapeHtml(display);
        html += ' <button type="button" class="btn btn-sm btn-link phone-directory-copy" data-copy="'
            + escapeHtml(display) + '" title="Копировать номер" aria-label="Копировать номер">'
            + '<i class="fas fa-copy" aria-hidden="true"></i></button>';
        return html;
    }

    function actionsRenderer(params) {
        if (!params.context || !params.context.isAdmin || !params.data || !params.data.id) {
            return '';
        }
        var id = params.data.id;
        return ''
            + '<div class="ag-actions">'
            + '<button type="button" class="btn btn-sm btn-outline-primary" data-pd-edit="' + id + '"'
            + ' title="Редактировать" aria-label="Редактировать"><i class="fas fa-pen" aria-hidden="true"></i></button>'
            + '<button type="button" class="btn btn-sm btn-outline-danger" data-pd-delete="' + id + '"'
            + ' title="Удалить" aria-label="Удалить"><i class="fas fa-xmark" aria-hidden="true"></i></button>'
            + '</div>';
    }

    function getColumnDefs(isAdmin) {
        var cols = [
            {
                headerName: 'ФИО / название',
                field: 'full_name',
                minWidth: 160,
                filter: 'agTextColumnFilter',
                cellRenderer: function(params) {
                    return emptyDash(params.value);
                },
            },
            {
                headerName: 'Должность',
                field: 'position',
                minWidth: 120,
                filter: 'agTextColumnFilter',
                cellRenderer: function(params) { return emptyDash(params.value); },
            },
            {
                headerName: 'Подразделение',
                field: 'department',
                minWidth: 120,
                filter: 'agTextColumnFilter',
                cellRenderer: function(params) { return emptyDash(params.value); },
            },
            {
                headerName: 'Кабинет',
                field: 'room',
                minWidth: 90,
                filter: 'agTextColumnFilter',
                cellRenderer: function(params) { return emptyDash(params.value); },
            },
            {
                headerName: 'Внутренний номер',
                field: 'internal_phone',
                minWidth: 130,
                filter: 'agTextColumnFilter',
                cellRenderer: phoneRenderer,
            },
            {
                headerName: 'Тип',
                field: 'entry_type_label',
                minWidth: 110,
                maxWidth: 150,
                filter: 'agTextColumnFilter',
            },
        ];

        if (isAdmin) {
            cols.push({
                headerName: 'Действия',
                field: 'actions',
                minWidth: 100,
                maxWidth: 120,
                pinned: 'right',
                sortable: false,
                filter: false,
                suppressHeaderMenuButton: true,
                cellRenderer: actionsRenderer,
            });
        }

        return cols;
    }

    function fitColumns(force) {
        clearTimeout(fitTimer);
        fitTimer = setTimeout(function() {
            if (!force && Date.now() < suppressFitUntil) {
                return;
            }
            if (!gridApi) {
                return;
            }
            var container = document.getElementById('agGridPhoneDirectoryContainer');
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
            }
            if (typeof gridApi.sizeColumnsToFit === 'function') {
                try {
                    gridApi.sizeColumnsToFit();
                } catch (e) {
                    console.warn('AG Grid (справочник): sizeColumnsToFit', e);
                }
            }
        }, 50);
    }

    function updateLastUpdated(value) {
        var el = document.getElementById('phoneDirectoryLastUpdated');
        if (!el || !value) {
            return;
        }
        var time = el.querySelector('time');
        if (!time) {
            return;
        }
        time.setAttribute('datetime', value);
        try {
            var d = new Date(value);
            if (!isNaN(d.getTime())) {
                var pad = function(n) { return n < 10 ? '0' + n : String(n); };
                time.textContent = pad(d.getDate()) + '.' + pad(d.getMonth() + 1) + '.' + d.getFullYear()
                    + ' ' + pad(d.getHours()) + ':' + pad(d.getMinutes());
                return;
            }
        } catch (e) { /* ignore */ }
        time.textContent = String(value);
    }

    function copyText(text) {
        if (!text) {
            return;
        }
        if (navigator.clipboard && navigator.clipboard.writeText) {
            navigator.clipboard.writeText(text).then(function() {
                if (window.yii && window.yii.alert) {
                    return;
                }
            }).catch(function() {});
            return;
        }
        var ta = document.createElement('textarea');
        ta.value = text;
        document.body.appendChild(ta);
        ta.select();
        try {
            document.execCommand('copy');
        } catch (e) { /* ignore */ }
        document.body.removeChild(ta);
    }

    function csrfParams() {
        var param = (window.yii && window.yii.getCsrfParam) ? window.yii.getCsrfParam() : '_csrf';
        var token = (window.yii && window.yii.getCsrfToken) ? window.yii.getCsrfToken() : '';
        var body = {};
        body[param] = token;
        return body;
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
                    if (result.last_updated) {
                        updateLastUpdated(result.last_updated);
                    }
                } else {
                    gridApi.setGridOption('rowData', []);
                }
                fitColumns(true);
            })
            .catch(function(err) {
                console.error('AG Grid (справочник): ошибка загрузки', err);
                gridApi.setGridOption('rowData', []);
            });
    }

    function bindContainerActions(container) {
        container.addEventListener('click', function(e) {
            var copyBtn = e.target.closest('[data-copy]');
            if (copyBtn) {
                e.preventDefault();
                copyText(copyBtn.getAttribute('data-copy'));
                return;
            }

            var editBtn = e.target.closest('[data-pd-edit]');
            if (editBtn && typeof window.openPhoneDirectoryEditModal === 'function') {
                e.preventDefault();
                window.openPhoneDirectoryEditModal(editBtn.getAttribute('data-pd-edit'));
                return;
            }

            var deleteBtn = e.target.closest('[data-pd-delete]');
            if (deleteBtn) {
                e.preventDefault();
                var id = deleteBtn.getAttribute('data-pd-delete');
                if (!id || !confirm('Удалить запись из справочника?')) {
                    return;
                }
                var deleteUrl = container.dataset.deleteUrl || '';
                var sep = deleteUrl.indexOf('?') >= 0 ? '&' : '?';
                var body = csrfParams();
                fetch(deleteUrl + sep + 'id=' + encodeURIComponent(id), {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
                        'X-Requested-With': 'XMLHttpRequest',
                    },
                    body: Object.keys(body).map(function(k) {
                        return encodeURIComponent(k) + '=' + encodeURIComponent(body[k]);
                    }).join('&'),
                })
                    .then(function(r) { return r.json(); })
                    .then(function(result) {
                        if (result && result.success) {
                            window.refreshPhoneDirectoryGrid();
                        } else {
                            alert((result && result.message) || 'Не удалось удалить запись');
                        }
                    })
                    .catch(function() {
                        alert('Ошибка при удалении записи');
                    });
            }
        });
    }

    function initAdminToolbar(container) {
        var createBtn = document.getElementById('phoneDirectoryCreateBtn');
        if (createBtn && typeof window.openPhoneDirectoryCreateModal === 'function') {
            createBtn.addEventListener('click', function() {
                window.openPhoneDirectoryCreateModal();
            });
        }

        var syncBtn = document.getElementById('phoneDirectorySyncBtn');
        if (syncBtn) {
            syncBtn.addEventListener('click', function() {
                if (!confirm('Синхронизировать записи сотрудников из пользователей системы?')) {
                    return;
                }
                var syncUrl = container.dataset.syncUrl || '';
                var body = csrfParams();
                syncBtn.disabled = true;
                fetch(syncUrl, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
                        'X-Requested-With': 'XMLHttpRequest',
                    },
                    body: Object.keys(body).map(function(k) {
                        return encodeURIComponent(k) + '=' + encodeURIComponent(body[k]);
                    }).join('&'),
                })
                    .then(function(r) { return r.json(); })
                    .then(function(result) {
                        alert((result && result.message) || 'Готово');
                        if (result && result.success) {
                            window.refreshPhoneDirectoryGrid();
                        }
                    })
                    .catch(function() {
                        alert('Ошибка синхронизации');
                    })
                    .finally(function() {
                        syncBtn.disabled = false;
                    });
            });
        }
    }

    function init() {
        var container = document.getElementById('agGridPhoneDirectoryContainer');
        if (!container || typeof agGrid === 'undefined') {
            if (container) {
                container.innerHTML = '<p class="text-muted p-4">Не удалось загрузить таблицу. Обновите страницу.</p>';
            }
            return;
        }

        var isAdmin = container.dataset.isAdmin === '1';

        var gridOptions = {
            columnDefs: getColumnDefs(isAdmin),
            animateRows: true,
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
            pagination: false,
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
                noRowsToShow: 'Нет записей в справочнике',
                filterOoo: 'Фильтр…',
            },
            context: {
                isAdmin: isAdmin,
            },
            onGridReady: function(params) {
                gridApi = params.api;
                window.phoneDirectoryGridApi = gridApi;
                container.classList.remove('users-grid-loading');
                var dataUrl = typeof window.buildPhoneDirectoryDataUrl === 'function'
                    ? window.buildPhoneDirectoryDataUrl()
                    : (container.dataset.url || '/index.php?r=phone-directory/get-grid-data');
                loadGridData(dataUrl);
            },
            onFirstDataRendered: function() {
                fitColumns(true);
            },
            onGridSizeChanged: function() {
                fitColumns();
            },
            onColumnResized: function(event) {
                if (event && event.finished) {
                    suppressFitUntil = Date.now() + 3000;
                }
            },
        };

        var createGrid = (window.iasCreateGrid || (window.AgGridFilter && window.AgGridFilter.iasCreateGrid));
        if (typeof createGrid === 'function') {
            createGrid(container, gridOptions);
        } else {
            agGrid.createGrid(container, gridOptions);
        }

        bindContainerActions(container);
        if (isAdmin) {
            initAdminToolbar(container);
        }

        window.addEventListener('resize', function() {
            suppressFitUntil = 0;
            fitColumns(true);
        });
    }

    window.refreshPhoneDirectoryGrid = function() {
        if (!gridApi) {
            return;
        }
        var dataUrl = typeof window.buildPhoneDirectoryDataUrl === 'function'
            ? window.buildPhoneDirectoryDataUrl()
            : '/index.php?r=phone-directory/get-grid-data';
        loadGridData(dataUrl);
    };

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() { setTimeout(init, 100); });
    } else {
        setTimeout(init, 100);
    }
})();
