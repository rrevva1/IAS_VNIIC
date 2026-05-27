/**
 * Модальное окно добавления техники на странице «Учёт ТС».
 */
(function($) {
    'use strict';

    function getCreateModalUrl() {
        var container = document.getElementById('agGridArmContainer');
        if (container && container.dataset.createModalUrl) {
            return container.dataset.createModalUrl;
        }
        return '/index.php?r=arm/create-modal';
    }

    function showToast(type, message) {
        if (typeof window.showNotification === 'function') {
            window.showNotification(type, message);
            return;
        }
        alert(message);
    }

    function displayFormErrors($form, errors) {
        $form.find('.has-error').removeClass('has-error');
        $form.find('.help-block, .invalid-feedback.arm-create-error').remove();
        if (!errors) {
            return;
        }
        $.each(errors, function(field, messages) {
            var list = Array.isArray(messages) ? messages : [messages];
            var $field = $form.find('[name="Equipment[' + field + ']"]');
            if (!$field.length) {
                $field = $form.find('[name="PartChar[' + field + ']"]');
            }
            var $group = $field.closest('.form-group, .mb-3, .arm-form-dynamic-fields > div');
            if ($group.length) {
                $group.addClass('has-error');
                $field.after('<div class="help-block arm-create-error">' + list.join('<br>') + '</div>');
            }
        });
    }

    function syncCreateModalHeader() {
        var $modal = $('#createArmModal');
        var $name = $modal.find('[name="Equipment[name]"]');
        var title = $.trim($name.val());
        var $label = $('#createArmModalLabel');
        var $subtitle = $('#createArmModalSubtitle');
        if (!$label.length) {
            return;
        }
        if (title) {
            $label.html('<i class="fas fa-plus" aria-hidden="true"></i> ' + $('<div>').text(title).html());
            if ($subtitle.length) {
                $subtitle.text('Новая запись в учёте технических средств');
            }
            return;
        }
        $label.html('<i class="fas fa-plus" aria-hidden="true"></i> Добавление техники');
        if ($subtitle.length) {
            $subtitle.text('Новая запись в учёте технических средств');
        }
    }

    function initLoadedForm() {
        if (window.IasUserSelect) {
            window.IasUserSelect.init(document.getElementById('createArmModalBody'));
        }
        if (typeof window.armInitEquipmentCreateForm === 'function') {
            window.armInitEquipmentCreateForm();
        }
        if (typeof window.armInitWarrantyPreview === 'function') {
            window.armInitWarrantyPreview();
        }
        syncCreateModalHeader();
        var modalRoot = document.getElementById('createArmModal');
        if (modalRoot) {
            modalRoot.removeEventListener('input', syncCreateModalHeaderOnInput);
            modalRoot.addEventListener('input', syncCreateModalHeaderOnInput);
        }
    }

    function syncCreateModalHeaderOnInput(e) {
        if (e.target && e.target.getAttribute('name') === 'Equipment[name]') {
            syncCreateModalHeader();
        }
    }

    function initFormSubmit() {
        var $form = $('#createArmModalBody').find('#arm-create-form');
        if (!$form.length) {
            return;
        }

        $form.off('submit.armCreate').on('submit.armCreate', function(e) {
            e.preventDefault();

            var $btn = $('#createArmModal').find('#submit-arm-create-btn');
            var originalHtml = $btn.length ? $btn.html() : '';
            if ($btn.length) {
                $btn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin" aria-hidden="true"></i> Сохранение…');
            }

            $.ajax({
                url: getCreateModalUrl(),
                type: 'POST',
                data: $form.serialize(),
                dataType: 'json',
            })
                .done(function(response) {
                    if (response && response.success) {
                        var modalEl = document.getElementById('createArmModal');
                        var modal = modalEl ? bootstrap.Modal.getInstance(modalEl) : null;
                        if (modal) {
                            modal.hide();
                        }
                        showToast('success', response.message || 'Техника добавлена.');
                        if (typeof window.refreshArmGrid === 'function') {
                            window.refreshArmGrid();
                        }
                    } else {
                        showToast('error', (response && response.message) || 'Не удалось сохранить технику.');
                        displayFormErrors($form, response && response.errors);
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
                    if ($btn.length) {
                        $btn.prop('disabled', false).html(originalHtml);
                    }
                });
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
        root.querySelectorAll('script:not([src])').forEach(function(script) {
            var code = script.textContent || script.innerText || '';
            if (!code.trim()) {
                return;
            }
            var exec = document.createElement('script');
            exec.text = code;
            document.body.appendChild(exec);
            exec.parentNode.removeChild(exec);
        });
    }

    window.openCreateArmModal = function() {
        var modalEl = document.getElementById('createArmModal');
        if (!modalEl) {
            return;
        }

        var modal = bootstrap.Modal.getOrCreateInstance(modalEl);
        modal.show();

        $('#createArmModalBody').html(loadingHtml());

        $.get(getCreateModalUrl())
            .done(function(html) {
                var bodyEl = document.getElementById('createArmModalBody');
                $('#createArmModalBody').html(html);
                runInsertedScripts(bodyEl);
                initLoadedForm();
                initFormSubmit();
            })
            .fail(function() {
                $('#createArmModalBody').html(
                    '<div class="alert alert-danger mb-0">Не удалось загрузить форму. Попробуйте позже.</div>'
                );
            });
    };

    $(document).on('click', '[data-arm-create-open]', function(e) {
        e.preventDefault();
        window.openCreateArmModal();
    });

    var modalEl = document.getElementById('createArmModal');
    if (modalEl) {
        modalEl.addEventListener('hidden.bs.modal', function() {
            if (window.IasUserSelect && typeof window.IasUserSelect.destroy === 'function') {
                window.IasUserSelect.destroy(document.getElementById('createArmModalBody'));
            }
            $('#createArmModalBody').html(loadingHtml());
        });
    }
})(jQuery);
