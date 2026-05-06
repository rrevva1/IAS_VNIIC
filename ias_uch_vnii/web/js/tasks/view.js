/**
 * JavaScript для страницы просмотра заявки
 * Функциональность быстрого изменения статуса и исполнителя
 */

$(document).ready(function() {
    // Инициализация
    initTasksView();
    
    function initTasksView() {
        initStatusChange();
        initExecutorChange();
        initImageModal();
        initAttachmentCards();
    }
    
    // Обработчик изменения статуса
    function initStatusChange() {
        $('#status-change').on('change', function() {
            var statusId = $(this).val();
            var $select = $(this);
            
            if (statusId) {
                // Показываем индикатор загрузки
                $select.prop('disabled', true);
                var originalValue = $select.val();
                
                $.post(statusChangeUrl, {
                    status_id: statusId
                })
                .done(function(data) {
                    if (data.success) {
                        showNotification('Статус успешно изменен', 'success');
                        setTimeout(function() {
                            location.reload();
                        }, 1000);
                    } else {
                        showNotification('Ошибка: ' + (data.message || 'Неизвестная ошибка'), 'error');
                        $select.val(originalValue);
                    }
                })
                .fail(function() {
                    showNotification('Ошибка соединения с сервером', 'error');
                    $select.val(originalValue);
                })
                .always(function() {
                    $select.prop('disabled', false);
                });
            }
        });
    }
    
    // Обработчик изменения исполнителя
    function initExecutorChange() {
        $('#executor-change').on('change', function() {
            var executorId = $(this).val();
            var $select = $(this);
            
            // Показываем индикатор загрузки
            $select.prop('disabled', true);
            var originalValue = $select.val();
            
            $.post(executorChangeUrl, {
                executor_id: executorId
            })
            .done(function(data) {
                if (data.success) {
                    showNotification('Исполнитель успешно назначен', 'success');
                    setTimeout(function() {
                        location.reload();
                    }, 1000);
                } else {
                    showNotification('Ошибка: ' + (data.message || 'Неизвестная ошибка'), 'error');
                    $select.val(originalValue);
                }
            })
            .fail(function() {
                showNotification('Ошибка соединения с сервером', 'error');
                $select.val(originalValue);
            })
            .always(function() {
                $select.prop('disabled', false);
            });
        });
    }

    // Обработчик для модального окна просмотра изображений
    function initImageModal() {
        // Обработка клика по элементам с модальным окном
        $(document).on('click', '[data-bs-toggle="modal"][data-bs-target="#imageModal"]', function (event) {
            event.preventDefault();
            var $trigger = $(this);
            var imageSrc = $trigger.data('image-src');
            var imageName = $trigger.data('image-name');
            
            var $modal = $('#imageModal');
            var $modalImage = $modal.find('#modalImage');
            var $modalImageName = $modal.find('#modalImageName');
            var $modalDownloadBtn = $modal.find('#modalDownloadBtn');
            
            // Показываем загрузку
            $modalImage.attr('src', '');
            $modalImageName.text('Загрузка...');
            
            // Загружаем изображение
            var img = new Image();
            img.onload = function() {
                $modalImage.attr('src', imageSrc);
                $modalImage.attr('alt', imageName);
                $modalImageName.text(imageName);
            };
            img.onerror = function() {
                $modalImage.attr('src', 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjIwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cmVjdCB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiBmaWxsPSIjZGRkIi8+PHRleHQgeD0iNTAlIiB5PSI1MCUiIGZvbnQtZmFtaWx5PSJBcmlhbCIgZm9udC1zaXplPSIxNCIgZmlsbD0iIzk5OSIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZHk9Ii4zZW0iPuKEliDQt9Cw0LrQsNC30LAg0L3QtSDQv9GA0L7QsdC10LvRjNC90L48L3RleHQ+PC9zdmc+');
                $modalImageName.text('Ошибка загрузки изображения');
            };
            img.src = imageSrc;
            
            // Находим ссылку на скачивание для этого файла
            var downloadLink = $('a[href*="download-attachment"]').filter(function() {
                return $(this).attr('href').includes(imageSrc.split('/').pop().split('_')[0]);
            }).first().attr('href');
            
            if (downloadLink) {
                $modalDownloadBtn.attr('href', downloadLink);
            }
            
            // Показываем модальное окно с использованием Bootstrap 5 API
            var imageModal = new bootstrap.Modal($modal[0]);
            imageModal.show();
        });
    }
    
    // Инициализация карточек вложений
    function initAttachmentCards() {
        // Добавляем эффекты при наведении
        $('.attachment-card').hover(
            function() {
                $(this).addClass('hover-effect');
            },
            function() {
                $(this).removeClass('hover-effect');
            }
        );
        
        // Обработчик клика по изображению для открытия модального окна
        $('.attachment-card img').on('click', function() {
            var $card = $(this).closest('.attachment-card');
            var $viewBtn = $card.find('button[data-bs-toggle="modal"]');
            if ($viewBtn.length) {
                $viewBtn.click();
            }
        });
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
    
    // Обработчик подтверждения удаления
    $('a[data-confirm]').on('click', function(e) {
        var message = $(this).data('confirm');
        if (!confirm(message)) {
            e.preventDefault();
            return false;
        }
    });
});
