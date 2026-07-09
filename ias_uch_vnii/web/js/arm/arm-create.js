/**
 * Модальное окно добавления и редактирования техники на странице «Учёт ТС».
 */
(function($) {
    'use strict';

    var formMode = 'create';
    var editEquipmentId = null;

    function getGridContainer() {
        return document.getElementById('agGridArmContainer');
    }

    function getCreateModalUrl() {
        var container = getGridContainer();
        if (container && container.dataset.createModalUrl) {
            return container.dataset.createModalUrl;
        }
        return '/index.php?r=arm/create-modal';
    }

    function getUpdateModalUrl(equipmentId) {
        var container = getGridContainer();
        var tpl = (container && container.dataset.updateModalUrlTemplate)
            || window.agGridArmUpdateModalUrlTemplate
            || '/index.php?r=arm/update-modal&id=__ID__';
        return tpl.replace('__ID__', String(equipmentId));
    }

    function getFormModalUrl() {
        if (formMode === 'edit' && editEquipmentId) {
            return getUpdateModalUrl(editEquipmentId);
        }
        return getCreateModalUrl();
    }

    function resetFormModalHeader() {
        var $label = $('#createArmModalLabel');
        var $subtitle = $('#createArmModalSubtitle');
        if ($label.length) {
            $label.html('<i class="fas fa-plus" aria-hidden="true"></i> Добавление техники');
        }
        if ($subtitle.length) {
            $subtitle.text('Новая запись в учёте технических средств');
        }
    }

    function showToast(type, message) {
        if (!message) {
            return;
        }
        var alertClass = type === 'success' ? 'alert-success' : 'alert-danger';
        var alertEl = document.createElement('div');
        alertEl.className = 'alert ' + alertClass + ' alert-dismissible fade show';
        alertEl.setAttribute('role', 'alert');
        alertEl.style.cssText = 'position:fixed;top:20px;right:20px;z-index:10050;min-width:300px;max-width:420px;';
        alertEl.innerHTML = escapeHtml(message)
            + '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Закрыть"></button>';
        document.body.appendChild(alertEl);
        window.setTimeout(function() {
            if (alertEl.parentNode) {
                bootstrap.Alert.getOrCreateInstance(alertEl).close();
            }
        }, 5000);
    }

    function escapeHtml(text) {
        return $('<div>').text(String(text || '')).html();
    }

    function clearFormErrors($form) {
        $form.find('.has-error').removeClass('has-error');
        $form.find('.arm-field--error').removeClass('arm-field--error arm-field--error-animate');
        $form.find('.is-invalid').removeClass('is-invalid');
        $form.find('.select2-container.is-invalid, .select2-container.arm-select2--invalid')
            .removeClass('is-invalid arm-select2--invalid');
        $form.find('.invalid-feedback').empty().removeClass('arm-create-error d-block');
    }

    function findFormFieldInput($form, field) {
        if (field === 'location_id') {
            field = 'location_name';
        }
        var names = [
            'Equipment[' + field + ']',
            'PartChar[' + field + ']',
            'OrgTech[' + field + ']',
        ];
        var $field = $();
        names.some(function(name) {
            $field = $form.find('[name="' + name + '"]');
            return $field.length > 0;
        });
        return $field;
    }

    function findFieldWrapper($field) {
        var $wrapper = $field.closest(
            '.arm-form-create__field, .arm-dynamic-field, .mb-3, .form-group'
        );
        return $wrapper.length ? $wrapper : $field.parent();
    }

    function getSelect2ContainerForField($field) {
        if (!$field || !$field.length) {
            return $();
        }
        var $container = $field.next('.select2-container');
        if ($container.length) {
            return $container;
        }
        return findFieldWrapper($field).find('.select2-container').first();
    }

    function syncSelect2ErrorState($field, hasError) {
        var $container = getSelect2ContainerForField($field);
        if (!$container.length) {
            return;
        }
        if (hasError) {
            $container.addClass('is-invalid arm-select2--invalid');
            return;
        }
        $container.removeClass('is-invalid arm-select2--invalid');
    }

    function setFieldErrorMessage($field, $wrapper, messages) {
        var list = Array.isArray(messages) ? messages : [messages];
        var html = list.map(escapeHtml).join('<br>');
        var $yiiError = $wrapper.find('.invalid-feedback').first();
        if ($yiiError.length) {
            $yiiError.html(html).addClass('d-block arm-create-error');
            return;
        }
        $field.after(
            '<div class="invalid-feedback d-block arm-create-error">' + html + '</div>'
        );
    }

    function applyValidationHighlight($form) {
        $form.find('.arm-field--error-animate').removeClass('arm-field--error-animate');

        $form.find('.form-control.is-invalid, .form-select.is-invalid, textarea.is-invalid').each(function() {
            var $input = $(this);
            var $wrapper = findFieldWrapper($input);
            if (!$wrapper.length) {
                return;
            }
            $wrapper.addClass('has-error arm-field--error');
            syncSelect2ErrorState($input, true);
            void $wrapper[0].offsetWidth;
            $wrapper.addClass('arm-field--error-animate');
        });

        $form.find('.arm-form-create__field .invalid-feedback, .arm-dynamic-field .invalid-feedback').each(function() {
            var text = $.trim($(this).text());
            if (!text) {
                return;
            }
            var $wrapper = $(this).closest('.arm-form-create__field, .arm-dynamic-field, .mb-3');
            if (!$wrapper.length) {
                return;
            }
            $wrapper.addClass('has-error arm-field--error');
            var $input = $wrapper.find('.form-control, .form-select, textarea').first();
            if ($input.length) {
                $input.addClass('is-invalid');
                syncSelect2ErrorState($input, true);
            }
            if (!$wrapper.hasClass('arm-field--error-animate')) {
                void $wrapper[0].offsetWidth;
                $wrapper.addClass('arm-field--error-animate');
            }
        });

        $form.find('.arm-form-create__field.has-error').each(function() {
            var $wrapper = $(this);
            $wrapper.addClass('arm-field--error');
            $wrapper.find('select.form-select, select.js-user-select-search').each(function() {
                var $select = $(this);
                $select.addClass('is-invalid');
                syncSelect2ErrorState($select, true);
            });
        });
    }

    function markFieldInvalid($field, messages) {
        if (!$field.length) {
            return;
        }
        var $wrapper = findFieldWrapper($field);
        $wrapper.addClass('has-error arm-field--error');
        $field.addClass('is-invalid');
        syncSelect2ErrorState($field, true);

        setFieldErrorMessage($field, $wrapper, messages);

        if ($wrapper[0]) {
            void $wrapper[0].offsetWidth;
            $wrapper.addClass('arm-field--error-animate');
        }
    }

    function displayFormErrors($form, errors) {
        clearFormErrors($form);
        if (!errors) {
            return;
        }
        $.each(errors, function(field, messages) {
            var $field = findFormFieldInput($form, field);
            markFieldInvalid($field, messages);
        });
        applyValidationHighlight($form);
    }

    function bindYiiValidationHighlight($form) {
        var attempts = 0;
        var tryBind = function() {
            attempts += 1;
            if (!$form.data('yiiActiveForm')) {
                if (attempts < 40) {
                    window.setTimeout(tryBind, 50);
                }
                return;
            }
            $form.off('afterValidate.armCreateHighlight').on('afterValidate.armCreateHighlight', function() {
                window.setTimeout(function() {
                    applyValidationHighlight($form);
                }, 0);
            });
        };
        tryBind();
    }

    function bindCreateFormErrorClear($form) {
        $form
            .off('input.armCreateClear change.armCreateClear')
            .on('input.armCreateClear change.armCreateClear', 'input, select, textarea', function() {
                var $input = $(this);
                var $wrapper = $input.closest('.arm-field--error, .arm-form-create__field.has-error');
                if (!$wrapper.length) {
                    return;
                }
                $wrapper.removeClass('has-error arm-field--error arm-field--error-animate');
                $input.removeClass('is-invalid');
                syncSelect2ErrorState($input, false);
                $wrapper.find('.invalid-feedback').empty().removeClass('arm-create-error d-block');
            });
    }

    function syncFormModalHeader() {
        var $modal = $('#createArmModal');
        var $name = $modal.find('[name="Equipment[name]"]');
        var title = $.trim($name.val());
        var inv = $.trim($modal.find('[name="Equipment[inventory_number]"]').val());
        var $label = $('#createArmModalLabel');
        var $subtitle = $('#createArmModalSubtitle');
        if (!$label.length) {
            return;
        }
        if (formMode === 'edit') {
            var display = title || inv || 'Техника';
            $label.html('<i class="fas fa-pen" aria-hidden="true"></i> ' + $('<div>').text(display).html());
            if ($subtitle.length) {
                $subtitle.text('Редактирование записи в учёте технических средств');
            }
            return;
        }
        if (title) {
            $label.html('<i class="fas fa-plus" aria-hidden="true"></i> ' + $('<div>').text(title).html());
            if ($subtitle.length) {
                $subtitle.text('Новая запись в учёте технических средств');
            }
            return;
        }
        resetFormModalHeader();
    }

    function initLoadedForm() {
        var modalBody = document.getElementById('createArmModalBody');
        try {
            if (typeof window.armInitEquipmentCreateForm === 'function') {
                window.armInitEquipmentCreateForm(modalBody);
            }
            if (window.IasUserSelect) {
                window.IasUserSelect.init(modalBody);
            }
            if (typeof window.armBindDatalistInputs === 'function' && modalBody) {
                window.armBindDatalistInputs(modalBody, '.js-location-datalist', 'arm-location-datalist');
                window.armBindDatalistInputs(modalBody, '.js-inventory-datalist', 'arm-inventory-datalist');
                window.armBindDatalistInputs(modalBody, '.js-equipment-name-datalist', 'arm-name-datalist');
            } else if (typeof window.armBindLocationDatalist === 'function') {
                window.armBindLocationDatalist(modalBody);
            }
            if (typeof window.armInitWarrantyPreview === 'function') {
                window.armInitWarrantyPreview();
            }
            if (typeof window.bindArmAttachments === 'function' && modalBody) {
                window.bindArmAttachments(modalBody);
            }
            if (typeof window.syncArmPhotosCardMinHeight === 'function' && modalBody) {
                window.requestAnimationFrame(function() {
                    window.syncArmPhotosCardMinHeight(modalBody);
                });
            }
        } catch (err) {
            if (window.console && typeof window.console.error === 'function') {
                window.console.error('ARM form init failed', err);
            }
        } finally {
            if (typeof window.armSyncEquipmentConfigFields === 'function') {
                window.armSyncEquipmentConfigFields(modalBody);
            }
            syncFormModalHeader();
            var modalRoot = document.getElementById('createArmModal');
            if (modalRoot) {
                modalRoot.removeEventListener('input', syncFormModalHeaderOnInput);
                modalRoot.addEventListener('input', syncFormModalHeaderOnInput);
            }
        }
    }

    function syncFormModalHeaderOnInput(e) {
        if (!e.target) {
            return;
        }
        var name = e.target.getAttribute('name') || '';
        if (name === 'Equipment[name]' || name === 'Equipment[inventory_number]') {
            syncFormModalHeader();
        }
    }

    function scrollToFirstError($form) {
        var $first = $form.find('.is-invalid, .has-error, .arm-field--error').first();
        if (!$first.length) {
            return;
        }
        var scrollParent = document.getElementById('createArmModalBody');
        if (!scrollParent || !$first[0]) {
            return;
        }
        var top = $first[0].getBoundingClientRect().top
            - scrollParent.getBoundingClientRect().top
            + scrollParent.scrollTop
            - 24;
        scrollParent.scrollTo({ top: Math.max(0, top), behavior: 'smooth' });
    }

    function triggerArmFormSave($form) {
        if (!$form || !$form.length) {
            return;
        }

        var formEl = $form[0];
        if (formEl && typeof formEl.checkValidity === 'function' && !formEl.checkValidity()) {
            if (typeof formEl.reportValidity === 'function') {
                formEl.reportValidity();
            }
            return;
        }

        if ($form.data('yiiActiveForm')) {
            $form
                .off('afterValidate.armCreateSave')
                .on('afterValidate.armCreateSave', function(event, messages, errorAttributes) {
                    $form.off('afterValidate.armCreateSave');
                    if (errorAttributes && errorAttributes.length) {
                        applyValidationHighlight($form);
                        scrollToFirstError($form);
                        showToast('error', 'Проверьте выделенные поля формы.');
                        return;
                    }
                    sendEquipmentFormRequest($form);
                });
            $form.yiiActiveForm('validate', true);
            return;
        }

        sendEquipmentFormRequest($form);
    }

    function sendEquipmentFormRequest($form) {
        if ($form.data('armCreateSaving')) {
            return;
        }
        $form.data('armCreateSaving', true);

        var $btn = $('#createArmModal').find('#submit-arm-create-btn');
        var originalHtml = $btn.length ? $btn.html() : '';
        if ($btn.length) {
            $btn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin" aria-hidden="true"></i> Сохранение…');
        }

        $.ajax({
            url: getFormModalUrl(),
            type: 'POST',
            data: $form.serialize(),
            dataType: 'json',
            headers: {
                'X-Requested-With': 'XMLHttpRequest',
                Accept: 'application/json',
            },
        })
            .done(function(response) {
                if (response && response.success) {
                    if (response.message) {
                        showToast('success', response.message);
                    }
                    var savedId = response.equipment_id || editEquipmentId;
                    var modalEl = document.getElementById('createArmModal');
                    var modal = modalEl ? bootstrap.Modal.getInstance(modalEl) : null;
                    if (modal) {
                        modal.hide();
                    }
                    if (typeof window.refreshArmGrid === 'function') {
                        window.refreshArmGrid();
                    }
                    if (window.ArmView && window.ArmView.isOpen && window.ArmView.isOpen()
                        && savedId && String(window.ArmView.getEquipmentId()) === String(savedId)) {
                        window.ArmView.reload();
                    }
                } else {
                    showToast('error', (response && response.message) || 'Не удалось сохранить технику.');
                    displayFormErrors($form, response && response.errors);
                    scrollToFirstError($form);
                }
            })
            .fail(function(xhr) {
                var msg = 'Ошибка сервера';
                if (xhr.responseJSON && xhr.responseJSON.message) {
                    msg = xhr.responseJSON.message;
                }
                showToast('error', msg);
            })
            .always(function() {
                $form.data('armCreateSaving', false);
                if ($btn.length) {
                    $btn.prop('disabled', false).html(originalHtml);
                }
            });
    }

    function initFormSubmit() {
        var $form = $('#createArmModalBody').find('#arm-create-form');
        if (!$form.length) {
            return;
        }

        bindCreateFormErrorClear($form);
        bindYiiValidationHighlight($form);

        $form
            .off('submit.armCreate')
            .on('submit.armCreate', function(e) {
                e.preventDefault();
                triggerArmFormSave($form);
                return false;
            });
    }

    function loadingHtml() {
        return '<div class="arm-view-modal__loading text-center text-muted py-5">' +
            '<i class="fas fa-circle-notch fa-spin fa-2x" aria-hidden="true"></i>' +
            '<p class="mt-3 mb-0">Загрузка формы…</p></div>';
    }

    /** Inline-скрипты из AJAX-ответа (jQuery .html() вырезает script — дублируем через append). */
    function runInsertedScripts(root) {
        if (!root) {
            return;
        }
        if (typeof window.armApplyArmFormConfigFromDom === 'function') {
            window.armApplyArmFormConfigFromDom(root);
        }
        root.querySelectorAll('script:not([src])').forEach(function(script) {
            var code = script.textContent || script.innerText || '';
            if (!code.trim()) {
                return;
            }
            try {
                var exec = document.createElement('script');
                exec.text = code;
                document.body.appendChild(exec);
                exec.parentNode.removeChild(exec);
            } catch (err) {
                if (window.console && typeof window.console.error === 'function') {
                    window.console.error('ARM modal inline script failed', err);
                }
            }
        });
    }

    function finalizeLoadedFormModal() {
        initLoadedForm();
        initFormSubmit();
        syncFormModalHeader();
    }

    function openEquipmentFormModal(mode, equipmentId) {
        var modalEl = document.getElementById('createArmModal');
        if (!modalEl) {
            return;
        }

        formMode = mode === 'edit' ? 'edit' : 'create';
        editEquipmentId = formMode === 'edit' ? parseInt(equipmentId, 10) || null : null;
        if (formMode === 'edit' && !editEquipmentId) {
            return;
        }

        if (formMode === 'create') {
            resetFormModalHeader();
        } else {
            var $label = $('#createArmModalLabel');
            var $subtitle = $('#createArmModalSubtitle');
            if ($label.length) {
                $label.html('<i class="fas fa-pen" aria-hidden="true"></i> Редактирование техники');
            }
            if ($subtitle.length) {
                $subtitle.text('Загрузка данных…');
            }
        }

        var modal = bootstrap.Modal.getOrCreateInstance(modalEl);
        modal.show();

        $('#createArmModalBody').html(loadingHtml());

        $.get(getFormModalUrl())
            .done(function(html) {
                var bodyEl = document.getElementById('createArmModalBody');
                $('#createArmModalBody').html(html);
                try {
                    runInsertedScripts(bodyEl);
                } catch (err) {
                    if (window.console && typeof window.console.error === 'function') {
                        window.console.error('ARM modal scripts failed', err);
                    }
                }
                finalizeLoadedFormModal();
            })
            .fail(function(xhr) {
                var msg = 'Не удалось загрузить форму. Попробуйте позже.';
                if (xhr && xhr.status === 403) {
                    msg = 'Нет прав на редактирование этой техники.';
                }
                $('#createArmModalBody').html(
                    '<div class="alert alert-danger mb-0">' + escapeHtml(msg) + '</div>'
                );
            });
    }

    window.openCreateArmModal = function() {
        openEquipmentFormModal('create');
    };

    window.openEditArmModal = function(equipmentId) {
        openEquipmentFormModal('edit', equipmentId);
    };

    $(document).on('click', '[data-arm-create-open]', function(e) {
        e.preventDefault();
        window.openCreateArmModal();
    });

    $(document).on('click', '[data-arm-edit]', function(e) {
        e.preventDefault();
        var id = $(this).attr('data-arm-edit');
        if (id) {
            window.openEditArmModal(id);
        }
    });

    var modalEl = document.getElementById('createArmModal');
    if (modalEl) {
        modalEl.addEventListener('click', function(e) {
            if (!e.target.closest('#submit-arm-create-btn')) {
                return;
            }
            e.preventDefault();
            var $form = $('#createArmModalBody').find('#arm-create-form');
            triggerArmFormSave($form);
        });

        modalEl.addEventListener('hidden.bs.modal', function() {
            if (window.IasUserSelect && typeof window.IasUserSelect.destroy === 'function') {
                window.IasUserSelect.destroy(document.getElementById('createArmModalBody'));
            }
            if (typeof window.armClearFormConfigGlobals === 'function') {
                window.armClearFormConfigGlobals();
            }
            $('#createArmModalBody').html(loadingHtml());
            formMode = 'create';
            editEquipmentId = null;
            resetFormModalHeader();
        });
    }

    var urlParams = new URLSearchParams(window.location.search);
    var editParam = urlParams.get('edit');
    if (editParam) {
        window.openEditArmModal(editParam);
        urlParams.delete('edit');
        var qs = urlParams.toString();
        var nextUrl = window.location.pathname + (qs ? '?' + qs : '') + window.location.hash;
        if (window.history && window.history.replaceState) {
            window.history.replaceState({}, '', nextUrl);
        }
    }
})(jQuery);
