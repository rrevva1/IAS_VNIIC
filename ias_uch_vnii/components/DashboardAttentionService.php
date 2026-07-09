<?php

namespace app\components;

use app\models\dictionaries\DicTaskStatus;
use app\models\entities\Equipment;
use app\models\entities\EquipmentDelivery;
use app\models\entities\License;
use app\models\entities\PartCharValues;
use app\models\entities\SprChars;
use app\models\entities\SprParts;
use app\models\entities\Tasks;
use app\models\entities\UserEquipmentCard;
use app\models\entities\Users;
use app\models\entities\WorkTask;
use app\models\search\WorkTaskSearch;
use Yii;

/**
 * Сводка проблем и сроков для главной страницы «Требует внимания».
 */
class DashboardAttentionService
{
    private const LIST_LIMIT = 5;

    /** Порог «истекает» для гарантии и аккумуляторов ИБП, дней. */
    private const WARNING_DAYS = 30;

    private Users $user;

    public function __construct(Users $user)
    {
        $this->user = $user;
    }

    /**
     * @return array{
     *     summary: array{critical: int, warning: int, info: int},
     *     widgets: array<int, array<string, mixed>>
     * }
     */
    public function build(): array
    {
        $widgets = [];

        if ($this->user->isAdministrator()) {
            $widgets[] = $this->buildLicensesExpiredWidget();
            $widgets[] = $this->buildLicensesExpiringWidget();
            $widgets[] = $this->buildUnsignedCardsWidget();
            $widgets[] = $this->buildDeliveryDraftsWidget();
        }

        if ($this->user->canAccessArm()) {
            $widgets[] = $this->buildEquipmentInRepairWidget();
            $widgets[] = $this->buildWarrantyExpiringWidget();
            foreach ($this->buildUpsBatteryWidgets() as $upsWidget) {
                $widgets[] = $upsWidget;
            }
        }

        if ($this->user->isSupportStaff()) {
            $widgets[] = $this->buildNewTasksWidget();
            $widgets[] = $this->buildTasksInProgressWidget();
            $widgets[] = $this->buildWorkTasksPendingReviewWidget();
        } elseif ($this->user->isRegularUser()) {
            $widgets[] = $this->buildMyOpenTasksWidget();
        }

        $widgets = array_values(array_filter($widgets, static function (array $widget): bool {
            return !empty($widget['visible']);
        }));

        usort($widgets, static function (array $a, array $b): int {
            $countA = (int) ($a['count'] ?? 0);
            $countB = (int) ($b['count'] ?? 0);
            if ($countA > 0 && $countB === 0) {
                return -1;
            }
            if ($countA === 0 && $countB > 0) {
                return 1;
            }
            $order = ['critical' => 0, 'warning' => 1, 'info' => 2];
            $sevA = $order[$a['severity'] ?? 'info'] ?? 3;
            $sevB = $order[$b['severity'] ?? 'info'] ?? 3;
            if ($sevA !== $sevB) {
                return $sevA <=> $sevB;
            }

            return strcmp((string) ($a['title'] ?? ''), (string) ($b['title'] ?? ''));
        });

        return [
            'summary' => $this->buildSummary($widgets),
            'widgets' => $widgets,
        ];
    }

    /**
     * @param array<int, array<string, mixed>> $widgets
     * @return array{critical: int, warning: int, info: int}
     */
    private function buildSummary(array $widgets): array
    {
        $summary = ['critical' => 0, 'warning' => 0, 'info' => 0];

        foreach ($widgets as $widget) {
            $severity = (string) ($widget['severity'] ?? 'info');
            $count = (int) ($widget['count'] ?? 0);
            if ($count <= 0 || !isset($summary[$severity])) {
                continue;
            }
            $summary[$severity] += $count;
        }

        return $summary;
    }

    /**
     * @param array<int, array<string, mixed>> $items
     */
    private function makeWidget(
        string $id,
        string $title,
        string $icon,
        string $severity,
        int $count,
        array $items,
        array $url,
        string $emptyText = 'Нет записей, требующих внимания.'
    ): array {
        return [
            'id' => $id,
            'title' => $title,
            'icon' => $icon,
            'severity' => $severity,
            'count' => $count,
            'items' => $items,
            'url' => $url,
            'url_label' => $count > self::LIST_LIMIT ? 'Все ' . $count : 'Перейти',
            'empty_text' => $emptyText,
            'visible' => true,
        ];
    }

