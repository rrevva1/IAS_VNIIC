/**
 * Модальное окно выдачи комплекта со склада.
 */
(function() {
    'use strict';

    var modalEl = document.getElementById('issueKitModal');
    if (!modalEl) {
        return;
    }

    var optionsUrl = window.armIssueKitOptionsUrl || '';
    var submitUrl = window.armIssueKitUrl || '';
    var primaryLocationUrl = window.agGridArmUserPrimaryLocationUrl || '';
    var csrf = window.armReassignCsrf || {};
    var modalInstance = null;
    var optionsCache = { hosts: [], monitors: [], ups: [] };
    var prefillHostId = null;
    var suppressHostOptionsReload = false;

    function getModal() {
        if (!modalInstance && typeof bootstrap !== 'undefined') {
            modalInstance = bootstrap.Modal.getOrCreateInstance(modalEl);
        }
        return modalInstance;
    }

    function notify(message, type) {
        type = type || 'success';
        var alertClass = type === 'success' ? 'alert-success' : (type === 'warning' ? 'alert-warning' : 'alert-danger');
        var alertHtml = '<div class="alert ' + alertClass + ' alert-dismissible fade show" role="alert" style="position:fixed;top:20px;right:20px;z-index:10050;min-width:300px;">'
            + escapeHtml(message)
            + '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Закрыть"></button></div>';
        var wrapper = document.createElement('div');
        wrapper.innerHTML = alertHtml;
        var alertEl = wrapper.firstElementChild;
        document.body.appendChild(alertEl);
        setTimeout(function() {
            if (alertEl && typeof bootstrap !== 'undefined') {
                bootstrap.Alert.getOrCreateInstance(alertEl).close();
            }
        }, 5000);
    }

    function escapeHtml(str) {
        var div = document.createElement('div');
        div.textContent = str == null ? '' : String(str);
        return div.innerHTML;
    }

    function getEl(id) {
        return document.getElementById(id);
    }

    function initSelect2(scope) {
        if (window.IasUserSelect) {
            window.IasUserSelect.init(scope || modalEl, { force: true });
        }
    }

    function destroySelect2(selectEl) {
        if (!selectEl || !window.jQuery) {
            return;
        }
        var $el = window.jQuery(selectEl);
        if ($el.hasClass('select2-hidden-accessible')) {
            $el.select2('destroy');
        }
    }

    function setSelectOptions(selectEl, items, placeholder, selectedIds) {
        if (!selectEl) {
            return;
        }
        destroySelect2(selectEl);

        var isMultiple = !!selectEl.multiple;
        var selected = [];
        if (Array.isArray(selectedIds)) {
            selected = selectedIds.map(function(v) { return String(v); }).filter(Boolean);
        } else if (selectedIds != null && selectedIds !== '') {
            selected = [String(selectedIds)];
        }
        var html = '';
        if (!isMultiple) {
            html += '<option value="">' + escapeHtml(placeholder) + '</option>';
        }
        items.forEach(function(item) {
            var id = String(parseInt(item.id, 10));
            var isSelected = selected.indexOf(id) !== -1 ? ' selected' : '';
            html += '<option value="' + id + '"' + isSelected + '>' + escapeHtml(item.label || '') + '</option>';
        });
        selectEl.innerHTML = html;
        return selected;
    }

    function applySelectValue(selectEl, selectedIds) {
        if (!selectEl || !window.jQuery) {
            return;
        }
        var $el = window.jQuery(selectEl);
        if (selectEl.multiple) {
            var values = Array.isArray(selectedIds) ? selectedIds.map(String).filter(Boolean) : [];
            // Без trigger('change') Select2 multi не рисует выбранные chip'ы.
            $el.val(values.length ? values : null).trigger('change');
        } else if (selectedIds != null && selectedIds !== '') {
            $el.val(String(selectedIds)).trigger('change');
        } else {
            $el.val(null).trigger('change');
        }
    }

    function getSelectValue(selectId) {
        var el = getEl(selectId);
        if (!el) {
            return el && el.multiple ? [] : '';
        }
        if (window.jQuery && window.jQuery(el).hasClass('select2-hidden-accessible')) {
            var $el = window.jQuery(el);
            if (el.multiple) {
                // Источник правды для multi — то, что реально показывает Select2.
                // Иначе option[selected] / .val() могут остаться после рассинхрона UI.
                var data = [];
                try {
                    data = $el.select2('data') || [];
                } catch (e) {
                    data = [];
                }
                return data.map(function(item) {
                    if (!item || item.id == null || item.id === '') {
                        return '';
                    }
                    return String(item.id);
                }).filter(Boolean);
            }
            return $el.val() || '';
        }
        if (window.IasUserSelect && typeof window.IasUserSelect.getValue === 'function') {
            var iasVal = window.IasUserSelect.getValue(el);
            if (el.multiple) {
                if (Array.isArray(iasVal)) {
                    return iasVal.filter(Boolean);
                }
                return iasVal ? [iasVal] : [];
            }
            return iasVal || '';
        }
        if (el.multiple) {
            return Array.prototype.slice.call(el.selectedOptions || []).map(function(opt) {
                return opt.value;
            }).filter(Boolean);
        }
        return el.value || '';
    }

    function getSelectValuesAsInts(selectId) {
        var raw = getSelectValue(selectId);
        var list = Array.isArray(raw) ? raw : (raw ? [raw] : []);
        return list.map(function(v) { return parseInt(v, 10); }).filter(function(id) { return id > 0; });
    }

    function getSelectedLabel(selectEl) {
        if (!selectEl || !selectEl.options) {
            return '';
        }
        var value = selectEl.id ? getSelectValue(selectEl.id) : (selectEl.value || '');
        if (value === '' || value == null || Array.isArray(value)) {
            return '';
        }
        var opt = selectEl.querySelector('option[value="' + String(value).replace(/"/g, '\\"') + '"]');
        if (opt) {
            return (opt.textContent || '').trim();
        }
        return '';
    }

    function getSelectedMonitorLabels() {
        var ids = getSelectValuesAsInts('issueKitMonitorIds');
        if (ids.length === 0) {
            return [];
        }
        var el = getEl('issueKitMonitorIds');
        var labels = [];
        for (var i = 0; i < ids.length; i++) {
            var id = ids[i];
            var label = '';
            var monitors = optionsCache.monitors || [];
            for (var j = 0; j < monitors.length; j++) {
                if (parseInt(monitors[j].id, 10) === id) {
                    label = monitors[j].label || '';
                    break;
                }
            }
            if (!label && el) {
                var opt = el.querySelector('option[value="' + id + '"]');
                if (opt) {
                    label = opt.textContent || '';
                }
            }
            if (label) {
                labels.push(label);
            }
        }
        return labels;
    }

    function findHostOption(hostId) {
        var id = parseInt(hostId, 10);
        if (!id) {
            return null;
        }
        var hosts = optionsCache.hosts || [];
        for (var i = 0; i < hosts.length; i++) {
            if (parseInt(hosts[i].id, 10) === id) {
                return hosts[i];
            }
        }
        return null;
    }

    function fillHostNetworkFields(hostId, force) {
        var hostnameEl = getEl('issueKitHostname');
        var ipEl = getEl('issueKitIp');
        if (!hostnameEl || !ipEl) {
            return;
        }
        if (!force && (hostnameEl.dataset.userEdited === '1' || ipEl.dataset.userEdited === '1')) {
            return;
        }
        var host = findHostOption(hostId);
        hostnameEl.value = host && host.hostname ? host.hostname : '';
        ipEl.value = host && host.ip ? host.ip : '';
        delete hostnameEl.dataset.userEdited;
        delete ipEl.dataset.userEdited;
        updatePreview();
    }

    function getSelectedUserName() {
        return getSelectedLabel(getEl('issueKitUserId'));
    }

    function getSelectedLocationName() {
        return getSelectedLabel(getEl('issueKitLocationId'));
    }

    function renderOpChangeRow(change) {
        if (!change) {
            return '';
        }
        var mutedClass = change.muted ? ' arm-op-change--muted' : '';
        var html = '<li class="arm-op-change' + mutedClass + '">';
        if (change.label) {
            html += '<span class="arm-op-change__label">' + escapeHtml(change.label) + '</span>';
        }
        html += '<span class="arm-op-change__body">';
        if (change.from) {
            html += '<span class="arm-op-change__from">' + escapeHtml(change.from) + '</span>';
            html += '<i class="fas fa-arrow-right arm-op-change__arrow" aria-hidden="true"></i>';
        }
        html += '<span class="arm-op-change__to">' + escapeHtml(change.to || '') + '</span>';
        if (change.hint) {
            html += '<span class="arm-op-change__hint">' + escapeHtml(change.hint) + '</span>';
        }
        html += '</span></li>';
        return html;
    }

    function renderOpChangesEmpty(message) {
        return '<li class="arm-op-change arm-op-change--muted">'
            + '<span class="arm-op-change__label">Ожидание</span>'
            + '<span class="arm-op-change__body"><span class="arm-op-change__to">' + escapeHtml(message) + '</span></span>'
            + '</li>';
    }

    function renderCompositionCard(chip, title, meta, isHost) {
        var cardClass = 'arm-op-card' + (isHost ? ' arm-op-card--host' : ' arm-op-card--child');
        return '<article class="' + cardClass + '">'
            + '<span class="arm-op-card__chip">' + escapeHtml(chip) + '</span>'
            + '<div class="arm-op-card__body">'
            + '<div class="arm-op-card__title">' + escapeHtml(title) + '</div>'
            + (meta ? '<div class="arm-op-card__meta">' + escapeHtml(meta) + '</div>' : '')
            + '</div></article>';
    }

    function splitOptionLabel(label) {
        var parts = String(label || '').split(' · ').map(function(p) { return p.trim(); }).filter(Boolean);
        return {
            name: parts[0] || label || '—',
            meta: parts.slice(1).join(' · ')
        };
    }

    function updateCompositionPreview() {
        var listEl = getEl('issueKitCompositionList');
        var countEl = getEl('issueKitCompositionCount');
        if (!listEl) {
            return;
        }

        var hostLabel = getSelectedLabel(getEl('issueKitHostId'));
        var monitorLabels = getSelectedMonitorLabels();
        var upsLabel = getSelectedLabel(getEl('issueKitUpsId'));
        var hostname = ((getEl('issueKitHostname') || {}).value || '').trim();
        var ipAddress = ((getEl('issueKitIp') || {}).value || '').trim();
        var cards = [];

        if (hostLabel) {
            var hostParts = splitOptionLabel(hostLabel);
            var hostMeta = hostParts.meta;
            if (hostname) {
                hostMeta = (hostMeta ? hostMeta + ' · ' : '') + 'имя: ' + hostname;
            }
            if (ipAddress) {
                hostMeta = (hostMeta ? hostMeta + ' · ' : '') + 'IP: ' + ipAddress;
            }
            cards.push(renderCompositionCard('СБ', hostParts.name, hostMeta, true));
        }

        monitorLabels.forEach(function(label) {
            var parts = splitOptionLabel(label);
            cards.push(renderCompositionCard('Мон', parts.name, parts.meta, false));
        });

        if (upsLabel) {
            var upsParts = splitOptionLabel(upsLabel);
            cards.push(renderCompositionCard('ИБП', upsParts.name, upsParts.meta, false));
        }

        if (countEl) {
            countEl.textContent = String(cards.length);
        }

        if (cards.length === 0) {
            listEl.innerHTML = '<div class="arm-op-aside__empty">'
                + '<i class="fas fa-box" aria-hidden="true"></i>'
                + '<span class="arm-op-aside__empty-text">Выберите технику справа — здесь появится состав комплекта</span>'
                + '</div>';
            return;
        }

        listEl.innerHTML = '<div class="arm-op-card-list">' + cards.join('') + '</div>';
    }

    function updatePreview() {
        var previewDiv = getEl('issueKitPreview');
        var previewList = getEl('issueKitPreviewList');
        updateCompositionPreview();
        if (!previewDiv || !previewList) {
            return;
        }

        var userName = getSelectedUserName();
        var locationName = getSelectedLocationName();
        var hostLabel = getSelectedLabel(getEl('issueKitHostId'));
        var monitorLabels = getSelectedMonitorLabels();
        var upsLabel = getSelectedLabel(getEl('issueKitUpsId'));
        var hostname = ((getEl('issueKitHostname') || {}).value || '').trim();
        var ipAddress = ((getEl('issueKitIp') || {}).value || '').trim();

        var changes = [];
        if (userName) {
            changes.push({ label: 'Ответственный', to: userName });
        }
        if (locationName) {
            changes.push({ label: 'Помещение', to: locationName });
        }
        if (hostLabel) {
            changes.push({ label: 'Системный блок', to: splitOptionLabel(hostLabel).name });
        }
        if (hostname !== '') {
            changes.push({ label: 'Имя компьютера', to: hostname });
        }
        if (ipAddress !== '') {
            changes.push({ label: 'IP-адрес', to: ipAddress });
        }
        if (monitorLabels.length === 1) {
            changes.push({
                label: 'Монитор',
                to: splitOptionLabel(monitorLabels[0]).name,
                hint: 'привязка к СБ'
            });
        } else if (monitorLabels.length > 1) {
            changes.push({
                label: 'Мониторы',
                to: monitorLabels.length + ' шт.',
                hint: 'привязка к СБ'
            });
        }
        if (upsLabel) {
            changes.push({
                label: 'ИБП',
                to: splitOptionLabel(upsLabel).name,
                hint: 'привязка к СБ'
            });
        }

        previewDiv.classList.remove('arm-reassign-preview--hidden');
        if (changes.length === 0) {
            previewList.innerHTML = renderOpChangesEmpty('Укажите получателя и состав комплекта');
            return;
        }

        previewList.innerHTML = changes.map(renderOpChangeRow).join('');
    }

    function toggleEmptyState() {
        var emptyEl = getEl('issueKitOptionsEmpty');
        var submitBtn = getEl('issueKitSubmit');
        var hasHosts = optionsCache.hosts && optionsCache.hosts.length > 0;
        if (emptyEl) {
            emptyEl.style.display = hasHosts ? 'none' : 'block';
        }
        if (submitBtn) {
            submitBtn.disabled = !hasHosts;
        }
    }

    function loadOptions(hostId) {
        if (!optionsUrl) {
            return Promise.resolve();
        }

        var url = new URL(optionsUrl, window.location.origin);
        if (hostId) {
            url.searchParams.set('host_id', String(hostId));
        }

        return fetch(url.toString(), {
            headers: { Accept: 'application/json', 'X-Requested-With': 'XMLHttpRequest' },
            credentials: 'same-origin',
        })
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (!data || !data.success) {
                    throw new Error((data && data.message) || 'Не удалось загрузить списки техники');
                }
                optionsCache = {
                    hosts: data.hosts || [],
                    monitors: data.monitors || [],
                    ups: data.ups || [],
                };

                var hostSelect = getEl('issueKitHostId');
                var monitorSelect = getEl('issueKitMonitorIds');
                var upsSelect = getEl('issueKitUpsId');
                var currentHost = getSelectValue('issueKitHostId');
                var currentMonitors = getSelectValuesAsInts('issueKitMonitorIds').map(String);
                var currentUps = getSelectValue('issueKitUpsId');
                var selectedHost = prefillHostId || currentHost;

                // Сохраняем только те id мониторов, которые ещё есть в новом списке
                var availableMonitorIds = {};
                (optionsCache.monitors || []).forEach(function(item) {
                    availableMonitorIds[String(item.id)] = true;
                });
                currentMonitors = currentMonitors.filter(function(id) {
                    return availableMonitorIds[id];
                });

                setSelectOptions(hostSelect, optionsCache.hosts, '— выберите системный блок —', selectedHost);
                setSelectOptions(monitorSelect, optionsCache.monitors, '', currentMonitors);
                setSelectOptions(upsSelect, optionsCache.ups, '— не выдавать —', currentUps);

                prefillHostId = null;
                suppressHostOptionsReload = true;
                try {
                    initSelect2(modalEl);
                    applySelectValue(hostSelect, selectedHost);
                    applySelectValue(monitorSelect, currentMonitors);
                    applySelectValue(upsSelect, currentUps);
                } finally {
                    suppressHostOptionsReload = false;
                }
                toggleEmptyState();
                fillHostNetworkFields(getSelectValue('issueKitHostId'), true);
                updatePreview();
            })
            .catch(function(err) {
                var emptyEl = getEl('issueKitOptionsEmpty');
                if (emptyEl) {
                    emptyEl.textContent = err.message || 'Не удалось загрузить списки техники со склада.';
                    emptyEl.style.display = 'block';
                }
                notify(err.message || 'Не удалось загрузить списки техники', 'danger');
            });
    }

    function applyPrimaryLocation(userId) {
        if (!primaryLocationUrl || !userId) {
            return Promise.resolve();
        }
        var url = primaryLocationUrl + (primaryLocationUrl.indexOf('?') >= 0 ? '&' : '?') + 'user_id=' + encodeURIComponent(userId);
        return fetch(url, {
            headers: { Accept: 'application/json', 'X-Requested-With': 'XMLHttpRequest' },
            credentials: 'same-origin',
        })
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (!data || !data.success || !data.location_id) {
                    return;
                }
                var locationSelect = getEl('issueKitLocationId');
                if (!locationSelect) {
                    return;
                }
                var locId = String(data.location_id);
                if (window.jQuery && window.jQuery(locationSelect).find('option[value="' + locId + '"]').length) {
                    window.jQuery(locationSelect).val(locId).trigger('change');
                    updatePreview();
                } else if (locationSelect.querySelector('option[value="' + locId + '"]')) {
                    locationSelect.value = locId;
                    updatePreview();
                }
            })
            .catch(function() {});
    }

    function setSubmitting(isSubmitting) {
        var btn = getEl('issueKitSubmit');
        if (!btn) {
            return;
        }
        var text = btn.querySelector('.issue-kit-submit-text');
        var spinner = btn.querySelector('.issue-kit-submit-spinner');
        btn.disabled = isSubmitting;
        if (text) {
            text.style.display = isSubmitting ? 'none' : '';
        }
        if (spinner) {
            spinner.style.display = isSubmitting ? '' : 'none';
        }
    }

    function submitIssueKit() {
        var hostId = parseInt(getSelectValue('issueKitHostId'), 10);
        var userId = parseInt(getSelectValue('issueKitUserId'), 10);
        var locationId = parseInt(getSelectValue('issueKitLocationId'), 10);
        var monitorIds = getSelectValuesAsInts('issueKitMonitorIds');
        var upsId = parseInt(getSelectValue('issueKitUpsId'), 10);
        var hostname = (getEl('issueKitHostname') || {}).value || '';
        var ipAddress = (getEl('issueKitIp') || {}).value || '';

        if (!userId) {
            notify('Укажите получателя комплекта.', 'warning');
            return;
        }
        if (!locationId) {
            notify('Укажите помещение выдачи.', 'warning');
            return;
        }
        if (!hostId) {
            notify('Укажите системный блок.', 'warning');
            return;
        }

        var fd = new FormData();
        if (csrf.param && csrf.token) {
            fd.append(csrf.param, csrf.token);
        }
        fd.append('host_id', String(hostId));
        fd.append('responsible_user_id', String(userId));
        fd.append('location_id', String(locationId));
        monitorIds.forEach(function(id) {
            fd.append('monitor_ids[]', String(id));
        });
        if (upsId > 0) {
            fd.append('ups_id', String(upsId));
        }
        if (hostname.trim() !== '') {
            fd.append('hostname', hostname.trim());
        }
        if (ipAddress.trim() !== '') {
            fd.append('ip', ipAddress.trim());
        }

        setSubmitting(true);
        fetch(submitUrl, {
            method: 'POST',
            body: fd,
            credentials: 'same-origin',
            headers: { 'X-Requested-With': 'XMLHttpRequest', Accept: 'application/json' },
        })
            .then(function(r) {
                return r.text().then(function(text) {
                    var data = null;
                    try {
                        data = text ? JSON.parse(text) : null;
                    } catch (e) {
                        throw new Error(r.ok
                            ? 'Некорректный ответ сервера при выдаче комплекта.'
                            : 'Ошибка сервера (' + r.status + '). Проверьте авторизацию и повторите попытку.');
                    }
                    if (!r.ok) {
                        throw new Error((data && data.message) || ('Ошибка сервера (' + r.status + ').'));
                    }
                    return data;
                });
            })
            .then(function(data) {
                if (!data || !data.success) {
                    throw new Error((data && data.message) || 'Не удалось выдать комплект');
                }
                notify(data.message || 'Комплект выдан.', 'success');
                getModal().hide();
                if (typeof window.refreshArmGrid === 'function') {
                    window.refreshArmGrid();
                }
            })
            .catch(function(err) {
                notify(err.message || 'Ошибка выдачи комплекта', 'danger');
            })
            .finally(function() {
                setSubmitting(false);
            });
    }

    function resetForm() {
        ['issueKitUserId', 'issueKitLocationId', 'issueKitMonitorIds', 'issueKitUpsId'].forEach(function(id) {
            var el = getEl(id);
            if (!el) {
                return;
            }
            if (window.jQuery && window.jQuery(el).hasClass('select2-hidden-accessible')) {
                window.jQuery(el).val(null).trigger('change');
            } else {
                el.value = '';
            }
        });
        var hostnameEl = getEl('issueKitHostname');
        var ipEl = getEl('issueKitIp');
        if (hostnameEl) {
            hostnameEl.value = '';
            delete hostnameEl.dataset.userEdited;
        }
        if (ipEl) {
            ipEl.value = '';
            delete ipEl.dataset.userEdited;
        }
        updatePreview();
    }

    function openIssueKitModal(hostId) {
        prefillHostId = hostId ? parseInt(hostId, 10) : null;
        resetForm();
        loadOptions(prefillHostId).then(function() {
            getModal().show();
        });
    }

    window.openIssueKitModal = openIssueKitModal;

    modalEl.addEventListener('shown.bs.modal', function() {
        var hostId = getSelectValue('issueKitHostId');
        var monitorIds = getSelectValuesAsInts('issueKitMonitorIds').map(String);
        var upsId = getSelectValue('issueKitUpsId');
        var userId = getSelectValue('issueKitUserId');
        var locationId = getSelectValue('issueKitLocationId');

        suppressHostOptionsReload = true;
        try {
            initSelect2(modalEl);
            applySelectValue(getEl('issueKitUserId'), userId);
            applySelectValue(getEl('issueKitLocationId'), locationId);
            applySelectValue(getEl('issueKitHostId'), hostId);
            applySelectValue(getEl('issueKitMonitorIds'), monitorIds);
            applySelectValue(getEl('issueKitUpsId'), upsId);
        } finally {
            suppressHostOptionsReload = false;
        }
        updatePreview();
    });

    modalEl.addEventListener('change', function(e) {
        var target = e.target;
        if (!target || !target.id) {
            return;
        }
        if (target.id === 'issueKitHostId') {
            fillHostNetworkFields(getSelectValue('issueKitHostId'), true);
            if (!suppressHostOptionsReload) {
                loadOptions(parseInt(getSelectValue('issueKitHostId'), 10) || null);
            }
            updatePreview();
            return;
        }
        if (target.id === 'issueKitHostname' || target.id === 'issueKitIp') {
            target.dataset.userEdited = '1';
        }
        if (target.id === 'issueKitUserId') {
            var userId = parseInt(getSelectValue('issueKitUserId'), 10);
            if (userId > 0) {
                applyPrimaryLocation(userId);
            }
        }
        updatePreview();
    });

    modalEl.addEventListener('input', function(e) {
        var target = e.target;
        if (!target || (target.id !== 'issueKitHostname' && target.id !== 'issueKitIp')) {
            return;
        }
        target.dataset.userEdited = '1';
        updatePreview();
    });

    var submitBtn = getEl('issueKitSubmit');
    if (submitBtn) {
        submitBtn.addEventListener('click', submitIssueKit);
    }

    var openBtn = document.getElementById('btnIssueKit');
    if (openBtn) {
        openBtn.addEventListener('click', function() {
            var hostId = null;
            if (typeof window.getArmSelectedHostId === 'function') {
                hostId = window.getArmSelectedHostId();
            }
            openIssueKitModal(hostId);
        });
    }
})();
