/**
 * JavaScript для форм создания и редактирования заявок
 * Функциональность загрузки файлов и валидации
 */

$(document).ready(function() {
    // Инициализация
    initTasksForm();
    
    function initTasksForm() {
        initFileUpload();
        initFormValidation();
        initAutoSave();
    }
    
    // Инициализация загрузки файлов
    function initFileUpload() {
        var $fileInput = $('#tasks-uploadfiles');
        var $uploadArea = $('.file-upload-area');
        var $uploadedFiles = $('.uploaded-files');
        var $progressBar = $('.upload-progress');
        
        if ($fileInput.length && $uploadArea.length) {
            // Обработчик клика по области загрузки
            $uploadArea.on('click', function() {
                $fileInput.click();
            });
            
            // Обработчик изменения файлов
            $fileInput.on('change', function() {
                handleFileSelection(this.files);
            });
            
            // Обработчики drag & drop
            $uploadArea.on('dragover', function(e) {
                e.preventDefault();
                $(this).addClass('dragover');
            });
            
            $uploadArea.on('dragleave', function(e) {
                e.preventDefault();
                $(this).removeClass('dragover');
            });
            
            $uploadArea.on('drop', function(e) {
                e.preventDefault();
                $(this).removeClass('dragover');
                handleFileSelection(e.originalEvent.dataTransfer.files);
            });
        }
    }
    
    // Обработка выбранных файлов
    function handleFileSelection(files) {
        var $uploadedFiles = $('.uploaded-files');
        var $progressBar = $('.upload-progress');
        
        if (files.length === 0) return;
        
        // Показываем прогресс-бар
        $progressBar.show();
        
        // Обрабатываем каждый файл
        Array.from(files).forEach(function(file, index) {
            if (validateFile(file)) {
                addFileToList(file);
            }
        });
        
        // Скрываем прогресс-бар
        setTimeout(function() {
            $progressBar.hide();
        }, 1000);
    }
    
    // Валидация файла
    function validateFile(file) {
        var maxSize = 10 * 1024 * 1024; // 10MB
        var allowedTypes = [
            'image/jpeg', 'image/png', 'image/gif', 'image/webp',
            'application/pdf', 'application/msword', 
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            'text/plain', 'application/zip', 'application/x-rar-compressed'
        ];
        
        if (file.size > maxSize) {
            showNotification('Файл "' + file.name + '" слишком большой. Максимальный размер: 10MB', 'error');
            return false;
        }
        
        if (!allowedTypes.includes(file.type)) {
            showNotification('Тип файла "' + file.name + '" не поддерживается', 'error');
            return false;
        }
        
        return true;
    }
    
    // Добавление файла в список
    function addFileToList(file) {
        var $uploadedFiles = $('.uploaded-files');
        var fileId = 'file_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
        
        var fileItem = $('<div class="uploaded-file-item" data-file-id="' + fileId + '">' +
            '<i class="fa fa-file-o uploaded-file-icon"></i>' +
            '<span class="uploaded-file-name">' + escapeHtml(file.name) + '</span>' +
            '<span class="uploaded-file-size">' + formatFileSize(file.size) + '</span>' +
            '<i class="fa fa-times uploaded-file-remove" title="Удалить файл"></i>' +
            '</div>');
        
        $uploadedFiles.append(fileItem);
        
        // Обработчик удаления файла
        fileItem.find('.uploaded-file-remove').on('click', function() {
            fileItem.remove();
        });
        
        // Сохраняем файл в скрытом поле
        var $hiddenInput = $('<input type="hidden" name="Tasks[uploadFiles][]" value="' + fileId + '">');
        $hiddenInput.data('file', file);
        $uploadedFiles.append($hiddenInput);
    }
    
    // Инициализация валидации формы
    function initFormValidation() {
        var $form = $('form');
        
        if ($form.length) {
            $form.on('submit', function(e) {
                if (!validateForm()) {
                    e.preventDefault();
                    return false;
                }
            });
            
            // Валидация в реальном времени
            $form.find('input, textarea, select').on('blur', function() {
                validateField($(this));
            });
        }
    }
    
    // Валидация формы
    function validateForm() {
        var isValid = true;
        var $form = $('form');
        
        // Проверяем обязательные поля
        $form.find('[required]').each(function() {
            if (!validateField($(this))) {
                isValid = false;
            }
        });
        
        return isValid;
    }
    
    // Валидация отдельного поля
    function validateField($field) {
        var value = $field.val().trim();
        var isValid = true;
        var $group = $field.closest('.form-group');
        
        // Убираем предыдущие ошибки
        $group.removeClass('has-error');
        $group.find('.help-block').remove();
        
        // Проверяем обязательность
        if ($field.prop('required') && !value) {
            showFieldError($group, 'Это поле обязательно для заполнения');
            isValid = false;
        }
        
        // Проверяем email
        if ($field.attr('type') === 'email' && value) {
            var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(value)) {
                showFieldError($group, 'Введите корректный email адрес');
                isValid = false;
            }
        }
        
        // Проверяем длину текста
        var maxLength = $field.attr('maxlength');
        if (maxLength && value.length > parseInt(maxLength)) {
            showFieldError($group, 'Максимальная длина: ' + maxLength + ' символов');
            isValid = false;
        }
        
        return isValid;
    }
    
    // Показать ошибку поля
    function showFieldError($group, message) {
        $group.addClass('has-error');
        $group.append('<div class="help-block">' + message + '</div>');
    }
    
    // Автосохранение черновика
    function initAutoSave() {
        var $form = $('form');
        var autoSaveInterval = 30000; // 30 секунд
        var lastSaveTime = 0;
        
        if ($form.length) {
            setInterval(function() {
                var currentTime = Date.now();
                if (currentTime - lastSaveTime > autoSaveInterval) {
                    saveDraft();
                    lastSaveTime = currentTime;
                }
            }, autoSaveInterval);
            
            // Сохраняем при изменении полей
            $form.find('input, textarea, select').on('change', function() {
                setTimeout(saveDraft, 2000); // Задержка 2 секунды
            });
        }
    }
    
    // Сохранение черновика
    function saveDraft() {
        var $form = $('form');
        var formData = $form.serialize();
        
        // Отправляем AJAX запрос для сохранения черновика
        $.post($form.attr('action') + '?draft=1', formData)
            .done(function(data) {
                if (data.success) {
                    console.log('Черновик сохранен');
                }
            })
            .fail(function() {
                console.log('Ошибка сохранения черновика');
            });
    }
    
    // Вспомогательные функции
    function escapeHtml(text) {
        var map = {
            '&': '&amp;',
            '<': '&lt;',
            '>': '&gt;',
            '"': '&quot;',
            "'": '&#039;'
        };
        return text.replace(/[&<>"']/g, function(m) { return map[m]; });
    }
    
    function formatFileSize(bytes) {
        if (bytes === 0) return '0 Bytes';
        var k = 1024;
        var sizes = ['Bytes', 'KB', 'MB', 'GB'];
        var i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
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
