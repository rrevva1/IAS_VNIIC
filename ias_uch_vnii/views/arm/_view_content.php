<?php
/**
 * Карточка актива (просмотр).
 *
 * @var yii\web\View $this
 * @var app\models\entities\Equipment $model
 * @var array $chars Характеристики из part_char_values
 * @var app\models\entities\EquipHistory[] $history
 * @var bool $isModal
 * @var bool $isHost
 * @var array{monitor?: array, disk?: array, ups?: array} $linkedComponents
 * @var list<array{type_label: string, icon_class: string, id: ?int, label: string, inventory_number: string}> $linkedComponentRows
 * @var array<int, array<string, mixed>> $photos
 */

use app\components\EquipmentCharCatalog;
use yii\helpers\Html;
use yii\helpers\Url;

$isModal = !empty($isModal);

$isOrgTech = EquipmentCharCatalog::isPrinterOrMfuType($model->resolveEquipmentTypeName());
$cartridgeStatus = $isOrgTech
    ? EquipmentCharCatalog::formatCartridgeProcurementStatus($model->description)
    : '';
$printerComment = $isOrgTech
    ? EquipmentCharCatalog::formatPrinterComment($model->description)
    : '';
$equipmentTypeName = $model->resolveEquipmentTypeName() ?: '—';
$status = $model->equipmentStatus;
$statusCode = $status ? (string) $status->status_code : '';
$statusBadgeMap = [
    'in_use' => 'arm-view-status--in-use',
    'in_stock' => 'arm-view-status--stock',
    'in_repair' => 'arm-view-status--repair',
    'writeoff' => 'arm-view-status--writeoff',
    'archived' => 'arm-view-status--archived',
];
$statusBadgeClass = $statusBadgeMap[$statusCode] ?? 'arm-view-status--stock';

$headerIconClass = EquipmentCharCatalog::resolveEquipmentTypeIconClass(
    $equipmentTypeName,
    $model->inventory_number
);

$canEdit = Yii::$app->user->identity
    && (Yii::$app->user->identity->isAdministrator() || (int) $model->responsible_user_id === (int) Yii::$app->user->id);
$isAdmin = Yii::$app->user->identity && Yii::$app->user->identity->isAdministrator();

$displayTitle = trim((string) ($model->name ?: ''));
if ($displayTitle === '') {
    $displayTitle = trim((string) ($model->inventory_number ?: 'Техника'));
}

if (!$isModal) {
    $this->title = $displayTitle;
    $this->params['breadcrumbs'][] = $this->title;
}

$formatDate = static function (?string $date): string {
    if ($date === null || trim($date) === '') {
        return '';
    }
    try {
        return (new \DateTimeImmutable(trim($date)))->format('d.m.Y');
    } catch (\Exception $e) {
        return trim($date);
    }
};

$formatDateTime = static function (?string $date): string {
    if ($date === null || trim($date) === '') {
        return '';
    }
    try {
        return (new \DateTimeImmutable(trim($date)))->format('d.m.Y H:i');
    } catch (\Exception $e) {
        return trim($date);
    }
};

$renderValue = static function ($value, bool $allowEmpty = true): string {
    if ($value === null || $value === '') {
        return $allowEmpty ? '<span class="arm-view-dl__value arm-view-dl__value--empty">—</span>' : '';
    }
    if (is_bool($value)) {
        return Html::tag('span', $value ? 'Да' : 'Нет', ['class' => 'arm-view-dl__value']);
    }

    return Html::tag('span', Html::encode((string) $value), ['class' => 'arm-view-dl__value']);
};

$warrantySummary = '—';
if ($model->warranty_years !== null && $model->warranty_years !== '') {
    $years = (float) $model->warranty_years;
    $yearsLabel = $years == 1 ? '1 год' : (($years >= 2 && $years <= 4) ? $years . ' года' : $years . ' лет');
    $until = $model->getWarrantyUntilDisplay();
    $warrantySummary = $yearsLabel . ($until !== '' ? ', до ' . $until : '');
} elseif ($model->getWarrantyUntilDisplay() !== '') {
    $warrantySummary = 'до ' . $model->getWarrantyUntilDisplay();
}

