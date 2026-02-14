<?php

namespace app\controllers;

use app\models\entities\Software;
use app\models\entities\License;
use app\models\entities\EquipmentSoftware;
use app\models\entities\Equipment;
use app\components\AuditLog;
use Yii;
use yii\db\Exception as DbException;
use yii\filters\AccessControl;
use yii\filters\VerbFilter;
use yii\web\Controller;
use yii\web\ForbiddenHttpException;
use yii\web\NotFoundHttpException;

/**
 * Учёт ПО и лицензий (ТЗ 5.1.12). Только для администраторов.
 * Таблицы: software, licenses, equipment_software (эталон БД).
 */
class SoftwareController extends Controller
{
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
                ],
            ],
        ];
    }

    public function actionIndex($name = null, $expiring_days = null)
    {
        try {
            $query = Software::find()->orderBy(['name' => SORT_ASC]);
            if ($name !== null && $name !== '') {
                $query->andWhere(['ilike', 'name', $name]);
            }
            if ($expiring_days !== null && $expiring_days !== '' && (int) $expiring_days > 0) {
                $until = date('Y-m-d', strtotime('+' . (int) $expiring_days . ' days'));
                $today = date('Y-m-d');
                $ids = License::find()
                    ->select('software_id')
                    ->where(['<=', 'valid_until', $until])
                    ->andWhere(['>=', 'valid_until', $today])
                    ->column();
                $query->andWhere(['id' => $ids ?: [0]]);
            }
            $list = $query->all();
        } catch (DbException $e) {
            if (strpos($e->getMessage(), 'software') !== false && (strpos($e->getMessage(), 'не существует') !== false || strpos($e->getMessage(), 'does not exist') !== false)) {
                return $this->render('migrate-required');
            }
            throw $e;
        }
        return $this->render('index', ['list' => $list]);
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
        return $this->render('license-form', ['model' => $model, 'software' => $software]);
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
        return $this->render('license-form', ['model' => $model, 'software' => $software]);
    }

    public function actionLicenseDelete($id)
    {
        $model = $this->findLicense((int) $id);
        $softwareId = $model->software_id;
        $model->delete();
        AuditLog::log('license.delete', 'license', $id, 'success', ['software_id' => $softwareId]);
        Yii::$app->session->setFlash('success', 'Лицензия удалена.');
        return $this->redirect(['view', 'id' => $softwareId]);
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
}
