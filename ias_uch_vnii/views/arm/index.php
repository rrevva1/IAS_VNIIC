<?php
/**
 * Учет ТС: список оборудования в AG Grid.
 * Колонки — по Основному учёту (см. docs/МАППИНГ_КОЛОНОК_УЧЕТ_ТС.md).
 */

use app\assets\ArmGridAsset;
use yii\helpers\Html;
use yii\helpers\Url;

ArmGridAsset::register($this);

$this->title = 'Учет ТС';
$this->params['breadcrumbs'][] = $this->title;

$equipmentTypes = $equipmentTypes ?? [];
?>
<div class="arm-index">
    <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
        <h1 class="mb-0"><?= Html::encode($this->title) ?></h1>
        <div class="btn-group">
            <?= Html::a('<i class="glyphicon glyphicon-plus"></i> Добавить технику', ['create'], ['class' => 'btn btn-success']) ?>
            <?= Html::button('<i class="glyphicon glyphicon-refresh"></i> Обновить', [
                'class' => 'btn btn-outline-secondary',
                'onclick' => 'refreshArmGrid()',
            ]) ?>
            <?= Html::button('<i class="glyphicon glyphicon-transfer"></i> Переместить/Переназначить', [
                'class' => 'btn btn-primary',
                'id' => 'btnReassignArm',
                'title' => 'Выберите одну или несколько строк в таблице, затем нажмите',
            ]) ?>
        </div>
    </div>

    <p class="text-muted small mb-2">Чтобы переместить или переназначить технику — отметьте <strong>чекбоксы слева</strong> у нужных строк, затем нажмите кнопку «Переместить/Переназначить».</p>
    <ul class="nav nav-tabs arm-type-tabs mb-3" role="tablist">
        <li class="nav-item">
            <a class="nav-link active arm-type-tab" href="#" data-type-id="">Вся техника</a>
        </li>
        <?php foreach ($equipmentTypes as $type): ?>
        <li class="nav-item">
            <a class="nav-link arm-type-tab" href="#" data-type-id="<?= Html::encode($type['id'] ?? '') ?>"><?= Html::encode($type['name'] ?? '') ?></a>
        </li>
        <?php endforeach; ?>
    </ul>

    <div id="agGridArmContainer" class="ag-theme-quartz" style="width: 100%; height: calc(100vh - 280px); min-height: 500px;">
        <div class="text-center p-4 text-muted">
            <span class="glyphicon glyphicon-refresh glyphicon-spin"></span>
            <p>Загрузка таблицы...</p>
        </div>
    </div>
</div>

<div class="modal fade" id="reassignArmModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">
                    <i class="glyphicon glyphicon-transfer"></i> Переместить/Переназначить технику
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Закрыть"></button>
            </div>
            <div class="modal-body">
                <!-- Блок информации о выбранных единицах -->
                <div id="reassignEquipmentInfo" class="mb-4">
                    <div class="d-flex align-items-center mb-2">
                        <strong>Выбрано единиц техники: <span id="reassignEquipmentCount">0</span></strong>
                    </div>
                    <div id="reassignEquipmentList" class="equipment-list-container">
                        <div class="text-center text-muted py-3">
                            <span class="glyphicon glyphicon-refresh glyphicon-spin"></span> Загрузка информации...
                        </div>
                    </div>
                </div>

                <hr class="my-4">

                <!-- Блок изменения параметров -->
                <div class="mb-3">
                    <label class="form-label fw-bold">Изменить для всех выбранных единиц:</label>
                </div>

                <div class="mb-3">
                    <label class="form-label">Ответственный</label>
                    <select id="reassignUserId" class="form-select">
                        <option value="">— не менять —</option>
                        <option value="0">— снять назначение —</option>
                        <?php foreach ($users ?? [] as $uid => $uname): ?>
                        <option value="<?= (int)$uid ?>"><?= Html::encode($uname) ?></option>
                        <?php endforeach; ?>
                    </select>
                    <small class="form-text text-muted">Оставьте "— не менять —", чтобы сохранить текущее значение</small>
                </div>

                <div class="mb-3">
                    <label class="form-label">Помещение</label>
                    <select id="reassignLocationId" class="form-select">
                        <option value="">— не менять —</option>
                        <?php foreach ($locations ?? [] as $lid => $lname): ?>
                        <option value="<?= (int)$lid ?>"><?= Html::encode($lname) ?></option>
                        <?php endforeach; ?>
                    </select>
                    <small class="form-text text-muted">Оставьте "— не менять —", чтобы сохранить текущее значение</small>
                </div>

                <div class="mb-3">
                    <label class="form-label">Статус</label>
                    <select id="reassignStatusId" class="form-select">
                        <option value="">— не менять —</option>
                        <?php foreach ($statuses ?? [] as $sid => $sname): ?>
                        <option value="<?= (int)$sid ?>"><?= Html::encode($sname) ?></option>
                        <?php endforeach; ?>
                    </select>
                    <small class="form-text text-muted">Оставьте "— не менять —", чтобы сохранить текущее значение</small>
                </div>

                <!-- Блок предпросмотра изменений -->
                <div id="reassignPreview" class="alert alert-info mb-0" style="display: none;">
                    <strong><i class="glyphicon glyphicon-info-sign"></i> Предпросмотр изменений:</strong>
                    <ul id="reassignPreviewList" class="mb-0 mt-2"></ul>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Отмена</button>
                <button type="button" class="btn btn-primary" id="reassignSubmit" disabled>
                    <span class="reassign-submit-text">Сохранить</span>
                    <span class="reassign-submit-spinner" style="display: none;">
                        <span class="glyphicon glyphicon-refresh glyphicon-spin"></span> Сохранение...
                    </span>
                </button>
            </div>
        </div>
    </div>
