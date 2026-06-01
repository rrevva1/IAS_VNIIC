<?php

namespace app\controllers;

/**
 * Раздел «Склад» — учёт техники, размещённой в помещениях с типом «склад».
 * Интерфейс и операции совпадают с учётом ТС; отличается только фильтр выборки.
 */
class WarehouseController extends ArmController
{
    public function actionIndex()
    {
        return $this->renderEquipmentListPage(
            'warehouse_only',
            'Склад',
            ['warehouse/get-grid-data'],
            ['warehouse/export-xlsx']
        );
    }

    public function actionGetGridData()
    {
        return $this->buildGridDataJsonResponse('warehouse_only');
    }

    public function actionExportXlsx()
    {
        return parent::actionExportXlsx();
    }
}
