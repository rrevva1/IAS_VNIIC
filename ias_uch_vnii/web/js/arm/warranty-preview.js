/**
 * Подсказки по гарантии — только внутри полей (placeholder / title).
 */
(function () {
    'use strict';

    var YEARS_DEFAULT_PLACEHOLDER = 'Например: 3';
    var DATE_WARRANTY_PLACEHOLDER = 'Для расчёта гарантии';

    function resolveBaseDate(purchaseEl) {
        return purchaseEl && purchaseEl.value ? purchaseEl.value.trim() : '';
    }

    function parseYears(value) {
        if (value === null || value === undefined) {
            return NaN;
        }
        var normalized = String(value).replace(',', '.').trim();
        if (normalized === '') {
            return NaN;
        }
        var years = parseFloat(normalized, 10);
        return Number.isFinite(years) && years > 0 ? years : NaN;
    }

    function calculateWarrantyUntil(baseDate, years) {
        if (!baseDate || !Number.isFinite(years) || years <= 0) {
            return null;
        }
        var parts = baseDate.split('-');
        if (parts.length !== 3) {
            return null;
        }
        var year = parseInt(parts[0], 10);
        var month = parseInt(parts[1], 10) - 1;
        var day = parseInt(parts[2], 10);
        if (!Number.isFinite(year) || !Number.isFinite(month) || !Number.isFinite(day)) {
            return null;
        }
        var dt = new Date(year, month, day);
        if (Number.isNaN(dt.getTime())) {
            return null;
        }
        var monthsToAdd = Math.round(years * 12);
        dt.setMonth(dt.getMonth() + monthsToAdd);
        var y = dt.getFullYear();
        var m = String(dt.getMonth() + 1).padStart(2, '0');
        var d = String(dt.getDate()).padStart(2, '0');
        return d + '.' + m + '.' + y;
    }

    function setDatePlaceholder(el, text) {
        if (!el) {
            return;
        }
        if (text) {
            el.setAttribute('placeholder', text);
        } else {
            el.removeAttribute('placeholder');
        }
    }

    function updatePreview() {
        var yearsEl = document.getElementById('equipment-warranty-years');
        var purchaseEl = document.getElementById('equipment-purchase-date');
        var years = parseYears(yearsEl ? yearsEl.value : '');
        var baseDate = resolveBaseDate(purchaseEl);

        setDatePlaceholder(purchaseEl, '');

        if (yearsEl) {
            yearsEl.placeholder = YEARS_DEFAULT_PLACEHOLDER;
            yearsEl.title = '';
        }

        if (!Number.isFinite(years)) {
            return;
        }

        if (!baseDate) {
            if (yearsEl) {
                yearsEl.title = 'Укажите дату закупки';
            }
            if (purchaseEl && !purchaseEl.value.trim()) {
                setDatePlaceholder(purchaseEl, DATE_WARRANTY_PLACEHOLDER);
            }
            return;
        }

        var until = calculateWarrantyUntil(baseDate, years);
        if (yearsEl && until) {
            yearsEl.title = 'Гарантия до: ' + until;
        } else if (yearsEl) {
            yearsEl.title = 'Не удалось рассчитать дату окончания гарантии';
        }
    }

    function bind() {
        var ids = ['equipment-warranty-years', 'equipment-purchase-date'];
        ids.forEach(function (id) {
            var el = document.getElementById(id);
            if (!el || el.dataset.warrantyPreviewBound === '1') {
                return;
            }
            el.dataset.warrantyPreviewBound = '1';
            el.addEventListener('input', updatePreview);
            el.addEventListener('change', updatePreview);
        });
        updatePreview();
    }

    window.armInitWarrantyPreview = bind;

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', bind);
    } else {
        bind();
    }
})();
