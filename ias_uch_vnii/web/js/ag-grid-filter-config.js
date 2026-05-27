/**
 * Упрощённые фильтры AG Grid + русская локализация (все таблицы ИАС).
 */
(function() {
    'use strict';

    var TEXT_FILTER_PARAMS = {
        filterOptions: ['contains'],
        defaultOption: 'contains',
        maxNumConditions: 2,
        numAlwaysVisibleConditions: 1,
        buttons: ['apply', 'reset'],
        debounceMs: 280,
        trimInput: true,
    };

    var NUMBER_FILTER_PARAMS = {
        filterOptions: ['equals', 'greaterThan', 'lessThan'],
        defaultOption: 'equals',
        maxNumConditions: 2,
        numAlwaysVisibleConditions: 1,
        buttons: ['apply', 'reset'],
        debounceMs: 280,
    };

    var DATE_FILTER_PARAMS = {
        filterOptions: ['equals', 'greaterThan', 'lessThan'],
        defaultOption: 'equals',
        maxNumConditions: 2,
        numAlwaysVisibleConditions: 1,
        buttons: ['apply', 'reset'],
    };

    /** Ключи filterLocaleText AG Grid 34 и интерфейса таблицы. */
    var AG_GRID_LOCALE_RU = {
        page: 'Страница',
        to: 'до',
        of: 'из',
        next: 'След.',
        last: 'Последняя',
        first: 'Первая',
        previous: 'Пред.',
        loadingOoo: 'Загрузка…',
        noRowsToShow: 'Нет данных',
        pageSizeSelectorLabel: 'Строк на странице:',

        applyFilter: 'Применить',
        clearFilter: 'Очистить',
        resetFilter: 'Сбросить',
        cancelFilter: 'Отмена',
        textFilter: 'Текстовый фильтр',
        numberFilter: 'Числовой фильтр',
        dateFilter: 'Фильтр по дате',
        setFilter: 'Фильтр по списку',
        filterOoo: 'Введите значение…',
        searchOoo: 'Поиск…',
        filterPlaceholder: 'Введите значение…',
        empty: 'Выберите значение',
        equals: 'Равно',
        notEqual: 'Не равно',
        lessThan: 'Меньше',
        greaterThan: 'Больше',
        inRange: 'Между',
        inRangeStart: 'С',
        inRangeEnd: 'По',
        lessThanOrEqual: 'Не больше',
        greaterThanOrEqual: 'Не меньше',
        contains: 'Содержит',
        notContains: 'Не содержит',
        startsWith: 'Начинается с',
        endsWith: 'Заканчивается на',
        blank: 'Пусто',
        notBlank: 'Не пусто',
        before: 'До',
        after: 'После',
        andCondition: 'И',
        orCondition: 'Или',
        dateFormatOoo: 'гггг-мм-дд',

        filterSummaryInactive: 'все',
        filterSummaryContains: 'содержит',
        filterSummaryNotContains: 'не содержит',
        filterSummaryTextEquals: 'равно',
        filterSummaryTextNotEqual: 'не равно',
        filterSummaryStartsWith: 'начинается с',
        filterSummaryEndsWith: 'заканчивается на',
        filterSummaryBlank: 'пусто',
        filterSummaryNotBlank: 'не пусто',
        filterSummaryEquals: '=',
        filterSummaryNotEqual: '≠',
        filterSummaryGreaterThan: '>',
        filterSummaryGreaterThanOrEqual: '≥',
        filterSummaryLessThan: '<',
        filterSummaryLessThanOrEqual: '≤',
        filterSummaryInRange: 'между',

        selectAll: 'Выбрать все',
        unselectAll: 'Снять выбор',
        columns: 'Колонки',
        copy: 'Копировать',
        export: 'Экспорт',
    };

    AG_GRID_LOCALE_RU.filterSummaryInRangeValues = function(variableValues) {
        return '(' + variableValues[0] + ' — ' + variableValues[1] + ')';
    };
    AG_GRID_LOCALE_RU.filterSummaryTextQuote = function(variableValues) {
        return '«' + variableValues[0] + '»';
    };

    /**
     * @param {{ key: string, defaultValue?: string, variableValues?: string[] }} params
     * @param {Function|undefined} chain
     * @returns {string}
     */
    function resolveLocaleText(params, chain) {
        var key = params.key;
        var mapped = AG_GRID_LOCALE_RU[key];

        if (typeof mapped === 'function') {
            return mapped(params.variableValues || []);
        }
        if (mapped != null && mapped !== '') {
            return String(mapped);
        }
        if (typeof chain === 'function') {
            var chained = chain(params);
            if (chained != null && chained !== '') {
                return String(chained);
            }
        }
        if (params.defaultValue != null) {
            return String(params.defaultValue);
        }

        return key;
    }

    /**
     * @param {Function|undefined} existing
     * @returns {Function}
     */
    function createGetLocaleText(existing) {
        return function(params) {
            return resolveLocaleText(params, existing);
        };
    }

    /**
     * @param {object} colDef
     * @returns {object}
     */
    function applySimpleFilterToColDef(colDef) {
        if (!colDef || colDef.filter === false) {
            return colDef;
        }

        var next = Object.assign({}, colDef);

        if (next.filter === 'agNumberColumnFilter') {
            next.filterParams = Object.assign({}, NUMBER_FILTER_PARAMS, next.filterParams || {});
        } else if (next.filter === 'agDateColumnFilter') {
            next.filterParams = Object.assign({}, DATE_FILTER_PARAMS, next.filterParams || {});
        } else if (next.filter === 'agTextColumnFilter' || next.filter === true || next.filter == null) {
            if (next.filter === true || next.filter == null) {
                next.filter = 'agTextColumnFilter';
            }
            next.filterParams = Object.assign({}, TEXT_FILTER_PARAMS, next.filterParams || {});
        }

        return next;
    }

    function mergeLocaleText(gridLocale) {
        return Object.assign({}, AG_GRID_LOCALE_RU, gridLocale || {});
    }

    function applyGridLocale(opts) {
        var previousGetLocaleText = opts.getLocaleText;
        opts.getLocaleText = createGetLocaleText(previousGetLocaleText);
        opts.localeText = mergeLocaleText(opts.localeText);
    }

    function attachResetButtonFallback(opts) {
        var prevOnFilterOpened = opts.onFilterOpened;
        opts.onFilterOpened = function(params) {
            if (typeof prevOnFilterOpened === 'function') {
                prevOnFilterOpened(params);
            }
            if (!params || !params.api || !params.column || typeof params.column.getColId !== 'function') {
                return;
            }
            var colId = params.column.getColId();
            setTimeout(function() {
                var filterRoots = document.querySelectorAll('.ag-popup-child .ag-filter, .ag-popup .ag-filter');
                if (!filterRoots || !filterRoots.length) {
                    return;
                }
                var filterRoot = filterRoots[filterRoots.length - 1];
                var panel = filterRoot.querySelector('.ag-filter-apply-panel');
                if (panel && panel.querySelector('.ag-filter-apply-panel-button')) {
                    return;
                }
                if (!panel) {
                    panel = document.createElement('div');
                    panel.className = 'ag-filter-apply-panel ias-filter-reset-panel';
                    filterRoot.appendChild(panel);
                }
                if (panel.querySelector('.ias-filter-reset-btn')) {
                    return;
                }

                var btn = document.createElement('button');
                btn.type = 'button';
                btn.className = 'ag-button ag-standard-button ag-filter-apply-panel-button ias-filter-reset-btn';
                btn.textContent = 'Сбросить';
                btn.addEventListener('click', function() {
                    var result = null;
                    if (typeof params.api.setColumnFilterModel === 'function') {
                        result = params.api.setColumnFilterModel(colId, null);
                    } else if (typeof params.api.destroyFilter === 'function') {
                        params.api.destroyFilter(colId);
                    }
                    if (result && typeof result.then === 'function') {
                        result.finally(function() {
                            if (typeof params.api.onFilterChanged === 'function') {
                                params.api.onFilterChanged();
                            }
                        });
                        return;
                    }
                    if (typeof params.api.onFilterChanged === 'function') {
                        params.api.onFilterChanged();
                    }
                });
                panel.appendChild(btn);
            }, 0);
        };
    }

    function patchCreateGrid() {
        if (typeof agGrid === 'undefined' || typeof agGrid.createGrid !== 'function') {
            return;
        }
        if (agGrid.createGrid.__iasSimpleFilterPatched) {
            if (agGrid.createGrid.__iasOriginalCreateGrid) {
                agGrid.createGrid = agGrid.createGrid.__iasOriginalCreateGrid;
            } else {
                return;
            }
        }
        var original = agGrid.createGrid.bind(agGrid);
        agGrid.createGrid = function(container, options) {
            var opts = options ? Object.assign({}, options) : {};

            applyGridLocale(opts);
            attachResetButtonFallback(opts);

            if (opts.columnDefs && Array.isArray(opts.columnDefs)) {
                opts.columnDefs = opts.columnDefs.map(applySimpleFilterToColDef);
            }

            if (opts.defaultColDef) {
                opts.defaultColDef = Object.assign({}, opts.defaultColDef);
                if (opts.defaultColDef.filter === true || opts.defaultColDef.filter == null) {
                    opts.defaultColDef.filter = 'agTextColumnFilter';
                }

                // Гарантируем наличие кнопки «Сбросить» даже при своих filterParams.
                var baseParams = opts.defaultColDef.filterParams || {};
                if (!baseParams.buttons || !baseParams.buttons.length) {
                    baseParams = Object.assign({}, baseParams, { buttons: ['apply', 'reset'] });
                }

                if (opts.defaultColDef.filter === 'agTextColumnFilter') {
                    opts.defaultColDef.filterParams = Object.assign(
                        {},
                        TEXT_FILTER_PARAMS,
                        baseParams
                    );
                } else if (opts.defaultColDef.filter === 'agNumberColumnFilter') {
                    opts.defaultColDef.filterParams = Object.assign(
                        {},
                        NUMBER_FILTER_PARAMS,
                        baseParams
                    );
                } else if (opts.defaultColDef.filter === 'agDateColumnFilter') {
                    opts.defaultColDef.filterParams = Object.assign(
                        {},
                        DATE_FILTER_PARAMS,
                        baseParams
                    );
                } else {
                    opts.defaultColDef.filterParams = baseParams;
                }

                if (opts.defaultColDef.floatingFilter == null) {
                    opts.defaultColDef.floatingFilter = false;
                }
            }

            var api = original(container, opts);
            if (api) {
                window.__iasAgGridApis = window.__iasAgGridApis || [];
                window.__iasAgGridApis.push(api);
            }
            return api;
        };
        agGrid.createGrid.__iasSimpleFilterPatched = true;
        agGrid.createGrid.__iasOriginalCreateGrid = original;
    }

    var globalGetLocaleText = createGetLocaleText();

    window.AgGridFilter = {
        textParams: TEXT_FILTER_PARAMS,
        numberParams: NUMBER_FILTER_PARAMS,
        dateParams: DATE_FILTER_PARAMS,
        localeRu: AG_GRID_LOCALE_RU,
        getLocaleText: globalGetLocaleText,
        mergeLocaleText: mergeLocaleText,
        applyToColDef: applySimpleFilterToColDef,
        applyGridLocale: applyGridLocale,
        defaultColDefExtras: {
            floatingFilter: false,
        },
        patchCreateGrid: patchCreateGrid,
    };

    patchCreateGrid();
})();
