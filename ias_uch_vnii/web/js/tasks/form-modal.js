/**
 * JavaScript для модальной формы создания/редактирования заявки
 * Управление загрузкой и отображением файлов в AG Grid модальном окне
 */

$(document).ready(function() {
    var selectedFiles = [];
    
    /**
     * Функция для форматирования размера файла
     * @param {number} bytes - размер файла в байтах
     * @returns {string} - отформатированный размер
     */
    function formatFileSize(bytes) {
        if (bytes === 0) return '0 Bytes';
        var k = 1024;
        var sizes = ['Bytes', 'KB', 'MB', 'GB'];
        var i = Math.floor(Math.log(bytes) / Math.log(k));
        return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
    }
    
    /**
     * Функция для получения иконки файла по расширению
     * @param {string} fileName - имя файла
     * @returns {string} - CSS класс иконки
     */
    function getFileIcon(fileName) {
        var ext = fileName.split('.').pop().toLowerCase();
        var icons = {
            'pdf': 'fa fa-file-pdf',
            'doc': 'fa fa-file-word',
            'docx': 'fa fa-file-word',
            'xls': 'fa fa-file-excel',
            'xlsx': 'fa fa-file-excel',
            'txt': 'fa fa-file-alt',
            'jpg': 'fa fa-file-image',
            'jpeg': 'fa fa-file-image',
            'png': 'fa fa-file-image',
            'gif': 'fa fa-file-image',
            'bmp': 'fa fa-file-image'
        };
        return icons[ext] || 'fa fa-file';
    }
    
    /**
     * Функция для отображения списка выбранных файлов
     */
    function displayFilesList() {
        var listContainer = $('#files-list-container');
        listContainer.empty();
        
        if (selectedFiles.length === 0) {
            $('#selected-files-list').hide();
            $('.file-label').html('Выберите файлы для загрузки');
            $('.file-label').css('border-color', '#ced4da');
            return;
        }
        
        $('#selected-files-list').show();
        $('.file-label').html('<i class="glyphicon glyphicon-ok"></i> Выбрано файлов: ' + selectedFiles.length);
        $('.file-label').css('border-color', '#28a745');
        
        selectedFiles.forEach(function(file, index) {
            var fileItem = $('<li class="file-item"></li>');
            var fileName = $('<div class="file-item-name"><i class="' + getFileIcon(file.name) + '"></i>' + file.name + '</div>');
            var fileSize = $('<span class="file-item-size">' + formatFileSize(file.size) + '</span>');
            var removeBtn = $('<button type="button" class="remove-file-btn" data-index="' + index + '"><i class="glyphicon glyphicon-remove"></i></button>');
            
            fileItem.append(fileName);
            fileItem.append(fileSize);
            fileItem.append(removeBtn);
            listContainer.append(fileItem);
        });
    }
    
    /**
     * Обработка изменения input файлов
     */
    $(document).on('change', '#file-input-tasks', function(e) {
        selectedFiles = Array.from(this.files);
        displayFilesList();
    });
    
    /**
     * Удаление отдельного файла из списка
     */
    $(document).on('click', '.remove-file-btn', function() {
        var index = $(this).data('index');
        selectedFiles.splice(index, 1);
        
        // Обновляем input файлов через DataTransfer API
        var dataTransfer = new DataTransfer();
        selectedFiles.forEach(function(file) {
            dataTransfer.items.add(file);
        });
        document.getElementById('file-input-tasks').files = dataTransfer.files;
        
        displayFilesList();
    });
    
    /**
     * Очистка всех выбранных файлов
     */
    $(document).on('click', '.clear-files-btn', function() {
        selectedFiles = [];
        document.getElementById('file-input-tasks').value = '';
        displayFilesList();
    });
    
    /**
     * Анимация при отправке формы
     */
    $('#task-form').on('submit', function() {
        $('#submit-task-btn').html('<i class="glyphicon glyphicon-refresh glyphicon-spin"></i> Создание...');
        $('#submit-task-btn').prop('disabled', true).addClass('form-loading');
    });
});

