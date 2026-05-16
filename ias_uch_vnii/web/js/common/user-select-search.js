/**
 * Комбобокс выбора пользователя с поиском по ФИО (Select2).
 * Элементы: select.js-user-select-search
 */
(function ($) {
    'use strict';

    var RU = {
        errorLoading: function () { return 'Не удалось загрузить данные'; },
        inputTooLong: function (args) {
            var n = args.input.length - args.maximum;
            return 'Удалите ' + n + ' симв.';
        },
        inputTooShort: function (args) {
            var n = args.minimum - args.input.length;
            return 'Введите ещё ' + n + ' симв.';
        },
        loadingMore: function () { return 'Загрузка…'; },
        maximumSelected: function (args) {
            return 'Можно выбрать не более ' + args.maximum;
        },
        noResults: function () { return 'Ничего не найдено'; },
        searching: function () { return 'Поиск…'; },
    };

    var modalFocusTrapFixed = false;

    /** Bootstrap 5 modal focus trap ломает Select2 (список закрывается сразу после клика). */
    function ensureBootstrapModalSelect2FocusFix() {
        if (modalFocusTrapFixed) {
            return;
        }
        modalFocusTrapFixed = true;
        document.addEventListener('focusin', function (e) {
            if ($(e.target).closest('.select2-container, .select2-dropdown').length) {
                e.stopImmediatePropagation();
            }
        }, true);
    }

    function resolvePlaceholder($select) {
        var fromData = $select.data('placeholder');
        if (fromData) {
            return String(fromData);
        }
        var emptyOpt = $select.find('option[value=""]').first();
        if (emptyOpt.length) {
            return emptyOpt.text();
        }
        return 'Введите ФИО для поиска';
    }

    function resolveDropdownParent($select) {
        var $modal = $select.closest('.modal.show, .modal');
        if ($modal.length) {
            return $(document.body);
        }
        var $field = $select.closest('.js-user-select-field');
        if ($field.length) {
            return $field;
        }
        return $(document.body);
    }

    function closeOtherUserSelects(currentEl) {
        $('select.js-user-select-search.select2-hidden-accessible').each(function () {
            if (this !== currentEl) {
                $(this).select2('close');
            }
        });
    }

    function buildOptions($select) {
        var hasEmpty = $select.find('option[value=""]').length > 0;
        return {
            language: RU,
            width: '100%',
            minimumResultsForSearch: 0,
            placeholder: resolvePlaceholder($select),
            allowClear: hasEmpty,
            dropdownParent: resolveDropdownParent($select),
            dropdownAutoWidth: false,
        };
    }

    function dispatchNativeChange(selectEl) {
        if (!selectEl) {
            return;
        }
        try {
            selectEl.dispatchEvent(new Event('change', { bubbles: true }));
        } catch (err) {
            var evt = document.createEvent('HTMLEvents');
            evt.initEvent('change', true, false);
            selectEl.dispatchEvent(evt);
        }
    }

    function bindSelect2Events($select) {
        $select.off('select2:opening.iasUserSelect select2:select.iasUserSelect select2:clear.iasUserSelect');
        $select.on('select2:opening.iasUserSelect', function () {
            closeOtherUserSelects(this);
        });
        $select.on('select2:select.iasUserSelect select2:clear.iasUserSelect', function () {
            var el = this;
            setTimeout(function () {
                dispatchNativeChange(el);
            }, 0);
        });
    }

    function initOne(selectEl) {
        var $select = $(selectEl);
        if (!$select.length) {
            return;
        }
        if ($select.hasClass('select2-hidden-accessible')) {
            $select.select2('destroy');
        }
        if ($select.closest('.modal').length) {
            ensureBootstrapModalSelect2FocusFix();
        }
        $select.select2(buildOptions($select));
        bindSelect2Events($select);
    }

    function shouldInitInPlace($select) {
        var $modal = $select.closest('.modal');
        if (!$modal.length) {
            return true;
        }
        return $modal.hasClass('show');
    }

    window.IasUserSelect = {
        init: function (context, options) {
            options = options || {};
            var $root = context ? $(context) : $(document);
            if ($root.closest('.modal').length || $root.hasClass('modal') || $root.is('.modal')) {
                ensureBootstrapModalSelect2FocusFix();
            }
            if (options.reinit) {
                this.destroy(context);
            }
            $root.find('select.js-user-select-search').each(function () {
                var $select = $(this);
                if (!context && !options.force && !shouldInitInPlace($select)) {
                    return;
                }
                if (!$select.is(':visible')) {
                    return;
                }
                initOne(this);
            });
        },

        destroy: function (context) {
            var $root = context ? $(context) : $(document);
            $root.find('select.js-user-select-search.select2-hidden-accessible').each(function () {
                $(this).off('select2:opening.iasUserSelect');
                $(this).select2('destroy');
            });
        },

        setValue: function (selectEl, value, silent) {
            if (!selectEl) {
                return;
            }
            var $el = $(selectEl);
            var val = value == null ? '' : String(value);
            var wasDisabled = selectEl.disabled;
            if (wasDisabled) {
                selectEl.disabled = false;
            }
            $el.val(val);
            if ($el.hasClass('select2-hidden-accessible')) {
                $el.trigger('change.select2');
                if (!silent) {
                    $el.trigger('change');
                }
            } else if (!silent) {
                $el.trigger('change');
            }
            if (wasDisabled) {
                selectEl.disabled = true;
                if ($el.hasClass('select2-hidden-accessible')) {
                    $el.trigger('change.select2');
                }
            }
        },

        setDisabled: function (selectEl, disabled) {
            if (!selectEl) {
                return;
            }
            var $el = $(selectEl);
            $el.prop('disabled', !!disabled);
            if ($el.hasClass('select2-hidden-accessible')) {
                $el.trigger('change.select2');
            }
        },

        getValue: function (selectEl) {
            return selectEl ? $(selectEl).val() : '';
        },

        closeAll: function (context) {
            var $root = context ? $(context) : $(document);
            $root.find('select.js-user-select-search.select2-hidden-accessible').each(function () {
                $(this).select2('close');
            });
        },
    };

    $(function () {
        window.IasUserSelect.init();
    });
}(window.jQuery));
