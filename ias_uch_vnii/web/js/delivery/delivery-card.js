/**
 * Модальное окно карточки поставки.
 */
(function() {
    'use strict';

    var unitsApi = null;
    var bulkMode = 'serials';
    var currentDeliveryId = null;
    var currentLineId = 0;
    var cardModalInstance = null;
    var unitsFitColumnsTimer = null;
    var unitsSuppressFitUntil = 0;

    function getContainer() {
        return document.getElementById('agGridDeliveryContainer');
    }

    function cardModalUrl(id, lineId) {
        var c = getContainer();
        var tpl = (c && c.dataset.cardModalUrlTemplate) || '/index.php?r=delivery/card-modal&id=__ID__';
        var url = tpl.replace('__ID__', String(id));
        if (lineId) {
            url += (url.indexOf('?') >= 0 ? '&' : '?') + 'line_id=' + encodeURIComponent(lineId);
        }
        return url;
    }

    function apiUrl(action, id) {
        return '/index.php?r=delivery/' + action + '&id=' + encodeURIComponent(id);
    }

    function csrfToken() {
        var meta = document.querySelector('meta[name="csrf-token"]');
        return meta ? meta.content : '';
    }

    function csrfParam() {
        var meta = document.querySelector('meta[name="csrf-param"]');
        return meta ? meta.getAttribute('content') : '_csrf';
    }

    function postJson(url, body) {
        var data = new FormData();
        Object.keys(body || {}).forEach(function(k) {
            if (body[k] !== undefined && body[k] !== null) {
                data.append(k, body[k]);
            }
        });
        var token = csrfToken();
        var param = csrfParam();
        if (token && param) {
            data.append(param, token);
        }
        return fetch(url, {
            method: 'POST',
            body: data,
            credentials: 'same-origin',
            headers: { 'X-Requested-With': 'XMLHttpRequest' },
        }).then(function(r) { return r.json(); });
    }

    window.deliveryShowToast = function(type, message) {
        showToast(type, message);
    };

    function showToast(type, message) {
        if (!message) {
            return;
        }
        var alertClass = type === 'success' ? 'alert-success' : 'alert-danger';
        var el = document.createElement('div');
        el.className = 'alert ' + alertClass + ' alert-dismissible fade show';
        el.style.cssText = 'position:fixed;top:20px;right:20px;z-index:10070;min-width:280px;max-width:420px;';
        el.innerHTML = escapeHtml(message)
            + '<button type="button" class="btn-close" data-bs-dismiss="alert"></button>';
        document.body.appendChild(el);
        setTimeout(function() {
            if (el.parentNode) {
                bootstrap.Alert.getOrCreateInstance(el).close();
            }
        }, 5000);
    }

    function escapeHtml(str) {
        var div = document.createElement('div');
        div.textContent = str;
        return div.innerHTML;
    }

    function getContentRoot() {
        return document.querySelector('#deliveryCardModalBody .delivery-card-content');
    }

    function getActiveLineId() {
        var root = getContentRoot();
        if (root) {
            var active = root.querySelector('.delivery-line-row.is-active');
            if (active) {
                return parseInt(active.getAttribute('data-line-id'), 10) || 0;
            }
            return parseInt(root.getAttribute('data-line-id'), 10) || 0;
        }
        return currentLineId;
    }

    function setActiveLine(lineId) {
        currentLineId = lineId;
        var root = getContentRoot();
        if (!root) {
            return;
        }
        root.setAttribute('data-line-id', String(lineId));
        root.querySelectorAll('.delivery-line-row').forEach(function(row) {
            var id = parseInt(row.getAttribute('data-line-id'), 10);
            row.classList.toggle('is-active', id === lineId);
        });
    }

    function shouldSkipFitUnitsColumns() {
        return Date.now() < unitsSuppressFitUntil;
    }

    function markUnitsColumnUserResize() {
        unitsSuppressFitUntil = Date.now() + 2500;
    }

    /** Подгонка ширины столбцов под область таблицы — как в «Учёт ТС». */
    function scheduleFitUnitsColumns(force) {
        clearTimeout(unitsFitColumnsTimer);
        unitsFitColumnsTimer = setTimeout(function() {
            if (!force && shouldSkipFitUnitsColumns()) {
                return;
            }
            if (!unitsApi || typeof unitsApi.sizeColumnsToFit !== 'function') {
                return;
            }
            var container = document.getElementById('agGridDeliveryUnits');
            if (!container || container.clientWidth < 80) {
                return;
            }
            try {
                unitsApi.sizeColumnsToFit();
            } catch (e) {
                console.warn('AG Grid (техника в закупке): sizeColumnsToFit', e);
            }
            scheduleUnitsRowHeights();
        }, 50);
    }

    function scheduleUnitsRowHeights() {
        if (unitsApi && window.AgGridWrap && typeof window.AgGridWrap.scheduleResetRowHeights === 'function') {
            window.AgGridWrap.scheduleResetRowHeights(unitsApi);
        }
    }

    /** Высота строки по содержимому — как в «Учёт ТС» (компактнее, чем общий MIN_ROW_HEIGHT AgGridWrap). */
    function getDeliveryUnitsRowHeight(params) {
        var wrap = window.AgGridWrap;
        var maxLines = 1;
        if (wrap && params && params.data && params.api
            && typeof params.api.getAllDisplayedColumns === 'function') {
            params.api.getAllDisplayedColumns().forEach(function(col) {
                if (!col || typeof col.getColDef !== 'function') {
                    return;
                }
                var def = col.getColDef();
                var field = def.field;
                if (!field || (def.width > 0 && def.width <= 48 && !def.flex)) {
                    return;
                }
                var raw = params.data[field];
                if (raw == null || String(raw).trim() === '') {
                    return;
                }
                var text = String(raw);
                var explicitLines = text.split(/\r?\n/).filter(function(s) {
                    return String(s).trim() !== '';
                }).length;
                var wrapped = wrap.estimateLines(text, wrap.getColumnWidth(col));
                maxLines = Math.max(maxLines, explicitLines, Math.max(1, wrapped - 1));
            });
        }
        var el = document.getElementById('agGridDeliveryUnits');
        var style = el ? getComputedStyle(el) : null;
        var base = style ? parseFloat(style.getPropertyValue('--arm-grid-row-base')) : NaN;
        var step = style ? parseFloat(style.getPropertyValue('--arm-grid-row-step')) : NaN;
        var max = style ? parseFloat(style.getPropertyValue('--arm-grid-row-max')) : NaN;
        if (!Number.isFinite(base)) {
            base = 18;
        }
        if (!Number.isFinite(step)) {
            step = 12;
        }
        if (!Number.isFinite(max)) {
            max = 84;
        }
        var n = Math.max(1, Math.min(6, maxLines));

        return Math.min(max, base + n * step);
    }

    function syncUnitsFilterHint() {
        var hint = document.getElementById('deliveryUnitsFilterHint');
        var root = getContentRoot();
        if (!hint || !root) {
            return;
        }
        var active = root.querySelector('.delivery-line-row.is-active');
        if (!active) {
            hint.textContent = '';
            hint.hidden = true;
            return;
        }
        var typeBtn = active.querySelector('.delivery-line-select');
        var typeText = typeBtn ? typeBtn.textContent.trim() : '';
        var nameParts = [];
        active.querySelectorAll('td .small.text-muted').forEach(function(el) {
            var t = el.textContent.trim();
            if (t && t.indexOf('Гарантия:') !== 0) {
                nameParts.push(t);
            }
        });
        var label = typeText;
        if (nameParts.length) {
            label += ' — ' + nameParts[0];
        }
        hint.textContent = label ? 'Показано: ' + label : '';
        hint.hidden = !label;
    }

    function selectDeliveryLine(lineId) {
        if (!lineId) {
            return;
        }
        setActiveLine(lineId);
        syncUnitsFilterHint();
        loadUnits();
    }

    function loadUnits() {
        if (!unitsApi || !currentDeliveryId) {
            return;
        }
        var lineId = getActiveLineId();
        var searchEl = document.getElementById('deliveryUnitsSearch');
        var search = searchEl ? searchEl.value.trim() : '';
        var url = apiUrl('get-units', currentDeliveryId);
        if (lineId > 0) {
            url += '&line_id=' + encodeURIComponent(lineId);
        }
        if (search) {
            url += '&search=' + encodeURIComponent(search);
        }
        fetch(url, { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
            .then(function(r) { return r.json(); })
            .then(function(res) {
                unitsApi.setGridOption('rowData', (res && res.success && res.data) ? res.data : []);
                scheduleFitUnitsColumns();
                scheduleUnitsRowHeights();
            });
    }

    function destroyUnitsGrid() {
        if (unitsApi) {
            unitsApi.destroy();
            unitsApi = null;
        }
    }

    function initUnitsGrid() {
        destroyUnitsGrid();
        var container = document.getElementById('agGridDeliveryUnits');
        var utils = window.SectionGridUtils;
        if (!container || !utils || typeof agGrid === 'undefined') {
            return;
        }

        var armView = '/index.php?r=arm/view';

        var wrap = window.AgGridWrap;
        var defaultColDef = wrap
            ? wrap.mergeDefaultColDef({
                sortable: true,
                filter: true,
                resizable: true,
                wrapText: true,
                autoHeight: false,
                cellClass: 'ag-cell-wrap-text',
            }, true)
            : utils.mergeDefaultColDef();

        var columnDefs = [
            {
                headerName: '№',
                field: 'seq_no',
                minWidth: 52,
                maxWidth: 64,
                suppressSizeToFit: true,
                wrapText: true,
            },
            { headerName: 'Тип', field: 'line_type', minWidth: 100, wrapText: true },
            {
                headerName: 'Наименование',
                field: 'line_name',
                minWidth: 140,
                wrapText: true,
                cellRenderer: function(params) {
                    var text = params.value != null && String(params.value).trim() !== ''
                        ? String(params.value)
                        : '—';
                    if (!params.data || !params.data.equipment_id) {
                        return escapeHtml(text);
                    }
                    var sep = armView.indexOf('?') >= 0 ? '&' : '?';
                    return '<a href="' + armView + sep + 'id=' + encodeURIComponent(params.data.equipment_id)
                        + '" target="_blank" rel="noopener" title="Открыть карточку актива">'
                        + escapeHtml(text) + '</a>';
                },
            },
            { headerName: 'Серийный', field: 'serial_number', minWidth: 100, wrapText: true },
            { headerName: 'Инв. №', field: 'inventory_number', minWidth: 90, wrapText: true },
            { headerName: 'Где сейчас', field: 'holder', minWidth: 120, wrapText: true },
            { headerName: 'Помещение', field: 'location_name', minWidth: 100, wrapText: true },
        ];

        var gridOpts = {
            columnDefs: columnDefs,
            theme: 'legacy',
            animateRows: true,
            defaultColDef: defaultColDef,
            domLayout: 'normal',
            suppressCellFocus: true,
            suppressHorizontalScroll: false,
            alwaysShowHorizontalScroll: true,
            getRowHeight: getDeliveryUnitsRowHeight,
            onGridReady: function(params) {
                unitsApi = params.api;
                loadUnits();
            },
            onFirstDataRendered: function() {
                scheduleFitUnitsColumns();
                scheduleUnitsRowHeights();
            },
            onDisplayedColumnsChanged: scheduleUnitsRowHeights,
            onColumnResized: function(event) {
                markUnitsColumnUserResize();
                if (event && event.finished) {
                    scheduleUnitsRowHeights();
                }
            },
            onGridSizeChanged: function() {
                scheduleUnitsRowHeights();
                if (shouldSkipFitUnitsColumns()) {
                    return;
                }
                if (container && container.clientWidth >= 80) {
                    scheduleFitUnitsColumns();
                }
            },
        };

        var createGrid = window.iasCreateGrid || (window.AgGridFilter && window.AgGridFilter.iasCreateGrid);
        (typeof createGrid === 'function' ? createGrid : agGrid.createGrid.bind(agGrid))(container, gridOpts);
        requestAnimationFrame(function() {
            requestAnimationFrame(function() {
                scheduleFitUnitsColumns(true);
            });
        });
    }

    function mountDeliveryHeader() {
        var headerEl = document.getElementById('deliveryCardModalHeader');
        var root = getContentRoot();
        if (!headerEl || !root) {
            return;
        }
        var slot = root.querySelector('#deliveryCardHeaderSlot');
        if (!slot) {
            return;
        }
        headerEl.innerHTML = '';
        headerEl.appendChild(slot);
        slot.classList.add('arm-view__header-slot--in-modal');
        var titleNode = slot.querySelector('.arm-view__title');
        var label = document.getElementById('deliveryCardModalLabel');
        if (label && titleNode) {
            label.textContent = titleNode.textContent.trim();
        }
        var subtitle = document.getElementById('deliveryCardModalSubtitle');
        if (subtitle) {
            subtitle.hidden = true;
        }
    }

    function syncActionLinks() {
        var exportBtn = document.getElementById('deliveryCardExportBtn');
        if (exportBtn && currentDeliveryId) {
            exportBtn.href = apiUrl('export-units', currentDeliveryId);
        }
    }

    function bindCardEvents(meta) {
        var root = getContentRoot();
        if (!root) {
            return;
        }

        root.querySelectorAll('.delivery-line-row').forEach(function(row) {
            row.addEventListener('click', function(e) {
                if (e.target.closest('button') && !e.target.closest('.delivery-line-select')) {
                    return;
                }
                var lineId = parseInt(row.getAttribute('data-line-id'), 10);
                if (!lineId) {
                    return;
                }
                selectDeliveryLine(lineId);
            });
            row.querySelectorAll('.delivery-line-select').forEach(function(btn) {
                btn.addEventListener('click', function(e) {
                    e.preventDefault();
                });
            });
            if (meta.isDraft) {
                row.addEventListener('dblclick', function() {
                    try {
                        openLineModal(JSON.parse(row.getAttribute('data-line')));
                    } catch (err) { /* ignore */ }
                });
            }
        });

        var addLine = document.getElementById('deliveryAddLineBtn');
        if (addLine) {
            addLine.onclick = function() { openLineModal(null); };
        }

        var search = document.getElementById('deliveryUnitsSearch');
        if (search) {
            var t;
            search.oninput = function() {
                clearTimeout(t);
                t = setTimeout(loadUnits, 300);
            };
        }

        ['deliveryBulkSerialBtn', 'deliveryBulkInventoryBtn', 'deliveryBulkPairsBtn'].forEach(function(id) {
            var btn = document.getElementById(id);
            if (!btn) {
                return;
            }
            btn.onclick = function() {
                if (id === 'deliveryBulkInventoryBtn') {
                    openBulkModal('inventory');
                } else if (id === 'deliveryBulkPairsBtn') {
                    openBulkModal('pairs');
                } else {
                    openBulkModal('serials');
                }
            };
        });
    }

    function bindModalFooterActions(meta) {
        var postBtn = document.getElementById('deliveryCardPostBtn');
        if (postBtn) {
            postBtn.onclick = function() {
                if (!confirm('Провести поставку? Будут созданы карточки техники на складах, указанных в строках.')) {
                    return;
                }
                postJson(apiUrl('post-delivery', currentDeliveryId), {}).then(function(res) {
                    showToast(res.success ? 'success' : 'error', res.message);
                    if (res.success) {
                        reloadCard();
                        if (typeof window.refreshDeliveryGrid === 'function') {
                            window.refreshDeliveryGrid();
                        }
                    }
                });
            };
        }

        var delBtn = document.getElementById('deliveryCardDeleteBtn');
        if (delBtn) {
            delBtn.onclick = function() {
                if (!confirm('Удалить черновик поставки?')) {
                    return;
                }
                postJson(apiUrl('delete', currentDeliveryId), {}).then(function(res) {
                    showToast(res.success ? 'success' : 'error', res.message);
                    if (res.success) {
                        if (cardModalInstance) {
                            cardModalInstance.hide();
                        }
                        if (typeof window.refreshDeliveryGrid === 'function') {
                            window.refreshDeliveryGrid();
                        }
                    }
                });
            };
        }
    }

    function bindHeaderForm() {
        var form = document.getElementById('delivery-header-form');
        if (!form) {
            return;
        }
        form.addEventListener('submit', function(e) {
            e.preventDefault();
            var data = new FormData(form);
            var body = {};
            data.forEach(function(v, k) { body[k] = v; });
            postJson(apiUrl('save-header', currentDeliveryId), body).then(function(res) {
                showToast(res.success ? 'success' : 'error', res.message || 'Сохранено');
                if (res.success) {
                    reloadCard();
                    if (typeof window.refreshDeliveryGrid === 'function') {
                        window.refreshDeliveryGrid();
                    }
                }
            });
        });
    }

    function stripExcludedLineChars(tpl) {
        tpl = tpl || {};
        var part = Object.assign({}, tpl.PartChar || {});
        delete part.hostname;
        delete part.ip;
        return {
            PartChar: part,
            OrgTech: tpl.OrgTech || {},
        };
    }

    function applyLineCharTemplate(lineData) {
        var tpl = stripExcludedLineChars(lineData && lineData.char_template ? lineData.char_template : {});
        window.armFormChars = tpl.PartChar || {};
        window.armFormOrgTech = tpl.OrgTech || {};
        if (typeof window.armSyncDeliveryLineFields === 'function') {
            window.armSyncDeliveryLineFields(false);
        }
    }

    function openLineModal(lineData) {
        var modalEl = document.getElementById('deliveryLineModal');
        if (!modalEl) {
            return;
        }
        document.getElementById('deliveryLineId').value = lineData ? lineData.id : '';
        document.getElementById('deliveryLineType').value = lineData ? lineData.equipment_type : '';
        document.getElementById('deliveryLineWarehouse').value = lineData && lineData.warehouse_location_id
            ? String(lineData.warehouse_location_id) : '';
        document.getElementById('deliveryLineName').value = lineData ? lineData.name : '';
        document.getElementById('deliveryLineQty').value = lineData ? lineData.quantity : 1;
        var warrantyEl = document.getElementById('deliveryLineWarrantyYears');
        if (warrantyEl) {
            warrantyEl.value = lineData && lineData.warranty_years != null && lineData.warranty_years !== ''
                ? String(lineData.warranty_years)
                : '';
        }
        var delBtn = document.getElementById('deliveryLineDeleteBtn');
        if (delBtn) {
            delBtn.hidden = !lineData || !lineData.id;
        }
        document.getElementById('deliveryLineModalLabel').textContent = lineData && lineData.id
            ? 'Редактирование техники'
            : 'Добавить технику';
        if (!lineData) {
            window.armFormChars = {};
            window.armFormOrgTech = {};
        }
        applyLineCharTemplate(lineData);
        bootstrap.Modal.getOrCreateInstance(modalEl).show();
    }

    function postForm(url, formEl) {
        var data = new FormData(formEl);
        var token = csrfToken();
        var param = csrfParam();
        if (token && param) {
            data.append(param, token);
        }
        return fetch(url, {
            method: 'POST',
            body: data,
            credentials: 'same-origin',
            headers: { 'X-Requested-With': 'XMLHttpRequest' },
        }).then(function(r) { return r.json(); });
    }

    function openBulkModal(mode) {
        bulkMode = mode;
        var modalEl = document.getElementById('deliveryBulkModal');
        var title = document.getElementById('deliveryBulkModalTitle');
        var hint = document.getElementById('deliveryBulkModalHint');
        var text = document.getElementById('deliveryBulkText');
        if (!modalEl || !title) {
            return;
        }
        if (mode === 'inventory') {
            title.textContent = 'Массовый ввод инвентарных номеров';
            hint.textContent = 'По одному номеру на строку, в порядке единиц выбранной строки.';
        } else if (mode === 'pairs') {
            title.textContent = 'Связка серийный — инвентарный';
            hint.textContent = 'Две колонки из Excel: серийный и инвентарный в одной строке, '
                + 'между ними табуляция. По одной паре на строку.';
        } else {
            title.textContent = 'Массовый ввод серийных номеров';
            hint.textContent = 'По одному серийному на строку для активной строки слева.';
        }
        if (text) {
            text.value = '';
            if (mode === 'pairs') {
                text.placeholder = 'Серийный\tИнв. №\n(вставьте две колонки из Excel)';
            } else {
                text.placeholder = 'По одному значению на строку';
            }
        }
        bootstrap.Modal.getOrCreateInstance(modalEl).show();
    }

    function initLineModal() {
        var saveBtn = document.getElementById('deliveryLineSaveBtn');
        var form = document.getElementById('deliveryLineForm');
        if (saveBtn && form) {
            saveBtn.onclick = function() {
                if (!form.reportValidity()) {
                    return;
                }
                var lineId = document.getElementById('deliveryLineId').value;
                postForm(apiUrl('save-line', currentDeliveryId), form).then(function(res) {
                    showToast(res.success ? 'success' : 'error', res.message);
                    if (res.success) {
                        bootstrap.Modal.getInstance(document.getElementById('deliveryLineModal')).hide();
                        reloadCard(res.line_id || lineId);
                    }
                });
            };
        }
        var delBtn = document.getElementById('deliveryLineDeleteBtn');
        if (delBtn) {
            delBtn.onclick = function() {
                var lineId = document.getElementById('deliveryLineId').value;
                if (!lineId || !confirm('Удалить строку?')) {
                    return;
                }
                postJson(apiUrl('delete-line', currentDeliveryId), { line_id: lineId }).then(function(res) {
                    showToast(res.success ? 'success' : 'error', res.message);
                    if (res.success) {
                        bootstrap.Modal.getInstance(document.getElementById('deliveryLineModal')).hide();
                        reloadCard();
                    }
                });
            };
        }
    }

    function initBulkModal() {
        var applyBtn = document.getElementById('deliveryBulkApplyBtn');
        if (!applyBtn) {
            return;
        }
        applyBtn.onclick = function() {
            var text = (document.getElementById('deliveryBulkText') || {}).value || '';
            var lineId = getActiveLineId();
            var promise;
            if (bulkMode === 'inventory') {
                promise = postJson(apiUrl('bulk-inventory', currentDeliveryId), {
                    text: text,
                    line_id: lineId || '',
                    mode: 'seq',
                });
            } else if (bulkMode === 'pairs') {
                promise = postJson(apiUrl('bulk-inventory', currentDeliveryId), {
                    text: text,
                    line_id: lineId || '',
                    mode: 'serial_map',
                });
            } else {
                if (!lineId) {
                    showToast('error', 'Выберите строку поставки слева.');
                    return;
                }
                promise = postJson(apiUrl('bulk-serials', currentDeliveryId), {
                    text: text,
                    line_id: lineId,
                    mode: 'seq',
                });
            }
            promise.then(function(res) {
                showToast(res.success ? 'success' : 'error', res.message);
                if (res.success) {
                    bootstrap.Modal.getInstance(document.getElementById('deliveryBulkModal')).hide();
                    loadUnits();
                    reloadCard();
                    if (typeof window.refreshDeliveryGrid === 'function') {
                        window.refreshDeliveryGrid();
                    }
                }
            });
        };
    }

    function reloadCard(preferredLineId) {
        if (!currentDeliveryId) {
            return;
        }
        var lineId = preferredLineId || getActiveLineId();
        loadCardBody(currentDeliveryId, lineId);
    }

    function resetCardModalHeader() {
        var headerEl = document.getElementById('deliveryCardModalHeader');
        if (!headerEl) {
            return;
        }
        headerEl.innerHTML = '<div class="arm-view-modal__header-body">'
            + '<h5 class="modal-title mb-0" id="deliveryCardModalLabel">Поставка</h5>'
            + '<p class="text-muted small mb-0 mt-1" id="deliveryCardModalSubtitle">Загрузка…</p>'
            + '</div>';
    }

    function loadCardBody(id, lineId) {
        var body = document.getElementById('deliveryCardModalBody');
        if (!body) {
            return;
        }
        destroyUnitsGrid();
        resetCardModalHeader();
        body.innerHTML = '<div class="arm-view-modal__loading text-center text-muted py-5">'
            + '<i class="fas fa-circle-notch fa-spin fa-2x"></i><p class="mt-3 mb-0">Загрузка…</p></div>';

        fetch(cardModalUrl(id, lineId), { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
            .then(function(r) { return r.text(); })
            .then(function(html) {
                body.innerHTML = html;
                var root = getContentRoot();
                var isDraft = root && root.getAttribute('data-is-draft') === '1';
                currentLineId = getActiveLineId();
                mountDeliveryHeader();
                syncActionLinks();
                bindCardEvents({ isDraft: isDraft });
                syncUnitsFilterHint();
                bindHeaderForm();
                bindModalFooterActions({ isDraft: isDraft });
                if (typeof window.bindDeliveryAttachments === 'function') {
                    window.bindDeliveryAttachments();
                }
                initUnitsGrid();
            });
    }

    function init() {
        var modalEl = document.getElementById('deliveryCardModal');
        if (!modalEl) {
            return;
        }
        cardModalInstance = bootstrap.Modal.getOrCreateInstance(modalEl);
        modalEl.addEventListener('hidden.bs.modal', function() {
            destroyUnitsGrid();
            currentDeliveryId = null;
        });
        initLineModal();
        initBulkModal();
    }

    window.openDeliveryCardModal = function(id, lineId) {
        currentDeliveryId = parseInt(id, 10);
        currentLineId = lineId ? parseInt(lineId, 10) : 0;
        var modalEl = document.getElementById('deliveryCardModal');
        if (!modalEl) {
            return;
        }
        cardModalInstance = bootstrap.Modal.getOrCreateInstance(modalEl);
        cardModalInstance.show();
        loadCardBody(currentDeliveryId, currentLineId);
    };

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