    private function buildLicensesExpiredWidget(): array
    {
        $today = date('Y-m-d');
        $query = License::find()
            ->alias('l')
            ->innerJoinWith(['software s'], false)
            ->where(['l.is_perpetual' => false])
            ->andWhere(['not', ['l.valid_until' => null]])
            ->andWhere(['<', 'l.valid_until', $today])
            ->orderBy(['l.valid_until' => SORT_ASC, 's.name' => SORT_ASC]);

        $total = (int) (clone $query)->count();
        $licenses = (clone $query)->limit(self::LIST_LIMIT)->all();
        $items = [];

        foreach ($licenses as $license) {
            $items[] = [
                'label' => $license->software ? (string) $license->software->name : '—',
                'meta' => 'истекла ' . $this->formatDate($license->valid_until),
                'url' => ['/software/index'],
            ];
        }

        return $this->makeWidget(
            'licenses_expired',
            'Лицензии истекли',
            'fas fa-key',
            'critical',
            $total,
            $items,
            ['/software/index'],
            'Нет просроченных лицензий.'
        );
    }

    private function buildLicensesExpiringWidget(): array
    {
        $licenseDays = License::EXPIRING_WARNING_DAYS;
        $today = date('Y-m-d');
        $until = date('Y-m-d', strtotime('+' . $licenseDays . ' days'));

        $query = License::find()
            ->alias('l')
            ->innerJoinWith(['software s'], false)
            ->where(['l.is_perpetual' => false])
            ->andWhere(['not', ['l.valid_until' => null]])
            ->andWhere(['>=', 'l.valid_until', $today])
            ->andWhere(['<=', 'l.valid_until', $until])
            ->orderBy(['l.valid_until' => SORT_ASC, 's.name' => SORT_ASC]);

        $total = (int) (clone $query)->count();
        $licenses = (clone $query)->limit(self::LIST_LIMIT)->all();
        $items = [];

        foreach ($licenses as $license) {
            $daysLeft = $this->daysUntil($license->valid_until);
            $items[] = [
                'label' => $license->software ? (string) $license->software->name : '—',
                'meta' => 'до ' . $this->formatDate($license->valid_until),
                'badge' => $daysLeft !== null ? $daysLeft . ' дн.' : 'Скоро',
                'badge_class' => 'bg-warning text-dark',
                'url' => ['/software/index', 'expiring_days' => $licenseDays],
            ];
        }

        return $this->makeWidget(
            'licenses_expiring',
            'Лицензии истекают',
            'fas fa-key',
            'warning',
            $total,
            $items,
            ['/software/index', 'expiring_days' => $licenseDays],
            'Нет лицензий, истекающих в ближайшие ' . $licenseDays . ' дн.'
        );
    }

    private function buildEquipmentInRepairWidget(): array
    {
        $query = Equipment::find()
            ->alias('e')
            ->innerJoin(['ds' => 'dic_equipment_status'], 'ds.id = e.status_id')
            ->where(['ds.status_code' => 'in_repair'])
            ->andWhere(['e.is_deleted' => false, 'e.is_archived' => false])
            ->orderBy(['e.name' => SORT_ASC, 'e.inventory_number' => SORT_ASC]);

        $total = (int) (clone $query)->count();
        $rows = (clone $query)->limit(self::LIST_LIMIT)->all();
        $items = [];

        foreach ($rows as $equipment) {
            $items[] = [
                'label' => $this->equipmentLabel($equipment),
                'url' => ['/arm/view', 'id' => $equipment->id],
            ];
        }

        return $this->makeWidget(
            'equipment_in_repair',
            'Техника в ремонте',
            'fas fa-screwdriver-wrench',
            'warning',
            $total,
            $items,
            ['/arm/index'],
            'Нет техники в ремонте.'
        );
    }

