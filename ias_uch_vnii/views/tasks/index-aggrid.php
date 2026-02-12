<?php

use yii\helpers\Html;
use yii\helpers\Url;
use app\assets\AgGridAsset;
use app\models\entities\Users;
use app\models\dictionaries\DicTaskStatus;

// Подключаем AG Grid assets
AgGridAsset::register($this);

$this->title = 'Help Desk - Заявки (AG Grid)';
$this->params['breadcrumbs'] = [];

// Определяем, является ли пользователь администратором
$isAdmin = !Yii::$app->user->isGuest && Yii::$app->user->identity && Yii::$app->user->identity->isAdministrator();
$isRegularUser = !Yii::$app->user->isGuest && Yii::$app->user->identity && Yii::$app->user->identity->isRegularUser();

// Получаем список пользователей для dropdown (только для админов)
$usersList = [];
$statusList = [];

if ($isAdmin) {
    $usersList = Users::find()
        ->select(['full_name', 'id_user'])
        ->indexBy('id_user')
        ->column();
    
    $statusList = DicTaskStatus::getStatusList();
}

// Передаем данные в JavaScript
$this->registerJs("
    window.isUserAdmin = " . ($isAdmin ? 'true' : 'false') . ";
    window.allUsersList = " . json_encode($usersList) . ";
    window.allStatusList = " . json_encode($statusList) . ";
    window.agGridDataUrl = '" . Url::to(['tasks/get-grid-data']) . "';
", \yii\web\View::POS_HEAD);
?>

<!-- Основной контейнер для страницы заявок с AG Grid -->
<div class="tasks-index-ag">
    
    <!-- Панель инструментов -->
    <div class="ag-grid-toolbar">
        <div class="btn-group">
            <?php if ($isRegularUser || $isAdmin): ?>
                <?= Html::button('<i class="glyphicon glyphicon-plus"></i> Создать заявку', [
                    'class' => 'btn btn-success',
                    'onclick' => 'openCreateTaskModal()'
                ]) ?>
            <?php endif; ?>
            <?php if ($isAdmin): ?>
                <?= Html::button('<i class="glyphicon glyphicon-hdd"></i> Учет ТС', [
                    'class' => 'btn btn-primary',
                    'title' => 'Управление техническими средствами',
                    'onclick' => 'openEquipmentManagementModal()'
                ]) ?>
            <?php endif; ?>
            
            <?= Html::button('<i class="glyphicon glyphicon-refresh"></i> Обновить', [
                'class' => 'btn btn-outline-secondary',
                'onclick' => 'refreshGrid()'
            ]) ?>
            
            <?php if ($isAdmin): ?>
                <?= Html::button('<i class="glyphicon glyphicon-check"></i> Выбрать все', [
                    'class' => 'btn btn-outline-secondary',
                    'onclick' => 'selectAllRows()'
                ]) ?>
                
                <?= Html::button('<i class="glyphicon glyphicon-unchecked"></i> Снять выбор', [
                    'class' => 'btn btn-outline-secondary',
                    'onclick' => 'deselectAllRows()'
                ]) ?>
            <?php endif; ?>
        </div>
        
        <div class="btn-group">
            <?= Html::button('<i class="glyphicon glyphicon-export"></i> Excel', [
                'class' => 'btn btn-outline-primary',
                'onclick' => 'exportToExcel()'
            ]) ?>
            
            <?= Html::button('<i class="glyphicon glyphicon-export"></i> CSV', [
                'class' => 'btn btn-outline-primary',
                'onclick' => 'exportToCsv()'
            ]) ?>
        </div>
    </div>
    
    <!-- Контейнер для AG Grid -->
    <div id="agGridTasksContainer" class="ag-theme-quartz">
        <div class="text-center">
            <i class="glyphicon glyphicon-refresh glyphicon-spin"></i>
            <p>Загрузка таблицы заявок...</p>
        </div>
    </div>
</div>

<!-- Модальное окно для создания заявки -->
<div class="modal fade" id="createTaskModal" tabindex="-1" role="dialog" aria-labelledby="createTaskModalLabel">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="createTaskModalLabel">
                    <i class="glyphicon glyphicon-plus-sign"></i> Создать новую заявку
                </h4>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" id="createTaskModalBody">
                <!-- Сюда будет загружаться форма через AJAX -->
                <div class="text-center">
                    <i class="glyphicon glyphicon-refresh glyphicon-spin"></i>
                    <p>Загрузка формы...</p>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Модальное окно для предпросмотра файлов (AG Grid) -->
<div class="modal fade preview-modal" id="previewModal" tabindex="-1" aria-labelledby="previewModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="previewModalLabel">Предпросмотр файла</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" id="previewContent">
                <!-- Контент предпросмотра будет загружен через ag-grid.js -->
                <div class="text-center text-muted">
                    <i class="glyphicon glyphicon-picture"></i>
                    <p>Выберите вложение для предпросмотра</p>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Закрыть</button>
                <a href="#" class="btn btn-primary" id="downloadBtn" target="_blank">
                    <i class="glyphicon glyphicon-download"></i> Скачать
                </a>
            </div>
        </div>
    </div>
</div>

<!-- Модальное окно для управления ТС -->
<div class="modal fade" id="equipmentManagementModal" tabindex="-1" role="dialog" aria-labelledby="equipmentManagementModalLabel">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="equipmentManagementModalLabel">
                    <i class="glyphicon glyphicon-hdd"></i> Управление техническими средствами
                </h4>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" id="equipmentManagementModalBody">
                <!-- Сюда будет загружаться контент через AJAX -->
                <div class="text-center">
                    <i class="glyphicon glyphicon-refresh glyphicon-spin"></i>
                    <p>Загрузка...</p>
                </div>
            </div>
        </div>
    </div>
</div>

<?php
// JavaScript для модального окна управления ТС
$this->registerJs("
    // Экземпляр модального окна для управления ТС
    var equipmentManagementModalInstance = null;
    
    // Функция открытия модального окна управления ТС
    function openEquipmentManagementModal() {
        var modalElement = document.getElementById('equipmentManagementModal');
        if (!modalElement) {
            console.error('Модальное окно equipmentManagementModal не найдено');
            return;
        }
        
        // Создаем или получаем экземпляр модального окна
        if (!equipmentManagementModalInstance) {
            equipmentManagementModalInstance = new bootstrap.Modal(modalElement, {
                backdrop: true,
                keyboard: true
            });
        }
        
        // Показываем модальное окно
        equipmentManagementModalInstance.show();
        
        // Загружаем список пользователей для выбора
        $.ajax({
            url: '" . \yii\helpers\Url::to(['users/index']) . "',
            type: 'GET',
            success: function(data) {
                // Извлекаем только содержимое контейнера с пользователями
                var content = $(data).find('.users-index').html();
                if (!content) {
                    content = '<div class=\"alert alert-info\">Перейдите в раздел <a href=\"" . \yii\helpers\Url::to(['users/index']) . "\" target=\"_blank\">Пользователи</a> для управления техническими средствами.</div>';
                }
                $('#equipmentManagementModalBody').html(content);
            },
            error: function() {
                $('#equipmentManagementModalBody').html('<div class=\"alert alert-danger\">Ошибка загрузки данных. <a href=\"" . \yii\helpers\Url::to(['users/index']) . "\" target=\"_blank\">Открыть в новой вкладке</a></div>');
            }
        });
    }
    
    // Очистка при закрытии модального окна
    $('#equipmentManagementModal').on('hidden.bs.modal', function() {
        $('#equipmentManagementModalBody').html('<div class=\"text-center\"><i class=\"glyphicon glyphicon-refresh glyphicon-spin\"></i><p>Загрузка...</p></div>');
    });
    
    // Экспортируем функцию глобально
    window.openEquipmentManagementModal = openEquipmentManagementModal;
", \yii\web\View::POS_END);
?>
