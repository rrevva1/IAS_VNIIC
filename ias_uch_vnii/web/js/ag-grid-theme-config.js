/**
 * Тема AG Grid: legacy + видимая сетка + русская локализация фильтров.
 */
(function () {
    'use strict';

    if (typeof agGrid === 'undefined' || !agGrid.provideGlobalGridOptions) {
        return;
    }

    var wrapDef = (typeof window.AgGridWrap !== 'undefined' && window.AgGridWrap.defaultColDefInfinite)
        ? window.AgGridWrap.defaultColDefInfinite
        : {
            wrapText: true,
            autoHeight: false,
            wrapHeaderText: true,
            autoHeaderHeight: true,
            cellClass: 'ag-cell-wrap-text',
        };

    var filterExtras = (typeof window.AgGridFilter !== 'undefined' && window.AgGridFilter.defaultColDefExtras)
        ? window.AgGridFilter.defaultColDefExtras
        : { floatingFilter: false };

    var globalOpts = {
        theme: 'legacy',
        defaultColDef: Object.assign({}, wrapDef, filterExtras),
        suppressHorizontalScroll: false,
        /** Без мигающего текстового курсора в ячейках при клике по таблице и странице */
        suppressCellFocus: true,
        enableCellTextSelection: false,
    };

    if (typeof window.AgGridFilter !== 'undefined') {
        globalOpts.localeText = window.AgGridFilter.mergeLocaleText();
        globalOpts.getLocaleText = window.AgGridFilter.getLocaleText;
    }

    agGrid.provideGlobalGridOptions(globalOpts, 'deep');
})();
