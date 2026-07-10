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
        if (field.name === 'ip' || field.name === 'misc_ip') {
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

    function getOrgTechValues(orgTechOverride) {
        if (orgTechOverride !== undefined) {
            return orgTechOverride;
        }
        return window.armFormOrgTech || {};
    }

    function renderChoiceSelectField(f, chars) {
        chars = chars || window.armFormChars || {};
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

    function renderTextareaPartCharField(f, chars) {
        chars = chars || window.armFormChars || {};
        var val = chars[f.name] || '';
        var div = createDynamicFieldWrapper();
        div.classList.add('arm-dynamic-field--full');
        var label = document.createElement('label');
        label.className = 'form-label';
        label.textContent = f.label || f.name;

        var textarea = document.createElement('textarea');
        textarea.className = 'form-control';
        textarea.name = 'PartChar[' + (f.name || '') + ']';
        textarea.rows = 4;
        textarea.setAttribute('data-part', f.part || '');
        textarea.setAttribute('data-char', f.char || '');
        if (f.placeholder) {
            textarea.placeholder = String(f.placeholder);
        }
        textarea.value = String(val);

        div.appendChild(label);
        div.appendChild(textarea);
        return div;
    }

    function renderCartridgeSelectField(f, orgTechOverride) {
        var orgTech = getOrgTechValues(orgTechOverride);
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

    function isPrinterOrMfuType(type) {
        var t = String(type || '').trim().toLowerCase();
        return t === 'принтер' || t === 'мфу';
    }

    function isMiscType(type) {
        return String(type || '').trim().toLowerCase() === 'прочее';
    }

    function isCartridgeField(field) {
        return !!field && (field.widget === 'cartridge-select' || field.name === 'cartridge_procurement');
    }

    function filterConfigFields(fields) {
        if (!fields || !fields.length) {
            return [];
        }
        return fields.filter(function(field) {
            return !isCartridgeField(field);
        });
    }

    function syncPrinterCartridgeSection(type, root) {
        var section = findInArmFormRoot('arm-form-cartridge-section', root);
        if (!section) {
            return;
        }
        if (isPrinterOrMfuType(type)) {
            section.classList.remove('d-none');
        } else {
            section.classList.add('d-none');
        }
    }

    function syncDescriptionSection(type, root) {
        var form = findInArmFormRoot('arm-create-form', root);
        var section = findInArmFormRoot('arm-form-description-section', root);
        if (!form || !section) {
            return;
        }
        var titleEl = section.querySelector('#arm-create-section-note');
        var textarea = section.querySelector('[name="Equipment[description]"]');
        var printerTitle = form.getAttribute('data-arm-description-title-printer') || 'Комментарий';
        var defaultTitle = form.getAttribute('data-arm-description-title-default') || 'Примечание';
        var printerPlaceholder = form.getAttribute('data-arm-description-placeholder-printer') || '';
        var defaultPlaceholder = form.getAttribute('data-arm-description-placeholder-default') || '';
        var isPrinter = isPrinterOrMfuType(type);
        var isMisc = isMiscType(type);
        if (titleEl) {
            titleEl.textContent = isPrinter ? printerTitle : defaultTitle;
        }
        if (textarea) {
            textarea.placeholder = isPrinter ? printerPlaceholder : defaultPlaceholder;
        }
        section.classList.toggle('d-none', isMisc);
    }

    function collectPartCharValuesFromDom(content) {
        var values = {};
        if (!content) {
            return values;
        }
        content.querySelectorAll('[name^="PartChar["]').forEach(function(el) {
            if (!el.name) {
                return;
            }
            var match = el.name.match(/^PartChar\[([^\]]+)\]$/);
            if (!match) {
                return;
            }
            values[match[1]] = el.value;
        });
        return values;
    }

    function getArmFormRoot(container) {
        if (container && container.querySelector) {
            return container;
        }
        var modalBody = document.getElementById('createArmModalBody');
        if (modalBody && modalBody.querySelector('#arm-create-form')) {
            return modalBody;
        }
        return document;
    }

    function findInArmFormRoot(id, root) {
        if (!id) {
            return null;
        }
        root = root || getArmFormRoot();
        if (root && root !== document && root.querySelector) {
            var scoped = root.querySelector('#' + id);
            if (scoped) {
                return scoped;
            }
        }
        return document.getElementById(id);
    }

    function readConfigJsonFromForm(root) {
        var form = findInArmFormRoot('arm-create-form', root);
        if (!form) {
            return '';
        }
        var raw = form.getAttribute('data-arm-form-config') || '';
        return String(raw).trim();
    }

    function findArmFormConfigNode(root) {
        root = getArmFormRoot(root);
        var fromForm = readConfigJsonFromForm(root);
        if (fromForm) {
            return { source: 'form', value: fromForm };
        }
        if (root && root !== document && root.querySelector) {
            var inRoot = root.querySelector('#arm-form-config-json');
            if (inRoot && inRoot.value) {
                return { source: 'textarea', node: inRoot, value: inRoot.value };
            }
        }
        var fallback = document.getElementById('arm-form-config-json');
        if (fallback && fallback.value) {
            return { source: 'textarea', node: fallback, value: fallback.value };
        }
        return null;
    }

    function applyArmFormConfigData(data) {
        if (!data || typeof data !== 'object') {
            return { templates: {}, chars: {}, orgTech: {} };
        }
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
    }

    function loadArmFormConfig(root) {
        var configNode = findArmFormConfigNode(root);
        if (configNode && configNode.value) {
            try {
                return applyArmFormConfigData(JSON.parse(configNode.value));
            } catch (err) {
                if (window.console && typeof window.console.error === 'function') {
                    window.console.error('ARM form config JSON parse failed', err);
                }
            }
        }
        var templates = window.armFormFieldTemplates;
        var chars = window.armFormChars || {};
        var orgTech = window.armFormOrgTech || {};
        if (templates && typeof templates === 'object' && Object.keys(templates).length > 0) {
            return { templates: templates, chars: chars, orgTech: orgTech };
        }
        return { templates: {}, chars: {}, orgTech: {} };
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

    function renderDatePartCharField(f, chars) {
        var div = createDynamicFieldWrapper();
        var val = normalizeDateForInput(chars[f.name] || '');
        var placeholder = resolveFieldPlaceholder(f, null);
        var inputAttrs =
            'type="date" class="form-control" name="PartChar[' + escapeHtml(f.name) + ']" value="' +
            escapeHtml(val) + '" data-part="' + escapeHtml(f.part || '') + '" data-char="' +
            escapeHtml(f.char || '') + '"';
        if (placeholder) {
            inputAttrs += ' title="' + escapeHtml(placeholder) + '"';
        }
        div.innerHTML =
            '<label class="form-label">' + escapeHtml(f.label || f.name) + '</label>' +
            '<input ' + inputAttrs + '>';
        return div;
    }

    function renderNumberPartCharField(f, chars) {
        var div = createDynamicFieldWrapper();
        var val = chars[f.name] || '';
        var placeholder = resolveFieldPlaceholder(f, null);
        var inputAttrs =
            'type="number" class="form-control" name="PartChar[' + escapeHtml(f.name) + ']" value="' +
            escapeHtml(val) + '" data-part="' + escapeHtml(f.part || '') + '" data-char="' +
            escapeHtml(f.char || '') + '" min="0" max="30" step="0.5" inputmode="decimal"';
        if (placeholder) {
            inputAttrs += ' placeholder="' + escapeHtml(placeholder) + '"';
        }
        div.innerHTML =
            '<label class="form-label">' + escapeHtml(f.label || f.name) + '</label>' +
            '<input ' + inputAttrs + '>';
        return div;
    }

    function normalizeDateForInput(value) {
        var val = String(value || '').trim();
        if (!val) {
            return '';
        }
        if (/^\d{4}-\d{2}-\d{2}$/.test(val)) {
            return val;
        }
        var match = val.match(/^(\d{1,2})\.(\d{1,2})\.(\d{4})$/);
        if (match) {
            return match[3] + '-' + String(match[2]).padStart(2, '0') + '-' + String(match[1]).padStart(2, '0');
        }
        return val;
    }

    function resolveDynamicDom(domOpts) {
        domOpts = domOpts || {};
        return {
            blockId: domOpts.blockId || 'dynamic-fields-block',
            contentId: domOpts.contentId || 'dynamic-fields-content',
            chars: domOpts.chars !== undefined ? domOpts.chars : null,
            orgTech: domOpts.orgTech !== undefined ? domOpts.orgTech : null,
            root: domOpts.root || null,
        };
    }

    function renderFields(type, domOpts) {
        var dom = resolveDynamicDom(domOpts);
        var root = getArmFormRoot(dom.root);
        var cfg = loadArmFormConfig(root);
        var templates = cfg.templates;
        var chars = dom.chars !== null ? dom.chars : cfg.chars;
        var orgTechOverride = dom.orgTech;
        var fields = resolveTemplateFields(templates, type);
        var block = findInArmFormRoot(dom.blockId, root);
        var content = findInArmFormRoot(dom.contentId, root);
        if (!block || !content) {
            return;
        }
        var domChars = collectPartCharValuesFromDom(content);
        if (Object.keys(domChars).length > 0) {
            chars = Object.assign({}, chars, domChars);
        }
        syncPrinterCartridgeSection(type, root);
        syncDescriptionSection(type, root);
        if (!type || !fields || fields.length === 0) {
            if (content.querySelector('.arm-dynamic-field')) {
                if (type) {
                    block.classList.remove('d-none');
                    block.classList.add('arm-form-create__config-visible');
                }
                return;
            }
            block.classList.add('d-none');
            block.classList.remove('arm-form-create__config-visible');
            content.innerHTML = '';
            return;
        }
        fields = filterConfigFields(fields);
        if (fields.length === 0) {
            if (content.querySelector('.arm-dynamic-field')) {
                block.classList.remove('d-none');
                block.classList.add('arm-form-create__config-visible');
                return;
            }
            block.classList.add('d-none');
            block.classList.remove('arm-form-create__config-visible');
            content.innerHTML = '';
            return;
        }
        content.innerHTML = '';
        fields.forEach(function(f) {
            if (isCartridgeField(f)) {
                return;
            }
            if (f.widget === 'disk-datalist-multi' || f.name === 'disk') {
                content.appendChild(renderDiskMultiField(f, chars));
                return;
            }
            if (f.widget === 'cartridge-select' || f.name === 'cartridge_procurement') {
                content.appendChild(renderCartridgeSelectField(f, orgTechOverride));
                return;
            }
            if (f.widget === 'choice-select' && f.options && f.options.length) {
                content.appendChild(renderChoiceSelectField(f, chars));
                return;
            }
            if (f.widget === 'date') {
                content.appendChild(renderDatePartCharField(f, chars));
                return;
            }
            if (f.widget === 'number') {
                content.appendChild(renderNumberPartCharField(f, chars));
                return;
            }
            if (f.widget === 'textarea') {
                content.appendChild(renderTextareaPartCharField(f, chars));
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

    var DELIVERY_LINE_DOM = {
        blockId: 'delivery-line-dynamic-block',
        contentId: 'delivery-line-dynamic-content',
    };

    function syncFormForSelect(sel, domOpts) {
        if (!sel) {
            return;
        }
        domOpts = domOpts || {};
        if (!domOpts.root) {
            domOpts.root = sel.closest('#createArmModalBody') || getArmFormRoot();
        }
        renderFields(getSelectedType(sel), domOpts);
    }

    function syncEquipmentConfigFields(container) {
        var root = getArmFormRoot(container);
        if (typeof window.armApplyArmFormConfigFromDom === 'function') {
            window.armApplyArmFormConfigFromDom(root);
        }
        var sel = findInArmFormRoot('equipment-type-select', root);
        if (!sel) {
            return;
        }
        renderFields(getSelectedType(sel), { root: root });
    }

    function syncDeliveryLineFields(clearChars) {
        var sel = document.getElementById('deliveryLineType');
        if (!sel) {
            return;
        }
        var domOpts = Object.assign({}, DELIVERY_LINE_DOM);
        if (clearChars) {
            domOpts.chars = {};
            domOpts.orgTech = {};
        } else {
            domOpts.chars = window.armFormChars || {};
            domOpts.orgTech = window.armFormOrgTech || {};
        }
        renderFields(getSelectedType(sel), domOpts);
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

    function init(container) {
        var root = getArmFormRoot(container);
        syncEquipmentConfigFields(root);
        bindDatalistInputs(root, '.js-location-datalist', 'arm-location-datalist');
        bindDatalistInputs(root, '.js-inventory-datalist', 'arm-inventory-datalist');
        bindDatalistInputs(root, '.js-equipment-name-datalist', 'arm-name-datalist');
    }

    window.armInitEquipmentCreateForm = init;
    window.armRenderDynamicFields = renderFields;
    window.armSyncEquipmentConfigFields = syncEquipmentConfigFields;
    window.armApplyArmFormConfigFromDom = function(container) {
        var root = getArmFormRoot(container);
        var configNode = findArmFormConfigNode(root);
        if (!configNode || !configNode.value) {
            return false;
        }
        try {
            applyArmFormConfigData(JSON.parse(configNode.value));
            return true;
        } catch (err) {
            if (window.console && typeof window.console.error === 'function') {
                window.console.error('ARM form config apply failed', err);
            }
            return false;
        }
    };
    window.armClearFormConfigGlobals = function() {
        window.armFormFieldTemplates = undefined;
        window.armFormChars = undefined;
        window.armFormOrgTech = undefined;
    };
    window.armSyncDeliveryLineFields = syncDeliveryLineFields;
    window.armEnsureDatalistOption = ensureDatalistOption;
    window.armBindDatalistInputs = bindDatalistInputs;
    window.armBindLocationDatalist = function(root) {
        bindDatalistInputs(root, '.js-location-datalist', 'arm-location-datalist');
    };

    if (!document.documentElement.dataset.armFormDynamicBound) {
        document.documentElement.dataset.armFormDynamicBound = '1';
        document.addEventListener('change', function(e) {
            if (!e.target) {
                return;
            }
            if (e.target.id === 'equipment-type-select') {
                var root = e.target.closest('#createArmModalBody') || getArmFormRoot();
                renderFields(getSelectedType(e.target), { root: root });
                return;
            }
            if (e.target.id === 'deliveryLineType') {
                window.armFormChars = {};
                window.armFormOrgTech = {};
                syncDeliveryLineFields(false);
            }
        });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
