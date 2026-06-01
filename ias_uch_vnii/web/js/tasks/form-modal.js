/**
 * Drag-and-drop и список файлов в формах создания заявки и внутренней задачи.
 */
(function($) {
    'use strict';

    /** @type {WeakMap<HTMLFormElement, File[]>} */
    var filesByForm = new WeakMap();
    var activeForm = null;

    function isFormInDocument(form) {
        return form && document.body.contains(form);
    }

    function resolveCreateForm(formEl) {
        if (formEl) {
            return formEl;
        }
        if (isFormInDocument(activeForm)) {
            return activeForm;
        }
        activeForm = null;

        var createBody = document.getElementById('createTaskModalBody');
        if (createBody) {
            var createForm = createBody.querySelector('form#task-form');
            if (createForm) {
                return createForm;
            }
        }

        var editBody = document.getElementById('editTaskModalBody');
        if (editBody) {
            var editForm = editBody.querySelector('form#task-form');
            if (editForm) {
                return editForm;
            }
        }

        return document.getElementById('workTaskCreateForm')
            || document.getElementById('task-form');
    }

    function getFilesForForm(form) {
        if (!form) {
            return [];
        }
        if (!filesByForm.has(form)) {
            filesByForm.set(form, []);
        }
        return filesByForm.get(form);
    }

    function setFilesForForm(form, files) {
        if (!form) {
            return;
        }
        filesByForm.set(form, files);
    }

    function getFileContext(formEl) {
        var form = resolveCreateForm(formEl);
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
        var form = ctx && ctx.form;
        if (!input || !form || typeof DataTransfer === 'undefined') {
            return;
        }
        var selectedFiles = getFilesForForm(form);
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

        var selectedFiles = getFilesForForm(ctx.form);
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
        if (!fileList || !fileList.length || !ctx || !ctx.form) {
            return;
        }
        var selectedFiles = getFilesForForm(ctx.form);
        Array.from(fileList).forEach(function(file) {
            var exists = selectedFiles.some(function(f) {
                return f.name === file.name && f.size === file.size && f.lastModified === file.lastModified;
            });
            if (!exists) {
                selectedFiles.push(file);
            }
        });
        setFilesForForm(ctx.form, selectedFiles);
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
        var form = this.closest('form');
        if (!form) {
            return;
        }
        var index = $(this).data('index');
        var selectedFiles = getFilesForForm(form);
        selectedFiles.splice(index, 1);
        setFilesForForm(form, selectedFiles);
        var ctx = getFileContext(form);
        syncInputFiles(ctx);
        displayFilesList(ctx);
    });

    $(document).on('click', '.clear-files-btn', function() {
        var form = this.closest('form');
        var ctx = getFileContext(form);
        if (!ctx || !ctx.form.contains(this)) {
            return;
        }
        setFilesForForm(ctx.form, []);
        if (ctx.input) {
            ctx.input.value = '';
        }
        displayFilesList(ctx);
    });

    $(document).on('submit', '#task-form', function() {
        if (typeof window.tasksFormPrepareSubmit === 'function') {
            window.tasksFormPrepareSubmit(this);
        }
        var $btn = $(this).find('#submit-task-btn');
        if (!$btn.length) {
            $btn = $('#submit-task-btn');
        }
        $btn.html('<i class="fas fa-spinner fa-spin" aria-hidden="true"></i> Отправка…');
        $btn.prop('disabled', true).addClass('form-loading');
    });

    window.tasksCreateFormInit = function(formEl) {
        var form = resolveCreateForm(formEl);
        if (!form) {
            return;
        }
        activeForm = form;

        setFilesForForm(form, []);
        var ctx = getFileContext(form);

        if (ctx && ctx.input) {
            ctx.input.value = '';
        }
        if (ctx && ctx.dropZone) {
            delete ctx.dropZone.dataset.fileDropBound;
        }

        displayFilesList(ctx);
        initDropZone(ctx);
    };

    /** Перед AJAX-отправкой формы — перенос выбранных файлов в input[type=file]. */
    window.tasksFormPrepareSubmit = function(formEl) {
        var ctx = getFileContext(formEl);
        if (!ctx) {
            return;
        }
        syncInputFiles(ctx);
    };
})(jQuery);
