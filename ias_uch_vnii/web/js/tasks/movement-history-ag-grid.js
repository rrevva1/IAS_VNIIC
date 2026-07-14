/**
 * AG Grid: таблица истории перемещений техники.
 */
(function() {
    'use strict';

    var localeTextRu = {
        page: 'Страница',
        to: 'до',
        of: 'из',
        next: 'След.',
        last: 'Последняя',
        first: 'Первая',
        previous: 'Пред.',
        loadingOoo: 'Загрузка...',
        noRowsToShow: 'Нет данных',
        filterOoo: 'Фильтр...',
        pageSizeSelectorLabel: 'Строк:',
    };

    function escapeHtml(str) {
        var div = document.createElement('div');
        div.textContent = str == null ? '' : String(str);
        return div.innerHTML;
    }

    function buildDataUrlWithPeriod(dataUrl) {
        try {
            var target = new URL(dataUrl, window.location.origin);
            var current = new URL(window.location.href);
            var from = current.searchParams.get('date_from');
            var to = current.searchParams.get('date_to');

            if (from) {
                target.searchParams.set('date_from', from);
            }
            if (to) {
                target.searchParams.set('date_to', to);
            }

            return target.toString();
        } catch (e) {
            return dataUrl;
        }
    }

    function estimateLinesByWidth(text, colWidth) {
        var value = text == null ? '' : String(text).trim();
        if (!value) {
            return 1;
        }
        var width = Math.max(56, Number(colWidth || 120) - 20);
        if (window.AgGridWrap && typeof window.AgGridWrap.estimateLines === 'function') {
            return Math.max(1, window.AgGridWrap.estimateLines(value, width));
        }
        return Math.max(1, Math.ceil(value.length / 22));
    }

    function getMovementRowLines(params) {
        if (!params || !params.data || !params.api || typeof params.api.getAllDisplayedColumns !== 'function') {
            return 1;
        }
        var cols = params.api.getAllDisplayedColumns() || [];
        var maxLines = 1;
        cols.forEach(function(col) {
            if (!col || typeof col.getColId !== 'function') {
                return;
            }
            var colId = col.getColId();
            if (!colId || colId === 'ag-Grid-SelectionColumn' || colId === 'row_num' || colId === 'moved_units') {
                return;
            }
            var value = params.data[colId];
            var width = typeof col.getActualWidth === 'function' ? col.getActualWidth() : 120;
            maxLines = Math.max(maxLines, estimateLinesByWidth(value, width));
        });
        return maxLines;
    }

    function applyQuickFilter(api, value) {
        if (!api) {
            return;
        }
        if (typeof api.setGridOption === 'function') {
            api.setGridOption('quickFilterText', value || '');
        } else if (typeof api.setQuickFilter === 'function') {
            api.setQuickFilter(value || '');
        }
    }

    function createMovementGrid(container, dataUrl) {
        if (!container || typeof agGrid === 'undefined') {
            return;
        }
        container.innerHTML = '';

        var columnDefs = [
            { headerName: 'Дата и время', field: 'moved_at', width: 170, minWidth: 150, filter: 'agTextColumnFilter', wrapText: true },
            { headerName: 'Откуда', field: 'from_location', width: 220, minWidth: 180, filter: 'agTextColumnFilter', wrapText: true },
            { headerName: 'Куда', field: 'to_location', width: 220, minWidth: 180, filter: 'agTextColumnFilter', wrapText: true },
            { headerName: 'От кого', field: 'from_responsible', width: 220, minWidth: 180, filter: 'agTextColumnFilter', wrapText: true },
            { headerName: 'Кому', field: 'to_responsible', width: 220, minWidth: 180, filter: 'agTextColumnFilter', wrapText: true },
            { headerName: 'Единиц техники', field: 'moved_units', width: 130, filter: 'agNumberColumnFilter' },
            {
                headerName: 'Техника',
                field: 'examples',
                width: 420,
                minWidth: 320,
                filter: 'agTextColumnFilter',
                wrapText: true,
                cellRenderer: function(params) {
                    var links = params && params.data && Array.isArray(params.data.example_links)
                        ? params.data.example_links
                        : [];
                    if (links.length > 0) {
                        return links.map(function(item) {
                            var id = item && item.id != null ? String(item.id) : '';
                            var label = item && item.label != null ? String(item.label) : '';
                            if (!id || !label) {
                                return '';
                            }
                            return '<a href="/index.php?r=arm/view&id=' + encodeURIComponent(id)
                                + '" class="tasks-movement-link" target="_blank" rel="noopener noreferrer">'
                                + escapeHtml(label) + '</a>';
                        }).filter(Boolean).join('<br>');
                    }
                    var text = params && params.value != null ? String(params.value) : '';
                    if (!text.trim()) {
                        return '';
                    }
                    var div = document.createElement('div');
                    div.textContent = text;
                    return div.innerHTML.replace(/\n/g, '<br>');
                },
            },
        ];

        function fitColumns(api) {
            if (!api || typeof api.sizeColumnsToFit !== 'function') {
                return;
            }
            if (!container || container.clientWidth < 80) {
                return;
            }
            try {
                api.sizeColumnsToFit();
            } catch (e) {
                console.warn('AG Grid (история перемещений): sizeColumnsToFit', e);
            }
        }

        var gridOpts = {
            columnDefs: columnDefs,
            theme: 'legacy',
            animateRows: true,
            defaultColDef: { sortable: true, filter: true, resizable: true },
            suppressHorizontalScroll: false,
            pagination: false,
            domLayout: 'normal',
            alwaysShowHorizontalScroll: true,
            alwaysShowVerticalScroll: true,
            scrollbarWidth: 12,
            getRowHeight: function(params) {
                var lines = Math.max(1, Math.min(8, getMovementRowLines(params)));
                return Math.min(132, 24 + lines * 14);
            },
            localeText: localeTextRu,
            onFirstDataRendered: function(params) {
                fitColumns(params.api);
                if (params.api && typeof params.api.resetRowHeights === 'function') {
                    params.api.resetRowHeights();
                }
            },
            onGridSizeChanged: function(params) {
                fitColumns(params.api);
                if (params.api && typeof params.api.resetRowHeights === 'function') {
                    params.api.resetRowHeights();
                }
            },
            onColumnResized: function(params) {
                if (params && params.finished && params.api && typeof params.api.resetRowHeights === 'function') {
                    params.api.resetRowHeights();
                }
            },
            onDisplayedColumnsChanged: function(params) {
                if (params && params.api && typeof params.api.resetRowHeights === 'function') {
                    params.api.resetRowHeights();
                }
            },
            onGridReady: function(params) {
                var quickFilterInput = document.getElementById('movementHistoryQuickFilter');
                var quickFilterClear = document.getElementById('movementHistoryQuickFilterClear');

                function updateQuickFilterClear() {
                    if (!quickFilterClear || !quickFilterInput) {
                        return;
                    }
                    quickFilterClear.hidden = !String(quickFilterInput.value || '').trim();
                }

                if (quickFilterInput && !quickFilterInput.dataset.gridQuickFilterBound) {
                    quickFilterInput.dataset.gridQuickFilterBound = '1';
                    quickFilterInput.addEventListener('input', function() {
                        applyQuickFilter(params.api, quickFilterInput.value || '');
                        updateQuickFilterClear();
                    });
                }
                if (quickFilterClear && !quickFilterClear.dataset.gridQuickFilterBound) {
                    quickFilterClear.dataset.gridQuickFilterBound = '1';
                    quickFilterClear.addEventListener('click', function() {
                        if (!quickFilterInput) {
                            return;
                        }
                        quickFilterInput.value = '';
                        applyQuickFilter(params.api, '');
                        updateQuickFilterClear();
                        quickFilterInput.focus();
                    });
                }
                if (quickFilterInput && quickFilterInput.value) {
                    applyQuickFilter(params.api, quickFilterInput.value);
                }
                updateQuickFilterClear();

                fetch(buildDataUrlWithPeriod(dataUrl), { cache: 'no-store' })
                    .then(function(r) {
                        return r.json();
                    })
                    .then(function(result) {
                        if (result && result.success && result.data) {
                            params.api.setGridOption('rowData', result.data);
                        } else {
                            params.api.setGridOption('rowData', []);
                        }
                        setTimeout(function() {
                            fitColumns(params.api);
                            if (quickFilterInput && quickFilterInput.value) {
                                applyQuickFilter(params.api, quickFilterInput.value);
                            }
                            if (params.api && typeof params.api.resetRowHeights === 'function') {
                                params.api.resetRowHeights();
                            }
                        }, 0);
                    })
                    .catch(function(err) {
                        console.error('AG Grid (история перемещений):', err);
                    });
            },
        };

        var createGrid = window.iasCreateGrid || (window.AgGridFilter && window.AgGridFilter.iasCreateGrid);
        (typeof createGrid === 'function' ? createGrid : agGrid.createGrid.bind(agGrid))(container, gridOpts);
    }

    function init() {
        var container = document.getElementById('agGridMovementHistoryContainer');
        if (container && container.dataset.url) {
            createMovementGrid(container, container.dataset.url);
        }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() {
            setTimeout(init, 150);
        });
    } else {
        setTimeout(init, 150);
    }
})();