$charLabels = array_merge([
    'cpu' => 'Процессор',
    'ram' => 'Оперативная память',
    'disk' => 'Накопители',
    'monitor' => 'Монитор',
    'screen_diagonal' => 'Диагональ экрана',
    'monitor_inv' => '№ монитора',
    'hostname' => 'Имя компьютера',
    'ip' => 'IP-адрес',
    'os' => 'Операционная система',
    'ups_battery' => 'Модель аккумулятора',
    'ups_battery_replaced_at' => 'Дата замены аккумулятора',
    'ups_battery_service_life' => 'Срок службы аккумулятора',
], EquipmentCharCatalog::getPrinterMfuCharDisplayLabels());
$isMonitorEquipment = str_contains(mb_strtolower(trim($equipmentTypeName)), 'монитор');
$isHost = !empty($isHost);
$linkedComponentRows = $linkedComponentRows ?? [];
$visibleChars = [];
foreach ($charLabels as $key => $label) {
    if ($key === 'monitor_inv' && $isMonitorEquipment) {
        continue;
    }
    if ($isHost && in_array($key, ['monitor', 'monitor_inv'], true)) {
        continue;
    }
    if (!empty($chars[$key])) {
        $displayValue = $chars[$key];
        if ($key === 'ups_battery_replaced_at') {
            $displayValue = EquipmentCharCatalog::formatPartCharDateDisplay($displayValue);
        } elseif ($key === 'ups_battery_service_life') {
            $displayValue = EquipmentCharCatalog::formatUpsBatteryServiceLifeDisplay($displayValue);
        }
        $visibleChars[$key] = ['label' => $label, 'value' => $displayValue];
    }
}

$eventTypeLabels = [
    'create' => 'Создание записи',
    'update' => 'Изменение данных',
    'move' => 'Перемещение',
    'assign' => 'Назначение ответственного',
    'unassign' => 'Снятие ответственного',
    'status_change' => 'Изменение статуса',
    'maintenance' => 'Обслуживание',
    'writeoff' => 'Списание',
    'archive' => 'Архивация',
    'restore' => 'Восстановление из архива',
];

$relatedTasks = $model->getTasks()->with('status')->orderBy(['created_at' => SORT_DESC])->limit(20)->all();
?>

