/**
 * Модальное окно просмотра карточки техники.
 */
(function() {
    'use strict';

    var modalEl = document.getElementById('armViewModal');
    var bodyEl = document.getElementById('armViewModalBody');
    var headerEl = document.getElementById('armViewModalHeader');
    var titleEl = document.getElementById('armViewModalLabel');
    if (!modalEl || !bodyEl) {
        return;
    }

    var modalInstance = null;
    var currentEquipmentId = null;
    var loadingHtml = bodyEl.innerHTML;
    var defaultHeaderHtml = headerEl ? headerEl.innerHTML : '';

    function getViewModalUrl(id) {
        var container = document.getElementById('agGridArmContainer');
        var tpl = (container && container.dataset.viewModalUrlTemplate)
            || window.agGridArmViewModalUrlTemplate
            || '/index.php?r=arm/view-modal&id=__ID__';
        return tpl.replace('__ID__', String(id));
    }

    function getModal() {
        if (!modalInstance && typeof bootstrap !== 'undefined') {
            modalInstance = bootstrap.Modal.getOrCreateInstance(modalEl);
        }
        return modalInstance;
    }

    function setLoading() {
        bodyEl.innerHTML = loadingHtml;
        if (headerEl) {
            headerEl.innerHTML = defaultHeaderHtml;
        }
    }

    function setTitle(text) {
        if (titleEl) {
            titleEl.textContent = text || 'Карточка техники';
        }
    }

    function mountHeader(root) {
        if (!headerEl || !root) {
            return;
        }
        var slot = root.querySelector('#armViewHeaderSlot');
        if (!slot) {
            return;
        }
        headerEl.innerHTML = '';
        headerEl.appendChild(slot);
        slot.classList.add('arm-view__header-slot--in-modal');
        var titleNode = slot.querySelector('.arm-view__title');
        if (titleNode) {
            setTitle(titleNode.textContent.trim());
        }
    }

    function loadEquipment(equipmentId) {
        currentEquipmentId = equipmentId;
        setLoading();
        setTitle('Карточка #' + equipmentId);

        return fetch(getViewModalUrl(equipmentId), {
            headers: { 'X-Requested-With': 'XMLHttpRequest', Accept: 'text/html' },
            credentials: 'same-origin',
        })
            .then(function(r) {
                if (!r.ok) {
                    return r.text().then(function() {
                        var err = new Error('load failed');
                        err.status = r.status;
                        throw err;
                    });
                }
                return r.text();
            })
            .then(function(html) {
                if (!html || html.indexOf('arm-view') === -1) {
                    throw new Error('invalid response');
                }
                bodyEl.innerHTML = html;
                mountHeader(bodyEl.querySelector('.arm-view'));
            })
            .catch(function(err) {
                var msg = 'Не удалось загрузить карточку техники.';
                if (err && err.status === 403) {
                    msg = 'Нет доступа к этой записи.';
                } else if (err && err.status === 404) {
                    msg = 'Техника не найдена.';
                }
                bodyEl.innerHTML = '<p class="text-danger mb-0">' + msg + '</p>';
            });
    }

    function open(equipmentId) {
        var id = parseInt(equipmentId, 10);
        if (!id) {
            return;
        }
        var m = getModal();
        if (m) {
            m.show();
        }
        loadEquipment(id);
    }

    window.openArmViewModal = open;

    window.ArmView = {
        open: open,
        reload: function() {
            if (currentEquipmentId) {
                return loadEquipment(currentEquipmentId);
            }
            return Promise.resolve();
        },
        isOpen: function() {
            return modalEl.classList.contains('show');
        },
        getEquipmentId: function() {
            return currentEquipmentId;
        },
    };

    document.addEventListener('click', function(e) {
        var link = e.target.closest('[data-arm-view]');
        if (link) {
            e.preventDefault();
            open(link.getAttribute('data-arm-view'));
        }
    });

    modalEl.addEventListener('hidden.bs.modal', function() {
        currentEquipmentId = null;
        setTitle('Карточка техники');
        setLoading();
        var params = new URLSearchParams(window.location.search);
        if (params.has('equipment')) {
            params.delete('equipment');
            var qs = params.toString();
            var next = window.location.pathname + (qs ? '?' + qs : '') + window.location.hash;
            if (window.history && window.history.replaceState) {
                window.history.replaceState({}, '', next);
            }
        }
    });

    var params = new URLSearchParams(window.location.search);
    var equipmentParam = params.get('equipment');
    if (equipmentParam) {
        open(equipmentParam);
        params.delete('equipment');
        var qs = params.toString();
        var next = window.location.pathname + (qs ? '?' + qs : '') + window.location.hash;
        if (window.history && window.history.replaceState) {
            window.history.replaceState({}, '', next);
        }
    }
})();
