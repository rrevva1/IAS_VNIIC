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

    function ensureDatalistOption(listId, value) {
        var v = String(value || '').trim();
        if (!v) {
            return;
        }
        var list = document.getElementById(listId);
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

    var DATALIST_WIDGETS = {
        'cpu-datalist': {
            listId: 'arm-cpu-datalist',
            placeholder: 'Выберите из списка или введите модель вручную',
            hint: 'Можно выбрать известную модель или указать новую — она сохранится в учёте.'
        },
        'ram-datalist': {
            listId: 'arm-ram-datalist',
            placeholder: 'Выберите объём из списка или введите вручную',
            hint: 'Можно выбрать известное значение или указать новое — оно сохранится в учёте.'
        },
        'os-datalist': {
            listId: 'arm-os-datalist',
            placeholder: 'Выберите ОС из списка или введите вручную',
            hint: 'Можно выбрать известную систему или указать новую — она сохранится в учёте.'
        }
    };

    function getDatalistWidgetConfig(field) {
        if (!field) {
            return null;
        }
        if (field.widget && DATALIST_WIDGETS[field.widget]) {
            return DATALIST_WIDGETS[field.widget];
        }
        if (field.name === 'cpu') {
            return DATALIST_WIDGETS['cpu-datalist'];
        }
        if (field.name === 'ram') {
            return DATALIST_WIDGETS['ram-datalist'];
        }
        if (field.name === 'os') {
            return DATALIST_WIDGETS['os-datalist'];
        }
        return null;
    }

    function ensureDiskDatalistOption(value) {
        ensureDatalistOption('arm-disk-datalist', value);
    }

    function parseDiskList(val) {
        return String(val || '')
            .split(/\s*[,;]\s*/)
            .map(function(s) {
                return s.trim();
            })
            .filter(function(s) {
                return s !== '';
            });
    }

    function isPrinterOrMfuType(type) {
        var t = String(type || '').trim().toLowerCase();
        return t === 'принтер' || t === 'мфу';
    }

    function toggleDescriptionSection(type) {
        var section = document.getElementById('arm-form-description-section');
        if (!section) {
            return;
        }
        if (isPrinterOrMfuType(type)) {
            section.classList.add('d-none');
        } else {
            section.classList.remove('d-none');
        }
    }

    function getOrgTechValues() {
        return window.armFormOrgTech || {};
    }

    function renderCartridgeSelectField(f) {
        var orgTech = getOrgTechValues();
        var current = String(orgTech.cartridge_procurement || '').trim();
        var div = createDynamicFieldWrapper();
        div.innerHTML = '<label class="form-label">' + escapeHtml(f.label || f.name) + '</label>';

        var submitted = document.createElement('input');
        submitted.type = 'hidden';
        submitted.name = 'OrgTechSubmitted';
        submitted.value = '1';

        var select = document.createElement('select');
        select.className = 'form-select';
        select.name = 'OrgTech[cartridge_procurement]';
        [
            { value: '', label: '— не указано —' },
            { value: 'yes', label: 'Учтен' },
            { value: 'no', label: 'Не учтен' }
        ].forEach(function(opt) {
            var option = document.createElement('option');
            option.value = opt.value;
            option.textContent = opt.label;
            if (opt.value === current) {
                option.selected = true;
            }
            select.appendChild(option);
        });

        div.appendChild(submitted);
        div.appendChild(select);
        return div;
    }

    function renderPrinterCommentField(f) {
        var orgTech = getOrgTechValues();
        var val = String(orgTech.printer_comment || '').trim();
        var div = createDynamicFieldWrapper();
        div.innerHTML =
            '<label class="form-label">' + escapeHtml(f.label || f.name) + '</label>' +
            '<textarea class="form-control" name="OrgTech[printer_comment]" rows="3" placeholder="Дополнительные примечания">' +
            escapeHtml(val) + '</textarea>';
        return div;
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

    function createDynamicFieldWrapper() {
        var div = document.createElement('div');
        div.className = 'arm-dynamic-field';
        return div;
    }

    function createDiskRow(value) {
        var row = document.createElement('div');
        row.className = 'arm-disk-row';
        var input = document.createElement('input');
        input.type = 'text';
        input.className = 'form-control';
        input.name = 'PartCharDisks[]';
        input.value = value || '';
        input.setAttribute('list', 'arm-disk-datalist');
        input.setAttribute('autocomplete', 'off');
        input.placeholder = 'Выберите из списка или введите вручную';
        input.addEventListener('change', function() {
            ensureDiskDatalistOption(input.value);
        });
        input.addEventListener('blur', function() {
            ensureDiskDatalistOption(input.value);
        });

        var removeBtn = document.createElement('button');
        removeBtn.type = 'button';
        removeBtn.className = 'btn btn-outline-secondary btn-sm arm-disk-remove';
        removeBtn.title = 'Удалить накопитель';
        removeBtn.textContent = '×';
        removeBtn.addEventListener('click', function() {
            var list = row.parentElement;
            if (!list) {
                return;
            }
            if (list.querySelectorAll('.arm-disk-row').length <= 1) {
                input.value = '';
                return;
            }
            row.remove();
        });

        row.appendChild(input);
        row.appendChild(removeBtn);
        if (value) {
            ensureDiskDatalistOption(value);
        }
        return row;
    }

    function renderDiskMultiField(f, chars) {
        var div = createDynamicFieldWrapper();
        div.classList.add('arm-dynamic-field--disks');
        div.innerHTML =
            '<label class="form-label">' + escapeHtml(f.label || f.name) + '</label>';

        var submitted = document.createElement('input');
        submitted.type = 'hidden';
        submitted.name = 'PartCharDisksSubmitted';
        submitted.value = '1';

        var list = document.createElement('div');
        list.className = 'arm-disk-list';
        list.setAttribute('data-field', 'disk');

        var disks = parseDiskList(chars.disk || '');
        if (disks.length === 0) {
            disks = [''];
        }
        disks.forEach(function(d) {
            list.appendChild(createDiskRow(d));
        });

        var addBtn = document.createElement('button');
        addBtn.type = 'button';
        addBtn.className = 'btn btn-outline-primary btn-sm arm-disk-add';
        addBtn.textContent = '+ Добавить накопитель';
        addBtn.addEventListener('click', function() {
            list.appendChild(createDiskRow(''));
            var inputs = list.querySelectorAll('input[name="PartCharDisks[]"]');
            if (inputs.length) {
                inputs[inputs.length - 1].focus();
            }
        });

        var hint = document.createElement('div');
        hint.className = 'form-text text-muted';
        hint.textContent =
            'Можно указать несколько дисков. Выберите известный вариант из списка или введите новый — он сохранится в учёте.';

        div.appendChild(submitted);
        div.appendChild(list);
        div.appendChild(addBtn);
        div.appendChild(hint);
        return div;
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
            block.classList.add('d-none');
            content.innerHTML = '';
            toggleDescriptionSection(type);
            return;
        }
        content.innerHTML = '';
        fields.forEach(function(f) {
            if (f.widget === 'disk-datalist-multi' || f.name === 'disk') {
                content.appendChild(renderDiskMultiField(f, chars));
                return;
            }
            if (f.widget === 'cartridge-select' || f.name === 'cartridge_procurement') {
                content.appendChild(renderCartridgeSelectField(f));
                return;
            }
            if (f.widget === 'printer-comment' || f.name === 'printer_comment') {
                content.appendChild(renderPrinterCommentField(f));
                return;
            }

            var val = chars[f.name] || '';
            var div = createDynamicFieldWrapper();
            var datalistCfg = getDatalistWidgetConfig(f);
            var inputAttrs =
                'type="text" class="form-control" name="PartChar[' + escapeHtml(f.name) + ']" value="' +
                escapeHtml(val) + '" data-part="' + escapeHtml(f.part || '') + '" data-char="' +
                escapeHtml(f.char || '') + '"';
            var hint = '';
            if (datalistCfg) {
                inputAttrs += ' list="' + datalistCfg.listId + '" autocomplete="off" placeholder="' +
                    escapeHtml(datalistCfg.placeholder) + '"';
                hint = '<div class="form-text text-muted">' + escapeHtml(datalistCfg.hint) + '</div>';
            }
            div.innerHTML =
                '<label class="form-label">' + escapeHtml(f.label || f.name) + '</label>' +
                '<input ' + inputAttrs + '>' + hint;
            content.appendChild(div);
            if (datalistCfg && val) {
                ensureDatalistOption(datalistCfg.listId, val);
            }
        });
        block.classList.remove('d-none');
        toggleDescriptionSection(type);
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
                block.classList.add('d-none');
            }
            toggleDescriptionSection('');
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
