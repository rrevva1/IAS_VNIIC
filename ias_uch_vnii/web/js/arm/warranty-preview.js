/**
 * Предпросмотр даты окончания гарантии по сроку в годах и базовой дате.
 */
(function () {
    'use strict';

    function resolveBaseDate(commissioningEl, purchaseEl) {
        var commissioning = commissioningEl && commissioningEl.value ? commissioningEl.value.trim() : '';
        if (commissioning) {
            return commissioning;
        }
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

    function updatePreview() {
        var preview = document.getElementById('equipment-warranty-until-preview');
        if (!preview) {
            return;
        }
        var yearsEl = document.getElementById('equipment-warranty-years');
        var commissioningEl = document.getElementById('equipment-commissioning-date');
        var purchaseEl = document.getElementById('equipment-purchase-date');
        var years = parseYears(yearsEl ? yearsEl.value : '');
        var baseDate = resolveBaseDate(commissioningEl, purchaseEl);

        if (!Number.isFinite(years)) {
            preview.textContent = '';
            return;
        }
        if (!baseDate) {
            preview.textContent = 'Укажите дату ввода в эксплуатацию или дату закупки для расчёта.';
            return;
        }
        var until = calculateWarrantyUntil(baseDate, years);
        preview.textContent = until
            ? 'Гарантия до: ' + until
            : 'Не удалось рассчитать дату окончания гарантии.';
    }

    function bind() {
        var ids = ['equipment-warranty-years', 'equipment-commissioning-date', 'equipment-purchase-date'];
        ids.forEach(function (id) {
            var el = document.getElementById(id);
            if (el) {
                el.addEventListener('input', updatePreview);
                el.addEventListener('change', updatePreview);
            }
        });
        updatePreview();
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', bind);
    } else {
        bind();
    }
})();
