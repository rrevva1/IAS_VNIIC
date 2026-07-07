<?php
/**
 * @var array $equipmentTypes
 * @var array<int, string> $warehouses
 */

use yii\helpers\Html;
?>
<div class="modal fade" id="deliveryLineModal" tabindex="-1" aria-labelledby="deliveryLineModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable modal-lg arm-view-modal__dialog">
        <div class="modal-content arm-view-modal">
            <div class="modal-header arm-view-modal__header">
                <h5 class="modal-title mb-0" id="deliveryLineModalLabel">Добавить технику</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Закрыть"></button>
            </div>
            <form id="deliveryLineForm" class="modal-body arm-view-modal__body" autocomplete="off">
                <input type="hidden" id="deliveryLineId" name="line_id" value="">
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label" for="deliveryLineType">Тип техники</label>
                        <select class="form-select" id="deliveryLineType" name="EquipmentDeliveryLine[equipment_type]" required>
                            <option value="">— выберите —</option>
                            <?php foreach (($equipmentTypes ?? []) as $typeId => $typeName): ?>
                                <option value="<?= Html::encode(is_string($typeId) ? $typeId : $typeName) ?>">
                                    <?= Html::encode($typeName) ?>
                                </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label" for="deliveryLineWarehouse">Склад</label>
                        <select class="form-select" id="deliveryLineWarehouse" name="EquipmentDeliveryLine[warehouse_location_id]" required>
                            <option value="">— выберите склад —</option>
                            <?php foreach (($warehouses ?? []) as $whId => $whName): ?>
                                <option value="<?= (int) $whId ?>"><?= Html::encode($whName) ?></option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div class="col-12">
                        <label class="form-label" for="deliveryLineName">Наименование</label>
                        <input type="text" class="form-control" id="deliveryLineName" name="EquipmentDeliveryLine[name]" maxlength="200" required>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label" for="deliveryLineQty">Количество</label>
                        <input type="number" class="form-control" id="deliveryLineQty" name="EquipmentDeliveryLine[quantity]" min="1" max="500" value="1" required>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label" for="deliveryLineWarrantyYears">Гарантия, лет</label>
                        <input type="number" class="form-control" id="deliveryLineWarrantyYears"
                               name="EquipmentDeliveryLine[warranty_years]"
                               min="0" max="50" step="0.5" placeholder="Например: 3">
                        <p class="form-text mb-0 delivery-line-warranty-hint">От даты поставки</p>
                    </div>
                </div>
                <div id="delivery-line-dynamic-block" class="arm-form-create__config d-none mt-3">
                    <h6 class="arm-form-create__config-title">Характеристики (как при учёте ТС)</h6>
                    <div id="delivery-line-dynamic-content" class="arm-form-create__config-fields row g-2"></div>
                </div>
            </form>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline-danger arm-tool-btn" id="deliveryLineDeleteBtn" hidden>
                    <i class="fas fa-trash" aria-hidden="true"></i>
                    Удалить
                </button>
                <button type="button" class="btn btn-outline-secondary arm-tool-btn" data-bs-dismiss="modal">Отмена</button>
                <button type="button" class="btn btn-primary arm-tool-btn" id="deliveryLineSaveBtn">
                    <i class="fas fa-check" aria-hidden="true"></i>
                    Сохранить
                </button>
            </div>
        </div>
    </div>
</div>
