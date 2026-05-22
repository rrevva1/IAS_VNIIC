/**
 * Тема AG Grid: legacy + видимая сетка (совместимо с wrapText и нашим CSS).
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

    agGrid.provideGlobalGridOptions({
        theme: 'legacy',
        defaultColDef: wrapDef,
        suppressHorizontalScroll: false,
    });
})();
