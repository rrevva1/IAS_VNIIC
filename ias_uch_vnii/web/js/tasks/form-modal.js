/**
 * Модальная форма создания заявки
 */
(function($) {
    'use strict';

    var selectedFiles = [];

    function formatFileSize(bytes) {
        if (bytes === 0) {
            return '0 Б';
        }
        var k = 1024;
        var sizes = ['Б', 'КБ', 'МБ', 'ГБ'];
        var i = Math.floor(Math.log(bytes) / Math.log(k));
        return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
    }

    function getFileIcon(fileName) {
        var ext = fileName.split('.').pop().toLowerCase();
        var icons = {
            pdf: 'fa-file-pdf',
            doc: 'fa-file-word',
            docx: 'fa-file-word',
            xls: 'fa-file-excel',
            xlsx: 'fa-file-excel',
            txt: 'fa-file-lines',
            jpg: 'fa-file-image',
            jpeg: 'fa-file-image',
            png: 'fa-file-image',
            gif: 'fa-file-image',
            bmp: 'fa-file-image',
        };
        return icons[ext] || 'fa-file';
    }

    function getFileInput() {
        return document.getElementById('file-input-tasks');
    }

    function getDropZone() {
        return document.getElementById('tasks-file-drop');
    }

    function syncInputFiles() {
        var input = getFileInput();
        if (!input || typeof DataTransfer === 'undefined') {
            return;
        }
        var dt = new DataTransfer();
        selectedFiles.forEach(function(file) {
            dt.items.add(file);
        });
        input.files = dt.files;
    }

    function displayFilesList() {
        var listContainer = $('#files-list-container');
        var dropZone = getDropZone();
        listContainer.empty();

        if (selectedFiles.length === 0) {
            $('#selected-files-list').prop('hidden', true);
            if (dropZone) {
                dropZone.classList.remove('is-filled');
            }
            return;
        }

        $('#selected-files-list').prop('hidden', false);
        if (dropZone) {
            dropZone.classList.add('is-filled');
        }

        selectedFiles.forEach(function(file, index) {
            var $item = $('<li class="tasks-files-list__item"></li>');
            var $name = $('<div class="tasks-files-list__item-name"></div>')
                .append($('<i class="fas ' + getFileIcon(file.name) + '" aria-hidden="true"></i>'))
                .append($('<span></span>').text(file.name));
            var $size = $('<span class="tasks-files-list__item-size"></span>').text(formatFileSize(file.size));
            var $remove = $('<button type="button" class="tasks-files-list__item-remove" aria-label="Удалить файл"></button>')
                .append('<i class="fas fa-xmark" aria-hidden="true"></i>')
                .data('index', index);

            $item.append($name, $size, $remove);
            listContainer.append($item);
        });
    }

    function addFiles(fileList) {
        if (!fileList || !fileList.length) {
            return;
        }
        Array.from(fileList).forEach(function(file) {
            var exists = selectedFiles.some(function(f) {
                return f.name === file.name && f.size === file.size && f.lastModified === file.lastModified;
            });
            if (!exists) {
                selectedFiles.push(file);
            }
        });
        syncInputFiles();
        displayFilesList();
    }

    function initDropZone() {
        var dropZone = getDropZone();
        var input = getFileInput();
        if (!dropZone || !input) {
            return;
        }

        if (dropZone.dataset.fileDropBound === '1') {
            return;
        }
        dropZone.dataset.fileDropBound = '1';

        dropZone.addEventListener('click', function(e) {
            if (e.target.closest('.tasks-files-list__item-remove, .clear-files-btn')) {
                return;
            }
            if (e.target === input) {
                return;
            }
            e.preventDefault();
            input.click();
        });

        dropZone.addEventListener('keydown', function(e) {
            if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                input.click();
            }
        });

        input.addEventListener('change', function() {
            addFiles(this.files);
            this.value = '';
        });

        ['dragenter', 'dragover'].forEach(function(evt) {
            dropZone.addEventListener(evt, function(e) {
                e.preventDefault();
                e.stopPropagation();
                dropZone.classList.add('is-dragover');
            });
        });

        ['dragleave', 'drop'].forEach(function(evt) {
            dropZone.addEventListener(evt, function(e) {
                e.preventDefault();
                e.stopPropagation();
                dropZone.classList.remove('is-dragover');
            });
        });

        dropZone.addEventListener('drop', function(e) {
            addFiles(e.dataTransfer && e.dataTransfer.files);
        });
    }

    $(document).on('click', '.tasks-files-list__item-remove', function() {
        var index = $(this).data('index');
        selectedFiles.splice(index, 1);
        syncInputFiles();
        displayFilesList();
    });

    $(document).on('click', '.clear-files-btn', function() {
        selectedFiles = [];
        var input = getFileInput();
        if (input) {
            input.value = '';
        }
        displayFilesList();
    });

    $(document).on('submit', '#task-form', function() {
        var $btn = $('#submit-task-btn');
        $btn.html('<i class="fas fa-spinner fa-spin" aria-hidden="true"></i> Отправка…');
        $btn.prop('disabled', true).addClass('form-loading');
    });

    window.tasksCreateFormInit = function() {
        selectedFiles = [];
        var input = getFileInput();
        if (input) {
            input.value = '';
        }
        var dropZone = getDropZone();
        if (dropZone) {
            delete dropZone.dataset.fileDropBound;
        }
        displayFilesList();
        initDropZone();
    };
})(jQuery);
