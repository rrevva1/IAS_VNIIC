/**
 * JavaScript для страницы списка заявок
 * Функциональность фильтрации, поиска и массовых операций
 */

$(document).ready(function() {
    // Инициализация
    initTasksIndex();
    
    function initTasksIndex() {
        initFilters();
        initSearch();
        initBulkActions();
        initTableSorting();
        initRefreshButton();
    }
    
    // Инициализация фильтров
    function initFilters() {
        var $filterForm = $('#filter-form');
        var $filterInputs = $filterForm.find('input, select');
        
        if ($filterForm.length) {
            // Автоматическая отправка формы при изменении фильтров
            $filterInputs.on('change', function() {
                $filterForm.submit();
            });
            
            // Обработчик кнопки "Сбросить"
            $filterForm.find('.btn-reset').on('click', function(e) {
                e.preventDefault();
                resetFilters();
            });
            
            // Обработчик кнопки "Применить"
            $filterForm.find('.btn-apply').on('click', function(e) {
                e.preventDefault();
                applyFilters();
            });
        }
    }
    
    // Сброс фильтров
    function resetFilters() {
        var $filterForm = $('#filter-form');
        $filterForm.find('input[type="text"]').val('');
        $filterForm.find('select').prop('selectedIndex', 0);
        $filterForm.find('input[type="date"]').val('');
        $filterForm.submit();
    }
    
    // Применение фильтров
    function applyFilters() {
        var $filterForm = $('#filter-form');
        $filterForm.submit();
    }
    
    // Инициализация поиска
    function initSearch() {
        var $searchInput = $('#search-input');
        var searchTimeout;
        
        if ($searchInput.length) {
            $searchInput.on('input', function() {
                clearTimeout(searchTimeout);
                var query = $(this).val();
                
                searchTimeout = setTimeout(function() {
                    performSearch(query);
                }, 500); // Задержка 500мс
            });
            
            // Обработчик кнопки поиска
            $('.btn-search').on('click', function() {
                var query = $searchInput.val();
                performSearch(query);
            });
        }
    }
    
    // Выполнение поиска
    function performSearch(query) {
        var $filterForm = $('#filter-form');
        var $searchField = $filterForm.find('input[name*="search"]');
        
        if ($searchField.length) {
            $searchField.val(query);
        } else {
            $filterForm.append('<input type="hidden" name="search" value="' + encodeURIComponent(query) + '">');
        }
        
        $filterForm.submit();
    }
    
    // Инициализация массовых операций
    function initBulkActions() {
        var $selectAllCheckbox = $('#select-all');
        var $itemCheckboxes = $('.item-checkbox');
        var $bulkActions = $('.bulk-actions');
        
        if ($selectAllCheckbox.length && $itemCheckboxes.length) {
            // Обработчик "Выбрать все"
            $selectAllCheckbox.on('change', function() {
                var isChecked = $(this).is(':checked');
                $itemCheckboxes.prop('checked', isChecked);
                updateBulkActions();
            });
            
            // Обработчики отдельных чекбоксов
            $itemCheckboxes.on('change', function() {
                updateSelectAllState();
                updateBulkActions();
            });
            
            // Обработчики кнопок массовых операций
            $bulkActions.find('.btn-bulk-action').on('click', function(e) {
                e.preventDefault();
                var action = $(this).data('action');
                performBulkAction(action);
            });
        }
    }
    
    // Обновление состояния "Выбрать все"
    function updateSelectAllState() {
        var $selectAllCheckbox = $('#select-all');
        var $itemCheckboxes = $('.item-checkbox');
        var checkedCount = $itemCheckboxes.filter(':checked').length;
        var totalCount = $itemCheckboxes.length;
        
        if (checkedCount === 0) {
            $selectAllCheckbox.prop('indeterminate', false).prop('checked', false);
        } else if (checkedCount === totalCount) {
            $selectAllCheckbox.prop('indeterminate', false).prop('checked', true);
        } else {
            $selectAllCheckbox.prop('indeterminate', true);
        }
    }
    
    // Обновление видимости кнопок массовых операций
    function updateBulkActions() {
        var $bulkActions = $('.bulk-actions');
        var checkedCount = $('.item-checkbox:checked').length;
        
        if (checkedCount > 0) {
            $bulkActions.show();
            $bulkActions.find('.selected-count').text(checkedCount);
        } else {
            $bulkActions.hide();
        }
    }
    
    // Выполнение массовых операций
    function performBulkAction(action) {
        var selectedIds = [];
        $('.item-checkbox:checked').each(function() {
            selectedIds.push($(this).val());
        });
        
        if (selectedIds.length === 0) {
            showNotification('Выберите элементы для выполнения операции', 'warning');
            return;
        }
        
        var actionText = getActionText(action);
        if (!confirm('Вы уверены, что хотите ' + actionText + ' выбранные элементы?')) {
            return;
        }
        
        // Показываем индикатор загрузки
        showLoading();
        
        $.post(window.location.href, {
            bulk_action: action,
            selected_ids: selectedIds
        })
        .done(function(data) {
            if (data.success) {
                showNotification('Операция выполнена успешно', 'success');
                setTimeout(function() {
                    location.reload();
                }, 1000);
            } else {
                showNotification('Ошибка: ' + (data.message || 'Неизвестная ошибка'), 'error');
            }
        })
        .fail(function() {
            showNotification('Ошибка соединения с сервером', 'error');
        })
        .always(function() {
            hideLoading();
        });
    }
    
    // Получение текста действия
    function getActionText(action) {
        var actions = {
            'delete': 'удалить',
            'activate': 'активировать',
            'deactivate': 'деактивировать',
            'export': 'экспортировать'
        };
        return actions[action] || action;
    }
    
    // Инициализация сортировки таблицы
    function initTableSorting() {
        var $sortableHeaders = $('.table th[data-sort]');
        
        $sortableHeaders.on('click', function() {
            var sortField = $(this).data('sort');
            var currentSort = getUrlParameter('sort');
            var currentOrder = getUrlParameter('order');
            
            var newOrder = 'asc';
            if (currentSort === sortField && currentOrder === 'asc') {
                newOrder = 'desc';
            }
            
            var url = updateUrlParameter(window.location.href, 'sort', sortField);
            url = updateUrlParameter(url, 'order', newOrder);
            
            window.location.href = url;
        });
        
        // Добавляем индикаторы сортировки
        var currentSort = getUrlParameter('sort');
        var currentOrder = getUrlParameter('order');
        
        if (currentSort) {
            var $header = $('.table th[data-sort="' + currentSort + '"]');
            var icon = currentOrder === 'desc' ? 'fa-sort-desc' : 'fa-sort-asc';
            $header.append(' <i class="fa ' + icon + '"></i>');
        }
    }
    
    // Инициализация кнопки обновления
    function initRefreshButton() {
        $('.btn-refresh').on('click', function(e) {
            e.preventDefault();
            location.reload();
        });
    }
    
    // Вспомогательные функции
    function getUrlParameter(name) {
        var urlParams = new URLSearchParams(window.location.search);
        return urlParams.get(name);
    }
    
    function updateUrlParameter(url, param, paramVal) {
        var newAdditionalURL = "";
        var tempArray = url.split("?");
        var baseURL = tempArray[0];
        var additionalURL = tempArray[1];
        var temp = "";
        
        if (additionalURL) {
            tempArray = additionalURL.split("&");
            for (var i = 0; i < tempArray.length; i++) {
                if (tempArray[i].split('=')[0] != param) {
                    newAdditionalURL += temp + tempArray[i];
                    temp = "&";
                }
            }
        }
        
        var rows_txt = temp + "" + param + "=" + paramVal;
        return baseURL + "?" + newAdditionalURL + rows_txt;
    }
    
    function showLoading() {
        $('body').addClass('loading');
        $('.loading-overlay').show();
    }
    
    function hideLoading() {
        $('body').removeClass('loading');
        $('.loading-overlay').hide();
    }
    
    // Функция для показа уведомлений
    function showNotification(message, type) {
        type = type || 'info';
        
        var alertClass = 'alert-info';
        switch(type) {
            case 'success':
                alertClass = 'alert-success';
                break;
            case 'error':
                alertClass = 'alert-danger';
                break;
            case 'warning':
                alertClass = 'alert-warning';
                break;
        }
        
        var $notification = $('<div class="alert ' + alertClass + ' alert-dismissible fade show" role="alert" style="position: fixed; top: 20px; right: 20px; z-index: 9999; min-width: 300px;">' +
            '<button type="button" class="close" data-dismiss="alert" aria-label="Close">' +
            '<span aria-hidden="true">&times;</span>' +
            '</button>' +
            message +
            '</div>');
        
        $('body').append($notification);
        
        // Автоматически скрываем уведомление через 5 секунд
        setTimeout(function() {
            $notification.alert('close');
        }, 5000);
    }
});
