/**
 * Предупреждение о занятости внутреннего номера при выборе в select.
 */
(function() {
    'use strict';

    function bindSelect(select) {
        if (!select || select.dataset.phoneSelectBound === '1') {
            return;
        }
        select.dataset.phoneSelectBound = '1';

        var wrap = select.closest('.field-users-phone, .field-phonedirectory-internal_phone, .profile-edit-form__field, .users-create-form__section, .phone-directory-form-wrap, .mb-0')
            || select.parentElement;
        var warn = wrap ? wrap.querySelector('[data-phone-occupancy-warn]') : null;
        if (!warn) {
            warn = select.parentElement && select.parentElement.querySelector('[data-phone-occupancy-warn]');
        }
        // Ищем соседний блок предупреждения
        if (!warn) {
            var next = select.nextElementSibling;
            while (next && !next.hasAttribute('data-phone-occupancy-warn')) {
                next = next.nextElementSibling;
            }
            warn = next;
        }
        if (!warn && select.closest('div')) {
            var root = select.closest('div').parentElement;
            if (root) {
                warn = root.querySelector('[data-phone-occupancy-warn]');
            }
        }

        function update() {
            if (!warn) {
                return;
            }
            var opt = select.options[select.selectedIndex];
            var text = opt ? String(opt.text || '') : '';
            var occupied = text.indexOf('занят') !== -1;
            if (!select.value) {
                warn.classList.add('d-none');
                warn.textContent = '';
                return;
            }
            if (occupied) {
                warn.classList.remove('d-none');
                warn.innerHTML = '<i class="fas fa-triangle-exclamation" aria-hidden="true"></i> '
                    + 'Номер уже используется. Сохранение допускается (общий номер).';
            } else {
                warn.classList.add('d-none');
                warn.textContent = '';
            }
        }

        select.addEventListener('change', update);
        update();
    }

    function init(root) {
        (root || document).querySelectorAll('select[data-phone-select="1"]').forEach(bindSelect);
    }

    window.initInternalPhoneSelects = init;

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() { init(document); });
    } else {
        init(document);
    }

    // После подгрузки модалок
    document.addEventListener('shown.bs.modal', function(e) {
        if (e && e.target) {
            init(e.target);
        }
    });
})();
