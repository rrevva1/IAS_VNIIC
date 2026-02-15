/**
 * AG Grid для страницы «Журнал аудита».
 * Данные из audit/get-grid-data; фильтры по дате, пользователю, типу операции, типу объекта.
 */
(function() {
    'use strict';

    var gridApi;

    function getColumnDefs() {
        return [
            { headerName: 'ID', field: 'id', width: 80, filter: 'agNumberColumnFilter', hide: true },
            { headerName: 'Время', field: 'event_time', width: 160, filter: 'agTextColumnFilter' },
            { headerName: 'Пользователь', field: 'actor_name', flex: 1, minWidth: 140, filter: 'agTextColumnFilter' },
            { headerName: 'Тип операции', field: 'action_type', width: 140, filter: 'agTextColumnFilter' },
            { headerName: 'Тип объекта', field: 'object_type', width: 110, filter: 'agTextColumnFilter' },
            { headerName: 'ID объекта', field: 'object_id', width: 100, filter: 'agTextColumnFilter' },
            { headerName: 'Результат', field: 'result_status', width: 100, filter: 'agTextColumnFilter' },
            { headerName: 'Доп. данные', field: 'payload', flex: 1, minWidth: 120, filter: 'agTextColumnFilter', tooltipField: 'payload', hide: true },
            { headerName: 'Ошибка', field: 'error_message', width: 180, filter: 'agTextColumnFilter', tooltipField: 'error_message', hide: true },
        ];
    }

    var localeTextRu = {
        page: 'Страница', to: 'до', of: 'из', next: 'След.', last: 'Последняя',
        first: 'Первая', previous: 'Пред.', loadingOoo: 'Загрузка...',
        noRowsToShow: 'Нет данных', filterOoo: 'Фильтр...', pageSizeSelectorLabel: 'Строк:',
        applyFilter: 'Применить', resetFilter: 'Сбросить', clearFilter: 'Очистить',
        equals: 'Равно', notEqual: 'Не равно', contains: 'Содержит', notContains: 'Не содержит',
        startsWith: 'Начинается с', endsWith: 'Заканчивается на', blank: 'Пусто', notBlank: 'Не пусто',
        filterPlaceholder: 'Введите значение...', searchOoo: 'Поиск...',
        selectAll: 'Выбрать все', unselectAll: 'Снять выбор',
        pinned: 'Закреплено', pinLeft: 'Закрепить слева', pinRight: 'Закрепить справа', noPin: 'Снять закрепление',
        autosizeThisColumn: 'Автоширина этой колонки', autosizeAllColumns: 'Автоширина всех колонок',
        resetColumns: 'Сбросить колонки', expandAll: 'Развернуть все', collapseAll: 'Свернуть все',
        copy: 'Копировать', copyWithHeaders: 'Копировать с заголовками',
        paste: 'Вставить', export: 'Экспорт',
        columns: 'Колонки', pivotMode: 'Режим сводной таблицы',
    };

    function getDataUrl() {
        var base = window.agGridAuditDataUrl || '/index.php?r=audit/get-grid-data';
        var params = [];
        var form = document.getElementById('audit-filter-form');
        if (form) {
            var from = (form.querySelector('[name="from"]') || {}).value;
            var to = (form.querySelector('[name="to"]') || {}).value;
            var actorId = (form.querySelector('[name="actor_id"]') || {}).value;
            var actionType = (form.querySelector('[name="action_type"]') || {}).value;
            var objectType = (form.querySelector('[name="object_type"]') || {}).value;
            if (from) params.push('from=' + encodeURIComponent(from));
            if (to) params.push('to=' + encodeURIComponent(to));
            if (actorId) params.push('actor_id=' + encodeURIComponent(actorId));
            if (actionType) params.push('action_type=' + encodeURIComponent(actionType));
            if (objectType) params.push('object_type=' + encodeURIComponent(objectType));
        }
        if (params.length) {
            base += (base.indexOf('?') >= 0 ? '&' : '?') + params.join('&');
        }
        return base;
    }

    function loadGridData() {
        if (!gridApi) return;
        fetch(getDataUrl())
            .then(function(r) { return r.ok ? r.json() : Promise.reject(new Error('HTTP ' + r.status)); })
            .then(function(result) {
                if (result.success && result.data) {
                    gridApi.setGridOption('rowData', result.data);
                }
            })
            .catch(function(err) { console.error('AG Grid (Журнал аудита): ошибка загрузки', err); });
    }

    function initFilterForm() {
        var form = document.getElementById('audit-filter-form');
        if (form) {
            form.addEventListener('submit', function(e) {
                e.preventDefault();
                loadGridData();
            });
        }
    }

    function init() {
        var container = document.getElementById('agGridAuditContainer');
        if (!container || typeof agGrid === 'undefined') {
            if (container) container.innerHTML = '<p class="text-muted">Загрузка таблицы...</p>';
            return;
        }
        container.innerHTML = '';
        var gridOpts = {
            columnDefs: getColumnDefs(),
            defaultColDef: { sortable: true, filter: true, resizable: true },
            pagination: true,
            paginationPageSize: 50,
            paginationPageSizeSelector: [20, 50, 100, 500, 9999],
            domLayout: 'normal',
            getRowHeight: function() { return 36; },
            localeText: localeTextRu,
            sideBar: 'columns',
            onGridReady: function(params) {
                gridApi = params.api;
                loadGridData();
                initFilterForm();
            },
        };
        agGrid.createGrid(container, gridOpts);
    }

    window.refreshAuditGrid = function() {
        loadGridData();
    };

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() { setTimeout(init, 100); });
    } else {
        setTimeout(init, 100);
    }
})();
