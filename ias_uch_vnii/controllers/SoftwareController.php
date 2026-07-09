<?php

namespace app\controllers;

use app\components\AuditLog;
use app\components\EquipmentCharCatalog;
use app\components\LicenseAttachmentService;
use app\models\entities\DeskAttachments;
use app\models\entities\Equipment;
use app\models\entities\EquipmentSoftware;
use app\models\entities\License;
use app\models\entities\Software;
use app\models\entities\Users;
use Yii;
use yii\db\Exception as DbException;
use yii\db\Transaction;
use yii\filters\AccessControl;
use yii\filters\VerbFilter;
use yii\web\Controller;
use yii\web\ForbiddenHttpException;
use yii\web\NotFoundHttpException;
use yii\web\Response;
use yii\web\UploadedFile;

/**
 * Учёт ПО и лицензий (ТЗ 5.1.12). Только для администраторов.
 */
class SoftwareController extends Controller
{
    private LicenseAttachmentService $licenseAttachmentService;

    public function __construct($id, $module, LicenseAttachmentService $licenseAttachmentService, $config = [])
    {
        $this->licenseAttachmentService = $licenseAttachmentService;
        parent::__construct($id, $module, $config);
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
                            return Yii::$app->user->identity && Yii::$app->user->identity->isAdministrator();
                        },
                    ],
                ],
                'denyCallback' => function () {
                    throw new ForbiddenHttpException('Доступ только для администраторов.');
                },
            ],
            'verbs' => [
                'class' => VerbFilter::class,
                'actions' => [
                    'delete' => ['POST'],
                    'license-delete' => ['POST'],
                    'equipment-software-delete' => ['POST'],
                    'upload-license-attachment' => ['POST'],
                    'delete-license-attachment' => ['POST'],
                ],
            ],
        ];
    }

    public function actionIndex($name = null, $expiring_days = null)
    {
        try {
            return $this->render('index');
        } catch (DbException $e) {
            if (strpos($e->getMessage(), 'software') !== false && (strpos($e->getMessage(), 'не существует') !== false || strpos($e->getMessage(), 'does not exist') !== false)) {
                return $this->render('migrate-required');
            }
            throw $e;
        }
    }

    /**
     * JSON для AG Grid: список закупленных лицензий ПО.
     */
    public function actionGetGridData($name = null, $expiring_days = null)
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        try {
            $query = License::find()
                ->alias('l')
                ->joinWith(['software s'])
                ->orderBy(['l.valid_until' => SORT_ASC, 's.name' => SORT_ASC]);

            if ($name !== null && $name !== '') {
                $query->andWhere(['ilike', 's.name', $name]);
            }

            $today = date('Y-m-d');
            if ($expiring_days !== null && $expiring_days !== '' && (int) $expiring_days > 0) {
                $until = date('Y-m-d', strtotime('+' . (int) $expiring_days . ' days'));
                $query->andWhere(['and', ['<=', 'l.valid_until', $until], ['>=', 'l.valid_until', $today]])
                    ->andWhere(['l.is_perpetual' => false]);
            }

            $licenses = $query->all();
            $licenseIds = array_map(static fn(License $l) => (int) $l->id, $licenses);
            $equipmentMap = $this->buildLicenseEquipmentSummaryMap($licenseIds);

            $data = [];
            foreach ($licenses as $license) {
                $software = $license->software;
                $validUntil = $license->valid_until ? (string) $license->valid_until : '';
                $data[] = [
                    'id' => (int) $license->id,
                    'software_name' => $software ? (string) $software->name : '—',
                    'supplier' => (string) ($license->supplier ?? ''),
                    'purchase_date' => $license->purchase_date ? (string) $license->purchase_date : '',
                    'valid_from' => $license->valid_from ? (string) $license->valid_from : '',
                    'validity_years' => $license->validity_years !== null ? (float) $license->validity_years : null,
                    'is_perpetual' => $license->isPerpetual(),
                    'validity_display' => $license->getValidityDisplay(),
                    'valid_until' => $validUntil,
                    'seats' => (int) ($license->seats ?? 1),
                    'equipment_summary' => $equipmentMap[(int) $license->id] ?? '',
                    'expiry_status' => $license->getExpiryStatus(),
                ];
            }

            return ['success' => true, 'data' => $data, 'total' => count($data)];
        } catch (DbException $e) {
            if (strpos($e->getMessage(), 'software') !== false && (strpos($e->getMessage(), 'не существует') !== false || strpos($e->getMessage(), 'does not exist') !== false)) {
                return ['success' => false, 'message' => 'Таблицы лицензий не найдены.', 'data' => [], 'total' => 0];
            }

            return ['success' => false, 'message' => $e->getMessage(), 'data' => [], 'total' => 0];
        }
    }

    public function actionView($id)
    {
        try {
            $model = $this->findModel((int) $id);
        } catch (DbException $e) {
            if (strpos($e->getMessage(), 'software') !== false && (strpos($e->getMessage(), 'не существует') !== false || strpos($e->getMessage(), 'does not exist') !== false)) {
                return $this->render('migrate-required');
            }
            throw $e;
        }

        return $this->render('view', ['model' => $model]);
    }

    public function actionCreate()
    {
        $model = new Software();
        if ($model->load(Yii::$app->request->post()) && $model->save()) {
            AuditLog::log('software.create', 'software', $model->id, 'success', ['software_id' => $model->id]);
            Yii::$app->session->setFlash('success', 'ПО добавлено.');

            return $this->redirect(['view', 'id' => $model->id]);
        }

        return $this->render('form', ['model' => $model]);
    }

    public function actionUpdate($id)
    {
        $model = $this->findModel((int) $id);
        if ($model->load(Yii::$app->request->post()) && $model->save()) {
            AuditLog::log('software.update', 'software', $model->id, 'success', ['software_id' => $model->id]);
            Yii::$app->session->setFlash('success', 'ПО обновлено.');

            return $this->redirect(['view', 'id' => $model->id]);
        }

        return $this->render('form', ['model' => $model]);
    }

    public function actionDelete($id)
    {
        $model = $this->findModel((int) $id);
        License::deleteAll(['software_id' => $model->id]);
        EquipmentSoftware::deleteAll(['software_id' => $model->id]);
        $model->delete();
        AuditLog::log('software.delete', 'software', $model->id, 'success', ['software_id' => $model->id]);
        Yii::$app->session->setFlash('success', 'ПО удалено.');

        return $this->redirect(['index']);
    }

    public function actionLicenseCreate($software_id)
    {
        $software = $this->findModel((int) $software_id);
        $model = new License();
        $model->software_id = $software->id;
        if ($model->load(Yii::$app->request->post()) && $model->save()) {
            AuditLog::log('license.create', 'license', $model->id, 'success', ['software_id' => $software->id]);
            Yii::$app->session->setFlash('success', 'Лицензия добавлена.');

            return $this->redirect(['view', 'id' => $software->id]);
        }

        return $this->render('license-form', [
            'model' => $model,
            'software' => $software,
            'supplierNames' => EquipmentCharCatalog::getDistinctSuppliers(),
        ]);
    }

    public function actionLicenseUpdate($id)
    {
        $model = $this->findLicense((int) $id);
        $software = $model->software;
        if ($model->load(Yii::$app->request->post()) && $model->save()) {
            AuditLog::log('license.update', 'license', $model->id, 'success', ['software_id' => $software->id]);
            Yii::$app->session->setFlash('success', 'Лицензия обновлена.');

            return $this->redirect(['view', 'id' => $software->id]);
        }

        return $this->render('license-form', [
            'model' => $model,
            'software' => $software,
            'supplierNames' => EquipmentCharCatalog::getDistinctSuppliers(),
        ]);
    }

    public function actionLicenseDelete($id)
    {
        $model = $this->findLicense((int) $id);
        $softwareId = $model->software_id;
        EquipmentSoftware::updateAll(['license_id' => null], ['license_id' => (int) $id]);
        $model->delete();
        AuditLog::log('license.delete', 'license', $id, 'success', ['software_id' => $softwareId]);

        if (Yii::$app->request->isAjax) {
            Yii::$app->response->format = Response::FORMAT_JSON;

            return ['success' => true, 'message' => 'Лицензия удалена.'];
        }

        Yii::$app->session->setFlash('success', 'Лицензия удалена.');

        return $this->redirect(['index']);
    }

    /**
     * Модальное окно: создание лицензии.
     */
    public function actionLicenseCreateModal()
    {
        $model = new License();
        $model->seats = 1;

        return $this->handleLicenseModal($model, null, 'Лицензия добавлена.', 'Добавить лицензию');
    }

    /**
     * Модальное окно: редактирование лицензии.
     */
    public function actionLicenseUpdateModal($id)
    {
        $model = $this->findLicense((int) $id);

        return $this->handleLicenseModal($model, $model->software, 'Лицензия обновлена.', 'Редактировать лицензию');
    }

    public function actionUploadLicenseAttachment($id)
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $license = $this->findLicense((int) $id);
        $files = UploadedFile::getInstancesByName('uploadFiles');
        if ($files === []) {
            $single = UploadedFile::getInstanceByName('uploadFiles');
            if ($single) {
                $files = [$single];
            }
        }

        return $this->licenseAttachmentService->uploadAttachments($license, $files);
    }

    public function actionDeleteLicenseAttachment($id)
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        $license = $this->findLicense((int) $id);
        $attachmentId = (int) Yii::$app->request->post('attachment_id', 0);

        return $this->licenseAttachmentService->deleteAttachment($license, $attachmentId);
    }

    public function actionDownloadLicenseAttachment($id, $attachmentId)
    {
        $license = $this->findLicense((int) $id);
        $attachment = $this->findLicenseAttachment($license, (int) $attachmentId);
        if (!$attachment->fileExists()) {
            throw new NotFoundHttpException('Файл не найден.');
        }

        return Yii::$app->response->sendFile($attachment->getFullPath(), $attachment->original_name);
    }

    public function actionEquipmentSoftwareCreate($software_id)
    {
        $software = $this->findModel((int) $software_id);
        $model = new EquipmentSoftware();
        $model->software_id = $software->id;
        if ($model->load(Yii::$app->request->post()) && $model->save()) {
            AuditLog::log('equipment_software.create', 'equipment_software', $model->id, 'success', ['software_id' => $software->id, 'equipment_id' => $model->equipment_id]);
            Yii::$app->session->setFlash('success', 'Установка добавлена.');

            return $this->redirect(['view', 'id' => $software->id]);
        }
        $equipmentList = Equipment::find()->select(['name', 'inventory_number', 'id'])->orderBy('inventory_number')->all();
        $equipmentItems = [];
        foreach ($equipmentList as $e) {
            $equipmentItems[$e->id] = $e->inventory_number . ' — ' . $e->name;
        }

        return $this->render('equipment-software-form', ['model' => $model, 'software' => $software, 'equipmentItems' => $equipmentItems]);
    }

    public function actionEquipmentSoftwareDelete($id)
    {
        $model = EquipmentSoftware::findOne((int) $id);
        if (!$model) {
            throw new NotFoundHttpException('Запись не найдена.');
        }
        $softwareId = $model->software_id;
        $equipmentId = $model->equipment_id;
        $model->delete();
        AuditLog::log('equipment_software.delete', 'equipment_software', $id, 'success', ['software_id' => $softwareId, 'equipment_id' => $equipmentId]);
        Yii::$app->session->setFlash('success', 'Установка удалена.');

        return $this->redirect(['view', 'id' => $softwareId]);
    }

    /**
     * @return array|string|Response
     */
    protected function handleLicenseModal(
        License $model,
        ?Software $software,
        string $successMessage,
        string $modalTitle
    ) {
        if (Yii::$app->request->isPost) {
            Yii::$app->response->format = Response::FORMAT_JSON;
            $post = Yii::$app->request->post();
            $equipmentIds = $post['equipment_ids'] ?? [];
            if (!is_array($equipmentIds)) {
                $equipmentIds = [];
            }

            if (!$model->load($post)) {
                return [
                    'success' => false,
                    'message' => 'Не удалось загрузить данные формы.',
                    'errors' => $model->errors,
                ];
            }

            $licensePost = $post['License'] ?? [];
            $model->is_perpetual = !empty($licensePost['is_perpetual']);

            $softwareName = trim((string) ($post['software_name'] ?? ''));
            if ($softwareName === '' && $software) {
                $softwareName = trim((string) $software->name);
            }
            if ($softwareName === '') {
                return [
                    'success' => false,
                    'message' => 'Укажите наименование программного обеспечения.',
                    'errors' => ['software_name' => ['Укажите наименование программного обеспечения.']],
                ];
            }

            $software = $this->resolveSoftwareByName($softwareName);
            $model->software_id = $software->id;

            /** @var Transaction $tx */
            $tx = Yii::$app->db->beginTransaction();
            try {
                $isNew = $model->isNewRecord;
                if (!$model->save()) {
                    $tx->rollBack();

                    return [
                        'success' => false,
                        'errors' => $model->errors,
                        'message' => 'Не удалось сохранить'
                            . ($model->getFirstErrors() ? ': ' . implode(' ', $model->getFirstErrors()) : ''),
                    ];
                }

                $this->syncLicenseEquipment($model, $equipmentIds);

                $files = UploadedFile::getInstancesByName('uploadFiles');
                if ($files === []) {
                    $single = UploadedFile::getInstanceByName('uploadFiles');
                    if ($single) {
                        $files = [$single];
                    }
                }
                if ($files !== []) {
                    $uploadResult = $this->licenseAttachmentService->uploadAttachments($model, $files);
                    if (!$uploadResult['success']) {
                        $tx->rollBack();

                        return [
                            'success' => false,
                            'message' => $uploadResult['message'] ?? 'Не удалось загрузить документы.',
                            'errors' => ['uploadFiles' => [$uploadResult['message'] ?? 'Ошибка загрузки']],
                        ];
                    }
                }

                $tx->commit();
            } catch (\Throwable $e) {
                $tx->rollBack();
                throw $e;
            }

            $action = $isNew ? 'license.create' : 'license.update';
            AuditLog::log($action, 'license', $model->id, 'success', ['software_id' => $model->software_id]);

            return [
                'success' => true,
                'message' => $successMessage,
                'license_id' => (int) $model->id,
                'software_id' => (int) $model->software_id,
            ];
        }

        return $this->renderAjax('_license_form_modal', $this->getLicenseFormParams($model, $software, $modalTitle));
    }

    /**
     * @return array<string, mixed>
     */
    protected function getLicenseFormParams(License $model, ?Software $software, string $modalTitle): array
    {
        $equipmentIds = [];
        if (!$model->isNewRecord) {
            $equipmentIds = EquipmentSoftware::find()
                ->select('equipment_id')
                ->where(['license_id' => $model->id])
                ->column();
            $equipmentIds = array_map('intval', $equipmentIds);
        }

        return [
            'model' => $model,
            'software' => $software,
            'softwareName' => $software ? (string) $software->name : '',
            'modalTitle' => $modalTitle,
            'softwareNames' => Software::find()
                ->select('name')
                ->distinct()
                ->orderBy(['name' => SORT_ASC])
                ->column(),
            'equipmentRows' => $this->buildEquipmentRows(),
            'selectedEquipmentIds' => $equipmentIds,
            'supplierNames' => EquipmentCharCatalog::getDistinctSuppliers(),
            'attachments' => $model->isNewRecord ? [] : $this->licenseAttachmentService->getAttachmentRows($model),
        ];
    }

    protected function resolveSoftwareByName(string $name): Software
    {
        $name = trim($name);
        $software = Software::find()->where(['name' => $name])->one();
        if ($software !== null) {
            return $software;
        }

        $software = new Software();
        $software->name = $name;
        if (!$software->save()) {
            throw new \RuntimeException('Не удалось сохранить наименование ПО.');
        }

        return $software;
    }

    /**
     * @param int[] $licenseIds
     * @return array<int, string>
     */
    protected function buildLicenseEquipmentSummaryMap(array $licenseIds): array
    {
        if ($licenseIds === []) {
            return [];
        }

        $rows = EquipmentSoftware::find()
            ->alias('es')
            ->innerJoin(['e' => Equipment::tableName()], 'e.id = es.equipment_id')
            ->leftJoin(['l' => 'locations'], 'l.id = e.location_id')
            ->leftJoin(['u' => Users::tableName()], 'u.id = e.responsible_user_id')
            ->where(['es.license_id' => $licenseIds])
            ->select([
                'es.license_id',
                'e.inventory_number',
                'e.name',
                'location_name' => 'l.name',
                'user_name' => 'u.full_name',
            ])
            ->orderBy(['e.inventory_number' => SORT_ASC])
            ->asArray()
            ->all();

        $map = [];
        foreach ($rows as $row) {
            $licenseId = (int) ($row['license_id'] ?? 0);
            if ($licenseId <= 0) {
                continue;
            }
            $inv = trim((string) ($row['inventory_number'] ?? ''));
            $eqName = trim((string) ($row['name'] ?? ''));
            $title = $inv !== '' && $eqName !== '' ? $eqName . ' — ' . $inv : ($eqName !== '' ? $eqName : $inv);
            $location = trim((string) ($row['location_name'] ?? ''));
            $user = trim((string) ($row['user_name'] ?? ''));
            $meta = [];
            if ($location !== '') {
                $meta[] = $location;
            }
            if ($user !== '') {
                $meta[] = $user;
            }
            $label = $title;
            if ($meta !== []) {
                $label .= ' (' . implode(', ', $meta) . ')';
            }
            if ($label === '') {
                continue;
            }
            if (!isset($map[$licenseId])) {
                $map[$licenseId] = [];
            }
            $map[$licenseId][] = $label;
        }

        foreach ($map as $licenseId => $labels) {
            $map[$licenseId] = implode('; ', array_unique($labels));
        }

        return $map;
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    protected function buildEquipmentRows(): array
    {
        $equipmentList = Equipment::find()
            ->alias('e')
            ->with(['location', 'responsibleUser'])
            ->orderBy(['e.inventory_number' => SORT_ASC])
            ->all();

        $rows = [];
        foreach ($equipmentList as $equipment) {
            $rows[] = [
                'id' => (int) $equipment->id,
                'inventory_number' => trim((string) $equipment->inventory_number),
                'name' => trim((string) $equipment->name),
                'location' => $equipment->location ? trim((string) $equipment->location->name) : '',
                'responsible' => $equipment->responsibleUser
                    ? trim((string) $equipment->responsibleUser->getDisplayName())
                    : '',
            ];
        }

        return $rows;
    }

    /**
     * @param array<int|string, mixed> $equipmentIds
     */
    protected function syncLicenseEquipment(License $license, array $equipmentIds): void
    {
        $equipmentIds = array_values(array_unique(array_filter(array_map('intval', $equipmentIds))));
        $softwareId = (int) $license->software_id;

        EquipmentSoftware::updateAll(
            ['license_id' => null],
            [
                'and',
                ['license_id' => (int) $license->id],
                ['not in', 'equipment_id', $equipmentIds !== [] ? $equipmentIds : [0]],
            ]
        );

        foreach ($equipmentIds as $equipmentId) {
            $link = EquipmentSoftware::findOne([
                'equipment_id' => $equipmentId,
                'software_id' => $softwareId,
            ]);
            if ($link === null) {
                $link = new EquipmentSoftware();
                $link->equipment_id = $equipmentId;
                $link->software_id = $softwareId;
            }
            $link->license_id = (int) $license->id;
            $link->save(false);
        }
    }

    protected function findModel(int $id): Software
    {
        if (($m = Software::findOne($id)) !== null) {
            return $m;
        }
        throw new NotFoundHttpException('ПО не найдено.');
    }

    protected function findLicense(int $id): License
    {
        if (($m = License::findOne($id)) !== null) {
            return $m;
        }
        throw new NotFoundHttpException('Лицензия не найдена.');
    }

    protected function findLicenseAttachment(License $license, int $attachmentId): DeskAttachments
    {
        if (!$this->licenseAttachmentService->licenseOwnsAttachment((int) $license->id, $attachmentId)) {
            throw new NotFoundHttpException('Вложение не найдено.');
        }
        $attachment = DeskAttachments::findOne($attachmentId);
        if ($attachment === null) {
            throw new NotFoundHttpException('Вложение не найдено.');
        }

        return $attachment;
    }
}
