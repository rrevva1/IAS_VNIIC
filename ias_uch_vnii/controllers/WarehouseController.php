<?php

namespace app\controllers;

use app\components\KitIssuanceService;
use Yii;
use yii\web\Response;

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

    /**
     * Списки свободной техники на складе для формы выдачи комплекта.
     */
    public function actionIssueKitOptions()
    {
        Yii::$app->response->format = Response::FORMAT_JSON;

        $hostId = (int) Yii::$app->request->get('host_id', 0);
        $warehouseLocationId = (int) Yii::$app->request->get('warehouse_location_id', 0);

        return (new KitIssuanceService())->getOptions(
            $warehouseLocationId > 0 ? $warehouseLocationId : null,
            $hostId > 0 ? $hostId : null
        );
    }

    /**
     * Выдача комплекта со склада: хост + опционально мониторы и ИБП.
     */
    public function actionIssueKit()
    {
        Yii::$app->response->format = Response::FORMAT_JSON;

        $hostId = (int) Yii::$app->request->post('host_id', 0);
        $monitorIds = Yii::$app->request->post('monitor_ids', []);
        if (!is_array($monitorIds)) {
            $monitorIds = $monitorIds !== '' && $monitorIds !== null ? [(int) $monitorIds] : [];
        }
        $legacyMonitorId = (int) Yii::$app->request->post('monitor_id', 0);
        if ($legacyMonitorId > 0) {
            $monitorIds[] = $legacyMonitorId;
        }
        $upsId = (int) Yii::$app->request->post('ups_id', 0);
        $userId = (int) Yii::$app->request->post('responsible_user_id', 0);
        $locationId = (int) Yii::$app->request->post('location_id', 0);
        $hostname = trim((string) Yii::$app->request->post('hostname', ''));
        $ipAddress = trim((string) Yii::$app->request->post('ip', ''));

        return (new KitIssuanceService())->issueKit(
            $hostId,
            $monitorIds,
            $upsId > 0 ? $upsId : null,
            $userId,
            $locationId,
            null,
            $hostname !== '' ? $hostname : null,
            $ipAddress !== '' ? $ipAddress : null
        );
    }
}
