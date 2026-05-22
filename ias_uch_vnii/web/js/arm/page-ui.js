/**
 * Оболочка страницы «Учёт ТС» (поиск, вкладки, выбор строк) — без логики AG Grid.
 */
(function() {
    'use strict';

    function getSearchText() {
        var input = document.getElementById('armQuickFilter');
        return input ? input.value.trim() : '';
    }

    function updateSearchClearButton() {
        var btn = document.getElementById('armQuickFilterClear');
        if (!btn) {
            return;
        }
        btn.hidden = !getSearchText();
    }

    function updateSelectionBar() {
        var bar = document.getElementById('armSelectionBar');
        var countEl = document.getElementById('armSelectionCount');
        if (!bar) {
            return;
        }
        var api = window.armGridApi;
        var n = api && typeof api.getSelectedRows === 'function' ? api.getSelectedRows().length : 0;
        if (n > 0) {
            bar.classList.add('is-visible');
            if (countEl) {
                countEl.textContent = String(n);
            }
        } else {
            bar.classList.remove('is-visible');
        }
    }

    window.armUpdatePageChrome = function() {
        updateSearchClearButton();
        updateSelectionBar();
    };

    function initPageChrome() {
        var clearSearch = document.getElementById('armQuickFilterClear');
        if (clearSearch) {
            clearSearch.addEventListener('click', function() {
                var input = document.getElementById('armQuickFilter');
                if (input) {
                    input.value = '';
                    input.dispatchEvent(new Event('input', { bubbles: true }));
                    input.focus();
                }
            });
        }

        var clearSelection = document.getElementById('armSelectionClear');
        if (clearSelection) {
            clearSelection.addEventListener('click', function() {
                var api = window.armGridApi;
                if (api && typeof api.deselectAll === 'function') {
                    api.deselectAll();
                }
                if (typeof window.armUpdatePageChrome === 'function') {
                    window.armUpdatePageChrome();
                }
            });
        }

        var selectionReassign = document.getElementById('armSelectionReassign');
        if (selectionReassign) {
            selectionReassign.addEventListener('click', function() {
                var api = window.armGridApi;
                var rows = api && typeof api.getSelectedRows === 'function' ? api.getSelectedRows() : [];
                if (rows.length === 0) {
                    alert('Выберите одну или несколько единиц техники в таблице (отметьте чекбоксы слева от строк).');
                    return;
                }
                var ids = rows.map(function(r) { return r.id; });
                if (typeof window.openReassignModal === 'function') {
                    window.openReassignModal(ids);
                }
            });
        }

        window.armUpdatePageChrome();
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initPageChrome);
    } else {
        initPageChrome();
    }
})();
