/**
 * Модальное окно редактирования собственного профиля.
 */
(function() {
    'use strict';

    var modalEl = null;
    var bodyEl = null;
    var loadingHtml = '';

    function getModalUrl() {
        var root = document.querySelector('[data-profile-modal-url]');
        return (root && root.getAttribute('data-profile-modal-url'))
            || window.profileEditModalUrl
            || '/index.php?r=users/profile-modal';
    }

    function showToast(type, message) {
        if (typeof window.showNotification === 'function') {
            window.showNotification(type, message);
            return;
        }
        if (typeof window.IASNotify === 'function') {
            window.IASNotify(message, type === 'error' ? 'danger' : type);
            return;
        }
        alert(message);
    }

    function displayFormErrors(errors) {
        var $ = window.jQuery;
        if (!$ || !errors) {
            return;
        }
        $('#profileEditModalBody .has-error').removeClass('has-error');
        $('#profileEditModalBody .help-block.field-error').remove();
        $.each(errors, function(field, messages) {
            var $field = $('#profile-' + field + ', #users-' + field);
            if (!$field.length) {
                return;
            }
            var $group = $field.closest('.field-profile-' + field + ', .field-users-' + field + ', .form-group, .mb-0, .profile-edit-form__section');
            $group.addClass('has-error');
            $field.after('<div class="help-block field-error">' + messages.join('<br>') + '</div>');
        });
    }

    function parseJsonResponse(xhr) {
        if (xhr.responseJSON) {
            return xhr.responseJSON;
        }
        if (!xhr.responseText) {
            return null;
        }
        try {
            return JSON.parse(xhr.responseText);
        } catch (e) {
            return null;
        }
    }

    function resetModalBody() {
        if (bodyEl) {
            bodyEl.innerHTML = loadingHtml;
        }
    }

    function moveModalToBody() {
        if (modalEl && modalEl.parentNode !== document.body) {
            document.body.appendChild(modalEl);
        }
    }

    function analyzePassword(password, confirm) {
        return {
            length: password.length >= 8,
            lower: /[a-zа-яё]/u.test(password),
            upper: /[A-ZА-ЯЁ]/u.test(password),
            digit: /\d/u.test(password),
            match: password !== '' && password === confirm,
        };
    }

    function scorePassword(checks) {
        var score = 0;
        if (checks.length) score++;
        if (checks.lower) score++;
        if (checks.upper) score++;
        if (checks.digit) score++;
        return score;
    }

    function bindPasswordStrength() {
        var passwordInput = document.getElementById('profile-password_plain');
        var confirmInput = document.getElementById('profile-password_confirm');
        var panel = document.getElementById('profilePasswordStrength');
        var fill = document.getElementById('profilePasswordStrengthFill');
        var rules = document.getElementById('profilePasswordRules');

        if (!passwordInput || !confirmInput || !panel || !fill || !rules) {
            return;
        }

        function updateStrength() {
            var password = passwordInput.value || '';
            var confirm = confirmInput.value || '';

            if (password === '' && confirm === '') {
                panel.hidden = true;
                return;
            }

            panel.hidden = false;
            var checks = analyzePassword(password, confirm);
            var score = scorePassword(checks);

            fill.style.width = Math.max(8, (score / 4) * 100) + '%';
            fill.className = 'profile-password-strength__fill';
            if (score <= 1) {
                fill.classList.add('profile-password-strength__fill--weak');
            } else if (score <= 3) {
                fill.classList.add('profile-password-strength__fill--medium');
            } else {
                fill.classList.add('profile-password-strength__fill--strong');
            }

            rules.querySelectorAll('li[data-rule]').forEach(function(item) {
                var rule = item.getAttribute('data-rule');
                var ok = checks[rule];
                item.classList.toggle('is-met', !!ok);
            });
        }

        passwordInput.addEventListener('input', updateStrength);
        confirmInput.addEventListener('input', updateStrength);
        updateStrength();
    }

    function validateClientPassword() {
        var passwordInput = document.getElementById('profile-password_plain');
        var confirmInput = document.getElementById('profile-password_confirm');
        if (!passwordInput || !confirmInput) {
            return true;
        }

        var password = passwordInput.value || '';
        var confirm = confirmInput.value || '';

        if (password === '' && confirm === '') {
            return true;
        }

        var checks = analyzePassword(password, confirm);
        if (!checks.length || !checks.lower || !checks.upper || !checks.digit) {
            showToast('error', 'Пароль должен содержать не менее 8 символов, строчные и прописные буквы, а также цифры.');
            return false;
        }
        if (!checks.match) {
            showToast('error', 'Пароли не совпадают.');
            return false;
        }

        return true;
    }

    function updateProfilePhone(phone) {
        var phoneEl = document.querySelector('[data-profile-phone-value]');
        if (phoneEl) {
            phoneEl.textContent = phone && String(phone).trim() !== '' ? phone : 'Не указан';
        }
    }

    function handleFormSubmit(e) {
        e.preventDefault();

        var $ = window.jQuery;
        var $form = $(e.currentTarget);
        if (!$form.length || !$form.closest('#profileEditModalBody').length) {
            return;
        }

        if (!validateClientPassword()) {
            return;
        }

        var $btn = $form.find('#profile-edit-submit');
        var originalHtml = $btn.html();
        $btn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> Сохранение…');

        $.ajax({
            url: getModalUrl(),
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
                    if (typeof response.phone !== 'undefined') {
                        updateProfilePhone(response.phone);
                    }
                    var inst = modalEl && window.bootstrap && window.bootstrap.Modal.getInstance(modalEl);
                    if (inst) {
                        inst.hide();
                    }
                    showToast('success', response.message || 'Профиль сохранён.');
                } else {
                    showToast('error', (response && response.message) || 'Не удалось сохранить.');
                    displayFormErrors(response && response.errors);
                }
            })
            .fail(function(xhr) {
                var parsed = parseJsonResponse(xhr);
                var msg = (parsed && parsed.message)
                    || 'Ошибка сервера'
                    + (xhr.status ? ' (' + xhr.status + ')' : '');
                showToast('error', msg);
                if (parsed && parsed.errors) {
                    displayFormErrors(parsed.errors);
                }
            })
            .always(function() {
                $btn.prop('disabled', false).html(originalHtml);
            });
    }

    function bindFormSubmitDelegation() {
        var $ = window.jQuery;
        var $body = $('#profileEditModalBody');
        if (!$body.length) {
            return;
        }
        $body.off('submit.profileEdit', 'form').on('submit.profileEdit', 'form', handleFormSubmit);
    }

    function loadForm() {
        resetModalBody();

        if (!window.jQuery) {
            if (bodyEl) {
                bodyEl.innerHTML = '<div class="alert alert-danger mb-0">Не загружен jQuery. Обновите страницу.</div>';
            }
            return;
        }

        window.jQuery.get(getModalUrl())
            .done(function(html) {
                var $body = window.jQuery('#profileEditModalBody');
                $body.html(html);
                $body.find('script').remove();
                bindFormSubmitDelegation();
                bindPasswordStrength();
            })
            .fail(function() {
                window.jQuery('#profileEditModalBody').html(
                    '<div class="alert alert-danger mb-0">Не удалось загрузить форму. Попробуйте позже.</div>'
                );
            });
    }

    function open() {
        if (!modalEl || !window.bootstrap || !window.bootstrap.Modal) {
            showToast('error', 'Модальное окно недоступно. Обновите страницу.');
            return;
        }

        moveModalToBody();
        var modal = window.bootstrap.Modal.getOrCreateInstance(modalEl, {
            backdrop: true,
            keyboard: true,
            focus: true,
        });
        modal.show();
        loadForm();
    }

    function init() {
        modalEl = document.getElementById('profileEditModal');
        bodyEl = document.getElementById('profileEditModalBody');
        if (!modalEl || !bodyEl) {
            return;
        }

        loadingHtml = bodyEl.innerHTML;
        moveModalToBody();
        bindFormSubmitDelegation();

        window.openProfileEditModal = open;

        document.addEventListener('click', function(e) {
            var trigger = e.target.closest('[data-profile-edit-open]');
            if (!trigger) {
                return;
            }
            e.preventDefault();
            open();
        });

        modalEl.addEventListener('hidden.bs.modal', function() {
            resetModalBody();
        });

        var params = new URLSearchParams(window.location.search);
        if (params.get('editProfile')) {
            open();
            params.delete('editProfile');
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
