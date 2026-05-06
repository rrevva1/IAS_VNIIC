/**
 * Умная форма техники: подгрузка полей в зависимости от типа.
 */
(function() {
    'use strict';
    function renderFields(type) {
        var templates = window.armFormFieldTemplates || {};
        var chars = window.armFormChars || {};
        var fields = templates[type];
        var block = document.getElementById('dynamic-fields-block');
        var content = document.getElementById('dynamic-fields-content');
        if (!block || !content) return;
        if (!fields || fields.length === 0) {
            block.style.display = 'none';
            return;
        }
        content.innerHTML = '';
        fields.forEach(function(f) {
            var val = chars[f.name] || '';
            var div = document.createElement('div');
            div.className = 'mb-3';
            div.innerHTML = '<label class="form-label">' + (f.label || f.name) + '</label>' +
                '<input type="text" class="form-control" name="PartChar[' + f.name + ']" value="' + (val || '').replace(/"/g, '&quot;') + '" data-part="' + (f.part || '') + '" data-char="' + (f.char || '') + '">';
            content.appendChild(div);
        });
        block.style.display = 'block';
    }
    function init() {
        var sel = document.getElementById('equipment-type-select');
        if (!sel) return;
        var selectedOpt = sel.options[sel.selectedIndex];
        var currentType = selectedOpt ? selectedOpt.text : '';
        if (currentType) {
            renderFields(currentType);
        } else {
            document.getElementById('dynamic-fields-block').style.display = 'none';
        }
        sel.addEventListener('change', function() {
            var opt = this.options[this.selectedIndex];
            var t = opt ? opt.text : '';
            if (t) {
                renderFields(t);
            } else {
                document.getElementById('dynamic-fields-block').style.display = 'none';
            }
        });
    }
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
