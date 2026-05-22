/**
 * Перенос текста в ячейках AG Grid: общие настройки и оценка высоты строки.
 */
(function () {
    'use strict';

    var LINE_HEIGHT = 24;
    var ROW_PADDING = 36;
    var SAFETY_LINES = 1;
    var MIN_ROW_HEIGHT = 62;
    var MAX_ROW_HEIGHT = 360;
    var AVG_CHAR_PX = 7;

    function splitLongToken(token, charsPerLine) {
        if (token.length <= charsPerLine) {
            return [token];
        }
        var parts = [];
        for (var i = 0; i < token.length; i += charsPerLine) {
            parts.push(token.substring(i, i + charsPerLine));
        }
        return parts;
    }

    function estimateLines(text, columnWidth) {
        var value = text == null ? '' : String(text).trim();
        if (!value) {
            return 1;
        }

        var width = Math.max(48, (columnWidth || 120) - 24);
        var charsPerLine = Math.max(6, Math.floor(width / AVG_CHAR_PX));
        var totalLines = 0;

        value.split(/\r?\n/).forEach(function (paragraph) {
            var para = paragraph.trim();
            if (!para) {
                totalLines += 1;
                return;
            }

            var words = para.split(/\s+/).filter(function (w) { return w !== ''; });
            var lineLen = 0;
            var lines = 0;

            words.forEach(function (word) {
                var tokens = splitLongToken(word, charsPerLine);
                tokens.forEach(function (token, tokenIndex) {
                    if (tokenIndex > 0) {
                        lines += 1;
                        lineLen = token.length;
                        return;
                    }
                    if (lineLen === 0) {
                        lines = Math.max(1, lines);
                        lineLen = token.length;
                        return;
                    }
                    if (lineLen + 1 + token.length <= charsPerLine) {
                        lineLen += 1 + token.length;
                    } else {
                        lines += 1;
                        lineLen = token.length;
                    }
                });
            });

            totalLines += Math.max(1, lines);
        });

        return Math.max(1, totalLines + SAFETY_LINES);
    }

    function getColumnWidth(col) {
        if (!col) {
            return 120;
        }
        if (typeof col.getActualWidth === 'function') {
            var actual = col.getActualWidth();
            if (actual && actual > 0) {
                return actual;
            }
        }
        var def = typeof col.getColDef === 'function' ? col.getColDef() : {};
        return def.width || def.minWidth || 120;
    }

    /**
     * Высота строки по содержимому видимых колонок (для infinite / server-side).
     */
    function estimateRowHeight(params, extraLines) {
        var data = params && params.data;
        if (!data) {
            return MIN_ROW_HEIGHT;
        }

        var maxLines = Math.max(1, extraLines || 1);
        var api = params.api;

        if (api && typeof api.getAllDisplayedColumns === 'function') {
            api.getAllDisplayedColumns().forEach(function (col) {
                if (!col || typeof col.getColDef !== 'function') {
                    return;
                }
                var def = col.getColDef();
                var field = def.field;
                if (!field || def.checkboxSelection || def.headerCheckboxSelection) {
                    return;
                }
                if (def.width > 0 && def.width <= 48 && !def.flex) {
                    return;
                }
                var raw = data[field];
                if (raw == null || raw === '') {
                    return;
                }
                maxLines = Math.max(maxLines, estimateLines(raw, getColumnWidth(col)));
            });
        }

        var height = maxLines * LINE_HEIGHT + ROW_PADDING;
        return Math.min(MAX_ROW_HEIGHT, Math.max(MIN_ROW_HEIGHT, Math.ceil(height * 1.14)));
    }

    function scheduleResetRowHeights(api) {
        if (!api || typeof api.resetRowHeights !== 'function') {
            return;
        }
        var run = function () {
            try {
                api.resetRowHeights();
            } catch (e) { /* ignore */ }
        };
        setTimeout(run, 0);
        setTimeout(run, 80);
        setTimeout(run, 250);
    }

    var wrapCellStyle = {
        whiteSpace: 'normal',
        lineHeight: '24px',
        wordBreak: 'break-word',
        overflow: 'visible',
    };

    var wrapColDef = {
        wrapText: true,
        autoHeight: true,
        wrapHeaderText: true,
        autoHeaderHeight: true,
        cellClass: 'ag-cell-wrap-text',
        cellStyle: wrapCellStyle,
    };

    var wrapColDefInfinite = {
        wrapText: true,
        wrapHeaderText: true,
        autoHeaderHeight: true,
        cellClass: 'ag-cell-wrap-text',
        cellStyle: wrapCellStyle,
    };

    function mergeDefaultColDef(local, useInfinite) {
        var base = useInfinite ? wrapColDefInfinite : wrapColDef;
        return Object.assign({}, base, local || {});
    }

    window.AgGridWrap = {
        defaultColDef: wrapColDef,
        defaultColDefInfinite: wrapColDefInfinite,
        mergeDefaultColDef: mergeDefaultColDef,
        estimateLines: estimateLines,
        estimateRowHeight: estimateRowHeight,
        getColumnWidth: getColumnWidth,
        scheduleResetRowHeights: scheduleResetRowHeights,
        MIN_ROW_HEIGHT: MIN_ROW_HEIGHT,
        MAX_ROW_HEIGHT: MAX_ROW_HEIGHT,
        LINE_HEIGHT: LINE_HEIGHT,
        ROW_PADDING: ROW_PADDING,
    };
})();
