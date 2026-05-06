<?php

namespace app\controllers;

use app\components\UserEquipmentCardService;
use app\models\entities\UserEquipmentCard;
use app\models\entities\Users;
use Yii;
use yii\filters\AccessControl;
use yii\filters\VerbFilter;
use yii\web\Controller;
use yii\web\NotFoundHttpException;
use yii\web\Response;

class UserEquipmentCardsController extends Controller
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
                        'matchCallback' => static function () {
                            return Yii::$app->user->identity && Yii::$app->user->identity->isAdministrator();
                        },
                    ],
                ],
            ],
            'verbs' => [
                'class' => VerbFilter::class,
                'actions' => [
                    'mark-signed' => ['POST'],
                ],
            ],
        ];
    }

    public function actionIndex(string $tab = 'all')
    {
        if (!UserEquipmentCardService::isCardsTableReady()) {
            Yii::$app->session->setFlash(
                'warning',
                'Раздел карточек недоступен до применения миграций. Выполните: php yii migrate'
            );
            return $this->redirect(['arm/index']);
        }

        $users = Users::find()->orderBy(['full_name' => SORT_ASC])->all();
        foreach ($users as $user) {
            UserEquipmentCardService::ensureCardForUser((int) $user->id);
        }

        $query = UserEquipmentCard::find()->with(['user', 'signedByAdmin'])->orderBy(['updated_at' => SORT_DESC, 'id' => SORT_DESC]);
        if ($tab === 'unsigned') {
            $query->andWhere(['is_signed' => false]);
        }

        return $this->render('index', [
            'cards' => $query->all(),
            'tab' => $tab,
        ]);
    }

    public function actionDownload(int $userId)
    {
        if (!UserEquipmentCardService::isCardsTableReady()) {
            Yii::$app->session->setFlash('warning', 'Таблицы карточек не созданы. Выполните миграции.');
            return $this->redirect(['arm/index']);
        }

        $data = UserEquipmentCardService::buildCardData($userId);
        if (empty($data['equipment'])) {
            Yii::$app->session->setFlash('warning', 'У пользователя нет закрепленной техники. Карточка не требуется.');
            return $this->redirect(['index']);
        }

        $tmpFile = tempnam(sys_get_temp_dir(), 'card_');
        $docxPath = $tmpFile . '.docx';
        @unlink($tmpFile);

        $this->createDocxFile($docxPath, $data);

        return Yii::$app->response->sendFile(
            $docxPath,
            'equipment_card_user_' . $userId . '.docx',
            ['mimeType' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'inline' => false]
        );
    }

    public function actionMarkSigned(int $id)
    {
        if (!UserEquipmentCardService::isCardsTableReady()) {
            Yii::$app->session->setFlash('warning', 'Таблицы карточек не созданы. Выполните миграции.');
            return $this->redirect(['arm/index']);
        }

        $card = UserEquipmentCard::findOne($id);
        if (!$card) {
            throw new NotFoundHttpException('Карточка не найдена.');
        }
        $card->is_signed = true;
        $card->signed_at = date('Y-m-d H:i:s');
        $card->signed_by_admin_id = Yii::$app->user->id;
        $card->save(false);

        Yii::$app->session->setFlash('success', 'Подписание карточки подтверждено администратором.');
        return $this->redirect(['index']);
    }

    private function createDocxFile(string $targetPath, array $data): void
    {
        $user = $data['user'];
        $equipment = $data['equipment'];
        $templatePath = Yii::getAlias('@app/docs/reports/шаблон_карточки_польз.docx');
        if (!is_file($templatePath)) {
            throw new \RuntimeException('Шаблон карточки не найден: ' . $templatePath);
        }

        if (!copy($templatePath, $targetPath)) {
            throw new \RuntimeException('Не удалось создать файл по шаблону.');
        }

        $zip = new \ZipArchive();
        if ($zip->open($targetPath) !== true) {
            throw new \RuntimeException('Не удалось открыть DOCX шаблон.');
        }

        $documentXml = $zip->getFromName('word/document.xml');
        if ($documentXml === false) {
            $zip->close();
            throw new \RuntimeException('Не найден word/document.xml в шаблоне.');
        }

        $fullName = $user ? (string) $user->full_name : '—';
        $room = '—';
        foreach ($equipment as $eq) {
            if ($eq->location && trim((string) $eq->location->name) !== '') {
                $room = (string) $eq->location->name;
                break;
            }
        }

        $documentXml = str_replace('Иванов Иван Иванович', $this->xmlEscape($fullName), $documentXml);
        $documentXml = str_replace('408а', $this->xmlEscape($room), $documentXml);
        $documentXml = $this->replaceTemplateTableRows($documentXml, $equipment);

        $zip->addFromString('word/document.xml', $documentXml);
        $zip->close();
    }

    private function xmlEscape(string $text): string
    {
        return htmlspecialchars($text, ENT_XML1 | ENT_QUOTES, 'UTF-8');
    }

    private function replaceTemplateTableRows(string $documentXml, array $equipment): string
    {
        if (!preg_match('/(<w:tbl>.*?<w:tr\b.*?<\/w:tr>)(.*?)(<\/w:tbl>)/s', $documentXml, $m)) {
            return $documentXml;
        }
        $tableHeadAndHeaderRow = $m[1];
        $tableTail = $m[3];

        $rowsXml = '';
        $today = date('d.m.Y');
        foreach ($equipment as $eq) {
            $name = (string) ($eq->name ?? '');
            $inv = (string) ($eq->inventory_number ?? '');
            $unit = trim((string) ($eq->equipment_type ?? ''));
            if ($unit === '') {
                $unit = 'ТС';
            }
            $rowsXml .= $this->buildTableRowXml($today, $name, $inv, $unit, '1', '');
        }
        if ($rowsXml === '') {
            $rowsXml = $this->buildTableRowXml($today, 'Нет закрепленной техники', '', '', '', '');
        }

        $newTable = $tableHeadAndHeaderRow . $rowsXml . $tableTail;
        return preg_replace('/<w:tbl>.*?<\/w:tbl>/s', $newTable, $documentXml, 1) ?? $documentXml;
    }

    private function buildTableRowXml(
        string $date,
        string $name,
        string $inventory,
        string $unit,
        string $count,
        string $signature
    ): string {
        return '<w:tr>'
            . $this->buildCellXml($date, true)
            . $this->buildCellXml($name, false)
            . $this->buildCellXml($inventory, true)
            . $this->buildCellXml($unit, true)
            . $this->buildCellXml($count, true)
            . $this->buildCellXml($signature, false)
            . '</w:tr>';
    }

    private function buildCellXml(string $text, bool $center): string
    {
        $safe = $this->xmlEscape($text);
        $jc = $center ? '<w:jc w:val="center"/>' : '';
        return '<w:tc><w:tcPr/><w:p><w:pPr>' . $jc . '</w:pPr><w:r><w:t xml:space="preserve">' . $safe . '</w:t></w:r></w:p></w:tc>';
    }
}

