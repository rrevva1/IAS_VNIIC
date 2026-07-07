/**
 * Оболочка страницы «Поставки» — поиск, кнопка «Добавить».
 */
(function() {
    'use strict';

    function getGridContainer() {
        return document.getElementById('agGridDeliveryContainer');
    }

    function getCreateDraftUrl() {
        var c = getGridContainer();
        return (c && c.dataset.createDraftUrl) || '/index.php?r=delivery/create-draft';
    }

    function csrfToken() {
        var meta = document.querySelector('meta[name="csrf-token"]');
        return meta ? meta.content : '';
    }

    function csrfParam() {
        var meta = document.querySelector('meta[name="csrf-param"]');
        return meta ? meta.getAttribute('content') : '_csrf';
    }

    function showToast(type, message) {
        if (!message) {
            return;
        }
        var alertClass = type === 'success' ? 'alert-success' : 'alert-danger';
        var el = document.createElement('div');
        el.className = 'alert ' + alertClass + ' alert-dismissible fade show';
        el.style.cssText = 'position:fixed;top:20px;right:20px;z-index:10060;min-width:280px;max-width:420px;';
        el.setAttribute('role', 'alert');
        el.innerHTML = message
            + '<button type="button" class="btn-close" data-bs-dismiss="alert"></button>';
        document.body.appendChild(el);
        setTimeout(function() {
            if (el.parentNode) {
                bootstrap.Alert.getOrCreateInstance(el).close();
            }
        }, 5000);
    }

    function getSearchText() {
        var input = document.getElementById('deliveryQuickFilter');
        return input ? input.value.trim() : '';
    }

    function updateSearchClearButton() {
        var btn = document.getElementById('deliveryQuickFilterClear');
        if (btn) {
            btn.hidden = !getSearchText();
        }
    }

    window.deliveryUpdatePageChrome = function() {
        updateSearchClearButton();
    };

    function createDraftAndOpenCard(btn) {
        if (btn) {
            btn.disabled = true;
        }
        var data = new FormData();
        var token = csrfToken();
        var param = csrfParam();
        if (token && param) {
            data.append(param, token);
        }
        fetch(getCreateDraftUrl(), {
            method: 'POST',
            body: data,
            credentials: 'same-origin',
            headers: { 'X-Requested-With': 'XMLHttpRequest' },
        })
            .then(function(r) { return r.json(); })
            .then(function(res) {
                if (res.success && res.delivery_id) {
                    if (typeof window.refreshDeliveryGrid === 'function') {
                        window.refreshDeliveryGrid();
                    }
                    if (typeof window.openDeliveryCardModal === 'function') {
                        window.openDeliveryCardModal(res.delivery_id);
                    }
                } else {
                    showToast('error', res.message || 'Не удалось создать поставку');
                }
            })
            .catch(function() {
                showToast('error', 'Ошибка сети');
            })
            .finally(function() {
                if (btn) {
                    btn.disabled = false;
                }
            });
    }

    function init() {
        var clearBtn = document.getElementById('deliveryQuickFilterClear');
        if (clearBtn) {
            clearBtn.addEventListener('click', function() {
                var input = document.getElementById('deliveryQuickFilter');
                if (input) {
                    input.value = '';
                    input.dispatchEvent(new Event('input', { bubbles: true }));
                }
                updateSearchClearButton();
            });
        }

        document.querySelectorAll('[data-delivery-create-open]').forEach(function(btn) {
            btn.addEventListener('click', function() {
                createDraftAndOpenCard(btn);
            });
        });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
