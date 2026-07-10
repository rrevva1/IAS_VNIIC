/**
 * Модальное окно закреплённой техники пользователя (раздел «Карточки ТС»).
 */
(function() {
    'use strict';

    var modalEl = document.getElementById('uecUserEquipmentModal');
    var bodyEl = document.getElementById('uecUserEquipmentModalBody');
    var subtitleEl = document.getElementById('uecUserEquipmentModalSubtitle');
    if (!modalEl || !bodyEl) {
        return;
    }

    var modalInstance = null;
    var loadingHtml = bodyEl.innerHTML;

    function getModal() {
        if (!modalInstance && typeof bootstrap !== 'undefined') {
            modalInstance = bootstrap.Modal.getOrCreateInstance(modalEl);
        }
        return modalInstance;
    }

    function buildUrl(userId) {
        var tpl = window.userEquipmentCardsUserEquipmentUrl
            || '/index.php?r=user-equipment-cards/user-equipment&userId=__ID__';
        return tpl.replace('__ID__', String(userId));
    }

    function setLoading() {
        bodyEl.innerHTML = loadingHtml;
    }

    function setSubtitle(userName) {
        if (!subtitleEl) {
            return;
        }
        subtitleEl.textContent = userName
            ? 'Список техники, закреплённой за пользователем'
            : '—';
    }

    function open(userId, userName) {
        var id = parseInt(userId, 10);
        if (!id) {
            return;
        }

        setLoading();
        setSubtitle(userName || '');

        var modal = getModal();
        if (modal) {
            modal.show();
        }

        fetch(buildUrl(id), {
            headers: {
                'X-Requested-With': 'XMLHttpRequest',
                Accept: 'text/html',
            },
            credentials: 'same-origin',
        })
            .then(function(response) {
                if (!response.ok) {
                    var err = new Error('load failed');
                    err.status = response.status;
                    throw err;
                }
                return response.text();
            })
            .then(function(html) {
                bodyEl.innerHTML = html;
            })
            .catch(function(err) {
                var msg = 'Не удалось загрузить список техники.';
                if (err && err.status === 404) {
                    msg = 'Пользователь не найден.';
                } else if (err && err.status === 403) {
                    msg = 'Нет доступа к данным пользователя.';
                }
                bodyEl.innerHTML = '<p class="text-danger mb-0">' + msg + '</p>';
            });
    }

    window.openUserEquipmentModal = open;

    modalEl.addEventListener('hidden.bs.modal', function() {
        setLoading();
        setSubtitle('—');
    });
})();
