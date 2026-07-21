/**
 * Модальные формы создания/редактирования записей справочника (admin).
 */
(function() {
    'use strict';

    function getModal() {
        return document.getElementById('phoneDirectoryFormModal');
    }

    function getModalBody() {
        return document.getElementById('phoneDirectoryFormModalBody');
    }

    function getContainer() {
        return document.getElementById('agGridPhoneDirectoryContainer');
    }

    function showModal() {
        var modalEl = getModal();
        if (!modalEl || typeof bootstrap === 'undefined') {
            return;
        }
        var modal = bootstrap.Modal.getOrCreateInstance(modalEl);
        modal.show();
    }

    function hideModal() {
        var modalEl = getModal();
        if (!modalEl || typeof bootstrap === 'undefined') {
            return;
        }
        var modal = bootstrap.Modal.getOrCreateInstance(modalEl);
        modal.hide();
    }

    function loadForm(url, title) {
        var body = getModalBody();
        var label = document.getElementById('phoneDirectoryFormModalLabel');
        if (!body) {
            return;
        }
        if (label && title) {
            label.textContent = title;
        }
        body.innerHTML = '<p class="text-muted mb-0">Загрузка…</p>';
        showModal();

        fetch(url, {
            headers: { 'X-Requested-With': 'XMLHttpRequest' },
        })
            .then(function(r) { return r.ok ? r.text() : Promise.reject(new Error('HTTP ' + r.status)); })
            .then(function(html) {
                body.innerHTML = html;
                bindForm(body);
                if (typeof window.initInternalPhoneSelects === 'function') {
                    window.initInternalPhoneSelects(body);
                }
            })
            .catch(function() {
                body.innerHTML = '<p class="text-danger mb-0">Не удалось загрузить форму.</p>';
            });
    }

    function bindForm(body) {
        var form = body.querySelector('#phone-directory-form');
        if (!form) {
            return;
        }

        form.addEventListener('submit', function(e) {
            e.preventDefault();
            var submitBtn = form.querySelector('#phone-directory-form-submit');
            if (submitBtn) {
                submitBtn.disabled = true;
            }

            var formData = new FormData(form);
            fetch(form.getAttribute('action'), {
                method: 'POST',
                headers: { 'X-Requested-With': 'XMLHttpRequest' },
                body: formData,
            })
                .then(function(r) { return r.json(); })
                .then(function(result) {
                    if (result && result.success) {
                        hideModal();
                        if (typeof window.refreshPhoneDirectoryGrid === 'function') {
                            window.refreshPhoneDirectoryGrid();
                        }
                        return;
                    }
                    alert((result && result.message) || 'Не удалось сохранить');
                })
                .catch(function() {
                    alert('Ошибка сохранения');
                })
                .finally(function() {
                    if (submitBtn) {
                        submitBtn.disabled = false;
                    }
                });
        });
    }

    window.openPhoneDirectoryCreateModal = function() {
        var container = getContainer();
        var url = (container && container.dataset.createModalUrl) || '/index.php?r=phone-directory/create-modal';
        loadForm(url, 'Новая запись справочника');
    };

    window.openPhoneDirectoryEditModal = function(id) {
        var container = getContainer();
        var template = (container && container.dataset.updateModalUrlTemplate)
            || '/index.php?r=phone-directory/update-modal&id=__ID__';
        var url = template.replace('__ID__', encodeURIComponent(id));
        loadForm(url, 'Редактирование записи');
    };
})();
