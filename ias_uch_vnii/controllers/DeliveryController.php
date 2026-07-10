<?php

namespace app\controllers;

use app\components\DeliveryService;
use app\components\EquipmentCharCatalog;
use app\components\AuditLog;
use app\models\entities\EquipmentDelivery;
use app\models\entities\EquipmentDeliveryLine;
use app\models\entities\EquipmentDeliveryUnit;
use app\models\entities\DeskAttachments;
use app\models\entities\Location;
use app\models\entities\EquipmentTypes;
use app\models\search\DeliverySearch;
use Yii;
use yii\filters\AccessControl;
use yii\filters\VerbFilter;
use yii\helpers\ArrayHelper;
use yii\web\Controller;
use yii\web\ForbiddenHttpException;
use yii\web\NotFoundHttpException;
use yii\web\Response;
use yii\web\UploadedFile;

/**
 * Раздел «Поставки» — массовый ввод техники на склад.
 */
class DeliveryController extends Controller
{
    private DeliveryService $deliveryService;

    public function init()
    {
        parent::init();
        $this->deliveryService = new DeliveryService();
    }

    public function behaviors()
    {
        return [
            'access' => [
                'class' => AccessControl::class,
                'rules' => [
                    [
                        'allow' => true,
                        'roles' => ['@'],
                        'matchCallback' => function () {
                            return Yii::$app->user->identity && Yii::$app->user->identity->canAccessArm();
                        },
                    ],
                ],
                'denyCallback' => function () {
                    throw new ForbiddenHttpException('Доступ запрещён.');
                },
            ],
            'verbs' => [
                'class' => VerbFilter::class,
                'actions' => [
                    'delete' => ['POST'],
                    'delete-line' => ['POST'],
                    'post-delivery' => ['POST'],
                    'save-line' => ['POST'],
                    'bulk-serials' => ['POST'],
                    'bulk-inventory' => ['POST'],
                    'save-header' => ['POST'],
                    'create-draft' => ['POST'],
                    'upload-attachment' => ['POST'],
                    'delete-attachment' => ['POST'],
                ],
            ],
        ];
    }

    public function actionIndex()
    {
        $openId = (string) Yii::$app->request->get('open', '');
        if ($openId === '' && (string) Yii::$app->request->get('id', '') !== '') {
            $openId = (string) Yii::$app->request->get('id', '');
        }

        return $this->render('index', array_merge([
            'openDeliveryId' => preg_match('/^\d+$/', $openId) ? $openId : '',
            'equipmentTypes' => EquipmentTypes::getList(),
            'warehouses' => $this->getWarehouseMap(),
        ], $this->getArmFormScriptParams()));
    }

    public function actionGetGridData()
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $searchModel = new DeliverySearch();
        $provider = $searchModel->search(Yii::$app->request->queryParams);
        $data = [];

        foreach ($provider->getModels() as $model) {
            /** @var EquipmentDelivery $model */
            $stats = DeliverySearch::getDeliveryStats((int) $model->id);
            $data[] = [
                'id' => (int) $model->id,
                'name' => $model->name,
                'supplier' => $model->supplier ?? '',
                'delivery_date' => $this->formatDeliveryDateForGrid($model->delivery_date),
                'status' => $model->status,
                'status_label' => $model->getStatusLabel(),
                'units_total' => $stats['units_total'],
            ];
        }

