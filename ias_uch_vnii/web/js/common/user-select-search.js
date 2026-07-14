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
        var isMultiple = !!$select.prop('multiple');
        var hasEmpty = $select.find('option[value=""]').length > 0;
        var opts = {
            language: RU,
            width: '100%',
            minimumResultsForSearch: 0,
            placeholder: resolvePlaceholder($select),
            allowClear: !isMultiple && hasEmpty,
            closeOnSelect: !isMultiple,
            dropdownParent: resolveDropdownParent($select),
            dropdownAutoWidth: false,
        };
        if ($select.hasClass('executor-change-ag')) {
            opts.dropdownCssClass = 'ias-user-select-dropdown--executor';
            opts.selectionCssClass = 'ias-user-select-selection--executor';
        }
        if ($select.closest('#createArmModal, #reassignArmModal, #issueKitModal').length) {
            opts.dropdownCssClass = (opts.dropdownCssClass ? opts.dropdownCssClass + ' ' : '') +
                'arm-modal-select2-dropdown';
            opts.selectionCssClass = (opts.selectionCssClass ? opts.selectionCssClass + ' ' : '') +
                'arm-modal-select2-selection';
        }
        return opts;
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
        $select.off('select2:opening.iasUserSelect select2:select.iasUserSelect select2:unselect.iasUserSelect select2:clear.iasUserSelect');
        $select.on('select2:opening.iasUserSelect', function () {
            closeOtherUserSelects(this);
        });
        $select.on('select2:select.iasUserSelect select2:unselect.iasUserSelect select2:clear.iasUserSelect', function () {
            var el = this;
            setTimeout(function () {
                dispatchNativeChange(el);
            }, 0);
        });
    }

    function getExecutorGridCellWidth($select) {
        var cell = $select.closest('#agGridTasksContainer .ag-cell.tasks-executor-cell')[0];
        if (!cell) {
            return 0;
        }
        return Math.max(0, Math.floor(cell.getBoundingClientRect().width) - 16);
    }

    function applyExecutorGridSelectWidth($select) {
        var $el = $select instanceof $ ? $select : $($select);
        if (!$el.length || !$el.hasClass('executor-change-ag')) {
            return;
        }
        if (!$el.closest('#agGridTasksContainer').length) {
            return;
        }
        var w = getExecutorGridCellWidth($el);
        if (w < 48) {
            return;
        }
        $el.closest('.tasks-executor-select-wrap').css({ width: '100%', display: 'block' });
        var $container = $el.next('.select2-container');
        if ($container.length) {
            $container.css({ width: w + 'px', maxWidth: '100%' });
        }
    }

    function resolveSelect2Width($select) {
        if ($select.hasClass('executor-change-ag') && $select.closest('#agGridTasksContainer').length) {
            var w = getExecutorGridCellWidth($select);
            if (w >= 48) {
                return w;
            }
        }
        return '100%';
    }

    function initOne(selectEl) {
        var $select = $(selectEl);
        if (!$select.length) {
            return;
        }
        if ($select.hasClass('executor-change-ag--grid')) {
            return;
        }
        if ($select.hasClass('select2-hidden-accessible')) {
            $select.select2('destroy');
        }
        if ($select.closest('.modal').length) {
            ensureBootstrapModalSelect2FocusFix();
        }
        var opts = buildOptions($select);
        opts.width = resolveSelect2Width($select);
        $select.select2(opts);
        bindSelect2Events($select);
        if ($select.hasClass('executor-change-ag') && $select.closest('#agGridTasksContainer').length) {
            applyExecutorGridSelectWidth($select);
            requestAnimationFrame(function() {
                applyExecutorGridSelectWidth($select);
            });
        }
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
                if ($select.hasClass('executor-change-ag--grid')) {
                    return;
                }
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

        syncExecutorGridWidthsIn: function (context) {
            var $root = context ? $(context) : $('#agGridTasksContainer');
            if (!$root.length) {
                return;
            }
            $root.find('select.executor-change-ag').each(function () {
                applyExecutorGridSelectWidth($(this));
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