</div>

<style>
.equipment-list-container {
    max-height: 300px;
    overflow-y: auto;
    border: 1px solid #dee2e6;
    border-radius: 4px;
    padding: 10px;
    background-color: #f8f9fa;
}
.equipment-item {
    background: white;
    border: 1px solid #dee2e6;
    border-radius: 4px;
    padding: 10px;
    margin-bottom: 8px;
}
.equipment-item:last-child {
    margin-bottom: 0;
}
.equipment-item-header {
    font-weight: bold;
    color: #495057;
    margin-bottom: 6px;
}
.equipment-item-detail {
    font-size: 0.9em;
    color: #6c757d;
    margin: 2px 0;
}
.equipment-summary {
    background: white;
    border: 1px solid #dee2e6;
    border-radius: 4px;
    padding: 12px;
}
</style>
<?php
$this->registerJs(
    "window.agGridArmDataUrl = " . json_encode(Url::to(['arm/get-grid-data'])) . ";",
    \yii\web\View::POS_HEAD
);
$this->registerJs(
    "window.agGridArmCurrentTypeId = '';" .
    "window.agGridArmReassignUrl = " . json_encode(Url::to(['arm/reassign'])) . ";" .
    "window.agGridArmGetSelectedInfoUrl = " . json_encode(Url::to(['arm/get-selected-info'])) . ";" .
    "window.armReassignCsrf = {param: " . json_encode(Yii::$app->request->csrfParam) . ", token: " . json_encode(Yii::$app->request->csrfToken) . "};" .
    "window.armUsers = " . json_encode($users ?? []) . ";" .
    "window.armLocations = " . json_encode($locations ?? []) . ";" .
    "window.armStatuses = " . json_encode($statuses ?? []) . ";",
    \yii\web\View::POS_HEAD
);
$this->registerJs("
(function(){
    var reassignModal, pendingIds = [], equipmentData = [], equipmentSummary = {};
    
    // Загрузка информации о выбранных единицах техники
    function loadSelectedEquipmentInfo(ids) {
        var infoContainer = document.getElementById('reassignEquipmentList');
        var countSpan = document.getElementById('reassignEquipmentCount');
        
        if (!infoContainer || !countSpan) return;
        
        infoContainer.innerHTML = '<div class=\"text-center text-muted py-3\"><span class=\"glyphicon glyphicon-refresh glyphicon-spin\"></span> Loading information...</div>';
        countSpan.textContent = ids.length;
        
        var fd = new FormData();
        fd.append(window.armReassignCsrf.param, window.armReassignCsrf.token);
        ids.forEach(function(id) { fd.append('ids[]', id); });
        
        fetch(window.agGridArmGetSelectedInfoUrl, { method: 'POST', body: fd })
            .then(function(r) { return r.ok ? r.json() : Promise.reject(new Error('HTTP ' + r.status)); })
            .then(function(result) {
                if (result.success && result.data) {
                    equipmentData = result.data;
                    equipmentSummary = result.summary || {};
                    console.log('Данные о выбранных единицах загружены:', equipmentData.length, 'единиц');
                    renderEquipmentInfo();
                    // Обновляем предпросмотр после загрузки данных - с небольшой задержкой для надежности
                    setTimeout(function() {
                        // Проверяем, что модальное окно все еще открыто
                        var modal = document.getElementById('reassignArmModal');
                        if (modal && modal.classList.contains('show')) {
                            updatePreview();
                        }
                    }, 50);
                } else {
                    console.error('Ошибка загрузки данных:', result.message || 'Unknown error');
                    infoContainer.innerHTML = '<div class=\"alert alert-danger\">Error loading data: ' + (result.message || 'Unknown error') + '</div>';
                    // Все равно пытаемся обновить предпросмотр, если модальное окно открыто
                    setTimeout(function() {
                        var modal = document.getElementById('reassignArmModal');
                        if (modal && modal.classList.contains('show')) {
                            updatePreview();
                        }
                    }, 50);
                }
            })
            .catch(function(err) {
                console.error('Ошибка загрузки информации о технике:', err);
                infoContainer.innerHTML = '<div class=\"alert alert-danger\">Error loading data: ' + err.message + '</div>';
                // Все равно пытаемся обновить предпросмотр
                setTimeout(function() {
                    updatePreview();
                }, 50);
            });
    }
    
    // Отображение информации о выбранных единицах техники
    function renderEquipmentInfo() {
        var container = document.getElementById('reassignEquipmentList');
        if (!container) return;
        
        if (equipmentData.length === 0) {
            container.innerHTML = '<div class=\"text-muted\">No data</div>';
            return;
        }
        
        var html = '';
        
        // If more than 5 units selected, show summary
        if (equipmentData.length > 5) {
            html += '<div class=\"equipment-summary\">';
            html += '<div class=\"mb-2\"><strong>Selected: ' + equipmentData.length + ' equipment units</strong></div>';
            
            if (equipmentSummary.has_responsible > 0) {
                html += '<div class=\"equipment-item-detail\">• ' + equipmentSummary.has_responsible + ' units with responsible person</div>';
            }
            if (equipmentSummary.without_responsible > 0) {
                html += '<div class=\"equipment-item-detail\">• ' + equipmentSummary.without_responsible + ' units without responsible person</div>';
            }
            
            // Group by locations
            var locationsMap = {};
            equipmentData.forEach(function(item) {
                var locId = item.location_id || 'none';
                if (!locationsMap[locId]) {
                    locationsMap[locId] = { name: item.location_name || 'Not specified', count: 0 };
                }
                locationsMap[locId].count++;
            });
            Object.keys(locationsMap).forEach(function(locId) {
                html += '<div class=\"equipment-item-detail\">• ' + locationsMap[locId].count + ' units in location: ' + escapeHtml(locationsMap[locId].name) + '</div>';
            });
            
            html += '</div>';
        } else {
            // Show detailed information for each unit
            equipmentData.forEach(function(item) {
                html += '<div class=\"equipment-item\">';
                html += '<div class=\"equipment-item-header\">';
                html += 'Inv. #: ' + escapeHtml(item.inventory_number || '-') + ' | ' + escapeHtml(item.name || '-');
                html += '</div>';
                html += '<div class=\"equipment-item-detail\">';
                html += 'Responsible: ' + (item.responsible_user_name || '<span class=\"text-muted\">not assigned</span>');
                html += '</div>';
                html += '<div class=\"equipment-item-detail\">';
                html += 'Location: ' + (item.location_name || '<span class=\"text-muted\">not specified</span>');
                html += '</div>';
                html += '<div class=\"equipment-item-detail\">';
                html += 'Status: ' + (item.status_name || '<span class=\"text-muted\">not specified</span>');
                html += '</div>';
                html += '</div>';
            });
        }
        
        container.innerHTML = html;
    }
    
    // Обновление предпросмотра изменений
    function updatePreview() {
        // Проверяем, что модальное окно открыто и видимо
        var modal = document.getElementById('reassignArmModal');
        if (!modal) {
            console.warn('updatePreview: модальное окно не найдено');
            return;
        }
        
        // Проверяем, что модальное окно видимо (Bootstrap modal)
        // Используем проверку класса 'show' вместо внутреннего состояния Bootstrap
        // НО: не завершаем выполнение, если модальное окно не видимо - просто не обновляем предпросмотр
        // Это позволяет обновить состояние кнопки даже если модальное окно закрывается
        var isModalVisible = modal.classList.contains('show');
        
        var submitBtn = document.getElementById('reassignSubmit');
        if (!submitBtn) {
            console.warn('updatePreview: кнопка сохранения не найдена');
            return;
        }
        
        // Предпросмотр - ищем элементы внутри модального окна
        // Сначала пытаемся найти через getElementById
        var previewDiv = document.getElementById('reassignPreview');
        var previewList = document.getElementById('reassignPreviewList');
        
        // Если не найдены, пытаемся найти внутри модального окна
        if (!previewDiv || !previewList) {
            if (modal) {
                previewDiv = modal.querySelector('#reassignPreview');
                previewList = modal.querySelector('#reassignPreviewList');
            }
        }
        
        // Если все еще не найдены, пытаемся найти через querySelector в document
        if (!previewDiv || !previewList) {
            previewDiv = document.querySelector('#reassignPreview');
            previewList = document.querySelector('#reassignPreviewList');
        }
        
        // Если элементы предпросмотра не найдены, пытаемся найти их снова (на случай, если DOM еще не обновлен)
        // Делаем несколько попыток с небольшой задержкой, если элементы не найдены
        if ((!previewDiv || !previewList) && isModalVisible) {
            // Если модальное окно видимо, но элементы не найдены, пытаемся еще раз через небольшую задержку
            setTimeout(function() {
                var retryModal = document.getElementById('reassignArmModal');
                if (!retryModal || !retryModal.classList.contains('show')) {
                    return; // Модальное окно закрыто
                }
                
                var retryPreviewDiv = retryModal.querySelector('#reassignPreview') || document.getElementById('reassignPreview');
                var retryPreviewList = retryModal.querySelector('#reassignPreviewList') || document.getElementById('reassignPreviewList');
                
                if (retryPreviewDiv && retryPreviewList) {
                    // Элементы найдены, обновляем предпросмотр
                    // Рекурсивно вызываем updatePreview, но только один раз
                    if (!window.updatePreviewRetryInProgress) {
                        window.updatePreviewRetryInProgress = true;
                        updatePreview();
                        window.updatePreviewRetryInProgress = false;
                    }
                } else {
                    console.warn('updatePreview: элементы предпросмотра не найдены после повторной попытки', {
                        previewDiv: !!retryPreviewDiv,
                        previewList: !!retryPreviewList,
                        modalExists: !!retryModal,
                        modalVisible: retryModal && retryModal.classList.contains('show')
                    });
                }
            }, 100);
        }
        
        if (!previewDiv || !previewList) {
            console.warn('updatePreview: элементы предпросмотра не найдены, пропускаем обновление предпросмотра', {
                previewDiv: !!previewDiv,
                previewList: !!previewList,
                isModalVisible: isModalVisible,
                modalExists: !!modal
            });
            // Продолжаем выполнение, чтобы обновить состояние кнопки
        }
        
        var userIdEl = document.getElementById('reassignUserId');
        var locationIdEl = document.getElementById('reassignLocationId');
        var statusIdEl = document.getElementById('reassignStatusId');
        
        if (!userIdEl || !locationIdEl || !statusIdEl) {
            console.warn('updatePreview: form fields not found');
            return;
        }
        
        var userId = userIdEl.value || '';
        var locationId = locationIdEl.value || '';
        var statusId = statusIdEl.value || '';
        
        console.log('updatePreview called: userId=', userId, 'locationId=', locationId, 'statusId=', statusId, 'equipmentData.length=', equipmentData.length);
        
        var changes = [];
        var hasChanges = false;
        
        // Проверяем изменения ответственного
        if (userId !== '') {
            hasChanges = true;
            var newUserName = '';
            if (userId === '0') {
                newUserName = 'remove assignment';
            } else if (window.armUsers && window.armUsers[userId]) {
                newUserName = window.armUsers[userId];
            }
            
            var affectedCount = 0;
            var oldUsers = [];
            equipmentData.forEach(function(item) {
                if (userId === '0' && item.responsible_user_id) {
                    affectedCount++;
                    if (item.responsible_user_name && oldUsers.indexOf(item.responsible_user_name) === -1) {
                        oldUsers.push(item.responsible_user_name);
                    }
                } else if (userId !== '0' && item.responsible_user_id != userId) {
                    affectedCount++;
                    if (item.responsible_user_name && oldUsers.indexOf(item.responsible_user_name) === -1) {
                        oldUsers.push(item.responsible_user_name);
                    }
                }
            });
            
            if (affectedCount > 0) {
                var oldUserText = oldUsers.length > 0 ? oldUsers.join(', ') : 'raznye';
                changes.push('Responsible: ' + oldUserText + ' -> ' + newUserName + ' (' + affectedCount + ' units)');
            }
        }
        
        // Проверяем изменения помещения
        if (locationId !== '') {
            hasChanges = true;
            var newLocationName = window.armLocations && window.armLocations[locationId] ? window.armLocations[locationId] : '';
            
            var affectedCount = 0;
            var oldLocations = [];
            equipmentData.forEach(function(item) {
                if (item.location_id != locationId) {
                    affectedCount++;
                    if (item.location_name && oldLocations.indexOf(item.location_name) === -1) {
                        oldLocations.push(item.location_name);
                    }
                }
            });
            
            if (affectedCount > 0) {
                var oldLocText = oldLocations.length > 0 ? oldLocations.join(', ') : 'raznye';
                changes.push('Location: ' + oldLocText + ' -> ' + newLocationName + ' (' + affectedCount + ' units)');
            }
        }
        
        // Проверяем изменения статуса
        if (statusId !== '') {
            hasChanges = true;
            var newStatusName = window.armStatuses && window.armStatuses[statusId] ? window.armStatuses[statusId] : '';
            
            var affectedCount = 0;
            var oldStatuses = [];
            equipmentData.forEach(function(item) {
                if (item.status_id != statusId) {
                    affectedCount++;
                    if (item.status_name && oldStatuses.indexOf(item.status_name) === -1) {
                        oldStatuses.push(item.status_name);
                    }
                }
            });
            
            if (affectedCount > 0) {
                var oldStatusText = oldStatuses.length > 0 ? oldStatuses.join(', ') : 'raznye';
                changes.push('Status: ' + oldStatusText + ' -> ' + newStatusName + ' (' + affectedCount + ' units)');
            }
        }
        
        // Check if any field has been changed (not empty)
        var hasAnyChange = (userId !== '' || locationId !== '' || statusId !== '');
        
        console.log('updatePreview: hasAnyChange=', hasAnyChange, 'hasChanges=', hasChanges, 'changes.length=', changes.length, 'equipmentData.length=', equipmentData.length);
        
        if (hasAnyChange) {
            // Если есть хотя бы одно изменение, активируем кнопку
            submitBtn.disabled = false;
            console.log('Кнопка активирована, так как есть изменения');
            
            // Обновляем предпросмотр только если элементы найдены И модальное окно видимо
            if (previewDiv && previewList && isModalVisible) {
                // Показываем блок предпросмотра
                previewDiv.style.display = 'block';
                
                if (changes.length > 0) {
                    // Показываем детальный предпросмотр изменений
                    previewList.innerHTML = changes.map(function(change) {
                        return '<li>' + escapeHtml(change) + '</li>';
                    }).join('');
                    console.log('Предпросмотр обновлен: детальные изменения, элементов изменений:', changes.length);
                } else if (equipmentData.length > 0) {
                    // Если изменения выбраны, но не приведут к реальным изменениям (все уже имеют эти значения)
                    previewList.innerHTML = '<li class=\"text-muted\">Changes will be applied to all selected equipment</li>';
                    console.log('Предпросмотр обновлен: изменения будут применены ко всем выбранным единицам');
                } else {
                    // Если данные еще не загружены
                    previewList.innerHTML = '<li class=\"text-muted\">Loading information...</li>';
                    console.log('Предпросмотр обновлен: данные загружаются');
                }
                console.log('Предпросмотр обновлен, элементы найдены, модальное окно видимо');
            } else {
                console.warn('Предпросмотр не обновлен:', {
                    previewDiv: !!previewDiv,
                    previewList: !!previewList,
                    isModalVisible: isModalVisible
                });
            }
        } else {
            // Нет изменений - блокируем кнопку
            submitBtn.disabled = true;
            console.log('Кнопка деактивирована, так как нет изменений');
            
            // Скрываем предпросмотр только если элементы найдены И модальное окно видимо
            if (previewDiv && previewList && isModalVisible) {
                previewDiv.style.display = 'none';
                previewList.innerHTML = '';
            }
        }
        
        console.log('updatePreview: hasAnyChange=', hasAnyChange, 'userId=', userId, 'locationId=', locationId, 'statusId=', statusId, 'changes.length=', changes.length, 'equipmentData.length=', equipmentData.length, 'submitBtn.disabled=', submitBtn.disabled);
    }
    
    // Валидация формы
    function validateForm() {
        var userId = document.getElementById('reassignUserId').value;
        var locationId = document.getElementById('reassignLocationId').value;
        var statusId = document.getElementById('reassignStatusId').value;
        return userId !== '' || locationId !== '' || statusId !== '';
    }
    
    // Показ уведомления
    function showNotification(message, type) {
        type = type || 'success';
        var alertClass = type === 'success' ? 'alert-success' : 'alert-danger';
        var alertHtml = '<div class=\"alert ' + alertClass + ' alert-dismissible fade show\" role=\"alert\" style=\"position: fixed; top: 20px; right: 20px; z-index: 9999; min-width: 300px;\">' +
            escapeHtml(message) +
            '<button type=\"button\" class=\"btn-close\" data-bs-dismiss=\"alert\" aria-label=\"Закрыть\"></button>' +
            '</div>';
        var alertDiv = document.createElement('div');
        alertDiv.innerHTML = alertHtml;
        document.body.appendChild(alertDiv.firstElementChild);
        setTimeout(function() {
            var alert = document.querySelector('.alert');
            if (alert) {
                var bsAlert = new bootstrap.Alert(alert);
                bsAlert.close();
            }
        }, 5000);
    }
    
    // Отправка данных
    // Функция для восстановления состояния кнопки
    function resetSubmitButton() {
        var submitBtn = document.getElementById('reassignSubmit');
        if (!submitBtn) return;
        var submitText = submitBtn.querySelector('.reassign-submit-text');
        var submitSpinner = submitBtn.querySelector('.reassign-submit-spinner');
        if (submitText) submitText.style.display = 'inline';
        if (submitSpinner) submitSpinner.style.display = 'none';
        submitBtn.disabled = false;
    }
    
    function submitReassign() {
        var submitBtn = document.getElementById('reassignSubmit');
        if (!submitBtn) {
            console.error('Кнопка submitReassign не найдена');
            return;
        }
        
        var submitText = submitBtn.querySelector('.reassign-submit-text');
        var submitSpinner = submitBtn.querySelector('.reassign-submit-spinner');
        
        // Проверяем наличие изменений
        var userId = document.getElementById('reassignUserId').value;
        var locationId = document.getElementById('reassignLocationId').value;
        var statusId = document.getElementById('reassignStatusId').value;
        
        console.log('submitReassign: userId=', userId, 'locationId=', locationId, 'statusId=', statusId, 'pendingIds.length=', pendingIds.length);
        
        if (!userId && !locationId && !statusId) {
            console.warn('Нет изменений для сохранения');
            showNotification('Выберите хотя бы одно поле для изменения.', 'error');
            return;
        }
        
        if (pendingIds.length === 0) {
            console.error('Нет выбранных единиц техники для сохранения');
            showNotification('Ошибка: не выбраны единицы техники для сохранения', 'error');
            return;
        }
        
        // Проверяем, не заблокирована ли кнопка (но не останавливаем выполнение, если есть изменения)
        if (submitBtn.disabled && (!userId && !locationId && !statusId)) {
            console.warn('Кнопка заблокирована и нет изменений');
            showNotification('Выберите хотя бы одно поле для изменения.', 'error');
            return;
        }
        
        // Сохраняем состояние кнопки перед отправкой
        submitBtn.disabled = true;
        if (submitText) submitText.style.display = 'none';
        if (submitSpinner) submitSpinner.style.display = 'inline';
        
        var fd = new FormData();
        fd.append(window.armReassignCsrf.param, window.armReassignCsrf.token);
        pendingIds.forEach(function(id) { fd.append('ids[]', id); });
        
        if (userId !== '') {
            fd.append('responsible_user_id', userId === '0' ? '' : userId);
        }
        if (locationId !== '') {
            fd.append('location_id', locationId);
        }
        if (statusId !== '') {
            fd.append('status_id', statusId);
        }
        
        console.log('Отправка запроса на перезакрепление...');
        
        fetch(window.agGridArmReassignUrl, { method: 'POST', body: fd })
            .then(function(r) { 
                console.log('Ответ получен, статус:', r.status);
                if (!r.ok) {
                    return r.text().then(function(text) {
                        console.error('Ошибка HTTP:', r.status, text);
                        return Promise.reject(new Error('HTTP ' + r.status + ': ' + text.substring(0, 100)));
                    });
                }
                return r.json();
            })
            .then(function(res) {
                console.log('Ответ от сервера:', res);
                if (res.success) {
                    var message = res.message;
                    if (res.details) {
                        var details = [];
                        if (res.details.responsible_user_changed > 0) {
                            details.push('Ответственный изменен: ' + res.details.responsible_user_changed);
                        }
                        if (res.details.location_changed > 0) {
                            details.push('Помещение изменено: ' + res.details.location_changed);
                        }
                        if (res.details.status_changed > 0) {
                            details.push('Статус изменен: ' + res.details.status_changed);
                        }
                        if (details.length > 0) {
                            message += '\\n• ' + details.join('\\n• ');
                        }
                    }
                    // Восстанавливаем состояние кнопки перед закрытием модального окна
                    resetSubmitButton();
                    // Очищаем данные после успешного сохранения
                    pendingIds = [];
                    equipmentData = [];
                    equipmentSummary = {};
                    // Закрываем модальное окно
                    if (reassignModal) {
                        reassignModal.hide();
                    }
                    // Обновляем таблицу
                    if (typeof refreshArmGrid === 'function') {
                        console.log('Обновление таблицы после успешного сохранения');
                        refreshArmGrid();
                    }
                    showNotification('✓ ' + message, 'success');
                } else {
                    console.error('Ошибка сохранения:', res.message);
                    showNotification(res.message || 'Ошибка при сохранении', 'error');
                    resetSubmitButton();
                }
            })
            .catch(function(err) {
                console.error('Ошибка при сохранении:', err);
                showNotification('Ошибка сети: ' + (err.message || 'Неизвестная ошибка'), 'error');
                resetSubmitButton();
            });
    }
    
    // Функция escapeHtml
    function escapeHtml(str) {
        if (str == null) return '';
        var div = document.createElement('div');
        div.textContent = str;
        return div.innerHTML;
    }
    
    // Открытие модального окна
    window.openReassignModal = function(ids) {
        pendingIds = ids || [];
        equipmentData = [];
        equipmentSummary = {};
        
        // Сброс полей
        var u = document.getElementById('reassignUserId');
        var l = document.getElementById('reassignLocationId');
        var s = document.getElementById('reassignStatusId');
        if (u) u.value = '';
        if (l) l.value = '';
        if (s) s.value = '';
        
        // Скрыть предпросмотр и очистить его содержимое
        var preview = document.getElementById('reassignPreview');
        var previewList = document.getElementById('reassignPreviewList');
        if (preview) {
            preview.style.display = 'none';
        }
        if (previewList) {
            previewList.innerHTML = '';
        }
        
        // Восстановить состояние кнопки (на случай, если она была в состоянии загрузки)
        resetSubmitButton();
        
        // Деактивировать кнопку (так как нет изменений)
        var submitBtn = document.getElementById('reassignSubmit');
        if (submitBtn) submitBtn.disabled = true;
        
        if (!reassignModal) {
            reassignModal = new bootstrap.Modal(document.getElementById('reassignArmModal'));
        }
        
        // Используем событие Bootstrap modal для инициализации после полного открытия
        var modalElement = document.getElementById('reassignArmModal');
        if (modalElement) {
            // Удаляем предыдущие обработчики, если они есть
            if (window.reassignModalShownHandler) {
                modalElement.removeEventListener('shown.bs.modal', window.reassignModalShownHandler);
            }
            
            // Создаем новый обработчик для события показа модального окна
            window.reassignModalShownHandler = function() {
                console.log('Модальное окно полностью открыто, инициализируем обработчики');
                initEventHandlers();
                
                // Ищем элементы предпросмотра внутри модального окна
                var modal = document.getElementById('reassignArmModal');
                var previewDiv = modal ? modal.querySelector('#reassignPreview') : document.getElementById('reassignPreview');
                var previewList = modal ? modal.querySelector('#reassignPreviewList') : document.getElementById('reassignPreviewList');
                
                console.log('При открытии модального окна: previewDiv=', !!previewDiv, 'previewList=', !!previewList, 'modal=', !!modal);
                
                // Принудительно обновляем предпросмотр после привязки обработчиков
                updatePreview();
            };
            
            // Привязываем обработчик события показа модального окна
            modalElement.addEventListener('shown.bs.modal', window.reassignModalShownHandler);
        }
        
        reassignModal.show();
        
        // Загрузить информацию о выбранных единицах
        if (pendingIds.length > 0) {
            loadSelectedEquipmentInfo(pendingIds);
        } else {
            // Если нет ID, все равно обновляем предпросмотр после задержки
            setTimeout(function() {
                var modal = document.getElementById('reassignArmModal');
                if (modal && modal.classList.contains('show')) {
                    updatePreview();
                }
            }, 200);
        }
    };
    
    // Инициализация обработчиков
    function initEventHandlers() {
        // Обработчик кнопки сохранения (привязываем один раз)
        var submitBtn = document.getElementById('reassignSubmit');
        if (submitBtn && !submitBtn.hasAttribute('data-handler-attached')) {
            submitBtn.addEventListener('click', function(e) {
                e.preventDefault();
                e.stopPropagation();
                console.log('Клик по кнопке сохранения');
                submitReassign();
            });
            submitBtn.setAttribute('data-handler-attached', 'true');
            console.log('Submit button handler attached');
        }
        
        // Обработчики изменения полей - используем делегирование на уровне документа
        // Привязываем обработчик один раз, он будет работать всегда
        if (!window.reassignFieldChangeHandlerAttached) {
            window.reassignFieldChangeHandler = function(e) {
                var target = e.target;
                // Проверяем, что событие произошло внутри модального окна перезакрепления
                var modal = document.getElementById('reassignArmModal');
                if (!modal) {
                    return;
                }
                
                // Проверяем, что модальное окно видимо
                if (!modal.classList.contains('show')) {
                    // Модальное окно закрыто, игнорируем событие
                    return;
                }
                
                // Проверяем, что событие произошло внутри модального окна
                if (!modal.contains(target)) {
                    return;
                }
                
                if (target.id === 'reassignUserId' || target.id === 'reassignLocationId' || target.id === 'reassignStatusId') {
                    // Получаем equipmentData из замыкания (она объявлена в области видимости функции)
                    var currentEquipmentDataLength = 0;
                    try {
                        // Пытаемся получить длину массива equipmentData из области видимости
                        // Если она недоступна напрямую, используем 0
                        if (typeof equipmentData !== 'undefined' && Array.isArray(equipmentData)) {
                            currentEquipmentDataLength = equipmentData.length;
                        }
                    } catch(e) {
                        // Игнорируем ошибку
                    }
                    console.log('Field changed:', target.id, 'value:', target.value, 'equipmentData.length:', currentEquipmentDataLength);
                    // Используем небольшую задержку, чтобы значение успело обновиться
                    setTimeout(function() {
                        // Проверяем, что модальное окно все еще открыто перед обновлением предпросмотра
                        var checkModal = document.getElementById('reassignArmModal');
                        if (checkModal && checkModal.classList.contains('show')) {
                            console.log('Вызываем updatePreview после изменения поля');
                            updatePreview();
                        } else {
                            console.log('Модальное окно закрыто, пропускаем обновление предпросмотра');
                        }
                    }, 10);
                }
            };
            
            // Привязываем обработчик к документу с capture фазой
            document.addEventListener('change', window.reassignFieldChangeHandler, true);
            window.reassignFieldChangeHandlerAttached = true;
            console.log('Field change handlers attached via document delegation (one time)');
        }
    }
    
    document.addEventListener('DOMContentLoaded', function() {
        // Инициализируем обработчики при загрузке страницы
        setTimeout(function() {
            initEventHandlers();
        }, 500);
    });
})();
", \yii\web\View::POS_END);
