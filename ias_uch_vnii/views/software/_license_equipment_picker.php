<?php
/**
 * Выбор техники для привязки к лицензии.
 *
 * @var array<int, array<string, mixed>> $equipmentRows
 * @var int[] $selectedEquipmentIds
 */

use yii\helpers\Html;

$equipmentRows = $equipmentRows ?? [];
$selectedEquipmentIds = array_map('intval', $selectedEquipmentIds ?? []);
$selectedMap = array_fill_keys($selectedEquipmentIds, true);
?>
<div class="software-license-equipment-picker mb-0" data-license-equipment-picker>
    <label class="form-label software-license-equipment-picker__search-label" for="license-equipment-search">Поиск техники</label>
    <input type="search"
           class="form-control form-control-sm software-license-equipment-picker__search mb-2"
           id="license-equipment-search"
           placeholder="Поиск по инв. номеру, названию, помещению, ответственному…"
           autocomplete="off"
           data-license-equipment-search>

    <div class="software-license-equipment-picker__list" data-license-equipment-list>
        <?php if ($equipmentRows === []): ?>
            <p class="text-muted small mb-0">В учёте техники нет записей.</p>
        <?php else: ?>
            <?php foreach ($equipmentRows as $row): ?>
                <?php
                $id = (int) ($row['id'] ?? 0);
                if ($id <= 0) {
                    continue;
                }
                $inv = trim((string) ($row['inventory_number'] ?? ''));
                $name = trim((string) ($row['name'] ?? ''));
                $location = trim((string) ($row['location'] ?? '—')) ?: '—';
                $responsible = trim((string) ($row['responsible'] ?? '—')) ?: '—';
                $searchText = mb_strtolower(implode(' ', [
                    $inv,
                    $name,
                    $location,
                    $responsible,
                ]), 'UTF-8');
                $title = $inv !== '' && $name !== '' ? $name . ' — ' . $inv : ($name !== '' ? $name : $inv);
                ?>
                <label class="software-license-equipment-picker__item"
                       data-license-equipment-item
                       data-search="<?= Html::encode($searchText) ?>">
                    <input type="checkbox"
                           class="form-check-input software-license-equipment-picker__checkbox"
                           name="equipment_ids[]"
                           value="<?= $id ?>"
                           <?= isset($selectedMap[$id]) ? 'checked' : '' ?>>
                    <span class="software-license-equipment-picker__body">
                        <span class="software-license-equipment-picker__title"><?= Html::encode($title ?: '—') ?></span>
                        <span class="software-license-equipment-picker__meta text-muted small">
                            Помещение: <?= Html::encode($location) ?>
                            · Ответственный: <?= Html::encode($responsible) ?>
                        </span>
                    </span>
                </label>
            <?php endforeach; ?>
        <?php endif; ?>
    </div>
    <p class="form-text mb-0">Отметьте технику, на которой используется лицензия. Поле необязательное.</p>
</div>
