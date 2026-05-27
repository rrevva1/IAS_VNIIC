(function() {
    'use strict';

    if (window.__workTasksCreateInit) {
        return;
    }
    window.__workTasksCreateInit = true;

    var modalEl = document.getElementById('workTaskCreateModal');
    if (!modalEl) {
        return;
    }

    var form = modalEl.querySelector('#workTaskCreateForm');
    if (!form) {
        return;
    }

    var errorBox = document.getElementById('workTaskCreateFormError');
    var submitBtn = modalEl.querySelector('#workTaskCreateSubmit');
    var modalInstance = null;
    var isSubmitting = false;

    function getModal() {
        if (!modalInstance && typeof bootstrap !== 'undefined') {
            modalInstance = bootstrap.Modal.getOrCreateInstance(modalEl);
        }
        return modalInstance;
    }

    function showError(message) {
        if (!errorBox) {
            alert(message);
            return;
        }
        errorBox.textContent = message;
        errorBox.classList.remove('d-none');
    }

    function clearError() {
        if (errorBox) {
            errorBox.textContent = '';
            errorBox.classList.add('d-none');
        }
        form.querySelectorAll('.is-invalid').forEach(function(el) {
            el.classList.remove('is-invalid');
        });
        form.querySelectorAll('.invalid-feedback').forEach(function(el) {
            el.remove();
        });
    }

    function postForm(url, formElement) {
        var body = new FormData(formElement);
        return fetch(url, {
            method: 'POST',
            body: body,
            headers: { 'X-Requested-With': 'XMLHttpRequest' },
        }).then(function(r) {
            return r.json();
        });
    }

    function syncCreateModalTitle() {
        var titleInput = form.querySelector('[name="WorkTask[title]"]');
        var labelEl = document.getElementById('workTaskCreateModalLabel');
        if (!labelEl || !titleInput) {
            return;
        }
        var title = (titleInput.value || '').trim();
        labelEl.innerHTML = title
            ? '<i class="fas fa-plus" aria-hidden="true"></i> ' + escapeHtml(title)
            : '<i class="fas fa-plus" aria-hidden="true"></i> Новая задача';
    }

    function escapeHtml(text) {
        var div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    function initFileDrop() {
        if (typeof window.tasksCreateFormInit === 'function') {
            window.tasksCreateFormInit(form);
        }
    }

    function openModal() {
        clearError();
        initFileDrop();
        syncCreateModalTitle();
        var m = getModal();
        if (m) {
            m.show();
        }
    }

    document.querySelectorAll('[data-work-task-create-open]').forEach(function(btn) {
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            openModal();
        });
    });

    modalEl.addEventListener('shown.bs.modal', function() {
        initFileDrop();
        var titleInput = form.querySelector('[name="WorkTask[title]"]');
        if (titleInput) {
            titleInput.focus();
        }
    });

    modalEl.addEventListener('input', function(e) {
        if (e.target && e.target.getAttribute('name') === 'WorkTask[title]') {
            syncCreateModalTitle();
        }
    });

    modalEl.addEventListener('hidden.bs.modal', function() {
        clearError();
        form.reset();
        initFileDrop();
        isSubmitting = false;
        if (submitBtn) {
            submitBtn.disabled = false;
        }
    });

    form.addEventListener('submit', function(e) {
        e.preventDefault();
        e.stopImmediatePropagation();
        if (isSubmitting) {
            return;
        }
        clearError();
        isSubmitting = true;
        if (submitBtn) {
            submitBtn.disabled = true;
        }

        postForm(form.getAttribute('action') || '', form)
            .then(function(res) {
                if (res.success) {
                    var m = getModal();
                    if (m) {
                        m.hide();
                    }
                    var params = new URLSearchParams(window.location.search);
                    params.delete('create');
                    params.delete('task');
                    var qs = params.toString();
                    window.location.href = window.location.pathname + (qs ? '?' + qs : '');
                    return;
                }
                isSubmitting = false;
                var msg = res.message || 'Не удалось создать задачу';
                if (res.errors) {
                    var parts = [];
                    Object.keys(res.errors).forEach(function(attr) {
                        res.errors[attr].forEach(function(err) {
                            parts.push(err);
                        });
                    });
                    if (parts.length) {
                        msg = parts.join(' ');
                    }
                }
                showError(msg);
            })
            .catch(function() {
                isSubmitting = false;
                showError('Ошибка сети. Повторите попытку.');
            })
            .finally(function() {
                if (submitBtn && !isSubmitting) {
                    submitBtn.disabled = false;
                }
            });
    }, true);

    var params = new URLSearchParams(window.location.search);
    if (params.get('create') === '1') {
        openModal();
        params.delete('create');
        var qs = params.toString();
        var next = window.location.pathname + (qs ? '?' + qs : '') + window.location.hash;
        if (window.history && window.history.replaceState) {
            window.history.replaceState({}, '', next);
        }
    }
})();
