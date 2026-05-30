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
        'cpu-datalist': { listId: 'arm-cpu-datalist' },
        'ram-datalist': { listId: 'arm-ram-datalist' },
        'os-datalist': { listId: 'arm-os-datalist' },
        'ip-datalist': { listId: 'arm-ip-datalist' },
        'ups-battery-datalist': { listId: 'arm-ups-battery-datalist' },
        'screen-diagonal-datalist': { listId: 'arm-screen-diagonal-datalist' }
    };

    function resolveFieldPlaceholder(field, datalistCfg) {
        if (field && field.placeholder) {
            return String(field.placeholder);
        }
        if (datalistCfg && datalistCfg.placeholder) {
            return String(datalistCfg.placeholder);
        }

        return '';
    }

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
        if (field.name === 'ip') {
            return DATALIST_WIDGETS['ip-datalist'];
        }
        if (field.name === 'ups_battery') {
            return DATALIST_WIDGETS['ups-battery-datalist'];
        }
        if (field.name === 'screen_diagonal') {
            return DATALIST_WIDGETS['screen-diagonal-datalist'];
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

    function getOrgTechValues() {
        return window.armFormOrgTech || {};
    }

    function renderChoiceSelectField(f) {
        var chars = window.armFormChars || {};
        var current = String(chars[f.name] || '').trim();
        var div = createDynamicFieldWrapper();
        var label = document.createElement('label');
        label.className = 'form-label';
        label.textContent = f.label || f.name;

        var select = document.createElement('select');
        select.className = 'form-select';
        select.name = 'PartChar[' + (f.name || '') + ']';

        (f.options || []).forEach(function(opt) {
            var option = document.createElement('option');
            option.value = String(opt.value != null ? opt.value : '');
            option.textContent = String(opt.label != null ? opt.label : opt.value || '');
            if (option.value === current) {
                option.selected = true;
            }
            select.appendChild(option);
        });

        div.appendChild(label);
        div.appendChild(select);
        return div;
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

    function loadArmFormConfig() {
        var templates = window.armFormFieldTemplates;
        var chars = window.armFormChars || {};
        var orgTech = window.armFormOrgTech || {};
        if (templates && typeof templates === 'object' && Object.keys(templates).length > 0) {
            return { templates: templates, chars: chars, orgTech: orgTech };
        }
        var node = document.getElementById('arm-form-config-json');
        if (!node || !node.value) {
            return { templates: {}, chars: {}, orgTech: {} };
        }
        try {
            var data = JSON.parse(node.value);
            if (data.templates) {
                window.armFormFieldTemplates = data.templates;
            }
            if (data.chars) {
                window.armFormChars = data.chars;
            }
            if (data.orgTech) {
                window.armFormOrgTech = data.orgTech;
            }
            return {
                templates: data.templates || {},
                chars: data.chars || {},
                orgTech: data.orgTech || {},
            };
        } catch (err) {
            return { templates: {}, chars: {}, orgTech: {} };
        }
    }

    function resolveTemplateFields(templates, type) {
        var key = String(type || '').trim();
        if (!key) {
            return null;
        }
        if (templates[key]) {
            return templates[key];
        }
        var lower = key.toLowerCase();
        var foundKey = Object.keys(templates).find(function(k) {
            return String(k).trim().toLowerCase() === lower;
        });
        return foundKey ? templates[foundKey] : null;
    }

    function createDynamicFieldWrapper() {
        var div = document.createElement('div');
        div.className = 'arm-dynamic-field';
        return div;
    }

    function createDiskRow(value, placeholder) {
        var row = document.createElement('div');
        row.className = 'arm-disk-row';
        var input = document.createElement('input');
        input.type = 'text';
        input.className = 'form-control';
        input.name = 'PartCharDisks[]';
        input.value = value || '';
        input.setAttribute('list', 'arm-disk-datalist');
        input.setAttribute('autocomplete', 'off');
        input.placeholder = placeholder || 'Тип и объём накопителя';
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
        var diskPlaceholder = resolveFieldPlaceholder(f, null);
        disks.forEach(function(d) {
            list.appendChild(createDiskRow(d, diskPlaceholder));
        });

        var addBtn = document.createElement('button');
        addBtn.type = 'button';
        addBtn.className = 'btn btn-outline-primary btn-sm arm-disk-add';
        addBtn.textContent = '+ Добавить накопитель';
        addBtn.addEventListener('click', function() {
            list.appendChild(createDiskRow('', diskPlaceholder));
            var inputs = list.querySelectorAll('input[name="PartCharDisks[]"]');
            if (inputs.length) {
                inputs[inputs.length - 1].focus();
            }
        });

        div.appendChild(submitted);
        div.appendChild(list);
        div.appendChild(addBtn);
        return div;
    }

    function renderFields(type) {
        var cfg = loadArmFormConfig();
        var templates = cfg.templates;
        var chars = cfg.chars;
        var fields = resolveTemplateFields(templates, type);
        var block = document.getElementById('dynamic-fields-block');
        var content = document.getElementById('dynamic-fields-content');
        if (!block || !content) {
            return;
        }
        if (!type || !fields || fields.length === 0) {
            block.classList.add('d-none');
            block.classList.remove('arm-form-create__config-visible');
            content.innerHTML = '';
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
            if (f.widget === 'choice-select' && f.options && f.options.length) {
                content.appendChild(renderChoiceSelectField(f));
                return;
            }
            var val = chars[f.name] || '';
            var div = createDynamicFieldWrapper();
            var datalistCfg = getDatalistWidgetConfig(f);
            var placeholder = resolveFieldPlaceholder(f, datalistCfg);
            var inputAttrs =
                'type="text" class="form-control" name="PartChar[' + escapeHtml(f.name) + ']" value="' +
                escapeHtml(val) + '" data-part="' + escapeHtml(f.part || '') + '" data-char="' +
                escapeHtml(f.char || '') + '"';
            if (datalistCfg) {
                inputAttrs += ' list="' + datalistCfg.listId + '" autocomplete="off"';
            }
            if (placeholder) {
                inputAttrs += ' placeholder="' + escapeHtml(placeholder) + '"';
            }
            div.innerHTML =
                '<label class="form-label">' + escapeHtml(f.label || f.name) + '</label>' +
                '<input ' + inputAttrs + '>';
            content.appendChild(div);
            if (datalistCfg && val) {
                ensureDatalistOption(datalistCfg.listId, val);
            }
        });
        block.classList.remove('d-none');
        block.classList.add('arm-form-create__config-visible');
    }

    function syncFormForSelect(sel) {
        if (!sel) {
            return;
        }
        renderFields(getSelectedType(sel));
    }

    function bindDatalistInputs(root, selector, listId) {
        var scope = root || document;
        var boundKey = 'datalistBound' + String(listId || '').replace(/[^a-z0-9]/gi, '');
        Array.prototype.forEach.call(scope.querySelectorAll(selector), function(input) {
            if (input.dataset[boundKey] === '1') {
                return;
            }
            input.dataset[boundKey] = '1';
            var sync = function() {
                ensureDatalistOption(listId, input.value);
            };
            input.addEventListener('change', sync);
            input.addEventListener('blur', sync);
        });
    }

    function init() {
        syncFormForSelect(document.getElementById('equipment-type-select'));
        bindDatalistInputs(document, '.js-location-datalist', 'arm-location-datalist');
        bindDatalistInputs(document, '.js-inventory-datalist', 'arm-inventory-datalist');
        bindDatalistInputs(document, '.js-equipment-name-datalist', 'arm-name-datalist');
    }

    window.armInitEquipmentCreateForm = init;
    window.armEnsureDatalistOption = ensureDatalistOption;
    window.armBindDatalistInputs = bindDatalistInputs;
    window.armBindLocationDatalist = function(root) {
        bindDatalistInputs(root, '.js-location-datalist', 'arm-location-datalist');
    };

    if (!document.documentElement.dataset.armFormDynamicBound) {
        document.documentElement.dataset.armFormDynamicBound = '1';
        document.addEventListener('change', function(e) {
            if (!e.target || e.target.id !== 'equipment-type-select') {
                return;
            }
            renderFields(getSelectedType(e.target));
        });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
