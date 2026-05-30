/**
 * Модальное окно просмотра карточки пользователя (раздел «Пользователи»).
 */
(function() {
    'use strict';

    var modalEl = null;
    var bodyEl = null;
    var headerEl = null;
    var titleEl = null;
    var currentUserId = null;
    var loadingHtml = '';

    function getViewModalUrl(id) {
        var container = document.getElementById('agGridUsersContainer');
        var tpl = (container && container.dataset.viewModalUrlTemplate)
            || window.agGridUsersViewModalUrlTemplate
            || '/index.php?r=users/view-modal&id=__ID__';
        return tpl.replace('__ID__', String(id));
    }

    function getModal() {
        var Modal = window.bootstrap && window.bootstrap.Modal;
        if (!modalEl || !Modal) {
            return null;
        }
        return Modal.getOrCreateInstance(modalEl);
    }

    function setLoading() {
        if (!bodyEl) {
            return;
        }
        bodyEl.innerHTML = loadingHtml;
        if (headerEl) {
            var hiddenTitle = headerEl.querySelector('#usersViewModalLabel');
            headerEl.innerHTML = '';
            if (hiddenTitle) {
                headerEl.appendChild(hiddenTitle);
            } else {
                headerEl.innerHTML = '<h5 class="modal-title mb-0 visually-hidden" id="usersViewModalLabel">Карточка пользователя</h5>';
            }
            titleEl = document.getElementById('usersViewModalLabel');
        }
    }

    function setTitle(text) {
        var nameNode = headerEl && headerEl.querySelector('.profile-hero__name');
        if (nameNode) {
            nameNode.textContent = text || 'Пользователь';
            return;
        }
        if (titleEl) {
            titleEl.textContent = text || 'Карточка пользователя';
        }
    }

    function mountHeader(root) {
        if (!headerEl || !root) {
            return;
        }
        var slot = root.querySelector('#usersViewHeaderSlot');
        if (!slot) {
            return;
        }
        var hiddenTitle = headerEl.querySelector('#usersViewModalLabel');
        headerEl.innerHTML = '';
        if (hiddenTitle) {
            headerEl.appendChild(hiddenTitle);
        }
        headerEl.appendChild(slot);
        slot.classList.add('users-view__header-slot--in-modal');
        var nameNode = slot.querySelector('.profile-hero__name');
        if (nameNode) {
            setTitle(nameNode.textContent.trim());
        }
    }

    function loadUser(userId) {
        currentUserId = userId;
        setLoading();
        setTitle('Пользователь #' + userId);

        return fetch(getViewModalUrl(userId), {
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
                if (!html || html.indexOf('profile-view') === -1) {
                    throw new Error('invalid response');
                }
                bodyEl.innerHTML = html;
                mountHeader(bodyEl.querySelector('.profile-view'));
            })
            .catch(function(err) {
                var msg = 'Не удалось загрузить карточку пользователя.';
                if (err && err.status === 403) {
                    msg = 'Нет доступа к этой записи.';
                } else if (err && err.status === 404) {
                    msg = 'Пользователь не найден.';
                }
                bodyEl.innerHTML = '<p class="text-danger mb-0">' + msg + '</p>';
            });
    }

    function ensureViewModalInBody() {
        if (modalEl && modalEl.parentNode !== document.body) {
            document.body.appendChild(modalEl);
        }
    }

    function open(userId) {
        var id = parseInt(userId, 10);
        if (!id || !modalEl) {
            return;
        }
        ensureViewModalInBody();
        var m = getModal();
        if (m) {
            m.show();
        }
        loadUser(id);
    }

    function clearStuckModalBackdrop() {
        if (document.querySelector('.modal.show')) {
            return;
        }
        document.querySelectorAll('.modal-backdrop').forEach(function(el) {
            el.remove();
        });
        document.body.classList.remove('modal-open');
        document.body.style.removeProperty('overflow');
        document.body.style.removeProperty('padding-right');
    }

    function init() {
        modalEl = document.getElementById('usersViewModal');
        bodyEl = document.getElementById('usersViewModalBody');
        headerEl = document.getElementById('usersViewModalHeader');
        titleEl = document.getElementById('usersViewModalLabel');
        if (!modalEl || !bodyEl) {
            return;
        }

        ensureViewModalInBody();
        clearStuckModalBackdrop();
        loadingHtml = bodyEl.innerHTML;

        window.openUsersViewModal = open;

        window.UsersView = {
            open: open,
            reload: function() {
                if (currentUserId) {
                    return loadUser(currentUserId);
                }
                return Promise.resolve();
            },
            isOpen: function() {
                return modalEl.classList.contains('show');
            },
            getUserId: function() {
                return currentUserId;
            },
        };

        document.addEventListener('click', function(e) {
            var trigger = e.target.closest('[data-users-view]');
            if (!trigger) {
                return;
            }
            e.preventDefault();
            open(trigger.getAttribute('data-users-view'));
        });

        modalEl.addEventListener('hidden.bs.modal', function() {
            currentUserId = null;
            setLoading();
            var params = new URLSearchParams(window.location.search);
            if (params.has('user')) {
                params.delete('user');
                var qs = params.toString();
                var next = window.location.pathname + (qs ? '?' + qs : '') + window.location.hash;
                if (window.history && window.history.replaceState) {
                    window.history.replaceState({}, '', next);
                }
            }
        });

        var params = new URLSearchParams(window.location.search);
        var userParam = params.get('user');
        if (userParam) {
            open(userParam);
            params.delete('user');
            var qs = params.toString();
            var next = window.location.pathname + (qs ? '?' + qs : '') + window.location.hash;
            if (window.history && window.history.replaceState) {
                window.history.replaceState({}, '', next);
            }
        }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