    private function buildWarrantyExpiringWidget(): array
    {
        $today = date('Y-m-d');
        $until = date('Y-m-d', strtotime('+' . self::WARNING_DAYS . ' days'));

        $query = Equipment::find()
            ->where(['is_deleted' => false, 'is_archived' => false])
            ->andWhere(['not', ['warranty_until' => null]])
            ->andWhere(['>=', 'warranty_until', $today])
            ->andWhere(['<=', 'warranty_until', $until])
            ->orderBy(['warranty_until' => SORT_ASC, 'name' => SORT_ASC]);

        $total = (int) (clone $query)->count();
        $rows = (clone $query)->limit(self::LIST_LIMIT)->all();
        $items = [];

        foreach ($rows as $equipment) {
            $daysLeft = $this->daysUntil($equipment->warranty_until);
            $items[] = [
                'label' => $this->equipmentLabel($equipment),
                'meta' => 'до ' . $this->formatDate($equipment->warranty_until),
                'badge' => $daysLeft !== null ? $daysLeft . ' дн.' : 'Скоро',
                'badge_class' => 'bg-warning text-dark',
                'url' => ['/arm/view', 'id' => $equipment->id],
            ];
        }

        return $this->makeWidget(
            'warranty_expiring',
            'Гарантия истекает',
            'fas fa-shield',
            'warning',
            $total,
            $items,
            ['/arm/index'],
            'Нет техники с истекающей гарантией.'
        );
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    private function buildUpsBatteryWidgets(): array
    {
        $dueRows = $this->collectUpsBatteryDueRows();
        if (isset($dueRows['error'])) {
            return [
                $this->makeWidget(
                    'ups_battery_due',
                    'Замена аккумулятора ИБП',
                    'fas fa-car-battery',
                    'warning',
                    0,
                    [],
                    ['/arm/index'],
                    (string) $dueRows['error']
                ),
            ];
        }

        $overdueRows = array_values(array_filter(
            $dueRows,
            static fn(array $row): bool => !empty($row['is_overdue'])
        ));
        $upcomingRows = array_values(array_filter(
            $dueRows,
            static fn(array $row): bool => empty($row['is_overdue'])
        ));

        return [
            $this->makeUpsBatteryWidget(
                'ups_battery_overdue',
                'Замена аккумулятора просрочена',
                'critical',
                $overdueRows,
                'Нет ИБП с просроченной заменой аккумулятора.'
            ),
            $this->makeUpsBatteryWidget(
                'ups_battery_due',
                'Замена аккумулятора ИБП',
                'warning',
                $upcomingRows,
                'Нет ИБП с подходящим сроком замены аккумулятора.'
            ),
        ];
    }

    /**
     * @param array<int, array<string, mixed>> $dueRows
     */
    private function makeUpsBatteryWidget(
        string $id,
        string $title,
        string $severity,
        array $dueRows,
        string $emptyText
    ): array {
        $total = count($dueRows);
        $items = [];

        foreach (array_slice($dueRows, 0, self::LIST_LIMIT) as $row) {
            $item = [
                'label' => $this->equipmentLabelFromParts($row['name'], $row['inventory_number']),
                'meta' => (!empty($row['is_overdue']) ? 'просрочено с ' : 'до ') . $this->formatDate($row['due_date']),
                'url' => ['/arm/view', 'id' => $row['id']],
            ];
            if (!empty($row['is_overdue'])) {
                $item['badge'] = 'Просрочено';
                $item['badge_class'] = 'bg-danger';
            }
            $items[] = $item;
        }

        return $this->makeWidget(
            $id,
            $title,
            'fas fa-car-battery',
            $severity,
            $total,
            $items,
            ['/arm/index'],
            $emptyText
        );
    }

    /**
     * @return array<int, array<string, mixed>>|array{error: string}
     */
    private function collectUpsBatteryDueRows(): array
    {
        $partId = $this->resolvePartId('ИБП');
        $replacedCharId = $this->resolveCharId('Дата замены аккумулятора');
        $lifeCharId = $this->resolveCharId('Срок службы аккумулятора');

        if ($partId === null || $replacedCharId === null || $lifeCharId === null) {
            return ['error' => 'Справочник характеристик ИБП не настроен.'];
        }

        $replacedRows = PartCharValues::find()
            ->select(['equipment_id', 'value_text'])
            ->where(['part_id' => $partId, 'char_id' => $replacedCharId])
            ->andWhere(['not', ['value_text' => null]])
            ->asArray()
            ->all();

        if ($replacedRows === []) {
            return ['error' => 'Нет ИБП с данными о замене аккумулятора.'];
        }

        $lifeRows = PartCharValues::find()
            ->select(['equipment_id', 'value_text', 'value_num'])
            ->where(['part_id' => $partId, 'char_id' => $lifeCharId])
            ->indexBy('equipment_id')
            ->asArray()
            ->all();

        $equipmentIds = array_values(array_unique(array_map(static function (array $row): int {
            return (int) ($row['equipment_id'] ?? 0);
        }, $replacedRows)));

        $equipmentById = Equipment::find()
            ->select(['id', 'name', 'inventory_number'])
            ->where(['id' => $equipmentIds, 'is_deleted' => false, 'is_archived' => false])
            ->indexBy('id')
            ->asArray()
            ->all();

        $today = strtotime(date('Y-m-d'));
        $thresholdTs = strtotime('+' . self::WARNING_DAYS . ' days', $today);
        $dueRows = [];

        foreach ($replacedRows as $row) {
            $equipmentId = (int) ($row['equipment_id'] ?? 0);
            if ($equipmentId <= 0 || !isset($equipmentById[$equipmentId], $lifeRows[$equipmentId])) {
                continue;
            }

            $replacedAt = trim((string) ($row['value_text'] ?? ''));
            if ($replacedAt === '') {
                continue;
            }

            $lifeRow = $lifeRows[$equipmentId];
            $serviceLife = $lifeRow['value_num'] ?? null;
            if ($serviceLife === null || $serviceLife === '') {
                $serviceLife = str_replace(',', '.', trim((string) ($lifeRow['value_text'] ?? '')));
            }
            $serviceLife = (float) $serviceLife;
            if ($serviceLife <= 0) {
                continue;
            }

            $dueDate = $this->computeBatteryDueDate($replacedAt, $serviceLife);
            if ($dueDate === null) {
                continue;
            }
            $dueTs = strtotime($dueDate);
            if ($dueTs === false || $dueTs > $thresholdTs) {
                continue;
            }

            $equipment = $equipmentById[$equipmentId];
            $dueRows[] = [
                'id' => $equipmentId,
                'name' => (string) ($equipment['name'] ?? ''),
                'inventory_number' => (string) ($equipment['inventory_number'] ?? ''),
                'due_date' => $dueDate,
                'is_overdue' => $dueTs < $today,
            ];
        }

        usort($dueRows, static function (array $a, array $b): int {
            return strcmp($a['due_date'], $b['due_date']);
        });

        return $dueRows;
    }

    private function buildNewTasksWidget(): array
    {
        $statusId = DicTaskStatus::find()
            ->select('id')
            ->where(['status_code' => DicTaskStatus::CODE_NEW, 'is_archived' => false])
            ->scalar();

        if ($statusId === false) {
            return $this->makeWidget('tasks_new', 'Новые заявки', 'fas fa-clipboard-list', 'info', 0, [], ['/tasks/index']);
        }

        $query = Tasks::find()
            ->where(['status_id' => (int) $statusId])
            ->orderBy(['created_at' => SORT_DESC, 'id' => SORT_DESC]);

        return $this->buildTasksWidget(
            'tasks_new',
            'Новые заявки',
            'fas fa-clipboard-list',
            'info',
            $query,
            ['/tasks/index'],
            'Нет новых заявок.'
        );
    }

    private function buildTasksInProgressWidget(): array
    {
        $statusIds = DicTaskStatus::find()
            ->select('id')
            ->where([
                'status_code' => [
                    DicTaskStatus::CODE_EXECUTOR_ASSIGNED,
                    DicTaskStatus::CODE_IN_PROGRESS,
                    DicTaskStatus::CODE_ON_HOLD,
                ],
                'is_archived' => false,
            ])
            ->column();

        if ($statusIds === []) {
            return $this->makeWidget('tasks_in_progress', 'Заявки в работе', 'fas fa-spinner', 'warning', 0, [], ['/tasks/index']);
        }

        $query = Tasks::find()
            ->with(['status'])
            ->where(['status_id' => array_map('intval', $statusIds)])
            ->orderBy(['updated_at' => SORT_DESC, 'id' => SORT_DESC]);

        return $this->buildTasksWidget(
            'tasks_in_progress',
            'Заявки в работе',
            'fas fa-spinner',
            'warning',
            $query,
            ['/tasks/index'],
            'Нет заявок в работе.'
        );
    }

    private function buildMyOpenTasksWidget(): array
    {
        $completedIds = DicTaskStatus::getCompletedStatusIds();
        $query = Tasks::find()
            ->with(['status'])
            ->where(['requester_id' => $this->user->id])
            ->orderBy(['updated_at' => SORT_DESC, 'id' => SORT_DESC]);

        if ($completedIds !== []) {
            $query->andWhere(['not in', 'status_id', $completedIds]);
        }
        $cancelledId = DicTaskStatus::find()
            ->select('id')
            ->where(['status_code' => DicTaskStatus::CODE_CANCELLED, 'is_archived' => false])
            ->scalar();
        if ($cancelledId !== false) {
            $query->andWhere(['<>', 'status_id', (int) $cancelledId]);
        }

        return $this->buildTasksWidget(
            'my_open_tasks',
            'Мои открытые заявки',
            'fas fa-clipboard-list',
            'info',
            $query,
            ['/tasks/index'],
            'У вас нет открытых заявок.'
        );
    }

    /**
     * @param \yii\db\ActiveQuery $query
     */
    private function buildTasksWidget(
        string $id,
        string $title,
        string $icon,
        string $severity,
        $query,
        array $url,
        string $emptyText
    ): array {
        $total = (int) (clone $query)->count();
        $tasks = (clone $query)->limit(self::LIST_LIMIT)->all();
        $items = [];

        foreach ($tasks as $task) {
            $description = trim((string) $task->description);
            if (mb_strlen($description) > 80) {
                $description = mb_substr($description, 0, 77) . '…';
            }
            $items[] = [
                'label' => $description !== '' ? $description : 'Заявка #' . $task->id,
                'meta' => $task->status ? (string) $task->status->status_name : '',
                'badge' => '#' . $task->id,
                'badge_class' => 'bg-secondary',
                'url' => ['/tasks/view', 'id' => $task->id],
            ];
        }

        return $this->makeWidget($id, $title, $icon, $severity, $total, $items, $url, $emptyText);
    }

    private function buildWorkTasksPendingReviewWidget(): array
    {
        $search = new WorkTaskSearch();
        $total = $search->countPendingReview([]);

        $pendingId = \app\models\dictionaries\DicWorkTaskStatus::resolveIdByCode(
            \app\models\dictionaries\DicWorkTaskStatus::CODE_PENDING_REVIEW
        );

        $items = [];
        if ($pendingId !== null) {
            $tasks = WorkTask::find()
                ->with(['status'])
                ->where(['is_deleted' => false, 'status_id' => $pendingId])
                ->orderBy(['updated_at' => SORT_DESC, 'id' => SORT_DESC])
                ->limit(self::LIST_LIMIT)
                ->all();

            foreach ($tasks as $task) {
                $items[] = [
                    'label' => trim((string) $task->title) !== '' ? (string) $task->title : 'Задача #' . $task->id,
                    'badge' => '#' . $task->id,
                    'badge_class' => 'bg-primary',
                    'url' => ['/work-tasks/index'],
                ];
            }
        }

        return $this->makeWidget(
            'work_tasks_pending',
            'Задачи на подтверждение',
            'fas fa-list-check',
            'info',
            $total,
            $items,
            ['/work-tasks/index'],
            'Нет задач, ожидающих подтверждения.'
        );
    }

    private function buildUnsignedCardsWidget(): array
    {
        $query = UserEquipmentCard::find()
            ->alias('c')
            ->innerJoinWith(['user u'], false)
            ->where(['c.is_signed' => false])
            ->orderBy(['u.full_name' => SORT_ASC]);

        $total = (int) (clone $query)->count();
        $cards = (clone $query)->limit(self::LIST_LIMIT)->all();
        $items = [];

        foreach ($cards as $card) {
            $items[] = [
                'label' => $card->user ? (string) $card->user->full_name : 'Пользователь #' . $card->user_id,
                'url' => ['/user-equipment-cards/index'],
            ];
        }

        return $this->makeWidget(
            'unsigned_cards',
            'Неподписанные карточки ТС',
            'fas fa-id-card',
            'warning',
            $total,
            $items,
            ['/user-equipment-cards/index'],
            'Все карточки подписаны.'
        );
    }

    private function buildDeliveryDraftsWidget(): array
    {
        $query = EquipmentDelivery::find()
            ->where(['status' => EquipmentDelivery::STATUS_DRAFT])
            ->orderBy(['updated_at' => SORT_DESC, 'id' => SORT_DESC]);

        $total = (int) (clone $query)->count();
        $rows = (clone $query)->limit(self::LIST_LIMIT)->all();
        $items = [];

        foreach ($rows as $delivery) {
            $label = trim((string) ($delivery->name ?? ''));
            if ($label === '') {
                $label = 'Поставка #' . $delivery->id;
            }
            $items[] = [
                'label' => $label,
                'url' => ['/delivery/index'],
            ];
        }

        return $this->makeWidget(
            'delivery_drafts',
            'Черновики поставок',
            'fas fa-truck',
            'info',
            $total,
            $items,
            ['/delivery/index'],
            'Нет черновиков поставок.'
        );
    }

    private function equipmentLabel(Equipment $equipment): string
    {
        return $this->equipmentLabelFromParts((string) $equipment->name, (string) $equipment->inventory_number);
    }

    private function equipmentLabelFromParts(string $name, string $inventoryNumber): string
    {
        $name = trim($name);
        $inventoryNumber = trim($inventoryNumber);
        if ($name !== '' && $inventoryNumber !== '') {
            return $name . ' — ' . $inventoryNumber;
        }

        return $name !== '' ? $name : ($inventoryNumber !== '' ? $inventoryNumber : '—');
    }

    private function formatDate(?string $value): string
    {
        $value = trim((string) $value);
        if ($value === '') {
            return '—';
        }

        return Yii::$app->formatter->asDate($value, 'php:d.m.Y');
    }

    private function daysUntil(?string $date): ?int
    {
        $date = trim((string) $date);
        if ($date === '') {
            return null;
        }
        $today = strtotime(date('Y-m-d'));
        $target = strtotime($date);
        if ($target === false) {
            return null;
        }

        return (int) floor(($target - $today) / 86400);
    }

    private function resolvePartId(string $name): ?int
    {
        $id = SprParts::find()->select('id')->where(['name' => $name])->scalar();

        return $id !== false ? (int) $id : null;
    }

    private function resolveCharId(string $name): ?int
    {
        $id = SprChars::find()->select('id')->where(['name' => $name])->scalar();

        return $id !== false ? (int) $id : null;
    }

    private function computeBatteryDueDate(string $replacedAt, float $serviceLifeYears): ?string
    {
        $replacedAt = trim($replacedAt);
        if ($replacedAt === '' || $serviceLifeYears <= 0) {
            return null;
        }

        $dt = \DateTime::createFromFormat('Y-m-d', substr($replacedAt, 0, 10));
        if ($dt === false) {
            $dt = \DateTime::createFromFormat('d.m.Y', $replacedAt);
        }
        if ($dt === false) {
            $ts = strtotime($replacedAt);
            if ($ts === false) {
                return null;
            }
            $dt = (new \DateTime())->setTimestamp($ts);
        }

        $months = (int) round($serviceLifeYears * 12);
        if ($months < 1) {
            return null;
        }
        $dt->modify('+' . $months . ' months');

        return $dt->format('Y-m-d');
    }
}