<div class="arm-view"
     data-equipment-id="<?= (int) $model->id ?>"
     data-can-edit-photos="0">
    <div id="armViewHeaderSlot">
    <header class="arm-view__header">
        <div class="arm-view__header-layout">
            <div class="arm-view__header-icon" aria-hidden="true">
                <i class="fas <?= Html::encode($headerIconClass) ?>"></i>
            </div>
            <div class="arm-view__header-content">
                <div class="arm-view__header-top">
                    <span class="arm-view__type"><?= Html::encode($equipmentTypeName) ?></span>
                    <div class="arm-view__badges">
                        <?php if ($status): ?>
                            <span class="arm-view-badge-status <?= Html::encode($statusBadgeClass) ?>">
                                <?= Html::encode($status->status_name) ?>
                            </span>
                        <?php endif; ?>
                        <?php if ($model->is_archived): ?>
                            <span class="arm-view-badge-status arm-view-status--archived">В архиве</span>
                        <?php endif; ?>
                        <?php if ($cartridgeStatus === EquipmentCharCatalog::CARTRIDGE_ACCOUNTED_LABEL): ?>
                            <span class="arm-view-badge-status arm-view-badge--cartridge-ok"><?= Html::encode($cartridgeStatus) ?></span>
                        <?php elseif ($cartridgeStatus === EquipmentCharCatalog::CARTRIDGE_NOT_ACCOUNTED_LABEL): ?>
                            <span class="arm-view-badge-status arm-view-badge--cartridge-no"><?= Html::encode($cartridgeStatus) ?></span>
                        <?php endif; ?>
                    </div>
                </div>
                <h1 class="arm-view__title"><?= Html::encode($displayTitle) ?></h1>
                <?php if (trim((string) $model->inventory_number) !== '' || trim((string) $model->serial_number) !== ''): ?>
                <ul class="arm-view__meta" role="list">
                    <?php if (trim((string) $model->inventory_number) !== ''): ?>
                    <li class="arm-view__meta-chip">
                        <span class="arm-view__meta-label">Инв. №</span>
                        <span class="arm-view__meta-value"><?= Html::encode($model->inventory_number) ?></span>
                    </li>
                    <?php endif; ?>
                    <?php if (trim((string) $model->serial_number) !== ''): ?>
                    <li class="arm-view__meta-chip">
                        <span class="arm-view__meta-label">Серийный №</span>
                        <span class="arm-view__meta-value"><?= Html::encode($model->serial_number) ?></span>
                    </li>
                    <?php endif; ?>
                </ul>
                <?php endif; ?>
            </div>
        </div>
    </header>
    </div>

    <div class="arm-view__actions">
        <?php if ($canEdit): ?>
            <?= Html::button('<i class="fas fa-pen" aria-hidden="true"></i> Редактировать', [
                'class' => 'btn arm-tool-btn arm-view-btn arm-view-btn--edit',
                'type' => 'button',
                'data-arm-edit' => (int) $model->id,
            ]) ?>
            <?php if (!$model->is_archived && $isAdmin): ?>
                <?= Html::a('<i class="fas fa-box-archive" aria-hidden="true"></i> Архивировать', ['archive', 'id' => $model->id], [
                    'class' => 'btn arm-tool-btn arm-view-btn arm-view-btn--archive',
                    'data' => ['method' => 'post', 'confirm' => 'Переместить эту единицу техники в архив?'],
                ]) ?>
            <?php endif; ?>
        <?php endif; ?>
        <?php if ($isModal): ?>
            <?= Html::button('<i class="fas fa-xmark" aria-hidden="true"></i> Закрыть', [
                'class' => 'btn arm-tool-btn arm-view-btn arm-view-btn--close',
                'type' => 'button',
                'data-bs-dismiss' => 'modal',
            ]) ?>
        <?php else: ?>
            <?= Html::a('<i class="fas fa-arrow-left" aria-hidden="true"></i> К списку', ['index'], [
                'class' => 'btn arm-tool-btn arm-view-btn arm-view-btn--close',
            ]) ?>
        <?php endif; ?>
    </div>

    <?php if ($model->is_archived): ?>
        <div class="alert alert-warning arm-view__alert-archive" role="alert">
            <strong>Единица в архиве.</strong>
            <?php if (trim((string) $model->archive_reason) !== ''): ?>
                <?= Html::encode($model->archive_reason) ?>
            <?php endif; ?>
            <?php $archivedAt = $formatDate($model->archived_at); ?>
            <?php if ($archivedAt !== ''): ?>
                <span class="text-muted"> (<?= Html::encode($archivedAt) ?>)</span>
            <?php endif; ?>
        </div>
    <?php endif; ?>

    <div class="arm-view__grid">
        <section class="arm-view-card" aria-labelledby="arm-view-section-assignment">
            <h2 id="arm-view-section-assignment" class="arm-view-card__title">Закрепление</h2>
            <div class="arm-view-card__body">
                <dl class="arm-view-dl">
                    <div class="arm-view-dl__row">
                        <dt class="arm-view-dl__label">Ответственный</dt>
                        <dd><?= $renderValue($model->responsibleUser ? $model->responsibleUser->getDisplayName() : null) ?></dd>
                    </div>
                    <div class="arm-view-dl__row">
                        <dt class="arm-view-dl__label">Местоположение</dt>
                        <dd><?= $renderValue($model->location ? $model->location->name : null) ?></dd>
                    </div>
                </dl>
            </div>
        </section>

        <section class="arm-view-card" aria-labelledby="arm-view-section-purchase">
            <h2 id="arm-view-section-purchase" class="arm-view-card__title">Закупка и гарантия</h2>
            <div class="arm-view-card__body">
                <dl class="arm-view-dl">
                    <div class="arm-view-dl__row">
                        <dt class="arm-view-dl__label">Поставщик</dt>
                        <dd><?= $renderValue($model->supplier) ?></dd>
                    </div>
                    <div class="arm-view-dl__row">
                        <dt class="arm-view-dl__label">Дата закупки</dt>
                        <dd><?= $renderValue($formatDate($model->purchase_date) ?: null) ?></dd>
                    </div>
                    <div class="arm-view-dl__row">
                        <dt class="arm-view-dl__label">Гарантия</dt>
                        <dd><?= $renderValue($warrantySummary === '—' ? null : $warrantySummary) ?></dd>
                    </div>
                    <?php if ($isOrgTech && $cartridgeStatus !== ''): ?>
                    <div class="arm-view-dl__row">
                        <dt class="arm-view-dl__label">Закупка картриджей</dt>
                        <dd><?= $renderValue($cartridgeStatus) ?></dd>
                    </div>
                    <?php endif; ?>
                </dl>
            </div>
        </section>
    </div>

    <?php if (!empty($linkedComponentRows)): ?>
    <section class="arm-view-section" aria-labelledby="arm-view-linked-title">
        <h2 id="arm-view-linked-title" class="arm-view-section__title">Привязанная техника</h2>
        <ul class="arm-view-linked-list">
            <?php foreach ($linkedComponentRows as $linkedRow): ?>
            <li class="arm-view-linked-list__item">
                <span class="arm-view-linked-list__type" title="<?= Html::encode($linkedRow['type_label']) ?>">
                    <i class="fas <?= Html::encode($linkedRow['icon_class']) ?>" aria-hidden="true"></i>
                    <span class="arm-view-linked-list__type-text"><?= Html::encode($linkedRow['type_label']) ?></span>
                </span>
                <div class="arm-view-linked-list__body">
                    <?php if (!empty($linkedRow['id'])): ?>
                        <?= Html::button(Html::encode($linkedRow['label']), [
                            'class' => 'btn btn-link p-0 arm-view-linked-list__link',
                            'type' => 'button',
                            'data-arm-view' => (int) $linkedRow['id'],
                            'title' => 'Открыть карточку: ' . $linkedRow['label'],
                        ]) ?>
                    <?php else: ?>
                        <span class="arm-view-linked-list__label"><?= Html::encode($linkedRow['label']) ?></span>
                    <?php endif; ?>
                    <?php
                    $linkedInv = trim((string) ($linkedRow['inventory_number'] ?? ''));
                    if ($linkedInv !== '' && $linkedInv !== trim((string) $linkedRow['label'])):
                    ?>
                        <span class="arm-view-linked-list__inv text-muted">Инв. № <?= Html::encode($linkedInv) ?></span>
                    <?php endif; ?>
                </div>
            </li>
            <?php endforeach; ?>
        </ul>
    </section>
    <?php endif; ?>

    <?php if (!empty($visibleChars)): ?>
    <section class="arm-view-section" aria-labelledby="arm-view-config-title">
        <h2 id="arm-view-config-title" class="arm-view-section__title">Конфигурация</h2>
        <div class="arm-view-card">
            <div class="arm-view-specs">
                <?php foreach ($visibleChars as $spec): ?>
                <div class="arm-view-spec">
                    <span class="arm-view-spec__label"><?= Html::encode($spec['label']) ?></span>
                    <span class="arm-view-spec__value"><?= nl2br(Html::encode($spec['value'])) ?></span>
                </div>
                <?php endforeach; ?>
            </div>
        </div>
    </section>
    <?php endif; ?>

    <?= $this->render('_view_photos', [
        'photos' => $photos ?? [],
    ]) ?>

    <?php
    $noteText = $isOrgTech ? $printerComment : trim((string) ($model->description ?? ''));
    if ($noteText !== ''):
    ?>
    <section class="arm-view-section" aria-labelledby="arm-view-note-title">
        <h2 id="arm-view-note-title" class="arm-view-section__title"><?= $isOrgTech ? 'Комментарий' : 'Примечание' ?></h2>
        <div class="arm-view-card">
            <div class="arm-view-card__body" style="padding: 1rem;">
                <p class="mb-0 arm-view-dl__value arm-view-dl__value--pre"><?= nl2br(Html::encode($noteText)) ?></p>
            </div>
        </div>
    </section>
    <?php endif; ?>

    <?php if (!empty($relatedTasks)): ?>
    <section class="arm-view-section" aria-labelledby="arm-view-tasks-title">
        <h2 id="arm-view-tasks-title" class="arm-view-section__title">Связанные заявки</h2>
        <ul class="arm-view-list">
            <?php foreach ($relatedTasks as $t): ?>
            <li class="arm-view-list__item">
                <div>
                    <strong>№<?= (int) $t->id ?></strong>
                    — <?= Html::encode($t->title ?: mb_substr((string) $t->description, 0, 80)) ?>
                    <?php if ($t->status): ?>
                        <span class="badge bg-light text-dark ms-1"><?= Html::encode($t->status->status_name) ?></span>
                    <?php endif; ?>
                    <div class="text-muted small"><?= Html::encode($formatDate($t->created_at)) ?></div>
                </div>
                <?= Html::a('Открыть', ['/tasks/index', 'task' => $t->id], [
                    'class' => 'btn btn-sm arm-view-btn arm-view-btn--link',
                    'target' => '_blank',
                    'rel' => 'noopener',
                ]) ?>
            </li>
            <?php endforeach; ?>
        </ul>
    </section>
    <?php endif; ?>

    <?php if (!empty($history)): ?>
    <section class="arm-view-section" aria-labelledby="arm-view-history-title">
        <h2 id="arm-view-history-title" class="arm-view-section__title">История перемещений и изменений</h2>
        <ul class="arm-view-timeline">
            <?php foreach ($history as $h): ?>
            <?php
                $details = trim($h->getFormattedDetails());
                $commentLabel = $h->getCommentLabel();
                $actorName = $h->changedByUser
                    ? trim((string) ($h->changedByUser->full_name ?: $h->changedByUser->email ?: ''))
                    : '';
            ?>
            <li class="arm-view-timeline__item">
                <div class="arm-view-timeline__date"><?= Html::encode($formatDateTime($h->changed_at)) ?></div>
                <div class="arm-view-timeline__event">
                    <?= Html::encode($eventTypeLabels[$h->event_type] ?? $h->event_type) ?>
                </div>
                <?php if ($details !== ''): ?>
                    <div class="arm-view-timeline__detail"><?= Html::encode($details) ?></div>
                <?php endif; ?>
                <?php if ($actorName !== ''): ?>
                    <div class="arm-view-timeline__actor">Выполнил: <?= Html::encode($actorName) ?></div>
                <?php endif; ?>
                <?php if ($commentLabel !== null): ?>
                    <div class="arm-view-timeline__comment"><?= Html::encode($commentLabel) ?></div>
                <?php endif; ?>
            </li>
            <?php endforeach; ?>
        </ul>
    </section>
    <?php endif; ?>

    <details class="arm-view-service">
        <summary>Служебная информация</summary>
        <div class="arm-view-card mt-2">
            <div class="arm-view-card__body">
                <dl class="arm-view-dl">
                    <div class="arm-view-dl__row">
                        <dt class="arm-view-dl__label">ID в системе</dt>
                        <dd><?= $renderValue($model->id) ?></dd>
                    </div>
                    <div class="arm-view-dl__row">
                        <dt class="arm-view-dl__label">Создано</dt>
                        <dd><?= $renderValue($formatDateTime($model->created_at) ?: null) ?></dd>
                    </div>
                    <div class="arm-view-dl__row">
                        <dt class="arm-view-dl__label">Обновлено</dt>
                        <dd><?= $renderValue($formatDateTime($model->updated_at) ?: null) ?></dd>
                    </div>
                </dl>
            </div>
        </div>
    </details>
</div>