        return ['success' => true, 'data' => $data, 'total' => count($data)];
    }

    public function actionCreate()
    {
        return $this->redirect(['index']);
    }

    /**
     * @deprecated Открывается модальное окно на index.
     */
    public function actionView($id)
    {
        return $this->redirect(['index', 'open' => (int) $id]);
    }

    /**
     * Быстрое создание черновика поставки (открывается сразу карточка).
     */
    public function actionCreateDraft()
    {
        Yii::$app->response->format = Response::FORMAT_JSON;

        $warehouses = $this->getWarehouseMap();
        if ($warehouses === []) {
            return [
                'success' => false,
                'message' => 'В справочнике нет помещений с типом «склад». Добавьте склад, чтобы создать поставку.',
            ];
        }

        $model = new EquipmentDelivery();
        $model->status = EquipmentDelivery::STATUS_DRAFT;
        $model->delivery_date = date('Y-m-d');
        $model->name = 'Новая поставка';

        if (!$model->save()) {
            return [
                'success' => false,
                'message' => 'Не удалось создать поставку.',
                'errors' => $model->errors,
            ];
        }

        return [
            'success' => true,
            'message' => 'Черновик создан. Заполните данные и добавьте строки с техникой.',
            'delivery_id' => (int) $model->id,
        ];
    }

    /**
     * Модальное окно карточки поставки.
     */
    public function actionCardModal($id)
    {
        $model = $this->findModel((int) $id);
        $lines = EquipmentDeliveryLine::find()
            ->where(['delivery_id' => $model->id])
            ->with(['warehouseLocation'])
            ->orderBy(['sort_order' => SORT_ASC, 'id' => SORT_ASC])
            ->all();

        $lineId = (int) Yii::$app->request->get('line_id', 0);
        if ($lineId <= 0 && $lines !== []) {
            $lineId = (int) $lines[0]->id;
        }

        return $this->renderAjax('_card_content', array_merge($this->getFormParams($model), [
            'lines' => $lines,
            'lineId' => $lineId,
            'stats' => DeliverySearch::getDeliveryStats((int) $model->id),
            'isDraft' => $model->isDraft(),
            'canEditHeader' => $model->isDraft() || $model->status === EquipmentDelivery::STATUS_POSTED,
        ]));
    }

    public function actionSaveHeader($id)
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $model = $this->findModel((int) $id);
        if (!$model->load(Yii::$app->request->post()) || !$model->save()) {
            return [
                'success' => false,
                'message' => 'Не удалось сохранить.',
                'errors' => $model->errors,
            ];
        }
        if ($model->isPosted()) {
            $this->deliveryService->syncDeliveryHeaderToEquipment($model);
        }

        return ['success' => true, 'message' => 'Сохранено.'];
    }

    public function actionSaveLine($id)
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $delivery = $this->findModel((int) $id);
        $lineId = Yii::$app->request->post('line_id');
        $lineId = $lineId !== null && $lineId !== '' ? (int) $lineId : null;

        return $this->deliveryService->saveLine($delivery, Yii::$app->request->post(), $lineId);
    }

    public function actionDeleteLine($id)
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $delivery = $this->findModel((int) $id);
        if (!$delivery->isDraft()) {
            return ['success' => false, 'message' => 'Удаление строк доступно только в черновике.'];
        }

        $lineId = (int) Yii::$app->request->post('line_id', 0);
        $line = EquipmentDeliveryLine::findOne(['id' => $lineId, 'delivery_id' => $delivery->id]);
        if (!$line) {
            return ['success' => false, 'message' => 'Строка не найдена.'];
        }

        $blocked = EquipmentDeliveryUnit::find()
            ->where(['line_id' => $line->id])
            ->andWhere(['not', ['equipment_id' => null]])
            ->exists();
        if ($blocked) {
            return ['success' => false, 'message' => 'Нельзя удалить строку с уже созданной техникой.'];
        }

        $line->delete();

        return ['success' => true, 'message' => 'Строка удалена.'];
    }

    public function actionGetUnits($id)
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $this->findModel((int) $id);
        $lineId = Yii::$app->request->get('line_id');
        $search = Yii::$app->request->get('search');

        return [
            'success' => true,
            'data' => $this->deliveryService->getUnitsGridRows(
                (int) $id,
                $lineId ? (int) $lineId : null,
                $search !== null ? (string) $search : null
            ),
        ];
    }

    public function actionBulkSerials($id)
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $this->findModel((int) $id);
        $lineId = (int) Yii::$app->request->post('line_id', 0);
        $text = (string) Yii::$app->request->post('text', '');
        $mode = (string) Yii::$app->request->post('mode', 'seq');

        if ($lineId <= 0) {
            return ['success' => false, 'message' => 'Укажите строку поставки.'];
        }

        return $this->deliveryService->applyBulkSerials($lineId, $text, $mode);
    }

    public function actionBulkInventory($id)
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $this->findModel((int) $id);
        $lineId = Yii::$app->request->post('line_id');
        $text = (string) Yii::$app->request->post('text', '');
        $mode = (string) Yii::$app->request->post('mode', 'seq');

        return $this->deliveryService->applyBulkInventory(
            (int) $id,
            $text,
            $lineId !== null && $lineId !== '' ? (int) $lineId : null,
            $mode
        );
    }

    public function actionPostDelivery($id)
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $delivery = $this->findModel((int) $id);
        $result = $this->deliveryService->postDelivery($delivery);
        if ($result['success']) {
            AuditLog::log('delivery.post', 'equipment_deliveries', $delivery->id, 'success');
        }

        return $result;
    }

    public function actionDelete($id)
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $model = $this->findModel((int) $id);
        if (!$model->isDraft()) {
            return ['success' => false, 'message' => 'Удалить можно только черновик.'];
        }

        $hasEquipment = EquipmentDeliveryUnit::find()
            ->alias('u')
            ->innerJoin(['l' => EquipmentDeliveryLine::tableName()], 'l.id = u.line_id')
            ->where(['l.delivery_id' => $model->id])
            ->andWhere(['not', ['u.equipment_id' => null]])
            ->exists();
        if ($hasEquipment) {
            return ['success' => false, 'message' => 'Нельзя удалить поставку с созданной техникой.'];
        }

        foreach ($this->deliveryService->getAttachmentRows($model) as $row) {
            $this->deliveryService->deleteAttachment($model, (int) $row['id']);
        }

        $model->delete();

        return ['success' => true, 'message' => 'Поставка удалена.'];
    }

    public function actionExportUnits($id)
    {
        $delivery = $this->findModel((int) $id);
        $rows = $this->deliveryService->getUnitsGridRows((int) $delivery->id);

        $lines = ['seq;equipment_type;name;serial_number;inventory_number'];
        $seq = 0;
        foreach ($rows as $row) {
            $seq++;
            $lines[] = implode(';', [
                $seq,
                $row['line_type'],
                str_replace(';', ',', $row['line_name']),
                $row['serial_number'],
                $row['inventory_number'],
            ]);
        }

        $content = "\xEF\xBB\xBF" . implode("\n", $lines) . "\n";
        Yii::$app->response->format = Response::FORMAT_RAW;
        Yii::$app->response->headers->set('Content-Type', 'text/csv; charset=UTF-8');
        Yii::$app->response->headers->set(
            'Content-Disposition',
            'attachment; filename="delivery_' . $delivery->id . '_units.csv"'
        );

        return $content;
    }

    /**
     * @return array<string, mixed>
     */
    /**
     * @return array<string, mixed>
     */
    private function getFormParams(EquipmentDelivery $model): array
    {
        return [
            'model' => $model,
            'supplierNames' => EquipmentCharCatalog::getDistinctSuppliers(),
            'statusList' => EquipmentDelivery::getStatusList(),
            'attachments' => $this->deliveryService->getAttachmentRows($model),
            'canEditAttachments' => $model->canEditAttachments(),
        ];
    }

    public function actionUploadAttachment($id)
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $delivery = $this->findModel((int) $id);
        $files = UploadedFile::getInstancesByName('uploadFiles');
        if ($files === []) {
            $single = UploadedFile::getInstanceByName('uploadFiles');
            if ($single) {
                $files = [$single];
            }
        }

        return $this->deliveryService->uploadAttachments($delivery, $files);
    }

    public function actionDeleteAttachment($id)
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $delivery = $this->findModel((int) $id);
        $attachmentId = (int) Yii::$app->request->post('attachment_id', 0);

        return $this->deliveryService->deleteAttachment($delivery, $attachmentId);
    }

    public function actionDownloadAttachment($id, $attachmentId)
    {
        $delivery = $this->findModel((int) $id);
        $attachment = $this->findDeliveryAttachment($delivery, (int) $attachmentId);
        if (!$attachment->fileExists()) {
            throw new NotFoundHttpException('Файл не найден.');
        }
        $response = Yii::$app->response;
        $response->headers->set('X-Content-Type-Options', 'nosniff');

        return $response->sendFile($attachment->getFullPath(), $attachment->original_name);
    }

    public function actionPreviewAttachment($id, $attachmentId)
    {
        $delivery = $this->findModel((int) $id);
        $attachment = $this->findDeliveryAttachment($delivery, (int) $attachmentId);
        if (!$attachment->fileExists()) {
            throw new NotFoundHttpException('Файл не найден.');
        }

        $extension = strtolower((string) $attachment->file_extension);
        $mimeTypes = [
            'pdf' => 'application/pdf',
            'png' => 'image/png',
            'jpg' => 'image/jpeg',
            'jpeg' => 'image/jpeg',
            'gif' => 'image/gif',
            'bmp' => 'image/bmp',
        ];
        $mimeType = $mimeTypes[$extension] ?? 'application/octet-stream';
        $response = Yii::$app->response;
        $response->headers->set('Content-Type', $mimeType);
        $response->headers->set('X-Content-Type-Options', 'nosniff');
        if ($extension === 'pdf' || isset($mimeTypes[$extension])) {
            $response->headers->set('Content-Disposition', 'inline; filename="' . addslashes($attachment->original_name) . '"');

            return $response->sendFile($attachment->getFullPath(), $attachment->original_name, ['inline' => true]);
        }

        return $response->sendFile($attachment->getFullPath(), $attachment->original_name);
    }

    /**
     * Параметры для arm/_form_scripts и datalists на странице поставок.
     *
     * @return array<string, mixed>
     */
    private function getArmFormScriptParams(): array
    {
        $orgTechFields = $this->filterDeliveryLineCharFields(array_merge(
            EquipmentCharCatalog::getPrinterMfuFormFieldDefinitions(),
            [
                [
                    'name' => 'cartridge_procurement',
                    'label' => 'Учёт для закупки картриджей',
                    'widget' => 'cartridge-select',
                ],
            ]
        ));
        $armFormTemplateData = EquipmentCharCatalog::buildFormFieldTemplates($orgTechFields, true);

        return [
            'chars' => [],
            'orgTech' => [],
            'orgTechFields' => $orgTechFields,
            'armFormFieldTemplates' => $armFormTemplateData['templates'],
            'cpuModels' => EquipmentCharCatalog::getDistinctCpuModels(),
            'ramModels' => EquipmentCharCatalog::getDistinctRamValues(),
            'osModels' => EquipmentCharCatalog::getDistinctOsValues(),
            'diskModels' => EquipmentCharCatalog::getDistinctDiskModels(),
            'ipAddresses' => [],
            'upsBatteryModels' => EquipmentCharCatalog::getDistinctUpsBatteryModels(),
            'inventoryNumbers' => EquipmentCharCatalog::getDistinctInventoryNumbers(),
            'equipmentNames' => EquipmentCharCatalog::getDistinctEquipmentNames(),
            'screenDiagonalValues' => EquipmentCharCatalog::getDistinctScreenDiagonalValues(),
            'supplierNames' => EquipmentCharCatalog::getDistinctSuppliers(),
            'locationNames' => ArrayHelper::getColumn(
                Location::find()->orderBy(['name' => SORT_ASC])->all(),
                'name'
            ),
            'currentSupplier' => '',
            'currentLocation' => '',
            'currentInventoryNumber' => '',
            'currentEquipmentName' => '',
            'currentScreenDiagonal' => '',
            'isModal' => false,
        ];
    }

    /**
     * Поля характеристик строки поставки (без имени ПК и IP).
     *
     * @param array<int, array<string, mixed>> $fields
     * @return array<int, array<string, mixed>>
     */
    private function filterDeliveryLineCharFields(array $fields): array
    {
        $exclude = ['hostname', 'ip'];

        return array_values(array_filter($fields, static function (array $field) use ($exclude): bool {
            return !in_array((string) ($field['name'] ?? ''), $exclude, true);
        }));
    }

    /**
     * Дата поставки для грида (дд.мм.гггг), как «Дата закупки» в учёте ТС.
     */
    private function formatDeliveryDateForGrid(?string $raw): string
    {
        if ($raw === null || trim($raw) === '') {
            return '';
        }
        try {
            return (new \DateTimeImmutable(trim($raw)))->format('d.m.Y');
        } catch (\Exception $e) {
            return trim($raw);
        }
    }

    /**
     * @return array<int, string>
     */
    private function getWarehouseMap(): array
    {
        return ArrayHelper::map(
            Location::find()
                ->where(['location_type' => 'склад', 'is_archived' => false])
                ->orderBy(['name' => SORT_ASC])
                ->all(),
            'id',
            'name'
        );
    }

    protected function findDeliveryAttachment(EquipmentDelivery $delivery, int $attachmentId): DeskAttachments
    {
        if (!$this->deliveryService->deliveryOwnsAttachment((int) $delivery->id, $attachmentId)) {
            throw new NotFoundHttpException('Вложение не найдено.');
        }
        $attachment = DeskAttachments::findOne($attachmentId);
        if ($attachment === null) {
            throw new NotFoundHttpException('Вложение не найдено.');
        }

        return $attachment;
    }

    protected function findModel(int $id): EquipmentDelivery
    {
        $model = EquipmentDelivery::find()
            ->where(['id' => $id])
            ->with(['warehouseLocation', 'createdByUser'])
            ->one();
        if ($model !== null) {
            return $model;
        }

        throw new NotFoundHttpException('Поставка не найдена.');
    }
}
