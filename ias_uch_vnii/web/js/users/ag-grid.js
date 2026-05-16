/**
 * AG Grid для страницы «Пользователи».
 * Поддержка раскрытия строки с отображением техники пользователя (аналогично заявкам).
 */
(function() {
    'use strict';

    var gridApi;
    var quickFilterTimer = null;

    function buildUrl(baseUrl, id) {
        if (!baseUrl) {
            return '';
        }
        var sep = baseUrl.indexOf('?') === -1 ? '?' : '&';
        return baseUrl + sep + 'id=' + encodeURIComponent(id);
    }

    function emailRenderer(params) {
        var value = params.value;
        if (!value) {
            return '';
        }
        return '<a href="mailto:' + value + '">' + value + '</a>';
    }

    function actionsRenderer(params) {
        if (!params.data || !params.data.id) {
            return '';
        }
        var id = params.data.id;
        var container = document.createElement('div');
        container.className = 'ag-actions';
        container.style.display = 'flex';
        container.style.gap = '8px';
        container.style.alignItems = 'center';

        var viewLink = document.createElement('a');
        viewLink.href = buildUrl(params.context.viewUrl, id);
        viewLink.textContent = '🔍';
        viewLink.title = 'Показать';
        viewLink.setAttribute('aria-label', 'Показать');

        var updateLink = document.createElement('a');
        updateLink.href = buildUrl(params.context.updateUrl, id);
        updateLink.textContent = '✏️';
        updateLink.title = 'Изменить';
        updateLink.setAttribute('aria-label', 'Изменить');

        var deleteLink = document.createElement('a');
        deleteLink.href = buildUrl(params.context.deleteUrl, id);
        deleteLink.textContent = '🗑️';
        deleteLink.title = 'Удалить';
        deleteLink.setAttribute('aria-label', 'Удалить');
        deleteLink.setAttribute('data-confirm', 'Удалить пользователя?');
        deleteLink.setAttribute('data-method', 'post');

        container.appendChild(viewLink);
        container.appendChild(updateLink);
        container.appendChild(deleteLink);

        return container;
    }

    /**
     * Рендерер полноширинной строки «Техника работника» (как в заявках).
     */
    function equipmentDetailRenderer(params) {
        if (!params.data || !params.data.isDetailRow) {
            return document.createElement('div');
        }
        var equipmentData = params.data.equipmentData || [];
        var totalCount = params.data.totalCount || 0;
        var container = document.createElement('div');
        container.className = 'equipment-detail-container';
        container.style.cssText = 'background-color: #f8f9fa; padding: 20px; border-left: 4px solid #667eea; animation: slideDown 0.3s ease-out;';

        if (equipmentData.length === 0) {
            container.innerHTML = [
                '<div style="text-align: center; padding: 30px; color: #6c757d;">',
                '<i class="glyphicon glyphicon-info-sign" style="font-size: 32px; margin-bottom: 15px; color: #adb5bd;"></i>',
                '<p style="font-size: 16px; margin: 0;">У пользователя нет закрепленной техники</p>',
                '</div>'
            ].join('');
        } else {
            var html = [
                '<div style="margin-bottom: 15px;">',
                '<span style="font-size: 16px; font-weight: 600; color: #495057;">🖥️ Техника работника</span>',
                '<span style="margin-left: 10px; padding: 3px 10px; background: #667eea; color: white; border-radius: 12px; font-size: 13px;">',
                totalCount + (totalCount === 1 ? ' единица' : totalCount < 5 ? ' единицы' : ' единиц'),
                '</span>',
                '</div>',
                '<table class="table table-bordered table-hover" style="margin: 0; background: white; border-radius: 6px; overflow: hidden;">',
                '<thead style="background-color: #667eea; color: white;">',
                '<tr><th style="padding: 12px;">ID</th><th style="padding: 12px;">Название техники</th><th style="padding: 12px;">Местоположение</th><th style="padding: 12px;">Описание</th><th style="padding: 12px;">Дата добавления</th></tr>',
                '</thead><tbody>'
            ].join('');
            equipmentData.forEach(function(item, index) {
                var rowStyle = index % 2 === 0 ? 'background-color: #ffffff;' : 'background-color: #f8f9fa;';
                html += '<tr style="' + rowStyle + '">' +
                    '<td style="padding: 10px; text-align: center;"><strong>' + item.id + '</strong></td>' +
                    '<td style="padding: 10px;"><strong style="color: #495057;">' + (item.name || '') + '</strong></td>' +
                    '<td style="padding: 10px;">' + (item.location || '') + '</td>' +
                    '<td style="padding: 10px; color: #6c757d;">' + (item.description || '') + '</td>' +
                    '<td style="padding: 10px; font-size: 13px;">' + (item.created_at || '') + '</td>' +
                    '</tr>';
            });
            html += '</tbody></table>';
            container.innerHTML = html;
        }
        return container;
    }

    /**
     * Колонка с кнопкой раскрытия техники пользователя.
     */
    function equipmentToggleRenderer(params) {
        if (!params.data || params.data.isDetailRow) {
            return '';
        }
        var userId = params.data.id;
        var isExpanded = params.node.data._equipmentExpanded || false;
        var title = isExpanded ? 'Скрыть технику' : 'Показать технику работника';
        var btnClass = isExpanded ? 'equipment-toggle-btn equipment-toggle-btn--expanded' : 'equipment-toggle-btn';
        var symbol = isExpanded ? '−' : '+';
        return '<button class="' + btnClass + '" data-user-id="' + userId + '" aria-label="' + title + '" title="' + title + '"><span class="toggle-icon">' + symbol + '</span></button>';
    }

    function getColumnDefs() {
        var cols = [
            {
                headerName: '',
                field: 'equipment_toggle',
                width: 56,
                minWidth: 48,
                pinned: 'left',
                filter: false,
                sortable: false,
                cellRenderer: equipmentToggleRenderer,
            },
            { headerName: 'ID', field: 'id', width: 90, filter: 'agNumberColumnFilter' },
            { headerName: 'ФИО', field: 'full_name', flex: 1, minWidth: 180, filter: 'agTextColumnFilter' },
            { headerName: 'Email', field: 'email', flex: 1, minWidth: 200, filter: 'agTextColumnFilter', cellRenderer: emailRenderer },
            { headerName: 'Роль', field: 'role_name', width: 180, filter: 'agTextColumnFilter' },
            { headerName: 'Пароль', field: 'password_mask', width: 120, sortable: false, filter: false, valueGetter: function() { return '••••••••'; } },
            { headerName: 'Действия', field: 'actions', width: 140, sortable: false, filter: false, cellRenderer: actionsRenderer },
        ];
        return cols;
    }

    function bindUsersQuickFilter() {
        var input = document.getElementById('usersGridQuickFilter');
        if (!input || input.hasAttribute('data-bound')) {
            return;
        }
        input.setAttribute('data-bound', '1');
        input.addEventListener('input', function() {
            if (!gridApi) {
                return;
            }
            var value = input.value || '';
            clearTimeout(quickFilterTimer);
            quickFilterTimer = setTimeout(function() {
                gridApi.setGridOption('quickFilterText', value);
            }, 200);
        });
    }

    function loadGridData(url) {
        if (!gridApi || !url) {
            return;
        }
        fetch(url)
            .then(function(r) { return r.ok ? r.json() : Promise.reject(new Error('HTTP ' + r.status)); })
            .then(function(result) {
                if (result && result.success && result.data) {
                    gridApi.setGridOption('rowData', result.data);
                } else {
                    gridApi.setGridOption('rowData', []);
                }
            })
            .catch(function(err) { console.error('AG Grid (Пользователи): ошибка загрузки', err); });
    }

    /**
     * Переключение отображения техники пользователя (раскрыть/свернуть).
     */
    function toggleEquipmentDetailUser(userId) {
        if (!gridApi) { return; }
        var userRowNode = null;
        gridApi.forEachNode(function(node) {
            if (node.data && node.data.id == userId && !node.data.isDetailRow) {
                userRowNode = node;
            }
        });
        if (!userRowNode) { return; }
        var isExpanded = userRowNode.data._equipmentExpanded || false;
        if (isExpanded) {
            hideEquipmentDetailUser(userId);
        } else {
            showEquipmentDetailForUser(userId, userRowNode);
        }
    }

    /**
     * Показать технику пользователя (загрузка по API и вставка detail-строки).
     */
    function showEquipmentDetailForUser(userId, userRowNode) {
        fetch('/index.php?r=tasks/get-user-equipment&userId=' + userId)
            .then(function(r) { return r.json(); })
            .then(function(result) {
                if (result.success) {
                    userRowNode.data._equipmentExpanded = true;
                    userRowNode.data._equipmentData = result.data;
                    gridApi.refreshCells({ rowNodes: [userRowNode], force: true });

                    var rowData = [];
                    gridApi.forEachNode(function(node) {
                        if (node.data && !node.data.isDetailRow) {
                            rowData.push(node.data);
                            if (node.data.id == userId) {
                                rowData.push({
                                    isDetailRow: true,
                                    parentUserId: userId,
                                    equipmentData: result.data,
                                    totalCount: result.total || (result.data && result.data.length) || 0,
                                });
                            }
                        }
                    });
                    gridApi.setGridOption('rowData', rowData);
                    setTimeout(function() {
                        if (gridApi.onRowHeightChanged) {
                            gridApi.onRowHeightChanged();
                        }
                    }, 100);
                } else {
                    alert('Ошибка: ' + (result.message || 'Не удалось загрузить данные'));
                }
            })
            .catch(function(err) {
                console.error('Ошибка загрузки техники пользователя', err);
                alert('Ошибка соединения с сервером');
            });
    }

    /**
     * Скрыть технику пользователя (удалить detail-строку).
     */
    function hideEquipmentDetailUser(userId) {
        var userRowNode = null;
        gridApi.forEachNode(function(node) {
            if (node.data && node.data.id == userId && !node.data.isDetailRow) {
                userRowNode = node;
            }
        });
        if (userRowNode) {
            userRowNode.data._equipmentExpanded = false;
            delete userRowNode.data._equipmentData;
        }
        var rowData = [];
        gridApi.forEachNode(function(node) {
            if (node.data) {
                if (node.data.isDetailRow && node.data.parentUserId == userId) { return; }
                rowData.push(node.data);
            }
        });
        gridApi.setGridOption('rowData', rowData);
        setTimeout(function() {
            if (gridApi.onRowHeightChanged) {
                gridApi.onRowHeightChanged();
            }
        }, 100);
    }

    function init() {
        var container = document.getElementById('agGridUsersContainer');
        if (!container || typeof agGrid === 'undefined') {
            if (container) {
                container.innerHTML = '<p class="text-muted">Загрузка таблицы...</p>';
            }
            return;
        }

        var dataUrl = container.dataset.url || '/index.php?r=users/get-grid-data';
        var viewUrl = container.dataset.viewUrl || '/index.php?r=users/view';
        var updateUrl = container.dataset.updateUrl || '/index.php?r=users/update';
        var deleteUrl = container.dataset.deleteUrl || '/index.php?r=users/delete';

        var gridOptions = {
            columnDefs: getColumnDefs(),
            defaultColDef: { sortable: true, filter: true, resizable: true },
            getQuickFilterText: function(params) {
                if (!params.data || params.data.isDetailRow) {
                    return '';
                }
                var d = params.data;
                return [d.id, d.full_name, d.email, d.role_name].filter(function(v) {
                    return v != null && v !== '';
                }).join(' ');
            },
            pagination: true,
            paginationPageSize: 20,
            paginationPageSizeSelector: [10, 20, 50, 100],
            domLayout: 'normal',
            isFullWidthRow: function(params) {
                return params.rowNode.data && params.rowNode.data.isDetailRow;
            },
            fullWidthCellRenderer: equipmentDetailRenderer,
            getRowHeight: function(params) {
                if (!params.node.data || !params.node.data.isDetailRow) {
                    return 36;
                }
                var equipmentData = params.node.data.equipmentData || [];
                if (equipmentData.length === 0) {
                    return 120;
                }
                var headerHeight = 60;
                var tableHeaderHeight = 45;
                var rowHeight = 45;
                var padding = 40;
                return Math.min(headerHeight + tableHeaderHeight + equipmentData.length * rowHeight + padding, 600);
            },
            localeText: {
                page: 'Страница', to: 'до', of: 'из', next: 'След.', last: 'Последняя',
                first: 'Первая', previous: 'Пред.', loadingOoo: 'Загрузка...',
                noRowsToShow: 'Нет данных', filterOoo: 'Фильтр...', pageSizeSelectorLabel: 'Строк:',
            },
            context: {
                viewUrl: viewUrl,
                updateUrl: updateUrl,
                deleteUrl: deleteUrl,
            },
            onGridReady: function(params) {
                gridApi = params.api;
                loadGridData(dataUrl);
                bindEquipmentToggleClick(container);
                bindUsersQuickFilter();
            },
        };

        container.innerHTML = '';
        agGrid.createGrid(container, gridOptions);
    }

    /**
     * Обработчик клика по кнопке раскрытия техники (только внутри грида пользователей).
     */
    function bindEquipmentToggleClick(container) {
        if (!container) { return; }
        container.addEventListener('click', function(e) {
            var btn = e.target.closest && e.target.closest('.equipment-toggle-btn');
            if (!btn) { return; }
            e.preventDefault();
            e.stopPropagation();
            var userId = btn.getAttribute('data-user-id');
            if (userId) {
                toggleEquipmentDetailUser(userId);
            }
        });
    }

    window.refreshUsersGrid = function() {
        var container = document.getElementById('agGridUsersContainer');
        if (!container || !gridApi) {
            return;
        }
        var dataUrl = container.dataset.url || '/index.php?r=users/get-grid-data';
        loadGridData(dataUrl);
    };

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() { setTimeout(init, 100); });
    } else {
        setTimeout(init, 100);
    }
})();
