/**
 * Drag-and-drop и список файлов в формах создания заявки и внутренней задачи.
 */
(function($) {
    'use strict';

    var selectedFiles = [];
    var activeForm = null;

    function resolveActiveForm(formEl) {
        if (formEl) {
            return formEl;
        }
        if (activeForm) {
            return activeForm;
        }

        return document.getElementById('workTaskCreateForm')
            || document.getElementById('task-form');
    }

    function getFileContext(formEl) {
        var form = resolveActiveForm(formEl);
        if (!form) {
            return null;
        }

        return {
            form: form,
            dropZone: form.querySelector('[data-tasks-file-drop]'),
            input: form.querySelector('[data-tasks-file-input]'),
            filesList: form.querySelector('[data-tasks-files-list]'),
            listContainer: form.querySelector('[data-tasks-files-container]'),
        };
    }

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

    function syncInputFiles(ctx) {
        var input = ctx && ctx.input;
        if (!input || typeof DataTransfer === 'undefined') {
            return;
        }
        var dt = new DataTransfer();
        selectedFiles.forEach(function(file) {
            dt.items.add(file);
        });
        input.files = dt.files;
    }

    function displayFilesList(ctx) {
        if (!ctx || !ctx.listContainer) {
            return;
        }

        var $listContainer = $(ctx.listContainer);
        var $filesList = ctx.filesList ? $(ctx.filesList) : $();
        $listContainer.empty();

        if (selectedFiles.length === 0) {
            $filesList.prop('hidden', true);
            if (ctx.dropZone) {
                ctx.dropZone.classList.remove('is-filled');
            }
            return;
        }

        $filesList.prop('hidden', false);
        if (ctx.dropZone) {
            ctx.dropZone.classList.add('is-filled');
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
            $listContainer.append($item);
        });
    }

    function addFiles(fileList, ctx) {
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
        syncInputFiles(ctx);
        displayFilesList(ctx);
    }

    function initDropZone(ctx) {
        var dropZone = ctx && ctx.dropZone;
        var input = ctx && ctx.input;
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
            addFiles(this.files, ctx);
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
            addFiles(e.dataTransfer && e.dataTransfer.files, ctx);
        });
    }

    $(document).on('click', '.tasks-files-list__item-remove', function() {
        var index = $(this).data('index');
        selectedFiles.splice(index, 1);
        var ctx = getFileContext();
        syncInputFiles(ctx);
        displayFilesList(ctx);
    });

    $(document).on('click', '.clear-files-btn', function() {
        var ctx = getFileContext();
        if (!ctx || !ctx.form.contains(this)) {
            return;
        }
        selectedFiles = [];
        if (ctx.input) {
            ctx.input.value = '';
        }
        displayFilesList(ctx);
    });

    $(document).on('submit', '#task-form', function() {
        var $btn = $('#submit-task-btn');
        $btn.html('<i class="fas fa-spinner fa-spin" aria-hidden="true"></i> Отправка…');
        $btn.prop('disabled', true).addClass('form-loading');
    });

    window.tasksCreateFormInit = function(formEl) {
        activeForm = resolveActiveForm(formEl);
        var ctx = getFileContext(formEl);
        selectedFiles = [];

        if (ctx && ctx.input) {
            ctx.input.value = '';
        }
        if (ctx && ctx.dropZone) {
            delete ctx.dropZone.dataset.fileDropBound;
        }

        displayFilesList(ctx);
        initDropZone(ctx);
    };
})(jQuery);
