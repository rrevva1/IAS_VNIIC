/**
 * JavaScript для карточки просмотра заявки (страница и модальное окно).
 */

window.initTasksViewPage = function(context) {
    var $root = context ? $(context) : $(document);
    initExecutorChange($root);
    initExecutorCommentEdit($root);
    initImageModal($root);
    initAttachmentCards($root);
};

$(document).ready(function() {
    if ($('#tasksViewRoot').length) {
        window.initTasksViewPage();
    }
});

function initExecutorCommentEdit($root) {
    var $block = $root.find('.tasks-view-executor-comment');
    if (!$block.length) {
        return;
    }

    var $textarea = $block.find('.tasks-view-executor-comment__input');
    var $btn = $block.find('[data-task-save-comment]');
    var $status = $block.find('.tasks-view-executor-comment__status');
    var url = $block.data('updateUrl');
    if (!url || !$textarea.length || !$btn.length) {
        return;
    }

    function setStatus(text, isError) {
        $status
            .text(text || '')
            .toggleClass('text-danger', !!isError)
            .toggleClass('text-success', !!(text && !isError));
    }

    function saveComment() {
        $btn.prop('disabled', true);
        setStatus('Сохранение…', false);

        var postData = { comment: $textarea.val() };
        if (typeof yii !== 'undefined' && typeof yii.getCsrfParam === 'function') {
            postData[yii.getCsrfParam()] = yii.getCsrfToken();
        }

        $.post(url, postData)
            .done(function(data) {
                if (data && data.success) {
                    setStatus('Сохранено', false);
                    showTasksViewNotification(data.message || 'Комментарий сохранён', 'success');
                    if (typeof window.refreshGrid === 'function') {
                        window.refreshGrid();
                    }
                } else {
                    setStatus('', false);
                    showTasksViewNotification((data && data.message) || 'Не удалось сохранить комментарий', 'error');
                }
            })
            .fail(function() {
                setStatus('', false);
                showTasksViewNotification('Ошибка соединения с сервером', 'error');
            })
            .always(function() {
                $btn.prop('disabled', false);
            });
    }

    $btn.off('click.tasksViewComment').on('click.tasksViewComment', function() {
        saveComment();
    });

    $textarea.off('keydown.tasksViewComment').on('keydown.tasksViewComment', function(e) {
        if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
            e.preventDefault();
            saveComment();
        }
    });
}

function initExecutorChange($root) {
    var $select = $root.find('#executor-change');
    if (!$select.length) {
        return;
    }

    $select.off('change.tasksViewExecutor').on('change.tasksViewExecutor', function() {
        var executorId = $(this).val();
        if (!executorId) {
            return;
        }

        var url = window.executorChangeUrl;
        var $container = $(this).closest('#tasksViewRoot');
        if ($container.length && $container.data('executorChangeUrl')) {
            url = $container.data('executorChangeUrl');
        }
        if (!url) {
            return;
        }

        $select.prop('disabled', true);
        var originalValue = $select.val();

        $.post(url, {
            executor_id: executorId,
        })
            .done(function(data) {
                if (data.success) {
                    showTasksViewNotification('Исполнитель успешно назначен', 'success');
                    if (window.TasksView && typeof window.TasksView.reload === 'function' && window.TasksView.isOpen()) {
                        window.TasksView.reload();
                    } else {
                        setTimeout(function() {
                            location.reload();
                        }, 1000);
                    }
                } else {
                    showTasksViewNotification('Ошибка: ' + (data.message || 'Неизвестная ошибка'), 'error');
                    $select.val(originalValue);
                }
            })
            .fail(function() {
                showTasksViewNotification('Ошибка соединения с сервером', 'error');
                $select.val(originalValue);
            })
            .always(function() {
                $select.prop('disabled', false);
            });
    });
}

function initImageModal($root) {
    $root.find('[data-bs-toggle="modal"][data-bs-target="#imageModal"]').off('click.tasksViewImage').on('click.tasksViewImage', function(event) {
        event.preventDefault();
        var $trigger = $(this);
        var imageSrc = $trigger.data('image-src');
        var imageName = $trigger.data('image-name');

        var $modal = $('#imageModal');
        if (!$modal.length) {
            return;
        }
        var $modalImage = $modal.find('#modalImage');
        var $modalImageName = $modal.find('#modalImageName');
        var $modalDownloadBtn = $modal.find('#modalDownloadBtn');

        $modalImage.attr('src', '');
        $modalImageName.text('Загрузка...');

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

        var downloadLink = $('a[href*="download-attachment"]').filter(function() {
            return $(this).attr('href').indexOf(String(imageSrc).split('/').pop().split('_')[0]) !== -1;
        }).first().attr('href');

        if (downloadLink) {
            $modalDownloadBtn.attr('href', downloadLink);
        }

        var imageModal = bootstrap.Modal.getOrCreateInstance($modal[0]);
        imageModal.show();
    });
}

function initAttachmentCards($root) {
    $root.find('.attachment-card').hover(
        function() {
            $(this).addClass('hover-effect');
        },
        function() {
            $(this).removeClass('hover-effect');
        }
    );

    $root.find('.attachment-card img').off('click.tasksViewAttach').on('click.tasksViewAttach', function() {
        var $card = $(this).closest('.attachment-card');
        var $viewBtn = $card.find('button[data-bs-toggle="modal"]');
        if ($viewBtn.length) {
            $viewBtn.trigger('click');
        }
    });
}

function showTasksViewNotification(message, type) {
    type = type || 'info';

    var alertClass = 'alert-info';
    switch (type) {
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

    var $notification = $('<div class="alert ' + alertClass + ' alert-dismissible fade show" role="alert" style="position: fixed; top: 20px; right: 20px; z-index: 10060; min-width: 300px;">' +
        '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Закрыть"></button>' +
        message +
        '</div>');

    $('body').append($notification);

    setTimeout(function() {
        $notification.alert('close');
    }, 5000);
}
