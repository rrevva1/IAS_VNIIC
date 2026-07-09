/**
 * Модальное окно добавления и редактирования лицензий.
 */
(function() {
    'use strict';

    var currentMode = 'create';
    var currentSoftwareId = null;
    var currentLicenseId = null;
    var loadRequestId = 0;
    var loadingHtml = (
        '<div class="arm-view-modal__loading text-center text-muted py-5">' +
        '<i class="fas fa-circle-notch fa-spin fa-2x" aria-hidden="true"></i>' +
        '<p class="mt-3 mb-0">Загрузка формы…</p></div>'
    );

    function getGridContainer() {
        return document.getElementById('agGridSoftwareContainer');
    }

    function getModalEl() {
        return document.getElementById('softwareLicenseModal');
    }

    function csrfParam() {
        var meta = document.querySelector('meta[name="csrf-param"]');
        return meta ? meta.getAttribute('content') : '_csrf';
    }

    function csrfToken() {
        var meta = document.querySelector('meta[name="csrf-token"]');
        return meta ? meta.getAttribute('content') : '';
    }

    function appendCsrf(body) {
        var token = csrfToken();
        if (token) {
            body.append(csrfParam(), token);
        }
    }

    function getLicenseCreateModalUrl() {
        var container = getGridContainer();
        return (container && container.dataset.licenseCreateModalUrl)
            || '/index.php?r=software/license-create-modal';
    }

    function getLicenseUpdateModalUrl(licenseId) {
        var container = getGridContainer();
        var tpl = (container && container.dataset.licenseUpdateModalUrlTemplate)
            || '/index.php?r=software/license-update-modal&id=__ID__';
        return tpl.replace('__ID__', String(licenseId));
    }

    function showToast(type, message) {
        if (!message) {
            return;
        }
        if (typeof window.showNotification === 'function') {
            window.showNotification(type, message);
            return;
        }
        var alertClass = type === 'success' ? 'alert-success' : 'alert-danger';
        var alertEl = document.createElement('div');
        alertEl.className = 'alert ' + alertClass + ' alert-dismissible fade show';
        alertEl.setAttribute('role', 'alert');
        alertEl.style.cssText = 'position:fixed;top:20px;right:20px;z-index:10050;min-width:300px;max-width:420px;';
        alertEl.innerHTML = String(message)
            + '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Закрыть"></button>';
        document.body.appendChild(alertEl);
        window.setTimeout(function() {
            if (alertEl.parentNode) {
                bootstrap.Alert.getOrCreateInstance(alertEl).close();
            }
        }, 5000);
    }

    function setModalTitle(text) {
        var $ = window.jQuery;
        var titleEl = document.getElementById('softwareLicenseModalLabel');
        var subtitleEl = document.getElementById('softwareLicenseModalSubtitle');
        var title = text || '';
        if (titleEl && $) {
            var icon = currentMode === 'edit' ? 'fa-pen' : 'fa-plus';
            $(titleEl).html(
                '<i class="fas ' + icon + '" aria-hidden="true"></i> ' + $('<div>').text(title).html()
            );
        } else if (titleEl) {
            titleEl.textContent = title;
        }
        if (subtitleEl) {
            subtitleEl.textContent = currentMode === 'edit'
                ? 'Изменение данных закупленной лицензии'
                : 'Учёт закупленной лицензии на программное обеспечение';
        }
    }

    function getTitleForMode(mode) {
        var modal = getModalEl();
        if (!modal) {
            return mode === 'edit' ? 'Редактировать лицензию' : 'Добавить лицензию';
        }
        if (mode === 'edit') {
            return modal.getAttribute('data-update-title') || 'Редактировать лицензию';
        }
        return modal.getAttribute('data-create-title') || 'Добавить лицензию';
    }

    function resetModalBody() {
        var body = document.getElementById('softwareLicenseModalBody');
        if (body) {
            body.innerHTML = loadingHtml;
        }
    }

    function displayFormErrors(errors) {
        var $ = window.jQuery;
        if (!$ || !errors) {
            return;
        }
        $('#softwareLicenseModalBody .has-error').removeClass('has-error');
        $('#softwareLicenseModalBody .help-block.field-error').remove();
        $.each(errors, function(field, messages) {
            var $field = $();
            if (field === 'software_name') {
                $field = $('#softwareLicenseModalBody [name="software_name"]');
            } else {
                $field = $('#softwareLicenseModalBody [name="License[' + field + ']"]');
            }
            if (!$field.length && field === 'uploadFiles') {
                $field = $('#softwareLicenseModalBody [data-license-attachment-input]');
            }
            if (!$field.length) {
                return;
            }
            var $group = $field.closest(
                '.arm-form-create__field, .field-license-' + field + ', .form-group, .mb-3, .software-license-attachments__upload'
            );
            $group.addClass('has-error');
            $field.after('<div class="help-block field-error">' + messages.join('<br>') + '</div>');
        });
    }

    function refreshGrid() {
        var container = getGridContainer();
        if (container && window.SectionGridUtils && typeof window.SectionGridUtils.reload === 'function') {
            window.SectionGridUtils.reload(container.id);
        }
    }

    function openModalInstance() {
        var modalEl = getModalEl();
        if (!modalEl || !window.bootstrap || !window.bootstrap.Modal) {
            return null;
        }
        return window.bootstrap.Modal.getOrCreateInstance(modalEl);
    }

    function bindLicenseEquipmentPicker(root) {
        if (!root) {
            return;
        }
        var picker = root.querySelector('[data-license-equipment-picker]');
        if (!picker) {
            return;
        }
        var searchInput = picker.querySelector('[data-license-equipment-search]');
        var items = picker.querySelectorAll('[data-license-equipment-item]');
        if (!searchInput || !items.length) {
            return;
        }

        searchInput.addEventListener('input', function() {
            var query = (searchInput.value || '').trim().toLowerCase();
            items.forEach(function(item) {
                var haystack = (item.getAttribute('data-search') || '').toLowerCase();
                item.classList.toggle('d-none', query !== '' && haystack.indexOf(query) === -1);
            });
        });
    }

    function bindPerpetualToggle(root) {
        if (!root) {
            return;
        }
        var checkbox = root.querySelector('.software-license-form__perpetual input[type="checkbox"]')
            || root.querySelector('[name="License[is_perpetual]"][type="checkbox"]');
        var yearsInput = root.querySelector('[name="License[validity_years]"]');
        if (!checkbox || !yearsInput) {
            return;
        }

        var yearsGroup = yearsInput.closest(
            '.software-license-form__validity-years, .field-license-validity_years, .arm-form-create__field'
        );

        function sync() {
            var perpetual = checkbox.checked;
            yearsInput.disabled = perpetual;
            yearsInput.readOnly = perpetual;
            if (perpetual) {
                yearsInput.value = '';
                if (yearsGroup) {
                    yearsGroup.classList.add('software-license-form__validity-years--disabled', 'text-muted');
                }
            } else {
                if (yearsGroup) {
                    yearsGroup.classList.remove('software-license-form__validity-years--disabled', 'text-muted');
                }
            }
        }

        checkbox.addEventListener('change', sync);
        sync();
    }

    function bindFormSubmit() {
        var $ = window.jQuery;
        if (!$) {
            return;
        }
        var $form = $('#softwareLicenseModalBody').find('#software-license-form');
        if (!$form.length) {
            return;
        }

        $('#submit-software-license-btn').off('click.softwareLicense').on('click.softwareLicense', function() {
            submitForm($form);
        });

        $form.off('submit.softwareLicense').on('submit.softwareLicense', function(e) {
            e.preventDefault();
            submitForm($form);
        });

        if (typeof window.bindLicenseAttachments === 'function') {
            window.bindLicenseAttachments(document.getElementById('softwareLicenseModalBody'));
        }

        var modalBody = document.getElementById('softwareLicenseModalBody');
        bindPerpetualToggle(modalBody);
        bindLicenseEquipmentPicker(modalBody);
    }

    function submitForm($form) {
        var $ = window.jQuery;
        var $btn = $('#submit-software-license-btn');
        var originalHtml = $btn.html();
        $btn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin" aria-hidden="true"></i> Сохранение…');

        var formEl = $form[0];
        var yearsInput = formEl.querySelector('[name="License[validity_years]"]');
        if (yearsInput) {
            yearsInput.disabled = false;
            yearsInput.readOnly = false;
        }
        var body = new FormData(formEl);
        appendCsrf(body);

        fetch($form.attr('action'), {
            method: 'POST',
            body: body,
            credentials: 'same-origin',
            headers: { 'X-Requested-With': 'XMLHttpRequest', Accept: 'application/json' },
        })
            .then(function(response) { return response.json(); })
            .then(function(res) {
                if (res && res.success) {
                    var inst = openModalInstance();
                    if (inst) {
                        inst.hide();
                    }
                    showToast('success', res.message || 'Сохранено');
                    refreshGrid();
                    return;
                }
                displayFormErrors(res && res.errors);
                showToast('error', (res && res.message) || 'Ошибка сохранения');
            })
            .catch(function() {
                showToast('error', 'Ошибка сохранения');
            })
            .finally(function() {
                $btn.prop('disabled', false).html(originalHtml);
                if (yearsInput) {
                    var perpetualCheckbox = formEl.querySelector('.software-license-form__perpetual input[type="checkbox"]')
                        || formEl.querySelector('[name="License[is_perpetual]"][type="checkbox"]');
                    var perpetual = !!(perpetualCheckbox && perpetualCheckbox.checked);
                    yearsInput.disabled = perpetual;
                    yearsInput.readOnly = perpetual;
                }
            });
    }

    function loadForm(url, mode, softwareId, licenseId) {
        var $ = window.jQuery;
        if (!$ || !url) {
            return;
        }
        currentMode = mode;
        currentSoftwareId = softwareId || null;
        currentLicenseId = licenseId || null;
        var requestId = ++loadRequestId;
        resetModalBody();
        setModalTitle(getTitleForMode(mode));

        var inst = openModalInstance();
        if (inst) {
            inst.show();
        }

        $.ajax({
            url: url,
            type: 'GET',
            headers: { 'X-Requested-With': 'XMLHttpRequest' },
        }).done(function(html) {
            if (requestId !== loadRequestId) {
                return;
            }
            var body = document.getElementById('softwareLicenseModalBody');
            if (body) {
                body.innerHTML = html;
            }
            bindFormSubmit();
        }).fail(function() {
            if (requestId !== loadRequestId) {
                return;
            }
            showToast('error', 'Не удалось загрузить форму');
            resetModalBody();
        });
    }

    window.openSoftwareLicenseCreateModal = function() {
        loadForm(getLicenseCreateModalUrl(), 'create', null, null);
    };

    window.openSoftwareLicenseUpdateModal = function(licenseId) {
        loadForm(getLicenseUpdateModalUrl(licenseId), 'edit', null, licenseId);
    };

    document.addEventListener('click', function(e) {
        var createBtn = e.target.closest('[data-software-license-create]');
        if (createBtn) {
            e.preventDefault();
            window.openSoftwareLicenseCreateModal();
            return;
        }
        var editBtn = e.target.closest('[data-software-license-edit]');
        if (editBtn) {
            e.preventDefault();
            var licenseId = editBtn.getAttribute('data-software-license-edit');
            if (licenseId) {
                window.openSoftwareLicenseUpdateModal(licenseId);
            }
        }
    });
})();
