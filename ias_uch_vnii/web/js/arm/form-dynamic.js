/**
 * Умная форма техники: поля характеристик по выбранному типу.
 */
(function() {
    'use strict';

    function escapeHtml(s) {
        return String(s || '')
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;');
    }

    function ensureCpuDatalistOption(value) {
        var v = String(value || '').trim();
        if (!v) {
            return;
        }
        var list = document.getElementById('arm-cpu-datalist');
        if (!list) {
            return;
        }
        var exists = false;
        Array.prototype.forEach.call(list.options, function(opt) {
            if (String(opt.value).trim() === v) {
                exists = true;
            }
        });
        if (!exists) {
            var opt = document.createElement('option');
            opt.value = v;
            list.appendChild(opt);
        }
    }

    function getSelectedType(sel) {
        if (!sel || sel.selectedIndex < 0) {
            return '';
        }
        var opt = sel.options[sel.selectedIndex];
        if (!opt || !opt.value) {
            return '';
        }
        return String(opt.value).trim();
    }

    function renderFields(type) {
        var templates = window.armFormFieldTemplates || {};
        var chars = window.armFormChars || {};
        var fields = templates[type];
        var block = document.getElementById('dynamic-fields-block');
        var content = document.getElementById('dynamic-fields-content');
        if (!block || !content) {
            return;
        }
        if (!type || !fields || fields.length === 0) {
            block.style.display = 'none';
            content.innerHTML = '';
            return;
        }
        content.innerHTML = '';
        fields.forEach(function(f) {
            var val = chars[f.name] || '';
            var div = document.createElement('div');
            div.className = 'mb-3';
            var inputAttrs =
                'type="text" class="form-control" name="PartChar[' + escapeHtml(f.name) + ']" value="' +
                escapeHtml(val) + '" data-part="' + escapeHtml(f.part || '') + '" data-char="' +
                escapeHtml(f.char || '') + '"';
            if (f.widget === 'cpu-datalist' || f.name === 'cpu') {
                inputAttrs += ' list="arm-cpu-datalist" autocomplete="off" placeholder="Выберите из списка или введите модель вручную"';
            }
            var hint = '';
            if (f.widget === 'cpu-datalist' || f.name === 'cpu') {
                hint = '<div class="form-text text-muted">Можно выбрать известную модель или указать новую — она сохранится в учёте.</div>';
            }
            div.innerHTML =
                '<label class="form-label">' + escapeHtml(f.label || f.name) + '</label>' +
                '<input ' + inputAttrs + '>' + hint;
            content.appendChild(div);
            if ((f.widget === 'cpu-datalist' || f.name === 'cpu') && val) {
                ensureCpuDatalistOption(val);
            }
        });
        block.style.display = 'block';
    }

    function init() {
        var sel = document.getElementById('equipment-type-select');
        if (!sel) {
            return;
        }
        var currentType = getSelectedType(sel);
        if (currentType) {
            renderFields(currentType);
        } else {
            var block = document.getElementById('dynamic-fields-block');
            if (block) {
                block.style.display = 'none';
            }
        }
        sel.addEventListener('change', function() {
            renderFields(getSelectedType(this));
        });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
