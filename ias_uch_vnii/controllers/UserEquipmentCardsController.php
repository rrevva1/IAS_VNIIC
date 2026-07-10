<?php

namespace app\controllers;

use app\components\UserEquipmentCardService;
use app\models\entities\UserEquipmentCard;
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

    public function actionIndex(string $tab = 'all', string $q = '')
    {
        if (!UserEquipmentCardService::isCardsTableReady()) {
            Yii::$app->session->setFlash(
                'warning',
                'Раздел карточек недоступен до применения миграций. Выполните: php yii migrate'
            );
            return $this->redirect(['arm/index']);
        }

        return $this->render('index', [
            'tab' => $tab,
            'q' => trim($q),
        ]);
    }

    public function actionGetGridData(string $tab = 'all', string $q = '', int $limit = 20, int $offset = 0, string $sortModel = '')
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
        if (!UserEquipmentCardService::isCardsTableReady()) {
            return ['success' => false, 'message' => 'Таблицы карточек не созданы.', 'data' => [], 'total' => 0];
        }

        try {
            $q = trim($q);
            $limit = max(1, min(5000, $limit));
            $offset = max(0, $offset);

            $query = $this->buildCardsQuery($tab, $q, $sortModel);
            $pageUserIds = (clone $query)
                ->select('c.user_id')
                ->limit($limit)
                ->offset($offset)
                ->column();
            foreach (array_unique(array_map('intval', $pageUserIds)) as $userId) {
                UserEquipmentCardService::ensureCardForUser($userId);
            }

            $query = $this->buildCardsQuery($tab, $q, $sortModel);
            $total = (int) (clone $query)->count('c.id');
            $models = $query->limit($limit)->offset($offset)->all();
            $rows = [];
            foreach ($models as $card) {
                $rows[] = [
                    'id' => (int) $card->id,
                    'user_id' => (int) $card->user_id,
                    'user_name' => $card->user ? (string) $card->user->getDisplayName() : '—',
                    'version_no' => (int) $card->version_no,
                    'is_signed' => (bool) $card->is_signed,
                    'signed_by_admin' => $card->signedByAdmin ? (string) $card->signedByAdmin->getDisplayName() : '—',
                    'updated_at' => (string) ($card->updated_at ?: $card->created_at),
                ];
            }

            return ['success' => true, 'data' => $rows, 'total' => $total];
        } catch (\Throwable $e) {
            Yii::error('Cards grid error: ' . $e->getMessage(), __METHOD__);
            return ['success' => false, 'message' => 'Ошибка загрузки данных карточек.', 'data' => [], 'total' => 0];
        }
    }

    private function buildCardsQuery(string $tab, string $q, string $sortModel = '')
    {
        $query = UserEquipmentCard::find()
            ->alias('c')
            ->with(['user', 'signedByAdmin'])
            ->joinWith(['user u', 'signedByAdmin sba']);

        if ($tab === 'unsigned') {
            $query->andWhere(['c.is_signed' => false]);
        }

        if ($q !== '') {
            $query->andWhere([
                'or',
                ['ilike', 'u.full_name', $q],
                ['ilike', 'u.username', $q],
                ['ilike', 'u.email', $q],
            ]);
        }

        $sort = $this->buildSortOrder($sortModel);
        if (!empty($sort)) {
            $query->orderBy($sort);
        } else {
            $query->orderBy(['u.full_name' => SORT_ASC, 'c.id' => SORT_DESC]);
        }

        return $query;
    }

    private function buildSortOrder(string $sortModelRaw): array
    {
        $sortModelRaw = trim($sortModelRaw);
        if ($sortModelRaw === '') {
            return [];
        }

        $decoded = json_decode($sortModelRaw, true);
        if (!is_array($decoded)) {
            return [];
        }

        $allowed = [
            'id' => 'c.id',
            'user_name' => 'u.full_name',
            'version_no' => 'c.version_no',
            'is_signed' => 'c.is_signed',
            'signed_by_admin' => 'sba.full_name',
            'updated_at' => 'c.updated_at',
        ];

        $orderBy = [];
        foreach ($decoded as $item) {
            if (!is_array($item)) {
                continue;
            }
            $colId = isset($item['colId']) ? (string) $item['colId'] : '';
            $dir = isset($item['sort']) ? strtolower((string) $item['sort']) : '';
            if (!isset($allowed[$colId])) {
                continue;
            }
            if ($dir !== 'asc' && $dir !== 'desc') {
                continue;
            }
            $orderBy[$allowed[$colId]] = $dir === 'asc' ? SORT_ASC : SORT_DESC;
        }

        if (!empty($orderBy) && !isset($orderBy['c.id'])) {
            $orderBy['c.id'] = SORT_DESC;
        }

        return $orderBy;
    }

    /**
     * Список закреплённой техники пользователя (модальное окно).
     */
    public function actionUserEquipment(int $userId)
    {
        if (!UserEquipmentCardService::isCardsTableReady()) {
            throw new NotFoundHttpException('Раздел карточек недоступен.');
        }

        $data = UserEquipmentCardService::buildCardData($userId);
        if ($data['user'] === null) {
            throw new NotFoundHttpException('Пользователь не найден.');
        }

        return $this->renderAjax('_user_equipment_content', [
            'user' => $data['user'],
            'equipment' => $data['equipment'],
            'isModal' => true,
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
        $isAjax = Yii::$app->request->isAjax;
        if ($isAjax) {
            Yii::$app->response->format = Response::FORMAT_JSON;
        }

        if (!UserEquipmentCardService::isCardsTableReady()) {
            if ($isAjax) {
                return ['success' => false, 'message' => 'Таблицы карточек не созданы. Выполните миграции.'];
            }
            Yii::$app->session->setFlash('warning', 'Таблицы карточек не созданы. Выполните миграции.');
            return $this->redirect(['arm/index']);
        }

        $card = UserEquipmentCard::findOne($id);
        if (!$card) {
            if ($isAjax) {
                return ['success' => false, 'message' => 'Карточка не найдена.'];
            }
            throw new NotFoundHttpException('Карточка не найдена.');
        }
        $card->is_signed = true;
        $card->signed_at = date('Y-m-d H:i:s');
        $card->signed_by_admin_id = Yii::$app->user->id;
        $card->save(false);

        if ($isAjax) {
            return ['success' => true];
        }
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

